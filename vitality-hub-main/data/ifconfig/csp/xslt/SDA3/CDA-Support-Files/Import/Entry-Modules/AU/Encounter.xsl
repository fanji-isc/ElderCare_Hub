<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 sdtc xsi exsl">

	<!-- DefaultEncounter imports the CDA encompassingEncounter. -->
	<xsl:template match="*" mode="DefaultEncounter">
		<!--
			$encounterIDTemp is used as an intermediate so that
			$encounterID can be set such that "000nnn" does NOT
			match "nnn" when comparing encounter numbers.
		-->
		<xsl:variable name="encounterIDTemp"><xsl:apply-templates select="." mode="EncounterId"/></xsl:variable>
		<xsl:variable name="encounterID" select="string($encounterIDTemp)"/>

		<Encounters>
			<Encounter>
				<xsl:apply-templates select="." mode="DefaultEncounterDetail"/>

				<!-- Process CDA Append/Transform/Replace Directive -->
				<xsl:call-template name="ActionCode">
					<xsl:with-param name="informationType" select="'Encounter'"/>
				</xsl:call-template>

				<!-- Health Funds -->
				<xsl:variable name="payerEntries" select="$administrativeObservationsSection/ext:coverage2"/>
				<xsl:if test="$payerEntries">
					<HealthFunds>
						<xsl:apply-templates select="$payerEntries" mode="HealthFund"/>
					</HealthFunds>
				</xsl:if>

				<!-- Visit Description (NEHTA Clinical Synopsis) -->
				<xsl:apply-templates select="$eventSection/hl7:component/hl7:section[hl7:code/@code='102.15513.4.1.1' and hl7:code/@codeSystem=$nctisOID]/hl7:entry/hl7:act[hl7:code/@code='103.15582' and hl7:code/@codeSystem=$nctisOID]" mode="ClinicalSynopsis"/>

				<!-- Separation Mode -->
				

				<!-- Specialties -->
				<xsl:variable name="specialtyEntries" select="$administrativeObservationsSection/hl7:entry[hl7:observation/hl7:code/@code='103.16028' and hl7:observation/hl7:code/@codeSystem=$nctisOID]"/>
				<xsl:if test="$specialtyEntries">
					<Specialties>
						<xsl:apply-templates select="$specialtyEntries" mode="Specialties"/>
					</Specialties>
				</xsl:if>

				<!-- Recommendations Provided -->
				<xsl:variable name="recommendationEntries" select="$planSection/hl7:component/hl7:section[hl7:code/@code='101.20016' and hl7:code/@codeSystem=$nctisOID]/hl7:entry/hl7:act[hl7:code/@code='102.20016.4.1.1' and hl7:code/@codeSystem=$nctisOID]"/>
				<xsl:if test="$recommendationEntries">
					<RecommendationsProvided>
						<xsl:apply-templates select="$recommendationEntries" mode="Recommendations"/>
					</RecommendationsProvided>
				</xsl:if>

				<!-- Custom SDA Data-->
				<xsl:apply-templates select="." mode="ImportCustom-Encounter"/>
			</Encounter>
		</Encounters>
	</xsl:template>

	<!-- OverriddenEncounter imports an encounter that is found only in the CDA Encounters section. -->
	<xsl:template match="*" mode="OverriddenEncounter">
		<!--
			$encounterIDTemp is used as an intermediate so that
			$encounterID can be set such that "000nnn" does NOT
			match "nnn" when comparing encounter numbers.
		-->
		<xsl:variable name="encounterIDTemp"><xsl:apply-templates select="." mode="EncounterId"/></xsl:variable>
		<xsl:variable name="encounterID" select="string($encounterIDTemp)"/>

		<Encounters>
		<Encounter>
			<xsl:apply-templates select="." mode="OverriddenEncounterDetail"/>

			<!-- Process CDA Append/Transform/Replace Directive -->
			<xsl:call-template name="ActionCode">
				<xsl:with-param name="informationType" select="'Encounter'"/>
			</xsl:call-template>

			<!-- Health Funds -->
			<xsl:variable name="payerEntries" select="$administrativeObservationsSection/ext:coverage2"/>
			<xsl:if test="$payerEntries">
				<HealthFunds>
					<xsl:apply-templates select="$payerEntries" mode="HealthFunds"/>
				</HealthFunds>
			</xsl:if>

			<!-- Visit Description (NEHTA Clinical Synopsis) -->
			<xsl:apply-templates select="$eventSection/hl7:component/hl7:section[hl7:code/@code='102.15513.4.1.1' and hl7:code/@codeSystem=$nctisOID]/hl7:entry/hl7:act[hl7:code/@code='103.15582' and hl7:code/@codeSystem=$nctisOID]" mode="ClinicalSynopsis"/>

			<!-- Specialties -->
			<xsl:variable name="specialtyEntries" select="$administrativeObservationsSection/hl7:entry[hl7:observation/hl7:code/@code='103.16028' and hl7:observation/hl7:code/@codeSystem=$nctisOID]"/>
			<xsl:if test="$specialtyEntries">
				<Specialties>
					<xsl:apply-templates select="$specialtyEntries" mode="Specialties"/>
				</Specialties>
			</xsl:if>

			<!-- Recommendations Provided -->
			<xsl:variable name="recommendationEntries" select="$planSection/hl7:component/hl7:section[hl7:code/@code='101.20016' and hl7:code/@codeSystem=$nctisOID]/hl7:entry/hl7:act[hl7:code/@code='102.20016.4.1.1' and hl7:code/@codeSystem=$nctisOID]"/>
			<xsl:if test="$recommendationEntries">
				<RecommendationsProvided>
					<xsl:apply-templates select="$recommendationEntries" mode="Recommendations"/>
				</RecommendationsProvided>
			</xsl:if>

			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Encounter"/>
		</Encounter>
		</Encounters>
	</xsl:template>

