import os

# IRIS connection settings
IRIS_HOST = os.getenv("IRIS_HOST", "localhost")
IRIS_PORT = os.getenv("IRIS_PORT", "1972")
IRIS_NAMESPACE = os.getenv("IRIS_NAMESPACE", "USER")
IRIS_USER = os.getenv("IRIS_USER", "_SYSTEM")
IRIS_PASSWORD = os.getenv("IRIS_PASSWORD", "demo")