from fastapi import FastAPI, UploadFile, File
from fastapi.responses import Response
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



# client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
def get_openai_client():
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        return None
    return OpenAI(api_key=api_key)




# @app.post("/api/answer")
# async def answer(payload: dict = Body(...)):
#     """
#     Takes text from the user and returns a friendly response.
#     """
#     client = get_openai_client()
#     if client is None:
#         return {"error": "OPENAI_API_KEY not set"}

#     user_text = payload.get("text", "").strip()
#     if not user_text:
#         return {"error": "Empty input"}

#     try:
#         completion = client.chat.completions.create(
#             model="gpt-4o-mini",
#             messages=[
#                 {
#                     "role": "system",
#                     "content": (
#                         "You are a calm, friendly elder-care assistant. "
#                         "Speak clearly, briefly, and reassuringly. "
#                         "Do not give medical diagnoses. "
#                         "If unsure, suggest contacting a caregiver."
#                     ),
#                 },
#                 {
#                     "role": "user",
#                     "content": user_text,
#                 },
#             ],
#             temperature=0.3,
#         )

#         answer_text = completion.choices[0].message.content.strip()
#         return {"answer": answer_text}

#     except Exception as e:
#         print("Answer error:", repr(e))
#         return {"error": str(e)}
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

    # Add the newest user message at the end (important)
    chat = [system_msg] + history + [{"role": "user", "content": user_text}]

    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=chat,
        temperature=0.3,
    )

    answer_text = completion.choices[0].message.content.strip()
    return {"answer": answer_text}


def get_iris():
    conn_str = f"{IRIS_HOST}:{IRIS_PORT}/{IRIS_NAMESPACE}"
    return iris.connect(conn_str, IRIS_USERNAME, IRIS_PASSWORD, sharedmemory=False)


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