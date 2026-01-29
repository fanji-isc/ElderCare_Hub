<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns="urn:hl7-org:v3"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sdtc="urn:hl7-org:sdtc"
	xmlns:isc="http://extension-functions.intersystems.com"
	xmlns:exsl="http://exslt.org/common"
	xmlns:set="http://exslt.org/sets"
	exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HITSP.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-IHE.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/XDLAB/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/XDLAB/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/XDLAB/Result.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/XDLAB/DiagnosticResults.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>
	
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:call-template name="templateIds-XDLABHeader"/>
			<xsl:apply-templates select="Patient" mode="id-Document"/>
			
			<code code="11502-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="LABORATORY REPORT.TOTAL"/>
			
			<xsl:apply-templates select="." mode="document-title">
				<xsl:with-param name="title1">Lab Report Document</xsl:with-param>
			</xsl:apply-templates>
			
			<effectiveTime value="{$currentDateTime}"/>
			<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
			<languageCode code="en-US"/>
			<setId root="{isc:evaluate('createGUID')}"/>
			<versionNumber value="1"/>
			
			<!-- Person Information module -->
			<xsl:apply-templates select="Patient" mode="personInformation"/>
			
			<!-- Information Source module -->
			<xsl:apply-templates select="Patient" mode="informationSource"/>
			
			<!-- Participants OrderedBy (ordering clinicians) module - see XDLAB/HealthcareProvider.xsl	-->
			<xsl:apply-templates select="." mode="participants-OrderedBy"/>
			
			<!-- Healthcare Providers module - see XDLAB/HealthcareProvider.xsl -->
			<xsl:apply-templates select="Patient" mode="healthcareProviders"/>

			<!-- End CDA Header -->
			<!-- Begin CCD Body -->
			<component>
				<structuredBody>
					<!-- Results module - see XDLAB/Result.xsl -->
					<xsl:apply-templates select="." mode="results-XDLAB">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template name="templateIds-XDLABHeader">
		<xsl:if test="string-length($hl7-CDA-CDAR2GeneralHeader)"><templateId root="{$hl7-CDA-CDAR2GeneralHeader}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level1Declaration)"><templateId root="{$hl7-CDA-Level1Declaration}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level2Declaration)"><templateId root="{$hl7-CDA-Level2Declaration}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level3Declaration)"><templateId root="{$hl7-CDA-Level3Declaration}"/></xsl:if>
		<xsl:if test="string-length($ihe-LabReportSpecification)"><templateId root="{$ihe-LabReportSpecification}"/></xsl:if>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
