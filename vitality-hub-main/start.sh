#!/bin/bash
set -e

echo "==> Starting IRIS..."
# We removed the 'su' wrapper. Just call iris directly.
iris start IRIS quietly

# Disable exit-on-error for the wait loop
set +e

echo "==> Waiting for IRIS to be ready..."
# We test the connection until it succeeds
until iris session IRIS -U USER "quit" > /dev/null 2>&1; do
    echo "    ...still waiting for IRIS"
    sleep 2
done
echo "==> IRIS is ready."

# ── FHIR server setup ────────────────────────────────────────────────────────
if [ ! -f /data/fhir-setup-done ]; then
    echo "==> First run: setting up FHIR server and loading patient data..."
    iris session IRIS < /scripts/fhirserver.script
    iris session IRIS < /scripts/enablecors.script
    touch /data/fhir-setup-done
    echo "==> FHIR setup complete."
else
    echo "==> FHIR already configured, skipping."
fi

echo "==> Loading Garmin data into IRIS..."
# Using the full path to the venv python
/opt/venv/bin/python /app/backend/iris_db.py

echo "==> Starting FastAPI backend on :3001..."
# Running in background
/opt/venv/bin/uvicorn backend.api:app --host 0.0.0.0 --port 3001 --reload &

echo "==> Starting Vite dev server on :8080..."
# Running in background
npm --prefix /app run dev -- --host 0.0.0.0 --port 8080 &

echo ""
echo "All services are initializing..."
echo "  Web UI : http://localhost:8080"
echo "  API    : http://localhost:3001"
echo "  IRIS   : http://localhost:52773/csp/sys/UtilHome.csp"
echo ""

# This keeps the script (and container) alive
wait