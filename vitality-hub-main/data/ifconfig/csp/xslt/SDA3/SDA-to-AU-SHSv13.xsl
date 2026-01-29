<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-AU.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/AU/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/AU/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>

	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/Immunization.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/MedicalHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AU/Procedure.xsl"/>

	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AU/AdministrativeObservations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AU/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AU/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AU/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AU/MedicalHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AU/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AU/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AU/ProceduresAndInterventions.xsl"/>
	
	<!-- The AU documents have several sections and fields whose structure or required values vary between documents. -->
	<xsl:variable name="documentExportType">NEHTASharedHealthSummary</xsl:variable>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>
	
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0">
			<!-- Begin CDA Header -->
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<templateId root="{$nehta-sharedHealthSummary}" extension="1.3"/>
			<templateId root="{$nehta-renderingSpecification}" extension="1.0"/>
			
			<xsl:apply-templates select="Patient" mode="id-Document"/>
			
			<code code="60591-5" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Patient Summary"/>
			
			<xsl:apply-templates select="." mode="document-title">
				<xsl:with-param name="title1">Shared Health Summary</xsl:with-param>
			</xsl:apply-templates>
			
			<effectiveTime value="{$currentDateTime}"/>
			<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
			<languageCode code="en-AU"/>
			<ext:completionCode code="F" codeSystem="1.2.36.1.2001.1001.101.104.20104" codeSystemName="NCTIS Document Status Values" displayName="Final"/>
			
			<!-- Person Information module -->
			<xsl:apply-templates select="Patient" mode="personInformation"/>
			
			<!-- Information Source module -->
			<xsl:apply-templates select="Patient" mode="informationSource"/>
			
			<!-- End CDA Header -->
			<!-- Begin Shared Health Summary Body -->
			<component>
				<structuredBody>
					<!-- Adverse Reactions -->
					<xsl:apply-templates select="." mode="allergies">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
						
					<!-- Medications -->
					<xsl:apply-templates select="." mode="medications">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
						
					<!-- Medical History (Problem/Diagnosis, Procedure, Other Medical History Item) -->
					<xsl:apply-templates select="." mode="medicalHistory">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
						
					<!-- Immunisations -->
					<xsl:apply-templates select="." mode="immunizations">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
						
					<!-- Administrative Observations -->
					<xsl:apply-templates select="." mode="administrativeObservations"/>
										
					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End Shared Health Summary Body -->
		</ClinicalDocument>
	</xsl:template>
		
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
