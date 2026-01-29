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
					HS.SDA3.Procedure ExternalId
					CDA Section: Procedures and Interventions
					CDA Field: Id
					CDA XPath: entry/procedure/id
				-->
				<xsl:apply-templates select="." mode="id-External"/>

				<!--
					HS.SDA3.Procedure Procedure
					CDA Section: Procedures and Interventions
					CDA Field: Procedure Type
					CDA XPath: entry/procedure/code
				-->
				<xsl:apply-templates select="Procedure" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/procedures/narrativeLinkPrefixes/procedureDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/procedures/narrativeLinkPrefixes/procedureNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					HS.SDA3.Procedure ProcedureTime
					CDA Section: Procedures and Interventions
					CDA Field: Procedure Date/Time
					CDA XPath: entry/procedure/effectiveTime
				-->				
				<xsl:apply-templates select="." mode="effectiveTime-procedure"/>
				
				<!-- Procedure body site/part -->
				<targetSiteCode nullFlavor="UNK"/>
				
				<!--
					HS.SDA3.Procedure Clinician
					CDA Section: Procedures and Interventions
					CDA Field: Procedure Provider
					CDA XPath: entry/procedure/performer
				-->				
				<xsl:apply-templates select="Clinician" mode="performer"/>
				
				<!--
					HS.SDA3.Procedure EnteredBy
					CDA Section: Procedures and Interventions
					CDA Field: Author
					CDA XPath: entry/procedure/author
				-->				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					HS.SDA3.Procedure EnteredAt
					CDA Section: Procedures and Interventions
					CDA Field: Information Source
					CDA XPath: entry/procedure/informant
				-->				
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!-- 
					HS.SDA3.Procedure EncounterNumber
					CDA Section: Procedures and Interventions
					CDA Field: Encounter
					CDA XPath: entry/procedure/entryRelationship/encounter
					
					This links the Procedure to an encounter in the Encounters section.
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
