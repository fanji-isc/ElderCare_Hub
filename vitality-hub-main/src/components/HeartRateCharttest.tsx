import { useEffect, useMemo, useState } from "react";
import { Area, AreaChart, ResponsiveContainer, XAxis, YAxis, Tooltip } from "recharts";
// import epochJson from "../data/heart_rate.json"; // <-- put your epoch JSON here

type EpochDescriptor = { key: string; index: number };

type EpochPayload = {
  userProfilePK: number;
  activityUuid: string;
  epochDescriptorDTOList: EpochDescriptor[];
  epochArray: Array<number[]>; // each row: [timestamp, heartRate, stress, spo2, respiration]
};

type ChartPoint = {
  ts: number; // REAL timestamp (ms)
  bpm: number;
};

function pickIndex(descriptors: EpochDescriptor[], key: string, fallback: number) {
  const hit = descriptors.find((d) => d.key === key);
  return typeof hit?.index === "number" ? hit.index : fallback;
}

export function HeartRateChart() {
  const [payload, setPayload] = useState<EpochPayload | null>(null);
  const [error, setError] = useState<string | null>(null);

  //  fetch from IRIS-backed API
  useEffect(() => {
    // fetch("/api/hr")
      fetch("/api/hr?patient_id=PATIENT_001")

      .then(async (r) => {
        if (!r.ok) throw new Error(await r.text());
        return r.json();
      })
      .then((data) => {
        setPayload(data as EpochPayload);
        setError(null);
      })
      .catch((e) => setError(String(e)));
  }, []);

  const { data, minBpm, maxBpm } = useMemo(() => {
    if (!payload) return { data: [] as ChartPoint[], minBpm: null as number | null, maxBpm: null as number | null };

    const tsIndex = pickIndex(payload.epochDescriptorDTOList, "timestamp", 0);
    const hrIndex = pickIndex(payload.epochDescriptorDTOList, "heartRate", 1);

    const raw: ChartPoint[] = [];
    for (const row of payload.epochArray) {
      const ts = row[tsIndex];
      const hr = row[hrIndex];
      if (typeof ts !== "number" || !Number.isFinite(ts)) continue;
      if (typeof hr !== "number" || !Number.isFinite(hr)) continue;
      raw.push({ ts, bpm: hr });
    }

    raw.sort((a, b) => a.ts - b.ts);

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
    if (lo === hi) return [lo - 5, hi + 5];
    return [lo, hi];
  }, [minBpm, maxBpm]);

  // THIS is the "real time" display: it converts the epoch-ms timestamp to your local clock time
  const formatTimeLocal = (ts: number) =>
    new Date(ts).toLocaleTimeString(undefined, {
      hour: "numeric",
      minute: "2-digit",
    });

  const formatTimeLocalWithSeconds = (ts: number) =>
    new Date(ts).toLocaleTimeString(undefined, {
      hour: "numeric",
      minute: "2-digit",
      second: "2-digit",
    });

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

      <div className="h-64">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
            <defs>
              <linearGradient id="heartGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="hsl(0, 75%, 60%)" stopOpacity={0.3} />
                <stop offset="100%" stopColor="hsl(0, 75%, 60%)" stopOpacity={0} />
              </linearGradient>
            </defs>

            {/*  REAL TIME axis: numeric timestamps spaced correctly */}
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

      {data.length === 0 && (
        <p className="mt-3 text-sm text-muted-foreground">
          No heartRate values found in epochArray.
        </p>
      )}
    </div>
  );
}
