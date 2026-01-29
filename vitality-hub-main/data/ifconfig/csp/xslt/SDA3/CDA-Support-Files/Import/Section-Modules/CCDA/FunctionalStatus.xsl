<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="FunctionalStatusSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-FunctionalStatusSection]" mode="FunctionalStatusSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="FunctionalStatusSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-FunctionalStatus"/></xsl:variable>
		<!--
			Currently only Functional Status Problem Observations
			and Cognitive Status Problem Observations are imported.
			Functional Status Results and Cognitive Status Results
			are not imported.
		-->
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and ((not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))) and (hl7:observation/hl7:templateId/@root=$ccda-FunctionalStatusProblemObservation or hl7:observation/hl7:templateId/@root=$ccda-CognitiveStatusProblemObservation)]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Problems>
					<xsl:apply-templates select="$sectionEntries" mode="FunctionalStatusEntries"/>
				</Problems>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Problems>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'FunctionalStatus'"/>
						<xsl:with-param name="actionScope" select="'FUNCTIONALSTATUS'"/>
					</xsl:apply-templates>
				</Problems>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="FunctionalStatusEntries">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Problem'"/>
			<xsl:with-param name="actionScope" select="'PRESENT'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:observation[not(.//@negationInd='true')]" mode="FunctionalStatus"/>
	</xsl:template>
	
	<!-- Determine if the Functional Status section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $sectionRootPath[hl7:templateId/@root=$ccda-FunctionalStatusSection].
		Return 1 if the section is present and there is no hl7:entry element.
		Return 1 if the section is present and explicitly indicates "No Data" according to HS standard logic.
		Otherwise Return 0 (section is present and appears to include active problems data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-FunctionalStatus">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
