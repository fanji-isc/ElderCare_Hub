import { Brain } from "lucide-react";

export function StressIndicator() {
  const stressLevel = 35; // Low stress percentage
  const circumference = 2 * Math.PI * 45;
  const strokeDashoffset = circumference - (stressLevel / 100) * circumference;

  const getStressStatus = (level: number) => {
    if (level < 30) return { text: "Relaxed", color: "text-success" };
    if (level < 50) return { text: "Low Stress", color: "text-success" };
    if (level < 70) return { text: "Moderate", color: "text-warning" };
    return { text: "High Stress", color: "text-destructive" };
  };

  const status = getStressStatus(stressLevel);

  return (
    <div className="rounded-2xl bg-card p-6 shadow-card">
      <div className="mb-4 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-stress text-primary-foreground">
          <Brain className="h-5 w-5" />
        </div>
        <div>
          <h3 className="text-heading font-display text-foreground">Stress Level</h3>
          <p className="text-body-sm text-muted-foreground">Based on HRV analysis</p>
        </div>
      </div>

      <div className="flex items-center justify-center py-6">
        <div className="relative">
          <svg className="h-36 w-36 -rotate-90 transform">
            {/* Background circle */}
            <circle
              cx="72"
              cy="72"
              r="45"
              stroke="hsl(var(--muted))"
              strokeWidth="10"
              fill="none"
            />
            {/* Progress circle */}
            <circle
              cx="72"
              cy="72"
              r="45"
              stroke="hsl(var(--stress))"
              strokeWidth="10"
              fill="none"
              strokeLinecap="round"
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              className="transition-all duration-1000 ease-out"
            />
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <span className="text-display font-display text-foreground">{stressLevel}%</span>
            <span className={`text-body-sm font-medium ${status.color}`}>{status.text}</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4 border-t border-border pt-4">
        <div className="text-center">
          <p className="text-display-sm font-display text-foreground">48ms</p>
          <p className="text-caption text-muted-foreground">HRV Average</p>
        </div>
        <div className="text-center">
          <p className="text-display-sm font-display text-foreground">6.2</p>
          <p className="text-caption text-muted-foreground">Recovery Score</p>
        </div>
      </div>
    </div>
  );
}
