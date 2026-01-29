<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="functionalStatus">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- Include only Problems with Category of 248536006 (Finding of functional performance and activity) -->
		<!-- or 373930000 (Cognitive function finding).  All others belong in the Problem List section.        -->
		<xsl:variable name="hasData" select="Problems/Problem[Category/Code='248536006' or Category/Code='373930000']"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/functionalStatus/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-functionalStatusSection"/>
					
					<code code="47420-5" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Functional Status"/>
					<title>Functional Status</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="functionalStatus-Narrative">
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="functionalStatus-Entries">
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="functionalStatus-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-functionalStatusSection">
		<templateId root="{$ccda-FunctionalStatusSection}"/>
	</xsl:template>
</xsl:stylesheet>
