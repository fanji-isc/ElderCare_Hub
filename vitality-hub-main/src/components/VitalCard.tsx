import { ReactNode } from "react";
import { cn } from "@/lib/utils";

interface VitalCardProps {
  title: string;
  value: string | number;
  unit?: string;
  subtitle?: string;
  icon: ReactNode;
  trend?: "up" | "down" | "stable";
  trendValue?: string;
  variant?: "heart" | "sleep" | "ecg" | "stress" | "fall" | "default";
  className?: string;
}

const variantStyles = {
  heart: "bg-heart/10 text-heart",
  sleep: "bg-sleep/10 text-sleep",
  ecg: "bg-ecg/10 text-ecg",
  stress: "bg-stress/10 text-stress",
  fall: "bg-fall/10 text-fall",
  default: "bg-primary/10 text-primary",
};

const iconBgStyles = {
  heart: "bg-heart",
  sleep: "bg-sleep",
  ecg: "bg-ecg",
  stress: "bg-stress",
  fall: "bg-fall",
  default: "bg-primary",
};

export function VitalCard({
  title,
  value,
  unit,
  subtitle,
  icon,
  trend,
  trendValue,
  variant = "default",
  className,
}: VitalCardProps) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-2xl bg-card p-6 shadow-card transition-all duration-300 hover:shadow-glow hover:-translate-y-1",
        className
      )}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-3">
            <div
              className={cn(
                "flex h-10 w-10 items-center justify-center rounded-xl text-primary-foreground",
                iconBgStyles[variant]
              )}
            >
              {icon}
            </div>
            <span className="text-body-sm font-medium text-muted-foreground">
              {title}
            </span>
          </div>

          <div className="flex items-baseline gap-1.5">
            <span className="text-display font-display tracking-tight">
              {value}
            </span>
            {unit && (
              <span className="text-body text-muted-foreground">{unit}</span>
            )}
          </div>

          {(trend || subtitle) && (
            <div className="mt-2 flex items-center gap-2">
              {trend && (
                <span
                  className={cn(
                    "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-caption font-medium",
                    trend === "up" && "bg-success/10 text-success",
                    trend === "down" && "bg-destructive/10 text-destructive",
                    trend === "stable" && "bg-muted text-muted-foreground"
                  )}
                >
                  {trend === "up" && "↑"}
                  {trend === "down" && "↓"}
                  {trend === "stable" && "→"}
                  {trendValue}
                </span>
              )}
              {subtitle && (
                <span className="text-caption text-muted-foreground">
                  {subtitle}
                </span>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Decorative gradient */}
      <div
        className={cn(
          "absolute -right-8 -top-8 h-32 w-32 rounded-full opacity-20 blur-2xl",
          iconBgStyles[variant]
        )}
      />
    </div>
  );
}
