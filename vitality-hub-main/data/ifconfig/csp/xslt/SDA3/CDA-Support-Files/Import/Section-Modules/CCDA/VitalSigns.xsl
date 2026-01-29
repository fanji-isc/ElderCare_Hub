<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="VitalSignsSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-VitalSignsSectionEntriesOptional or hl7:templateId/@root=$ccda-VitalSignsSectionEntriesRequired]" mode="VitalSignsSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="VitalSignsSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-VitalSigns"/></xsl:variable>
		<xsl:variable name="sectionEntries" select="hl7:entry[(not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Observations>
					<xsl:apply-templates select="$sectionEntries" mode="VitalSigns"/>
				</Observations>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Observations>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Observation'"/>
					</xsl:apply-templates>
				</Observations>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="VitalSigns">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Observation'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="." mode="VitalSign"/>
	</xsl:template>
	
	<!-- Determine if the Vital Signs section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $vitalSignSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include vital signs data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-VitalSigns">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry/hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and (hl7:entry[1]/hl7:organizer[1]/hl7:component[1]/hl7:observation/hl7:code/@nullFlavor='NI' or hl7:entry[1]/hl7:organizer[1]/hl7:component[1]/hl7:observation/hl7:value/@nullFlavor='NI')">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
