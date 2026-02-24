import { useEffect, useState } from "react";
import { AlertTriangle, CheckCircle2, Footprints } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, ReferenceLine, ResponsiveContainer, Legend,
} from "recharts";

// ── Types ─────────────────────────────────────────────────────────────────────
type RiskLevel = "low" | "medium" | "high";
interface Pattern { name: string; level: RiskLevel; detail: string }
interface Metric  { label: string; value: string; normal: string; level: RiskLevel }

interface GaitSession {
  startTime: string;
  cadence: number;
  gaitSpeedMs: number;
  strideLength: { leftCm: number; rightCm: number };
  groundContactTimeMs: { left: number; right: number };
  strideVariabilityPct: number;
  stepSymmetryPct: number;
}
interface GaitDay { calendarDate: string; sessions: GaitSession[] }

// ── Risk thresholds (clinical gait standards for elderly) ─────────────────────
// Sources: Studenski et al. JAMA 2011 (speed); Hausdorff et al. J Appl Physiol 1997 (variability);
// Fritz & Lusardi J Geriatr Phys Ther 2009 (cadence/speed); approximate for stride/GCT/symmetry.
const riskCadence     = (v: number): RiskLevel => v < 80  ? "high" : v < 100 ? "medium" : "low";
const riskSpeed       = (v: number): RiskLevel => v < 0.7 ? "high" : v < 1.0 ? "medium" : "low";
const riskStride      = (v: number): RiskLevel => v < 90  ? "high" : v < 140 ? "medium" : "low";
const riskGCT         = (v: number): RiskLevel => v > 950 ? "high" : v > 650 ? "medium" : "low";
const riskSymmetry    = (v: number): RiskLevel => v < 78  ? "high" : v < 95  ? "medium" : "low";
const riskVariability = (v: number): RiskLevel => v > 10  ? "high" : v > 5   ? "medium" : "low";

function overallLevel(levels: RiskLevel[]): RiskLevel {
  if (levels.includes("high"))   return "high";
  if (levels.includes("medium")) return "medium";
  return "low";
}

// ── Format helpers ────────────────────────────────────────────────────────────
const fmtDate = (iso: string) =>
  new Date(iso).toLocaleDateString([], { month: "short", day: "numeric", year: "numeric" });
const fmtTime = (iso: string) =>
  new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
const sessionLabel = (iso: string) => {
  // Parse directly from string to avoid UTC↔local timezone shifts
  // Use compact "1/15a" / "1/15p" so all 16 labels fit without Recharts skipping
  const [datePart, timePart] = iso.split("T");
  const [, month, day] = datePart.split("-").map(Number);
  const hour = parseInt(timePart.split(":")[0], 10);
  return `${month}/${day} ${hour < 12 ? "AM" : "PM"}`;
};

// ── UI helpers ────────────────────────────────────────────────────────────────
const levelColor: Record<RiskLevel, string> = {
  low:    "text-success bg-success/10",
  medium: "text-warning bg-warning/10",
  high:   "text-destructive bg-destructive/10",
};
const levelDot: Record<RiskLevel, string> = {
  low: "bg-success", medium: "bg-warning", high: "bg-destructive",
};

function RiskIcon({ level }: { level: RiskLevel }) {
  return level === "low"
    ? <CheckCircle2 className="h-4 w-4" />
    : <AlertTriangle className="h-4 w-4" />;
}

