<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sHOPreI-PresentIllnessSection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-HistoryOfPresentIllnessSection)" mode="sHOPreI-PresentIllnesses"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sHOPreI-PresentIllnesses">
		<xsl:variable name="IsNoDataSection">
			<xsl:apply-templates select="." mode="sHOPreI-IsNoDataSection-PresentIllnesses"/>
		</xsl:variable>
		
		<xsl:if test="$IsNoDataSection='0' or $documentActionCode='XFRM'">
			<IllnessHistories>
				<!-- Process CDA Append/Transform/Replace Directive -->
				<xsl:call-template name="ActionCode">
					<xsl:with-param name="informationType" select="'IllnessHistory'"/>
				</xsl:call-template>
				
				<xsl:if test="$IsNoDataSection='0'">
					<xsl:apply-templates select="hl7:entry[not(.//@negationInd='true')]/hl7:act" mode="eHOPI-IllnessHistory"/>
				</xsl:if>
			</IllnessHistories>
		</xsl:if>
	</xsl:template>
	
	<!-- Determine if the History of Present Illness section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is the $sectionRootPath for the History of Present Illness section.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include present illness data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sHOPreI-IsNoDataSection-PresentIllnesses">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>