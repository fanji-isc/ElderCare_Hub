from fastapi import FastAPI, UploadFile, File, HTTPException, Body, Query
from fastapi.responses import Response, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware

import iris
import json
import os
import tempfile
import requests as _requests
import numpy as np
from scipy.signal import find_peaks
from datetime import datetime, timezone, timedelta
import openai
from openai import OpenAI
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
        # Fetch the combined record
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
        # Fetch the combined record
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        # Only return the Sleep part
        return data.get("sleep", {})
    finally:
        conn.close()

@app.get("/api/dailySummary")
def get_dailySummary(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        # Only return the Daily Summary part
        return data.get("dailySummary", {})
    finally:
        conn.close()

@app.get("/api/toilet")
def get_toilet(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        # Only return the Toilet part
        return data.get("toilet", [])
    finally:
        conn.close()

@app.get("/api/gait")
def get_gait(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        # Only return the Gait part
        return data.get("gait", [])
    finally:
        conn.close()

@app.get("/api/fridge")
def get_fridge(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        # Only return the Fridge part
        return data.get("fridge", [])
    finally:
        conn.close()

@app.get("/api/neighborhood")
def get_neighborhood(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        # Only return the Neighborhood part
        return data.get("neighborhood", [])
    finally:
        conn.close()

@app.get("/api/phone_calls")
def get_phone_calls(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}
        # Only return the Phone Calls part
        return data.get("phoneCalls", [])
    finally:
        conn.close()

# ── Interprete IRIS Home data endpoints ───────────────────────────────────────

def interprete_garmin(patient_id: str = "") -> dict:
    """This function retrieves a summary of the Patient's ECG, HR, and Sleep Data from their Garmin Watch.

    returns: Status of the execution of this function, and a dictionary of the 'ECG Summary', 'HR Summary', and 'Sleep Summary'."""
    def unix_to_utc(timestamp):
        return datetime.fromtimestamp(timestamp / 1000.0, tz=timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')
    
    def get_ecgdata(ecg_list):
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

    def get_hrdata(hr_json):
        """
        Filters raw Garmin HR data into a concise dictionary optimized for LLM analysis and summarization.
        """
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

    def get_sleepdata(sleep_list):
        """
        Filters raw Garmin Sleep data into a concise dictionary optimized for LLM analysis and summarization.
        """
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

    def get_gaitdata(gait_list):
        # Flatten all sessions across all days for historical context
        all_sessions = [s for day in gait_list for s in day.get("sessions", [])]

        n = len(all_sessions)
        
        avg_speed = sum(x["gaitSpeedMs"] for x in all_sessions) / n
        avg_symmetry = sum(x["stepSymmetryPct"] for x in all_sessions) / n
        avg_variability = sum(x["strideVariabilityPct"] for x in all_sessions) / n
        avg_gct_diff = sum(abs(x["groundContactTimeMs"]["left"] - 
                            x["groundContactTimeMs"]["right"]) for x in all_sessions) / n

        score = 0
        if avg_speed < 0.6: score += 4
        elif avg_speed < 0.8: score += 2
        if avg_symmetry < 75: score += 3
        elif avg_symmetry < 82: score += 2
        if avg_variability > 12: score += 2
        elif avg_variability > 8: score += 1
        if avg_gct_diff > 100: score += 2
        elif avg_gct_diff > 60: score += 1

        risk_level = "high" if score >= 5 else "moderate" if score >= 2 else "low"

        latest_day = max(gait_list, key=lambda x: x["calendarDate"])
        latest_s = latest_day["sessions"][-1]
        
        latest_gct_diff = abs(latest_s["groundContactTimeMs"]["left"] - latest_s["groundContactTimeMs"]["right"])
        latest_stride_diff = abs(latest_s["strideLength"]["leftCm"] - latest_s["strideLength"]["rightCm"])

        return {
            "fall_risk_assessment": {
                "level": risk_level,
                "weighted_score": score,
                "is_concerning": risk_level != "low"
            },
            "latest_snapshot": {
                "date": latest_day["calendarDate"],
                "speed_ms": round(latest_s["gaitSpeedMs"], 2),
                "symmetry_pct": round(latest_s["stepSymmetryPct"], 1),
                "variability_pct": round(latest_s["strideVariabilityPct"], 1),
                "asymmetry": {
                    "gct_delta_ms": latest_gct_diff,
                    "stride_delta_cm": latest_stride_diff,
                    "shorter_stride_side": "left" if latest_s["strideLength"]["leftCm"] < latest_s["strideLength"]["rightCm"] else "right"
                }
            },
            "historical_averages": {
                "avg_walking_speed": round(avg_speed, 2),
                "avg_symmetry": round(avg_symmetry, 1),
                "avg_variability": round(avg_variability, 1),
                "avg_gct_imbalance": round(avg_gct_diff, 0)
            },
            "clinical_flags": {
                "frailty_speed_alert": latest_s["gaitSpeedMs"] < 0.8,
                "high_instability_alert": latest_s["strideVariabilityPct"] > 10.0,
                "significant_limp_detected": latest_gct_diff > 60
            }
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
    gait_strategist = f"""
    # ROLE: Garmin Mobility and Fall Risk Coach

    # CONTEXT:
    You are a Physical Therapist specializing in geriatric biomechanics. You analyze gait dictionaries to detect physical frailty, injury-related guarding (limping), and overall fall risk.

    # DATA INTERPRETATION RULES:
    1. **The Risk Score (0-11):** 
    - You will receive a `weighted_score`.
        - **Score 0-1:** Baseline stability. 
        - **Score 2-4:** Moderate Risk. Likely transient fatigue or minor discomfort.
        - **Score 5+:** High Fall Risk. Requires immediate environmental review (trip hazards) and potentially a mobility aid.
    2. **Acute vs. Chronic (Trend Analysis):** 
    - Compare `latest_snapshot` speed and variability against `historical_averages`. 
        - If `speed_ms` is >10% lower than `avg_walking_speed`, flag as "Acute Mobility Decline."
        - If `variability_pct` is higher than the historical average, the user is currently "unstable" and prone to tripping.
    3. **Asymmetry & Unilateral Pain:** 
    - Use the `asymmetry` object.
        - A `gct_delta_ms` > 60ms indicates a significant "limp." 
        - Identify the `shorter_stride_side`. If the user has a shorter right stride, they are likely "guarding" the right side due to pain or weakness.
    4. **Clinical Thresholds:** 
    - Speed < 0.8 m/s = "The Sixth Vital Sign" warning for frailty.
    - Speed < 0.6 m/s = Critical threshold for loss of independence.

    # RESPONSE STRUCTURE:
    Focus on **Stability** and **Symmetry**. Translate the "GCT Delta" into plain English (e.g. "The user is favoring their left leg").

    # TONE:
    Professional and data-driven. These insights are being interpreted by an orchestrator agent as part of a wider health monitoring system. Therefore, avoid "fluff"; focus on biological impact. Refer to the patient in the third person.

    # INPUT: 

    """

    conn = get_iris()
    client = get_openai_client()

    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        combined_record = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(combined_record) if combined_record else {}
        
        raw_ecg_data = data.get("ecg", [])
        raw_hr_data = data.get("hr", {})
        raw_sleep_data = data.get("sleep", [])
        raw_gait_data = data.get("gait", [])

        ecg_data = get_ecgdata(raw_ecg_data)
        ecg_response = client.responses.create(
            model="gpt-5-nano",
            input= ecg_analyst + json.dumps(ecg_data)
        )

        hr_data = get_hrdata(raw_hr_data)
        hr_response = client.responses.create(
            model="gpt-5-nano",
            input= hr_coach + json.dumps(hr_data)
        )

        sleep_data = get_sleepdata(raw_sleep_data)
        sleep_response = client.responses.create(
            model="gpt-5-nano",
            input= sleep_coach + json.dumps(sleep_data)
        )

        gait_data = get_gaitdata(raw_gait_data)
        gait_response = client.responses.create(
            model="gpt-5-nano",
            input= gait_strategist + json.dumps(gait_data)
        )
        return {"status": "success", "data": {"ECG Summary": ecg_response.output_text, "HR Summary": hr_response.output_text, "Sleep Summary": sleep_response.output_text, "Geriatric Gait Summary": gait_response.output_text}}
    except Exception as e:
        return {"status": "error", "message": f"The following error was found: {e}."}
    finally:
        conn.close()

def interprete_home_data(patient_id: str = "") -> dict:
    """This function retrieves a summary of the Patient's Toilet and Fridge Data from their smart home hub.

    returns: Status of the execution of this function, and a dictionary of the 'Hydration Summary' and 'Nutrition Summary'."""
    def get_toiletdata(toilet_list):
        """
        Filters raw Smart Toilet data into a concise dictionary optimized for LLM analysis and summarization.
        """
        daily_analysis = []
        
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
    
    def get_fridgedata(fridge_list):
        """
        Filters raw Smart Fridge data into a concise dictionary optimized for LLM analysis and summarization.
        """
        nutritional_trends = []
        
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
    - When `morning_status` is "Dehydrated," advise the user to drink some water before checking their Garmin Body Battery or taking an ECG, as dehydration can cause "false-positive" stress readings.
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
    - If water is <2L, flag that this needs to be compared to the Smart Toilet `colorLevel`. If color is >5, flag a "High Fall Risk" due to potential orthostatic hypotension (dizziness when standing).
    4. **Cognitive Support:** 
    - If the fridge flags many "Expiring soon" items, suggest a simple "Meal of the Day" using those specific items to reduce the user's cognitive load.

    # TONE: 
    Compassionate, vigilant, respectful, and safety-oriented.
    
    # INPUT: 
    
    """
    
    conn = get_iris()
    client = get_openai_client()
    
    try:
        irispy = iris.createIRIS(conn)
        # Fetch the combined record
        combined_record = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(combined_record) if combined_record else {}
        
        raw_toilet_data = data.get("toilet", {})
        raw_fridge_data = data.get("fridge", {})
    
        toilet_data = get_toiletdata(raw_toilet_data)
        toilet_response = client.responses.create(
            model="gpt-5-nano",
            input= hydration_coach + json.dumps(toilet_data)
        )

        fridge_data, inventory_str = get_fridgedata(raw_fridge_data)
        fridge_response = client.responses.create(
            model="gpt-5-nano",
            input= nutrition_coach + f"Current inventory: \n{inventory_str}\n\n Fridge Data: \n{json.dumps(fridge_data)}"
        )

        return {"status": "success", "data": {"Hydration Summary": toilet_response.output_text, "Nutrition Summary": fridge_response.output_text}}
    except Exception as e:
        return {"status": "error", "message": f"The following error was found: {e}."}
    finally:
        conn.close()

# TODO: rewrite to be a tool the agent can call if Frank asks about his neighbourhood
@app.get("/api/build-neighbourhood-context")
def build_neighbourhood_context(patient_id: str, first_name: str):
    neighborhoodJson = get_neighborhood(patient_id)

    latest_dict = neighborhoodJson[0] if neighborhoodJson else None
    lines = []
    if latest_dict:
        lines.append("Neighborhood activities this week (each has a booking ID):")
        for a in latest_dict.get("activities", []):
            attendeeNames = ", ".join([x.get("name", "") for x in a.get("attendees", [])])
            suffix = ""
            if attendeeNames:
                extra = f" +{a.get('extraCount')} more" if a.get('extraCount', 0) > 0 else ""
                suffix = f" — attending: {attendeeNames}{extra}"
            lines.append(f" • [ID: {a.get('id', 0)}] {a.get('title', "")}: {a.get('date', "")} at {a.get('time', "")}, {a.get('location', "")} ({a.get('duration', "")}) {suffix}")
        
        lines.append("Recent neighbor activity: ")
        for f in latest_dict.get("feedItems", []):
            lines.append(f" • {f.get('name', "")} {f.get('activity', [])} ({f.get('time', "")})")

        help_posts = latest_dict.get("helpPosts", [])
        requests = [p for p in help_posts if p.get("type", "") == "request"]
        offers   = [p for p in help_posts if p.get("type", "") == "offer"]

        if requests:
            lines.append("Neighbors who need help: ")
            for p in requests:
                lines.append(f" • {p.get('name', "")} ({p.get('category', "")}): {p.get('message', "")}")
        if offers:
            lines.append("Neighbors offering help: ")
            for p in offers:
                lines.append(f" • {p.get('name', "")} ({p.get('category', "")}): {p.get('message', "")}")

        lines.append("")
        
        instructions = f"""
        BOOKING INSTRUCTION: If {first_name} asks to join, book, sign up for, register for, or asks you to pick and sign them up for an activity, then confirm enthusiastically in your normal response that you have successfully registered them. 
        Then, on a brand new line at the very end, append exactly: [[JOIN:ID]] where ID is that activity's booking ID number from the list above. 
        Do NOT speak or mention [[JOIN:ID]] — it is a silent machine code only, never part of the conversation. 
        Always append it whenever {first_name} wants to be signed up. DO NOT sign them up without them explicitly asking to be.
        """
        lines.append(instructions)
    return "\n".join(lines)

def build_step_history(dailySummaryJson: list):
    all_days = sorted(
        [d for d in dailySummaryJson if d.get("calendarDate")],
        key=lambda x: x.get("calendarDate")
    )
    step_history_raw = [d for d in all_days if d.get("totalSteps")][-14:]
    step_history = []
    for d in step_history_raw:
        date_obj = datetime.strptime(d.get("calendarDate"), "%Y-%m-%d")
        formatted_date = date_obj.strftime("%-m/%-d") 
        step_history.append({
            "day": formatted_date,
            "steps": d.get("totalSteps")
        })
    return step_history

def extract_fridge(patient_id: str):
    fridgeJson = get_fridge(patient_id)
    
    latest_dict = max(fridgeJson, key=lambda x: x.get("calendarDate"), default=None)
    if latest_dict:
        inventory_list = latest_dict.get("inventory")
        current_items = [inv.get("item") for inv in inventory_list]
        alerts = latest_dict.get("alerts")
        expiring_items = [a.get("item") for a in alerts if a.get("type") == "expiring"]
        nutrition = latest_dict.get("dailyNutrition")
        meals_list = latest_dict.get("mealsDetected")

        return {
            "waterLiters": nutrition.get("waterLiters"),
            "currentItems": current_items,
            "expiringItems": expiring_items,
            "mealsCount": len(meals_list),
        }
    return {"waterLiters": 50, "currentItems": [], "expiringItems": [], "mealsCount": 0}

def extract_hydration(patient_id: str):
    toiletJson = get_toilet(patient_id)
    
    hydrationNote = ""
    hydrationColorLevel = 0
    latest = max(toiletJson, key=lambda x: x.get("calendarDate"), default=None)
    readings = latest.get("readings")
    latest_reading = max(readings, key=lambda r: r.get("timestamp"), default={})
    hydrationColorLevel = latest_reading.get("colorLevel")
    if hydrationColorLevel > 0:
        levels = [
            (2, "well hydrated"),
            (4, "adequately hydrated"),
            (5, "mildly dehydrated — could drink more water"),
            (6, "moderately dehydrated — needs more fluids"),
            (7, "significantly dehydrated — drinking water is important right now")
        ]        
        hydrationNote = next((note for max_lvl, note in levels if hydrationColorLevel <= max_lvl), "severely dehydrated — needs attention soon")
    dehydrated = "dehydrated" in hydrationNote.lower()
    return hydrationNote, hydrationColorLevel, dehydrated

def extract_gait(patient_id: str):
    gaitJson = get_gait(patient_id)
    
    all_sessions = [s for day in gaitJson for s in day["sessions"]]
    if all_sessions:
        n = len(all_sessions)
        avg_speed       = sum(x["gaitSpeedMs"] for x in all_sessions) / n
        avg_symmetry    = sum(x["stepSymmetryPct"] for x in all_sessions) / n
        avg_variability = sum(x["strideVariabilityPct"] for x in all_sessions) / n
        avg_gct_diff = sum(abs(x["groundContactTimeMs"]["left"] - 
                               x["groundContactTimeMs"]["right"]) 
                           for x in all_sessions) / n
        score = 0
        if avg_speed < 0.6: score += 4
        elif avg_speed < 0.8: score += 2
        if avg_symmetry < 75: score += 3
        elif avg_symmetry < 82: score += 2
        if avg_variability > 12: score += 2
        elif avg_variability > 8: score += 1
        if avg_gct_diff > 100: score += 2
        elif avg_gct_diff > 60: score += 1

        risk_level = "high" if score >= 5 else "moderate" if score >= 2 else "low"
        gaitNote = (f"{risk_level} fall risk — avg walking speed {avg_speed:.2f} m/s, "
                    f"step symmetry {round(avg_symmetry)}%, "
                    f"stride variability {avg_variability:.1f}%, "
                    f"L/R ground contact diff {round(avg_gct_diff)} ms")
    
    gaitConcern = (risk_level != "low")
    
    latest_day = max(gaitJson, key=lambda x: x["calendarDate"])
    s = latest_day["sessions"][-1] 

    gct = s["groundContactTimeMs"]
    stride = s["strideLength"]

    gait_metrics = {
        "symmetry": float(s["stepSymmetryPct"]),
        "variability": float(s["strideVariabilityPct"]),
        "speed": float(s["gaitSpeedMs"]),
        "cadence": float(s["cadence"]),
        "worseStride": min(stride["leftCm"], stride["rightCm"]),
        "worseGCT": max(gct["left"], gct["right"])
    }
    return gaitNote, gaitConcern, gait_metrics

def extract_phone_calls(patient_id: str):
    phoneCallJson = get_phone_calls(patient_id)
    phone_calls = {"phoneCallMinutes": 0, "phoneCallTrend": []}
    
    sorted_calls = sorted(
        phoneCallJson, 
        key=lambda x: str(x.get("calendarDate", ""))
    )
    if sorted_calls:
        last7 = sorted_calls[-7:]
        trend = [float(d.get("totalMinutes", 0)) for d in last7]
        latest = sorted_calls[-1]
        minutes = float(latest.get("totalMinutes", 0)) 
        phone_calls = {"phoneCallMinutes": minutes, "phoneCallTrend": trend}
    return phone_calls

def extract_sleep(patient_id: str):
    sleepJson = get_sleep(patient_id)
    
    hoursAsleep = 0
    filtered_sleep = [
        x for x in sleepJson 
        if x.get("calendarDate") and (
            x.get("deepSleepSeconds") is not None or 
            x.get("lightSleepSeconds") is not None or 
            x.get("remSleepSeconds") is not None
        )
    ]
    if filtered_sleep:
        latest = max(filtered_sleep, key=lambda x: str(x.get("calendarDate", "")), default=None)   
        if latest:
            total_seconds = latest.get("deepSleepSeconds") + latest.get("lightSleepSeconds") + latest.get("remSleepSeconds")
            hoursAsleep = total_seconds / 3600
    return hoursAsleep

# TODO: check where vitals is called to see if more/different keys should be included
@app.get("/api/build-patient-dashboard")
def get_patient_dashboard(patient_id: str):
    dailyJson = get_dailySummary(patient_id)
    latest_dailySummary = max(dailyJson, key=lambda x: x.get("calendarDate"), default=None)

    # extractStress
    aggregator_list = latest_dailySummary.get("allDayStress").get("aggregatorList")
    awake = next((a for a in aggregator_list if a.get("type") == "AWAKE"), {})
    stressLevel = round(awake.get("averageStressLevel"))

    fridge = extract_fridge(patient_id)
    hydrationNote, hydrationColorLevel, dehydrated = extract_hydration(patient_id)
    gaitNote, gaitConcern, gaitMetrics = extract_gait(patient_id)    
    phoneCalls = extract_phone_calls(patient_id)
    hoursAsleep = extract_sleep(patient_id)
    stepHistory = build_step_history(dailyJson)

    return {
        "heartRate": latest_dailySummary.get("currentDayRestingHeartRate") or latest_dailySummary.get("restingHeartRate") or 0,
        "steps": latest_dailySummary.get("totalSteps") or 0,
        "stressLevel": stressLevel,
        "sleepHours": hoursAsleep,
        "hydrationNote": hydrationNote,
        "hydrationColorLevel": hydrationColorLevel,
        "waterLiters": fridge.get("waterLiters"),
        "expiringItems": fridge.get("expiringItems"),
        "currentItems": fridge.get("currentItems"),
        "mealsCount": fridge.get("mealsCount"),
        "phoneCallMinutes": phoneCalls.get("phoneCallMinutes"),
        "phoneCallTrend": phoneCalls.get("phoneCallTrend"),
        "gaitNote": gaitNote,
        "fallRiskAlert": dehydrated and gaitConcern,
        "gaitMetrics": gaitMetrics,
        "stepHistory": stepHistory
    }

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

@app.get("/api/patient-medications")
def get_patient_medications(first_name: str, last_name: str):
    try:
        all_patients = get_fhir_patients()
        
        first_name_lower = first_name.lower()
        last_name_lower = last_name.lower()
        
        target_patient = next(
            (p for p in all_patients if 
            first_name_lower in p['name'].lower() and 
            last_name_lower in p['name'].lower()), 
            None
        )

        if not target_patient:
            raise HTTPException(
                status_code=404, 
                detail=f"Patient {first_name} {last_name} not found in FHIR records"
            )

        medications = get_fhir_medications(target_patient['id'])    
        return medications
    except Exception as e:
        raise e

def extract_fall_risk_medications(first_name: str, last_name: str):
    """Return medications that warn about dizziness or dehydration risk."""
    flagged = []
    medications = get_patient_medications(first_name, last_name)
    active_meds = [m for m in medications if m['status'] == 'active']
    for m in active_meds:
        dosage_instructions = (m.get("dosage") or "").lower()
        if any(kw in dosage_instructions for kw in ["dizziness", "dizzy", "orthostatic", "dehydration", "urination"]):
            flagged.append(f"{m['drug']} — {m['dosage']}")
    return flagged

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

@app.get("/api/patient-appointments")
def get_patient_appointments(first_name: str, last_name: str):
    try:
        all_patients = get_fhir_patients()
        
        first_name_lower = first_name.lower()
        last_name_lower = last_name.lower()
        
        target_patient = next(
            (p for p in all_patients if 
            first_name_lower in p['name'].lower() and 
            last_name_lower in p['name'].lower()), 
            None
        )

        if not target_patient:
            raise HTTPException(
                status_code=404, 
                detail=f"Patient {first_name} {last_name} not found in FHIR records"
            )
        
        appointments = get_fhir_appointments(target_patient['id'])
        return appointments
    except Exception as e:
        raise e

def get_fhir_care_teams(patient_id: str = ""):
    bundle = _fhir_get("CareTeam", {"patient": patient_id, "status": "active"})
    results = []
    
    for e in bundle.get("entry", []):
        r = e["resource"]
        
        participants = []
        for p in r.get("participant", []):
            member = p.get("member", {}).get("display", "Unknown Member")
            role_data = p.get("role", [{}])[0].get("coding", [{}])[0]
            role = role_data.get("display") or p.get("role", [{}])[0].get("text", "Member")
            participants.append(f"{member} ({role})")
        
        reasons = []
        for code_obj in r.get("reasonCode", []):
            reason_display = code_obj.get("coding", [{}])[0].get("display") or code_obj.get("text")
            if reason_display:
                reasons.append(reason_display)

        orgs = [org.get("display", "Unknown Organization") for org in r.get("managingOrganization", [])]
        
        results.append({
            "name": r.get("name", "Unnamed Team"),
            "status": r.get("status"),
            "managing_org": ", ".join(orgs) if orgs else "N/A",
            "reasons": reasons,
            "participants": participants,
            "period_start": r.get("period", {}).get("start", "N/A")
        })
        
    return results

def get_fhir_care_plans(patient_id: str = ""):
    bundle = _fhir_get("CarePlan", {"patient": patient_id, "status": "active", "_sort": "-date"})
    results = []
    
    for e in bundle.get("entry", []):
        r = e["resource"]
        
        category_obj = r.get("category", [{}])[0]
        category_text = (
            category_obj.get("text") or 
            category_obj.get("coding", [{}])[0].get("display") or 
            "General Care Plan"
        )
        
        activities = []
        for act in r.get("activity", []):
            detail = act.get("detail", {})
            desc = detail.get("description") or detail.get("code", {}).get("text", "Planned activity")
            activities.append(desc)
            
        results.append({
            "title": r.get("title") or category_text,
            "category": category_text,
            "status": r.get("status"),
            "activities": activities,
            "start_date": r.get("period", {}).get("start", "N/A")
        })
        
    return results

# ── Interprete FHIR proxy endpoints ───────────────────────────────────────────

def get_patient_context(patient_id: str = ""):
    conditions  = get_fhir_conditions(patient_id)
    medications = get_fhir_medications(patient_id)
    vitals      = get_fhir_vitals(patient_id)
    labs        = get_fhir_labs(patient_id)
    bp_trend    = get_fhir_bp_trend(patient_id)
    care_plans  = get_fhir_care_plans(patient_id)
    care_teams  = get_fhir_care_teams(patient_id)
    appointments = get_fhir_appointments(patient_id)
    
    try:
        patient_bundle = _fhir_get("Patient", {"_id": patient_id})
        entries = patient_bundle.get("entry", [])
        patient_info = _parse_patient(entries[0]["resource"]) if entries else {}
    except Exception:
        patient_info = {}

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
    cteam_text = "\n".join(
        f"  - {t['name']} (Status: {t['status']}, Org: {t['managing_org']}, Start: {t['period_start'][:10] if t.get('period_start') else 'unknown'})\n"
        f"    Participants: {', '.join(t['participants']) if t['participants'] else 'None'}\n"
        f"    Reasons: {', '.join(t['reasons']) if t['reasons'] else 'Not specified'}"
        for t in care_teams
    ) or "  None"
    cplan_text = "\n".join(
        f"  - {p['title']}: {p['category']} ({p['status']}, Start: {p['start_date'][:10] if p.get('start_date') else 'unknown'})\n"
        f"    Activities: {', '.join(p['activities']) if p['activities'] else 'No activities listed'}"
        for p in care_plans
    ) or "  None"
    appt_text  = "\n".join(
        f"  - {a['start'][:10]}: {a['type']} with {a['practitioner']} at {a['location']} (Status: {a['status']})"
        for a in appointments
    ) or "  None"

    context = f"""
    Patient: {name} {age_str}

    Conditions:
    {cond_text}

    Medications:
    {med_text}

    Recent Vitals:
    {vital_text}

    Recent Labs:
    {lab_text}

    Blood Pressure Trend (most recent readings):
    {bp_text}

    Care Plans:
    {cplan_text}

    Care Teams:
    {cteam_text}

    Upcoming Appointments:
    {appt_text}
    """
    return context

# Patient summary could be generated via the UI during account creation in order to provide more details?
def get_patient_desc(patient_id: str = ""):
    return """
           **Frank Larson**, 74-year-old man — retired civil engineer, widowed, living alone at home in Medfield, MA. He has:
            - hypertension,
            - hyperlipidemia,
            - type 2 diabetes,
            - severe right knee osteoarthritis — right total knee replacement (Mar 2024) with good recovery,
            - recurrent orthostatic dizziness/near-falls with dehydration risk (noted Jan 2026; borderline hypernatremia, mild creatinine rise),
            - and major depressive disorder (bereavement-related after spouse's death in Jan 2025; on sertraline).

            Recent status (2026-01-20): HR 64/min, weight 88.2 kg (BMI 28.4). Labs show sodium 146 mmol/L, creatinine 1.3 mg/dL, and glucose 148 mg/dL.

            His son **David** is his primary contact. His primary care provider is **Dr. Sarah Mitchell** (Medfield Family Health Center).

            Upcoming Appointments:
            - Primary care check-up: Friday 01 May 2026, 10:00 AM (Dr. James Patel) at Medfield Family Practice
            - Cardiology follow-up: Friday 08 May 2026, 11:00 AM (Dr. Sarah Chen) at Medfield Cardiology Clinic
            - Lab work (blood panel): Friday 15 May 2026, 9:00 AM at Quest Diagnostics - Medfield

            Active Medications:
            - Sertraline 50 mg each morning
            - Metoprolol succinate ER 50 mg daily
            - Gabapentin 300 mg three times daily
            - Lisinopril 10 mg daily
            - Metformin 500 mg twice daily with meals
            - Hydrochlorothiazide 25 mg every morning
            - Atorvastatin 40 mg nightly
            (Note: Amlodipine, glipizide, and naproxen are listed as stopped.)

            Care context / plans: 
            - Comprehensive elderly care plan (active, from 2024-06-15) focused on monitoring blood pressure and orthostatic vitals, fall/dizziness review (concern for polypharmacy-related dizziness), hydration education due to diuretic use, depression check-ins, medication reconciliation, and diabetes monitoring including annual HbA1c.
            """
    patient_fhir = get_patient_context(patient_id)
    
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    medical_analyst = """You are an expert medical data analyst specializing in FHIR R4 working as part of a Smart Home Hub. 
                        When given a FHIR bundle, you should analyse the patient's medical history and generate a short summary of them to provide as context to other agents. 
                        The format of the answer should be plain text. 
                        Be clear and concise, only include whatever is most necessary. 
                        DO NOT try and provide any advise on further actions or perform any diagnoses yourself.

                        Your answer should follow the following template: 
                        **Eleanor Turner**, 82-year-old woman — retired schoolteacher, living alone in her apartment. She has: 
                            - active Parkinson's disease, 
                            - orthostatic hypotension, 
                            - age-related macular degeneration (AMD) - Missed AMD clinic appointment in Mar 2025, 
                            - osteoporosis, 
                            - type 2 diabetes, 
                            - prior neck-of-femur fracture (Feb 2024 total hip replacement), 
                            - and recent lobar pneumonia (Dec 2025). 

                        Her daughter **Linda** lives 45 minutes away. Her primary care provider is **NP Davis**.

                        She uses a walking stick, and has home safety rails installed. 

                        Upcoming Appointments:
                        - Endocrinology (Diabetes review): Saturday 19 April 2025, 10:00 AM (NP Davis) at Medfield Family Health Center

                        Active Medications:
                        - Levodopa/Carbidopa 25/100 mg, 1 tablet TID (for Parkinson's)
                        - Amlodipine 5 mg, 1 tablet daily (for blood pressure)
                        """
    response = client.responses.create(
        model="gpt-5.4-nano",
        instructions = medical_analyst,
        input= f"Analyze this FHIR bundle and provide a short summary of their medical history:\n\n{patient_fhir}"
    )
    return response.output_text

@app.post("/api/clinician_summary/generate")
def generate_clinician_summary(patient_id: str = Query(...)):
    patient_fhir = get_patient_context(patient_id)

    client = get_openai_client()
    if not client:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    medical_analyst = f"""
    # ROLE: FHIR R4 Expert

    # CONTEXT: 
    You are an expert medical data analyst specializing in FHIR R4, speaking directly to a clinician. When given a FHIR bundle, your task is to synthesize a clinically coherent patient summary that explains the patient's current risk state, key contributing factors, and any gaps in care.
    Prioritize clinical synthesis over enumeration. Combine related findings into a single narrative, highlighting cause-and-effect relationships (e.g., medications contributing to symptoms, unresolved post-operative issues increasing risk).

    Focus on:
    - What is happening with the patient now
    - Why it matters clinically
    - What is driving the current risk
    - What has not resolved as expected
    - How medications, conditions, and recent events interact

    Incorporate timing where relevant (e.g., “10 months post-op”, “3 weeks ago”) to highlight ongoing or unresolved issues. Explicitly evaluate how current medications may contribute to symptoms or risks.

    Start with the most clinically important issue affecting near-term risk (e.g., fall risk, medication side effects, unresolved recovery), and avoid listing all conditions — include only what materially impacts current clinical decision-making.

    DO NOT invent data that is not present in the input.

    # RESPONSE STRUCTURE:
    The format of the answer should be plain text — no markdown, no asterisks, no bold. Start with the highest-priority risk first. Keep each explanation concise but data-rich. DO NOT invent data not present in the input. 
    Format your response exactly like this example — a titled header line, then dash-prefixed bullets (no more than 5 bullets in each section):

    Summary (based on medical record):
    [A concise but data-rich clinical narrative in 1-2 bullet points. Synthesize the patient's history, current risks, medications, and contributing factors. Emphasize causality, time course, and interactions.]

    Suggested actions:
    [Provide a short list of clear, clinically appropriate next steps. Each action should be on its own bullet-point, concise, practical, and directly linked to the patient's risks and care gaps. Format in the style 'Physical therapy referral: urgent gait reassessment; right-leg compensation has persisted beyond expected post-op recovery window']

    Home data insights:
    [If the patient's home data (e.g., gait metrics, hydration patterns) reveals any insights that are not already captured in the medical record but are relevant to their clinical risks, include them here in 1-2 bullet points. Include the source of this data (Hydration: Smart Toilet, Nutrition: Smart Fridge, Everything else: Garmin device).]

    # TONE:
    Be clear, concise, and clinically grounded. Write as a clinician-to-clinician summary. Focus only on high-impact risks and actionable insights. Avoid unnecessary detail or exhaustive condition lists.
    """

    try:
        response = client.responses.create(
            model="gpt-5-nano",
            instructions=medical_analyst,
            input=f"""Analyze this FHIR bundle and provide a short summary of their clinical risks:

                    {patient_fhir}

                    And their home data insights (gait, hydration, sleep, etc):
                    {get_resident_context(patient_id) if patient_id == "1" else "- No home data available for this patient."}
                    """
        )
    except openai.RateLimitError:
        raise HTTPException(status_code=429, detail="OpenAI rate limit reached. Please try again in a moment.")
    except openai.InternalServerError as e:
        raise HTTPException(status_code=503, detail=f"OpenAI service temporarily unavailable: {e.message}")
    except openai.APIError as e:
        raise HTTPException(status_code=502, detail=f"OpenAI API error: {e.message}")
    summary_text = response.output_text

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

@app.get("/api/clinician_summary")
def clinician_overview(patient_id: str = Query(...)):
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

# ── AI System Prompts ─────────────────────────────────────────────────────────

def get_resident_context(patient_id: str = ""):
    return """
    ---
    ### ⚠️ OVERALL RISK LEVEL: **CRITICAL**
    **Primary Driver:** The combination of **skipped/very low-protein dinner** plus **morning dehydration** is most likely worsening **right-sided weakness/limp**, which aligns with **high fall-risk gait** and may also be contributing to **incomplete physiological recovery** on sleep/HRV.

    #### I. ACUTE SAFETY & FALL RISK
    * **Finding:** High fall risk.
    * **Gait speed:** **0.77 m/s** (frailty-range; below 0.8 m/s threshold)
    * **Variability:** **10.5%** (slightly above historical 10.2% → more instability)
    * **Asymmetry/limp:** **GCT delta 80 ms (>60 ms)** with **right side guarded** (right leg likely painful/weak)
    * **Systemic Cause:** Home nutrition flags show **only 2 meals detected** with **dinner skipped** and **very low calories**, plus **protein at ~45 g (<60 g target)**. Under-fueling commonly reduces strength/endurance and increases compensatory movement—matching today's **frailty-speed + limp/asymmetry + higher variability** pattern.  
    Hydration is also concerning: hydration starts the day **“Dehydrated”** on several days, and today's later status remains problematic on **2026-04-29** (ends at **colorLevel 6**), which can worsen balance and dizziness risk.

    #### II. METABOLIC & AUTONOMIC LOAD
    * **Status:** Mixed—**nutrition load is low**, **hydration is not consistently protective**, vitamins not provided.
    * **Protein:** **~45 g (below target)**
    * **Water:** reported **1.9 L (<2 L)**
    * **Hydration pattern:** mornings often dehydrated; **2026-04-29 ends dehydrated (6)**
    * **Cardiac Impact:** Garmin shows **stable sinus rhythm** and measurable HRV:
    * **ECG rhythm:** **SINUS_NORMAL**
    * **SDNN:** **~35 ms** (modest beat-to-beat variation)
    * **Resting HR:** ~**65 bpm**
    
    However, the sleep section indicates **recovery is limited** (HRV/physiology-based “Recovery” bottleneck), which fits a scenario where **dehydration + low fueling** reduces the nervous system's “reset” capacity. Evening perceived stress is present but **not strongly driven by heart rate**, suggesting the strain may be more **recovery/hydration/nutrition related** than exertion-related.

    #### III. MENTAL HEALTH & COGNITIVE VIGILANCE
    * **Markers:**
    * **Appetite/behavioral decline proxy:** **Dinner skipped + very low calories**
    * **Inventory/executive-function proxy:** **Expiring items** (milk, spinach, turkey slices, salmon fillet) indicate potential planning burden; the home plan attempts to reduce cognitive load via a “Meal of the Day,” which suggests these lapses are meaningful.
    * **Sleep stress:** Sleep shows **short total sleep (2h50m)** with **Recovery bottleneck (Recovery=71)** and **sleep stress ~19.35**.
    
    Taken together: low intake + expiring-item pressure/possible planning difficulty aligns with **reduced recovery** and higher cognitive vulnerability the next day (grogginess, less resilience), increasing real-world fall risk—especially with today's limp.

    #### IV. PRIORITY INTERVENTIONS (THE "GOLDEN THREE")
    1. **Immediate Safety:**  
    Implement **assisted mobility now** (use a cane/walker or have supervision for ambulation/turning). Do a quick **trip-hazard + lighting** check (especially where the patient pivots due to the limp).

    2. **Targeted Input (today's highest-yield fix):**  
    **Protein + hydration repletion within hours.**  
    * Protein goal: move toward **≥60 g today**, using available items (e.g., **eggs + Greek yogurt**, **turkey slices + cottage cheese**, and/or **salmon** if feasible).  
    * Hydration goal: raise from **1.9 L to ~2.0-2.5 L** (small scheduled sips through the afternoon). Because **colorLevel ends high (6)** on 2026-04-29, prioritize consistent drinking and monitor dizziness on standing.

    3. **Recovery/Clinical:**  
    Focus on **sleep recovery quality and nervous-system “reset.”**  
    Tonight: set **lights-out ~45 minutes earlier** (target a longer sleep window), and keep a **screen-free wind-down** to reduce sleep stress. Clinically/observationally: watch for whether the **right-sided guarding** improves after nutrition/hydration correction; if not, expedite evaluation.

    ---
    """
    client = get_openai_client()
    
    garmin_dict = interprete_garmin(patient_id)
    home_dict = interprete_home_data(patient_id)
    if garmin_dict.get("status") == "error" or home_dict.get("status") == "error":
        garmin_data = "None"
        home_data = "None"
    else:
        garmin_data = garmin_dict.get("data")
        home_data = home_dict.get("data")

    old_triage_desc = f"""
    ### ROLE: ELDERLY SYSTEMIC RISK ANALYST

    # CONTEXT:
    You are a Senior Clinical Data Scientist specializing in Geriatric Health. You analyze data from six distinct health monitoring systems (ECG, HR, Sleep, Gait, Hydration, and Nutrition) to create a unified safety and recovery profile for an elderly user.
    Your goal is to generate a summary of the patient's Garmin and Home Appliance data for an orchestrator agent to interprete as part of a wider health monitoring system. Therefore, avoid medical jargon unless accompanied by a brief explanation. Refer to the patient in the third person. 

    # INTERPRETATION FRAMEWORK: 
    You must cross-reference data across all six systems to identify patterns of "Biological Resilience," "Mental Wellbeing," and "Acute Safety Risks." Use the following holistic logic:
    1. **Neuromotor Stability (The Brain-Body Link):**
    - Correlate `stride_variability_pct` (Gait) with `avg_sleep_stress` (Sleep) and `sdnn_hrv_ms` (ECG).
    - *Logic:* High variability (>10%) + High Sleep Stress = **Neurological Fatigue**. 
    - *Interpretation:* This indicates the nervous system is struggling to coordinate movement. Physically, this is a **High Fall Risk**. Mentally, this often presents as high anxiety, cognitive "fog," or the early onset of delirium/illness.
    2. **The "Slowing" Syndrome (Mood & Frailty):**
    - Connect `latest_snapshot.speed_ms` (Gait) with `protein_intake` (Fridge) and `overallScore` (Sleep).
    - *Logic:* Speed < 0.8 m/s + Low Protein + Low Sleep Quality.
    - *Interpretation:* Physically, this is **Frailty & Sarcopenia**. Mentally, this "Slowing" is a classic marker for **Geriatric Depression** or social withdrawal. A body that isn't fueling or moving is a mind that is likely retreating.
    3. **Autonomic Dissonance (Pain & Anxiety):**
    - Compare `avg_hr` and `sdnn_hrv_ms` (ECG) against `steps` and `cadence` (Gait).
    - *Logic:* Elevated HR/Low HRV despite **Low Physical Activity**.
    - *Interpretation:* This suggests "Internal Load." If the user isn't moving but the heart is racing, evaluate for **Hidden Pain** (which drives fall risk) or **Psychological Distress/Agitation**.
    4. **Homeostatic Safety Flags:**
    - **CRITICAL (Physical):** Gait Speed < 0.6 m/s OR (Dehydration + High Asymmetry). This is an imminent fall or collapse warning.
    - **CRITICAL (Mental/Systemic):** "Appetite Loss" (Fridge) + "Restless Moments" (Sleep) + "Withdrawal from Activity" (Low Steps). This suggests a significant decline in mental health or the beginning of a systemic "failure to thrive."
    5. **Circadian & Recovery Routine:**
    - Compare `last_meal_time` (Fridge) and `nap_duration` (Sleep) against `deep_pct` (Sleep).
    - *Logic:* Disrupted routines steal Deep Sleep. 
    - *Interpretation:* Chronic lack of Deep Sleep reduces emotional regulation and increases daytime confusion (Sun-downing), which directly impacts both mood stability and physical balance.

    # OUTPUT STRUCTURE
    Your response must follow this template:

    ---
    ### ⚠️ OVERALL RISK LEVEL: [LOW | ELEVATED | CRITICAL]
    **Primary Driver:** [Identify the #1 system causing the risk today]

    #### 1. THE "WHY" (Unified Insight)
    [A concise narrative explaining how the different data points are interacting. E.g., "The user is electrically stable but physically vulnerable due to under-fueling and dehydration."]

    #### 2. CROSS-SYSTEM CORRELATIONS
    * **[Link 1]:** (e.g., Nutrition vs. Sleep)
    * **[Link 2]:** (e.g., Hydration vs. Cardiac)
    * **[Link 3]:** etc.

    #### 3. GUARDIAN ACTION ITEMS
    * **Immediate:** [Actions the patient should take now, e.g., Drink 500ml water]
    * **Daily Goal:** [Nutritional or activity adjustment]
    * **Watch For:** [Clinical symptom to observe, e.g., Dizziness, gait changes]
    ---

    # INPUT:    
    1. The patient's Garmin data is: 
    {garmin_data}

    2. The patient's Home data is: 
    {home_data}
    """
    triage_desc = f"""
    # ROLE: SYSTEMIC TRIAGE AGENT (GERIATRIC CLINICAL SPECIALIST)

    ## 1. MISSION
    You are a specialized AI health analyst. Your task is to ingest two dictionaries — **Garmin Data** (Biological Outputs) and **Home Data** (Environmental Inputs) — and synthesize them into a single, high-level **Clinician's Brief**. You must identify how physical inputs (food/water) are directly impacting physiological outputs (HRV/Gait/Sleep).

    ## 2. INTERPRETATION & RELATIONAL LOGIC
    Do not summarize the dictionaries in isolation. You must "connect the dots" using these geriatric-specific rules:

    * **The Fueling-Stability Chain:** If Nutrition/Fridge flags "Skipped Meals" or "Low Protein," cross-reference with **Gait Speed** and **Variability**. 
        * *Logic:* Under-fueling leads to muscle weakness, which manifests as a drop in speed and a spike in tripping risk.
    * **The Dehydration-Cardiac Loop:** Correlate **Toilet ColorLevel** with **ECG SDNN/HRV**. 
        * *Logic:* High dehydration (Level 5+) thickens blood and reduces HRV. If the heart shows low "reserve" or "modest variation," check if the hydration levels were "Dehydrated" in the morning.
    * **The Pain-Sleep Correlation:** Look at **Gait Asymmetry** (GCT Delta > 60ms) and compare it to **Sleep Recovery Scores**. 
        * *Logic:* A pronounced limp (guarding) often indicates pain, which is a primary driver of "Unbalanced Recovery" or high "Sleep Stress" in the elderly.
    * **Cognitive-Behavioral Flags:** Connect "Expiring Items" (Fridge) and "Skipped Meals" with "Sleep Stress."
        * *Logic:* Forgetting to eat or failing to manage inventory are markers of executive dysfunction or depressive withdrawal, often preceded by poor deep sleep architecture.

    ## 3. REPORT STRUCTURE (MANDATORY)
    Your goal is to generate a summary of the patient's Garmin and Home Appliance data for an orchestrator agent to interprete as part of a wider health monitoring system. Therefore, avoid medical jargon unless accompanied by a brief explanation. Refer to the patient in the third person. Your final output must follow this exact template:

    ---
    ### ⚠️ OVERALL RISK LEVEL: [LOW | ELEVATED | CRITICAL]
    **Primary Driver:** [A one-sentence summary identifying the single most dangerous pattern connecting the sensors today.]

    #### I. ACUTE SAFETY & FALL RISK
    * **Finding:** [Combine Gait Speed, Symmetry, and Variability stats.]
    * **Systemic Cause:** [Explain how Nutrition or Hydration data from the Home dictionary is driving this physical state.]

    #### II. METABOLIC & AUTONOMIC LOAD
    * **Status:** [Synthesize Protein, Vitamin C, and Water levels.]
    * **Cardiac Impact:** [Explain how these inputs are affecting the ECG/HR results (e.g., "Cardiac reserve is limited by chronic dehydration").]

    #### III. MENTAL HEALTH & COGNITIVE VIGILANCE
    * **Markers:** [Analyze Appetite Loss, Sleep Stress, and Inventory Management (Expiring Items) as proxies for mood and cognitive load.]

    #### IV. PRIORITY INTERVENTIONS (THE "GOLDEN THREE")
    1.  **Immediate Safety:** [Non-medical physical intervention, e.g., assisted walking.]
    2.  **Targeted Input:** [Specific meal/hydration goal using available fridge inventory.]
    3.  **Recovery/Clinical:** [Specific sleep or clinical observation goal.]
    ---

    # INPUT:    
    1. The patient's Garmin data is: 
    {garmin_data}

    2. The patient's Home data is: 
    {home_data}
    """
    response = client.responses.create(
        model="gpt-5.4-nano",
        instructions = triage_desc,
        input = "Generate a summary of the patient's Garmin and Home Appliance data for the orchestrator agent to utilise in future decision-making."
    )
    
    triage_answer = response.output_text
    return triage_answer

@app.get("/api/system-prompt")
def old_system_prompt(patient_id: str = "") -> str:
    neighborhoodJson = get_neighborhood(patient_id)

    latest_dict = neighborhoodJson[0] if neighborhoodJson else None

    act_lines = [] # Neighborhood activites
    ride_lines = [] # Neighbor ride offers from help board 
    companion_lines = [] # Neighbor companionship offers from help board
    if latest_dict:
        today = datetime.strptime(latest_dict.get('date'), '%Y-%m-%d')
        filtered_activities = []
        for a in latest_dict.get("activities", []):
            act_date = datetime.strptime(f"{a.get('date')} {today.year}", "%A, %b %d %Y")
            if today <= act_date <= today + timedelta(days=3):
                filtered_activities.append(a)
            
        sorted_activities = sorted(
            filtered_activities, 
            key=lambda x: datetime.strptime(x.get('date'), "%A, %b %d")
        )
        for a in sorted_activities:
            attendeeNames = ", ".join([x.get("name", "") for x in a.get("attendees", [])])
            suffix = ""
            if attendeeNames:
                extra = f" +{a.get('extraCount')} more" if a.get('extraCount', 0) > 0 else ""
                suffix = f" — attending: {attendeeNames}{extra}"
            act_lines.append(f" • [ID: {a.get('id', 0)}] {a.get('title', "")}: {a.get('date', "")} at {a.get('time', "")}, {a.get('location', "")} ({a.get('duration', "")}) {suffix}")

        for p in latest_dict.get("helpPosts", []):
            if p.get("type") == "offer" and p.get("category", "").lower() == "ride":
                ride_lines.append(f" • {p.get('name')}: {p.get('message')}")
            if p.get("category", "").lower() == "companionship":
                companion_lines.append(f" • {p.get('name')}: {p.get('message')}")
        
    activities = "\n".join(act_lines) if act_lines else "None posted right now."
    ride_offers = "\n".join(ride_lines) if ride_lines else "None posted right now."
    companion_offers = "\n".join(companion_lines) if companion_lines else "None posted right now."

    fridge = extract_fridge(patient_id)

    triage_answer = get_resident_context(patient_id)
    patient_desc = get_patient_desc(patient_id)

    nhh_desc = f"""
    ### ROLE: Elder-care assitant

    # CONTEXT: 
    You are a calm, friendly elder-care assistant. You are speaking directly to the following user:

    {patient_desc}
 
    # TONE:
    Speak clearly and briefly. Don't patronise them. Prioritise conciseness, your reply should keep to 4-5 sentences.

    # RESTRICTIONS:
    DO NOT give medical diagnoses. 
    If unsure, suggest contacting their healthcare professional.

    # DATA SUMMARY: 

    {triage_answer}

    # APPOINTMENT INSTRUCTION:
    When Frank asks about appointments, you MUST read out every detail for each one: full date, time, appointment type, physician name (if any), and location. Never omit any of these fields. Example: "You have a Primary Care Check-up on Wednesday, April 8th at 9:00 AM with Dr. James Patel at Medfield Family Practice."

    # NEIGHBORHOOD ACTIVITIES :
    Consider all activities in their neighborhood community (Oakwood Pines) and suggest the most appropriate for their specific wellbeing. Prioritise any activities happening today ({today.strftime('%A, %b %d')}) or tomorrow ({(today + timedelta(days=1)).strftime('%A, %b %d')}).

    {activities}

    # NEIGHBORHOOD HELP BOARD:
    If they are looking for rides, companionship, or other help, consider the following neighbor offers in their community fromt the help board.

    - Rides:
    {ride_offers}

    - Companionship:
    {companion_offers}

    # BOOKING INSTRUCTION: 
    If the user confirms they would like to join a specific activity, then confirm enthusiastically in your response that you have successfully registered them. 

    Then, on a brand new line at the very end, append exactly: [[JOIN:ID]] where ID is that activity's booking ID number from the list above. 
    Do NOT speak or mention [[JOIN:ID]] — it is a silent machine code only, never part of the conversation with the user. DO NOT sign them up without them explicitly asking to be.

    # NEIGHBOR CONNECT INSTRUCTION:
    If the user asks for a ride/transport or companionship, follow this logic:
    1. First mention any neighbors who have offered (from the list above). If no neighbor ride fits, suggest Lyft as a convenient option. If no companionship offers fit, suggest joining a neighborhood activity as a way to meet people or to contact his family.
    2. If the user wants to connect with a specific neighbor (e.g. "connect me with Barbara"), confirm warmly and on a brand new line at the very end append exactly: [[CONNECT_NEIGHBOR:Name]] where Name is the neighbor's first name (e.g. [[CONNECT_NEIGHBOR:Barbara]]).

    [[CONNECT_NEIGHBOR:Name]] is a silent machine code — never speak or mention it.
    
    # CALL INSTRUCTION: 
    If they ask to call or talk to their family, then confirm warmly in your normal response that you will help achieve this. 
    
    Then, on a brand new line at the very end, append exactly: [[CALL_FAMILY]] — this is a silent machine code, never speak or mention it.

    # FOOD & ACTIVITY CONNECTION:
    If the user asks about food, recipes, or what to eat, suggest something from his fridge inventory AND check if there is a relevant upcoming activity (e.g. a cooking demo or class) — if so, briefly mention it by name and date as something he might enjoy.

    Fridge inventory: 
    - Current items: 
    {"\n".join(fridge.get("currentItems", [])) if fridge.get("currentItems") else "Nothing currently in the fridge."}

    - Expiring items: 
    {"\n".join(fridge.get("expiringItems", [])) if fridge.get("expiringItems") else "Nothing is currently expiring soon." }
    """

    return nhh_desc

# @app.get("/api/system-prompt")
def get_system_prompt(patient_id: str = "", first_name: str = "", last_name: str = "") -> str:
    # ── Real-time health data ──────────────────────────────────────────────────
    hoursAsleep = extract_sleep(patient_id)
    fridge = extract_fridge(patient_id)
    hydrationNote, hydrationColorLevel, dehydrated = extract_hydration(patient_id)
    gaitNote, gaitConcern, _ = extract_gait(patient_id)

    dailyJson = get_dailySummary(patient_id)
    latest_daily = max(dailyJson, key=lambda x: x.get("calendarDate"), default={})
    steps = latest_daily.get("totalSteps") or 0
    heartRate = latest_daily.get("currentDayRestingHeartRate") or latest_daily.get("restingHeartRate") or 0
    aggregator_list = latest_daily.get("allDayStress", {}).get("aggregatorList", [])
    awake = next((a for a in aggregator_list if a.get("type") == "AWAKE"), {})
    stressLevel = round(awake.get("averageStressLevel", 0))

    data_lines = []
    if hoursAsleep:                          data_lines.append(f"- Sleep last night: {round(hoursAsleep, 1)} hours")
    if heartRate:                            data_lines.append(f"- Resting heart rate: {heartRate} BPM")
    if steps:                                data_lines.append(f"- Steps today: {steps}")
    if stressLevel:                          data_lines.append(f"- Stress level: {stressLevel}/100 (0 = very calm, 100 = very stressed)")
    if hydrationNote and hydrationColorLevel > 0:
                                             data_lines.append(f"- Hydration (smart toilet): level {hydrationColorLevel}/8 — {hydrationNote}")
    if gaitNote:                             data_lines.append(f"- Gait / walking analysis: {gaitNote}")
    if dehydrated and gaitConcern:           data_lines.append("- Combined fall risk alert: YES — gait irregularities combined with dehydration")
    meals = fridge.get("mealsCount")
    if meals is not None:                    data_lines.append(f"- Meals detected today (smart fridge): {meals}")
    current_items = fridge.get("currentItems", [])
    if current_items:                        data_lines.append(f"- Current fridge inventory: {', '.join(current_items)}")
    expiring_items = fridge.get("expiringItems", [])
    if expiring_items:                       data_lines.append(f"- Fridge items expiring soon: {', '.join(expiring_items)}")
    
    # TODO: get patient name from the patient id or make it a parameter
    fall_risk_meds = extract_fall_risk_medications(first_name, last_name)
    if fall_risk_meds:                       data_lines.append(f"- Medications that may cause dizziness or dehydration:\n  " + "\n  ".join(fall_risk_meds))

    # TODO: get patient name from the patient id or make it a parameter
    medications = get_patient_medications(first_name, last_name)
    active_meds = [m for m in medications if m['status'] == 'active']
    if active_meds:
        med_lines = [f"  • {m['drug']}: {m['dosage']}" for m in active_meds]
        data_lines.append("- Active prescriptions:\n" + "\n".join(med_lines))

    # TODO: get patient name from the patient id or make it a parameter
    appts = get_patient_appointments(first_name, last_name)
    appts.sort(key=lambda x: x["start"])
    if appts:
        appt_lines = []
        for a in appts:
            try:
                dt = datetime.strptime(a["start"], "%Y-%m-%dT%H:%M:%SZ")
                date_str = dt.strftime("%A, %B %d")
                time_str = dt.strftime("%I:%M %p").lstrip("0")
            except Exception:
                date_str = a["start"][:10]
                time_str = ""
            parts = [f"{date_str} at {time_str}", a["type"]]
            if a["practitioner"]: parts.append(f"with {a['practitioner']}")
            if a["location"]: parts.append(f"at {a['location']}")
            appt_lines.append("  • " + " — ".join(parts))
        data_lines.append("- Upcoming appointments:\n" + "\n".join(appt_lines))

    data_summary = "\n".join(data_lines)

    # ── Neighborhood — all upcoming activities ─────────────────────────────────
    neighborhoodJson = get_neighborhood(patient_id)
    latest_dict = neighborhoodJson[0] if neighborhoodJson else None

    act_lines = []
    if latest_dict:
        today = datetime.strptime(latest_dict.get('date'), '%Y-%m-%d')
        sorted_activities = sorted(
            latest_dict.get("activities", []),
            key=lambda x: (lambda d: datetime.strptime(d, "%A, %b %d %Y"))(f"{x.get('date')} {today.year}")
        )
        day_abbr = {"Mon,": "Monday,", "Tue,": "Tuesday,", "Wed,": "Wednesday,", "Thu,": "Thursday,", "Fri,": "Friday,", "Sat,": "Saturday,", "Sun,": "Sunday,"}
        for a in sorted_activities:
            attendeeNames = ", ".join([x.get("name", "") for x in a.get("attendees", [])])
            suffix = ""
            if attendeeNames:
                extra = f" +{a.get('extraCount')} more" if a.get('extraCount', 0) > 0 else ""
                suffix = f" — attending: {attendeeNames}{extra}"
            date_str = a.get('date', '')
            for abbr, full in day_abbr.items():
                date_str = date_str.replace(abbr, full)
            act_lines.append(f" • [ID: {a.get('id', 0)}] {a.get('title', '')}: {date_str} at {a.get('time', '')}, {a.get('location', '')} ({a.get('duration', '')}) {suffix}")
    activities = "\n".join(act_lines)

    # ── Neighbor ride offers from help board ───────────────────────────────────
    ride_lines = []
    if latest_dict:
        for p in latest_dict.get("helpPosts", []):
            if p.get("type") == "offer" and p.get("category", "").lower() == "ride":
                ride_lines.append(f" • {p.get('name')}: {p.get('message')}")
    ride_offers = "\n".join(ride_lines) if ride_lines else "None posted right now."

    # ── Neighbor companionship offers from help board ─────────────────────────
    companion_lines = []
    if latest_dict:
        for p in latest_dict.get("helpPosts", []):
            if p.get("category", "").lower() == "companionship":
                companion_lines.append(f" • {p.get('name')}: {p.get('message')}")
    companion_offers = "\n".join(companion_lines) if companion_lines else "None posted right now."

    patient_desc = get_patient_desc(patient_id)

    return f"""
    ### ROLE: Elder-care assistant

    # CONTEXT:
    You are Joy, a warm and caring AI health companion. You are speaking directly to the following patient:

    {patient_desc}

    # TONE:
    Speak clearly and briefly. Don't patronise them. Prioritise conciseness, your reply should keep to 4-5 sentences.

    # RESTRICTIONS:
    DO NOT give medical diagnoses.
    If unsure, suggest contacting their healthcare professional.

    # FRANK'S CURRENT HEALTH DATA (real-time from wearable and smart home sensors):
    {data_summary}

    # APPOINTMENT INSTRUCTION:
    When Frank asks about appointments, you MUST read out every detail for each one: full date, time, appointment type, physician name (if any), and location. Never omit any of these fields. Example: "You have a Primary Care Check-up on Wednesday, April 8th at 9:00 AM with Dr. James Patel at Medfield Family Practice."

    # NEIGHBORHOOD ACTIVITIES (Oakwood Pines — all upcoming):
    Consider all activities and suggest the most appropriate for Frank's wellbeing. Prioritise any happening today ({today.strftime('%A, %b %d')}) or tomorrow ({(today + timedelta(days=1)).strftime('%A, %b %d')}).

    {activities}

    # NEIGHBOR RIDE OFFERS:
    Neighbors who have offered rides in the community help board:
    {ride_offers}

    # NEIGHBOR COMPANIONSHIP OFFERS:
    Neighbors who have offered companionship in the community help board:
    {companion_offers}

    # NEIGHBOR CONNECT INSTRUCTION:
    If Frank asks how to get to the doctor's office (or any appointment), always offer exactly these three options and nothing else:
    1. His son David — "Your son David could take you."
    2. His neighbor Barbara — "Your neighbor Barbara could give you a ride."
    3. Lyft — "Or I can help you book a Lyft."
    Wait for Frank to choose. Then:
    - If Frank chooses David → simply say something like "Great, you can give David a call — he'll be happy to help."
    - If Frank chooses Barbara → confirm warmly (e.g. "I'll connect you with Barbara now!") and on a brand new line at the very end append exactly: [[CONNECT_NEIGHBOR:Barbara]]
      IMPORTANT: Only append [[CONNECT_NEIGHBOR:Barbara]] after Frank has explicitly chosen Barbara. Never connect proactively.
    - If Frank chooses Lyft → tell him Lyft is a great option and he can open the Lyft app or ask someone to help book it.

    For any other ride/transport or companionship request (not doctor-related):
    1. First mention any neighbors who have offered (from the lists above).
    2. If Frank wants to connect with a specific neighbor, confirm warmly and on a brand new line at the very end append exactly: [[CONNECT_NEIGHBOR:Name]] where Name is the neighbor's first name (e.g. [[CONNECT_NEIGHBOR:Barbara]]).
    3. If no neighbor ride fits, suggest Lyft as a convenient option. If no companionship offers fit, suggest joining a neighborhood activity as a way to meet people or to contact his family.
    [[CONNECT_NEIGHBOR:Name]] is a silent machine code — never speak or mention it.

    # FOOD & ACTIVITY CONNECTION:
    If Frank asks about food, recipes, or what to eat, suggest something from his fridge inventory AND check if there is a relevant upcoming activity (e.g. a cooking demo or class) — if so, briefly mention it by name and date as something he might enjoy.

    # BOOKING INSTRUCTION:
    When mentioning activities to Frank, only say the name, date, and start time — nothing else (no duration, no location, no description).
    If Frank confirms they would like to join any activity, confirm enthusiastically and explicitly name the activity (e.g. "I've signed you up for the Neighborhood Walk on Thursday!").
    Then, on a brand new line at the very end, append exactly: [[JOIN:ID]] where ID is that activity's booking ID number from the list above.
    Do NOT speak or mention [[JOIN:ID]] — it is a silent machine code only, never part of the conversation. DO NOT sign them up without them explicitly asking.

    # CALL INSTRUCTION:
    There are exactly two cases:
    1. Frank explicitly asks to call (e.g. "call David", "I want to talk to my son") → immediately say something like "Calling David now!" and append [[CALL_FAMILY]] on a brand new line at the very end. No questions, no alternatives.
    2. Frank mentions a family member or says he misses them but does NOT ask to call → ask ONE simple question only: "Would you like me to call David?" — nothing else, no alternatives, no drafting messages. Wait for his response. Only append [[CALL_FAMILY]] after he confirms.
    [[CALL_FAMILY]] is a silent machine code — never say it out loud.
    """

@app.get("/api/checkin-prompt")
def get_check_in_prompt(mode: str = ""):
    if mode == "fall":
        return f"""
        # TASK
        Provide a good morning message gently summarising their current fall-risk status based on their garmin and household data. 
        DO NOT mention meals or nutrition. Focus on gait, hydration, and medications that may cause dizziness. If you are concerned they are a fall-risk, warn them to take it slow when getting up and moving around today. 
        
        Avoid returning too long of a message, your response should not require bullet points. Keep to 3-4 sentences.
        Avoid giving too much technical detail, this summary should act as a higher level overview of their health. Do not use actual numbers, talk around the data in a more general way (e.g. "I noticed your walking has been unsteady" not "Your GCT delta is above 60ms").

        Based on your summary, suggest some advice for how best to behave today. Do NOT suggest getting medical assistance unless the data shows a truly severe condition. Suggesting calling their family or primary contact is fine if the situation warrants it.
        """
    elif mode == "mental":
        return f"""
        # TASK
        Provide a good evening message to check in on their mental wellbeing based on their garmin and household data. DO NOT say you are checking in on their mental health, just provide a warm message that acknowledges the data and offers gentle encouragement.
        DO NOT mention fall risk, gait, dehydration, or physical safety. Focus on sleep, activity levels, and meals as the main pillars of mental health. 
        If you see signs of low activity, poor sleep, or low meal counts, gently acknowledge this and suggest that getting out with neighbors tomorrow might help lift their spirits. Do NOT name or detail any specific activities, keep it vague and warm like "your neighbors would love to see you."
        
        Avoid returning too long of a message, your response should not require bullet points. Keep to 3-4 sentences. Open with "Good evening, Frank".
        Avoid giving too much technical detail, this summary should act as a higher level overview of their health. Do not use actual numbers, talk around the data in a more general way (e.g. "I noticed you didn't get much rest last night" instead of "You got 5.6 hours of sleep last night").
        
        If they later asks about activities, suggest things happening tomorrow or later in the week, not today. It is the evening already.
        """
    return ""

# ── AI response endpoints ─────────────────────────────────────────────────────

@app.post("/api/answer/stream")
async def answer_stream(payload: dict = Body(...)):
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    user_text = (payload.get("text") or "").strip()
    if not user_text:
        raise HTTPException(status_code=400, detail="Empty input")

    history = (payload.get("messages") or [])[-5:] + [{"role": "user", "content": user_text}]
    system_msg = (payload.get("system") or "").strip()

    def generate():
        try:
            stream = client.responses.create(
                model="gpt-5.4-nano",
                instructions=system_msg,
                input=history,
                stream=True,
                temperature=0.2
            )
            for event in stream:
                if event.type == "response.output_text.delta":
                    delta = event.delta or ""
                    if delta:
                        yield json.dumps({"delta": delta}) + "\n"
                elif event.type == "response.completed":
                    break
            yield json.dumps({"done": True}) + "\n"
        except Exception as e:
            yield json.dumps({"error": str(e)}) + "\n"

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
            model="tts-1-hd",
            voice="nova",
            input=text,
        )
        return Response(
            content=audio.read(),
            media_type="audio/mpeg",
        )
    except Exception as e:
        print("TTS error:", repr(e))
        raise HTTPException(status_code=500, detail=str(e))