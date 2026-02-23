import { useEffect, useState } from "react";
import { Heart, Moon, Footprints, Activity, Upload } from "lucide-react";
import { Header } from "@/components/Header";
import { VitalCard } from "@/components/VitalCard";
import { HeartRateChart } from "@/components/HeartRateCharttest";
import { ECGVisualization } from "@/components/ECGVisualization";
import { SleepChart } from "@/components/SleepChart";
import { HydrationIndicator } from "@/components/HydrationIndicator";
import { WalkingActivityChart } from "@/components/WalkingActivityChart";
import { ShareWithProvider } from "@/components/ShareWithProvider";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import VoiceAssistantPanel from "@/components/VoiceAssistantPanel";

type Vitals = {
  heartRate: number;   // dailySummary
  steps: number;       // dailySummary
  stressLevel: number; // dailySummary allDayStress AWAKE averageStressLevel
  sleepHours: number;  // /api/sleep list (deep+light+rem)
};

const API_BASE = "http://localhost:3001";
const PATIENT_ID = "PATIENT_001";

// Pick latest daily record by calendarDate (YYYY-MM-DD)
function pickLatestByCalendarDate(list: any[]): any | null {
  if (!Array.isArray(list) || list.length === 0) return null;
  return [...list].sort((a, b) =>
    String(b?.calendarDate || "").localeCompare(String(a?.calendarDate || ""))
  )[0];
}

function extractStress(latestDay: any): number {
  const aggregators = latestDay?.allDayStress?.aggregatorList ?? [];
  const awake = aggregators.find((a: any) => a.type === "AWAKE");
  return Math.round(Number(awake?.averageStressLevel ?? 0));
}

function stressLabel(v: number): string {
  if (v === 0) return "Today";
  if (v <= 25) return "Low stress";
  if (v <= 50) return "Moderate";
  if (v <= 75) return "High stress";
  return "Very high";
}

// Your /api/sleep returns a LIST of sleep records. Compute hours from deep+light+rem.
function extractSleepHoursFromGarminList(sleepJson: any): number {
  if (!Array.isArray(sleepJson)) return 0;

  const records = sleepJson.filter((x: any) =>
    typeof x?.calendarDate === "string" &&
    (x?.deepSleepSeconds != null || x?.lightSleepSeconds != null || x?.remSleepSeconds != null)
  );

  if (records.length === 0) return 0;

  const latest = pickLatestByCalendarDate(records);
  if (!latest) return 0;

  const deep = Number(latest.deepSleepSeconds ?? 0);
  const light = Number(latest.lightSleepSeconds ?? 0);
  const rem = Number(latest.remSleepSeconds ?? 0);

  const totalSleepSeconds = deep + light + rem;
  return totalSleepSeconds / 3600;
}

const Index = () => {
  const handleImportData = () => {
    toast.info("Health data import coming soon!", {
      description: "Connect to InterSystems IRIS to sync your export.xml data",
    });
  };

  const [vitals, setVitals] = useState<Vitals>({
    heartRate: 0,
    steps: 0,
    stressLevel: 0,
    sleepHours: 0,
  });

  useEffect(() => {
    (async () => {
      try {
        const [dailyRes, sleepRes] = await Promise.all([
          fetch(`${API_BASE}/api/dailySummary?patient_id=${encodeURIComponent(PATIENT_ID)}`),
          fetch(`${API_BASE}/api/sleep?patient_id=${encodeURIComponent(PATIENT_ID)}`),
        ]);

        const dailyJson = dailyRes.ok ? await dailyRes.json() : [];
        const sleepJson = sleepRes.ok ? await sleepRes.json() : [];

        const latestDay = Array.isArray(dailyJson) ? pickLatestByCalendarDate(dailyJson) : null;

        const heartRate = Number(
          latestDay?.currentDayRestingHeartRate ?? latestDay?.restingHeartRate ?? 0
        );

        const steps = Number(latestDay?.totalSteps ?? 0);

        const stressLevel = extractStress(latestDay);

        const sleepHours = extractSleepHoursFromGarminList(sleepJson);

        setVitals({ heartRate, steps, stressLevel, sleepHours });
      } catch (e) {
        console.log("Vitals fetch error:", e);
      }
    })();
  }, []);

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="container mx-auto px-4 py-8">
        {/* Welcome Section */}
        <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-display-sm font-display text-foreground">
              Good morning, Fan
            </h2>
            <p className="text-body-lg text-muted-foreground">
              Here's your health overview for today
            </p>
          </div>

          <div className="flex items-center gap-3">
            <VoiceAssistantPanel />
            <Button onClick={handleImportData}>
              <Upload className="mr-2 h-4 w-4" />
              Import Data
            </Button>
          </div>
        </div>

        {/* Vital Cards */}
        <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <VitalCard
            title="Resting Heart Rate"
            value={vitals.heartRate}
            unit="BPM"
            icon={<Heart className="h-5 w-5" />}
            variant="heart"
            trend="stable"
            trendValue="Today"
            subtitle=""
          />

          <VitalCard
            title="Sleep"
            value={vitals.sleepHours ? vitals.sleepHours.toFixed(1) : "—"}
            unit={vitals.sleepHours ? "hours" : ""}
            icon={<Moon className="h-5 w-5" />}
            variant="sleep"
            trend="stable"
            trendValue="Last night"
            subtitle=""
          />

          <VitalCard
            title="Steps"
            value={vitals.steps}
            unit=""
            icon={<Footprints className="h-5 w-5" />}
            variant="ecg"
            trend="stable"
            trendValue="Today"
            subtitle=""
          />

          <VitalCard
            title="Stress Level"
            value={vitals.stressLevel || "—"}
            unit={vitals.stressLevel ? "/ 100" : ""}
            icon={<Activity className="h-5 w-5" />}
            variant="stress"
            trend="stable"
            trendValue={stressLabel(vitals.stressLevel)}
            subtitle=""
          />
        </div>

        {/* Charts */}
        <div className="mb-8 grid gap-6 lg:grid-cols-2">
          <HeartRateChart />
          <ECGVisualization />
        </div>

        <div className="mb-8 grid gap-6 lg:grid-cols-2">
          <SleepChart />
          <HydrationIndicator />
        </div>

        {/* Gait Analysis + Share */}
        <div className="mb-8 grid gap-6 lg:grid-cols-2">
          <WalkingActivityChart />
          <ShareWithProvider />
        </div>
      </main>
    </div>
  );
};

export default Index;
