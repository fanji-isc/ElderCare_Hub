# # syntax=docker/dockerfile:1

# FROM node:20-alpine

# WORKDIR /app

# # Install deps first for caching
# COPY package*.json ./
# RUN npm ci

# # Copy the rest
# COPY . .

# EXPOSE 8080

# # Vite must bind to all interfaces inside Docker
# CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "8080"]
# syntax=docker/dockerfile:1
# syntax=docker/dockerfile:1
FROM node:20-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y python3 python3-venv python3-pip \
 && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

COPY backend/requirements.txt /app/backend/requirements.txt
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir -r /app/backend/requirements.txt

COPY . .

EXPOSE 8080
CMD ["sh", "-lc", "/opt/venv/bin/python backend/iris_db.py && npm run dev -- --host 0.0.0.0 --port 8080"]
