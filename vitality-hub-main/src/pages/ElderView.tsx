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
  Utensils, Shield, Droplets, Pill, Maximize2,
} from "lucide-react";
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid,
  Tooltip, ReferenceLine, ResponsiveContainer,
} from "recharts";

const API_BASE = "http://localhost:3001";
const PATIENT_ID = "PATIENT_001";

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
  phoneCallMinutes: number;
  phoneCallTrend: number[];
  gaitNote: string;
  fallRiskAlert: boolean;
};
type Msg = { role: "user" | "assistant"; content: string };
type Med = { drug: string; status: string; authored: string; dosage: string };

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


function extractSleep(sleepJson: any): number {
  if (!Array.isArray(sleepJson)) return 0;
  const latest = pickLatest(sleepJson.filter((x: any) =>
    typeof x?.calendarDate === "string" &&
    (x?.deepSleepSeconds != null || x?.lightSleepSeconds != null || x?.remSleepSeconds != null)
  ));
  if (!latest) return 0;
  return (Number(latest.deepSleepSeconds ?? 0) + Number(latest.lightSleepSeconds ?? 0) + Number(latest.remSleepSeconds ?? 0)) / 3600;
}

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
  if      (level <= 2) note = "well hydrated";
  else if (level <= 4) note = "adequately hydrated";
  else if (level === 5) note = "mildly dehydrated — could drink more water";
  else if (level === 6) note = "moderately dehydrated — needs more fluids";
  else if (level === 7) note = "significantly dehydrated — drinking water is important right now";
  else                  note = "severely dehydrated — needs attention soon";
  return { note, colorLevel: level };
}

