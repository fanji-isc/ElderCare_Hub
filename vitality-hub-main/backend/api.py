from fastapi import FastAPI, UploadFile, File, HTTPException, Body
from fastapi.responses import Response, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware

import iris
import json
import os
import tempfile
import requests as _requests
import numpy as np
from scipy.signal import find_peaks
from datetime import datetime, timezone
from openai import OpenAI
from agents import set_default_openai_key, set_tracing_disabled
from agents import Agent, Runner, function_tool
from backend.config import IRIS_HOST, IRIS_PORT, IRIS_NAMESPACE, IRIS_USERNAME, IRIS_PASSWORD
FHIR_BASE = "http://localhost:52773/csp/healthshare/demo/fhir/r4"
FHIR_AUTH = ("_SYSTEM", "demo")
FHIR_HEADERS = {"Accept": "application/fhir+json"}

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins="*",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_openai_client():
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        return None
    return OpenAI(api_key=api_key)

def get_iris():
    conn_str = f"{IRIS_HOST}:{IRIS_PORT}/{IRIS_NAMESPACE}"
    return iris.connect(conn_str, IRIS_USERNAME, IRIS_PASSWORD, sharedmemory=False)

def get_FHIR_from_json() -> dict:
    """This function retrieves the Patient Bundle from the given FHIR file path.
    
    returns: Status of the execution of this function, and the FHIR bundle json"""
    try:
        file_path = os.path.join(os.path.dirname(__file__), os.pardir, "fhirdata", "Frank_Larson_c7c448b0-f1f5-45c2-aa50-2763f799c984.json")
        with open(file_path, 'r') as file:
            FHIR_Bundle = json.load(file)
        return {"status": "success", "data": FHIR_Bundle}
    except FileNotFoundError:
        return {"status": "error", "message": "The filepath was not valid."}
    except Exception as e:
        return {"status": "error", "message": f"The following error was found: {e}."}

