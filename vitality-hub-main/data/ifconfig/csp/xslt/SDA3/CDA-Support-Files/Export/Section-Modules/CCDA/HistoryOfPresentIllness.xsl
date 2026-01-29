<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="presentIllness">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="IllnessHistories"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/presentIllness/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-presentIllnessSection"/>
					
					<code code="10164-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="HISTORY OF PRESENT ILLNESS"/>
					<title>History of Present Illness</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="IllnessHistories" mode="presentIllness-Narrative"/>
							<xsl:apply-templates select="IllnessHistories" mode="presentIllness-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="presentIllness-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-presentIllnessSection">
		<templateId root="{$ccda-HistoryOfPresentIllnessSection}"/>
	</xsl:template>
</xsl:stylesheet>
