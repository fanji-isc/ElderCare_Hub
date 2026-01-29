<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
  <!-- AlsoInclude: VitalSign.xsl -->
	
	<xsl:template match="hl7:entry" mode="eHSO-OutcomeEntry">
		
		<Outcome>
			<!--
				Field : Outcome FromTime
				Target: HS.SDA3.Outcome FromTime
				Target: /Container/Outcomes/Outcome/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation/effectiveTime/low/@value
			-->
			<xsl:apply-templates select="hl7:observation/hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>

			<!--
				Field : Outcome ToTime
				Target: HS.SDA3.Outcome ToTime
				Target: /Container/Outcomes/Outcome/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation/effectiveTime/high/@value
			-->
			<xsl:apply-templates select="hl7:observation/hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>


			<!--
				Field : Outcome Act Id
				Target: HS.SDA3.Outcome ExternalId
				Target: /Container/Outcomes/Outcome/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation/id
			-->
			<xsl:apply-templates select="hl7:observation" mode="fn-ExternalId-concatenated"/>

			<!--
				Field : Outcome Narrative Text
				Target: HS.SDA3.Outcome Description
				Target: /Container/Outcomes/Outcome/Description
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation/text
			-->
			<xsl:variable name="referenceLink" select="substring-after(hl7:observation/hl7:text/hl7:reference/@value, '#')"/>
			<xsl:variable name="referenceValue">
				<xsl:choose>
					<xsl:when test="string-length($referenceLink)">
						<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="string-length($referenceValue)&gt;0">
				<Description>
					<xsl:value-of select="$referenceValue"/>
				</Description>
			</xsl:if>
			
			<!--
				Field : Outcome Observation
				Target: HS.SDA3.Outcome Observation
				Target: /Container/Outcomes/Outcome/Observation
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation
				StructuredMappingRef: eVS-Observation-Detail
			-->
			<xsl:if test="hl7:observation/hl7:value">
				<xsl:apply-templates select="hl7:observation" mode="eVS-OutcomeObservation-Detail"/>
			</xsl:if>


			<xsl:variable name="interventionIds" select="hl7:observation/hl7:entryRelationship/hl7:act[hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.122']/hl7:id" />
			<xsl:apply-templates select="$interventionIds"  mode="fn-W-pName-ExternalId-reference" >
				<xsl:with-param name="hsElementName">InterventionId</xsl:with-param>
			</xsl:apply-templates>

	
			<xsl:apply-templates select="." mode="eHSO-ImportCustom"/>
		</Outcome>
	</xsl:template>
	

	<!--
		This empty template may be overridden with custom logic.
	
		The input node spec is $sectionRootPath/hl7:entry/hl7:encounter
	-->
	<xsl:template match="*" mode="eHSO-ImportCustom">
	</xsl:template>
	
</xsl:stylesheet>