<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="*" mode="sHDI-dischargeInstructions">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="count(Encounters/Encounter/RecommendationsProvided/Recommendation[string-length(NoteText/text())>0])"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeInstructions/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="$hasData = 0"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sHDI-templateIds-dischargeInstructionsSection"/>
					
					<code code="8653-8" displayName="HOSPITAL DISCHARGE INSTRUCTIONS" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Hospital Discharge Instructions</title>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="." mode="sHDI-dischargeInstructions-Narrative"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="sHDI-dischargeInstructions-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Container" mode="sHDI-dischargeInstructions-Narrative">
		<text>
			<list>
				<xsl:for-each select="Encounters/Encounter/RecommendationsProvided/Recommendation[string-length(NoteText/text())>0]">
					<item>
						<xsl:value-of select="NoteText/text()"/>
					</item>
				</xsl:for-each>
			</list>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="sHDI-dischargeInstructions-NoData">
		<text><xsl:value-of select="$exportConfiguration/dischargeInstructions/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sHDI-templateIds-dischargeInstructionsSection">
		<templateId root="{$ccda-HospitalDischargeInstructionsSection}"/>
		<templateId root="{$ccda-HospitalDischargeInstructionsSection}" extension="2015-08-01"/>
	</xsl:template>
	
</xsl:stylesheet>