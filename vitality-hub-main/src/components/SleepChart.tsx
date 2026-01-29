
// import React, { useState, useEffect } from "react";
// import { Bar, BarChart, ResponsiveContainer, XAxis, YAxis, Tooltip, Cell } from "recharts";

// // 1. Helper to map Garmin scores to your UI categories
// const getQualityFromScore = (score: number) => {
//   if (score >= 90) return "excellent";
//   if (score >= 80) return "good";
//   if (score >= 70) return "fair";
//   return "poor";
// };

// const getBarColor = (quality: string) => {
//   switch (quality) {
//     case "excellent": return "hsl(250, 60%, 65%)";
//     case "good":      return "hsl(250, 50%, 70%)";
//     case "fair":      return "hsl(250, 40%, 75%)";
//     case "poor":      return "hsl(250, 30%, 80%)";
//     default:          return "hsl(250, 60%, 65%)";
//   }
// };

// export function SleepChart() {
//   const [data, setData] = useState<any[]>([]);
//   const [loading, setLoading] = useState(true);

// useEffect(() => {
//   fetch(`/api/sleep?patient_id=PATIENT_001`)
//     .then((res) => res.json())
//     .then((result) => {
//       const sleepArray = Array.isArray(result) ? result : [result];

//       const formatted = sleepArray.map((day: any) => {
//         const totalSeconds =
//           (day.deepSleepSeconds || 0) +
//           (day.lightSleepSeconds || 0) +
//           (day.remSleepSeconds || 0);

//         return {
//           day: day.calendarDate
//             ? new Date(day.calendarDate).toLocaleDateString("en-US", { weekday: "short" })
//             : "N/A",
//           hours: parseFloat((totalSeconds / 3600).toFixed(1)),
//           quality: getQualityFromScore(day.sleepScores?.overallScore || 0),
//           score: day.sleepScores?.overallScore || 0,
//         };
//       });

//       setData(formatted);
//       setLoading(false);
//     })
//     .catch((err) => {
//       console.error("Fetch error:", err);
//       setLoading(false);
//     });
// }, []);


//   const avgSleep = data.length 
//     ? (data.reduce((acc, d) => acc + d.hours, 0) / data.length).toFixed(1) 
//     : "0.0";

//   if (loading) return <div className="p-6 text-center text-muted-foreground">Loading IRIS Data...</div>;

//   return (
//     <div className="rounded-2xl bg-card p-6 shadow-card">
//       <div className="mb-6 flex items-center justify-between">
//         <div>
//           <h3 className="text-xl font-bold text-foreground">Sleep Analysis</h3>
//           <p className="text-sm text-muted-foreground">Data from InterSystems IRIS</p>
//         </div>
//         <div className="text-right">
//           <p className="text-3xl font-bold text-indigo-500">{avgSleep}h</p>
//           <p className="text-xs text-muted-foreground">Average</p>
//         </div>
//       </div>

//       <div className="h-48">
//         <ResponsiveContainer width="100%" height="100%">
//           <BarChart data={data} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
//             <XAxis
//               dataKey="day"
//               axisLine={false}
//               tickLine={false}
//               tick={{ fill: "hsl(215, 16%, 50%)", fontSize: 12 }}
//             />
//             <YAxis
//               domain={[0, 12]}
//               axisLine={false}
//               tickLine={false}
//               tick={{ fill: "hsl(215, 16%, 50%)", fontSize: 12 }}
//             />
//             <Tooltip
//               cursor={{ fill: 'transparent' }}
//               contentStyle={{
//                 backgroundColor: "#fff",
//                 border: "none",
//                 borderRadius: "12px",
//                 boxShadow: "0 4px 20px -4px rgba(0,0,0,0.1)",
//               }}
//               formatter={(value: number) => [`${value} hours`, "Duration"]}
//             />
//             <Bar dataKey="hours" radius={[8, 8, 0, 0]}>
//               {data.map((entry, index) => (
//                 <Cell key={`cell-${index}`} fill={getBarColor(entry.quality)} />
//               ))}
//             </Bar>
//           </BarChart>
//         </ResponsiveContainer>
//       </div>

