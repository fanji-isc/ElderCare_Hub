import os
from dotenv import load_dotenv
from openai import OpenAI

# Setup Paths
base_dir = os.path.dirname(__file__)
FHIR_inpath = os.path.join(base_dir, os.pardir, os.pardir, "iris_utils/patient/EleanorTurner_FHIR.json")

# Initialize Environment
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=api_key)


def get_clinical_risks(patient_fhir):
    response = client.chat.completions.create(
        model="gpt-5", 
        messages=[
            {
                "role": "system", 
                "content": "You are an expert medical data analyst specializing in FHIR R4. When given a FHIR bundle, you should analyse their medical history to determine what conditions they are at risk for."
                            "Format your answer in plaintext."
            },
            {
                "role": "user", 
                "content": f"Analyze this FHIR bundle and provide a short summary of her clinical risks:\n\n{patient_fhir}"
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

def main(full_run):
    if full_run:
        FHIR_inpath = os.path.join(base_dir, os.pardir, os.pardir, "iris_utils/patient/EleanorTurner_FHIR.json")
        try:
            with open(FHIR_inpath, "r") as file:
                content = file.read()
        except FileNotFoundError:
            print(f"Error: Could not find file at {FHIR_inpath}")
            exit()

        analysis_result = get_clinical_risks(content)
        tasklists = get_agent_tasklist(analysis_result)

        print(f"Analysis results: \n{analysis_result}")
        print("\n")
        print(f"Tasklists: \n{tasklists}")
    else:
        analysis_inpath = os.path.join(base_dir, "EleanorTurner_FHIR.txt")
        try:
            with open(analysis_inpath, "r") as file:
                analysis_result = file.read()
        except FileNotFoundError:
            print(f"Error: Could not find file at {analysis_inpath}")
            exit()

        tasklists = get_agent_tasklist(analysis_result)

        print(f"Analysis results: \n{analysis_result}")
        print("\n")
        print(f"Tasklists: \n{tasklists}")

main(False)