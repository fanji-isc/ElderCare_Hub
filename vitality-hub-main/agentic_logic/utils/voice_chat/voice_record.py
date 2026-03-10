import os 
import json
import queue
import sounddevice as sd
from vosk import Model, KaldiRecognizer

MODEL_PATH = os.path.join(os.path.dirname(__file__), "voice_model")

def record_from_mic(model_path: str = MODEL_PATH, samplerate: int = 16000, device = None):
    q = queue.Queue()
    model = Model(model_path)
    rec = KaldiRecognizer(model, samplerate)

    captured_segments = []
    running = True

    def callback(indata, frames, time, status):
        if status:
            print(status)
        q.put(bytes(indata))

    def stop():
        nonlocal running
        running = False

    print('Listening... Say "start" to start listening and "stop" at the end of a sentence to stop recording.\n')

    try:
        with sd.RawInputStream(
            samplerate=samplerate,
            blocksize=8000,
            device=device,
            dtype="int16",
            channels=1,
            callback=callback,
        ):
            while running:
                data = q.get()
                if rec.AcceptWaveform(data):
                    result = json.loads(rec.Result())
                    text = result.get("text", "").strip()

                    if text:
                        captured_segments.append(text)

                        words = text.split()
                        if words and words[-1].lower() == "stop":
                            print('Detected "stop". Stopping recording...')
                            stop()
                            break

    except KeyboardInterrupt:
        print("\nStopping...")

    final_result = json.loads(rec.FinalResult()).get("text", "").strip()
    if final_result:
        captured_segments.append(final_result)

    full_text = " ".join(captured_segments).strip().lower()

    if "start" in full_text and "stop" in full_text:
        start_index = full_text.find("start") + len("start")
        stop_index = full_text.rfind("stop")
        return full_text[start_index:stop_index].strip()
    return ""