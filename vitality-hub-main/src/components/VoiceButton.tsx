import React, { useRef, useState } from "react";

type Props = {
  apiBase?: string;              // e.g. "http://localhost:3001"
  onTranscript: (text: string) => void;
};

export default function VoiceButton({
  apiBase = "http://localhost:3001",
  onTranscript,
}: Props) {
  const [isRecording, setIsRecording] = useState(false);
  const [status, setStatus] = useState<string>("");

  const recorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<BlobPart[]>([]);
  const streamRef = useRef<MediaStream | null>(null);

  const start = async () => {
    try {
      setStatus("Listening...");
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      streamRef.current = stream;

      // Safer mime selection across browsers
      const mime =
        MediaRecorder.isTypeSupported("audio/webm;codecs=opus")
          ? "audio/webm;codecs=opus"
          : MediaRecorder.isTypeSupported("audio/webm")
          ? "audio/webm"
          : "";

      const recorder = new MediaRecorder(stream, mime ? { mimeType: mime } : undefined);
      recorderRef.current = recorder;
      chunksRef.current = [];

      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) chunksRef.current.push(e.data);
      };

      recorder.onstop = async () => {
        setIsRecording(false);
        setStatus("Transcribing...");

        const blob = new Blob(chunksRef.current, { type: mime || "audio/webm" });

        // Prevent sending tiny/empty audio (very common cause of flaky failures)
        if (blob.size < 2000) {
            setStatus("Too short — try again");
            streamRef.current?.getTracks().forEach((t) => t.stop());
            streamRef.current = null;
            return;
        }

        const fd = new FormData();
        fd.append("file", blob, "audio.webm");

        try {
            const res = await fetch(`${apiBase}/api/transcribe`, {
            method: "POST",
            body: fd,
            });

            // fetch() does NOT throw on HTTP errors, so we must inspect the response
            const contentType = res.headers.get("content-type") || "";
            const data: any = contentType.includes("application/json")
            ? await res.json()
            : { error: await res.text() };

            console.log("TRANSCRIBE:", res.status, data);

            if (!res.ok) {
            setStatus(`Transcription failed (${res.status})`);
            return;
            }
            if (data?.error) {
            setStatus(String(data.error));
            return;
            }

            const text = String(data?.transcript || "").trim();
            onTranscript(text);
            setStatus("");
        } catch (e) {
            console.error(e);
            setStatus("Transcription failed (network)");
        } finally {
            streamRef.current?.getTracks().forEach((t) => t.stop());
            streamRef.current = null;
        }
        };


      recorder.start();
      setIsRecording(true);
    } catch (e) {
      console.error(e);
      setStatus("Mic permission denied");
    }
  };

  const stop = () => {
    const r = recorderRef.current;
    if (r && r.state !== "inactive") r.stop();
  };

  return (
    <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
      <button
        onMouseDown={start}
        onMouseUp={stop}
        onTouchStart={start}
        onTouchEnd={stop}
        style={{
          padding: "10px 14px",
          borderRadius: 10,
          border: "none",
          color: "white",
          background: isRecording ? "#dc2626" : "#0f172a",
          fontSize: 16,
          cursor: "pointer",
        }}
      >
        {isRecording ? "Release to send" : "Hold to talk 🎤"}
      </button>
      <div style={{ fontSize: 14, opacity: 0.8 }}>{status}</div>
    </div>
  );
}
