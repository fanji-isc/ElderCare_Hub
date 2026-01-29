<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc hl7 xsi">
	<!-- AlsoInclude: Comment.xsl -->
	
	<xsl:template match="hl7:observation" mode="eAD-AdvanceDirective">
		<xsl:variable name="isOtherDirective"><xsl:apply-templates select="." mode="eAD-OtherDirectiveObservation" /></xsl:variable>
 		<xsl:variable name="hasAlertValue"><xsl:apply-templates select="." mode="eAD-HasAlertValue-AdvanceDirective" /></xsl:variable>
		
	    <xsl:if test="$isOtherDirective='false' and $hasAlertValue='true'">
		<AdvanceDirective>
			<!--
				Field : Advance Directive Author
				Target: HS.SDA3.AdvanceDirective EnteredBy
				Target: /Container/AdvanceDirectives/AdvanceDirective/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!--
				Field : Advance Directive Information Source
				Target: HS.SDA3.AdvanceDirective EnteredAt
				Target: /Container/AdvanceDirectives/AdvanceDirective/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!--
				Field : Advance Directive Author Time
				Target: HS.SDA3.AdvanceDirective EnteredOn
				Target: /Container/AdvanceDirectives/AdvanceDirective/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/author/time/@value
			-->
			<!-- HS.SDA3.AdvanceDirective EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>

			<!--
				Field : Advance Directive Id
				Target: HS.SDA3.AdvanceDirective ExternalId
				Target: /Container/AdvanceDirectives/AdvanceDirective/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/id
				StructuredMappingRef: ExternalId
			-->
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>

			<!--
				Field : Advance Directive Effective Date - Start
				Target: HS.SDA3.AdvanceDirective FromTime
				Target: /Container/AdvanceDirectives/AdvanceDirective/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/effectiveTime/low/@value
				Note  : CDA effectiveTime for Advance Directive has only a single
						time value - low or high.  If low is found then SDA FromTime
						is imported.  Otherwise if high is found then SDA ToTime is
						imported.
			-->
			<!--
				Field : Advance Directive Effective Date - End
				Target: HS.SDA3.AdvanceDirective ToTime
				Target: /Container/AdvanceDirectives/AdvanceDirective/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/effectiveTime/high/@value
				Note  : CDA effectiveTime for Advance Directive has only a single
						time value - low or high.  If low is found then SDA FromTime
						is imported.  Otherwise if high is found then SDA ToTime is
						imported.
			-->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>
			
			<!-- Alert Type -->
			<xsl:apply-templates select="." mode="eAD-AlertType" />
			
			<!-- Alert -->
			<xsl:apply-templates select="." mode="eAD-Alert" />
			
			<!-- Alert Status -->
			<xsl:apply-templates select="." mode="eAD-Status"/>
			
			<!--
				Field : Advance Directive Free Text Type
				Target: HS.SDA3.AdvanceDirective Comments
				Target: /Container/AdvanceDirectives/AdvanceDirective/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="eCm-Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eAD-ImportCustom-AdvanceDirective"/>
		</AdvanceDirective>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eAD-Alert">
		<!--
			Field : Advance Directive Alert
			Target: HS.SDA3.AdvanceDirective Alert
			Target: /Container/AdvanceDirectives/AdvanceDirective/Alert
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/value[@xsi:type='CD' and @code]
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'Alert'"/>
			<xsl:with-param name="importOriginalText" select="'1'" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:observation" mode="eAD-AlertType">
		<!--
			Field : Advance Directive Type
			Target: HS.SDA3.AdvanceDirective AlertType
			Target: /Container/AdvanceDirectives/AdvanceDirective/AlertType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/code
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'AlertType'"/>
			<xsl:with-param name="importOriginalText" select="'1'" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eAD-Status">
		<!-- The mode formerly known as AlertStatus -->
		<!--
			Field : Advance Directive Status
			Target: HS.SDA3.AdvanceDirective Status
			Target: /Container/AdvanceDirectives/AdvanceDirective/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/effectiveTime/high/@value
		-->
		<xsl:variable name="endDate" select="hl7:effectiveTime/hl7:high/@value"/>
		<xsl:variable name="dateDiff">
			<xsl:choose>
				<xsl:when test="string-length($endDate)">
					<xsl:value-of select="isc:evaluate('dateDiff', 'dd', concat(substring($endDate,5,2), '-', substring($endDate,7,2), '-', substring($endDate,1,4)))"/>
				</xsl:when>
				<xsl:otherwise>-999</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!--
			There is no Advance Directive Status in C-CDA.  CDA Advance
			Directive effectiveTime/high is compared to the current
			date when determining the Status value to use in SDA.
		-->
		<Status>
			<xsl:choose>
				<xsl:when test="number($dateDiff)>0">I</xsl:when>
				<xsl:otherwise>A</xsl:otherwise>
			</xsl:choose>
		</Status>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.	
		The input node spec is normally $sectionRootPath/hl7:entry.
	-->
	<xsl:template match="*" mode="eAD-ImportCustom-AdvanceDirective">
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eAD-OtherDirectiveObservation">
		<xsl:value-of select="contains('|71388002|AD|', concat('|', hl7:code/@code, '|'))"/>
   	</xsl:template>
   	
    <xsl:template match="hl7:observation"  mode="eAD-HasAlertValue-AdvanceDirective">
		<xsl:value-of select="hl7:value/@xsi:type='CD' and hl7:value/@code"/>
   	</xsl:template>

</xsl:stylesheet>
