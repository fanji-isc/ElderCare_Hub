import os
from dotenv import load_dotenv
from openai import OpenAI
from operator import itemgetter
import json


# Setup Paths
base_dir = os.path.dirname(__file__)
FHIR_inpath = os.path.join(base_dir, os.pardir, os.pardir, "fhirdata/Frank_Larson_c7c448b0-f1f5-45c2-aa50-2763f799c984.json")

# Initialize Environment
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=api_key)

def get_clinical_risks(patient_fhir):
    def _find_condition(file_path: str, target_condition: str) -> dict | None:
        condition_names = itemgetter("condition_names")

        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                record = json.loads(line)
                if target_condition in condition_names(record):
                    return record
        return None

    falls_condition = _find_condition(os.path.join(base_dir, os.pardir, "utils/conditions/nhs_conditions_pages.jsonl"), "Falls")

    response = client.chat.completions.create(
        model="gpt-5", 
        messages=[
            # {
            #     "role": "system", 
            #     "content": "You are an expert medical data analyst specializing in FHIR R4. When given a FHIR bundle, you should analyse their medical history to determine what conditions they are at risk for."
            #                 "Format your answer in plaintext."
            # },
            # {
            #     "role": "system", 
            #     "content": "You are an expert medical data analyst specializing in FHIR R4. When given a FHIR bundle, you should analyse their medical history to determine what conditions they are at risk for. "
            #                 "Validate whether the given patient is a Fall Risk using the given dictionary as your window of context. "
            #                 "The format of the answer returned should be a dictionary where the first key is 'fall_risk' for the Boolean of whether the patient is or is not. The second is 'reasoning'. "
            #                 "Only use the given dictionary. Do not make any inferences based on knowledge from other sources. "
            #                 f"Dictionary: \n{falls_condition}"
            # },
            # {
            #     "role": "system", 
            #     "content": "You are an expert medical data analyst specializing in FHIR R4. When given a FHIR bundle, you should analyse their medical history to determine what conditions they are at risk for. "
            #                 "The format of the answer returned should be a dictionary where the first key is the 'condition' they are at risk for. The second is 'reasoning'. "
            #                 "Be clear and concise, only include conditions that are high risk. "
            # },
            {
                "role": "system", 
                "content": "You are an expert medical data analyst specializing in FHIR R4 speaking directly to a clinician. When given a FHIR bundle, you should analyse the patient's medical history to determine what conditions they are at risk for. "
                            "The format of the answer should be plain text. "
                            "Be clear and concise, only include conditions that are high risk so that a clinician can interprete this quickly. "
                            "DO NOT try and provide the clinician with any advise on further actions or perform any diagnoses yourself."
            },
            {
                "role": "user", 
                "content": f"Analyze this FHIR bundle and provide a short summary of his clinical risks:\n\n{patient_fhir}"
            }
        ]
    )
    return response.choices[0].message.content

def get_agent_tasklist(clinical_risks):
    response = client.chat.completions.create(
        model="gpt-5", 
        messages=[
            {
                "role": "system", 
                "content": "You are an orchestrator agent. When given a list of clinical risks, determine what each agent's tasklist should be. "
                            "These tasklists should be as basic as possible. These agents have limited independency. "
                            "Format your answer as a dictionary with each key being an agents name, and the value is their respective tasklist. Don't duplicate the object keys, define their tasklist in a single instruction set."
            },
            {
                "role": "system", 
                "content": "You are an orchestrator agent for an appliance agent and a wellbeing agent. These agents have patient consent to perform the following roles: "
                            " - The appliance agent has access to data about the household's smart devices (lights, kettle) and the patient's Garmin watch, and is able to analyse these to look out for signs of the clinical risks. "
                            " - The wellbeing agent is able to interact with the patient directly through a chat interface to give them advice to avoid their clinical risks. They cannot begin an interaction and so their tasklist should be about what to look out for during sessions."
            },
            {
                "role": "user", 
                "content": f"Analyze this short summary of the patient's clinical risks:\n\n{clinical_risks}"
            }
        ]
    )
    return response.choices[0].message.content

def main():
    try:
        with open(FHIR_inpath, "r") as file:
            content = file.read()
    except FileNotFoundError:
        print(f"Error: Could not find file at {FHIR_inpath}")
        exit()

    analysis_result = get_clinical_risks(content)

    print(f"Analysis results: \n{analysis_result}")


main()