<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="results">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | OtherOrders/OtherOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/results/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-diagnosticResultsSection"/>
					
					<code code="30954-2" displayName="Relevant diagnostic tests and/or laboratory data" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Results</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="diagnosticResults-Narrative"/>
							<xsl:apply-templates select="." mode="diagnosticResults-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="diagnosticResults-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- If the "entries required" templateId is needed then this template is overridden by *EntriesRequired.xsl -->
	<xsl:template match="*" mode="templateIds-diagnosticResultsSection">
		<templateId root="{$ccda-ResultsSectionEntriesOptional}"/>
	</xsl:template>
</xsl:stylesheet>
