<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- I = Inactive -->
	<xsl:variable name="alertInactiveStatusCodes">|I|</xsl:variable>
	
	<xsl:template match="*" mode="alerts-Narrative">
		<text>
			<table border="1" width="100%">
				<caption>Alerts</caption> 
				<thead>
					<tr>
						<th>Alert Type</th>
						<th>Alert</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Alert[not(contains($alertInactiveStatusCodes, concat('|', Status/text(), '|')))]" mode="alerts-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="alerts-NarrativeDetail">
		<xsl:variable name="alertNumber" select="position()"/>
		
		<tr ID="{concat($exportConfiguration/alerts/narrativeLinkPrefixes/alertNarrative/text(), position())}">
			<td ID="{concat($exportConfiguration/alerts/narrativeLinkPrefixes/alertType/text(), position())}"><xsl:value-of select="AlertType/Description/text()"/></td>
			<td ID="{concat($exportConfiguration/alerts/narrativeLinkPrefixes/alertAlert/text(), position())}"><xsl:value-of select="Alert/Description/text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="alerts-Entries">		
		<xsl:apply-templates select="Alert[not(contains($alertInactiveStatusCodes, concat('|', Status/text(), '|')))]" mode="alerts-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="alerts-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<entry typeCode="DRIV">
			<xsl:apply-templates select="." mode="alerts-Detail">
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="alerts-NoData">
		<text mediaType="text/x-hl7-text+xml"><xsl:value-of select="$exportConfiguration/alerts/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="alerts-Detail">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<observation classCode="OBS" moodCode="EVN">
			<xsl:choose>
				<xsl:when test="string-length(EnteredAt/Code) and string-length(ExternalId)">
					<xsl:apply-templates select="." mode="id-External"/>
				</xsl:when>
				<xsl:otherwise>
					<id root="{isc:evaluate('createUUID')}"/>
				</xsl:otherwise>
			</xsl:choose>
		
			<xsl:apply-templates select="AlertType" mode="generic-Coded"/>
			<xsl:apply-templates select="Alert" mode="value-CD"/>
		</observation>
	</xsl:template>
</xsl:stylesheet>
