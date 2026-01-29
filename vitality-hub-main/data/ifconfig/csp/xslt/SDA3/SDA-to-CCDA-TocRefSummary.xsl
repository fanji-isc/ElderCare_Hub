<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-CCDA.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDA/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDA/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/AdvanceDirective.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/FunctionalStatus.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Immunization.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Result.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/VitalSign.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/AdvanceDirectives.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/AllergiesAndOtherAdverseReactionsEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/DiagnosticResults.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/DiagnosticResultsEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/DischargeDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/FunctionalStatus.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HistoryOfPastIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HospitalAdmissionDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HospitalDischargeInstructions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Instructions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ImmunizationsEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/MedicationsEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProblemListEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProceduresAndInterventionsEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ReasonForReferral.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ReasonForVisit.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/VitalSigns.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/VitalSignsEntriesRequired.xsl"/>
	
	<xsl:variable name="documentPatientSetting"><xsl:apply-templates select="." mode="document-patientSetting"/></xsl:variable>
	<xsl:variable name="documentIsExportSummary"><xsl:apply-templates select="." mode="document-isExportSummary"/></xsl:variable>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>
	
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:apply-templates select="." mode="templateIds-documentHeader"/>
			
			<xsl:apply-templates select="Patient" mode="id-Document"/>
			
			<code code="34133-9" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Summarization of Episode Note"/>
			
			<xsl:variable name="originalTitle"><xsl:apply-templates select="." mode="document-originalTitle"/></xsl:variable>
			<xsl:apply-templates select="." mode="document-title">
				<xsl:with-param name="title1"><xsl:value-of select="$originalTitle"/></xsl:with-param>
			</xsl:apply-templates>
			
			<effectiveTime value="{$currentDateTime}"/>
			<xsl:apply-templates mode="document-confidentialityCode" select="."/>
			<languageCode code="en-US"/>
			
			<!-- Person Information module -->
			<xsl:apply-templates select="Patient" mode="personInformation"/>
			
			<!-- Information Source module -->
			<xsl:apply-templates select="Patient" mode="informationSource"/>
			
			<!-- Support module	-->
			<xsl:apply-templates select="Patient" mode="nextOfKin"/>
			
			<!-- Healthcare Providers module -->
			<xsl:apply-templates select="Patient" mode="healthcareProviders">
				<xsl:with-param name="includeDiagnosisClinicians" select="'1'"/>
			</xsl:apply-templates>
			
			<!-- End CDA Header -->
			<!-- Begin CCD Body -->
			<component>
				<structuredBody>
					<!-- Payers -->
					<xsl:apply-templates select="." mode="payers"/>
					
					<!-- Advance Directives module -->
					<xsl:apply-templates select="." mode="advanceDirectives"/>
					
					<!-- Problem List module -->
					<xsl:apply-templates select="." mode="problems">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Allergies -->
					<xsl:apply-templates select="." mode="allergies">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Family History module -->
					<xsl:apply-templates select="." mode="familyHistory"/>
					
					<!-- Social History module -->
					<xsl:apply-templates select="." mode="socialHistory">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Medications module -->
					<xsl:apply-templates select="." mode="medications">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Immunizations module -->
					<xsl:apply-templates select="." mode="immunizations">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Vital Signs module -->
					<xsl:apply-templates select="." mode="vitalSigns">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Procedures and Interventions module -->
					<xsl:apply-templates select="." mode="procedures">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Functional Status module -->
					<xsl:apply-templates select="." mode="functionalStatus">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Plan of Care module -->
					<xsl:apply-templates select="." mode="planOfCare">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Hospital Admisson Diagnoses and Hospital Discharge Diagnoses modules -->
					<!--
						Only need to export one of these sections if only one of them has
						data.  If neither has data then just export Discharge Diagnoses.
					-->
					<xsl:if test="$documentPatientSetting='Inpatient'">
						<xsl:variable name="hasAdmissionDiagnoses"><xsl:apply-templates select="." mode="admissionDiagnoses-hasData"/></xsl:variable>
						<xsl:variable name="hasDischargeDiagnoses"><xsl:apply-templates select="." mode="dischargeDiagnoses-hasData"/></xsl:variable>
						<xsl:if test="string-length($hasAdmissionDiagnoses)">
							<xsl:apply-templates select="." mode="admissionDiagnoses"/>
						</xsl:if>
						<xsl:if test="string-length($hasDischargeDiagnoses) or (not(string-length($hasAdmissionDiagnoses)) and not(string-length($hasDischargeDiagnoses)))">
							<xsl:apply-templates select="." mode="dischargeDiagnoses"/>
						</xsl:if>
					</xsl:if>
					
					<!-- Instructions, or Hospital Discharge Instructions module -->
					<xsl:choose>
						<xsl:when test="$documentPatientSetting='Ambulatory'">
							<xsl:apply-templates select="." mode="instructions"/>
						</xsl:when>
						<xsl:when test="$documentPatientSetting='Inpatient'">
							<xsl:apply-templates select="." mode="dischargeInstructions">
								<xsl:with-param name="sectionRequired" select="'1'"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
		
					<!-- Encounters module -->
					<xsl:apply-templates select="." mode="encounters"/>
					
					<!-- Reason for Visit module -->
					<xsl:apply-templates select="." mode="reasonForVisit">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Reason for Referral module -->
					<xsl:apply-templates select="." mode="reasonForReferral">
						<xsl:with-param name="sectionRequired">
							<xsl:choose>
								<xsl:when test="$documentPatientSetting='Ambulatory'">1</xsl:when>
								<xsl:when test="$documentPatientSetting='Inpatient'">0</xsl:when>
							</xsl:choose>
						</xsl:with-param>
					</xsl:apply-templates>
					
					<!-- Results module -->
					<xsl:apply-templates select="." mode="results">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-documentHeader">
		<templateId root="{$ccda-USRealmHeader}"/>
		<templateId root="{$ccda-ContinuityOfCareCCD}"/>
	</xsl:template>
	
	<!-- confidentialityCode may be overriden by stylesheets that import this one -->
	<xsl:template mode="document-confidentialityCode" match="Container">
		<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
	</xsl:template>
	
	<!--
		Patient Setting can be Ambulatory or Inpatient.  The default logic
		here figures it out based on latest SDA Encounter.  This template
		is intended to be overridden by ambulatory-specific or inpatient-
		specific transforms.
	-->
	<xsl:template match="*" mode="document-patientSetting">
		<xsl:variable name="latestEncounterType" select="translate(/Container/Encounters/Encounter[1]/EncounterType/text(),$lowerCase,$upperCase)"/>
		<xsl:choose>
			<xsl:when test="$latestEncounterType='I' or $latestEncounterType='IP' or $latestEncounterType='INPATIENT'">Inpatient</xsl:when>
			<xsl:otherwise>Ambulatory</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		The C-CDA document can be a Transition of Care/Referral Summary
		or an Export Summary.  The default logic here defaults the flag
		to 0 (Transition of Care/Referral Summary).  This template is
		intended to be overridden by ToC-specific or Export Summary-
		specific transforms.
	-->
	<xsl:template match="*" mode="document-isExportSummary">0</xsl:template>
	
	<!--
		The C-CDA document can be a Transition of Care/Referral Summary
		or an Export Summary, and within those types, can be Ambulatory
		or Inpatient.  The default logic here defaults the title to
		Transition of Care/Referral Summary.  This template is intended
		to be overridden by more specific transforms.
	-->
	<xsl:template match="*" mode="document-originalTitle">
		<xsl:choose>
			<xsl:when test="$documentIsExportSummary='0' and $documentPatientSetting='Ambulatory'">Transition of Care/Referral Summary - Ambulatory</xsl:when>
			<xsl:when test="$documentIsExportSummary='0' and $documentPatientSetting='Inpatient'">Transition of Care/Referral Summary - Inpatient</xsl:when>
			<xsl:when test="$documentIsExportSummary='1' and $documentPatientSetting='Ambulatory'">Export Summary - Ambulatory</xsl:when>
			<xsl:when test="$documentIsExportSummary='1' and $documentPatientSetting='Inpatient'">Export Summary - Inpatient</xsl:when>
			<xsl:otherwise>Transition of Care/Referral Summary</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
