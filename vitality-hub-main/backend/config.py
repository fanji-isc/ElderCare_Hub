import os

IRIS_HOST      = os.environ.get("IRIS_HOST",      "localhost")
IRIS_PORT      = int(os.environ.get("IRIS_PORT",  "1972"))
IRIS_NAMESPACE = os.environ.get("IRIS_NAMESPACE", "USER")
IRIS_USERNAME  = os.environ.get("IRIS_USERNAME",  "_SYSTEM")
IRIS_PASSWORD  = os.environ.get("IRIS_PASSWORD",  "demo")