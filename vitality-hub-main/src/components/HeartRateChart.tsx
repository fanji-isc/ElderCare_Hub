import { useEffect, useMemo, useState } from "react";
import { Area, AreaChart, ResponsiveContainer, XAxis, YAxis, Tooltip } from "recharts";

type EpochDescriptor = { key: string; index: number };

type EpochPayload = {
  userProfilePK?: number;
  activityUuid?: string;
  epochDescriptorDTOList?: EpochDescriptor[];
  epochArray?: Array<number[]>; // each row: [timestamp, heartRate, stress, spo2, respiration]
};

type ChartPoint = {
  ts: number; // epoch ms
  bpm: number;
};

function pickIndex(
  descriptors: EpochDescriptor[] | undefined | null,
  key: string,
  fallback: number
) {
  if (!Array.isArray(descriptors)) return fallback;
  const hit = descriptors.find((d) => d?.key === key);
  return typeof hit?.index === "number" ? hit.index : fallback;
}

export function HeartRateChart() {
  const patientId = "PATIENT_001";

  const [payload, setPayload] = useState<EpochPayload | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Fetch from IRIS-backed API (via Vite proxy /api -> http://api:3001)
  useEffect(() => {
    let cancelled = false;

    async function run() {
      setLoading(true);
      setError(null);

      try {
        const r = await fetch(`/api/hr?patient_id=${encodeURIComponent(patientId)}`);
        if (!r.ok) throw new Error(await r.text());
        const data = (await r.json()) as unknown;

        if (cancelled) return;

        // Some APIs might return {} when empty; keep it but don’t crash.
        setPayload((data ?? null) as EpochPayload);
        setLoading(false);
      } catch (e: any) {
        if (cancelled) return;
        setError(e?.message ? String(e.message) : String(e));
        setPayload(null);
        setLoading(false);
      }
    }

    run();
    return () => {
      cancelled = true;
    };
  }, []);

  const { data, minBpm, maxBpm } = useMemo(() => {
    // Default return
    const empty = { data: [] as ChartPoint[], minBpm: null as number | null, maxBpm: null as number | null };

    if (!payload) return empty;

    const descriptors = payload.epochDescriptorDTOList;
    const rows = payload.epochArray;

    // Guard shape
    if (!Array.isArray(descriptors) || !Array.isArray(rows)) return empty;

    const tsIndex = pickIndex(descriptors, "timestamp", 0);
    const hrIndex = pickIndex(descriptors, "heartRate", 1);

    const raw: ChartPoint[] = [];
    for (const row of rows) {
      if (!Array.isArray(row)) continue;
      const ts = row[tsIndex];
      const hr = row[hrIndex];
      if (typeof ts !== "number" || !Number.isFinite(ts)) continue;
      if (typeof hr !== "number" || !Number.isFinite(hr)) continue;
      raw.push({ ts, bpm: hr });
    }

    raw.sort((a, b) => a.ts - b.ts);

    // Downsample for performance
    const targetPoints = 600;
    const step = raw.length > targetPoints ? Math.ceil(raw.length / targetPoints) : 1;

    const downsampled: ChartPoint[] = [];
    for (let i = 0; i < raw.length; i += step) downsampled.push(raw[i]);

    let min = Infinity;
    let max = -Infinity;
    for (const p of raw) {
      if (p.bpm < min) min = p.bpm;
      if (p.bpm > max) max = p.bpm;
    }

    return {
      data: downsampled,
      minBpm: Number.isFinite(min) ? min : null,
      maxBpm: Number.isFinite(max) ? max : null,
    };
  }, [payload]);

  const rangeText =
    minBpm != null && maxBpm != null
      ? `Range: ${Math.round(minBpm)}-${Math.round(maxBpm)} BPM`
      : "Range: —";

  const yDomain: [number, number] = useMemo(() => {
    if (minBpm == null || maxBpm == null) return [50, 100];
    const pad = 8;
    const lo = Math.max(0, Math.floor(minBpm - pad));
    const hi = Math.ceil(maxBpm + pad);
    if (lo === hi) return [Math.max(0, lo - 5), hi + 5];
    return [lo, hi];
  }, [minBpm, maxBpm]);

  const formatTimeLocal = (ts: number) =>
    new Date(ts).toLocaleTimeString(undefined, { hour: "numeric", minute: "2-digit" });

  const formatTimeLocalWithSeconds = (ts: number) =>
    new Date(ts).toLocaleTimeString(undefined, { hour: "numeric", minute: "2-digit", second: "2-digit" });

  return (
    <div className="rounded-2xl bg-card p-6 shadow-card">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h3 className="text-heading font-display text-foreground">Heart Rate Today</h3>
          <p className="text-body-sm text-muted-foreground">Real time from epoch timestamps</p>
        </div>

        <div className="flex gap-4 text-body-sm">
          <div className="flex items-center gap-2">
            <span className="h-3 w-3 rounded-full bg-heart" />
            <span className="text-muted-foreground">{rangeText}</span>
          </div>
        </div>
      </div>

      {error && (
        <div className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">
          HeartRate API error: {error}
        </div>
      )}

      {loading && (
        <div className="mb-4 text-sm text-muted-foreground">
          Loading heart rate from IRIS…
        </div>
      )}

      <div className="h-64">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
            <defs>
              <linearGradient id="heartGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="hsl(0, 75%, 60%)" stopOpacity={0.3} />
                <stop offset="100%" stopColor="hsl(0, 75%, 60%)" stopOpacity={0} />
              </linearGradient>
            </defs>

            <XAxis
              dataKey="ts"
              type="number"
              domain={["dataMin", "dataMax"]}
              tickFormatter={formatTimeLocal}
              axisLine={false}
              tickLine={false}
              tick={{ fill: "hsl(215, 16%, 50%)", fontSize: 12 }}
            />

            <YAxis
              domain={yDomain}
              axisLine={false}
              tickLine={false}
              tick={{ fill: "hsl(215, 16%, 50%)", fontSize: 12 }}
            />

            <Tooltip
              labelFormatter={(ts) => `Time: ${formatTimeLocalWithSeconds(Number(ts))}`}
              formatter={(value: number) => [`${Math.round(value)} BPM`, "Heart Rate"]}
              contentStyle={{
                backgroundColor: "hsl(0, 0%, 100%)",
                border: "none",
                borderRadius: "12px",
                boxShadow: "0 4px 20px -4px rgba(0,0,0,0.1)",
                padding: "12px 16px",
              }}
            />

            <Area
              type="monotone"
              dataKey="bpm"
              stroke="hsl(0, 75%, 60%)"
              strokeWidth={3}
              fill="url(#heartGradient)"
              dot={false}
              isAnimationActive={true}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      {!loading && data.length === 0 && !error && (
        <p className="mt-3 text-sm text-muted-foreground">
          No heartRate values found in epochArray (or API returned empty data).
        </p>
      )}
    </div>
  );
}
