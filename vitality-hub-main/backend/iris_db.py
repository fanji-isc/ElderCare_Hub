print(">>> iris_db.py started", flush=True)

import iris, json, os, time

# Connection Settings
IRIS_HOST = os.environ.get("IRIS_HOST", "iris4health")
IRIS_PORT = os.environ.get("IRIS_PORT", "1972")
IRIS_NAMESPACE = os.environ.get("IRIS_NAMESPACE", "USER")
IRIS_USERNAME = os.environ.get("IRIS_USERNAME", "_SYSTEM")
IRIS_PASSWORD = os.environ.get("IRIS_PASSWORD", "demo")

def connect_once_ready(conn_str, user, pwd, tries=60, sleep_s=2):
    for i in range(tries):
        try:
            return iris.connect(conn_str, user, pwd, sharedmemory=False)
        except Exception:
            if i % 5 == 0:
                print(f">>> Waiting for IRIS... (attempt {i+1})", flush=True)
            time.sleep(sleep_s)
    return None

def main():
    base = os.path.dirname(os.path.abspath(__file__))
    
    # 1. Load Garmin Files
    def safe_load(filename):
        path = os.path.join(base, "..", "garmin", filename)
        try:
            with open(path, "r", encoding="utf-8") as f:
                return f.read()
        except FileNotFoundError:
            print(f"--- Warning: {filename} not found.")
            return ""

    ecg_text = safe_load("ecg.json")
    hr_text = safe_load("heart_rate.json")
    sleep_text = safe_load("sleep.json")

    patient_id = "PATIENT_001"

    conn_str = f"{IRIS_HOST}:{IRIS_PORT}/{IRIS_NAMESPACE}"
    conn = connect_once_ready(conn_str, IRIS_USERNAME, IRIS_PASSWORD)
    
    if not conn:
        print(">>> Failed to connect to IRIS.")
        return

    try:
        irispy = iris.createIRIS(conn)
        
        # 2. COMPILE CHECK: Pointing to the root of your source
        # This will now find /iris-src/MyApp/ because of the folder we created
        print(">>> Compiling classes...", flush=True)
        # status = irispy.classMethodValue("%SYSTEM.OBJ", "LoadDir", "/iris-src", "ck")
        
        # if status != 1:
        #     print(">>> ERROR: Compilation failed. Check folder structure and .cls syntax.", flush=True)
        #     return

        st1 = irispy.classMethodValue("%SYSTEM.OBJ", "Load", "/iris-src/MyApp/JSONStore.cls", "ck")
        if irispy.classMethodValue("%SYSTEM.Status", "IsError", st1):
            raise RuntimeError(irispy.classMethodValue("%SYSTEM.Status", "GetErrorText", st1))

        # compile Utils next
        st2 = irispy.classMethodValue("%SYSTEM.OBJ", "Load", "/iris-src/MyApp/Utils.cls", "ck")
        if irispy.classMethodValue("%SYSTEM.Status", "IsError", st2):
            raise RuntimeError(irispy.classMethodValue("%SYSTEM.Status", "GetErrorText", st2))


        # 3. SAVE DATA: Passing all 4 arguments to MyApp.Utils:SavePatientData
        record_id = irispy.classMethodValue(
            "MyApp.Utils", 
            "SavePatientData", 
            patient_id, 
            ecg_text, 
            hr_text,
            sleep_text
        )
        
        if record_id and record_id != "0":
            print(f">>> Success! Record saved for {patient_id} with ID = {record_id}", flush=True)
        else:
            print(">>> Error: SavePatientData returned 0. Check IRIS logs for %Save() errors.", flush=True)
        
    except Exception as e:
        print(f">>> Runtime Error: {e}", flush=True)
    finally:
        conn.close()
        
if __name__ == "__main__":
    main()