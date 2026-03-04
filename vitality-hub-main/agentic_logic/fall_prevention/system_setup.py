import os, sys
import iris
import time
import ssl
import smtplib
import pytz
import json
from operator import itemgetter
from datetime import datetime, timedelta
from email.message import EmailMessage
from dotenv import load_dotenv
from openai import OpenAI
from agents import set_default_openai_key, set_tracing_disabled
from agents import Agent, Runner, ModelSettings, function_tool
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from iris_utils.sql_context import get_schemas_metadata
from iris_utils.parse_garmin import get_ecgdata, get_hrdata, get_sleepdata

def _find_condition(file_path: str, target_condition: str) -> dict | None:
    condition_names = itemgetter("condition_names")

    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            record = json.loads(line)
            if target_condition in condition_names(record):
                return record
    return None

def _read_description_file(file_name: str) -> str:
    messaging_path = os.path.join(base_dir, os.pardir, "agent_messages", file_name)
    file = open(messaging_path, "r", encoding='utf-8')
    content = file.read()
    file.close()
    return content

# Setup Paths
base_dir = os.path.dirname(__file__)
par_dir = os.path.join(base_dir, os.pardir)
# Agent context
FHIR_inpath = os.path.join(par_dir, "iris_utils/patient/EleanorTurner_FHIR.json")
appliance_schemas = get_schemas_metadata(schema_list=os.getenv("APPLIANCE_SCHEMA").split(","))
wellbeing_schemas = get_schemas_metadata(schema_list=os.getenv("WELLBEING_SCHEMA").split(","))
falls_condition = _find_condition(os.path.join(par_dir, "utils/conditions/nhs_conditions_pages.jsonl"), "Falls")
# Agent Descriptions
appliance_desc = _read_description_file("appliance.txt") + f"\nThe database schema has been extracted as follows: {str(appliance_schemas)}"
clinical_desc = _read_description_file("clinical.txt") + f"\nThe patient's FHIR bundle is located at this file path: {FHIR_inpath}" # could replace this with giving it the patients NHS number, and it then performs the GET request itself through a tool call
wellbeing_desc = _read_description_file("wellbeing.txt") + f"\nThe database schema has been extracted as follows: {str(wellbeing_schemas)}"
messaging_desc = _read_description_file("messaging.txt")

# Result outpaths
clinical_risk_path = os.path.join(base_dir, "outputs/clinical_risks.txt")
tasklist_path = os.path.join(base_dir, "outputs/agent_tasklists.json")
# Patient summary -> generated via the UI during account creation? this was AI generated based on her EPR, then merged with the sample provided
patient_desc = """
**Eleanor Turner**, 82-year-old woman — retired schoolteacher, living alone in her apartment. She has: 
- active Parkinson's disease, 
- orthostatic hypotension, 
- age-related macular degeneration (AMD) - Missed AMD clinic appointment in Mar 2025, 
- osteoporosis, 
- type 2 diabetes, 
- prior neck-of-femur fracture (Feb 2024 total hip replacement), 
- and recent lobar pneumonia (Dec 2025). 

She uses a walking stick, and has home safety rails installed. 

Her daughter **Linda** lives 45 minutes away. Her primary care provider is **NP Davis**."""

# Initialize Environment
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")
set_default_openai_key(os.getenv("OPENAI_API_KEY"))
set_tracing_disabled(True)
client = OpenAI(api_key=api_key)
args = {'hostname': os.getenv("IRIS_SQL_HOST"), 'port': int(os.getenv("IRIS_SQL_PORT")), 'namespace': os.getenv("IRIS_SQL_NAMESPACE"),
        'username': os.getenv("IRIS_SQL_USERNAME"), 'password': os.getenv("IRIS_SQL_PASSWORD")}
connection = iris.connect(**args)
iris_cursor = connection.cursor()

