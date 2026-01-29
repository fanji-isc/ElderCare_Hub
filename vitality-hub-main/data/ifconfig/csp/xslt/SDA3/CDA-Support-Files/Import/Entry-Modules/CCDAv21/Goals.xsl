<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
  <!-- AlsoInclude: AuthorParticipation.xsl Condition.xsl PriorityPreference.xsl VitalSign.xsl -->
  
	<xsl:template match="*" mode="eG-GoalEntry">
		<!-- Goal-->
		<!-- the following variables are currently UNUSED
		<xsl:variable name="encounterIDTemp"><xsl:apply-templates select="." mode="fn-formatEncounterId"/></xsl:variable>
		<xsl:variable name="encounterID" select="string($encounterIDTemp)"/> -->
		
		<Goal>
			<!--
				Field : Goal FromTime
				Target: HS.SDA3.Goal FromTime
				Target: /Container/Goals/Goal/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/effectiveTime/low/@value
			-->
			<xsl:apply-templates select="hl7:observation/hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>

			<!--
				Field : Goal ToTime
				Target: HS.SDA3.Goal ToTime
				Target: /Container/Goals/Goal/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/effectiveTime/high/@value
			-->
			<xsl:apply-templates select="hl7:observation/hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>

			<!--
				Field : Goal Act Id
				Target: HS.SDA3.Goal ExternalId
				Target: /Container/Goals/Goal/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/id
			-->
			<xsl:apply-templates select="hl7:observation" mode="fn-ExternalId-concatenated"/>

			<!--
				Field : Goal Description
				Target: HS.SDA3.Goal Description
				Target: /Container/Goals/Goal/Description
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/text
			-->
			<Description>
				<xsl:variable name="referenceLink" select="substring-after(hl7:observation/hl7:text/hl7:reference/@value, '#')"/>
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
				Field : Goal Target
				Target: HS.SDA3.Goal Target
				Target: /Container/Goals/Goal/Target
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/value
			-->
			<Target>
				<xsl:apply-templates select="hl7:observation/hl7:effectiveTime" mode="fn-I-timestamp">
					<xsl:with-param name="emitElementName" select="'ObservationTime'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="hl7:observation" mode="eVS-ObservationCode" />
				<xsl:apply-templates select="hl7:observation/hl7:value" mode="eVS-ObservationValue" />
			</Target>

			<!--
				Field : Goal Priority
				Target: HS.SDA3.Goal Priority
				Target: /Container/Goals/Goal/Priority
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/entryRelationship/observation
				StructuredMappingRef: Priority
			-->
			<xsl:apply-templates select="hl7:observation/hl7:entryRelationship/hl7:observation[hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.143']" mode="ePP-Priority" />
	
			<!--
				Field : Goal Authors
				Target: HS.SDA3.Goal Authors
				Target: /Container/Goals/Goal/Authors
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/author
			-->
			<xsl:if test="hl7:observation/hl7:author">
				<Authors>
					<xsl:apply-templates select="hl7:observation/hl7:author" mode="eAP-DocumentProvider"/>
				</Authors>
			</xsl:if>

			<!--
				Field : Goal HealthConcernIds
				Target: HS.SDA3.Goal HealthConcernIds
				Target: /Container/Goals/Goal/HealthConcernIds
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/entryRelationship/act[hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.122']/id
			-->
			<xsl:if test="hl7:observation/hl7:entryRelationship/hl7:act[hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.122']">
				<HealthConcernIds>
					<xsl:apply-templates select="hl7:observation/hl7:entryRelationship/hl7:act[hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.122']/hl7:id" mode="fn-W-pName-ExternalId-reference" >
						<xsl:with-param name="hsElementName">HealthConcernIdsItem</xsl:with-param>
					</xsl:apply-templates>
				</HealthConcernIds>
			</xsl:if>

			<xsl:apply-templates select="." mode="eG-ImportCustom"/>
		</Goal>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
	
		The input node spec is $sectionRootPath/hl7:entry/hl7:encounter
	-->
	<xsl:template match="*" mode="eG-ImportCustom">
	</xsl:template>
	
</xsl:stylesheet>