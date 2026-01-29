<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="presentIllness-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Period Start Date/Time</th>
						<th>Period End Date/Time</th>
						<th>Note Text</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="IllnessHistory" mode="presentIllness-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="presentIllness-NarrativeDetail">
		<tr ID="{concat($exportConfiguration/presentIllness/narrativeLinkPrefixes/presentIllnessNarrative/text(), position())}">
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/presentIllness/narrativeLinkPrefixes/presentIllnessNote/text(), position())}"><xsl:value-of select="NoteText/text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="presentIllness-Entries">
		<xsl:apply-templates select="IllnessHistory" mode="presentIllness-EntryDetail"/>
	</xsl:template>

	<xsl:template match="*" mode="presentIllness-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<!--
					HS.SDA3.IllnessHistory ExternalId
					CDA Section: History of Present Illness
					CDA Field: Id
					CDA XPath: entry/act/id
				-->			
				<xsl:apply-templates select="." mode="id-External"/>

				<!--
					HS.SDA3.IllnessHistory NoteText
					CDA Section: History of Present Illness
					CDA Field: History of Present Illness Text
					CDA XPath: entry/act/code
					
					The NoteText text does not appear in the section body,
					it only appears in the CDA section narrative.
					/entry/act/code/originalText/reference/@value points
					to the narrative location of the text.
				-->
				<code nullFlavor="OTH">
					<originalText><reference value="{concat('#', $exportConfiguration/presentIllness/narrativeLinkPrefixes/presentIllnessNote/text(), $narrativeLinkSuffix)}"/></originalText>
				</code>
				<text><reference value="{concat('#', $exportConfiguration/presentIllness/narrativeLinkPrefixes/presentIllnessNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="active"/>
				
				<!--
					HS.SDA3.IllnessHistory FromTime
					HS.SDA3.IllnessHistory ToTime
					CDA Section: History of Present Illness
					CDA Field: History of Present Illness Date/Time
					CDA XPath: entry/act/effectiveTime
				-->				
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
				
				<!--
					HS.SDA3.IllnessHistory EnteredBy
					CDA Section: History of Present Illness
					CDA Field: Author
					CDA XPath: entry/act/author
				-->				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					HS.SDA3.IllnessHistory EnteredAt
					CDA Section: History of Present Illness
					CDA Field: Information Source
					CDA XPath: entry/act/informant
				-->				
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="presentIllness-NoData">
		<text><xsl:value-of select="$exportConfiguration/presentIllness/emptySection/narrativeText/text()"/></text>
	</xsl:template>
</xsl:stylesheet>
