<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
  <!-- AlsoInclude: Condition.xsl -->
  <!-- AlsoInclude: AuthorParticipation.xsl -->
  <!-- AlsoInclude: PriorityPreference.xsl -->
	
	<xsl:template match="*" mode="eHC-HealthConcernEntry">
		<!-- Health Concerns-->
		<!-- the following variables are currently UNUSED
		<xsl:variable name="encounterIDTemp"><xsl:apply-templates select="." mode="fn-S-formatEncounterId"/></xsl:variable>
		<xsl:variable name="encounterID" select="string($encounterIDTemp)"/> -->
		
		<HealthConcern>

			<!--
				Field : HealthConcern FromTime
				Target: HS.SDA3.HealthConcern FromTime
				Target: /Container/HealthConcerns/HealthConcern/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/effectiveTime/low/@value
			-->
			<xsl:apply-templates select="hl7:act/hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>

			<!--
				Field : HealthConcern ToTime
				Target: HS.SDA3.HealthConcern ToTime
				Target: /Container/HealthConcerns/HealthConcern/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/effectiveTime/high/@value
			-->
			<xsl:apply-templates select="hl7:act/hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>


			<!--
				Field : HealthConcern Act Id
				Target: HS.SDA3.HealthConcern ExternalId
				Target: /Container/HealthConcerns/HealthConcern/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/id
			-->
			<xsl:apply-templates select="hl7:act" mode="fn-ExternalId-concatenated"/>

			<!--
				Field : HealthConcern Description
				Target: HS.SDA3.HealthConcern ExternalId
				Target: /Container/HealthConcerns/HealthConcern/Description
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/text
			-->
			<Description>
				<xsl:variable name="referenceLink" select="substring-after(hl7:act/hl7:text/hl7:reference/@value, '#')"/>
				<xsl:variable name="referenceValue">
					<xsl:choose>
						<xsl:when test="string-length($referenceLink)">
							<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$referenceValue"/>
			</Description>
			
			<!--
				Field : HealthConcern Status
				Target: HS.SDA3.HealthConcern Status
				Target: /Container/HealthConcerns/HealthConcern/Status
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/statusCode
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:act/hl7:statusCode" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" >Status</xsl:with-param>
			</xsl:apply-templates>

			<!--
				Field : HealthConcern Priority
				Target: HS.SDA3.HealthConcern Priority
				Target: /Container/HealthConcerns/HealthConcern/Priority
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/entryRelationship/observation
				StructuredMappingRef: Priority
			-->
			<xsl:apply-templates select="hl7:act/hl7:entryRelationship/hl7:observation[hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.143']" mode="ePP-Priority" />
	
			<!--
				Field : HealthConcern Authors
				Target: HS.SDA3.HealthConcern Authors
				Target: /Container/HealthConcerns/HealthConcern/Authors
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/author
				StructuredMappingRef: Priority
			-->
			<xsl:if test="hl7:act/hl7:author">
				<Authors>
					<xsl:apply-templates select="hl7:act/hl7:author" mode="eAP-DocumentProvider"/>
				</Authors>
			</xsl:if>
	
			<xsl:apply-templates select="." mode="eHC-ImportCustom"/>
		</HealthConcern>
	</xsl:template>

	<!--
		This empty template may be overridden with custom logic.
	
		The input node spec is $sectionRootPath/hl7:entry/hl7:encounter
	-->
	<xsl:template match="*" mode="eHC-ImportCustom">
	</xsl:template>
	
</xsl:stylesheet>