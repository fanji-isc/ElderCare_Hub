<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets"
       exclude-result-prefixes="isc xsi sdtc exsl set">
  <!-- AlsoInclude: AuthorParticipation.xsl EntryReference.xsl PriorityPreference VitalSign.xsl -->
  
	<xsl:template match="Goals" mode="eG-goals-Narrative">
		<xsl:param name="docs"/>

		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Text</th>
						<th>Date</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Goal" mode="eG-goals-NarrativeDetail"/>
				</tbody>
			</table>

			<!-- structured narrative documents -->
			<xsl:apply-templates mode="narrative-export-documents" select="..">
				<xsl:with-param name="docs" select="$docs"/>
				<xsl:with-param name="header" select="$exportConfiguration/narrative/section[templateId/@root=$ccda-GoalsSection]/title/text()"/>
			</xsl:apply-templates>

		</text>
	</xsl:template>
	
	<xsl:template match="Goal" mode="eG-goals-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		<xsl:variable name="goalExportProfileRTF">
			<goals>
				<emptySection>
					<exportData>0</exportData>
					<narrativeText>This patient has no known goals.</narrativeText>
				</emptySection>

				<narrativeLinkPrefixes>
					<goalsNarrative>goalsNarrative-</goalsNarrative>
					<goalsText>goalsText-</goalsText>
				</narrativeLinkPrefixes>
			</goals>
		</xsl:variable>		
		<tr ID="{concat('goalsNarrative-', $narrativeLinkSuffix)}">
			<td ID="{concat('goalsText-', $narrativeLinkSuffix)}">
				<xsl:value-of select="Description/text()" />
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="string-length(FromTime)"><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></xsl:when>
					<xsl:when test="string-length(EnteredOn)"><xsl:apply-templates select="EnteredOn" mode="fn-narrativeDateFromODBC"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="'Unknown'"/></xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="Goals" mode="eG-goals-Entries">
		<xsl:apply-templates select="Goal" mode="eG-goals-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="Goal" mode="eG-goals-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		<!-- Goal becomes Goal Observation -->
		<entry>
      <observation classCode="OBS" moodCode="GOL">
        <xsl:call-template name="eG-templateIds-goalObservation"/>

        <!--
					Field : Goal Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/id
					Source: HS.SDA3.Goal ExternalId
					Source: /Container/Goals/Goal/ExternalId
					StructuredMappingRef: id-External-CarePlan
		-->
        <xsl:apply-templates select="." mode="fn-id-External-CarePlan">
          <xsl:with-param name="externalId" select="ExternalId"/>
        </xsl:apply-templates>        

        <!--
					Field : Goal Target Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/code
					Source: HS.SDA3.Observation ObservationCode
					Source: /Container/Goals/Goal/Target/ObservationCode
					StructuredMappingRef: generic-Coded
		-->
        <xsl:choose>
          <xsl:when test="Target/ObservationCode">
            <xsl:apply-templates select="Target/ObservationCode" mode="fn-generic-Coded"/>
          </xsl:when>
          <xsl:otherwise>
            <code nullFlavor="NI"/>
          </xsl:otherwise>
        </xsl:choose>

        <!--
					Field : Goal Description
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/text
					Source: HS.SDA3.Goal Description
					Source: /Container/Goals/Goal/Description
				-->
        <text>
          <reference value="{concat('#', 'goalsText-', $narrativeLinkSuffix)}"/>
        </text>

        <statusCode code="active"/>

        <!--
					Field : Goal Effective Date - Start
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/effectiveTime/low/@value
					Source: HS.SDA3.Goal FromTime
					Source: /Container/Goals/Goal/FromTime
				-->
        <!--
					Field : Goal Effective Date - End
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/effectiveTime/high/@value
					Source: HS.SDA3.Goal ToTime
					Source: /Container/Goals/Goal/ToTime
				-->
        <xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>

        <!--
					Field : Goal Target Value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/value
					Source: HS.SDA3.Goal Target
					Source: /Container/Goals/Goal/Target
					StructuredMappingRef: eVS-value-observation
				-->
        <xsl:apply-templates select="Target" mode="eVS-value-observation"/>

        <!-- 
					Field: Goal Authors
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation[templateId/@root='2.16.840.1.113883.10.20.22.4.121']/author
					Source: /Container/Goals/Goal/Authors/DocumentProvider/Provider
					StructuredMappingRef: author-Human
				-->
        <xsl:apply-templates select="Authors/DocumentProvider/Provider" mode="eAP-author-Human"/>

        <xsl:if test="HealthConcernIds/HealthConcernIdsItem">
          <xsl:apply-templates select="HealthConcernIds/HealthConcernIdsItem" mode="eER-entryRelationship">
            <xsl:with-param name="relationshipTypeCode">REFR</xsl:with-param>
          </xsl:apply-templates>
        </xsl:if>

        <!-- 
					Field: Priority of Goal
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation[templateId/@root='2.16.840.1.113883.10.20.22.4.121']/entryRelationship/observation
					Source: /Container/Goals/Goal/Priority
				-->
        <xsl:apply-templates select="Priority" mode="ePP-entryRelationship"/>
      </observation>
		</entry>
	</xsl:template>
  

  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  
  <xsl:template name="eG-templateIds-goalObservation">
    <templateId root="{$ccda-GoalObservation}"/>
  </xsl:template>
  
</xsl:stylesheet>