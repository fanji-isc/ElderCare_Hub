import { useEffect, useState } from "react";
import { Droplets } from "lucide-react";

// Urine color scale (1–8) used clinically to assess hydration.
const COLOR_SCALE = [
  { level: 1, hex: "#FEFBE4", label: "Pale Straw",  status: "Excellent",        statusColor: "text-success" },
  { level: 2, hex: "#F5EB6E", label: "Straw",        status: "Well Hydrated",    statusColor: "text-success" },
  { level: 3, hex: "#ECD93E", label: "Yellow",       status: "Normal",           statusColor: "text-success" },
  { level: 4, hex: "#D4B800", label: "Dark Yellow",  status: "Drink More Water", statusColor: "text-warning" },
  { level: 5, hex: "#BF9420", label: "Amber",        status: "Mild Dehydration", statusColor: "text-warning" },
  { level: 6, hex: "#9E7020", label: "Dark Amber",   status: "Dehydrated",       statusColor: "text-destructive" },
  { level: 7, hex: "#7A4E18", label: "Brown",        status: "Very Dehydrated",  statusColor: "text-destructive" },
  { level: 8, hex: "#4A2D0A", label: "Very Dark",    status: "See a Doctor",     statusColor: "text-destructive" },
];

const API_BASE = "http://localhost:3001";
const PATIENT_ID = "PATIENT_001";

function pickLatestByCalendarDate(list: any[]): any | null {
  if (!Array.isArray(list) || list.length === 0) return null;
  return [...list].sort((a, b) =>
    String(b?.calendarDate || "").localeCompare(String(a?.calendarDate || ""))
  )[0];
}

function getTimeOfDay(timestamp: string): string {
  try {
    const hour = new Date(timestamp).getHours();
    if (hour < 6)  return "Night";
    if (hour < 12) return "Morning";
    if (hour < 14) return "Midday";
    if (hour < 18) return "Afternoon";
    if (hour < 21) return "Evening";
    return "Night";
  } catch {
    return "";
  }
}

function formatDateTime(timestamp: string): { date: string; time: string } {
  try {
    const d = new Date(timestamp);
    return {
      date: d.toLocaleDateString([], { month: "short", day: "numeric", year: "numeric" }),
      time: d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
    };
  } catch {
    return { date: "—", time: "—" };
  }
}

export function HydrationIndicator() {
  const [detectedLevel, setDetectedLevel] = useState<number>(1);
  const [lastReading, setLastReading] = useState<{ date: string; time: string }>({ date: "—", time: "—" });
  const [timeOfDay, setTimeOfDay] = useState<string>("");
  const [readingsToday, setReadingsToday] = useState<number>(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch(
          `${API_BASE}/api/toilet?patient_id=${encodeURIComponent(PATIENT_ID)}`
        );
        const json = res.ok ? await res.json() : [];
        const latest = pickLatestByCalendarDate(Array.isArray(json) ? json : []);
        if (latest) {
          const readings: any[] = Array.isArray(latest.readings) ? latest.readings : [];
          const lastRead = readings[readings.length - 1];
          if (lastRead) {
            const level = Number(lastRead.colorLevel);
            setDetectedLevel(Math.min(8, Math.max(1, level)));
            setLastReading(formatDateTime(lastRead.timestamp));
            setTimeOfDay(getTimeOfDay(lastRead.timestamp));
          }
          setReadingsToday(readings.length);
        }
      } catch (e) {
        console.log("Toilet fetch error:", e);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const detected = COLOR_SCALE[detectedLevel - 1];

  return (
    <div className="rounded-2xl bg-card shadow-card overflow-hidden">
      {/* Header */}
      <div className="flex items-center gap-3 border-b border-border bg-gradient-to-r from-cyan-50 to-sky-50 px-6 py-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-stress text-primary-foreground">
          <Droplets className="h-5 w-5" />
        </div>
        <div className="flex-1">
          <h3 className="text-heading font-display text-foreground">Hydration Level</h3>
          <p className="text-caption text-muted-foreground">Smart toilet · urine color detection</p>
        </div>
      </div>

      <div className="p-6">
        {loading ? (
          <div className="flex items-center justify-center py-12 text-muted-foreground text-sm">
            Loading…
          </div>
        ) : (
          <>
            {/* Color scale */}
            <div className="py-4">
              <div className="mb-2 flex gap-1">
                {COLOR_SCALE.map((c) => (
                  <div key={c.level} className="flex flex-1 flex-col items-center gap-1">
                    <div
                      className="relative h-8 w-full rounded-md"
                      style={{
                        backgroundColor: c.hex,
                        border: c.level === detectedLevel
                          ? "2px solid hsl(var(--foreground))"
                          : "2px solid transparent",
                      }}
                    >
                      {c.level === detectedLevel && (
                        <div className="absolute -top-2 left-1/2 -translate-x-1/2">
                          <div className="h-0 w-0 border-x-4 border-b-4 border-x-transparent border-b-foreground" />
                        </div>
                      )}
                    </div>
                    <span className="text-[10px] text-muted-foreground">{c.level}</span>
                  </div>
                ))}
              </div>
              <div className="flex justify-between text-[10px] text-muted-foreground">
                <span>Well hydrated</span>
                <span>Dehydrated</span>
              </div>
            </div>

            {/* Current reading */}
            <div
              className="mb-4 flex items-center gap-3 rounded-xl p-3"
              style={{ backgroundColor: detected.hex + "33" }}
            >
              <div
                className="h-10 w-10 flex-shrink-0 rounded-lg border border-border"
                style={{ backgroundColor: detected.hex }}
              />
              <div>
                <p className={`text-body-sm font-semibold ${detected.statusColor}`}>{detected.status}</p>
                <p className="text-caption text-muted-foreground">
                  Level {detected.level} · {detected.label}
                </p>
                {timeOfDay && (
                  <p className="text-[11px] text-muted-foreground italic mt-0.5">{timeOfDay}</p>
                )}
              </div>
            </div>

            {/* Footer stats */}
            <div className="grid grid-cols-2 gap-4 border-t border-border pt-4">
              <div className="text-center">
                <p className="text-display-sm font-display text-foreground">{lastReading.time}</p>
                <p className="text-body-sm text-foreground">{lastReading.date}</p>
                <p className="text-caption text-muted-foreground">Last Reading</p>
              </div>
              <div className="text-center">
                <p className="text-display-sm font-display text-foreground">{readingsToday}x</p>
                <p className="text-caption text-muted-foreground">Readings Today</p>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
