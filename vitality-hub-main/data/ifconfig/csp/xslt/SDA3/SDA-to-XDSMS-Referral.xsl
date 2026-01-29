<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HITSP.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-IHE.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/XPHR/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AdvanceDirective.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/XPHR/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Immunization.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/XPHR/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/VitalSign.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AdvanceDirectives.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/HistoryOfPastIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/XPHR/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/ReasonForReferral.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/VitalSigns.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>
	
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>

			<xsl:call-template name="templateIds-XDSMS-Referral-Header"/>
			<xsl:apply-templates select="Patient" mode="id-Document"/>

			<code code="34133-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Summarization of Episode Note"/>
			
			<xsl:apply-templates select="." mode="document-title">
				<xsl:with-param name="title1">Referral Summary Document</xsl:with-param>
			</xsl:apply-templates>
			
			<effectiveTime value="{$currentDateTime}"/>
			<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
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
					
					<!-- Reason for Referral module -->
					<xsl:apply-templates select="." mode="reasonForReferral">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- History of Present Illness module -->
					<xsl:apply-templates select="." mode="presentIllness">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Problem List module -->
					<xsl:apply-templates select="." mode="problems">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- History of Past Illness module -->
					<xsl:apply-templates select="." mode="pastIllness"/>

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
					<xsl:apply-templates select="." mode="vitalSigns"/>
					
					<!-- Plan of Care module -->
					<xsl:apply-templates select="." mode="planOfCare"/>
					
					<!-- Encounters module -->
					<xsl:apply-templates select="." mode="encounters"/>
					
					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template name="templateIds-XDSMS-Referral-Header">
		<xsl:if test="string-length($hl7-CDA-CDAR2GeneralHeader)"><templateId root="{$hl7-CDA-CDAR2GeneralHeader}"/></xsl:if>
		<xsl:if test="string-length($hl7-CCD-RegisteredTemplatesRoot)"><templateId root="{$hl7-CCD-RegisteredTemplatesRoot}"/></xsl:if>
		<xsl:if test="string-length($hl7-CCD-GeneralHeader)"><templateId root="{$hl7-CCD-GeneralHeader}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level1Declaration)"><templateId root="{$hl7-CDA-Level1Declaration}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level2Declaration)"><templateId root="{$hl7-CDA-Level2Declaration}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level3Declaration)"><templateId root="{$hl7-CDA-Level3Declaration}"/></xsl:if>
		<xsl:if test="string-length($hitsp-C48-ReferralSummary)"><templateId root="{$hitsp-C48-ReferralSummary}"/></xsl:if>
		<xsl:if test="string-length($ihe-MedicalDocumentsSpecification)"><templateId root="{$ihe-MedicalDocumentsSpecification}"/></xsl:if>
		<xsl:if test="string-length($ihe-MedicalSummarySpecification)"><templateId root="{$ihe-MedicalSummarySpecification}"/></xsl:if>
		<xsl:if test="string-length($ihe-ReferralSummarySpecification)"><templateId root="{$ihe-ReferralSummarySpecification}"/></xsl:if>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
