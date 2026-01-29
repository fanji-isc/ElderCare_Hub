<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="physicalExams">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!--<xsl:variable name="hasData" select="PhysicalExams"/>-->
		<xsl:variable name="hasData" select="''"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/physicalExams/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-physicalExamsSection"/>
					
					<code code="29545-1" displayName="Physical Findings" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Physical Examination</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="physicalExams-Narrative"/>
							<xsl:apply-templates select="." mode="physicalExams-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="physicalExams-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- If the "entries required" templateId is needed then this template is overridden by *EntriesRequired.xsl -->
	<xsl:template match="*" mode="templateIds-physicalExamsSection">
		<templateId root="{$ccda-PhysicalExamSection}"/>
	</xsl:template>
</xsl:stylesheet>
