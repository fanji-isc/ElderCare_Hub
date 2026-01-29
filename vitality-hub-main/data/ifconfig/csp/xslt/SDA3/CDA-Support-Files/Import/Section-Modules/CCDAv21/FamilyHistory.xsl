<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sFH-FamilyHistorySection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-FamilyHistorySection)" mode="sFH-FamilyHistories"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sFH-FamilyHistories">
		<xsl:variable name="IsNoDataSection">
			<xsl:apply-templates select="." mode="sFH-IsNoDataSection-FamilyHistory"/>
		</xsl:variable>
		
		<xsl:if test="$IsNoDataSection='0' or $documentActionCode='XFRM'">
			<FamilyHistories>
				<!-- Process CDA Append/Transform/Replace Directive -->
				<xsl:call-template name="ActionCode">
					<xsl:with-param name="informationType" select="'FamilyHistory'"/>
				</xsl:call-template>
				
				<xsl:if test="$IsNoDataSection='0'">
					<xsl:apply-templates select="hl7:entry" mode="eFH-FamilyHistory"/>
				</xsl:if>
			</FamilyHistories>
		</xsl:if>
	</xsl:template>
	
	<!-- Determine if the Family History section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is the $sectionRootPath for the Family History section.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include family history data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sFH-IsNoDataSection-FamilyHistory">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry/hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>