<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!--********************************************************

     Include files

     ******************************************************** -->	
	<!-- System, Common, and Variables -->     
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-CCDA.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>		
	
	<!-- Export entry module files -->	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AuthorParticipation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PersonalInformation.xsl"/>


	<!-- Export section module files -->		
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Non-RatifiedSections.xsl"/>

	<!--********************************************************

     C-CDA Document

     ******************************************************** -->
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">

			<!-- 
				Begin CDA Header 
			-->

			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<!-- Template Id -->			
			<xsl:apply-templates select="." mode="fn-templateId-USRealmHeader"/>
			<xsl:apply-templates select="." mode="templateId-USDHeader"/>

			<xsl:apply-templates select="Patient" mode="fn-id-Document"/>

			<!-- Code -->
			<code code="34133-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Summarization of Episode Note"/>
			
			<!-- Document  -->			
			<xsl:apply-templates select="." mode="fn-title-forDocument">
				<xsl:with-param name="title1">Patient Summary Document</xsl:with-param>
			</xsl:apply-templates>

			<effectiveTime value="{$currentDateTime}"/>

			<xsl:apply-templates select="." mode="document-confidentialityCode" />

			<languageCode code="en-US"/>
			
			<!-- Person Information module -->
			<xsl:apply-templates select="Patient" mode="ePI-personInformation"/>
			
			<!-- Information Source module -->
			<xsl:apply-templates select="Patient" mode="eIS-informationSource"/>		

			<!-- End CDA Header -->	

			<!-- 
				Begin CCD Body 
			-->	

			<!-- NonXMLBody module -->
			<xsl:apply-templates select="." mode="sNRS-nonXMLBody"/>
			
			<!-- Custom export -->
			<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>

			<!-- End CCD Body -->

		</ClinicalDocument>
	</xsl:template>

	
	<!--********************************************************

     Templates

     ******************************************************** -->	
	<xsl:template match="*" mode="templateId-USDHeader">
		<templateId root="{$ccda-USRealmHeader}"/>
		<templateId root="{$ccda-UnstructuredDocument}"/>
	</xsl:template>
	
	<!-- ConfidentialityCode may be overriden by stylesheets that import this one -->
	<xsl:template match="Container" mode="document-confidentialityCode">
		<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>

</xsl:stylesheet>
