FROM containers.intersystems.com/intersystems/irishealth-community:latest-cd

USER root

# ── Install Node.js 20 ──────────────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y curl gnupg python3 python3-venv python3-pip dos2unix && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── IRIS / FHIR directories ─────────────────────────────────────────────────
RUN mkdir -p /scripts /data/ifconfig /fhirdata

# ── Copy FHIR setup files ────────────────────────────────────────────────────
COPY ./merge/CMF.cpf /merge/CMF.cpf
COPY ./scripts/fhirserver.script /scripts/fhirserver.script
COPY ./scripts/enablecors.script /scripts/enablecors.script

# ── Copy FHIR sample data ────────────────────────────────────────────────────
COPY ./fhirdata/ /fhirdata/

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

# Fix Windows line endings and make the script executable
RUN sed -i 's/\r$//' /start.sh && chmod +x /start.sh

# Ensure the IRIS user owns everything it needs
RUN chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} \
    /data/ /fhirdata/ /merge/ /scripts/ /app /start.sh

# ── Switch back to the IRIS user ────────────────────────────────────────────
USER ${ISC_PACKAGE_MGRUSER}

EXPOSE 8080 3001 52773 1972

ENV ISC_DATA_DIRECTORY=/data/ifconfig
ENV ISC_CPF_MERGE_FILE=/merge/CMF.cpf

ENTRYPOINT ["/start.sh"]