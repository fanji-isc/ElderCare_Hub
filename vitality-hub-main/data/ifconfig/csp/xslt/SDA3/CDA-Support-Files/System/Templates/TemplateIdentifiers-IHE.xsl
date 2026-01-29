<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<!-- CDA Document Content Modules -->
	<xsl:variable name="ihe-LabReportSpecification">1.3.6.1.4.1.19376.1.3.3</xsl:variable>
	<xsl:variable name="ihe-MedicalDocumentsSpecification">1.3.6.1.4.1.19376.1.5.3.1.1.1</xsl:variable>
	<xsl:variable name="ihe-MedicalSummarySpecification">1.3.6.1.4.1.19376.1.5.3.1.1.2</xsl:variable>
	<xsl:variable name="ihe-ReferralSummarySpecification">1.3.6.1.4.1.19376.1.5.3.1.1.3</xsl:variable>
	<xsl:variable name="ihe-DischargeSummarySpecification">1.3.6.1.4.1.19376.1.5.3.1.1.4</xsl:variable>
	<xsl:variable name="ihe-PHRExtractSpecification">1.3.6.1.4.1.19376.1.5.3.1.1.5</xsl:variable>
	<xsl:variable name="ihe-PHRUpdateSpecification">1.3.6.1.4.1.19376.1.5.3.1.1.6</xsl:variable>
	
	<!-- CDA Header Content Modules -->
	<xsl:variable name="ihe-PCC-LanguageCommunication">1.3.6.1.4.1.19376.1.5.3.1.2.1</xsl:variable>
	<xsl:variable name="ihe-PCC-EmployerAndSchoolContacts">1.3.6.1.4.1.19376.1.5.3.1.2.2</xsl:variable>
	<xsl:variable name="ihe-PCC-HealthcareProvidersAndPharmacies">1.3.6.1.4.1.19376.1.5.3.1.2.3</xsl:variable>
	<xsl:variable name="ihe-PCC-PatientContacts">1.3.6.1.4.1.19376.1.5.3.1.2.4</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-Spouse">1.3.6.1.4.1.19376.1.5.3.1.2.4.1</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-NaturalFatherOfFetus">1.3.6.1.4.1.19376.1.5.3.1.2.4.2</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-Authorization">1.3.6.1.4.1.19376.1.5.3.1.2.5</xsl:variable>

	<!-- CDA Section Content Modules -->
	<!-- Other Condition Histories -->
	<xsl:variable name="ihe-PCC-ActiveProblems">1.3.6.1.4.1.19376.1.5.3.1.3.6</xsl:variable>
	<xsl:variable name="ihe-PCC-HistoryOfPastIllness">1.3.6.1.4.1.19376.1.5.3.1.3.8</xsl:variable>
	<xsl:variable name="ihe-PCC-EncounterHistories">1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3</xsl:variable>
	<xsl:variable name="ihe-PCC-ListOfSurgeries">1.3.6.1.4.1.19376.1.5.3.1.3.11</xsl:variable>
	<xsl:variable name="ihe-PCC-CodedListOfSurgeries">1.3.6.1.4.1.19376.1.5.3.1.3.12</xsl:variable>
	<xsl:variable name="ihe-PCC-AllergiesAndOtherAdverseReactions">1.3.6.1.4.1.19376.1.5.3.1.3.13</xsl:variable>
	<xsl:variable name="ihe-PCC-FamilyMedicalHistory">1.3.6.1.4.1.19376.1.5.3.1.3.14</xsl:variable>
	<xsl:variable name="ihe-PCC-CodedFamilyMedicalHistory">1.3.6.1.4.1.19376.1.5.3.1.3.15</xsl:variable>
	<xsl:variable name="ihe-PCC-SocialHistory">1.3.6.1.4.1.19376.1.5.3.1.3.16</xsl:variable>
	<xsl:variable name="ihe-PCC-FunctionalStatus">1.3.6.1.4.1.19376.1.5.3.1.3.17</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-CodedFunctionalStatus">1.3.6.1.4.1.19376.1.5.3.1.1.12.2.1</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-PainScaleAssessment">1.3.6.1.4.1.19376.1.5.3.1.1.12.2.2</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-BradenScore">1.3.6.1.4.1.19376.1.5.3.1.1.12.2.3</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-GeriatricDepressionScale">1.3.6.1.4.1.19376.1.5.3.1.1.12.2.4</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-PhysicalFunction">1.3.6.1.4.1.19376.1.5.3.1.1.12.2.5</xsl:variable>
	<xsl:variable name="ihe-PCC-HazardousWorkingConditions">1.3.6.1.4.1.19376.1.5.3.1.1.5.3.1</xsl:variable>
	<xsl:variable name="ihe-PCC-PregnancyHistory">1.3.6.1.4.1.19376.1.5.3.1.1.5.3.4</xsl:variable>
	<xsl:variable name="ihe-PCC-MedicalDevices">1.3.6.1.4.1.19376.1.5.3.1.1.5.3.5</xsl:variable>
	<xsl:variable name="ihe-PCC-ForeignTravel">1.3.6.1.4.1.19376.1.5.3.1.1.5.3.6</xsl:variable>

	<!-- Medications -->
	<xsl:variable name="ihe-PCC-Medications">1.3.6.1.4.1.19376.1.5.3.1.3.19</xsl:variable>
	<xsl:variable name="ihe-PCC-Immunizations">1.3.6.1.4.1.19376.1.5.3.1.3.23</xsl:variable>

	<!-- Plans of Care -->
	<xsl:variable name="ihe-PCC-CarePlan">1.3.6.1.4.1.19376.1.5.3.1.3.31</xsl:variable>
	<xsl:variable name="ihe-PCC-CarePlan-ObservationRequest">1.3.6.1.4.1.19376.1.5.3.1.1.20.3.1</xsl:variable>
	<xsl:variable name="ihe-PCC-AdvanceDirectives">1.3.6.1.4.1.19376.1.5.3.1.3.34</xsl:variable>
	<xsl:variable name="ihe-PCC-CodedAdvanceDirectives">1.3.6.1.4.1.19376.1.5.3.1.3.35</xsl:variable>
	<xsl:variable name="ihe-PCC-AssessmentAndPlan">1.3.6.1.4.1.19376.1.5.3.1.1.13.2.5</xsl:variable>

	<!-- Impressions -->
	<xsl:variable name="ihe-PCC_CDASupplement-Assessments">1.3.6.1.4.1.19376.1.5.3.1.1.13.2.4</xsl:variable>

	<!-- Administrative and Other Information -->
	<xsl:variable name="ihe-PCC-Payers">1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7</xsl:variable>

	<!-- CDA and HL7 Version 3 Entry Content Modules -->
	<xsl:variable name="ihe-PCC-Severity">1.3.6.1.4.1.19376.1.5.3.1.4.1</xsl:variable>
	<xsl:variable name="ihe-PCC-ProblemStatusObservation">1.3.6.1.4.1.19376.1.5.3.1.4.1.1</xsl:variable>
	<xsl:variable name="ihe-PCC-HealthStatus">1.3.6.1.4.1.19376.1.5.3.1.4.1.2</xsl:variable>
	<xsl:variable name="ihe-PCC-Comments">1.3.6.1.4.1.19376.1.5.3.1.4.2</xsl:variable>
	<xsl:variable name="ihe-PCC-PatientMedicationInstructions">1.3.6.1.4.1.19376.1.5.3.1.4.3</xsl:variable>
	<xsl:variable name="ihe-PCC-MedicationFulfillmentInstructions">1.3.6.1.4.1.19376.1.5.3.1.4.3.1</xsl:variable>
	<xsl:variable name="ihe-PCC-ExternalReferences">1.3.6.1.4.1.19376.1.5.3.1.4.4</xsl:variable>
	<xsl:variable name="ihe-PCC-InternalReferences">1.3.6.1.4.1.19376.1.5.3.1.4.4.1</xsl:variable>
	<xsl:variable name="ihe-PCC-ConcernEntry">1.3.6.1.4.1.19376.1.5.3.1.4.5.1</xsl:variable>
	<xsl:variable name="ihe-PCC-ProblemConcernEntry">1.3.6.1.4.1.19376.1.5.3.1.4.5.2</xsl:variable>
	<xsl:variable name="ihe-PCC-AllergyAndIntoleranceConcern">1.3.6.1.4.1.19376.1.5.3.1.4.5.3</xsl:variable>
	<xsl:variable name="ihe-PCC-ProblemEntry">1.3.6.1.4.1.19376.1.5.3.1.4.5</xsl:variable>
	<xsl:variable name="ihe-PCC-AllergiesAndIntolerances">1.3.6.1.4.1.19376.1.5.3.1.4.6</xsl:variable>
	<xsl:variable name="ihe-PCC-MedicationsEntry">1.3.6.1.4.1.19376.1.5.3.1.4.7</xsl:variable>
	<xsl:variable name="ihe-PCC-CombinationMedicationEntry">1.3.6.1.4.1.19376.1.5.3.1.4.11</xsl:variable>	
	<xsl:variable name="ihe-PCC-ImmunizationsEntry">1.3.6.1.4.1.19376.1.5.3.1.4.12</xsl:variable>
	<xsl:variable name="ihe-PCC-SupplyEntry">1.3.6.1.4.1.19376.1.5.3.1.4.7.3</xsl:variable>
	<xsl:variable name="ihe-PCC-ProductEntry">1.3.6.1.4.1.19376.1.5.3.1.4.7.2</xsl:variable>
	<xsl:variable name="ihe-PCC-SimpleObservations">1.3.6.1.4.1.19376.1.5.3.1.4.13</xsl:variable>
	<xsl:variable name="ihe-PCC-LabBatteryOrganizer">1.3.6.1.4.1.19376.1.3.1.4</xsl:variable>
	<xsl:variable name="ihe-PCC-VitalSignsOrganizer">1.3.6.1.4.1.19376.1.5.3.1.4.13.1</xsl:variable>
	<xsl:variable name="ihe-PCC-VitalSignsObservation">1.3.6.1.4.1.19376.1.5.3.1.4.13.2</xsl:variable>
	<xsl:variable name="ihe-PCC-FamilyHistoryOrganizer">1.3.6.1.4.1.19376.1.5.3.1.4.15</xsl:variable>
	<xsl:variable name="ihe-PCC-SocialHistoryObservation">1.3.6.1.4.1.19376.1.5.3.1.4.13.4</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-FamilyHistoryObservation">1.3.6.1.4.1.19376.1.5.3.1.4.13.3</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-PregnancyObservation">1.3.6.1.4.1.19376.1.5.3.1.4.13.5</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-AdvanceDirectiveObservation">1.3.6.1.4.1.19376.1.5.3.1.4.13.7</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-BloodTypeObservation">1.3.6.1.4.1.19376.1.5.3.1.4.13.6</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-Encounters">1.3.6.1.4.1.19376.1.5.3.1.4.14</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-UpdateEntry">1.3.6.1.4.1.19376.1.5.3.1.4.16</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-ProcedureEntry">1.3.6.1.4.1.19376.1.5.3.1.4.19</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-CoverageEntry">1.3.6.1.4.1.19376.1.5.3.1.4.17</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-PayerEntry">1.3.6.1.4.1.19376.1.5.3.1.4.18</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-PainScoreObservation">1.3.6.1.4.1.19376.1.5.3.1.1.12.3.1</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-BradenScoreObservation">1.3.6.1.4.1.19376.1.5.3.1.1.12.3.2</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-BradenScoreComponent">1.3.6.1.4.1.19376.1.5.3.1.1.12.3.3</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-GeriatricDepressionScoreObservation">1.3.6.1.4.1.19376.1.5.3.1.1.12.3.4</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-GeriatricDepressionScoreComponent">1.3.6.1.4.1.19376.1.5.3.1.1.12.3.5</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-SurveyPanel">1.3.6.1.4.1.19376.1.5.3.1.1.12.3.7</xsl:variable>
	<xsl:variable name="ihe-PCC_CDASupplement-SurveyObservation">1.3.6.1.4.1.19376.1.5.3.1.1.12.3.6</xsl:variable>
	<xsl:variable name="ihe-PCC-ReferralOrderingPhysician">1.3.6.1.4.1.19376.1.3.3.1.6</xsl:variable>
	<xsl:variable name="ihe-PCC-LaboratoryPerformer">1.3.6.1.4.1.19376.1.3.3.1.7</xsl:variable>
	
	<!-- Other Section Templates -->
	<xsl:variable name="ihe-PCC-LaboratorySpecialty">1.3.6.1.4.1.19376.1.3.3.2.1</xsl:variable>
	<xsl:variable name="ihe-PCC-LaboratorySpecialtySubSection">1.3.6.1.4.1.19376.1.3.3.2.2</xsl:variable>
	<xsl:variable name="ihe-PCC-ReasonForReferral">1.3.6.1.4.1.19376.1.5.3.1.3.1</xsl:variable>
	<xsl:variable name="ihe-PCC-CodedReasonForReferral">1.3.6.1.4.1.19376.1.5.3.1.3.2</xsl:variable>
	<xsl:variable name="ihe-PCC-HospitalAdmissionDiagnosis">1.3.6.1.4.1.19376.1.5.3.1.3.3</xsl:variable>
	<xsl:variable name="ihe-PCC-HistoryOfPresentIllness">1.3.6.1.4.1.19376.1.5.3.1.3.4</xsl:variable>
	<xsl:variable name="ihe-PCC-HospitalCourse">1.3.6.1.4.1.19376.1.5.3.1.3.5</xsl:variable>
	<xsl:variable name="ihe-PCC-DischargeDiagnosis">1.3.6.1.4.1.19376.1.5.3.1.3.7</xsl:variable>
	<xsl:variable name="ihe-PCC-SelectMedsAdministered">1.3.6.1.4.1.19376.1.5.3.1.3.21</xsl:variable>
	<xsl:variable name="ihe-PCC-HospitalDischargeMedications">1.3.6.1.4.1.19376.1.5.3.1.3.22</xsl:variable>
	<xsl:variable name="ihe-PCC-CodedVitalSigns">1.3.6.1.4.1.19376.1.5.3.1.1.5.3.2</xsl:variable>
	<xsl:variable name="ihe-PCC-VitalSigns">1.3.6.1.4.1.19376.1.5.3.1.3.25</xsl:variable>
	<xsl:variable name="ihe-PCC-CodedResults">1.3.6.1.4.1.19376.1.5.3.1.3.28</xsl:variable>

	<!-- Other Entry Templates -->
	<xsl:variable name="ihe-PCC-LaboratoryReportEntry">1.3.6.1.4.1.19376.1.3.1</xsl:variable>
	<xsl:variable name="ihe-PCC-LaboratoryObservation">1.3.6.1.4.1.19376.1.3.1.6</xsl:variable>
	<xsl:variable name="ihe-PCC-SubstanceEntry">1.3.6.1.4.1.19376.1.5.3.1.4.7.1</xsl:variable>

	<!-- IHE BPPC Templates -->
	<xsl:variable name="ihe-BPPC">1.3.6.1.4.1.19376.1.5.3.1.1.7</xsl:variable>
	<xsl:variable name="ihe-BPPC-SD">1.3.6.1.4.1.19376.1.5.3.1.1.7.1</xsl:variable>
	<xsl:variable name="ihe-BPPC-ConsentServiceEvent">1.3.6.1.4.1.19376.1.5.3.1.2.6</xsl:variable>
	<xsl:variable name="ihe-BPPC-Authorization">1.3.6.1.4.1.19376.1.5.3.1.2.5</xsl:variable>
	
	<!-- IHE XDS-SD Templates -->
	<xsl:variable name="ihe-XDS-SD">1.3.6.1.4.1.19376.1.2.20</xsl:variable>
	<xsl:variable name="ihe-XDS-SD-OriginalAuthor">1.3.6.1.4.1.19376.1.2.20.1</xsl:variable>
	<xsl:variable name="ihe-XDS-SD-ScanningDevice">1.3.6.1.4.1.19376.1.2.20.2</xsl:variable>
	<xsl:variable name="ihe-XDS-SD-ScannerOperator">1.3.6.1.4.1.19376.1.2.20.3</xsl:variable>
	
</xsl:stylesheet>
