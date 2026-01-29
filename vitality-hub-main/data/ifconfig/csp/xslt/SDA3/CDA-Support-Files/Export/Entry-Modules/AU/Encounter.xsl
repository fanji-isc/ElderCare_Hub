<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:variable name="encompassingEncNum"><xsl:apply-templates select="." mode="encompassingEncounterNumber"/></xsl:variable>
	<xsl:variable name="encompassingEncOrg"><xsl:apply-templates select="." mode="encompassingEncounterOrganization"/></xsl:variable>
	<xsl:variable name="encompassingEncToEncounters"><xsl:apply-templates select="." mode="encompassingEncounterToEncounters"/></xsl:variable>
	
	<xsl:template match="*" mode="encounters-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Start Date/Time</th>
						<th>End Date/Time</th>
						<th>Encounter Type</th>
						<th>Admission Type</th>
						<th>Attending Clinicians</th>
						<th>Care Facility</th>
						<th>Care Department</th>
						<th>Encounter ID</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Encounter[not(contains('|G|S|', concat('|', EncounterType/text(), '|'))) and not(EncounterNumber/text()=$encompassingEncNum and HealthCareFacility/Organization/Code/text()=$encompassingEncOrg and not($encompassingEncToEncounters='1'))]" mode="encounters-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="encounters-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/encounters/narrativeLinkPrefixes/encounterNarrative/text(), $narrativeLinkSuffix)}">
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="EndTime" mode="narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="encounter-typeDescription-select"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates></td>
			<td ID="{concat($exportConfiguration/encounters/narrativeLinkPrefixes/encounterAdmission/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="AdmissionType" mode="descriptionOrCode"/></td>
			<td><xsl:apply-templates select="AttendingClinicians/CareProvider" mode="encounters-NarrativeDetail-AttendingClinician"/></td>
			<td><xsl:apply-templates select="HealthCareFacility/Organization" mode="descriptionOrCode"/></td>
			<td><xsl:apply-templates select="HealthCareFacility" mode="descriptionOrCode"/></td>
			<td><xsl:apply-templates select="EncounterNumber" mode="encounterNumber-converted"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="encounters-NarrativeDetail-AttendingClinician">
		<xsl:if test="position()>1"><br/></xsl:if>
		<xsl:apply-templates select="." mode="name-Person-Narrative"/>
	</xsl:template>
	
	<xsl:template match="*" mode="encounters-Entries">
		<xsl:apply-templates select="Encounter[not(contains('|G|S|', concat('|', EncounterType/text(), '|'))) and not(EncounterNumber/text()=$encompassingEncNum and HealthCareFacility/Organization/Code/text()=$encompassingEncOrg and not($encompassingEncToEncounters='1'))]" mode="encounters-EntryDetail"/>
	</xsl:template>

	<xsl:template match="*" mode="encounters-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry>
			<encounter classCode="ENC" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-encounterEntry"/>

				<!--
					Field : Encounter External Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/id[1]
					Source: HS.SDA3.Encounter ExternalId
					Source: /Container/Encounters/Encounter/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="id-External"/>
				
				<!--
					Field : Encounter Number
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/id[2]
					Source: HS.SDA3.Encounter EncounterNumber
					Source: /Container/Encounters/Encounter/EncounterNumber
					StructuredMappingRef: id-Encounter
				-->
				<xsl:apply-templates select="." mode="id-Encounter"/>
				
				<!-- Encounter Type -->
				<xsl:apply-templates select="." mode="encounter-type-select">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterNarrative/text(), $narrativeLinkSuffix)}"/></text>
				
				<!--
					Field : Encounter Start Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/effectiveTime/low/@value
					Source: HS.SDA3.Encounter FromTime
					Source: /Container/Encounters/Encounter/FromTime
				-->
				<!--
					Field : Encounter End Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/effectiveTime/high/@value
					Source: HS.SDA3.Encounter ToTime
					Source: /Container/Encounters/Encounter/ToTime
				-->
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
				
				<!-- Admission Type -->
				<xsl:apply-templates select="." mode="admission-type"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"></xsl:with-param></xsl:apply-templates>
				
				<!--
					Field : Encounter Attending Clinicians
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/performer
					Source: HS.SDA3.Encounter AttendingClinicians.CareProvider
					Source: /Container/Encounters/Encounter/AttendingClinicians/CareProvider
					StructuredMappingRef: performer
				-->
				<xsl:apply-templates select="AttendingClinicians/CareProvider" mode="performer"/>
				
				<!--
					Field : Encounter Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/author
					Source: HS.SDA3.Encounter EnteredBy
					Source: /Container/Encounters/Encounter/EnteredBy
					StructuredMappingRef: assignedAuthor-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					Field : Encounter Information Source Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/informant
					Source: HS.SDA3.Encounter ConsultingClinicians.CareProvider
					Source: /Container/Encounters/Encounter/ConsultingClinicians/CareProvider
					StructuredMappingRef: informant-encounterParticipant
				-->
				<xsl:apply-templates select="ConsultingClinicians/CareProvider[string-length(SDACodingStandard) and string-length(Code)]" mode="informant-encounterParticipant"/>
				
				<!--
					Field : Encounter Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/informant
					Source: HS.SDA3.Encounter EnteredAt
					Source: /Container/Encounters/Encounter/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!-- Admission Source (to be done later as participant[@typeCode='ORG']/code) -->
				<!-- Specs for CCD admission source are unclear -->
				
				<!-- Encounter location -->
				<xsl:apply-templates select="HealthCareFacility" mode="encounter-location"/>
			</encounter>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="encounters-NoData">
		<text><xsl:value-of select="$exportConfiguration/encounters/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<!--
		encounter-type-select determines whether to export CDA
		encounter type using SDA EncounterCodedType or EncounterType.
		This template calls encounter-type-coded or encounter-type,
		based on the available SDA data.
	-->
	<xsl:template match="Encounter" mode="encounter-type-select">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:choose>
			<xsl:when test="string-length(EncounterCodedType)">
				<xsl:apply-templates select="EncounterCodedType" mode="encounter-type-coded">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="encounter-type">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="EncounterCodedType" mode="encounter-type-coded">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<!--
			Field : Encounter Coded Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/code
			Source: HS.SDA3.Encounter EncounterCodedType
			Source: /Container/Encounters/Encounter/EncounterCodedType
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="encounter-type">
		<xsl:param name="narrativeLinkSuffix"/>
		<!--
			Field : Encompassing Encounter Type Code
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/code/@code
			Source: HS.SDA3.Encounter EncounterType
			Source: /Container/Encounters/Encounter/EncounterType
			Note  : SDA EncounterType maps to @code in the following manner:
					If EncounterType='I' then @code='IMP'
					If EncounterType='O' then @code='AMB'
					If EncounterType='E' then @code='EMER'
					If EncounterType='P' then @code='IMP'
					If EncounterType is any other non-blank value then @code='IMP'
		-->
		<!--
			Field : Encompassing Encounter Type Description
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/code/@displayName
			Source: HS.SDA3.Encounter EncounterType
			Source: /Container/Encounters/Encounter/EncounterType
			Note  : SDA EncounterType maps to @displayName in the following manner:
					If EncounterType='I' then @displayName='Inpatient'
					If EncounterType='O' then @displayName='Ambulatory'
					If EncounterType='E' then @displayName='Emergency'
					If EncounterType='P' then @displayName='Inpatient'
					If EncounterType is any other non-blank value then @displayName='Inpatient'
		-->
		<xsl:variable name="encounterTypeInformation">
			<EncounterType xmlns="">
				<SDACodingStandard><xsl:value-of select="$cpt4Name"/></SDACodingStandard>
				<Code>
					<xsl:choose>
						<xsl:when test="EncounterType/text() = 'E'">EMER</xsl:when>
						<xsl:when test="EncounterType/text() = 'I'">IMP</xsl:when>
						<xsl:when test="EncounterType/text() = 'O'">AMB</xsl:when>
						<xsl:otherwise>AMB</xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description>
					<xsl:choose>
						<xsl:when test="EncounterType/text() = 'E'">Emergency</xsl:when>
						<xsl:when test="EncounterType/text() = 'I'">Inpatient Encounter</xsl:when>
						<xsl:when test="EncounterType/text() = 'O'">Ambulatory</xsl:when>
						<xsl:otherwise>Ambulatory</xsl:otherwise>
					</xsl:choose>
				</Description>
			</EncounterType>
		</xsl:variable>
		
		<xsl:variable name="encounterType" select="exsl:node-set($encounterTypeInformation)/EncounterType"/>
		
		<xsl:apply-templates select="$encounterType" mode="generic-Coded">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)"/>
		</xsl:apply-templates>
	</xsl:template>

	<!--
		encounter-typeDescription-select determines whether to get the
		encounter type display value from SDA EncounterCodedType or
		EncounterType.  This template calls encounter-typeDescription-coded
		or encounter-typeDescription, based on the available SDA data.
	-->
	<xsl:template match="Encounter" mode="encounter-typeDescription-select">
		<xsl:param name="narrativeLinkSuffix"/>
		<xsl:choose>
			<xsl:when test="string-length(EncounterCodedType)">
				<xsl:apply-templates select="EncounterCodedType" mode="encounter-typeDescription-coded"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="EncounterType" mode="encounter-typeDescription">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="EncounterCodedType" mode="encounter-typeDescription-coded">
		<xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/>
	</xsl:template>
	
	<xsl:template match="*" mode="encounter-typeDescription">
		<xsl:choose>
			<xsl:when test="text() = 'E'">Emergency</xsl:when>
			<xsl:when test="text() = 'G'">Generated</xsl:when>
			<xsl:when test="text() = 'I'">Inpatient</xsl:when>
			<xsl:when test="text() = 'N'">Neo-natal</xsl:when>
			<xsl:when test="text() = 'O'">Outpatient</xsl:when>
			<xsl:when test="text() = 'S'">Silent</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="admission-type">
		<xsl:param name="narrativeLinkSuffix"/>
		<!--
			Field : Encounter Admission Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/priorityCode
			Source: HS.SDA3.Encounter AdmissionType
			Source: /Container/Encounters/Encounter/AdmissionType
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="AdmissionType" mode="generic-Coded">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterAdmission/text(), $narrativeLinkSuffix)"/>
			<xsl:with-param name="requiredCodeSystemOID" select="$nubcUB92OID"/>
			<xsl:with-param name="cdaElementName" select="'priorityCode'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="encounter-location">
		<xsl:if test="string-length(Code/text()) or string-length(Organization/Code/text())">
			<participant typeCode="LOC">
				<participantRole classCode="SDLOC">
					<!--
						Field : Encounter Location ID
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/participant/participantRole/id
						Source: HS.SDA3.Encounter HealthCareFacility
						Source: /Container/Encounters/Encounter/HealthCareFacility
						StructuredMappingRef: id-encounterLocation
					-->
					<xsl:apply-templates select="." mode="id-encounterLocation"/>
					
					<!--
						Field : Encounter Location Name
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/participant/participantRole/playingEntity/name/text()
						Source: HS.SDA3.Encounter HealthCareFacility.Organization.Description
						Source: /Container/Encounters/Encounter/HealthCareFacility/Organization/Description
						Note  : If Organization Description is not found, then Location Name
								is taken from the first found of Organization Code,
								HealthCareFacility Description, or HealthCareFacility Code.
					-->
					<playingEntity classCode="PLC">
						<name>
							<xsl:choose>
								<xsl:when test="string-length(Organization/Description/text())">
									<xsl:value-of select="Organization/Description/text()"/>
								</xsl:when>
								<xsl:when test="string-length(Organization/Code/text())">
									<xsl:value-of select="Organization/Code/text()"/>
								</xsl:when>
								<xsl:when test="string-length(Description/text())">
									<xsl:value-of select="Description/text()"/>
								</xsl:when>
								<xsl:when test="string-length(Code/text())">
									<xsl:value-of select="Code/text()"/>
								</xsl:when>
							</xsl:choose>
						</name>
					</playingEntity>
				</participantRole>
			</participant>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-encounterEntry">
		<xsl:if test="$hitsp-CDA-Encounters"><templateId root="{$hitsp-CDA-Encounters}"/></xsl:if>
		<xsl:if test="$hl7-CCD-EncounterActivity"><templateId root="{$hl7-CCD-EncounterActivity}"/></xsl:if>
		<xsl:if test="$ihe-PCC_CDASupplement-Encounters"><templateId root="{$ihe-PCC_CDASupplement-Encounters}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
