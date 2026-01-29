<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="results-XDLAB">
		<xsl:variable name="hasData" select="LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/results/emptySection/exportData/text()"/>
		
		<xsl:if test="$hasData or (not($hasData) and ($exportSectionWhenNoData = 1))">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-diagnosticResultsXDLABSection"/>
	
					<code code="26436-6" displayName="LABORATORY STUDIES" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Results</title>
	
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="results-XDLAB-SubSection">
								<xsl:sort select="ResultTime" order="descending"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise><xsl:apply-templates select="." mode="diagnosticResults-NoData"/></xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="results-XDLAB-SubSection">
		<component>
			<section>
				<xsl:apply-templates select="." mode="templateIds-diagnosticResultsXDLABSubSection"/>
				<code code="26436-6" displayName="LABORATORY STUDIES" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<xsl:apply-templates select="." mode="diagnosticResults-Narrative">
					<xsl:with-param name="narrativeLinkSuffix" select="position()"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="." mode="diagnosticResultsXDLAB-Entries">
					<xsl:with-param name="narrativeLinkSuffix" select="position()"/>
				</xsl:apply-templates>
			</section>
		</component>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-diagnosticResultsXDLABSection">
		<xsl:if test="$ihe-PCC-LaboratorySpecialty"><templateId root="{$ihe-PCC-LaboratorySpecialty}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-diagnosticResultsXDLABSubSection">
		<xsl:if test="$ihe-PCC-LaboratorySpecialtySubSection"><templateId root="{$ihe-PCC-LaboratorySpecialtySubSection}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
