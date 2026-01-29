<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- AlsoInclude: AuthorParticipation.xsl -->
  
	<xsl:template match="*" mode="eHOPI-presentIllness-Narrative">
		<xsl:param name="docs"/>

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
					<xsl:apply-templates select="IllnessHistory" mode="eHOPI-presentIllness-NarrativeDetail"/>
				</tbody>
			</table>

			<!-- structured narrative documents -->
			<xsl:apply-templates mode="narrative-export-documents" select="..">
				<xsl:with-param name="docs" select="$docs"/>
				<xsl:with-param name="header" select="$exportConfiguration/narrative/section[templateId/@root=$ccda-HistoryOfPresentIllnessSection]/title/text()"/>
			</xsl:apply-templates>

		</text>
	</xsl:template>

	<xsl:template match="IllnessHistory" mode="eHOPI-presentIllness-NarrativeDetail">
		<tr ID="{concat($exportConfiguration/presentIllness/narrativeLinkPrefixes/presentIllnessNarrative/text(), position())}">
			<td><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="fn-narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/presentIllness/narrativeLinkPrefixes/presentIllnessNote/text(), position())}"><xsl:value-of select="NoteText/text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="eHOPI-presentIllness-Entries">
		<xsl:apply-templates select="IllnessHistory" mode="eHOPI-presentIllness-EntryDetail"/>
	</xsl:template>

	<xsl:template match="IllnessHistory" mode="eHOPI-presentIllness-EntryDetail">
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
				<xsl:apply-templates select="." mode="fn-id-External"/>

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
				<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>
				
				<!--
					Field : History of Present Illness Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/author
					Source: HS.SDA3.IllnessHistory EnteredBy
					Source: /Container/IllnessHistories/IllnessHistory/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				
				<!--
					Field : History of Present Illness Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/informant
					Source: HS.SDA3.IllnessHistory EnteredAt
					Source: /Container/IllnessHistories/IllnessHistory/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="eHOPI-presentIllness-NoData">
		<text><xsl:value-of select="$exportConfiguration/presentIllness/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
</xsl:stylesheet>