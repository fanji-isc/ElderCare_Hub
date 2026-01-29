<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HITSP.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-IHE.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-CCDA.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/BridgeC32/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/BridgeC32/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>

	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/EncompassingEncounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/Immunization.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/Result.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/BridgeC32/VitalSign.xsl"/>

	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/DiagnosticResults.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/BridgeC32/VitalSigns.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>

	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:call-template name="templateIds-BridgeC32Header"/>
			<xsl:apply-templates select="Patient" mode="id-Document"/>
			
			<code code="34133-9" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Summarization of Episode Note"/>
			
			<xsl:apply-templates select="." mode="document-title">
				<xsl:with-param name="title1">Patient Summary Document</xsl:with-param>
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
			
			<!--
				Encompassing Encounter module
				
				Export only if requested via $encompassingEncNum and $encompassingEncOrg.
			-->
			<xsl:variable name="encompassingEncNum"><xsl:apply-templates select="." mode="encompassingEncounterNumber"/></xsl:variable>
			<xsl:variable name="encompassingEncOrg"><xsl:apply-templates select="." mode="encompassingEncounterOrganization"/></xsl:variable>
			<xsl:if test="string-length($encompassingEncNum) and string-length($encompassingEncOrg)">
				<xsl:apply-templates select="Encounters/Encounter[(EncounterNumber/text()=$encompassingEncNum) and (HealthCareFacility/Organization/Code/text()=$encompassingEncOrg)]" mode="encompassingEncounter">
					<xsl:with-param name="clinicians" select="'|DIS|ATND|ADM|CON|REF|'"/>
				</xsl:apply-templates>
			</xsl:if>
			
			<!-- End CDA Header -->	
			<!-- Begin CCD Body -->
			<component>
				<structuredBody>
					<!-- Payers -->
					<xsl:apply-templates select="." mode="payers"/>
					
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

					<!-- Plan of Care module -->
					<xsl:apply-templates select="." mode="planOfCare"/>
	
					<!-- Encounters module -->
					<xsl:apply-templates select="." mode="encounters"/>

					<!-- Results module -->
					<xsl:apply-templates select="." mode="results-C32">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>

					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template name="templateIds-BridgeC32Header">
		<xsl:if test="string-length($hl7-CCD-RegisteredTemplatesRoot)"><templateId root="{$hl7-CCD-RegisteredTemplatesRoot}"/></xsl:if>
		<xsl:if test="string-length($hl7-CCD-GeneralHeader)"><templateId root="{$hl7-CCD-GeneralHeader}"/></xsl:if>
		<xsl:if test="string-length($hitsp-C32-SummaryDocument)"><templateId root="{$hitsp-C32-SummaryDocument}"/></xsl:if>
		<xsl:if test="string-length($ihe-MedicalDocumentsSpecification)"><templateId root="{$ihe-MedicalDocumentsSpecification}"/></xsl:if>
	</xsl:template>
	
	<!-- confidentialityCode may be overriden by stylesheets that import this one -->
	<xsl:template mode="document-confidentialityCode" match="Container">
		<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
	</xsl:template>

	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
