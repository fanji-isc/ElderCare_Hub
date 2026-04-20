import { useEffect, useState } from "react";
import {
  Heart, Moon, Utensils, Brain, Footprints, Shield, Droplets, Pill,
  ShieldCheck, AlertCircle, AlertTriangle,
  Phone, PhoneOff, PhoneIncoming, PhoneCall, Share2,
  Calendar, CheckSquare, Square,
} from "lucide-react";
import { Header } from "@/components/Header";
import { HeartRateChart } from "@/components/HeartRateChart";
import { SleepChart } from "@/components/SleepChart";
import { WalkingActivityChart } from "@/components/WalkingActivityChart";
import { SmartFridgeCard } from "@/components/SmartFridgeCard";
import { ECGVisualization } from "@/components/ECGVisualization";
import { HydrationIndicator } from "@/components/HydrationIndicator";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import {
  AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, ReferenceLine,
} from "recharts";
import { toast } from "sonner";

type Vitals = { heartRate: number; steps: number; stressLevel: number; sleepHours: number; mealsCount: number };
type Med = { drug: string; status: string; authored: string; dosage: string };
type Appt = { status: string; start: string; end: string; type: string; practitioner: string; location: string };

const API_BASE = "http://localhost:3001";
const HOME_ID = "PATIENT_001";
const first_name = "Frank";
const last_name = "Larson";

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

// ── Health card status helpers ─────────────────────────────────────────────────
function heartStatus(bpm: number) {
  if (bpm === 0)              return { label: "No data",           note: "Heart rate unavailable",                   color: "text-muted-foreground", status: "fair" as const };
  if (bpm >= 55 && bpm <= 85) return { label: "Normal range",      note: `${bpm} BPM — healthy resting rate`,        color: "text-emerald-600",       status: "good" as const };
  if (bpm > 85 && bpm <= 100) return { label: "Slightly elevated", note: `${bpm} BPM — monitor if it persists`,      color: "text-amber-600",         status: "fair" as const };
  if (bpm < 55 && bpm > 0)    return { label: "Slightly low",      note: `${bpm} BPM — could be normal if athletic`, color: "text-amber-600",         status: "fair" as const };
  return                       { label: "Check with doctor",  note: `${bpm} BPM — outside normal range`,       color: "text-rose-600",          status: "warn" as const };
}

function stepsStatus(steps: number) {
  if (steps === 0)   return { label: "No data",            note: "Activity data unavailable",                        color: "text-muted-foreground", status: "fair" as const };
  if (steps >= 5000) return { label: "Very active",        note: `${steps.toLocaleString()} steps — excellent!`,     color: "text-emerald-600",       status: "good" as const };
  if (steps >= 2500) return { label: "Moderately active",  note: `${steps.toLocaleString()} steps — good movement`,  color: "text-emerald-600",       status: "good" as const };
  if (steps >= 1000) return { label: "Light activity",     note: `${steps.toLocaleString()} steps — quieter day`,    color: "text-amber-600",         status: "fair" as const };
  return             { label: "Very little movement", note: `${steps.toLocaleString()} steps — may want to check in`, color: "text-rose-600",       status: "warn" as const };
}

function stressStatus(v: number) {
  if (v === 0)  return { label: "Calm",        note: "Stress levels look great",       color: "text-emerald-600", status: "good" as const };
  if (v <= 35)  return { label: "Calm",        note: "Very relaxed today",             color: "text-emerald-600", status: "good" as const };
  if (v <= 60)  return { label: "Mild stress", note: "Some stress — likely normal",    color: "text-amber-600",   status: "fair" as const };
  return        { label: "High stress",  note: "Elevated stress — worth a call", color: "text-rose-600",    status: "warn" as const };
}

function sleepStatus(h: number) {
  if (h === 0)   return { label: "No data",       note: "Sleep data unavailable",                 color: "text-muted-foreground", status: "fair" as const };
  if (h >= 7)    return { label: "Well rested",   note: `${h.toFixed(1)} hrs — great for his age`,     color: "text-emerald-600", status: "good" as const };
  if (h >= 5.5)  return { label: "Light sleep",   note: `${h.toFixed(1)} hrs — a bit below ideal`,     color: "text-amber-600",   status: "fair" as const };
  return          { label: "Poor sleep",   note: `Only ${h.toFixed(1)} hrs — worth checking in`, color: "text-rose-600",    status: "warn" as const };
}

function hydrationStatus(level: number) {
  if (level === 0) return { label: "No data",          note: "Hydration data unavailable",             color: "text-muted-foreground", status: "fair" as const };
  if (level <= 2)  return { label: "Excellent",        note: "Well hydrated — great job!",             color: "text-emerald-600",      status: "good" as const };
  if (level <= 3)  return { label: "Normal",           note: "Hydration looks normal",                 color: "text-emerald-600",      status: "good" as const };
  if (level <= 4)  return { label: "Drink More Water", note: "Could use a bit more water",             color: "text-amber-600",        status: "fair" as const };
  if (level <= 5)  return { label: "Mild Dehydration", note: "Encourage more fluid intake",            color: "text-amber-600",        status: "fair" as const };
  if (level <= 6)  return { label: "Dehydrated",       note: "Dehydrated — needs water now",           color: "text-rose-600",         status: "warn" as const };
  return           { label: "Very Dehydrated",         note: "Severely dehydrated — consider calling", color: "text-rose-600",         status: "warn" as const };
}

