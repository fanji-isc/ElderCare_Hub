import { useState, useEffect, useRef } from "react";
import { Header } from "@/components/Header";
import { CommunityPanel } from "@/components/CommunityPanel";
import { HeartRateChart } from "@/components/HeartRateChart";
import { ECGVisualization } from "@/components/ECGVisualization";
import { SleepChart } from "@/components/SleepChart";
import { HydrationIndicator } from "@/components/HydrationIndicator";
import { WalkingActivityChart } from "@/components/WalkingActivityChart";
import { SmartFridgeCard } from "@/components/SmartFridgeCard";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import {
  Users, HeartHandshake, ChevronDown, ChevronUp,
  Mic, Activity, Heart, Moon, Footprints, Volume2,
  ShieldAlert, Brain, Calendar,
  Utensils, Shield, Droplets, Pill,
  Phone, PhoneOff, PhoneCall, PhoneIncoming,
} from "lucide-react";
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid,
  Tooltip, ReferenceLine, ResponsiveContainer,
} from "recharts";

const API_BASE = "http://localhost:3001";
const HOME_ID = "PATIENT_001";
const first_name = "Frank"
const last_name = "Larson"

type Vitals = {
  heartRate: number;
  steps: number;
  stressLevel: number;
  sleepHours: number;
  hydrationNote: string;
  hydrationColorLevel: number;
  waterLiters: number;
  expiringItems: string[];
  currentItems: string[];
  mealsCount: number;
  gaitNote: string;
  fallRiskAlert: boolean;
};
type Msg = { role: "user" | "assistant"; content: string };
type Med = { drug: string; status: string; authored: string; dosage: string };
type Appt = { status: string; start: string; end: string; type: string; practitioner: string; location: string };

// ── Health card status helpers ─────────────────────────────────────────────────
function heartStatus(bpm: number) {
  if (bpm === 0)              return { label: "No data",           note: "Heart rate unavailable",                   color: "text-muted-foreground",  status: "fair" as const };
  if (bpm >= 55 && bpm <= 85) return { label: "Normal range",      note: `${bpm} BPM — healthy resting rate`,        color: "text-emerald-600",       status: "good" as const };
  if (bpm > 85 && bpm <= 100) return { label: "Slightly elevated", note: `${bpm} BPM — monitor if it persists`,      color: "text-amber-600",         status: "fair" as const };
  if (bpm < 55 && bpm > 0)    return { label: "Slightly low",      note: `${bpm} BPM — could be normal if athletic`, color: "text-amber-600",         status: "fair" as const };
  return                             { label: "Check with doctor",  note: `${bpm} BPM — outside normal range`,       color: "text-rose-600",          status: "warn" as const };
}

function stepsStatus(steps: number) {
  if (steps === 0)   return { label: "No data",            note: "Activity data unavailable",                          color: "text-muted-foreground",  status: "fair" as const };
  if (steps >= 5000) return { label: "Very active",        note: `${steps.toLocaleString()} steps — excellent!`,       color: "text-emerald-600",       status: "good" as const };
  if (steps >= 2500) return { label: "Moderately active",  note: `${steps.toLocaleString()} steps — good movement`,    color: "text-emerald-600",       status: "good" as const };
  if (steps >= 1000) return { label: "Light activity",     note: `${steps.toLocaleString()} steps — quieter day`,      color: "text-amber-600",         status: "fair" as const };
  return                  { label: "Very little movement", note: `${steps.toLocaleString()} steps — try a short walk`, color: "text-rose-600",          status: "warn" as const };
}

function stressStatus(v: number) {
  if (v === 0)  return { label: "Calm",        note: "Stress levels look great",    color: "text-emerald-600", status: "good" as const, barColor: "bg-emerald-500" };
  if (v <= 35)  return { label: "Calm",        note: "Very relaxed today",          color: "text-emerald-600", status: "good" as const, barColor: "bg-emerald-500" };
  if (v <= 60)  return { label: "Mild stress", note: "Some stress — likely normal", color: "text-amber-600",   status: "fair" as const, barColor: "bg-amber-500" };
  return              { label: "High stress",  note: "Elevated — try to relax",     color: "text-rose-600",    status: "warn" as const, barColor: "bg-rose-500" };
}

function sleepStatus(h: number) {
  if (h === 0)  return { label: "No data",     note: "Sleep data unavailable",                   color: "text-muted-foreground",  status: "fair" as const };
  if (h >= 7)   return { label: "Well rested", note: `${h.toFixed(1)} hrs — great for his age`,  color: "text-emerald-600",       status: "good" as const };
  if (h >= 5.5) return { label: "Light sleep", note: `${h.toFixed(1)} hrs — a bit below ideal`,  color: "text-amber-600",         status: "fair" as const };
  return               { label: "Poor sleep",  note: `Only ${h.toFixed(1)} hrs — worth monitoring`, color: "text-rose-600",       status: "warn" as const };
}

function hydrationStatus(level: number) {
  if (level === 0) return { label: "No data",          note: "Hydration data unavailable",       color: "text-muted-foreground", status: "fair" as const };
  if (level <= 2)  return { label: "Excellent",        note: "Well hydrated — great job!",       color: "text-emerald-600",      status: "good" as const };
  if (level <= 3)  return { label: "Normal",           note: "Hydration looks normal",           color: "text-emerald-600",      status: "good" as const };
  if (level <= 4)  return { label: "Drink More Water", note: "Could use a bit more water",       color: "text-amber-600",        status: "fair" as const };
  if (level <= 5)  return { label: "Mild Dehydration", note: "Drink a glass of water now",       color: "text-amber-600",        status: "fair" as const };
  if (level <= 6)  return { label: "Dehydrated",       note: "Needs more fluids soon",           color: "text-rose-600",         status: "warn" as const };
  return                  { label: "Very Dehydrated",  note: "Drink water — this is important",  color: "text-rose-600",         status: "warn" as const };
}

