<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- AlsoInclude: AuthorParticipation.xsl EntryReference.xsl -->
  
	<xsl:template match="Interventions" mode="eIn-interventions-Narrative">
		<xsl:param name="docs"/>

		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Text</th>
						<th>Date</th>
						<th>Status</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Intervention" mode="eIn-interventions-NarrativeDetail"/>
				</tbody>
			</table>

			<!-- structured narrative documents -->
			<xsl:apply-templates mode="narrative-export-documents" select="ancestor::Container">
				<xsl:with-param name="docs" select="$docs"/>
				<xsl:with-param name="header" select="$exportConfiguration/narrative/section[templateId/@root=$ccda-InterventionsSection]/title/text()"/>
			</xsl:apply-templates>

		</text>
	</xsl:template>
	
	<xsl:template match="Intervention" mode="eIn-interventions-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		<xsl:variable name="interventionExportProfileRTF">
			<interventions>
				<emptySection>
					<exportData>0</exportData>
					<narrativeText>This patient has no known interventions.</narrativeText>
				</emptySection>

				<narrativeLinkPrefixes>
					<interventionsNarrative>interventionsNarrative-</interventionsNarrative>
					<interventionsText>interventionsText-</interventionsText>
				</narrativeLinkPrefixes>
			</interventions>
		</xsl:variable>		
		<tr ID="{concat('interventionsNarrative-', $narrativeLinkSuffix)}">
			<td ID="{concat('interventionsText-', $narrativeLinkSuffix)}">
				<xsl:value-of select="Description/text()" />
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="string-length(FromTime)"><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></xsl:when>
					<xsl:when test="string-length(EnteredOn)"><xsl:apply-templates select="EnteredOn" mode="fn-narrativeDateFromODBC"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="'Unknown'"/></xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="Status='C'">Completed</xsl:when>
					<xsl:otherwise>Planned/Active</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="Interventions" mode="eIn-interventions-Entries">
		<xsl:apply-templates select="Intervention" mode="eIn-interventions-EntryDetail"/>
	</xsl:template>
  
	<xsl:template match="Intervention" mode="eIn-interventions-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>

		<xsl:choose>
			<xsl:when test="Status='C'">
				<xsl:apply-templates select="." mode="eIn-completedIntervention-EntryDetail">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="eIn-plannedIntervention-EntryDetail">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
	<xsl:template match="Intervention" mode="eIn-plannedIntervention-EntryDetail">
		<xsl:param name="narrativeLinkSuffix" />
		<!-- Intervention becomes Intervention act -->
		<entry>
			<act classCode="ACT" moodCode="INT">
			  <xsl:call-template name="eIn-templateIds-plannedInterventionAct"/>

        		<!--
					Field : Intervention Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.146']/id
					Source: HS.SDA3.Intervention ExternalId
					Source: /Container/CarePlans/CarePlan/Interventions/Intervention/ExternalId
					StructuredMappingRef: id-External-CarePlan
				-->
        		<xsl:apply-templates select="." mode="fn-id-External-CarePlan">
          			<xsl:with-param name="externalId" select="ExternalId"/>
       	 		</xsl:apply-templates>

        		<code code="362956003" displayName="Procedure / intervention (navigational concept)"  codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" />

        		<!--
					Field : Intervention Description
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.146']/text
					Source: HS.SDA3.Intervention Description
					Source: /Container/CarePlans/CarePlan/Interventions/Intervention/Description
				-->
				<text><reference value="{concat('#', 'interventionsText-', $narrativeLinkSuffix)}"/></text>

				<statusCode code="active"/>

				<!--
					Field : Intervention Effective Date - Start
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.146']/effectiveTime/low/@value
					Source: HS.SDA3.Intervention FromTime
					Source: /Container/CarePlans/CarePlan/Interventions/Intervention/FromTime
				-->
				<!--
					Field : Intervention Effective Date - End
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.146']/effectiveTime/high/@value
					Source: HS.SDA3.Intervention ToTime
					Source: /Container/CarePlans/CarePlan/Interventions/Intervention/ToTime
				-->
				<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>

				<!-- 
					Field: Performers of Intervention
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.146']/author
					Source: /Container/CarePlans/CarePlan/Inerventions/Inervention/Performers/DocumentProvider/Provider
				-->
				<xsl:apply-templates select="Performers/DocumentProvider/Provider" mode="eAP-author-Human" />

				<xsl:apply-templates select="GoalIds/GoalIdsItem" mode="eER-entryRelationship">
					<xsl:with-param name="relationshipTypeCode">RSON</xsl:with-param>
				</xsl:apply-templates>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="Intervention" mode="eIn-completedIntervention-EntryDetail">
		<xsl:param name="narrativeLinkSuffix" />
		<!-- Intervention becomes Intervention act -->
		<entry>
			<act classCode="ACT" moodCode="EVN">
			  <xsl:call-template name="eIn-templateIds-interventionAct"/>

        		<!--
					Field : Intervention Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.131']/id
					Source: HS.SDA3.Intervention ExternalId
					Source: /Container/CarePlans/CarePlan/Interventions/Intervention/ExternalId
					StructuredMappingRef: id-External-CarePlan
				-->
        		<xsl:apply-templates select="." mode="fn-id-External-CarePlan">
          			<xsl:with-param name="externalId" select="ExternalId"/>
       	 		</xsl:apply-templates>

        		<code code="362956003" displayName="Procedure / intervention (navigational concept)"  codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" />

        		<!--
					Field : Intervention Description
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.131']/text
					Source: HS.SDA3.Intervention Description
					Source: /Container/CarePlans/CarePlan/Interventions/Intervention/Description
				-->
				<text><reference value="{concat('#', 'interventionsText-', $narrativeLinkSuffix)}"/></text>

				<statusCode code="completed"/>

				<!--
					Field : Intervention Effective Date - Start
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.131']/effectiveTime/low/@value
					Source: HS.SDA3.Intervention FromTime
					Source: /Container/CarePlans/CarePlan/Interventions/Intervention/FromTime
				-->
				<!--
					Field : Intervention Effective Date - End
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.131']/effectiveTime/high/@value
					Source: HS.SDA3.Intervention ToTime
					Source: /Container/CarePlans/CarePlan/Interventions/Intervention/ToTime
				-->
				<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>

				<!-- 
					Field: Performers of Intervention
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.21.2.3']/entry/act[templateId/@root='2.16.840.1.113883.10.20.22.4.131']/author
					Source: /Container/CarePlans/CarePlan/Inerventions/Inervention/Performers/DocumentProvider/Provider
				-->
				<xsl:apply-templates select="Performers/DocumentProvider/Provider" mode="eAP-author-Human" />

				<xsl:apply-templates select="GoalIds/GoalIdsItem" mode="eER-entryRelationship">
					<xsl:with-param name="relationshipTypeCode">RSON</xsl:with-param>
				</xsl:apply-templates>
			</act>
		</entry>
	</xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  
  <xsl:template name="eIn-templateIds-interventionAct">
    <templateId root="{$ccda-InterventionAct}" extension="2015-08-01"/>
  </xsl:template>
  
  <xsl:template name="eIn-templateIds-plannedInterventionAct">
    <templateId root="{$ccda-PlannedInterventionAct}" extension="2015-08-01"/>
  </xsl:template>
  
</xsl:stylesheet>