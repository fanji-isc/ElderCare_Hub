import { useEffect, useState } from "react";
import { Stethoscope, User, Calendar, Hash, MapPin, FlaskConical, Activity, Brain, ChevronRight, ArrowLeft, Loader2, RefreshCw } from "lucide-react";
import { Header } from "@/components/Header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import {
  ComposedChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ReferenceArea, ResponsiveContainer,
} from "recharts";

const API_BASE = "http://localhost:3001";


function generateAvatar(name: string, gender: string, age: number): string {
  // Multi-pass hash — each attribute gets a completely independent value
  const hashAttr = (str: string, attr: string) => {
    const key = attr + "|" + str;
    let h = 0x811c9dc5 >>> 0;
    for (let i = 0; i < key.length; i++) {
      h ^= key.charCodeAt(i);
      h = Math.imul(h, 0x01000193) >>> 0;
      h ^= h >>> 16;
    }
    return h >>> 0;
  };
  const h1 = hashAttr(name, "hair");
  const h2 = hashAttr(name, "eyes");
  const h3 = hashAttr(name, "shirt");
  const h4 = hashAttr(name, "skin");
  const h5 = hashAttr(name, "glasses");
  const h6 = hashAttr(name, "hairstyle");

  const bg = "#dbeafe";
  const isFemale = gender?.toLowerCase() === "female";

  // Hair: gray/white for 65+, salt-and-pepper for 50-64, natural for under 50
  const youngHairs = ["#4a3728","#8B4513","#d4a017","#2c1810","#a0522d","#c8960c","#1a1a1a","#6b3a2a","#3d1f00","#7a4f00","#c0392b","#5d4037","#bf8040","#000000","#5c3317","#e8b84b"];
  const midHairs   = ["#8a7060","#9e8070","#7a6858","#b09080","#6a6060","#909090","#787060","#a09088","#706860","#c0a898","#585050","#b8a090"];
  const oldHairs   = ["#c8c8c8","#d8d8d8","#b8b8b8","#e0e0e0","#a8a8a8","#f0f0f0","#d0c8c0","#e8e0d8","#c0b8b0","#ddd8d0"];
  const hairPalette = age >= 65 ? oldHairs : age >= 50 ? midHairs : youngHairs;
  const hair = hairPalette[h1 % hairPalette.length];
  const hairDark = hair + "cc";

  // Eye color: fully independent — wider variety
  const eyeColors = ["#4a6fa5","#5c8a3c","#4a7a6a","#8a6040","#3a6a8a","#6a4a30","#2a6a5a","#3a8a5a","#8a5a3a","#4a4a8a","#6a8a3a","#8a3a4a","#3a4a6a","#7a6a2a"];
  const eyeColor = eyeColors[h2 % eyeColors.length];

  // Shirt color: independent — wider variety
  const shirtColors = ["#1e3a5f","#7c3aed","#0f766e","#b45309","#be123c","#1d4ed8","#065f46","#92400e","#4c1d95","#134e4a","#7f1d1d","#1e40af","#166534","#854d0e","#6b21a8","#0e7490","#9a3412","#1e3a5f","#365314","#831843"];
  const shirt = shirtColors[h3 % shirtColors.length];

  // Skin tone: independent — wider variety
  const skinTones = ["#f5cba7","#f0b88a","#e8a87c","#daa06d","#c68642","#f7d9b5","#d4956a","#ebb98a","#a0522d","#cd853f","#d2691e","#f4a460","#8b4513","#deb887","#c8956c","#fddbb4"];
  const skin = name === "Frank Larson" ? "#f7d9b5" : skinTones[h4 % skinTones.length];
  const skinDark = skin.replace(/[89a-f]/gi, c => (parseInt(c,16) - 2).toString(16));

  // Wrinkles for older patients
  const wrinkles = age >= 60 ? `
    <path d="M78 85 Q100 82 122 85" stroke="${skinDark}" stroke-width="0.8" fill="none" opacity="0.5"/>
    <path d="M82 79 Q100 76 118 79" stroke="${skinDark}" stroke-width="0.8" fill="none" opacity="0.4"/>
    <path d="M86 122 Q82 130 84 138" stroke="${skinDark}" stroke-width="1.2" fill="none" opacity="0.7"/>
    <path d="M114 122 Q118 130 116 138" stroke="${skinDark}" stroke-width="1.2" fill="none" opacity="0.7"/>` : "";

  // Glasses: independent hash
  const hasGlasses = age >= 50 && (h5 % 2 === 0);
  const glasses = hasGlasses ? `
    <rect x="70" y="95" width="24" height="16" rx="5" fill="none" stroke="#555" stroke-width="2"/>
    <rect x="106" y="95" width="24" height="16" rx="5" fill="none" stroke="#555" stroke-width="2"/>
    <path d="M94 103 L106 103" stroke="#555" stroke-width="2"/>
    <path d="M56 100 L70 100" stroke="#555" stroke-width="2"/>
    <path d="M130 100 L144 100" stroke="#555" stroke-width="2"/>` : "";

  // Bald: independent hash
  const isBald = !isFemale && age >= 60 && (hashAttr(name, "bald") % 3 === 0);

  // Hair style variant for females: 0=long, 1=medium bob
  const femaleHairStyle = h6 % 2;
  const femaleHair = femaleHairStyle === 0 ? `
    <path d="M54 90 Q52 60 70 50 Q100 38 130 50 Q148 60 146 90" fill="${hair}"/>
    <path d="M54 90 Q48 120 52 145" fill="${hair}" stroke="${hair}" stroke-width="12" stroke-linecap="round"/>
    <path d="M146 90 Q152 120 148 145" fill="${hair}" stroke="${hair}" stroke-width="12" stroke-linecap="round"/>
    <path d="M56 75 Q58 55 75 50 Q100 42 125 50 Q142 55 144 75" fill="${hairDark}"/>` : `
    <path d="M54 90 Q52 65 70 52 Q100 40 130 52 Q148 65 146 90" fill="${hair}"/>
    <path d="M54 90 Q50 110 55 125" fill="${hair}" stroke="${hair}" stroke-width="10" stroke-linecap="round"/>
    <path d="M146 90 Q150 110 145 125" fill="${hair}" stroke="${hair}" stroke-width="10" stroke-linecap="round"/>
    <path d="M56 75 Q58 55 75 50 Q100 42 125 50 Q142 55 144 75" fill="${hairDark}"/>`;

  const maleHairFull = `
    <ellipse cx="100" cy="68" rx="46" ry="22" fill="${hair}"/>
    <path d="M56 75 Q58 55 75 50 Q100 42 125 50 Q142 55 144 75" fill="${hairDark}"/>
    <path d="M56 80 Q52 90 54 105" stroke="${hair}" stroke-width="5" fill="none" stroke-linecap="round"/>
    <path d="M144 80 Q148 90 146 105" stroke="${hair}" stroke-width="5" fill="none" stroke-linecap="round"/>`;

  const maleHairBald = `
    <path d="M56 80 Q52 90 54 105" stroke="${hair}" stroke-width="4" fill="none" stroke-linecap="round"/>
    <path d="M144 80 Q148 90 146 105" stroke="${hair}" stroke-width="4" fill="none" stroke-linecap="round"/>
    <path d="M60 72 Q70 62 100 60 Q130 62 140 72" stroke="${hair}" stroke-width="3" fill="none" opacity="0.5"/>`;

  const hairSvg = isFemale ? femaleHair : (isBald ? maleHairBald : maleHairFull);

  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" width="200" height="200">
  <circle cx="100" cy="100" r="100" fill="${bg}"/>
  <rect x="78" y="138" width="44" height="35" rx="8" fill="${skin}"/>
  <path d="M68 165 Q100 185 132 165 L145 200 H55 Z" fill="${shirt}"/>
  <ellipse cx="100" cy="105" rx="46" ry="52" fill="${skin}"/>
  <ellipse cx="54" cy="110" rx="8" ry="11" fill="${skin}"/>
  <ellipse cx="146" cy="110" rx="8" ry="11" fill="${skin}"/>
  ${hairSvg}
  ${wrinkles}
  <path d="M72 95 Q82 91 92 93" stroke="#777" stroke-width="${age >= 60 ? 2 : 2.5}" fill="none" stroke-linecap="round"/>
  <path d="M108 93 Q118 91 128 95" stroke="#777" stroke-width="${age >= 60 ? 2 : 2.5}" fill="none" stroke-linecap="round"/>
  <ellipse cx="82" cy="102" rx="9" ry="7" fill="white"/>
  <ellipse cx="118" cy="102" rx="9" ry="7" fill="white"/>
  <circle cx="82" cy="102" r="5" fill="${eyeColor}"/>
  <circle cx="118" cy="102" r="5" fill="${eyeColor}"/>
  <circle cx="82" cy="102" r="3" fill="#1a1a2e"/>
  <circle cx="118" cy="102" r="3" fill="#1a1a2e"/>
  <circle cx="84" cy="100" r="1.2" fill="white"/>
  <circle cx="120" cy="100" r="1.2" fill="white"/>
  <path d="M94 120 Q100 125 106 120" stroke="${skinDark}" stroke-width="1.5" fill="none" stroke-linecap="round"/>
  <path d="M87 132 Q100 141 113 132" stroke="#c07050" stroke-width="2" fill="none" stroke-linecap="round"/>
  ${glasses}
</svg>`;

  return "data:image/svg+xml;base64," + btoa(svg);
}

function getPatientAvatar(name: string, gender: string, birthDate?: string): string {
  const age = birthDate
    ? Math.floor((Date.now() - new Date(birthDate).getTime()) / (1000 * 60 * 60 * 24 * 365.25))
    : 50;
  return generateAvatar(name, gender, age);
}

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

// Horizontal BMI gauge — matches the Health Chart screenshot style
function BmiGauge({ bmi, weight, height }: { bmi: number | null; weight: number | null; height: number | null }) {
  const MIN = 10, MAX = 40, RANGE = MAX - MIN;
  const zones = [
    { label: "Below 18.5 (Underweight)", color: "#fb923c", start: 10, end: 18.5 },
    { label: "18.5 – 24.9 (Normal)",     color: "#4ade80", start: 18.5, end: 25 },
    { label: "25 – 29.9 (Overweight)",   color: "#fbbf24", start: 25, end: 30 },
    { label: "30 or over (Obesity)",     color: "#f87171", start: 30, end: 40 },
  ];
  const pct  = bmi != null ? Math.max(0, Math.min(100, ((bmi - MIN) / RANGE) * 100)) : null;
  const cat  = bmi != null ? bmiCategory(bmi) : null;

  // Convert metric → US units for display
  const weightLbs = weight != null ? Math.round(weight * 2.20462) : null;
  const heightFtIn = height != null ? (() => {
    const totalInches = height / 2.54;
    const ft = Math.floor(totalInches / 12);
    const inches = Math.round(totalInches % 12);
    return `${ft}'${inches}"`;
  })() : null;

  return (
    <div className="flex flex-col gap-3">
      {/* Stats row */}
      <div className="flex flex-wrap items-baseline gap-5 text-sm">
        {bmi != null && (
          <span>
            BMI:{" "}
            <span className="text-2xl font-bold" style={{ color: cat?.color }}>
              {bmi}
            </span>
          </span>
        )}
        {weightLbs != null && (
          <span className="text-muted-foreground">
            Weight: <span className="font-semibold text-foreground">{weightLbs} lbs</span>
          </span>
        )}
        {heightFtIn != null && (
          <span className="text-muted-foreground">
            Height: <span className="font-semibold text-foreground">{heightFtIn}</span>
          </span>
        )}
      </div>

      {/* Colored bar + indicator dot */}
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

      {/* Scale labels */}
      <div className="flex justify-between px-0.5 text-xs text-muted-foreground">
        <span>10</span>
        <span>18.5</span>
        <span>25</span>
        <span>30</span>
        <span>40</span>
      </div>

      {/* Legend */}
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

// ── PatientBanner (list row) ──────────────────────────────────────────────────
function PatientBanner({ patient, onClick }: { patient: FhirPatient; onClick: () => void }) {
  const age = patient.birthDate
    ? Math.floor((Date.now() - new Date(patient.birthDate).getTime()) / (1000 * 60 * 60 * 24 * 365.25))
    : null;
  return (
    <Card className="cursor-pointer hover:shadow-md transition-shadow border-l-4 border-l-blue-400" onClick={onClick}>
      <CardContent className="p-4">
        <div className="flex items-center gap-4">
          <img
            src={getPatientAvatar(patient.name, patient.gender, patient.birthDate)}
            alt={patient.name}
            className="h-12 w-12 flex-shrink-0 rounded-full object-cover border-2 border-blue-100"
          />
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
                <span className="flex items-center gap-1"><Calendar className="h-3 w-3" />DOB: {fmt(patient.birthDate)}</span>
              )}
              {patient.mrn && (
                <span className="flex items-center gap-1"><Hash className="h-3 w-3" />MRN: {patient.mrn}</span>
              )}
              {patient.address?.city && (
                <span className="flex items-center gap-1"><MapPin className="h-3 w-3" />{[patient.address.city, patient.address.state].filter(Boolean).join(", ")}</span>
              )}
            </div>
          </div>
          <ChevronRight className="h-5 w-5 text-muted-foreground flex-shrink-0" />
        </div>
      </CardContent>
    </Card>
  );
}