//       <div className="mt-6 flex justify-center gap-4 text-xs">
//         {["excellent", "good", "fair", "poor"].map((q) => (
//           <div key={q} className="flex items-center gap-1.5">
//             <span className="h-2 w-2 rounded-full" style={{ backgroundColor: getBarColor(q) }} />
//             <span className="capitalize text-muted-foreground">{q}</span>
//           </div>
//         ))}
//       </div>
//     </div>
//   );
// }
// src/components/SleepChart.tsx
// src/components/SleepChart.tsx
import React, { useEffect, useMemo, useState } from "react";
import {
  ResponsiveContainer,
  ComposedChart,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Bar,
  Line,
  Scatter,
} from "recharts";

type RawSleep = {
  calendarDate?: string;
  deepSleepSeconds?: number;
  lightSleepSeconds?: number;
  remSleepSeconds?: number;
  awakeSleepSeconds?: number;
  unmeasurableSeconds?: number;
  sleepScores?: { overallScore?: number; recoveryScore?: number };
  napList?: Array<{ napTimeSec?: number }>;
};

type ChartRow = {
  key: string;
  dayLabel: string;

  // hours
  deep: number;
  light: number;
  rem: number;
  awake: number;
  unmeasurable: number;
  napHours: number;

  total: number;
  efficiency: number | null; // 0..1
  score: number | null; // 0..100
};

const COLORS = {
  deep: "#4338ca",
  light: "#818cf8",
  rem: "#a5b4fc",
  awake: "#fbbf24",
  unmeasurable: "#fca5a5",
  nap: "#c7f9cc",
  effLine: "#10b981",
  scoreDot: "#ef4444",
};

function safeNum(v: unknown) {
  return typeof v === "number" && Number.isFinite(v) ? v : 0;
}

