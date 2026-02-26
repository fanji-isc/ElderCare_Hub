import { useEffect, useState } from "react";
import {
  Heart, Moon, Footprints, Activity,
  ShieldCheck, AlertCircle, AlertTriangle,
  Phone, Share2, Clock, TrendingUp, TrendingDown, Minus,
} from "lucide-react";
import { Header } from "@/components/Header";
import { HeartRateChart } from "@/components/HeartRateCharttest";
import { SleepChart } from "@/components/SleepChart";
import { WalkingActivityChart } from "@/components/WalkingActivityChart";
import { SmartFridgeCard } from "@/components/SmartFridgeCard";
import { ECGVisualization } from "@/components/ECGVisualization";
import { HydrationIndicator } from "@/components/HydrationIndicator";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

type Vitals = { heartRate: number; steps: number; stressLevel: number; sleepHours: number };

const API_BASE = "http://localhost:3001";
const PATIENT_ID = "PATIENT_001";

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

// ─── Plain-language interpretation helpers ────────────────────────────────────

function sleepStatus(h: number): { label: string; note: string; color: string; status: "good" | "fair" | "warn" } {
  if (h === 0) return { label: "No data", note: "Sleep data unavailable", color: "text-muted-foreground", status: "fair" };
  if (h >= 7) return { label: "Well rested", note: `${h.toFixed(1)} hrs — great for his age`, color: "text-emerald-600", status: "good" };
  if (h >= 5.5) return { label: "Light sleep", note: `${h.toFixed(1)} hrs — a bit below ideal`, color: "text-amber-600", status: "fair" };
  return { label: "Poor sleep", note: `Only ${h.toFixed(1)} hrs — worth checking in`, color: "text-rose-600", status: "warn" };
}

function heartStatus(bpm: number): { label: string; note: string; color: string; status: "good" | "fair" | "warn" } {
  if (bpm === 0) return { label: "No data", note: "Heart rate unavailable", color: "text-muted-foreground", status: "fair" };
  if (bpm >= 55 && bpm <= 85) return { label: "Normal range", note: `${bpm} BPM — healthy resting rate`, color: "text-emerald-600", status: "good" };
  if (bpm > 85 && bpm <= 100) return { label: "Slightly elevated", note: `${bpm} BPM — monitor if it persists`, color: "text-amber-600", status: "fair" };
  if (bpm < 55 && bpm > 0) return { label: "Slightly low", note: `${bpm} BPM — could be normal if athletic`, color: "text-amber-600", status: "fair" };
  return { label: "Check with doctor", note: `${bpm} BPM — outside normal range`, color: "text-rose-600", status: "warn" };
}

function stepsStatus(steps: number): { label: string; note: string; color: string; status: "good" | "fair" | "warn" } {
  if (steps === 0) return { label: "No data", note: "Activity data unavailable", color: "text-muted-foreground", status: "fair" };
  if (steps >= 5000) return { label: "Very active", note: `${steps.toLocaleString()} steps — excellent!`, color: "text-emerald-600", status: "good" };
  if (steps >= 2500) return { label: "Moderately active", note: `${steps.toLocaleString()} steps — good movement`, color: "text-emerald-600", status: "good" };
  if (steps >= 1000) return { label: "Light activity", note: `${steps.toLocaleString()} steps — quieter day`, color: "text-amber-600", status: "fair" };
  return { label: "Very little movement", note: `${steps.toLocaleString()} steps — may want to check in`, color: "text-rose-600", status: "warn" };
}

function stressStatus(v: number): { label: string; note: string; color: string; status: "good" | "fair" | "warn" } {
  if (v === 0) return { label: "Calm", note: "Stress levels look great", color: "text-emerald-600", status: "good" };
  if (v <= 35) return { label: "Calm", note: "Very relaxed today", color: "text-emerald-600", status: "good" };
  if (v <= 60) return { label: "Mild stress", note: "Some stress — likely normal", color: "text-amber-600", status: "fair" };
  return { label: "High stress", note: "Elevated stress — worth a call", color: "text-rose-600", status: "warn" };
}

