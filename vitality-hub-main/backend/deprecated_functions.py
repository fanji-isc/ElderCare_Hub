def morning_message():
    return """Good morning, Frank — I'm glad you're up. 
                Your Garmin and home sensors show a very restless, short night of sleep, only one meal yesterday with low protein, and dark morning urine — that combination raises your dizziness/fall risk today. 
                Please sip 250-500 ml of water slowly now, have a small protein snack (two eggs, turkey slices, or Greek yogurt are easy options), and avoid getting up or walking alone right away: sit for a minute before standing and take slow, supported steps if you need to move. 
                Rest through the morning, try to add more fluids and a bit more protein over the next few hours, and if you feel faint, have chest pain, or become very confused, call emergency services or contact Dr. Mitchell (or David) right away."""
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")
    
    garmin_dict = interprete_garmin()
    home_dict = interprete_home_data()
    if garmin_dict.get("status") == "error" or home_dict.get("status") == "error":
        garmin_data = "None"
        home_data = "None"
    else:
        garmin_data = garmin_dict.get("data")
        home_data = home_dict.get("data")

    triage_desc = f"""
    ### ROLE: ELDERLY SYSTEMIC RISK ANALYST

    # CONTEXT:
    You are a Senior Clinical Data Scientist specializing in Geriatric Health. You analyze data from five distinct health monitoring systems (ECG, HR, Sleep, Hydration, and Nutrition) to create a unified safety and recovery profile for an elderly user.
    Your goal is to generate a summary of the patient's Garmin and Home Appliance data for their clinician to interprete.
 
    # INTERPRETATION FRAMEWORK
    You must cross-reference the data provided using the following clinical logic:
    1. **Hydration-Cardiac Link:** 
    - Correlate Smart Toilet `colorLevel` with ECG `sdnn_hrv_ms`. Dark urine (Level 5+) + low HRV (SDNN < 30) = High risk for orthostatic hypotension (dizziness when standing).
    2. **Nutrition-Sleep-Stability Chain:** 
    - Connect `protein_intake` (Fridge) with `deep_pct` and `restless_moments` (Sleep). Low protein or skipped meals in the elderly often trigger poor deep sleep and increased nighttime restlessness, which is a fall risk.
    3. **The Digestion Tax:** 
    - Compare Fridge `last_meal_time` with Sleep `avg_sleep_stress`. If dinner is late, explain how it prevents the heart rate from dropping, stealing recovery time.
    4. **Geriatric Safety Flags:** 
    - **Critical:** "Appetite Loss" or "Skipped Meals" (Fridge) + "Rising Sleep Stress" (Sleep).
    - **Warning:** Low `spo2` (HR) + High `respiration` (HR/Sleep) + "Dehydration" (Toilet).

    # OUTPUT STRUCTURE
    Your response must follow this template:

    ---
    ### ⚠️ OVERALL RISK LEVEL: [LOW | ELEVATED | CRITICAL]
    **Primary Driver:** [Identify the #1 system causing the risk today]

    #### 1. THE "WHY" (Unified Insight)
    [A concise narrative explaining how the different data points are interacting. E.g., "The user is electrically stable but physically vulnerable due to under-fueling and dehydration."]

    #### 2. CROSS-SYSTEM CORRELATIONS
    * **[Link 1]:** (e.g., Nutrition vs. Sleep)
    * **[Link 2]:** (e.g., Hydration vs. Cardiac)

    #### 3. GUARDIAN ACTION ITEMS
    * **Immediate:** [Action to take now, e.g., Drink 500ml water]
    * **Daily Goal:** [Nutritional or activity adjustment]
    * **Watch For:** [Clinical symptom to observe, e.g., Dizziness, gait changes]
    ---

    # INPUT:    
    1. The patient's Garmin data is: 
    {garmin_data}

    2. The patient's Home data is: 
    {home_data}
    """
    response = client.responses.create(
        model="gpt-o4-mini",
        instructions = medical_analyst,
        input = "Generate a summary of the patient's Garmin and Home Appliance data for their clinician to interprete."
    )
    
    triage_answer = response.output_text
    patient_desc = get_patient_desc()

    wellbeing_desc = f"""
    ### ROLE: Elder-care assitant

    # CONTEXT: 
    You are a calm, friendly elder-care assistant. You are speaking directly to the following patient:

    {patient_desc}

    # TONE:
    Speak clearly, briefly, and reassuringly. 

    # RESTRICTIONS:
    DO NOT give medical diagnoses. 
    If unsure, suggest contacting their healthcare professional.

    # DATA SUMMARY: 

    {triage_answer}
    """
    response = client.responses.create(
        model="gpt-5-mini",
        instructions = wellbeing_desc,
        input = "Provide a good morning message including a gentle summary of what the system has noticed based on their garmin and household data, and some advice for how best to behave today. "
                "Avoid returning too long of a message, your response should not require bullet points."
    )
    answer_text = response.output_text

    return {"answer": answer_text}

