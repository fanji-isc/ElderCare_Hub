<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
  <!-- AlsoInclude: Condition.xsl -->
  <!-- AlsoInclude: AuthorParticipation.xsl -->
  <!-- AlsoInclude: PriorityPreference.xsl -->

	<xsl:template match="HealthConcerns" mode="eHC-healthConcerns-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Text</th>
						<th>Date</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="HealthConcern" mode="eHC-healthConcerns-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="HealthConcern" mode="eHC-healthConcerns-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		

		<xsl:variable name="healthConcernExportProfileRTF">
			<healthConcerns>
				<emptySection>
					<exportData>0</exportData>
					<narrativeText>This patient has no known health concerns.</narrativeText>
				</emptySection>

				<narrativeLinkPrefixes>
					<healthConcernsNarrative>healthConcernsNarrative-</healthConcernsNarrative>
					<healthConcernsText>healthConcernsText-</healthConcernsText>
				</narrativeLinkPrefixes>
			</healthConcerns>
		</xsl:variable>
		
		<tr ID="{concat('healthConcernsNarrative-', $narrativeLinkSuffix)}">
			<td ID="{concat('healthConcernsText-', $narrativeLinkSuffix)}">
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
	
	<xsl:template match="HealthConcerns" mode="eHC-healthConcerns-Entries">
		<xsl:apply-templates select="HealthConcern" mode="eHC-healthConcerns-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="HealthConcern" mode="eHC-healthConcerns-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		<!-- HealthConcern becomes health concern act -->
		<entry>
			<act classCode="ACT" moodCode="EVN">
        		<xsl:call-template name="eHC-templateIds-healthConcernAct"/>
        		
        		<!--
					Field : Health Concern Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/id
					Source: HS.SDA3.HealthConcern ExternalId
					Source: /Container/HealthConcerns/HealthConcern/ExternalId
					StructuredMappingRef: id-External-CarePlan
				-->
		        <xsl:apply-templates select="." mode="fn-id-External-CarePlan">
		          <xsl:with-param name="externalId" select="ExternalId"/>
		        </xsl:apply-templates>

        		<code code="75310-3" displayName="Health Concern" codeSystem="{$loincOID}" codeSystemName="{$loincName}" />
        		<!--
					Field : Health Concern Description
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/observation/text
					Source: HS.SDA3.HealthConcern Description
					Source: /Container/HealthConcerns/HealthConcern/Description
				-->
				<text><reference value="{concat('#', 'healthConcernsText-', $narrativeLinkSuffix)}"/></text>
				<xsl:if test="Status">
					<statusCode><xsl:attribute name="code" ><xsl:value-of select="Status/Code" /></xsl:attribute></statusCode>
				</xsl:if>

				<!--
					Field : Health Concern Effective Date - Start
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/observation/effectiveTime/low/@value
					Source: HS.SDA3.HealthConcern FromTime
					Source: /Container/HealthConcerns/HealthConcern/FromTime
				-->
				<!--
					Field : Health Concern Effective Date - End
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/observation/effectiveTime/high/@value
					Source: HS.SDA3.HealthConcern ToTime
					Source: /Container/HealthConcerns/HealthConcern/ToTime
				-->
				<xsl:if test="(string-length(FromTime) or string-length(StartTime)) or (string-length(ToTime) or string-length(EndTime))">
					<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>
				</xsl:if>

				<!-- 
					Field : Authors of Health Concern
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.132']/author
					Source: HS.SDA3.HealthConcern Authors
					Source: /Container/HealthConcerns/HealthConcern/Authors/DocumentProvider/Provider
				-->
				<xsl:apply-templates select="Authors/DocumentProvider/Provider" mode="eAP-author-Human" />

				<!-- 
					Field : Health Concern Priority
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.132']/entryRelationship/observation
					Source: HS.SDA3.HealthConcern Priority
					Source: /Container/HealthConcerns/HealthConcern/Priority
				-->
				<xsl:apply-templates select="Priority" mode="ePP-entryRelationship" />

			</act>
		</entry>
	</xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  
  <xsl:template name="eHC-templateIds-healthConcernAct">
	  <templateId root="{$ccda-healthConcernAct}" extension="2015-08-01"/>
	</xsl:template>
  
</xsl:stylesheet>