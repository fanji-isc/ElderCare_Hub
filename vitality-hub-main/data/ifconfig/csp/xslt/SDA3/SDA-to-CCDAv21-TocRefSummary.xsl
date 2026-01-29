<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-CCDA.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Narrative.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AdvanceDirective.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AllergyAndDrugSensitivity.xsl"/>
  	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Assessment.xsl"/> 	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AssessmentAndPlan.xsl"/>	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AuthorParticipation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/EncompassingEncounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/FunctionalStatus.xsl"/>
  	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Goals.xsl"/>
  	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HealthConcerns.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Immunization.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Instruction.xsl"/>	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Note.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PlanOfTreatment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PriorityPreference.xsl"/>	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Result.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/VitalSign.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/AdvanceDirectives.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Assessments.xsl"/>		
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/AssessmentAndPlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/ChiefComplaint.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/ChiefComplaintAndReasonForVisit.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/DiagnosticResults.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/DischargeDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/FunctionalStatus.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HealthConcerns.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HistoryOfPastIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HospitalAdmissionDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HospitalDischargeInstructions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Instructions.xsl"/>	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Notes.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/PlanOfTreatment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/ReasonForReferral.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/ReasonForVisit.xsl"/>	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/VitalSigns.xsl"/>
	
	<xsl:variable name="documentPatientSetting"><xsl:apply-templates select="." mode="document-patientSetting"/></xsl:variable>
	<xsl:variable name="documentIsExportSummary"><xsl:apply-templates select="." mode="document-isExportSummary"/></xsl:variable>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>
	
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:apply-templates select="." mode="fn-templateId-USRealmHeader"/>

			<xsl:apply-templates select="." mode="templateIds-CCDHeader"/>	
			
			<xsl:apply-templates select="Patient" mode="fn-id-Document"/>
			
			<code code="34133-9" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Summarization of Episode Note"/>
			
			<xsl:variable name="originalTitle"><xsl:apply-templates select="." mode="document-originalTitle"/></xsl:variable>
			<xsl:apply-templates select="." mode="fn-title-forDocument">
				<xsl:with-param name="title1"><xsl:value-of select="$originalTitle"/></xsl:with-param>
			</xsl:apply-templates>
			
			<effectiveTime value="{$currentDateTime}"/>
			<xsl:apply-templates mode="document-confidentialityCode" select="."/>
			<languageCode code="en-US"/>
		
			<!-- Person Information module -->
			<xsl:apply-templates select="Patient" mode="ePI-personInformation"/>
				
			<!-- Information Source module -->
			<xsl:apply-templates select="Patient" mode="eIS-informationSource"/>
			
			<!-- Support module	-->
			<xsl:apply-templates select="Patient" mode="eS-nextOfKin"/>
			
			<!-- Healthcare Providers module -->
			<xsl:apply-templates select="Patient" mode="eHP-healthcareProviders"/>

			<!-- Encompassing Encounter module -->
			<!-- There should always be just a single Encounter which represents this discharge, per CONF:1198-8471 -->
			<xsl:apply-templates select="Encounters/Encounter[1]" mode="eEE-encompassingEncounter">
				<xsl:with-param name="clinicians" select="'|DIS|ATND|ADM|CON|REF|'"/>
			</xsl:apply-templates>		
			
			<!-- End CDA Header -->
			<!-- Begin CCD Body -->
			<component>
				<structuredBody>
					<!-- Payers -->
					<xsl:apply-templates select="." mode="sP-payers"/>
					
					<!-- Advance Directives module -->
					<xsl:apply-templates select="." mode="sAD-advanceDirectives"/>
					
					<!-- Problem List module -->
					<xsl:apply-templates select="." mode="sPL-problems">
						<xsl:with-param name="sectionRequired" select="'1'"/>
						<xsl:with-param name="entriesRequired" select="'1'"/>						
					</xsl:apply-templates>
					
					<!-- Allergies -->
					<xsl:apply-templates select="." mode="sAOAR-allergies">
						<xsl:with-param name="sectionRequired" select="'1'"/>
						<xsl:with-param name="entriesRequired" select="'1'"/>
					</xsl:apply-templates>

					<!-- Family History module -->
					<xsl:apply-templates select="." mode="sFH-familyHistory"/>
					
					<!-- Social History module -->
					<xsl:apply-templates select="." mode="sSH-socialHistory">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>

					<!-- Medications module -->
					<xsl:apply-templates select="." mode="sM-medications">
						<xsl:with-param name="sectionRequired" select="'1'"/>
						<xsl:with-param name="entriesRequired" select="'1'"/>						
					</xsl:apply-templates>
					
					<!-- Immunizations module -->
					<xsl:apply-templates select="." mode="sIm-immunizations"/>
					
					<!-- Vital Signs module -->
					<xsl:apply-templates select="." mode="sVS-vitalSigns">
						<xsl:with-param name="sectionRequired" select="'1'"/>
						<xsl:with-param name="entriesRequired" select="'1'"/>
					</xsl:apply-templates>	
					
					<!-- Procedures and Interventions module -->
					<xsl:apply-templates select="." mode="sPAI-procedures">
						<xsl:with-param name="sectionRequired" select="'1'"/>
						<xsl:with-param name="entriesRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Functional Status module -->
					<xsl:apply-templates select="." mode="sFS-functionalStatus"/>
					
					<!-- Plan of Treatment module -->
					<xsl:apply-templates select="." mode="sPOT-planOfTreatment"/>


					<!-- Assessment and Plan module-->
					<xsl:apply-templates select="." mode="sANP-assessmentAndPlan"/>						
					
					<!-- Hospital Admisson Diagnoses and Hospital Discharge Diagnoses modules -->
					<!--
						Only need to export one of these sections if only one of them has
						data.  If neither has data then just export Discharge Diagnoses.
					-->
					
					<xsl:if test="$documentPatientSetting='Inpatient'">
						<!-- Hospital Admission Diagnosis module -->
						<xsl:apply-templates select="." mode="sHAD-admissionDiagnoses"/>
						<!-- Discharge Diagnosis module -->
						<xsl:apply-templates select="." mode="sDD-dischargeDiagnoses">
							<xsl:with-param name="sectionRequired" select="'1'"/>
						</xsl:apply-templates>						
					</xsl:if>
					
					
					<!-- Instructions, or Hospital Discharge Instructions module -->
					<xsl:choose>
						<xsl:when test="$documentPatientSetting='Ambulatory'">
							<xsl:apply-templates select="." mode="sIns-Instructions"/>
						</xsl:when>
						<xsl:when test="$documentPatientSetting='Inpatient'">
							<!-- Hospital Discharge Instructions module -->
							<xsl:apply-templates select="." mode="sHDI-dischargeInstructions">
								<xsl:with-param name="sectionRequired" select="'1'"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
		
					<!-- Encounters module -->
					<xsl:apply-templates select="." mode="sE-encounters"/>
					
					<xsl:variable name="hasReasonForReferralParameterData" select="string-length($eventReason)"/>
					<xsl:variable name="hasReasonForReferralSDAData" select="string-length(Referrals/Referral/ReferralReason/text())"/>
					<xsl:variable name="hasReasonForVisitData" select="Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())]"/>
					<xsl:variable name="hasReasonForReferralDocs">
						<xsl:apply-templates select="." mode="sRFR-reasonForReferral-hasStructuredNarrativeDocs"/>
					</xsl:variable>
					<xsl:variable name="hasReasonForVisitDocs">
						<xsl:apply-templates select="." mode="sRFV-reasonForVisit-hasStructuredNarrativeDocs"/>
					</xsl:variable>

					<!--
						Reason for Referral module and Reason For Visit module
						
						Consultation Note must contain either Reason for Referral
						OR Reason for Visit, but not both.
						
						If SDA data for both, then export only Reason for Referral.
						If SDA only for Referral, then export only Reason for Referral.
						If SDA only for Visit, then export only Reason for Visit.
						If no SDA for either, then export Reason for Referral no-data section.
					-->					
					<xsl:choose>
						<xsl:when test="$hasReasonForReferralParameterData or $hasReasonForReferralSDAData or ($hasReasonForReferralDocs='true')">
							<xsl:apply-templates select="." mode="sRFR-reasonForReferral"/>
						</xsl:when>
						<xsl:when test="$hasReasonForVisitData or ($hasReasonForVisitDocs='true')">
							<xsl:apply-templates select="." mode="sRFV-reasonForVisit"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="sRFR-reasonForReferral">
								<xsl:with-param name="sectionRequired">
									<xsl:choose>
										<xsl:when test="$documentPatientSetting='Ambulatory'">1</xsl:when>
										<xsl:when test="$documentPatientSetting='Inpatient'">0</xsl:when>
									</xsl:choose>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
								
					<!--
						Chief Complaint or Chief Complaint and Reason for Vist module
						
						Consultation Note has special rules for these sections:
						- If a Reason for Visit section is present, then the document
						  must have a Chief Complaint section.
						- If a Reason for Referral section is present (and hence Reason
						  for Visit is not), then the document must have a combined Chief
						  Complaint and Reason for Visit section.
					-->
					
					<xsl:choose>
						<xsl:when test="$hasReasonForReferralParameterData or $hasReasonForReferralSDAData or ($hasReasonForReferralDocs='true')">
							<!--
								This means that the Reason for Referral section was exported,
								and so a Chief Complaint and Reason for Visit section is
								required.  Use the SDA data for Reason for Visit if present.
							-->
							<xsl:apply-templates select="." mode="sEDRFV-chiefComplaintAndReasonForVisit">
								<xsl:with-param name="sectionRequired" select="'1'"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$hasReasonForVisitData or ($hasReasonForVisitDocs='true')">
							<!--
								This means that the Reason for Visit section was exported,
								and so a Chief Complaint section is required.  Use the SDA
								data for Reason for Visit if present.
							-->
							<xsl:apply-templates select="." mode="sED-chiefComplaint">
								<xsl:with-param name="sectionRequired" select="'1'"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="sEDRFV-chiefComplaintAndReasonForVisit">
								<xsl:with-param name="sectionRequired" select="'1'"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>

					<!-- Results module -->
					<xsl:apply-templates select="." mode="sDR-results">
						<xsl:with-param name="sectionRequired" select="'1'"/>
						<xsl:with-param name="entriesRequired" select="'1'"/>						
					</xsl:apply-templates>
					
					<!-- Assessment module -->
					<xsl:apply-templates select="." mode="sA-assessments">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>				

					<!-- Health Concerns module -->
					<xsl:apply-templates select="." mode="sHC-HealthConcerns"/> 

					<!-- Notes module -->
					<xsl:apply-templates select="." mode="sN-notes"/> 

					<!-- standalone structured narratives -->
					<xsl:apply-templates mode="narrative-export-sections" select=".">
						<xsl:with-param name="templates">
							<item root="{$ccda-CareTeamsSection}"/>
						</xsl:with-param>
					</xsl:apply-templates>

					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-CCDHeader">
		<templateId root="{$ccda-ContinuityOfCareCCD}"/>
		<templateId root="{$ccda-ContinuityOfCareCCD}" extension="2015-08-01"/>
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
