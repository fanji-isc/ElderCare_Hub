<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="FunctionalStatus">
		<Problem>
			<!--
				Field : Functional Status Encounter
				Target: HS.SDA3.Problem EncounterNumber
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Functional Status and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>
			
			<!--
				Field : Functional Status Author
				Target: HS.SDA3.Problem EnteredBy
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!--
				Field : Functional Status Information Source
				Target: HS.SDA3.Problem EnteredAt
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!--
				Field : Functional Status Author Time
				Target: HS.SDA3.Problem EnteredOn
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!--
				Field : Functional Status Problem Concern Act Id
				Target: HS.SDA3.Problem ExternalId
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/id
				StructuredMappingRef: ExternalId
			-->
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!--
				Field : Functional Status Start Date/Time
				Target: HS.SDA3.Problem FromTime
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/effectiveTime/low/@value
			-->
			<!--
				Field : Functional Status End Date/Time
				Target: HS.SDA3.Problem ToTime
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/effectiveTime/high/@value
			-->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
			
			<!-- Functional Status Problem Details -->
			<xsl:apply-templates select="hl7:text" mode="FunctionalStatusProblemDetails"/>
			
			<!--
				Field : Functional Status Code
				Target: HS.SDA3.Problem Problem
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/Problem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/value
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:value" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Problem'"/>
			</xsl:apply-templates>
			
			<!--
				Field : Functional Status Type
				Target: HS.SDA3.Problem Category
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/Category
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/code
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Category'"/>
			</xsl:apply-templates>
			
			<!--
				Field : Functional Status Treating Provider
				Target: HS.SDA3.Problem Clinician
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/performer
				StructuredMappingRef: Clinician
				Note  : SDA Functional Status Treating Provider is imported either from
						CDA entry/act/performer or entry/act/entryRelationship/observation/performer.
						A CDA Functional Status entry will have either one or the other.
			-->
			<!--
				Field : Functional Status Treating Provider
				Target: HS.SDA3.Problem Clinician
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/performer
				StructuredMappingRef: Clinician
				Note  : SDA Functional Status Treating Provider is imported either from
						CDA entry/act/performer or entry/act/entryRelationship/observation/performer.
						A CDA Functional Status entry will have either one or the other.
			-->
			<xsl:apply-templates select="hl7:performer | hl7:entryRelationship/hl7:observation/hl7:performer" mode="Clinician"/>
			
			<!--
				Field : Functional Status Comments
				Target: HS.SDA3.Problem Comments
				Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-FunctionalStatus"/>
		</Problem>
	</xsl:template>

	<xsl:template match="*" mode="IdentificationTime">
		<xsl:choose>
			<xsl:when test="@value"><IdentificationTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></IdentificationTime></xsl:when>
			<xsl:when test="hl7:low/@value"><IdentificationTime><xsl:value-of select="isc:evaluate('xmltimestamp', hl7:low/@value)"/></IdentificationTime></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="FunctionalStatusProblemDetails">
		<!--
			Field : Functional Status Name
			Target: HS.SDA3.Problem ProblemDetails
			Target: /Container/Problems/Problem[Category/Code='248536006' or Category/Code='373930000']/ProblemDetails
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.14']/entry/act/entryRelationship/observation/text
		-->
		<ProblemDetails><xsl:apply-templates select="." mode="TextValue"/></ProblemDetails>
	</xsl:template>
		
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-FunctionalStatus">
	</xsl:template>
</xsl:stylesheet>