function overallStatus(vitals: Vitals) {
  const statuses = [
    sleepStatus(vitals.sleepHours).status,
    heartStatus(vitals.heartRate).status,
    stepsStatus(vitals.steps).status,
    stressStatus(vitals.stressLevel).status,
  ];
  if (statuses.includes("warn")) return "warn";
  if (statuses.includes("fair")) return "fair";
  return "good";
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function InsightCard({
  icon: Icon, title, label, note, color, iconBg,
}: {
  icon: React.ElementType; title: string; label: string; note: string; color: string; iconBg: string;
}) {
  return (
    <div className="rounded-2xl bg-card p-5 shadow-card">
      <div className="mb-3 flex items-center gap-3">
        <div className={`flex h-10 w-10 items-center justify-center rounded-xl ${iconBg}`}>
          <Icon className="h-5 w-5" />
        </div>
        <span className="text-body-sm font-medium text-muted-foreground">{title}</span>
      </div>
      <p className={`text-xl font-bold ${color}`}>{label}</p>
      <p className="mt-1 text-body-sm text-muted-foreground">{note}</p>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

const FamilyView = () => {
  const [vitals, setVitals] = useState<Vitals>({ heartRate: 0, steps: 0, stressLevel: 0, sleepHours: 0 });
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const [dailyRes, sleepRes] = await Promise.all([
          fetch(`${API_BASE}/api/dailySummary?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/sleep?patient_id=${encodeURIComponent(PATIENT_ID)}`),
        ]);
        const dailyJson = dailyRes.ok ? await dailyRes.json() : [];
        const sleepJson = sleepRes.ok ? await sleepRes.json() : [];
        const day = pickLatest(Array.isArray(dailyJson) ? dailyJson : []);
        setVitals({
          heartRate: Number(day?.currentDayRestingHeartRate ?? day?.restingHeartRate ?? 0),
          steps: Number(day?.totalSteps ?? 0),
          stressLevel: extractStress(day),
          sleepHours: extractSleep(sleepJson),
        });
      } catch { /* silent */ }
      finally { setLoaded(true); }
    })();
  }, []);

  const sleep  = sleepStatus(vitals.sleepHours);
  const heart  = heartStatus(vitals.heartRate);
  const steps  = stepsStatus(vitals.steps);
  const stress = stressStatus(vitals.stressLevel);
  const overall = loaded ? overallStatus(vitals) : "good";

  const statusConfig = {
    good: {
      icon: ShieldCheck,
      bg: "from-emerald-50 to-teal-50 border-emerald-200",
      iconBg: "bg-emerald-500",
      text: "text-emerald-800",
      sub: "text-emerald-600",
      badge: "bg-emerald-100 text-emerald-700",
      message: "Frank is doing well today",
      sub2: "All vitals look healthy — no concerns to report.",
    },
    fair: {
      icon: AlertCircle,
      bg: "from-amber-50 to-yellow-50 border-amber-200",
      iconBg: "bg-amber-500",
      text: "text-amber-800",
      sub: "text-amber-600",
      badge: "bg-amber-100 text-amber-700",
      message: "Frank is generally okay",
      sub2: "A few things are slightly off — worth keeping an eye on.",
    },
    warn: {
      icon: AlertTriangle,
      bg: "from-rose-50 to-red-50 border-rose-200",
      iconBg: "bg-rose-500",
      text: "text-rose-800",
      sub: "text-rose-600",
      badge: "bg-rose-100 text-rose-700",
      message: "Frank may need your attention",
      sub2: "Some vitals are outside the normal range — consider checking in.",
    },
  }[overall];

  const StatusIcon = statusConfig.icon;

  // Build a natural-language summary paragraph
  const highlights: string[] = [];
  if (vitals.sleepHours > 0) highlights.push(sleep.status === "good" ? `He slept ${vitals.sleepHours.toFixed(1)} hours — well rested.` : `He only slept ${vitals.sleepHours.toFixed(1)} hours last night.`);
  if (vitals.steps > 0) highlights.push(steps.status === "good" ? `He's been active with ${vitals.steps.toLocaleString()} steps today.` : `He logged ${vitals.steps.toLocaleString()} steps today — a lighter day.`);
  if (vitals.heartRate > 0) highlights.push(`Resting heart rate is ${vitals.heartRate} BPM — ${heart.label.toLowerCase()}.`);
  highlights.push(stress.status === "good" ? "Stress levels look calm." : `Stress seems ${stress.label.toLowerCase()} today.`);

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="container mx-auto px-4 py-8 sm:px-6">

        {/* ── Page header ──────────────────────────────────────────── */}
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-display-sm font-display font-semibold text-foreground">
              Frank's Health Summary
            </h2>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm" onClick={() => toast.info("Calling Frank…")}>
              <Phone className="mr-1.5 h-4 w-4" />
              Call Frank
            </Button>
            <Button size="sm" onClick={() => toast.info("Opening share options…")}>
              <Share2 className="mr-1.5 h-4 w-4" />
              Share Report
            </Button>
          </div>
        </div>

        {/* ── Overall status banner ─────────────────────────────────── */}
        <div className={`mb-8 flex items-start gap-5 rounded-2xl border bg-gradient-to-br p-6 shadow-card ${statusConfig.bg}`}>
          <div className={`flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-2xl shadow-sm ${statusConfig.iconBg}`}>
            <StatusIcon className="h-7 w-7 text-white" />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <h3 className={`text-2xl font-display font-bold ${statusConfig.text}`}>
                {statusConfig.message}
              </h3>
              <span className={`rounded-full px-3 py-0.5 text-body-sm font-medium ${statusConfig.badge}`}>
                {overall === "good" ? "All good" : overall === "fair" ? "Monitor" : "Attention needed"}
              </span>
            </div>
            <p className={`mt-1 text-body ${statusConfig.sub}`}>{statusConfig.sub2}</p>
            {highlights.length > 0 && (
              <p className="mt-3 text-body text-foreground/80 leading-relaxed">
                {highlights.join(" ")}
              </p>
            )}
          </div>
          <div className="hidden flex-shrink-0 items-center gap-1.5 text-caption text-muted-foreground sm:flex">
            <Clock className="h-3.5 w-3.5" />
            Updated today
          </div>
        </div>

        {/* ── Four insight cards ────────────────────────────────────── */}
        <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <InsightCard
            icon={Moon} title="Sleep Last Night"
            label={sleep.label} note={sleep.note}
            color={sleep.color} iconBg="bg-sleep/10 text-sleep"
          />
          <InsightCard
            icon={Heart} title="Resting Heart Rate"
            label={heart.label} note={heart.note}
            color={heart.color} iconBg="bg-heart/10 text-heart"
          />
          <InsightCard
            icon={Footprints} title="Steps Today"
            label={steps.label} note={steps.note}
            color={steps.color} iconBg="bg-ecg/10 text-ecg"
          />
          <InsightCard
            icon={Activity} title="Stress Level"
            label={stress.label} note={stress.note}
            color={stress.color} iconBg="bg-stress/10 text-stress"
          />
        </div>

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

      </main>
    </div>
  );
};

export default FamilyView;
