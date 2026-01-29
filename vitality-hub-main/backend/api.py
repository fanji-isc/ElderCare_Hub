from fastapi import FastAPI
import iris
import json
import os

app = FastAPI()

IRIS_HOST = os.getenv("IRIS_HOST", "iris4health")
IRIS_PORT = int(os.getenv("IRIS_PORT", "1972"))
IRIS_NAMESPACE = os.getenv("IRIS_NAMESPACE", "USER")
IRIS_USERNAME = os.getenv("IRIS_USERNAME", "_SYSTEM")
IRIS_PASSWORD = os.getenv("IRIS_PASSWORD", "demo")

# def get_iris():
#     return iris.connect(
#         IRIS_HOST,
#         IRIS_PORT,
#         IRIS_NAMESPACE,
#         IRIS_USERNAME,
#         IRIS_PASSWORD
#     )

def get_iris():
    conn_str = f"{IRIS_HOST}:{IRIS_PORT}/{IRIS_NAMESPACE}"
    return iris.connect(conn_str, IRIS_USERNAME, IRIS_PASSWORD, sharedmemory=False)

@app.get("/api/ping")
def ping():
    return {"ok": True}


@app.get("/api/debug/raw")
def debug_raw(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        return {"raw": txt}
    finally:
        conn.close()
# @app.get("/api/ecg")
# def get_ecg():
#     conn = get_iris()
#     try:
#         irispy = iris.createIRIS(conn)
#         txt = irispy.classMethodValue(
#             "MyApp.Utils",
#             "GetLatestJSONFile"
#         )
#         return {} if not txt else json.loads(txt)
#     finally:
#         conn.close()
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
        
        # Only return the Heart Rate part
        return data.get("sleep", {})
    finally:
        conn.close()