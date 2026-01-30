import { useState } from "react";
import { Heart, Moon, Activity, Zap, Upload } from "lucide-react";
import { Header } from "@/components/Header";
import { VitalCard } from "@/components/VitalCard";
import { HeartRateChart } from "@/components/HeartRateCharttest";
import { ECGVisualization } from "@/components/ECGVisualization";
import { SleepChart } from "@/components/SleepChart";
import { StressIndicator } from "@/components/StressIndicator";
import { FallPrevention } from "@/components/FallPrevention";
import { ShareWithProvider } from "@/components/ShareWithProvider";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import VoiceButton from "@/components/VoiceButton";

type Msg = { role: "user" | "assistant"; content: string };

// Text-to-Speech helper
const speak = async (text: string) => {
  try {
    const res = await fetch("http://localhost:3001/api/speak", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text }),
    });

    const ct = res.headers.get("content-type") || "";
    if (!res.ok) {
      console.error("TTS failed:", await res.text());
      return;
    }
    if (!ct.startsWith("audio/")) return;

    const blob = await res.blob();
    const url = URL.createObjectURL(blob);
    const audio = new Audio(url);
    audio.onended = () => URL.revokeObjectURL(url);
    await audio.play();
  } catch (e) {
    console.error("Audio playback error:", e);
  }
};

const Index = () => {
  const [messages, setMessages] = useState<Msg[]>([]);
  const [isThinking, setIsThinking] = useState(false);

  const handleImportData = () => {
    toast.info("Health data import coming soon!", {
      description: "Connect to InterSystems IRIS to sync your export.xml data",
    });
  };

  const handleVoice = async (text: string) => {
  const userText = (text || "").trim();
  if (!userText) return;

  const nextMessages: Msg[] = [...messages, { role: "user", content: userText }];
  setMessages(nextMessages);
  setIsThinking(true);

  try {
    const res = await fetch("http://localhost:3001/api/answer", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        text: userText,
        messages: nextMessages,
      }),
    });

    const data = await res.json();

    if (!res.ok || data?.error) {
      const errMsg = "Sorry — something went wrong.";
      setMessages([...nextMessages, { role: "assistant", content: errMsg }]);
      setIsThinking(false);
      speak(errMsg); // no await
      return;
    }

    const a = String(data.answer || "").trim();
    setMessages([...nextMessages, { role: "assistant", content: a }]);

    setIsThinking(false); 
    speak(a);             
    return;
  } catch (e) {
    const errMsg = "Sorry — network error.";
    setMessages([...nextMessages, { role: "assistant", content: errMsg }]);
    setIsThinking(false);
    speak("I'm having trouble connecting right now.");
    return;
  }
};

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
            <VoiceButton onTranscript={handleVoice} />
            <Button onClick={handleImportData}>
              <Upload className="mr-2 h-4 w-4" />
              Import Data
            </Button>
          </div>
        </div>

        {messages.length > 0 && (
          <div className="mb-6 rounded-2xl bg-muted/60 p-5">
            <div className="space-y-3">
              {messages.map((m, i) => (
                <div key={i} className="flex gap-3">
                  <div className="shrink-0 font-semibold">
                    {m.role === "user" ? "You" : "Assistant"}
                  </div>
                  <div>{m.content}</div>
                </div>
              ))}

                            {isThinking &&
                messages.length > 0 &&
                messages[messages.length - 1].role === "user" && (
                  <div className="flex gap-3 text-muted-foreground">
                    <div className="shrink-0 font-semibold">Assistant</div>
                    <div>Thinking…</div>
                  </div>
              )}

            </div>
          </div>
        )}

        {/* Rest of your dashboard */}
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


        <div className="mb-8 grid gap-6 lg:grid-cols-2">
          <HeartRateChart />
          <ECGVisualization />
        </div>

        <div className="mb-8 grid gap-6 lg:grid-cols-2">
          <SleepChart />
          <StressIndicator />
        </div>

        <div className="grid gap-6 lg:grid-cols-2">
          <FallPrevention />
          <ShareWithProvider />
        </div>
      </main>
    </div>
  );
};

export default Index;