# Patient summary could be generated via the UI during account creation in order to provide more details?
def _get_patient_desc():
    return """
           **Frank Larson**, 74-year-old man — retired civil engineer, widowed, living alone at home in Medfield, MA. He has:
            - hypertension,
            - hyperlipidemia,
            - type 2 diabetes,
            - severe right knee osteoarthritis — right total knee replacement (Mar 2024) with good recovery,
            - recurrent orthostatic dizziness/near-falls with dehydration risk (noted Jan 2026; borderline hypernatremia, mild creatinine rise),
            - and major depressive disorder (bereavement-related after spouse's death in Jan 2025; on sertraline).

            Independent ambulation post-TKA; fall-prevention and hydration education in place.

            His son **David** is his primary contact. His primary care provider is **Dr. Sarah Mitchell** (Medfield Family Health Center)."""
    patient_fhir = get_FHIR_from_json()
    if patient_fhir.get("status") == "success":
        patient_fhir = patient_fhir.get("data")
    else:
        raise Exception(detail=patient_fhir.get("message"))
    
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")
    
    example = """
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

    response = client.chat.completions.create(
        model="gpt-5", 
        messages=[
            {
                "role": "system", 
                "content": "You are an expert medical data analyst specializing in FHIR R4 working as part of a Smart Home Hub. "
                            "When given a FHIR bundle, you should analyse the patient's medical history and generate a short summary of them to provide as context to other agents. "
                            "The format of the answer should be plain text. "
                            "Be clear and concise, only include whatever is most necessary. "
                            "DO NOT try and provide any advise on further actions or perform any diagnoses yourself."
            },
            {
                "role": "system",
                "content": f"Your answer should follow the following template: \n{example}"
                
            },
            {
                "role": "user", 
                "content": f"Analyze this FHIR bundle and provide a short summary of their medical history:\n\n{patient_fhir}"
            }
        ]
    )
    return response.choices[0].message.content

def _get_clinical_risks():
    """This function analyses the Patient Bundle from the given FHIR file path to determine what conditions they are at risk for.
    
    returns: The short clinician appropriate summary"""
    return """
            Clinical risk summary (Mr. Frank Larson, 74):
            - High fall and syncope risk: recurrent orthostatic dizziness with two near-falls (2026-01-20); polypharmacy with hypotensive/CNS-active agents (HCTZ, lisinopril, metoprolol, gabapentin, sertraline); beta-blocker-related bradycardia (HR 62-64 bpm); lives alone.
            - Volume depletion/dehydration and electrolyte disturbance: borderline hypernatremia (Na 146 mmol/L) with poor intake; on thiazide diuretic; symptoms of dizziness consistent with volume loss.
            - Acute kidney injury risk: rising creatinine to 1.3 mg/dL (from 1.0 in 2024) in the setting of dehydration plus ACE inhibitor and thiazide (prerenal risk).
            - Metformin-associated lactic acidosis risk: dehydration and reduced renal function increase risk while on metformin.
            - High atherosclerotic cardiovascular disease (ASCVD) risk: age >70, male, long-standing hypertension, type 2 diabetes, and hyperlipidemia (BPs typically 135-150/84-93).
            - Depression-related risks: major depressive disorder after bereavement with ongoing low mood/appetite/sleep disturbance; social isolation (widowed, living alone) increases risk of functional decline and poor adherence.
            """
    patient_fhir = get_FHIR_from_json()
    if patient_fhir.get("status") == "success":
        patient_fhir = patient_fhir.get("data")
    else:
        raise Exception(detail=patient_fhir.get("message"))
    
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")
    
    response = client.chat.completions.create(
        model="gpt-5", 
        messages=[
            {
                "role": "system", 
                "content": "You are an expert medical data analyst specializing in FHIR R4 speaking directly to a clinician. When given a FHIR bundle, you should analyse the patient's medical history to determine what conditions they are at risk for. "
                            "The format of the answer should be plain text. "
                            "Be clear and concise, only include conditions that are high risk so that a clinician can interprete this quickly. "
                            "DO NOT try and provide the clinician with any advise on further actions or perform any diagnoses yourself."
            },
            {
                "role": "user", 
                "content": f"Analyze this FHIR bundle and provide a short summary of their clinical risks:\n\n{patient_fhir}"
            }
        ]
    )
    return response.choices[0].message.content

# ── IRIS Home data endpoints ─────────────────────────────────────────────────────

@app.get("/api/ecg")
def get_ecg(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        
        # Only return the ECG part
        return data.get("ecg", {})
    finally:
        conn.close()

@app.get("/api/hr")
def get_hr(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        
        # Only return the Heart Rate part
        return data.get("hr", {})
    finally:
        conn.close()

@app.get("/api/sleep")
def get_sleep(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        
        return data.get("sleep", {})
    finally:
        conn.close()

@app.get("/api/dailySummary")
def get_dailySummary(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        
        return data.get("dailySummary", {})
    finally:
        conn.close()

@app.get("/api/toilet")
def get_toilet(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        return data.get("toilet", [])
    finally:
        conn.close()

@app.get("/api/gait")
def get_gait(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        return data.get("gait", [])
    finally:
        conn.close()

@app.get("/api/fridge")
def get_fridge(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        return data.get("fridge", [])
    finally:
        conn.close()

@app.get("/api/neighborhood")
def get_neighborhood(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        return data.get("neighborhood", [])
    finally:
        conn.close()

@app.get("/api/phone_calls")
def get_phone_calls(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        return data.get("phoneCalls", [])
    finally:
        conn.close()

@function_tool
def interprete_garmin() -> dict:
    """This function retrieves a summary of the Patient's ECG, HR, and Sleep Data from their Garmin Watch.

    returns: Status of the execution of this function, and a dictionary of the 'ECG Summary', 'HR Summary', and 'Sleep Summary'."""
    def unix_to_utc(timestamp):
        return datetime.fromtimestamp(timestamp / 1000.0, tz=timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')
    
    def get_ecgdata(ECGData):
        """
        Filters raw Garmin ECG data into a concise dictionary optimized for LLM analysis and summarization.
        """
        def analyze_raw_ecg(ecg_readings):
            samples = np.array(ecg_readings["samples"])
            fs = ecg_readings["sampleRate"]  # 128.0 Hz
            
            # look for peaks with a minimum height and distance 
            # (distance=fs/2 ensures we don't pick up T-waves as beats)
            peaks, _ = find_peaks(samples, distance=fs/2, prominence=np.std(samples))
            # RR-intervals in milliseconds: (Difference in indices / sampling rate) * 1000
            rr_intervals = np.diff(peaks) / fs * 1000
            sdnn = float(np.std(rr_intervals))
            max_hr = 60000 / np.min(rr_intervals)
            min_hr = 60000 / np.max(rr_intervals)
            
            analysis_report = {
                "total_beats_detected": len(peaks),
                "mean_rr_interval_ms": round(float(np.mean(rr_intervals)), 2),
                "sdnn_hrv_ms": round(sdnn, 2),
                "estimated_hr_range": f"{round(min_hr)} - {round(max_hr)} bpm",
                "rhythm_stability": {
                    "rr_variance": round(float(np.var(rr_intervals)), 2),
                    "is_regular_rhythm": sdnn < 50  # Simple heuristic for rhythm stability
                },
                "signal_metadata": {
                    "sample_count": len(samples),
                    "sampling_rate_hz": fs
                }
            }
            
            return analysis_report
        
        ecg_list = json.loads(ECGData)

        llm_input = []
        for ecg_json in ecg_list:
            summary = ecg_json.get("summary", {})
            reading = ecg_json.get("reading", {})

            start_time_utc = unix_to_utc(summary.get("startTime", 0))
            analysis_report = analyze_raw_ecg(reading)

            llm_input.append({
                "utc_timestamp": start_time_utc,
                "local_time": summary.get("startTimeLocal"),
                "rhythm_classification": summary.get("rhythmClassification"),
                "metrics": {
                    "average_heart_rate_bpm": summary.get("heartRateAverage"),
                    "rmssd_hrv_ms": summary.get("rmssdHrv"),
                    "lead_type": reading.get("leadType"),
                    "duration_seconds": reading.get("durationInSeconds")
                },
                "calculated_metrics": analysis_report,
                "context": {
                    "mounting_side": summary.get("mountingSide"),
                    "reported_symptoms": summary.get("symptoms", []),
                    "device_info": summary.get("deviceInfo", {}).get("productName", "Garmin Device")
                }
            })
        return llm_input

    def get_hrdata(HRData):
        """
        Filters raw Garmin HR data into a concise dictionary optimized for LLM analysis and summarization.
        """
        hr_json = json.loads(HRData)

        epochs = hr_json.get("epochArray", [])

        # Extract columns based on the provided descriptors
        # 0: timestamp, 1: heartRate, 2: stress, 3: spo2, 4: respiration
        timestamps = [e[0] for e in epochs if e[0] is not None]
        hr_values = [e[1] for e in epochs if e[1] is not None]
        stress_values = [e[2] for e in epochs if e[2] is not None]
        spo2_values = [e[3] for e in epochs if e[3] is not None]
        resp_values = [e[4] for e in epochs if e[4] is not None]

        def get_stats(data):
            if not data: return None
            return {
                "min": float(np.min(data)),
                "max": float(np.max(data)),
                "avg": float(round(np.mean(data), 2)),
                "std_dev": float(round(np.std(data), 2))
            }

        start_time = min(timestamps)
        end_time = max(timestamps)
        duration_minutes = (end_time - start_time) / 60000

        # Check for correlation between Stress and Heart Rate
        correlation = None
        if len(hr_values) == len(stress_values) and len(hr_values) > 1:
            correlation = float(round(np.corrcoef(hr_values, stress_values)[0, 1], 2))

        analysis_report = {
            "time_window": {
                "utc_start_timestamp": unix_to_utc(start_time),
                "utc_end_timestamp": unix_to_utc(end_time),
                "duration_total_minutes": float(round(duration_minutes, 2))
            },
            "summary_metrics": {
                "heart_rate_bpm": get_stats(hr_values),
                "stress_score_0_100": get_stats(stress_values),
                "blood_oxygen_spo2": get_stats(spo2_values),
                "respiration_breaths_per_min": get_stats(resp_values)
            },
            "physiological_insights": {
                "hr_stress_correlation": correlation,
                "data_points_analyzed": len(epochs),
                "is_high_stress_event": any(s > 75 for s in stress_values)
            }
        }
        return analysis_report

    def get_sleepdata(SleepData):
        """
        Filters raw Garmin Sleep data into a concise dictionary optimized for LLM analysis and summarization.
        """
        sleep_list = json.loads(SleepData)

        def sec_to_hms(seconds: int) -> str:
            # Convert Seconds to Hours/Minutes for readability
            h = seconds // 3600
            m = (seconds % 3600) // 60
            return f"{h}h {m}m"

        processed_entries = []
        for sleep_entry in sleep_list:
            # Filter out empty "retro" objects and keep only valid sleep records
            if "calendarDate" in sleep_entry:
                # Basic Totals
                scores = sleep_entry.get("sleepScores", {})

                deep = sleep_entry.get("deepSleepSeconds", 0)
                light = sleep_entry.get("lightSleepSeconds", 0)
                rem = sleep_entry.get("remSleepSeconds", 0)
                awake = sleep_entry.get("awakeSleepSeconds", 0)
                total_sleep_sec = deep + light + rem
                
                architecture = {}
                if total_sleep_sec > 0:
                    architecture = {
                        "deep_pct": round((deep / total_sleep_sec) * 100, 1),
                        "rem_pct": round((rem / total_sleep_sec) * 100, 1),
                        "light_pct": round((light / total_sleep_sec) * 100, 1)
                    }

                naps = sleep_entry.get("napList", [])
                nap_summary = []
                for nap in naps:
                    nap_summary.append({
                        "duration": sec_to_hms(nap.get("napTimeSec", 0)),
                        "time": nap.get("napStartTimestampGMT", "").split("T")[-1][:5]
                    })

                processed_entries.append({
                    "date": sleep_entry["calendarDate"],
                    "total_sleep_time": sec_to_hms(total_sleep_sec),
                    "awake_time_during_sleep": sec_to_hms(awake),
                    "scores": {
                        "overall": scores.get("overallScore"),
                        "recovery": scores.get("recoveryScore"),
                        "restfulness": scores.get("restfulnessScore")
                    },
                    "architecture": architecture,
                    "physiologicals": {
                        "avg_sleep_stress": round(float(sleep_entry.get("avgSleepStress", 0)), 2),
                        "avg_respiration_brpm": sleep_entry.get("averageRespiration"),
                        "restless_moments": sleep_entry.get("restlessMomentCount")
                    },
                    "naps": nap_summary if nap_summary else "NONE",
                    "garmin_feedback": scores.get("feedback", "NONE")
                })

        overall_avg_score = np.mean([e["scores"]["overall"] for e in processed_entries])
        stress_trend = np.mean([e["physiologicals"]["avg_sleep_stress"] for e in processed_entries])

        return {
            "overall_stats": {
                "mean_overall_score": float(round(overall_avg_score, 2)),
                "mean_avg_sleep_stress": float(round(stress_trend, 2)),
                "total_nights_tracked": len(processed_entries)
            },
            "daily_breakdown": processed_entries
        }    

    ecg_analyst = """
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
    sleep_coach = """
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
    1. THE HEADLINE: A punchy, one-sentence summary about their most recent sleep (e.g., "An elite recovery night with perfect structural balance." or "A restless night with higher strain than normal.")
    2. THE "WIN": Identify the highest sub-score and explain why it's a physiological victory.
    3. THE "BOTTLENECK": Identify the lowest sub-score. Explain the "Why" (referencing ENUMs) and the "So What" (how the patient will feel today).
    4. THE COACH'S ADVICE: Provide one specific, actionable habit change based on the data.

    When providing data, such as total hours of sleep, cross reference it against the patient's baseline / 7-day average to give the patient context for the data.

    # TONE:
    Professional and data-driven. These insights are being interpreted by an orchestrator agent as part of a wider health monitoring system. Therefore, avoid "fluff"; focus on biological impact. Refer to the patient in the third person.

    # INPUT: 

    """

    conn = get_iris()
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")
    
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        combined_record = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", "")
        data = json.loads(combined_record) if combined_record else {}
        
        raw_ecg_data = data.get("ecg", {})
        raw_hr_data = data.get("hr", {})
        raw_sleep_data = data.get("sleep", {})
        # garmin_dir = os.path.join(os.path.dirname(__file__), os.pardir, "garmin")
        # file = open(os.path.join(garmin_dir, "ECG.json"), "r", encoding='utf-8')
        # raw_ecg_data = file.read()
        # file.close()
        # file = open(os.path.join(garmin_dir, "heart_rate.json"), "r", encoding='utf-8')
        # raw_hr_data = file.read()
        # file.close()
        # file = open(os.path.join(garmin_dir, "sleep.json"), "r", encoding='utf-8')
        # raw_sleep_data = file.read()
        # file.close()

        ecg_data = get_ecgdata(raw_ecg_data)
        ecg_response = client.responses.create(
            model="gpt-5.2",
            input= ecg_analyst + json.dumps(ecg_data)
        )

        hr_data = get_hrdata(raw_hr_data)
        hr_response = client.responses.create(
            model="gpt-5.2",
            input= hr_coach + json.dumps(hr_data)
        )

        sleep_data = get_sleepdata(raw_sleep_data)
        sleep_response = client.responses.create(
            model="gpt-5.2",
            input= sleep_coach + json.dumps(sleep_data)
        )
        return {"status": "success", "data": {"ECG Summary": ecg_response.output_text, "HR Summary": hr_response.output_text, "Sleep Summary": sleep_response.output_text}}
    except Exception as e:
        return {"status": "error", "message": f"The following error was found: {e}."}
    finally:
        conn.close()