function gaitStatus(symmetryPct: number, variabilityPct: number, speedMs: number, cadence: number, worseStride: number, worseGCT: number) {
  if (symmetryPct === 0) return { label: "No data", note: "Gait data unavailable",          color: "text-muted-foreground", status: "fair" as const };
  const isHigh = cadence < 80  || speedMs < 0.7  || worseStride < 90  || worseGCT > 950 || symmetryPct < 78  || variabilityPct > 10;
  if (isHigh) return { label: "High Risk",     note: "Significant gait irregularities detected", color: "text-rose-600",    status: "warn" as const };
  const isMed  = cadence < 100 || speedMs < 1.0  || worseStride < 140 || worseGCT > 650 || symmetryPct < 95  || variabilityPct > 5;
  if (isMed)  return { label: "Moderate Risk", note: "Some asymmetry — worth monitoring",        color: "text-amber-600",   status: "fair" as const };
  return             { label: "Low Risk",      note: "Gait looks steady and balanced",           color: "text-emerald-600", status: "good" as const };
}

// ── ModalCard ─────────────────────────────────────────────────────────────────
function ModalCard({
  icon: Icon, iconBg, gradient, title, subtitle, children,
}: {
  icon: React.ElementType; iconBg: string; gradient: string;
  title: string; subtitle?: string; children: React.ReactNode;
}) {
  return (
    <div className="rounded-2xl bg-card shadow-card overflow-hidden">
      <div className={`flex items-center gap-3 border-b border-border px-5 py-3.5 bg-gradient-to-r ${gradient}`}>
        <div className={`flex h-9 w-9 items-center justify-center rounded-xl ${iconBg} text-primary-foreground`}>
          <Icon className="h-4 w-4" />
        </div>
        <div>
          <p className="text-sm font-semibold text-foreground leading-tight">{title}</p>
          {subtitle && <p className="text-xs text-muted-foreground">{subtitle}</p>}
        </div>
      </div>
      <div className="p-5">{children}</div>
    </div>
  );
}

