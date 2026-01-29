<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
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
		<xsl:if test="$documentExportType='NEHTADischargeSummary' or $documentExportType='NEHTASharedHealthSummary'">
			<performer typeCode="PRF">
				<xsl:apply-templates select="parent::node()" mode="time"/>
				<xsl:apply-templates select="." mode="assignedEntity-performer"/>
			</performer>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="informant">
		<!--
			StructuredMapping: informant
			
			Field
			Path  : ./
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
			Path  : ./
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
		<!--
			This AU version of author-Document is a copy of
			the standard author-Human, with a change to the
			assignedAuthor template call.
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
			<xsl:apply-templates select="." mode="assignedAuthor-Document"/>
		</author>
	</xsl:template>
	
	<xsl:template match="*" mode="author-Human">
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
		<!--
			This AU version of assignedAuthor-Document is a copy
			of the standard assignedAuthor-Human, with some changes.
		-->
		<assignedAuthor classCode="ASSIGNED">
			<!-- Clinician ID -->
			<xsl:apply-templates select="." mode="id-Clinician"/>

			<!--
				For AU, document author comes from /Container/Patient/EnteredBy.
				Therefore it will not have a CareProviderType property, and so will
				get a default value for document author role/occupation code.
				See careProviderType-ANZSCO.
			-->
			<xsl:apply-templates select="." mode="careProviderType-ANZSCO"/>
			
			<!-- Author Address -->
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<!-- Author Telecom -->
			<xsl:apply-templates select="." mode="telecom"/>

			<!-- Person -->
			<xsl:apply-templates select="." mode="assignedPerson-Document"/>
						
			<!-- Represented Organization -->
			<xsl:apply-templates select="../EnteredAt" mode="representedOrganization"/>
		</assignedAuthor>
	</xsl:template>
	
	
	<xsl:template match="*" mode="assignedEntity-performer">
		<assignedEntity classCode="ASSIGNED">
			<!-- Contact Identifier -->
			<xsl:apply-templates select="." mode="id-Clinician"/>
			
			<!--
				For AU, assignedEntity performer comes from an EnteredBy
				property.  Therefore it will not have a CareProviderType property,
				and so will get a default value for document author role/occupation
				code. See careProviderType-ANZSCO.
			-->
			<xsl:apply-templates select="." mode="careProviderType-ANZSCO"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="telecom"/>
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="assignedPerson"/>
		</assignedEntity>
	</xsl:template>
	
	<xsl:template match="*" mode="assignedEntity-encounterParticipant">
		<assignedEntity classCode="ASSIGNED">
			<!-- Contact Identifier -->
			<xsl:apply-templates select="." mode="id-Clinician"/>
			
			<!--
				Admitting, Attending and Consulting clinicians
				are CareProvider, which includes CareProviderType, which
				enables the specification of valid ANZSCO role/occupation
				data.  However, Referring clinician does not, and will be
				given a default value.  See careProviderType-ANZSCO.
			-->
			<xsl:apply-templates select="." mode="careProviderType-ANZSCO"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="telecom"/>
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="assignedPerson"/>
		</assignedEntity>
	</xsl:template>
	
	<xsl:template match="*" mode="assignedEntity-LegalAuthenticator">
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
			<xsl:apply-templates select="$homeCommunity/Organization" mode="representedOrganization"/>
		</assignedEntity>
	</xsl:template>
	
	<xsl:template match="*" mode="id-sdtcPatient">
		<xsl:param name="xpathContext"/>
		<!-- NEHTA does not allow for exporting sdtc:patient. -->
	</xsl:template>
	
	<xsl:template match="*" mode="associatedEntity">
		<xsl:param name="contactType"/>
		
		<!--
			StructuredMapping: associatedEntity
			
			Field
			Path  : associatedEntity/id
			Source: ExternalId
			Source: ExternalId/text()
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : associatedEntity/code
			Source: Relationship
			Source: ./Relationship
			StructuredMappingRef: generic-Coded
			
			Field
			Path  : associatedEntity/addr
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
			
			Field
			Path  : associatedEntity/telecom
			Source: ContactInfo
			Source: ./ContactInfo
			StructuredMappingRef: telecom
			
			Field
			Path  : associatedEntity/associatedPerson/name
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
			<xsl:apply-templates select="." mode="name-Person"/>
			<xsl:apply-templates select="." mode="asEntityIdentifier-Person"/>
		</assignedPerson>
	</xsl:template>
	
	<xsl:template match="*" mode="assignedPerson-Document">
		<assignedPerson>
			<xsl:apply-templates select="." mode="name-Person"/>
			<xsl:apply-templates select="." mode="asEntityIdentifier-Person"/>
			<!-- ext:asEmployment - Use EnteredAt. -->
			<xsl:if test="$documentExportType='NEHTASharedHealthSummary' or $documentExportType='NEHTAEventSummary' or $documentExportType='NEHTAeReferral'">
				<xsl:apply-templates select="../EnteredAt" mode="employment"/>
			</xsl:if>
		</assignedPerson>
	</xsl:template>
	
	<xsl:template match="*" mode="associatedPerson">
		<associatedPerson>
			<xsl:apply-templates select="." mode="name-Person"/>
			<xsl:apply-templates select="." mode="asEntityIdentifier-Person"/>
		</associatedPerson>
	</xsl:template>
	
	<xsl:template match="*" mode="associatedPerson-Referee">
		<associatedPerson>
			<xsl:apply-templates select="." mode="name-Person"/>
			<xsl:apply-templates select="." mode="asEntityIdentifier-Person"/>
			<xsl:apply-templates select="../ReferredToOrganization/Organization" mode="employment"/>
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
		<!--
			AU requires that at least family name have a value.
			If Name/FamilyName/text() is not present then try
			to parse it from Description/text().
		-->
		<xsl:variable name="normalizedDescription" select="normalize-space(Description/text())"/>
		<xsl:choose>
			<xsl:when test="string-length($normalizedDescription) or Name">
				<xsl:variable name="contactName" select="$normalizedDescription"/>
				<xsl:variable name="contactPrefix" select="Name/NamePrefix/text()"/>
				<xsl:variable name="contactFirstName">
					<xsl:choose>
						<xsl:when test="string-length(Name/GivenName/text())">
							<xsl:value-of select="Name/GivenName/text()"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,',')">
							<xsl:value-of select="substring-after($normalizedDescription,',')"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription)">
							<xsl:value-of select="substring-before($normalizedDescription,' ')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="contactMiddleName" select="Name/MiddleName/text()"/>
				<xsl:variable name="contactLastName">
					<xsl:choose>
						<xsl:when test="string-length(Name/FamilyName/text())">
							<xsl:value-of select="Name/FamilyName/text()"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,',')">
							<xsl:value-of select="substring-before($normalizedDescription,',')"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,' ')">
							<xsl:value-of select="substring-after($normalizedDescription,' ')"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription)">
							<xsl:value-of select="$normalizedDescription"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="contactSuffix" select="Name/ProfessionalSuffix/text()"/>
				
				<xsl:choose>
					<!--<xsl:when test="string-length($contactName) or string-length($contactFirstName) or string-length($contactLastName)">-->
					<xsl:when test="string-length($contactLastName)">
						<name use="L">
							<!--<xsl:if test="string-length($contactName)"><xsl:value-of select="$contactName"/></xsl:if>-->
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
	
	<xsl:template match="*" mode="name-Person-Narrative">
		<!--
			AU requires that person names in the narrative
			be formatted as: Name Title(s), Given Name(s),
			Family Name(s), Name Suffix(es).
		-->
		<xsl:variable name="normalizedDescription" select="normalize-space(Description/text())"/>
		<xsl:choose>
			<xsl:when test="string-length($normalizedDescription) or Name">
				<xsl:variable name="contactName" select="$normalizedDescription"/>
				<xsl:variable name="contactPrefix" select="Name/NamePrefix/text()"/>
				<xsl:variable name="contactFirstName">
					<xsl:choose>
						<xsl:when test="string-length(Name/GivenName/text())">
							<xsl:value-of select="Name/GivenName/text()"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,',')">
							<xsl:value-of select="substring-after($normalizedDescription,',')"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription)">
							<xsl:value-of select="substring-before($normalizedDescription,' ')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="contactMiddleName" select="Name/MiddleName/text()"/>
				<xsl:variable name="contactLastName">
					<xsl:choose>
						<xsl:when test="string-length(Name/FamilyName/text())">
							<xsl:value-of select="Name/FamilyName/text()"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,',')">
							<xsl:value-of select="substring-before($normalizedDescription,',')"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,' ')">
							<xsl:value-of select="substring-after($normalizedDescription,' ')"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription)">
							<xsl:value-of select="$normalizedDescription"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="contactSuffix" select="Name/ProfessionalSuffix/text()"/>
				
				<xsl:variable name="displayName">
					<xsl:if test="string-length($contactFirstName) or string-length($contactLastName)">
						<xsl:if test="string-length($contactPrefix)"><xsl:value-of select="concat($contactPrefix,' ')"/></xsl:if>
						<xsl:if test="string-length($contactFirstName)"><xsl:value-of select="concat($contactFirstName,' ')"/></xsl:if>
						<xsl:if test="string-length($contactMiddleName)"><xsl:value-of select="concat($contactMiddleName,' ')"/></xsl:if>
						<xsl:if test="string-length($contactLastName)"><xsl:value-of select="concat($contactLastName,' ')"/></xsl:if>
						<xsl:if test="string-length($contactSuffix)"><xsl:value-of select="$contactSuffix"/></xsl:if>
					</xsl:if>
				</xsl:variable>
				
				<xsl:value-of select="normalize-space($displayName)"/>
			</xsl:when>
		</xsl:choose>
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
		<!-- For AU, there is no address use "HP", only "H". -->
		<xsl:apply-templates select="." mode="address-Home"/>
	</xsl:template>
	
	<xsl:template match="*" mode="address-Home">
		<xsl:apply-templates select="." mode="address">
			<xsl:with-param name="addressUse">H</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="address-Postal">
		<xsl:apply-templates select="." mode="address">
			<xsl:with-param name="addressUse">PST</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="address">
		<xsl:param name="addressUse" select="'WP'"/>
		
		<xsl:choose>
			<xsl:when test="Address | InsuredAddress">
				<xsl:apply-templates select="Address | InsuredAddress" mode="address-Individual">
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
			Path  : usablePeriod/low/@value
			Source: FromTime
			Source: FromTime/text()
			
			Field
			Path  : usablePeriod/high/@value
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
		<!-- For AU, country must match a Name (not Code) from ISO3166-1 -->
		<xsl:variable name="addressCountry1" select="text()"/>
		<xsl:variable name="addressCountry2" select="translate($addressCountry1,$lowerCase,$upperCase)"/>
		<xsl:choose>
			<xsl:when test="$addressCountry2 = 'AUSTRALIA'">Australia</xsl:when>
			<xsl:when test="$addressCountry2 = 'AU'">Australia</xsl:when>
			<xsl:when test="$addressCountry2 = 'AUS'">Australia</xsl:when>
			<xsl:when test="$addressCountry2 = 'USA'">United States of America</xsl:when>
			<xsl:when test="$addressCountry2 = 'US'">United States of America</xsl:when>
			<xsl:when test="$addressCountry2 = 'UNITED STATES'">United States of America</xsl:when>
			<xsl:otherwise><xsl:value-of select="$addressCountry1"/></xsl:otherwise>
		</xsl:choose>
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
	
	
	<!-- <xsl:template match="*" mode="representedOrganization-Document"> SEE BASE TEMPLATE -->
	
	<!-- <xsl:template match="*" mode="representedOrganization-HealthPlan"> SEE BASE TEMPLATE -->
	
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
					
					<xsl:apply-templates select="." mode="asEntityIdentifier-Organization"/>
					
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
	
	<xsl:template match="*" mode="representedOrganization-Recipient">
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="code-to-description">
						<xsl:with-param name="identityType" select="'Facility'"/>
						<xsl:with-param name="defaultDescription" select="Description/text()"/>
					</xsl:apply-templates>
				</xsl:variable>
				
				<representedOrganization>
					<xsl:apply-templates select="." mode="id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)"><name><xsl:value-of select="$organizationName"/></name></xsl:when>
						<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					
					<xsl:if test="Organization">
						<asOrganizationPartOf>
							<effectiveTime nullFlavor="UNK"/>
							<wholeOrganization>
								<xsl:apply-templates select="Organization/Code" mode="id-Facility"/>

								<xsl:choose>
									<xsl:when test="string-length(Organization/Description/text())"><name><xsl:value-of select="Organization/Description/text()"/></name></xsl:when>
									<xsl:when test="string-length(Organization/Code/text())"><name><xsl:value-of select="Organization/Code/text()"/></name></xsl:when>
									<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
								</xsl:choose>
								
								<xsl:apply-templates select="Organization" mode="asEntityIdentifier-Organization"/>
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
				
				<serviceProviderOrganization>
					<xsl:apply-templates select="." mode="id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)"><name><xsl:value-of select="$organizationName"/></name></xsl:when>
						<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="telecom"/>
					<xsl:apply-templates select="." mode="address-WorkPrimary"/>
										
					<xsl:if test="Organization">
						<asOrganizationPartOf>
							<effectiveTime nullFlavor="UNK"/>
							<wholeOrganization>
								<xsl:apply-templates select="Organization/Code" mode="id-Facility"/>

								<xsl:choose>
									<xsl:when test="string-length(Organization/Description/text())"><name><xsl:value-of select="Organization/Description/text()"/></name></xsl:when>
									<xsl:when test="string-length(Organization/Code/text())"><name><xsl:value-of select="Organization/Code/text()"/></name></xsl:when>
									<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
								</xsl:choose>
								
								<xsl:apply-templates select="Organization" mode="telecom"/>
								<xsl:apply-templates select="Organization" mode="address-WorkPrimary"/>
								<xsl:apply-templates select="Organization" mode="asEntityIdentifier-Organization"/>
							</wholeOrganization>
						</asOrganizationPartOf>
					</xsl:if>
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
	
	<xsl:template match="*" mode="legalAuthenticator">
		<legalAuthenticator>
			<time value="{$currentDateTime}"/>
			<signatureCode code="S"/>
			
			<xsl:apply-templates select="." mode="assignedEntity-LegalAuthenticator"/>
		</legalAuthenticator>
	</xsl:template>
	
	
	<xsl:template match="*" mode="custodian">
		<custodian>
			<assignedCustodian>
				<xsl:apply-templates select="." mode="representedCustodianOrganization"/>
			</assignedCustodian>
		</custodian>
	</xsl:template>

	<xsl:template match="*" mode="code-administrativeGender">
		<xsl:variable name="genderCode">
			<xsl:choose>
				<xsl:when test="starts-with(Gender/Code/text(),'M')">M</xsl:when>
				<xsl:when test="starts-with(Gender/Code/text(),'F')">F</xsl:when>
				<xsl:when test="starts-with(Gender/Code/text(),'I')">I</xsl:when>
				<xsl:otherwise>N</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="genderDescription">
			<xsl:choose>
				<xsl:when test="starts-with(Gender/Code/text(),'M')">Male</xsl:when>
				<xsl:when test="starts-with(Gender/Code/text(),'F')">Female</xsl:when>
				<xsl:when test="starts-with(Gender/Code/text(),'I')">Intersex or Indeterminate</xsl:when>
				<xsl:otherwise>Not Stated/Inadequately Described</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- administrativeGenderCode does not allow for <translation>. -->
		<administrativeGenderCode code="{$genderCode}" codeSystem="2.16.840.1.113883.13.68" codeSystemName="AS 5017-2006 Health Care Client Identifier Sex" displayName="{$genderDescription}"/>
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

	<xsl:template match="*" mode="code-route">
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$nciThesaurusOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">routeCode</xsl:with-param>
		</xsl:apply-templates>
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
		<translation code="{Code/text()}">
			<xsl:attribute name="codeSystem"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="CodeSystem/text()"/></xsl:apply-templates></xsl:attribute>
			<xsl:attribute name="codeSystemName"><xsl:value-of select="CodeSystem/text()"/></xsl:attribute>
			<xsl:attribute name="displayName"><xsl:value-of select="Description/text()"/></xsl:attribute>
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
		<xsl:apply-templates select="." mode="id-ExternalPlacerOrFiller"/>
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
			Check to see if the Code and OID values are actually OIDs.  The
			value is considered an OID if all of the following are true:
			- Starts with "1." or "2."
			- Is at least 10 characters long
			- Has 4 or more "."
			- Has no characters other than numbers and "."'s
		-->
		<xsl:variable name="CodeisOID" select="(starts-with(Code/text(),'1.') or starts-with(Code/text(),'2.')) and string-length(Code/text())>10 and string-length(translate(Code/text(),translate(Code/text(),'.',''),''))>3 and not(string-length(translate(Code/text(),'0123456789.','')))"/>
		<xsl:variable name="facilityOID"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="Code/text()"/></xsl:apply-templates></xsl:variable>
		<xsl:variable name="OIDisOID" select="(starts-with($facilityOID,'1.') or starts-with($facilityOID,'2.')) and string-length($facilityOID)>10 and string-length(translate($facilityOID,translate($facilityOID,'.',''),''))>3 and not(string-length(translate($facilityOID,'0123456789.','')))"/>
		
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:if test="$OIDisOID"><id root="{$facilityOID}"/></xsl:if>
				<xsl:if test="not($CodeisOID)">
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
		<id root="{isc:evaluate('createUUID')}"/>
		
		<!-- For AU, include special logic for HPI-I information. -->
		<!--<xsl:variable name="sdaCodingStandardOID">
			<xsl:choose>
				<xsl:when test="string-length(SDACodingStandard/text())">
					<xsl:apply-templates select="." mode="oid-for-code">
						<xsl:with-param name="Code" select="SDACodingStandard/text()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length(SDACodingStandard/text()) and string-length(Code/text())">
				<id root="{$sdaCodingStandardOID}" extension="{Code/text()}"/>
			</xsl:when>
			<xsl:when test="starts-with(Code/text(),concat($hiServiceOID,'.',$hpiiPrefix))">
				<id root="{Code/text()}"/>
			</xsl:when>
			<xsl:when test="starts-with($sdaCodingStandardOID,concat($hiServiceOID,'.',$hpiiPrefix))">
				<id root="{$sdaCodingStandardOID}"/>
			</xsl:when>
			<xsl:otherwise><id root="{isc:evaluate('createUUID')}"/></xsl:otherwise>
		</xsl:choose>-->
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
		
		<!-- AU - NullFlavor has to be an attribute of effectiveTime, not low/high.  -->
		<xsl:choose>
		<xsl:when test="string-length(FromTime/text()) and (string-length(ToTime/text()) and $includeHighTime = true())">
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(FromTime/text())">
					<low><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="string-length(ToTime/text()) and $includeHighTime = true()">
					<high><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></high>
				</xsl:when>
			</xsl:choose>			
		</effectiveTime>
		</xsl:when>
		<xsl:otherwise>
		<effectiveTime nullFlavor="UNK"/>
		</xsl:otherwise>
		</xsl:choose>
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
		<effectiveTime>
			<xsl:choose>
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
					<xsl:if test="string-length(EnteredOn)"><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="effectiveTime-low"/>
					<xsl:if test="$includeHighTime = true()"><xsl:apply-templates select="." mode="effectiveTime-high"/></xsl:if>
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
		<!-- AU wants a value or nothing at all. No nullFlavor. -->
		<xsl:choose>
			<xsl:when test="string-length(FromTime)"><low><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low></xsl:when>
			<xsl:when test="string-length(StartTime)"><low><xsl:attribute name="value"><xsl:apply-templates select="StartTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="effectiveTime-high">
		<!-- AU wants a value or nothing at all. No nullFlavor. -->
		<xsl:choose>
			<xsl:when test="string-length(EndTime)"><high><xsl:attribute name="value"><xsl:apply-templates select="EndTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></high></xsl:when>
			<xsl:when test="string-length(ToTime)"><high><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></high></xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="xmlToHL7TimeStamp">
		<!--
			AU requires a time zone on a time stamp that is more
			definite than just a date.  xmlToHL7TimeStamp assumes that
			text() is HS.SDA3.TimeStamp and does not have a time zone
			already included.
		-->
		<xsl:variable name="hl7TimeStamp" select="translate(text(), 'TZ:- ', '')"/>
		<xsl:choose>
			<xsl:when test="string-length($hl7TimeStamp)>8"><xsl:value-of select="concat($hl7TimeStamp,$currentTimeZoneOffset)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$hl7TimeStamp"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="encounterLink-component">
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
			Path  : entryRelationship
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
			Path  : value/@code
			Source: Code
			Source: Code/text()
			
			Field
			Path  : value/@displayName
			Source: Description
			Source: Description/text()
			
			Field
			Path  : value/@codeSystem
			Source: SDACodingStandard
			Source: SDACodingStandard/text()
			
			Field
			Path  : value/@codeSystemName
			Source: SDACodingStandard
			Source: SDACodingStandard/text()
			
			Field
			Path  : value/translation
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
					<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="translation"/>
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
		<xsl:param name="xsiType"/>
		<xsl:param name="writeOriginalText" select="'1'"/>
		<xsl:param name="cdaElementName" select="'code'"/>
		<xsl:param name="hsCustomPairElementName"/>
		
		<!--
			requiredCodeSystemOID is the OID of a specifically required codeSystem.
			requiredCodeSystemOID may be multiple OIDs, delimited by vertical bar.
			
			isCodeRequired indicates whether or not code nullFlavor is allowed.
			
			cdaElementName is the element (code, value, maritalStatusCode, etc.)
		-->
		
		<!--
			For AU, narrativeLink, requiredCodeSystemOID, and isCodeRequired are
			hard-coded variables instead of parameters, in order to accomplish the
			following:
			- Write no reference links in originalText
			- Write no translation elements, just use SDACodingStandardOID as is, or $noCodeSystemOID
			- Write no nullFlavor for code elements
		-->
		<xsl:variable name="narrativeLink" select="''"/>
		<xsl:variable name="requiredCodeSystemOID" select="''"/>
		<xsl:variable name="isCodeRequired" select="'1'"/>
		
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="not(string-length($hsCustomPairElementName))"><xsl:value-of select="Code/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="NVPair[Name/text()=concat($hsCustomPairElementName,'Code')]/Value/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="not(string-length($hsCustomPairElementName))"><xsl:value-of select="Description/text()"/></xsl:when>
				<xsl:when test="string-length($hsCustomPairElementName) and string-length(NVPair[Name/text()=concat($hsCustomPairElementName,'Description')]/Value/text())"><xsl:value-of select="NVPair[Name/text()=concat($hsCustomPairElementName,'Description')]/Value/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$code"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codingStandard">
			<xsl:choose>
				<xsl:when test="not(string-length($hsCustomPairElementName))"><xsl:value-of select="SDACodingStandard/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="NVPair[Name/text()=concat($hsCustomPairElementName,'CodingStandard')]/Value/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($code)">
			
				<xsl:variable name="sdaCodingStandardOID"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="$codingStandard"/></xsl:apply-templates></xsl:variable>
				
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
							<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
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
							
					<xsl:if test="$addTranslation='1'"><translation code="{translate($code,' ','_')}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{$description}"/></xsl:if>
					<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="translation"/>
				</xsl:element>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:element name="{$cdaElementName}">
					<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
					<xsl:if test="string-length($xsiType)"><xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute></xsl:if>
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
	
	<xsl:template name="nehta-globalStatement">
		<xsl:param name="narrativeLink"/>
		<xsl:param name="codeCode"/>
		<xsl:param name="valueCode" select="'01'"/>
		
		<xsl:variable name="codeDisplayName">
			<xsl:choose>
				<xsl:when test="$valueCode='01'">None known</xsl:when>
				<xsl:when test="$valueCode='02'">Not asked</xsl:when>
				<xsl:when test="$valueCode='03'">None supplied</xsl:when>
				<xsl:otherwise>None known</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<text mediaType="text/x-hl7-text+xml">
			<table border="1" width="100%">
				<caption>Exclusion Statements</caption>
				<thead>
					<tr>
						<th>Exclusions</th>
						<th>Values</th>
					</tr>
				</thead>
				<tbody>
					<!-- Narrative link is added here on the small chance that the
						document has no other data that would otherwise cause a
						narrative link to be written.
					-->
					<tr ID="{concat($narrativeLink,'1')}">
						<td>Global Statement</td>
						<td>
							<list>
								<item><xsl:value-of select="$codeDisplayName"/></item>
							</list>
						</td>
					</tr>
				</tbody>
			</table>
		</text>
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="{$codeCode}" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Global Statement"/>
				<value xsi:type="CD" code="{$valueCode}" codeSystem="1.2.36.1.2001.1001.101.104.16299" codeSystemName="NCTIS Global Statement Values" displayName="{$codeDisplayName}"/>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="EthnicGroup" mode="code-ethnicGroup">
		<!--
			AU has specific requirements for ethnic group.
			The Indigenous Status code table is small enough
			for us to coerce some missing values to something.
		-->
		<xsl:variable name="displayNameToUse">
			<xsl:choose>
				<xsl:when test="string-length(Description/text())"><xsl:value-of select="Description/text()"/></xsl:when>
				<xsl:when test="Code/text()='1'">Aboriginal but not Torres Strait Islander origin</xsl:when>
				<xsl:when test="Code/text()='2'">Torres Strait Islander but not Aboriginal origin</xsl:when>
				<xsl:when test="Code/text()='3'">Both Aboriginal and Torres Strait Islander origin</xsl:when>
				<xsl:when test="Code/text()='4'">Neither Aboriginal nor Torres Strait Islander origin</xsl:when>
				<xsl:when test="Code/text()='9'">Not stated/inadequately described</xsl:when>
				<xsl:otherwise><xsl:value-of select="Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="displayNameTemp">
			<xsl:value-of select="normalize-space(translate($displayNameToUse,$lowerCase,$upperCase))"/>
		</xsl:variable>
		
		<xsl:variable name="codeToUse">
			<xsl:choose>
				<xsl:when test="contains('|1|2|3|4|9|',concat('|',Code/text(),'|'))"><xsl:value-of select="Code/text()"/></xsl:when>
				<xsl:when test="$displayNameTemp='ABORIGINAL BUT NOT TORRES STRAIT ISLANDER ORIGIN'">1</xsl:when>
				<xsl:when test="$displayNameTemp='TORRES STRAIT ISLANDER BUT NOT ABORIGINAL ORIGIN'">2</xsl:when>
				<xsl:when test="$displayNameTemp='BOTH ABORIGINAL AND TORRES STRAIT ISLANDER ORIGIN'">3</xsl:when>
				<xsl:when test="$displayNameTemp='NEITHER ABORIGINAL NOR TORRES STRAIT ISLANDER ORIGIN'">4</xsl:when>
				<xsl:when test="$displayNameTemp='NOT STATED/INADEQUATELY DESCRIBED'">9</xsl:when>
				<xsl:otherwise><xsl:value-of select="Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="codeSystemToUse">
			<xsl:choose>
				<xsl:when test="translate(SDACodingStandard/text(),$lowerCase,$upperCase)='METEOR INDIGENOUS STATUS'">2.16.840.1.113883.3.879.291036</xsl:when>
				<xsl:when test="string-length(SDACodingStandard/text())"><xsl:value-of select="SDACodingStandard/text()"/></xsl:when>
				<xsl:when test="contains('|1|2|3|4|9|',concat('|',$codeToUse,'|'))">2.16.840.1.113883.3.879.291036</xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="codeSystemNameToUse">
			<xsl:choose>
				<xsl:when test="$codeSystemToUse='2.16.840.1.113883.3.879.291036'">METeOR Indigenous Status</xsl:when>
				<xsl:when test="$codeSystemToUse=$noCodeSystemOID"><xsl:value-of select="$noCodeSystemName"/></xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="code-for-oid">
						<xsl:with-param name="OID" select="$codeSystemToUse"/>
					</xsl:apply-templates></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<ethnicGroupCode code="{$codeToUse}" codeSystem="{$codeSystemToUse}" codeSystemName="{$codeSystemNameToUse}" displayName="{$displayNameToUse}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="asEntityIdentifier-Person">
		<!--
			Required HPI-I export format (illustrated Luhn number is just an example):
			<ext:id root="1.2.36.1.2001.1003.0.8003613392003497" assigningAuthorityName="HPI-I"/>
			
			You can get this using any of these SDA formats (in order of preference):
			- <Code>1.2.36.1.2001.1003.0.8003613392003497</Code>
			- <SDACodingStandard>1.2.36.1.2001.1003.0</SDACodingStandard><Code>8003613392003497</Code>
			- <SDACodingStandard>1.2.36.1.2001.1003.0.8003613392003497</SDACodingStandard>
			- <Code>8003613392003497</Code>
			
			Any other format will use SDACodingStandard and Code as is for root and extension, respectively.
		-->
		<xsl:apply-templates select="." mode="asEntityIdentifier">
			<xsl:with-param name="hpiPrefix" select="$hpiiPrefix"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="asEntityIdentifier-Organization">
		<!--
			Required HPI-O export format (illustrated Luhn number is just an example):
			<ext:id root="1.2.36.1.2001.1003.0.8003625140006861" assigningAuthorityName="HPI-O"/>
			
			You can get this using any of these SDA formats (in order of preference):
			- <Code>1.2.36.1.2001.1003.0.8003625140006861</Code>
			- <SDACodingStandard>1.2.36.1.2001.1003.0</SDACodingStandard><Code>8003625140006861</Code>
			- <SDACodingStandard>1.2.36.1.2001.1003.0.8003625140006861</SDACodingStandard>
			- <Code>8003613392003497</Code>
			
			Any other format will use SDACodingStandard and Code as is for root and extension, respectively.
		-->
		<xsl:apply-templates select="." mode="asEntityIdentifier">
			<xsl:with-param name="hpiPrefix" select="$hpioPrefix"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="asEntityIdentifier">
		<xsl:param name="hpiPrefix"/>
		
		<xsl:variable name="sdaCodingStandardOID">
			<xsl:choose>
				<xsl:when test="string-length(SDACodingStandard/text())">
					<xsl:apply-templates select="." mode="oid-for-code">
						<xsl:with-param name="Code" select="SDACodingStandard/text()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="sdaCodingStandard">
			<xsl:apply-templates select="." mode="code-for-oid">
				<xsl:with-param name="OID" select="$sdaCodingStandardOID"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:variable name="hpiAA">
			<xsl:choose>
				<xsl:when test="$hpiPrefix=$hpiiPrefix">HPI-I</xsl:when>
				<xsl:when test="$hpiPrefix=$hpioPrefix">HPI-O</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="rootToUse">
			<xsl:choose>
				<xsl:when test="starts-with(Code/text(),concat($hiServiceOID,'.',$hpiPrefix))"><xsl:value-of select="Code/text()"/></xsl:when>
				<xsl:when test="$sdaCodingStandardOID=$hiServiceOID and starts-with(Code/text(),$hpiPrefix)"><xsl:value-of select="concat($hiServiceOID,'.',Code/text())"/></xsl:when>
				<xsl:when test="starts-with($sdaCodingStandardOID,concat($hiServiceOID,'.',$hpiPrefix))"><xsl:value-of select="$sdaCodingStandardOID"/></xsl:when>
				<xsl:when test="$sdaCodingStandardOID=$noCodeSystemOID and string-length(Code/text())=16 and starts-with(Code/text(),$hpiPrefix)"><xsl:value-of select="concat($hiServiceOID,'.',Code/text())"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$sdaCodingStandardOID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<xsl:variable name="extensionToUse">
			<xsl:choose>
				<xsl:when test="string-length(Code/text()) and not(starts-with($rootToUse,concat($hiServiceOID,'.',$hpiPrefix)))"><xsl:value-of select="Code/text()"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
				
		<ext:asEntityIdentifier classCode="IDENT">
			<xsl:element name="ext:id">
				<xsl:if test="string-length($rootToUse)"><xsl:attribute name="root"><xsl:value-of select="$rootToUse"/></xsl:attribute></xsl:if>
				<xsl:if test="string-length($extensionToUse)"><xsl:attribute name="extension"><xsl:value-of select="$extensionToUse"/></xsl:attribute></xsl:if>
				<xsl:if test="starts-with($rootToUse,concat($hiServiceOID,'.',$hpiPrefix))"><xsl:attribute name="assigningAuthorityName"><xsl:value-of select="$hpiAA"/></xsl:attribute></xsl:if>
				<xsl:if test="not(starts-with($rootToUse,concat($hiServiceOID,'.',$hpiPrefix)))"><xsl:attribute name="assigningAuthorityName"><xsl:value-of select="$sdaCodingStandard"/></xsl:attribute></xsl:if>
				<xsl:if test="not(string-length($rootToUse))"><xsl:attribute name="nullFlavor"><xsl:value-of select="$idNullFlavor"/></xsl:attribute></xsl:if>
			</xsl:element>
			<xsl:choose>
				<xsl:when test="starts-with($rootToUse,$hiServiceOID)">
					<ext:assigningGeographicArea classCode="PLC">
						<ext:name>National Identifier</ext:name>
					</ext:assigningGeographicArea>
				</xsl:when>
				<xsl:otherwise>
					<ext:code code="EI" codeSystem="2.16.840.1.113883.12.203" codeSystemName="Identifier Type (HL7)" />
				</xsl:otherwise>
			</xsl:choose>
		</ext:asEntityIdentifier>
	</xsl:template>
	
	<xsl:template match="*" mode="employment">
		<ext:asEmployment classCode="EMP">
			<xsl:choose>
				<xsl:when test="string-length(Code/text())">
					<ext:employerOrganization>
						<asOrganizationPartOf>
							<wholeOrganization>
								<xsl:choose>
									<xsl:when test="string-length(Description/text())"><name><xsl:value-of select="Description/text()"/></name></xsl:when>
									<xsl:when test="string-length(Code/text())"><name><xsl:value-of select="Code/text()"/></name></xsl:when>
									<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
								</xsl:choose>
								
								<xsl:apply-templates select="." mode="asEntityIdentifier-Organization"/>
							</wholeOrganization>
						</asOrganizationPartOf>
					</ext:employerOrganization>
				</xsl:when>
				<xsl:otherwise>
					<ext:employerOrganization>
						<id nullFlavor="{$idNullFlavor}"/>
						<name nullFlavor="UNK"/>
						<telecom nullFlavor="UNK"/>
						<addr nullFlavor="{$addrNullFlavor}"/>
					</ext:employerOrganization>
				</xsl:otherwise>
			</xsl:choose>
		</ext:asEmployment>
	</xsl:template>
	
	<xsl:template match="*" mode="careProviderType-ANZSCO">
		<!--
			1220.0 ANZSCO is required here, and it is a very large
			set of code/displayName values.  Only in cases where
			CareProviderType is not present will we default in values.
			Otherwise, CareProviderType must specify valid ANZSCO data.
		-->
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="not(CareProviderType)">253111</xsl:when>
				<xsl:otherwise><xsl:value-of select="CareProviderType/Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="not(CareProviderType)">General Medical Practitioner</xsl:when>
				<xsl:when test="string-length(CareProviderType/Description)"><xsl:value-of select="CareProviderType/Description/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="CareProviderType/Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codeSystem">
			<xsl:choose>
				<xsl:when test="not(CareProviderType)">2.16.840.1.113883.13.62</xsl:when>
				<xsl:when test="not(string-length(CareProviderType/SDACodingStandard/text()))"><xsl:value-of select="$noCodeSystemOID"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="CareProviderType/SDACodingStandard/text()"/></xsl:apply-templates></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codeSystemName">
			<xsl:choose>
				<xsl:when test="$codeSystem='2.16.840.1.113883.13.62'">1220.0 - ANZSCO - Australian and New Zealand Standard Classification of Occupations, First Edition, 2006</xsl:when>
				<xsl:when test="not(string-length(CareProviderType/SDACodingStandard/text()))"><xsl:value-of select="$noCodeSystemName"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$codeSystem"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<code code="{$code}" codeSystem="{$codeSystem}" codeSystemName="{$codeSystemName}" displayName="{$description}"/>
	</xsl:template>
		
	<xsl:template match="*" mode="narrativeDateFromODBC">
		<!-- The expected date format coming in is "ODBC format" YYYY-MM-DDTHH:MM:SSZ -->
		<xsl:variable name="year" select="substring(text(),1,4)"/>
		<xsl:variable name="month" select="substring(text(),6,2)"/>
		<xsl:variable name="monthText">
			<xsl:choose>
				<xsl:when test="$month='01'">Jan</xsl:when>
				<xsl:when test="$month='02'">Feb</xsl:when>
				<xsl:when test="$month='03'">Mar</xsl:when>
				<xsl:when test="$month='04'">Apr</xsl:when>
				<xsl:when test="$month='05'">May</xsl:when>
				<xsl:when test="$month='06'">Jun</xsl:when>
				<xsl:when test="$month='07'">Jul</xsl:when>
				<xsl:when test="$month='08'">Aug</xsl:when>
				<xsl:when test="$month='09'">Sep</xsl:when>
				<xsl:when test="$month='10'">Oct</xsl:when>
				<xsl:when test="$month='11'">Nov</xsl:when>
				<xsl:when test="$month='12'">Dec</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- Trim leading zero from day. -->
		<xsl:variable name="day">
			<xsl:choose>
				<xsl:when test="substring(text(),9,1)='0'"><xsl:value-of select="substring(text(),10,1)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="substring(text(),9,2)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Trim leading zero from hour. -->
		<xsl:variable name="hour">
			<xsl:choose>
				<xsl:when test="substring(text(),12,1)='0'"><xsl:value-of select="substring(text(),13,1)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="substring(text(),12,2)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="minute" select="substring(text(),15,2)"/>
		<xsl:value-of select="concat($day,' ',$monthText,' ',$year,' ',$hour,':',$minute)"/>
	</xsl:template>
</xsl:stylesheet>
