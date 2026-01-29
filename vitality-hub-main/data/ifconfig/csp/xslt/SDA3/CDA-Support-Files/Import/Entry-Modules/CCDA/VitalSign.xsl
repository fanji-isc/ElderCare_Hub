<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="VitalSign">
		<xsl:apply-templates select="hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')]" mode="VitalSignDetail">
			<xsl:with-param name="encounterNum"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="VitalSignDetail">
		<xsl:param name="encounterNum"/>
		
		<Observation>
			<!--
				Field : Vital Sign Encounter
				Target: HS.SDA3.Observation EncounterNumber
				Target: /Container/Observations/Observation/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Vital Sign and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber><xsl:value-of select="$encounterNum"/></EncounterNumber>
			
			<!--
				Field : Vital Sign Author
				Target: HS.SDA3.Observation EnteredBy
				Target: /Container/Observations/Observation/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/author
				StructuredMappingRef: EnteredByDetail
				Note  : If there is no author data at the CDA observation level
						then the CDA organizer level is used for the author data.
			-->
			<xsl:choose>
				<xsl:when test="hl7:author">
					<xsl:apply-templates select="." mode="EnteredBy"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="parent::node()/parent::node()" mode="EnteredBy"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Vital Sign Information Source
				Target: HS.SDA3.Observation EnteredAt
				Target: /Container/Observations/Observation/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/informant
				StructuredMappingRef: EnteredAt
				Note  : If there is no informant data at the CDA observation level
						then the CDA organizer level is used for the informant data.
			-->
			<xsl:choose>
				<xsl:when test="hl7:informant">
					<xsl:apply-templates select="." mode="EnteredAt"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="parent::node()/parent::node()" mode="EnteredAt"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Vital Sign Author Time
				Target: HS.SDA3.Observation EnteredOn
				Target: /Container/Observations/Observation/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/author/time/@value
				Note  : If there is no author data at the CDA observation level
						then the CDA organizer level is used for the author data.
			-->
			<xsl:choose>
				<xsl:when test="hl7:author">
					<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="parent::node()/parent::node()/hl7:author/hl7:time" mode="EnteredOn"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Vital Sign Id
				Target: HS.SDA3.Observation ExternalId
				Target: /Container/Observations/Observation/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!--
				Field : Vital Sign Clinician
				Target: HS.SDA3.Observation Clinician
				Target: /Container/Observations/Observation/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/performer
				StructuredMappingRef: Clinician
			-->
			<xsl:apply-templates select="hl7:performer" mode="Clinician"/>
			
			<!--
				Field : Vital Sign Observation Time
				Target: HS.SDA3.Observation ObservationTime
				Target: /Container/Observations/Observation/ObservationTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/effectiveTime
			-->
			<xsl:apply-templates select="hl7:effectiveTime" mode="ObservationTime"/>
			
			<xsl:variable name="observationValueUnits">
				<xsl:choose>
					<xsl:when test="hl7:value/@xsi:type = 'PQ' and string-length(hl7:value/@unit)">
						<xsl:value-of select="hl7:value/@unit"/>							
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<!--
				Field : Vital Sign Result Type (Vital Sign LOINC Code)
				Target: HS.SDA3.Observation ObservationCode
				Target: /Container/Observations/Observation/ObservationCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/code
				StructuredMappingRef: CodeTableDetail
			-->
			<!--
				Field : Vital Sign Result Value Units
				Target: HS.SDA3.Observation ObservationCode.ObservationValueUnits
				Target: /Container/Observations/Observation/ObservationCode/ObservationValueUnits
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/value/@unit
			-->
			<xsl:apply-templates select="hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'ObservationCode'"/>
				<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>
			
			<!--
				Field : Vital Sign Result Value
				Target: HS.SDA3.Observation ObservationValue
				Target: /Container/Observations/Observation/ObservationValue
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/value/@value
				Note  : If the Result Value Unit is not available then the
						Result Value is imported from CDA value/text() instead
						of value/@value.
			-->
			<xsl:apply-templates select="hl7:value" mode="ObservationValue"/>
			
			<!--
				Field : Vital Sign Comments
				Target: HS.SDA3.Observation Comments
				Target: /Container/Observations/Observation/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-VitalSign"/>
		</Observation>
	</xsl:template>
	
	<xsl:template match="*" mode="ObservationValue">
		<ObservationValue>
			<xsl:choose>
				<xsl:when test="@xsi:type = 'PQ'"><xsl:value-of select="@value"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="text()"/></xsl:otherwise>
			</xsl:choose>
		</ObservationValue>
	</xsl:template>

	<xsl:template match="*" mode="ObservationTime">
		<ObservationTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></ObservationTime>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry.
	-->
	<xsl:template match="*" mode="ImportCustom-VitalSign">
	</xsl:template>
</xsl:stylesheet>
