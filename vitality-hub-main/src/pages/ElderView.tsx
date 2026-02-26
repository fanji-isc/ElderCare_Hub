import { useState, useEffect, useRef } from "react";
import { Header } from "@/components/Header";
import { CommunityPanel } from "@/components/CommunityPanel";
import { VitalCard } from "@/components/VitalCard";
import { HeartRateChart } from "@/components/HeartRateCharttest";
import { ECGVisualization } from "@/components/ECGVisualization";
import { SleepChart } from "@/components/SleepChart";
import { HydrationIndicator } from "@/components/HydrationIndicator";
import { WalkingActivityChart } from "@/components/WalkingActivityChart";
import { SmartFridgeCard } from "@/components/SmartFridgeCard";
import {
  Users, HeartHandshake, ChevronDown, ChevronUp,
  Mic, Activity, Heart, Moon, Footprints, Volume2,
  ShieldAlert, Brain,
} from "lucide-react";

const API_BASE = "http://localhost:3001";
const PATIENT_ID = "PATIENT_001";

type Vitals = {
  heartRate: number;
  steps: number;
  stressLevel: number;
  sleepHours: number;
  hydrationNote: string;       // e.g. "well hydrated" | "mildly dehydrated"
  hydrationColorLevel: number; // raw urine color level 1–7 (1=clear/hydrated, 7=dark/dehydrated)
  waterLiters: number;         // from fridge daily nutrition
  expiringItems: string[];  // fridge items expiring within 2 days
  currentItems: string[];
  mealsCount: number;          // meals detected today
  gaitNote: string;            // gait risk summary, empty if no data
  fallRiskAlert: boolean;      // true when gait concern + dehydration combine
};
type Msg = { role: "user" | "assistant"; content: string };

function pickLatest(list: any[]): any | null {
  if (!Array.isArray(list) || list.length === 0) return null;
  return [...list].sort((a, b) =>
    String(b?.calendarDate || "").localeCompare(String(a?.calendarDate || ""))
  )[0];
}

function extractStress(day: any): number {
  const awake = (day?.allDayStress?.aggregatorList ?? []).find((a: any) => a.type === "AWAKE");
  return Math.round(Number(awake?.averageStressLevel ?? 0));
}

function stressLabel(v: number) {
  if (v === 0) return "Today";
  if (v <= 25) return "Low stress";
  if (v <= 50) return "Moderate";
  if (v <= 75) return "High stress";
  return "Very high";
}

function extractSleep(sleepJson: any): number {
  if (!Array.isArray(sleepJson)) return 0;
  const latest = pickLatest(sleepJson.filter((x: any) =>
    typeof x?.calendarDate === "string" &&
    (x?.deepSleepSeconds != null || x?.lightSleepSeconds != null || x?.remSleepSeconds != null)
  ));
  if (!latest) return 0;
  return (Number(latest.deepSleepSeconds ?? 0) + Number(latest.lightSleepSeconds ?? 0) + Number(latest.remSleepSeconds ?? 0)) / 3600;
}

// colorLevel: 1=very clear (excellent), 2=pale yellow (good), 3=yellow (fine),
//             4=dark yellow (mild concern), 5=amber (dehydrated), 6+=dark amber/brown (severely dehydrated)
function extractHydration(toiletJson: any): { note: string; colorLevel: number } {
  if (!Array.isArray(toiletJson) || toiletJson.length === 0) return { note: "", colorLevel: 0 };
  const latest = pickLatest(toiletJson);
  if (!Array.isArray(latest?.readings) || latest.readings.length === 0) return { note: "", colorLevel: 0 };
  const sorted = [...latest.readings].sort((a: any, b: any) =>
    String(b.timestamp).localeCompare(String(a.timestamp))
  );
  const level = Number(sorted[0]?.colorLevel ?? 0);
  if (level === 0) return { note: "", colorLevel: 0 };
  let note = "";
  if (level <= 2) note = "well hydrated";
  else if (level <= 3) note = "adequately hydrated";
  else if (level <= 4) note = "mildly dehydrated — could drink more water";
  else if (level <= 5) note = "moderately dehydrated — needs more fluids";
  else note = "significantly dehydrated — drinking water is important right now";
  return { note, colorLevel: level };
}

