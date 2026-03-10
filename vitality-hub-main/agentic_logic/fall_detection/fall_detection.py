import os
import sys
import iris
import time
import asyncio
import ssl
import smtplib
import pytz
from datetime import datetime, timedelta
from email.message import EmailMessage
from dotenv import load_dotenv
from agents import set_default_openai_key, set_tracing_disabled
from agents import Agent, Runner, function_tool
from agents.extensions.memory import AdvancedSQLiteSession
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from iris_utils.sql_context import get_schemas_metadata

def _read_description_file(file_name: str) -> str:
    messaging_path = os.path.join(os.path.dirname(__file__), '..', "agent_messages", file_name)
    file = open(messaging_path, "r")
    content = file.read()
    file.close()
    return content

# Initialize environment and IRIS connection
load_dotenv()
set_default_openai_key(os.getenv("OPENAI_API_KEY"))
set_tracing_disabled(True)
args = {'hostname': os.getenv("IRIS_SQL_HOST"), 'port': int(os.getenv("IRIS_SQL_PORT")), 'namespace': os.getenv("IRIS_SQL_NAMESPACE"),
        'username': os.getenv("IRIS_SQL_USERNAME"), 'password': os.getenv("IRIS_SQL_PASSWORD")}
connection = iris.connect(**args)
iris_cursor = connection.cursor()

appliance_schemas = get_schemas_metadata(schema_list=os.getenv("APPLIANCE_SCHEMA").split(","))
wellbeing_schemas = get_schemas_metadata(schema_list=os.getenv("WELLBEING_SCHEMA").split(","))
appliance_desc = _read_description_file("appliance.txt") + f"\nThe database schema has been extracted as follows: {str(appliance_schemas)}"
wellbeing_desc = _read_description_file("wellbeing.txt") + f"\nThe database schema has been extracted as follows: {str(wellbeing_schemas)}"
messaging_desc = _read_description_file("messaging.txt")

session = AdvancedSQLiteSession(
    session_id="conversation_comprehensive",
    create_tables=True,
)

def write(*args) -> None:
    log = open(os.path.join(os.path.dirname(__file__), "fall_detection_output.txt"), "a", encoding="utf-8")
    log.write(f"{datetime.now(pytz.timezone("Europe/London")).strftime('%d %b %Y, %H:%M:%S')}: " + " ".join(str(a) for a in args) + "\n")
    log.flush()
    log.close()

def get_last_widget_time(widget_name: str) -> str | None:
    """This function retrieves the timestamp of the last update time of the specified widget from the IRIS database.
    
    arguments:
    widget_name: A string containing the name of the widget to query.
    
    returns: A string containing the timestamp of the last update time in 'YYYY-MM-DD HH:MM:SS' format, or None if no record is found."""
    iris_cursor.execute(f"SELECT TOP 1 UpdateDateTime FROM BlackBox.WebsiteData WHERE Widget = '{widget_name}' ORDER BY UpdateDateTime DESC")
    result = iris_cursor.fetchone()
    if result:
        return result[0].strftime("%Y-%m-%d %H:%M:%S")
    return None

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
async def handoff_to_agent(agent_name: str, handoff_reason: str) -> dict:
    """Handoff to specified agent for a given reason.
    
    arguments:
    agent_name: The name of the agent to handoff to, either 'Wellbeing Agent' or 'Appliance Agent'.
    handoff_reason: The reason for the handoff. This will be provided as input to the agent, so write it clearly and concisely as a request.

    returns: Status of the execution of this function, and the results of the handoff."""
    if agent_name != "Wellbeing Agent":
        return {"status": "error", "message": "This function only supports handoff to the 'Wellbeing Agent' at this time."}
    
    try:
        wellbeing_agent = Agent(
            name="Wellbeing Agent",
            instructions=wellbeing_desc,
            tools=[check_in_with_patient, send_alert, check_in_with_patient_after_alert, read_sql_db],
        )
        result_stream = Runner.run_streamed(
            wellbeing_agent,
            handoff_reason,
            session=session,
        )
        stream = result_stream.stream_events()

        async for event in stream:
            event_type = event.type
            if event_type == "agent_updated_stream_event":
                write(f"Updating Agent to: {event.new_agent.name}")
            elif event_type == "run_item_stream_event":
                write(f"[RunItem of type '{event.name}' received.]")
                if event.name == "message_output_created":
                    write(f"Message output: \n{event.item.raw_item.content[0].text}\n")
                elif event.name == "tool_called":
                    write(f"Tool '{event.item.raw_item.name}' called with arguments: \n{event.item.raw_item.arguments}\n")
                elif event.name == "tool_output":
                    write(f"Returned output: \n{event.item.raw_item.get('output')}\n")
        write("\n")
        
        if result_stream.is_complete:
            await session.store_run_usage(result_stream)
        return {"status": "success", "data": {"Wellbeing Assistant": result_stream.final_output}}
    except Exception as e:
        return {"status": "error", "message": str(e)}
 
