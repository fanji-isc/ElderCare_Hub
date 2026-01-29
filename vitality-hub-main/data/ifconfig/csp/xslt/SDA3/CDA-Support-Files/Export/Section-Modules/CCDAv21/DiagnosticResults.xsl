<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Entry module has non-parallel name. AlsoInclude: Result.xsl -->
  
	<xsl:template match="*" mode="sDR-results">
		<xsl:param name="sectionRequired" select="'0'"/>
		<xsl:param name="entriesRequired" select="'0'"/>
		
		<xsl:variable name="resultList" select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]
			                                 | LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]
			                                 | OtherOrders/OtherOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]"/>
		<xsl:variable name="hasData" select="count($resultList) > 0"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/results/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>

					<xsl:call-template name="sDR-templateIds-diagnosticResultsSection">
						<xsl:with-param name="entriesRequired" select="$entriesRequired"/>
					</xsl:call-template>

					<code code="30954-2" displayName="Relevant diagnostic tests and/or laboratory data" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Results</title>

					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="eR-diagnosticResults-Narrative">
								<xsl:with-param name="resultList" select="$resultList"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="eR-diagnosticResults-Entries">
								<xsl:with-param name="resultList" select="$resultList"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eR-diagnosticResults-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sDR-templateIds-diagnosticResultsSection">
		<xsl:param name="entriesRequired"/>
		<xsl:choose>
			<xsl:when test="$entriesRequired = '1'">
				<templateId root="{$ccda-ResultsSectionEntriesRequired}"/>
				<templateId root="{$ccda-ResultsSectionEntriesRequired}" extension="2015-08-01"/>
			</xsl:when>
			<xsl:otherwise>
				<templateId root="{$ccda-ResultsSectionEntriesOptional}"/>
				<templateId root="{$ccda-ResultsSectionEntriesOptional}" extension="2015-08-01"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>