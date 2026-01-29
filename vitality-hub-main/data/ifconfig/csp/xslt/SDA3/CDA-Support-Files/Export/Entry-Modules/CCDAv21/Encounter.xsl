<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl">
  <!-- AlsoInclude: AuthorParticipation.xsl Condition.xsl -->
	
	<xsl:key name="diagnosesByEncounter" match="/Container/Diagnoses/Diagnosis" use="EncounterNumber"/>
  <xsl:key name="diagnosesByEncounter" match="/Container" use="'NEVER_MATCH_THIS!'"/>
  <!-- Second line in the above key is to ensure that the "key table" is populated
       with at least one row, but we never want to retrieve that row. -->
  
	<xsl:template match="*" mode="eE-encounters-Narrative">
		<xsl:param name="encounterList"/>
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Start Date/Time</th>
						<th>End Date/Time</th>
						<th>Encounter Type</th>
						<th>Admission Type</th>
						<xsl:if test="$documentPatientSetting='Ambulatory'"><th>Encounter Diagnosis</th></xsl:if>
						<th>Attending Clinicians</th>
						<th>Care Facility</th>
						<th>Care Department</th>
						<th>Encounter ID</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="$encounterList" mode="eE-encounters-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="Encounter" mode="eE-encounters-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/encounters/narrativeLinkPrefixes/encounterNarrative/text(), $narrativeLinkSuffix)}">
			<td><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="EndTime" mode="fn-narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="eE-encounter-typeDescription-select"/></td>
			<td ID="{concat($exportConfiguration/encounters/narrativeLinkPrefixes/encounterAdmission/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="AdmissionType" mode="fn-descriptionOrCode"/></td>
			<xsl:if test="$documentPatientSetting='Ambulatory'">
				<td>
					<xsl:apply-templates select="." mode="eE-encounters-NarrativeDetail-diagnoses">
						<xsl:with-param name="encounterPosition" select="position()"/>
						<xsl:with-param name="encounterNumber" select="EncounterNumber/text()"/>
					</xsl:apply-templates>
				</td>
			</xsl:if>
			<td><xsl:apply-templates select="AttendingClinicians/CareProvider" mode="eE-encounters-NarrativeDetail-AttendingClinician"/></td>
			<td>
				<xsl:variable name="facilityName"><xsl:apply-templates select="HealthCareFacility/Organization" mode="fn-descriptionOrCode"/></xsl:variable>
				<xsl:variable name="facilityAddress"><xsl:apply-templates select="HealthCareFacility/Organization/Address" mode="fn-addressSingleLine"/></xsl:variable>
				<xsl:variable name="hasAddress" select="string-length($facilityAddress) > 0"/>
				<xsl:choose>
					<xsl:when test="string-length($facilityName)">
						<xsl:choose>
							<xsl:when test="$hasAddress">
								<xsl:value-of select="concat($facilityName,', ',$facilityAddress)"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="$facilityName"/></xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$hasAddress">
							<xsl:value-of select="$facilityAddress"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td><xsl:apply-templates select="HealthCareFacility" mode="fn-descriptionOrCode"/></td>
			<td><xsl:apply-templates select="EncounterNumber" mode="fn-encounterNumber-converted"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="CareProvider" mode="eE-encounters-NarrativeDetail-AttendingClinician">
		<xsl:if test="position()>1"><br/></xsl:if>
		<xsl:apply-templates select="." mode="fn-name-Person-Narrative"/>
	</xsl:template>
	
	<xsl:template match="Encounter" mode="eE-encounters-NarrativeDetail-diagnoses">
		<xsl:param name="encounterPosition"/>
		<xsl:param name="encounterNumber"/>
		
		<xsl:apply-templates select="key('diagnosesByEncounter',$encounterNumber)[string-length(Diagnosis/Description/text())]" mode="eE-encounters-NarrativeDetail-diagnosis">
			<xsl:with-param name="encounterPosition" select="$encounterPosition"/>
		</xsl:apply-templates>
		<!-- Loop over all the "outer" Diagnosis elements having a Description in their "inner" Diagnosis element
			   and display that Description -->
		<xsl:for-each select="key('diagnosesByEncounter',$encounterNumber)[string-length(Diagnosis/Description/text())]">	
			<xsl:if test="position()>1"><br/></xsl:if>
			<content ID="{concat($exportConfiguration/encounterDiagnoses/narrativeLinkPrefixes/diagnosisDescription/text(),$encounterPosition,'-',position())}">
				<xsl:value-of select="Description"/>
			</content>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="*" mode="eE-encounters-Entries">
		<xsl:param name="encounterList"/>
		<xsl:apply-templates select="$encounterList" mode="eE-encounters-EntryDetail"/>
	</xsl:template>

	<xsl:template match="Encounter" mode="eE-encounters-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry>
			<encounter classCode="ENC" moodCode="EVN">
				<xsl:call-template name="eE-templateIds-encounterEntry"/>

				<!--
					Field : Encounter External Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/id[1]
					Source: HS.SDA3.Encounter ExternalId
					Source: /Container/Encounters/Encounter/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="fn-id-External"/>
				
				<!--
					Field : Encounter Number
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/id[2]
					Source: HS.SDA3.Encounter EncounterNumber
					Source: /Container/Encounters/Encounter/EncounterNumber
					StructuredMappingRef: id-Encounter
				-->
				<xsl:apply-templates select="." mode="fn-id-Encounter"/>
				
				<!-- Encounter Type -->
				<xsl:apply-templates select="." mode="eE-encounter-type-select">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterNarrative/text(), $narrativeLinkSuffix)}"/></text>
				
				<!--
					Field : Encounter Start Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/effectiveTime/low/@value
					Source: HS.SDA3.Encounter FromTime
					Source: /Container/Encounters/Encounter/FromTime
				-->
				<!--
					Field : Encounter End Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/effectiveTime/high/@value
					Source: HS.SDA3.Encounter ToTime
					Source: /Container/Encounters/Encounter/ToTime
				-->
				<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>
				
				<!-- Admission Type -->
				<xsl:apply-templates select="." mode="eE-admission-type">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
				
				<!--
					Field : Encounter Attending Clinicians
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/performer
					Source: HS.SDA3.Encounter AttendingClinicians.CareProvider
					Source: /Container/Encounters/Encounter/AttendingClinicians/CareProvider
					StructuredMappingRef: performer
				-->
				<xsl:apply-templates select="AttendingClinicians/CareProvider" mode="fn-performer"/>
				
				<!--
					Field : Encounter Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/author
					Source: HS.SDA3.Encounter EnteredBy
					Source: /Container/Encounters/Encounter/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				
				<!--
					Field : Encounter Information Source Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/informant
					Source: HS.SDA3.Encounter ConsultingClinicians.CareProvider
					Source: /Container/Encounters/Encounter/ConsultingClinicians/CareProvider
					StructuredMappingRef: informant-encounterParticipant
				-->
				<xsl:apply-templates select="ConsultingClinicians/CareProvider[string-length(SDACodingStandard) and string-length(Code)]" mode="fn-informant-encounterParticipant"/>

				<!--
					Field : Encounter Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/informant
					Source: HS.SDA3.Encounter EnteredAt
					Source: /Container/Encounters/Encounter/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<!-- Admission Source (to be done later as participant[@typeCode='ORG']/code) -->
				<!-- Specs for CCD admission source are unclear -->
				
				<!-- Encounter location, also used by Location in PlanOfCare.xsl -->
				<xsl:apply-templates select="HealthCareFacility" mode="eE-encounter-location"/>

				<!--OfficeContact (EnteredAt and EnteredBy) is mapped to Encounter/Participant-->
				<xsl:apply-templates select="." mode="eE-encounter-officeContact"/>
				
				<xsl:if test="$documentPatientSetting='Ambulatory'">
					<xsl:apply-templates select="." mode="eE-encounter-diagnoses">
						<xsl:with-param name="encounterPosition" select="position()"/>
						<xsl:with-param name="encounterNumber" select="EncounterNumber/text()"/>
					</xsl:apply-templates>
				</xsl:if>
			</encounter>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="eE-encounters-NoData">
		<text><xsl:value-of select="$exportConfiguration/encounters/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="Encounter" mode="eE-encounter-type-select">
		<xsl:param name="narrativeLinkSuffix"/>
		<!--
		encounter-type-select determines whether to export CDA
		encounter type using SDA EncounterCodedType or EncounterType,
		preferring the former. When EncounterCodedType is present,
		produce a code element for it. If not, invoke encounter-type,
		and make the best code element we can from EncounterType.
		-->
		<xsl:choose>
			<xsl:when test="string-length(EncounterCodedType)">
				<!--
			Field : Encounter Coded Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/code
			Source: HS.SDA3.Encounter EncounterCodedType
			Source: /Container/Encounters/Encounter/EncounterCodedType
			StructuredMappingRef: generic-Coded
		-->
				<xsl:apply-templates select="EncounterCodedType" mode="fn-generic-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="eE-encounter-type">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Encounter" mode="eE-encounter-type">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<!--
			Field : Encompassing Encounter Type Code
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/code/@code
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
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/code/@displayName
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
		
		<xsl:apply-templates select="exsl:node-set($encounterTypeInformation)/EncounterType" mode="fn-generic-Coded">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Encounter" mode="eE-encounter-typeDescription-select">
		<!--
		encounter-typeDescription-select determines whether to get the
		encounter type display value from EncounterCodedType or from
		EncounterType.  This template calls encounter-typeDescription-coded
		or encounter-typeDescription, based on the available SDA data.
		-->
		<xsl:choose>
			<xsl:when test="string-length(EncounterCodedType)">
				<xsl:apply-templates select="EncounterCodedType" mode="fn-originalTextOrDescriptionOrCode"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="EncounterType = 'E'">Emergency</xsl:when>
					<xsl:when test="EncounterType = 'G'">Generated</xsl:when>
					<xsl:when test="EncounterType = 'I'">Inpatient</xsl:when>
					<xsl:when test="EncounterType = 'N'">Neo-natal</xsl:when>
					<xsl:when test="EncounterType = 'O'">Outpatient</xsl:when>
					<xsl:when test="EncounterType = 'S'">Silent</xsl:when>
					<xsl:when test="EncounterType">Unknown</xsl:when>
					<!-- Past behavior was to only put out Unknown if there was an EncounterType element.
						   ToDo: decide if we want to put out anything when there is no EncounterType at all. -->
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Encounter" mode="eE-admission-type">
		<xsl:param name="narrativeLinkSuffix"/>
		
			<!--
				Field : Encounter Admission Type
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/priorityCode
				Source: HS.SDA3.Encounter AdmissionType
				Source: /Container/Encounters/Encounter/AdmissionType
				StructuredMappingRef: generic-Coded
			-->
			<xsl:apply-templates select="AdmissionType" mode="fn-generic-Coded">
				<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterAdmission/text(), $narrativeLinkSuffix)"/>
				<xsl:with-param name="requiredCodeSystemOID" select="$nubcUB92OID"/>
				<xsl:with-param name="cdaElementName" select="'priorityCode'"/>
			</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="HealthCareFacility | Location | ReferredToOrganization" mode="eE-encounter-location">
		<xsl:if test="string-length(Code/text()) or string-length(Organization/Code/text())">
			<participant typeCode="LOC">
				<participantRole classCode="SDLOC">
					<xsl:call-template name="eE-templateIds-encounterLocation"/>
					
					<!--
						Field : Encounter Location ID
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/id
						Source: HS.SDA3.Encounter HealthCareFacility
						Source: /Container/Encounters/Encounter/HealthCareFacility
						StructuredMappingRef: id-encounterLocation
					-->
					<xsl:apply-templates select="." mode="fn-id-encounterLocation"/>
					
					<xsl:variable name="locationTypeCode">
						<xsl:choose>
							<xsl:when test="LocationType/text()='ER'">1108-0</xsl:when>
							<xsl:when test="LocationType/text()='CLINIC'">1160-1</xsl:when>
							<xsl:when test="LocationType/text()='DEPARTMENT'">1010-8</xsl:when>
							<xsl:when test="LocationType/text()='WARD'">1160-1</xsl:when>
							<xsl:when test="LocationType/text()='OTHER'">1117-1</xsl:when>
							<xsl:when test="../EncounterType/text()='E'">1108-0</xsl:when>
							<xsl:when test="../EncounterType/text()='I'">1160-1</xsl:when>
							<xsl:when test="../EncounterType/text()='O'">1160-1</xsl:when>
							<xsl:when test="../EncounterType/text()='P'">1108-0</xsl:when>
							<xsl:otherwise>1117-1</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="locationTypeDesc">
						<xsl:choose>
							<xsl:when test="$locationTypeCode='1108-0'">Emergency Room</xsl:when>
							<xsl:when test="$locationTypeCode='1160-1'">Urgent Care Center</xsl:when>
							<xsl:when test="$locationTypeCode='1117-1'">Family Medicine Clinic</xsl:when>
							<xsl:when test="$locationTypeCode='1010-8'">General Laboratory</xsl:when>
							<xsl:otherwise>Urgent Care Center</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<!--
						Field : Encounter Location Type Code
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/code/@code
						Source: HS.SDA3.Encounter HealthCareFacility.LocationType
						Source: /Container/Encounters/Encounter/HealthCareFacility/LocationType
					-->
					<!--
						Field : Encounter Location Type Description
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/code/@displayName
						Source: HS.SDA3.Encounter HealthCareFacility.LocationType
						Source: /Container/Encounters/Encounter/HealthCareFacility/LocationType
					-->
					<code code="{$locationTypeCode}" codeSystem="{$healthcareServiceLocationOID}" codeSystemName="{$healthcareServiceLocationName}" displayName="{$locationTypeDesc}"/>
					
					<!--
						Field : Encounter Location Name
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/playingEntity/name/text()
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

	<xsl:template match="Encounter" mode="eE-encounter-officeContact">

		<xsl:variable name="hasName" select="EnteredBy/Description"/>
		<xsl:variable name="hasAddress" select="EnteredAt/Address"/>
		<xsl:variable name="hasContactInfo" select="EnteredAt/ContactInfo"/>

		<xsl:if test="$hasName or $hasAddress or $hasContactInfo">
			<participant typeCode="ENT">
				<participantRole classCode="SDLOC">
					<xsl:call-template name="eE-templateIds-encounterLocation"/>					
				
					<!--
						Field : Encounter Location Type Code
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/code/@code
						Note: Use 1184-1 (Hard-coded)
					-->
					<!--
						Field : Encounter Location Type Description
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/code/@displayName
						Note: Use Administrative Area (Hard-coded)
					-->
					<code code="1184-1" codeSystem="{$healthcareServiceLocationOID}" codeSystemName="{$healthcareServiceLocationName}" displayName="Administrative Area"/>

					<!--
						Field : Encounter Address
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/addr/
						Source: HS.SDA3.CodeTableDetail.OrganizationA Address
						Source: /Container/Encounters/Encounter/EnteredAt/Address
					-->
					<xsl:if test="$hasAddress">
						<xsl:apply-templates select="EnteredAt" mode="fn-address"/>
					</xsl:if>

					<!--
						Field : Encounter ContactInfo
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/telecom/
						Source: HS.SDA3.CodeTableDetail.OrganizationA ContactInfo
						Source: /Container/Encounters/Encounter/EnteredAt/ContactInfo
					-->
					<xsl:if test="$hasContactInfo">
						<xsl:apply-templates select="EnteredAt" mode="fn-telecom"/>	
					</xsl:if>				
					
					<!--
						Field : Encounter EnteredBy Description
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/playingEntity/name/text()
						Source: HS.SDA3.CodeTableDetail.OrganizationA Description
						Source: /Container/Encounters/Encounter/EnteredBy/Description
					-->
					<xsl:if test="$hasName">
						<playingEntity classCode="PLC">
							<name>
								<xsl:value-of select="normalize-space(EnteredBy/Description/text())"/>
							</name>
						</playingEntity>
					</xsl:if>
				</participantRole>
			</participant>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template match="Encounter" mode="eE-encounter-diagnoses">
		<xsl:param name="encounterPosition"/>
		<xsl:param name="encounterNumber"/>
		
		<xsl:for-each select="key('diagnosesByEncounter',$encounterNumber)">
			<entryRelationship typeCode="SUBJ">
				<act classCode="ACT" moodCode="EVN">
					<xsl:call-template name="eE-templateIds-encounterDiagnosis"/>
					<id nullFlavor="UNK"/>
					<code code="29308-4" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Diagnosis"/>
					<statusCode code="active"/>
					<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>
					<!-- Template observation-Diagnosis is located in Condition.xsl -->
					<xsl:apply-templates select="." mode="eCn-observation-Diagnosis">
						<xsl:with-param name="narrativeLinkCategory" select="'encounterDiagnoses'"/>
						<xsl:with-param name="narrativeLinkSuffix" select="concat($encounterPosition, '-', position())"/>
					</xsl:apply-templates>
				</act>
			</entryRelationship>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="EncounterType" mode="eE-encounter-typeDescription">
		<!-- UNUSED -->
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
	
	<xsl:template match="Diagnosis" mode="eE-encounters-NarrativeDetail-diagnosis">
		<!-- UNUSED -->
		<xsl:param name="encounterPosition"/>
		
		<xsl:if test="position()>1"><br/></xsl:if>
		<content ID="{concat($exportConfiguration/encounterDiagnoses/narrativeLinkPrefixes/diagnosisDescription/text(),$encounterPosition,'-',position())}">
			<xsl:apply-templates select="Diagnosis" mode="fn-descriptionOrCode"/>
		</content>
	</xsl:template>
	
	<xsl:template match="EncounterCodedType" mode="eE-encounter-typeDescription-coded">
		<!-- UNUSED -->
		<xsl:apply-templates select="." mode="fn-originalTextOrDescriptionOrCode"/>
	</xsl:template>
	
	<xsl:template match="EncounterCodedType" mode="eE-encounter-type-coded">
		<xsl:param name="narrativeLinkSuffix"/>
		<!-- UNUSED -->
		
		<!--
			Field : Encounter Coded Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/code
			Source: HS.SDA3.Encounter EncounterCodedType
			Source: /Container/Encounters/Encounter/EncounterCodedType
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="fn-generic-Coded">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/encounters/narrativeLinkPrefixes/encounterDescription/text(), $narrativeLinkSuffix)"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eE-templateIds-encounterEntry">
		<templateId root="{$ccda-EncounterActivity}"/>
		<templateId root="{$ccda-EncounterActivity}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eE-templateIds-encounterDiagnosis">
		<templateId root="{$ccda-EncounterDiagnosis}"/>
		<templateId root="{$ccda-EncounterDiagnosis}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eE-templateIds-encounterLocation">
		<templateId root="{$ccda-ServiceDeliveryLocation}"/>
		<templateId root="{$ccda-ServiceDeliveryLocation}" extension="2015-08-01"/>
	</xsl:template>
</xsl:stylesheet>