async def main():
    """This function runs the main monitoring loop for fall detection. Checks first for unchecked Alert Widget updates, and if found, triggers the Appliance Agent to process the alert.
    If the Appliance Agent determines that the Wellbeing Agent needs to be notified, it hands off to the Wellbeing Agent to handle the notification and follow-up process.
    The loop continues indefinitely, checking for new alerts every 10 seconds.
    """
    open(os.path.join(os.path.dirname(__file__), "fall_detection_output.txt"), 'w').close()
    write("Starting fall detection monitoring loop...")

    appliance_agent = Agent(
        name="Appliance Agent",
        instructions=appliance_desc,
        tools=[read_sql_db, handoff_to_agent],
        model="gpt-5-mini",
    )

    while True:
        write("\nEntering loop...")
        waiting = True
        try:
            while waiting:
                last_email_time = get_last_widget_time("Email")
                last_alert_time = get_last_widget_time("Alert")
                # if no alert detected, do nothing
                if last_alert_time:
                    # if no email has been sent since this alert was detected, start loop
                    if (not last_email_time) or (last_email_time < last_alert_time):
                        waiting = False
                        write("New alert detected, notifying appliance agent...")
                
                if waiting:
                    write("No new tasks to process. Waiting before checking again...")
                    await asyncio.sleep(10)
                
            write("Generating task list for appliance agent...")

            # TODO: Automate this, doesnt need to be agentic
            task_list = f"""
            Goal: Validate the Alert Widget against the SensitivitySlider Widget to validate whether the Wellbeing Agent needs to notify the circle of care.

            High-level requirements:
            - If the most recent Alert Widget value is smaller than the most recent SensitivitySlider value, notify the Wellbeing Agent.
            - The Wellbeing Agent must then check in with the patient, and send an alert email to the social care team if necessary.
            - If the Wellbeing Agent sends an alert email, it must then check in with the patient again to check their status after the alert.

            Constraints:
            - If there is no SensitivitySlider value, default to 0.5
            - If the Wellbeing Agent does not execute all of the required steps in a single run, handoff to it again with the remaining tasks until all tasks are complete.
            """
            
            write("Starting appliance agent run...")

            result_stream = Runner.run_streamed(
                appliance_agent,
                task_list,
                session=session,
            )
            stream = result_stream.stream_events()
            write(f"\n[Streaming initiated...]") 

            async for event in stream:
                event_type = event.type
                if event_type == "agent_updated_stream_event":
                    write(f"Updating Agent to: {event.new_agent.name}")
                elif event_type == "run_item_stream_event":
                    write(f"[RunItem of type '{event.name}' received.]")
                    if event.name == "message_output_created":
                        write(f"Message output: \n{event.item.raw_item.content[0].text}\n")
                    elif event.name == "tool_called":
                        write(f"Tool '{event.item.raw_item.name}' called with arguments: \n{event.item.raw_item.arguments}\n")
                    elif event.name == "tool_output":
                        write(f"Returned output: \n{event.item.raw_item.get('output')}\n")
            write("\n")
            write("[Streaming completed.]")
            
            if result_stream.is_complete:
                await session.store_run_usage(result_stream)
                tool_usage = await session.get_tool_usage()
                if tool_usage:
                    write("\nTool usage summary:")
                    for tool_name, count, turn in tool_usage:
                        write(f"  {tool_name}: used {count} times in turn {turn}")
                else:
                    write("\nNo tool usage found. \n")
                await asyncio.sleep(10)
            else:
                write("\n [ERROR] Appliance agent run did not complete successfully. \n")
        except KeyboardInterrupt:
            write("Keyboard interrupt received. Exiting loop.")
            break
        except Exception as e:
            write(f"Error in monitoring loop: {e}")
            await asyncio.sleep(20)
            continue
    session.close()

if __name__ == "__main__":
    asyncio.run(main())