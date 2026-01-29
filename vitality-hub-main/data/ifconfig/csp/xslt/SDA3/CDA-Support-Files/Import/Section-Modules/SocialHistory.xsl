<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="SocialHistorySection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$socialHistorySectionTemplateId]" mode="SocialHistories"/>
	</xsl:template>
	
	<xsl:template match="*" mode="SocialHistories">
		<xsl:variable name="IsNoDataSection">
			<xsl:apply-templates select="." mode="IsNoDataSection-SocialHistory"/>
		</xsl:variable>
		
		<xsl:if test="$IsNoDataSection='0' or $documentActionCode='XFRM'">
			<SocialHistories>
				<!-- Process CDA Append/Transform/Replace Directive -->
				<xsl:call-template name="ActionCode">
					<xsl:with-param name="informationType" select="'SocialHistory'"/>
				</xsl:call-template>
				
				<!--Observations with code/@code='76691-5' are for gender identity, and may be excluded depending on the configuration settings-->
				<xsl:apply-templates select="hl7:entry[$IsNoDataSection='0' and not(.//@negationInd='true')]/hl7:observation[$socialHistoryGenderIdentityImportMode = '1' or not(hl7:code/@code='76691-5')]" mode="SocialHistory"/>
			</SocialHistories>
		</xsl:if>
	</xsl:template>
	
	<!-- Determine if the Social History section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is the $sectionRootPath for the Social History section.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include social history data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-SocialHistory">
		<xsl:choose>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(hl7:observation/hl7:code/@code='76691-5')])=0 and $socialHistoryGenderIdentityImportMode='0'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
