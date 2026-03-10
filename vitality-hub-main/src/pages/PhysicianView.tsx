import { useEffect, useState } from "react";
import {
  Stethoscope, User, Calendar, Hash, MapPin, Activity, Brain,
  ChevronRight, ArrowLeft,
  Heart, Moon, Utensils, Footprints, Shield, Droplets, Pill,
  ShieldCheck, AlertCircle, AlertTriangle, Maximize2,
} from "lucide-react";
import { Header } from "@/components/Header";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Skeleton } from "@/components/ui/skeleton";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { HeartRateChart } from "@/components/HeartRateChart";
import { SleepChart } from "@/components/SleepChart";
import { WalkingActivityChart } from "@/components/WalkingActivityChart";
import { SmartFridgeCard } from "@/components/SmartFridgeCard";
import { ECGVisualization } from "@/components/ECGVisualization";
import { HydrationIndicator } from "@/components/HydrationIndicator";
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid,
  Tooltip, ReferenceLine, ResponsiveContainer,
} from "recharts";

const API_BASE = "http://localhost:3001";
const PATIENT_ID = "PATIENT_001";

// ── Type definitions ───────────────────────────────────────────────────────────
type FhirPatient = { id: string; name: string; birthDate: string; gender: string; mrn: string | null; address: { line?: string[]; city?: string; state?: string } };
type Condition   = { display: string; code: string; status: string; onset: string };
type Medication  = { drug: string; status: string; authored: string; dosage: string };
type Observation = { display: string; value: number | null; unit: string; date: string };
type BpPoint     = { date: string; systolic: number; diastolic: number };
type Vitals      = { heartRate: number; steps: number; stressLevel: number; sleepHours: number };

