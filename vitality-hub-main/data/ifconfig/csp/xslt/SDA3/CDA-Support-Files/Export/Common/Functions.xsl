<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Keys to encounter data -->
	<xsl:key name="EncNum" match="Encounter" use="EncounterNumber"/>

	<xsl:template match="*" mode="participant">
		<participant typeCode="IND">
			<xsl:apply-templates select="." mode="time"/>
			<xsl:apply-templates select="." mode="participantRole"/>
		</participant>
	</xsl:template>
	
	<xsl:template match="*" mode="participantRole">
		<participantRole>
			<xsl:apply-templates select="." mode="id-Clinician"/>
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			<xsl:apply-templates select="." mode="telecom"/>
			<xsl:apply-templates select="." mode="playingEntity"/>
		</participantRole>
	</xsl:template>
	
	<xsl:template match="*" mode="playingEntity">
		<playingEntity>
			<xsl:apply-templates select="." mode="name-Person"/>
		</playingEntity>
	</xsl:template>
	
	<xsl:template match="*" mode="performer">
		<!--
			StructuredMapping: performer
			
			Field
			Path  : time/low/@value
			Source: ParentProperty.FromTime
			Source: ../FromTime
			
			Field
			Path  : time/high/@value
			Source: ParentProperty.ToTime
			Source: ../ToTime
			
			Field
			Path  : assignedEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity-performer
		-->
		<performer typeCode="PRF">
			<xsl:apply-templates select="parent::node()" mode="time"/>
			<xsl:apply-templates select="." mode="assignedEntity-performer"/>
		</performer>
	</xsl:template>
	
	<xsl:template match="*" mode="informant">
		<!--
			StructuredMapping: informant
			
			Field
			Path  : assignedEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity
		-->
		<informant>
			<xsl:apply-templates select="." mode="assignedEntity"/>
		</informant>
	</xsl:template>

	<xsl:template match="*" mode="informant-encounterParticipant">
		<!--
			StructuredMapping: informant-encounterParticipant
			
			Field
			Path  : assignedEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity-encounterParticipant
		-->
		<informant>
			<xsl:apply-templates select="." mode="assignedEntity-encounterParticipant"/>
		</informant>
	</xsl:template>

	<xsl:template match="*" mode="informant-noPatientIdentifier">
		<informant>
			<xsl:apply-templates select="." mode="assignedEntity"><xsl:with-param name="includePatientIdentifier" select="false()"/></xsl:apply-templates>
		</informant>
	</xsl:template>

	<xsl:template match="*" mode="author-Document">
		<author typeCode="AUT">
			<time value="{$currentDateTime}"/>
			<xsl:apply-templates select="." mode="assignedAuthor-Document"/>
		</author>
	</xsl:template>

	<xsl:template match="*" mode="author-Human">
		<!--
			StructuredMapping: author-Human
			
			Field
			Path  : time
			Source: ParentProperty.EnteredOn
			Source: ../EnteredOn
			
			Field
			Path  : assignedAuthor
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedAuthor-Human
		-->
		<author typeCode="AUT">
			<xsl:choose>
				<xsl:when test="string-length(../EnteredOn)">
					<time><xsl:attribute name="value"><xsl:apply-templates select="../EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></time>
				</xsl:when>
				<xsl:otherwise>
					<time nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="." mode="assignedAuthor-Human"/>
		</author>
	</xsl:template>

	<xsl:template match="*" mode="author-Device">
		<author typeCode="AUT">
			<time value="{$currentDateTime}"/>
			<xsl:apply-templates select="." mode="assignedAuthor-Device"/>
		</author>
	</xsl:template>
	
	<xsl:template match="*" mode="author-Code">
		<!--
			StructuredMapping: author-Code
			
			Field
			Path  : originalText/text()
			Source: CurrentProperty
			Source: text()
		-->
		<code nullFlavor="NA">
			<originalText><xsl:value-of select="text()"/></originalText>
		</code>
	</xsl:template>
	
	<xsl:template match="*" mode="assignedEntity">
		<xsl:param name="includePatientIdentifier" select="true()"/>
		<!--
			StructuredMapping: assignedEntity
		
			Field
			Path  : id
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : addr
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
			
			Field
			Path  : telecom
			Source: ContactInfo
			Source: ./ContactInfo
			StructuredMappingRef: telecom
			
			Field
			Path  : assignedPerson
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedPerson
			
			Field
			Path  : representedOrganization
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: representedOrganization
		-->
		
		<assignedEntity>
			<!-- Contact Identifier -->
			<xsl:apply-templates select="." mode="id-Clinician"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="telecom"/>
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="assignedPerson"/>
			
			<!-- Represented Organization -->
			<xsl:apply-templates select="." mode="representedOrganization"/>
			
			<!-- HITSP-specific patient extension, available today only for encountered data -->
			<xsl:if test="($includePatientIdentifier = true())"><xsl:apply-templates select="." mode="id-sdtcPatient"><xsl:with-param name="xpathContext" select="."/></xsl:apply-templates></xsl:if>
		</assignedEntity>
	</xsl:template>

	<xsl:template match="*" mode="assignedAuthor-Document">
		<assignedAuthor classCode="ASSIGNED">
			<id nullFlavor="{$idNullFlavor}"/>
			<addr nullFlavor="{$addrNullFlavor}"/>
			<telecom nullFlavor="UNK"/>
			<assignedPerson><name nullFlavor="UNK"/></assignedPerson>
			
			<!-- Represented Organization -->
			<xsl:apply-templates select="." mode="representedOrganization-Document"/>
		</assignedAuthor>
	</xsl:template>
	
	<xsl:template match="*" mode="assignedEntity-performer">
		<!--
			StructuredMapping: assignedEntity-performer
			
			Field
			Path  : id
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : addr
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
			
			Field
			Path  : telecom
			Source: ContactInfo
			Source: ./ContactInfo
			StructuredMappingRef: telecom
			
			Field
			Path  : assignedPerson
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedPerson
		-->
		<assignedEntity classCode="ASSIGNED">
			<!-- Contact Identifier -->
			<xsl:apply-templates select="." mode="id-Clinician"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="telecom"/>
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="assignedPerson"/>
		</assignedEntity>
	</xsl:template>
	
	<xsl:template match="*" mode="assignedEntity-encounterParticipant">
		<!--
			StructuredMapping: assignedEntity-encounterParticipant
			
			Field
			Path  : id
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : addr
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
			
			Field
			Path  : telecom
			Source: ContactInfo
			Source: ./ContactInfo
			StructuredMappingRef: telecom
			
			Field
			Path  : assignedPerson
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedPerson
		-->
		<assignedEntity classCode="ASSIGNED">
			<!-- Contact Identifier -->
			<xsl:apply-templates select="." mode="id-Clinician"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="telecom"/>
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="assignedPerson"/>
		</assignedEntity>
	</xsl:template>
	
	<xsl:template match="*" mode="id-sdtcPatient">
		<xsl:param name="xpathContext"/>
		
		<xsl:if test="$xpathContext = true()">
			<xsl:variable name="encounterContext" select="key('EncNum', $xpathContext/EncounterNumber)[1]"/>
			<xsl:choose>
				<xsl:when test="$encounterContext = true()">
					<xsl:apply-templates select="$encounterContext[string-length(EnteredAt/Code/text()) and string-length(EncounterMRN/text())]" mode="sdtc-Patient"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="id-sdtcPatient">
						<xsl:with-param name="xpathContext" select="$xpathContext/parent::node()"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Encounter" mode="sdtc-Patient">
		<sdtc:patient>
			<sdtc:id>
				<xsl:attribute name="root"><xsl:apply-templates select="EnteredAt/Code" mode="code-to-oid"><xsl:with-param name="identityType" select="'Facility'"></xsl:with-param></xsl:apply-templates></xsl:attribute>
				<xsl:attribute name="extension"><xsl:value-of select="EncounterMRN/text()"/></xsl:attribute>
			</sdtc:id>
		</sdtc:patient>
	</xsl:template>
	
	<xsl:template match="*" mode="associatedEntity">
		<xsl:param name="contactType"/>

		<!--
			StructuredMapping: associatedEntity
			
			Field
			Path  : id
			Source: ExternalId
			Source: ExternalId/text()
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : code
			Source: Relationship
			Source: ./Relationship
			StructuredMappingRef: generic-Coded
			
			Field
			Path  : addr
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
			
			Field
			Path  : telecom
			Source: ContactInfo
			Source: ./ContactInfo
			StructuredMappingRef: telecom
			
			Field
			Path  : associatedPerson/name
			Source: Name
			Source: ./Name
			StructuredMappingRef: name-Person
		-->
		<associatedEntity classCode="{$contactType}">
		
			<xsl:apply-templates select="." mode="id-Clinician"/>
			
			<xsl:apply-templates select="Relationship" mode="generic-Coded">
				<xsl:with-param name="requiredCodeSystemOID" select="$roleCodeOID"/>
				<xsl:with-param name="isCodeRequired" select="'1'"/>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<xsl:apply-templates select="." mode="telecom"/>
			
			<xsl:apply-templates select="." mode="associatedPerson"/>
			
			<xsl:apply-templates select="EnteredAt" mode="scopingOrganization"/>
		</associatedEntity>
	</xsl:template>
	
	<xsl:template match="*" mode="assignedAuthor-Human">
		<!--
			StructuredMapping: assignedAuthor-Human
			
			Field
			Path  : id
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : code
			Source: Description
			Source: ./Description
			StructuredMappingRef: author-Code
			Note  : assignedAuthor/code is exported only when the SDA Description
					indicates patient-entered data, when Description is "Payer",
					"Payor" or "Patient".
			
			Field
			Path  : representedOrganization
			Source: ParentProperty.EnteredAt
			Source: ../EnteredAt
			StructuredMappingRef: representedOrganization
		-->
		<assignedAuthor classCode="ASSIGNED">
			<!-- Clinician ID -->
			<xsl:apply-templates select="." mode="id-Clinician"/>

			<!-- HealthShare-specific author types -->
			<xsl:apply-templates select="Description[contains('|PAYER|PAYOR|PATIENT|', translate(text(), $lowerCase, $upperCase))]" mode="author-Code"/>
			
			<!-- Author Address -->
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<!-- Author Telecom -->
			<xsl:apply-templates select="." mode="telecom"/>

			<!-- Person -->
			<xsl:apply-templates select="." mode="assignedPerson"/>
						
			<!-- Represented Organization -->
			<xsl:apply-templates select="../EnteredAt" mode="representedOrganization"/>
		</assignedAuthor>
	</xsl:template>

	<xsl:template match="*" mode="assignedAuthor-Device">
		<assignedAuthor classCode="ASSIGNED">
			<!-- HealthShare ID -->
			<xsl:apply-templates select="." mode="id-HealthShare"/>
			
			<addr nullFlavor="{$addrNullFlavor}"/>
			<telecom nullFlavor="UNK"/>
			
			<!-- Software Device -->
			<xsl:apply-templates select="." mode="assignedAuthoringDevice"/>
			
			<!-- Represented Organization -->
			<xsl:apply-templates select="." mode="representedOrganization-Document"/>
		</assignedAuthor>
	</xsl:template>

	<xsl:template match="*" mode="assignedAuthoringDevice">
		<assignedAuthoringDevice>
			<softwareName>InterSystems HealthShare</softwareName>
		</assignedAuthoringDevice>
	</xsl:template>
	
	<xsl:template match="*" mode="assignedPerson">
		<!--
			StructuredMapping: assignedPerson
			
			Field
			Path  : name
			Source: Name
			Source: ./Name
			StructuredMappingRef: name-Person
		-->
		<assignedPerson>
			<xsl:choose>
				<xsl:when test="not(local-name()='EnteredAt')">
					<xsl:apply-templates select="." mode="name-Person"/>
				</xsl:when>
				<xsl:otherwise>
					<name nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
		</assignedPerson>
	</xsl:template>

	<xsl:template match="*" mode="associatedPerson">
		<associatedPerson>
			<xsl:apply-templates select="." mode="name-Person"/>
		</associatedPerson>
	</xsl:template>
	
	<xsl:template match="*" mode="subject">
		<subject>
			<relatedSubject classCode="PRS">
				<xsl:apply-templates select="." mode="generic-Coded">
					<xsl:with-param name="requiredCodeSystemOID" select="$roleCodeOID"/>
					<xsl:with-param name="isCodeRequired" select="'1'"/>
				</xsl:apply-templates>

				<subject>
					<name nullFlavor="UNK"/>
					<administrativeGenderCode nullFlavor="UNK"/>
					<birthTime nullFlavor="UNK"/>
				</subject>
			</relatedSubject>
		</subject>
	</xsl:template>

	<xsl:template match="*" mode="name-Person">
	<!-- match could be Patient, HealthFund, Subscriber, PerformedAt, Contact, Clinician,
		   FamilyDoctor, CareProvider, AdmittingClinician, DiagnosingClinician, ReferringClinician,
		   EnteredBy, OrderedBy, VerifiedBy -->		
		<!--
			StructuredMapping: name-Person
			Note  : C-CDA does not allow the export
			of the Description/text() as a straight text line.
			It only allows the export of the name parts inside of <family>, <given>, etc.  If the Name object is not passed into here, then try to parse the name parts out of Description/text().
								
			Field
			Path  : family
			Source: FamilyName
			Source: FamilyName/text()
			
			Field
			Path  : given[1]
			Source: GivenName
			Source: GivenName/text()
			
			Field
			Path  : given[2]
			Source: MiddleName
			Source: MiddleName/text()
			
			Field
			Path  : prefix
			Source: NamePrefix
			Source: NamePrefix/text()
			
			Field
			Path  : suffix
			Source: ProfessionalSuffix
			Source: ProfessionalSuffix/text()
		-->
		<xsl:variable name="normalizedDescription" select="normalize-space(Description/text())"/>
		<xsl:variable name="hasDescription" select="string-length($normalizedDescription)"/>	
		<xsl:variable name="hasCommaInFullName" select="contains($normalizedDescription,',')"/>		
		<xsl:variable name="hasSpaceInFullName" select="contains($normalizedDescription,' ')"/>	
		
		<xsl:choose>
			<xsl:when test="$hasDescription or Name">
				<xsl:variable name="contactPrefix" select="normalize-space(Name/NamePrefix/text())"/>

				<xsl:variable name="contactFirstName">
					<xsl:choose>
						<xsl:when test="string-length(normalize-space(Name/GivenName/text()))">
							<xsl:value-of select="normalize-space(Name/GivenName/text())"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="$hasDescription">
								<xsl:choose>
									<xsl:when test="$hasCommaInFullName">
										<xsl:value-of select="normalize-space(substring-after($normalizedDescription,','))"/>
									</xsl:when>
									<xsl:when test="$hasSpaceInFullName">
										<xsl:value-of select="normalize-space(substring-before($normalizedDescription,' '))"/>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>				

				<xsl:variable name="contactMiddleName" select="normalize-space(Name/MiddleName/text())"/>

				<xsl:variable name="contactLastName">
					<xsl:choose>
						<xsl:when test="string-length(normalize-space(Name/FamilyName/text()))">
							<xsl:value-of select="Name/FamilyName/text()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="$hasDescription">
								<xsl:choose>
									<xsl:when test="$hasCommaInFullName">
										<xsl:value-of select="normalize-space(substring-before($normalizedDescription,','))"/>
									</xsl:when>
									<xsl:when test="$hasSpaceInFullName">
										<xsl:value-of select="normalize-space(substring-after($normalizedDescription,' '))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$normalizedDescription"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>				

				<xsl:variable name="contactSuffix" select="normalize-space(Name/ProfessionalSuffix/text())"/>				

				<xsl:choose>
					<xsl:when test="string-length($contactFirstName) or string-length($contactLastName)">
						<name use="L">
							<xsl:if test="string-length($contactLastName)"><family><xsl:value-of select="$contactLastName"/></family></xsl:if>
							<xsl:if test="string-length($contactFirstName)"><given><xsl:value-of select="$contactFirstName"/></given></xsl:if>
							<xsl:if test="string-length($contactMiddleName)"><given><xsl:value-of select="$contactMiddleName"/></given></xsl:if>
							<xsl:if test="string-length($contactPrefix)"><prefix><xsl:value-of select="$contactPrefix"/></prefix></xsl:if>
							<xsl:if test="string-length($contactSuffix)"><suffix><xsl:value-of select="$contactSuffix"/></suffix></xsl:if>
						</name>
					</xsl:when>
					<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Name" mode="name-Person-Other">
		<xsl:param name="use" select="'P'"/>
		
		<xsl:variable name="contactPrefix" select="NamePrefix/text()"/>
		<xsl:variable name="contactFirstName" select="GivenName/text()"/>
		<xsl:variable name="contactMiddleName" select="normalize-space(MiddleName/text())"/>
		<xsl:variable name="contactLastName" select="FamilyName/text()"/>
		<xsl:variable name="contactSuffix" select="ProfessionalSuffix/text()"/>
		
		<!--
			StructuredMapping: name-Person-Other
			Note  : C-CDA only allows the export of the name parts inside of <family>, <given>, etc.
								
			Field
			Path  : family
			Source: FamilyName
			Source: FamilyName/text()
			
			Field
			Path  : given[1]
			Source: GivenName
			Source: GivenName/text()
			
			Field
			Path  : given[2]
			Source: MiddleName
			Source: MiddleName/text()
			
			Field
			Path  : prefix
			Source: NamePrefix
			Source: NamePrefix/text()
			
			Field
			Path  : suffix
			Source: ProfessionalSuffix
			Source: ProfessionalSuffix/text()
		-->
		<xsl:choose>
			<xsl:when test="string-length($contactFirstName) or string-length($contactLastName)">
				<name use="{$use}">
					<xsl:if test="string-length($contactLastName)"><family><xsl:value-of select="$contactLastName"/></family></xsl:if>
					<xsl:if test="string-length($contactFirstName)"><given><xsl:value-of select="$contactFirstName"/></given></xsl:if>
					<xsl:if test="string-length($contactMiddleName)"><given><xsl:value-of select="$contactMiddleName"/></given></xsl:if>
					<xsl:if test="string-length($contactPrefix)"><prefix><xsl:value-of select="$contactPrefix"/></prefix></xsl:if>
					<xsl:if test="string-length($contactSuffix)"><suffix><xsl:value-of select="$contactSuffix"/></suffix></xsl:if>
				</name>
			</xsl:when>
			<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="name-Person-Narrative">
		<xsl:value-of select="normalize-space(Description/text())"/>
	</xsl:template>
	
	<xsl:template match="Patient" mode="addresses-Patient">
		<!--
			StructuredMapping: addresses-Patient
			
			Field
			Path  : ./
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
		-->
		<xsl:choose>
			<xsl:when test="Addresses/Address">
				<xsl:apply-templates select="Addresses/Address" mode="address-Patient"/>
			</xsl:when>
			<xsl:otherwise><addr nullFlavor="{$addrNullFlavor}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Address" mode="address-Patient">
		<xsl:apply-templates select="." mode="address-Individual">
			<xsl:with-param name="addressUse">
				<xsl:choose>
					<xsl:when test="position()=1">HP</xsl:when>
					<xsl:otherwise>H</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- DO NOT USE address-Person, it is deprecated as of HealthShare Core 13. -->
	<xsl:template match="*" mode="address-Person">
		<xsl:choose>
			<xsl:when test="Addresses">
				<xsl:apply-templates select="Addresses[1]" mode="address-HomePrimary"/>
				<xsl:apply-templates select="following::Addresses[1]" mode="address-Home"/>
			</xsl:when>
			<xsl:otherwise><addr nullFlavor="{$addrNullFlavor}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="address-WorkPrimary">
		<xsl:apply-templates select="." mode="address">
			<xsl:with-param name="addressUse">WP</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="address-HomePrimary">
		<xsl:apply-templates select="." mode="address">
			<xsl:with-param name="addressUse">HP</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="address-Home">
		<xsl:apply-templates select="." mode="address">
			<xsl:with-param name="addressUse">H</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="address">
		<xsl:param name="addressUse" select="'WP'"/>

		<xsl:choose>
			<xsl:when test="Address | InsuredAddress">
				<xsl:apply-templates select="Address | InsuredAddress[1]" mode="address-Individual">
					<xsl:with-param name="addressUse" select="$addressUse"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise><addr nullFlavor="{$addrNullFlavor}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="address-Individual">
		<xsl:param name="addressUse" select="'WP'"/>
		
		<!-- Input node-spec is Address or InsuredAddress. -->
		
		<xsl:variable name="addressStreet" select="Street/text()"/>
		<xsl:variable name="addressCity" select="City/Code/text()"/>
		<xsl:variable name="addressState" select="State/Code/text()"/>
		<xsl:variable name="addressZip" select="Zip/Code/text()"/>
		<xsl:variable name="addressCountry"><xsl:apply-templates select="Country/Code" mode="address-country"/></xsl:variable>
		<xsl:variable name="addressCounty" select="County/Code/text()"/>
		<xsl:variable name="addressFromTime"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:variable>
		<xsl:variable name="addressToTime"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:variable>
		
		<!--
			StructuredMapping: address
								
			Field
			Path  : useablePeriod/low/@value
			Source: FromTime
			Source: FromTime/text()
			
			Field
			Path  : useablePeriod/high/@value
			Source: ToTime
			Source: ToTime/text()
			
			Field
			Path  : ./
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: address-streetLine
			
			Field
			Path  : city
			Source: City.Code
			Source: City/Code/text()
			
			Field
			Path  : state
			Source: State.Code
			Source: State/Code/text()
			
			Field
			Path  : postalCode
			Source: Zip.Code
			Source: Zip/Code/text()
			
			Field
			Path  : country
			Source: Country.Code
			Source: Country/Code/text()
			
			Field
			Path  : county
			Source: County.Code
			Source: County/Code/text()
		-->
		<xsl:choose>
			<xsl:when test="string-length($addressStreet) or string-length($addressCity) or string-length($addressState) or string-length($addressZip) or string-length($addressCountry)">
				<addr use="{$addressUse}">
					<xsl:if test="string-length($addressStreet)"><xsl:apply-templates select="." mode="address-streetLine"><xsl:with-param name="streetText" select="$addressStreet"/></xsl:apply-templates></xsl:if>
					<xsl:if test="string-length($addressCity)"><city><xsl:value-of select="$addressCity"/></city></xsl:if>
					<xsl:if test="string-length($addressState)"><state><xsl:value-of select="$addressState"/></state></xsl:if>
					<xsl:if test="string-length($addressZip)"><postalCode><xsl:value-of select="$addressZip"/></postalCode></xsl:if>
					<xsl:choose>
						<xsl:when test="string-length($addressCountry)">
							<country><xsl:value-of select="$addressCountry"/></country>
						</xsl:when>
						<xsl:otherwise>
							<country nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="string-length($addressCounty)"><county><xsl:value-of select="$addressCounty"/></county></xsl:if>
					<xsl:if test="string-length($addressFromTime) or string-length($addressToTime)">
						<useablePeriod xsi:type="IVL_TS">
							<xsl:choose>
								<xsl:when test="string-length($addressFromTime)"><low value="{$addressFromTime}"/></xsl:when>
								<xsl:otherwise><low nullFlavor="UNK"/></xsl:otherwise>
							</xsl:choose>
							
							<xsl:choose>
								<xsl:when test="string-length($addressToTime)"><high value="{$addressToTime}"/></xsl:when>
								<xsl:otherwise><high nullFlavor="UNK"/></xsl:otherwise>
							</xsl:choose>
						</useablePeriod>
					</xsl:if>
				</addr>
			</xsl:when>
			<xsl:otherwise><addr nullFlavor="{$addrNullFlavor}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="address-streetLine">
		<xsl:param name="streetText"/>
		<xsl:param name="pieceIndex" select="'1'"/>
		
		<!--
			StructuredMapping: address-streetLine
			
			Field
			Path  : streetAddressLine
			Source: Street
			Source: Street/text()
			Note  : SDA stores multiple street address lines as a single
					semicolon-delimited string.  address-StreetLine parses
					the pieces of the line and exports them as multiple
					streetAddressLine elements.
		-->
		<xsl:variable name="currentPiece" select="isc:evaluate('piece',$streetText,';',$pieceIndex)"/>
		<xsl:if test="string-length($currentPiece)">
			<streetAddressLine><xsl:value-of select="normalize-space($currentPiece)"/></streetAddressLine>
			<xsl:apply-templates select="." mode="address-streetLine">
				<xsl:with-param name="streetText" select="$streetText"/>
				<xsl:with-param name="pieceIndex" select="$pieceIndex+1"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="address-country">
		<xsl:value-of select="text()"/>
	</xsl:template>
	
	<xsl:template match="*" mode="telecom">
		<xsl:choose>
			<xsl:when test="ContactInfo | InsuredContact">
				<xsl:variable name="telecomHomePhone">
					<xsl:apply-templates select="(ContactInfo|InsuredContact)/HomePhoneNumber" mode="telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomWorkPhone">
					<xsl:apply-templates select="(ContactInfo|InsuredContact)/WorkPhoneNumber" mode="telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomMobilePhone">
					<xsl:apply-templates select="(ContactInfo|InsuredContact)/MobilePhoneNumber" mode="telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomEmail" select="normalize-space((ContactInfo|InsuredContact)/EmailAddress/text())"/>
				
				<!--
					StructuredMapping: telecom
					
					Note  : The export of the @use attribute depends upon the type of number.
					For Home Phone, @use="HP".
					For Work Phone, @use="WP".
					For Mobile Phone, @use="MC".
					For E-mail, @use is omitted, and @value includes a "mailto:" prefix.
					All available types of telecom found in the SDA input are exported.
										
					Field
					Path  : @value
					Source: HomePhoneNumber
					Source: HomePhoneNumber/text()
					
					Field
					Path  : @value
					Source: WorkPhoneNumber
					Source: WorkPhoneNumber/text()
					
					Field
					Path  : @value
					Source: MobilePhoneNumber
					Source: MobilePhoneNumber/text()
					
					Field
					Path  : @value
					Source: EmailAddress
					Source: EmailAddress/text()
				-->
				<xsl:choose>
					<xsl:when test="string-length($telecomHomePhone) or string-length($telecomWorkPhone) or string-length($telecomMobilePhone) or string-length($telecomEmail)">
						<xsl:if test="string-length($telecomHomePhone)"><telecom use="HP" value="{concat('tel:', $telecomHomePhone)}"/></xsl:if>
						<xsl:if test="string-length($telecomWorkPhone)"><telecom use="WP" value="{concat('tel:', $telecomWorkPhone)}"/></xsl:if>
						<xsl:if test="string-length($telecomMobilePhone)"><telecom use="MC" value="{concat('tel:', $telecomMobilePhone)}"/></xsl:if>
						<xsl:if test="string-length($telecomEmail)"><telecom value="{concat('mailto:', $telecomEmail)}"/></xsl:if>
					</xsl:when>
					<xsl:otherwise><telecom nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><telecom nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="representedOrganization">
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="code-to-description">
						<xsl:with-param name="identityType" select="'Facility'"/>
						<xsl:with-param name="defaultDescription" select="Description/text()"/>
					</xsl:apply-templates>
				</xsl:variable>
				
				<!--
					StructuredMapping: representedOrganization
					
					Field
					Path  : id
					Source: CurrentProperty
					Source: ./
					StructuredMappingRef: id-Facility
					
					Field
					Path  : name
					Source: Code
					Source: Code/text()
					
					Field
					Path  : telecom
					Source: ContactInfo
					Source: ./ContactInfo
					StructuredMappingRef: telecom
					
					Field
					Path  : addr
					Source: Address
					Source: ./Address
					StructuredMappingRef: address
				-->
				<representedOrganization>
					<xsl:apply-templates select="." mode="id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)"><name><xsl:value-of select="$organizationName"/></name></xsl:when>
						<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="telecom"/>
					<xsl:apply-templates select="." mode="address-WorkPrimary"/>
					
					<xsl:if test="$homeCommunityOID or $homeCommunityCode or $homeCommunityName">
						<asOrganizationPartOf>
							<effectiveTime nullFlavor="UNK"/>
							<wholeOrganization>
								<xsl:apply-templates select="$homeCommunity/Organization" mode="id-Facility"/>

								<xsl:choose>
									<xsl:when test="string-length($homeCommunityName)"><name><xsl:value-of select="$homeCommunityName"/></name></xsl:when>
									<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
								</xsl:choose>
								
								<xsl:apply-templates select="$homeCommunity/Organization" mode="telecom"/>
								<xsl:apply-templates select="$homeCommunity/Organization" mode="address-WorkPrimary"/>
							</wholeOrganization>
						</asOrganizationPartOf>
					</xsl:if>
				</representedOrganization>
			</xsl:when>
			<xsl:otherwise>
				<representedOrganization>
					<id nullFlavor="{$idNullFlavor}"/>
					<name nullFlavor="UNK"/>
					<telecom nullFlavor="UNK"/>
					<addr nullFlavor="{$addrNullFlavor}"/>
				</representedOrganization>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="serviceProviderOrganization">
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="code-to-description">
						<xsl:with-param name="identityType" select="'Facility'"/>
						<xsl:with-param name="defaultDescription" select="Description/text()"/>
					</xsl:apply-templates>
				</xsl:variable>
				
				<!--
					StructuredMapping: serviceProviderOrganization
					
					Field
					Path  : id
					Source: CurrentProperty
					Source: ./
					StructuredMappingRef: id-Facility
					
					Field
					Path  : name
					Source: Code
					Source: Code/text()
					
					Field
					Path  : telecom
					Source: ContactInfo
					Source: ./ContactInfo
					StructuredMappingRef: telecom
					
					Field
					Path  : addr
					Source: Address
					Source: ./Address
					StructuredMappingRef: address
				-->
				<serviceProviderOrganization>
					<xsl:apply-templates select="." mode="id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)"><name><xsl:value-of select="$organizationName"/></name></xsl:when>
						<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="telecom"/>
					<xsl:apply-templates select="." mode="address-WorkPrimary"/>
				</serviceProviderOrganization>
			</xsl:when>
			<xsl:otherwise>
				<serviceProviderOrganization>
					<id nullFlavor="{$idNullFlavor}"/>
					<name nullFlavor="UNK"/>
					<telecom nullFlavor="UNK"/>
					<addr nullFlavor="{$addrNullFlavor}"/>
				</serviceProviderOrganization>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="representedOrganization-Document">
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="code-to-description">
						<xsl:with-param name="identityType" select="'HomeCommunity'"/>
						<xsl:with-param name="defaultDescription" select="Description/text()"/>
					</xsl:apply-templates>
				</xsl:variable>
				
				<representedOrganization>
					<xsl:apply-templates select="." mode="id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)"><name><xsl:value-of select="$organizationName"/></name></xsl:when>
						<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="telecom"/>
					<xsl:apply-templates select="." mode="address-WorkPrimary"/>
					
				</representedOrganization>
			</xsl:when>
			<xsl:otherwise>
				<representedOrganization>
					<id nullFlavor="{$idNullFlavor}"/>
					<name nullFlavor="UNK"/>
					<telecom nullFlavor="UNK"/>
					<addr nullFlavor="{$addrNullFlavor}"/>
				</representedOrganization>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="representedCustodianOrganization">
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="code-to-description">
						<xsl:with-param name="identityType" select="'Facility'"/>
						<xsl:with-param name="defaultDescription" select="Description/text()"/>
					</xsl:apply-templates>
				</xsl:variable>
				
				<representedCustodianOrganization>
					<xsl:apply-templates select="." mode="id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)"><name><xsl:value-of select="$organizationName"/></name></xsl:when>
						<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="telecom"/>
					<xsl:apply-templates select="." mode="address-WorkPrimary"/>
				</representedCustodianOrganization>
			</xsl:when>
			<xsl:otherwise>
				<representedCustodianOrganization>
					<id nullFlavor="{$idNullFlavor}"/>
					<name nullFlavor="UNK"/>
					<telecom nullFlavor="UNK"/>
					<addr nullFlavor="{$addrNullFlavor}"/>
				</representedCustodianOrganization>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="scopingOrganization">
		<xsl:variable name="organizationName">
			<xsl:apply-templates select="Code" mode="code-to-description">
				<xsl:with-param name="defaultDescription" select="Description/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<scopingOrganization>
			<xsl:choose>
				<xsl:when test="string-length($organizationName)"><name><xsl:value-of select="$organizationName"/></name></xsl:when>
				<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="." mode="telecom"/>
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
		</scopingOrganization>
	</xsl:template>
	
	<xsl:template match="*" mode="legalAuthenticator">
		<legalAuthenticator>
			<time value="{$currentDateTime}"/>
			<signatureCode code="S"/>
			
			<xsl:apply-templates select="." mode="assignedEntity"/>
		</legalAuthenticator>
	</xsl:template>
	
	<xsl:template match="*" mode="custodian">
		<custodian>
			<assignedCustodian>
				<xsl:apply-templates select="." mode="representedCustodianOrganization"/>
			</assignedCustodian>
		</custodian>
	</xsl:template>
	
	<!-- **The code template is deprecated as of HealthShare Core 13.**  Please use template generic-Coded. -->
	<xsl:template match="*" mode="code">
		<xsl:param name="narrativeLink"/>
		<xsl:param name="xsiType"/>
		
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="narrativeLink" select="$narrativeLink"/>
			<xsl:with-param name="xsiType" select="$xsiType"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="code-administrativeGender">
		<!--
			Field : Patient Gender Code
			Target: /ClinicalDocument/recordTarget/patientRole/patient/administrativeGenderCode/@code
			Source: HS.SDA3.Patient Gender.Code
			Source: /Container/Patient/Gender/Code
			Note  : @codeSystem and @codeSystemName are hard-coded to the administrativeGenderCode code system.
		-->
		<!--
			Field : Patient Gender Description
			Target: /ClinicalDocument/recordTarget/patientRole/patient/administrativeGenderCode/@displayName
			Source: HS.SDA3.Patient Gender.Code
			Source: /Container/Patient/Gender/Code
			Note  : @displayName is derived from the SDA Gender Code, not from the SDA Gender Description.
		-->
		<xsl:variable name="genderCode">
			<xsl:choose>
				<xsl:when test="starts-with(Gender/Code/text(),'M')">M</xsl:when>
				<xsl:when test="starts-with(Gender/Code/text(),'F')">F</xsl:when>
				<xsl:otherwise>UN</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="genderDescription">
			<xsl:choose>
				<xsl:when test="starts-with(Gender/Code/text(),'M')">Male</xsl:when>
				<xsl:when test="starts-with(Gender/Code/text(),'F')">Female</xsl:when>
				<xsl:otherwise>Undifferentiated</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- administrativeGenderCode does not allow for <translation>. -->
		<administrativeGenderCode code="{$genderCode}" codeSystem="{$administrativeGenderOID}" codeSystemName="{$administrativeGenderName}" displayName="{$genderDescription}"/>
	</xsl:template>

	<xsl:template match="*" mode="code-maritalStatus">
		<!--
			Field : Patient Marital Status
			Target: /ClinicalDocument/recordTarget/patientRole/patient/maritalStatusCode
			Source: HS.SDA3.Patient MaritalStatus
			Source: /Container/Patient/MaritalStatus
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$maritalStatusOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">maritalStatusCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="code-race">
		<!--
			Field : Patient Race
			Target: /ClinicalDocument/recordTarget/patientRole/patient/raceCode
			Source: HS.SDA3.Patient Races
			Source: /Container/Patient/Races/Race[1]
			Note  : Multiple race codes may be in the CDA header.  The first
					raceCode must be in namespace urn:hl7-org:v3 (hl7).  Any
					additional raceCodes must be in namespace urn:hl7-org:sdtc
					(sdtc).
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$raceAndEthnicityCDCOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">raceCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="code-additionalRace">
		<!--
			Field : Patient Additional Races
			Target: /ClinicalDocument/recordTarget/patientRole/patient/sdtc:raceCode
			Source: HS.SDA3.Patient Races
			Source: /Container/Patient/Races/Race[2..n]
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$raceAndEthnicityCDCOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">sdtc:raceCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="EthnicGroup" mode="code-ethnicGroup">
		<!--
			Field : Patient Ethnicity
			Target: /ClinicalDocument/recordTarget/patientRole/patient/ethnicGroupCode
			Source: HS.SDA3.Patient EthnicGroup
			Source: /Container/Patient/EthnicGroup
			Note  : ethnicGroupCode has a very small required value set.  If the CDA
					export logic detects that the SDA data cannot yield a compliant
					export, then nullFlavor="OTH" is exported and the SDA data is
					exported in a subordinate translation element.
			StructuredMappingRef: generic-Coded
		-->
		
		<xsl:variable name="valueSet">|2135-2!Hispanic or Latino|2186-5!Not Hispanic or Latino|</xsl:variable>
		
		<!-- descriptionFromValueSet is the indicator that Code/text() is in the value set. -->
		<xsl:variable name="descriptionFromValueSet">
			<xsl:value-of select="substring-before(substring-after($valueSet,concat('|',Code/text(),'!')),'|')"/>
		</xsl:variable>
		
		<xsl:variable name="displayName">
			<xsl:choose>
				<xsl:when test="string-length($descriptionFromValueSet)"><xsl:value-of select="$descriptionFromValueSet"/></xsl:when>
				<xsl:when test="string-length(Description/text())"><xsl:value-of select="Description/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="originalText">
			<xsl:choose>
				<xsl:when test="string-length(Description/text())"><xsl:value-of select="Description/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$displayName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="codeSystem">
			<xsl:choose>
				<xsl:when test="SDACodingStandard/text()=$raceAndEthnicityCDCName or SDACodingStandard/text()=$raceAndEthnicityCDCOID">
					<xsl:value-of select="$raceAndEthnicityCDCOID"/>
				</xsl:when>
				<xsl:when test="string-length(SDACodingStandard/text())">
					<xsl:apply-templates select="." mode="oid-for-code">
						<xsl:with-param name="Code" select="SDACodingStandard/text()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="codeSystemName">
			<xsl:choose>
				<xsl:when test="$codeSystem=$raceAndEthnicityCDCOID">
					<xsl:value-of select="$raceAndEthnicityCDCName"/>
				</xsl:when>
				<xsl:when test="string-length(SDACodingStandard/text())">
					<xsl:value-of select="SDACodingStandard/text()"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($descriptionFromValueSet) and $codeSystem=$raceAndEthnicityCDCOID">
				<ethnicGroupCode code="{Code/text()}" codeSystem="{$codeSystem}" codeSystemName="{$codeSystemName}" displayName="{$displayName}">
					<originalText><xsl:value-of select="$originalText"/></originalText>
				</ethnicGroupCode>
			</xsl:when>
			<xsl:otherwise>
				<ethnicGroupCode nullFlavor="OTH">
					<originalText><xsl:value-of select="$originalText"/></originalText>
					<translation code="{translate(Code/text(),' ','_')}" codeSystem="{$codeSystem}" codeSystemName="{$codeSystemName}" displayName="{$displayName}"/>
				</ethnicGroupCode>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="code-religiousAffiliation">
		<!--
			Field : Patient Religion
			Target: /ClinicalDocument/recordTarget/patientRole/patient/religiousAffiliationCode
			Source: HS.SDA3.Patient Religion
			Source: /Container/Patient/Religion
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$religiousAffiliationOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">religiousAffiliationCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="code-function">
		<!--
			StructuredMapping: code-function
			
			Field : Provider Role Coded
			Path  : ./
			Source: CareProvider
			Source: ./CareProvider
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$providerRoleOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">functionCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="code-interpretation">
		<!--
			Field : Result Interpretation
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.28']/entry/organizer/component/observation/interpretationCode
			Source: HS.SDA3.LabResultItem ResultInterpretation
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultInterpretation
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$observationInterpretationOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">interpretationCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="code-route">
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$nciThesaurusOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">routeCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="value-ST">
		<value xsi:type="ST"><xsl:value-of select="text()"/></value>
	</xsl:template>
	
	<xsl:template match="*" mode="value-PQ">
		<xsl:param name="units"/>
		
		<!--
			xsi type PQ requires that value be numeric and that
			unit be present.  If one of those conditions is not
			true, then export as a string.
		-->
		<xsl:choose>
			<xsl:when test="(number(text()) and string-length($units))">
				<value xsi:type="PQ" value="{text()}" unit="{$units}"/>
			</xsl:when>
			<xsl:when test="not(string-length($units))">
				<value xsi:type="ST"><xsl:value-of select="text()"/></value>
			</xsl:when>
			<xsl:when test="string-length($units)">
				<value xsi:type="ST"><xsl:value-of select="concat(text(), ' ', $units)"/></value>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="value-Coded">
		<xsl:param name="narrativeLink"/>
		<xsl:param name="xsiType"/>
		<xsl:param name="requiredCodeSystemOID"/>
		<xsl:param name="isCodeRequired" select="'0'"/>
		
		<!--
			StructuredMapping: value-Coded
			
			Field
			Path  : @code
			Source: Code
			Source: Code/text()
			
			Field
			Path  : @displayName
			Source: Description
			Source: Description/text()
			Note  : If Description does not have a value and Code has a value
					then Code is used to populate @displayName.
			
			Field
			Path  : @codeSystem
			Source: SDACodingStandard
			Source: SDACodingStandard/text()
			Note  : SDACodingStandard is intended to be a text name representation
					of the code system.  @codeSystem is an OID value.  It is derived
					by cross-referencing SDACodingStandard with the HealthShare OID
					Registry.
			
			Field
			Path  : @codeSystemName
			Source: SDACodingStandard
			Source: SDACodingStandard/text()
			
			Field
			Path  : originalText/text()
			Source: OriginalText
			Source: OriginalText/text()
			
			Field
			Path  : translation/@code
			Source: PriorCodes.PriorCode.Code
			Source: PriorCodes/PriorCode/Code/text()
			
			Field
			Path  : translation/@displayName
			Source: PriorCodes.PriorCode.Description
			Source: PriorCodes/PriorCode/Description/text()
			Note  : If Description does not have a value and Code has a value
					then Code is used to populate @displayName.
			
			Field
			Path  : translation/@codeSystem
			Source: PriorCodes.PriorCode.SDACodingStandard
			Source: PriorCodes/PriorCode/SDACodingStandard/text()
			Note  : SDACodingStandard is intended to be a text name representation
					of the code system.  @codeSystem is an OID value.  It is derived
					by cross-referencing SDACodingStandard with the HealthShare OID
					Registry.
			
			Field
			Path  : translation/@codeSystemName
			Source: PriorCodes.PriorCode.SDACodingStandard
			Source: PriorCodes/PriorCode/SDACodingStandard/text()
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="narrativeLink" select="$narrativeLink"/>
			<xsl:with-param name="xsiType" select="$xsiType"/>
			<xsl:with-param name="requiredCodeSystemOID" select="$requiredCodeSystemOID"/>
			<xsl:with-param name="isCodeRequired" select="$isCodeRequired"/>
			<xsl:with-param name="cdaElementName">value</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="value-CD">
		<xsl:apply-templates select="." mode="value-Coded">
			<xsl:with-param name="xsiType">CD</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="value-CE">
		<xsl:apply-templates select="." mode="value-Coded">
			<xsl:with-param name="xsiType">CE</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="value-IVL_PQ">
		<xsl:param name="referenceRangeLowValue"/>
		<xsl:param name="referenceRangeHighValue"/>
		<xsl:param name="referenceRangeUnits"/>
		
		<value xsi:type="IVL_PQ">
			<xsl:choose>
				<xsl:when test="string-length($referenceRangeLowValue) and string-length($referenceRangeUnits)"><low value="{$referenceRangeLowValue}" unit="{$referenceRangeUnits}"/></xsl:when>
				<xsl:when test="string-length($referenceRangeLowValue)"><low value="{$referenceRangeLowValue}"/></xsl:when>
				<xsl:otherwise><low nullFlavor="UNK"/></xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="string-length($referenceRangeHighValue) and string-length($referenceRangeUnits)"><high value="{$referenceRangeHighValue}" unit="{$referenceRangeUnits}"/></xsl:when>
				<xsl:when test="string-length($referenceRangeHighValue)"><high value="{$referenceRangeHighValue}"/></xsl:when>
				<xsl:otherwise><high nullFlavor="UNK"/></xsl:otherwise>
			</xsl:choose>
		</value>
	</xsl:template>

	<xsl:template match="*" mode="translation">
		<xsl:variable name="sdaCodingStandardOID">
			<xsl:apply-templates select="." mode="oid-for-code">
				<xsl:with-param name="Code" select="CodeSystem/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="CodingStandardIsOID">
			<xsl:apply-templates select="." mode="isOID">
				<xsl:with-param name="text" select="CodeSystem/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="CodingStandardOIDIsOID">
			<xsl:apply-templates select="." mode="isOID">
				<xsl:with-param name="text" select="$sdaCodingStandardOID"/>
			</xsl:apply-templates>
		</xsl:variable>
		<translation>
			<xsl:if test="string-length(Code/text())">
				<xsl:attribute name="code"><xsl:value-of select="Code/text()"/></xsl:attribute>
			</xsl:if>
			<!-- Export @codeSystem only if a code system OID value is available. -->
			<xsl:choose>
				<xsl:when test="$CodingStandardOIDIsOID='1'">
					<xsl:attribute name="codeSystem">
						<xsl:value-of select="$sdaCodingStandardOID"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="$CodingStandardIsOID='1'">
					<xsl:attribute name="codeSystem">
						<xsl:value-of select="CodeSystem/text()"/>
					</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<!-- Export @codeSystemName only if code system has a value and is not an OID. -->
			<xsl:if test="(string-length(CodeSystem/text())) and ($CodingStandardIsOID='0')">
				<xsl:attribute name="codeSystemName"><xsl:value-of select="CodeSystem/text()"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="string-length(Description/text())">
				<xsl:attribute name="displayName"><xsl:value-of select="Description/text()"/></xsl:attribute>
			</xsl:if>
		</translation>
	</xsl:template>

	<xsl:template match="*" mode="id-External">
		<!--
			StructuredMapping: id-External
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : SDA ExternalId is exported as id/@extension only when EnteredAt/Code
					is also present.  In that case the OID for EnteredAt/Code is also
					exported, as id/@root.  Otherwise <id nullFlavor="UNK"/> is exported.
		-->
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(ExternalId)">
				<id>
					<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
					<xsl:attribute name="extension"><xsl:value-of select="ExternalId/text()"/></xsl:attribute>
					<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-ExternalId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise><id nullFlavor="{$idNullFlavor}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="id-Placer">
		<!--
			StructuredMapping: id-Placer
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : SDA PlacerId is exported as id/@extension only when
					EnteringOrganization/Organization/Code or EnteredAt/Code
					is also present.  If one of those Codes is present then
					the OID for the first found of those Codes is also exported,
					as id/@root.  Otherwise a GUID is exported in @root and no
					@extension is exported.
		-->
		<xsl:choose>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(PlacerId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-PlacerId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(PlacerId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-PlacerId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id root="{isc:evaluate('createGUID')}" assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedPlacerId')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="id-Filler">
		<!--
			StructuredMapping: id-Filler
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : SDA FillerId is exported as id/@extension only when
					EnteringOrganization/Organization/Code or EnteredAt/Code
					is also present.  If one of those Codes is present then
					the OID for the first found of those Codes is also exported,
					as id/@root.  Otherwise a GUID is exported in @root and no
					@extension is exported.
		-->
		<xsl:choose>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(FillerId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-FillerId')"/></xsl:attribute>
			 	</id>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(FillerId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-FillerId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id root="{isc:evaluate('createGUID')}" assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedFillerId')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		id-ExternalPlacerOrFiller exports only the first found of ExternalId,
		PlacerId or FillerId.  If none found then export CDA <id> as a UUID.
	-->
	<xsl:template match="*" mode="id-ExternalPlacerOrFiller">
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(ExternalId)">
				<xsl:apply-templates select="." mode="id-External"/>
			</xsl:when>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(PlacerId)">
				<xsl:apply-templates select="." mode="id-Placer"/>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(PlacerId)">
				<xsl:apply-templates select="." mode="id-Placer"/>
			</xsl:when>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(FillerId)">
				<xsl:apply-templates select="." mode="id-Filler"/>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(FillerId)">
				<xsl:apply-templates select="." mode="id-Filler"/>
			</xsl:when>
			<xsl:otherwise><id root="{isc:evaluate('createUUID')}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="id-Medication">
		<xsl:apply-templates select="." mode="id-External"/>
		<xsl:apply-templates select="." mode="id-Placer"/>
		<xsl:apply-templates select="." mode="id-Filler"/>
	</xsl:template>
	
	<xsl:template match="*" mode="id-PrescriptionNumber">
		<!--
			StructuredMapping: id-PrescriptionNumber
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : SDA PrescriptionNumber is exported as id/@extension only
					when EnteredAt Code is also present.  In that case the
					OID for Entered At is also exported, as id/@root.
					Otherwise <id nullFlavor="UNK"/> is exported.
		-->
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(PrescriptionNumber)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PrescriptionNumber/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-PrescriptionNumber')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}" extension="{concat(EnteredAt/Code/text(), '-UnspecifiedPrescriptionNumber')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="id-Facility">
		<!--
			StructuredMapping: id-Facility
			
			Field
			Path  : @root
			Source: Code
			Source: Code/text()
			Note  : If SDA Code is an OID then Code is exported as id/@root
					and no id/@extension is included.  If SDA Code can be
					translated to an OID (i.e., is an IdentityCode defined
					in the HealthShare OID Registry) then that OID is
					exported as id/@root and Code is exported as id/@extension.
			
			Field
			Path  : @extension
			Source: Code
			Source: Code/text()
		-->
		<!--
			Check to see if the Code and OID values are actually OIDs.
		-->
		<xsl:variable name="CodeisOID">
			<xsl:apply-templates select="." mode="isOID">
				<xsl:with-param name="text" select="Code/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="facilityOID">
			<xsl:apply-templates select="." mode="oid-for-code">
				<xsl:with-param name="Code" select="Code/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="OIDisOID">
			<xsl:apply-templates select="." mode="isOID">
				<xsl:with-param name="text" select="$facilityOID"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:if test="$OIDisOID='1'"><id root="{$facilityOID}"/></xsl:if>
				<xsl:if test="$CodeisOID='0'">
					<id>
						<xsl:attribute name="root"><xsl:value-of select="$homeCommunityOID"/></xsl:attribute>
						<xsl:attribute name="extension"><xsl:value-of select="Code/text()"/></xsl:attribute>
						<xsl:attribute name="displayable">true</xsl:attribute>
					</id>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise><id nullFlavor="{$idNullFlavor}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="id-encounterLocation">
		<!-- The location might not be in the OID Registry, which is okay. -->
		<xsl:variable name="locationOID">
			<xsl:apply-templates select="." mode="oid-for-code">
				<xsl:with-param name="Code" select="Code/text()"/>
				<xsl:with-param name="default" select="''"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<!-- This template assumes that organization (if present) is in the OID Registry. -->
		<xsl:variable name="organizationOID">
			<xsl:apply-templates select="." mode="oid-for-code">
				<xsl:with-param name="Code" select="Organization/Code/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<!--
			StructuredMapping: id-encounterLocation
			
			Field
			Path  : @root
			Source: Organization.Code
			Source: Organization/Code/text()
			Note  : If SDA HealthCareFacility/Code and SDA HealthCareFacility/Organization/Code
					are both present then
					export @root=OrganizationOID and @extension=HealthCareFacility/Code.
					This condition takes precedence over the next condition to
					protect somewhat against the presence of an IdentityCode in the
					OID Registry that is the same as HealthCareFacility/Code but is
					not actually that facility/location.
					
					If HealthCareFacility/Code has an OID then
					export @root=HealthCareFacilityOID.
					
					If HealthCareFacility/Code does not have a value and
					HealthCareFacility/Organization/Code has a value then
					export @root=OrganizationOID.
					
					If HealthCareFacility/Code has a value but no OID and
					HealthCareFacility/Organization/Code does not have a value then
					export @root=HealthCareFacility/Code.
					This may not be valid CDA but at least returns some information.
			
			Field
			Path  : @extension
			Source: Code
			Source: Code/text()
		-->
		<id>
			<xsl:choose>
				<xsl:when test="string-length(Code/text()) and string-length(Organization/Code/text())">
					<xsl:attribute name="root"><xsl:value-of select="$organizationOID"/></xsl:attribute>
					<xsl:attribute name="extension"><xsl:value-of select="Code/text()"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="string-length($locationOID)">
					<xsl:attribute name="root"><xsl:value-of select="$locationOID"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="not(string-length(Code/text())) and string-length(Organization/Code/text())">
					<xsl:attribute name="root"><xsl:value-of select="$organizationOID"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="string-length(Code/text())">
					<xsl:attribute name="root"><xsl:value-of select="Code/text()"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
		</id>
	</xsl:template>
	
	<xsl:template match="*" mode="id-Document">
		<xsl:choose>
			<xsl:when test="$documentUniqueId and string-length($documentUniqueId)">
				<id root="{$documentUniqueId}"/>
			</xsl:when>
			<xsl:otherwise>
				<id root="{isc:evaluate('createUUID')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="id-Encounter">
		<!--
			StructuredMapping: id-Encounter
			
			Field
			Path  : @root
			Source: ParentProperty.HealthCareFacility.Organization.Code
			Source: ../HealthCareFacility/Organization/Code
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : The SDA EncounterNumber is cleansed of semicolons, colons,
					percent signs, spaces and double quotes by converting
					them to underscore before exporting @extension.
		-->
		<id>
			<xsl:attribute name="root"><xsl:apply-templates select="HealthCareFacility/Organization/Code" mode="code-to-oid"/></xsl:attribute>
			<xsl:attribute name="extension"><xsl:apply-templates select="EncounterNumber" mode="encounterNumber-converted"/></xsl:attribute>
			<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(HealthCareFacility/Organization/Code/text(), '-EncounterId')"/></xsl:attribute>
		</id>
	</xsl:template>

	<xsl:template match="*" mode="id-Clinician">
		<!--
			StructuredMapping: id-Clinician
			
			Field
			Path  : @root
			Source: SDACodingStandard
			Source: /SDACodingStandard
			Note  : If SDACodingStandard does not have a value then
					Code is exported to @root instead of @extension.
			
			Field
			Path  : @extension
			Source: Code
			Source: /Code
			Note  : If SDACodingStandard does not have a value then
					Code is exported to @root instead of @extension.
		-->
		<xsl:choose>
			<xsl:when test="string-length(SDACodingStandard) and string-length(Code)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="Code/text()"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="string-length(Code)">
				<id>
			 		<xsl:attribute name="root"><xsl:value-of select="$noCodeSystemOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="Code/text()"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise><id nullFlavor="{$idNullFlavor}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="id-HealthShare">
		<id root="{$healthShareOID}"/>
	</xsl:template>

	<xsl:template match="*" mode="id-PayerGroup">
		<!--
			StructuredMapping: id-PayerGroup
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : SDA GroupNumber is exported as @extension only when GroupName is also present.  In that case the OID for GroupName is also exported, as @root.  Otherwise <id nullFlavor="UNK"/> is exported.
		-->
		<xsl:choose>
			<xsl:when test="string-length(GroupName) and string-length(GroupNumber)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="GroupName/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="GroupNumber/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(GroupName/text(), '-PayerGroupId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise><id nullFlavor="{$idNullFlavor}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-IVL_TS">
		<xsl:choose>
			<xsl:when test="string-length(FromTime) or string-length(ToTime)">
				<effectiveTime xsi:type="IVL_TS">
					<xsl:apply-templates select="." mode="effectiveTime-low"/>
					<xsl:apply-templates select="." mode="effectiveTime-high"/>
				</effectiveTime>
			</xsl:when>
			<xsl:otherwise><effectiveTime xsi:type="IVL_TS" nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-PIVL_TS">
		<!--
			Field: Medication Frequency
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Source: HS.SDA3.AbstractOrder Frequency
			Source: /Container/Medications/Medication/Frequency
		-->
		<xsl:if test="string-length(normalize-space(Code/text()))">
			<!--
				CDA Administration Timing (from SDA Frequency) needs a number
				(periodValue) and a unit (periodUnit) to comprise an interval.
				institutionSpecified serves as a breadcrumb when (re-)importing
				the CDA to indicate whether the database stored data was
				actually an interval or a frequency.
				
				periodValue must be a number, and periodUnit must be a string
				without spaces.
				
				Despite its name, Frequency can be used to store any text,
				which means it could have text that indicates an interval or a
				frequency.
			-->

			<xsl:variable name="codeNormal" select="normalize-space(Code/text())"/>
			<xsl:variable name="codeLower" select="translate($codeNormal, $upperCase, $lowerCase)"/>
			<xsl:variable name="codeP1" select="isc:evaluate('piece', $codeLower, ' ', '1')"/>
			<xsl:variable name="codeP2" select="isc:evaluate('piece', $codeLower, ' ', '2')"/>
			<xsl:variable name="codeP3" select="isc:evaluate('piece', $codeLower, ' ', '3')"/>
			<xsl:variable name="codeNoSpaces" select="translate($codeLower,' ','')"/>
			<xsl:variable name="singular" select="'|s|sec|second|min|minute|h|hr|hour|d|day|w|week|mon|month|y|yr|year|'"/>
			<xsl:variable name="plural" select="'|s|sec|secs|seconds|min|mins|minutes|h|hr|hrs|hour|hours|d|day|days|w|week|weeks|mon|mons|month|months|y|yr|yrs|year|years|'"/>
			
			<xsl:choose>
				<!-- ex: "4 hours" (interval) -->
				<xsl:when test="number($codeP1) and contains($plural, concat('|',$codeP2, '|'))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{$codeP1}" unit="{$codeP2}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- BID means twice a day (frequency) -->
				<xsl:when test="$codeP1='bid'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="12" unit="h"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- TID means three times a day (frequency) -->
				<xsl:when test="$codeP1='tid'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="8" unit="h"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- QID means four times a day (frequency) -->
				<xsl:when test="$codeP1='qid'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="6" unit="h"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- nID means n times a day (frequency) -->
				<xsl:when test="contains($codeP1, 'id') and number(substring-before($codeP1, 'id'))">
					<xsl:variable name="numberOfTimes" select="substring-before($codeP1, 'id')"/>
					<xsl:variable name="periodValue" select="24 div $numberOfTimes"/>
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="{$periodValue}" unit="h"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- QD means once a day (frequency) -->
				<xsl:when test="$codeP1='qd'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="1" unit="d"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- QOD means every other day (frequency) -->
				<xsl:when test="$codeP1='qod'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="2" unit="d"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n seconds, minutes, hours, days, or weeks (interval) ('q' plus number plus unit) -->
				<xsl:when test="string-length($codeNoSpaces)>2 and starts-with($codeNoSpaces, 'q') and contains('|s|m|h|d|w|m|y|l|', concat('|',substring($codeNoSpaces,string-length($codeNoSpaces)),'|')) and number(substring($codeNoSpaces,2,string-length($codeNoSpaces)-2))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{number(substring($codeNoSpaces,2,string-length($codeNoSpaces)-2))}" unit="{substring($codeNoSpaces,string-length($codeNoSpaces))}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n seconds, minutes, hours, days, or weeks (interval) ('q' plus unit plus number) -->
				<xsl:when test="(starts-with($codeP1, 'qs') or starts-with($codeP1, 'qm') or starts-with($codeP1, 'qh') or starts-with($codeP1, 'qd') or starts-with($codeP1, 'qw')) and (number(substring($codeP1, 3)) or number($codeP2))">
					<xsl:variable name="periodValue">
						<xsl:choose>
							<xsl:when test="number(substring($codeP1, 3))"><xsl:value-of select="substring($codeP1, 3)"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$codeP2"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{$periodValue}" unit="{substring($codeP1,2,1)}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n months (interval) ('q' plus number plus 'mo') -->
				<xsl:when test="string-length($codeNoSpaces)>3 and starts-with($codeNoSpaces, 'q') and substring($codeNoSpaces,string-length($codeNoSpaces)-1,2)='mo' and number(substring($codeNoSpaces,2,string-length($codeNoSpaces)-3))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{number(substring($codeNoSpaces,2,string-length($codeNoSpaces)-3))}" unit="mon"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n months (interval) ('q' plus number plus 'mon') -->
				<xsl:when test="string-length($codeNoSpaces)>4 and starts-with($codeNoSpaces, 'q') and substring($codeNoSpaces,string-length($codeNoSpaces)-2,3)='mon' and number(substring($codeNoSpaces,2,string-length($codeNoSpaces)-4))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{number(substring($codeNoSpaces,2,string-length($codeNoSpaces)-4))}" unit="mon"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n months (interval) -->
				<xsl:when test="starts-with($codeP1, 'ql') and number(substring($codeP1, 3))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{substring($codeP1, 3)}" unit="mon"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n months (interval) -->
				<xsl:when test="starts-with($codeP1, 'ql') and number($codeP2)">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{$codeP2}" unit="mon"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- ex: "4 per hour" (frequency) -->
				<xsl:when test="number($codeP1) and contains('|a|an|per|x|', concat('|',$codeP2, '|')) and contains($singular, concat('|',$codeP3, '|'))">
					<xsl:variable name="periodUnit1">
						<xsl:choose>
							<xsl:when test="starts-with($codeP3, 'h')">h</xsl:when>
							<xsl:when test="starts-with($codeP3, 'd')">d</xsl:when>
							<xsl:when test="starts-with($codeP3, 'w')">w</xsl:when>
							<xsl:when test="starts-with($codeP3, 'mon')">mon</xsl:when>
							<xsl:when test="starts-with($codeP3, 'y')">y</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodUnitN">
						<xsl:choose>
							<xsl:when test="starts-with($codeP3, 'h')">min</xsl:when>
							<xsl:when test="starts-with($codeP3, 'd')">h</xsl:when>
							<xsl:when test="starts-with($codeP3, 'w')">d</xsl:when>
							<xsl:when test="starts-with($codeP3, 'mon')">d</xsl:when>
							<xsl:when test="starts-with($codeP3, 'y')">d</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodValue">
						<xsl:choose>
							<xsl:when test="$codeP1='1'">1</xsl:when>
							<xsl:when test="$periodUnit1='h'"><xsl:value-of select="60 div $codeP1"/></xsl:when>
							<xsl:when test="$periodUnit1='d'"><xsl:value-of select="24 div $codeP1"/></xsl:when>
							<xsl:when test="$periodUnit1='w'"><xsl:value-of select="7 div $codeP1"/></xsl:when>
							<xsl:when test="$periodUnit1='mon'"><xsl:value-of select="round(30 div $codeP1)"/></xsl:when>
							<xsl:when test="$periodUnit1='y'"><xsl:value-of select="round(365 div $codeP1)"/></xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodUnit">
						<xsl:choose>
							<xsl:when test="$codeP1='1'"><xsl:value-of select="$periodUnit1"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$periodUnitN"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="{$periodValue}" unit="{$periodUnit}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- ex: "4xD" (frequency) -->
				<xsl:when test="contains($codeP1, 'x') and not(string-length($codeP2)) and number(substring-before($codeP1, 'x')) and contains($singular, concat('|', substring-after($codeP1,'x'), '|'))">
					<xsl:variable name="tempValue" select="substring-before($codeP1,'x')"/>
					<xsl:variable name="tempUnit" select="substring-after($codeP1,'x')"/>
					<xsl:variable name="periodUnit1">
						<xsl:choose>
							<xsl:when test="starts-with($tempUnit, 'h')">h</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'd')">d</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'w')">w</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'mon')">mon</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'y')">y</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodUnitN">
						<xsl:choose>
							<xsl:when test="starts-with($tempUnit, 'h')">min</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'd')">h</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'w')">d</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'mon')">d</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'y')">d</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodValue">
						<xsl:choose>
							<xsl:when test="$tempValue='1'">1</xsl:when>
							<xsl:when test="$periodUnit1='h'"><xsl:value-of select="60 div $tempValue"/></xsl:when>
							<xsl:when test="$periodUnit1='d'"><xsl:value-of select="24 div $tempValue"/></xsl:when>
							<xsl:when test="$periodUnit1='w'"><xsl:value-of select="7 div $tempValue"/></xsl:when>
							<xsl:when test="$periodUnit1='mon'"><xsl:value-of select="round(30 div $tempValue)"/></xsl:when>
							<xsl:when test="$periodUnit1='y'"><xsl:value-of select="round(365 div $tempValue)"/></xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodUnit">
						<xsl:choose>
							<xsl:when test="$tempValue='1'"><xsl:value-of select="$periodUnit1"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$periodUnitN"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="{$periodValue}" unit="{$periodUnit}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- If we're out of scenarios from which we can reasonably deduce    -->
				<!-- the periodValue and periodUnit, then don't export effectiveTime. -->
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-FromTo">
		<xsl:param name="includeHighTime" select="true()"/>
		<xsl:param name="POCeffectiveTimeCenter" select="'0'"/>
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="$POCeffectiveTimeCenter='1' and string-length(FromTime/text()) and (FromTime/text()=ToTime/text())">
						<center><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></center>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length(FromTime/text())">
							<low><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low>
						</xsl:when>
						<xsl:otherwise>
							<low nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="string-length(ToTime/text()) and $includeHighTime = true()">
							<high><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></high>
						</xsl:when>
						<xsl:when test="not(string-length(ToTime/text())) and $includeHighTime = true()">
							<high nullFlavor="UNK"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-Identification">
		<xsl:param name="includeHighTime" select="true()"/>
		
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(IdentificationTime/text())">
					<low><xsl:attribute name="value"><xsl:apply-templates select="IdentificationTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low>
				</xsl:when>
				<xsl:otherwise>
					<low nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$includeHighTime = true()"><high nullFlavor="UNK"/></xsl:if>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-procedure">
		<xsl:param name="POCeffectiveTimeCenter" select="'0'"/>
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(FromTime/text()) or string-length(ToTime/text())">
					<xsl:choose>
						<xsl:when test="$POCeffectiveTimeCenter='1' and (FromTime/text()=ToTime/text())">
							<center><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></center>
						</xsl:when> 
						<xsl:otherwise>
							<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string-length(ProcedureTime)">
					<xsl:attribute name="value"><xsl:apply-templates select="ProcedureTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime">
		<xsl:param name="includeHighTime" select="true()"/>
		<xsl:param name="POCeffectiveTimeCenter" select="'0'"/>
		
		<xsl:choose>
			<xsl:when test="local-name() = 'EnteredOn'"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="." mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:when test="local-name() = 'ObservationTime'"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="." mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:when test="local-name() = 'IdentificationTime'">
				<effectiveTime>
					<xsl:apply-templates select="." mode="effectiveTime-low"/>
					<xsl:if test="$includeHighTime = true()"><xsl:apply-templates select="." mode="effectiveTime-high"/></xsl:if>
				</effectiveTime>
			</xsl:when>
			<xsl:when test="not(string-length(EnteredOn)) and not(string-length(FromTime)) and not(string-length(StartTime)) and not(string-length(ToTime)) and not(string-length(EndTime))">
				<effectiveTime>
					<low nullFlavor="UNK"/>
					<xsl:if test="$includeHighTime = true()"><high nullFlavor="UNK"/></xsl:if>
				</effectiveTime>
			</xsl:when>
			<xsl:when test="string-length(EnteredOn) or (string-length(FromTime) or string-length(StartTime)) or (string-length(ToTime) or string-length(EndTime))">
				<effectiveTime>
					<xsl:choose>
						<xsl:when test="string-length(EnteredOn)">
							<xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute>
						</xsl:when>
						<xsl:when test="$POCeffectiveTimeCenter='1' and string-length(FromTime/text()) and (FromTime/text()=ToTime/text())">
							<center>
								<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
							</center>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="effectiveTime-low"/>
							<xsl:if test="$includeHighTime = true()"><xsl:apply-templates select="." mode="effectiveTime-high"/></xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</effectiveTime>
			</xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="time">
		<xsl:choose>
			<xsl:when test="local-name() = 'EnteredOn'"><time><xsl:attribute name="value"><xsl:apply-templates select="." mode="xmlToHL7TimeStamp"/></xsl:attribute></time></xsl:when>
			<xsl:when test="(string-length(FromTime) or string-length(StartTime)) or (string-length(ToTime) or string-length(EndTime))">
				<time>
					<xsl:apply-templates select="." mode="effectiveTime-low"/>
					<xsl:apply-templates select="." mode="effectiveTime-high"/>
				</time>
			</xsl:when>
			<xsl:otherwise><time nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-low">
		<xsl:choose>
			<xsl:when test="string-length(FromTime)"><low><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low></xsl:when>
			<xsl:when test="string-length(StartTime)"><low><xsl:attribute name="value"><xsl:apply-templates select="StartTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low></xsl:when>
			<xsl:otherwise><low nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="effectiveTime-high">
		<xsl:choose>
			<xsl:when test="string-length(EndTime)"><high><xsl:attribute name="value"><xsl:apply-templates select="EndTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></high></xsl:when>
			<xsl:when test="string-length(ToTime)"><high><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></high></xsl:when>
			<xsl:otherwise><high nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="xmlToHL7TimeStamp">
		<xsl:value-of select="translate(text(), 'TZ:- ', '')"/>
	</xsl:template>

	<xsl:template match="*" mode="encounterLink-component">
		<!--
			StructuredMapping: encounterLink-component
			
			Field
			Path  : encounter
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: encounterLink-Detail
		-->
		<xsl:if test="string-length(EncounterNumber)">
			<xsl:variable name="encounter" select="key('EncNum', EncounterNumber)[1]"/>
			<xsl:variable name="isValidEncounter">
				<xsl:choose>
					<xsl:when test="string-length($encounter) > 0">
						<xsl:apply-templates select="$encounter/EncounterType" mode="encounter-IsValid"/>
					</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="$isValidEncounter = 'true'">
				<component>
					<xsl:apply-templates select="$encounter" mode="encounterLink-Detail"/>
				</component>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="encounterLink-entryRelationship">
		<!--
			StructuredMapping: encounterLink-entryRelationship
			
			Field
			Path  : encounter
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: encounterLink-Detail
		-->
		<xsl:if test="string-length(EncounterNumber)">
			<xsl:variable name="encounter" select="key('EncNum', EncounterNumber)[1]"/>
			<xsl:variable name="isValidEncounter">
				<xsl:choose>
					<xsl:when test="string-length($encounter) > 0">
						<xsl:apply-templates select="$encounter/EncounterType" mode="encounter-IsValid"/>
					</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="$isValidEncounter = 'true'">
				<entryRelationship typeCode="SUBJ">
					<xsl:apply-templates select="$encounter" mode="encounterLink-Detail"/>
				</entryRelationship>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="encounterLink-Detail">
		<!--
			StructuredMapping: encounterLink-Detail
			
			Field
			Path  : id/@root
			Source: HS.SDA3.Encounter HealthCareFacility.Organization.Code
			Source: /Container/Encounter/Encounter/HealthCareFacility/Organization/Code/text()
			
			Field
			Path  : id/@extension
			Source: CurrentProperty
			Source: ./text()
		-->
		<encounter classCode="ENC" moodCode="EVN">
			<id>
			 	<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="HealthCareFacility/Organization/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 	<xsl:attribute name="extension"><xsl:apply-templates select="EncounterNumber" mode="encounterNumber-converted"/></xsl:attribute>
			</id>
		</encounter>
	</xsl:template>

	<xsl:template match="EncounterType" mode="encounter-IsValid">
		<xsl:choose>
			<xsl:when test="contains('|I|O|E|', concat('|', text(), '|'))">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="narrativeLink-EncounterSuffix">
		<xsl:param name="entryNumber"/>
		<xsl:variable name="encounter" select="key('EncNum', EncounterNumber)"/>
		<xsl:variable name="encounterNumber"><xsl:apply-templates select="$encounter/EncounterNumber" mode="encounterNumber-converted"/></xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($encounter) > 0">
				<xsl:value-of select="concat(translate($encounter/HealthCareFacility/Organization/Code/text(),' ','_'), '.', $encounterNumber, '.', $entryNumber)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$entryNumber"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Code" mode="code-to-oid">
		<xsl:param name="identityType"/>
		
		<xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="text()"/></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Code" mode="code-to-description">
		<xsl:param name="identityType"/>
		<xsl:param name="defaultDescription" select="''"/>
		
		<!--
			If getDescriptionForOID finds no Description in the OID Registry for
			the specified Code, then return $defaultDescription if specified.
		-->
		<xsl:variable name="oidForCode"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="text()"/></xsl:apply-templates></xsl:variable>
		
		<!-- $descriptionForOID will be equal to $oidForCode if no Description was found. -->
		<xsl:variable name="descriptionForOID"><xsl:value-of select="isc:evaluate('getDescriptionForOID', $oidForCode, $identityType)"/></xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($oidForCode) and string-length($descriptionForOID) and not($oidForCode=$descriptionForOID)">
				<xsl:value-of select="$descriptionForOID"/>
			</xsl:when>
			<xsl:when test="string-length($descriptionForOID) and not(string-length($defaultDescription))">
				<xsl:value-of select="$descriptionForOID"/>
			</xsl:when>
			<xsl:when test="string-length($defaultDescription)">
				<xsl:value-of select="$defaultDescription"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!--
		snomed-Status is a special case value-Coded template for
		status fields that have to be SNOMED status codes.
	-->
	<xsl:template match="*" mode="snomed-Status">
		<xsl:param name="narrativeLink"/>
		
		<!--
			StructuredMapping: snomed-Status
			
			Field
			Path  : @code
			Source: Code
			Source: Code/text()
			
			Field
			Path  : @displayName
			Source: Description
			Source: Description/text()
			
			Field
			Path  : @codeSystem
			Source: SDACodingStandard
			Source: SDACodingStandard/text()
			
			Field
			Path  : @codeSystemName
			Source: SDACodingStandard
			Source: SDACodingStandard/text()
			
			Field
			Path  : translation
			Source: Code
			Source: Code/text()
		-->
		<xsl:variable name="xsiType" select="'CE'"/>
		
		<xsl:variable name="sdaCodingStandardOID"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
		
		<xsl:variable name="snomedStatusCodes">|55561003|73425007|90734009|7087005|255227004|415684004|410516002|413322009|</xsl:variable>
		<xsl:variable name="isValidSnomedCode" select="contains($snomedStatusCodes, concat('|', Code/text(), '|'))"/>
		
		<xsl:variable name="codeSystemOIDForTranslation">
			<xsl:choose>
				<xsl:when test="string-length($sdaCodingStandardOID)"><xsl:value-of select="$sdaCodingStandardOID"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codeSystemNameForTranslation">
			<xsl:choose>
				<xsl:when test="string-length($sdaCodingStandardOID)"><xsl:value-of select="SDACodingStandard/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="description"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:variable>
		
		<xsl:choose>
			<!--
				If the code system is SNOMED and code is a valid SNOMED status
				code, then export as is.
				
				Otherwise if code is a valid SNOMED status code but the code
				system is missing or is not SNOMED then export the code system
				as SNOMED and also export a translation element that has the
				original data from the SDA.
				
				Otherwise if code is not a valid SNOMED status code then try
				to find a SNOMED status code that is the closest fit to the
				one found in the SDA, or merely default it to Inactive.
				Export with the SNOMED code system and export a translation
				element that has the original data from the SDA.
			-->
			<xsl:when test="$isValidSnomedCode">
				<value code="{Code/text()}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="{$description}">
					<xsl:if test="string-length($xsiType)"><xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute></xsl:if>
					
					<xsl:if test="$sdaCodingStandardOID != $snomedOID"><translation code="{Code/text()}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{Description/text()}"/></xsl:if>
					<xsl:apply-templates select="PriorCodes/PriorCode[Type='O' or Type='A']" mode="translation"/>
				</value>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="." mode="snomed-Status-Code"/></xsl:variable>
				<xsl:variable name="codeUpper" select="translate(Code/text(), $lowerCase, $upperCase)"/>
				<xsl:variable name="description2">
					<xsl:choose>
						<xsl:when test="$codeUpper = 'A'">Active</xsl:when>
						<xsl:when test="$codeUpper = 'C'">Inactive</xsl:when>
						<xsl:when test="$codeUpper = 'H'">On Hold</xsl:when>
						<xsl:when test="$codeUpper = 'IP'">Active</xsl:when>
						<xsl:when test="$codeUpper = 'D'">Inactive</xsl:when>
						<xsl:otherwise><xsl:value-of select="$description"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<value code="{$snomedStatusCode}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="{$description2}">
					<xsl:if test="string-length($xsiType)"><xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute></xsl:if>
					
					<translation code="{translate(Code/text(),' ','_')}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{$description}"/>
					<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="translation"/>
				</value>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		snomed-Status-Code returns a SNOMED status code, based
		on the Code and Description properties and the list of
		valid SNOMED status codes.
	-->
	<xsl:template match="*" mode="snomed-Status-Code">
		<xsl:variable name="codeUpper" select="translate(Code/text(), $lowerCase, $upperCase)"/>
		<xsl:variable name="descUpper" select="translate(Description/text(), $lowerCase, $upperCase)"/>
		
		<xsl:choose>
			<xsl:when test="contains('|55561003|73425007|90734009|7087005|255227004|415684004|410516002|413322009|',concat('|',Code/text(),'|'))"><xsl:value-of select="Code/text()"/></xsl:when>
			<xsl:when test="$codeUpper = 'A'">55561003</xsl:when>
			<xsl:when test="$codeUpper = 'C'">73425007</xsl:when>
			<xsl:when test="$codeUpper = 'H'">421139008</xsl:when>
			<xsl:when test="$codeUpper = 'IP'">55561003</xsl:when>
			<xsl:when test="$codeUpper = 'INT'">73425007</xsl:when>
			<xsl:when test="$codeUpper = 'D'">73425007</xsl:when>
			<xsl:when test="$codeUpper = 'E'">73425007</xsl:when>
			<xsl:when test="contains($descUpper, 'INACTIVE')">73425007</xsl:when>
			<xsl:when test="contains($descUpper, 'NO LONGER ACTIVE')">73425007</xsl:when>
			<xsl:when test="contains($descUpper, 'ACTIVE')">55561003</xsl:when>
			<xsl:when test="contains($descUpper, 'CHRONIC')">90734009</xsl:when>
			<xsl:when test="contains($descUpper, 'INTERMITTENT')">7087005</xsl:when>
			<xsl:when test="contains($descUpper, 'RECUR')">255227004</xsl:when>
			<xsl:when test="contains($descUpper, 'RULE OUT')">415684004</xsl:when>
			<xsl:when test="contains($descUpper, 'RULED OUT')">410516002</xsl:when>
			<xsl:when test="contains($descUpper, 'FOOD')">414285001</xsl:when>
			<xsl:when test="contains($descUpper, 'RESOLVED')">413322009</xsl:when>
			<xsl:when test="$codeUpper = 'R'">73425007</xsl:when>
			<xsl:otherwise>73425007</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- generic-Coded has common logic for handling coded element fields. -->
	<xsl:template match="*" mode="generic-Coded">
		<xsl:param name="narrativeLink"/>
		<xsl:param name="xsiType"/>
		<xsl:param name="requiredCodeSystemOID"/>
		<xsl:param name="isCodeRequired" select="'0'"/>
		<xsl:param name="writeOriginalText" select="'1'"/>
		<xsl:param name="cdaElementName" select="'code'"/>
		<xsl:param name="hsCustomPairElementName"/>
		<xsl:param name="displayText"/>
		
		<!--
			StructuredMapping: generic-Coded
			
			Field
			Path  : @code
			Source: Code
			Source: Code/text()
			
			Field
			Path  : @displayName
			Source: Description
			Source: Description/text()
			Note  : If Description does not have a value and Code has a value
					then Code is used to populate @displayName.
			
			Field
			Path  : @codeSystem
			Source: SDACodingStandard
			Source: SDACodingStandard/text()
			Note  : SDACodingStandard is intended to be a text name representation
					of the code system.  @codeSystem is an OID value.  It is derived
					by cross-referencing SDACodingStandard with the HealthShare OID
					Registry.
			
			Field
			Path  : @codeSystemName
			Source: SDACodingStandard
			Source: SDACodingStandard/text()
			
			Field
			Path  : originalText/text()
			Source: OriginalText
			Source: OriginalText/text()
			
			Field
			Path  : translation/@code
			Source: PriorCodes.PriorCode.Code
			Source: PriorCodes/PriorCode/Code/text()
			
			Field
			Path  : translation/@displayName
			Source: PriorCodes.PriorCode.Description
			Source: PriorCodes/PriorCode/Description/text()
			Note  : If Description does not have a value and Code has a value
					then Code is used to populate @displayName.
			
			Field
			Path  : translation/@codeSystem
			Source: PriorCodes.PriorCode.SDACodingStandard
			Source: PriorCodes/PriorCode/SDACodingStandard/text()
			Note  : SDACodingStandard is intended to be a text name representation
					of the code system.  @codeSystem is an OID value.  It is derived
					by cross-referencing SDACodingStandard with the HealthShare OID
					Registry.
			
			Field
			Path  : translation/@codeSystemName
			Source: PriorCodes.PriorCode.SDACodingStandard
			Source: PriorCodes/PriorCode/SDACodingStandard/text()
		-->
		
		<!--
			requiredCodeSystemOID is the OID of a specifically required codeSystem.
			requiredCodeSystemOID may be multiple OIDs, delimited by vertical bar.
			
			isCodeRequired indicates whether or not code nullFlavor is allowed.
			
			cdaElementName is the element (code, value, maritalStatusCode, etc.)
			
			displayText can override the SDA information as the source for displayName.
		-->
		
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="not(string-length($hsCustomPairElementName))"><xsl:value-of select="translate(Code/text(),' ','_')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="NVPair[Name/text()=concat($hsCustomPairElementName,'Code')]/Value/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="descriptionFromSDA">
			<xsl:choose>
				<xsl:when test="not(string-length($hsCustomPairElementName)) and string-length(Description/text())"><xsl:value-of select="Description/text()"/></xsl:when>
				<xsl:when test="string-length($hsCustomPairElementName) and string-length(NVPair[Name/text()=concat($hsCustomPairElementName,'Description')]/Value/text())"><xsl:value-of select="NVPair[Name/text()=concat($hsCustomPairElementName,'Description')]/Value/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$code"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="string-length($displayText)"><xsl:value-of select="$displayText"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$descriptionFromSDA"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codingStandard">
			<xsl:choose>
				<xsl:when test="not(string-length($hsCustomPairElementName))"><xsl:value-of select="SDACodingStandard/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="NVPair[Name/text()=concat($hsCustomPairElementName,'CodingStandard')]/Value/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="sdaCodingStandardOID">
			<xsl:apply-templates select="." mode="oid-for-code">
				<xsl:with-param name="Code" select="$codingStandard"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($code)">
			
				<!--
					If a translation element is required for this coded element,
					the translation will use the SDACodingStandard OID from the
					input SDA as the basis for translation codeSystem and
					codeSystemName.
				-->
				<xsl:variable name="codeSystemOIDForTranslation">
					<xsl:choose>
						<xsl:when test="string-length($sdaCodingStandardOID)"><xsl:value-of select="$sdaCodingStandardOID"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="codeSystemNameForTranslation">
					<xsl:choose>
						<xsl:when test="string-length($sdaCodingStandardOID)"><xsl:value-of select="$codingStandard"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$noCodeSystemName"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<!--
					If the requirements for this coded element require
					a code element to be exported regardless of the
					SDACodingStandard value, $noCodeSystem may need to
					be forced in as the code system.
				-->
				<xsl:variable name="codeSystemOIDPrimary">
					<xsl:choose>
						<xsl:when test="string-length($requiredCodeSystemOID) and not(contains(concat('|',$requiredCodeSystemOID,'|'),concat('|',$sdaCodingStandardOID,'|')))">
							<xsl:choose>
								<xsl:when test="not(contains($requiredCodeSystemOID,'|'))">
									<xsl:value-of select="$requiredCodeSystemOID"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring-before($requiredCodeSystemOID,'|')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="not(string-length($requiredCodeSystemOID)) and $isCodeRequired='1' and not(string-length($sdaCodingStandardOID))"><xsl:value-of select="$noCodeSystemOID"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$sdaCodingStandardOID"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="codeSystemNamePrimary"><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$codeSystemOIDPrimary"/></xsl:apply-templates></xsl:variable>
				
				<!--
					If the requirements for this coded element specify a
					certain code system and the SDACodingStandard is not
					that code system, then a translation element will need
					to be exported for the original SDA data.
					
					If no particular codeSystem is required, and <code> is
					not required to have a @code, and SDACodingStandard is
					missing from the SDA data, then a translation element
					will need to be exported for the original SDA data,
					with $noCodeSystem as the code system.
					
					For all other cases, no need to build a translation.
				-->
				<xsl:variable name="addTranslation">
					<xsl:choose>
						<xsl:when test="string-length($requiredCodeSystemOID) and not(contains(concat('|',$requiredCodeSystemOID,'|'),concat('|',$sdaCodingStandardOID,'|')))">1</xsl:when>
						<xsl:when test="not(string-length($requiredCodeSystemOID)) and $isCodeRequired='0' and not(string-length($sdaCodingStandardOID))">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<!--
					If the requirements for this coded element specify a
					certain code system, and SDACodingStandard is not that
					code system or is missing, and <code> is not required
					to have @code, then it is okay to export nullFlavor.
					
					For all other cases, export @code for <code> is required.
				-->
				<xsl:variable name="makeNullFlavor">
					<xsl:choose>
						<xsl:when test="string-length($requiredCodeSystemOID) and $isCodeRequired='0' and not(contains(concat('|',$requiredCodeSystemOID,'|'),concat('|',$sdaCodingStandardOID,'|')))">1</xsl:when>
						<xsl:when test="not(string-length($requiredCodeSystemOID)) and $isCodeRequired='0' and not(string-length($sdaCodingStandardOID))">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
						
				<xsl:element name="{$cdaElementName}">
					<xsl:choose>
						<xsl:when test="$makeNullFlavor='1'">
							<xsl:choose>
								<xsl:when test="$addTranslation='1'">
									<xsl:attribute name="nullFlavor">OTH</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="string-length($xsiType)"><xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute></xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="code"><xsl:value-of select="translate($code,' ','_')"/></xsl:attribute>
							<xsl:attribute name="codeSystem"><xsl:value-of select="$codeSystemOIDPrimary"/></xsl:attribute>
							<xsl:attribute name="codeSystemName"><xsl:value-of select="$codeSystemNamePrimary"/></xsl:attribute>
							<xsl:if test="string-length($description)"><xsl:attribute name="displayName"><xsl:value-of select="$description"/></xsl:attribute></xsl:if>
							<xsl:if test="string-length($xsiType)"><xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute></xsl:if>
						</xsl:otherwise>
					</xsl:choose>
							
					<xsl:if test="$writeOriginalText='1'">
						<originalText>
							<xsl:choose>
								<xsl:when test="string-length($narrativeLink)"><reference value="{$narrativeLink}"/></xsl:when>
								<xsl:when test="string-length(OriginalText)"><xsl:value-of select="OriginalText"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$description"/></xsl:otherwise>
							</xsl:choose>
						</originalText>
					</xsl:if>
							
					<xsl:if test="$addTranslation='1'"><translation code="{translate($code,' ','_')}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{$descriptionFromSDA}"/></xsl:if>
					<xsl:apply-templates select="PriorCodes/PriorCode[Type='O' or Type='A']" mode="translation"/>
				</xsl:element>
			</xsl:when>
			
			<!--
				If there is no Code, then add as much information
				to this nullFlavored element as is available.
			-->
			<xsl:otherwise>
				<xsl:variable name="CodingStandardIsOID">
					<xsl:apply-templates select="." mode="isOID">
						<xsl:with-param name="text" select="$codingStandard"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="CodingStandardOIDIsOID">
					<xsl:apply-templates select="." mode="isOID">
						<xsl:with-param name="text" select="$sdaCodingStandardOID"/>
					</xsl:apply-templates>
				</xsl:variable>
				<!-- 
					When attributes other than nullFlavor are exported, the
					XSLT has no control over the order in which the attributes
					actually appear in the output XML.
				-->
				<xsl:element name="{$cdaElementName}">
					<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
					<xsl:if test="string-length($xsiType)">
						<xsl:attribute name="xsi:type">
							<xsl:value-of select="$xsiType"/>
						</xsl:attribute>
					</xsl:if>
					<!-- Export @codeSystem only if a coding standard OID value is available. -->
					<xsl:choose>
						<xsl:when test="$CodingStandardOIDIsOID='1'">
							<xsl:attribute name="codeSystem">
								<xsl:value-of select="$sdaCodingStandardOID"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:when test="$CodingStandardIsOID='1'">
							<xsl:attribute name="codeSystem">
								<xsl:value-of select="$sdaCodingStandard"/>
							</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<!-- Export @codeSystemName only if coding standard has a value and is not an OID. -->
					<xsl:if test="(string-length($codingStandard)) and ($CodingStandardIsOID='0')">
						<xsl:attribute name="codeSystemName">
							<xsl:value-of select="$codingStandard"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="string-length($description)">
						<xsl:attribute name="displayName">
							<xsl:value-of select="$description"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$writeOriginalText='1'">
						<originalText>
							<xsl:choose>
								<xsl:when test="string-length($narrativeLink)"><reference value="{$narrativeLink}"/></xsl:when>
								<xsl:when test="string-length(OriginalText)"><xsl:value-of select="OriginalText"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$description"/></xsl:otherwise>
							</xsl:choose>
						</originalText>
					</xsl:if>
					<xsl:apply-templates select="PriorCodes/PriorCode[Type='O' or Type='A']" mode="translation"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		code-for-oid returns the IdentityCode for a specified OID.
		If no IdentityCode is found, then $default is returned.
	-->
	<xsl:template match="*" mode="code-for-oid">
		<xsl:param name="OID"/>
		<xsl:param name="default" select="$OID"/>
		
		<xsl:value-of select="isc:evaluate('getCodeForOID',$OID,'',$default)"/>
	</xsl:template>
	
	<!--
		oid-for-code returns the OID for a specified IdentityCode.
		If no OID is found, then $default is returned.
	-->
	<xsl:template match="*" mode="oid-for-code">
		<xsl:param name="Code"/>
		<xsl:param name="default" select="$Code"/>
		
		<xsl:value-of select="isc:evaluate('getOIDForCode',$Code,'',$default)"/>
	</xsl:template>
	
	<!--
		telecom-regex implements pattern checking against
		two regular expressions: '\+?[-0-9().]+' and '.\d+.'
		
		This template is needed because fn:matches is not
		available to XSLT 1.0.
		
		Return the normalize-space of the original value if
		it passes, return nothing if it does not.
	-->
	<xsl:template match="*" mode="telecom-regex">
		<xsl:variable name="telecomToUse">
			<xsl:choose>
				<xsl:when test="starts-with(normalize-space(text()),'+')"><xsl:value-of select="substring(normalize-space(text()),2)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space(text())"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!--
			The string MAY start with plus sign (+).
			
			After that, the next char (or first, if no "+") MUST
			be hyphen, or left paren, or right paren, or a single
			numeric digit.
			
			For the remaining chars, they can be any characters.
			However, if the first non-"+" char was NOT a digit,
			then at least one of the remaining chars MUST be a digit.
		-->
		<xsl:if test="substring($telecomToUse,1,1)='0' or number(substring($telecomToUse,1,1)) or (string-length($telecomToUse)>1 and translate(substring($telecomToUse,1,1),'()-','')='' and not(translate(substring($telecomToUse,2),'0123456789','')=$telecomToUse))"><xsl:value-of select="normalize-space(text())"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="encounterNumber-converted">
		<xsl:variable name="encounterNumberLower" select="translate(text(),$upperCase,$lowerCase)"/>
		<xsl:variable name="encounterNumberClean" select="translate(text(),';:% &#34;','_____')"/>
		<xsl:choose>
			<xsl:when test="starts-with($encounterNumberLower,'urn:uuid:')">
				<xsl:value-of select="substring($encounterNumberClean,10)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$encounterNumberClean"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="document-title">
		<xsl:param name="title1"/>
		
		<xsl:variable name="title2">
			<xsl:value-of select="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='IncompleteResult']/text()"/>
		</xsl:variable>
		<title>
			<xsl:choose>
				<xsl:when test="string-length($title2)">
					<xsl:value-of select="concat($title1,' ',$title2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$title1"/>
				</xsl:otherwise>
			</xsl:choose>
		</title>
	</xsl:template>
	
	<!--
		narrativeDateFromODBC takes a date value that is expected
		to be in ODBC format YYYY-MM-DDTHH:MM:SSZ, and removes the
		letters "T" and "Z" to provide for a better format for
		display in CDA section narratives.
	-->
	<xsl:template match="*" mode="narrativeDateFromODBC">
		<xsl:value-of select="translate(text(),'TZ',' ')"/>
	</xsl:template>
	
	<!--
		encompassingEncounterNumber returns the SDA EncounterNumber
		of the encounter to export to CDA encompassingEncounter.
		This value will be used as the CDA encounter id/@extension.
	-->
	<xsl:template match="*" mode="encompassingEncounterNumber">
		<xsl:value-of select="/Container/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='EncompassingEncounterNumber']/text()"/>
	</xsl:template>
	
	<!--
		encompassingEncounterOrganization returns the SDA Encounter
		HealthCareFacility Organization Code of the encounter to
		export to CDA encompassingEncounter.  This value will be
		used as the CDA encounter id/@root.
	-->
	<xsl:template match="*" mode="encompassingEncounterOrganization">
		<xsl:value-of select="/Container/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='EncompassingEncounterOrganization']/text()"/>
	</xsl:template>
	
	<!--
		encompassingEncounterToEncounters returns a flag to indicate
		whether to export the desired encompassingEncounter also
		to the Encounters section.  Return 1 = export to Encounters
		section, return anything else = do not export to Encounters
		section.
	-->
	<xsl:template match="*" mode="encompassingEncounterToEncounters">
		<xsl:value-of select="/Container/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='EncompassingEncounterToEncounters']/text()"/>
	</xsl:template>
	
	<!--
		descriptionOrCode receives a node-spec for an SDA CodeTableDetail
		item, and returns the Description text if present, otherwise it
		returns the Code text.
	-->
	<xsl:template match="*" mode="descriptionOrCode">
		<xsl:choose>
			<xsl:when test="string-length(Description)"><xsl:value-of select="Description"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="Code"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		codeOrDescription receives a node-spec for an SDA CodeTableDetail
		item, and returns the Code text if present, otherwise it returns
		the Description text.
	-->
	<xsl:template match="*" mode="codeOrDescription">
		<xsl:choose>
			<xsl:when test="string-length(Code)"><xsl:value-of select="Code"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="Description"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		originalTextOrDescriptionOrCode receives a node-spec for an
		SDA CodeTableDetail item and returns the OriginalText text
		if present, otherwise it returns the Description text if
		present, otherwise it returns the Code text.
	-->
	<xsl:template match="*" mode="originalTextOrDescriptionOrCode">
		<xsl:choose>
			<xsl:when test="string-length(OriginalText)"><xsl:value-of select="OriginalText"/></xsl:when>
			<xsl:when test="string-length(Description)"><xsl:value-of select="Description"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="Code"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		Determine if the specified text is an OID.  It is
		considered an OID if all of the following are true:
		- Starts with "1." or "2."
		- Is at least 10 characters long
		- Has 4 or more "."
		- Has no characters other than numbers and "."'s
	-->
	<xsl:template match="*" mode="isOID">
		<xsl:param name="text"/>
		
		<xsl:choose>
			<xsl:when test="(starts-with($text,'1.') or starts-with($text,'2.')) and string-length($text)>10 and string-length(translate($text,translate($text,'.',''),''))>3 and not(string-length(translate($text,'0123456789.','')))">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		This template exports the sub-nodes of the AdditionalDocumentInfo XML data.
		This template in general handles most of the transform of that XML data to
		valid C32 CDA.  Specialized handling of certain elements is indicated by the
		xsl:when conditions in the processing of the current Element.
	 -->
	<xsl:template match="Element" mode="fn-Document-Element">
		<xsl:choose>
			<!-- xsl:when conditions are special cases where the data needs to be massaged for C32 purposes. -->
			<xsl:when test="Name/text()='effectiveTime'">
				<xsl:apply-templates select="." mode="fn-Document-IVL_TS"/>
			</xsl:when>
			<xsl:when test="Name/text()='telecom'">
				<xsl:apply-templates select="." mode="fn-Document-TelecomDetail"/>
			</xsl:when>
			<xsl:when test="Name/text()='assignedEntity'">
				<xsl:apply-templates select="." mode="fn-Document-AssignedEntity"/>
			</xsl:when>
			<xsl:when test="Name/text()='associatedEntity'">
				<xsl:apply-templates select="." mode="fn-Document-AssociatedEntity"/>
			</xsl:when>
			<xsl:when test="Name/text()='assignedAuthor'">
				<xsl:apply-templates select="." mode="fn-Document-AssignedAuthor"/>
			</xsl:when>
			<xsl:when test="Name/text()='serviceEvent'">
				<xsl:apply-templates select="." mode="fn-Document-ServiceEvent"/>
			</xsl:when>
			<xsl:when test="Name/text()='encompassingEncounter'">
				<xsl:apply-templates select="." mode="fn-Document-EncompassingEncounter"/>
			</xsl:when>
			<xsl:when test="contains('|guardianOrganization|providerOrganization|manufacturerOrganization|wholeOrganization|representedOrganization|representedCustodianOrganization|receivedOrganization|scopingOrganization|serviceProviderOrganization|',concat('|',Name/text(),'|'))">
				<xsl:apply-templates select="." mode="fn-Document-Organization"/>
			</xsl:when>
			<xsl:when test="Name/text()='relatedEntity'">
				<xsl:apply-templates select="." mode="fn-Document-RelatedEntity"/>
			</xsl:when>
			<xsl:when test="Name/text()='patientRole'">
				<xsl:apply-templates select="." mode="fn-Document-PatientRole"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Otherwise, generic handling of the element. -->
				<xsl:element name="{Name/text()}">
					<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
					<xsl:apply-templates select="Elements/Element" mode="fn-Document-Element"/>
					<xsl:if test="string-length(translate(Value/text(),'&#9;&#10;&#13;&#32;',''))">
						<xsl:value-of select="Value/text()"/>
					</xsl:if>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Attribute" mode="fn-Document-ElementAttribute">
		<xsl:attribute name="{Name/text()}"><xsl:value-of select="Value/text()"/></xsl:attribute>
	</xsl:template>
	
	<!-- Export nullFlavor for addr if it is completely missing from the current Elements collection. -->
	<xsl:template match="Elements" mode="fn-Document-Addr">
		<xsl:choose>
			<xsl:when test="Element[Name/text()='addr']">
				<xsl:apply-templates select="Element[Name/text()='addr']" mode="fn-Document-Element"/>
			</xsl:when>
			<xsl:otherwise><addr nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- assignedAuthor needs to have addr and telecom filled in with nullFlavor if missing from the current Elements collection. -->
	<!-- assignedAuthor needs to have representedOrganization filled in with nullFlavor if both assignedPerson and representedOrganization are missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-AssignedAuthor">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Addr"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Telecom"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedPerson']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedAuthoringDevice']" mode="fn-Document-Element"/>
			<xsl:choose>
				<xsl:when test="Elements/Element[Name/text()='representedOrganization']">
					<xsl:apply-templates select="Elements/Element[Name/text()='representedOrganization']" mode="fn-Document-Organization"/>
				</xsl:when>
				<xsl:when test="not(Elements/Element[Name/text()='assignedPerson'])">
					<representedOrganization>
						<id nullFlavor="UNK"/>
						<name nullFlavor="UNK"/>
						<telecom nullFlavor="UNK"/>
						<addr nullFlavor="UNK"/>
					</representedOrganization>
				</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- assignedEntity needs to have addr and telecom filled in with nullFlavor if missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-AssignedEntity">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Id"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Addr"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Telecom"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedPerson']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='representedOrganization']" mode="fn-Document-Organization"/>
		</xsl:element>
	</xsl:template>
	
	<!-- associatedEntity needs to have addr and telecom filled in with nullFlavor if missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-AssociatedEntity">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Id"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Addr"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Telecom"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='associatedPerson']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='scopingOrganization']" mode="fn-Document-Organization"/>
		</xsl:element>
	</xsl:template>
	
	<!-- Input is authenticator or legalAuthenticator. -->
	<!-- These need to have time filled in with nullFlavor if missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-Authenticator">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Time-TS"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='signatureCode']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedEntity']" mode="fn-Document-AssignedEntity"/>
		</xsl:element>
	</xsl:template>
	
	<!-- author needs to have time filled in with nullFlavor if missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-Author">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='functionCode']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Time-TS"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedAuthor']" mode="fn-Document-AssignedAuthor"/>
		</xsl:element>
	</xsl:template>
	
	<!-- dataEnterer needs to have time filled in with nullFlavor if missing from HeaderInfo item. -->
	<xsl:template match="Element" mode="fn-Document-DataEnterer">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='functionCode']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Time-TS"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedEntity']" mode="fn-Document-Element"/>
		</xsl:element>
	</xsl:template>
	
	<!-- encompassingEncounter needs to have effectiveTime filled in with nullFlavor if missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-EncompassingEncounter">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-Document-Element"/>
			<xsl:choose>
				<xsl:when test="Elements/Element[Name/text()='effectiveTime']">
					<xsl:apply-templates select="Elements/Element[Name/text()='effectiveTime']" mode="fn-Document-IVL_TS"/>
				</xsl:when>
				<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="Elements/Element[Name/text()='dischargeDispositionCode']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='responsibleParty']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='encounterParticipant']" mode="fn-Document-EncounterParticipant"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='location']" mode="fn-Document-Element"/>
		</xsl:element>
	</xsl:template>
	
	<!-- encounterParticipant needs to have time filled in with nullFlavor if missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-EncounterParticipant">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Time-TS"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedEntity']" mode="fn-Document-AssignedEntity"/>
		</xsl:element>
	</xsl:template>
	
	<!-- Export nullFlavor for id if it is completely missing from the current Elements collection. -->
	<xsl:template match="Elements" mode="fn-Document-Id">
		<xsl:choose>
			<xsl:when test="Element[Name/text()='id']">
				<xsl:apply-templates select="Element[Name/text()='id']" mode="fn-Document-Element"/>
			</xsl:when>
			<xsl:otherwise><id nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- For time and effectiveTime that are typed as IVL_TS, make sure that any values include HHMMSS , because the C32 validator requires it. -->
	<xsl:template match="Element" mode="fn-Document-IVL_TS">
		<xsl:element name="{Name/text()}">
			<xsl:choose>
				<!-- If the input is a TS with just nullFlavor then export the specified nullFlavor in both low and high. -->
				<xsl:when test="Attributes/Attribute[Name/text()='nullFlavor'] and not(Elements/Element)">
					<low>
						<xsl:attribute name="nullFlavor">
							<xsl:value-of select="Attributes/Attribute[Name/text()='nullFlavor']/Value/text()"/>
						</xsl:attribute>
					</low>
					<high>
						<xsl:attribute name="nullFlavor">
							<xsl:value-of select="Attributes/Attribute[Name/text()='nullFlavor']/Value/text()"/>
						</xsl:attribute>
					</high>
				</xsl:when>
				<!-- If the input is a TS value then export that value to low and set high to nulFlavor. -->
				<xsl:when test="Attributes/Attribute[Name/text()='value'] and not(Elements/Element)">
					<low>
						<xsl:attribute name="value">
							<xsl:apply-templates select="Attributes/Attribute[Name/text()='value']" mode="fn-Document-TimeValue"/>
						</xsl:attribute>
					</low>
					<high nullFlavor="UNK"/>
				</xsl:when>
				<!-- If IVL_TS low and/or high is present, then export both low and high. -->
				<xsl:when test="Elements/Element[Name/text()='low'] or Elements/Element[Name/text()='high']">
					<xsl:choose>
						<xsl:when test="Elements/Element[Name/text()='low'] and not(string-length(Elements/Element[Name/text()='low']/Attributes/Attribute[Name/text()='nullFlavor']/Value/text()))">
							<low>
								<xsl:attribute name="value">
									<xsl:apply-templates select="Elements/Element[Name/text()='low']/Attributes/Attribute[Name/text()='value']" mode="fn-Document-TimeValue"/>
								</xsl:attribute>
							</low>
						</xsl:when>
						<xsl:otherwise>
							<low nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="Elements/Element[Name/text()='high'] and not(string-length(Elements/Element[Name/text()='high']/Attributes/Attribute[Name/text()='nullFlavor']/Value/text()))">
							<high>
								<xsl:attribute name="value">
									<xsl:apply-templates select="Elements/Element[Name/text()='high']/Attributes/Attribute[Name/text()='value']" mode="fn-Document-TimeValue"/>
								</xsl:attribute>
							</high>
						</xsl:when>
						<xsl:otherwise>
							<high nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!--
		Inputs can be any of:
		- guardianOrganization
		- providerOrganization
		- manufacturerOrganization
		- wholeOrganization
		- representedOrganization
		- representedCustodianOrganization
		- receivedOrganization|scopingOrganization
		- serviceProviderOrganization
	-->
	<!-- These need to have telecom and addr filled in with nullFlavor if missing from HeaderInfo item. -->
	<xsl:template match="Element" mode="fn-Document-Organization">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='name']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Telecom"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Addr"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='standardIndustryClassCode']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='asOrganizationPartOf']" mode="fn-Document-Element"/>
		</xsl:element>
	</xsl:template>
	
	<!-- patientRole needs to have addr and telecome filled in with nullFlavor if missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-PatientRole">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Addr"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Telecom"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='patient']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='providerOrganization']" mode="fn-Document-Organization"/>
		</xsl:element>
	</xsl:template>
	
	<!-- relatedEntity needs to have addr, telecom, effectiveTime and time filled in with nullFlavor if missing from HeaderInfo item. -->
	<xsl:template match="Element" mode="fn-Document-RelatedEntity">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Addr"/>
			<xsl:apply-templates select="Elements" mode="fn-Document-Telecom"/>
			<xsl:choose>
				<xsl:when test="Elements/Element[Name/text()='effectiveTime']">
					<xsl:apply-templates select="Elements/Element[Name/text()='effectiveTime']" mode="fn-Document-IVL_TS"/>
				</xsl:when>
				<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="Elements/Element[Name/text()='relatedPerson']" mode="fn-Document-Element"/>
		</xsl:element>
	</xsl:template>
	
	<!-- serviceEvent needs to have effectiveTime low and high filled in with nullFlavor if missing from the current Elements collection. -->
	<xsl:template match="Element" mode="fn-Document-ServiceEvent">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-Document-Element"/>
			<xsl:choose>
				<xsl:when test="Elements/Element[Name/text()='effectiveTime']">
					<xsl:apply-templates select="Elements/Element[Name/text()='effectiveTime']" mode="fn-Document-IVL_TS"/>
				</xsl:when>
				<xsl:otherwise>
					<effectiveTime>
						<low nullFlavor="UNK"/>
						<high nullFlavor="UNK"/>
					</effectiveTime>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="Elements/Element[Name/text()='performer']" mode="fn-Document-Element"/>
		</xsl:element>
	</xsl:template>
	
	<!-- Export nullFlavor for telecom if it is completely missing from the current Elements collection. -->
	<xsl:template match="Elements" mode="fn-Document-Telecom">
		<xsl:choose>
			<xsl:when test="Element[Name/text()='telecom']">
				<xsl:apply-templates select="Element[Name/text()='telecom']" mode="fn-Document-TelecomDetail"/>
			</xsl:when>
			<xsl:otherwise><telecom nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- For telecom, remove spaces from the value because the regex used by the C32 validator does not allow it. -->
	<xsl:template match="Element" mode="fn-Document-TelecomDetail">
		<xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-TelecomAttribute"/>
		</xsl:element>
	</xsl:template>
	
	<!-- For telecom, remove spaces from the value because the regex used by the C32 validator does not allow it. -->
	<xsl:template match="Attribute" mode="fn-Document-TelecomAttribute">
		<xsl:attribute name="{Name/text()}"><xsl:value-of select="translate(Value/text(),' ','')"/></xsl:attribute>
	</xsl:template>
	
	<!-- Export nullFlavor for TS time if it is completely missing from the current Elements collection. -->
	<xsl:template match="Elements" mode="fn-Document-Time-TS">
		<xsl:choose>
			<xsl:when test="Element[Name/text()='time']">
				<xsl:apply-templates select="Element[Name/text()='time']" mode="fn-Document-TS"/>
			</xsl:when>
			<xsl:otherwise><time nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- For a time or effectiveTime value, make sure that it includes HHMMSS, because the C32 validator requires it. -->
	<xsl:template match="Attribute" mode="fn-Document-TimeValue">
		<xsl:variable name="cdaDateTimeValue" select="Value/text()"/>
		<xsl:variable name="delimiter">
			<xsl:choose>
				<xsl:when test="contains($cdaDateTimeValue,'-')">-</xsl:when>
				<xsl:when test="contains($cdaDateTimeValue,'+')">+</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="cdaDateTime">
			<xsl:choose>
				<xsl:when test="string-length($delimiter)">
					<xsl:value-of select="substring-before($cdaDateTimeValue,$delimiter)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$cdaDateTimeValue"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="cdaTimeZone">
			<xsl:if test="string-length($delimiter)">
				<xsl:value-of select="substring-after($cdaDateTimeValue,$delimiter)"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="newCdaDateTime">
			<xsl:choose>
				<xsl:when test="string-length($cdaDateTime)=8">
					<xsl:value-of select="concat($cdaDateTime,'000000')"/>
				</xsl:when>
				<xsl:when test="string-length($cdaDateTime)=12">
					<xsl:value-of select="concat($cdaDateTime,'00')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$cdaDateTime"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($cdaTimeZone)">
				<xsl:value-of select="concat($newCdaDateTime,$delimiter,$cdaTimeZone)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$newCdaDateTime"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- For time and effectiveTime that are typed as TS, make sure any value include HHMMSS , because the C32 validator requires it. -->
	<xsl:template match="Element" mode="fn-Document-TS">
		<xsl:element name="{Name/text()}">
			<xsl:choose>
				<!-- If nullFlavor then export the specified nullFlavor plus any other attributes. -->
				<xsl:when test="Attributes/Attribute[Name/text()='nullFlavor']">
					<xsl:apply-templates select="Attributes/Attribute" mode="fn-Document-ElementAttribute"/>
				</xsl:when>
				<!-- If effectiveTime is just a single value then export that value. -->
				<xsl:when test="Attributes/Attribute[Name/text()='value']">
					<xsl:attribute name="value">
						<xsl:apply-templates select="Attributes/Attribute[Name/text()='value']" mode="fn-Document-TimeValue"/>
					</xsl:attribute>
				</xsl:when>
				<!-- If we have an IVL_TS feeding this TS then take the first found of low and high and use that for value. -->
				<xsl:when test="Elements/Element[Name/text()='low'] or Elements/Element[Name/text()='high']">
					<xsl:choose>
						<xsl:when test="Elements/Element[Name/text()='low'] and not(string-length(Elements/Element[Name/text()='low']/Attributes/Attribute[Name/text()='nullFlavor']/Value/text()))">
							<xsl:attribute name="value">
								<xsl:apply-templates select="Elements/Element[Name/text()='low']/Attributes/Attribute[Name/text()='value']" mode="fn-Document-TimeValue"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:when test="Elements/Element[Name/text()='high'] and not(string-length(Elements/Element[Name/text()='high']/Attributes/Attribute[Name/text()='nullFlavor']/Value/text()))">
							<xsl:attribute name="value">
								<xsl:apply-templates select="Elements/Element[Name/text()='high']/Attributes/Attribute[Name/text()='value']" mode="fn-Document-TimeValue"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