# Define agent tools
@function_tool
def read_sql_db(sql_query: str) -> dict:
    """This function runs one VALID ANSI SQL query 
        (Use the DATEADD function for time arithmetic. 
        Do not include any formatting characters such as triple backticks, '''sql ___ ''' blocks, or newline characters. 
        Do not use the keywords FETCH or LIMIT. Use TOP 1 instead if a single row is needed.
        Do not use tuple comparisons, such as (col1, col2) = (val1, val2). 
        The query must use explicit JOIN ... ON syntax.
        Use aggregation functions such as SUM, AVG, COUNT, etc. so that the query returns minimal rows.) 
        This function returns the result as a JSON object.
        
        arguments:
        query: A valid ANSI SQL query string.

        returns: A JSON object containing the query result or an error message."""
    try:
        iris_cursor.execute(sql_query)
        result = iris_cursor.fetchall()
        desc = iris_cursor.description

        headers = [tuple[0] for tuple in desc]
        formatted_results = [{headers[i]: result[j][i] for i in range(len(headers))} for j in range(len(result))]
        
        return {"status": "success", "data": formatted_results}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@function_tool
def check_in_with_patient(system_prompt: str) -> dict:
    """This function checks in with the patient via the chatbot interface to see if they are okay. 
        If the patient does not respond within the given timeout period, it returns a message indicating no response.

    arguments:
    system_prompt: A string containing the system prompt for the check-in to be written on the chatbot interface.
    
    returns: Status of the execution of this function, and a message indicating the patient's status."""
    def get_input_with_timeout(system_prompt: str, timeout: int) -> str | None:
        """Waits (checking every 30s) for user input within a specified timeout period. Returns None if no input is received, else the user input."""
        try:
            iris_cursor.execute("SELECT MAX(SessionID) FROM Chatbot.History")
            result = iris_cursor.fetchone()
            session_id = str(result[0])
            now = datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S")
            now = datetime.strptime(now, "%Y-%m-%d %H:%M:%S")
            iris_cursor.execute("""
                INSERT INTO Chatbot.History (SessionID, MessageRole, MessageContent, Timestamp)
                VALUES (?, ?, ?, ?)
            """, (session_id, "assistant", system_prompt, now.strftime("%Y-%m-%d %H:%M:%S")))
            connection.commit()
        except Exception as e:
            raise Exception(f"Error storing system_prompt in IRIS: {e}")
        
        timeout_time = now + timedelta(seconds=timeout)
        while datetime.now(pytz.timezone("Europe/London")).replace(microsecond=0, tzinfo=None) < timeout_time:
            try:
                iris_cursor.execute(f"SELECT TOP 1 MessageContent, Timestamp FROM Chatbot.History WHERE SessionID = {session_id} AND MessageRole = 'user' ORDER BY Timestamp DESC")
                result = iris_cursor.fetchone()
                if result:
                    if result[1] - now >= timedelta(seconds=0) and result[1] - now <= timedelta(seconds=timeout):
                        return result[0]
            except Exception as e:
                raise Exception(f"Error checking user response in IRIS: {e}")
            time.sleep(timeout // 5)
        return None
    
    try: 
        patient_reply = get_input_with_timeout(system_prompt, 30)
    except Exception as e:
        return {"status": "error", "message": str(e)}
    
    # TODO: Read the reply to determine if an alert is necessary
    if patient_reply is None or patient_reply.strip() == "":
        return {"status": "success", "message": "No response received from patient. Requesting assistance."}
    else:
        try:
            query = "Insert into BlackBox.WebsiteData (UpdateDateTime, Widget, ApplianceData, UpdateRole) values (?,?,?,?)"
            now = datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S")
            params = [(now, 'Email', 0, "Assistant")]
            iris_cursor.executemany(query, params)  
        except Exception as e:
            raise Exception(f"Error storing empty email in IRIS: {e}")
        return {"status": "success", "message": f"Patient responsed within time: '{patient_reply}'. No further action needed."}

@function_tool
def check_in_with_patient_after_alert() -> dict:
    """This function waits for a patient response from the chatbot interface to see if they are okay. 
        If the patient has previously not responded within a given timeout period, an alert has been sent to their circle of care, and now the system waits for their response to send a follow up alert.
    
    returns: Status of the execution of this function, and a message indicating the patient's status."""
    def get_input_without_timeout(system_prompt: str) -> tuple[str, str]:
        """Waits for user input indefinitely. Returns the timestamp and user input once received."""
        try:
            iris_cursor.execute("SELECT MAX(SessionID) FROM Chatbot.History")
            result = iris_cursor.fetchone()
            session_id = str(result[0])
            now = datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S")
            now = datetime.strptime(now, "%Y-%m-%d %H:%M:%S")
            iris_cursor.execute("""
                INSERT INTO Chatbot.History (SessionID, MessageRole, MessageContent, Timestamp)
                VALUES (?, ?, ?, ?)
            """, (session_id, "assistant", system_prompt, now.strftime("%Y-%m-%d %H:%M:%S")))
            connection.commit()
        except Exception as e:
            raise Exception(f"Error storing system_prompt in IRIS: {e}")

        while True:
            try:
                iris_cursor.execute(f"SELECT TOP 1 MessageContent, Timestamp FROM Chatbot.History WHERE SessionID = {session_id} AND MessageRole = 'user' ORDER BY Timestamp DESC")
                result = iris_cursor.fetchone()
                if result and result[1] >= now:
                    return result[1].strftime("%Y-%m-%d %H:%M:%S"), result[0]
            except Exception as e:
                raise Exception(f"Error checking user response in IRIS: {e}")
            time.sleep(20)
    
    try: 
        system_prompt = "No response was received within 2 minutes. An alert has now been sent to your circle of care. Please reply when ready and we can correct this."
        timestamp_str, patient_reply = get_input_without_timeout(system_prompt)
        return {"status": "success", "message": f"Patient response after alert recorded at {timestamp_str}: '{patient_reply}'. Forward this information to circle of care."}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@function_tool
async def send_alert(alert_type: int) -> dict:
    """This function sends an alert email to the social care team when an input above the threshold is detected, and the patient is non-responsive.

    arguments:
    alert_type: An integer indicating the type of alert to be sent. 1 - Patient non-responsive and requires assistance. 2 - Patient has responded after alert was sent and an update alert needs to be sent.
    
    returns: Status of the execution of this function, and details of the email sent for logging purposes."""
    try:
        if alert_type not in [1, 2]:
            return {"status": "error", "message": "Invalid alert_type. Must be 0, 1, or 2."}
        elif alert_type == 1:
            appliance_names = ["SensitivitySlider", "Alert"]
            appliance_data = {}
            for appliance_name in appliance_names:
                query = f"SELECT TOP 1 ApplianceData, UpdateRole, UpdateDateTime FROM BlackBox.WebsiteData WHERE Widget = '{appliance_name}' ORDER BY UpdateDateTime DESC"
                iris_cursor.execute(query)
                result = iris_cursor.fetchall()
                if result:
                    appliance_data[appliance_name] = {
                        "value": float(result[0][0]),
                        "role": result[0][1],
                        "time": result[0][2].strftime("%Y-%m-%d %H:%M:%S")
                    }
            email_subject = "Alert: Input Above Threshold Detected"
            system_prompt = f"An alert of value {appliance_data['Alert']['value']} was just detected at {appliance_data['Alert']['time']}, which is below the Sensitivity threshold of {appliance_data['SensitivitySlider']['value']} which was set by {appliance_data['SensitivitySlider']['role']}. This prompted a check in with the patient, which proved non-responsive. Please notify the social care team that our patient requires assistance."
        else:
            iris_cursor.execute("SELECT MAX(SessionID) FROM Chatbot.History")
            result = iris_cursor.fetchone()
            session_id = str(result[0])
            iris_cursor.execute(f"SELECT TOP 1 MessageContent, Timestamp FROM Chatbot.History WHERE SessionID = {session_id} AND MessageRole = 'user' ORDER BY Timestamp DESC")
            result = iris_cursor.fetchone()
            patient_reply_time = result[1]
            patient_reply = result[0]
            iris_cursor.execute(f"SELECT TOP 1 Timestamp FROM Chatbot.History WHERE SessionID = {session_id} AND MessageRole = 'assistant' ORDER BY Timestamp DESC")
            result = iris_cursor.fetchone()
            time_taken = int((patient_reply_time - (result[0] - timedelta(minutes=2))).total_seconds() // 60)
            email_subject = "Alert Update: Patient Response Received"
            system_prompt = f"Following the previous alert email, after {time_taken} minutes the patient has now responded stating: '{patient_reply}'. Please inform the social care team of this update."

        # Write the body of the email
        messaging_agent = Agent(
            name="Messaging Agent",
            instructions=messaging_desc,
            tools=[],
            model="gpt-4o-mini",
        )
        response = await Runner.run(
            messaging_agent,
            system_prompt
        )

        # Populate and send the email
        msg = EmailMessage()
        body = response.final_output
        msg['Subject'] = email_subject
        msg['From'] = "areyouprofessor@gmail.com"
        msg['To'] = "saskiaj.sg@gmail.com"
        msg.set_content(body)

        smtp_server = "smtp.gmail.com"
        port = 465  # Port for secure SMTP (SMTP_SSL)
        context = ssl.create_default_context()

        with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
            server.login("areyouprofessor@gmail.com", os.getenv("GMAIL_APP_PASSWORD"))
            server.send_message(msg)
            time.sleep(2)  # Simulate delay for sending email
        
        query = "Insert into BlackBox.WebsiteData (UpdateDateTime, Widget, ApplianceData, UpdateRole) values (?,?,?,?)"
        now = datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S")
        params = [(now, 'Email', alert_type, "Assistant")]
        iris_cursor.executemany(query, params)
        
        return {"status": "success", "data": {"msg_subject": msg['Subject'], "msg_body": body}}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@function_tool
def get_FHIR(file_path: str) -> dict:
    """This function retrieves the Patient Bundle from the given FHIR file path.

    arguments:
    file_path: The file to be read.
    
    returns: Status of the execution of this function, and the FHIR bundle json"""
    try:
        with open(file_path, 'r') as file:
            FHIR_Bundle = json.load(file)
        return {"status": "success", "data": FHIR_Bundle}
    except FileNotFoundError:
        return {"status": "error", "message": "The filepath was not valid."}
    except Exception as e:
        return {"status": "error", "message": f"The following error was found: {e}."}

@function_tool
def interprete_garmin(yesterday_datetime: datetime) -> dict:
    """This function retrieves a summary of the Patient's ECG, HR, and Sleep Data from their Garmin Watch of the week ending on the given datetime.

    arguments:
    yesterday_datetime: The last day of the week that is to be analysed (usually yesterday).
    
    returns: Status of the execution of this function, and a dictionary of the 'ECG Summary', 'HR Summary', and 'Sleep Summary' of the week ending on the given date"""
    sleep_coach = f"""
    # ROLE: Garmin Sleep Performance Coach

    # CONTEXT:
    You are an expert physiological analyst specialized in interpreting Garmin's Firstbeat Analytics sleep data. You translate raw JSON metrics into elite-level coaching insights. You prioritize Heart Rate Variability (HRV), sleep architecture, and stress markers.

    # DATA INTERPRETATION RULES:

    1. RELIABILITY CHECK (The 'retro' Key):
    - If "retro": true -> The data is a manual entry or server-side estimate. Advise the patient that sleep stage accuracy (Deep/REM) is lower.
    - If "retro": false -> High-fidelity sensor data. Trust the metrics fully.

    2. SCORE GRADIENT:
    - 90-100: Elite/Optimal (Rare, peak recovery).
    - 80-89: Good (Productive, healthy recovery).
    - 60-79: Fair (Functional but sub-optimal; "The Gray Zone").
    - Below 60: Poor (High strain, illness, or significant sleep debt).

    3. METRIC DEFINITIONS:
    - overallScore: The executive summary of the night's quality.
    - recoveryScore: Derived from HRV. High = Nervous system is calm. Low = Systemic stress/illness.
    - restfulnessScore: Physical movement. Low = Tossing/turning or poor sleep environment.

    4. FEEDBACK ENUM MAPPING:

    - [HIGH-PERFORMANCE / POSITIVE]
        - POSITIVE_HIGHLY_RECOVERING: Exceptional HRV; the body is aggressively shedding stress.
        - POSITIVE_RECOVERY_EXCELLENT: Peak readiness for physical or mental high-intensity tasks.
        - POSITIVE_LONG_AND_DEEP: Prioritize physical repair; excellent for post-workout recovery.
        - POSITIVE_LONG_AND_REFRESHING: High efficiency in clearing brain "sleep pressure" (adenosine).
        - POSITIVE_LONG_AND_CONTINUOUS: Elite sleep efficiency; no interruptions or fragmentation.
        - POSITIVE_OPTIMAL_STRUCTURE: Perfect ratios of Light, Deep, and REM sleep.
        - POSITIVE_RESTFUL_EVENING: Immediate descent into recovery; no pre-sleep cortisol spikes.

    - [INTERFERENCE / NEGATIVE]
        - NEGATIVE_ALCOHOL_DETECTED: Physiological impairment; high sleeping HR and suppressed HRV.
        - NEGATIVE_HIGH_STRESS: "Fight or Flight" mode during sleep; possible overtraining or illness.
        - NEGATIVE_STRESSFUL_DAY: Daytime stress inhibited the transition into deep recovery.
        - NEGATIVE_UNBALANCED_RECOVERY: Chaotic sleep cycles; usually environmental (noise/heat).
        - NEGATIVE_LONG_AWAKE: High WASO (Wake After Sleep Onset); fragmented sleep.
        - NEGATIVE_LATE_BEDTIME: Circadian disruption; missed the optimal hormonal sleep window.

    # RESPONSE STRUCTURE:
    1. THE HEADLINE: A punchy, one-sentence summary about {yesterday_datetime}'s sleep (e.g., "An elite recovery night with perfect structural balance." or "A restless night with higher strain than normal.")
    2. THE "WIN": Identify the highest sub-score and explain why it's a physiological victory.
    3. THE "BOTTLENECK": Identify the lowest sub-score. Explain the "Why" (referencing ENUMs) and the "So What" (how the patient will feel today).
    4. THE COACH'S ADVICE: Provide one specific, actionable habit change based on the data.

    When providing data, such as total hours of sleep, cross reference it against the patient's baseline / 7-day average to give the patient context for the data.

    # TONE:
    Professional and data-driven. These insights are being interpreted by an orchestrator agent as part of a wider health monitoring system. Therefore, avoid "fluff"; focus on biological impact. Refer to the patient in the third person.

    # INPUT: 

    """
    ecg_analyst = f"""
    # ROLE: ECG Precision Analyst

    # CONTEXT: 
    You are a specialist in cardiac electrophysiology. Your goal is to interpret processed Lead I ECG dictionary data to identify rhythm stability and autonomic balance.

    # DATA INTERPRETATION RULES:
    1. **Rhythm Stability:** 
    - Analyze `sdnn_hrv_ms` and `rr_variance`. High variance in a resting state suggests a healthy "Sinus Arrhythmia," whereas extremely low variance might indicate overtraining or high stress.
    2. **Classification Check:** 
    - Validate the `device_classification`. If it says `SINUS_NORMAL` but `rr_variance` is high, explain the role of the Vagus nerve in heart rate modulation.
    3. **Clinical Context:** 
    - Explain that a Lead I ECG (from a wrist-worn device) is a snapshot of the heart's electrical activity from the left to right arm. Focus on the "timing" of the beats rather than diagnosing structural heart disease.

    # TONE:
    Clinical, precise, and objective. These insights are being interpreted by an orchestrator agent as part of a wider health monitoring system. Therefore, avoid medical jargon unless accompanied by a brief explanation. Refer to the patient in the third person. 

    # INPUT: 

    """
    hr_coach = f"""
    # ROLE: Autonomic Recovery Coach (Time-series Specialist)

    # CONTEXT: 
    You are an expert in autonomic nervous system (ANS) physiology. Your task is to interpret a structured HR analysis report to determine a user's physiological load, stress resilience, and respiratory stability.

    # DATA INTERPRETATION RULES:
    1. **The HR/Stress Correlation:** 
    - Look at `hr_stress_correlation`. 
        - **High (>0.7):** HR is driving stress (physical load/exercise).
        - **Low (<0.3):** Stress is likely psychological or chemical (caffeine, anxiety), as HR and stress are "decoupled."
    2. **Stress Extremes:** 
    - If `is_high_stress_event` is `True`, look at the `stress_score_0_100` max value. Determine if this was a momentary spike or a sustained period of high sympathetic activation.
    3. **Oxygen & Breathing:** 
    - Evaluate `blood_oxygen_spo2` and `respiration_breaths_per_min`. 
        - Flag any `spo2` averages below 95% as potential recovery inhibitors.
        - Note if `respiration` min/max range is wide, which may indicate periods of breath-holding or intense focus ("screen apnea").
    4. **Temporal Context:** 
    - Use the `time_window` to orient your advice. A 60-minute window of high stress in the morning (focus) is different from a 60-minute window of high stress at midnight (poor recovery).

    # TONE:
    Insightful, analytical, and highly personalized. Translate the "Summary Metrics" into a narrative about the patient's day. These insights are being interpreted by an orchestrator agent as part of a wider health monitoring system. Therefore, avoid medical jargon unless accompanied by a brief explanation. Refer to the patient in the third person. 

    # INPUT: 

    """
    try:
        ecg_data = get_ecgdata(end_datetime=yesterday_datetime)
        ecg_response = client.responses.create(
            model="gpt-5.2",
            input= ecg_analyst + json.dumps(ecg_data)
        )
        hr_data = get_hrdata(end_datetime=yesterday_datetime)
        hr_response = client.responses.create(
            model="gpt-5.2",
            input= hr_coach + json.dumps(hr_data)
        )
        sleep_data = get_sleepdata(end_datetime=yesterday_datetime)
        sleep_response = client.responses.create(
            model="gpt-5.2",
            input= sleep_coach + json.dumps(sleep_data)
        )
        return {"status": "success", "data": {"ECG Summary": ecg_response.output_text, "HR Summary": hr_response.output_text, "Sleep Summary": sleep_response.output_text}}
    except Exception as e:
        return {"status": "error", "message": f"The following error was found: {e}."}

# TODO: Tools to be written:
@function_tool
def get_agent_reports() -> dict:
    """This function retrieves the Appliance Agent and Wellbeing Agent's latest daily report.
    
    returns: Status of the execution of this function, the Appliance Agent report, and the Wellbeing Agent report"""
    return {"status": "error", "message": "Neither of the two agents have written daily reports yet."}

@function_tool
def generate_report(file_path: str) -> dict:
    """This function saves the agents latest daily report to the given file path.

    arguments:
    file_path: The file to be written to.
    
    returns: Status of the execution of this function"""
    # Also for the short summary for the wellbeing agent
    # (rn just save to a txt file, eventually store in IRIS DocDB)
    return {"status": "error", "message": "This function has not been implemented yet."}

# Define agents
wellbeing_agent = Agent(
    name="Wellbeing Agent",
    instructions=wellbeing_desc,
    tools=[check_in_with_patient, send_alert, check_in_with_patient_after_alert, read_sql_db, generate_report, get_agent_reports],
    model="gpt-5-mini",
    handoff_description="The Wellbeing Agent is able to interact with the patient directly through a chat interface to give them advice to avoid their clinical risks. They cannot begin an interaction and so their tasklist should be about what to look out for during sessions."
)
appliance_agent = Agent(
    name="Appliance Agent",
    instructions=appliance_desc,
    tools=[read_sql_db, interprete_garmin, generate_report, get_agent_reports],
    handoffs=[wellbeing_agent],
    model="gpt-5-mini",
    handoff_description="The Appliance Agent has access to data about the household's smart devices (lights, kettle) and the patient's Garmin watch, and is able to analyse these to look out for signs of the clinical risks."
)
clinical_agent = Agent(
    name="Clinical Agent",
    instructions=clinical_desc,
    tools=[get_FHIR, get_agent_reports],
    model="gpt-5-mini",
    model_settings = ModelSettings(
        tool_choice="required"
    ),
    handoff_description="The Clinical Agent is an expert medical data analyst specializing in FHIR R4. They have access to the patient's EPR."
)

# To be included if we want the agent tasklists to be dynamically generated
coordinator = Agent(
    name="Multi-agent Coordinator",
    instructions="Analyse and decompose the user's request into sub-tasks, then dispatch each sub-task to the appropriate agent for execution.",
    handoffs=[clinical_agent, appliance_agent, wellbeing_agent],
    model="gpt-5-mini"
)
