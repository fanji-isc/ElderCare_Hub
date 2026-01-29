<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="instructions">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Encounters/Encounter/RecommendationsProvided/Recommendation[string-length(NoteText/text())>0]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/instructions/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-instructionsSection"/>
					
					<code code="69730-0" displayName="INSTRUCTIONS" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Instructions</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="instructions-Narrative"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="instructions-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="instructions-Narrative">
		<text>
			<list>
				<xsl:apply-templates select="Encounters/Encounter" mode="instructions-Narrative-Recommendations"/>
			</list>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="instructions-Narrative-Recommendations">
			<xsl:apply-templates select="RecommendationsProvided/Recommendation[string-length(NoteText/text())>0]" mode="instructions-Narrative-Recommendation"/>
	</xsl:template>
	
	<xsl:template match="*" mode="instructions-Narrative-Recommendation">
		<item>
			<xsl:value-of select="NoteText/text()"/>
		</item>
	</xsl:template>
	
	<xsl:template match="*" mode="instructions-NoData">
		<text>
			<xsl:value-of select="$exportConfiguration/instructions/emptySection/narrativeText/text()"/>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-instructionsSection">
		<templateId root="{$ccda-InstructionsSection}"/>
	</xsl:template>
</xsl:stylesheet>