@function_tool
def interprete_home_data() -> dict:
    """This function retrieves a summary of the Patient's Toilet, Fridge, and Light Data from their smart home hub.

    returns: Status of the execution of this function, and a dictionary of the 'Hydration Summary', 'Nutrition Summary', and 'Light Summary'."""
    def get_toiletdata(ToiletData):
        """
        Filters raw Smart Toilet data into a concise dictionary optimized for LLM analysis and summarization.
        """
        daily_analysis = []
        toilet_list = json.loads(ToiletData)
        
        for day in toilet_list:
            readings = day.get("readings", [])
            if not readings:
                continue
            
            # Calculate hydration improvement (Morning vs Last Reading)
            morning_level = readings[0]["colorLevel"]
            last_level = readings[-1]["colorLevel"]
            improvement = morning_level - last_level
            
            daily_analysis.append({
                "date": day["calendarDate"],
                "readings_count": len(readings),
                "morning_status": "Dehydrated" if morning_level >= 5 else "Hydrated",
                "hydration_trend": {
                    "start_level": morning_level,
                    "end_level": last_level,
                    "net_improvement": int(improvement)
                },
                "is_incomplete_data": len(readings) < 3
            })
            
        return daily_analysis
    
    def get_fridgedata(FridgeData):
        """
        Filters raw Smart Fridge data into a concise dictionary optimized for LLM analysis and summarization.
        """
        nutritional_trends = []
        fridge_list = json.loads(FridgeData)
        
        for day in fridge_list:
            nutrition = day.get("dailyNutrition", {})
            meals = day.get("mealsDetected", [])
            alerts = [a["message"] for a in day.get("alerts", [])]
            
            # Protein check: Elderly individuals often need ~1.2g per kg of body weight
            # We flag anything below 60g as a potential risk for muscle loss
            protein_intake = nutrition.get("protein", 0)
            
            nutritional_trends.append({
                "date": day["calendarDate"],
                "safety_summary": {
                    "calories": nutrition.get("calories"),
                    "macronutrients": f"Protein: {protein_intake}g, Carbs: {nutrition.get('carbs')}g, Fat: {nutrition.get('fat')}g",
                    "protein_status": "Adequate" if protein_intake >= 65 else "Low (Sarcopenia Risk)",
                    "hydration_liters": nutrition.get("waterLiters"),
                    "meal_consistency": "Normal" if len(meals) >= 3 else "Irregular/Skipped"
                },
                "cognitive_indicators": {
                    "expired_items_count": len([a for a in alerts if "expires" in a.lower()]),
                    "skipped_meals_flag": any("skipped" in a.lower() for a in alerts)
                },
                "critical_alerts": day.get("alerts", [])
            })

        latest_inventory = fridge_list[-1].get("inventory")
        inventory_str = "["
        for dict in latest_inventory:
            inventory_str += f"{json.dumps(dict)} ,"
        inventory_str = inventory_str[:-2] + "]"
            
        return nutritional_trends, inventory_str

    hydration_coach = """
    ### ROLE: METABOLIC HEALTH COACH

    # CONTEXT: 
    You specialize in hydration, kidney health, and metabolic recovery. You interpret smart toilet data (Urine Color Levels) to provide advice on fluid intake and its impact on heart health.

    # DATA INTERPRETATION RULES:
    1. **Hydration Scale:** 
    - Follows the Armstrong urine color scale. Level 1-2 is very well-hydrated, 3-4 is acceptable, and 5-8 is increasingly dehydrated.
    2. **The "Flush" Trend:** 
    - Look for a downward trend in `colorLevel` throughout the day. If the level stays at 6-8 all day, flag this as a "Chronic Dehydration" risk that will negatively impact the user's Garmin HRV.
    3. **Recovery Link:** 
    - When `morning_status` is "Dehydrated," advise the user to drink 500ml of water before checking their Garmin Body Battery or taking an ECG, as dehydration can cause "false-positive" stress readings.
    4. **Data Gaps:** 
    - If `is_incomplete_data` is True, remind the user that hydration tracking requires consistency to map against their HR trends.

    # TONE: 
    Practical, health-conscious, and supportive.

    # INPUT: 

    """
    nutrition_coach = """
    ### ROLE: GERIATRIC WELLNESS COACH

    # CONTEXT:
    You are a specialist in geriatric nutrition and preventative care. You interpret Smart Fridge and Garmin data to ensure an elderly user is maintaining muscle mass, hydration, and cognitive routine.

    # DATA INTERPRETATION RULES:
    1. **The Anorexia of Aging:** 
    - Prioritize the "Appetite Loss" and "Skipped Meals" fridge alerts. In elderly users, these are not "fasting protocols"—they are high-risk events for falls and weakness.
    2. **Protein & Sarcopenia:** 
    - If protein drops below 60g, advise incorporating whatever high protein items are currently in the inventory to support muscle retention.
    3. **Hydration & Fall Prevention:** 
    - If water is <1.8L, flag that this needs to be compared to the Smart Toilet `colorLevel`. If color is >5, flag a "High Fall Risk" due to potential orthostatic hypotension (dizziness when standing).
    4. **Cognitive Support:** 
    - If the fridge flags many "Expiring soon" items, suggest a simple "Meal of the Day" using those specific items to reduce the user's cognitive load.

    # TONE: 
    Compassionate, vigilant, respectful, and safety-oriented.
    
    # INPUT: 
    
    """
    
    conn = get_iris()
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")
    
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        combined_record = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", "")
        data = json.loads(combined_record) if combined_record else {}
        
        raw_toilet_data = data.get("toilet", {})
        raw_fridge_data = data.get("fridge", {})
        # garmin_dir = os.path.join(os.path.dirname(__file__), os.pardir, "garmin")
        # file = open(os.path.join(garmin_dir, "toilet_hydration.json"), "r", encoding='utf-8')
        # raw_toilet_data = file.read()
        # file.close()
        # file = open(os.path.join(garmin_dir, "fridge.json"), "r", encoding='utf-8')
        # raw_fridge_data = file.read()
        # file.close()
    
        toilet_data = get_toiletdata(raw_toilet_data)
        toilet_response = client.responses.create(
            model="gpt-5.2",
            input= hydration_coach + json.dumps(toilet_data)
        )

        fridge_data, inventory_str = get_fridgedata(raw_fridge_data)
        fridge_response = client.responses.create(
            model="gpt-5.2",
            input= nutrition_coach + f"Current inventory: \n{inventory_str}\n\n Fridge Data: \n{json.dumps(fridge_data)}"
        )

        return {"status": "success", "data": {"Hydration Summary": toilet_response.output_text, "Nutrition Summary": fridge_response.output_text}}
    except Exception as e:
        return {"status": "error", "message": f"The following error was found: {e}."}
    finally:
        conn.close()

