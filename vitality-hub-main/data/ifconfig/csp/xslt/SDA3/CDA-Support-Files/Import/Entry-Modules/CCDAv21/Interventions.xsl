<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
  <!-- AlsoInclude: AuthorParticipation.xsl Condition.xsl PriorityPreference.xsl -->
  
	<xsl:template match="hl7:entry" mode="eIn-InterventionEntry">
		<!-- Health Concerns-->
		<!-- the following variables are currently UNUSED
		<xsl:variable name="encounterIDTemp"><xsl:apply-templates select="." mode="fn-formatEncounterId"/></xsl:variable>
		<xsl:variable name="encounterID" select="string($encounterIDTemp)"/> -->
		
		<Intervention>
			<!--
				Field : Intervention FromTime
				Target: HS.SDA3.Intervention FromTime
				Target: /Container/CarePlans/CarePlan/Interventions/Intervention/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act/effectiveTime/low/@value
			-->
			<xsl:apply-templates select="hl7:act/hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>

			<!--
				Field : Intervention ToTime
				Target: HS.SDA3.Intervention ToTime
				Target: /Container/CarePlans/CarePlan/Interventions/Intervention/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act/effectiveTime/high/@value
			-->
			<xsl:apply-templates select="hl7:act/hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>


			<!--
				Field : Intervention Act Id
				Target: HS.SDA3.Intervention ExternalId
				Target: /Container/CarePlans/CarePlan/Interventions/Intervention/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act/id
			-->
			<xsl:apply-templates select="hl7:act" mode="fn-ExternalId-concatenated"/>

			<!--
				Field : Intervention Description
				Target: HS.SDA3.Intervention Description
				Target: /Container/CarePlans/CarePlan/Interventions/Intervention/Description
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act/text
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
				Field : Intervention Status
				Target: HS.SDA3.Intervention Status
				Target: /Container/CarePlans/CarePlan/Interventions/Intervention/Status
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act/statusCode
			-->
			<Status>
				<xsl:choose>
					<xsl:when test="hl7:act/hl7:statusCode/@code='completed'">C</xsl:when>
					<xsl:otherwise>A</xsl:otherwise>
				</xsl:choose>
			</Status>
	
			<!--
				Field : Intervention Performers
				Target: HS.SDA3.Intervention Performers
				Target: /Container/CarePlans/CarePlan/Interventions/Intervention/Performers
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act/author
			-->
			<xsl:if test="hl7:act/hl7:author">
				<Performers>
					<xsl:apply-templates select="hl7:act/hl7:author" mode="eAP-DocumentProvider"/>
				</Performers>
			</xsl:if>

			<!--
				Field : Intervention Goal IDs
				Target: HS.SDA3.Intervention GoalIds
				Target: /Container/CarePlans/CarePlan/GoalIds
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.4.122']/hl7:id
			-->
			<xsl:variable name="goalIds" select="hl7:act/hl7:entryRelationship/hl7:act[hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.122']/hl7:id" />
			<xsl:if test="$goalIds">
				<GoalIds>
					<xsl:apply-templates select="$goalIds"  mode="fn-W-pName-ExternalId-reference" >
						<xsl:with-param name="hsElementName">GoalIdsItem</xsl:with-param>
					</xsl:apply-templates>
				</GoalIds>
			</xsl:if>

	
			<xsl:apply-templates select="." mode="eIn-ImportCustom"/>
		</Intervention>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eIn-InterventionSource-problem">
		<InterventionSource>
			<Problem>
				<xsl:apply-templates select="." mode="eCn-Condition-observation" />
			</Problem>
		</InterventionSource>
	</xsl:template>

	<!--
		This empty template may be overridden with custom logic.
	
		The input node spec is $sectionRootPath/hl7:entry/hl7:encounter
	-->
	<xsl:template match="*" mode="eIn-ImportCustom">
	</xsl:template>
	
</xsl:stylesheet>