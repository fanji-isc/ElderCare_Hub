<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="ProceduresSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-ProceduresSectionEntriesOptional or hl7:templateId/@root=$ccda-ProceduresSectionEntriesRequired]" mode="ProceduresSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="ProceduresSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-Procedures"/></xsl:variable>
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and (not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Procedures>
					<xsl:apply-templates select="$sectionEntries" mode="Procedures"/>
				</Procedures>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Procedures>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Procedure'"/>
					</xsl:apply-templates>
				</Procedures>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="Procedures">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Procedure'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:procedure[not(.//@negationInd='true')]" mode="Procedure"/>
	</xsl:template>
	
	<!-- Determine if the Procedures section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $procedureSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include procedures data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-Procedures">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and hl7:entry[1]/hl7:procedure/hl7:code/@nullFlavor='NI'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