# ── AI response endpoints ─────────────────────────────────────────────────────

@app.post("/api/answer")
async def answer(payload: dict = Body(...)):
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    user_text = (payload.get("text") or "").strip()
    if not user_text:
        raise HTTPException(status_code=400, detail="Empty input")

    history = payload.get("messages") or []
    history = history[-5:]
    # history is like: [{"role":"user","content":"..."}, {"role":"assistant","content":"..."}]

    system_msg = {
        "role": "system",
        "content": (
            "You are a calm, friendly elder-care assistant. "
            "Speak clearly, briefly, and reassuringly. "
            "DO NOT give medical diagnoses. "
            "If unsure, suggest contacting a healthcare professional."
        )
    }

    chat = [system_msg] + history + [{"role": "user", "content": user_text}]

    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=chat,
        temperature=0.3,
    )

    answer_text = completion.choices[0].message.content.strip()
    return {"answer": answer_text}

@app.post("/api/answer/stream")
async def answer_stream(payload: dict = Body(...)):
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    user_text = (payload.get("text") or "").strip()
    if not user_text:
        raise HTTPException(status_code=400, detail="Empty input")

    history = (payload.get("messages") or [])[-5:]

    # Allow callers to inject a custom system prompt (e.g. RAG context with personal health data).
    # Fall back to the generic elder-care prompt if none is provided.
    custom_system = (payload.get("system") or "").strip()
    system_msg = {
        "role": "system",
        "content": custom_system if custom_system else (
            "You are a calm, friendly elder-care assistant. "
            "Speak clearly, briefly, and reassuringly. "
            "DO NOT give medical diagnoses. "
            "If unsure, suggest contacting a healthcare professional."
        )
    }

    chat = [system_msg] + history + [{"role": "user", "content": user_text}]

    def generate():
        try:
            stream = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=chat,
                temperature=0.3,
                stream=True,
            )
            for chunk in stream:
                delta = chunk.choices[0].delta.content or ""
                if delta:
                    yield json.dumps({"delta": delta}) + "\n"
        except Exception as e:
            yield json.dumps({"error": str(e)}) + "\n"
        yield json.dumps({"done": True}) + "\n"

    return StreamingResponse(generate(), media_type="application/x-ndjson")

