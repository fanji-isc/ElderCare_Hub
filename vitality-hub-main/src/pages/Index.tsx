import { Heart, Moon, Activity, Zap, Upload } from "lucide-react";
import { Header } from "@/components/Header";
import { VitalCard } from "@/components/VitalCard";
import { HeartRateChart } from "@/components/HeartRateChart";
import { ECGVisualization } from "@/components/ECGVisualization";
import { SleepChart } from "@/components/SleepChart";
import { StressIndicator } from "@/components/StressIndicator";
import { FallPrevention } from "@/components/FallPrevention";
import { ShareWithProvider } from "@/components/ShareWithProvider";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

const Index = () => {
  const handleImportData = () => {
    toast.info("Health data import coming soon!", {
      description: "Connect to InterSystems IRIS to sync your export.xml data",
    });
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="container mx-auto px-4 py-8">
        {/* Welcome Section */}
        <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-display-sm font-display text-foreground">Good morning, Fan</h2>
            <p className="text-body-lg text-muted-foreground">
              Here's your health overview for today
            </p>
          </div>
          <Button onClick={handleImportData} className="bg-primary hover:bg-primary/90">
            <Upload className="mr-2 h-4 w-4" />
            Import Data
          </Button>
        </div>

        {/* Vital Signs Grid */}
        <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <VitalCard
            title="Heart Rate"
            value={72}
            unit="BPM"
            icon={<Heart className="h-5 w-5" />}
            variant="heart"
            trend="stable"
            trendValue="Normal"
            subtitle="Resting"
          />
          <VitalCard
            title="Sleep"
            value="7.5"
            unit="hours"
            icon={<Moon className="h-5 w-5" />}
            variant="sleep"
            trend="up"
            trendValue="+0.5h"
            subtitle="Last night"
          />
          <VitalCard
            title="Blood Oxygen"
            value={98}
            unit="%"
            icon={<Activity className="h-5 w-5" />}
            variant="ecg"
            trend="stable"
            trendValue="Healthy"
          />
          <VitalCard
            title="Energy Level"
            value={85}
            unit="%"
            icon={<Zap className="h-5 w-5" />}
            variant="stress"
            trend="up"
            trendValue="+10%"
            subtitle="vs yesterday"
          />
        </div>

        {/* Charts Section */}
        <div className="mb-8 grid gap-6 lg:grid-cols-2">
          <HeartRateChart />
          <ECGVisualization />
        </div>

        {/* Sleep and Stress Section */}
        <div className="mb-8 grid gap-6 lg:grid-cols-2">
          <SleepChart />
          <StressIndicator />
        </div>

        {/* Fall Prevention and Sharing */}
        <div className="grid gap-6 lg:grid-cols-2">
          <FallPrevention />
          <ShareWithProvider />
        </div>

        {/* Footer Note */}
        <div className="mt-8 rounded-2xl bg-muted/50 p-6 text-center">
          <p className="text-body-sm text-muted-foreground">
            Data synced from Garmin • Connected to InterSystems IRIS database
          </p>
          <p className="mt-1 text-caption text-muted-foreground">
            Last updated: {new Date().toLocaleString()}
          </p>
        </div>
      </main>
    </div>
  );
};

export default Index;