function extractFridge(fridgeJson: any): { waterLiters: number; currentItems: string[];expiringItems: string[]; mealsCount: number } {
  if (!Array.isArray(fridgeJson) || fridgeJson.length === 0) return { waterLiters: 0, currentItems: [], expiringItems: [], mealsCount: 0 };
  const latest = pickLatest(fridgeJson);
  if (!latest) return { waterLiters: 0, currentItems: [],expiringItems: [], mealsCount: 0 };

  const currentItems = Array.isArray(latest.inventory)
    ? latest.inventory
        .map((inv: any) => String(inv?.item ?? ""))
        .filter(Boolean)
    : [];
  const expiringItems = (latest.alerts ?? [])
    .filter((a: any) => a.type === "expiring")
    .map((a: any) => String(a.item));
  
  return {
    waterLiters: Number(latest.dailyNutrition?.waterLiters ?? 0),
    currentItems,
    expiringItems,
    mealsCount: (latest.mealsDetected ?? []).length,
  };
}

// Clinical fall-risk thresholds for elderly (longitudinal — all sessions across all dates):
// Normal elderly walking speed: > 1.0 m/s; < 0.8 m/s = significant risk
// Normal step symmetry: > 90%; < 82% = compensatory gait; < 75% = severe asymmetry
// Stride variability: < 8% normal; > 8% elevated; > 12% clinically significant
// Ground contact time L/R difference: > 60 ms = persistent imbalance; > 100 ms = severe
function extractGait(gaitJson: any): { note: string; riskLevel: "low" | "moderate" | "high" } | null {
  if (!Array.isArray(gaitJson) || gaitJson.length === 0) return null;

  // Aggregate ALL sessions across ALL dates for a longitudinal picture
  const allSessions: any[] = [];
  for (const day of gaitJson) {
    if (Array.isArray(day?.sessions)) allSessions.push(...day.sessions);
  }
  if (allSessions.length === 0) return null;

  const n = allSessions.length;
  const avgSpeed       = allSessions.reduce((s: number, x: any) => s + Number(x.gaitSpeedMs         ?? 0), 0) / n;
  const avgSymmetry    = allSessions.reduce((s: number, x: any) => s + Number(x.stepSymmetryPct      ?? 0), 0) / n;
  const avgVariability = allSessions.reduce((s: number, x: any) => s + Number(x.strideVariabilityPct ?? 0), 0) / n;
  const avgGCTDiff     = allSessions.reduce((s: number, x: any) => {
    const l = Number(x.groundContactTimeMs?.left  ?? 0);
    const r = Number(x.groundContactTimeMs?.right ?? 0);
    return s + Math.abs(l - r);
  }, 0) / n;

  // Score — high ≥ 5, moderate 2–4, low 0–1
  let score = 0;
  if (avgSpeed < 0.6)        score += 4;
  else if (avgSpeed < 0.8)   score += 2;
  else if (avgSpeed < 1.0)   score += 1;

  if (avgSymmetry < 75)      score += 3;
  else if (avgSymmetry < 82) score += 2;
  else if (avgSymmetry < 90) score += 1;

  if (avgVariability > 12)   score += 2;
  else if (avgVariability > 8) score += 1;

  if (avgGCTDiff > 100)      score += 2;
  else if (avgGCTDiff > 60)  score += 1;

  const riskLevel: "low" | "moderate" | "high" = score >= 5 ? "high" : score >= 2 ? "moderate" : "low";
  const note = `${riskLevel} fall risk — avg walking speed ${avgSpeed.toFixed(2)} m/s, step symmetry ${Math.round(avgSymmetry)}%, stride variability ${avgVariability.toFixed(1)}%, L/R ground contact diff ${Math.round(avgGCTDiff)} ms`;
  return { note, riskLevel };
}

type Panel = "health" | "activity" | "helping" | null;

