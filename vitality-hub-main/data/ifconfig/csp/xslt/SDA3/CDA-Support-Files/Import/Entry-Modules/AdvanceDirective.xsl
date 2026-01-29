<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="hl7:observation" mode="AdvanceDirective">
		<xsl:variable name="isOtherDirective"><xsl:apply-templates select="." mode="OtherDirectiveObservation" /></xsl:variable>
 		<xsl:variable name="hasAlertValue"><xsl:apply-templates select="." mode="HasAlertValue-AdvanceDirective" /></xsl:variable>

   	    <xsl:if test="$isOtherDirective='false' and $hasAlertValue='true'">
		<AdvanceDirective>
			<!--
				Field : Advance Directive Author
				Target: HS.SDA3.AdvanceDirective EnteredBy
				Target: /Container/AdvanceDirectives/AdvanceDirective/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!--
				Field : Advance Directive Information Source
				Target: HS.SDA3.AdvanceDirective EnteredAt
				Target: /Container/AdvanceDirectives/AdvanceDirective/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!--
				Field : Advance Directive Author Time
				Target: HS.SDA3.AdvanceDirective EnteredOn
				Target: /Container/AdvanceDirectives/AdvanceDirective/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>

			<!--
				Field : Advance Directive Id
				Target: HS.SDA3.AdvanceDirective ExternalId
				Target: /Container/AdvanceDirectives/AdvanceDirective/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/id
				StructuredMappingRef: ExternalId
			-->
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>

			<!--
				Field : Advance Directive Effective Date - Start
				Target: HS.SDA3.AdvanceDirective FromTime
				Target: /Container/AdvanceDirectives/AdvanceDirective/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/effectiveTime/low/@value
				Note  : CDA effectiveTime for Advance Directive has only a single
						time value - low or high.  If low is found then SDA FromTime
						is imported.  Otherwise if high is found then SDA ToTime is
						imported.
			-->
			<!--
				Field : Advance Directive Effective Date - End
				Target: HS.SDA3.AdvanceDirective ToTime
				Target: /Container/AdvanceDirectives/AdvanceDirective/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/effectiveTime/high/@value
				Note  : CDA effectiveTime for Advance Directive has only a single
						time value - low or high.  If low is found then SDA FromTime
						is imported.  Otherwise if high is found then SDA ToTime is
						imported.
			-->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
			
			<!-- Alert Type -->
			<xsl:apply-templates select="." mode="AlertType" />
			
			<!-- Alert -->
			<xsl:apply-templates select="." mode="Alert" />
			
			<!-- Alert Status -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value" mode="AlertStatus"/>
			
			<!--
				Field : Advance Directive Free Text Type
				Target: HS.SDA3.AdvanceDirective Comments
				Target: /Container/AdvanceDirectives/AdvanceDirective/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-AdvanceDirective"/>
		</AdvanceDirective>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="Alert">
		<!--
			Field : Advance Directive Alert
			Target: HS.SDA3.AdvanceDirective Alert
			Target: /Container/AdvanceDirectives/AdvanceDirective/Alert
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/value[@xsi:type='CD' and @code]
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:value" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'Alert'"/>
			<xsl:with-param name="importOriginalText" select="'1'" />
		</xsl:apply-templates>
	</xsl:template>
		
	<xsl:template match="hl7:observation" mode="AlertType">
		<!--
			Field : Advance Directive Type
			Target: HS.SDA3.AdvanceDirective AlertType
			Target: /Container/AdvanceDirectives/AdvanceDirective/AlertType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/code
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:code" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'AlertType'"/>
			<xsl:with-param name="importOriginalText" select="'1'" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="AlertStatus">
		<!--
			Field : Advance Directive Status
			Target: HS.SDA3.AdvanceDirective Status
			Target: /Container/AdvanceDirectives/AdvanceDirective/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value/@code
		-->
		<Status>
			<xsl:choose>
				<xsl:when test="contains('|425392003|310305009|425396000|425397009|425393008|425395001|425394002|', concat('|', @code, '|'))">A</xsl:when>
				<xsl:otherwise>I</xsl:otherwise>
			</xsl:choose>
		</Status>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.	
		The input node spec is $sectionRootPath/hl7:entry/hl7:observation.
	-->
	<xsl:template match="*" mode="ImportCustom-AdvanceDirective">
	</xsl:template>

	<xsl:template match="hl7:observation" mode="OtherDirectiveObservation">
		<xsl:value-of select="contains('|71388002|AD|', concat('|', hl7:code/@code, '|'))"/>
   	</xsl:template>
   	
   	<xsl:template match="hl7:observation"  mode="HasAlertValue-AdvanceDirective">
		<xsl:value-of select="hl7:value/@xsi:type='CD' and hl7:value/@code"/>
   	</xsl:template>

</xsl:stylesheet>