// Metric bar: shows patient value as a dot on a scale with normal zone shaded
function MetricBar({ label, display, value, scale, normalRange, level, normalLabel }: {
  label: string; display: string; value: number;
  scale: [number, number]; normalRange: [number, number];
  level: RiskLevel; normalLabel: string;
}) {
  const [min, max] = scale;
  const [nMin, nMax] = normalRange;
  const range = max - min;
  const valuePct = Math.min(98, Math.max(2, ((value - min) / range) * 100));
  const nMinPct  = Math.min(99, Math.max(0, ((nMin - min) / range) * 100));
  const nMaxPct  = Math.min(100, Math.max(0, ((nMax - min) / range) * 100));

  const markerBg   = level === "high" ? "bg-destructive" : level === "medium" ? "bg-warning" : "bg-success";
  const valueColor = level === "high" ? "text-destructive" : level === "medium" ? "text-warning" : "text-success";

  return (
    <div className="space-y-1">
      <div className="flex items-baseline justify-between gap-2">
        <span className="text-body-sm font-medium text-foreground">{label}</span>
        <span className={`text-body-sm font-bold tabular-nums shrink-0 ${valueColor}`}>{display}</span>
      </div>
      <div className="relative h-2.5 w-full rounded-full bg-muted/70">
        {/* Normal zone — green band */}
        <div
          className="absolute top-0 h-full bg-success/25 rounded-sm"
          style={{ left: `${nMinPct}%`, width: `${nMaxPct - nMinPct}%` }}
        />
        {/* Normal boundary line */}
        <div className="absolute top-0 h-full w-px bg-success/60" style={{ left: `${nMinPct}%` }} />
        {/* Value dot */}
        <div
          className={`absolute top-1/2 h-4 w-4 -translate-y-1/2 -translate-x-1/2 rounded-full border-2 border-background shadow-sm ${markerBg}`}
          style={{ left: `${valuePct}%` }}
        />
      </div>
      <div className="flex justify-between items-center text-[9px] text-muted-foreground">
        <span>{min}</span>
        <span className="text-success font-medium">{normalLabel}</span>
        <span>{max}</span>
      </div>
    </div>
  );
}

// ── Mini trend chart — supports one or two lines ──────────────────────────────
interface LineSpec { key: string; name: string; color: string; dashed?: boolean }

