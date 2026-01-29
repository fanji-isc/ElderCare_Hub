<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="reasonForReferral">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasParameterData" select="string-length($eventReason)"/>
		<xsl:variable name="hasSDAData" select="string-length(Referrals/Referral/ReferralReason/text())"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/reasonForReferral/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasParameterData) or ($hasSDAData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not(($hasParameterData) or ($hasSDAData))"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-reasonForReferralSection"/>
					
					<code code="42349-1" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Reason for Referral"/>
					<title>Reason for Referral</title>
					
					<xsl:choose>
						<xsl:when test="$hasParameterData or $hasSDAData">
							<text>
								<xsl:if test="$hasParameterData">
									<xsl:apply-templates select="." mode="reasonForReferral-parameter-Narrative"/>
								</xsl:if>
								<xsl:if test="$hasSDAData">
									<xsl:if test="$hasParameterData"><br/></xsl:if>
									<xsl:apply-templates select="." mode="reasonForReferral-SDA-Narrative"/>
								</xsl:if>
							</text>
						</xsl:when>
						<xsl:otherwise><xsl:apply-templates select="." mode="reasonForReferral-NoData"/></xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="reasonForReferral-parameter-Narrative">
		<xsl:value-of select="$eventReason" disable-output-escaping="yes"/>
	</xsl:template>
	
	<xsl:template match="*" mode="reasonForReferral-SDA-Narrative">
		<xsl:value-of select="Referrals/Referral/ReferralReason/text()"/>
	</xsl:template>
	
	<xsl:template match="*" mode="reasonForReferral-NoData">
		<text><xsl:value-of select="$exportConfiguration/reasonForReferral/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-reasonForReferralSection">
		<templateId root="{$ccda-ReasonForReferralSection}"/>
	</xsl:template>
</xsl:stylesheet>