const ElderView = () => {
  const [openPanel, setOpenPanel] = useState<Panel>(null);
  const emptyVitals: Vitals = { heartRate: 0, steps: 0, stressLevel: 0, sleepHours: 0, hydrationNote: "", hydrationColorLevel: 0, waterLiters: 0, expiringItems: [], currentItems: [], mealsCount: 0, gaitNote: "", fallRiskAlert: false };
  const [vitals, setVitals] = useState<Vitals>(emptyVitals);
  const vitalsRef = useRef<Vitals>(emptyVitals);
  vitalsRef.current = vitals;

  // NOHA voice state
  const [isRecording, setIsRecording] = useState(false);
  const [isThinking, setIsThinking] = useState(false);
  const [nohaStatus, setNohaStatus] = useState("");
  const [messages, setMessages] = useState<Msg[]>([]);
  const recorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<BlobPart[]>([]);
  const streamRef = useRef<MediaStream | null>(null);
  const messagesRef = useRef<Msg[]>([]);
  messagesRef.current = messages;
  const runningRef = useRef(false);
  const scrollBottomRef = useRef<HTMLDivElement | null>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const audioSourceRef = useRef<AudioBufferSourceNode | null>(null);
  const speakAbortRef = useRef<AbortController | null>(null);
  const audioCtxRef = useRef<AudioContext | null>(null);

  // Must be called synchronously inside a user-gesture handler (pointerDown / click)
  // to unlock audio autoplay for the rest of the session.
  const unlockAudio = () => {
    if (audioCtxRef.current) return;
    try {
      const ctx = new AudioContext();
      const buf = ctx.createBuffer(1, 1, 22050);
      const src = ctx.createBufferSource();
      src.buffer = buf;
      src.connect(ctx.destination);
      src.start(0);
      audioCtxRef.current = ctx;
    } catch { /* ignore */ }
  };

  const today = new Date().toLocaleDateString("en-US", {
    weekday: "long", month: "long", day: "numeric",
  });

  const stopAudio = () => {
    try { audioSourceRef.current?.stop(); } catch { /* already stopped */ }
    audioSourceRef.current = null;
    audioRef.current?.pause();
    audioRef.current = null;
  };

  // Fetch TTS audio bytes without playing. Returns null on abort/error.
  const fetchTTSBuffer = async (text: string, signal: AbortSignal): Promise<ArrayBuffer | null> => {
    try {
      const res = await fetch(`${API_BASE}/api/speak`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text }),
        signal,
      });
      if (signal.aborted || !res.ok || !(res.headers.get("content-type") || "").startsWith("audio/")) return null;
      return await res.arrayBuffer();
    } catch {
      return null;
    }
  };

  // Play a pre-fetched ArrayBuffer; resolves when playback ends.
  const decodeAndPlay = (arrayBuffer: ArrayBuffer, signal: AbortSignal): Promise<void> =>
    new Promise((resolve) => {
      if (signal.aborted) { resolve(); return; }
      if (audioCtxRef.current) {
        audioCtxRef.current.decodeAudioData(arrayBuffer).then((audioBuffer) => {
          if (signal.aborted) { resolve(); return; }
          const source = audioCtxRef.current!.createBufferSource();
          source.buffer = audioBuffer;
          source.connect(audioCtxRef.current!.destination);
          audioSourceRef.current = source;
          source.onended = () => { audioSourceRef.current = null; resolve(); };
          source.start(0);
        }).catch(() => resolve());
      } else {
        const blob = new Blob([arrayBuffer]);
        const url = URL.createObjectURL(blob);
        const audio = new Audio(url);
        audioRef.current = audio;
        audio.onended  = () => { URL.revokeObjectURL(url); audioRef.current = null; resolve(); };
        audio.onerror  = () => { URL.revokeObjectURL(url); audioRef.current = null; resolve(); };
        audio.play().catch(() => { URL.revokeObjectURL(url); audioRef.current = null; resolve(); });
      }
    });

  // For replaying single messages (Volume2 button) — still fetches all-at-once.
  const speakText = async (text: string) => {
    speakAbortRef.current?.abort();
    const controller = new AbortController();
    speakAbortRef.current = controller;
    stopAudio();
    const buf = await fetchTTSBuffer(text, controller.signal);
    if (buf && !controller.signal.aborted) await decodeAndPlay(buf, controller.signal);
  };

  // Builds a RAG system prompt embedding Frank's live health data.
  // Passed to NOHA for open-ended voice Q&A so it can answer personal health questions.
  const buildHealthContext = (v: Vitals): string => {
    const lines: string[] = [
      "You are NOHA, a warm and caring AI health companion for Frank, an elderly person living independently.",
      "",
      "Frank's current health data (from his wearable sensors and smart home devices):",
    ];
    if (v.sleepHours)   lines.push(`- Sleep last night: ${v.sleepHours.toFixed(1)} hours`);
    if (v.heartRate)    lines.push(`- Resting heart rate: ${v.heartRate} BPM`);
    if (v.steps)        lines.push(`- Steps today: ${v.steps.toLocaleString()}`);
    if (v.stressLevel)  lines.push(`- Stress level: ${v.stressLevel}/100 (0 = very calm, 100 = very stressed)`);
    if (v.hydrationNote && v.hydrationColorLevel > 0) {
      lines.push(`- Hydration (smart toilet urine color sensor): level ${v.hydrationColorLevel}/6 — ${v.hydrationNote}`);
    }
    if (v.gaitNote)     lines.push(`- Gait / walking analysis: ${v.gaitNote}`);
    if (v.fallRiskAlert) lines.push(`- Combined fall risk alert: YES — gait irregularities combined with dehydration create elevated fall risk today`);
    if (v.mealsCount)   lines.push(`- Meals detected today (smart fridge): ${v.mealsCount}`);
    if (v.currentItems.length) lines.push(`- Current fridge inventory: ${v.currentItems.join(", ")}`);

    if (v.expiringItems.length) lines.push(`- Fridge items expiring soon: ${v.expiringItems.join(", ")}`);
    lines.push("");
    lines.push(
      "Use this personal health data to answer Frank's questions accurately and specifically. " +
      "Be warm, clear, and use simple language suitable for an elderly person. " +
      "Keep answers brief (2–3 sentences). " +
      "Do not diagnose medical conditions. " +
      "Address him as Frank."
    );
    return lines.join("\n");
  };

  // Streams tokens from /api/answer/stream (newline-delimited JSON).
  // onFirstChunk fires once when the first token arrives.
  // onChunk fires with the accumulated text on every token.
  // system: optional RAG system prompt — if omitted the backend uses its default elder-care prompt.
  // Returns the full response text.
  const streamAnswer = async (
    text: string,
    history: Msg[],
    onFirstChunk: () => void,
    onChunk: (full: string) => void,
    system?: string,
  ): Promise<string> => {
    const res = await fetch(`${API_BASE}/api/answer/stream`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text, messages: history, ...(system ? { system } : {}) }),
    });
    if (!res.ok || !res.body) throw new Error(`HTTP ${res.status}`);

    const reader = res.body.getReader();
    const decoder = new TextDecoder();
    let buffer = "";
    let fullText = "";
    let firstChunk = true;

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split("\n");
      buffer = lines.pop() ?? "";
      for (const line of lines) {
        if (!line.trim()) continue;
        try {
          const parsed = JSON.parse(line);
          if (parsed.done) return fullText;
          if (parsed.error) throw new Error(parsed.error);
          if (parsed.delta) {
            fullText += parsed.delta;
            if (firstChunk) { firstChunk = false; onFirstChunk(); }
            onChunk(fullText);
          }
        } catch { /* ignore individual parse errors */ }
      }
    }
    return fullText;
  };

  const runCheckIn = async (v: Vitals, mode: "fall" | "mental") => {
    if (runningRef.current || isRecording) return;
    runningRef.current = true;
    setIsThinking(true);

    const dataLines: string[] = [];
    let prompt = "";

    if (mode === "fall") {
      if (v.gaitNote) dataLines.push(`- Gait analysis: ${v.gaitNote}`);
      if (v.hydrationNote && v.hydrationColorLevel > 0) {
        const colorDesc = v.hydrationColorLevel <= 2 ? "clear / pale yellow (good)"
          : v.hydrationColorLevel <= 3 ? "yellow (acceptable)"
          : v.hydrationColorLevel <= 4 ? "dark yellow (mild concern)"
          : v.hydrationColorLevel <= 5 ? "amber (dehydrated)"
          : "dark amber / brown (severely dehydrated)";
        dataLines.push(`- Smart toilet urine color: level ${v.hydrationColorLevel}/6 — ${colorDesc} → ${v.hydrationNote}`);
      }
      if (v.fallRiskAlert) dataLines.push(`- COMBINED FALL RISK ALERT: gait irregularities together with dehydration significantly increase fall risk today`);

      prompt = dataLines.length
        ? `You are NOHA, a warm and caring safety companion for Frank, an elderly person living independently.

Here is Frank's fall-risk evidence right now:
${dataLines.join("\n")}

Talk to Frank simply and warmly — like a caring friend, not a doctor. Use short, easy sentences.
Briefly mention the specific evidence: what his walking sensor found (speed, symmetry) and what the toilet urine color sensor showed.
Then tell him clearly whether he needs to be extra careful today.
If there is a COMBINED FALL RISK ALERT, say it first, explain that both his gait and hydration are concerning, and give him 2 simple practical tips (e.g. drink a glass of water now, move slowly, hold handrails).
Keep it to 4–5 sentences. Address him as Frank.`
        : `You are NOHA. Warmly reassure Frank that his walking looks steady today and encourage him to keep moving safely. One sentence only. Address him as Frank.`;

    } else {
      if (v.sleepHours)  dataLines.push(`- Sleep last night: ${v.sleepHours.toFixed(1)} hours`);
      if (v.steps)       dataLines.push(`- Steps today: ${v.steps.toLocaleString()}`);
      if (v.stressLevel) dataLines.push(`- Stress level: ${v.stressLevel}/100 (0 = very calm, 100 = very stressed)`);

      prompt = dataLines.length
        ? `You are NOHA, a warm and caring companion for Frank, an elderly person living independently.

Here is how Frank is doing today:
${dataLines.join("\n")}

Talk to Frank gently and cheerfully — like a kind friend checking in. Use simple, short sentences. Comment briefly on how well he slept, how active he's been, and how relaxed or stressed he seems. If stress is high or sleep was poor, offer one simple, comforting suggestion (like a short walk, a cup of tea, or calling a friend). End with a warm, encouraging word. Keep it to 3–4 sentences. Address him as Frank.`
        : `You are NOHA. Give Frank a warm, cheerful hello and ask how his day is going. One sentence only. Address him as Frank.`;
    }

    // Add the bubble immediately (shows "Thinking…" until text arrives)
    setMessages((prev) => [...prev, { role: "assistant", content: "" }]);

    try {
      let fullText = "";
      fullText = await streamAnswer(
        prompt,
        [],
        () => { setIsThinking(false); },
        (text) => {
          setMessages((prev) => {
            const msgs = [...prev];
            if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant") {
              msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: text };
            }
            return msgs;
          });
        },
      );

      if (!fullText) {
        setMessages((prev) => {
          const msgs = [...prev];
          if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant" && !msgs[msgs.length - 1].content) {
            msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: "Good morning, Frank! I'm here whenever you need me." };
          }
          return msgs;
        });
      }
      if (fullText) speakText(fullText); // speak full response after streaming completes
    } catch {
      setMessages((prev) => {
        const msgs = [...prev];
        if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant" && !msgs[msgs.length - 1].content) {
          msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: "Good morning, Frank! I'm here whenever you need me." };
        }
        return msgs;
      });
    } finally {
      runningRef.current = false;
      setIsThinking(false);
    }
  };

  useEffect(() => {
    (async () => {
      try {
        const [dailyRes, sleepRes, toiletRes, fridgeRes, gaitRes] = await Promise.all([
          fetch(`${API_BASE}/api/dailySummary?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/sleep?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/toilet?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/fridge?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/gait?patient_id=${encodeURIComponent(PATIENT_ID)}`),
        ]);
        const dailyJson = dailyRes.ok ? await dailyRes.json() : [];
        const sleepJson = sleepRes.ok ? await sleepRes.json() : [];
        const toiletJson = toiletRes.ok ? await toiletRes.json() : [];
        const fridgeJson = fridgeRes.ok ? await fridgeRes.json() : [];
        const gaitJson  = gaitRes.ok  ? await gaitRes.json()  : [];
        const day = pickLatest(Array.isArray(dailyJson) ? dailyJson : []);
        const fridge = extractFridge(fridgeJson);
        const { note: hydrationNote, colorLevel: hydrationColorLevel } = extractHydration(toiletJson);
        const gait = extractGait(gaitJson);
        const dehydrated = hydrationNote.includes("dehydrated");
        const gaitConcern = gait !== null && gait.riskLevel !== "low";
        const loaded: Vitals = {
          heartRate: Number(day?.currentDayRestingHeartRate ?? day?.restingHeartRate ?? 0),
          steps: Number(day?.totalSteps ?? 0),
          stressLevel: extractStress(day),
          sleepHours: extractSleep(sleepJson),
          hydrationNote,
          hydrationColorLevel,
          waterLiters: fridge.waterLiters,
          expiringItems: fridge.expiringItems,
          currentItems: fridge.currentItems,
          mealsCount: fridge.mealsCount,
          gaitNote: gait?.note ?? "",
          fallRiskAlert: dehydrated && gaitConcern,
        };
        setVitals(loaded);
        vitalsRef.current = loaded; // update ref immediately — don't wait for re-render
      } catch { /* silent */ }
    })();
  }, []);

  useEffect(() => {
    scrollBottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, isThinking]);

  const startRecording = async () => {
    if (isRecording || isThinking) return;
    unlockAudio(); // synchronous — must be first, before any await
    try {
      setNohaStatus("Listening…");
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      streamRef.current = stream;

      const mime = MediaRecorder.isTypeSupported("audio/webm;codecs=opus")
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
        setNohaStatus("Transcribing…");

        const blob = new Blob(chunksRef.current, { type: mime || "audio/webm" });

        if (blob.size < 2000) {
          setNohaStatus("Too short — try again");
          streamRef.current?.getTracks().forEach((t) => t.stop());
          streamRef.current = null;
          return;
        }

        const fd = new FormData();
        fd.append("file", blob, "audio.webm");

        try {
          const res = await fetch(`${API_BASE}/api/transcribe`, { method: "POST", body: fd });
          const ct = res.headers.get("content-type") || "";
          const data: any = ct.includes("application/json")
            ? await res.json()
            : { error: await res.text() };

          if (!res.ok || data?.error) {
            setNohaStatus("Transcription failed");
            return;
          }

          const text = String(data?.transcript || "").trim();
          if (!text) {
            setNohaStatus("Didn't catch that — try again");
            return;
          }

          setNohaStatus("");
          const nextMessages: Msg[] = [...messagesRef.current, { role: "user", content: text }];
          // Add user message + empty assistant bubble immediately
          setMessages([...nextMessages, { role: "assistant", content: "" }]);
          setIsThinking(true);

          let fullAnswer = "";
          fullAnswer = await streamAnswer(
            text,
            nextMessages,
            () => { setIsThinking(false); },
            (t) => {
              setMessages((prev) => {
                const msgs = [...prev];
                if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant") {
                  msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: t };
                }
                return msgs;
              });
            },
            buildHealthContext(vitalsRef.current), // RAG: inject Frank's live health data
          );

          if (!fullAnswer) {
            setMessages((prev) => {
              const msgs = [...prev];
              if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant" && !msgs[msgs.length - 1].content) {
                msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: "Sorry — something went wrong." };
              }
              return msgs;
            });
          }
          if (fullAnswer) speakText(fullAnswer); // speak full response after streaming completes
        } catch {
          setNohaStatus("Network error");
          setMessages((prev) => [...prev, { role: "assistant", content: "Sorry — network error." }]);
        } finally {
          setIsThinking(false);
          streamRef.current?.getTracks().forEach((t) => t.stop());
          streamRef.current = null;
        }
      };

      recorder.start();
      setIsRecording(true);
    } catch {
      setNohaStatus("Mic permission denied");
    }
  };

  const stopRecording = () => {
    const r = recorderRef.current;
    if (r && r.state !== "inactive") r.stop();
  };

  const toggle = (panel: Panel) =>
    setOpenPanel((prev) => (prev === panel ? null : panel));

  const cardBase = "group flex flex-col items-center gap-4 rounded-3xl border-2 p-6 text-center shadow-md transition-all duration-200 active:scale-[0.97]";

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white">
      <Header />

      <main className="container mx-auto px-4 py-8 sm:px-6">

        {/* ── Greeting ───────────────────────────────────────────────── */}
        <div className="mb-8 text-center">
          <p className="text-lg font-medium text-muted-foreground">{today}</p>
          <h2 className="mt-1 text-5xl font-display font-bold text-foreground">
            Good morning, Frank!
          </h2>
        </div>

        {/* ── NOHA Hold-to-Talk Button ────────────────────────────────── */}
        <div className="mx-auto mb-4 max-w-2xl">
          <button
            onPointerDown={startRecording}
            onPointerUp={stopRecording}
            onPointerLeave={stopRecording}
            disabled={isThinking}
            className={[
              "w-full select-none touch-none",
              "flex flex-col items-center gap-5 rounded-3xl border-2 p-10 text-center shadow-lg",
              "transition-all duration-150",
              isRecording
                ? "border-red-400 bg-gradient-to-br from-red-500 to-rose-600 scale-[0.98] shadow-red-200"
                : isThinking
                ? "border-indigo-200 bg-gradient-to-br from-indigo-100 to-violet-100 opacity-80 cursor-not-allowed"
                : "border-indigo-200 bg-gradient-to-br from-indigo-50 to-violet-50 hover:border-indigo-400 hover:shadow-xl cursor-pointer",
            ].join(" ")}
          >
            {/* Mic icon */}
            <div className={[
              "flex h-28 w-28 items-center justify-center rounded-full shadow-md transition-all duration-150",
              isRecording ? "bg-white/25 animate-pulse" : isThinking ? "bg-indigo-300" : "bg-indigo-500",
            ].join(" ")}>
              <Mic className={`h-14 w-14 ${isRecording ? "text-white" : isThinking ? "text-indigo-700" : "text-white"}`} />
            </div>

            {/* Label */}
            <div>
              <p className={`text-4xl font-display font-bold leading-tight ${isRecording ? "text-white" : "text-indigo-900"}`}>
                {isRecording ? "Listening…" : isThinking ? "NOHA is thinking…" : "Talk to NOHA"}
              </p>
              <p className={`mt-2 text-xl ${isRecording ? "text-white/80" : "text-indigo-500"}`}>
                {isRecording
                  ? "Release to send"
                  : isThinking
                  ? messages.length === 0 ? "Preparing your morning check-in…" : "Getting your answer…"
                  : nohaStatus || "Hold to speak"}
              </p>
            </div>
          </button>

          {/* Check-in buttons */}
          <div className="mt-3 flex justify-center gap-3">
            <button
              onClick={() => { unlockAudio(); runCheckIn(vitalsRef.current, "fall"); }}
              disabled={isThinking || isRecording}
              className="flex items-center gap-2 rounded-2xl border border-orange-200 bg-white px-5 py-2.5 text-base font-medium text-orange-700 shadow-sm transition hover:bg-orange-50 hover:border-orange-400 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ShieldAlert className="h-4 w-4" />
              Fall Risk
            </button>
            <button
              onClick={() => { unlockAudio(); runCheckIn(vitalsRef.current, "mental"); }}
              disabled={isThinking || isRecording}
              className="flex items-center gap-2 rounded-2xl border border-violet-200 bg-white px-5 py-2.5 text-base font-medium text-violet-700 shadow-sm transition hover:bg-violet-50 hover:border-violet-400 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Brain className="h-4 w-4" />
              Mental Health
            </button>
          </div>
        </div>

        {/* ── Conversation history ────────────────────────────────────── */}
        {messages.length > 0 && (
          <div className="mx-auto mb-8 max-w-2xl rounded-3xl border border-indigo-100 bg-white shadow-md overflow-hidden">
            <div className="max-h-72 overflow-y-auto p-6">
              <div className="space-y-4">
                {messages.map((m, i) => (
                  <div key={i} className={`flex gap-3 ${m.role === "user" ? "flex-row-reverse" : ""}`}>
                    <span className={`shrink-0 text-base font-bold ${m.role === "user" ? "text-indigo-700" : "text-violet-700"}`}>
                      {m.role === "user" ? "You" : "NOHA"}
                    </span>
                    <div className="flex items-start gap-2">
                      <p className={`rounded-2xl px-4 py-2 text-base leading-relaxed ${
                        m.role === "user"
                          ? "bg-indigo-50 text-indigo-900"
                          : "bg-violet-50 text-violet-900"
                      }`}>
                        {m.content
                          ? m.content
                          : (isThinking && i === messages.length - 1)
                            ? <span className="inline-flex items-center gap-1 italic text-violet-400 animate-pulse">Thinking…</span>
                            : <span className="italic text-violet-400">…</span>}
                      </p>
                      {m.role === "assistant" && m.content && (
                        <button
                          onClick={() => speakText(m.content)}
                          className="mt-1 flex-shrink-0 rounded-xl p-2 text-violet-400 hover:bg-violet-50 hover:text-violet-700 transition"
                          title="Hear this"
                        >
                          <Volume2 className="h-5 w-5" />
                        </button>
                      )}
                    </div>
                  </div>
                ))}
                <div ref={scrollBottomRef} />
              </div>
            </div>
          </div>
        )}

        {/* ── Three Action Cards ─────────────────────────────────────── */}
        <div className="mx-auto max-w-3xl">
          <div className="grid gap-4 sm:grid-cols-3">
            {/* My Health */}
            <button
              onClick={() => toggle("health")}
              className={`${cardBase} ${
                openPanel === "health"
                  ? "border-blue-400 bg-blue-500 shadow-blue-200"
                  : "border-blue-100 bg-white hover:border-blue-300 hover:bg-blue-50"
              }`}
            >
              <div className={`flex h-20 w-20 items-center justify-center rounded-2xl ${openPanel === "health" ? "bg-white/20" : "bg-blue-100"}`}>
                <Activity className={`h-10 w-10 ${openPanel === "health" ? "text-white" : "text-blue-600"}`} />
              </div>
              <div>
                <p className={`text-xl font-bold leading-tight ${openPanel === "health" ? "text-white" : "text-foreground"}`}>
                  My Health
                </p>
                <p className={`mt-1 text-sm ${openPanel === "health" ? "text-white/80" : "text-muted-foreground"}`}>
                  Vitals & monitoring data
                </p>
              </div>
              {openPanel === "health"
                ? <ChevronUp className="h-6 w-6 text-white/80" />
                : <ChevronDown className="h-6 w-6 text-blue-400" />}
            </button>

            {/* Neighborhood Activities */}
            <button
              onClick={() => toggle("activity")}
              className={`${cardBase} ${
                openPanel === "activity"
                  ? "border-teal-400 bg-teal-500 shadow-teal-200"
                  : "border-teal-100 bg-white hover:border-teal-300 hover:bg-teal-50"
              }`}
            >
              <div className={`flex h-20 w-20 items-center justify-center rounded-2xl ${openPanel === "activity" ? "bg-white/20" : "bg-teal-100"}`}>
                <Users className={`h-10 w-10 ${openPanel === "activity" ? "text-white" : "text-teal-600"}`} />
              </div>
              <div>
                <p className={`text-xl font-bold leading-tight ${openPanel === "activity" ? "text-white" : "text-foreground"}`}>
                  Neighborhood Activities
                </p>
                <p className={`mt-1 text-sm ${openPanel === "activity" ? "text-white/80" : "text-muted-foreground"}`}>
                  Events & activities nearby
                </p>
              </div>
              {openPanel === "activity"
                ? <ChevronUp className="h-6 w-6 text-white/80" />
                : <ChevronDown className="h-6 w-6 text-teal-400" />}
            </button>

            {/* Helping Board */}
            <button
              onClick={() => toggle("helping")}
              className={`${cardBase} ${
                openPanel === "helping"
                  ? "border-rose-400 bg-rose-500 shadow-rose-200"
                  : "border-rose-100 bg-white hover:border-rose-300 hover:bg-rose-50"
              }`}
            >
              <div className={`flex h-20 w-20 items-center justify-center rounded-2xl ${openPanel === "helping" ? "bg-white/20" : "bg-rose-100"}`}>
                <HeartHandshake className={`h-10 w-10 ${openPanel === "helping" ? "text-white" : "text-rose-500"}`} />
              </div>
              <div>
                <p className={`text-xl font-bold leading-tight ${openPanel === "helping" ? "text-white" : "text-foreground"}`}>
                  Helping Board
                </p>
                <p className={`mt-1 text-sm ${openPanel === "helping" ? "text-white/80" : "text-muted-foreground"}`}>
                  Give or get help from neighbors
                </p>
              </div>
              {openPanel === "helping"
                ? <ChevronUp className="h-6 w-6 text-white/80" />
                : <ChevronDown className="h-6 w-6 text-rose-400" />}
            </button>
          </div>
        </div>

        {/* ── My Health Panel ────────────────────────────────────────── */}
        {openPanel === "health" && (
          <div className="mt-6 rounded-3xl border border-blue-100 bg-white p-6 shadow-lg sm:p-8">
            <h3 className="mb-6 text-2xl font-display font-bold text-foreground">My Health Today</h3>

            {/* Vital Cards */}
            <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <VitalCard
                title="Resting Heart Rate" value={vitals.heartRate} unit="BPM"
                icon={<Heart className="h-5 w-5" />} variant="heart"
                trend="stable" trendValue="Today" subtitle=""
              />
              <VitalCard
                title="Sleep" value={vitals.sleepHours ? vitals.sleepHours.toFixed(1) : "—"}
                unit={vitals.sleepHours ? "hours" : ""}
                icon={<Moon className="h-5 w-5" />} variant="sleep"
                trend="stable" trendValue="Last night" subtitle=""
              />
              <VitalCard
                title="Steps" value={vitals.steps} unit=""
                icon={<Footprints className="h-5 w-5" />} variant="ecg"
                trend="stable" trendValue="Today" subtitle=""
              />
              <VitalCard
                title="Stress Level" value={vitals.stressLevel || "—"}
                unit={vitals.stressLevel ? "/ 100" : ""}
                icon={<Activity className="h-5 w-5" />} variant="stress"
                trend="stable" trendValue={stressLabel(vitals.stressLevel)} subtitle=""
              />
            </div>

            {/* Charts */}
            <div className="mb-6 grid gap-6 lg:grid-cols-2">
              <HeartRateChart />
              <ECGVisualization />
            </div>
            <div className="mb-6 grid gap-6 lg:grid-cols-2">
              <SleepChart />
              <HydrationIndicator />
            </div>
            <div className="grid gap-6 lg:grid-cols-2">
              <WalkingActivityChart />
              <SmartFridgeCard />
            </div>
          </div>
        )}

        {/* ── Neighborhood Activities Panel ──────────────────────────── */}
        {openPanel === "activity" && (
          <div className="mt-6 rounded-3xl border border-teal-100 bg-white p-6 shadow-lg sm:p-8">
            <CommunityPanel section="activity" />
          </div>
        )}

        {/* ── Helping Board Panel ────────────────────────────────────── */}
        {openPanel === "helping" && (
          <div className="mt-6 rounded-3xl border border-rose-100 bg-white p-6 shadow-lg sm:p-8">
            <CommunityPanel section="helping" />
          </div>
        )}

        <div className="h-12" />
      </main>
    </div>
  );
};

export default ElderView;
