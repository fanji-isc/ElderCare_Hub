<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
	
	<xsl:template match="*" mode="sHSO-Section">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-HealthStatusAndOutcomesSection)" mode="sHSO-SectionEntries"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sHSO-SectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sHSO-IsNoDataSection"/></xsl:variable>
		<xsl:if test="$isNoDataSection='0'">
			<Outcomes>
				<xsl:apply-templates select="hl7:entry[not(.//@negationInd='true')]" mode="eHSO-OutcomeEntry"/>
			</Outcomes>
		</xsl:if>
	</xsl:template>
	
	<!-- Determine if the Outcomes section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $procedureSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include procedures data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sHSO-IsNoDataSection">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and hl7:entry[1]/hl7:procedure/hl7:code/@nullFlavor='NI'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>