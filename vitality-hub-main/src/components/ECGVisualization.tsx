import React, { useEffect, useMemo, useState } from "react";
import { Activity, Clock } from "lucide-react";

type EcgRecord = {
  summary: {
    startTimeLocal?: string;
    rhythmClassification?: string;
    heartRateAverage?: number;
    rmssdHrv?: number;
  };
  reading: {
    sampleRate: number;
    durationInSeconds: number;
    samples: number[];
  };
};

function formatStartTime(raw: string | undefined): { date: string; time: string } {
  if (!raw) return { date: "—", time: "—" };
  try {
    const d = new Date(raw);
    return {
      date: d.toLocaleDateString([], { month: "short", day: "numeric", year: "numeric" }),
      time: d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
    };
  } catch {
    return { date: "—", time: "—" };
  }
}

export function ECGVisualization() {
  const [ecgJson, setEcgJson] = useState<EcgRecord[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [sampleOffset, setSampleOffset] = useState(0);

  useEffect(() => {
    fetch("/api/ecg")
      .then(async (r) => {
        if (!r.ok) throw new Error(await r.text());
        return r.json();
      })
      .then((data) => { setEcgJson(data as EcgRecord[]); setError(null); })
      .catch((e) => setError(String(e)));
  }, []);

  const ecg = ecgJson?.[0];
  const width = 400;
  const height = 100;
  const windowSeconds = 5;
  const speedMultiplier = 0.5;
  const samples = ecg?.reading.samples ?? [];
  const sampleRate = ecg?.reading.sampleRate ?? 250;

  const windowSize = useMemo(
    () => Math.max(10, Math.floor(windowSeconds * sampleRate)),
    [windowSeconds, sampleRate]
  );

  useEffect(() => {
    if (!ecg || samples.length === 0) return;
    const fps = 30;
    const step = Math.max(1, Math.floor((sampleRate / fps) * speedMultiplier));
    const interval = setInterval(() => {
      setSampleOffset((prev) => (prev + step) % samples.length);
    }, 1000 / fps);
    return () => clearInterval(interval);
  }, [ecg, sampleRate, samples.length, speedMultiplier]);

  const windowedSamples = useMemo(() => {
    if (samples.length === 0) return [];
    const end = sampleOffset;
    const start = end - windowSize;
    if (start >= 0) return samples.slice(start, end);
    return samples.slice(samples.length + start).concat(samples.slice(0, end));
  }, [sampleOffset, windowSize, samples]);

  const pathD = useMemo(() => {
    const midY = height / 2;
    const n = windowedSamples.length;
    if (n < 2) return `M 0 ${midY}`;
    let min = Infinity, max = -Infinity;
    for (const v of windowedSamples) { if (v < min) min = v; if (v > max) max = v; }
    if (min === max) { min -= 0.01; max += 0.01; }
    const scaleY = (height * 0.85) / (max - min);
    const center = (min + max) / 2;
    const yFor = (v: number) => midY - (v - center) * scaleY;
    let d = `M 0 ${yFor(windowedSamples[0])}`;
    for (let i = 1; i < n; i++) d += ` L ${(i / (n - 1)) * width} ${yFor(windowedSamples[i])}`;
    return d;
  }, [windowedSamples]);

  const bpm      = ecg?.summary.heartRateAverage ?? "—";
  const hrv      = ecg?.summary.rmssdHrv ?? "—";
  const duration = ecg?.reading.durationInSeconds ?? "—";
  const { date: startDate, time: startTime } = formatStartTime(ecg?.summary.startTimeLocal);

  const CardShell = ({ children }: { children: React.ReactNode }) => (
    <div className="rounded-2xl bg-card shadow-card overflow-hidden">{children}</div>
  );

  const Header = () => (
    <div className="flex items-center gap-3 border-b border-border bg-gradient-to-r from-emerald-50 to-teal-50 px-5 py-3.5">
      <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-ecg text-primary-foreground">
        <Activity className="h-4 w-4" />
      </div>
      <div className="flex-1 min-w-0">
        <h3 className="text-sm font-semibold text-foreground leading-tight">ECG Reading</h3>
        <p className="text-xs text-muted-foreground truncate">
          {ecg?.summary.rhythmClassification ?? "ECG waveform"}
        </p>
      </div>
      {ecg && (
        <div className="flex items-center gap-1.5 flex-shrink-0">
          <span className="relative flex h-2.5 w-2.5">
            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-success opacity-75" />
            <span className="relative inline-flex h-2.5 w-2.5 rounded-full bg-success" />
          </span>
          <span className="text-xs font-medium text-success">Live</span>
        </div>
      )}
    </div>
  );

  if (error) return (
    <CardShell><Header />
      <div className="p-5"><p className="text-sm text-destructive">Failed to load ECG: {error}</p></div>
    </CardShell>
  );

  if (!ecgJson) return (
    <CardShell><Header />
      <div className="flex items-center justify-center h-44">
        <p className="text-sm text-muted-foreground">Loading ECG…</p>
      </div>
    </CardShell>
  );

  if (!ecg) return (
    <CardShell><Header />
      <div className="flex items-center justify-center h-44">
        <p className="text-sm text-muted-foreground">No ECG records found.</p>
      </div>
    </CardShell>
  );

  return (
    <CardShell>
      <Header />
      <div className="p-5 space-y-4">

        {/* Waveform */}
        <div className="relative h-[140px] overflow-hidden rounded-xl bg-slate-950">
          <svg
            viewBox={`0 0 ${width} ${height}`}
            className="absolute inset-0 h-full w-full"
            preserveAspectRatio="none"
          >
            <defs>
              <linearGradient id="ecgGradient" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0%"   stopColor="hsl(187, 60%, 52%)" stopOpacity={0.2} />
                <stop offset="40%"  stopColor="hsl(187, 60%, 52%)" stopOpacity={1} />
                <stop offset="60%"  stopColor="hsl(187, 60%, 52%)" stopOpacity={1} />
                <stop offset="100%" stopColor="hsl(187, 60%, 52%)" stopOpacity={0.2} />
              </linearGradient>
            </defs>
            <path
              d={pathD}
              fill="none"
              stroke="url(#ecgGradient)"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
          {/* ECG grid overlay */}
          <div
            className="absolute inset-0 opacity-[0.07]"
            style={{
              backgroundImage: `
                linear-gradient(to right, hsl(187, 60%, 52%) 1px, transparent 1px),
                linear-gradient(to bottom, hsl(187, 60%, 52%) 1px, transparent 1px)
              `,
              backgroundSize: "20px 20px",
            }}
          />
        </div>

        {/* Metrics row */}
        <div className="grid grid-cols-4 gap-2">
          {/* BPM */}
          <div className="rounded-lg bg-muted/50 px-3 py-2.5 text-center">
            <p className="text-xl font-bold text-foreground leading-none">{bpm}</p>
            <p className="mt-1 text-[11px] text-muted-foreground">BPM</p>
          </div>

          {/* HRV */}
          <div className="rounded-lg bg-muted/50 px-3 py-2.5 text-center">
            <p className="text-xl font-bold text-foreground leading-none">{hrv}</p>
            <p className="mt-1 text-[11px] text-muted-foreground">HRV ms</p>
          </div>

          {/* Duration */}
          <div className="rounded-lg bg-muted/50 px-3 py-2.5 text-center">
            <p className="text-xl font-bold text-foreground leading-none">{duration}<span className="text-sm font-normal">s</span></p>
            <p className="mt-1 text-[11px] text-muted-foreground">Duration</p>
          </div>

          {/* Start Time — compact, no giant font */}
          <div className="rounded-lg bg-muted/50 px-3 py-2.5 text-center">
            <div className="flex items-center justify-center gap-1 mb-0.5">
              <Clock className="h-3 w-3 text-muted-foreground" />
              <p className="text-xs font-semibold text-foreground">{startTime}</p>
            </div>
            <p className="text-[11px] text-muted-foreground">{startDate}</p>
            <p className="mt-0.5 text-[11px] text-muted-foreground">Recorded</p>
          </div>
        </div>

      </div>
    </CardShell>
  );
}
