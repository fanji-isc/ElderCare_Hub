# Explaination
This README is for when this folder was a project in itself, file paths and other specific information may not be accurate now! Use this for overarching logic understanding.

## Overview
This repository illustrates how InterSystems IRIS for Health can support NOHA's needs using a Multi Agentic Workflow. Specifically, this is by providing a network of agents access to data stored within IRIS consumed by APIs, enabling them to detect events.

Within the fall detection demo, there exists an **Appliance Agent** monitoring device data to determine daily activities. This is held within the schemas defined within the .env file of this repository. If it receives an alert from the wearable device of the resident, it should then hand off to the **Wellbeing Agent**. 
This agent has access to the Chatbot, via the schema defined within the .env file of this repository which is where the chat history is saved. By monitoring response times, it then decides whether to handoff to the **Messaging Agent** to send an email to the resident's circle of care.

Work on the fall prevention demo is still ongoing, looking at detecting that a resident, Eleanor Turner, is a high fall risk. This will be done by accessing her medical records (via FHIR Facade), her wearable data to monitor her daily step count, and her household appliance data for her lifestyle habits.

## Getting Started
### Prerequisites
- Python 3.12.9
- Environment configuration via a .env file

### Setting up the Python Environment
Using Python 3.12.9, create a virtual environment for the project:
```bash
python -m venv .venv
```
Activate with:
```bash
.venv\Scripts\activate
```
Within the virtual environment, install the necessary packages:
```bash
pip install -r iris-local\requirements.txt
```

Then install iris-python into the virtual environment:
```bash
pip install --upgrade intersystems-irispython
```

### Configuring InterSystems IRIS
Build the docker container in detached mode by running:
```bash
docker-compose up -d --build
```

If you need to restart it at any point run the following commands:
```bash
docker-compose stop
```
```bash
docker-compose up -d
```

Once it has been built, wait for roughly 3 minutes to let it finish setting up, then you should be able to enter the [Management Portal](http://localhost:8880/csp/sys/%25CSP.Portal.Home.zen) as 'Username: superuser', 'Password: SYS', and create a new [Namespace](http://localhost:8880/csp/sys/mgr/%25CSP.UI.Portal.Namespaces.zen). This may take some time to save.

To then get the necessary SQL Schemas, run 
```bash
python iris-local\src\iris_utils\initialise_iris_tables.py
```
This will initialise and populate the necessary tables.

### Launching the Fall Detection Demo
To launch the chatbot, within the virtual environment run:
```bash
python iris-local\src\fall_demo_controller.py
```

This will launch two subprocesses, one for the Chatbot interface and one for the agents script.


## How does IRIS fit in
There are three schemas defined within the fall detection project. 

### OctopusSample
> This is a deprecated schema that is kept as part of this project to show how the Appliance Agent handles noise. Within the schema is the **SampleData** table, which includes data pulled from the Octopus Energy API about energy prices at various times and some fabricated sample energy usage. 
>
> This table was for the Energy Agent to use, but as it is not a part of this subgraph of the Agent Network, this table is unnecessary.

### BlackBox
> This schema contains the **WebsiteData** table which is populated by interactions with the widget_page. The listed widgets are the:
> - 'SensitivitySlider', with ApplianceData referencing the threshold value 
> - 'LaundryLight', where 0 represents 'Not in use', 1 for 'Ready', 2 for 'In use' (which is technically deprecated as part of the Energy Agent demo)
> - 'Alert', with ApplianceData referencing the event value 
> - 'Email', where 0 is for 'Alert Detected', 1 for 'Alert Update'
> 
> The UpdateRole defines whether the resident or agent was the one to update the widget value.
>
> This schema also contrains the **ApplianceData** table, which is to be used in the fall prevention demo.

### Chatbot
> This schema contains the **History** table which is populated by interactions with the main_chatbot. The SessionID keeps track of the chat session number so as to be able to clear the chat display on refresh.
