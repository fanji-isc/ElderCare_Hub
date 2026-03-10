import os
import json
import urllib3
import requests
from dotenv import load_dotenv

# This line hides the "InsecureRequestWarning" that pops up when you disable SSL --> TODO: find a way to point it to a .pem/.crt
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

load_dotenv()
FHIRFacadeURL = os.getenv('FHIRFacadeURL')
eleanor_turner = os.getenv('PatientNHSNumber')
headers = {
  'Authorization': os.getenv('FHIRFacadeAuth')
}

def get_patient_record(NHS_number: int = eleanor_turner) -> str:
    """This function fetches a given patients patient record from the UKSalesDemo189 HealthConnect FHIR Facade.
    
    arguments:
    NHS_number: The patient's 10 digit long NHS number. If left empty, defaults to Eleanor Turner.
    
    returns: The json string.
    """
    if len(NHS_number) != 10:
        return "NHS numbers must be exactly 10 digits long. This is an invalid NHS number"
    
    patient_url = f"{FHIRFacadeURL}/r4/Patient/{NHS_number}"

    response = requests.request("GET", patient_url, headers=headers, data={}, verify=False)

    if response.status_code == 200:
        fhir_record = response.json()
        return json.dumps(fhir_record)
    else:
        return f"Failed to retrieve data. Status code: {response.status_code}"
    

def fhir_query_tool(fhir_endpoint: str) -> dict:
    """
        Takes in a valid FHIR vR4 endpoint URL (HTTP method, path including query string, and JSON body if needed) and performs a GET request on the configured FHIR Server to retrieve the resource data. 
		Ensure the information that would be retrieved from the input request is general enough to summarise and answer the question, while using the appropriate search coding system and code values.
		Use only endpoints and parameters consistent with FHIR RESTful API.

		EXAMPLES:
		NL: "Find female patients born after 1985"
		fhir_endpoint: /Patient?gender=female&birthdate=gt1985-01-01

		Some examples of correct REST API requests for the FHIR R4 specification are:
		/Patient
		/Patient/1
		/Patient?given=Bailey
		/Patient?family=roberts
		/Patient?birthdate=1932-2-23
		/Patient?given=Alvina&birthdate=1967-7-23
		/Patient?given:contains=alv
		/Patient/1/$everything
		/Patient?_count=2
		/Patient?_summary=count
		/Patient?address-city=London&birthdate=lt2000-01-01
		/Observation?patient=1
		/Observation?subject:Patient.name=Aaron
		/Patient?_has:Observation:subject:value-concept=266919005
		/Observation?code=8302-2&value-quantity=gt180|http://unitsofmeasure.org|cm
		/Encounter?patient=1&date=ge2020-01-01T:00:00:00+00:00&date=le2024-01-01T00:00:00+00:00
		/Encounter?class=EMER&_summary=count
		/Patient?_id=1&_revinclude=Observation:subject

		args:
			fhir_endpoint: a valid FHIR vR4 endpoint URL (HTTP method, path including query string, and JSON body if needed).
		returns:
			A JSON object containing the FHIR resource data or an error message.
    """    
    if fhir_endpoint[0] != "/":
        fhir_endpoint = "/" + fhir_endpoint
    
    FHIR_SERVER_BASE = f"{FHIRFacadeURL}/r4"
    
    try:
        response = requests.get(FHIR_SERVER_BASE + fhir_endpoint, headers=headers, data={}, verify=False)

        if response.status_code != 200:
            return {"status": "error", "message": f"An error occurred while trying to reach the FHIR Server at {FHIR_SERVER_BASE + fhir_endpoint}: {response.status_code}"}

        return {"status": "success", "data": str(response.content)}
    except Exception as ex:
        return {"status": "error", "message": f"An error occurred while trying to reach the FHIR Server: {ex}"}
    
resp_dict = fhir_query_tool(f"/Observation?patient={eleanor_turner}")
if resp_dict["status"] == "success":
    print(resp_dict["data"])
else:
    print(resp_dict["message"])