# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Vitality Hub is a multi-view health monitoring dashboard for elderly care. It displays Garmin wearable data (heart rate, ECG, sleep, stress, steps, gait) and other smart household devices (smart toilet - hydration , smart fridge - nutrition) alongside FHIR clinical records, with a voice-controlled AI assistant powered by OpenAI. Data is stored in InterSystems IRIS Health via ObjectScript.

**Three primary views:**
- **Elder View** (`src/pages/ElderView.tsx`) — patient-facing dashboard with all health metrics alonside data about their neighborhood
- **Family View** (`src/pages/FamilyView.tsx`) — caregiver overview of the patient's vitals
- **Physician View** (`src/pages/PhysicianView.tsx`) — clinical view with FHIR data (conditions, medications, labs, vitals, procedures)

## Running the Project

Requires a `.env` file in the root with `OPENAI_API_KEY=sk-...` before starting.

```bash
docker compose up --build   # Start all services (iris, api, web)
```

- Web UI: http://localhost:8080
- IRIS Management Portal: http://localhost:52773/csp/sys/UtilHome.csp (user: `_SYSTEM`, pass: `demo`)
- Backend API: http://localhost:3001

> **Hot reload:** Changes to `backend/` are picked up instantly via Vite HMR — no restart needed.
> **Requires restart:** Changes to `src/` require `docker compose restart`.
> **Requires rebuild:** Changes to `garmin/`, or `fhirdata/` require `docker compose down -v && docker compose up --build`.

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
| `GET /api/iris_data?column=hr` | Heart rate epoch data |
| `GET /api/iris_data?column=sleep` | Sleep stages |
| `GET /api/iris_data?column=ecg` | ECG waveform |
| `GET /api/iris_data?column=dailySummary` | Steps, resting HR, stress |
| `GET /api/iris_data?column=gait` | Gait / fall risk metrics |
| `GET /api/iris_data?column=fridge` | Smart fridge / nutrition data |
| `GET /api/iris_data?column=toilet` | Hydration / toilet events |
| `GET /api/iris_data?column=neighborhood` | Community activity |
| `GET /api/iris_data?column=phoneCalls` | Phone call log |
| `GET /api/get-vitals` | Vitals data for dashboard |
| `GET /api/fhir/patients` | FHIR patient list |
| `GET /api/fhir/patient` | Single patient demographics |
| `GET /api/fhir/conditions` | Active conditions |
| `GET /api/fhir/medications` | Medications (called by patient ID) |
| `GET /api/fhir/patient-medications` | Medications (called by patient name) |
| `GET /api/fhir/vitals` | Vital signs |
| `GET /api/fhir/labs` | Lab results |
| `GET /api/fhir/procedures` | Procedures |
| `GET /api/fhir/immunizations` | Immunizations |
| `GET /api/fhir/encounters` | Encounters |
| `GET /api/fhir/bp-trend` | Blood pressure trend |
| `GET /api/fhir/appointments` | Appointments |
| `GET /api/fhir/patient-appointments` | Appointments (called by patient name) |
| `POST /api/clinician_summary/generate` | Generate FHIR summary for clinician (including home data section) |
| `GET /api/clinician_summary` | Retrieve FHIR summary for clinician (including home data section) |
| `GET /api/system-prompt` | System prompt for ElderView agent |
| `GET /api/checkin-prompt` | Assistant prompt for ElderView agent |
| `POST /api/transcribe` | Audio → GPT-4o-mini transcription |
| `POST /api/answer/stream` | Streaming Text → GPT-5.4-nano response |
| `POST /api/speak` | Text → OpenAI TTS-1-HD audio with Nova voice |

**Database**: InterSystems IRIS Health. `backend/iris_db.py` runs at startup to load `garmin/*.json` and `fhirdata/*.json` files into IRIS under the ID `PATIENT_001`, who is `Frank Larson`.

## Key Data Flow

1. On startup, `iris_db.py` reads `garmin/` and `fhirdata/` JSON files and stores them in IRIS under `PATIENT_001`.
2. Frontend fetches health metrics from the backend via the FastAPI endpoints
3. Voice assistant: hold VoiceButton → WebM/Opus audio → `/api/transcribe` → `/api/answer/stream` → `/api/speak` → audio playback.

## Data Files

| Directory | Contents |
|---|---|
| `garmin/` | `heart_rate.json`, `sleep.json`, `ECG.json`, `daily_summary.json`, `gait.json`, `fridge.json`, `toilet_hydration.json`, `neighborhood_activities.json` |
| `fhirdata/` | FHIR R4 bundles for Frank Larson and other patients within the Vitality Hub (used by Physician View) |

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18, TypeScript, Vite, Tailwind CSS, shadcn/ui, Recharts, TanStack Query |
| Backend | Python 3.11, FastAPI, Uvicorn |
| Database | InterSystems IRIS Health Community (ObjectScript) |
| AI | OpenAI API (gpt-5.4-nano, gpt-4o-mini-transcribe, tts-1-hd) |

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
