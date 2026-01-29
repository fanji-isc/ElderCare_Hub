<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<!-- CDA General Templates -->
	<xsl:variable name="hl7-CDA-CDAR2GeneralHeader">2.16.840.1.113883.3.27.1776</xsl:variable>
	<xsl:variable name="hl7-CDA-RegisteredTemplatesRoot">2.16.840.1.113883.10</xsl:variable>
	<xsl:variable name="hl7-CDA-SDTCRegisteredTemplatesRoot">2.16.840.1.113883.10.20</xsl:variable>
	<xsl:variable name="hl7-CDA-Level1Declaration">2.16.840.1.113883.10.20.10</xsl:variable>
	<xsl:variable name="hl7-CDA-Level2Declaration">2.16.840.1.113883.10.20.20</xsl:variable>
	<xsl:variable name="hl7-CDA-Level3Declaration">2.16.840.1.113883.10.20.30</xsl:variable>

	<!-- CCD General Templates -->
	<xsl:variable name="hl7-CCD-RegisteredTemplatesRoot">2.16.840.1.113883.10.20.1</xsl:variable>
	<xsl:variable name="hl7-CCD-HistoryAndPhysicalRoot">2.16.840.1.113883.10.20.2</xsl:variable>
	<xsl:variable name="hl7-CCD-GeneralHeader">2.16.840.1.113883.10.20.3</xsl:variable>
	<xsl:variable name="hl7-CCD-ConsultNoteRoot">2.16.840.1.113883.10.20.4</xsl:variable>

	<!-- CCD Section Templates -->
	<xsl:variable name="hl7-CCD-AdvanceDirectivesSection">2.16.840.1.113883.10.20.1.1</xsl:variable>
	<xsl:variable name="hl7-CCD-AlertsSection">2.16.840.1.113883.10.20.1.2</xsl:variable>
	<xsl:variable name="hl7-CCD-EncountersSection">2.16.840.1.113883.10.20.1.3</xsl:variable>
	<xsl:variable name="hl7-CCD-FamilyHistorySection">2.16.840.1.113883.10.20.1.4</xsl:variable>
	<xsl:variable name="hl7-CCD-FunctionalStatusSection">2.16.840.1.113883.10.20.1.5</xsl:variable>
	<xsl:variable name="hl7-CCD-ImmunizationsSection">2.16.840.1.113883.10.20.1.6</xsl:variable>
	<xsl:variable name="hl7-CCD-MedicalEquipmentSection">2.16.840.1.113883.10.20.1.7</xsl:variable>
	<xsl:variable name="hl7-CCD-MedicationsSection">2.16.840.1.113883.10.20.1.8</xsl:variable>
	<xsl:variable name="hl7-CCD-PayersSection">2.16.840.1.113883.10.20.1.9</xsl:variable>
	<xsl:variable name="hl7-CCD-PlanOfCareSection">2.16.840.1.113883.10.20.1.10</xsl:variable>
	<xsl:variable name="hl7-CCD-ProblemSection">2.16.840.1.113883.10.20.1.11</xsl:variable>
	<xsl:variable name="hl7-CCD-ProceduresSection">2.16.840.1.113883.10.20.1.12</xsl:variable>
	<xsl:variable name="hl7-CCD-PurposeSection">2.16.840.1.113883.10.20.1.13</xsl:variable>
	<xsl:variable name="hl7-CCD-ResultsSection">2.16.840.1.113883.10.20.1.14</xsl:variable>
	<xsl:variable name="hl7-CCD-SocialHistorySection">2.16.840.1.113883.10.20.1.15</xsl:variable>
	<xsl:variable name="hl7-CCD-VitalSignsSection">2.16.840.1.113883.10.20.1.16</xsl:variable>

	<!-- CCD Clinical Statement Templates -->
	<xsl:variable name="hl7-CCD-AdvanceDirectiveObservation">2.16.840.1.113883.10.20.1.17</xsl:variable>
	<xsl:variable name="hl7-CCD-AlertObservation">2.16.840.1.113883.10.20.1.18</xsl:variable>
	<xsl:variable name="hl7-CCD-AuthorizationActivity">2.16.840.1.113883.10.20.1.19</xsl:variable>
	<xsl:variable name="hl7-CCD-CoverageActivity">2.16.840.1.113883.10.20.1.20</xsl:variable>
	<xsl:variable name="hl7-CCD-EncounterActivity">2.16.840.1.113883.10.20.1.21</xsl:variable>
	<xsl:variable name="hl7-CCD-FamilyHistoryObservation">2.16.840.1.113883.10.20.1.22</xsl:variable>
	<xsl:variable name="hl7-CCD-FamilyHistoryOrganizer">2.16.840.1.113883.10.20.1.23</xsl:variable>
	<xsl:variable name="hl7-CCD-MedicationActivity">2.16.840.1.113883.10.20.1.24</xsl:variable>
	<xsl:variable name="hl7-CCD-PlanOfCareActivity">2.16.840.1.113883.10.20.1.25</xsl:variable>
	<xsl:variable name="hl7-CCD-PolicyActivity">2.16.840.1.113883.10.20.1.26</xsl:variable>
	<xsl:variable name="hl7-CCD-ProblemAct">2.16.840.1.113883.10.20.1.27</xsl:variable>
	<xsl:variable name="hl7-CCD-ProblemObservation">2.16.840.1.113883.10.20.1.28</xsl:variable>
	<xsl:variable name="hl7-CCD-ProcedureActivity">2.16.840.1.113883.10.20.1.29</xsl:variable>
	<xsl:variable name="hl7-CCD-PurposeActivity">2.16.840.1.113883.10.20.1.30</xsl:variable>
	<xsl:variable name="hl7-CCD-ResultObservation">2.16.840.1.113883.10.20.1.31</xsl:variable>
	<xsl:variable name="hl7-CCD-ResultOrganizer">2.16.840.1.113883.10.20.1.32</xsl:variable>
	<xsl:variable name="hl7-CCD-SocialHistoryObservation">2.16.840.1.113883.10.20.1.33</xsl:variable>
	<xsl:variable name="hl7-CCD-SupplyActivity">2.16.840.1.113883.10.20.1.34</xsl:variable>
	<xsl:variable name="hl7-CCD-VitalSignsOrganizer">2.16.840.1.113883.10.20.1.35</xsl:variable>

	<!-- CCD Supporting Templates (used within a clinical statements) -->
	<xsl:variable name="hl7-CCD-AdvanceDirectiveReference">2.16.840.1.113883.10.20.1.36</xsl:variable>
	<xsl:variable name="hl7-CCD-AdvanceDirectiveStatusObservation">2.16.840.1.113883.10.20.1.37</xsl:variable>
	<xsl:variable name="hl7-CCD-AgeObservation">2.16.840.1.113883.10.20.1.38</xsl:variable>
	<xsl:variable name="hl7-CCD-AlertStatusObservation">2.16.840.1.113883.10.20.1.39</xsl:variable>
	<xsl:variable name="hl7-CCD-Comment">2.16.840.1.113883.10.20.1.40</xsl:variable>
	<xsl:variable name="hl7-CCD-EpisodeObservation">2.16.840.1.113883.10.20.1.41</xsl:variable>
	<xsl:variable name="hl7-CCD-FamilyHistoryCauseOfDeathObservation">2.16.840.1.113883.10.20.1.42</xsl:variable>
	<xsl:variable name="hl7-CCD-FulfillmentInstruction">2.16.840.1.113883.10.20.1.43</xsl:variable>
	<xsl:variable name="hl7-CCD-LocationParticipation">2.16.840.1.113883.10.20.1.45</xsl:variable>
	<xsl:variable name="hl7-CCD-MedicationSeriesNumberObservation">2.16.840.1.113883.10.20.1.46</xsl:variable>
	<xsl:variable name="hl7-CCD-MedicationStatusObservation">2.16.840.1.113883.10.20.1.47</xsl:variable>
	<xsl:variable name="hl7-CCD-PatientAwareness">2.16.840.1.113883.10.20.1.48</xsl:variable>
	<xsl:variable name="hl7-CCD-PatientInstruction">2.16.840.1.113883.10.20.1.49</xsl:variable>
	<xsl:variable name="hl7-CCD-ProblemHealthStatusObservation">2.16.840.1.113883.10.20.1.51</xsl:variable>
	<xsl:variable name="hl7-CCD-ProblemStatusObservation">2.16.840.1.113883.10.20.1.50</xsl:variable>
	<xsl:variable name="hl7-CCD-Product">2.16.840.1.113883.10.20.1.53</xsl:variable>
	<xsl:variable name="hl7-CCD-ProductInstance">2.16.840.1.113883.10.20.1.52</xsl:variable>
	<xsl:variable name="hl7-CCD-ReactionObservation">2.16.840.1.113883.10.20.1.54</xsl:variable>
	<xsl:variable name="hl7-CCD-SeverityObservation">2.16.840.1.113883.10.20.1.55</xsl:variable>
	<xsl:variable name="hl7-CCD-SocialHistoryStatusObservation">2.16.840.1.113883.10.20.1.56</xsl:variable>
	<xsl:variable name="hl7-CCD-StatusObservation">2.16.840.1.113883.10.20.1.57</xsl:variable>
	<xsl:variable name="hl7-CCD-StatusOfFunctionalStatusObservation">2.16.840.1.113883.10.20.1.44</xsl:variable>
	<xsl:variable name="hl7-CCD-VerificationOfAnAdvanceDirectiveObservation">2.16.840.1.113883.10.20.1.58</xsl:variable>
	
	<!-- Other Templates -->
	<xsl:variable name="hl7-CCD-AssessmentAndPlanSection">2.16.840.1.113883.10.20.2.7</xsl:variable>
	<xsl:variable name="hl7-CCD-HistoryOfPastIllnessSection">2.16.840.1.113883.10.20.2.9</xsl:variable>
	<xsl:variable name="hl7-CCD-ReasonForReferralSection">2.16.840.1.113883.10.20.4.8</xsl:variable>
</xsl:stylesheet>