@app.post("/api/transcribe")
async def transcribe(file: UploadFile = File(...)):
    client = get_openai_client()
    if client is None:
        return {"error": "OPENAI_API_KEY not set in api container"}

    # Save uploaded audio temporarily
    suffix = ".webm"
    if file.filename and "." in file.filename:
        suffix = "." + file.filename.split(".")[-1].lower()

    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name

    try:
        with open(tmp_path, "rb") as f:
            r = client.audio.transcriptions.create(
                model="gpt-4o-mini-transcribe",
                file=f,
            )
        return {"transcript": getattr(r, "text", "")}
    except Exception as e:
        print("Transcribe error:", repr(e))
        return {"error": str(e)}
    finally:
        try:
            os.remove(tmp_path)
        except:
            pass

@app.post("/api/speak")
async def speak(payload: dict = Body(...)):
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    text = (payload.get("text") or "").strip()
    if not text:
        raise HTTPException(status_code=400, detail="Empty text")

    try:
        audio = client.audio.speech.create(
            model="gpt-4o-mini-tts",
            # voice="alloy",
            voice="marin",
            input=text,
        )
        return Response(
            content=audio.read(),
            media_type="audio/mpeg",
        )
    except Exception as e:
        print("TTS error:", repr(e))
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/good_morning")
def morning_message():
    return """Good morning, Frank — I'm glad you're up. 
                Your Garmin and home sensors show a very restless, short night of sleep, only one meal yesterday with low protein, and dark morning urine — that combination raises your dizziness/fall risk today. 
                Please sip 250-500 ml of water slowly now, have a small protein snack (two eggs, turkey slices, or Greek yogurt are easy options), and avoid getting up or walking alone right away: sit for a minute before standing and take slow, supported steps if you need to move. 
                Rest through the morning, try to add more fluids and a bit more protein over the next few hours, and if you feel faint, have chest pain, or become very confused, call emergency services or contact Dr. Mitchell (or David) right away."""
# async def morning_message():
    # # TODO: test if this is even necessary
    # api_key = os.environ.get("OPENAI_API_KEY")
    # if api_key:
    #     set_default_openai_key(api_key)
    #     set_tracing_disabled(True)
    # else:
    #     raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    # triage_desc = f"""
    # ### ROLE: ELDERLY SYSTEMIC RISK ANALYST

    # # CONTEXT:
    # You are a Senior Clinical Data Scientist specializing in Geriatric Health. You analyze data from five distinct health monitoring systems (ECG, HR, Sleep, Hydration, and Nutrition) to create a unified safety and recovery profile for an elderly user.
 
    # # INTERPRETATION FRAMEWORK
    # You must cross-reference the data provided using the following clinical logic:
    # 1. **Hydration-Cardiac Link:** 
    # - Correlate Smart Toilet `colorLevel` with ECG `sdnn_hrv_ms`. Dark urine (Level 5+) + low HRV (SDNN < 30) = High risk for orthostatic hypotension (dizziness when standing).
    # 2. **Nutrition-Sleep-Stability Chain:** 
    # - Connect `protein_intake` (Fridge) with `deep_pct` and `restless_moments` (Sleep). Low protein or skipped meals in the elderly often trigger poor deep sleep and increased nighttime restlessness, which is a fall risk.
    # 3. **The Digestion Tax:** 
    # - Compare Fridge `last_meal_time` with Sleep `avg_sleep_stress`. If dinner is late, explain how it prevents the heart rate from dropping, stealing recovery time.
    # 4. **Geriatric Safety Flags:** 
    # - **Critical:** "Appetite Loss" or "Skipped Meals" (Fridge) + "Rising Sleep Stress" (Sleep).
    # - **Warning:** Low `spo2` (HR) + High `respiration` (HR/Sleep) + "Dehydration" (Toilet).

    # # OUTPUT STRUCTURE
    # Your response must follow this template:

    # ---
    # ### ⚠️ OVERALL RISK LEVEL: [LOW | ELEVATED | CRITICAL]
    # **Primary Driver:** [Identify the #1 system causing the risk today]

    # #### 1. THE "WHY" (Unified Insight)
    # [A concise narrative explaining how the different data points are interacting. E.g., "The user is electrically stable but physically vulnerable due to under-fueling and dehydration."]

    # #### 2. CROSS-SYSTEM CORRELATIONS
    # * **[Link 1]:** (e.g., Nutrition vs. Sleep)
    # * **[Link 2]:** (e.g., Hydration vs. Cardiac)

    # #### 3. GUARDIAN ACTION ITEMS
    # * **Immediate:** [Action to take now, e.g., Drink 500ml water]
    # * **Daily Goal:** [Nutritional or activity adjustment]
    # * **Watch For:** [Clinical symptom to observe, e.g., Dizziness, gait changes]
    # ---
    # """
    # triage_agent = Agent(
    #     name="Triage Agent",
    #     instructions=triage_desc,
    #     tools=[interprete_garmin, interprete_home_data],
    #     model="gpt-5-mini"
    # )
    # summarise_request = f"Generate a summary of the patient's Garmin and Home Appliance data for their clinician to interprete."
    # result = await Runner.run(triage_agent, summarise_request)
    # triage_answer = result.final_output

    # patient_desc = _get_patient_desc()
    # wellbeing_desc = f"""
    # ### ROLE: Elder-care assitant

    # # CONTEXT: 
    # You are a calm, friendly elder-care assistant. You are speaking directly to the following patient:

    # {patient_desc}

    # # TONE:
    # Speak clearly, briefly, and reassuringly. 

    # # RESTRICTIONS:
    # DO NOT give medical diagnoses. 
    # If unsure, suggest contacting their healthcare professional.

    # # DATA SUMMARY: 

    # {triage_answer}
    # """
    # wellbeing_agent = Agent(
    #     name="Wellbeing Agent",
    #     instructions=wellbeing_desc,
    #     model="gpt-5-mini"
    # )
    # morning_request = "Provide a good morning message including a gentle summary of what the system has noticed based on their garmin and household data, and some advice for how best to behave today. Avoid returning too long of a message, your response should not require bullet points."
    # result = await Runner.run(wellbeing_agent, morning_request)
    # answer_text = result.final_output

    # return {"answer": answer_text}