<xsl:template match="*" mode="DefaultEncounterDetail">
		<!--
			Field : Encompassing Encounter Author
			Target: HS.SDA3.Encounter EnteredBy
			Target: /Container/Encounters/Encounter/EnteredBy
			Source: /ClinicalDocument/author
			StructuredMappingRef: EnteredByDetail
			Note  : When importing CDA encompassingEncounter to SDA
					Encounter, CDA document-level author is imported
					to SDA Encounter EnteredBy.
		-->
		<xsl:apply-templates select="$defaultAuthorRootPath" mode="EnteredBy"/>

		<!--
			Field : Encompassing Encounter Information Source
			Target: HS.SDA3.Encounter EnteredAt
			Target: /Container/Encounters/Encounter/EnteredAt
			Source: /ClinicalDocument/informant
			StructuredMappingRef: EnteredAt
			Note  : When importing CDA encompassingEncounter to SDA
					Encounter, CDA document-level informant is imported
					to SDA Encounter EnteredAt.
		-->
		<xsl:apply-templates select="." mode="EnteredAt"/>

		<!--
			Field : Encompassing Encounter Author Time
			Target: HS.SDA3.Encounter EnteredOn
			Target: /Container/Encounters/Encounter/EnteredOn
			Source: /ClinicalDocument/author/time/@value
			Note  : When importing CDA encompassingEncounter to SDA
					Encounter, CDA document-level author/time is
					imported to SDA Encounter EnteredOn.
		-->
		<xsl:apply-templates select="$defaultAuthorRootPath[1]/hl7:time" mode="EnteredOn"/>

		<!--
			Field : Encompassing Encounter Number
			Target: HS.SDA3.Encounter ExternalId
			Target: /Container/Encounters/Encounter/ExternalId
			Source: /ClinicalDocument/componentOf/encompassingEncounter/id[1]
			StructuredMappingRef: ExternalId
		-->
		<xsl:apply-templates select="." mode="ExternalId"/>

		<!--
			Field : Encompassing Encounter Type
			Target: HS.SDA3.Encounter EncounterType
			Target: /Container/Encounters/Encounter/EncounterType
			Source: /ClinicalDocument/componentOf/encompassingEncounter/code/@code
			Note  : SDA EncounterType is a string property derived
					from the CDA coded encounter type information.
					Only values of E, I, or O are imported.  The
					logic is based on definitions in ImportProfile.xsl
					under variable encountersImportConfiguration.
		-->
		<!--
			The value to import to EncounterType is derived
			here so it can be used as part of the logic for
			EndTime as well as for the actual export of
			EncounterType.

			hl7:code in CDA encompassingEncounter is required
			to be Patient Class (EMER, IMP, AMB).  There is
			no Encounter Type in CDA encompassingEncounter,
			so without it, Patient Class is the closest thing
			there is.
		-->
		<xsl:variable name="encounterType"><xsl:apply-templates select="hl7:code" mode="EncounterType"/></xsl:variable>

		<!--
			Field : Encompassing Encounter Start Date/Time
			Target: HS.SDA3.Encounter FromTime
			Target: /Container/Encounters/Encounter/FromTime
			Source: /ClinicalDocument/componentOf/encompassingEncounter/effectiveTime/low/@value
		-->
		<!--
			Field : Encompassing Encounter End Date/Time
			Target: HS.SDA3.Encounter ToTime
			Target: /Container/Encounters/Encounter/ToTime
			Source: /ClinicalDocument/componentOf/encompassingEncounter/effectiveTime/high/@value
		-->
		<xsl:variable name="fromTime">
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:low/@value">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/hl7:low/@value)"/>
				</xsl:when>
				<xsl:when test="not(hl7:effectiveTime/hl7:low/@value) and not(hl7:effectiveTime/hl7:high/@value) and hl7:effectiveTime/@value">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/@value)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="toTime">
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:high/@value">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/hl7:high/@value)"/>
				</xsl:when>
				<xsl:when test="not(hl7:effectiveTime/hl7:low/@value) and not(hl7:effectiveTime/hl7:high/@value) and hl7:effectiveTime/@value">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/@value)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- The logic for endTime here matches that in HS.SDA3.Streamlet.Encounter. -->
		<xsl:variable name="endTime">
			<xsl:choose>
				<xsl:when test="string-length($toTime)"><xsl:value-of select="$toTime"/></xsl:when>
				<xsl:when test="$encounterType='I'"><xsl:value-of select="'&#34;&#34;'"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$fromTime"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($fromTime)"><FromTime><xsl:value-of select="$fromTime"/></FromTime></xsl:if>
		<xsl:if test="string-length($toTime)"><ToTime><xsl:value-of select="$toTime"/></ToTime></xsl:if>
		<xsl:if test="string-length($endTime)"><EndTime><xsl:value-of select="$endTime"/></EndTime></xsl:if>

		<!-- Encounter Type -->
		<EncounterType><xsl:value-of select="$encounterType"/></EncounterType>

		<!--
			Field : Encompassing Encounter Coded Type
			Target: HS.SDA3.Encounter EncounterCodedType
			Target: /Container/Encounters/Encounter/EncounterCodedType
			Source: /ClinicalDocument/componentOf/encompassingEncounter/code
			StructuredMappingRef: CodeTableDetail
			Note  : SDA EncounterCodedType is a coded element imported
					from the CDA coded encounter type information.
		-->
		<xsl:apply-templates select="hl7:code" mode="EncounterCodedType"/>

		<!--
			Field : Encompassing Encounter Admission Type
			Target: HS.SDA3.Encounter AdmissionType
			Target: /Container/Encounters/Encounter/AdmissionType
			Source: /ClinicalDocument/componentOf/encompassingEncounter/priorityCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:priorityCode" mode="AdmissionType"/>

		<!--
			Field : Encompassing Encounter Admitting Clinician
			Target: HS.SDA3.Encounter AdmittingClinician
			Target: /Container/Encounters/Encounter/AdmittingClinician
			Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode = 'ADM']
			StructuredMappingRef: CareProviderDetail
		-->
		<xsl:apply-templates select="hl7:encounterParticipant[@typeCode = 'ADM']" mode="AdmittingClinician"/>

		<!--
			Field : Encompassing Encounter Attending Clinicians
			Target: HS.SDA3.Encounter AttendingClinicians
			Target: /Container/Encounters/Encounter/AttendingClinicians
			Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode = 'ATND']
			StructuredMappingRef: AttendingClinicians
		-->
		<xsl:apply-templates select="." mode="AttendingClinicians"/>

		<!--
			Field : Encompassing Encounter Referring Clinician
			Target: HS.SDA3.Encounter ReferringClinician
			Target: /Container/Encounters/Encounter/ReferringClinician
			Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode = 'REF']
			StructuredMappingRef: DoctorDetail
		-->
		<xsl:apply-templates select="hl7:encounterParticipant[@typeCode = 'REF']" mode="ReferringClinician"/>

		<!--
			Field : Encompassing Encounter Consulting Clinicians
			Target: HS.SDA3.Encounter ConsultingClinicians
			Target: /Container/Encounters/Encounter/ConsultingClinicians
			Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode = 'CON']
			StructuredMappingRef: ConsultingClinicians
		-->
		<xsl:apply-templates select="." mode="ConsultingClinicians"/>

		<!--
			Field : Encompassing Encounter Number
			Target: HS.SDA3.Encounter EncounterNumber
			Target: /Container/Encounters/Encounter/EncounterNumber
			Source: /ClinicalDocument/componentOf/encompassingEncounter/id[2]/@extension
			Note  : For import, if CDA id[2]/@extension is not
					present then CDA id[2]/@root is imported to
					SDA EncounterNumber.
		-->
		<EncounterNumber><xsl:apply-templates select="." mode="EncounterId"/></EncounterNumber>

		<!--
			Field : Encompassing Encounter MRN
			Target: HS.SDA3.Encounter EncounterMRN
			Target: /Container/Encounters/Encounter/EncounterMRN
			Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant/assignedEntity/sdtc:patient/sdtc:id/@extension
			Note  : If CDA encompassingEncounter patient id is not
					available for import, then CDA patient-level id
					is imported to SDA EncounterMRN instead.
		-->
		<xsl:apply-templates select="." mode="EncounterMRN"/>

		<!-- 
			SeparationMode
		-->
		<xsl:apply-templates select="hl7:dischargeDispositionCode" mode="SeparationMode"/>
	
		<!--
			If encompassingEncounter has hl7:location, then use the HealthCareFacility
			template to use hl7:location as the source for SDA3 HealthCareFacility/Organization.
			Otherwise, use the encounter-HealthCareFacility template to use either hl7:id/@root
			or the derived SendingFacility code as the source.
		-->
		<xsl:choose>
			<xsl:when test="hl7:location">
				<xsl:apply-templates select="hl7:location" mode="HealthCareFacility"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="encounter-HealthCareFacility"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="OverriddenEncounterDetail">
		<!--
			Field : Encounter Author
			Target: HS.SDA3.Encounter EnteredBy
			Target: /Container/Encounters/Encounter/EnteredBy
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/author
			StructuredMappingRef: EnteredByDetail
		-->
		<xsl:apply-templates select="." mode="EnteredBy"/>

		<!--
			Field : Encounter Information Source
			Target: HS.SDA3.Encounter EnteredAt
			Target: /Container/Encounters/Encounter/EnteredAt
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/informant
			StructuredMappingRef: EnteredAt
		-->
		<xsl:apply-templates select="." mode="EnteredAt"/>

		<!--
			Field : Encounter Author Time
			Target: HS.SDA3.Encounter EnteredOn
			Target: /Container/Encounters/Encounter/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/author/time/@value
		-->
		<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>

		<!--
			Field : Encounter Number
			Target: HS.SDA3.Encounter ExternalId
			Target: /Container/Encounters/Encounter/ExternalId
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/id
			StructuredMappingRef: ExternalId
		-->
		<xsl:apply-templates select="." mode="ExternalId"/>

		<!--
			Field : Encounter Type
			Target: HS.SDA3.Encounter EncounterType
			Target: /Container/Encounters/Encounter/EncounterType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/code/@code
			Note  : SDA EncounterType is a string property derived
					from the CDA coded encounter type information.
					Only values of E, I, or O are imported.  The
					logic is based on definitions in ImportProfile.xsl
					under variable encountersImportConfiguration.
		-->
		<!--
			The value to import to EncounterType is derived
			here so it can be used as part of the logic for
			EndTime as well as for the actual export of
			EncounterType.
		-->
		<xsl:variable name="encounterType"><xsl:apply-templates select="hl7:code" mode="EncounterType"/></xsl:variable>

		<!--
			Field : Encounter Start Date/Time
			Target: HS.SDA3.Encounter FromTime
			Target: /Container/Encounters/Encounter/FromTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/effectiveTime/low/@value
		-->
		<!--
			Field : Encounter End Date/Time
			Target: HS.SDA3.Encounter ToTime
			Target: /Container/Encounters/Encounter/ToTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/effectiveTime/high/@value
		-->
		<xsl:variable name="fromTime">
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:low/@value">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/hl7:low/@value)"/>
				</xsl:when>
				<xsl:when test="not(hl7:effectiveTime/hl7:low/@value) and not(hl7:effectiveTime/hl7:high/@value) and hl7:effectiveTime/@value">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/@value)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="toTime">
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:high/@value">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/hl7:high/@value)"/>
				</xsl:when>
				<xsl:when test="not(hl7:effectiveTime/hl7:low/@value) and not(hl7:effectiveTime/hl7:high/@value) and hl7:effectiveTime/@value">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/@value)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- The logic for endTime here matches that in HS.SDA3.Streamlet.Encounter. -->
		<xsl:variable name="endTime">
			<xsl:choose>
				<xsl:when test="string-length($toTime)"><xsl:value-of select="$toTime"/></xsl:when>
				<xsl:when test="$encounterType='I'"><xsl:value-of select="'&#34;&#34;'"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$fromTime"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($fromTime)"><FromTime><xsl:value-of select="$fromTime"/></FromTime></xsl:if>
		<xsl:if test="string-length($toTime)"><ToTime><xsl:value-of select="$toTime"/></ToTime></xsl:if>
		<xsl:if test="string-length($endTime)"><EndTime><xsl:value-of select="$endTime"/></EndTime></xsl:if>

		<EncounterType><xsl:value-of select="$encounterType"/></EncounterType>

		<!--
			Field : Encounter Coded Type
			Target: HS.SDA3.Encounter EncounterCodedType
			Target: /Container/Encounters/Encounter/EncounterCodedType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/code
			StructuredMappingRef: CodeTableDetail
			Note  : SDA EncounterCodedType is a coded element imported
					from the CDA coded encounter type information.
		-->
		<xsl:apply-templates select="hl7:code" mode="EncounterCodedType"/>
		
		<!--
			Field : Encounter Admission Type
			Target: HS.SDA3.Encounter AdmissionType
			Target: /Container/Encounters/Encounter/AdmissionType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/priorityCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:priorityCode" mode="AdmissionType"/>

		<!--
			Field : Encounter Provider
			Target: HS.SDA3.Encounter AttendingClinicians
			Target: /Container/Encounters/Encounter/AttendingClinicians
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.3']/entry/encounter/performer[@typeCode = 'PRF']
			StructuredMappingRef: AttendingClinicians
		-->
		<xsl:apply-templates select="." mode="AttendingClinicians"/>

		<!-- HS.SDA3.Encounter ConsultingClinicians -->
		<!-- Consulting Clinicians from informant -->
		<xsl:apply-templates select="." mode="ConsultingClinicians-informant"/>

		<!--
			Field : Encounter Number
			Target: HS.SDA3.Encounter EncounterNumber
			Target: /Container/Encounters/Encounter/EncounterNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/id[2]/@extension
			Note  : For import, if CDA id[2]/@extension is not
					present then CDA id[2]/@root is imported to
					SDA EncounterNumber.
		-->
		<EncounterNumber><xsl:apply-templates select="." mode="EncounterId"/></EncounterNumber>

		<!--
			Field : Encounter MRN
			Target: HS.SDA3.Encounter EncounterMRN
			Target: /Container/Encounters/Encounter/EncounterMRN
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/informant/assignedEntity/sdtc:patient/sdtc:id/@extension
			Note  : If CDA encounter patient id is not available
					for import, then CDA patient-level is imported
					to SDA EncounterMNR instead.
		-->
		<xsl:apply-templates select="." mode="EncounterMRN"/>

		<!-- HealthCareFacility -->
		<xsl:apply-templates select="." mode="encounter-HealthCareFacility"/>
	</xsl:template>

	<!--
		EncounterType returns a string value derived from
		the CDA coded encounter type information.
	-->
	<xsl:template match="*" mode="EncounterType">
		<!--
			If the CDA Encounter Type data has the No Code
			System OID in the first translation element
			(if any), then use the first translation element
			for import.
		-->
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="not(@code) and hl7:translation[1]/@code">
					<xsl:value-of select="hl7:translation[1]/@code"/>
				</xsl:when>
				<xsl:when test="hl7:translation[1]/@codeSystem=$noCodeSystemOID">
					<xsl:value-of select="hl7:translation[1]/@code"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="@code"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codeSystem">
			<xsl:choose>
				<xsl:when test="not(@code) and hl7:translation[1]/@codeSystem">
					<xsl:value-of select="hl7:translation[1]/@codeSystem"/>
				</xsl:when>
				<xsl:when test="hl7:translation[1]/@codeSystem=$noCodeSystemOID">
					<xsl:value-of select="$noCodeSystemOID"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="@codeSystem"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--
			The value generated here is intended for SDA
			EncounterType, which shoud only be E, I, or O.

			$encounterTypeMaps is based on definitions in
			ImportProfile.xsl, under variable
			encountersImportConfiguration.
		-->
		<xsl:choose>
			<xsl:when test="string-length($encounterTypeMaps/encounterTypeMap[CDACode/text()=$code and CDACodeSystem=$codeSystem]/SDAEncounterType/text())">
				<xsl:value-of select="$encounterTypeMaps/encounterTypeMap[CDACode/text()=$code and CDACodeSystem=$codeSystem]/SDAEncounterType/text()"/>
			</xsl:when>
			<xsl:when test="$code = 'AMB'">O</xsl:when>
			<xsl:when test="$code = 'IMP'">I</xsl:when>
			<xsl:when test="$code = 'EMER'">E</xsl:when>
			<xsl:otherwise>O</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		EncounterCodedType imports CDA coded encounter
		type information as an SDA coded element.
	-->
	<xsl:template match="hl7:code" mode="EncounterCodedType">
		<xsl:apply-templates select="." mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'EncounterCodedType'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
	</xsl:template>

	<!--
		SeparationMode imports CDA coded Separation Mode
		information as an SDA coded element.
	-->
	<xsl:template match="hl7:dischargeDispositionCode" mode="SeparationMode">
		<xsl:apply-templates select="." mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'SeparationMode'"/>
			<xsl:with-param name="importOriginalText" select="'0'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="EncounterMRN">
		<!-- The checkPatientIdentifiers template is in PersonalInformation.xsl. -->
		<xsl:variable name="hasPatientMRN">
			<xsl:apply-templates select="/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/ext:asEntityIdentifier" mode="checkPatientIdentifiers">
				<xsl:with-param name="identifierType" select="'MRN'"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="hasPatientIHI">
			<xsl:apply-templates select="/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/ext:asEntityIdentifier" mode="checkPatientIdentifiers">
				<xsl:with-param name="identifierType" select="'IHI'"/>
			</xsl:apply-templates>
		</xsl:variable>

		<!-- Use the patient-level MRN or IHI when no encounter-level MRN is found. -->
		<EncounterMRN>
			<xsl:choose>
				<xsl:when test="string-length(hl7:encounterParticipant/hl7:assignedEntity/sdtc:patient/sdtc:id/@extension)">
					<xsl:value-of select="hl7:encounterParticipant/hl7:assignedEntity/sdtc:patient/sdtc:id/@extension"/>
				</xsl:when>
				<xsl:when test="string-length(hl7:informant/hl7:assignedEntity/sdtc:patient/sdtc:id/@extension)">
					<xsl:value-of select="hl7:informant/hl7:assignedEntity/sdtc:patient/sdtc:id/@extension"/>
				</xsl:when>
				<xsl:when test="string-length($hasPatientMRN)">
					<xsl:value-of select="/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/ext:asEntityIdentifier[@classCode='IDENT' and ext:code/@code='MR' and ext:code/@codeSystem='2.16.840.1.113883.12.203'][1]"/>
				</xsl:when>
				<xsl:when test="string-length($hasPatientIHI)">
					<xsl:choose>
						<xsl:when test="/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/ext:asEntityIdentifier[@classCode='IDENT' and ext:id/@assigningAuthorityName='IHI' and string-length(ext:id/@root)=37 and starts-with(ext:id/@root,$hiServiceOID) and substring(ext:id/@root,22,6)=$ihiPrefix][1]">
							<xsl:value-of select="substring(/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/ext:asEntityIdentifier/ext:id/@root,22)"/>
						</xsl:when>
						<xsl:when test="/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/ext:asEntityIdentifier[@classCode='IDENT' and ext:id/@assigningAuthorityName='IHI' and ext:id/@root=$hiServiceOID and string-length(ext:id/@extension)=16 and starts-with(ext:extension/@root,$ihiPrefix)][1]">
							<xsl:value-of select="/hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole/hl7:patient/ext:asEntityIdentifier/ext:extension/@root"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</EncounterMRN>
	</xsl:template>

