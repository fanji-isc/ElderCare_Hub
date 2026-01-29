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
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/FunctionalStatus.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HistoryOfPastIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/HospitalDischargeInstructions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Instructions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/MedicationsEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProblemListEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/ProceduresAndInterventionsEntriesRequired.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/VitalSigns.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/VitalSignsEntriesRequired.xsl"/>
	
	<xsl:variable name="documentPatientSetting">Ambulatory</xsl:variable>
	<xsl:variable name="documentIsExportSummary">0</xsl:variable>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>
	
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:apply-templates select="." mode="templateIds-documentHeader"/>
			
			<xsl:apply-templates select="Patient" mode="id-Document"/>
			
			<code code="34133-9" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Summarization of Episode Note"/>
			
			<xsl:apply-templates select="." mode="document-title">
				<xsl:with-param name="title1">Ambulatory Summary</xsl:with-param>
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
					<xsl:apply-templates select="." mode="socialHistory"/>
					
					<!-- Medications module -->
					<xsl:apply-templates select="." mode="medications">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Immunizations module -->
					<xsl:apply-templates select="." mode="immunizations"/>
					
					<!-- Vital Signs module -->
					<xsl:apply-templates select="." mode="vitalSigns">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Procedures and Interventions module -->
					<xsl:apply-templates select="." mode="procedures">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Functional Status module -->
					<xsl:apply-templates select="." mode="functionalStatus"/>
					
					<!-- Plan of Care module -->
					<xsl:apply-templates select="." mode="planOfCare">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Instructions module -->
					<xsl:apply-templates select="." mode="instructions"/>
					
					<!-- Encounters module -->
					<xsl:apply-templates select="." mode="encounters"/>
					
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
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