@app.get("/api/clinician_summary")
def clinician_overview(patient_id: str = ""):
    # --- Original hardcoded summary for Mr. Frank Larson (kept as style/format reference) ---
    # return """
    #         Clinical risk summary (Mr. Frank Larson, 74):
    #         - High fall and syncope risk: recurrent orthostatic dizziness with two near-falls (2026-01-20); polypharmacy with hypotensive/CNS-active agents (HCTZ, lisinopril, metoprolol, gabapentin, sertraline); beta-blocker-related bradycardia (HR 62-64 bpm); lives alone.
    #         - Volume depletion/dehydration and electrolyte disturbance: borderline hypernatremia (Na 146 mmol/L) with poor intake; on thiazide diuretic; symptoms of dizziness consistent with volume loss.
    #         - Acute kidney injury risk: rising creatinine to 1.3 mg/dL (from 1.0 in 2024) in the setting of dehydration plus ACE inhibitor and thiazide (prerenal risk).
    #         - Metformin-associated lactic acidosis risk: dehydration and reduced renal function increase risk while on metformin.
    #         - High atherosclerotic cardiovascular disease (ASCVD) risk: age >70, male, long-standing hypertension, type 2 diabetes, and hyperlipidemia (BPs typically 135-150/84-93).
    #         - Depression-related risks: major depressive disorder after bereavement with ongoing low mood/appetite/sleep disturbance; social isolation (widowed, living alone) increases risk of functional decline and poor adherence."""

    # --- Original dead-code string literals (home data supplement, kept for reference) ---
    # """Summary of home data:
    #         - Garmin sleep metrics from the most recent night show severely fragmented sleep (total sleep 2 h 44 m, 112 restless moments), high average sleep stress ~48.3 and a low recovery score (24).
    #         - Home-fridge logs for 2026-02-26 indicate a single eating event with total protein ≈58 g.
    #         - Smart-toilet recordings show repeated morning urine color Level 6 (consistent with relative dehydration).
    #         - ECG-derived HRV (SDNN) is ≈35 ms (above the 30 ms threshold noted in the protocol).
    #         - Labs previously noted borderline hypernatremia and a mild creatinine rise.
    #         - Clinical relevance:
    #             - These concurrent findings—low/late caloric and protein intake, recurrent morning dehydration, and markedly poor nocturnal recovery—are temporally correlated and collectively increase physiologic vulnerability in an older adult (heightened orthostatic and fall risk, impaired overnight autonomic recovery, and potential strain on renal function).
    #             - The SDNN does not meet the low-HRV cutoff, but persistent dehydration and inadequate intake remain important contextual factors when interpreting orthostatic symptoms, fall risk, HRV trends, and renal labs."""

    conn = get_iris()
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT TOP 1 SummaryText FROM MyApp.AISummary WHERE PatientID = ? ORDER BY UpdatedAt DESC",
            [patient_id]
        )
        row = cur.fetchone()
        return row[0] if row else ""
    finally:
        conn.close()

@app.post("/api/clinician_summary/generate")
def generate_clinician_summary(patient_id: str = ""):
    # 1. Fetch FHIR data using existing endpoint functions
    conditions  = get_fhir_conditions(patient_id)
    medications = get_fhir_medications(patient_id)
    vitals      = get_fhir_vitals(patient_id)
    labs        = get_fhir_labs(patient_id)
    bp_trend    = get_fhir_bp_trend(patient_id)

    # 2. Fetch patient demographics
    try:
        patient_bundle = _fhir_get("Patient", {"_id": patient_id})
        entries = patient_bundle.get("entry", [])
        patient_info = _parse_patient(entries[0]["resource"]) if entries else {}
    except Exception:
        patient_info = {}

    # 3. Build prompt context
    name = patient_info.get("name", "Unknown patient")
    birth = patient_info.get("birthDate", "")
    age_str = ""
    if birth:
        try:
            bdate = datetime.strptime(birth, "%Y-%m-%d")
            age_yrs = (datetime.now() - bdate).days // 365
            age_str = f", {age_yrs} years old"
        except Exception:
            pass

    cond_text  = "\n".join(
        f"  - {c['display']} ({c['status']}, onset {c['onset'][:10] if c.get('onset') else 'unknown'})"
        for c in conditions[:20]
    ) or "  None"
    med_text   = "\n".join(
        f"  - {m['drug']} ({m['status']}, {m['dosage']})"
        for m in medications[:20]
    ) or "  None"
    vital_text = "\n".join(
        f"  - {v['display']}: {v['value']} {v['unit']} ({v['date'][:10] if v.get('date') else ''})"
        for v in vitals[:20]
    ) or "  None"
    lab_text   = "\n".join(
        f"  - {l['display']}: {l['value']} {l['unit']} ({l['date'][:10] if l.get('date') else ''})"
        for l in labs[:20]
    ) or "  None"
    bp_text    = "\n".join(
        f"  - {b['date'][:10]}: {b['systolic']}/{b['diastolic']} mmHg"
        for b in bp_trend[-10:]
    ) or "  None"

    context = f"""Patient: {name}{age_str}

Conditions:
{cond_text}

Medications:
{med_text}

Recent Vitals:
{vital_text}

Recent Labs:
{lab_text}

Blood Pressure Trend (most recent readings):
{bp_text}"""

    # 4. Call OpenAI GPT-4o-mini
    # Style reference: the original hardcoded Frank Larson summary above uses titled header line
    # followed by dash-prefixed bullet items covering key geriatric risk domains.
    client = get_openai_client()
    if not client:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    system_prompt = (
        "You are a geriatric clinical risk analyst preparing a concise structured summary for a physician.\n"
        "Format your response exactly like this example — a titled header line, then dash-prefixed bullets:\n\n"
        "Clinical risk summary (Name, Age):\n"
        "- Risk domain 1: concise explanation with supporting data values\n"
        "- Risk domain 2: concise explanation with supporting data values\n\n"
        "Cover the most clinically relevant domains from: fall risk, volume/hydration/electrolytes, "
        "renal function, cardiovascular risk, medication interactions, mental health/cognition.\n"
        "Use plain text only — no markdown, no asterisks, no bold. Start with the highest-priority risk first.\n"
        "Keep each bullet concise but data-rich. Do not invent data not present in the input."
    )

    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Generate a clinical risk summary for this patient:\n\n{context}"},
        ],
        temperature=0.3,
        max_tokens=800,
    )
    summary_text = completion.choices[0].message.content.strip()

    # 5. Upsert into IRIS (delete existing row, insert new)
    conn = get_iris()
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM MyApp.AISummary WHERE PatientID = ?", [patient_id])
        cur.execute(
            "INSERT INTO MyApp.AISummary (PatientID, SummaryText, UpdatedAt) VALUES (?, ?, NOW())",
            [patient_id, summary_text],
        )
    finally:
        conn.close()

    return summary_text