function extractFridge(fridgeJson: any): { waterLiters: number; currentItems: string[]; expiringItems: string[]; mealsCount: number } {
  if (!Array.isArray(fridgeJson) || fridgeJson.length === 0) return { waterLiters: 0, currentItems: [], expiringItems: [], mealsCount: 0 };
  const latest = pickLatest(fridgeJson);
  if (!latest) return { waterLiters: 0, currentItems: [], expiringItems: [], mealsCount: 0 };
  const currentItems = Array.isArray(latest.inventory)
    ? latest.inventory.map((inv: any) => String(inv?.item ?? "")).filter(Boolean)
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

function extractPhoneCalls(callJson: any): { minutes: number; trend: number[] } {
  if (!Array.isArray(callJson) || callJson.length === 0) return { minutes: 0, trend: [] };
  const sorted = [...callJson].sort((a, b) =>
    String(a?.calendarDate || "").localeCompare(String(b?.calendarDate || ""))
  );
  const last7 = sorted.slice(-7);
  const trend = last7.map((d: any) => Number(d?.totalMinutes ?? 0));
  const todayEntry = pickLatest(callJson);
  const minutes = Number(todayEntry?.totalMinutes ?? 0);
  return { minutes, trend };
}

function extractGait(gaitJson: any): { note: string; riskLevel: "low" | "moderate" | "high" } | null {
  if (!Array.isArray(gaitJson) || gaitJson.length === 0) return null;
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

// ── Health card status helpers ─────────────────────────────────────────────────
function sleepStatus(h: number) {
  if (h === 0)  return { label: "No data",     note: "Sleep data unavailable",                   color: "text-muted-foreground", status: "fair" as const };
  if (h >= 7)   return { label: "Well rested", note: `${h.toFixed(1)} hrs — great for his age`,  color: "text-emerald-600",       status: "good" as const };
  if (h >= 5.5) return { label: "Light sleep", note: `${h.toFixed(1)} hrs — a bit below ideal`,  color: "text-amber-600",         status: "fair" as const };
  return         { label: "Poor sleep",   note: `Only ${h.toFixed(1)} hrs — worth monitoring`, color: "text-rose-600",          status: "warn" as const };
}

function heartStatus(bpm: number) {
  if (bpm === 0)              return { label: "No data",           note: "Heart rate unavailable",                   color: "text-muted-foreground", status: "fair" as const };
  if (bpm >= 55 && bpm <= 85) return { label: "Normal range",      note: `${bpm} BPM — healthy resting rate`,        color: "text-emerald-600",       status: "good" as const };
  if (bpm > 85 && bpm <= 100) return { label: "Slightly elevated", note: `${bpm} BPM — monitor if it persists`,      color: "text-amber-600",         status: "fair" as const };
  if (bpm < 55 && bpm > 0)    return { label: "Slightly low",      note: `${bpm} BPM — could be normal if athletic`, color: "text-amber-600",         status: "fair" as const };
  return                       { label: "Check with doctor",  note: `${bpm} BPM — outside normal range`,       color: "text-rose-600",          status: "warn" as const };
}

function stepsStatus(steps: number) {
  if (steps === 0)   return { label: "No data",            note: "Activity data unavailable",                          color: "text-muted-foreground", status: "fair" as const };
  if (steps >= 5000) return { label: "Very active",        note: `${steps.toLocaleString()} steps — excellent!`,       color: "text-emerald-600",       status: "good" as const };
  if (steps >= 2500) return { label: "Moderately active",  note: `${steps.toLocaleString()} steps — good movement`,    color: "text-emerald-600",       status: "good" as const };
  if (steps >= 1000) return { label: "Light activity",     note: `${steps.toLocaleString()} steps — quieter day`,      color: "text-amber-600",         status: "fair" as const };
  return             { label: "Very little movement", note: `${steps.toLocaleString()} steps — try a short walk`, color: "text-rose-600",          status: "warn" as const };
}

function stressStatusHelper(v: number) {
  if (v === 0)  return { label: "Calm",        note: "Stress levels look great",    color: "text-emerald-600", status: "good" as const };
  if (v <= 35)  return { label: "Calm",        note: "Very relaxed today",          color: "text-emerald-600", status: "good" as const };
  if (v <= 60)  return { label: "Mild stress", note: "Some stress — likely normal", color: "text-amber-600",   status: "fair" as const };
  return        { label: "High stress",  note: "Elevated — try to relax",     color: "text-rose-600",    status: "warn" as const };
}

function gaitStatusHelper(symmetryPct: number, variabilityPct: number, speedMs: number, cadence: number, worseStride: number, worseGCT: number) {
  if (symmetryPct === 0) return { label: "No data",     note: "Gait data unavailable",                color: "text-muted-foreground", status: "fair" as const };
  const isHigh = cadence < 80  || speedMs < 0.7  || worseStride < 90  || worseGCT > 950 || symmetryPct < 78  || variabilityPct > 10;
  const isMed  = cadence < 100 || speedMs < 1.0  || worseStride < 140 || worseGCT > 650 || symmetryPct < 95  || variabilityPct > 5;
  if (isHigh) return { label: "High Risk",     note: "Significant gait irregularities detected", color: "text-rose-600",    status: "warn" as const };
  if (isMed)  return { label: "Moderate Risk", note: "Some asymmetry — worth monitoring",        color: "text-amber-600",   status: "fair" as const };
  return       { label: "Low Risk",            note: "Gait looks steady and balanced",           color: "text-emerald-600", status: "good" as const };
}

function hydrationStatusHelper(level: number) {
  if (level === 0) return { label: "No data",          note: "Hydration data unavailable",       color: "text-muted-foreground", status: "fair" as const };
  if (level <= 2)  return { label: "Excellent",        note: "Well hydrated — great job!",       color: "text-emerald-600",      status: "good" as const };
  if (level <= 3)  return { label: "Normal",           note: "Hydration looks normal",           color: "text-emerald-600",      status: "good" as const };
  if (level <= 4)  return { label: "Drink More Water", note: "Could use a bit more water",       color: "text-amber-600",        status: "fair" as const };
  if (level <= 5)  return { label: "Mild Dehydration", note: "Drink a glass of water now",       color: "text-amber-600",        status: "fair" as const };
  if (level <= 6)  return { label: "Dehydrated",       note: "Needs more fluids soon",           color: "text-rose-600",         status: "warn" as const };
  return           { label: "Very Dehydrated",         note: "Drink water — this is important",  color: "text-rose-600",         status: "warn" as const };
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
  icon: Icon, iconBg, title, label, labelColor, note, onClick,
}: {
  icon: React.ElementType; iconBg: string; title: string;
  label: string; labelColor: string; note: string; onClick: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className="rounded-2xl bg-card shadow-card overflow-hidden cursor-pointer group hover:shadow-lg transition-shadow"
    >
      <div className="flex items-center gap-2.5 border-b border-border px-4 py-3 bg-muted/30 group-hover:bg-muted/50 transition-colors">
        <div className={`flex h-7 w-7 items-center justify-center rounded-lg ${iconBg}`}>
          <Icon className="h-3.5 w-3.5" />
        </div>
        <span className="text-xs font-medium text-muted-foreground flex-1">{title}</span>
        <Maximize2 className="h-3 w-3 text-muted-foreground/40 group-hover:text-muted-foreground transition-colors" />
      </div>
      <div className="px-4 py-3.5">
        <p className={`text-lg font-bold leading-tight ${labelColor}`}>{label}</p>
        <p className="mt-0.5 text-xs text-muted-foreground leading-snug">{note}</p>
      </div>
    </div>
  );
}

// ── MedicationDetail ──────────────────────────────────────────────────────────
function MedicationDetail() {
  const [meds, setMeds] = useState<Med[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const patientsRes = await fetch(`${API_BASE}/api/fhir/patients`);
        if (!patientsRes.ok) throw new Error("Could not load patient list");
        const patients: { id: string; name: string }[] = await patientsRes.json();
        const frank = patients.find(p => p.name.toLowerCase().includes("frank") && p.name.toLowerCase().includes("larson"));
        if (!frank) throw new Error("Frank Larson not found in FHIR patient list");
        const medRes = await fetch(`${API_BASE}/api/fhir/medications?patient_id=${encodeURIComponent(frank.id)}`);
        if (!medRes.ok) throw new Error("Medication fetch failed");
        const data: Med[] = await medRes.json();
        setMeds(Array.isArray(data) ? data : []);
      } catch (e: any) {
        setError(e?.message ?? "Failed to load medications");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

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

// ── ElderAppointments ────────────────────────────────────────────────────────
type Appt = { status: string; start: string; end: string; type: string; practitioner: string; location: string };

function ElderAppointments() {
  const [appts, setAppts] = useState<Appt[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const patientsRes = await fetch(`${API_BASE}/api/fhir/patients`);
        if (!patientsRes.ok) throw new Error("Could not load patient list");
        const patients: { id: string; name: string }[] = await patientsRes.json();
        const frank = patients.find(p => p.name.toLowerCase().includes("frank") && p.name.toLowerCase().includes("larson"));
        if (!frank) throw new Error("Frank Larson not found in FHIR patient list");
        const apptRes = await fetch(`${API_BASE}/api/fhir/appointments?patient_id=${encodeURIComponent(frank.id)}`);
        if (!apptRes.ok) throw new Error("Appointments fetch failed");
        const data: Appt[] = await apptRes.json();
        setAppts(Array.isArray(data) ? data : []);
      } catch (e: any) {
        setError(e?.message ?? "Failed to load appointments");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

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

type Panel = "health" | "activity" | "helping" | null;

const ElderView = () => {
  const [openPanel, setOpenPanel] = useState<Panel>(null);
  const emptyVitals: Vitals = { heartRate: 0, steps: 0, stressLevel: 0, sleepHours: 0, hydrationNote: "", hydrationColorLevel: 0, waterLiters: 0, expiringItems: [], currentItems: [], mealsCount: 0, phoneCallMinutes: 0, phoneCallTrend: [], gaitNote: "", fallRiskAlert: false };
  const [vitals, setVitals] = useState<Vitals>(emptyVitals);
  const vitalsRef = useRef<Vitals>(emptyVitals);
  vitalsRef.current = vitals;

  // Health card state
  const [gaitMetrics, setGaitMetrics] = useState({ symmetry: 0, variability: 0, speed: 0, cadence: 0, worseStride: 0, worseGCT: 0 });
  const [stepHistory, setStepHistory] = useState<{ day: string; steps: number }[]>([]);
  const [openModal, setOpenModal] = useState<string | null>(null);

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
  const neighborhoodRef = useRef<string>("");
  const scrollBottomRef = useRef<HTMLDivElement | null>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const audioSourceRef = useRef<AudioBufferSourceNode | null>(null);
  const speakAbortRef = useRef<AbortController | null>(null);
  const audioCtxRef = useRef<AudioContext | null>(null);

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

  const ttsReady = (text: string): string => {
    const t = text.trimEnd();
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
      lines.push(`- Hydration (smart toilet urine color sensor): level ${v.hydrationColorLevel}/8 — ${v.hydrationNote}`);
    }
    if (v.gaitNote)     lines.push(`- Gait / walking analysis: ${v.gaitNote}`);
    if (v.fallRiskAlert) lines.push(`- Combined fall risk alert: YES — gait irregularities combined with dehydration create elevated fall risk today`);
    if (v.mealsCount)   lines.push(`- Meals detected today (smart fridge): ${v.mealsCount}`);
    if (v.currentItems.length) lines.push(`- Current fridge inventory: ${v.currentItems.join(", ")}`);
    if (v.expiringItems.length) lines.push(`- Fridge items expiring soon: ${v.expiringItems.join(", ")}`);
    if (neighborhoodRef.current) {
      lines.push("");
      lines.push("Frank's neighborhood community (Oakwood Pines):");
      lines.push(neighborhoodRef.current);
    }
    lines.push("");
    lines.push(
      "Use Frank's personal health data and neighborhood information to answer his questions accurately. " +
      "Speak clearly and reassuringly, Frank should feel like you are a close companion not a doctor. " +
      "Keep answers brief (2-3 sentences). " +
      "DO NOT diagnose medical conditions. " +
      "Address him as Frank."
    );
    return lines.join("\n");
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
        const colorDesc = v.hydrationColorLevel <= 2 ? "colorless / pale straw (very well hydrated)"
          : v.hydrationColorLevel <= 4 ? "pale to normal yellow (adequately hydrated)"
          : v.hydrationColorLevel === 5 ? "dark yellow (mildly dehydrated)"
          : v.hydrationColorLevel === 6 ? "amber / honey (moderately dehydrated)"
          : v.hydrationColorLevel === 7 ? "dark amber / orange (significantly dehydrated)"
          : "brown / dark brown (severely dehydrated)";
        dataLines.push(`- Smart toilet urine color: level ${v.hydrationColorLevel}/8 — ${colorDesc} → ${v.hydrationNote}`);
      }
      if (v.fallRiskAlert) dataLines.push(`- COMBINED FALL RISK ALERT: gait irregularities together with dehydration significantly increase fall risk today`);
      prompt = dataLines.length
        ? `You are NOHA, a warm and caring safety companion for Frank, an elderly person living independently.

      Here is Frank's fall-risk evidence right now:
      ${dataLines.join("\n")}

      Talk to Frank simply and warmly — like a caring friend, not a doctor. Use short, easy sentences.
      Briefly mention the specific evidence: what his walking sensor found (speed, symmetry) and what the toilet urine color sensor showed.
      Then tell him clearly whether he needs to be extra careful today.
      If there is a COMBINED FALL RISK ALERT, say it first, explain whether his gait or hydration are concerning, and give him 2 simple practical tips (e.g. drink a glass of water once he gets up, move slowly, hold handrails).
      Keep it to 4-5 sentences. Address him as Frank.`
        : `You are NOHA. Warmly reassure Frank that his walking looks steady today and encourage him to keep moving safely and looking after himself. One sentence only. Don't be patronising. Address him as Frank.`;

    } else {
      if (v.sleepHours) {
        const sleepQuality = v.sleepHours < 5 ? "very poor — only " + v.sleepHours.toFixed(1) + " hours, significantly below healthy range"
          : v.sleepHours < 6.5 ? "below recommended — " + v.sleepHours.toFixed(1) + " hours"
          : "good — " + v.sleepHours.toFixed(1) + " hours";
        dataLines.push(`- Sleep last night: ${sleepQuality}`);
      }
      const mealStatus = v.mealsCount === 0
        ? "0 meals detected — Frank skipped all meals today (⚠️ appetite loss, possible depression signal)"
        : v.mealsCount === 1
        ? "only 1 meal detected (breakfast) — skipped lunch and dinner"
        : `${v.mealsCount} meals detected (normal)`;
      dataLines.push(`- Diet today (smart fridge): ${mealStatus}`);
      if (v.steps) dataLines.push(`- Steps today: ${v.steps.toLocaleString()} — ${v.steps < 2000 ? "very low, barely moved" : v.steps < 4000 ? "low activity" : "good"}`);
      if (v.stressLevel) dataLines.push(`- Stress level: ${v.stressLevel}/100`);
      if (v.phoneCallTrend.length > 0) {
        const trendStr = v.phoneCallTrend.join(" → ");
        const declining = v.phoneCallTrend.length >= 3 &&
          v.phoneCallTrend[v.phoneCallTrend.length - 1] < v.phoneCallTrend[0] * 0.4;
        dataLines.push(
          `- Phone / social contact (last ${v.phoneCallTrend.length} days, minutes): ${trendStr}` +
          (v.phoneCallMinutes === 0 ? " — NO calls today" : ` — ${v.phoneCallMinutes} min today`) +
          (declining ? " ⚠️ sharp decline in social contact" : "")
        );
      }
      if (neighborhoodRef.current) dataLines.push(`- Upcoming neighbourhood activities Frank could join:\n${neighborhoodRef.current}`);
      const poorSleep  = v.sleepHours > 0 && v.sleepHours < 6;
      const skippedMeals = v.mealsCount <= 1;
      const socialWithdrawal = v.phoneCallTrend.length >= 3 &&
        v.phoneCallTrend[v.phoneCallTrend.length - 1] < v.phoneCallTrend[0] * 0.4;
      const concernCount = [poorSleep, skippedMeals, socialWithdrawal].filter(Boolean).length;
      prompt = `You are NOHA, Frank's warm and caring AI companion. Frank is an elderly person living independently. You have been watching over him and you are genuinely concerned.

                Here is what you know about Frank today:
                ${dataLines.join("\n")}

                ${concernCount >= 2
                  ? `IMPORTANT CONTEXT: Frank appears to be going through a difficult time. The data shows he is not sleeping well, skipping meals, and has been calling family and friends much less than usual over the past week. These are signs he may be feeling down, depressed, or withdrawn. Do NOT just list data at him — approach this like a caring friend who has noticed he hasn't been himself lately.`
                  : poorSleep || skippedMeals
                  ? `IMPORTANT CONTEXT: Frank is showing some signs of low mood — poor sleep and skipped meals often go hand in hand with feeling down. Approach gently and warmly.`
                  : `Frank seems to be doing reasonably well today. Be warm and encouraging.`}

                Your response should:
                1. Open with a heartfelt greeting — like a friend who truly cares, not a check-box assistant.
                2. Tenderly acknowledge what you've noticed: poor sleep and skipped meals (name them directly but kindly — "I noticed you only had a small breakfast today" or "It looks like last night was a rough night for sleep").
                3. Ask Frank how he is feeling — invite him to share, keep it open and safe.
                4. Offer one small, concrete step he can take right now to feel a little better (a warm meal, a short walk outside, or joining a specific neighbourhood activity by name and time).
                5. Close with a sincere reminder that he is not alone — you are here, and the people around him care about him.

                Tone: warm, gentle, direct, human — like a trusted friend, not a patronising or cold medical alert. Keep it to 4-5 sentences. Address him as Frank.`;
    }
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
      );
      if (!fullText) {
        setMessages((prev) => {
          const msgs = [...prev];
          if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant" && !msgs[msgs.length - 1].content) {
            msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: "Good morning, Frank! I'm here whenever you need me." };
          }
          return msgs;
        });
        return;
      }
      const buf = await fetchTTSBuffer(ttsReady(fullText), ttsCtrl.signal);
      setIsThinking(false);
      setMessages((prev) => {
        const msgs = [...prev];
        if (msgs.length > 0 && msgs[msgs.length - 1].role === "assistant") {
          msgs[msgs.length - 1] = { ...msgs[msgs.length - 1], content: fullText };
        }
        return msgs;
      });
      if (buf && !ttsCtrl.signal.aborted) await decodeAndPlay(buf, ttsCtrl.signal);
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
        const [dailyRes, sleepRes, toiletRes, fridgeRes, gaitRes, neighborhoodRes, phoneCallRes] = await Promise.all([
          fetch(`${API_BASE}/api/dailySummary?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/sleep?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/toilet?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/fridge?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/gait?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/neighborhood?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/phone_calls?patient_id=${encodeURIComponent(PATIENT_ID)}`),
        ]);
        const dailyJson        = dailyRes.ok        ? await dailyRes.json()        : [];
        const sleepJson        = sleepRes.ok        ? await sleepRes.json()        : [];
        const toiletJson       = toiletRes.ok       ? await toiletRes.json()       : [];
        const fridgeJson       = fridgeRes.ok       ? await fridgeRes.json()       : [];
        const gaitJson         = gaitRes.ok         ? await gaitRes.json()         : [];
        const neighborhoodJson = neighborhoodRes.ok ? await neighborhoodRes.json() : [];
        const phoneCallJson    = phoneCallRes.ok    ? await phoneCallRes.json()    : [];

        // Build neighborhood RAG text
        const latest = Array.isArray(neighborhoodJson) && neighborhoodJson.length > 0 ? neighborhoodJson[0] : null;
        if (latest) {
          const lines: string[] = ["Neighborhood activities this week (each has a booking ID):"];
          (latest.activities ?? []).forEach((a: any) => {
            const attendeeNames = (a.attendees ?? []).map((x: any) => x.name).join(", ");
            lines.push(`  • [ID:${a.id}] ${a.title}: ${a.date} at ${a.time}, ${a.location} (${a.duration})${attendeeNames ? ` — attending: ${attendeeNames}${a.extraCount > 0 ? ` +${a.extraCount} more` : ""}` : ""}`);
          });
          lines.push("Recent neighbor activity:");
          (latest.feedItems ?? []).forEach((f: any) => { lines.push(`  • ${f.name} ${f.activity} (${f.time})`); });
          const requests = (latest.helpPosts ?? []).filter((p: any) => p.type === "request");
          const offers   = (latest.helpPosts ?? []).filter((p: any) => p.type === "offer");
          if (requests.length) { lines.push("Neighbors who need help:"); requests.forEach((p: any) => lines.push(`  • ${p.name} (${p.category}): ${p.message}`)); }
          if (offers.length)   { lines.push("Neighbors offering help:");  offers.forEach((p: any)   => lines.push(`  • ${p.name} (${p.category}): ${p.message}`)); }
          lines.push("");
          lines.push(
            "BOOKING INSTRUCTION: If Frank asks to join, book, sign up for, or register for a specific activity, " +
            "confirm enthusiastically in your normal response. Then, on a brand new line at the very end, " +
            "append exactly: [[JOIN:ID]] where ID is that activity's booking ID number from the list above. " +
            "Do NOT speak or mention [[JOIN:ID]] — it is a silent machine code only, never part of the conversation. " +
            "Only append it when Frank explicitly asks to join or book an activity."
          );
          neighborhoodRef.current = lines.join("\n");
        }

        const day = pickLatest(Array.isArray(dailyJson) ? dailyJson : []);
        const fridge = extractFridge(fridgeJson);
        const { note: hydrationNote, colorLevel: hydrationColorLevel } = extractHydration(toiletJson);
        const gait = extractGait(gaitJson);
        const { minutes: phoneCallMinutes, trend: phoneCallTrend } = extractPhoneCalls(phoneCallJson);
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
          phoneCallMinutes,
          phoneCallTrend,
          gaitNote: gait?.note ?? "",
          fallRiskAlert: dehydrated && gaitConcern,
        };
        setVitals(loaded);
        vitalsRef.current = loaded;

        // Extract latest session gait metrics for health card status
        const latestGaitDay = [...gaitJson]
          .filter((d: any) => d?.calendarDate)
          .sort((a: any, b: any) => String(b.calendarDate).localeCompare(String(a.calendarDate)))[0];
        if (latestGaitDay?.sessions?.length) {
          const s = latestGaitDay.sessions[latestGaitDay.sessions.length - 1];
          const worseStride = Math.min(Number(s.strideLength?.leftCm ?? 999), Number(s.strideLength?.rightCm ?? 999));
          const worseGCT    = Math.max(Number(s.groundContactTimeMs?.left ?? 0), Number(s.groundContactTimeMs?.right ?? 0));
          setGaitMetrics({ symmetry: Number(s.stepSymmetryPct ?? 0), variability: Number(s.strideVariabilityPct ?? 0), speed: Number(s.gaitSpeedMs ?? 0), cadence: Number(s.cadence ?? 0), worseStride, worseGCT });
        }

        // Build step history for trend chart
        const allDays = (Array.isArray(dailyJson) ? dailyJson : [])
          .filter((d: any) => d?.calendarDate)
          .sort((a: any, b: any) => a.calendarDate.localeCompare(b.calendarDate));
        setStepHistory(
          allDays.filter((d: any) => d?.totalSteps != null).slice(-14).map((d: any) => ({
            day: new Date(d.calendarDate + "T12:00:00").toLocaleDateString("en-US", { month: "numeric", day: "numeric" }),
            steps: Number(d.totalSteps),
          }))
        );
      } catch { /* silent */ }
    })();
  }, []);

  useEffect(() => {
    scrollBottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, isThinking]);

  // ── Derived health card status values ────────────────────────────────────
  const sleepS     = sleepStatus(vitals.sleepHours);
  const heartS     = heartStatus(vitals.heartRate);
  const stepsS     = stepsStatus(vitals.steps);
  const stressS    = stressStatusHelper(vitals.stressLevel);
  const hydrationS = hydrationStatusHelper(vitals.hydrationColorLevel);
  const gaitS      = gaitStatusHelper(gaitMetrics.symmetry, gaitMetrics.variability, gaitMetrics.speed, gaitMetrics.cadence, gaitMetrics.worseStride, gaitMetrics.worseGCT);


  const stressBarColor = stressS.status === "good" ? "bg-emerald-500" : stressS.status === "fair" ? "bg-amber-500" : "bg-rose-500";

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
      case "nutrition":
        return <SmartFridgeCard />;
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
                <div className={`h-full rounded-full transition-all ${stressBarColor}`} style={{ width: `${Math.min(100, vitals.stressLevel)}%` }} />
              </div>
              <div className="grid grid-cols-3 gap-2 text-center text-xs">
                <span className="rounded-lg bg-emerald-50 px-2 py-2 text-emerald-700 font-medium">0–35 · Calm</span>
                <span className="rounded-lg bg-amber-50 px-2 py-2 text-amber-700 font-medium">36–60 · Mild</span>
                <span className="rounded-lg bg-rose-50 px-2 py-2 text-rose-700 font-medium">61+ · Elevated</span>
              </div>
              <p className="text-xs text-muted-foreground leading-relaxed">
                Derived from Garmin heart rate variability analysis throughout the day. Scores are averaged across awake hours only.
              </p>
            </div>
          </ModalCard>
        );
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
            title="My Appointments" subtitle="Upcoming scheduled visits">
            <ElderAppointments />
          </ModalCard>
        );
      default:
        return null;
    }
  };

  const modalTitle: Record<string, string> = {
    heart: "Heart Health", sleep: "Sleep Analysis", nutrition: "Nutrition & Diet",
    stress: "Stress", steps: "Steps Today", gait: "Gait Analysis",
    hydration: "Hydration", medication: "Medications", appointments: "My Appointments",
  };

  const startRecording = async () => {
    if (isRecording || isThinking) return;
    unlockAudio();
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
      recorder.ondataavailable = (e) => { if (e.data.size > 0) chunksRef.current.push(e.data); };
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
          const data: any = ct.includes("application/json") ? await res.json() : { error: await res.text() };
          if (!res.ok || data?.error) { setNohaStatus("Transcription failed"); return; }
          const text = String(data?.transcript || "").trim();
          if (!text) {
            setNohaStatus("I didn't catch that — please try again");
            return;
          }

          setNohaStatus("");
          const nextMessages: Msg[] = [...messagesRef.current, { role: "user", content: text }];
          setMessages([...nextMessages, { role: "assistant", content: "" }]);
          setIsThinking(true);
          speakAbortRef.current?.abort();
          const ttsCtrl = new AbortController();
          speakAbortRef.current = ttsCtrl;
          stopAudio();
          const fullAnswer = await streamAnswer(
            text, nextMessages,
            () => { /* keep Thinking… visible until TTS is ready */ },
            () => { /* accumulate internally — don't update UI yet */ },
            buildHealthContext(vitalsRef.current),
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
            const displayAnswer = fullAnswer.replace(/\n?\s*\[\[JOIN:\d+\]\]/gi, "").trim();
            const buf = await fetchTTSBuffer(ttsReady(displayAnswer), ttsCtrl.signal);
            setIsThinking(false);
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
              window.dispatchEvent(new CustomEvent("noha-join-activity", { detail: { id: activityId } }));
              setOpenPanel("activity");
            }
          }
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
            <div className={[
              "flex h-28 w-28 items-center justify-center rounded-full shadow-md transition-all duration-150",
              isRecording ? "bg-white/25 animate-pulse" : isThinking ? "bg-indigo-300" : "bg-indigo-500",
            ].join(" ")}>
              <Mic className={`h-14 w-14 ${isRecording ? "text-white" : isThinking ? "text-indigo-700" : "text-white"}`} />
            </div>
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
                <p className={`mt-1 text-sm ${openPanel === "health" ? "text-white/80" : "text-muted-foreground"}`}>Vitals & monitoring data</p>
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
                <p className={`mt-1 text-sm ${openPanel === "activity" ? "text-white/80" : "text-muted-foreground"}`}>Events & activities nearby</p>
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
                <p className={`text-xl font-bold leading-tight ${openPanel === "helping" ? "text-white" : "text-foreground"}`}>Helping Board</p>
                <p className={`mt-1 text-sm ${openPanel === "helping" ? "text-white/80" : "text-muted-foreground"}`}>Give or get help from neighbors</p>
              </div>
              {openPanel === "helping" ? <ChevronUp className="h-6 w-6 text-white/80" /> : <ChevronDown className="h-6 w-6 text-rose-400" />}
            </button>

            {/* My Appointments moved into Health Overview grid */}
          </div>
        </div>

        {/* ── My Health Panel ────────────────────────────────────────── */}
        {openPanel === "health" && (
          <div className="mt-6 rounded-3xl border border-blue-100 bg-white p-6 shadow-lg sm:p-8">

            {/* Section label */}
            <div className="mb-4 flex items-center gap-3">
              <span className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Health Overview</span>
              <div className="flex-1 h-px bg-border" />
              <span className="text-xs text-muted-foreground">Tap any card for details</span>
            </div>

            {/* 8-card grid */}
            <div className="grid grid-cols-3 gap-3">
              <HealthCard icon={Heart} iconBg="bg-heart/15 text-heart" title="Heart Health" label={heartS.label} labelColor={heartS.color} note={heartS.note} onClick={() => setOpenModal("heart")} />
              <HealthCard icon={Moon} iconBg="bg-sleep/15 text-sleep" title="Sleep Analysis" label={sleepS.label} labelColor={sleepS.color} note={sleepS.note} onClick={() => setOpenModal("sleep")} />
              <HealthCard icon={Utensils} iconBg="bg-teal-500/15 text-teal-600" title="Nutrition & Diet" label="Meals tracked" labelColor="text-teal-600" note="Smart fridge monitoring" onClick={() => setOpenModal("nutrition")} />
              <HealthCard icon={Brain} iconBg="bg-stress/15 text-stress" title="Stress" label={stressS.label} labelColor={stressS.color} note={stressS.note} onClick={() => setOpenModal("stress")} />
              <HealthCard icon={Footprints} iconBg="bg-ecg/15 text-ecg" title="Steps Today" label={stepsS.label} labelColor={stepsS.color} note={stepsS.note} onClick={() => setOpenModal("steps")} />
              <HealthCard icon={Shield} iconBg="bg-amber-500/15 text-amber-600" title="Gait Analysis" label={gaitS.label} labelColor={gaitS.color} note={gaitS.note} onClick={() => setOpenModal("gait")} />
              <HealthCard icon={Droplets} iconBg="bg-teal-500/15 text-teal-600" title="Hydration" label={hydrationS.label} labelColor={hydrationS.color} note={hydrationS.note} onClick={() => setOpenModal("hydration")} />
              <HealthCard icon={Pill} iconBg="bg-blue-500/15 text-blue-600" title="Medication" label="Active Rx" labelColor="text-blue-600" note="Prescriptions & dosage" onClick={() => setOpenModal("medication")} />
              <HealthCard icon={Calendar} iconBg="bg-violet-500/15 text-violet-600" title="Appointments" label="Upcoming" labelColor="text-violet-600" note="Scheduled visits" onClick={() => setOpenModal("appointments")} />
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
