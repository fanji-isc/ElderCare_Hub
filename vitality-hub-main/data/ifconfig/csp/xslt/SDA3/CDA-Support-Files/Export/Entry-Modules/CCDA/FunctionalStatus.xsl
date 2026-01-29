<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="functionalStatus-Narrative">
		
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Functional or Cognitive Finding</th>
						<th>Observation</th>
						<th>Observation Details</th>
						<th>Onset Date</th>
						<th>Resolution Date</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Problems/Problem[Category/Code/text()='248536006' or Category/Code/text()='373930000']" mode="functionalStatus-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="functionalStatus-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<xsl:choose>
			<xsl:when test="Category/Code/text()='248536006'">
				<tr ID="{concat($exportConfiguration/functionalStatus/narrativeLinkPrefixes/functionalStatusNarrative/text(), $narrativeLinkSuffix)}">
					<td>Finding of functional performance and activity</td>
					<td><xsl:apply-templates select="Problem" mode="descriptionOrCode"/></td>
					<td ID="{concat($exportConfiguration/functionalStatus/narrativeLinkPrefixes/functionalStatusDescription/text(), $narrativeLinkSuffix)}"><xsl:value-of select="ProblemDetails/text()"/></td>
					<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
					<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
					<td ID="{concat($exportConfiguration/functionalStatus/narrativeLinkPrefixes/functionalStatusComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments"/></td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<tr ID="{concat($exportConfiguration/cognitiveStatus/narrativeLinkPrefixes/cognitiveStatusNarrative/text(), $narrativeLinkSuffix)}">
					<td>Cognitive function finding</td>
					<td><xsl:apply-templates select="Problem" mode="descriptionOrCode"/></td>
					<td ID="{concat($exportConfiguration/cognitiveStatus/narrativeLinkPrefixes/cognitiveStatusDescription/text(), $narrativeLinkSuffix)}"><xsl:value-of select="ProblemDetails/text()"/></td>
					<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
					<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
					<td ID="{concat($exportConfiguration/cognitiveStatus/narrativeLinkPrefixes/cognitiveStatusComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments"/></td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="functionalStatus-Entries">
		<xsl:apply-templates select="Problems/Problem[Category/Code/text()='248536006' or Category/Code/text()='373930000']" mode="functionalStatus-Entry"/>
	</xsl:template>

	<xsl:template match="*" mode="functionalStatus-Entry">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<xsl:choose>
			<xsl:when test="Category/Code/text()='248536006'">
				<xsl:apply-templates select="." mode="functionalStatus-EntryDetail">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="cognitiveStatus-EntryDetail">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="functionalStatus-EntryDetail">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:apply-templates select="." mode="functionalStatus-observation-Problem">
			<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="functionalStatus-NoData">
		<text><xsl:value-of select="$exportConfiguration/functionalStatus/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="cognitiveStatus-EntryDetail">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:apply-templates select="." mode="cognitiveStatus-observation-Problem">
			<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="functionalStatus-observation-Problem">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-problemObservation"/>
				<xsl:apply-templates select="." mode="templateIds-functionalStatusProblemObservation"/>
				
				<id nullFlavor="NI"/>
				
				<!--
					Field : Functional Status Problem Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/code
					Source: HS.SDA3.Problem Category
					Source: /Container/Problems/Problem/Category
					StructuredMappingRef: problem-ProblemType
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<xsl:choose>
					<xsl:when test="Category">
						<xsl:apply-templates select="Category" mode="problem-ProblemType"/>
					</xsl:when>
					<xsl:otherwise><code nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Functional Status Problem Name
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/text
					Source: HS.SDA3.Problem ProblemDetails
					Source: /Container/Problems/Problem/ProblemDetails
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<text><reference value="{concat('#', $exportConfiguration/functionalStatus/narrativeLinkPrefixes/functionalStatusDescription/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					Field : Functional Status Problem Start Date
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/effectiveTime/low/@value
					Source: HS.SDA3.Problem FromTime
					Source: /Container/Problems/Problem/FromTime
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<!--
					Field : Functional Status Problem End Date
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/effectiveTime/high/@value
					Source: HS.SDA3.Problem ToTime
					Source: /Container/Problems/Problem/ToTime
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<xsl:apply-templates select="." mode="effectiveTime-FromTo">
					<xsl:with-param name="includeHighTime" select="string-length(ToTime/text())"/>
				</xsl:apply-templates>
				
				<!--
					Field : Functional Status Problem Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/value
					Source: HS.SDA3.Problem Problem
					Source: /Container/Problems/Problem/Problem
					StructuredMappingRef: value-Coded
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<xsl:apply-templates select="Problem" mode="value-Coded">
					<xsl:with-param name="xsiType">CD</xsl:with-param>
					<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$snomedOID"/></xsl:with-param>
				</xsl:apply-templates>
				
				<!--
					Field : Functional Status Problem Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/performer
					Source: HS.SDA3.Problem Clinician
					Source: /Container/Problems/Problem/Clinician
					StructuredMappingRef: performer
					Note  : Problem Clinician is exported to entry/act/performer,
							but import looks at both entry/act/performer and
							entry/act/entryRelationship/observation/performer.
							
							An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<xsl:apply-templates select="Clinician" mode="performer"/>
				
				<!--
					Field : Functional Status Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/author
					Source: HS.SDA3.Problem EnteredBy
					Source: /Container/Problems/Problem/EnteredBy
					StructuredMappingRef: author-Human
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					Field : Functional Status Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/informant
					Source: HS.SDA3.Problem EnteredAt
					Source: /Container/Problems/Problem/EnteredAt
					StructuredMappingRef: informant
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!--
					Field : Functional Status Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.Problem Comments
					Source: /Container/Problems/Problem/Comments
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/functionalStatus/narrativeLinkPrefixes/functionalStatusComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<!--
					Field : Functional Status Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship
					Source: HS.SDA3.Problem EncounterNumber
					Source: /Container/Problems/Problem/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : An SDA Problem is exported to the Functional Status section
							when Problem Category/Code equals 248536006 or 373930000.
				-->
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</observation>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="cognitiveStatus-observation-Problem">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-problemObservation"/>
				<xsl:apply-templates select="." mode="templateIds-cognitiveStatusProblemObservation"/>
				
				<id nullFlavor="NI"/>
				
				<xsl:choose>
					<xsl:when test="Category">
						<xsl:apply-templates select="Category" mode="problem-ProblemType"/>
					</xsl:when>
					<xsl:otherwise><code nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
				
				<text><reference value="{concat('#', $exportConfiguration/cognitiveStatus/narrativeLinkPrefixes/cognitiveStatusDescription/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="." mode="effectiveTime-FromTo">
					<xsl:with-param name="includeHighTime" select="string-length(ToTime/text())"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="Problem" mode="value-Coded">
					<xsl:with-param name="xsiType">CD</xsl:with-param>
					<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$snomedOID"/></xsl:with-param>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="Clinician" mode="performer"/>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/cognitiveStatus/narrativeLinkPrefixes/cognitiveStatusComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-functionalStatusEntry">
		<templateId root="{$ccda-ProblemConcernAct}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-cognitiveStatusEntry">
		<templateId root="{$ccda-ProblemConcernAct}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-problemObservation">
		<templateId root="{$ccda-ProblemObservation}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-functionalStatusProblemObservation">
		<templateId root="{$ccda-FunctionalStatusProblemObservation}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-cognitiveStatusProblemObservation">
		<templateId root="{$ccda-CognitiveStatusProblemObservation}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-problemStatus">
		<templateId root="{$ccda-ProblemStatus}"/>
	</xsl:template>
</xsl:stylesheet>
