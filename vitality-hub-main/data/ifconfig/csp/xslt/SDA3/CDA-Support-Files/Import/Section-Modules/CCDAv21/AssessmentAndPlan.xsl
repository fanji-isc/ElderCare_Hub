<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="sANP-AssessmentAndPlanSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-AssessmentAndPlanSection]" mode="sANP-AssessmentAndPlanSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="sANP-AssessmentAndPlanSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sANP-IsNoDataSection-AssessmentAndPlan"/></xsl:variable>
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true')]"/>		

		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Documents>
					<xsl:apply-templates select="$sectionEntries" mode="sANP-AssessmentAndPlan"/>
				</Documents>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Documents>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Documents'"/>
						<xsl:with-param name="actionScope" select="'sANP-AssessmentAndPlan'"/>
					</xsl:apply-templates>
				</Documents>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="sANP-AssessmentAndPlan">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Document'"/>
			<xsl:with-param name="actionScope" select="'AssessmentAndPlan'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:act[not(.//@negationInd='true')]" mode="eANP-AssessmentAndPlan-EntryDetail"/>
	</xsl:template>
	
	<!-- Determine if the Assessment section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $assessmentSection.
		nullFlavor at the hl7:section level is the indicator for no information.
		Entries in this section are optional.
		Otherwise Return 0 (section is present and appears to include assessment data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sANP-IsNoDataSection-AssessmentAndPlan">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
