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
					Field : History of Present Illness Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/id
					Source: HS.SDA3.IllnessHistory ExternalId
					Source: /Container/IllnessHistories/IllnessHistory/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="id-External"/>

				<!--
					Field : History of Present Illness Text
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/code/originalText
					Source: HS.SDA3.IllnessHistory NoteText
					Source: /Container/IllnessHistories/IllnessHistory/NoteText
					Note  : The NoteText text does not appear in the section body,
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
					Field : History of Present Illness Start Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/effectiveTime/low/@value
					Source: HS.SDA3.IllnessHistory FromTime
					Source: /Container/IllnessHistories/IllnessHistory/FromTime
				-->
				<!--
					Field : History of Present Illness End Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/effectiveTime/high/@value
					Source: HS.SDA3.IllnessHistory ToTime
					Source: /Container/IllnessHistories/IllnessHistory/ToTime
				-->
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
				
				<!--
					Field : History of Present Illness Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/author
					Source: HS.SDA3.IllnessHistory EnteredBy
					Source: /Container/IllnessHistories/IllnessHistory/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					Field : History of Present Illness Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/informant
					Source: HS.SDA3.IllnessHistory EnteredAt
					Source: /Container/IllnessHistories/IllnessHistory/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="presentIllness-NoData">
		<text><xsl:value-of select="$exportConfiguration/presentIllness/emptySection/narrativeText/text()"/></text>
	</xsl:template>
</xsl:stylesheet>
