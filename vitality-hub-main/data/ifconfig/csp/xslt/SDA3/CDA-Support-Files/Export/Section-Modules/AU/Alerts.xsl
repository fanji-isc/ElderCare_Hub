<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="alerts">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- I = Inactive -->
		<xsl:variable name="alertInactiveStatusCodes">|I|</xsl:variable>
		<xsl:variable name="hasData" select="Alerts/Alert[not(contains($alertInactiveStatusCodes, concat('|', Status/text(), '|')))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/alerts/emptySection/exportData/text()"/>

		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>

					<code code="101.20021" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Alerts"/>
					<title>Alerts</title>
	
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="Alerts" mode="alerts-Narrative"/>
							<xsl:apply-templates select="Alerts" mode="alerts-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="alerts-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