const PhysicianView = () => {
  // ── Patient list ──────────────────────────────────────────────────────────
  const [patients, setPatients]       = useState<FhirPatient[]>([]);
  const [listLoading, setListLoading] = useState(true);
  const [listError, setListError]     = useState("");
  const [selectedId, setSelectedId]   = useState<string | null>(null);

  useEffect(() => {
    fetch(`${API_BASE}/api/fhir/patients`)
      .then(r => { if (!r.ok) throw new Error("Failed to load patients"); return r.json(); })
      .then(data => {
        const pts: FhirPatient[] = Array.isArray(data) ? data : [];
        pts.sort((a, b) => (a.name.split(" ").pop() ?? "").localeCompare(b.name.split(" ").pop() ?? ""));
        setPatients(pts);
      })
      .catch(e => setListError(e.message))
      .finally(() => setListLoading(false));
  }, []);

  // ── Patient detail ────────────────────────────────────────────────────────
  const [patient, setPatient]             = useState<FhirPatient | null>(null);
  const [conditions, setConditions]       = useState<Condition[]>([]);
  const [medications, setMedications]     = useState<Medication[]>([]);
  const [vitals, setVitals]               = useState<Observation[]>([]);
  const [labs, setLabs]                   = useState<Observation[]>([]);
  const [procedures, setProcedures]       = useState<Procedure[]>([]);
  const [immunizations, setImmunizations] = useState<Immunization[]>([]);
  const [encounters, setEncounters]       = useState<Encounter[]>([]);
  const [bpTrend, setBpTrend]             = useState<BpPoint[]>([]);
  const [loading, setLoading]             = useState(false);
  const [error, setError]                 = useState("");

  useEffect(() => {
    if (!selectedId) return;
    setPatient(patients.find(p => p.id === selectedId) ?? null);
    setLoading(true);
    setError("");
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
        setError(e.message || "Failed to load FHIR data");
      } finally {
        setLoading(false);
      }
    })();
  }, [selectedId]);

  function handleBack() {
    setSelectedId(null);
    setPatient(null);
    setConditions([]); setMedications([]); setVitals([]);
    setLabs([]); setProcedures([]); setImmunizations([]);
    setEncounters([]); setBpTrend([]);
  }

  const [summary, setSummary] = useState<string | null>(null);
  const [summaryLoading, setSummaryLoading] = useState<boolean>(false);
  const [summaryError, setSummaryError] = useState<string | null>(null);
  const [generating, setGenerating] = useState<boolean>(false);

  useEffect(() => {
    if (!selectedId) {
      setSummary(null);
      return;
    }
    setSummaryLoading(true);
    setSummaryError(null);

    fetch(`${API_BASE}/api/clinician_summary?patient_id=${selectedId}`)
      .then(r => {
        if (!r.ok) throw new Error("Could not load summary");
        return r.text();
      })
      .then((data: string) => {
        const cleanData = data.replace(/\\n/g, '\n').replace(/^"|"$/g, '');
        setSummary(cleanData || null);
      })
      .catch(e => {
        setSummaryError(e.message);
      })
      .finally(() => {
        setSummaryLoading(false);
      });
  }, [selectedId]);

  async function generateSummary() {
    if (!selectedId) return;
    setGenerating(true);
    setSummaryError(null);
    try {
      const r = await fetch(
        `${API_BASE}/api/clinician_summary/generate?patient_id=${selectedId}`,
        { method: "POST" }
      );
      if (!r.ok) {
        const detail = await r.json().then(j => j.detail).catch(() => null);
        throw new Error(detail ?? "Failed to generate summary");
      }
      const text = await r.text();
      const clean = text.replace(/\\n/g, '\n').replace(/^"|"$/g, '');
      setSummary(clean);
    } catch (e: unknown) {
      setSummaryError(e instanceof Error ? e.message : "Unknown error");
    } finally {
      setGenerating(false);
    }
  }

  const age = patient?.birthDate
    ? Math.floor((Date.now() - new Date(patient.birthDate).getTime()) / (1000 * 60 * 60 * 24 * 365.25))
    : null;

  // Derived trend data
  const bmiObs = vitals
    .filter(v => v.display.toLowerCase().includes("bmi") || v.display.toLowerCase().includes("mass index"))
    .sort((a, b) => a.date.localeCompare(b.date));

  const weightObs = vitals
    .filter(v => v.display.toLowerCase().includes("weight") && !v.display.toLowerCase().includes("bmi"))
    .sort((a, b) => a.date.localeCompare(b.date));

  const heightObs = vitals
    .filter(v => v.display.toLowerCase().includes("height"))
    .sort((a, b) => a.date.localeCompare(b.date));

  const bpChartData = bpTrend
    .map(p => ({ ...p, date: fmtYear(p.date), rawDate: p.date }))
    .sort((a, b) => a.rawDate.localeCompare(b.rawDate));

  const latestBmi    = bmiObs[bmiObs.length - 1];
  const latestWeight = weightObs[weightObs.length - 1];
  const latestHeight = heightObs[heightObs.length - 1];
  const latestBp     = bpChartData[bpChartData.length - 1];

  // ── Patient list view ─────────────────────────────────────────────────────
  if (!selectedId) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <div className="border-b border-border bg-card/40">
          <div className="container mx-auto flex items-center gap-2 px-4 py-4 sm:px-6">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-100">
              <Stethoscope className="h-4 w-4 text-blue-600" />
            </div>
            <span className="rounded-full bg-blue-100 px-3 py-1 text-body-sm font-medium text-blue-700">
              Physician View
            </span>
          </div>
        </div>
        <main className="container mx-auto px-4 py-6 sm:px-6">
          <div className="mb-5">
            <h2 className="text-xl font-semibold text-foreground">My Patients</h2>
          </div>
          {listLoading ? (
            <div className="space-y-3">{Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-[72px] w-full rounded-xl" />)}</div>
          ) : listError ? (
            <p className="text-sm text-destructive">{listError} — ensure the FHIR server is running and patient data is loaded.</p>
          ) : patients.length === 0 ? (
            <p className="text-sm text-muted-foreground">No patients found in FHIR server.</p>
          ) : (
            <div className="space-y-3">
              {patients.map(p => <PatientBanner key={p.id} patient={p} onClick={() => setSelectedId(p.id)} />)}
            </div>
          )}
        </main>
      </div>
    );
  }

  // ── Patient detail view ───────────────────────────────────────────────────
  return (
    <div className="min-h-screen bg-background">
      <Header />

      {/* ── Top bar ── */}
      <div className="border-b border-border bg-card/40">
        <div className="container mx-auto flex items-center gap-3 px-4 py-4 sm:px-6">
          <button
            onClick={handleBack}
            className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            <ArrowLeft className="h-4 w-4" />
            Patient List
          </button>
          <span className="text-muted-foreground">/</span>
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

      <main className="container mx-auto px-4 py-6 sm:px-6">

        {/* ── Patient header card ── */}
        <Card className="mb-6 shadow-card">
          <CardContent className="p-6">
            {loading ? (
              <div className="flex items-center gap-4">
                <Skeleton className="h-16 w-16 rounded-full" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-6 w-48" />
                  <Skeleton className="h-4 w-72" />
                </div>
              </div>
            ) : error ? (
              <p className="text-sm text-destructive">{error} — ensure the FHIR server is running and patient data is loaded.</p>
            ) : patient ? (
              <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                <img
                  src={getPatientAvatar(patient.name, patient.gender, patient.birthDate)}
                  alt={patient.name}
                  className="h-16 w-16 flex-shrink-0 rounded-full object-cover border-2 border-blue-100"
                />
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

        {/* ── 3 Main Tabs ── */}
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

          {/* ══════════════════════════════════════════════════════════
               Tab 1 — Health Overview
          ══════════════════════════════════════════════════════════ */}
          <TabsContent value="overview" className="space-y-6">

            {/* ── Row 1: BP Chart + BMI Gauge ── */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">

              {/* Blood Pressure Chart */}
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
                  {loading ? <Skeleton className="h-64 w-full" /> : bpChartData.length === 0 ? (
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
                        <Line
                          type="monotone"
                          dataKey="systolic"
                          name="Systolic"
                          stroke="#2563eb"
                          strokeWidth={2}
                          dot={<CustomBpDot />}
                          activeDot={{ r: 6 }}
                        />
                        <Line
                          type="monotone"
                          dataKey="diastolic"
                          name="Diastolic"
                          stroke="#7c3aed"
                          strokeWidth={2}
                          dot={{ r: 4, fill: "#7c3aed" }}
                          activeDot={{ r: 6 }}
                        />
                      </ComposedChart>
                    </ResponsiveContainer>
                  )}
                </CardContent>
              </Card>

              {/* BMI Gauge */}
              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-base">Height / Weight and BMI</CardTitle>
                </CardHeader>
                <CardContent>
                  {loading ? <Skeleton className="h-64 w-full" /> : (
                    <BmiGauge
                      bmi={latestBmi?.value ?? null}
                      weight={latestWeight?.value ?? null}
                      height={latestHeight?.value ?? null}
                    />
                  )}
                </CardContent>
              </Card>
            </div>

            {/* ── Row 2: Conditions + Medications ── */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <Card>
                <CardContent className="p-5">
                  <SectionHeader
                    icon={<span className="text-xs font-bold text-blue-600">Dx</span>}
                    title="Conditions"
                    count={conditions.length}
                  />
                  {loading ? <TableSkeleton cols={3} /> : (
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Condition</TableHead>
                          <TableHead>Onset</TableHead>
                          <TableHead>Status</TableHead>
                        </TableRow>
                      </TableHeader>
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
                  <SectionHeader
                    icon={<span className="text-xs font-bold text-blue-600">Rx</span>}
                    title="Medications"
                    count={medications.length}
                  />
                  {loading ? <TableSkeleton cols={3} /> : (
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Drug</TableHead>
                          <TableHead>Dosage</TableHead>
                          <TableHead>Status</TableHead>
                        </TableRow>
                      </TableHeader>
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

            {/* ── Row 3: Procedures + Immunizations ── */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <Card>
                <CardContent className="p-5">
                  <SectionHeader
                    icon={<span className="text-xs font-bold text-blue-600">Pr</span>}
                    title="Procedures"
                    count={procedures.length}
                  />
                  {loading ? <TableSkeleton cols={3} rows={3} /> : (
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Procedure</TableHead>
                          <TableHead>Date</TableHead>
                          <TableHead>Status</TableHead>
                        </TableRow>
                      </TableHeader>
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
                  <SectionHeader
                    icon={<span className="text-xs font-bold text-blue-600">Imm</span>}
                    title="Immunizations"
                    count={immunizations.length}
                  />
                  {loading ? <TableSkeleton cols={3} rows={3} /> : (
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Vaccine</TableHead>
                          <TableHead>Date</TableHead>
                          <TableHead>Status</TableHead>
                        </TableRow>
                      </TableHeader>
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

            {/* ── Row 4: Encounters + Labs ── */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <Card>
                <CardContent className="p-5">
                  <SectionHeader
                    icon={<span className="text-xs font-bold text-blue-600">En</span>}
                    title="Encounters"
                    count={encounters.length}
                  />
                  {loading ? <TableSkeleton cols={3} rows={3} /> : (
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Type</TableHead>
                          <TableHead>Date</TableHead>
                          <TableHead>Status</TableHead>
                        </TableRow>
                      </TableHeader>
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
                  <SectionHeader
                    icon={<FlaskConical className="h-3.5 w-3.5 text-blue-600" />}
                    title="Lab Results"
                    count={labs.length}
                  />
                  {loading ? <TableSkeleton cols={4} /> : (
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Test</TableHead>
                          <TableHead>Value</TableHead>
                          <TableHead>Unit</TableHead>
                          <TableHead>Date</TableHead>
                        </TableRow>
                      </TableHeader>
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

          {/* ══════════════════════════════════════════════════════════
               Tab 2 — AI Summary 
          ══════════════════════════════════════════════════════════ */}
          <TabsContent value="ai">
            <Card className="overflow-hidden border-none shadow-none">
              <CardContent className="flex flex-col items-center py-12 px-6">
                <div className="mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-blue-50">
                  {summaryLoading || generating ? (
                    <Loader2 className="h-8 w-8 text-blue-500 animate-spin" />
                  ) : (
                    <Brain className="h-8 w-8 text-blue-500" />
                  )}
                </div>

                <div className="max-w-3xl w-full">
                  <h3 className="text-xl font-bold text-slate-900 text-center mb-6">
                    AI Clinical Summary
                  </h3>

                  {summaryLoading ? (
                    <div className="space-y-4">
                      <Skeleton className="h-4 w-full" />
                      <Skeleton className="h-4 w-[90%]" />
                      <Skeleton className="h-4 w-[95%]" />
                    </div>
                  ) : summaryError ? (
                    <div className="p-4 rounded-md bg-red-50 text-red-700 text-sm text-center">
                      {summaryError}
                    </div>
                  ) : summary ? (
                    <>
                      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
                        <div className="p-6 space-y-4">
                          {summary.split('\n').map((line, i) => {
                            const trimmed = line.trim();
                            if (!trimmed) return null;

                            // Check if it's a bullet point
                            if (trimmed.startsWith('-')) {
                              return (
                                <div key={i} className="flex gap-3 text-sm leading-relaxed text-slate-700">
                                  <span className="text-blue-500 font-bold">•</span>
                                  <span>{trimmed.replace(/^-/, '').trim()}</span>
                                </div>
                              );
                            }

                            // Treat non-bullets as headers/titles
                            return (
                              <p key={i} className="text-sm font-semibold text-slate-900 pt-2 border-b border-slate-100 pb-2">
                                {trimmed}
                              </p>
                            );
                          })}
                        </div>
                        <div className="bg-slate-50 px-6 py-3 border-t border-slate-100 flex items-center justify-between">
                          <p className="text-[10px] text-slate-400 uppercase tracking-wider font-medium">
                            Generated by Clinical AI • {new Date().toLocaleDateString()}
                          </p>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={generateSummary}
                            disabled={generating}
                            className="text-xs text-slate-500 hover:text-slate-700"
                          >
                            {generating ? (
                              <Loader2 className="h-3 w-3 mr-1 animate-spin" />
                            ) : (
                              <RefreshCw className="h-3 w-3 mr-1" />
                            )}
                            Refresh
                          </Button>
                        </div>
                      </div>
                    </>
                  ) : (
                    <div className="flex flex-col items-center gap-4">
                      <p className="text-center text-muted-foreground italic">No summary generated yet.</p>
                      <Button
                        onClick={generateSummary}
                        disabled={generating}
                        className="bg-blue-600 hover:bg-blue-700 text-white"
                      >
                        {generating ? (
                          <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                        ) : (
                          <Brain className="h-4 w-4 mr-2" />
                        )}
                        {generating ? "Generating…" : "Generate AI Summary"}
                      </Button>
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </main>
    </div>
  );
};

export default PhysicianView;
