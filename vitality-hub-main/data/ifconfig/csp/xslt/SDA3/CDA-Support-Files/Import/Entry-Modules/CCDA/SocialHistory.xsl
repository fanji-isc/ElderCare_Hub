<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="SocialHistory">
		<SocialHistory>
			<!--
				Field : Social History Author
				Target: HS.SDA3.SocialHistory EnteredBy
				Target: /Container/SocialHistories/SocialHistory/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!--
				Field : Social History Information Source
				Target: HS.SDA3.SocialHistory EnteredAt
				Target: /Container/SocialHistories/SocialHistory/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!--
				Field : Social History Author Time
				Target: HS.SDA3.SocialHistory EnteredOn
				Target: /Container/SocialHistories/SocialHistory/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!--
				Field : Social History Id
				Target: HS.SDA3.SocialHistory ExternalId
				Target: /Container/SocialHistories/SocialHistory/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!--
				Field : Social History Start Date
				Target: HS.SDA3.SocialHistory FromTime
				Target: /Container/SocialHistories/SocialHistory/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/effectiveTime/low/@value
				Note  : If only CDA effectiveTime/@value is present then both
						SDA FromTime and ToTime are imported from that value.
			-->
			<!--
				Field : Social History End Date
				Target: HS.SDA3.SocialHistory ToTime
				Target: /Container/SocialHistories/SocialHistory/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/effectiveTime/high/@value
				Note  : If only CDA effectiveTime/@value is present then both
						SDA FromTime and ToTime are imported from that value.
			-->
			<!-- Social History effectiveTime can be single value (TS) or low and high (IVL_TS). -->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/@value">
					<xsl:apply-templates select="hl7:effectiveTime" mode="FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime" mode="ToTime"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Social Habit -->
			<xsl:choose>
				<xsl:when test="hl7:templateId/@root=$ccda-SmokingStatusObservation">
					<xsl:apply-templates select="." mode="SmokingStatus"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="SocialHabitDescription"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Social Habit Quantity -->
			<xsl:if test="not(hl7:templateId/@root=$ccda-SmokingStatusObservation)">
				<xsl:apply-templates select="." mode="SocialHabitQuantity"/>
			</xsl:if>
			
			<!-- Social History Status -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value" mode="SocialHistoryStatus"/>
			
			<!--
				Field : Social History Comments
				Target: HS.SDA3.SocialHistory SocialHabitComments
				Target: /Container/SocialHistories/SocialHistory/SocialHabitComments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="Comment">
				<xsl:with-param name="elementName" select="'SocialHabitComments'"/>
			</xsl:apply-templates>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-SocialHistory"/>
		</SocialHistory>
	</xsl:template>
	
	<xsl:template match="*" mode="SocialHabitQuantity">
		<!--
			Field : Social History Observed Value
			Target: HS.SDA3.SocialHistory SocialHabitQty
			Target: /Container/SocialHistories/SocialHistory/SocialHabitQty
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/value
		-->
		<xsl:variable name="quantityText">
			<xsl:choose>
				<xsl:when test="hl7:value/@value and hl7:value/@unit">
					<xsl:value-of select="concat(hl7:value/@value,' ',hl7:value/@unit)"/>
				</xsl:when>
				<xsl:when test="hl7:value/@code and hl7:value/@displayName">
					<xsl:value-of select="hl7:value/@displayName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="hl7:value/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="quantityCode">
			<xsl:choose>
				<xsl:when test="hl7:value/@value and hl7:value/@unit">
					<xsl:value-of select="concat(hl7:value/@value,' ',hl7:value/@unit)"/>
				</xsl:when>
				<xsl:when test="hl7:value/@code">
					<xsl:value-of select="hl7:value/@code"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="hl7:value/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="quantityCodeSystem">
			<xsl:if test="hl7:value/@code and hl7:value/@codeSystem">
				<xsl:value-of select="hl7:value/@codeSystem"/>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="hl7:value">
			<SocialHabitQty>
				<Code><xsl:value-of select="$quantityCode"/></Code>
				<Description><xsl:value-of select="$quantityText"/></Description>
				<xsl:if test="string-length($quantityCodeSystem)">
					<SDACodingStandard>
						<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$quantityCodeSystem"/></xsl:apply-templates>
					</SDACodingStandard>
				</xsl:if>
			</SocialHabitQty>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="SocialHabitDescription">
		<!--
			Field : Social History Type
			Target: HS.SDA3.SocialHistory SocialHabit
			Target: /Container/SocialHistories/SocialHistory/SocialHabit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/code
			StructuredMappingRef: CodeTableDetail
			Note  : If CDA entry/observation/code/@code is not
					present then SDA SocialHabit is imported
					from entry/observation/text instead.
		-->
		<xsl:choose>
			<xsl:when test="(hl7:code/@code) or (hl7:code/hl7:translation[1]/@codeSystem=$noCodeSystemOID) or (hl7:code/@nullFlavor and hl7:code/hl7:translation[1]/@code)">
				<xsl:apply-templates select="hl7:code" mode="CodeTable">
					<xsl:with-param name="hsElementName" select="'SocialHabit'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="hl7:text" mode="CodeTable">
					<xsl:with-param name="hsElementName" select="'SocialHabit'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="SmokingStatus">
		<!--
			Field : Social History Type - Smoking Status
			Target: HS.SDA3.SocialHistory SocialHabit
			Target: /Container/SocialHistories/SocialHistory/SocialHabit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/value
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:value" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'SocialHabit'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="SocialHistoryStatus">
		<!--
			Field : Social History Status
			Target: HS.SDA3.SocialHistory Status
			Target: /Container/SocialHistories/SocialHistory/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/entryRelationship/observation[code/@code='33999-4']/value/@code
			Note  : CDA value code of 55561003 is imported to SDA Status as "A".
					All other values - including blank - are imported as "I".
		-->
		<xsl:if test="@code">
			<Status>
				<xsl:choose>
					<xsl:when test="@code = '55561003'"><xsl:text>A</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text>I</xsl:text></xsl:otherwise>
				</xsl:choose>
			</Status>
		</xsl:if>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:observation.
	-->
	<xsl:template match="*" mode="ImportCustom-SocialHistory">
	</xsl:template>
</xsl:stylesheet>
