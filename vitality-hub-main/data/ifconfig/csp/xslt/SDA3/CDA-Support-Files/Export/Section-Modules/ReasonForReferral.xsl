<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="reasonForReferral">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="string-length($eventReason)"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/reasonForReferral/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-reasonForReferralSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="42349-1" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="REASON FOR REFERRAL"/>
					<title>Reason for Referral</title>
					
					<xsl:choose>
						<xsl:when test="$hasData"><xsl:apply-templates select="." mode="reasonForReferral-Narrative"/></xsl:when>
						<xsl:otherwise><xsl:apply-templates select="." mode="reasonForReferral-NoData"/></xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="reasonForReferral-Narrative">
		<text><xsl:value-of select="$eventReason" disable-output-escaping="yes"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="reasonForReferral-NoData">
		<text><xsl:value-of select="$exportConfiguration/reasonForReferral/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-reasonForReferralSection">
		<xsl:if test="$hitsp-CDA-ReasonForReferralSection"><templateId root="{$hitsp-CDA-ReasonForReferralSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ReasonForReferralSection"><templateId root="{$hl7-CCD-ReasonForReferralSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ReasonForReferral"><templateId root="{$ihe-PCC-ReasonForReferral}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
