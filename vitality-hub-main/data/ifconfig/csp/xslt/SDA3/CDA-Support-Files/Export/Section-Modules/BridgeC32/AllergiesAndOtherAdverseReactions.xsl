<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="allergies">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Allergies"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/allergies/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-allergiesSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="48765-2" displayName="Allergies, Adverse Reactions, Alerts" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Allergies, Adverse Reactions, Alerts</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="Allergies" mode="allergies-Narrative"/>
							<xsl:apply-templates select="Allergies" mode="allergies-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="allergies-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-allergiesSection">
		<xsl:if test="$hitsp-CDA-AllergiesAndOtherAdverseReactionsSection"><templateId root="{$hitsp-CDA-AllergiesAndOtherAdverseReactionsSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-AlertsSection"><templateId root="{$hl7-CCD-AlertsSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-AllergiesAndOtherAdverseReactions"><templateId root="{$ihe-PCC-AllergiesAndOtherAdverseReactions}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
