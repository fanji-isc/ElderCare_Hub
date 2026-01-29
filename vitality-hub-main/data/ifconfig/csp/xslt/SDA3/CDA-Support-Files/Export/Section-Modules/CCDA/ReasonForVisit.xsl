<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="reasonForVisit">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/reasonForVisit/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-reasonForVisitSection"/>
					
					<code code="29299-5" displayName="REASON FOR VISIT" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Reason for Visit</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="reasonForVisit-Narrative"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="reasonForVisit-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="reasonForVisit-Narrative">
		<text>
			<content>
				<xsl:value-of select="Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())]/VisitDescription/text()"/>
			</content>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="reasonForVisit-NoData">
		<text><xsl:value-of select="$exportConfiguration/reasonForVisit/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-reasonForVisitSection">
		<templateId root="{$ccda-ReasonForVisitSection}"/>
	</xsl:template>
</xsl:stylesheet>