// ── HealthCard ────────────────────────────────────────────────────────────────
function HealthCard({
  icon: Icon, iconBg, cardBg, title, label, labelColor, onClick,
}: {
  icon: React.ElementType; iconBg: string; cardBg: string;
  title: string; label: string; labelColor: string; onClick: () => void;
}) {
  return (
    <div onClick={onClick}
      className={`rounded-2xl shadow-card overflow-hidden cursor-pointer group hover:shadow-lg transition-shadow px-5 py-6 flex flex-col justify-center ${cardBg}`}>
      <div className="flex items-center gap-3 mb-4">
        <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${iconBg}`}>
          <Icon className="h-5 w-5" />
        </div>
        <span className="text-base font-semibold text-foreground">{title}</span>
      </div>
      <p className={`text-sm font-medium leading-tight ${labelColor}`}>{label}</p>
    </div>
  );
}

// ── MedicationDetail ──────────────────────────────────────────────────────────
function MedicationDetail() {
  const [meds, setMeds] = useState<Med[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchMeds = async () => {
      try {
        const res = await fetch(`${API_BASE}/api/patient-medications?first_name=${first_name}&last_name=${last_name}`);
        if (!res.ok) throw new Error("Patient not found or server error");
        
        const data = await res.json();
        setMeds(data);
      } catch (e: any) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    };

    if (first_name && last_name) fetchMeds();
  }, [first_name, last_name]);

  if (loading) return <div className="flex items-center justify-center py-12"><p className="text-sm text-muted-foreground">Loading medications…</p></div>;
  if (error)   return <div className="flex items-center justify-center py-12"><p className="text-sm text-rose-600">{error}</p></div>;
  if (!meds.length) return <div className="flex items-center justify-center py-12"><p className="text-sm text-muted-foreground">No medication records found.</p></div>;

  return (
    <div className="space-y-2">
      {meds.map((med, i) => {
        const authored = med.authored
          ? new Date(med.authored).toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" })
          : null;
        return (
          <div key={i} className="rounded-xl bg-muted/40 px-4 py-3">
            <div className="flex items-start justify-between gap-3">
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-foreground">{med.drug}</p>
                {med.dosage && <p className="mt-0.5 text-xs text-muted-foreground">{med.dosage}</p>}
                {authored && <p className="mt-0.5 text-xs text-muted-foreground/60">Prescribed {authored}</p>}
              </div>
              <span className={`flex-shrink-0 text-xs font-medium px-2.5 py-0.5 rounded-full ${
                med.status === "active" ? "bg-emerald-100 text-emerald-700" : "bg-muted text-muted-foreground"
              }`}>
                {med.status}
              </span>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ── AppointmentsDetail ────────────────────────────────────────────────────────
function AppointmentsDetail() {
  const [appts, setAppts] = useState<Appt[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchAppts = async () => {
      try {
        const res = await fetch(`${API_BASE}/api/patient-appointments?first_name=${first_name}&last_name=${last_name}`);
        if (!res.ok) throw new Error("Patient not found or server error");
        
        const data: Appt[] = await res.json();
        setAppts(Array.isArray(data) ? data : []);
      } catch (e: any) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    };

    if (first_name && last_name) fetchAppts();
  }, [first_name, last_name]);

  if (loading) return <div className="flex items-center justify-center py-12"><p className="text-sm text-muted-foreground">Loading appointments…</p></div>;
  if (error)   return <div className="flex items-center justify-center py-12"><p className="text-sm text-rose-600">{error}</p></div>;
  if (!appts.length) return <div className="flex items-center justify-center py-12"><p className="text-sm text-muted-foreground">No upcoming appointments scheduled.</p></div>;

  return (
    <div className="space-y-3">
      {appts.map((appt, i) => {
        const startDate = appt.start
          ? new Date(appt.start).toLocaleDateString("en-US", { weekday: "short", year: "numeric", month: "long", day: "numeric" })
          : null;
        const startTime = appt.start
          ? new Date(appt.start).toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" })
          : null;
        return (
          <div key={i} className="rounded-xl bg-violet-50 border border-violet-100 px-4 py-3">
            <div className="flex items-start gap-3">
              <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-violet-100">
                <Calendar className="h-5 w-5 text-violet-600" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-foreground">{appt.type}</p>
                {startDate && (
                  <p className="mt-0.5 text-sm text-violet-700 font-medium">
                    {startDate}{startTime ? ` at ${startTime}` : ""}
                  </p>
                )}
                {appt.practitioner && <p className="mt-0.5 text-xs text-muted-foreground">{appt.practitioner}</p>}
                {appt.location && <p className="text-xs text-muted-foreground">{appt.location}</p>}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────
type Panel = "health" | "activity" | "helping" | null;

const ElderView = () => {
  const today = new Date().toLocaleDateString("en-US", {
    weekday: "long", month: "long", day: "numeric",
  });
  // Set vitals
  const [openPanel, setOpenPanel] = useState<Panel>(null);
  const [demoOpen, setDemoOpen] = useState(false);
  const [pendingJoinId, setPendingJoinId] = useState<number | null>(null);
  const emptyVitals: Vitals = { heartRate: 0, steps: 0, stressLevel: 0, sleepHours: 0, hydrationNote: "", hydrationColorLevel: 0, waterLiters: 0, expiringItems: [], currentItems: [], mealsCount: 0, gaitNote: "", fallRiskAlert: false };
  const [vitals, setVitals] = useState<Vitals>(emptyVitals);
  const vitalsRef = useRef<Vitals>(emptyVitals);
  vitalsRef.current = vitals;

  // Health card state
  const [gaitMetrics, setGaitMetrics] = useState({ symmetry: 0, variability: 0, speed: 0, cadence: 0, worseStride: 0, worseGCT: 0 });
  const [stepHistory, setStepHistory] = useState<{ day: string; steps: number }[]>([]);
  const [openModal, setOpenModal] = useState<string | null>(null);

  // Phone call state
  const [callState, setCallState] = useState<"idle" | "calling" | "connected" | "declined">("idle");
  const [familyCallIncoming, setFamilyCallIncoming] = useState(false);
  const [familyCallConnected, setFamilyCallConnected] = useState(false);
  const [callSeconds, setCallSeconds] = useState(0);

  // NHH voice state
  const [isRecording, setIsRecording] = useState(false);
  const [isThinking, setIsThinking] = useState(false);
  const [NHHStatus, setNHHStatus] = useState("");
  const [messages, setMessages] = useState<Msg[]>([]);
  const recorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<BlobPart[]>([]);
  const streamRef = useRef<MediaStream | null>(null);
  const messagesRef = useRef<Msg[]>([]);
  messagesRef.current = messages;
  const runningRef = useRef(false);
  const neighborhoodRef = useRef<string>("");
  const scrollBottomRef = useRef<HTMLDivElement | null>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const audioSourceRef = useRef<AudioBufferSourceNode | null>(null);
  const speakAbortRef = useRef<AbortController | null>(null);
  const audioCtxRef = useRef<AudioContext | null>(null);

  const [systemMsg, setSystemMsg] = useState<string>("");

  useEffect(() => {
    const fetchSystemPrompt = async () => {
      try {
        const response = await fetch(`${API_BASE}/api/system-prompt?patient_id=${HOME_ID}`);
        
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }

        const data = await response.text();
        setSystemMsg(data);
      } catch (error) {
        console.error("Error fetching system prompt:", error);
        setSystemMsg("Error loading system message.");
      }
    };

    fetchSystemPrompt();
  }, []);

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
  const stopAudio = () => {
    try { audioSourceRef.current?.stop(); } catch { /* already stopped */ }
    audioSourceRef.current = null;
    audioRef.current?.pause();
    audioRef.current = null;
  };
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
  const decodeAndPlay = (arrayBuffer: ArrayBuffer, signal: AbortSignal): Promise<void> =>
    new Promise((resolve) => {
      if (signal.aborted) { resolve(); return; }
      // Use <audio> element rather than decodeAudioData: Chrome's Web Audio MP3 decoder
      // uses the Xing/LAME header to determine duration, which TTS-generated MP3s often
      // report inaccurately (shorter than actual speech), silently trimming the last sentence.
      // The <audio> element decodes frame-by-frame and always plays the complete file.
      const blob = new Blob([arrayBuffer], { type: "audio/mpeg" });
      const url = URL.createObjectURL(blob);
      const audio = new Audio(url);
      audioRef.current = audio;
      audio.onended  = () => { URL.revokeObjectURL(url); audioRef.current = null; resolve(); };
      audio.onerror  = () => { URL.revokeObjectURL(url); audioRef.current = null; resolve(); };
      audio.play().catch(() => { URL.revokeObjectURL(url); audioRef.current = null; resolve(); });
    });

  const ttsReady = (text: string): string => {
    const t = text.trim().replace(/[\r\n]+/g, " ");
    return /[.!?]$/.test(t) ? t : t + ".";
  };
  const speakText = async (text: string) => {
    speakAbortRef.current?.abort();
    const controller = new AbortController();
    speakAbortRef.current = controller;
    stopAudio();
    const buf = await fetchTTSBuffer(text, controller.signal);
    if (buf && !controller.signal.aborted) await decodeAndPlay(buf, controller.signal);
  };

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
      if (done) {
        // Flush any remaining bytes held by the TextDecoder
        buffer += decoder.decode();
        break;
      }
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
    // Process any remaining content left in the buffer after the stream closes
    if (buffer.trim()) {
      try {
        const parsed = JSON.parse(buffer);
        if (parsed.delta) {
          fullText += parsed.delta;
          onChunk(fullText);
        }
      } catch { /* ignore incomplete trailing data */ }
    }
    return fullText;
  };

  const runCheckIn = async (_v: Vitals, mode: "fall" | "mental") => {
    if (runningRef.current || isRecording) return;
    runningRef.current = true;
    setIsThinking(true);
    const prompt = await fetch(`${API_BASE}/api/checkin-prompt?mode=${mode}`).then(res => res.ok ? res.text() : "Error: Could not retrieve checkin prompt.");
    speakAbortRef.current?.abort();
    const ttsCtrl = new AbortController();
    speakAbortRef.current = ttsCtrl;
    stopAudio();
    setMessages([{ role: "assistant", content: "" }]);
    try {
      const fullText = await streamAnswer(
        prompt, [],
        () => { /* keep Thinking… visible until TTS is ready */ },
        () => { /* accumulate internally — don't update UI yet */ },
        systemMsg
      );
      if (!fullText) {
        setMessages((prev) => {
          const msgs = [...prev];
          if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant" && !msgs[msgs.length - 1].content) {
            msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: `Good morning, ${first_name}! I'm here whenever you need me.` };
          }
          return msgs;
        });
        return;
      }
      const buf = await fetchTTSBuffer(ttsReady(fullText), ttsCtrl.signal);
      setMessages([{ role: "assistant", content: fullText }]);
      if (buf && !ttsCtrl.signal.aborted) await decodeAndPlay(buf, ttsCtrl.signal);
    } catch {
      setMessages((prev) => {
        const msgs = [...prev];
        if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant" && !msgs[msgs.length - 1].content) {
          msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: `Good morning, ${first_name}! I'm here whenever you need me.` };
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
        // Build neighborhood RAG text 
        // TODO: remove this
        neighborhoodRef.current = await fetch(`${API_BASE}/api/build-neighbourhood-context?patient_id=${HOME_ID}&first_name=${first_name}`).then(res => res.ok ? res.text() : "Error: Could not retrieve neighbourhood context.");

        const res = await fetch(`${API_BASE}/api/build-patient-dashboard?patient_id=${HOME_ID}`);
        if (!res.ok) {
          const errorData = await res.json().catch(() => ({ detail: "Unknown Error" }));
          throw new Error(errorData.detail || "Fetch failed");
        }
        const dashboardData = await res.json() as any;
        const loaded: Vitals = {
          ...dashboardData
        };
        console.log("Fetched Vitals Data:", loaded);
        setVitals(loaded);
        vitalsRef.current = loaded;

        // Extract latest session gait metrics for health card status
        const incomingMetrics = dashboardData.gaitMetrics || {};
        setGaitMetrics({ 
            ...incomingMetrics 
        });

        // Build step history for trend chart
        setStepHistory(dashboardData.stepHistory ?? []);
      } catch (error) { console.error("Error fetching patient dashboard:", error); }
    })();
  }, []);

  useEffect(() => {
    scrollBottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, isThinking]);

  // ── Derived health card status values ────────────────────────────────────
  const sleepS     = sleepStatus(vitals.sleepHours);
  const heartS     = heartStatus(vitals.heartRate);
  const stepsS     = stepsStatus(vitals.steps);
  const stressS    = stressStatus(vitals.stressLevel);
  const hydrationS = hydrationStatus(vitals.hydrationColorLevel);
  const gaitS      = gaitStatus(gaitMetrics.symmetry, gaitMetrics.variability, gaitMetrics.speed, gaitMetrics.cadence, gaitMetrics.worseStride, gaitMetrics.worseGCT);

  const renderModalContent = () => {
    switch (openModal) {
      case "heart":
        return (
          <div className="flex flex-col gap-4">
            <HeartRateChart />
            <ECGVisualization />
          </div>
        );
      case "sleep":
        return <SleepChart />;
      case "stress":
        return (
          <ModalCard icon={Brain} iconBg="bg-stress" gradient="from-purple-50 to-violet-50"
            title="Stress" subtitle={stressS.note}>
            <div className="space-y-4 max-w-md">
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Score today</span>
                <span className={`text-2xl font-bold ${stressS.color}`}>
                  {vitals.stressLevel > 0 ? vitals.stressLevel : "—"}
                  <span className="text-sm font-normal text-muted-foreground"> / 100</span>
                </span>
              </div>
              <div className="h-3 rounded-full bg-muted overflow-hidden">
                <div className={`h-full rounded-full transition-all ${stressS.barColor}`} style={{ width: `${Math.min(100, vitals.stressLevel)}%` }} />
              </div>
              <div className="grid grid-cols-3 gap-2 text-center text-xs">
                <span className="rounded-lg bg-emerald-50 px-2 py-2 text-emerald-700 font-medium">0-35 · Calm</span>
                <span className="rounded-lg bg-amber-50 px-2 py-2 text-amber-700 font-medium">36-60 · Mild</span>
                <span className="rounded-lg bg-rose-50 px-2 py-2 text-rose-700 font-medium">61+ · Elevated</span>
              </div>
              <p className="text-xs text-muted-foreground leading-relaxed">
                Derived from Garmin heart rate variability analysis throughout the day. Scores are averaged across awake hours only.
              </p>
            </div>
          </ModalCard>
        );
      // TODO: migrate to backend (is stepHistory used elsewhere or can it be changed to have these consts?)
      case "steps": {
        const avgSteps = stepHistory.length ? Math.round(stepHistory.reduce((s, d) => s + d.steps, 0) / stepHistory.length) : 0;
        const maxSteps = stepHistory.length ? Math.max(...stepHistory.map(d => d.steps)) : 0;
        const prevAvg  = stepHistory.length > 1 ? Math.round(stepHistory.slice(0, -1).reduce((s, d) => s + d.steps, 0) / (stepHistory.length - 1)) : 0;
        const trendPct = prevAvg > 0 ? Math.round(((vitals.steps - prevAvg) / prevAvg) * 100) : 0;
        const trendUp  = trendPct >= 0;
        return (
          <ModalCard icon={Footprints} iconBg="bg-ecg" gradient="from-blue-50 to-sky-50"
            title="Steps Today" subtitle={stepsS.note}>
            <div className="space-y-5">
              <div className="flex items-end justify-between">
                <div>
                  <p className={`text-4xl font-bold ${stepsS.color}`}>{vitals.steps > 0 ? vitals.steps.toLocaleString() : "—"}</p>
                  <p className="mt-0.5 text-sm text-muted-foreground">{stepsS.label} today</p>
                </div>
                {prevAvg > 0 && (
                  <div className={`text-right ${trendUp ? "text-emerald-600" : "text-rose-600"}`}>
                    <p className="text-xl font-bold">{trendUp ? "+" : ""}{trendPct}%</p>
                    <p className="text-xs text-muted-foreground">vs. recent avg</p>
                  </div>
                )}
              </div>
              {stepHistory.length > 1 && (
                <div className="grid grid-cols-3 gap-3 text-center">
                  <div className="rounded-xl bg-muted/40 p-3">
                    <p className="text-base font-bold text-foreground">{avgSteps.toLocaleString()}</p>
                    <p className="text-xs text-muted-foreground">Daily avg</p>
                  </div>
                  <div className="rounded-xl bg-muted/40 p-3">
                    <p className="text-base font-bold text-emerald-600">{maxSteps.toLocaleString()}</p>
                    <p className="text-xs text-muted-foreground">Best day</p>
                  </div>
                  <div className="rounded-xl bg-muted/40 p-3">
                    <p className="text-base font-bold text-muted-foreground">{stepHistory.length}d</p>
                    <p className="text-xs text-muted-foreground">Tracked</p>
                  </div>
                </div>
              )}
              {stepHistory.length > 1 && (
                <>
                  <p className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">{stepHistory.length}-day trend</p>
                  <div className="h-52">
                    <ResponsiveContainer width="100%" height="100%">
                      <AreaChart data={stepHistory} margin={{ top: 8, right: 8, left: -20, bottom: 0 }}>
                        <defs>
                          <linearGradient id="stepsGradientElder" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stopColor="hsl(var(--ecg))" stopOpacity={0.35} />
                            <stop offset="100%" stopColor="hsl(var(--ecg))" stopOpacity={0} />
                          </linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
                        <XAxis dataKey="day" tick={{ fontSize: 11, fill: "hsl(215,16%,50%)" }} axisLine={false} tickLine={false} />
                        <YAxis tick={{ fontSize: 11, fill: "hsl(215,16%,50%)" }} axisLine={false} tickLine={false} />
                        <Tooltip contentStyle={{ fontSize: 12, borderRadius: 8, border: "1px solid hsl(var(--border))" }} formatter={(v: number) => [v.toLocaleString(), "Steps"]} />
                        <ReferenceLine y={5000} stroke="hsl(var(--success))" strokeDasharray="4 4" label={{ value: "Goal 5k", fontSize: 9, fill: "hsl(var(--success))", position: "right" }} />
                        <Area type="monotone" dataKey="steps" stroke="hsl(var(--ecg))" strokeWidth={2.5} fill="url(#stepsGradientElder)" dot={{ r: 3, fill: "hsl(var(--ecg))", strokeWidth: 0 }} isAnimationActive={false} />
                      </AreaChart>
                    </ResponsiveContainer>
                  </div>
                </>
              )}
            </div>
          </ModalCard>
        );
      }
      case "gait":
        return <WalkingActivityChart />;
      case "nutrition":
        return <SmartFridgeCard />;
      case "hydration":
        return <HydrationIndicator />;
      case "medication":
        return (
          <ModalCard icon={Pill} iconBg="bg-blue-500" gradient="from-blue-50 to-indigo-50"
            title="Medications" subtitle="Active prescriptions">
            <MedicationDetail />
          </ModalCard>
        );
      case "appointments":
        return (
          <ModalCard icon={Calendar} iconBg="bg-violet-500" gradient="from-violet-50 to-purple-50"
            title="Appointments" subtitle="Upcoming scheduled visits">
            <AppointmentsDetail />
          </ModalCard>
        );
      default:
        return null;
    }
  };

  const modalTitle: Record<string, string> = {
    heart: "Heart Health", sleep: "Sleep Analysis", stress: "Stress",
    steps: "Steps Today", gait: "Gait Analysis", nutrition: "Nutrition & Diet",
    hydration: "Hydration", medication: "Medications", appointments: "Appointments",
  };

  const startRecording = async () => {
    if (isRecording || isThinking) return;
    unlockAudio();
    try {
      setNHHStatus("Listening…");
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
      recorder.ondataavailable = (e) => { if (e.data.size > 0) chunksRef.current.push(e.data); };
      recorder.onstop = async () => {
        setIsRecording(false);
        setNHHStatus("Transcribing…");
        const blob = new Blob(chunksRef.current, { type: mime || "audio/webm" });
        if (blob.size < 2000) {
          setNHHStatus("Too short — try again");
          streamRef.current?.getTracks().forEach((t) => t.stop());
          streamRef.current = null;
          return;
        }
        const fd = new FormData();
        fd.append("file", blob, "audio.webm");
        try {
          const res = await fetch(`${API_BASE}/api/transcribe`, { method: "POST", body: fd });
          const ct = res.headers.get("content-type") || "";
          const data: any = ct.includes("application/json") ? await res.json() : { error: await res.text() };
          if (!res.ok || data?.error) { setNHHStatus("Transcription failed"); return; }
          const text = String(data?.transcript || "").trim();
          if (!text) {
            setNHHStatus("I didn't catch that — please try again");
            return;
          }

          setNHHStatus("");
          const nextMessages: Msg[] = [...messagesRef.current, { role: "user", content: text }];
          setMessages([...nextMessages, { role: "assistant", content: "" }]);
          setIsThinking(true);
          speakAbortRef.current?.abort();
          const ttsCtrl = new AbortController();
          speakAbortRef.current = ttsCtrl;
          stopAudio();
          // const healthContext = await fetch(`${API_BASE}/api/build-health-context`, 
          //   { 
          //     method: 'POST', 
          //     headers: { 'Content-Type': 'application/json' }, 
          //     body: JSON.stringify({ v: vitalsRef.current, nRef: neighborhoodRef.current, name: first_name }) 
          //   }
          // ).then(res => res.ok ? res.text() : "Error: Could not retrieve health context.");
          const fullAnswer = await streamAnswer(
            text, nextMessages,
            () => { /* keep Thinking… visible until TTS is ready */ },
            () => { /* accumulate internally — don't update UI yet */ },
            systemMsg // healthContext
          );
          if (!fullAnswer) {
            setMessages((prev) => {
              const msgs = [...prev];
              if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant" && !msgs[msgs.length - 1].content) {
                msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: "Sorry — something went wrong." };
              }
              return msgs;
            });
          } else {
            const joinMatch = fullAnswer.match(/\[\[JOIN:(\d+)\]\]/i);
            const callMatch = fullAnswer.match(/\[\[CALL_FAMILY\]\]/i);
            const displayAnswer = fullAnswer.replace(/\n?\s*\[\[JOIN:\d+\]\]/gi, "").replace(/\n?\s*\[\[CALL_FAMILY\]\]/gi, "").trim();
            const buf = await fetchTTSBuffer(ttsReady(displayAnswer), ttsCtrl.signal);
            setMessages((prev) => {
              const msgs = [...prev];
              if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant") {
                msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: displayAnswer };
              }
              return msgs;
            });
            if (buf && !ttsCtrl.signal.aborted) await decodeAndPlay(buf, ttsCtrl.signal);
            if (joinMatch) {
              const activityId = parseInt(joinMatch[1], 10);
              setOpenPanel("activity");
              setPendingJoinId(activityId);
            }
            if (callMatch) {
              startCall();
            }
          }
        } catch {
          setNHHStatus("Network error");
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
      setNHHStatus("Mic permission denied");
    }
  };
  const stopRecording = () => {
    const r = recorderRef.current;
    if (r && r.state !== "inactive") r.stop();
  };

  // Dispatch join event only after CommunityPanel has mounted and registered its listener
  useEffect(() => {
    if (pendingJoinId !== null && openPanel === "activity") {
      window.dispatchEvent(new CustomEvent("NHH-join-activity", { detail: { id: pendingJoinId } }));
      setPendingJoinId(null);
    }
  }, [pendingJoinId, openPanel]);

  // Listen for family's response to the call
  useEffect(() => {
    const handler = (e: StorageEvent) => {
      if (e.key !== "nhh-call-state") return;
      const val = JSON.parse(e.newValue ?? "{}");
      if (val.status === "accepted") setCallState("connected");
      if (val.status === "declined") {
        setCallState("declined");
        setTimeout(() => setCallState("idle"), 3000);
      }
      if (val.status === "idle") setCallState("idle");
    };
    window.addEventListener("storage", handler);
    return () => window.removeEventListener("storage", handler);
  }, []);

  const startCall = () => {
    setCallState("calling");
    localStorage.setItem("nhh-call-state", JSON.stringify({ status: "ringing", timestamp: Date.now() }));
  };
  const endCall = () => {
    setCallState("idle");
    localStorage.setItem("nhh-call-state", JSON.stringify({ status: "idle", timestamp: Date.now() }));
  };

  // Poll for incoming call from family
  useEffect(() => {
    const sync = () => {
      const val = JSON.parse(localStorage.getItem("nhh-family-call-state") ?? "{}");
      if (val.status === "ringing") { setFamilyCallIncoming(true); setFamilyCallConnected(false); }
      else if (val.status === "idle") { setFamilyCallIncoming(false); setFamilyCallConnected(false); }
    };
    sync();
    const interval = setInterval(sync, 500);
    const handler = (e: StorageEvent) => { if (e.key === "nhh-family-call-state") sync(); };
    window.addEventListener("storage", handler);
    return () => { clearInterval(interval); window.removeEventListener("storage", handler); };
  }, []);

  const acceptFamilyCall = () => {
    setFamilyCallIncoming(false);
    setFamilyCallConnected(true);
    localStorage.setItem("nhh-family-call-state", JSON.stringify({ status: "accepted", timestamp: Date.now() }));
  };
  const declineFamilyCall = () => {
    setFamilyCallIncoming(false);
    localStorage.setItem("nhh-family-call-state", JSON.stringify({ status: "declined", timestamp: Date.now() }));
  };
  const endFamilyCall = () => {
    setFamilyCallConnected(false);
    localStorage.setItem("nhh-family-call-state", JSON.stringify({ status: "idle", timestamp: Date.now() }));
  };

  const isCallConnected = callState === "connected" || familyCallConnected;
  useEffect(() => {
    if (!isCallConnected) { setCallSeconds(0); return; }
    const t = setInterval(() => setCallSeconds(s => s + 1), 1000);
    return () => clearInterval(t);
  }, [isCallConnected]);
  const fmtTime = (s: number) =>
    `${String(Math.floor(s / 60)).padStart(2, "0")}:${String(s % 60).padStart(2, "0")}`;

  const toggle = (panel: Panel) =>
    setOpenPanel((prev) => (prev === panel ? null : panel));

  const cardBase = "group flex flex-col items-center gap-4 rounded-3xl border-2 p-6 text-center shadow-md transition-all duration-200 active:scale-[0.97]";

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white">
      {/* ── Outgoing call to family ────────────────────────────────── */}
      {callState === "calling" && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between gap-4 px-6 py-5 bg-gradient-to-r from-emerald-600 to-teal-600 shadow-2xl text-white">
          <div className="flex items-center gap-4">
            <div className="relative flex items-center justify-center">
              <span className="absolute inline-flex h-14 w-14 rounded-full bg-white/20 animate-ping" />
              <span className="absolute inline-flex h-10 w-10 rounded-full bg-white/30 animate-ping [animation-delay:200ms]" />
              <div className="relative flex h-12 w-12 items-center justify-center rounded-full bg-white/25 shadow-lg">
                <PhoneCall className="h-6 w-6 text-white" />
              </div>
            </div>
            <div>
              <p className="text-lg font-bold tracking-wide">📲 Calling your family…</p>
              <p className="text-sm font-medium text-white/90">Waiting for them to pick up</p>
            </div>
          </div>
          <button onClick={endCall} className="flex items-center gap-2 rounded-full bg-rose-500 px-5 py-2.5 text-sm font-bold shadow-lg hover:bg-rose-400 active:scale-95 transition-all">
            <PhoneOff className="h-4 w-4" /> Cancel
          </button>
        </div>
      )}

      {/* ── Connected with family (outgoing call accepted) ─────────── */}
      {callState === "connected" && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between px-6 py-3 bg-emerald-600 text-white shadow-lg">
          <div className="flex items-center gap-3">
            <div className="h-2 w-2 rounded-full bg-white animate-pulse" />
            <span className="text-sm font-semibold">Connected with your family</span>
            <span className="rounded-full bg-white/20 px-2.5 py-0.5 text-xs font-mono font-semibold">{fmtTime(callSeconds)}</span>
          </div>
          <button onClick={endCall} className="flex items-center gap-2 rounded-full bg-white/20 px-3 py-1.5 text-xs font-semibold hover:bg-white/30 transition">
            <PhoneOff className="h-3.5 w-3.5" /> End Call
          </button>
        </div>
      )}

      {/* ── Incoming call from family ──────────────────────────────── */}
      {familyCallIncoming && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between gap-4 px-6 py-5 shadow-2xl"
          style={{ background: "linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #db2777 100%)" }}>
          <div className="flex items-center gap-4 text-white">
            <div className="relative flex items-center justify-center">
              <span className="absolute inline-flex h-14 w-14 rounded-full bg-white/20 animate-ping" />
              <span className="absolute inline-flex h-10 w-10 rounded-full bg-white/30 animate-ping [animation-delay:150ms]" />
              <div className="relative flex h-12 w-12 items-center justify-center rounded-full bg-white/25 shadow-lg">
                <PhoneIncoming className="h-6 w-6 text-white drop-shadow" />
              </div>
            </div>
            <div>
              <p className="text-lg font-bold tracking-wide">📞 Incoming Call</p>
              <p className="text-sm font-medium text-white/90">Your family wants to talk with you</p>
            </div>
          </div>
          <div className="flex gap-3">
            <button onClick={acceptFamilyCall} className="flex items-center gap-2 rounded-full bg-emerald-400 px-5 py-2.5 text-sm font-bold text-white shadow-lg hover:bg-emerald-300 active:scale-95 transition-all">
              <Phone className="h-4 w-4" /> Accept
            </button>
            <button onClick={declineFamilyCall} className="flex items-center gap-2 rounded-full bg-rose-500 px-5 py-2.5 text-sm font-bold text-white shadow-lg hover:bg-rose-400 active:scale-95 transition-all">
              <PhoneOff className="h-4 w-4" /> Decline
            </button>
          </div>
        </div>
      )}

      {/* ── Connected with family banner ───────────────────────────── */}
      {familyCallConnected && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between px-6 py-3 bg-emerald-600 text-white shadow-lg">
          <div className="flex items-center gap-3">
            <div className="h-2 w-2 rounded-full bg-white animate-pulse" />
            <span className="text-sm font-semibold">Connected with your family</span>
            <span className="rounded-full bg-white/20 px-2.5 py-0.5 text-xs font-mono font-semibold">{fmtTime(callSeconds)}</span>
          </div>
          <button onClick={endFamilyCall} className="flex items-center gap-2 rounded-full bg-white/20 px-3 py-1.5 text-xs font-semibold hover:bg-white/30 transition">
            <PhoneOff className="h-3.5 w-3.5" /> End Call
          </button>
        </div>
      )}

      <Header />

      {/* ── Demo dropdown ── */}
      <div className="fixed top-4 right-72 z-[60]">
        <div className="relative">
          <button
            onClick={() => setDemoOpen((v) => !v)}
            className="flex items-center gap-1.5 rounded-full border border-muted-foreground/20 bg-muted/30 px-3 py-1.5 text-xs font-medium text-muted-foreground/50 hover:bg-muted/60 hover:text-muted-foreground transition focus:outline-none"
          >
            Demo Mode
          </button>
          {demoOpen && (
            <div className="absolute right-0 top-9 w-44 rounded-xl border border-border bg-background shadow-lg py-1 z-[70]">
              <button
                onClick={() => { setDemoOpen(false); unlockAudio(); runCheckIn(vitalsRef.current, "fall"); }}
                disabled={isThinking || isRecording}
                className="flex w-full items-center gap-2 px-3 py-2 text-sm text-foreground hover:bg-muted disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ShieldAlert className="h-4 w-4 text-orange-500" />
                Fall Risk
              </button>
              <button
                onClick={() => { setDemoOpen(false); unlockAudio(); runCheckIn(vitalsRef.current, "mental"); }}
                disabled={isThinking || isRecording}
                className="flex w-full items-center gap-2 px-3 py-2 text-sm text-foreground hover:bg-muted disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Brain className="h-4 w-4 text-violet-500" />
                Mental Health
              </button>
            </div>
          )}
        </div>
      </div>

      <main className="container mx-auto px-4 py-8 sm:px-6">

        {/* ── Greeting ───────────────────────────────────────────────── */}
        <div className="mb-8 text-center">
          <p className="text-lg font-medium text-muted-foreground">{today}</p>
          <h2 className="mt-1 text-5xl font-display font-bold text-foreground">
            Good morning, {first_name}!
          </h2>
        </div>

        {/* ── NHH Hold-to-Talk Button ────────────────────────────────── */}
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
            <div className={[
              "flex h-28 w-28 items-center justify-center rounded-full shadow-md transition-all duration-150",
              isRecording ? "bg-white/25 animate-pulse" : isThinking ? "bg-indigo-300" : "bg-indigo-500",
            ].join(" ")}>
              <Mic className={`h-14 w-14 ${isRecording ? "text-white" : isThinking ? "text-indigo-700" : "text-white"}`} />
            </div>
            <div>
              <p className={`text-4xl font-display font-bold leading-tight ${isRecording ? "text-white" : "text-indigo-900"}`}>
                {isRecording ? "Listening…" : isThinking ? "Joy is thinking…" : "Talk to Joy"}
              </p>
              <p className={`mt-2 text-xl ${isRecording ? "text-white/80" : "text-indigo-500"}`}>
                {isRecording
                  ? "Release to send"
                  : isThinking
                  ? messages.length === 0 ? "Preparing your morning check-in…" : "Getting your answer…"
                  : NHHStatus || "Hold to speak"}
              </p>
            </div>
          </button>

          {/* Call Family — grouped with voice */}
          <div className="mt-4 flex justify-center">
            {callState === "idle" && (
              <button onClick={startCall}
                className="flex items-center gap-3 rounded-2xl bg-emerald-500 px-8 py-3 text-lg font-semibold text-white shadow-md transition hover:bg-emerald-400 active:scale-95">
                <Phone className="h-5 w-5" />
                Call Family
              </button>
            )}
            {callState === "calling" && (
              <button onClick={endCall}
                className="flex items-center gap-3 rounded-2xl bg-amber-400 px-8 py-3 text-lg font-semibold text-white shadow-md transition hover:bg-amber-300 animate-pulse">
                <PhoneCall className="h-5 w-5" />
                Calling…
              </button>
            )}
            {callState === "connected" && (
              <div className="flex items-center gap-3 rounded-2xl bg-emerald-500 px-8 py-3 shadow-md">
                <div className="h-2.5 w-2.5 rounded-full bg-white animate-pulse" />
                <span className="text-lg font-semibold text-white">Connected</span>
                <button onClick={endCall} className="ml-2 flex items-center gap-1.5 rounded-xl bg-white/20 px-3 py-1.5 text-sm font-medium text-white hover:bg-white/30 transition">
                  <PhoneOff className="h-4 w-4" /> End
                </button>
              </div>
            )}
            {callState === "declined" && (
              <div className="flex items-center gap-3 rounded-2xl border border-rose-200 bg-rose-50 px-8 py-3 text-lg font-medium text-rose-600">
                <PhoneOff className="h-5 w-5" />
                Call Declined
              </div>
            )}
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
                      {m.role === "user" ? "You" : "Joy"}
                    </span>
                    <div className="flex items-start gap-2">
                      <p className={`rounded-2xl px-4 py-2 text-base leading-relaxed ${
                        m.role === "user" ? "bg-indigo-50 text-indigo-900" : "bg-violet-50 text-violet-900"
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

        {/* ── Three Action Cards ──────────────────────────────────────── */}
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
                <p className={`text-xl font-bold leading-tight ${openPanel === "health" ? "text-white" : "text-foreground"}`}>My Health</p>
              </div>
              {openPanel === "health" ? <ChevronUp className="h-6 w-6 text-white/80" /> : <ChevronDown className="h-6 w-6 text-blue-400" />}
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
                <p className={`text-xl font-bold leading-tight ${openPanel === "activity" ? "text-white" : "text-foreground"}`}>Neighborhood Activities</p>
              </div>
              {openPanel === "activity" ? <ChevronUp className="h-6 w-6 text-white/80" /> : <ChevronDown className="h-6 w-6 text-teal-400" />}
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
                <p className={`text-xl font-bold leading-tight ${openPanel === "helping" ? "text-white" : "text-foreground"}`}>Neighbors Helping Neighbors</p>
              </div>
              {openPanel === "helping" ? <ChevronUp className="h-6 w-6 text-white/80" /> : <ChevronDown className="h-6 w-6 text-rose-400" />}
            </button>
          </div>
        </div>

        {/* ── My Health Panel ────────────────────────────────────────── */}
        {openPanel === "health" && (
          <div className="mt-6 rounded-3xl border border-blue-100 bg-white p-6 shadow-lg sm:p-8">

            {/* 9-card grid */}
            <div className="grid grid-cols-3 gap-3">
              <HealthCard icon={Heart} iconBg="bg-heart/15 text-heart" cardBg="bg-sky-50" title="Heart Health" label={heartS.label} labelColor={heartS.color} onClick={() => setOpenModal("heart")} />
              <HealthCard icon={Moon} iconBg="bg-sleep/15 text-sleep" cardBg="bg-sky-50" title="Sleep Analysis" label={sleepS.label} labelColor={sleepS.color} onClick={() => setOpenModal("sleep")} />
              <HealthCard icon={Utensils} iconBg="bg-teal-500/15 text-teal-600" cardBg="bg-sky-50" title="Nutrition & Diet" label="Meals tracked" labelColor="text-teal-600" onClick={() => setOpenModal("nutrition")} />
              <HealthCard icon={Brain} iconBg="bg-stress/15 text-stress" cardBg="bg-sky-50" title="Stress" label={stressS.label} labelColor={stressS.color} onClick={() => setOpenModal("stress")} />
              <HealthCard icon={Footprints} iconBg="bg-ecg/15 text-ecg" cardBg="bg-sky-50" title="Steps Today" label={stepsS.label} labelColor={stepsS.color} onClick={() => setOpenModal("steps")} />
              <HealthCard icon={Shield} iconBg="bg-amber-500/15 text-amber-600" cardBg="bg-sky-50" title="Gait Analysis" label={gaitS.label} labelColor={gaitS.color} onClick={() => setOpenModal("gait")} />
              <HealthCard icon={Droplets} iconBg="bg-teal-500/15 text-teal-600" cardBg="bg-sky-50" title="Hydration" label={hydrationS.label} labelColor={hydrationS.color} onClick={() => setOpenModal("hydration")} />
              <HealthCard icon={Pill} iconBg="bg-blue-500/15 text-blue-600" cardBg="bg-sky-50" title="Medication" label="Active Rx" labelColor="text-blue-600" onClick={() => setOpenModal("medication")} />
              <HealthCard icon={Calendar} iconBg="bg-violet-500/15 text-violet-600" cardBg="bg-sky-50" title="Appointments" label="Upcoming" labelColor="text-violet-600" onClick={() => setOpenModal("appointments")} />
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


      {/* ── Detail modal ── */}
      <Dialog open={openModal !== null} onOpenChange={() => setOpenModal(null)}>
        <DialogContent className="sm:max-w-3xl max-h-[85vh] overflow-y-auto">
          <DialogHeader className="sr-only">
            <DialogTitle>{openModal ? modalTitle[openModal] : ""}</DialogTitle>
          </DialogHeader>
          {renderModalContent()}
        </DialogContent>
      </Dialog>

    </div>
  );
};

export default ElderView;