async def generate_clinician_overview():
    # --- Original hardcoded summary for Mr. Frank Larson (kept as style/format reference) ---
    return """
            Clinical risk summary (Mr. Frank Larson, 74):
            - High fall and syncope risk: recurrent orthostatic dizziness with two near-falls (2026-01-20); polypharmacy with hypotensive/CNS-active agents (HCTZ, lisinopril, metoprolol, gabapentin, sertraline); beta-blocker-related bradycardia (HR 62-64 bpm); lives alone.
            - Volume depletion/dehydration and electrolyte disturbance: borderline hypernatremia (Na 146 mmol/L) with poor intake; on thiazide diuretic; symptoms of dizziness consistent with volume loss.
            - Acute kidney injury risk: rising creatinine to 1.3 mg/dL (from 1.0 in 2024) in the setting of dehydration plus ACE inhibitor and thiazide (prerenal risk).
            - Metformin-associated lactic acidosis risk: dehydration and reduced renal function increase risk while on metformin.
            - High atherosclerotic cardiovascular disease (ASCVD) risk: age >70, male, long-standing hypertension, type 2 diabetes, and hyperlipidemia (BPs typically 135-150/84-93).
            - Depression-related risks: major depressive disorder after bereavement with ongoing low mood/appetite/sleep disturbance; social isolation (widowed, living alone) increases risk of functional decline and poor adherence."""

    # --- Original dead-code home data supplement string literals (kept for reference) ---
    """Summary of home data:
    - Garmin sleep metrics from the most recent night show severely fragmented sleep (total sleep 2 h 44 m, 112 restless moments), high average sleep stress ~48.3 and a low recovery score (24).
    - Home-fridge logs for 2026-02-26 indicate a single eating event with total protein ≈58 g.
    - Smart-toilet recordings show repeated morning urine color Level 6 (consistent with relative dehydration).
    - ECG-derived HRV (SDNN) is ≈35 ms (above the 30 ms threshold noted in the protocol).
    - Labs previously noted borderline hypernatremia and a mild creatinine rise.
    - Clinical relevance:
        - These concurrent findings—low/late caloric and protein intake, recurrent morning dehydration, and markedly poor nocturnal recovery—are temporally correlated and collectively increase physiologic vulnerability in an older adult (heightened orthostatic and fall risk, impaired overnight autonomic recovery, and potential strain on renal function).
        - The SDNN does not meet the low-HRV cutoff, but persistent dehydration and inadequate intake remain important contextual factors when interpreting orthostatic symptoms, fall risk, HRV trends, and renal labs."""
    client = get_openai_client()
    if not client:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")

    # --- Original dead-code to generate the home data supplement (kept for reference) ---
    triage_desc = f"""
    ### ROLE: ELDERLY SYSTEMIC RISK ANALYST

    # CONTEXT:
    You are a Senior Clinical Data Scientist specializing in Geriatric Health. You analyze data from five distinct health monitoring systems (ECG, HR, Sleep, Hydration, and Nutrition) to create a unified safety and recovery profile for an elderly user.
 
    # INTERPRETATION FRAMEWORK
    You must cross-reference the data provided using the following clinical logic:
    1. **Hydration-Cardiac Link:** 
    - Correlate Smart Toilet `colorLevel` with ECG `sdnn_hrv_ms`. Dark urine (Level 5+) + low HRV (SDNN < 30) = High risk for orthostatic hypotension (dizziness when standing).
    2. **Nutrition-Sleep-Stability Chain:** 
    - Connect `protein_intake` (Fridge) with `deep_pct` and `restless_moments` (Sleep). Low protein or skipped meals in the elderly often trigger poor deep sleep and increased nighttime restlessness, which is a fall risk.
    3. **The Digestion Tax:** 
    - Compare Fridge `last_meal_time` with Sleep `avg_sleep_stress`. If dinner is late, explain how it prevents the heart rate from dropping, stealing recovery time.
    4. **Geriatric Safety Flags:** 
    - **Critical:** "Appetite Loss" or "Skipped Meals" (Fridge) + "Rising Sleep Stress" (Sleep).
    - **Warning:** Low `spo2` (HR) + High `respiration` (HR/Sleep) + "Dehydration" (Toilet).

    # OUTPUT STRUCTURE
    Your response must follow this template:

    ---
    ### ⚠️ OVERALL RISK LEVEL: [LOW | ELEVATED | CRITICAL]
    **Primary Driver:** [Identify the #1 system causing the risk today]

    #### 1. THE "WHY" (Unified Insight)
    [A concise narrative explaining how the different data points are interacting. E.g., "The user is electrically stable but physically vulnerable due to under-fueling and dehydration."]

    #### 2. CROSS-SYSTEM CORRELATIONS
    * **[Link 1]:** (e.g., Nutrition vs. Sleep)
    * **[Link 2]:** (e.g., Hydration vs. Cardiac)

    #### 3. GUARDIAN ACTION ITEMS
    * **Immediate:** [Action to take now, e.g., Drink 500ml water]
    * **Daily Goal:** [Nutritional or activity adjustment]
    * **Watch For:** [Clinical symptom to observe, e.g., Dizziness, gait changes]
    ---
    """
    triage_agent = Agent(
        name="Triage Agent",
        instructions=triage_desc,
        tools=[interprete_garmin, interprete_home_data],
        model="gpt-5-mini"
    )
    summarise_request = f"Generate a summary of the patient's Garmin and Home Appliance data for their clinician to interprete."
    result = await Runner.run(triage_agent, summarise_request)
    triage_answer = result.final_output

    patient_desc = _get_patient_desc()
    clinician_desc = f"""
    ### ROLE: Elder-care Clinical Assistant

    # CONTEXT: 
    You are a elder-care clinical assistant speaking directly to the following patient's clinician:

    {patient_desc}

    # TONE:
    Speak clearly and briefly, providing supporting data wherever possible. The clinician will want as much data as possible so as to perform the analysis themselves.

    # RESTRICTIONS:
    DO NOT try and provide any advise on further actions or perform any diagnoses yourself.
    Do not make clinical decisions, and do not invent data.

    # DATA SUMMARY: 

    {triage_answer}

    """
    clinical_agent = Agent(
        name="Clinical Agent",
        instructions=clinician_desc,
        model="gpt-5-mini"
    )
    summary_request = "Provide a summary for a clinician to interprete of the patient's garmin and household data, and how this is relevant in a clinical context. Avoid returning too long of a message, your response should not require bullet points."
    result = await Runner.run(clinical_agent, summary_request)
    answer_text = result.final_output

    risks = _get_clinical_risks()

    return {"answer": risks  + "\n\n" + answer_text}

