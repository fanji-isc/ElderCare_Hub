<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 sdtc xsi exsl">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HITSP.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-IHE.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/String-Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Common/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/ImportProfile.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AdvanceDirective.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AssessmentAndPlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/Result.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/VitalSign.xsl"/>

	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AdvanceDirectives.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AssessmentAndPlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/DiagnosticResults.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/DischargeDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/HistoryOfPastIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/HospitalAdmissionDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/HospitalDischargeMedications.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/MedicationsAdministered.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/Non-RatifiedSections.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/VitalSigns.xsl"/>

	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>

	<!-- Canonicalize the SDA output -->
	<xsl:template match="/">
		<xsl:variable name="firstPass"><xsl:apply-templates select="/hl7:ClinicalDocument"/></xsl:variable>
		<xsl:apply-templates select="exsl:node-set($firstPass)" mode= "Canonicalize"/>
	</xsl:template>

	<xsl:template match="/hl7:ClinicalDocument">
		<Container>
			<!-- Sending Facility -->
			<xsl:variable name="sendingFacility"><xsl:apply-templates select="." mode="SendingFacilityValue"/></xsl:variable>
			<xsl:if test="string-length($sendingFacility)">
				<SendingFacility><xsl:value-of select="$sendingFacility"/></SendingFacility>
			</xsl:if>
			
			<Patient>
				<!-- Personal Information -->
				<xsl:apply-templates select="hl7:recordTarget/hl7:patientRole" mode="PersonalInformation"/>
				
				<!-- Healthcare Provider module -->
				<xsl:apply-templates select="hl7:documentationOf" mode="HealthcareProvider"/>
				
				<!-- Support module -->
				<xsl:apply-templates select="." mode="Support"/>
			</Patient>
			
			
			<!-- Alerts and Allergies -->
			<xsl:apply-templates select="." mode="AllergiesSection"/>
			
			<!-- Advance Directives -->
			<xsl:apply-templates select="." mode="AdvanceDirectivesSection"/>
			
			<!-- Family History -->
			<xsl:apply-templates select="." mode="FamilyHistorySection"/>
			
			<!-- Social History -->
			<xsl:apply-templates select="." mode="SocialHistorySection"/>
			
			<!-- History of Present Illness -->
			<xsl:apply-templates select="." mode="PresentIllnessSection"/>
			
			<!-- Encounters -->
			<xsl:apply-templates select="." mode="Encounters"/>
			
			<!-- ActionCodes variable helps limit writing ActionCode to once per informationType/encounter combination. -->
			<xsl:if test="string-length($documentActionCode)">
				<xsl:if test="isc:evaluate('varKill','ActionCodes')"></xsl:if>
			</xsl:if>
			
			<!-- Problems and History of Past Illness -->
			<xsl:apply-templates select="." mode="ActiveProblemsSection"/>
			<xsl:apply-templates select="." mode="ResolvedProblemsSection"/>
			
			<!-- Hospital Admission and Discharge Diagnoses -->
			<xsl:apply-templates select="." mode="AdmissionDiagnosesSection"/>
			<xsl:apply-templates select="." mode="DischargeDiagnosesSection"/>
			
			<!-- Medications, Medications Administered, Discharge Medications -->
			<xsl:apply-templates select="." mode="DischargeMedicationsSection"/>
			<xsl:apply-templates select="." mode="MedicationsSection"/>
			<xsl:apply-templates select="." mode="MedicationsAdministeredSection"/>
			
			<!-- Immunizations -->
			<xsl:apply-templates select="." mode="ImmunizationsSection"/>
			
			<!-- Diagnostic Results -->
			<xsl:apply-templates select="." mode="ResultsSection"/>

			<!-- Vital Signs -->
			<xsl:apply-templates select="." mode="VitalSignsSection"/>
			
			<!-- Plan of Care -->
			<xsl:apply-templates select="." mode="PlanOfCareSection"/>
			
			<!-- Procedures and Interventions -->
			<xsl:apply-templates select="." mode="ProceduresSection"/>
			
			<!-- Care Considerations -->
			<xsl:apply-templates select="." mode="CareConsiderationsSection"/>
			
			<!-- Assessment and Plan -->
			<xsl:apply-templates select="." mode="AssessmentAndPlanSection"/>
			
			<!-- Payers -->
			<xsl:apply-templates select="." mode="PayersSection"/>

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
			<SourceFormat>C32</SourceFormat>
			<xsl:apply-templates select="." mode="fn-DocumentHeaderInfo"/>
			<xsl:apply-templates select="." mode="ImportCustom-AdditionalDocumentInfo"/>
		</AdditionalDocumentInfo>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ImportCustom-Container">
	</xsl:template>	
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ImportCustom-AdditionalDocumentInfo">
	</xsl:template>
</xsl:stylesheet>