function MiniChart({
  title, unit, accentColor, referenceY, referenceLabel, referenceColor,
  yDomain, data, lines, avgLabel,
}: {
  title: string; unit: string; accentColor: string; avgLabel: string;
  data: Record<string, unknown>[]; lines: LineSpec[];
  referenceY?: number; referenceLabel?: string; referenceColor?: string;
  yDomain?: [number, number];
}) {
  const showLegend = lines.length > 1;
  return (
    <div className="overflow-hidden rounded-xl border border-border bg-card">
      <div className="h-1 w-full" style={{ backgroundColor: accentColor }} />
      <div className="flex items-center justify-between px-4 pt-3 pb-1">
        <div className="flex items-center gap-2">
          <span className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: accentColor }} />
          <span className="text-body-sm font-semibold text-foreground">{title}</span>
        </div>
        <div className="text-right">
          <span className="text-caption text-muted-foreground">Avg </span>
          <span className="text-body-sm font-bold text-foreground">{avgLabel}</span>
          <span className="text-caption text-muted-foreground ml-1">{unit}</span>
        </div>
      </div>
      <div className="px-2 pb-3">
        <ResponsiveContainer width="100%" height={showLegend ? 130 : 110}>
          <LineChart data={data} margin={{ top: 4, right: 8, left: -20, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
            <XAxis dataKey="label" tick={{ fontSize: 8 }} tickLine={false} axisLine={false} interval={0} />
            <YAxis domain={yDomain} tick={{ fontSize: 9 }} tickLine={false} axisLine={false} />
            <Tooltip
              contentStyle={{ fontSize: 11, borderRadius: 8, border: "1px solid hsl(var(--border))" }}
              formatter={(v: number) => [`${v} ${unit}`, ""]}
            />
            {showLegend && <Legend wrapperStyle={{ fontSize: 10 }} />}
            {referenceY !== undefined && (
              <ReferenceLine
                y={referenceY}
                stroke={referenceColor ?? "hsl(var(--success))"}
                strokeDasharray="4 4"
                label={{ value: referenceLabel, fontSize: 9, fill: referenceColor ?? "hsl(var(--success))" }}
              />
            )}
            {lines.map((l) => (
              <Line
                key={l.key}
                dataKey={l.key}
                name={l.name}
                stroke={l.color}
                strokeWidth={2}
                dot={{ r: 3 }}
                strokeDasharray={l.dashed ? "4 2" : undefined}
                isAnimationActive={false}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

// ── Component ─────────────────────────────────────────────────────────────────
const API_BASE   = "http://localhost:3001";
const PATIENT_ID = "PATIENT_001";

export function WalkingActivityChart() {
  const [gaitDays, setGaitDays] = useState<GaitDay[]>([]);
  const [open, setOpen]         = useState(false);

  useEffect(() => {
    fetch(`${API_BASE}/api/gait?patient_id=${encodeURIComponent(PATIENT_ID)}`)
      .then((r) => (r.ok ? r.json() : []))
      .then((data) => {
        if (Array.isArray(data))
          setGaitDays([...data].sort((a, b) => a.calendarDate.localeCompare(b.calendarDate)));
      })
      .catch(() => {});
  }, []);

  // ── Derived values ──────────────────────────────────────────────────────────
  const latestDay     = gaitDays[gaitDays.length - 1];
  const latestSession = latestDay?.sessions?.[latestDay.sessions.length - 1] ?? null;

  // Flatten all sessions for trend charts — both sides kept as separate keys
  const allSessions = gaitDays.flatMap((day) =>
    day.sessions.map((s) => ({
      label:     sessionLabel(s.startTime),
      startTime: s.startTime,
      cadence:   s.cadence,
      speed:     s.gaitSpeedMs,
      strideL:   s.strideLength.leftCm,
      strideR:   s.strideLength.rightCm,
      gctL:      s.groundContactTimeMs.left,
      gctR:      s.groundContactTimeMs.right,
      symmetry:  s.stepSymmetryPct,
      variability: s.strideVariabilityPct,
    }))
  );

  // Determine worse side from data (shorter stride = more guarding; longer GCT = more caution)
  const worseStrideSide = latestSession
    ? (latestSession.strideLength.leftCm <= latestSession.strideLength.rightCm ? "left" : "right")
    : "right";
  const worseGCTSide = latestSession
    ? (latestSession.groundContactTimeMs.left >= latestSession.groundContactTimeMs.right ? "left" : "right")
    : "right";
  const worseStrideVal = latestSession
    ? Math.min(latestSession.strideLength.leftCm, latestSession.strideLength.rightCm)
    : 0;
  const worseGCTVal = latestSession
    ? Math.max(latestSession.groundContactTimeMs.left, latestSession.groundContactTimeMs.right)
    : 0;

  // Risk levels — use the worse side for bilateral metrics
  const rLevels = latestSession ? {
    cadence:     riskCadence(latestSession.cadence),
    speed:       riskSpeed(latestSession.gaitSpeedMs),
    stride:      riskStride(worseStrideVal),
    gct:         riskGCT(worseGCTVal),
    symmetry:    riskSymmetry(latestSession.stepSymmetryPct),
    variability: riskVariability(latestSession.strideVariabilityPct),
  } : null;

  const overall: RiskLevel = rLevels
    ? overallLevel(Object.values(rLevels) as RiskLevel[])
    : "low";
  const overallLabel = { high: "High Risk", medium: "Moderate Risk", low: "Low Risk" }[overall];

  const patterns: Pattern[] = latestSession && rLevels ? [
    { name: "Cadence",                  level: rLevels.cadence,     detail: `${latestSession.cadence} spm — normal 100–120` },
    { name: "Gait Speed",               level: rLevels.speed,       detail: `${latestSession.gaitSpeedMs.toFixed(2)} m/s — normal ≥1.0 m/s` },
    { name: "Stride Length (L / R)",    level: rLevels.stride,      detail: `${latestSession.strideLength.leftCm} / ${latestSession.strideLength.rightCm} cm — normal 140–160 cm; ${worseStrideSide}-side shorter` },
    { name: "Ground Contact (L / R)",   level: rLevels.gct,         detail: `${latestSession.groundContactTimeMs.left} / ${latestSession.groundContactTimeMs.right} ms — normal ≤650 ms; ${worseGCTSide} leg loading longer` },
    { name: "Step Symmetry",            level: rLevels.symmetry,    detail: `${latestSession.stepSymmetryPct}% — normal ≥95%; uneven weight distribution` },
    { name: "Stride Variability",       level: rLevels.variability, detail: `${latestSession.strideVariabilityPct}% — normal <5%; irregular step timing` },
  ] : [];

  const highCount = patterns.filter((p) => p.level === "high").length;
  const medCount  = patterns.filter((p) => p.level === "medium").length;

  const metrics: Metric[] = latestSession && rLevels ? [
    { label: "Cadence",                value: `${latestSession.cadence} spm`,                                                                 normal: "100–120 spm", level: rLevels.cadence     },
    { label: "Gait Speed",             value: `${latestSession.gaitSpeedMs.toFixed(2)} m/s`,                                                 normal: "≥1.0 m/s",   level: rLevels.speed       },
    { label: "Stride Length (L / R)",  value: `${latestSession.strideLength.leftCm} / ${latestSession.strideLength.rightCm} cm`,             normal: "140–160 cm",  level: rLevels.stride      },
    { label: "Ground Contact (L / R)", value: `${latestSession.groundContactTimeMs.left} / ${latestSession.groundContactTimeMs.right} ms`,   normal: "≤650 ms",    level: rLevels.gct         },
    { label: "Step Symmetry",          value: `${latestSession.stepSymmetryPct}%`,                                                           normal: "≥95%",        level: rLevels.symmetry    },
    { label: "Stride Variability",     value: `${latestSession.strideVariabilityPct}%`,                                                      normal: "<5%",         level: rLevels.variability },
  ] : [];

  // Avg helper for chart labels
  const avg = (key: keyof typeof allSessions[0]) => {
    if (!allSessions.length) return "—";
    const sum = allSessions.reduce((a, s) => a + (s[key] as number), 0);
    const val = sum / allSessions.length;
    return key === "speed" ? val.toFixed(2) : Math.round(val).toString();
  };

  // ── Render ──────────────────────────────────────────────────────────────────
  return (
    <>
      {/* ── Concise overview card ── */}
      <div className="rounded-2xl bg-card p-6 shadow-card">
        <div className="mb-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-fall text-primary-foreground">
              <Footprints className="h-6 w-6" />
            </div>
            <div>
              <h3 className="text-heading font-display text-foreground">Gait Analysis</h3>
              <p className="text-caption text-muted-foreground">
                {latestSession
                  ? `Latest · ${fmtDate(latestSession.startTime)} at ${fmtTime(latestSession.startTime)}`
                  : "Loading…"}
              </p>
            </div>
          </div>
          {rLevels && (
            <div className={`rounded-full px-4 py-2 ${levelColor[overall]}`}>
              <span className="text-body font-medium">{overallLabel}</span>
            </div>
          )}
        </div>

        {/* Metric bars */}
        {latestSession ? (
          <div className="mb-4 space-y-3">
            <MetricBar
              label="Cadence"
              display={`${latestSession.cadence} spm`}
              value={latestSession.cadence}
              scale={[60, 130]}
              normalRange={[100, 130]}
              level={rLevels!.cadence}
              normalLabel="normal ≥100 spm"
            />
            <MetricBar
              label="Gait Speed"
              display={`${latestSession.gaitSpeedMs.toFixed(2)} m/s`}
              value={latestSession.gaitSpeedMs}
              scale={[0.4, 1.4]}
              normalRange={[1.0, 1.4]}
              level={rLevels!.speed}
              normalLabel="normal ≥1.0 m/s"
            />
            <MetricBar
              label="Stride L/R"
              display={`${latestSession.strideLength.leftCm}/${latestSession.strideLength.rightCm} cm`}
              value={worseStrideVal}
              scale={[40, 170]}
              normalRange={[140, 170]}
              level={rLevels!.stride}
              normalLabel="normal ≥140 cm"
            />
            <MetricBar
              label="GCT L/R"
              display={`${latestSession.groundContactTimeMs.left}/${latestSession.groundContactTimeMs.right} ms`}
              value={worseGCTVal}
              scale={[500, 1100]}
              normalRange={[500, 650]}
              level={rLevels!.gct}
              normalLabel="normal ≤650 ms"
            />
            <MetricBar
              label="Step Symmetry"
              display={`${latestSession.stepSymmetryPct}%`}
              value={latestSession.stepSymmetryPct}
              scale={[60, 100]}
              normalRange={[95, 100]}
              level={rLevels!.symmetry}
              normalLabel="normal ≥95%"
            />
            <MetricBar
              label="Stride Variability"
              display={`${latestSession.strideVariabilityPct}%`}
              value={latestSession.strideVariabilityPct}
              scale={[0, 20]}
              normalRange={[0, 5]}
              level={rLevels!.variability}
              normalLabel="normal <5%"
            />
          </div>
        ) : (
          <div className="mb-4 h-32 rounded-xl bg-muted/30 animate-pulse" />
        )}

        {/* Alert + action */}
        <div className="flex items-center justify-between gap-4 rounded-xl bg-destructive/5 px-4 py-3">
          <div className="flex items-center gap-2">
            <AlertTriangle className="h-4 w-4 flex-shrink-0 text-destructive" />
            <p className="text-body-sm text-foreground">
              {highCount > 0 || medCount > 0
                ? <><strong>{highCount} high</strong>{medCount > 0 ? `, ${medCount} moderate` : ""} risk patterns — {worseStrideSide}-side guarding detected.</>
                : "Gait metrics within acceptable range."}
            </p>
          </div>
          <Button variant="outline" size="sm" className="flex-shrink-0" onClick={() => setOpen(true)}>
            View Details
          </Button>
        </div>
      </div>

      {/* ── Details dialog ── */}
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-heading font-display">Gait Analysis — Details</DialogTitle>
            <p className="text-body-sm text-muted-foreground">
              {latestSession
                ? `${fmtDate(latestSession.startTime)} · ${fmtTime(latestSession.startTime)} · ${allSessions.length} sessions`
                : "Loading…"}
            </p>
          </DialogHeader>

          <Tabs defaultValue="patterns">
            <TabsList className="mb-4 w-full">
              <TabsTrigger value="patterns" className="flex-1">Patterns</TabsTrigger>
              <TabsTrigger value="sessions" className="flex-1">Sessions</TabsTrigger>
              <TabsTrigger value="trends"   className="flex-1">Trends</TabsTrigger>
              <TabsTrigger value="metrics"  className="flex-1">Metrics</TabsTrigger>
            </TabsList>

            {/* Patterns */}
            <TabsContent value="patterns" className="space-y-2">
              {patterns.map((p) => (
                <div key={p.name}
                  className="flex items-start justify-between rounded-xl bg-muted/50 p-3 transition-colors hover:bg-muted"
                >
                  <div className="flex items-start gap-3">
                    <span className={`mt-0.5 flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-lg ${levelColor[p.level]}`}>
                      <RiskIcon level={p.level} />
                    </span>
                    <div>
                      <p className="text-body font-medium text-foreground">{p.name}</p>
                      <p className="text-caption text-muted-foreground">{p.detail}</p>
                    </div>
                  </div>
                  <span className={`ml-3 flex-shrink-0 rounded-full px-2 py-0.5 text-caption font-medium capitalize ${levelColor[p.level]}`}>
                    {p.level}
                  </span>
                </div>
              ))}
            </TabsContent>

            {/* Sessions table */}
            <TabsContent value="sessions">
              <div className="overflow-x-auto rounded-xl border border-border">
                <table className="w-full text-caption">
                  <thead>
                    <tr className="border-b border-border bg-muted/50">
                      {["Date / Time", "Cadence", "Speed", "Stride L/R (cm)", "GCT L/R (ms)", "Symmetry", "Variability"].map((h) => (
                        <th key={h} className="px-3 py-2 text-left font-semibold text-muted-foreground whitespace-nowrap">{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {allSessions.map((s, i) => {
                      const isLatest = s.startTime === latestSession?.startTime;
                      return (
                        <tr key={i} className={`border-b border-border last:border-0 ${isLatest ? "bg-primary/5 font-medium" : "hover:bg-muted/30"}`}>
                          <td className="px-3 py-2 text-foreground whitespace-nowrap">
                            {fmtDate(s.startTime)} {fmtTime(s.startTime)}
                            {isLatest && <span className="ml-1 text-caption text-primary">(latest)</span>}
                          </td>
                          <td className={`px-3 py-2 ${riskCadence(s.cadence) !== "low" ? "text-warning" : "text-muted-foreground"}`}>{s.cadence}</td>
                          <td className={`px-3 py-2 ${riskSpeed(s.speed) !== "low" ? "text-warning" : "text-muted-foreground"}`}>{(s.speed as number).toFixed(2)}</td>
                          <td className={`px-3 py-2 ${riskStride(s.strideR) !== "low" ? "text-warning" : "text-muted-foreground"}`}>{s.strideL}/{s.strideR}</td>
                          <td className={`px-3 py-2 ${riskGCT(s.gctR) !== "low" ? "text-warning" : "text-muted-foreground"}`}>{s.gctL}/{s.gctR}</td>
                          <td className={`px-3 py-2 ${riskSymmetry(s.symmetry) !== "low" ? "text-warning" : "text-muted-foreground"}`}>{s.symmetry}%</td>
                          <td className={`px-3 py-2 ${riskVariability(s.variability) !== "low" ? "text-warning" : "text-muted-foreground"}`}>{s.variability}%</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </TabsContent>

            {/* Trends */}
            <TabsContent value="trends" className="space-y-3">
              <p className="text-caption text-muted-foreground">
                {allSessions.length} sessions · {gaitDays[0]?.calendarDate} – {latestDay?.calendarDate}
              </p>

              {/* Stride Length — both sides on one chart to show asymmetry */}
              <MiniChart
                title="Stride Length — Left vs Right"
                unit="cm"
                accentColor="#3b82f6"
                data={allSessions}
                lines={[
                  { key: "strideL", name: worseStrideSide === "left" ? "Left (shorter)" : "Left",  color: "#3b82f6" },
                  { key: "strideR", name: worseStrideSide === "right" ? "Right (shorter)" : "Right", color: "#f59e0b", dashed: true },
                ]}
                referenceY={140}
                referenceLabel="min normal"
                referenceColor="hsl(var(--success))"
                yDomain={[60, 160]}
                avgLabel={`${avg("strideL")} L / ${avg("strideR")} R`}
              />

              {/* Ground Contact Time — both sides on one chart */}
              <MiniChart
                title="Ground Contact Time — Left vs Right"
                unit="ms"
                accentColor="#f97316"
                data={allSessions}
                lines={[
                  { key: "gctL", name: worseGCTSide === "left" ? "Left (longer)" : "Left",  color: "#f97316" },
                  { key: "gctR", name: worseGCTSide === "right" ? "Right (longer)" : "Right", color: "#dc2626", dashed: true },
                ]}
                referenceY={650}
                referenceLabel="max normal"
                referenceColor="hsl(var(--warning))"
                yDomain={[600, 1100]}
                avgLabel={`${avg("gctL")} L / ${avg("gctR")} R`}
              />

              {/* Cadence */}
              <MiniChart
                title="Cadence"
                unit="spm"
                accentColor="#ef4444"
                data={allSessions}
                lines={[{ key: "cadence", name: "Cadence", color: "#ef4444" }]}
                referenceY={100}
                referenceLabel="min normal"
                referenceColor="hsl(var(--success))"
                yDomain={[70, 110]}
                avgLabel={avg("cadence")}
              />

              {/* Step Symmetry */}
              <MiniChart
                title="Step Symmetry"
                unit="%"
                accentColor="#a855f7"
                data={allSessions}
                lines={[{ key: "symmetry", name: "Symmetry", color: "#a855f7" }]}
                referenceY={95}
                referenceLabel="normal"
                referenceColor="hsl(var(--success))"
                yDomain={[60, 100]}
                avgLabel={avg("symmetry")}
              />

              {/* Gait Speed */}
              <MiniChart
                title="Gait Speed"
                unit="m/s"
                accentColor="#06b6d4"
                data={allSessions}
                lines={[{ key: "speed", name: "Speed", color: "#06b6d4" }]}
                referenceY={1.0}
                referenceLabel="min normal"
                referenceColor="hsl(var(--success))"
                yDomain={[0.5, 1.2]}
                avgLabel={avg("speed")}
              />
            </TabsContent>

            {/* Metrics */}
            <TabsContent value="metrics">
              <div className="divide-y divide-border rounded-xl border border-border">
                {metrics.map((m) => (
                  <div key={m.label} className="flex items-center justify-between px-4 py-3">
                    <div>
                      <p className="text-body-sm font-medium text-foreground">{m.label}</p>
                      <p className="text-caption text-muted-foreground">Normal: {m.normal}</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-body-sm font-semibold text-foreground">{m.value}</span>
                      <span className={`h-2 w-2 rounded-full ${levelDot[m.level]}`} />
                    </div>
                  </div>
                ))}
              </div>
            </TabsContent>
          </Tabs>
        </DialogContent>
      </Dialog>
    </>
  );
}
