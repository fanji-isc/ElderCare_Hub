import { useEffect, useState } from "react";
import { Stethoscope, User, Calendar, Hash, MapPin, FlaskConical, Activity, Brain, ChevronRight, ArrowLeft } from "lucide-react";
import { Header } from "@/components/Header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import {
  ComposedChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ReferenceArea, ResponsiveContainer,
} from "recharts";

const API_BASE = "http://localhost:3001";

type FhirPatient  = { id: string; name: string; birthDate: string; gender: string; mrn: string | null; address: { line?: string[]; city?: string; state?: string } };
type Condition    = { display: string; code: string; status: string; onset: string };
type Medication   = { drug: string; status: string; authored: string; dosage: string };
type Observation  = { display: string; value: number | null; unit: string; date: string };
type Procedure    = { display: string; status: string; date: string };
type Immunization = { vaccine: string; status: string; date: string; lotNumber: string };
type Encounter    = { type: string; status: string; date: string; provider: string };
type BpPoint      = { date: string; systolic: number; diastolic: number };

function fmt(dateStr: string) {
  if (!dateStr) return "—";
  try { return new Date(dateStr).toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" }); }
  catch { return dateStr; }
}

function fmtYear(dateStr: string) {
  if (!dateStr) return "";
  try { return new Date(dateStr).toLocaleDateString("en-US", { year: "numeric", month: "short" }); }
  catch { return dateStr; }
}

function calcAge(birthDate: string) {
  return Math.floor((Date.now() - new Date(birthDate).getTime()) / (1000 * 60 * 60 * 24 * 365.25));
}

function StatusBadge({ status }: { status: string }) {
  const s = (status || "").toLowerCase();
  const cls =
    s === "active" || s === "completed" || s === "finished"
      ? "bg-emerald-100 text-emerald-700"
      : s === "stopped" || s === "entered-in-error"
      ? "bg-red-100 text-red-700"
      : "bg-slate-100 text-slate-600";
  return <span className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-medium capitalize ${cls}`}>{status}</span>;
}

function SectionHeader({ icon, title, count }: { icon: React.ReactNode; title: string; count?: number }) {
  return (
    <div className="flex items-center gap-2 border-b border-border pb-3 mb-4">
      <div className="flex h-7 w-7 items-center justify-center rounded-md bg-blue-50">{icon}</div>
      <h3 className="text-base font-semibold text-foreground">{title}</h3>
      {count !== undefined && count > 0 && (
        <span className="ml-auto rounded-full bg-blue-100 px-2 py-0.5 text-xs text-blue-700">{count}</span>
      )}
    </div>
  );
}

function TableSkeleton({ cols, rows = 4 }: { cols: number; rows?: number }) {
  return (
    <div className="space-y-3 p-4">
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="flex gap-4">
          {Array.from({ length: cols }).map((_, j) => <Skeleton key={j} className="h-4 flex-1" />)}
        </div>
      ))}
    </div>
  );
}

function bpColor(systolic: number) {
  if (systolic < 120) return "#16a34a";
  if (systolic < 130) return "#ca8a04";
  if (systolic < 140) return "#ea580c";
  return "#dc2626";
}

function bmiCategory(bmi: number) {
  if (bmi < 18.5) return { label: "Underweight", color: "#fb923c" };
  if (bmi < 25)   return { label: "Normal",      color: "#16a34a" };
  if (bmi < 30)   return { label: "Overweight",  color: "#ca8a04" };
  return               { label: "Obese",         color: "#dc2626" };
}

const CustomBpDot = (props: any) => {
  const { cx, cy, payload } = props;
  return <circle cx={cx} cy={cy} r={5} fill={bpColor(payload.systolic)} stroke="#fff" strokeWidth={1.5} />;
};

function BmiGauge({ bmi, weight }: { bmi: number | null; weight: number | null }) {
  const MIN = 10, MAX = 40, RANGE = MAX - MIN;
  const zones = [
    { label: "Below 18.5 (Underweight)", color: "#fb923c", start: 10, end: 18.5 },
    { label: "18.5 – 24.9 (Normal)",     color: "#4ade80", start: 18.5, end: 25 },
    { label: "25 – 29.9 (Overweight)",   color: "#fbbf24", start: 25, end: 30 },
    { label: "30 or over (Obesity)",     color: "#f87171", start: 30, end: 40 },
  ];
  const pct  = bmi != null ? Math.max(0, Math.min(100, ((bmi - MIN) / RANGE) * 100)) : null;
  const cat  = bmi != null ? bmiCategory(bmi) : null;

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-baseline gap-5 text-sm">
        {bmi != null && (
          <span>
            BMI:{" "}
            <span className="text-2xl font-bold" style={{ color: cat?.color }}>
              {bmi}
            </span>
          </span>
        )}
        {weight != null && (
          <span className="text-muted-foreground">
            Weight: <span className="font-semibold text-foreground">{weight} kg</span>
          </span>
        )}
      </div>
      <div className="relative mt-1">
        <div className="flex h-7 overflow-hidden rounded-full">
          {zones.map((z) => (
            <div
              key={z.label}
              style={{ width: `${((z.end - z.start) / RANGE) * 100}%`, backgroundColor: z.color }}
            />
          ))}
        </div>
        {pct != null && (
          <div
            className="absolute top-1/2 -translate-y-1/2 -translate-x-1/2"
            style={{ left: `${pct}%` }}
          >
            <div
              className="h-7 w-7 rounded-full border-[3px] border-white shadow-lg"
              style={{ backgroundColor: cat?.color }}
            />
          </div>
        )}
      </div>
      <div className="flex justify-between px-0.5 text-xs text-muted-foreground">
        <span>10</span>
        <span>18.5</span>
        <span>25</span>
        <span>30</span>
        <span>40</span>
      </div>
      <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-muted-foreground">
        {zones.map((z) => (
          <span key={z.label} className="flex items-center gap-1">
            <span className="inline-block h-2.5 w-2.5 rounded-sm" style={{ backgroundColor: z.color }} />
            {z.label}
          </span>
        ))}
      </div>
      {cat && bmi != null && (
        <p className="text-sm font-semibold" style={{ color: cat.color }}>
          {cat.label}
        </p>
      )}
    </div>
  );
}

// ── Top bar shared by both list and detail views ──────────────────────────────
function PhysicianTopBar({ onBack }: { onBack?: () => void }) {
  return (
    <div className="border-b border-border bg-card/40">
      <div className="container mx-auto flex items-center gap-3 px-4 py-4 sm:px-6">
        {onBack && (
          <>
            <button
              onClick={onBack}
              className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              <ArrowLeft className="h-4 w-4" />
              Patient List
            </button>
            <span className="text-muted-foreground">/</span>
          </>
        )}
        <div className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-100">
            <Stethoscope className="h-4 w-4 text-blue-600" />
          </div>
          <span className="rounded-full bg-blue-100 px-3 py-1 text-body-sm font-medium text-blue-700">
            Physician View
          </span>
        </div>
      </div>
    </div>
  );
}

// ── Patient list banner row ───────────────────────────────────────────────────
function PatientBanner({ patient, onClick }: { patient: FhirPatient; onClick: () => void }) {
  const age = patient.birthDate ? calcAge(patient.birthDate) : null;
  const initials = patient.name.split(" ").map(n => n[0]).join("").slice(0, 2).toUpperCase();
  return (
    <Card
      className="cursor-pointer hover:shadow-md transition-shadow border-l-4 border-l-blue-400"
      onClick={onClick}
    >
      <CardContent className="p-4">
        <div className="flex items-center gap-4">
          <div className="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 text-base font-bold text-blue-700">
            {initials}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-3 flex-wrap">
              <span className="text-base font-semibold text-foreground">{patient.name}</span>
              {patient.gender && (
                <span className="text-sm text-muted-foreground">
                  <User className="inline h-3.5 w-3.5 mr-0.5" />
                  {patient.gender.charAt(0).toUpperCase() + patient.gender.slice(1)}
                  {age !== null ? `, ${age} yrs` : ""}
                </span>
              )}
            </div>
            <div className="mt-1 flex flex-wrap gap-x-4 gap-y-0.5 text-xs text-muted-foreground">
              {patient.birthDate && (
                <span className="flex items-center gap-1">
                  <Calendar className="h-3 w-3" />
                  DOB: {fmt(patient.birthDate)}
                </span>
              )}
              {patient.mrn && (
                <span className="flex items-center gap-1">
                  <Hash className="h-3 w-3" />
                  MRN: {patient.mrn}
                </span>
              )}
              {patient.address?.city && (
                <span className="flex items-center gap-1">
                  <MapPin className="h-3 w-3" />
                  {[patient.address.city, patient.address.state].filter(Boolean).join(", ")}
                </span>
              )}
            </div>
          </div>
          <ChevronRight className="h-5 w-5 text-muted-foreground flex-shrink-0" />
        </div>
      </CardContent>
    </Card>
  );
}

// ── Main component ────────────────────────────────────────────────────────────
const PhysicianView = () => {
  // ── Patient list state ──────────────────────────────────────────────────
  const [patients, setPatients] = useState<FhirPatient[]>([]);
  const [listLoading, setListLoading] = useState(true);
  const [listError, setListError] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(null);

  useEffect(() => {
    fetch(`${API_BASE}/api/fhir/patients`)
      .then(r => { if (!r.ok) throw new Error("Failed to load patients"); return r.json(); })
      .then(data => {
        const pts: FhirPatient[] = Array.isArray(data) ? data : [];
        pts.sort((a, b) => {
          const aFamily = a.name.split(" ").pop() ?? "";
          const bFamily = b.name.split(" ").pop() ?? "";
          return aFamily.localeCompare(bFamily);
        });
        setPatients(pts);
      })
      .catch(e => setListError(e.message))
      .finally(() => setListLoading(false));
  }, []);

  // ── Patient detail state ────────────────────────────────────────────────
  const [patient, setPatient] = useState<FhirPatient | null>(null);
  const [conditions, setConditions]       = useState<Condition[]>([]);
  const [medications, setMedications]     = useState<Medication[]>([]);
  const [vitals, setVitals]               = useState<Observation[]>([]);
  const [labs, setLabs]                   = useState<Observation[]>([]);
  const [procedures, setProcedures]       = useState<Procedure[]>([]);
  const [immunizations, setImmunizations] = useState<Immunization[]>([]);
  const [encounters, setEncounters]       = useState<Encounter[]>([]);
  const [bpTrend, setBpTrend]             = useState<BpPoint[]>([]);
  const [detailLoading, setDetailLoading] = useState(false);
  const [detailError, setDetailError]     = useState("");

  useEffect(() => {
    if (!selectedId) return;
    setPatient(patients.find(p => p.id === selectedId) ?? null);
    setDetailLoading(true);
    setDetailError("");
    (async () => {
      try {
        const [cond, meds, vit, lab, proc, imm, enc, bp] = await Promise.all([
          fetch(`${API_BASE}/api/fhir/conditions?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/medications?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/vitals?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/labs?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/procedures?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/immunizations?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/encounters?patient_id=${selectedId}`).then(r => r.json()),
          fetch(`${API_BASE}/api/fhir/bp-trend?patient_id=${selectedId}`).then(r => r.json()),
        ]);
        setConditions(Array.isArray(cond) ? cond : []);
        setMedications(Array.isArray(meds) ? meds : []);
        setVitals(Array.isArray(vit) ? vit : []);
        setLabs(Array.isArray(lab) ? lab : []);
        setProcedures(Array.isArray(proc) ? proc : []);
        setImmunizations(Array.isArray(imm) ? imm : []);
        setEncounters(Array.isArray(enc) ? enc : []);
        setBpTrend(Array.isArray(bp) ? bp : []);
      } catch (e: any) {
        setDetailError(e.message || "Failed to load patient data");
      } finally {
        setDetailLoading(false);
      }
    })();
  }, [selectedId]);

  // ── Derived values (for detail view) ───────────────────────────────────
  const age = patient?.birthDate ? calcAge(patient.birthDate) : null;

  const bmiObs = vitals
    .filter(v => v.display.toLowerCase().includes("bmi") || v.display.toLowerCase().includes("mass index"))
    .sort((a, b) => a.date.localeCompare(b.date));

  const weightObs = vitals
    .filter(v => v.display.toLowerCase().includes("weight") && !v.display.toLowerCase().includes("bmi"))
    .sort((a, b) => a.date.localeCompare(b.date));

  const bpChartData = bpTrend
    .map(p => ({ ...p, date: fmtYear(p.date), rawDate: p.date }))
    .sort((a, b) => a.rawDate.localeCompare(b.rawDate));

  const latestBmi    = bmiObs[bmiObs.length - 1];
  const latestWeight = weightObs[weightObs.length - 1];
  const latestBp     = bpChartData[bpChartData.length - 1];

  function handleBack() {
    setSelectedId(null);
    setPatient(null);
    setConditions([]);
    setMedications([]);
    setVitals([]);
    setLabs([]);
    setProcedures([]);
    setImmunizations([]);
    setEncounters([]);
    setBpTrend([]);
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Patient list view
  // ════════════════════════════════════════════════════════════════════════
  if (!selectedId) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <PhysicianTopBar />
        <main className="container mx-auto px-4 py-6 sm:px-6">
          <div className="mb-5">
            <h2 className="text-xl font-semibold text-foreground">Patient Registry</h2>
            <p className="text-sm text-muted-foreground mt-0.5">
              Select a patient to view their health overview
            </p>
          </div>

          {listLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 5 }).map((_, i) => (
                <Skeleton key={i} className="h-[72px] w-full rounded-xl" />
              ))}
            </div>
          ) : listError ? (
            <p className="text-sm text-destructive">{listError} — ensure the FHIR server is running and patient data is loaded.</p>
          ) : patients.length === 0 ? (
            <p className="text-sm text-muted-foreground">No patients found in FHIR server.</p>
          ) : (
            <div className="space-y-3">
              {patients.map(p => (
                <PatientBanner key={p.id} patient={p} onClick={() => setSelectedId(p.id)} />
              ))}
            </div>
          )}
        </main>
      </div>
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Patient detail / health overview view
  // ════════════════════════════════════════════════════════════════════════
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <PhysicianTopBar onBack={handleBack} />

      <main className="container mx-auto px-4 py-6 sm:px-6">

        {/* ── Patient header card ── */}
        <Card className="mb-6 shadow-card">
          <CardContent className="p-6">
            {detailLoading && !patient ? (
              <div className="flex items-center gap-4">
                <Skeleton className="h-16 w-16 rounded-full" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-6 w-48" />
                  <Skeleton className="h-4 w-72" />
                </div>
              </div>
            ) : detailError ? (
              <p className="text-sm text-destructive">{detailError}</p>
            ) : patient ? (
              <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                <div className="flex h-16 w-16 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 text-xl font-bold text-blue-700">
                  {patient.name.split(" ").map(n => n[0]).join("").slice(0, 2).toUpperCase()}
                </div>
                <div className="flex-1 min-w-0">
                  <h2 className="text-2xl font-display font-bold text-foreground">{patient.name}</h2>
                  <div className="mt-1 flex flex-wrap gap-x-5 gap-y-1 text-body-sm text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <User className="h-3.5 w-3.5" />
                      {patient.gender ? patient.gender.charAt(0).toUpperCase() + patient.gender.slice(1) : "—"}
                      {age !== null ? `, ${age} yrs` : ""}
                    </span>
                    <span className="flex items-center gap-1">
                      <Calendar className="h-3.5 w-3.5" />
                      DOB: {fmt(patient.birthDate)}
                    </span>
                    {patient.mrn && (
                      <span className="flex items-center gap-1">
                        <Hash className="h-3.5 w-3.5" />
                        MRN: {patient.mrn}
                      </span>
                    )}
                    {patient.address?.city && (
                      <span className="flex items-center gap-1">
                        <MapPin className="h-3.5 w-3.5" />
                        {[patient.address.city, patient.address.state].filter(Boolean).join(", ")}
                      </span>
                    )}
                  </div>
                </div>
                {/* Quick stat pills */}
                <div className="flex gap-3 flex-wrap sm:flex-nowrap">
                  {latestBp && (
                    <div className="rounded-xl border px-4 py-2 text-center min-w-[100px]">
                      <div className="text-xs text-muted-foreground mb-0.5">Blood Pressure</div>
                      <div className="text-lg font-bold" style={{ color: bpColor(latestBp.systolic) }}>
                        {latestBp.systolic}/{latestBp.diastolic}
                      </div>
                      <div className="text-xs text-muted-foreground">mmHg</div>
                    </div>
                  )}
                  {latestBmi && (
                    <div className="rounded-xl border px-4 py-2 text-center min-w-[100px]">
                      <div className="text-xs text-muted-foreground mb-0.5">BMI</div>
                      <div className="text-lg font-bold" style={{ color: bmiCategory(latestBmi.value ?? 0).color }}>
                        {latestBmi.value}
                      </div>
                      <div className="text-xs text-muted-foreground">{bmiCategory(latestBmi.value ?? 0).label}</div>
                    </div>
                  )}
                  <div className="rounded-xl border px-4 py-2 text-center min-w-[100px]">
                    <div className="text-xs text-muted-foreground mb-0.5">Active Conditions</div>
                    <div className="text-lg font-bold text-foreground">{conditions.filter(c => c.status === "active").length}</div>
                    <div className="text-xs text-muted-foreground">problems</div>
                  </div>
                  <div className="rounded-xl border px-4 py-2 text-center min-w-[100px]">
                    <div className="text-xs text-muted-foreground mb-0.5">Medications</div>
                    <div className="text-lg font-bold text-foreground">{medications.filter(m => m.status === "active").length}</div>
                    <div className="text-xs text-muted-foreground">active Rx</div>
                  </div>
                </div>
              </div>
            ) : null}
          </CardContent>
        </Card>

        {/* ── Tabs ── */}
        <Tabs defaultValue="overview">
          <TabsList className="mb-6 h-auto">
            <TabsTrigger value="overview" className="flex items-center gap-1.5">
              <Activity className="h-3.5 w-3.5" />
              Health Overview
            </TabsTrigger>
            <TabsTrigger value="ai" className="flex items-center gap-1.5">
              <Brain className="h-3.5 w-3.5" />
              AI Summary
            </TabsTrigger>
          </TabsList>

          {/* ══ Tab 1 — Health Overview ══ */}
          <TabsContent value="overview" className="space-y-6">

            {/* Row 1: BP Chart + BMI Gauge */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-base">
                    Blood Pressure ({bpChartData.length})
                  </CardTitle>
                  <div className="flex flex-wrap gap-3 text-xs mt-1">
                    <span className="flex items-center gap-1"><span className="inline-block h-2.5 w-2.5 rounded-sm bg-emerald-200"/>Normal (&lt;120)</span>
                    <span className="flex items-center gap-1"><span className="inline-block h-2.5 w-2.5 rounded-sm bg-yellow-200"/>Elevated (120–129)</span>
                    <span className="flex items-center gap-1"><span className="inline-block h-2.5 w-2.5 rounded-sm bg-orange-200"/>Stage 1 (130–139)</span>
                    <span className="flex items-center gap-1"><span className="inline-block h-2.5 w-2.5 rounded-sm bg-red-200"/>Stage 2 (≥140)</span>
                  </div>
                </CardHeader>
                <CardContent>
                  {detailLoading ? <Skeleton className="h-64 w-full" /> : bpChartData.length === 0 ? (
                    <p className="py-8 text-center text-sm text-muted-foreground">No blood pressure data found</p>
                  ) : (
                    <ResponsiveContainer width="100%" height={240}>
                      <ComposedChart data={bpChartData} margin={{ top: 8, right: 16, bottom: 8, left: 0 }}>
                        <ReferenceArea y1={0}   y2={120} fill="#dcfce7" fillOpacity={0.6} />
                        <ReferenceArea y1={120} y2={130} fill="#fef9c3" fillOpacity={0.6} />
                        <ReferenceArea y1={130} y2={140} fill="#fed7aa" fillOpacity={0.6} />
                        <ReferenceArea y1={140} y2={180} fill="#fecaca" fillOpacity={0.6} />
                        <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                        <XAxis dataKey="date" tick={{ fontSize: 11 }} />
                        <YAxis domain={[60, 175]} tick={{ fontSize: 11 }} unit=" mmHg" width={70} />
                        <Tooltip
                          formatter={(val: any, name: string) => [`${val} mmHg`, name]}
                          contentStyle={{ fontSize: 12 }}
                        />
                        <Legend wrapperStyle={{ fontSize: 12 }} />
                        <Line type="monotone" dataKey="systolic" name="Systolic" stroke="#2563eb" strokeWidth={2} dot={<CustomBpDot />} activeDot={{ r: 6 }} />
                        <Line type="monotone" dataKey="diastolic" name="Diastolic" stroke="#7c3aed" strokeWidth={2} dot={{ r: 4, fill: "#7c3aed" }} activeDot={{ r: 6 }} />
                      </ComposedChart>
                    </ResponsiveContainer>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-base">Height / Weight and BMI</CardTitle>
                </CardHeader>
                <CardContent>
                  {detailLoading ? <Skeleton className="h-64 w-full" /> : (
                    <BmiGauge bmi={latestBmi?.value ?? null} weight={latestWeight?.value ?? null} />
                  )}
                </CardContent>
              </Card>
            </div>

            {/* Row 2: Conditions + Medications */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <Card>
                <CardContent className="p-5">
                  <SectionHeader icon={<span className="text-xs font-bold text-blue-600">Dx</span>} title="Conditions" count={conditions.length} />
                  {detailLoading ? <TableSkeleton cols={3} /> : (
                    <Table>
                      <TableHeader><TableRow><TableHead>Condition</TableHead><TableHead>Onset</TableHead><TableHead>Status</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {conditions.length === 0
                          ? <TableRow><TableCell colSpan={3} className="py-6 text-center text-muted-foreground text-sm">No conditions found</TableCell></TableRow>
                          : conditions.map((c, i) => (
                            <TableRow key={i}>
                              <TableCell className="font-medium text-sm">{c.display}</TableCell>
                              <TableCell className="text-muted-foreground text-sm">{fmt(c.onset)}</TableCell>
                              <TableCell><StatusBadge status={c.status} /></TableCell>
                            </TableRow>
                          ))}
                      </TableBody>
                    </Table>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-5">
                  <SectionHeader icon={<span className="text-xs font-bold text-blue-600">Rx</span>} title="Medications" count={medications.length} />
                  {detailLoading ? <TableSkeleton cols={3} /> : (
                    <Table>
                      <TableHeader><TableRow><TableHead>Drug</TableHead><TableHead>Dosage</TableHead><TableHead>Status</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {medications.length === 0
                          ? <TableRow><TableCell colSpan={3} className="py-6 text-center text-muted-foreground text-sm">No medications found</TableCell></TableRow>
                          : medications.map((m, i) => (
                            <TableRow key={i}>
                              <TableCell className="font-medium text-sm">{m.drug}</TableCell>
                              <TableCell className="text-muted-foreground text-sm">{m.dosage || "—"}</TableCell>
                              <TableCell><StatusBadge status={m.status} /></TableCell>
                            </TableRow>
                          ))}
                      </TableBody>
                    </Table>
                  )}
                </CardContent>
              </Card>
            </div>

            {/* Row 3: Procedures + Immunizations */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <Card>
                <CardContent className="p-5">
                  <SectionHeader icon={<span className="text-xs font-bold text-blue-600">Pr</span>} title="Procedures" count={procedures.length} />
                  {detailLoading ? <TableSkeleton cols={3} rows={3} /> : (
                    <Table>
                      <TableHeader><TableRow><TableHead>Procedure</TableHead><TableHead>Date</TableHead><TableHead>Status</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {procedures.length === 0
                          ? <TableRow><TableCell colSpan={3} className="py-6 text-center text-muted-foreground text-sm">No procedures found</TableCell></TableRow>
                          : procedures.map((p, i) => (
                            <TableRow key={i}>
                              <TableCell className="font-medium text-sm">{p.display}</TableCell>
                              <TableCell className="text-muted-foreground text-sm">{fmt(p.date)}</TableCell>
                              <TableCell><StatusBadge status={p.status} /></TableCell>
                            </TableRow>
                          ))}
                      </TableBody>
                    </Table>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-5">
                  <SectionHeader icon={<span className="text-xs font-bold text-blue-600">Imm</span>} title="Immunizations" count={immunizations.length} />
                  {detailLoading ? <TableSkeleton cols={3} rows={3} /> : (
                    <Table>
                      <TableHeader><TableRow><TableHead>Vaccine</TableHead><TableHead>Date</TableHead><TableHead>Status</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {immunizations.length === 0
                          ? <TableRow><TableCell colSpan={3} className="py-6 text-center text-muted-foreground text-sm">No immunizations found</TableCell></TableRow>
                          : immunizations.map((im, i) => (
                            <TableRow key={i}>
                              <TableCell className="font-medium text-sm">{im.vaccine}</TableCell>
                              <TableCell className="text-muted-foreground text-sm">{fmt(im.date)}</TableCell>
                              <TableCell><StatusBadge status={im.status} /></TableCell>
                            </TableRow>
                          ))}
                      </TableBody>
                    </Table>
                  )}
                </CardContent>
              </Card>
            </div>

            {/* Row 4: Encounters + Labs */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <Card>
                <CardContent className="p-5">
                  <SectionHeader icon={<span className="text-xs font-bold text-blue-600">En</span>} title="Encounters" count={encounters.length} />
                  {detailLoading ? <TableSkeleton cols={3} rows={3} /> : (
                    <Table>
                      <TableHeader><TableRow><TableHead>Type</TableHead><TableHead>Date</TableHead><TableHead>Status</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {encounters.length === 0
                          ? <TableRow><TableCell colSpan={3} className="py-6 text-center text-muted-foreground text-sm">No encounters found</TableCell></TableRow>
                          : encounters.map((enc, i) => (
                            <TableRow key={i}>
                              <TableCell className="font-medium text-sm">{enc.type}</TableCell>
                              <TableCell className="text-muted-foreground text-sm">{fmt(enc.date)}</TableCell>
                              <TableCell><StatusBadge status={enc.status} /></TableCell>
                            </TableRow>
                          ))}
                      </TableBody>
                    </Table>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-5">
                  <SectionHeader icon={<FlaskConical className="h-3.5 w-3.5 text-blue-600" />} title="Lab Results" count={labs.length} />
                  {detailLoading ? <TableSkeleton cols={4} /> : (
                    <Table>
                      <TableHeader><TableRow><TableHead>Test</TableHead><TableHead>Value</TableHead><TableHead>Unit</TableHead><TableHead>Date</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {labs.length === 0
                          ? <TableRow><TableCell colSpan={4} className="py-6 text-center text-muted-foreground text-sm">No lab results found</TableCell></TableRow>
                          : labs.map((l, i) => (
                            <TableRow key={i}>
                              <TableCell className="font-medium text-sm">{l.display}</TableCell>
                              <TableCell className="text-sm">{l.value ?? "—"}</TableCell>
                              <TableCell className="text-muted-foreground text-sm">{l.unit || "—"}</TableCell>
                              <TableCell className="text-muted-foreground text-sm">{fmt(l.date)}</TableCell>
                            </TableRow>
                          ))}
                      </TableBody>
                    </Table>
                  )}
                </CardContent>
              </Card>
            </div>

          </TabsContent>

          {/* ══ Tab 2 — AI Summary ══ */}
          <TabsContent value="ai">
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-24 text-center">
                <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-blue-50">
                  <Brain className="h-7 w-7 text-blue-400" />
                </div>
                <h3 className="text-lg font-semibold text-foreground mb-2">AI Clinical Summary</h3>
                <p className="text-sm text-muted-foreground max-w-sm">
                  Coming soon — AI-generated summaries of {patient?.name?.split(" ")[0] ?? "this patient"}'s clinical history, risk factors, and care recommendations.
                </p>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </main>
    </div>
  );
};

export default PhysicianView;
