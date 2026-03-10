import os
import iris
import json
import numpy as np
from scipy.signal import find_peaks
from datetime import datetime, timezone
from dotenv import load_dotenv

# Initialize Environment
load_dotenv()
args = {'hostname': os.getenv("IRIS_SQL_HOST"), 'port': int(os.getenv("IRIS_SQL_PORT")), 'namespace': os.getenv("IRIS_SQL_NAMESPACE"),
        'username': os.getenv("IRIS_SQL_USERNAME"), 'password': os.getenv("IRIS_SQL_PASSWORD")}
connection = iris.connect(**args)
iris_cursor = connection.cursor()

def unix_to_utc(timestamp):
    return datetime.fromtimestamp(timestamp / 1000.0, tz=timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')

def get_ecgdata(end_datetime: datetime, sql_query: str = "SELECT TOP 1 ECGData FROM MyApp.JSONStore ORDER BY CreatedAt DESC"):
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
    
    iris_cursor.execute(sql_query)
    result = iris_cursor.fetchone()
    ecg_list = json.loads(result[0])

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

def get_hrdata(end_datetime: datetime, sql_query: str = "SELECT TOP 1 HRData FROM MyApp.JSONStore ORDER BY CreatedAt DESC"):
    """
    Filters raw Garmin HR data into a concise dictionary optimized for LLM analysis and summarization.
    """
    iris_cursor.execute(sql_query)
    result = iris_cursor.fetchone()
    hr_json = json.loads(result[0])

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

def get_sleepdata(end_datetime: datetime, sql_query: str = "SELECT TOP 1 SleepData FROM MyApp.JSONStore ORDER BY CreatedAt DESC"):
    """
    Filters raw Garmin Sleep data into a concise dictionary optimized for LLM analysis and summarization.
    """
    iris_cursor.execute(sql_query)
    result = iris_cursor.fetchone()
    sleep_list = json.loads(result[0])

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

# file_path = os.path.join(os.path.dirname(__file__), "simulated_garmin", "combined_health_data.json")
# with open(file_path, 'r') as file:
#     synthetic_data = json.load(file)

# hr_dict = synthetic_data.get("HRData")
# hr_default = {
#     "userProfilePK": hr_dict.get("userProfilePK"),
#     "activityUuid": hr_dict.get("activityUuid"),
#     "epochDescriptorDTOList": hr_dict.get("epochDescriptorDTOList"),
#     "epochArray": []
# }

# daily_groups = {}
# for epoch in hr_dict.get("epochArray", []):
#     timestamp_ms = epoch[0]
#     date_str = datetime.fromtimestamp(timestamp_ms / 1000.0).strftime('%Y-%m-%d')
#     if date_str not in daily_groups:
#         daily_groups[date_str] = hr_default
#     daily_groups[date_str]["epochArray"].append(epoch)

# hr_list = [daily_groups[date] for date in sorted(daily_groups.keys())]
# ecg_list = synthetic_data.get("ECGData")
# sleep_list = synthetic_data.get("SleepData")

# date_range = [datetime.strptime('15/01/26 00:00:00', '%d/%m/%y %H:%M:%S0'),
#               datetime.strptime('16/01/26 00:00:00', '%d/%m/%y %H:%M:%S0'),
#               datetime.strptime('17/01/26 00:00:00', '%d/%m/%y %H:%M:%S0'),
#               datetime.strptime('18/01/26 00:00:00', '%d/%m/%y %H:%M:%S0'),
#               datetime.strptime('19/01/26 00:00:00', '%d/%m/%y %H:%M:%S0'),
#               datetime.strptime('20/01/26 00:00:00', '%d/%m/%y %H:%M:%S0'),
#               datetime.strptime('21/01/26 00:00:00', '%d/%m/%y %H:%M:%S0')]

# for i, date in enumerate(date_range):
#     sql_query = "INSERT INTO MyApp.JSONParsed (CreatedAt, ECGData, HRData, PatientID, SleepData) VALUES (?, ?, ?, ?, ?)"
#     params = [date, json.dumps(ecg_list[i]), json.dumps(hr_list[i]), "PATIENT_001", json.dumps(sleep_list[i])]
#     iris_cursor.execute(sql_query, params)