import { useEffect, useState } from "react";
import { Droplets } from "lucide-react";

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
  } catch { return ""; }
}

function formatDateTime(timestamp: string): { date: string; time: string } {
  try {
    const d = new Date(timestamp);
    return {
      date: d.toLocaleDateString([], { month: "short", day: "numeric", year: "numeric" }),
      time: d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
    };
  } catch { return { date: "—", time: "—" }; }
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
        const res = await fetch(`${API_BASE}/api/toilet?patient_id=${encodeURIComponent(PATIENT_ID)}`);
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
      <div className="flex items-center gap-3 border-b border-border bg-gradient-to-r from-cyan-50 to-sky-50 px-5 py-3.5">
        <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-stress text-primary-foreground">
          <Droplets className="h-4 w-4" />
        </div>
        <div className="flex-1">
          <h3 className="text-sm font-semibold text-foreground leading-tight">Hydration Level</h3>
          <p className="text-xs text-muted-foreground">Smart toilet · urine color detection</p>
        </div>
        {!loading && (
          <div className="flex-shrink-0 rounded-full px-2.5 py-1 text-xs font-medium"
            style={{ backgroundColor: detected.hex + "55", color: detected.hex === "#FEFBE4" ? "#a0900a" : detected.hex }}>
            Lvl {detectedLevel}
          </div>
        )}
      </div>

      <div className="p-5">
        {loading ? (
          <div className="flex items-center justify-center py-10 text-muted-foreground text-sm">Loading…</div>
        ) : (
          <div className="space-y-4">

            {/* Color scale strip */}
            <div>
              <div className="flex gap-1 mb-1">
                {COLOR_SCALE.map((c) => (
                  <div key={c.level} className="relative flex flex-1 flex-col items-center">
                    <div
                      className="h-7 w-full rounded-md transition-all"
                      style={{
                        backgroundColor: c.hex,
                        outline: c.level === detectedLevel ? "2px solid hsl(var(--foreground))" : "none",
                        outlineOffset: "1px",
                        transform: c.level === detectedLevel ? "scaleY(1.15)" : "scaleY(1)",
                      }}
                    />
                    {c.level === detectedLevel && (
                      <div className="absolute -bottom-2.5">
                        <div className="h-0 w-0 border-x-[4px] border-t-[5px] border-x-transparent border-t-foreground" />
                      </div>
                    )}
                  </div>
                ))}
              </div>
              <div className="mt-3 flex justify-between text-[10px] text-muted-foreground px-0.5">
                <span>Well hydrated</span>
                <span>See a doctor</span>
              </div>
            </div>

            {/* Current status badge */}
            <div
              className="flex items-center gap-3 rounded-xl border px-4 py-3"
              style={{ backgroundColor: detected.hex + "22", borderColor: detected.hex + "66" }}
            >
              <div
                className="h-9 w-9 flex-shrink-0 rounded-lg shadow-sm"
                style={{ backgroundColor: detected.hex, border: "1px solid rgba(0,0,0,0.1)" }}
              />
              <div className="min-w-0">
                <p className={`text-sm font-semibold leading-tight ${detected.statusColor}`}>{detected.status}</p>
                <p className="text-xs text-muted-foreground">Level {detected.level} · {detected.label}</p>
              </div>
              {timeOfDay && (
                <span className="ml-auto text-xs text-muted-foreground italic flex-shrink-0">{timeOfDay}</span>
              )}
            </div>

            {/* Footer stats */}
            <div className="grid grid-cols-2 gap-3 border-t border-border pt-4">
              {/* Last Reading */}
              <div className="rounded-lg bg-muted/40 px-3 py-2.5 text-center">
                <p className="text-base font-bold text-foreground leading-none">{lastReading.time}</p>
                <p className="mt-0.5 text-xs text-muted-foreground">{lastReading.date}</p>
                <p className="mt-1 text-[11px] text-muted-foreground">Last Reading</p>
              </div>
              {/* Readings Today */}
              <div className="rounded-lg bg-muted/40 px-3 py-2.5 text-center">
                <p className="text-2xl font-bold text-foreground leading-none">{readingsToday}</p>
                <p className="mt-0.5 text-xs text-muted-foreground">times</p>
                <p className="mt-1 text-[11px] text-muted-foreground">Today</p>
              </div>
            </div>

          </div>
        )}
      </div>
    </div>
  );
}
