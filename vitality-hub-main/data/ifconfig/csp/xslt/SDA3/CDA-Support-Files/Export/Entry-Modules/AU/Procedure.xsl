<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
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
					<xsl:apply-templates select="Procedures/Procedure" mode="procedures-NarrativeDetail"/>
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
		<xsl:apply-templates select="Procedures/Procedure" mode="procedures-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="procedures-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<procedure classCode="PROC" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-procedureEntry"/>
				
				<!--
					Field : Procedure Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.11']/entry/procedure/id
					Source: HS.SDA3.Procedure ExternalId
					Source: /Container/Procedures/Procedure/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="id-External"/>
				
				<!--
					Field : Procedure Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.11']/entry/procedure/code
					Source: HS.SDA3.Procedure Procedure
					Source: /Container/Procedures/Procedure/Procedure
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="Procedure" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/procedures/narrativeLinkPrefixes/procedureDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/procedures/narrativeLinkPrefixes/procedureNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					Field : Procedure Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.11']/entry/procedure/effectiveTime/@value
					Source: HS.SDA3.Procedure ProcedureTime
					Source: /Container/Procedures/Procedure/ProcedureTime
				-->
				<xsl:apply-templates select="." mode="effectiveTime-procedure"/>
				
				<!-- Procedure body site/part -->
				<targetSiteCode nullFlavor="UNK"/>
				
				<!--
					Field : Procedure Provider
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.11']/entry/procedure/performer
					Source: HS.SDA3.Procedure Clinician
					Source: /Container/Procedures/Procedure/Clinician
					StructuredMappingRef: performer
				-->
				<xsl:apply-templates select="Clinician" mode="performer"/>
				
				<!--
					Field : Procedure Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.11']/entry/procedure/author
					Source: HS.SDA3.Procedure EnteredBy
					Source: /Container/Procedures/Procedure/EnteredBy
					StructuredMappingRef: assignedAuthor-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					Field : Procedure Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.11']/entry/procedure/informant
					Source: HS.SDA3.Procedure EnteredAt
					Source: /Container/Procedures/Procedure/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!--
					Field : Procedure Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.11']/entry/procedure/entryRelationship/encounter
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
		<xsl:if test="$hitsp-CDA-Procedure"><templateId root="{$hitsp-CDA-Procedure}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProcedureActivity"><templateId root="{$hl7-CCD-ProcedureActivity}"/></xsl:if>
		<xsl:if test="$ihe-PCC_CDASupplement-ProcedureEntry"><templateId root="{$ihe-PCC_CDASupplement-ProcedureEntry}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