# async def clinician_overview():
    # api_key = os.environ.get("OPENAI_API_KEY")
    # if api_key:
    #     set_default_openai_key(api_key)
    #     set_tracing_disabled(True)
    # else:
    #     raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    # triage_desc = f"""
    # ### ROLE: ELDERLY SYSTEMIC RISK ANALYST

    # # CONTEXT:
    # You are a Senior Clinical Data Scientist specializing in Geriatric Health. You analyze data from five distinct health monitoring systems (ECG, HR, Sleep, Hydration, and Nutrition) to create a unified safety and recovery profile for an elderly user.
 
    # # INTERPRETATION FRAMEWORK
    # You must cross-reference the data provided using the following clinical logic:
    # 1. **Hydration-Cardiac Link:** 
    # - Correlate Smart Toilet `colorLevel` with ECG `sdnn_hrv_ms`. Dark urine (Level 5+) + low HRV (SDNN < 30) = High risk for orthostatic hypotension (dizziness when standing).
    # 2. **Nutrition-Sleep-Stability Chain:** 
    # - Connect `protein_intake` (Fridge) with `deep_pct` and `restless_moments` (Sleep). Low protein or skipped meals in the elderly often trigger poor deep sleep and increased nighttime restlessness, which is a fall risk.
    # 3. **The Digestion Tax:** 
    # - Compare Fridge `last_meal_time` with Sleep `avg_sleep_stress`. If dinner is late, explain how it prevents the heart rate from dropping, stealing recovery time.
    # 4. **Geriatric Safety Flags:** 
    # - **Critical:** "Appetite Loss" or "Skipped Meals" (Fridge) + "Rising Sleep Stress" (Sleep).
    # - **Warning:** Low `spo2` (HR) + High `respiration` (HR/Sleep) + "Dehydration" (Toilet).

    # # OUTPUT STRUCTURE
    # Your response must follow this template:

    # ---
    # ### ⚠️ OVERALL RISK LEVEL: [LOW | ELEVATED | CRITICAL]
    # **Primary Driver:** [Identify the #1 system causing the risk today]

    # #### 1. THE "WHY" (Unified Insight)
    # [A concise narrative explaining how the different data points are interacting. E.g., "The user is electrically stable but physically vulnerable due to under-fueling and dehydration."]

    # #### 2. CROSS-SYSTEM CORRELATIONS
    # * **[Link 1]:** (e.g., Nutrition vs. Sleep)
    # * **[Link 2]:** (e.g., Hydration vs. Cardiac)

    # #### 3. GUARDIAN ACTION ITEMS
    # * **Immediate:** [Action to take now, e.g., Drink 500ml water]
    # * **Daily Goal:** [Nutritional or activity adjustment]
    # * **Watch For:** [Clinical symptom to observe, e.g., Dizziness, gait changes]
    # ---
    # """
    # triage_agent = Agent(
    #     name="Triage Agent",
    #     instructions=triage_desc,
    #     tools=[interprete_garmin, interprete_home_data],
    #     model="gpt-5-mini"
    # )
    # summarise_request = f"Generate a summary of the patient's Garmin and Home Appliance data for their clinician to interprete."
    # result = await Runner.run(triage_agent, summarise_request)
    # triage_answer = result.final_output

    # patient_desc = _get_patient_desc()
    # risks = _get_clinical_risks()
    # clinician_desc = f"""
    # ### ROLE: Elder-care Clinical Assistant

    # # CONTEXT: 
    # You are a elder-care clinical assistant speaking directly to the following patient's clinician:

    # {patient_desc}

    # # TONE:
    # Speak clearly and briefly, providing supporting data wherever possible. The clinician will want as much data as possible so as to perform the analysis themselves.

    # # RESTRICTIONS:
    # DO NOT try and provide any advise on further actions or perform any diagnoses yourself.
    # Do not make clinical decisions, and do not invent data.

    # # DATA SUMMARY: 

    # {triage_answer}
    # """
    # clinical_agent = Agent(
    #     name="Clinical Agent",
    #     instructions=clinician_desc,
    #     model="gpt-5-mini"
    # )
    # summary_request = "Provide a summary for a clinician to interprete of the patient's garmin and household data, and how this is relevant in a clinical context. Avoid returning too long of a message, your response should not require bullet points."
    # result = await Runner.run(clinical_agent, summary_request)
    # answer_text = result.final_output

    # return {"answer": risks + "\n\n" + answer_text}

# ── FHIR proxy endpoints ──────────────────────────────────────────────────────

def _fhir_get(resource: str, params: dict = {}):
    try:
        r = _requests.get(
            f"{FHIR_BASE}/{resource}",
            params=params,
            auth=FHIR_AUTH,
            headers=FHIR_HEADERS,
            timeout=10,
        )
        r.raise_for_status()
        return r.json()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"FHIR error: {e}")

def _parse_patient(p: dict) -> dict:
    name = p.get("name", [{}])[0]
    given = " ".join(name.get("given", []))
    family = name.get("family", "")
    mrn = next((i["value"] for i in p.get("identifier", [])
                 if i.get("type", {}).get("coding", [{}])[0].get("code") == "MR"), None)
    return {
        "id": p.get("id"),
        "name": f"{given} {family}".strip(),
        "birthDate": p.get("birthDate"),
        "gender": p.get("gender"),
        "mrn": mrn,
        "address": p.get("address", [{}])[0],
    }

@app.get("/api/fhir/patients")
def get_fhir_patients():
    bundle = _fhir_get("Patient", {"_count": "100"})
    patients = [_parse_patient(e["resource"]) for e in bundle.get("entry", [])]
    patients.sort(key=lambda p: (p["name"].split() or [""])[-1])
    return patients

