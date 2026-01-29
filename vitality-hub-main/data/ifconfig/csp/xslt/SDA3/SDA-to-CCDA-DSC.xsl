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
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/EncompassingEncounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/FunctionalStatus.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Immunization.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/VitalSign.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/AdvanceDirectives.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/DischargeDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/FunctionalStatus.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HistoryOfPastIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HospitalAdmissionDiagnosis.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HospitalCourse.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HospitalDischargeInstructions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HospitalDischargeMedications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProceduresAndInterventions.xsl"/>
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
			
			<code code="18842-5" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Discharge Summarization Note"/>
			
			<xsl:apply-templates select="." mode="document-title">
				<xsl:with-param name="title1">Discharge Summary Document</xsl:with-param>
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
			<xsl:apply-templates select="Patient" mode="healthcareProviders"/>
			
			<!-- Encompassing Encounter module -->
			<xsl:apply-templates select="Encounters/Encounter" mode="encompassingEncounter">
				<xsl:with-param name="clinicians" select="'|DIS|ATND|ADM|CON|REF|'"/>
			</xsl:apply-templates>
			
			<!-- End CDA Header -->
			<!-- Begin CCD Body -->
			<component>
				<structuredBody>
					<!-- Advance Directives module -->
					<xsl:apply-templates select="." mode="advanceDirectives"/>
					
					<!-- History of Present Illness module -->
					<xsl:apply-templates select="." mode="presentIllness"/>
					
					<!-- Problem List module -->
					<xsl:apply-templates select="." mode="problems"/>
					
					<!-- History of Past Illness module -->
					<xsl:apply-templates select="." mode="pastIllness"/>
					
					<!-- Hospital Admission Diagnosis module -->
					<xsl:apply-templates select="." mode="admissionDiagnoses"/>
					
					<!-- Discharge Diagnosis module -->
					<xsl:apply-templates select="." mode="dischargeDiagnoses">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Allergies -->
					<xsl:apply-templates select="." mode="allergies">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Family History module -->
					<xsl:apply-templates select="." mode="familyHistory"/>
					
					<!-- Social History module -->
					<xsl:apply-templates select="." mode="socialHistory"/>
					
					<!-- Hospital Discharge Medications module -->
					<xsl:apply-templates select="." mode="dischargeMedications">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Immunizations module -->
					<xsl:apply-templates select="." mode="immunizations"/>
					
					<!-- Vital Signs module -->
					<xsl:apply-templates select="." mode="vitalSigns"/>
					
					<!-- Hospital Course module -->
					<xsl:apply-templates select="." mode="hospitalCourse">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>

					<!-- Reason for Visit module -->
					<xsl:apply-templates select="." mode="reasonForVisit">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>

					<!-- Procedures and Interventions module -->
					<xsl:apply-templates select="." mode="procedures"/>
					
					<!-- Functional Status module -->
					<xsl:apply-templates select="." mode="functionalStatus"/>
					
					<!-- Plan of Care module -->
					<xsl:apply-templates select="." mode="planOfCare">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Hospital Discharge Instructions module -->
					<xsl:apply-templates select="." mode="dischargeInstructions"/>
					
					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-documentHeader">
		<templateId root="{$ccda-USRealmHeader}"/>
		<templateId root="{$ccda-DischargeSummary}"/>
	</xsl:template>
	
	<!-- confidentialityCode may be overriden by stylesheets that import this one -->
	<xsl:template mode="document-confidentialityCode" match="Container">
	<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
	</xsl:template>

	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