def generate_clinician_summary(patient_id: str = Query(...)):
    """This function analyses the Patient Bundle from the given FHIR file path to determine what conditions they are at risk for.
    
    returns: The short clinician appropriate summary"""
    return ""
    params = {
        "_id": patient_id,
        "_revinclude": [
            "Condition:subject", 
            "Encounter:subject",
            "Observation:subject", 
            "MedicationRequest:subject",
            "Procedure:subject",
            "Immunization:patient",
            "Appointment:participant",
            "CareTeam:subject",
            "CarePlan:subject"
        ]
    }
    patient_fhir = _fhir_get("Patient", params)
    
    client = get_openai_client()
    if client is None:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY not set")
    
    medical_analyst = f"""
    # ROLE: FHIR R4 Expert

    # CONTEXT: 
    You are an expert medical data analyst specializing in FHIR R4 speaking directly to a clinician. When given a FHIR bundle, you should analyse the patient's medical history to determine what are their clinical risks.

	# RESPONSE STRUCTURE:
    The format of the answer should be plain text. 
    In your response, you should start with the following header, filling in the appropriate patient details 
    ## Clinical risk summary (Patient Name, Gender, DOB):
    
    # TONE:
    Be clear and concise, only include conditions and problems that are high risk so that a clinician can interprete this quickly. 
    DO NOT try and provide the clinician with any advise on further actions or perform any diagnoses yourself. 
    """
    response = client.responses.create(
        model="gpt-5-mini",
        instructions = medical_analyst,
        input = f"Analyze this FHIR bundle and provide a short summary of their clinical risks:\n\n{patient_fhir}"
    )
    summary_text = response.output_text

    # Upsert into IRIS (delete existing row, insert new)
    conn = get_iris()
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM MyApp.AISummary WHERE PatientID = ?", [patient_id])
        cur.execute(
            "INSERT INTO MyApp.AISummary (PatientID, SummaryText, UpdatedAt) VALUES (?, ?, NOW())",
            [patient_id, summary_text],
        )
    finally:
        conn.close()

    return summary_text