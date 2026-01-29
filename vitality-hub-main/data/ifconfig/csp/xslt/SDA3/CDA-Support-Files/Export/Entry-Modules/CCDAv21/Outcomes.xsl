<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com"
  xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
  <!-- AlsoInclude: EntryReference.xsl VitalSign.xsl -->

  <xsl:template match="Outcomes" mode="eHSO-outcomes-Narrative">
    <text>
      <table border="1" width="100%">
        <thead>
          <tr>
            <th>Text</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          <xsl:apply-templates select="Outcome" mode="eHSO-outcomes-NarrativeDetail"/>
        </tbody>
      </table>
    </text>
  </xsl:template>

  <xsl:template match="Outcome" mode="eHSO-outcomes-NarrativeDetail">
    <xsl:variable name="narrativeLinkSuffix" select="position()"/>
    <xsl:variable name="outcomeExportProfileRTF">
      <outcomes>
        <emptySection>
          <exportData>0</exportData>
          <narrativeText>This patient has no known outcomes.</narrativeText>
        </emptySection>

        <narrativeLinkPrefixes>
          <outcomesNarrative>outcomesNarrative-</outcomesNarrative>
          <outcomesText>outcomesText-</outcomesText>
        </narrativeLinkPrefixes>
      </outcomes>
    </xsl:variable>
    <tr ID="{concat('outcomesNarrative-', $narrativeLinkSuffix)}">
      <td ID="{concat('outcomesText-', $narrativeLinkSuffix)}">
        <xsl:value-of select="Description/text()"/>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="string-length(FromTime)">
            <xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/>
          </xsl:when>
          <xsl:when test="string-length(EnteredOn)">
            <xsl:apply-templates select="EnteredOn" mode="fn-narrativeDateFromODBC"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'Unknown'"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="Outcomes" mode="eHSO-outcomes-Entries">
    <xsl:apply-templates select="Outcome" mode="eHSO-outcomes-EntryDetail"/>
  </xsl:template>

  <xsl:template match="Outcome" mode="eHSO-outcomes-EntryDetail">
    <xsl:variable name="narrativeLinkSuffix" select="position()"/>
    <!-- Outcome becomes Outcome observation -->
    <entry>
      <observation classCode="OBS" moodCode="EVN">
        <xsl:call-template name="eHSO-templateIds-outcomeObservation"/>

        <!--
					Field : Outcome Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation/id
					Source: HS.SDA3.Outcome ExternalId
					Source: /Container/CarePlans/CarePlan/Outcomes/Outcome/ExternalId
					StructuredMappingRef: id-External-CarePlan
				-->
        <xsl:apply-templates select="." mode="fn-id-External-CarePlan">
          <xsl:with-param name="externalId" select="ExternalId"/>
        </xsl:apply-templates>

        <!--
					Field : Outcome Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation/code
					Source: HS.SDA3.Observation ObservationCode
					Source: /Container/CarePlans/CarePlan/Outcomes/Outcome/Observation/ObservationCode
					StructuredMappingRef: generic-Coded
				-->
        <xsl:choose>
          <xsl:when test="Observation/ObservationCode">
            <xsl:apply-templates select="Observation/ObservationCode" mode="fn-generic-Coded"/>
          </xsl:when>
          <xsl:otherwise>
            <code nullFlavor="NI"/>
          </xsl:otherwise>
        </xsl:choose>

        <!--
					Field : Outcome Description
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation/text
					Source: HS.SDA3.Outcome Description
					Source: /Container/CarePlans/CarePlan/Outcomes/Outcome/Description
				-->
        <text>
          <reference value="{concat('#', 'outcomesText-', $narrativeLinkSuffix)}"/>
        </text>

        <!--
					Field : Outcome Value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.61']/entry/observation/value
					Source: HS.SDA3.Outcome Observation
					Source: /Container/CarePlans/CarePlan/Outcomes/Outcome/Observation
					StructuredMappingRef: eVS-value-observation
				-->
        <xsl:apply-templates select="Observation" mode="eVS-value-observation"/>

        <xsl:apply-templates select="InterventionId" mode="eER-entryRelationship">
          <xsl:with-param name="relationshipTypeCode">RSON</xsl:with-param>
        </xsl:apply-templates>
      </observation>
    </entry>
  </xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->

  <xsl:template name="eHSO-templateIds-outcomeObservation">
    <templateId root="{$ccda-OutcomeObservation}"/>
  </xsl:template>

</xsl:stylesheet>