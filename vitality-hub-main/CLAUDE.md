# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Vitality Hub is a multi-view health monitoring dashboard for elderly care. It displays Garmin wearable data (heart rate, sleep, ECG, gait, daily activity, smart fridge/nutrition) alongside FHIR clinical records, with a voice-controlled AI assistant powered by OpenAI. Data is stored in InterSystems IRIS Health via ObjectScript.

**Three primary views:**
- **Elder View** (`src/pages/ElderView.tsx`) — patient-facing dashboard with all health metrics
- **Family View** (`src/pages/FamilyView.tsx`) — simplified caregiver overview of Frank Larson's vitals
- **Physician View** (`src/pages/PhysicianView.tsx`) — clinical view with FHIR data (conditions, medications, labs, vitals, procedures)

## Running the Project

Requires a `.env` file in the root with `OPENAI_API_KEY=sk-...` before starting.

```bash
docker compose up --build   # Start all services (iris, api, web)
```

- Web UI: http://localhost:8080
- IRIS Management Portal: http://localhost:52773/csp/sys/UtilHome.csp (user: `_SYSTEM`, pass: `demo`)
- Backend API: http://localhost:3001

> **Hot reload:** Changes to `src/` are picked up instantly via Vite HMR — no restart needed.
> **Requires rebuild:** Changes to `backend/`, `garmin/`, or `fhirdata/` require `docker compose down -v && docker compose up --build`.

## Frontend Development Commands

```bash
npm run dev       # Start Vite dev server (port 8080)
npm run build     # Production build
npm run lint      # ESLint
npm run preview   # Preview production build
```

## Architecture

Three Docker services communicate as follows:

```
Browser (8080) → [Vite/React] → /api proxy → [FastAPI (3001)] → [IRIS Health (1972)]
```

**Frontend** (`src/`): React 18 + TypeScript + Vite + Tailwind CSS + shadcn/ui + Recharts.

**Backend** (`backend/api.py`): FastAPI serving Garmin health data, FHIR records, and three OpenAI voice endpoints:

| Endpoint | Purpose |
|---|---|
| `GET /api/hr` | Heart rate epoch data |
| `GET /api/sleep` | Sleep stages |
| `GET /api/ecg` | ECG waveform |
| `GET /api/dailySummary` | Steps, resting HR, stress |
| `GET /api/gait` | Gait / fall risk metrics |
| `GET /api/fridge` | Smart fridge / nutrition data |
| `GET /api/toilet` | Hydration / toilet events |
| `GET /api/neighborhood` | Community activity |
| `GET /api/phone_calls` | Phone call log |
| `GET /api/fhir/patients` | FHIR patient list |
| `GET /api/fhir/patient` | Single patient demographics |
| `GET /api/fhir/conditions` | Active conditions |
| `GET /api/fhir/medications` | Medications |
| `GET /api/fhir/vitals` | Vital signs |
| `GET /api/fhir/labs` | Lab results |
| `GET /api/fhir/procedures` | Procedures |
| `GET /api/fhir/immunizations` | Immunizations |
| `GET /api/fhir/encounters` | Encounters |
| `GET /api/fhir/bp-trend` | Blood pressure trend |
| `POST /api/transcribe` | Audio → Whisper transcription |
| `POST /api/answer` | Text → GPT-4o-mini response |
| `POST /api/answer/stream` | Streaming version of /answer |
| `POST /api/speak` | Text → OpenAI TTS audio |

**Database**: InterSystems IRIS Health. `backend/iris_db.py` runs at startup to load `garmin/*.json` and `fhirdata/*.json` files into IRIS under patient key `PATIENT_001`.

## Key Data Flow

1. On startup, `iris_db.py` reads `garmin/` and `fhirdata/` JSON files and stores them in IRIS under patient key `PATIENT_001`.
2. Frontend fetches health metrics and derives values:
   - Sleep hours = `(deepSleepSeconds + lightSleepSeconds + remSleepSeconds) / 3600`
   - Energy = `bodyBatteryStatList` MOSTRECENT/ENDOFDAY entry
   - Stress = `allDayStress.aggregatorList` where `type === "AWAKE"`
3. Voice assistant: hold VoiceButton → WebM/Opus audio → `/api/transcribe` → `/api/answer` → `/api/speak` → audio playback.

## Data Files

| Directory | Contents |
|---|---|
| `garmin/` | `heart_rate.json`, `sleep.json`, `ECG.json`, `daily_summary.json`, `gait.json`, `fridge.json`, `toilet_hydration.json`, `neighborhood_activities.json` |
| `fhirdata/` | FHIR R4 bundles for Frank Larson and other patients (used by Physician View) |

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18, TypeScript, Vite, Tailwind CSS, shadcn/ui, Recharts, TanStack Query |
| Backend | Python 3.11, FastAPI, Uvicorn |
| Database | InterSystems IRIS Health Community (ObjectScript) |
| AI | OpenAI API (gpt-4o-mini, Whisper, TTS) |

## IRIS Database

- Connection config: `backend/config.py` (host: `iris4health`, port: `1972`, namespace: `USER`)
- ObjectScript source: `backend/iris/MyApp/` — `MyApp.JSONStore` (persistent storage), `MyApp.Utils` (save/retrieve methods)
- Loaded into container via Docker volume mount at `/iris-src`
- Data persisted in `data/` directory (Docker volume)

## UI Conventions

All metric cards follow this consistent structure:
- Wrapper: `rounded-2xl bg-card shadow-card overflow-hidden`
- Header: `flex items-center gap-3 border-b border-border px-5 py-3.5` with a gradient background
- Icon: `h-9 w-9 rounded-xl` container, `h-4 w-4` icon
- Title: `text-sm font-semibold text-foreground leading-tight` (use `p` tag, not `h3`, to avoid browser default heading styles)
- Subtitle: `text-xs text-muted-foreground`
- Body: `p-5`