// ── Date / age helpers ────────────────────────────────────────────────────────
function fmt(dateStr: string) {
  if (!dateStr) return "—";
  try { return new Date(dateStr).toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" }); }
  catch { return dateStr; }
}

function fmtYear(dateStr: string) {
  if (!dateStr) return "";
  try { return new Date(dateStr).toLocaleDateString("en-US", { year: "numeric", month: "short" }); }
  catch { return dateStr; }
}

function calcAge(birthDate: string) {
  return Math.floor((Date.now() - new Date(birthDate).getTime()) / (1000 * 60 * 60 * 24 * 365.25));
}

// ── Garmin data helpers ───────────────────────────────────────────────────────
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

// ── Status helpers ────────────────────────────────────────────────────────────
function sleepStatus(h: number) {
  if (h === 0)  return { label: "No data",     note: "Sleep data unavailable",                       color: "text-muted-foreground", status: "fair" as const };
  if (h >= 7)   return { label: "Well rested", note: `${h.toFixed(1)} hrs — great for their age`,    color: "text-emerald-600",       status: "good" as const };
  if (h >= 5.5) return { label: "Light sleep", note: `${h.toFixed(1)} hrs — a bit below ideal`,      color: "text-amber-600",         status: "fair" as const };
  return         { label: "Poor sleep",   note: `Only ${h.toFixed(1)} hrs — worth checking in`, color: "text-rose-600",          status: "warn" as const };
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
  return             { label: "Very little movement", note: `${steps.toLocaleString()} steps — may want to check in`, color: "text-rose-600",          status: "warn" as const };
}

function stressStatus(v: number) {
  if (v === 0)  return { label: "Calm",        note: "Stress levels look great",       color: "text-emerald-600", status: "good" as const };
  if (v <= 35)  return { label: "Calm",        note: "Very relaxed today",             color: "text-emerald-600", status: "good" as const };
  if (v <= 60)  return { label: "Mild stress", note: "Some stress — likely normal",    color: "text-amber-600",   status: "fair" as const };
  return        { label: "High stress",  note: "Elevated stress — worth a call", color: "text-rose-600",    status: "warn" as const };
}

function gaitStatus(symmetryPct: number, variabilityPct: number, speedMs: number, cadence: number, worseStride: number, worseGCT: number) {
  if (symmetryPct === 0) return { label: "No data",     note: "Gait data unavailable",                color: "text-muted-foreground", status: "fair" as const };
  const isHigh = cadence < 80  || speedMs < 0.7  || worseStride < 90  || worseGCT > 950 || symmetryPct < 78  || variabilityPct > 10;
  const isMed  = cadence < 100 || speedMs < 1.0  || worseStride < 140 || worseGCT > 650 || symmetryPct < 95  || variabilityPct > 5;
  if (isHigh) return { label: "High Risk",     note: "Significant gait irregularities detected", color: "text-rose-600",    status: "warn" as const };
  if (isMed)  return { label: "Moderate Risk", note: "Some asymmetry — worth monitoring",        color: "text-amber-600",   status: "fair" as const };
  return       { label: "Low Risk",            note: "Gait looks steady and balanced",           color: "text-emerald-600", status: "good" as const };
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

function overallStatus(v: Vitals) {
  const s = [sleepStatus(v.sleepHours).status, heartStatus(v.heartRate).status, stepsStatus(v.steps).status, stressStatus(v.stressLevel).status];
  if (s.includes("warn")) return "warn";
  if (s.includes("fair")) return "fair";
  return "good";
}

// ── FHIR helpers (patient header quick stats) ──────────────────────────────────
function bpColor(systolic: number) {
  if (systolic < 120) return "#16a34a";
  if (systolic < 130) return "#ca8a04";
  if (systolic < 140) return "#ea580c";
  return "#dc2626";
}

function bmiCategory(bmi: number) {
  if (bmi < 18.5) return { label: "Underweight", color: "#fb923c" };
  if (bmi < 25)   return { label: "Normal",      color: "#16a34a" };
  if (bmi < 30)   return { label: "Overweight",  color: "#ca8a04" };
  return               { label: "Obese",         color: "#dc2626" };
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
  icon: React.ElementType;
  iconBg: string;
  title: string;
  label: string;
  labelColor: string;
  note: string;
  onClick: () => void;
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
type Med = { drug: string; status: string; authored: string; dosage: string };

function MedicationDetail({ patientId }: { patientId: string }) {
  const [meds, setMeds] = useState<Med[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setLoading(true);
    setError(null);
    (async () => {
      try {
        const res = await fetch(`${API_BASE}/api/fhir/medications?patient_id=${encodeURIComponent(patientId)}`);
        if (!res.ok) throw new Error("Medication fetch failed");
        const data: Med[] = await res.json();
        setMeds(Array.isArray(data) ? data : []);
      } catch (e: any) {
        setError(e?.message ?? "Failed to load medications");
      } finally {
        setLoading(false);
      }
    })();
  }, [patientId]);

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

// ── PhysicianTopBar ───────────────────────────────────────────────────────────
function PhysicianTopBar({ onBack }: { onBack?: () => void }) {
  return (
    <div className="border-b border-border bg-card/40">
      <div className="container mx-auto flex items-center gap-3 px-4 py-4 sm:px-6">
        {onBack && (
          <>
            <button
              onClick={onBack}
              className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              <ArrowLeft className="h-4 w-4" />
              Patient List
            </button>
            <span className="text-muted-foreground">/</span>
          </>
        )}
        <div className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-100">
            <Stethoscope className="h-4 w-4 text-blue-600" />
          </div>
          <span className="rounded-full bg-blue-100 px-3 py-1 text-body-sm font-medium text-blue-700">
            Physician View
          </span>
        </div>
      </div>
    </div>
  );
}

// ── PatientBanner ─────────────────────────────────────────────────────────────
function PatientBanner({ patient, onClick }: { patient: FhirPatient; onClick: () => void }) {
  const age = patient.birthDate ? calcAge(patient.birthDate) : null;
  const initials = patient.name.split(" ").map(n => n[0]).join("").slice(0, 2).toUpperCase();
  return (
    <Card
      className="cursor-pointer hover:shadow-md transition-shadow border-l-4 border-l-blue-400"
      onClick={onClick}
    >
      <CardContent className="p-4">
        <div className="flex items-center gap-4">
          <div className="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 text-base font-bold text-blue-700">
            {initials}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-3 flex-wrap">
              <span className="text-base font-semibold text-foreground">{patient.name}</span>
              {patient.gender && (
                <span className="text-sm text-muted-foreground">
                  <User className="inline h-3.5 w-3.5 mr-0.5" />
                  {patient.gender.charAt(0).toUpperCase() + patient.gender.slice(1)}
                  {age !== null ? `, ${age} yrs` : ""}
                </span>
              )}
            </div>
            <div className="mt-1 flex flex-wrap gap-x-4 gap-y-0.5 text-xs text-muted-foreground">
              {patient.birthDate && (
                <span className="flex items-center gap-1">
                  <Calendar className="h-3 w-3" />
                  DOB: {fmt(patient.birthDate)}
                </span>
              )}
              {patient.mrn && (
                <span className="flex items-center gap-1">
                  <Hash className="h-3 w-3" />
                  MRN: {patient.mrn}
                </span>
              )}
              {patient.address?.city && (
                <span className="flex items-center gap-1">
                  <MapPin className="h-3 w-3" />
                  {[patient.address.city, patient.address.state].filter(Boolean).join(", ")}
                </span>
              )}
            </div>
          </div>
          <ChevronRight className="h-5 w-5 text-muted-foreground flex-shrink-0" />
        </div>
      </CardContent>
    </Card>
  );
}

// ── Main component ────────────────────────────────────────────────────────────
const PhysicianView = () => {
  // ── Patient list ─────────────────────────────────────────────────────────
  const [patients, setPatients] = useState<FhirPatient[]>([]);
  const [listLoading, setListLoading] = useState(true);
  const [listError, setListError] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(null);

  useEffect(() => {
    fetch(`${API_BASE}/api/fhir/patients`)
      .then(r => { if (!r.ok) throw new Error("Failed to load patients"); return r.json(); })
      .then(data => {
        const pts: FhirPatient[] = Array.isArray(data) ? data : [];
        pts.sort((a, b) => (a.name.split(" ").pop() ?? "").localeCompare(b.name.split(" ").pop() ?? ""));
        setPatients(pts);
      })
      .catch(e => setListError(e.message))
      .finally(() => setListLoading(false));
  }, []);

  // ── FHIR patient detail ───────────────────────────────────────────────────
  const [patient, setPatient]         = useState<FhirPatient | null>(null);
  const [conditions, setConditions]   = useState<Condition[]>([]);
  const [medications, setMedications] = useState<Medication[]>([]);
  const [vitalObs, setVitalObs]       = useState<Observation[]>([]);
  const [bpTrend, setBpTrend]         = useState<BpPoint[]>([]);
  const [detailLoading, setDetailLoading] = useState(false);
  const [detailError, setDetailError]     = useState("");

  // ── Garmin / wearable ─────────────────────────────────────────────────────
  const [vitals, setVitals]           = useState<Vitals>({ heartRate: 0, steps: 0, stressLevel: 0, sleepHours: 0 });
  const [stepHistory, setStepHistory] = useState<{ day: string; steps: number }[]>([]);
  const [hydrationLevel, setHydrationLevel] = useState(0);
  const [gaitMetrics, setGaitMetrics] = useState({ symmetry: 0, variability: 0, speed: 0, cadence: 0, worseStride: 0, worseGCT: 0 });
  const [openModal, setOpenModal]     = useState<string | null>(null);

  useEffect(() => {
    if (!selectedId) return;
    setPatient(patients.find(p => p.id === selectedId) ?? null);
    setDetailLoading(true);
    setDetailError("");
    (async () => {
      try {
        const [cond, meds, vit, bp, dailyRes, sleepRes, toiletRes, gaitRes] = await Promise.all([
          fetch(`${API_BASE}/api/fhir/conditions?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/medications?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/vitals?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/bp-trend?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/dailySummary?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/sleep?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/toilet?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/gait?patient_id=${encodeURIComponent(PATIENT_ID)}`),
        ]);

        setConditions(Array.isArray(cond) ? cond : []);
        setMedications(Array.isArray(meds) ? meds : []);
        setVitalObs(Array.isArray(vit) ? vit : []);
        setBpTrend(Array.isArray(bp) ? bp : []);

        // Garmin data
        const dailyJson = dailyRes.ok ? await dailyRes.json() : [];
        const sleepJson = sleepRes.ok ? await sleepRes.json() : [];
        const toiletJson: any[] = toiletRes.ok ? await toiletRes.json() : [];
        const gaitJson: any[]   = gaitRes.ok  ? await gaitRes.json()  : [];

        const latestGait = [...gaitJson]
          .filter((d: any) => d?.calendarDate)
          .sort((a: any, b: any) => String(b.calendarDate).localeCompare(String(a.calendarDate)))[0];
        if (latestGait?.sessions?.length) {
          const s = latestGait.sessions[latestGait.sessions.length - 1];
          const worseStride = Math.min(Number(s.strideLength?.leftCm ?? 999), Number(s.strideLength?.rightCm ?? 999));
          const worseGCT    = Math.max(Number(s.groundContactTimeMs?.left ?? 0), Number(s.groundContactTimeMs?.right ?? 0));
          setGaitMetrics({ symmetry: Number(s.stepSymmetryPct ?? 0), variability: Number(s.strideVariabilityPct ?? 0), speed: Number(s.gaitSpeedMs ?? 0), cadence: Number(s.cadence ?? 0), worseStride, worseGCT });
        }

        const latestToilet = [...toiletJson]
          .filter((d: any) => d?.calendarDate)
          .sort((a: any, b: any) => String(b.calendarDate).localeCompare(String(a.calendarDate)))[0];
        const lastReading = latestToilet?.readings?.at(-1);
        if (lastReading?.colorLevel) setHydrationLevel(Math.min(8, Math.max(1, Number(lastReading.colorLevel))));

        const allDays = (Array.isArray(dailyJson) ? dailyJson : [])
          .filter((d: any) => d?.calendarDate)
          .sort((a: any, b: any) => a.calendarDate.localeCompare(b.calendarDate));

        setStepHistory(
          allDays.filter((d: any) => d?.totalSteps != null).slice(-14).map((d: any) => ({
            day: new Date(d.calendarDate + "T12:00:00").toLocaleDateString("en-US", { month: "numeric", day: "numeric" }),
            steps: Number(d.totalSteps),
          }))
        );

        const day = allDays[allDays.length - 1] ?? null;
        setVitals({
          heartRate:   Number(day?.currentDayRestingHeartRate ?? day?.restingHeartRate ?? 0),
          steps:       Number(day?.totalSteps ?? 0),
          stressLevel: extractStress(day),
          sleepHours:  extractSleep(sleepJson),
        });
      } catch (e: any) {
        setDetailError(e.message || "Failed to load patient data");
      } finally {
        setDetailLoading(false);
      }
    })();
  }, [selectedId]);

  // ── Derived FHIR values (patient header quick stats) ─────────────────────
  const age = patient?.birthDate ? calcAge(patient.birthDate) : null;

  const bmiObs = vitalObs
    .filter(v => v.display.toLowerCase().includes("bmi") || v.display.toLowerCase().includes("mass index"))
    .sort((a, b) => a.date.localeCompare(b.date));

  const bpChartData = bpTrend
    .map(p => ({ ...p, date: fmtYear(p.date), rawDate: p.date }))
    .sort((a, b) => a.rawDate.localeCompare(b.rawDate));

  const latestBmi = bmiObs[bmiObs.length - 1];
  const latestBp  = bpChartData[bpChartData.length - 1];

  // ── Derived garmin status values ──────────────────────────────────────────
  const sleep     = sleepStatus(vitals.sleepHours);
  const heart     = heartStatus(vitals.heartRate);
  const steps     = stepsStatus(vitals.steps);
  const stress    = stressStatus(vitals.stressLevel);
  const hydration = hydrationStatus(hydrationLevel);
  const gait      = gaitStatus(gaitMetrics.symmetry, gaitMetrics.variability, gaitMetrics.speed, gaitMetrics.cadence, gaitMetrics.worseStride, gaitMetrics.worseGCT);
  const overall   = overallStatus(vitals);

  const firstName = patient?.name?.split(" ")[0] ?? "Patient";

  const statusConfig = {
    good: {
      icon: ShieldCheck, gradient: "from-emerald-50 to-teal-50", border: "border-emerald-200",
      iconBg: "bg-emerald-500", text: "text-emerald-900", sub: "text-emerald-700",
      badge: "bg-emerald-100 text-emerald-700 border border-emerald-200",
      message: `${firstName} is doing well today`, sub2: "All vitals look healthy — no concerns to report.",
    },
    fair: {
      icon: AlertCircle, gradient: "from-amber-50 to-yellow-50", border: "border-amber-200",
      iconBg: "bg-amber-500", text: "text-amber-900", sub: "text-amber-700",
      badge: "bg-amber-100 text-amber-700 border border-amber-200",
      message: `${firstName} is generally okay`, sub2: "A few things are slightly off — worth keeping an eye on.",
    },
    warn: {
      icon: AlertTriangle, gradient: "from-rose-50 to-red-50", border: "border-rose-200",
      iconBg: "bg-rose-500", text: "text-rose-900", sub: "text-rose-700",
      badge: "bg-rose-100 text-rose-700 border border-rose-200",
      message: `${firstName} may need your attention`, sub2: "Some vitals are outside the normal range — consider checking in.",
    },
  }[overall];

  const StatusIcon = statusConfig.icon;

  const highlights: string[] = [];
  if (vitals.sleepHours > 0) highlights.push(sleep.status === "good"
    ? `Slept ${vitals.sleepHours.toFixed(1)} hours — well rested.`
    : `Only slept ${vitals.sleepHours.toFixed(1)} hours last night.`);
  if (vitals.steps > 0) highlights.push(steps.status === "good"
    ? `Active with ${vitals.steps.toLocaleString()} steps today.`
    : `Logged ${vitals.steps.toLocaleString()} steps — a lighter day.`);
  if (vitals.heartRate > 0) highlights.push(`Resting heart rate is ${vitals.heartRate} BPM — ${heart.label.toLowerCase()}.`);
  highlights.push(stress.status === "good" ? "Stress levels look calm." : `Stress seems ${stress.label.toLowerCase()} today.`);

  const stressBarColor = stress.status === "good" ? "bg-emerald-500" : stress.status === "fair" ? "bg-amber-500" : "bg-rose-500";

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
            title="Steps Today" subtitle={steps.note}>
            <div className="space-y-5">
              <div className="flex items-end justify-between">
                <div>
                  <p className={`text-4xl font-bold ${steps.color}`}>{vitals.steps > 0 ? vitals.steps.toLocaleString() : "—"}</p>
                  <p className="mt-0.5 text-sm text-muted-foreground">{steps.label} today</p>
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
                          <linearGradient id="stepsGradientPhy" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stopColor="hsl(var(--ecg))" stopOpacity={0.35} />
                            <stop offset="100%" stopColor="hsl(var(--ecg))" stopOpacity={0} />
                          </linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
                        <XAxis dataKey="day" tick={{ fontSize: 11, fill: "hsl(215,16%,50%)" }} axisLine={false} tickLine={false} />
                        <YAxis tick={{ fontSize: 11, fill: "hsl(215,16%,50%)" }} axisLine={false} tickLine={false} />
                        <Tooltip contentStyle={{ fontSize: 12, borderRadius: 8, border: "1px solid hsl(var(--border))" }} formatter={(v: number) => [v.toLocaleString(), "Steps"]} />
                        <ReferenceLine y={5000} stroke="hsl(var(--success))" strokeDasharray="4 4" label={{ value: "Goal 5k", fontSize: 9, fill: "hsl(var(--success))", position: "right" }} />
                        <Area type="monotone" dataKey="steps" stroke="hsl(var(--ecg))" strokeWidth={2.5} fill="url(#stepsGradientPhy)" dot={{ r: 3, fill: "hsl(var(--ecg))", strokeWidth: 0 }} isAnimationActive={false} />
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
            <MedicationDetail patientId={selectedId!} />
          </ModalCard>
        );
      default:
        return null;
    }
  };

  const modalTitle: Record<string, string> = {
    heart: "Heart Health", sleep: "Sleep Analysis", nutrition: "Nutrition & Diet",
    stress: "Stress", steps: "Steps Today", gait: "Gait Analysis",
    hydration: "Hydration", medication: "Medications",
  };

  function handleBack() {
    setSelectedId(null);
    setPatient(null);
    setConditions([]);
    setMedications([]);
    setVitalObs([]);
    setBpTrend([]);
    setVitals({ heartRate: 0, steps: 0, stressLevel: 0, sleepHours: 0 });
    setStepHistory([]);
    setHydrationLevel(0);
    setGaitMetrics({ symmetry: 0, variability: 0, speed: 0, cadence: 0, worseStride: 0, worseGCT: 0 });
    setOpenModal(null);
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Patient list view
  // ════════════════════════════════════════════════════════════════════════
  if (!selectedId) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <PhysicianTopBar />
        <main className="container mx-auto px-4 py-6 sm:px-6">
          <div className="mb-5">
            <h2 className="text-xl font-semibold text-foreground">Patient Registry</h2>
            <p className="text-sm text-muted-foreground mt-0.5">Select a patient to view their health overview</p>
          </div>
          {listLoading ? (
            <div className="space-y-3">{Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-[72px] w-full rounded-xl" />)}</div>
          ) : listError ? (
            <p className="text-sm text-destructive">{listError} — ensure the FHIR server is running and patient data is loaded.</p>
          ) : patients.length === 0 ? (
            <p className="text-sm text-muted-foreground">No patients found in FHIR server.</p>
          ) : (
            <div className="space-y-3">
              {patients.map(p => <PatientBanner key={p.id} patient={p} onClick={() => setSelectedId(p.id)} />)}
            </div>
          )}
        </main>
      </div>
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Patient detail view
  // ════════════════════════════════════════════════════════════════════════
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <PhysicianTopBar onBack={handleBack} />

      <main className="container mx-auto px-4 py-6 sm:px-6">

        {/* ── Patient header card ── */}
        <Card className="mb-6 shadow-card">
          <CardContent className="p-6">
            {detailLoading && !patient ? (
              <div className="flex items-center gap-4">
                <Skeleton className="h-16 w-16 rounded-full" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-6 w-48" />
                  <Skeleton className="h-4 w-72" />
                </div>
              </div>
            ) : detailError ? (
              <p className="text-sm text-destructive">{detailError}</p>
            ) : patient ? (
              <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                <div className="flex h-16 w-16 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 text-xl font-bold text-blue-700">
                  {patient.name.split(" ").map(n => n[0]).join("").slice(0, 2).toUpperCase()}
                </div>
                <div className="flex-1 min-w-0">
                  <h2 className="text-2xl font-display font-bold text-foreground">{patient.name}</h2>
                  <div className="mt-1 flex flex-wrap gap-x-5 gap-y-1 text-body-sm text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <User className="h-3.5 w-3.5" />
                      {patient.gender ? patient.gender.charAt(0).toUpperCase() + patient.gender.slice(1) : "—"}
                      {age !== null ? `, ${age} yrs` : ""}
                    </span>
                    <span className="flex items-center gap-1">
                      <Calendar className="h-3.5 w-3.5" />
                      DOB: {fmt(patient.birthDate)}
                    </span>
                    {patient.mrn && (
                      <span className="flex items-center gap-1">
                        <Hash className="h-3.5 w-3.5" />
                        MRN: {patient.mrn}
                      </span>
                    )}
                    {patient.address?.city && (
                      <span className="flex items-center gap-1">
                        <MapPin className="h-3.5 w-3.5" />
                        {[patient.address.city, patient.address.state].filter(Boolean).join(", ")}
                      </span>
                    )}
                  </div>
                </div>
                {/* Quick stat pills */}
                <div className="flex gap-3 flex-wrap sm:flex-nowrap">
                  {latestBp && (
                    <div className="rounded-xl border px-4 py-2 text-center min-w-[100px]">
                      <div className="text-xs text-muted-foreground mb-0.5">Blood Pressure</div>
                      <div className="text-lg font-bold" style={{ color: bpColor(latestBp.systolic) }}>{latestBp.systolic}/{latestBp.diastolic}</div>
                      <div className="text-xs text-muted-foreground">mmHg</div>
                    </div>
                  )}
                  {latestBmi && (
                    <div className="rounded-xl border px-4 py-2 text-center min-w-[100px]">
                      <div className="text-xs text-muted-foreground mb-0.5">BMI</div>
                      <div className="text-lg font-bold" style={{ color: bmiCategory(latestBmi.value ?? 0).color }}>{latestBmi.value}</div>
                      <div className="text-xs text-muted-foreground">{bmiCategory(latestBmi.value ?? 0).label}</div>
                    </div>
                  )}
                  <div className="rounded-xl border px-4 py-2 text-center min-w-[100px]">
                    <div className="text-xs text-muted-foreground mb-0.5">Active Conditions</div>
                    <div className="text-lg font-bold text-foreground">{conditions.filter(c => c.status === "active").length}</div>
                    <div className="text-xs text-muted-foreground">problems</div>
                  </div>
                  <div className="rounded-xl border px-4 py-2 text-center min-w-[100px]">
                    <div className="text-xs text-muted-foreground mb-0.5">Medications</div>
                    <div className="text-lg font-bold text-foreground">{medications.filter(m => m.status === "active").length}</div>
                    <div className="text-xs text-muted-foreground">active Rx</div>
                  </div>
                </div>
              </div>
            ) : null}
          </CardContent>
        </Card>

        {/* ── Tabs ── */}
        <Tabs defaultValue="overview">
          <TabsList className="mb-6 h-auto">
            <TabsTrigger value="overview" className="flex items-center gap-1.5">
              <Activity className="h-3.5 w-3.5" />
              Health Overview
            </TabsTrigger>
            <TabsTrigger value="ai" className="flex items-center gap-1.5">
              <Brain className="h-3.5 w-3.5" />
              AI Summary
            </TabsTrigger>
          </TabsList>

          {/* ══ Tab 1 — Health Overview ══ */}
          <TabsContent value="overview" className="space-y-6">

            {/* Overall status banner */}
            <div className={`rounded-2xl border bg-gradient-to-r overflow-hidden shadow-card ${statusConfig.gradient} ${statusConfig.border}`}>
              <div className="flex items-start gap-4 p-5">
                <div className={`flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl shadow-sm ${statusConfig.iconBg}`}>
                  <StatusIcon className="h-5 w-5 text-white" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2 mb-1">
                    <h3 className={`text-base font-bold ${statusConfig.text}`}>{statusConfig.message}</h3>
                    <span className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${statusConfig.badge}`}>
                      {overall === "good" ? "All good" : overall === "fair" ? "Monitor" : "Attention needed"}
                    </span>
                  </div>
                  <p className={`text-sm ${statusConfig.sub}`}>{statusConfig.sub2}</p>
                  {highlights.length > 0 && (
                    <p className="mt-2 text-sm text-foreground/75 leading-relaxed">{highlights.join(" ")}</p>
                  )}
                </div>
              </div>
            </div>

            {/* Section label */}
            <div className="flex items-center gap-3">
              <span className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Health Overview</span>
              <div className="flex-1 h-px bg-border" />
              <span className="text-xs text-muted-foreground">Click any card for details</span>
            </div>

            {/* 8-card grid */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
              <HealthCard icon={Heart} iconBg="bg-heart/15 text-heart" title="Heart Health" label={heart.label} labelColor={heart.color} note={heart.note} onClick={() => setOpenModal("heart")} />
              <HealthCard icon={Moon} iconBg="bg-sleep/15 text-sleep" title="Sleep Analysis" label={sleep.label} labelColor={sleep.color} note={sleep.note} onClick={() => setOpenModal("sleep")} />
              <HealthCard icon={Utensils} iconBg="bg-teal-500/15 text-teal-600" title="Nutrition & Diet" label="Meals tracked" labelColor="text-teal-600" note="Smart fridge monitoring" onClick={() => setOpenModal("nutrition")} />
              <HealthCard icon={Brain} iconBg="bg-stress/15 text-stress" title="Stress" label={stress.label} labelColor={stress.color} note={stress.note} onClick={() => setOpenModal("stress")} />
              <HealthCard icon={Footprints} iconBg="bg-ecg/15 text-ecg" title="Steps Today" label={steps.label} labelColor={steps.color} note={steps.note} onClick={() => setOpenModal("steps")} />
              <HealthCard icon={Shield} iconBg="bg-amber-500/15 text-amber-600" title="Gait Analysis" label={gait.label} labelColor={gait.color} note={gait.note} onClick={() => setOpenModal("gait")} />
              <HealthCard icon={Droplets} iconBg="bg-teal-500/15 text-teal-600" title="Hydration" label={hydration.label} labelColor={hydration.color} note={hydration.note} onClick={() => setOpenModal("hydration")} />
              <HealthCard icon={Pill} iconBg="bg-blue-500/15 text-blue-600" title="Medication" label="Active Rx" labelColor="text-blue-600" note="Prescriptions & dosage" onClick={() => setOpenModal("medication")} />
            </div>

          </TabsContent>

          {/* ══ Tab 2 — AI Summary ══ */}
          <TabsContent value="ai">
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-24 text-center">
                <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-blue-50">
                  <Brain className="h-7 w-7 text-blue-400" />
                </div>
                <h3 className="text-lg font-semibold text-foreground mb-2">AI Clinical Summary</h3>
                <p className="text-sm text-muted-foreground max-w-sm">
                  Coming soon — AI-generated summaries of {patient?.name?.split(" ")[0] ?? "this patient"}'s clinical history, risk factors, and care recommendations.
                </p>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

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

export default PhysicianView;
