<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<xsl:template match="*" mode="clinicalSynopsis-Narrative">
		<text mediaType="text/x-hl7-text+xml">
			<table border="1" width="100%">
				<caption>Clinical Synopsis</caption>
				<thead>
					<tr>
						<th>Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="." mode="clinicalSynopsis-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="clinicalSynopsis-NarrativeDetail">
		<tr>
			<td>
				<xsl:choose>
					<xsl:when test="string-length(Encounters/Encounter/VisitDescription/text())">
						<xsl:value-of select="Encounters/Encounter/VisitDescription/text()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$exportConfiguration/clinicalSynopsis/emptySection/narrativeText/text()"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
		
	<xsl:template match="*" mode="clinicalSynopsis-EntryDetail">
		<xsl:variable name="synopsisCode">
			<xsl:choose>
				<xsl:when test="$documentExportType='NEHTADischargeSummary'">103.15582</xsl:when>
				<xsl:when test="$documentExportType='NEHTAEventSummary'">102.15513</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="synopsisDisplayName">
			<xsl:choose>
				<xsl:when test="$documentExportType='NEHTADischargeSummary'">Clinical Synopsis Description</xsl:when>
				<xsl:when test="$documentExportType='NEHTAEventSummary'">Clinical Synopsis</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
				<code code="{$synopsisCode}" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="{$synopsisDisplayName}"/>
				<text xsi:type="ST">
					<xsl:choose>
						<xsl:when test="string-length(Encounters/Encounter/VisitDescription/text())">
							<xsl:value-of select="Encounters/Encounter/VisitDescription/text()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$exportConfiguration/clinicalSynopsis/emptySection/narrativeText/text()"/>
						</xsl:otherwise>
					</xsl:choose>
				</text>
			</act>
		</entry>
	</xsl:template>
</xsl:stylesheet>
