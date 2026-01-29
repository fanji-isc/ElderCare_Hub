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
	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/AssessmentAndPlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/EncompassingEncounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Fulfillment.xsl"/>
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
	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/AssessmentAndPlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Assessments.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ChiefComplaint.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ChiefComplaintAndReasonForVisit.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/DiagnosticResults.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HistoryOfPastIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ReasonForReferral.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ReasonForVisit.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/VitalSigns.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/VitalSignsEntriesRequired.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>
	
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:apply-templates select="." mode="templateIds-documentHeader"/>
			
			<xsl:apply-templates select="Patient" mode="id-Document"/>
			
			<code code="11488-4" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Consultation Note"/>
			
			<xsl:apply-templates select="." mode="document-title">
				<xsl:with-param name="title1">Consultation Note</xsl:with-param>
			</xsl:apply-templates>
			
			<effectiveTime value="{$currentDateTime}"/>
			<xsl:apply-templates mode="document-confidentialityCode" select="."/>
			<languageCode code="en-US"/>
			
			<!-- Person Information module -->
			<xsl:apply-templates select="Patient" mode="personInformation"/>
			
			<!-- Information Source module -->
			<xsl:apply-templates select="Patient" mode="informationSource"/>
			
			<!-- Support module -->
			<xsl:apply-templates select="Patient" mode="nextOfKin"/>
			
			<!-- Fullfillment module -->
			<xsl:apply-templates select="Patient" mode="fulfillment"/>
			
			<!-- Healthcare Providers module -->
			<xsl:apply-templates select="Patient" mode="healthcareProviders"/>
			
			<!-- Encompassing Encounter module -->
			<xsl:apply-templates select="Encounters/Encounter" mode="encompassingEncounter">
				<xsl:with-param name="clinicians" select="'|DIS|ATND|ADM|CON|REF|'"/>
			</xsl:apply-templates>
			
			<!-- End CDA Header -->
			<!-- Begin CCD Body -->
			<component>
				<structuredBody>
					<!-- History of Present Illness module -->
					<xsl:apply-templates select="." mode="presentIllness">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Problem List module -->
					<xsl:apply-templates select="." mode="problems"/>
					
					<!-- History of Past Illness module -->
					<xsl:apply-templates select="." mode="pastIllness"/>
					
					<!-- Allergies -->
					<xsl:apply-templates select="." mode="allergies"/>
					
					<!-- Family History module -->
					<xsl:apply-templates select="." mode="familyHistory"/>
					
					<!-- Social History module -->
					<xsl:apply-templates select="." mode="socialHistory"/>
					
					<!-- Medications module -->
					<xsl:apply-templates select="." mode="medications"/>
					
					<!-- Immunizations module -->
					<xsl:apply-templates select="." mode="immunizations"/>
					
					<!-- Vital Signs module -->
					<xsl:apply-templates select="." mode="vitalSigns"/>
					
					<!-- Procedures and Interventions module -->
					<xsl:apply-templates select="." mode="procedures"/>
					
					<!-- Plan of Care module -->
					<xsl:apply-templates select="." mode="planOfCare">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Results module -->
					<xsl:apply-templates select="." mode="results"/>
					
					<!-- Assessment module -->
					<xsl:apply-templates select="." mode="assessments">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Assessment and Plan module -->
					<xsl:apply-templates select="." mode="assessmentAndPlan"/>
					
					<!--
						Reason for Referral module and Reason For Visit module
						
						Consultation Note must contain either Reason for Referral
						OR Reason for Visit, but not both.
						
						If SDA data for both, then export only Reason for Referral.
						If SDA only for Referral, then export only Reason for Referral.
						If SDA only for Visit, then export only Reason for Visit.
						If no SDA for either, then export Reason for Referral no-data section.
					-->
					<xsl:variable name="hasReasonForReferralParameterData" select="string-length($eventReason)"/>
					<xsl:variable name="hasReasonForReferralSDAData" select="string-length(Referrals/Referral/ReferralReason/text())"/>
					<xsl:variable name="hasReasonForVisitData" select="Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())]"/>
					<xsl:choose>
						<xsl:when test="$hasReasonForReferralParameterData or $hasReasonForReferralSDAData">
							<xsl:apply-templates select="." mode="reasonForReferral"/>
						</xsl:when>
						<xsl:when test="$hasReasonForVisitData">
							<xsl:apply-templates select="." mode="reasonForVisit"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="reasonForReferral">
								<xsl:with-param name="sectionRequired" select="'1'"/>
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
						<xsl:when test="$hasReasonForReferralParameterData or $hasReasonForReferralSDAData">
							<!--
								This means that the Reason for Referral section was exported,
								and so a Chief Complaint and Reason for Visit section is
								required.  Use the SDA data for Reason for Visit if present.
							-->
							<xsl:apply-templates select="." mode="chiefComplaintAndReasonForVisit">
								<xsl:with-param name="sectionRequired" select="'1'"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$hasReasonForVisitData">
							<!--
								This means that the Reason for Visit section was exported,
								and so a Chief Complaint section is required.  Use the SDA
								data for Reason for Visit if present.
							-->
							<xsl:apply-templates select="." mode="chiefComplaint">
								<xsl:with-param name="sectionRequired" select="'1'"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="chiefComplaintAndReasonForVisit">
								<xsl:with-param name="sectionRequired" select="'1'"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
					
					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-documentHeader">
		<templateId root="{$ccda-USRealmHeader}"/>
		<templateId root="{$ccda-ConsultationNote}"/>
	</xsl:template>
	
	<!-- confidentialityCode may be overriden by stylesheets that import this one -->
	<xsl:template mode="document-confidentialityCode" match="Container">
		<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
	</xsl:template>

	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
