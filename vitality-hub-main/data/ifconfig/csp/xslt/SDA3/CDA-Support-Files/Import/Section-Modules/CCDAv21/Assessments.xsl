<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
	
	<xsl:template match="*" mode="sA-AssessmentsSection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-AssessmentSection)" mode="sA-Assessments"/>
	</xsl:template>
	
	<xsl:template match="*" mode="sA-Assessments">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sA-IsNoDataSection-Assessments"/></xsl:variable>		
		
		<xsl:if test="$isNoDataSection = '0'">
			<Documents>
				<!--Each table row will be mapped to a single Document-->
				<xsl:apply-templates select="hl7:text/hl7:table/hl7:tbody/hl7:tr[hl7:td[contains(@ID, 'Assessment')]]" mode="sA-AssessmentDetail"/>
			</Documents>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:tr" mode="sA-AssessmentDetail">		
		<xsl:apply-templates select="." mode="eA-Assessment"/>
	</xsl:template>
	
	<!-- Determine if the Assessment section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $assessmentSection.
		Return 1 if the section nullFlavor attribute exists or when the section does not contain text/paragraph node.
		Otherwise Return 0 (section is present and appears to include assessment data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sA-IsNoDataSection-Assessments">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:text/hl7:table)=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>