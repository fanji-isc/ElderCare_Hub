FROM containers.intersystems.com/intersystems/irishealth-community:latest-cd

USER root

# ── Install Node.js 20 ──────────────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y curl gnupg python3 python3-venv python3-pip && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── IRIS / FHIR directories ─────────────────────────────────────────────────
RUN mkdir -p /scripts /data/ifconfig /fhirdata

# ── Copy FHIR setup files ────────────────────────────────────────────────────
COPY ./merge/CMF.cpf /merge/CMF.cpf
COPY ./scripts/fhirserver.script /scripts/fhirserver.script
COPY ./scripts/enablecors.script /scripts/enablecors.script

# ── Copy FHIR sample data (loaded into IRIS during the bake step) ────────────
COPY ./fhirdata/ /fhirdata/

RUN chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} \
    /data/ /fhirdata/ /merge/ /scripts/

USER root

# ── Node app ─────────────────────────────────────────────────────────────────
WORKDIR /app
COPY package*.json ./
RUN npm ci

# ── Python API ───────────────────────────────────────────────────────────────
COPY backend/requirements.txt /app/backend/requirements.txt
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r /app/backend/requirements.txt

# ── Copy project files ───────────────────────────────────────────────────────
COPY . .

# ── Startup script ───────────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080 3001 52773 1972

ENV ISC_DATA_DIRECTORY=/data/ifconfig
ENV ISC_CPF_MERGE_FILE=/merge/CMF.cpf

ENTRYPOINT ["/start.sh"]
