from fastapi import FastAPI, UploadFile, File
from fastapi.responses import Response, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi import HTTPException

import iris
import json
import os
import tempfile
from openai import OpenAI
from config import IRIS_HOST, IRIS_PORT, IRIS_NAMESPACE, IRIS_USERNAME, IRIS_PASSWORD
from fastapi import Body

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


@app.get("/api/steps")
def get_steps(patient_id: str = ""):
    conn = get_iris()
    try:
        irispy = iris.createIRIS(conn)
        txt = irispy.classMethodValue("MyApp.Utils", "GetLatestJSONFile", patient_id)
        data = json.loads(txt) if txt else {}

        # dailySummary might be:
        # - a dict
        # - a list (like the JSON you pasted)
        daily = data.get("dailySummary", {})

        if isinstance(daily, list) and len(daily) > 0:
            # pick the first record (or latest depending on your storage)
            steps = daily[0].get("totalSteps", 0)
        elif isinstance(daily, dict):
            steps = daily.get("totalSteps", 0)
        else:
            steps = 0

        return {"steps": steps}
    finally:
        conn.close()


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
            "Do not give medical diagnoses. "
            "If unsure, suggest contacting a healthcare professcional."
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
            "Do not give medical diagnoses. "
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