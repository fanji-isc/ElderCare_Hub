<?xml version="1.0" encoding="UTF-8"?>
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
			<td ID="{concat($exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="encounter-typeDescription-select"/></td>
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
					HS.SDA3.Encounter ExternalId
					HS.SDA3.Encounter EnteredAt
					CDA Section: Encounters
					CDA Field: External Id
					CDA XPath: entry/encounter/id[1]
				-->
				<xsl:apply-templates select="." mode="id-External"/>
				
				<!--
					HS.SDA3.Encounter EncounterNumber
					HS.SDA3.Encounter HealthCareFacility.Organization
					CDA Section: Encounters
					CDA Field: Encounter ID
					CDA XPath: entry/encounter/id[2]
				-->				
				<xsl:apply-templates select="." mode="id-Encounter"/>
				
				<!-- Encounter Type -->
				<xsl:apply-templates select="." mode="encounter-type-select">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterNarrative/text(), $narrativeLinkSuffix)}"/></text>
				
				<!--
					HS.SDA3.Encounter FromTime
					HS.SDA3.Encounter ToTime
					CDA Section: Encounters
					CDA Field: Encounter Date/Time
					CDA XPath: entry/encounter/effectiveTime
				-->				
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
				
				<!-- Admission Type -->
				<xsl:apply-templates select="." mode="admission-type"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"></xsl:with-param></xsl:apply-templates>
				
				<!--
					HS.SDA3.Encounter AttendingClinicians
					CDA Section: Encounters
					CDA Field: Encounter Provider
					CDA XPath: entry/encounter/performer
				-->				
				<xsl:apply-templates select="AttendingClinicians/CareProvider" mode="performer"/>
				
				<!--
					HS.SDA3.Encounter EnteredBy
					CDA Section: Encounters
					CDA Field: Author
					CDA XPath: entry/encounter/author
				-->				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					HS.SDA3.Encounter ConsultingClinicians
					CDA Section: Encounters
					CDA Field: Information Source
					CDA XPath: entry/encounter/informant
				-->				
				<xsl:apply-templates select="ConsultingClinicians/CareProvider[string-length(SDACodingStandard) and string-length(Code)]" mode="informant-encounterParticipant"/>
				
				<!--
					HS.SDA3.Encounter EnteredAt
					CDA Section: Encounters
					CDA Field: Information Source
					CDA XPath: entry/encounter/informant
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
		
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="encounter-type">
		<xsl:param name="narrativeLinkSuffix"/>
		<!--
			HS.SDA3.Encounter EncounterType
			CDA Section: Encounters
			CDA Field: Encounter Type
			CDA XPath: entry/encounter/code
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
		encounter type display value from EncounterCodedType or from
		EncounterType.  This template calls encounter-typeDescription-coded
		or encounter-typeDescription, based on the available SDA data.
	-->
	<xsl:template match="Encounter" mode="encounter-typeDescription-select">
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
				HS.SDA3.Encounter AdmissionType
				CDA Section: Encounters
				CDA Field: Admission Type
				CDA XPath: entry/encounter/priorityCode
			-->		
			<xsl:apply-templates select="AdmissionType" mode="generic-Coded">
				<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterAdmission/text(), $narrativeLinkSuffix)"/>
				<xsl:with-param name="requiredCodeSystemOID" select="$nubcUB92OID"/>
				<xsl:with-param name="cdaElementName" select="'priorityCode'"/>
			</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="encounter-location">
		<!--
			HS.SDA3.Encounter HealthCareFacility
			CDA Section: Encounters
			CDA Field: Facility Location
			CDA XPath: entry/encounter/participant[@typeCode='LOC']
		-->	
		<xsl:if test="string-length(Code/text()) or string-length(Organization/Code/text())">
			<participant typeCode="LOC">
				<participantRole classCode="SDLOC">
					<xsl:apply-templates select="." mode="id-encounterLocation"/>
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
