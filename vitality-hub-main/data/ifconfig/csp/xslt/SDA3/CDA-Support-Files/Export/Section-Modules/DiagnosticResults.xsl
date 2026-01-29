<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="results-C32">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | OtherOrders/OtherOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/results/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-diagnosticResultsC32Section"/>
	
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>

					<code code="30954-2" displayName="Relevant diagnostic tests and laboratory data" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Results</title>
	
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="diagnosticResults-Narrative"/>
							<xsl:apply-templates select="." mode="diagnosticResultsC32-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="diagnosticResults-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="results-C37">
		<xsl:variable name="hasData" select="LabOrders/LabOrder/Result"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/results/emptySection/exportData/text()"/>
		
		<xsl:if test="$hasData or (not($hasData) and ($exportSectionWhenNoData = 1))">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-diagnosticResultsC37Section"/>
	
					<code code="26436-6" displayName="LABORATORY STUDIES" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Results</title>
	
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="diagnosticResults-Narrative"><xsl:with-param name="orderType">LAB</xsl:with-param></xsl:apply-templates>
							<xsl:apply-templates select="." mode="diagnosticResultsC37-Entries"><xsl:with-param name="orderType">LAB</xsl:with-param></xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise><xsl:apply-templates select="." mode="diagnosticResults-NoData"/></xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-diagnosticResultsC32Section">
		<xsl:if test="$hitsp-CDA-DiagnosticResultsSection"><templateId root="{$hitsp-CDA-DiagnosticResultsSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ResultsSection"><templateId root="{$hl7-CCD-ResultsSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-CodedResults"><templateId root="{$ihe-PCC-CodedResults}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-diagnosticResultsC37Section">
		<xsl:if test="$hitsp-CDA-DiagnosticResultsSection"><templateId root="{$hitsp-CDA-DiagnosticResultsSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ResultsSection"><templateId root="{$hl7-CCD-ResultsSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-LaboratorySpecialty"><templateId root="{$ihe-PCC-LaboratorySpecialty}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