function gaitStatus(symmetryPct: number, variabilityPct: number, speedMs: number, cadence: number, worseStride: number, worseGCT: number) {
  if (symmetryPct === 0) return { label: "No data", note: "Gait data unavailable",          color: "text-muted-foreground", status: "fair" as const };
  const isHigh = cadence < 80  || speedMs < 0.7  || worseStride < 90  || worseGCT > 950 || symmetryPct < 78  || variabilityPct > 10;
  if (isHigh) return { label: "Irregular gait",     note: "Significant gait irregularities detected", color: "text-rose-600",    status: "warn" as const };
  const isMed  = cadence < 100 || speedMs < 1.0  || worseStride < 140 || worseGCT > 650 || symmetryPct < 95  || variabilityPct > 5;
  if (isMed)  return { label: "Some asymmetry", note: "Some asymmetry — worth monitoring",        color: "text-amber-600",   status: "fair" as const };
  return             { label: "Steady and Balanced",      note: "Gait looks steady and balanced",           color: "text-emerald-600", status: "good" as const };
}

function nutritionStatus(mealsCount: number) {
  let colour = "text-emerald-600"
  if (mealsCount === 2) colour = "text-amber-600";
  if (mealsCount === 1) colour = "text-orange-600";
  if (mealsCount === 0)  return  { label: `No meals tracked`, color: "text-rose-600"};
  return  { label: `${mealsCount} meals tracked`, color: colour};
}

