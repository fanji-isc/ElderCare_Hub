import { useState, useEffect } from "react";
import { HeartRateChart } from "@/components/HeartRateChart";
import { ECGVisualization } from "@/components/ECGVisualization";
import { SleepChart } from "@/components/SleepChart";
import { HydrationIndicator } from "@/components/HydrationIndicator";
import { WalkingActivityChart } from "@/components/WalkingActivityChart";
import { SmartFridgeCard } from "@/components/SmartFridgeCard";
import { Brain, Footprints, Pill, Calendar, CheckSquare, Square } from "lucide-react";
import {
  AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, ReferenceLine,
} from "recharts";

interface HealthModalProps {
  openModal: string | null;
  vitals: any;
  healthStatus: any;
  stepHistory: any[];
  showPrivacyFeatures: boolean; // Controls HippaShieldIcon and ApptActions
}

interface HealthCardProps {
  icon: React.ElementType;
  iconBg: string;
  title: string;
  label: string;
  labelColor: string;
  onClick: () => void;
  showShield?: boolean; // Add this prop
}

type Med = { drug: string; status: string; authored: string; dosage: string };
type Appt = { status: string; start: string; end: string; type: string; practitioner: string; location: string };

const first_name = "Frank";
const last_name = "Larson";

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
function ModalCard({ icon: Icon, iconBg, gradient, title, subtitle, children }: {
  icon: React.ElementType; iconBg: string; gradient: string; title: string; 
  subtitle?: string; children: React.ReactNode;
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
      </div>
      <div className="p-5">{children}</div>
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
        const res = await fetch(`/api/fhir/patient-medications?first_name=${first_name}&last_name=${last_name}`);
        if (!res.ok) throw new Error("Patient not found or server error");
        const data = await res.json();
        setMeds(data);
      } catch (e: any) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    };
    fetchMeds();
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
function AppointmentsDetail({ showActions }: { showActions: boolean }) {
  const [appts, setAppts] = useState<Appt[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [checked, setChecked] = useState<Record<string, boolean>>({});

  useEffect(() => {
    const fetchAppts = async () => {
      try {
        const res = await fetch(`/api/fhir/patient-appointments?first_name=${first_name}&last_name=${last_name}`);
        if (!res.ok) throw new Error("Patient not found or server error");
        const data: Appt[] = await res.json();
        setAppts(Array.isArray(data) ? data : []);
      } catch (e: any) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    };
    fetchAppts();
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
            {/* Only render the checklist for FamilyView */}
            {showActions && (
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
            )}
          </div>
        );
      })}
    </div>
  );
}

export const HealthModalContent = ({ openModal, vitals, healthStatus, stepHistory, showPrivacyFeatures }: HealthModalProps) => {
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
                title="Stress" subtitle={healthStatus.stress.note}>
                <div className="space-y-4 max-w-md">
                <div className="flex items-center justify-between">
                    <span className="text-sm text-muted-foreground">Score today</span>
                    <span className={`text-2xl font-bold ${healthStatus.stress.color}`}>
                    {vitals.stressLevel > 0 ? vitals.stressLevel : "—"}
                    <span className="text-sm font-normal text-muted-foreground"> / 100</span>
                    </span>
                </div>
                <div className="h-3 rounded-full bg-muted overflow-hidden">
                    <div className={`h-full rounded-full transition-all ${healthStatus.stress.barColor}`} style={{ width: `${vitals.stressLevel}%` }} />
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
        case "steps": {
            return (
            <ModalCard icon={Footprints} iconBg="bg-ecg" gradient="from-blue-50 to-sky-50"
                title="Steps Today" subtitle={healthStatus.steps.note}>
                <div className="space-y-5">
                <div className="flex items-end justify-between">
                    <div>
                    <p className={`text-4xl font-bold ${healthStatus.steps.color}`}>{vitals.steps > 0 ? vitals.steps.toLocaleString() : "—"}</p>
                    <p className="mt-0.5 text-sm text-muted-foreground">{healthStatus.steps.label} today</p>
                    </div>
                    {vitals.prevAvg > 0 && (
                    <div className={`text-right ${vitals.trendUp ? "text-emerald-600" : "text-rose-600"}`}>
                        <p className="text-xl font-bold">{vitals.trendUp ? "+" : ""}{vitals.trendPct}%</p>
                        <p className="text-xs text-muted-foreground">vs. recent avg</p>
                    </div>
                    )}
                </div>
                {stepHistory.length > 1 && (
                    <div className="grid grid-cols-3 gap-3 text-center">
                    <div className="rounded-xl bg-muted/40 p-3">
                        <p className="text-base font-bold text-foreground">{vitals.avgSteps}</p>
                        <p className="text-xs text-muted-foreground">Daily avg</p>
                    </div>
                    <div className="rounded-xl bg-muted/40 p-3">
                        <p className="text-base font-bold text-emerald-600">{vitals.maxSteps}</p>
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
                <AppointmentsDetail showActions={showPrivacyFeatures} />
            </ModalCard>
            );
        default:
            return null;
    }
};

export function HealthCard({ icon: Icon, iconBg, title, label, labelColor, onClick, showShield}: HealthCardProps) {
  return (
    <div
      onClick={onClick}
      className="rounded-2xl shadow-card overflow-hidden cursor-pointer group hover:shadow-lg transition-shadow px-5 py-6 flex flex-col justify-center bg-sky-50"
    >
      <div className="flex items-center gap-3 mb-4">
        <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${iconBg}`}>
          <Icon className="h-5 w-5" />
        </div>
        <span className="text-base font-semibold text-foreground flex-1">{title}</span>
        <span title="HIPAA Protected Health Information" className="flex-shrink-0">{showShield && <HipaaShieldIcon className="h-4 w-4" />}</span>
      </div>
      <p className={`text-sm font-medium leading-tight ${labelColor}`}>{label}</p>
    </div>
  );
}