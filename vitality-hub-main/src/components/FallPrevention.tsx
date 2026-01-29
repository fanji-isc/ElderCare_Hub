import { AlertTriangle, CheckCircle2, Shield } from "lucide-react";

interface RiskFactor {
  name: string;
  level: "low" | "medium" | "high";
  description: string;
}

const riskFactors: RiskFactor[] = [
  { name: "Balance", level: "low", description: "Steady gait detected" },
  { name: "Mobility", level: "low", description: "Normal movement patterns" },
  { name: "Medication", level: "medium", description: "Check dizziness side effects" },
  { name: "Environment", level: "low", description: "Home safety verified" },
];

const getRiskColor = (level: string) => {
  switch (level) {
    case "low":
      return "text-success bg-success/10";
    case "medium":
      return "text-warning bg-warning/10";
    case "high":
      return "text-destructive bg-destructive/10";
    default:
      return "text-muted-foreground bg-muted";
  }
};

const getRiskIcon = (level: string) => {
  switch (level) {
    case "low":
      return <CheckCircle2 className="h-4 w-4" />;
    case "medium":
    case "high":
      return <AlertTriangle className="h-4 w-4" />;
    default:
      return <CheckCircle2 className="h-4 w-4" />;
  }
};

export function FallPrevention() {
  const overallRisk = riskFactors.every((r) => r.level === "low") ? "Low" : "Moderate";

  return (
    <div className="rounded-2xl bg-card p-6 shadow-card">
      <div className="mb-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-fall text-primary-foreground">
            <Shield className="h-6 w-6" />
          </div>
          <div>
            <h3 className="text-heading font-display text-foreground">Fall Prevention</h3>
            <p className="text-body-sm text-muted-foreground">Risk assessment</p>
          </div>
        </div>
        <div className="rounded-full bg-success/10 px-4 py-2">
          <span className="text-body font-medium text-success">{overallRisk} Risk</span>
        </div>
      </div>

      <div className="space-y-3">
        {riskFactors.map((factor) => (
          <div
            key={factor.name}
            className="flex items-center justify-between rounded-xl bg-muted/50 p-4 transition-colors hover:bg-muted"
          >
            <div className="flex items-center gap-3">
              <span
                className={`flex h-8 w-8 items-center justify-center rounded-lg ${getRiskColor(factor.level)}`}
              >
                {getRiskIcon(factor.level)}
              </span>
              <div>
                <p className="text-body font-medium text-foreground">{factor.name}</p>
                <p className="text-caption text-muted-foreground">{factor.description}</p>
              </div>
            </div>
            <span
              className={`rounded-full px-3 py-1 text-caption font-medium capitalize ${getRiskColor(factor.level)}`}
            >
              {factor.level}
            </span>
          </div>
        ))}
      </div>

      <div className="mt-6 rounded-xl bg-primary/5 p-4">
        <p className="text-body-sm text-foreground">
          <strong>Recommendation:</strong> Continue regular balance exercises. Next assessment scheduled in 7 days.
        </p>
      </div>
    </div>
  );
}
