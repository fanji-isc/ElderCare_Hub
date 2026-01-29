<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" xmlns:math="http://exslt.org/math" exclude-result-prefixes="isc hl7 sdtc xsi exsl set math">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HITSP.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-IHE.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-CCDA.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/String-Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Common/CCDAv21/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Common/CCDAv21/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Common/CCDAv21/Narrative.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/ImportProfile.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/AdvanceDirective.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Assessment.xsl"/>	
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/AssessmentAndPlan.xsl"/>	
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/AuthorParticipation.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/EncounterDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/FunctionalStatus.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Goals.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/HealthConcerns.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Interventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Note.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Outcomes.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/PlanOfTreatment.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/PriorityPreference.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Result.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/SocialDeterminant.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/CCDAv21/VitalSign.xsl"/>

	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/AdvanceDirectives.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/AssessmentAndPlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Assessments.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/CarePlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/DiagnosticResults.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/DischargeDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/EncounterDiagnoses.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/FunctionalStatus.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Goals.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/HealthConcerns.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/HistoryOfPastIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/HospitalAdmissionDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/HospitalDischargeInstructions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/HospitalDischargeMedications.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Instructions.xsl"/>	
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Interventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Notes.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/MedicationsAdministered.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Non-RatifiedSections.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Outcomes.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/PlanOfTreatment.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/ReasonForVisit.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/CCDAv21/VitalSigns.xsl"/>

	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
	
	<!-- The following variable should be the only absolute-path reference to the source
	     document. If pre-processing is necessary, you should change $input to be the
       output of the pre-processing stage. That output must have hl7:ClinicalDocument
	     as the top of the tree. -->
	<xsl:variable name="input" select="/hl7:ClinicalDocument"/>

	<xsl:template match="/">
		<xsl:variable name="firstPass"><xsl:apply-templates select="$input"/></xsl:variable>
		<!-- $firstPass has the transformation output, but with some repetitive elements directly under Container.
		     In the second phase, we canonicalize the SDA output to have one of each type. -->
		<xsl:apply-templates select="exsl:node-set($firstPass)" mode= "Canonicalize"/>
	</xsl:template>

	<xsl:template match="hl7:ClinicalDocument">
		<Container>
			
			<Patient>
				<!-- Personal Information -->
				<xsl:apply-templates select="hl7:recordTarget/hl7:patientRole" mode="ePI-PersonalInformation"/>
				
				<!-- Healthcare Provider module -->
				<xsl:apply-templates select="hl7:documentationOf" mode="eHP-HealthcareProvider"/>
				
				<!-- Support module -->
				<xsl:apply-templates select="." mode="eS-Support"/>
			</Patient>
			
			<!-- Encounters -->
			<xsl:apply-templates select="." mode="sE-Encounters"/>

			<!-- Advance Directives -->
			<xsl:apply-templates select="." mode="sAD-AdvanceDirectivesSection"/>

			<!-- Alerts and Allergies -->
			<xsl:apply-templates select="." mode="sAOAR-AllergiesSection"/>
			
			<!-- Social History -->
			<xsl:apply-templates select="." mode="sSH-SocialHistorySection"/>

			<!-- Family History -->
			<xsl:apply-templates select="." mode="sFH-FamilyHistorySection"/>			
			
			<!-- History of Present Illness -->
			<xsl:apply-templates select="." mode="sHOPreI-PresentIllnessSection"/>
			
			<!-- ActionCodes variable helps limit writing ActionCode to once per informationType/encounter combination. -->
			<xsl:if test="string-length($documentActionCode)">
				<xsl:if test="isc:evaluate('varKill','ActionCodes')"></xsl:if>
			</xsl:if>
			
			<!-- Hospital Admission Diagnoses, Discharge Diagnoses, Assessments, Encounter Diagnoses -->
			<xsl:apply-templates select="." mode="sHAD-AdmissionDiagnosesSection"/>
			<xsl:apply-templates select="." mode="sDD-DischargeDiagnosesSection"/>
			<xsl:apply-templates select="." mode="sA-AssessmentsSection"/>
			<xsl:apply-templates select="." mode="sED-EncounterDiagnosesSection"/>

			<!-- Vital Signs (Observations) -->
			<xsl:apply-templates select="." mode="sVS-VitalSignsSection"/>

			<!-- Problems and History of Past Illness -->
			<xsl:apply-templates select="." mode="sPL-ActiveProblemsSection"/>
			<xsl:apply-templates select="." mode="sHOPasI-ResolvedProblemsSection"/>
			<xsl:apply-templates select="." mode="sFS-FunctionalStatusSection"/>
			
			<!-- Procedures and Interventions -->
			<xsl:apply-templates select="." mode="sPAI-ProceduresSection"/>

			<!-- Diagnostic Results -->
			<xsl:apply-templates select="." mode="sDR-ResultsSection"/>

			<!-- Plan of Treatment -->
			<xsl:apply-templates select="." mode="sPOT-PlanOfTreatmentSection"/>
			<xsl:apply-templates select="." mode="sPOT-PlanOfTreatmentSection-Orders"/>

			<!-- Assessment and Plan -->
			<xsl:apply-templates select="." mode="sANP-AssessmentAndPlanSection"/>

			<!-- Medications and Discharge Medications -->
			<xsl:apply-templates select="." mode="sHDM-DischargeMedicationsSection"/>
			<xsl:apply-templates select="." mode="sM-MedicationsSection"/>
			<xsl:apply-templates select="." mode="sMA-MedicationsAdministeredSection"/>

			<!-- Immunizations -->
			<xsl:apply-templates select="." mode="sIm-ImmunizationsSection"/>		
						
			<!-- Referrals -->
			<xsl:apply-templates select="." mode="sPOT-PlanOfTreatmentSection-Referrals"/>

			<!-- Documents imported from PlanOfTreatment Instructions-->
			<xsl:apply-templates select="." mode="sPOT-PlanOfTreatmentSection-Documents"/>

			<xsl:if test="hl7:templateId[@root='2.16.840.1.113883.10.20.22.1.15']">
				<!-- Care Plan -->
				<xsl:apply-templates select="." mode="sCP-Section"/>
			</xsl:if>

			<!-- Health Concerns -->
			<xsl:apply-templates select="." mode="sHC-Section"/>

			<!-- Goals -->
			<xsl:apply-templates select="." mode="sG-Section"/>

			<!-- Plan of Treatment Goals -->
			<xsl:apply-templates select="." mode="sPOT-Goals"/>
			
			<!-- Sending Facility -->
			<xsl:variable name="sendingFacility"><xsl:apply-templates select="." mode="fn-I-SendingFacilityValue"/></xsl:variable>
			<xsl:if test="string-length($sendingFacility)">
				<SendingFacility><xsl:value-of select="$sendingFacility"/></SendingFacility>
			</xsl:if>

			<!-- Document -->
			<xsl:apply-templates select="." mode="sNRS-Documents"/>

			<!-- Payers -->
			<xsl:apply-templates select="." mode="sP-PayersSection"/>

			<!-- Notes -->
			<xsl:apply-templates select="." mode="sN-NotesSection"/>

			<!-- Structured Section Narratives -->
			<xsl:apply-templates select="." mode="narrative-import-sections"/>

			<!-- Custom import -->
			<xsl:apply-templates select="." mode="ImportCustom-Container"/>
		  
			<!-- Document header data into AdditionalDocumentInfo, if requested. -->
			<xsl:if test="string-length(translate($documentHeaderItemsList,'| ',''))">
			   <xsl:apply-templates select="." mode="AdditionalDocumentInfo"/>
			</xsl:if>

		</Container>
	</xsl:template>

	<!-- At the top SDA level, insert the first element, then loop through the node sets of subsequent elements with the same name -->
	<xsl:template match="/Container/*" mode="Canonicalize"> 
		<xsl:variable name="elementName" select="local-name()"/>
		<xsl:if test="count(preceding-sibling::*[name()=$elementName])=0">
				<xsl:copy>
					<xsl:for-each select="self::* | following-sibling::*[name()=$elementName]">
						<xsl:apply-templates mode="Canonicalize"/> 
					</xsl:for-each>
				</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<!-- Copy all other SDA elements as is -->
	<xsl:template match="*" mode="Canonicalize"> 
		<xsl:copy>
			<xsl:apply-templates mode="Canonicalize"/> 
		</xsl:copy>
	</xsl:template>
	
  <!--
		AdditionalDocumentInfo reconstitutes selected CDA XML element and attribute data
		into an XML structure that is purely elements and values, with no attributes.
		This is done so that the data survives the final template calls to Canonicalize.
	-->
  <xsl:template match="hl7:ClinicalDocument" mode="AdditionalDocumentInfo">
    <AdditionalDocumentInfo>
      <SourceFormat>CCDA1.1</SourceFormat>
      <xsl:apply-templates select="." mode="fn-HeaderInfo-AddlDocInfo"/>
      <xsl:apply-templates select="." mode="ImportCustom-AdditionalDocumentInfo"/>
    </AdditionalDocumentInfo>
  </xsl:template>
  
  <!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ImportCustom-Container"/>
	
  
  <!-- This empty template may be overridden with custom logic. -->
  <xsl:template match="*" mode="ImportCustom-AdditionalDocumentInfo"/>
  
</xsl:stylesheet>
