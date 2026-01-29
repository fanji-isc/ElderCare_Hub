<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="dischargeInstructions">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Encounters/Encounter/RecommendationsProvided/Recommendation[string-length(NoteText/text())>0]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeInstructions/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-dischargeInstructionsSection"/>
					
					<code code="8653-8" displayName="HOSPITAL DISCHARGE INSTRUCTIONS" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Hospital Discharge Instructions</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="dischargeInstructions-Narrative"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="dischargeInstructions-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="dischargeInstructions-Narrative">
		<text>
			<list>
				<xsl:apply-templates select="Encounters/Encounter" mode="dischargeInstructions-Narrative-Recommendations"/>
			</list>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="dischargeInstructions-Narrative-Recommendations">
			<xsl:apply-templates select="RecommendationsProvided/Recommendation[string-length(NoteText/text())>0]" mode="dischargeInstructions-Narrative-Recommendation"/>
	</xsl:template>
	
	<xsl:template match="*" mode="dischargeInstructions-Narrative-Recommendation">
		<item>
			<xsl:value-of select="NoteText/text()"/>
		</item>
	</xsl:template>
	
	<xsl:template match="*" mode="dischargeInstructions-NoData">
		<text><xsl:value-of select="$exportConfiguration/dischargeInstructions/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-dischargeInstructionsSection">
		<templateId root="{$ccda-HospitalDischargeInstructionsSection}"/>
	</xsl:template>
</xsl:stylesheet>