@app.get("/api/fhir/patient")
def get_fhir_patient():
    bundle = _fhir_get("Patient", {"_count": "1"})
    entries = bundle.get("entry", [])
    if not entries:
        raise HTTPException(status_code=404, detail="No FHIR patient found")
    return _parse_patient(entries[0]["resource"])

@app.get("/api/fhir/conditions")
def get_fhir_conditions(patient_id: str = ""):
    bundle = _fhir_get("Condition", {"patient": patient_id, "_sort": "-onset-date", "_count": "50"})
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        coding = r.get("code", {}).get("coding", [{}])[0]
        results.append({
            "display": coding.get("display") or r.get("code", {}).get("text", "Unknown"),
            "code": coding.get("code"),
            "status": r.get("clinicalStatus", {}).get("coding", [{}])[0].get("code", "unknown"),
            "onset": r.get("onsetDateTime", r.get("onsetPeriod", {}).get("start", "")),
        })
    return results

@app.get("/api/fhir/medications")
def get_fhir_medications(patient_id: str = ""):
    bundle = _fhir_get("MedicationRequest", {"patient": patient_id, "_sort": "-authoredon", "_count": "50"})
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        med = r.get("medicationCodeableConcept", {})
        coding = med.get("coding", [{}])[0]
        dosage = r.get("dosageInstruction", [{}])[0]
        results.append({
            "drug": coding.get("display") or med.get("text", "Unknown"),
            "status": r.get("status", "unknown"),
            "authored": r.get("authoredOn", ""),
            "dosage": dosage.get("text", ""),
        })
    return results

@app.get("/api/fhir/vitals")
def get_fhir_vitals(patient_id: str = ""):
    bundle = _fhir_get("Observation", {
        "patient": patient_id,
        "category": "vital-signs",
        "_sort": "-date",
        "_count": "100",
    })
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        coding = r.get("code", {}).get("coding", [{}])[0]
        value_q = r.get("valueQuantity", {})
        results.append({
            "display": coding.get("display") or r.get("code", {}).get("text", "Unknown"),
            "value": value_q.get("value"),
            "unit": value_q.get("unit", ""),
            "date": r.get("effectiveDateTime", ""),
        })
    return results

@app.get("/api/fhir/labs")
def get_fhir_labs(patient_id: str = ""):
    bundle = _fhir_get("Observation", {
        "patient": patient_id,
        "category": "laboratory",
        "_sort": "-date",
        "_count": "100",
    })
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        coding = r.get("code", {}).get("coding", [{}])[0]
        value_q = r.get("valueQuantity", {})
        results.append({
            "display": coding.get("display") or r.get("code", {}).get("text", "Unknown"),
            "value": value_q.get("value"),
            "unit": value_q.get("unit", ""),
            "date": r.get("effectiveDateTime", ""),
        })
    return results

@app.get("/api/fhir/procedures")
def get_fhir_procedures(patient_id: str = ""):
    bundle = _fhir_get("Procedure", {"patient": patient_id, "_sort": "-date", "_count": "50"})
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        coding = r.get("code", {}).get("coding", [{}])[0]
        performed = r.get("performedPeriod", {}).get("start") or r.get("performedDateTime", "")
        results.append({
            "display": coding.get("display") or r.get("code", {}).get("text", "Unknown"),
            "status": r.get("status", "unknown"),
            "date": performed,
        })
    return results

@app.get("/api/fhir/immunizations")
def get_fhir_immunizations(patient_id: str = ""):
    bundle = _fhir_get("Immunization", {"patient": patient_id, "_sort": "-date", "_count": "50"})
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        coding = r.get("vaccineCode", {}).get("coding", [{}])[0]
        results.append({
            "vaccine": coding.get("display") or r.get("vaccineCode", {}).get("text", "Unknown"),
            "status": r.get("status", "unknown"),
            "date": r.get("occurrenceDateTime", ""),
            "lotNumber": r.get("lotNumber", ""),
        })
    return results

@app.get("/api/fhir/encounters")
def get_fhir_encounters(patient_id: str = ""):
    bundle = _fhir_get("Encounter", {"patient": patient_id, "_sort": "-date", "_count": "20"})
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        type_coding = r.get("type", [{}])[0].get("coding", [{}])[0]
        provider = r.get("serviceProvider", {}).get("display", "")
        results.append({
            "type": type_coding.get("display") or r.get("type", [{}])[0].get("text", "Unknown"),
            "status": r.get("status", "unknown"),
            "date": r.get("period", {}).get("start", ""),
            "provider": provider,
        })
    return results

@app.get("/api/fhir/appointments")
def get_fhir_appointments(patient_id: str = ""):
    today = datetime.now(timezone.utc).date().isoformat()
    bundle = _fhir_get("Appointment", {
        "patient": patient_id,
        "_sort": "date",
        "_count": "20",
        "date": f"ge{today}",
    })
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        if r.get("status") in ("cancelled", "noshow", "entered-in-error"):
            continue
        service = (
            r.get("serviceType", [{}])[0].get("coding", [{}])[0].get("display")
            or r.get("description", "Appointment")
        )
        practitioner = next(
            (p["actor"]["display"] for p in r.get("participant", [])
             if "Practitioner" in p.get("actor", {}).get("reference", "")),
            ""
        )
        location = next(
            (p["actor"]["display"] for p in r.get("participant", [])
             if "Location" in p.get("actor", {}).get("reference", "")),
            ""
        )
        results.append({
            "status": r.get("status", "unknown"),
            "start":  r.get("start", ""),
            "end":    r.get("end", ""),
            "type":   service,
            "practitioner": practitioner,
            "location":     location,
        })
    return results

@app.get("/api/fhir/bp-trend")
def get_fhir_bp_trend(patient_id: str = ""):
    bundle = _fhir_get("Observation", {
        "patient": patient_id,
        "code": "85354-9",
        "_sort": "date",
        "_count": "100",
    })
    results = []
    for e in bundle.get("entry", []):
        r = e["resource"]
        systolic = next(
            (c["valueQuantity"]["value"] for c in r.get("component", [])
             if c.get("code", {}).get("coding", [{}])[0].get("code") == "8480-6"), None)
        diastolic = next(
            (c["valueQuantity"]["value"] for c in r.get("component", [])
             if c.get("code", {}).get("coding", [{}])[0].get("code") == "8462-4"), None)
        if systolic and diastolic:
            results.append({
                "date": r.get("effectiveDateTime", ""),
                "systolic": systolic,
                "diastolic": diastolic,
            })
    return results