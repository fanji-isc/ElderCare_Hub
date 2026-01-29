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
	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/EncompassingEncounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDA/Support.xsl"/>

	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDA/Non-RatifiedSections.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>

	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:apply-templates select="." mode="templateIds-documentHeader"/>
			<xsl:apply-templates select="Patient" mode="id-Document"/>
			
			<code code="34133-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Summarization of Episode Note"/>
			
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
					<!-- NonXMLBody module -->
					<xsl:apply-templates select="." mode="nonXMLBody"/>
					
					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-documentHeader">
		<templateId root="{$ccda-USRealmHeader}"/>
		<templateId root="{$ccda-UnstructuredDocument}"/>
	</xsl:template>
	
	<!-- confidentialityCode may be overriden by stylesheets that import this one -->
	<xsl:template mode="document-confidentialityCode" match="Container">
		<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
