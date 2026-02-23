import { useEffect, useMemo, useState } from "react";
import { Activity } from "lucide-react";

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

export function ECGVisualization() {
  const [ecgJson, setEcgJson] = useState<EcgRecord[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [sampleOffset, setSampleOffset] = useState(0);

  // Fetch ECG JSON from your backend (which reads from IRIS)
  useEffect(() => {
    fetch("/api/ecg")
      .then(async (r) => {
        if (!r.ok) throw new Error(await r.text());
        return r.json();
      })
      .then((data) => {
        setEcgJson(data as EcgRecord[]);
        setError(null);
      })
      .catch((e) => setError(String(e)));
  }, []);

  // Wait until we have data
  const ecg = ecgJson?.[0];

  const width = 400;
  const height = 100;

  // Playback controls
  const windowSeconds = 5;
  const speedMultiplier = 0.5; // 0.5 = slower, 1 = real-time

  const samples = ecg?.reading.samples ?? [];
  const sampleRate = ecg?.reading.sampleRate ?? 250; // fallback

  const windowSize = useMemo(
    () => Math.max(10, Math.floor(windowSeconds * sampleRate)),
    [windowSeconds, sampleRate]
  );

  // Advance ECG playback (only when samples exist)
  useEffect(() => {
    if (!ecg || samples.length === 0) return;

    const fps = 30;
    const step = Math.max(1, Math.floor((sampleRate / fps) * speedMultiplier));

    const interval = setInterval(() => {
      setSampleOffset((prev) => (prev + step) % samples.length);
    }, 1000 / fps);

    return () => clearInterval(interval);
  }, [ecg, sampleRate, samples.length, speedMultiplier]);

  // Rolling window of samples
  const windowedSamples = useMemo(() => {
    if (samples.length === 0) return [];

    const end = sampleOffset;
    const start = end - windowSize;

    if (start >= 0) return samples.slice(start, end);

    // wrap around
    return samples
      .slice(samples.length + start)
      .concat(samples.slice(0, end));
  }, [sampleOffset, windowSize, samples]);

  // Convert samples → SVG path
  const pathD = useMemo(() => {
    const midY = height / 2;
    const n = windowedSamples.length;
    if (n < 2) return `M 0 ${midY}`;

    let min = Infinity;
    let max = -Infinity;
    for (const v of windowedSamples) {
      if (v < min) min = v;
      if (v > max) max = v;
    }

    // Flatline safety
    if (min === max) {
      min -= 0.01;
      max += 0.01;
    }

    const scaleY = (height * 0.85) / (max - min);
    const center = (min + max) / 2;

    const yFor = (v: number) => midY - (v - center) * scaleY;

    let d = `M 0 ${yFor(windowedSamples[0])}`;
    for (let i = 1; i < n; i++) {
      const x = (i / (n - 1)) * width;
      d += ` L ${x} ${yFor(windowedSamples[i])}`;
    }
    return d;
  }, [windowedSamples]);

  // Metadata formatting
  const startTime = ecg?.summary.startTimeLocal
    ? new Date(ecg.summary.startTimeLocal).toLocaleString()
    : "—";

  const bpm = ecg?.summary.heartRateAverage ?? "—";
  const hrv = ecg?.summary.rmssdHrv ?? "—";
  const duration = ecg?.reading.durationInSeconds ?? "—";

  if (error) {
    return (
      <div className="rounded-2xl bg-card p-6 shadow-card">
        <p className="text-sm text-destructive">Failed to load ECG: {error}</p>
      </div>
    );
  }

  if (!ecgJson) {
    return (
      <div className="rounded-2xl bg-card p-6 shadow-card">
        <p className="text-sm text-muted-foreground">Loading ECG…</p>
      </div>
    );
  }

  if (!ecg) {
    return (
      <div className="rounded-2xl bg-card p-6 shadow-card">
        <p className="text-sm text-muted-foreground">No ECG records found.</p>
      </div>
    );
  }

  return (
    <div className="rounded-2xl bg-card p-6 shadow-card">
      {/* Header */}
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-ecg text-primary-foreground">
            <Activity className="h-5 w-5" />
          </div>
          <div>
            <h3 className="text-heading font-display text-foreground">ECG Reading</h3>
            <p className="text-caption text-muted-foreground">
              {ecg.summary.rhythmClassification ?? "ECG waveform"}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span className="relative flex h-3 w-3">
            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-success opacity-75"></span>
            <span className="relative inline-flex h-3 w-3 rounded-full bg-success"></span>
          </span>
          <span className="text-caption font-medium text-success">Normal</span>
        </div>
      </div>

      {/* ECG Chart */}
      <div className="relative h-32 overflow-hidden rounded-xl bg-foreground/5">
        <svg
          viewBox={`0 0 ${width} ${height}`}
          className="absolute inset-0 h-full w-full"
          preserveAspectRatio="none"
        >
          <defs>
            <linearGradient id="ecgGradient" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stopColor="hsl(187, 60%, 42%)" stopOpacity={0.3} />
              <stop offset="50%" stopColor="hsl(187, 60%, 42%)" stopOpacity={1} />
              <stop offset="100%" stopColor="hsl(187, 60%, 42%)" stopOpacity={0.3} />
            </linearGradient>
          </defs>

          <path
            d={pathD}
            fill="none"
            stroke="url(#ecgGradient)"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>

        {/* Grid */}
        <div
          className="absolute inset-0 opacity-10"
          style={{
            backgroundImage: `
              linear-gradient(to right, hsl(187, 60%, 42%) 1px, transparent 1px),
              linear-gradient(to bottom, hsl(187, 60%, 42%) 1px, transparent 1px)
            `,
            backgroundSize: "20px 20px",
          }}
        />
      </div>

      {/* Info Panel */}
      <div className="mt-4 grid grid-cols-2 gap-4 text-center md:grid-cols-4">
        <div>
          <p className="text-display-sm font-display text-foreground">{bpm}</p>
          <p className="text-caption text-muted-foreground">BPM</p>
        </div>

        <div>
          <p className="text-display-sm font-display text-foreground">{hrv}</p>
          <p className="text-caption text-muted-foreground">HRV (RMSSD)</p>
        </div>

        <div>
          <p className="text-display-sm font-display text-foreground">{duration}s</p>
          <p className="text-caption text-muted-foreground">Duration</p>
        </div>

        <div>
          <p className="text-display-sm font-display text-foreground">{startTime}</p>
          <p className="text-caption text-muted-foreground">Start Time</p>
        </div>
      </div>
    </div>
  );
}
