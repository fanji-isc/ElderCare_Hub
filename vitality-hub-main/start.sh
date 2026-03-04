#!/bin/bash
set -e

echo "==> Starting IRIS..."
su -s /bin/bash ${ISC_PACKAGE_MGRUSER} -c "iris start IRIS quietly"

# Disable exit-on-error for non-critical steps below
set +e

echo "==> Waiting for IRIS to be ready..."
until su -s /bin/bash ${ISC_PACKAGE_MGRUSER} -c "iris session IRIS -U USER 'write 1 halt'" > /dev/null 2>&1; do
    sleep 3
done
echo "==> IRIS is ready."

# ── FHIR server setup — runs once on first boot, skipped on restarts ──────────
if [ ! -f /data/fhir-setup-done ]; then
    echo "==> First run: setting up FHIR server and loading patient data..."
    su -s /bin/bash ${ISC_PACKAGE_MGRUSER} -c "iris session IRIS < /scripts/fhirserver.script"
    su -s /bin/bash ${ISC_PACKAGE_MGRUSER} -c "iris session IRIS < /scripts/enablecors.script"
    touch /data/fhir-setup-done
    echo "==> FHIR setup complete."
else
    echo "==> FHIR already configured, skipping."
fi

echo "==> Loading Garmin data into IRIS..."
IRIS_HOST=localhost IRIS_PORT=1972 IRIS_NAMESPACE=USER \
    IRIS_USERNAME=_SYSTEM IRIS_PASSWORD=demo \
    /opt/venv/bin/python /app/backend/iris_db.py


echo "==> Starting FastAPI backend on :3001..."
IRIS_HOST=localhost IRIS_PORT=1972 IRIS_NAMESPACE=USER \
    IRIS_USERNAME=_SYSTEM IRIS_PASSWORD=demo \
    /opt/venv/bin/uvicorn backend.api:app --host 0.0.0.0 --port 3001 --reload &

echo "==> Starting Vite dev server on :8080..."
npm --prefix /app run dev -- --host 0.0.0.0 --port 8080 &

echo ""
echo "All services running:"
echo "  Web UI : http://localhost:8080"
echo "  API    : http://localhost:3001"
echo "  IRIS   : http://localhost:52773"
echo "  FHIR   : http://localhost:52773/csp/healthshare/demo/fhir/r4"
echo ""

wait