<xsl:template match="*" mode="EncounterId">
		<xsl:variable name="encounterNumber">
			<xsl:choose>
				<xsl:when test="string-length(hl7:id/@extension)"><xsl:value-of select="hl7:id/@extension"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="hl7:id/@root"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="encounterNumberLower" select="translate($encounterNumber,$upperCase,$lowerCase)"/>
		<xsl:variable name="encounterNumberClean" select="translate($encounterNumber,';:% &#34;','_____')"/>
		<xsl:choose>
			<xsl:when test="starts-with($encounterNumberLower,'urn:uuid:')">
				<xsl:value-of select="substring($encounterNumberClean,10)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$encounterNumberClean"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="AdmissionType">
		<xsl:apply-templates select="." mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'AdmissionType'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="encounter-HealthCareFacility">
		<!--
			CDA to SDA import of duplicated encounter checks
			encompassingEncounter/location first.  If not
			found there, it instead uses
			encounter/participant[@typeCode='LOC']/participantRole[@classCode='SDLOC'].
		-->

		<!--
			$organizationCode ought to get a value.  If it does
			not, then that indicates that something is wrong with
			the document itself, since not even SendingFacility
			could be found.
		-->
		<xsl:variable name="organizationCode">
			<xsl:apply-templates select="." mode="encounter-HealthCareFacility-OrganizationCode"/>
		</xsl:variable>

		<!--
			If location is present, then import HealthCareFacility Code,
			LocationType (if present), and Organization Code.
		-->
		<xsl:choose>
			<xsl:when test="hl7:participant[@typeCode='LOC']/hl7:participantRole[@classCode='SDLOC']">
				<HealthCareFacility>
					<Code>
						<xsl:apply-templates select="hl7:participant[@typeCode='LOC']/hl7:participantRole[@classCode='SDLOC']" mode="encounter-HealthCareFacility-LocationCode"/>
					</Code>

					<xsl:if test="string-length($organizationCode)">
						<Organization><Code><xsl:value-of select="$organizationCode"/></Code></Organization>
					</xsl:if>

					<xsl:variable name="locationTypeCode">
						<xsl:choose>
							<xsl:when test="hl7:code/@codeSystem=$healthcareServiceLocationOID">
								<xsl:choose>
									<xsl:when test="hl7:code/@code='1117-1'">CLINIC</xsl:when>
									<xsl:when test="hl7:code/@code='1160-1'">CLINIC</xsl:when>
									<xsl:when test="hl7:code/@code='1108-0'">ER</xsl:when>
									<xsl:when test="hl7:code/@code='1010-8'">DEPARTMENT</xsl:when>
									<xsl:otherwise>OTHER</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="contains('|CLINIC|ER|DEPARTMENT|WARD|OTHER|', concat('|',hl7:code/@code,'|'))">
								<xsl:value-of select="hl7:code/@code"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="string-length($locationTypeCode)">
						<LocationType><xsl:value-of select="$locationTypeCode"/></LocationType>
					</xsl:if>
				</HealthCareFacility>
			</xsl:when>
			<!--
				Otherwise if $organizationCode has a value then use it
				for both Organization Code and HealthCareFacility Code.
			-->
			<xsl:when test="string-length($organizationCode)">
				<HealthCareFacility>
					<Code><xsl:value-of select="$organizationCode"/></Code>
					<Organization><Code><xsl:value-of select="$organizationCode"/></Code></Organization>
				</HealthCareFacility>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="encounter-HealthCareFacility-LocationCode">
		<xsl:choose>
			<xsl:when test="string-length(hl7:id/@extension)">
				<xsl:value-of select="hl7:id/@extension"/>
			</xsl:when>
			<xsl:when test="string-length(hl7:id/@root)">
				<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="hl7:id/@root"/></xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string-length(hl7:playingEntity/hl7:name/text())">
				<xsl:value-of select="hl7:playingEntity/hl7:name/text()"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="encounter-HealthCareFacility-OrganizationCode">
		<!--
			If hl7:id/@root is present, then it is used as the
			source for Organization Code, regardless of whether
			it has an IdentityCode defined in the OID Registry.
			If there is an IdentityCode defined, then that code
			is used.  Otherwise, the @root is used as is.

			If hl7:id/@root is not present, then use the derived
			SendingFacility value as the source for Organization
			Code.
		-->
		<xsl:variable name="organizationCodeFromIdRoot">
			<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="hl7:id/@root"/></xsl:apply-templates>
		</xsl:variable>

		<xsl:variable name="sendingFacilityForEncounter"><xsl:apply-templates select="/hl7:ClinicalDocument" mode="SendingFacilityValue"/></xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($organizationCodeFromIdRoot)">
				<xsl:value-of select="$organizationCodeFromIdRoot"/>
			</xsl:when>
			<xsl:when test="string-length($sendingFacilityForEncounter)">
				<xsl:value-of select="$sendingFacilityForEncounter"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="ConsultingClinicians-informant">
		<xsl:if test="hl7:informant[not(hl7:assignedEntity/hl7:id/@nullFlavor) and hl7:assignedEntity/hl7:id/@root and hl7:assignedEntity/hl7:id/@extension and string-length(hl7:assignedEntity/hl7:assignedPerson/hl7:name)]">
			<ConsultingClinicians>
				<xsl:apply-templates select="hl7:informant[not(hl7:assignedEntity/hl7:id/@nullFlavor) and hl7:assignedEntity/hl7:id/@root and hl7:assignedEntity/hl7:id/@extension and string-length(hl7:assignedEntity/hl7:assignedPerson/hl7:name)]" mode="CareProvider"/>
			</ConsultingClinicians>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="ClinicalSynopsis">
		<VisitDescription><xsl:value-of select="hl7:text/text()"/></VisitDescription>
	</xsl:template>

	<xsl:template match="*" mode="Specialties">
		<xsl:apply-templates select="hl7:observation/hl7:value" mode="Specialty"/>
	</xsl:template>

	<xsl:template match="*" mode="Specialty">
		<xsl:apply-templates select="." mode="CodeTable"><xsl:with-param name="hsElementName" select="'CareProviderType'"/></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="Recommendations">
		<Recommendation>
			<NoteText><xsl:value-of select="hl7:text/text()"/></NoteText>

			<xsl:variable name="recipientPersons" select="hl7:performer[hl7:assignedEntity/hl7:assignedPerson]"/>
			<xsl:variable name="recipientOrganizations" select="hl7:performer[hl7:assignedEntity/hl7:representedOrganization]"/>

			<xsl:if test="$recipientPersons">
				<RecipientPersons>
					<xsl:apply-templates select="$recipientPersons" mode="RecipientPersons"/>
				</RecipientPersons>
			</xsl:if>
			<xsl:if test="$recipientOrganizations">
				<RecipientOrganizations>
					<xsl:apply-templates select="$recipientOrganizations" mode="RecipientOrganizations"/>
				</RecipientOrganizations>
			</xsl:if>
		</Recommendation>
	</xsl:template>

	<xsl:template match="*" mode="RecipientPersons">
		<xsl:apply-templates select="hl7:assignedEntity" mode="RecipientPerson"/>
	</xsl:template>

	<xsl:template match="*" mode="RecipientPerson">
		<CareProvider>
			<Code><xsl:value-of select="hl7:assignedPerson/ext:asEntityIdentifier/ext:id/@root"/></Code>
			<xsl:apply-templates select="hl7:assignedPerson/hl7:name" mode="ContactName"/>
			<xsl:apply-templates select="hl7:addr" mode="Address"/>
			<xsl:apply-templates select="." mode="ContactInfo"/>
			<CareProviderType>
				<Code><xsl:value-of select="hl7:code/@code"/></Code>
				<Description><xsl:value-of select="hl7:code/@displayName"/></Description>
			</CareProviderType>
		</CareProvider>
	</xsl:template>

	<xsl:template match="*" mode="RecipientOrganizations">
		<xsl:apply-templates select="hl7:assignedEntity" mode="HealthCareFacility"/>
	</xsl:template>

	<!--
		This empty template may be overridden with custom logic.

		The input node spec can be either of the following:
		- /hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter
		- $sectionRootPath/hl7:entry/hl7:encounter
	-->
	<xsl:template match="*" mode="ImportCustom-Encounter">
	</xsl:template>
</xsl:stylesheet>
