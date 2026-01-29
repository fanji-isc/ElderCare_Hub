<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="procedures-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Procedure</th>
						<th>Date / Time Performed</th>
						<th>Performing Clinician</th>
					</tr>
				</thead>
				<tbody>
					<!-- Export Procedures that: (did not come from PlanOfCare) AND ((with no date) OR (have a current or past effective date) OR (have a future effective date AND status not active)) -->
					<xsl:apply-templates select="Procedures/Procedure[(not(CustomPairs/NVPair/Name[text()='PlanOfCare' or text()='PlanOfTreatment'])) 
						and ((not(string-length(ProcedureTime/text())) and not(string-length(FromTime/text())))
							or ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) >= 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) >= 0))
							or (((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0))
								and (string-length(Status/Code/text()) and not(Status/Code/text()='active'))))]" mode="procedures-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="procedures-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/procedures/narrativeLinkPrefixes/procedureNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/procedures/narrativeLinkPrefixes/procedureDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="Procedure" mode="originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="ProcedureTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="Clinician" mode="name-Person-Narrative"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="procedures-Entries">
		<!-- Export Procedures that: (did not come from PlanOfCare) AND ((with no date) OR (have a current or past effective date) OR (have a future effective date AND status not active)) -->
		<xsl:apply-templates select="Procedures/Procedure[(not(CustomPairs/NVPair/Name[text()='PlanOfCare' or text()='PlanOfTreatment'])) 
			and ((not(string-length(ProcedureTime/text())) and not(string-length(FromTime/text())))
				or ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) >= 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) >= 0))
				or (((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0))
					and (string-length(Status/Code/text()) and not(Status/Code/text()='active'))))]" mode="procedures-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="procedures-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<procedure classCode="PROC" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-procedureEntry"/>

				<!--
					Field : Procedure Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/id
					Source: HS.SDA3.Procedure ExternalId
					Source: /Container/Procedures/Procedure/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="id-External"/>
				
				<!--
					Field : Procedure Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/code
					Source: HS.SDA3.Procedure Procedure
					Source: /Container/Procedures/Procedure/Procedure
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="Procedure" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/procedures/narrativeLinkPrefixes/procedureDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<!--
					Field : Procedure Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/statusCode
					Source: HS.SDA3.Procedure Status
					Source: /Container/Procedures/Procedure/Status
				-->
				<xsl:choose>
					<xsl:when test="string-length(Status/Code/text())">
						<statusCode>
							<xsl:attribute name="code">
								<xsl:value-of select="Status/Code/text()"/>
							</xsl:attribute>
						</statusCode>
					</xsl:when>
					<xsl:otherwise>
						<statusCode code="completed"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Procedure Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/effectiveTime/@value
					Source: HS.SDA3.Procedure ProcedureTime
					Source: /Container/Procedures/Procedure/ProcedureTime
				-->
				<xsl:apply-templates select="." mode="effectiveTime-procedure"/>
				
				<!--
					Field : Procedure Provider
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/performer
					Source: HS.SDA3.Procedure Clinician
					Source: /Container/Procedures/Procedure/Clinician
					StructuredMappingRef: performer-procedure
				-->
				<xsl:apply-templates select="Clinician" mode="performer-procedure"/>
				
				<!--
					Field : Procedure Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/author
					Source: HS.SDA3.Procedure EnteredBy
					Source: /Container/Procedures/Procedure/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					Field : Procedure Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/informant
					Source: HS.SDA3.Procedure EnteredAt
					Source: /Container/Procedures/Procedure/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!--
					Field : Procedure Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/entryRelationship
					Source: HS.SDA3.Procedure EncounterNumber
					Source: /Container/Procedures/Procedure/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : This links the Procedure to an encounter in the Encounters section.
				-->
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</procedure>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="procedures-NoData">
		<text><xsl:value-of select="$exportConfiguration/procedures/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-procedureEntry">
		<templateId root="{$ccda-ProcedureActivityProcedure}"/>
	</xsl:template>
</xsl:stylesheet>
