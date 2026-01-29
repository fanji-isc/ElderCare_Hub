import { useEffect, useMemo, useState } from "react";
import ecgJson from "../data/ecg.json"; // adjust if needed: "@/data/ecg.json"

type EcgRecord = {
  summary: {
    rhythmClassification?: string;
    averageHeartRateInBeatsPerMinute?: number;
    heartRateAverage?: number; // some exports use this name
    startTimeLocal?: string;
  };
  reading: {
    sampleRate: number;
    samples: number[];
    leadType?: string;
  };
  processingInfo?: unknown;
};

export function ECGVisualization() {
  // Your JSON is an array, so pick the first record (or choose by index later)
  const ecg = (ecgJson as EcgRecord[])[0];

  const samples = ecg.reading.samples;
  const sampleRate = ecg.reading.sampleRate; // e.g. 128
  const width = 400;
  const height = 100;
  const speedMultiplier = 0.5;

  // How many seconds of signal to show on screen
  const windowSeconds = 5;
  const windowSize = Math.max(10, Math.floor(windowSeconds * sampleRate));

  // Playhead in "samples"
  const [sampleOffset, setSampleOffset] = useState(0);

  // Animate at ~30fps, advancing by the right number of samples per tick
  useEffect(() => {
    if (!samples?.length || !sampleRate) return;

    const fps = 30;
    const step = Math.max(1, Math.floor(sampleRate / fps)* speedMultiplier); // samples per tick

    const interval = window.setInterval(() => {
      setSampleOffset((prev) => (prev + step) % samples.length);
    }, 1000 / fps);

    return () => window.clearInterval(interval);
  }, [sampleRate, samples?.length]);

  // Rolling window of samples ending at sampleOffset (wraps around)
  const windowedSamples = useMemo(() => {
    if (!samples?.length) return [];

    const end = sampleOffset;
    const start = end - windowSize;

    if (start >= 0) return samples.slice(start, end);

    // wrap around
    const head = samples.slice(samples.length + start);
    const tail = samples.slice(0, end);
    return head.concat(tail);
  }, [sampleOffset, windowSize, samples]);

  // Turn samples into an SVG path string
  const pathD = useMemo(() => {
    const midY = height / 2;
    const n = windowedSamples.length;
    if (n < 2) return `M 0 ${midY}`;

    // dynamic scaling based on the current window
    let min = Infinity;
    let max = -Infinity;
    for (const v of windowedSamples) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    if (min === max) {
      min -= 1;
      max += 1;
    }

    const scaleY = (height * 0.85) / (max - min); // keep padding
    const center = (min + max) / 2;

    const yFor = (v: number) => {
      const centered = v - center;
      return midY - centered * scaleY; // invert for SVG coords
    };

    let d = `M 0 ${yFor(windowedSamples[0])}`;
    for (let i = 1; i < n; i++) {
      const x = (i / (n - 1)) * width;
      d += ` L ${x} ${yFor(windowedSamples[i])}`;
    }
    return d;
  }, [windowedSamples]);

  const bpm =
    ecg.summary.averageHeartRateInBeatsPerMinute ??
    ecg.summary.heartRateAverage ??
    "—";

  const subtitle =
    ecg.summary.rhythmClassification ??
    (ecg.reading.leadType ? `Lead: ${ecg.reading.leadType}` : "ECG waveform");

  return (
    <div className="rounded-2xl bg-card p-6 shadow-card">
      <div className="mb-4 flex items-center justify-between">
        <div>
          <h3 className="text-heading font-display text-foreground">
            ECG Reading
          </h3>
          <p className="text-body-sm text-muted-foreground">{subtitle}</p>
        </div>
        <div className="flex items-center gap-2">
          <span className="relative flex h-3 w-3">
            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-success opacity-75"></span>
            <span className="relative inline-flex h-3 w-3 rounded-full bg-success"></span>
          </span>
          <span className="text-body-sm font-medium text-success">Normal</span>
        </div>
      </div>

      <div className="relative h-32 overflow-hidden rounded-xl bg-foreground/5">
        <svg
          viewBox={`0 0 ${width} ${height}`}
          className="absolute inset-0 h-full w-full"
          preserveAspectRatio="none"
        >
          <defs>
            <linearGradient id="ecgGradient" x1="0" y1="0" x2="1" y2="0">
              <stop
                offset="0%"
                stopColor="hsl(187, 60%, 42%)"
                stopOpacity={0.3}
              />
              <stop
                offset="50%"
                stopColor="hsl(187, 60%, 42%)"
                stopOpacity={1}
              />
              <stop
                offset="100%"
                stopColor="hsl(187, 60%, 42%)"
                stopOpacity={0.3}
              />
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

        {/* Grid overlay */}
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

      <div className="mt-4 grid grid-cols-3 gap-4 text-center">
        <div>
          <p className="text-display-sm font-display text-foreground">{bpm}</p>
          <p className="text-caption text-muted-foreground">BPM</p>
        </div>
        <div>
          <p className="text-display-sm font-display text-foreground">—</p>
          <p className="text-caption text-muted-foreground">PR Interval</p>
        </div>
        <div>
          <p className="text-display-sm font-display text-foreground">—</p>
          <p className="text-caption text-muted-foreground">QRS Duration</p>
        </div>
      </div>
    </div>
  );
}
