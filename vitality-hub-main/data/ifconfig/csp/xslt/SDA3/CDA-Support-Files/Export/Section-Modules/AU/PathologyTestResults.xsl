<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="pathologyTestResults">
		<xsl:param name="sectionRequired" select="'0'"/>

		<xsl:variable name="hasData" select="LabOrders/LabOrder/Result"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/results/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
				
					<code code="102.16144" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Pathology Test Result"/>
					<title>Pathology Test Result</title>
				
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="diagnosticResults-Narrative">
								<xsl:with-param name="orderType" select="'LAB'"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="diagnosticResultsNEHTA-Entries">
								<xsl:with-param name="orderType" select="'LAB'"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<!-- Currently no real spec for how to express "no data" for results.   -->
							<text><xsl:value-of select="$exportConfiguration/results/emptySection/narrativeText/text()"/></text>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
