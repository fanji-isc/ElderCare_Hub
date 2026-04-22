import { useState, useEffect, useRef } from "react";
import { Header } from "@/components/Header";
import { HealthModalContent, HealthCard } from "@/components/HealthPanel";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import {
  Heart, Moon, Utensils, Brain, Footprints, Shield, Droplets, Pill,
  ShieldCheck, AlertCircle, AlertTriangle,
  Phone, PhoneOff, PhoneIncoming, PhoneCall, Share2,
  Calendar, CheckSquare, Square,
} from "lucide-react";
import { toast } from "sonner";

type Vitals = { steps: number; stressLevel: number; stepsTrend: string, avgSteps: string, maxSteps: string, 
                prevAvgSteps: number, trendPctSteps: number, trendStepsUp: boolean };

const HOME_ID = "PATIENT_001";
const first_name = "Frank";
const last_name = "Larson";

// ─── Page ─────────────────────────────────────────────────────────────────────
const FamilyView = () => {
  // Card data states
  const emptyVitals: Vitals = { steps: 0, stressLevel: 0, stepsTrend: "", avgSteps: "", maxSteps: "", prevAvgSteps: 0, trendPctSteps: 0, trendStepsUp: false };
  const [vitals, setVitals] = useState<Vitals>(emptyVitals);
  const vitalsRef = useRef<Vitals>(emptyVitals);
  vitalsRef.current = vitals;
  const [stepHistory, setStepHistory] = useState<{ day: string; steps: number }[]>([]);
  const [healthStatus, setHealthStatus] = useState({ sleep: {}, heart: {}, stress: {}, steps: {}, hydration: {}, gait: {}, nutrition: {} });
  const [familySummary, setFamilySummary] = useState<{ status: string; summary: string } | null>(null);
  const [loaded, setLoaded] = useState(false);
  // UI states
  const [openModal, setOpenModal] = useState<string | null>(null);
  const [incomingCall, setIncomingCall] = useState(false);
  const [callConnected, setCallConnected] = useState(false);
  const [familyCallState, setFamilyCallState] = useState<"idle" | "calling" | "connected" | "declined">("idle");
  const [callSeconds, setCallSeconds] = useState(0);
  // Share report states
  const [shareModalOpen, setShareModalOpen] = useState(false);
  const [shareDescription, setShareDescription] = useState("");
  const [selectedData, setSelectedData] = useState<Record<string, boolean>>({
    heart: false, sleep: false, nutrition: false, stress: false, 
    steps: false, gait: false, hydration: false
  });
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerateReport = async () => {
    setIsGenerating(true);
    try {
      const payload = {
        patient_id: HOME_ID,
        patient_name: `${first_name} ${last_name}`,
        description: shareDescription,
        included_metrics: Object.keys(selectedData).filter(key => selectedData[key])
      };

      const response = await fetch(`/api/generate-report`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) throw new Error("Failed to generate report");

      toast.success("Report generated successfully!");
      setShareModalOpen(false);
    } catch (error) {
      toast.error("Error generating report. Please try again.");
      console.error(error);
    } finally {
      setIsGenerating(false);
    }
  };

  // Call state cross-tab syncing
  useEffect(() => {
    const resetToIdle = () => {
      localStorage.setItem("nhh-family-call-state", JSON.stringify({ status: "idle", timestamp: Date.now() }));
      setFamilyCallState("idle");
    };

    const initialVal = JSON.parse(localStorage.getItem("nhh-family-call-state") ?? "{}");
    if (initialVal.status === "declined" || initialVal.status === "ringing") resetToIdle();

    const sync = () => {
      const val = JSON.parse(localStorage.getItem("nhh-call-state") ?? "{}");
      if (val.status === "ringing") { setIncomingCall(true); setCallConnected(false); }
      else if (val.status === "idle") { setIncomingCall(false); setCallConnected(false); }

      const familyVal = JSON.parse(localStorage.getItem("nhh-family-call-state") ?? "{}");
      if (familyVal.status === "accepted") { setFamilyCallState("connected"); } 
      else if (familyVal.status === "declined") {
        setFamilyCallState("declined");
        setTimeout(() => { resetToIdle(); }, 3000);
      } else if (familyVal.status === "idle") { setFamilyCallState("idle"); }
    };

    sync(); // check on mount
    const interval = setInterval(sync, 500); // poll every 500ms (same-tab navigation)
    window.addEventListener("storage", sync);
    return () => { clearInterval(interval); window.removeEventListener("storage", sync); };
  }, []);

  const isFamilyConnected = callConnected || familyCallState === "connected";
  useEffect(() => {
    if (!isFamilyConnected) { setCallSeconds(0); return; }
    const t = setInterval(() => setCallSeconds(s => s + 1), 1000);
    return () => clearInterval(t);
  }, [isFamilyConnected]);

  const fmtTime = (s: number) => `${String(Math.floor(s / 60)).padStart(2, "0")}:${String(s % 60).padStart(2, "0")}`;

  const startFamilyCall = () => {
    setFamilyCallState("calling");
    localStorage.setItem("nhh-family-call-state", JSON.stringify({ status: "ringing", timestamp: Date.now() }));
  };
  const endFamilyCall = () => {
    setFamilyCallState("idle");
    localStorage.setItem("nhh-family-call-state", JSON.stringify({ status: "idle", timestamp: Date.now() }));
  };

  const acceptCall = () => {
    setIncomingCall(false);
    setCallConnected(true);
    localStorage.setItem("nhh-call-state", JSON.stringify({ status: "accepted", timestamp: Date.now() }));
  };
  const declineCall = () => {
    setIncomingCall(false);
    localStorage.setItem("nhh-call-state", JSON.stringify({ status: "declined", timestamp: Date.now() }));
  };
  const endCall = () => {
    setCallConnected(false);
    localStorage.setItem("nhh-call-state", JSON.stringify({ status: "idle", timestamp: Date.now() }));
  };

  useEffect(() => {
    (async () => {
      try {
        const [dashboardRes, summaryRes] = await Promise.all([
          fetch(`/api/build-patient-dashboard?patient_id=${HOME_ID}`),
          fetch(`/api/family-summary?patient_id=${HOME_ID}`)
        ]);

        if (!dashboardRes.ok) {
          const errorData = await dashboardRes.json().catch(() => ({ detail: "Unknown Error" }));
          throw new Error(errorData.detail || "Fetch failed");
        }
        const dashboardData = await dashboardRes.json() as any;
        const loaded: Vitals = {
          ...dashboardData
        };
        setVitals(loaded);
        vitalsRef.current = loaded;

        // Build step history for trend chart
        setStepHistory(dashboardData.stepHistory ?? []);

        // Fetch AI family summary
        if (summaryRes.ok) setFamilySummary(await summaryRes.json());

        // Build health card status values
        const allStatus = dashboardData.status;
        setHealthStatus({...allStatus});

      } catch (error) {
        console.error("Error loading data:", error);
      }
      finally { setLoaded(true); }
    })();
  }, []);

  if (!loaded) {
    return (
      <div className="flex h-screen items-center justify-center bg-background">
        <div className="text-center">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-emerald-500 border-t-transparent mx-auto mb-4"></div>
          <p className="text-muted-foreground animate-pulse">Loading {first_name}'s home data...</p>
        </div>
      </div>
    );
  }

  const statusConfig = {
    good: {
      icon: ShieldCheck, gradient: "from-emerald-50 to-teal-50", border: "border-emerald-200",
      iconBg: "bg-emerald-500", text: "text-emerald-900", title: `${first_name} is doing well today`
    },
    fair: {
      icon: AlertCircle, gradient: "from-amber-50 to-yellow-50", border: "border-amber-200",
      iconBg: "bg-amber-500", text: "text-amber-900", title: `${first_name} is generally okay`
    },
    warn: {
      icon: AlertTriangle, gradient: "from-rose-50 to-red-50", border: "border-rose-200",
      iconBg: "bg-rose-500", text: "text-rose-900", title: `${first_name} may need your attention`
    },
  }[familySummary.status];

  return (
    <div className="min-h-screen bg-background">
      {/* ── Outgoing call to Frank ───────────────────────────────── */}
      {familyCallState === "calling" && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between gap-4 px-6 py-5 bg-gradient-to-r from-emerald-600 to-teal-600 shadow-2xl text-white">
          <div className="flex items-center gap-4">
            <div className="relative flex items-center justify-center">
              <span className="absolute inline-flex h-14 w-14 rounded-full bg-white/20 animate-ping" />
              <span className="absolute inline-flex h-10 w-10 rounded-full bg-white/30 animate-ping [animation-delay:200ms]" />
              <div className="relative flex h-12 w-12 items-center justify-center rounded-full bg-white/25 shadow-lg">
                <PhoneCall className="h-6 w-6 text-white" />
              </div>
            </div>
            <div>
              <p className="text-lg font-bold tracking-wide">📲 Calling {first_name}...</p>
              <p className="text-sm font-medium text-white/90">Waiting for {first_name} to pick up</p>
            </div>
          </div>
          <button onClick={endFamilyCall} className="flex items-center gap-2 rounded-full bg-rose-500 px-5 py-2.5 text-sm font-bold shadow-lg hover:bg-rose-400 active:scale-95 transition-all">
            <PhoneOff className="h-4 w-4" /> Cancel
          </button>
        </div>
      )}

      {/* ── Incoming call overlay ─────────────────────────────────── */}
      {incomingCall && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between gap-4 px-6 py-5 shadow-2xl"
          style={{ background: "linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #db2777 100%)" }}>
          {/* Animated ring rings behind icon */}
          <div className="flex items-center gap-4 text-white">
            <div className="relative flex items-center justify-center">
              <span className="absolute inline-flex h-14 w-14 rounded-full bg-white/20 animate-ping" />
              <span className="absolute inline-flex h-10 w-10 rounded-full bg-white/30 animate-ping [animation-delay:150ms]" />
              <div className="relative flex h-12 w-12 items-center justify-center rounded-full bg-white/25 shadow-lg">
                <PhoneIncoming className="h-6 w-6 text-white drop-shadow" />
              </div>
            </div>
            <div>
              <p className="text-lg font-bold tracking-wide">📞 Incoming Call</p>
              <p className="text-sm font-medium text-white/90">{first_name} {last_name} is calling you</p>
            </div>
          </div>
          <div className="flex gap-3">
            <button onClick={acceptCall} className="flex items-center gap-2 rounded-full bg-emerald-400 px-5 py-2.5 text-sm font-bold text-white shadow-lg hover:bg-emerald-300 active:scale-95 transition-all">
              <Phone className="h-4 w-4" /> Accept
            </button>
            <button onClick={declineCall} className="flex items-center gap-2 rounded-full bg-rose-500 px-5 py-2.5 text-sm font-bold text-white shadow-lg hover:bg-rose-400 active:scale-95 transition-all">
              <PhoneOff className="h-4 w-4" /> Decline
            </button>
          </div>
        </div>
      )}

      {/* ── Connected banner (Frank called us / we called Frank) ─── */}
      {(callConnected || familyCallState === "connected") && (
        <div className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between px-6 py-3 bg-emerald-600 text-white shadow-lg">
          <div className="flex items-center gap-3">
            <div className="h-2 w-2 rounded-full bg-white animate-pulse" />
            <span className="text-sm font-semibold">Connected with {first_name}</span>
            <span className="rounded-full bg-white/20 px-2.5 py-0.5 text-xs font-mono font-semibold">{fmtTime(callSeconds)}</span>
          </div>
          <button
            onClick={callConnected ? endCall : endFamilyCall}
            className="flex items-center gap-2 rounded-full bg-white/20 px-3 py-1.5 text-xs font-semibold hover:bg-white/30 transition"
          >
            <PhoneOff className="h-3.5 w-3.5" /> End Call
          </button>
        </div>
      )}

      <Header />

      <main className="container mx-auto px-4 py-6 sm:px-6 max-w-7xl flex flex-col" style={{ minHeight: 'calc(100vh - 64px)' }}>

        {/* ── Page header ──────────────────────────────────────────── */}
        <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-xl font-bold text-foreground leading-tight">Welcome, {first_name}'s Family</h2>
          </div>
          <div className="flex items-center gap-2">
            {familyCallState === "idle" && (
              <Button variant="outline" size="sm" onClick={startFamilyCall}>
                <Phone className="mr-1.5 h-3.5 w-3.5" />
                Call {first_name}
              </Button>
            )}
            {familyCallState === "calling" && (
              <Button size="sm" onClick={endFamilyCall} className="animate-pulse bg-amber-500 hover:bg-amber-600 border-0">
                <PhoneCall className="mr-1.5 h-3.5 w-3.5" />
                Calling…
              </Button>
            )}
            {familyCallState === "connected" && (
              <Button size="sm" onClick={endFamilyCall} className="bg-emerald-600 hover:bg-emerald-700 border-0 gap-2">
                <span className="h-1.5 w-1.5 rounded-full bg-white animate-pulse" />
                Connected · End
                <PhoneOff className="h-3.5 w-3.5" />
              </Button>
            )}
            {familyCallState === "declined" && (
              <Button size="sm" disabled className="bg-rose-100 text-rose-600 border-0">
                <PhoneOff className="mr-1.5 h-3.5 w-3.5" />
                Declined
              </Button>
            )}
            <Button size="sm" onClick={() => setShareModalOpen(true)}>
              <Share2 className="mr-1.5 h-3.5 w-3.5" />
              Share Report
            </Button>
          </div>
        </div>

        {/* ── Overall status banner ─────────────────────────────────── */}
        <div className={`mb-6 rounded-2xl border bg-gradient-to-r overflow-hidden shadow-card ${statusConfig.gradient} ${statusConfig.border}`}>
          <div className="flex items-start gap-4 p-5">
            <div className={`flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl shadow-sm ${statusConfig.iconBg}`}>
              <statusConfig.icon className="h-5 w-5 text-white" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex flex-wrap items-center gap-2 mb-1">
                <h3 className={`text-base font-bold ${statusConfig.text}`}>{statusConfig.title}</h3>
              </div>
              {(
                <p className="mt-2 text-sm text-foreground/75 leading-relaxed">{familySummary.summary}</p>
              )}
            </div>
          </div>
        </div>

        {/* ── 9-card grid (3 × 3) ───────────────────────────────────── */}
        <div className="grid grid-cols-3 gap-3">
          <HealthCard icon={Heart}      iconBg="bg-heart/15 text-heart"           title="Heart Health"     label={healthStatus.heart.label}           labelColor={healthStatus.heart.color}     onClick={() => setOpenModal("heart")}      showShield={true} />
          <HealthCard icon={Moon}       iconBg="bg-sleep/15 text-sleep"           title="Sleep Analysis"   label={healthStatus.sleep.label}           labelColor={healthStatus.sleep.color}     onClick={() => setOpenModal("sleep")}      showShield={true} />
          <HealthCard icon={Utensils}   iconBg="bg-teal-500/15 text-teal-600"     title="Nutrition & Diet" label={healthStatus.nutrition.label}       labelColor={healthStatus.nutrition.color} onClick={() => setOpenModal("nutrition")}  showShield={true} />
          <HealthCard icon={Brain}      iconBg="bg-stress/15 text-stress"         title="Stress"           label={healthStatus.stress.label}          labelColor={healthStatus.stress.color}    onClick={() => setOpenModal("stress")}     showShield={true} />
          <HealthCard icon={Footprints} iconBg="bg-ecg/15 text-ecg"               title="Steps Today"      label={vitals.stepsTrend}                  labelColor={healthStatus.steps.color}     onClick={() => setOpenModal("steps")}      showShield={true} />
          <HealthCard icon={Shield}     iconBg="bg-amber-500/15 text-amber-600"   title="Gait Analysis"    label={healthStatus.gait.label}            labelColor={healthStatus.gait.color}      onClick={() => setOpenModal("gait")}       showShield={true} />
          <HealthCard icon={Droplets}   iconBg="bg-teal-500/15 text-teal-600"     title="Hydration"        label={healthStatus.hydration.label}       labelColor={healthStatus.hydration.color} onClick={() => setOpenModal("hydration")}  showShield={true} />
          <HealthCard icon={Pill}       iconBg="bg-blue-500/15 text-blue-600"     title="Medication"       label="Active Rx"       labelColor="text-blue-600"    onClick={() => setOpenModal("medication")}    showShield={true} />
          <HealthCard icon={Calendar}   iconBg="bg-violet-500/15 text-violet-600" title="Appointments"     label="Upcoming"        labelColor="text-violet-600"  onClick={() => setOpenModal("appointments")}  showShield={true} />
        </div>

      </main>

      {/* ── Detail modal ──────────────────────────────────────────────── */}
      <Dialog open={openModal !== null} onOpenChange={() => setOpenModal(null)}>
        <DialogContent className="sm:max-w-3xl max-h-[85vh] overflow-y-auto">
          <HealthModalContent 
            openModal={openModal} 
            vitals={vitals} 
            healthStatus={healthStatus} 
            stepHistory={stepHistory}
            showPrivacyFeatures={true}
          />
        </DialogContent>
      </Dialog>

      {/* ── Share Report Modal ────────────────────────────────────────── */}
      <Dialog open={shareModalOpen} onOpenChange={setShareModalOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Generate Family Report</DialogTitle>
            <p className="text-sm text-muted-foreground">Select which data points to include in the shared summary.</p>
          </DialogHeader>
          
          <div className="space-y-6 py-4">
            <div className="grid grid-cols-2 gap-3">
              {Object.keys(selectedData).map((key) => (
                <div key={key} className="flex items-center space-x-2">
                  <button 
                    onClick={() => setSelectedData(prev => ({ ...prev, [key]: !prev[key] }))}
                    className="flex items-center gap-2 text-sm font-medium"
                  >
                    {selectedData[key] ? ( <CheckSquare className="h-5 w-5 text-emerald-600" /> ) : ( <Square className="h-5 w-5 text-muted-foreground" /> )}
                    <span className="capitalize">{key === 'nutrition' ? 'Nutrition' : key}</span>
                  </button>
                </div>
              ))}
            </div>

            {/* Description Box */}
            <div className="space-y-2">
              <label className="text-sm font-semibold">Notes / Highlights</label>
              <textarea
                className="w-full min-h-[100px] rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                placeholder={`e.g., ${first_name} had a great week, but we are keeping an eye on his steps...`}
                value={shareDescription}
                onChange={(e) => setShareDescription(e.target.value)}
              />
            </div>

            <Button 
              className="w-full bg-emerald-600 hover:bg-emerald-700 text-white" 
              onClick={handleGenerateReport}
              disabled={isGenerating}
            >
              {isGenerating ? "Generating..." : "Generate & Share Report"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

    </div>
  );
};

export default FamilyView;