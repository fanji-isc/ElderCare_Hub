import { useEffect, useMemo, useState } from "react";
import { Moon } from "lucide-react";
import {
  ResponsiveContainer, BarChart, XAxis, YAxis,
  Tooltip, Bar, CartesianGrid,
} from "recharts";

type RawSleep = {
  calendarDate?: string;
  deepSleepSeconds?: number;
  lightSleepSeconds?: number;
  remSleepSeconds?: number;
  sleepScores?: { overallScore?: number };
};

type ChartRow = {
  key: string;
  dayLabel: string;
  deep: number;
  light: number;
  rem: number;
  total: number;
  score: number | null;
};

const STAGE = {
  deep:  { color: "#4338ca", label: "Deep" },
  rem:   { color: "#818cf8", label: "REM" },
  light: { color: "#c7d2fe", label: "Light" },
};

function safeNum(v: unknown) {
  return typeof v === "number" && Number.isFinite(v) ? v : 0;
}

export function SleepChart({ patientId = "PATIENT_001" }: { patientId?: string }) {
  const [rows, setRows]       = useState<ChartRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      setLoading(true);
      setError(null);
      try {
        const res = await fetch(`/api/sleep?patient_id=${encodeURIComponent(patientId)}`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const payload = await res.json();

        const arr: RawSleep[] = (Array.isArray(payload) ? payload : [payload])
          .filter((d: any) => d?.calendarDate);

        const mapped: ChartRow[] = arr.map((d, idx) => {
          const deep  = safeNum(d.deepSleepSeconds)  / 3600;
          const light = safeNum(d.lightSleepSeconds) / 3600;
          const rem   = safeNum(d.remSleepSeconds)   / 3600;
          const key   = d.calendarDate ?? `row-${idx}`;
          const dayLabel = d.calendarDate
            ? new Date(d.calendarDate).toLocaleDateString("en-US", { weekday: "short", month: "numeric", day: "numeric" })
            : `R${idx + 1}`;
          return { key, dayLabel, deep, light, rem, total: deep + light + rem, score: d.sleepScores?.overallScore ?? null };
        });

        mapped.sort((a, b) => (a.key > b.key ? 1 : -1));
        if (!cancelled) { setRows(mapped); setLoading(false); }
      } catch (e: any) {
        if (!cancelled) { setError(String(e?.message ?? e)); setLoading(false); }
      }
    }
    load();
    return () => { cancelled = true; };
  }, [patientId]);

  const avgTotal = useMemo(() => {
    if (!rows.length) return "—";
    return (rows.reduce((s, r) => s + r.total, 0) / rows.length).toFixed(1);
  }, [rows]);

  const avgScore = useMemo(() => {
    const scores = rows.map((r) => r.score).filter((x): x is number => x != null);
    if (!scores.length) return "—";
    return Math.round(scores.reduce((s, x) => s + x, 0) / scores.length).toString();
  }, [rows]);

  const latest = rows[rows.length - 1];

  if (loading) return (
    <div className="rounded-2xl bg-card shadow-card overflow-hidden">
      <div className="flex items-center gap-3 border-b border-border bg-gradient-to-r from-indigo-50 to-violet-50 px-6 py-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-sleep text-primary-foreground">
          <Moon className="h-5 w-5" />
        </div>
        <div className="flex-1">
          <h3 className="text-heading font-display text-foreground">Sleep Analysis</h3>
          <p className="text-caption text-muted-foreground">Sleep stages from Garmin</p>
        </div>
      </div>
      <div className="flex items-center justify-center h-48">
        <p className="text-body-sm text-muted-foreground">Loading sleep data…</p>
      </div>
    </div>
  );

  if (error || !rows.length) return (
    <div className="rounded-2xl bg-card shadow-card overflow-hidden">
      <div className="flex items-center gap-3 border-b border-border bg-gradient-to-r from-indigo-50 to-violet-50 px-6 py-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-sleep text-primary-foreground">
          <Moon className="h-5 w-5" />
        </div>
        <div className="flex-1">
          <h3 className="text-heading font-display text-foreground">Sleep Analysis</h3>
          <p className="text-caption text-muted-foreground">Sleep stages from Garmin</p>
        </div>
      </div>
      <div className="flex items-center justify-center h-48">
        <p className="text-body-sm text-muted-foreground">{error ?? "No sleep data available"}</p>
      </div>
    </div>
  );

  return (
    <div className="rounded-2xl bg-card shadow-card overflow-hidden">
      {/* Header */}
      <div className="flex items-center gap-3 border-b border-border bg-gradient-to-r from-indigo-50 to-violet-50 px-6 py-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-sleep text-primary-foreground">
          <Moon className="h-5 w-5" />
        </div>
        <div className="flex-1">
          <h3 className="text-heading font-display text-foreground">Sleep Analysis</h3>
          <p className="text-caption text-muted-foreground">Sleep stages from Garmin</p>
        </div>
        <div className="text-right">
          <div className="text-heading font-display text-foreground">{avgTotal}h</div>
          <div className="text-caption text-muted-foreground">Avg · Score {avgScore}</div>
        </div>
      </div>

      <div className="p-6">
        {/* Latest night stage breakdown */}
        {latest && (
          <div className="mb-4 grid grid-cols-3 divide-x divide-border rounded-xl border border-border">
            {(["deep", "rem", "light"] as const).map((stage) => (
              <div key={stage} className="flex flex-col items-center gap-1 py-3">
                <span className="h-2 w-8 rounded-full" style={{ backgroundColor: STAGE[stage].color }} />
                <span className="text-heading font-display text-foreground">
                  {latest[stage].toFixed(1)}h
                </span>
                <span className="text-caption text-muted-foreground">{STAGE[stage].label}</span>
              </div>
            ))}
          </div>
        )}

        {/* Stacked bar chart */}
        <div className="h-48">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={rows} margin={{ top: 4, right: 8, left: -20, bottom: 0 }} barCategoryGap="35%">
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
              <XAxis
                dataKey="dayLabel"
                tick={{ fontSize: 11, fill: "hsl(215, 16%, 50%)" }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                tick={{ fontSize: 11, fill: "hsl(215, 16%, 50%)" }}
                axisLine={false}
                tickLine={false}
                unit="h"
              />
              <Tooltip
                contentStyle={{ fontSize: 12, borderRadius: 8, border: "1px solid hsl(var(--border))" }}
                formatter={(v: number, name: string) => [`${v.toFixed(1)}h`, name]}
              />
              <Bar dataKey="deep"  name="Deep"  stackId="a" fill={STAGE.deep.color}  isAnimationActive={false} />
              <Bar dataKey="rem"   name="REM"   stackId="a" fill={STAGE.rem.color}   isAnimationActive={false} />
              <Bar dataKey="light" name="Light" stackId="a" fill={STAGE.light.color} isAnimationActive={false} radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Legend */}
        <div className="mt-3 flex justify-center gap-6">
          {(["deep", "rem", "light"] as const).map((stage) => (
            <div key={stage} className="flex items-center gap-1.5">
              <span className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: STAGE[stage].color }} />
              <span className="text-caption text-muted-foreground">{STAGE[stage].label}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
