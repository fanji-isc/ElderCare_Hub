<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="PresentIllness">
		<IllnessHistory>
			<!--
				Field : Illness History Author
				Target: HS.SDA3.IllnessHistory EnteredBy
				Target: /Container/IllnessHistories/IllnessHistory/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!--
				Field : Illness History Information Source
				Target: HS.SDA3.IllnessHistory EnteredAt
				Target: /Container/IllnessHistories/IllnessHistory/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!--
				Field : Illness History Author Time
				Target: HS.SDA3.IllnessHistory EnteredOn
				Target: /Container/IllnessHistories/IllnessHistory/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!--
				Field : Illness History Id
				Target: HS.SDA3.IllnessHistory ExternalId
				Target: /Container/IllnessHistories/IllnessHistory/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="ExternalId"/>

			<!--
				Field : Illness History Start Date/Time
				Target: HS.SDA3.IllnessHistory FromTime
				Target: /Container/IllnessHistories/IllnessHistory/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/effectiveTime/low/@value
			-->
			<!--
				Field : Illness History End Date/Time
				Target: HS.SDA3.IllnessHistory ToTime
				Target: /Container/IllnessHistories/IllnessHistory/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/effectiveTime/high/@value
			-->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
				
			<!--
				Field : Illness History Note Text
				Target: HS.SDA3.IllnessHistory NoteText
				Target: /Container/IllnessHistories/IllnessHistory/NoteText
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.4']/entry/act/code/originalText
			-->
			<NoteText><xsl:apply-templates select="hl7:code" mode="TextValue"/></NoteText>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-IllnessHistory"/>
		</IllnessHistory>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-IllnessHistory">
	</xsl:template>
</xsl:stylesheet>
