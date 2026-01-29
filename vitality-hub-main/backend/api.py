from fastapi import FastAPI
import iris
import json
import os
from config import IRIS_HOST, IRIS_PORT, IRIS_NAMESPACE, IRIS_USERNAME, IRIS_PASSWORD

app = FastAPI()


def get_iris():
    conn_str = f"{IRIS_HOST}:{IRIS_PORT}/{IRIS_NAMESPACE}"
    return iris.connect(conn_str, IRIS_USERNAME, IRIS_PASSWORD, sharedmemory=False)


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