export function SleepChart({ patientId = "PATIENT_001" }: { patientId?: string }) {
  const [rows, setRows] = useState<ChartRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      setError(null);

      try {
        const res = await fetch(`/api/sleep?patient_id=${encodeURIComponent(patientId)}`);
        if (!res.ok) throw new Error(`HTTP ${res.status} ${res.statusText}`);
        const payload = await res.json();

        // Your API returns an array, but it may include {"retro":false} rows.
        const arr: RawSleep[] = (Array.isArray(payload) ? payload : payload ? [payload] : [])
          .filter((d: any) => d && d.calendarDate); // IMPORTANT: remove retro-only objects

        const mapped: ChartRow[] = arr.map((d, idx) => {
          const deep = safeNum(d.deepSleepSeconds) / 3600;
          const light = safeNum(d.lightSleepSeconds) / 3600;
          const rem = safeNum(d.remSleepSeconds) / 3600;
          const awake = safeNum(d.awakeSleepSeconds) / 3600;
          const unmeasurable = safeNum(d.unmeasurableSeconds) / 3600;

          const napHours =
            Array.isArray(d.napList) && d.napList.length > 0
              ? safeNum(d.napList[0].napTimeSec) / 3600
              : 0;

          const total = deep + light + rem + awake + unmeasurable;

          const efficiency = total > 0 ? (deep + light + rem) / total : null; // 0..1
          const score = d.sleepScores?.overallScore ?? null;

          const key = d.calendarDate ?? `row-${idx}`;
          const dayLabel = d.calendarDate
            ? new Date(d.calendarDate).toLocaleDateString("en-US", {
                weekday: "short",
                month: "short",
                day: "numeric",
              })
            : `R${idx + 1}`;

          return {
            key,
            dayLabel,
            deep,
            light,
            rem,
            awake,
            unmeasurable,
            napHours,
            total,
            efficiency,
            score,
          };
        });

        // Sort chronologically (ISO date strings sort correctly)
        mapped.sort((a, b) => (a.key > b.key ? 1 : a.key < b.key ? -1 : 0));

        if (!cancelled) {
          setRows(mapped);
          setLoading(false);
        }
      } catch (e: any) {
        if (!cancelled) {
          setError(String(e?.message ?? e));
          setRows([]);
          setLoading(false);
        }
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, [patientId]);

  const maxTotal = useMemo(() => {
    if (!rows.length) return 10;
    const m = Math.max(...rows.map((r) => r.total));
    return Math.max(10, Math.ceil(m + 0.5));
  }, [rows]);

  const avgTotal = useMemo(() => {
    if (!rows.length) return "—";
    const v = rows.reduce((s, r) => s + r.total, 0) / rows.length;
    return v.toFixed(1);
  }, [rows]);

  const avgScore = useMemo(() => {
    const scores = rows.map((r) => r.score).filter((x): x is number => typeof x === "number");
    if (!scores.length) return "—";
    const v = scores.reduce((s, x) => s + x, 0) / scores.length;
    return Math.round(v).toString();
  }, [rows]);

  // For overlay visuals, map efficiency (0..1) and score (0..100) into the same Y scale (hours),
  // so they appear on top of the bars without needing a second axis.
  const effScaled = (r: ChartRow) => (r.efficiency == null ? null : r.efficiency * maxTotal);
  const scoreScaled = (r: ChartRow) => (r.score == null ? null : (r.score / 100) * maxTotal);

  if (loading) return <div className="p-6 text-center text-muted-foreground">Loading sleep data…</div>;
  if (error) return <div className="p-6 text-sm text-red-600">Error loading sleep data: {error}</div>;
  if (!rows.length) return <div className="p-6 text-center text-muted-foreground">No sleep data available</div>;

  return (
    <div className="rounded-2xl bg-card p-6 shadow-card">
      <div className="mb-4 flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-foreground">Sleep Analysis</h3>
          <p className="text-sm text-muted-foreground">
          </p>
        </div>

        <div className="text-right">
          <div className="text-xl font-bold">{avgTotal}h</div>
          <div className="text-xs text-muted-foreground">Avg total • Avg score {avgScore}</div>
        </div>
      </div>

      <div style={{ width: "100%", height: 380 }}>
        <ResponsiveContainer>
          <ComposedChart data={rows} margin={{ top: 8, right: 16, left: 0, bottom: 24 }}>
            <XAxis dataKey="dayLabel" tick={{ fontSize: 12 }} />
            {/* IMPORTANT: no yAxisId (fixes your error) */}
            <YAxis
              domain={[0, maxTotal]}
              tick={{ fontSize: 12 }}
              label={{ value: "Hours", angle: -90, position: "insideLeft", offset: -6 }}
            />

            <Tooltip
              labelFormatter={(label) => `Date: ${label}`}
              formatter={(value: any, name: any, ctx: any) => {
                const v = Number(value);

                // If the tooltip is coming from the overlays, show real values from the row.
                if (name === "Efficiency") {
                  const eff = ctx?.payload?.efficiency;
                  return [`${eff != null ? (eff * 100).toFixed(0) : "—"}%`, "Efficiency"];
                }
                if (name === "Score") {
                  const sc = ctx?.payload?.score;
                  return [`${sc != null ? sc : "—"}`, "Score"];
                }

                // Bar segments: show hours
                return [`${Number.isFinite(v) ? v.toFixed(1) : value} h`, name];
              }}
            />

            <Legend verticalAlign="top" height={36} />

            {/* Stacked stage bars */}
            <Bar dataKey="deep" stackId="a" name="Deep" fill={COLORS.deep} isAnimationActive={false} />
            <Bar dataKey="rem" stackId="a" name="REM" fill={COLORS.rem} isAnimationActive={false} />
            <Bar dataKey="light" stackId="a" name="Light" fill={COLORS.light} isAnimationActive={false} />
            <Bar dataKey="awake" stackId="a" name="Awake" fill={COLORS.awake} isAnimationActive={false} />
            <Bar dataKey="unmeasurable" stackId="a" name="Unmeasurable" fill={COLORS.unmeasurable} isAnimationActive={false} />

            {/* Optional: Nap as its own bar (not stacked with sleep) */}
            <Bar dataKey="napHours" name="Nap" fill={COLORS.nap} isAnimationActive={false} />

            {/* Overlays */}
            <Line
              type="monotone"
              dataKey={effScaled}
              stroke={COLORS.effLine}
              strokeWidth={2}
              dot={false}
              name="Efficiency"
              isAnimationActive={false}
            />

            <Scatter dataKey={scoreScaled} fill={COLORS.scoreDot} name="Score" isAnimationActive={false} />
          </ComposedChart>
        </ResponsiveContainer>
      </div>

      <div className="mt-4 text-xs text-muted-foreground">
        Efficiency = (deep + light + REM) / (deep + light + REM + awake + unmeasurable). Score = sleepScores.overallScore.
      </div>
    </div>
  );
}

