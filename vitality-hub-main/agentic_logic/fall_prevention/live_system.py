import os, sys
import pytz
import json
import shutil
import asyncio
from datetime import datetime, timedelta
from agents import Runner
from agents.extensions.memory import AdvancedSQLiteSession
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils.voice_chat.voice_record import record_from_mic
from system_setup import falls_condition
from system_setup import appliance_agent, wellbeing_agent, clinical_agent

def simulate_system(today):
    while today <= datetime.now():
        session = AdvancedSQLiteSession(
            session_id="daily_monitoring",
            create_tables=True,
        )

        check_fall_risk = f"""
        Goal: Validate whether the given patient is a Fall Risk using the given dictionary as your window of context. If there exists agent reports, you should include those in your analysis.

        High-level requirements:
        - The format of the answer returned should be a dictionary where the first key is 'fall_risk' for the Boolean of whether the patient is or is not. The second is 'reasoning'.

        Constraints:
        - Only use the given dictionary. Do not make any inferences based on knowledge from other sources.

        Dictionary: 
        {falls_condition}
        """

        async def get_clinical_risks():
            try:
                result = await Runner.run(clinical_agent, check_fall_risk)
                fall_risk_result = result.final_output
                return {"status": "success", "risk_dict": json.loads(fall_risk_result)}
            except Exception as e:
                return {"status": "error", "message": f"The following error was found: {e}."}

        result = asyncio.run(get_clinical_risks())
        if result.get("status") == "success":
            dict_result =  result.get("risk_dict")
            is_fall_risk = dict_result.get("fall_risk")
            reason =  dict_result.get("fall_risk")
            print(f"The given patient has been identified as {is_fall_risk} wrt being a fall risk. The reason was: \n{reason}")
        else:
            print(f"Failed to query the clinical agent. {result.get("message")}")
            exit()

        if is_fall_risk:
            # Patient requires aggressive monitoring
            # TODO: Check the time in the script and get the orchestrator to query them to request a report is generated of the session.
            # TODO: before calling the appliance agent, generate a summary of the patients lifestyle habits for it to monitor today against
            appliance_tasklist = """"
            Goal: Monitor this high fall risk patient to ensure they do not fall.

            High-level requirements:
            - Analyse the last 24 hours of smart-home logs: light on/off timestamps and kettle use times.
            - Monitor daily Garmin data: total steps, resting heart rate, sleep duration, incident/fall alerts, and nighttime PulseOx if available.
            - Determine a simple 7-day baseline for steps and resting heart rate. 
                - Flag if their step count drops >30% vs baseline for 2 consecutive days.
                - Flag if resting heart rate is >10 bpm above baseline for 2 consecutive days (possible illness/deconditioning).
            - Flag if no steps AND no light/kettle activity by 10:00 local (possible immobility/fall).
            - Flag if steps detected at night without any lights turning on (walking in the dark).
            - Flag any watch incident/fall alert immediately.
            - Flag if 3 or more light activations occur between 22:00-06:00 (possible nocturia/night wandering).

            - Send a concise daily summary and any active flags to the wellbeing agent; send immediate high-priority alerts for possible fall/no-activity or incident alerts.
            """
            wellbeing_tasklist = """"
            Goal: Monitor this high fall risk patient to ensure they do not fall.

            High-level requirements:
            - Check in with the patient in the morning before they get up with a summary of their previous nights sleep and previous days activities in order to advise how to best behave today.
            - On any possible fall/no-activity or incident alert: attempt immediate check-in to confirm safety; if unresponsive or responds requesting aid, provide comfort then alert their care team.
            - Based on the appliance agent's previous day's summary:
                - On step-count drop or elevated resting heart rate: ask about feeling unwell, dizziness, new cough/fever; suggest rest, fluids, and contacting their care team if symptoms persist or worsen.
                - On frequent night-time lights or dark walking: advise keeping night-lights on, clearing paths to bathroom, using the walking aid, and rising slowly from bed.
            - Falls/orthostatic prevention tips (use in check-ins and weekly nudge): rise slowly, pause seated before standing, ankle pumps before walking, adequate daytime fluids; keep walking stick within reach; wear non-slip footwear; keep floors/clutter clear.
            - Document patient responses and acknowledge preferences to adjust future advice and check-in timing.
            """
        else:
            # Patient requires passive monitoring
            appliance_tasklist = ""
            wellbeing_tasklist = ""
        
        today += timedelta(days=1)

async def clinician_view():
    today = datetime.now(pytz.timezone("Europe/London"))
    yesterday = today - timedelta(days=1)
    yesterday = yesterday.strftime("%Y-%m-%d")

    summarise_request = f"Generate a summary of the patient's Garmin data from the past week ending on {yesterday} for their clinician to interprete"
    result = await Runner.run(appliance_agent, summarise_request)
    return result.final_output

async def carer_view():
    today = datetime.now(pytz.timezone("Europe/London"))
    yesterday = today - timedelta(days=1)
    yesterday = yesterday.strftime("%Y-%m-%d")

    summarise_request = f"Generate a summary of the patient's Garmin data from the past week ending on {yesterday} for their family to view. They don't need to know the clinical details, be gentle and informative, not alarming. Provide your summary in a bullet point list"
    result = await Runner.run(appliance_agent, summarise_request)
    return result.final_output

async def patient_view():
    today = datetime.now(pytz.timezone("Europe/London"))
    yesterday = today - timedelta(days=1)
    yesterday = yesterday.strftime("%Y-%m-%d")

    summarise_request = f"Generate a summary of the patient's Garmin data from the past week ending on {yesterday} for them to view. Be warm, comforting and informative, not alarming, and provide some small actionable advice. Your response should be short to avoid this being unread."
    result = await Runner.run(appliance_agent, summarise_request)
    return result.final_output
        
if __name__ == "__main__":
    # Print Clincian Summary + write to outputs
    print("Clinician View: \n")
    print(asyncio.run(clinician_view()))
    print("\n")
    # Print Circle of Care Summary + write to outputs
    print("Circle of Care View: \n")
    print(asyncio.run(carer_view()))
    print("\n")

    width = shutil.get_terminal_size().columns
    print("-" * width)

    # Print Patient Summary + write to outputs
    print("Patient View: \n")
    print(asyncio.run(patient_view()))
    print("\n")

    # Simulate Chat
    # user_content = record_from_mic()
    # print(f"User recorded asking: \n{user_content}")
    
    # start_day = datetime.now() - timedelta(days=1)
    # simulate_system(start_day)