// ── MedicationDetail ──────────────────────────────────────────────────────────
function MedicationDetail() {
  const [meds, setMeds] = useState<Med[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchMeds = async () => {
      try {
        const res = await fetch(`${API_BASE}/api/fhir/patient-medications?first_name=${first_name}&last_name=${last_name}`);
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
function getApptActions(type: string): string[] {
  const t = type.toLowerCase();
  if (t.includes("cardio") || t.includes("cardiac"))
    return [`Collate ${first_name}'s heart rate readings`, `Send ${first_name} their current medication list`, `Remind ${first_name} 1 day before`];
  if (t.includes("lab") || t.includes("blood") || t.includes("panel"))
    return [`Remind ${first_name} to fast (no food after midnight)`, "Arrange early morning transport"];
  if (t.includes("primary") || t.includes("general") || t.includes("check"))
    return ["Prepare questions for the doctor", `Remind ${first_name} 1 day before`];
  return ["Arrange transport", `Remind ${first_name} 1 day before`];
}
function AppointmentsDetail() {
  const [appts, setAppts] = useState<Appt[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [checked, setChecked] = useState<Record<string, boolean>>({});

  useEffect(() => {
    const fetchAppts = async () => {
      try {
        const res = await fetch(`${API_BASE}/api/fhir/patient-appointments?first_name=${first_name}&last_name=${last_name}`);
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

  const toggle = (key: string) => setChecked(prev => ({ ...prev, [key]: !prev[key] }));

  if (loading) return <div className="flex items-center justify-center py-12"><p className="text-sm text-muted-foreground">Loading appointments…</p></div>;
  if (error)   return <div className="flex items-center justify-center py-12"><p className="text-sm text-rose-600">{error}</p></div>;
  if (!appts.length) return <div className="flex items-center justify-center py-12"><p className="text-sm text-muted-foreground">No upcoming appointments scheduled.</p></div>;

  return (
    <div className="space-y-4">
      {appts.map((appt, i) => {
        const startDate = appt.start
          ? new Date(appt.start).toLocaleDateString("en-US", { weekday: "short", year: "numeric", month: "short", day: "numeric" })
          : null;
        const startTime = appt.start
          ? new Date(appt.start).toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" })
          : null;
        const actions = getApptActions(appt.type);
        return (
          <div key={i} className="rounded-xl border border-violet-100 bg-violet-50/40 overflow-hidden">
            {/* Appointment header */}
            <div className="px-4 py-3 bg-violet-50 border-b border-violet-100">
              <div className="flex items-start justify-between gap-2">
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold text-foreground">{appt.type}</p>
                  {startDate && (
                    <p className="mt-0.5 text-xs text-muted-foreground">
                      {startDate}{startTime ? ` · ${startTime}` : ""}
                    </p>
                  )}
                  {appt.practitioner && (
                    <p className="mt-0.5 text-xs text-muted-foreground">{appt.practitioner}</p>
                  )}
                  {appt.location && (
                    <p className="mt-0.5 text-xs text-muted-foreground/70">{appt.location}</p>
                  )}
                </div>
                <span className="flex-shrink-0 text-xs font-medium px-2 py-0.5 rounded-full bg-violet-100 text-violet-700 capitalize">
                  {appt.status}
                </span>
              </div>
            </div>
            {/* Action checklist — no label */}
            <div className="px-4 py-3 space-y-2">
              {actions.map((action, j) => {
                const key = `${i}-${j}`;
                const done = !!checked[key];
                return (
                  <button key={key} onClick={() => toggle(key)} className="flex items-center gap-2.5 w-full text-left group">
                    {done
                      ? <CheckSquare className="h-4 w-4 flex-shrink-0 text-emerald-500" />
                      : <Square className="h-4 w-4 flex-shrink-0 text-muted-foreground/50 group-hover:text-violet-400 transition-colors" />
                    }
                    <span className={`text-sm leading-snug transition-colors ${done ? "line-through text-muted-foreground/50" : "text-foreground"}`}>
                      {action}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ── HipaaShieldIcon ───────────────────────────────────────────────────────────
function HipaaShieldIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      {/* Shield */}
      <path d="M12 2L3 6.5V13C3 18.2 7 22 12 23C17 22 21 18.2 21 13V6.5L12 2Z" fill="#84cc16"/>
      {/* Document (white) */}
      <path d="M8 8H12.5L15 10.5V19H8V8Z" fill="white"/>
      {/* Folded corner */}
      <path d="M12.5 8V10.5H15L12.5 8Z" fill="#bef264"/>
      {/* Medical cross */}
      <rect x="11" y="12" width="1.5" height="4.5" rx="0.4" fill="#84cc16"/>
      <rect x="9.25" y="13.5" width="5" height="1.5" rx="0.4" fill="#84cc16"/>
      {/* Badge circle */}
      <circle cx="18.5" cy="6" r="4" fill="white"/>
      <circle cx="18.5" cy="6" r="3.2" fill="#84cc16"/>
      {/* Checkmark */}
      <path d="M17 6L18.2 7.3L20.1 4.8" stroke="white" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
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
        <div className="flex-1">
          <p className="text-sm font-semibold text-foreground leading-tight">{title}</p>
          {subtitle && <p className="text-xs text-muted-foreground">{subtitle}</p>}
        </div>
        <span title="HIPAA Protected Health Information" className="flex-shrink-0"><HipaaShieldIcon className="h-4 w-4" /></span>
      </div>
      <div className="p-5">{children}</div>
    </div>
  );
}

// ── HealthCard ────────────────────────────────────────────────────────────────
function HealthCard({
  icon: Icon, iconBg, cardBg, title, label, labelColor, subtitle, onClick,
}: {
  icon: React.ElementType;
  iconBg: string;
  cardBg: string;
  title: string;
  label: string;
  labelColor: string;
  subtitle?: string;
  onClick: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className={`rounded-2xl shadow-card overflow-hidden cursor-pointer group hover:shadow-lg transition-shadow px-5 py-6 flex flex-col justify-center ${cardBg}`}
    >
      <div className="flex items-center gap-3 mb-4">
        <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${iconBg}`}>
          <Icon className="h-5 w-5" />
        </div>
        <span className="text-base font-semibold text-foreground flex-1">{title}</span>
        <span title="HIPAA Protected Health Information" className="flex-shrink-0"><HipaaShieldIcon className="h-4 w-4" /></span>
      </div>
      <p className={`text-sm font-medium leading-tight ${labelColor}`}>{label}</p>
      {subtitle && <p className="mt-1 text-xs text-muted-foreground leading-tight">{subtitle}</p>}
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────
const FamilyView = () => {
  const [vitals, setVitals] = useState<Vitals>({ heartRate: 0, steps: 0, stressLevel: 0, sleepHours: 0, mealsCount: 0 });
  const [stepHistory, setStepHistory] = useState<{ day: string; steps: number }[]>([]);
  const [hydrationLevel, setHydrationLevel] = useState(0);
  const [gaitMetrics, setGaitMetrics] = useState({ symmetry: 0, variability: 0, speed: 0, cadence: 0, worseStride: 0, worseGCT: 0 });
  const [familySummary, setFamilySummary] = useState<{ status: string; summary: string } | null>(null);
  const [loaded, setLoaded] = useState(false);
  const [openModal, setOpenModal] = useState<string | null>(null);
  const [incomingCall, setIncomingCall] = useState(false);
  const [callConnected, setCallConnected] = useState(false);
  const [familyCallState, setFamilyCallState] = useState<"idle" | "calling" | "connected" | "declined">("idle");
  const [callSeconds, setCallSeconds] = useState(0);
  const [shareModalOpen, setShareModalOpen] = useState(false);
  const [shareDescription, setShareDescription] = useState("");
  const [selectedData, setSelectedData] = useState<Record<string, boolean>>({
    heart: false, sleep: false, nutrition: false, stress: false, 
    steps: false, gait: false, hydration: false
  });
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerateReport = async () => {
    setIsGenerating(true);
    try {
      const payload = {
        patient_id: HOME_ID,
        patient_name: `${first_name} ${last_name}`,
        description: shareDescription,
        included_metrics: Object.keys(selectedData).filter(key => selectedData[key])
      };

      const response = await fetch(`${API_BASE}/api/generate-report`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) throw new Error("Failed to generate report");

      toast.success("Report generated successfully!");
      setShareModalOpen(false);
    } catch (error) {
      toast.error("Error generating report. Please try again.");
      console.error(error);
    } finally {
      setIsGenerating(false);
    }
  };

  useEffect(() => {
    const sync = () => {
      const val = JSON.parse(localStorage.getItem("nhh-call-state") ?? "{}");
      if (val.status === "ringing") { setIncomingCall(true); setCallConnected(false); }
      else if (val.status === "idle") { setIncomingCall(false); setCallConnected(false); }
    };
    sync(); // check on mount
    const interval = setInterval(sync, 500); // poll every 500ms (same-tab navigation)
    const handler = (e: StorageEvent) => { // cross-tab events
      if (e.key === "nhh-call-state") sync();
    };
    window.addEventListener("storage", handler);
    return () => { clearInterval(interval); window.removeEventListener("storage", handler); };
  }, []);

  // Listen for Frank's response to family's call
  useEffect(() => {
    const handler = (e: StorageEvent) => {
      if (e.key !== "nhh-family-call-state") return;
      const val = JSON.parse(e.newValue ?? "{}");
      if (val.status === "accepted") setFamilyCallState("connected");
      if (val.status === "declined") {
        setFamilyCallState("declined");
        setTimeout(() => setFamilyCallState("idle"), 3000);
      }
      if (val.status === "idle") setFamilyCallState("idle");
    };
    window.addEventListener("storage", handler);
    // Also poll for same-tab navigation
    const interval = setInterval(() => {
      const val = JSON.parse(localStorage.getItem("nhh-family-call-state") ?? "{}");
      if (val.status === "accepted" && familyCallState !== "connected") setFamilyCallState("connected");
      if (val.status === "idle" && familyCallState !== "idle") setFamilyCallState("idle");
    }, 500);
    return () => { window.removeEventListener("storage", handler); clearInterval(interval); };
  }, [familyCallState]);

  const isFamilyConnected = callConnected || familyCallState === "connected";
  useEffect(() => {
    if (!isFamilyConnected) { setCallSeconds(0); return; }
    const t = setInterval(() => setCallSeconds(s => s + 1), 1000);
    return () => clearInterval(t);
  }, [isFamilyConnected]);
  const fmtTime = (s: number) =>
    `${String(Math.floor(s / 60)).padStart(2, "0")}:${String(s % 60).padStart(2, "0")}`;

  const startFamilyCall = () => {
    setFamilyCallState("calling");
    localStorage.setItem("nhh-family-call-state", JSON.stringify({ status: "ringing", timestamp: Date.now() }));
  };
  const endFamilyCall = () => {
    setFamilyCallState("idle");
    localStorage.setItem("nhh-family-call-state", JSON.stringify({ status: "idle", timestamp: Date.now() }));
  };

  const acceptCall = () => {
    setIncomingCall(false);
    setCallConnected(true);
    localStorage.setItem("nhh-call-state", JSON.stringify({ status: "accepted", timestamp: Date.now() }));
  };
  const declineCall = () => {
    setIncomingCall(false);
    localStorage.setItem("nhh-call-state", JSON.stringify({ status: "declined", timestamp: Date.now() }));
  };
  const endCall = () => {
    setCallConnected(false);
    localStorage.setItem("nhh-call-state", JSON.stringify({ status: "idle", timestamp: Date.now() }));
  };

  // TODO: change how Vitals is set so the logic from ElderView can be reused
  useEffect(() => {
    (async () => {
      try {
        const [dailyRes, sleepRes, toiletRes, gaitRes, fridgeRes, summaryRes] = await Promise.all([
          fetch(`${API_BASE}/api/iris_data?patient_id=${HOME_ID}&column=dailySummary`),
          fetch(`${API_BASE}/api/iris_data?patient_id=${HOME_ID}&column=sleep`),
          fetch(`${API_BASE}/api/iris_data?patient_id=${HOME_ID}&column=toilet`),
          fetch(`${API_BASE}/api/iris_data?patient_id=${HOME_ID}&column=gait`),
          fetch(`${API_BASE}/api/iris_data?patient_id=${HOME_ID}&column=fridge`),
          fetch(`${API_BASE}/api/family-summary?patient_id=${HOME_ID}`),
        ]);
        const dailyJson = dailyRes.ok ? await dailyRes.json() : [];
        const sleepJson = sleepRes.ok ? await sleepRes.json() : [];
        const toiletJson: any[] = toiletRes.ok ? await toiletRes.json() : [];
        const gaitJson: any[] = gaitRes.ok ? await gaitRes.json() : [];
        const fridgeJson: any[] = fridgeRes.ok ? await fridgeRes.json() : [];

        if (summaryRes.ok) {
          const summaryData = await summaryRes.json();
          setFamilySummary(summaryData);
        }
    
        // Derive gait risk from latest day's sessions (average key metrics)
        const latestGait = [...gaitJson]
          .filter((d: any) => d?.calendarDate)
          .sort((a: any, b: any) => String(b.calendarDate).localeCompare(String(a.calendarDate)))[0];
        if (latestGait?.sessions?.length) {
          // Use the last session — same as WalkingActivityChart
          const s = latestGait.sessions[latestGait.sessions.length - 1];
          const worseStride = Math.min(Number(s.strideLength?.leftCm ?? 999), Number(s.strideLength?.rightCm ?? 999));
          const worseGCT    = Math.max(Number(s.groundContactTimeMs?.left ?? 0), Number(s.groundContactTimeMs?.right ?? 0));
          setGaitMetrics({
            symmetry:    Number(s.stepSymmetryPct ?? 0),
            variability: Number(s.strideVariabilityPct ?? 0),
            speed:       Number(s.gaitSpeedMs ?? 0),
            cadence:     Number(s.cadence ?? 0),
            worseStride,
            worseGCT,
          });
        }

        // Derive hydration level from latest day's last reading
        const latestToilet = [...toiletJson]
          .filter((d: any) => d?.calendarDate)
          .sort((a: any, b: any) => String(b.calendarDate).localeCompare(String(a.calendarDate)))[0];
        const lastReading = latestToilet?.readings?.at(-1);
        if (lastReading?.colorLevel) setHydrationLevel(Math.min(8, Math.max(1, Number(lastReading.colorLevel))));

        const allDays = (Array.isArray(dailyJson) ? dailyJson : [])
          .filter((d: any) => d?.calendarDate)
          .sort((a: any, b: any) => a.calendarDate.localeCompare(b.calendarDate));

        setStepHistory(
          allDays
            .filter((d: any) => d?.totalSteps != null)
            .slice(-14)
            .map((d: any) => ({
              day: new Date(d.calendarDate + "T12:00:00").toLocaleDateString("en-US", { month: "numeric", day: "numeric" }),
              steps: Number(d.totalSteps),
            }))
        );

        const latestFridge = [...fridgeJson].sort((a, b) =>
          String(b?.calendarDate || "").localeCompare(String(a?.calendarDate || ""))
        )[0];

        const day = allDays[allDays.length - 1] ?? null;
        setVitals({
          heartRate: Number(day?.currentDayRestingHeartRate ?? day?.restingHeartRate ?? 0),
          steps: Number(day?.totalSteps ?? 0),
          stressLevel: extractStress(day),
          sleepHours: extractSleep(sleepJson),
          mealsCount: (latestFridge.mealsDetected ?? []).length
        });
      } catch (error) {
        console.error("Error loading data:", error);
      }
      finally { setLoaded(true); }
    })();
  }, []);

  if (!loaded || !familySummary) {
    return (
      <div className="flex h-screen items-center justify-center bg-background">
        <div className="text-center">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-emerald-500 border-t-transparent mx-auto mb-4"></div>
          <p className="text-muted-foreground animate-pulse">Loading {first_name}'s health dashboard...</p>
        </div>
      </div>
    );
  }

  const sleep     = sleepStatus(vitals.sleepHours);
  const heart     = heartStatus(vitals.heartRate);
  const steps     = stepsStatus(vitals.steps);
  const stepsTrend = (() => {
    if (stepHistory.length < 2) return { label: steps.label, subtitle: undefined };
    const prev = stepHistory.slice(0, -1).reduce((s, d) => s + d.steps, 0) / (stepHistory.length - 1);
    const curr = vitals.steps;
    if (prev === 0) return { label: steps.label, subtitle: undefined };
    const pct = Math.round(((curr - prev) / prev) * 100);
    if (pct <= -20) return { label: `${curr.toLocaleString()} steps · ↓ ${Math.abs(pct)}%`, subtitle: undefined };
    if (pct >= 20)  return { label: `${curr.toLocaleString()} steps · ↑ ${pct}%`, subtitle: undefined };
    return { label: steps.label, subtitle: undefined };
  })();
  const stress    = stressStatus(vitals.stressLevel);
  const stressBarColor = stress.status === "good" ? "bg-emerald-500" : stress.status === "fair" ? "bg-amber-500" : "bg-rose-500";
  const hydration = hydrationStatus(hydrationLevel);
  const gait      = gaitStatus(gaitMetrics.symmetry, gaitMetrics.variability, gaitMetrics.speed, gaitMetrics.cadence, gaitMetrics.worseStride, gaitMetrics.worseGCT);
  const nutrition = nutritionStatus(vitals.mealsCount)

  const statusConfig = {
    good: {
      icon: ShieldCheck, gradient: "from-emerald-50 to-teal-50", border: "border-emerald-200",
      iconBg: "bg-emerald-500", text: "text-emerald-900", sub: "text-emerald-700",
      badge: "bg-emerald-100 text-emerald-700 border border-emerald-200",
      title: `${first_name} is doing well today`
    },
    fair: {
      icon: AlertCircle, gradient: "from-amber-50 to-yellow-50", border: "border-amber-200",
      iconBg: "bg-amber-500", text: "text-amber-900", sub: "text-amber-700",
      badge: "bg-amber-100 text-amber-700 border border-amber-200",
      title: `${first_name} is generally okay`
    },
    warn: {
      icon: AlertTriangle, gradient: "from-rose-50 to-red-50", border: "border-rose-200",
      iconBg: "bg-rose-500", text: "text-rose-900", sub: "text-rose-700",
      badge: "bg-rose-100 text-rose-700 border border-rose-200",
      title: `${first_name} may need your attention`
    },
  }[familySummary.status];

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
            title="Stress" subtitle={stress.note}>
            <div className="space-y-4 max-w-md">
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Score today</span>
                <span className={`text-2xl font-bold ${stress.color}`}>
                  {vitals.stressLevel > 0 ? vitals.stressLevel : "—"}
                  <span className="text-sm font-normal text-muted-foreground"> / 100</span>
                </span>
              </div>
              <div className="h-3 rounded-full bg-muted overflow-hidden">
                <div
                  className={`h-full rounded-full transition-all ${stressBarColor}`}
                  style={{ width: `${Math.min(100, vitals.stressLevel)}%` }}
                />
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
        const avgSteps = stepHistory.length
          ? Math.round(stepHistory.reduce((s, d) => s + d.steps, 0) / stepHistory.length)
          : 0;
        const maxSteps = stepHistory.length ? Math.max(...stepHistory.map((d) => d.steps)) : 0;
        const prevAvg = stepHistory.length > 1
          ? Math.round(stepHistory.slice(0, -1).reduce((s, d) => s + d.steps, 0) / (stepHistory.length - 1))
          : 0;
        const trendPct = prevAvg > 0 ? Math.round(((vitals.steps - prevAvg) / prevAvg) * 100) : 0;
        const trendUp = trendPct >= 0;
        return (
          <ModalCard icon={Footprints} iconBg="bg-ecg" gradient="from-blue-50 to-sky-50"
            title="Steps Today" subtitle={steps.note}>
            <div className="space-y-5">
              {/* Today + trend vs recent average */}
              <div className="flex items-end justify-between">
                <div>
                  <p className={`text-4xl font-bold ${steps.color}`}>
                    {vitals.steps > 0 ? vitals.steps.toLocaleString() : "—"}
                  </p>
                  <p className="mt-0.5 text-sm text-muted-foreground">{steps.label} today</p>
                </div>
                {prevAvg > 0 && (
                  <div className={`text-right ${trendUp ? "text-emerald-600" : "text-rose-600"}`}>
                    <p className="text-xl font-bold">{trendUp ? "+" : ""}{trendPct}%</p>
                    <p className="text-xs text-muted-foreground">vs. recent avg</p>
                  </div>
                )}
              </div>

              {/* Stats row */}
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

              {/* Trend area chart */}
              {stepHistory.length > 1 && (
                <>
                  <p className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                    {stepHistory.length}-day trend
                  </p>
                  <div className="h-52">
                    <ResponsiveContainer width="100%" height="100%">
                      <AreaChart data={stepHistory} margin={{ top: 8, right: 8, left: -20, bottom: 0 }}>
                        <defs>
                          <linearGradient id="stepsGradient" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stopColor="hsl(var(--ecg))" stopOpacity={0.35} />
                            <stop offset="100%" stopColor="hsl(var(--ecg))" stopOpacity={0} />
                          </linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
                        <XAxis dataKey="day" tick={{ fontSize: 11, fill: "hsl(215,16%,50%)" }} axisLine={false} tickLine={false} />
                        <YAxis tick={{ fontSize: 11, fill: "hsl(215,16%,50%)" }} axisLine={false} tickLine={false} />
                        <Tooltip
                          contentStyle={{ fontSize: 12, borderRadius: 8, border: "1px solid hsl(var(--border))" }}
                          formatter={(v: number) => [v.toLocaleString(), "Steps"]}
                        />
                        <ReferenceLine
                          y={5000}
                          stroke="hsl(var(--success))"
                          strokeDasharray="4 4"
                          label={{ value: "Goal 5k", fontSize: 9, fill: "hsl(var(--success))", position: "right" }}
                        />
                        <Area
                          type="monotone"
                          dataKey="steps"
                          stroke="hsl(var(--ecg))"
                          strokeWidth={2.5}
                          fill="url(#stepsGradient)"
                          dot={{ r: 3, fill: "hsl(var(--ecg))", strokeWidth: 0 }}
                          isAnimationActive={false}
                        />
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
            title="Upcoming Appointments" subtitle="Scheduled visits & family action items">
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
    hydration: "Hydration", medication: "Medications", appointments: "My Appointments",
  };

  return (
    <div className="min-h-screen bg-background">
      {/* ── Outgoing call to Frank ───────────────────────────────── */}
      {familyCallState === "calling" && (
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
              <p className="text-lg font-bold tracking-wide">📲 Calling {first_name}...</p>
              <p className="text-sm font-medium text-white/90">Waiting for {first_name} to pick up</p>
            </div>
          </div>
          <button onClick={endFamilyCall} className="flex items-center gap-2 rounded-full bg-rose-500 px-5 py-2.5 text-sm font-bold shadow-lg hover:bg-rose-400 active:scale-95 transition-all">
            <PhoneOff className="h-4 w-4" /> Cancel
          </button>
        </div>
      )}

      {/* ── Incoming call overlay ─────────────────────────────────── */}
      {incomingCall && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between gap-4 px-6 py-5 shadow-2xl"
          style={{ background: "linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #db2777 100%)" }}>
          {/* Animated ring rings behind icon */}
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
              <p className="text-sm font-medium text-white/90">{first_name} {last_name} is calling you</p>
            </div>
          </div>
          <div className="flex gap-3">
            <button onClick={acceptCall} className="flex items-center gap-2 rounded-full bg-emerald-400 px-5 py-2.5 text-sm font-bold text-white shadow-lg hover:bg-emerald-300 active:scale-95 transition-all">
              <Phone className="h-4 w-4" /> Accept
            </button>
            <button onClick={declineCall} className="flex items-center gap-2 rounded-full bg-rose-500 px-5 py-2.5 text-sm font-bold text-white shadow-lg hover:bg-rose-400 active:scale-95 transition-all">
              <PhoneOff className="h-4 w-4" /> Decline
            </button>
          </div>
        </div>
      )}

      {/* ── Connected banner (Frank called us / we called Frank) ─── */}
      {(callConnected || familyCallState === "connected") && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between px-6 py-3 bg-emerald-600 text-white shadow-lg">
          <div className="flex items-center gap-3">
            <div className="h-2 w-2 rounded-full bg-white animate-pulse" />
            <span className="text-sm font-semibold">Connected with {first_name}</span>
            <span className="rounded-full bg-white/20 px-2.5 py-0.5 text-xs font-mono font-semibold">{fmtTime(callSeconds)}</span>
          </div>
          <button
            onClick={callConnected ? endCall : endFamilyCall}
            className="flex items-center gap-2 rounded-full bg-white/20 px-3 py-1.5 text-xs font-semibold hover:bg-white/30 transition"
          >
            <PhoneOff className="h-3.5 w-3.5" /> End Call
          </button>
        </div>
      )}

      <Header />

      <main className="container mx-auto px-4 py-6 sm:px-6 max-w-7xl flex flex-col" style={{ minHeight: 'calc(100vh - 64px)' }}>

        {/* ── Page header ──────────────────────────────────────────── */}
        <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-xl font-bold text-foreground leading-tight">Welcome, {first_name}'s Family</h2>
          </div>
          <div className="flex items-center gap-2">
            {familyCallState === "idle" && (
              <Button variant="outline" size="sm" onClick={startFamilyCall}>
                <Phone className="mr-1.5 h-3.5 w-3.5" />
                Call {first_name}
              </Button>
            )}
            {familyCallState === "calling" && (
              <Button size="sm" onClick={endFamilyCall} className="animate-pulse bg-amber-500 hover:bg-amber-600 border-0">
                <PhoneCall className="mr-1.5 h-3.5 w-3.5" />
                Calling…
              </Button>
            )}
            {familyCallState === "connected" && (
              <Button size="sm" onClick={endFamilyCall} className="bg-emerald-600 hover:bg-emerald-700 border-0 gap-2">
                <span className="h-1.5 w-1.5 rounded-full bg-white animate-pulse" />
                Connected · End
                <PhoneOff className="h-3.5 w-3.5" />
              </Button>
            )}
            {familyCallState === "declined" && (
              <Button size="sm" disabled className="bg-rose-100 text-rose-600 border-0">
                <PhoneOff className="mr-1.5 h-3.5 w-3.5" />
                Declined
              </Button>
            )}
            <Button size="sm" onClick={() => setShareModalOpen(true)}>
              <Share2 className="mr-1.5 h-3.5 w-3.5" />
              Share Report
            </Button>
          </div>
        </div>

        {/* ── Overall status banner ─────────────────────────────────── */}
        <div className={`mb-6 rounded-2xl border bg-gradient-to-r overflow-hidden shadow-card ${statusConfig.gradient} ${statusConfig.border}`}>
          <div className="flex items-start gap-4 p-5">
            <div className={`flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl shadow-sm ${statusConfig.iconBg}`}>
              <statusConfig.icon className="h-5 w-5 text-white" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex flex-wrap items-center gap-2 mb-1">
                <h3 className={`text-base font-bold ${statusConfig.text}`}>{statusConfig.title}</h3>
              </div>
              {(
                <p className="mt-2 text-sm text-foreground/75 leading-relaxed">{familySummary.summary}</p>
              )}
            </div>
          </div>
        </div>

        {/* ── 9-card grid (3 × 3) ───────────────────────────────────── */}
        <div className="grid grid-cols-3 gap-3 flex-1" style={{ gridTemplateRows: 'repeat(3, 1fr)' }}>
          <HealthCard
            icon={Heart} iconBg="bg-heart/15 text-heart" cardBg="bg-sky-50"
            title="Heart Health"
            label={heart.label} labelColor={heart.color}
            onClick={() => setOpenModal("heart")}
          />
          <HealthCard
            icon={Moon} iconBg="bg-sleep/15 text-sleep" cardBg="bg-sky-50"
            title="Sleep Analysis"
            label={sleep.label} labelColor={sleep.color}
            onClick={() => setOpenModal("sleep")}
          />
          <HealthCard
            icon={Utensils} iconBg="bg-teal-500/15 text-teal-600" cardBg="bg-sky-50"
            title="Nutrition & Diet"
            label={nutrition.label} labelColor={nutrition.color}            
            onClick={() => setOpenModal("nutrition")}            
          />
          <HealthCard
            icon={Brain} iconBg="bg-stress/15 text-stress" cardBg="bg-sky-50"
            title="Stress"
            label={stress.label} labelColor={stress.color}
            onClick={() => setOpenModal("stress")}
          />
          <HealthCard
            icon={Footprints} iconBg="bg-ecg/15 text-ecg" cardBg="bg-sky-50"
            title="Steps Today"
            label={stepsTrend.label} labelColor={steps.color}
            subtitle={stepsTrend.subtitle}
            onClick={() => setOpenModal("steps")}
          />
          <HealthCard
            icon={Shield} iconBg="bg-amber-500/15 text-amber-600" cardBg="bg-sky-50"
            title="Gait Analysis"
            label={gait.label} labelColor={gait.color}
            onClick={() => setOpenModal("gait")}
          />
          <HealthCard
            icon={Droplets} iconBg="bg-teal-500/15 text-teal-600" cardBg="bg-sky-50"
            title="Hydration"
            label={hydration.label} labelColor={hydration.color}
            onClick={() => setOpenModal("hydration")}
          />
          <HealthCard
            icon={Pill} iconBg="bg-blue-500/15 text-blue-600" cardBg="bg-sky-50"
            title="Medication"
            label="Active Rx" labelColor="text-blue-600"
            onClick={() => setOpenModal("medication")}
          />
          <HealthCard
            icon={Calendar} iconBg="bg-violet-500/15 text-violet-600" cardBg="bg-sky-50"
            title="Appointments"
            label="Upcoming" labelColor="text-violet-600"
            onClick={() => setOpenModal("appointments")}
          />
        </div>

      </main>

      {/* ── Detail modal ──────────────────────────────────────────────── */}
      <Dialog open={openModal !== null} onOpenChange={() => setOpenModal(null)}>
        <DialogContent className="sm:max-w-3xl max-h-[85vh] overflow-y-auto">
          {/* Title is visually hidden — each modal's own card header serves as the visible title */}
          <DialogHeader className="sr-only">
            <DialogTitle>{openModal ? modalTitle[openModal] : ""}</DialogTitle>
          </DialogHeader>
          {renderModalContent()}
        </DialogContent>
      </Dialog>
      {/* ── Share Report Modal ────────────────────────────────────────── */}
      <Dialog open={shareModalOpen} onOpenChange={setShareModalOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Generate Family Report</DialogTitle>
            <p className="text-sm text-muted-foreground">Select which data points to include in the shared summary.</p>
          </DialogHeader>
          
          <div className="space-y-6 py-4">
            {/* 9 Tickboxes Grid */}
            <div className="grid grid-cols-2 gap-3">
              {Object.keys(selectedData).map((key) => (
                <div key={key} className="flex items-center space-x-2">
                  <button 
                    onClick={() => setSelectedData(prev => ({ ...prev, [key]: !prev[key] }))}
                    className="flex items-center gap-2 text-sm font-medium"
                  >
                    {selectedData[key] ? (
                      <CheckSquare className="h-5 w-5 text-emerald-600" />
                    ) : (
                      <Square className="h-5 w-5 text-muted-foreground" />
                    )}
                    <span className="capitalize">{key === 'nutrition' ? 'Nutrition' : key}</span>
                  </button>
                </div>
              ))}
            </div>

            {/* Description Box */}
            <div className="space-y-2">
              <label className="text-sm font-semibold">Notes / Highlights</label>
              <textarea
                className="w-full min-h-[100px] rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                placeholder={`e.g., ${first_name} had a great week, but we are keeping an eye on his steps...`}
                value={shareDescription}
                onChange={(e) => setShareDescription(e.target.value)}
              />
            </div>

            <Button 
              className="w-full bg-emerald-600 hover:bg-emerald-700 text-white" 
              onClick={handleGenerateReport}
              disabled={isGenerating}
            >
              {isGenerating ? "Generating..." : "Generate & Share Report"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

    </div>
  );
};

export default FamilyView;
