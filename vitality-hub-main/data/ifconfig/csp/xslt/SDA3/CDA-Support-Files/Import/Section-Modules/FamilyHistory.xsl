<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="FamilyHistorySection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$familyHistorySectionTemplateId]" mode="FamilyHistories"/>
	</xsl:template>
	
	<xsl:template match="*" mode="FamilyHistories">
		<xsl:variable name="IsNoDataSection">
			<xsl:apply-templates select="." mode="IsNoDataSection-FamilyHistory"/>
		</xsl:variable>
		
		<xsl:if test="$IsNoDataSection='0' or $documentActionCode='XFRM'">
			<FamilyHistories>
				<!-- Process CDA Append/Transform/Replace Directive -->
				<xsl:call-template name="ActionCode">
					<xsl:with-param name="informationType" select="'FamilyHistory'"/>
				</xsl:call-template>
				
				<xsl:apply-templates select="hl7:entry[$IsNoDataSection='0']" mode="FamilyHistory"/>
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
	<xsl:template match="*" mode="IsNoDataSection-FamilyHistory">
		<xsl:choose>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry/hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
