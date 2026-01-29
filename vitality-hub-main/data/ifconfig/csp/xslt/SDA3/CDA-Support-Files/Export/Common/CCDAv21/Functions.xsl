<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc"
	xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common"
	exclude-result-prefixes="isc exsl sdtc xsi">

	<!-- Keys to encounter data -->
	<xsl:key name="EncNum" match="Encounter" use="EncounterNumber"/>
	<xsl:key name="EncNum" match="/Container" use="'NEVER_MATCH_THIS!'"/>
	<!-- Key for /Container/AdditionalInfo/AdditionalInfoItem -->
	<xsl:key name="AdditionalInfoByKey" match="/Container/AdditionalInfo/AdditionalInfoItem" use="@AdditionalInfoKey"/>
	<xsl:key name="AdditionalInfoByKey" match="/Container" use="'NEVER_MATCH_THIS!'"/>
	<!-- Second line in each of the above keys is to ensure that the "key table" is populated
	       with at least one row, but we never want to retrieve that row. -->

	<xsl:template match="*" mode="fn-performer">
		<!-- Match could be Clinician, DiagnosingClinician, CareProvider, OrderedBy, ReferredToProvider -->		
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
			<xsl:apply-templates select=".." mode="fn-time"/>
			<xsl:apply-templates select="." mode="fn-assignedEntity-performer"/>
		</performer>
	</xsl:template>

	<xsl:template match="*" mode="fn-performer-carePlanProvider">
		<!-- Match could be Clinician, DiagnosingClinician, Provider, CareProvider, OrderedBy, ReferredToProvider -->		
		<!--
			StructuredMapping: performer-carePlanProvider
			
			Field
			Path  : CareProviderType
			Source: CareProviderType
			Source: ./CareProviderType
			StructuredMappingRef: code-function			

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
			<xsl:apply-templates select="CareProviderType" mode="fn-code-function"/>				
			<xsl:apply-templates select=".." mode="fn-time"/>
			<xsl:apply-templates select="." mode="fn-assignedEntity-performer"/>
		</performer>
	</xsl:template>

	<xsl:template match="*" mode="fn-device-procedure">
		<!--
			device-procedure is a special-case device export for C-CDA Procedures.  
		-->
		<xsl:for-each select="Device">
           	<xsl:if test="position() &gt; 1">
            	<br/>
           	</xsl:if>
			<xsl:value-of select="concat(Device/Description/text(), ' (', UDIAssigningAuthority/text(), ': ', UDIRoot/text(), ' ', UDIExtension/text())"/>		
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Clinician" mode="fn-performer-procedure">
		<!--
			performer-procedure is a special-case performer export for
			C-CDA Procedures.  <time> is not applicable, and procedure
			performer only is allowed one telecom, as opposed to other
			performers which may have multiple telecoms.  This
			template calls specialized template assignedEntity-procedure
			which calls specialized template telecom-performer-procedure
			which restricts telecom output to one.
		-->
		<!--
			StructuredMapping: performer-procedure
			
			Field
			Path  : assignedEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity-procedure
		-->
		<performer typeCode="PRF">
			<xsl:apply-templates select="." mode="fn-assignedEntity-procedure"/>
		</performer>
	</xsl:template>
	
	<xsl:template match="EnteredAt | Organization" mode="fn-informant">
		<!-- use of Organization is dormant at the moment -->
		<!--
			StructuredMapping: informant
			
			Field
			Path  : assignedEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity
		-->
		<informant>
			<xsl:apply-templates select="." mode="fn-assignedEntity"/>
		</informant>
	</xsl:template>

	<xsl:template match="CareProvider" mode="fn-informant-encounterParticipant">
		<!--
			StructuredMapping: informant-encounterParticipant
			
			Field
			Path  : assignedEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity-encounterParticipant
		-->
		<informant>
			<xsl:apply-templates select="." mode="fn-assignedEntity-encounterParticipant"/>
		</informant>
	</xsl:template>

	<xsl:template match="EnteredAt" mode="fn-informant-noPatientIdentifier">
		<informant>
			<xsl:apply-templates select="." mode="fn-assignedEntity">
				<xsl:with-param name="includePatientIdentifier" select="false()"/>
			</xsl:apply-templates>
		</informant>
	</xsl:template>

	<xsl:template match="*" mode="fn-assignedEntity">
	  <!-- match could be PerformedAt, Contact, EnteredAt, maybe Organization -->
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
			<xsl:apply-templates select="." mode="fn-id-Clinician"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="fn-telecom"/>			

			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="fn-assignedPerson"/>
			
			<!-- Represented Organization -->
			<xsl:apply-templates select="." mode="fn-representedOrganization"/>
			
			<!-- HITSP-specific patient extension, available today only for encountered data -->
			<!--<xsl:if test="($includePatientIdentifier = true())"><xsl:apply-templates select="." mode="fn-id-sdtcPatient"><xsl:with-param name="xpathContext" select="."/></xsl:apply-templates></xsl:if>-->
		</assignedEntity>
	</xsl:template>

	
	<xsl:template match="*" mode="fn-assignedEntity-performer">
	  <!-- Match could be Clinician, FamilyDoctor, CareProvider, AdmittingClinician, DiagnosingClinician -->
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
			<xsl:apply-templates select="." mode="fn-id-Clinician"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="fn-telecom"/>					
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="fn-assignedPerson"/>

		</assignedEntity>
	</xsl:template>
	
	<xsl:template match="Clinician" mode="fn-assignedEntity-procedure">
		<!--
			assignedEntity-procedure is a special case assignedEntity
			export for C-CDA Procedures.  Procedure performer only is
			allowed one telecom, as opposed to other performers which
			may have multiple telecoms.  This template calls specialized
			template telecom-performer-procedure which restricts telecom
			output to one.
		-->
		<!--
			StructuredMapping: assignedEntity-procedure
			
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
			StructuredMappingRef: telecom-performer-procedure
			
			Field
			Path  : assignedPerson
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedPerson
		-->
		<assignedEntity classCode="ASSIGNED">
			<!-- Contact Identifier -->
			<xsl:apply-templates select="." mode="fn-id-Clinician"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="fn-telecom-performer-procedure"/>
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="fn-assignedPerson"/>
		</assignedEntity>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-assignedEntity-encounterParticipant">
	  <!-- Match could be CareProvider, ReferringClinician -->
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
			<xsl:apply-templates select="." mode="fn-id-Clinician"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="fn-telecom"/>
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="fn-assignedPerson"/>
		</assignedEntity>
	</xsl:template>
	

	<xsl:template match="Organization" mode="fn-associatedEntity-scopingOrganization">
	  <!--
			StructuredMapping: associatedEntity-scopingOrganization
			
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
		<associatedEntity classCode="SDLOC">
			<scopingOrganization>

				<name><xsl:value-of select="Code/text()"/></name>

				<!-- Entity Telecom -->
				<xsl:apply-templates select="." mode="fn-telecom"/>

				<!-- Entity Address -->
				<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>

			</scopingOrganization>
		</associatedEntity>

	</xsl:template>

	<xsl:template match="SupportContact | Provider" mode="fn-associatedEntity">
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
		
			<xsl:apply-templates select="." mode="fn-id-Clinician"/>
			
			<xsl:apply-templates select="Relationship" mode="fn-generic-Coded">
				<xsl:with-param name="requiredCodeSystemOID" select="$roleCodeOID"/>
				<xsl:with-param name="isCodeRequired" select="'1'"/>
			</xsl:apply-templates>
		
			<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
			
			<xsl:apply-templates select="." mode="fn-telecom"/>
			
			<xsl:apply-templates select="." mode="fn-associatedPerson"/>
			
			<xsl:apply-templates select="EnteredAt" mode="fn-scopingOrganization"/>
		</associatedEntity>
	</xsl:template>

	<xsl:template match="Encounter" mode="fn-associatedEntity-ParticipantCallback">

		<!--
			StructuredMapping: associatedEntity-ParticipantCallback
			
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
			StructuredMappingRef: associatedPerson
		-->
		
		<associatedEntity classCode="ASSIGNED">

			<id nullFlavor="UNK"/>			
		
			<xsl:apply-templates select="EnteredAt" mode="fn-address-WorkPrimary"/>
			
			<xsl:apply-templates select="EnteredAt" mode="fn-telecom"/>
			
			<xsl:apply-templates select="EnteredBy" mode="fn-associatedPerson"/>
			
		</associatedEntity>
	</xsl:template>

	
	<xsl:template match="Organization" mode="fn-assignedAuthoringDevice">
		<assignedAuthoringDevice>
			<manufacturerModelName>InterSystems</manufacturerModelName>
			<softwareName>InterSystems HealthShare</softwareName>
		</assignedAuthoringDevice>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-assignedPerson">
	  <!-- match could be PerformedAt, Contact, Clinician, FamilyDoctor, CareProvider, AdmittingClinician, 
       DiagnosingClinician, ReferringClinician, EnteredBy, OrderedBy, VerifiedBy -->
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
					<xsl:apply-templates select="." mode="fn-name-Person"/>
				</xsl:when>		
				<xsl:otherwise>
					<name nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
		</assignedPerson>
	</xsl:template>

	<xsl:template match="SupportContact | Provider | EnteredBy" mode="fn-associatedPerson">
		<associatedPerson>
			<xsl:apply-templates select="." mode="fn-name-Person"/>
		</associatedPerson>
	</xsl:template>
	
	<xsl:template match="FamilyMember" mode="fn-subject">
		<subject>
			<relatedSubject classCode="PRS">
				<xsl:apply-templates select="." mode="fn-generic-Coded">
					<xsl:with-param name="requiredCodeSystemOID" select="$roleCodeOID"/>
					<xsl:with-param name="isCodeRequired" select="'1'"/>
				</xsl:apply-templates>
			</relatedSubject>
		</subject>
	</xsl:template>

	<xsl:template match="*" mode="fn-name-Person">
	<!-- match could be Patient, HealthFund, Subscriber, PerformedAt, Contact, Clinician,
		   FamilyDoctor, CareProvider, AdmittingClinician, DiagnosingClinician, ReferringClinician,
		   EnteredBy, OrderedBy, VerifiedBy -->		
		<!--
			StructuredMapping: name-Person
			Note  : C-CDA does not allow the export
			of the Description/text() as a straight text line.
			It only allows the export of the name parts inside of <family>, <given>, etc.
			If the Name object is not passed into here, then try to parse the name parts out of Description/text().
								
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
			
			Field
			Path  : validTime/low
			Source: FromTime
			Source: FromTime/text()
			
			Field
			Path  : validTime/high
			Source: ToTime
			Source: ToTime/text()
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

				<xsl:variable name="nameFromTime">
					<xsl:apply-templates select="Name/FromTime" mode="fn-xmlToHL7TimeStamp"/>
				</xsl:variable>
				<xsl:variable name="nameToTime">
					<xsl:apply-templates select="Name/ToTime" mode="fn-xmlToHL7TimeStamp"/>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="string-length($contactFirstName) or string-length($contactLastName)">
						<name use="L">
							<xsl:if test="string-length($contactLastName)"><family><xsl:value-of select="$contactLastName"/></family></xsl:if>
							<xsl:if test="string-length($contactFirstName)"><given><xsl:value-of select="$contactFirstName"/></given></xsl:if>
							<xsl:if test="string-length($contactMiddleName)"><given><xsl:value-of select="$contactMiddleName"/></given></xsl:if>
							<xsl:if test="string-length($contactPrefix)"><prefix><xsl:value-of select="$contactPrefix"/></prefix></xsl:if>
							<xsl:if test="string-length($contactSuffix)"><suffix><xsl:value-of select="$contactSuffix"/></suffix></xsl:if>
							<xsl:if test="string-length($nameFromTime) or string-length($nameToTime)">
								<validTime xsi:type="IVL_TS">
									<xsl:choose>
										<xsl:when test="string-length($nameFromTime)">
											<low value="{$nameFromTime}"/>
										</xsl:when>
										<xsl:otherwise>
											<low nullFlavor="UNK"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:choose>
										<xsl:when test="string-length($nameToTime)">
											<high value="{$nameToTime}"/>
										</xsl:when>
										<xsl:otherwise>
											<high nullFlavor="NA"/>
										</xsl:otherwise>
									</xsl:choose>
								</validTime>
							</xsl:if>
						</name>
					</xsl:when>
					<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Name" mode="fn-name-Person-Other">
		
		<xsl:variable name="contactFirstName" select="normalize-space(GivenName/text())"/>
		<xsl:variable name="contactMiddleName" select="normalize-space(MiddleName/text())"/>
		<xsl:variable name="contactLastName" select="normalize-space(FamilyName/text())"/>

		<xsl:variable name="nameType" select="normalize-space(Type/text())"/>
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />		
		<!-- The variable, when set, will cause creation of name/@use attribute for @nameUse = 'L' or @nameUse = 'P'. -->
		<!-- The variable, when set, will cause creation of name/@qualifier attribute for @nameUse = 'BR'. -->
		<xsl:variable name="nameUse">
			<xsl:choose>
				<xsl:when test="translate($nameType, $smallcase, $uppercase)='BIRTH'"><xsl:value-of select="'BR'"/></xsl:when>
				<xsl:when test="translate($nameType, $smallcase, $uppercase)='LEGAL'"><xsl:value-of select="'L'"/></xsl:when>
				<xsl:when test="translate($nameType, $smallcase, $uppercase)='PREVIOUS'"><xsl:value-of select="'L'"/></xsl:when>
				<xsl:when test="translate($nameType, $smallcase, $uppercase)='ALIAS'"><xsl:value-of select="'P'"/></xsl:when>
			</xsl:choose>
		</xsl:variable>				

		<xsl:variable name="nameFromTime">
			<xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/>
		</xsl:variable>
		<xsl:variable name="nameToTime">
			<xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/>
		</xsl:variable>
		
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
			
			Field
			Path  : validTime/low
			Source: FromTime
			Source: FromTime/text()
			
			Field
			Path  : validTime/high
			Source: ToTime
			Source: ToTime/text()
		-->

		<xsl:choose>
			<xsl:when test="string-length($contactFirstName) or string-length($contactLastName)">
				<name>
					<xsl:if test="$nameUse='L' or $nameUse='P'">
						<xsl:attribute name="use"><xsl:value-of select="$nameUse"/></xsl:attribute>
					</xsl:if>
					<family>
						<xsl:choose>
							<xsl:when test="string-length($contactLastName)">
								<xsl:if test="$nameUse='BR'">
									<xsl:attribute name="qualifier">
										<xsl:value-of select="'BR'" />
									</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="$contactLastName"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="nullFlavor">
									<xsl:value-of select="'NI'" />
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</family>

					<given>
						<xsl:choose>
							<xsl:when test="string-length($contactFirstName)">
								<xsl:if test="$nameUse='BR'">
									<xsl:attribute name="qualifier">
										<xsl:value-of select="'BR'" />
									</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="$contactFirstName"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="nullFlavor">
									<xsl:value-of select="'NI'" />
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</given>

					<xsl:if test="string-length($contactMiddleName)">
						<given>
							<xsl:if test="$nameUse='BR'">
								<xsl:attribute name="qualifier">
									<xsl:value-of select="'BR'" />
								</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="$contactMiddleName"/>
						</given>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(NamePrefix/text()))">
						<prefix>
							<xsl:value-of select="normalize-space(NamePrefix/text())"/>
						</prefix>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(ProfessionalSuffix/text()))">
						<suffix>
							<xsl:value-of select="normalize-space(ProfessionalSuffix/text())"/>
						</suffix>
					</xsl:if>
					<validTime xsi:type="IVL_TS">
						<xsl:choose>
							<xsl:when test="string-length($nameFromTime)">
								<low value="{$nameFromTime}"/>
							</xsl:when>
							<xsl:when test="string-length($nameToTime)">
								<low value="UNK"/>
							</xsl:when>
							<xsl:when test="translate($nameType, $smallcase, $uppercase)='PREVIOUS'">
								<low nullFlavor="UNK"/>
							</xsl:when>
							<xsl:otherwise>
								<low nullFlavor="NI"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="string-length($nameToTime)">
								<high value="{$nameToTime}"/>
							</xsl:when>
							<xsl:when test="translate($nameType, $smallcase, $uppercase)='PREVIOUS'">
								<high nullFlavor="UNK"/>
							</xsl:when>
							<xsl:otherwise>
								<high nullFlavor="NI"/>
							</xsl:otherwise>
						</xsl:choose>
					</validTime>
				</name>
			</xsl:when>
			<xsl:otherwise>
				<name nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="ReferringOrganization | ReferredToOrganization" mode="fn-name-Organization">
	  <!-- source could be any facility -->
	  <xsl:choose>
			<xsl:when test="Description">
				<name><xsl:value-of select="Description" /></name>
			</xsl:when>
			<xsl:otherwise>
				<name nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-name-Person-Narrative">
	  <!-- Used when preparing nice HTML output.
	       Match could be Clinician, DiagnosingClinician, CareProvider, OrderedBy -->
	  <xsl:value-of select="normalize-space(Description/text())"/>
	</xsl:template>
	
	<xsl:template match="Patient" mode="fn-addresses-Patient">
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
				<xsl:apply-templates select="Addresses/Address" mode="fn-address-Patient"/>
			</xsl:when>
			<xsl:otherwise>
				<addr nullFlavor="{$addrNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Address" mode="fn-address-Patient">
		<xsl:apply-templates select="." mode="fn-address-Individual">
			<xsl:with-param name="addressUse">
				<xsl:choose>
					<xsl:when test="position()=1">HP</xsl:when>
					<xsl:otherwise>H</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<!-- DO NOT USE address-Person, it is deprecated as of HealthShare Core 13. -->

	<xsl:template match="*" mode="fn-address-WorkPrimary">
		<xsl:apply-templates select="." mode="fn-address">
			<xsl:with-param name="addressUse">WP</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-address-HomePrimary">
		<xsl:apply-templates select="." mode="fn-address">
			<xsl:with-param name="addressUse">HP</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="fn-address-Home">
		<xsl:apply-templates select="." mode="fn-address">
			<xsl:with-param name="addressUse">H</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="fn-address">
		<xsl:param name="addressUse" select="'WP'"/>

		<xsl:choose>
			<xsl:when test="Address | InsuredAddress">
				<xsl:apply-templates select="Address | InsuredAddress[1]" mode="fn-address-Individual">
					<xsl:with-param name="addressUse" select="$addressUse"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<addr nullFlavor="{$addrNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Address | InsuredAddress | OfficeContactAddress" mode="fn-address-Individual">
		<xsl:param name="addressUse" select="'WP'"/>
		<!-- Input is Address or similar, having sub-elements for the various fields. -->
		
		<xsl:variable name="addressStreet" select="Street/text()"/>
		<xsl:variable name="addressCity" select="City/Code/text()"/>
		<xsl:variable name="addressState" select="State/Code/text()"/>
		<xsl:variable name="addressZip" select="Zip/Code/text()"/>
		<xsl:variable name="addressCountry">
			<xsl:apply-templates select="Country/Code" mode="fn-S-address-country"/>
		</xsl:variable>
		<xsl:variable name="addressCounty" select="County/Code/text()"/>
		<xsl:variable name="addressFromTime">
			<xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/>
		</xsl:variable>
		<xsl:variable name="addressToTime">
			<xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/>
		</xsl:variable>
		
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

			Field
			Path  : county
			Source: County.Code
			Source: County/Code/text()
		-->
		<xsl:choose>
			<xsl:when test="string-length(concat($addressStreet, $addressCity, $addressState, $addressZip, $addressCountry))">
				<addr use="{$addressUse}">
					<xsl:choose>
						<xsl:when test="string-length($addressStreet)">
							<xsl:apply-templates select="." mode="fn-address-streetLine">
							  <xsl:with-param name="streetText" select="$addressStreet"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<streetAddressLine nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="string-length($addressCity)">
							<city>
								<xsl:value-of select="$addressCity"/>
							</city>
						</xsl:when>
						<xsl:otherwise>
							<city nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
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
					<xsl:if test="string-length($addressCounty)">
						<county><xsl:value-of select="$addressCounty"/></county>
					</xsl:if>
					<xsl:if test="string-length($addressFromTime) or string-length($addressToTime)">
						<useablePeriod xsi:type="IVL_TS">
							<xsl:choose>
								<xsl:when test="string-length($addressFromTime)">
									<low value="{$addressFromTime}"/>
								</xsl:when>
								<xsl:otherwise>
									<low nullFlavor="UNK"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="string-length($addressToTime)">
									<high value="{$addressToTime}"/>
								</xsl:when>
								<xsl:otherwise>
									<high nullFlavor="UNK"/>
								</xsl:otherwise>
							</xsl:choose>
						</useablePeriod>
					</xsl:if>
				</addr>
			</xsl:when>
			<xsl:otherwise>
				<addr nullFlavor="{$addrNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
  <xsl:template match="*" mode="fn-address-streetLine">
    <!-- Context node is ignored; this template operates on the param. -->
    <xsl:param name="streetText"/>

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
    <xsl:choose>
      <xsl:when test="not(contains($streetText, ';'))">
        <streetAddressLine>
          <xsl:value-of select="normalize-space($streetText)"/>
        </streetAddressLine>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="currentPiece" select="substring-before($streetText, ';')"/>
        <xsl:if test="string-length($currentPiece)">
          <streetAddressLine>
            <xsl:value-of select="normalize-space($currentPiece)"/>
          </streetAddressLine>
          <!-- After emitting the current line, go back around with the remainder of the string -->
          <xsl:apply-templates select="." mode="fn-address-streetLine">
            <xsl:with-param name="streetText" select="substring-after($streetText, ';')"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
	
	<xsl:template match="Country/Code" mode="fn-S-address-country">
		<!-- US Realm country should be 'US'. -->
		<xsl:variable name="addressCountryUpper" select="translate(text(),$lowerCase,$upperCase)"/>
		<xsl:choose>
			<xsl:when test="not(string-length(text())) or text()='US'"><xsl:value-of select="text()"/></xsl:when>
			<xsl:when test="$addressCountryUpper='USA'">US</xsl:when>
			<xsl:when test="$addressCountryUpper='US'">US</xsl:when>
			<xsl:when test="$addressCountryUpper='UNITED STATES'">US</xsl:when>
			<xsl:when test="$addressCountryUpper='UNITED STATES OF AMERICA'">US</xsl:when>
			<xsl:otherwise><xsl:value-of select="text()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-telecom">
	  <!-- match can be Patient, HealthFund, PerformedAt, Contact.
	     Other elements having a ContactInfo child are also eligible to use this. -->
	  <xsl:choose>
			<xsl:when test="ContactInfo | InsuredContact">
				<xsl:variable name="telecomHomePhone">
					<xsl:apply-templates select="(ContactInfo | InsuredContact)/HomePhoneNumber" mode="fn-telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomWorkPhone">
					<xsl:apply-templates select="(ContactInfo | InsuredContact)/WorkPhoneNumber" mode="fn-telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomMobilePhone">
					<xsl:apply-templates select="(ContactInfo | InsuredContact)/MobilePhoneNumber" mode="fn-telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomEmail" select="normalize-space((ContactInfo | InsuredContact)/EmailAddress/text())"/>
				
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
					<xsl:when
						test="string-length($telecomHomePhone) or string-length($telecomWorkPhone) or string-length($telecomMobilePhone) or string-length($telecomEmail)">
						<xsl:if test="string-length($telecomHomePhone)">
							<telecom use="HP" value="{concat('tel:', $telecomHomePhone)}"/>
						</xsl:if>
						<xsl:if test="string-length($telecomWorkPhone)">
							<telecom use="WP" value="{concat('tel:', $telecomWorkPhone)}"/>
						</xsl:if>
						<xsl:if test="string-length($telecomMobilePhone)">
							<telecom use="MC" value="{concat('tel:', $telecomMobilePhone)}"/>
						</xsl:if>
						<xsl:if test="string-length($telecomEmail)">
							<telecom value="{concat('mailto:', $telecomEmail)}"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<telecom nullFlavor="UNK"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<telecom nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Clinician" mode="fn-telecom-performer-procedure">
		<xsl:choose>
			<xsl:when test="ContactInfo">
				<xsl:variable name="telecomHomePhone">
					<xsl:apply-templates select="ContactInfo/HomePhoneNumber" mode="fn-telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomWorkPhone">
					<xsl:apply-templates select="ContactInfo/WorkPhoneNumber" mode="fn-telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomMobilePhone">
					<xsl:apply-templates select="ContactInfo/MobilePhoneNumber" mode="fn-telecom-regex"/>
				</xsl:variable>
				<xsl:variable name="telecomEmail" select="normalize-space(ContactInfo/EmailAddress/text())"/>
				
				<!--
					StructuredMapping: telecom-performer-procedure
					
					Note  : The export of the @use attribute depends upon the type of number.
					For Work Phone, @use="WP".
					For Mobile Phone, @use="MC".
					For E-mail, @use is omitted, and @value includes a "mailto:" prefix.
					For Home Phone, @use="HP".
					Only the first found of Work Phone, Mobile Phone, E-mail or Home
					Phone (in that order) from the SDA is exported.
					
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
										
					Field
					Path  : @value
					Source: HomePhoneNumber
					Source: HomePhoneNumber/text()
				-->
				<xsl:choose>
					<xsl:when test="string-length($telecomWorkPhone)">
						<telecom use="WP" value="{concat('tel:', $telecomWorkPhone)}"/>
					</xsl:when>
					<xsl:when test="string-length($telecomMobilePhone)">
						<telecom use="MC" value="{concat('tel:', $telecomMobilePhone)}"/>
					</xsl:when>
					<xsl:when test="string-length($telecomEmail)">
						<telecom value="{concat('mailto:', $telecomEmail)}"/>
					</xsl:when>
					<xsl:when test="string-length($telecomHomePhone)">
						<telecom use="HP" value="{concat('tel:', $telecomHomePhone)}"/>
					</xsl:when>
					<xsl:otherwise>
						<telecom nullFlavor="UNK"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<telecom nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-representedOrganization">
	  <!-- match could be PerformedAt, Contact, EnteredAt, maybe Organization -->
	  <xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="fn-code-to-description">
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
					Source: Description
					Source: Description/text()
					Note  : Code can be an indirect source of the information
					for name, only if the Code value has an entry in the OID
					Registry and that OID Registry entry includes a value for
					the Description property, in which case that Description
					value is used.  Otherwise, the Description on the SDA
					coded element is used.
					
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
					<xsl:apply-templates select="." mode="fn-id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)">
							<name><xsl:value-of select="$organizationName"/></name>
						</xsl:when>
						<xsl:otherwise>
							<name nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="fn-telecom"/>
					<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
										
					<xsl:if test="$homeCommunityOID or $homeCommunityCode or $homeCommunityName">
						<asOrganizationPartOf>
							<effectiveTime nullFlavor="UNK"/>
							<wholeOrganization>
								<xsl:apply-templates select="$homeCommunity/Organization" mode="fn-id-Facility"/>

								<xsl:choose>
									<xsl:when test="string-length($homeCommunityName)">
										<name><xsl:value-of select="$homeCommunityName"/></name>
									</xsl:when>
									<xsl:otherwise>
										<name nullFlavor="UNK"/>
									</xsl:otherwise>
								</xsl:choose>
								
								<xsl:apply-templates select="$homeCommunity/Organization" mode="fn-telecom"/>
								<xsl:apply-templates select="$homeCommunity/Organization" mode="fn-address-WorkPrimary"/>
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
	
	<xsl:template match="Organization" mode="fn-serviceProviderOrganization">
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="fn-code-to-description">
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
					<xsl:apply-templates select="." mode="fn-id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)">
							<name><xsl:value-of select="$organizationName"/></name>
						</xsl:when>
						<xsl:otherwise>
							<name nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="fn-telecom"/>
					<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
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
	
	<xsl:template match="Organization" mode="fn-representedOrganization-Document">
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="fn-code-to-description">
						<xsl:with-param name="identityType" select="'HomeCommunity'"/>
						<xsl:with-param name="defaultDescription" select="Description/text()"/>
					</xsl:apply-templates>
				</xsl:variable>
				
				<representedOrganization>
					<xsl:apply-templates select="." mode="fn-id-Facility"/>
					
					<xsl:choose>
						<xsl:when test="string-length($organizationName)">
							<name><xsl:value-of select="$organizationName"/></name>
						</xsl:when>
						<xsl:otherwise>
							<name nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="fn-telecom"/>
					<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
					
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
	
	<xsl:template match="EnteredAt" mode="fn-scopingOrganization">
		<xsl:variable name="organizationName">
			<xsl:apply-templates select="Code" mode="fn-code-to-description">
				<xsl:with-param name="defaultDescription" select="Description/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<scopingOrganization>
			<xsl:choose>
				<xsl:when test="string-length($organizationName)">
					<name><xsl:value-of select="$organizationName"/></name>
				</xsl:when>
				<xsl:otherwise>
					<name nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="." mode="fn-telecom"/>
			<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
		</scopingOrganization>
	</xsl:template>
	
	<xsl:template match="Contact" mode="fn-legalAuthenticator">
		<legalAuthenticator>
			<time value="{$currentDateTime}"/>
			<signatureCode code="S"/>
			<xsl:apply-templates select="." mode="fn-assignedEntity"/>
		</legalAuthenticator>
	</xsl:template>
	
	<xsl:template match="Organization" mode="fn-custodian">
		<custodian>
			<assignedCustodian>
				<xsl:choose>
					<xsl:when test="string-length(Code/text())">
						<xsl:variable name="organizationName">
							<xsl:apply-templates select="Code" mode="fn-code-to-description">
								<xsl:with-param name="identityType" select="'Facility'"/>
								<xsl:with-param name="defaultDescription" select="Description/text()"/>
							</xsl:apply-templates>
						</xsl:variable>
						
						<representedCustodianOrganization>
							<!-- C-CDA validation on custodian section specifically wants
						       only one <id>. Don't use the id-Facility template here. -->
							<xsl:choose>
								<xsl:when test="string-length(Code/text())">
									<xsl:variable name="facilityOID">
										<xsl:apply-templates select="Code" mode="fn-oid-for-code">
											<xsl:with-param name="Code" select="Code/text()"/>
										</xsl:apply-templates>
									</xsl:variable>
									<id>
										<xsl:attribute name="root"><xsl:value-of select="$facilityOID"/></xsl:attribute>
									</id>
								</xsl:when>
								<xsl:otherwise>
									<id nullFlavor="{$idNullFlavor}"/>
								</xsl:otherwise>
							</xsl:choose>
							
							<xsl:choose>
								<xsl:when test="string-length($organizationName)">
									<name><xsl:value-of select="$organizationName"/></name>
								</xsl:when>
								<xsl:otherwise>
									<name nullFlavor="UNK"/>
								</xsl:otherwise>
							</xsl:choose>
							
							<xsl:apply-templates select="." mode="fn-telecom"/>
							<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
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
			</assignedCustodian>
		</custodian>
	</xsl:template>
	
	<xsl:template match="Patient" mode="fn-code-administrativeGender">
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
		<administrativeGenderCode code="{$genderCode}" codeSystem="{$administrativeGenderOID}"
			codeSystemName="{$administrativeGenderName}" displayName="{$genderDescription}"/>
	</xsl:template>

	<xsl:template match="MaritalStatus" mode="fn-code-maritalStatus">
		<!--
			Field : Patient Marital Status
			Target: /ClinicalDocument/recordTarget/patientRole/patient/maritalStatusCode
			Source: HS.SDA3.Patient MaritalStatus
			Source: /Container/Patient/MaritalStatus
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="fn-generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID" select="$maritalStatusOID"/>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">maritalStatusCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="Race" mode="fn-code-race">
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
		<xsl:apply-templates select="." mode="fn-generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID" select="$raceAndEthnicityCDCOID"/>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">raceCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Race" mode="fn-code-additionalRace">
		<!--
			Field : Patient Additional Races
			Target: /ClinicalDocument/recordTarget/patientRole/patient/sdtc:raceCode
			Source: HS.SDA3.Patient Races
			Source: /Container/Patient/Races/Race[2..n]
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="fn-generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID" select="$raceAndEthnicityCDCOID"/>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<!-- CAUTION: the next line only works because there is a namespace URI associated
				  with the "sdtc" prefix at this point. -->
			<xsl:with-param name="cdaElementName">sdtc:raceCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="EthnicGroup" mode="fn-code-ethnicGroup">
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
				<xsl:when test="string-length($descriptionFromValueSet)">
					<xsl:value-of select="$descriptionFromValueSet"/>
				</xsl:when>
				<xsl:when test="string-length(Description/text())">
					<xsl:value-of select="Description/text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="Code/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="originalText">
			<xsl:choose>
				<xsl:when test="string-length(Description/text())">
					<xsl:value-of select="Description/text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$displayName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="codeSystem">
			<xsl:choose>
				<xsl:when test="SDACodingStandard/text()=$raceAndEthnicityCDCName or SDACodingStandard/text()=$raceAndEthnicityCDCOID">
					<xsl:value-of select="$raceAndEthnicityCDCOID"/>
				</xsl:when>
				<xsl:when test="string-length(SDACodingStandard/text())">
					<xsl:apply-templates select="." mode="fn-oid-for-code">
						<xsl:with-param name="Code" select="SDACodingStandard/text()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$noCodeSystemOID"/>
				</xsl:otherwise>
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
				<xsl:otherwise>
					<xsl:value-of select="$noCodeSystemName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($descriptionFromValueSet) and $codeSystem = $raceAndEthnicityCDCOID">
				<ethnicGroupCode code="{Code/text()}" codeSystem="{$codeSystem}"
					codeSystemName="{$codeSystemName}" displayName="{$displayName}">
					<originalText><xsl:value-of select="$originalText"/></originalText>
				</ethnicGroupCode>
			</xsl:when>
			<xsl:otherwise>
				<ethnicGroupCode nullFlavor="OTH">
					<originalText><xsl:value-of select="$originalText"/></originalText>
					<translation code="{translate(Code/text(),' ','_')}" codeSystem="{$codeSystem}"
						codeSystemName="{$codeSystemName}" displayName="{$displayName}"/>
				</ethnicGroupCode>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Religion" mode="fn-code-religiousAffiliation">
		<!--
			Field : Patient Religion
			Target: /ClinicalDocument/recordTarget/patientRole/patient/religiousAffiliationCode
			Source: HS.SDA3.Patient Religion
			Source: /Container/Patient/Religion
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="fn-generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID" select="$religiousAffiliationOID"/>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">religiousAffiliationCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="CareProviderType" mode="fn-code-function">
		<!--
			StructuredMapping: code-function
			
			Field : Provider Role Coded
			Path  : ./
			Source: CareProvider
			Source: ./CareProvider
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="fn-generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID" select="concat($providerRoleOID,'|',$participationFunctionOID)"/>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">functionCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="Route" mode="fn-code-route">
		<xsl:apply-templates select="." mode="fn-generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID" select="$nciThesaurusOID"/>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">routeCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="fn-value-ST">
		<value xsi:type="ST"><xsl:value-of select="text()"/></value>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-value-PQ">
		<xsl:param name="units"/>
		<!--
			xsi type PQ requires that value be numeric and that
			unit be present.  If one of those conditions is not
			true, then export as a string.
		-->
		<xsl:choose>
			<xsl:when test="(number(text()) and string-length($units))">
				<value xsi:type="PQ" value="{text()}" unit="{$units}"/>
				<!-- template name="fn-unit-to-ucum" is now UNUSED -->
			</xsl:when>
			<xsl:when test="not(string-length($units))">
				<value xsi:type="ST"><xsl:value-of select="text()"/></value>
			</xsl:when>
			<xsl:when test="string-length($units)">
				<value xsi:type="ST"><xsl:value-of select="concat(text(), ' ', $units)"/></value>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-value-Coded">
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
		<xsl:apply-templates select="." mode="fn-generic-Coded">
			<xsl:with-param name="narrativeLink" select="$narrativeLink"/>
			<xsl:with-param name="xsiType" select="$xsiType"/>
			<xsl:with-param name="requiredCodeSystemOID" select="$requiredCodeSystemOID"/>
			<xsl:with-param name="isCodeRequired" select="$isCodeRequired"/>
			<xsl:with-param name="cdaElementName">value</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-value-CD">
		<xsl:apply-templates select="." mode="fn-value-Coded">
			<xsl:with-param name="xsiType">CD</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="fn-value-CE">
		<xsl:apply-templates select="." mode="fn-value-Coded">
			<xsl:with-param name="xsiType">CE</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="ResultNormalRange" mode="fn-value-IVL_PQ">
		<xsl:param name="referenceRangeLowValue"/>
		<xsl:param name="referenceRangeHighValue"/>
		<xsl:param name="referenceRangeUnits"/>
		
		<value xsi:type="IVL_PQ">
			<xsl:choose>
				<xsl:when test="string-length($referenceRangeLowValue) and string-length($referenceRangeUnits)">
					<low value="{$referenceRangeLowValue}" unit="{$referenceRangeUnits}"/>
				</xsl:when>
				<xsl:when test="string-length($referenceRangeLowValue)">
					<low value="{$referenceRangeLowValue}"/>
				</xsl:when>
				<xsl:otherwise>
					<low nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="string-length($referenceRangeHighValue) and string-length($referenceRangeUnits)">
					<high value="{$referenceRangeHighValue}" unit="{$referenceRangeUnits}"/>
				</xsl:when>
				<xsl:when test="string-length($referenceRangeHighValue)">
					<high value="{$referenceRangeHighValue}"/>
				</xsl:when>
				<xsl:otherwise>
					<high nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
		</value>
	</xsl:template>

	<xsl:template match="*" mode="fn-translation">
		<translation code="{Code/text()}">
			<xsl:attribute name="codeSystem">
				<xsl:apply-templates select="." mode="fn-oid-for-code">
					<xsl:with-param name="Code" select="CodeSystem/text()"/>
				</xsl:apply-templates>
			</xsl:attribute>
			<xsl:attribute name="codeSystemName">
				<xsl:value-of select="CodeSystem/text()"/>
			</xsl:attribute>
			<xsl:attribute name="displayName">
				<xsl:value-of select="Description/text()"/>
			</xsl:attribute>
		</translation>
	</xsl:template>

	<xsl:template match="*" mode="fn-id-External-CarePlan">
		<xsl:param name="externalId" select="''"/>
		<!--
			StructuredMapping: id-External-CarePlan			

			Field
			Path  : ./id/@root
			Source: CurrentProperty
			Source: ./

			Field
			Path  : ./id/@extension
			Source: CurrentProperty
			Source: ./

			Note  : CarePlan-related SDA ExternalId is exported as id/@root only when ExternalId
					is present. When ExternalId contains '|', it will be split into root and extension.
					Otherwise, the entire text of the ExternalId is exported to be the id?@root.
					If ExternalId does not exist, <id nullFlavor="UNK"/> is exported.
		-->
		<xsl:choose>
			<xsl:when test="$externalId">
				<id>
					<xsl:choose>
						<xsl:when test="contains($externalId/text(), '|')">
							<xsl:variable name="rootOID">
								<xsl:apply-templates select="." mode="fn-oid-for-code">
									<xsl:with-param name="Code" select="substring-before($externalId/text(), '|')"/></xsl:apply-templates>
							</xsl:variable>

							<xsl:attribute name="root">
								<xsl:value-of select="$rootOID"/>
							</xsl:attribute>
							<xsl:attribute name="extension">
								<xsl:value-of select="substring-after($externalId/text(), '|')"/>
							</xsl:attribute>	
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="root">
								<xsl:value-of select="$externalId/text()"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="*" mode="fn-id-External">
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
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="EnteredAt/Code/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="ExternalId/text()"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of select="concat(EnteredAt/Code/text(), '-ExternalId')"/>
					</xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-id-Placer">
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
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="PlacerId/text()"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of
							select="concat(EnteringOrganization/Organization/Code/text(), '-PlacerId')"/>
					</xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(PlacerId)">
				<id>
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="EnteredAt/Code/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="PlacerId/text()"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of select="concat(EnteredAt/Code/text(), '-PlacerId')"/>
					</xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id root="{isc:evaluate('createGUID')}"
					assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedPlacerId')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-id-Filler">
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
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="FillerId/text()"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of
							select="concat(EnteringOrganization/Organization/Code/text(), '-FillerId')"/>
					</xsl:attribute>
			 	</id>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(FillerId)">
				<id>
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="EnteredAt/Code/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="FillerId/text()"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of select="concat(EnteredAt/Code/text(), '-FillerId')"/>
					</xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id root="{isc:evaluate('createGUID')}"
					assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedFillerId')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-id-ExternalPlacerOrFiller">
	<!--
		id-ExternalPlacerOrFiller exports only the first found of ExternalId,
		PlacerId or FillerId.  If none found then export CDA <id> as a UUID.
	-->
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(ExternalId)">
				<xsl:apply-templates select="." mode="fn-id-External"/>
			</xsl:when>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(PlacerId)">
				<xsl:apply-templates select="." mode="fn-id-Placer"/>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(PlacerId)">
				<xsl:apply-templates select="." mode="fn-id-Placer"/>
			</xsl:when>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(FillerId)">
				<xsl:apply-templates select="." mode="fn-id-Filler"/>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(FillerId)">
				<xsl:apply-templates select="." mode="fn-id-Filler"/>
			</xsl:when>
			<xsl:otherwise><id root="{isc:evaluate('createUUID')}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Medication | Vaccination" mode="fn-id-Medication">
		<xsl:apply-templates select="." mode="fn-id-External"/>
		<xsl:apply-templates select="." mode="fn-id-Placer"/>
		<xsl:apply-templates select="." mode="fn-id-Filler"/>
	</xsl:template>
	
	<xsl:template match="Medication | Vaccination" mode="fn-id-PrescriptionNumber">
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
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="EnteredAt/Code/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="PrescriptionNumber/text()"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of select="concat(EnteredAt/Code/text(), '-PrescriptionNumber')"/>
					</xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}" extension="{concat(EnteredAt/Code/text(), '-UnspecifiedPrescriptionNumber')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-id-Facility">
	  <!-- Match could be PerformedAt, Contact, EnteredAt, HealthFund, Organization -->
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
		<!-- Check to see if the Code and OID values are actually OIDs. -->
	  <xsl:variable name="CodeisOID">
	    <xsl:apply-templates select="." mode="fn-N-isOID">
	      <xsl:with-param name="input" select="Code/text()"/>
	    </xsl:apply-templates>
	  </xsl:variable>
		<xsl:variable name="facilityOID">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
				<xsl:with-param name="Code" select="Code/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="facilityOIDisValid">
		  <xsl:apply-templates select="." mode="fn-N-isOID">
		    <xsl:with-param name="input" select="$facilityOID"/>
		  </xsl:apply-templates>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="boolean(Code/text())">
			  <xsl:if test="$facilityOIDisValid='1'">
					<id root="{$facilityOID}"/>
				</xsl:if>
			  <xsl:if test="$CodeisOID='0'">
					<id>
						<xsl:attribute name="root">
							<xsl:value-of select="$homeCommunityOID"/><!-- a global variable -->
						</xsl:attribute>
						<xsl:attribute name="extension">
							<xsl:call-template name="fn-text-to-UID">
							  <xsl:with-param name="text" select="Code/text()"/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:attribute name="displayable">true</xsl:attribute>
					</id>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="HealthCareFacility | Location | ReferredToOrganization" mode="fn-id-encounterLocation">
		<!-- The location might not be in the OID Registry, which is okay. -->
		<xsl:variable name="locationOID">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
				<xsl:with-param name="Code" select="Code/text()"/>
				<xsl:with-param name="default" select="''"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<!-- This template assumes that organization (if present) is in the OID Registry. -->
		<xsl:variable name="organizationOID">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
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
			<xsl:variable name="hasCode" select="boolean(Code/text())"/>
			<xsl:variable name="hasOrgCode" select="boolean(Organization/Code/text())"/>
			<xsl:choose>
				<xsl:when test="$hasCode and $hasOrgCode">
					<xsl:attribute name="root">
						<xsl:value-of select="$organizationOID"/>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="Code/text()"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="string-length($locationOID)">
					<xsl:attribute name="root">
						<xsl:value-of select="$locationOID"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="$hasOrgCode">
					<xsl:attribute name="root">
						<xsl:value-of select="$organizationOID"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="$hasCode">
					<xsl:attribute name="root">
						<xsl:value-of select="Code/text()"/>
					</xsl:attribute>
				</xsl:when>
			</xsl:choose>
		</id>
	</xsl:template>
	
	<xsl:template match="Patient" mode="fn-id-Document">
		<xsl:choose>
			<xsl:when test="string-length($documentUniqueId)">
				<id root="{$documentUniqueId}"/>
			</xsl:when>
			<xsl:otherwise>
				<id root="{isc:evaluate('createUUID')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Encounter" mode="fn-id-Encounter">
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
		<xsl:choose>
			<xsl:when test="string-length(HealthCareFacility/Organization/Code) and string-length(EncounterNumber)">
				<id>
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="HealthCareFacility/Organization/Code/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:apply-templates select="EncounterNumber" mode="fn-encounterNumber-converted"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of	select="concat(HealthCareFacility/Organization/Code/text(), '-EncounterId')"/>
					</xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-id-Clinician">
	  <!-- Match could be Clinician, Contact, FamilyDoctor, CareProvider, AdmittingClinician, DiagnosingClinician,
		ReferringClinician, EnteredBy, OrderedBy, VerifiedBy, SupportContact, PerformedAt, EnteredAt, Organization -->
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
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="SDACodingStandard/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="Code/text()"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="string-length(Code)">
				<id>
			 		<xsl:attribute name="root"><xsl:value-of select="$noCodeSystemOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="Code/text()"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-id-HealthShare">
		<id root="{$healthShareOID}"/>
	</xsl:template>

	<xsl:template match="HealthFund" mode="fn-id-PayerGroup">
		<!--
			StructuredMapping: id-PayerGroup
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : SDA GroupNumber is exported as @extension only when GroupName is also present.
			In that case the OID for GroupName is also exported, as @root.
			Otherwise <id nullFlavor="UNK"/> is exported.
		-->
		<xsl:choose>
			<xsl:when test="string-length(GroupName) and string-length(GroupNumber)">
				<id>
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="GroupName/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="GroupNumber/text()"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of select="concat(GroupName/text(), '-PayerGroupId')"/>
					</xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
	<xsl:template match="*" mode="fn-id-ExternalId-concatenated">
		<!--
			StructuredMapping: fn-id-ExternalId-concatenated
			Note  : Expects an ExternalId of the form "<ExternalId>root|extension</ExternalId>"
			
			Field
			Path  : ./
			Source: ExternalId
			Source: ./ExternalId
			StructuredMappingRef: fn-id-concatenated
		-->
		<xsl:choose>
			<xsl:when test="ExternalId">
				<xsl:apply-templates select="ExternalId" mode="fn-id-concatenated" />
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-id-concatenated">
		<!--
			StructuredMapping: fn-id-concatenated
			Note  : Expects an ExternalId of the form "<ExternalId>root|extension</ExternalId>"
			
			Field
			Path  : ./id/@root
			Source: CurrentProperty
			Source: ./

			Field
			Path  : ./id/@extension
			Source: CurrentProperty
			Source: ./
		-->
		<xsl:variable name="extension" select="substring-after(text(), '|')" />
		<id>
			<xsl:choose>
				<xsl:when test="string-length($extension)">
					<xsl:attribute name="root">
						<xsl:value-of select="substring-before(text(), '|')" />
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="$extension" />
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="root">
						<xsl:value-of select="text()" />
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</id>
	</xsl:template>
  
	<xsl:template match="Medication" mode="fn-effectiveTime-IVL_TS">
		<xsl:choose>
			<xsl:when test="string-length(FromTime) or string-length(ToTime)">
				<effectiveTime xsi:type="IVL_TS">
					<xsl:apply-templates select="." mode="fn-effectiveTime-low"/>
					<xsl:apply-templates select="." mode="fn-effectiveTime-high"/>
				</effectiveTime>
			</xsl:when>
			<xsl:otherwise>
				<effectiveTime xsi:type="IVL_TS" nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Frequency" mode="fn-effectiveTime-PIVL_TS">
		<!--
			Field: Medication Frequency
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
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

			<xsl:variable name="codeLower" select="translate(normalize-space(Code/text()), $upperCase, $lowerCase)"/>
			<!--<xsl:variable name="codeP1" select="isc:evaluate('piece', $codeLower, ' ', '1')"/> etc. -->
			<xsl:variable name="codeP1" select="substring-before($codeLower, ' ')"/>
			<xsl:variable name="P23temp" select="substring-after($codeLower, ' ')"/>
			<xsl:variable name="codeP2" select="substring-before($P23temp, ' ')"/>
			<xsl:variable name="codeP3" select="substring-before(substring-after($P23temp, ' '), ' ')"/>
			<!-- ToDoXSLT2: use tokenize above -->
			<xsl:variable name="singular" select="'|s|sec|second|min|minute|h|hr|hour|d|day|w|week|mon|month|y|yr|year|'"/>
			<xsl:variable name="plural" select="'|s|sec|secs|seconds|min|mins|minutes|h|hr|hrs|hour|hours|d|day|days|w|week|weeks|mon|mons|month|months|y|yr|yrs|year|years|'"/>
			<xsl:variable name="codeNoSpaces" select="translate($codeLower, ' ', '')"/>
			<xsl:variable name="codeNoSpacesLength" select="string-length($codeNoSpaces)"/>
			
			<xsl:choose>
				<!-- ex: "4 hours" (interval) -->
				<xsl:when test="number($codeP1) and contains($plural, concat('|',$codeP2, '|'))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{$codeP1}" unit="{$codeP2}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- BID means twice a day (frequency) -->
				<xsl:when test="$codeP1 = 'bid'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="12" unit="h"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- TID means three times a day (frequency) -->
				<xsl:when test="$codeP1 = 'tid'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="8" unit="h"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- QID means four times a day (frequency) -->
				<xsl:when test="$codeP1 = 'qid'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="6" unit="h"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- nID means n times a day (frequency) -->
				<xsl:when test="contains($codeP1, 'id') and number(substring-before($codeP1, 'id'))">
					<xsl:variable name="periodValue" select="24 div number(substring-before($codeP1, 'id'))"/>
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="{$periodValue}" unit="h"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- QD means once a day (frequency) -->
				<xsl:when test="$codeP1 = 'qd'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="1" unit="d"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- QOD means every other day (frequency) -->
				<xsl:when test="$codeP1 = 'qod'">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="2" unit="d"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n seconds, minutes, hours, days, or weeks (interval) ('q' plus number plus unit) -->
				<xsl:when
					test="$codeNoSpacesLength > 2 and starts-with($codeNoSpaces, 'q') 
					       and contains('|s|m|h|d|w|m|y|l|', concat('|', substring($codeNoSpaces, $codeNoSpacesLength), '|')) 
					       and number(substring($codeNoSpaces, 2, $codeNoSpacesLength - 2))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{number(substring($codeNoSpaces,2,$codeNoSpacesLength - 2))}"
							unit="{substring($codeNoSpaces,$codeNoSpacesLength)}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n seconds, minutes, hours, days, or weeks (interval) ('q' plus unit plus number) -->
				<xsl:when
					test="(starts-with($codeP1, 'qs') or starts-with($codeP1, 'qm') or starts-with($codeP1, 'qh') or starts-with($codeP1, 'qd') or starts-with($codeP1, 'qw')) 
					       and (number(substring($codeP1, 3)) or number($codeP2))">
					<xsl:variable name="periodValue">
						<xsl:choose>
							<xsl:when test="number(substring($codeP1, 3))">
								<xsl:value-of select="substring($codeP1, 3)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$codeP2"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{$periodValue}" unit="{substring($codeP1,2,1)}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n months (interval) ('q' plus number plus 'mo') -->
				<xsl:when
					test="$codeNoSpacesLength > 3 and starts-with($codeNoSpaces, 'q')
					       and substring($codeNoSpaces, $codeNoSpacesLength - 1, 2) = 'mo' 
					       and number(substring($codeNoSpaces, 2, $codeNoSpacesLength - 3))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{number(substring($codeNoSpaces,2,$codeNoSpacesLength - 3))}"
							unit="mon"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- every n months (interval) ('q' plus number plus 'mon') -->
				<xsl:when
					test="$codeNoSpacesLength > 4 and starts-with($codeNoSpaces, 'q') 
					       and substring($codeNoSpaces, $codeNoSpacesLength - 2, 3) = 'mon' 
					       and number(substring($codeNoSpaces, 2, $codeNoSpacesLength - 4))">
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="false" operator="A">
						<period value="{number(substring($codeNoSpaces,2,$codeNoSpacesLength - 4))}"
							unit="mon"/>
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
				<xsl:when
					test="number($codeP1) and contains('|a|an|per|x|', concat('|', $codeP2, '|'))
						and contains($singular, concat('|', $codeP3, '|'))">
					<xsl:variable name="periodUnit1">
						<xsl:choose>
							<xsl:when test="starts-with($codeP3, 'h')">h</xsl:when>
							<xsl:when test="starts-with($codeP3, 'd')">d</xsl:when>
							<xsl:when test="starts-with($codeP3, 'w')">w</xsl:when>
							<xsl:when test="starts-with($codeP3, 'mon')">mon</xsl:when>
							<xsl:when test="starts-with($codeP3, 'y')">y</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodValue">
						<xsl:choose>
							<xsl:when test="$codeP1 = '1'">1</xsl:when>
							<xsl:when test="$periodUnit1 = 'h'">
								<xsl:value-of select="60 div $codeP1"/>
							</xsl:when>
							<xsl:when test="$periodUnit1 = 'd'">
								<xsl:value-of select="24 div $codeP1"/>
							</xsl:when>
							<xsl:when test="$periodUnit1 = 'w'">
								<xsl:value-of select="7 div $codeP1"/>
							</xsl:when>
							<xsl:when test="$periodUnit1 = 'mon'">
								<xsl:value-of select="round(30 div $codeP1)"/>
							</xsl:when>
							<xsl:when test="$periodUnit1 = 'y'">
								<xsl:value-of select="round(365 div $codeP1)"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodUnit">
						<xsl:choose>
							<xsl:when test="$codeP1 = '1'">
								<xsl:value-of select="$periodUnit1"/>
							</xsl:when>
							<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="starts-with($codeP3, 'h')">min</xsl:when>
							<xsl:when test="starts-with($codeP3, 'd')">h</xsl:when>
							<xsl:when test="starts-with($codeP3, 'w')">d</xsl:when>
							<xsl:when test="starts-with($codeP3, 'mon')">d</xsl:when>
							<xsl:when test="starts-with($codeP3, 'y')">d</xsl:when>
						</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<effectiveTime xsi:type="PIVL_TS" institutionSpecified="true" operator="A">
						<period value="{$periodValue}" unit="{$periodUnit}"/>
					</effectiveTime>
				</xsl:when>
				
				<!-- ex: "4xD" (frequency) -->
				<xsl:when test="contains($codeP1, 'x') and not(string-length($codeP2)) 
					       and number(substring-before($codeP1, 'x')) 
					       and contains($singular, concat('|', substring-after($codeP1, 'x'), '|'))">
					<xsl:variable name="numberBeforeX" select="substring-before($codeP1, 'x')"/>
					<xsl:variable name="tempUnit" select="substring-after($codeP1, 'x')"/>
					<xsl:variable name="periodUnit1">
						<xsl:choose>
							<xsl:when test="starts-with($tempUnit, 'h')">h</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'd')">d</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'w')">w</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'mon')">mon</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'y')">y</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodValue">
						<xsl:choose>
							<xsl:when test="$numberBeforeX = '1'">1</xsl:when>
							<xsl:when test="$periodUnit1 = 'h'">
								<xsl:value-of select="60 div $numberBeforeX"/>
							</xsl:when>
							<xsl:when test="$periodUnit1 = 'd'">
								<xsl:value-of select="24 div $numberBeforeX"/>
							</xsl:when>
							<xsl:when test="$periodUnit1 = 'w'">
								<xsl:value-of select="7 div $numberBeforeX"/>
							</xsl:when>
							<xsl:when test="$periodUnit1 = 'mon'">
								<xsl:value-of select="round(30 div $numberBeforeX)"/>
							</xsl:when>
							<xsl:when test="$periodUnit1 = 'y'">
								<xsl:value-of select="round(365 div $numberBeforeX)"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="periodUnit">
						<xsl:choose>
							<xsl:when test="$numberBeforeX = '1'">
								<xsl:value-of select="$periodUnit1"/>
							</xsl:when>
							<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="starts-with($tempUnit, 'h')">min</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'd')">h</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'w')">d</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'mon')">d</xsl:when>
							<xsl:when test="starts-with($tempUnit, 'y')">d</xsl:when>
						</xsl:choose>
							</xsl:otherwise>
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
	
	<xsl:template match="*" mode="fn-effectiveTime-FromTo">
		<!-- This is a general-purpose template to produce an effectiveTime element with two
			sub-elements, one for low and (optionally) one for high. Use the boolean
      $includeHighTime param to specify whether the high sub-element is produced.
			Apply it to the node whose children are FromTime and (optionally) ToTime.
			The nullFlavor attribute will be emitted if there is no text, and you can use the
		  $paramNullFlavor param to change the string from the "UNK" default. -->
		<xsl:param name="includeHighTime" select="true()"/>
		<xsl:param name="paramNullFlavor" select="'UNK'"/>
		
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(FromTime/text())">
					<low>
						<xsl:attribute name="value">
							<xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:attribute>
					</low>
				</xsl:when>
				<xsl:otherwise>
					<low nullFlavor="{$paramNullFlavor}"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$includeHighTime">
				<xsl:choose>
					<xsl:when test="string-length(ToTime/text())">
						<high>
							<xsl:attribute name="value">
								<xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/>
							</xsl:attribute>
						</high>
					</xsl:when>
					<xsl:otherwise>
						<high nullFlavor="{$paramNullFlavor}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="Diagnosis | Encounter" mode="fn-effectiveTime-Identification">
		<xsl:param name="includeHighTime" select="true()"/>
		
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(IdentificationTime/text())">
					<low>
						<xsl:attribute name="value">
							<xsl:apply-templates select="IdentificationTime" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:attribute>
					</low>
				</xsl:when>
				<xsl:otherwise>
					<low nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$includeHighTime = true()">
				<high nullFlavor="UNK"/>
			</xsl:if>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-effectiveTime-singleton">
		<!-- This is a general-purpose template to produce an effectiveTime element with a single
		   value attribute. Apply it to the node whose text content is the date-time to become
		   the value. The nullFlavor attribute will be emitted if there is no text. -->
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(text())">
					<xsl:attribute name="value">
						<xsl:apply-templates select="." mode="fn-xmlToHL7TimeStamp"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-effectiveTime-singletonChoice">
		<!-- This is a general-purpose template to produce an effectiveTime element with a single
		   value attribute. Apply it to the node that is an event with a single point in time
		   (e.g., Vaccination) and may have either a FromTime or EnteredOn child to indicate
		   when it occurred.
		   The nullFlavor attribute will be emitted if neither FromTime nor EnteredOn is present. -->
		<xsl:choose>
			<xsl:when test="string-length(FromTime)">
				<effectiveTime>
					<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute>
				</effectiveTime>
			</xsl:when>
			<xsl:when test="string-length(EnteredOn)">
				<effectiveTime>
					<xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute>
				</effectiveTime>
			</xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-effectiveTime">
	  <!-- Match could be RadOrder, LabOrder, OtherOrder, Appointment, CustomObject (Goal, Instructions) -->
	  <xsl:param name="includeHighTime" select="true()"/>
		
		<xsl:choose>
			<xsl:when test="not(string-length(concat(EnteredOn,FromTime,StartTime,ToTime,EndTime)))">
				<effectiveTime>
					<low nullFlavor="UNK"/>
					<xsl:if test="$includeHighTime">
						<high nullFlavor="UNK"/>
					</xsl:if>
				</effectiveTime>
			</xsl:when>
			<xsl:when test="string-length(EnteredOn) or (string-length(FromTime) or string-length(StartTime)) or (string-length(ToTime) or string-length(EndTime))">
				<effectiveTime>
					<xsl:if test="string-length(EnteredOn)">
						<xsl:attribute name="value">
							<xsl:apply-templates select="EnteredOn" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:attribute>
					</xsl:if>
					
					<xsl:apply-templates select="." mode="fn-effectiveTime-low"/>
					<xsl:if test="$includeHighTime">
						<xsl:apply-templates select="." mode="fn-effectiveTime-high"/>
					</xsl:if>
				</effectiveTime>
			</xsl:when>
			<xsl:otherwise>
				<effectiveTime nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-time">
		<!-- This is similar to fn-effectiveTime-FromTo, except
		     (1) the outer element is named time,
		 and (2) high is always included. -->
		<xsl:choose>
			<xsl:when test="(string-length(FromTime) or string-length(StartTime)) or (string-length(ToTime) or string-length(EndTime))">
				<time>
					<xsl:apply-templates select="." mode="fn-effectiveTime-low"/>
					<xsl:apply-templates select="." mode="fn-effectiveTime-high"/>
				</time>
			</xsl:when>
			<xsl:otherwise>
				<time nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-effectiveTime-low">
		<!-- This is a general-purpose template to produce the low sub-element for an 
			 effectiveTime element. Apply it to the node whose children are FromTime or
			 StartTime. The nullFlavor attribute will be emitted if there is no text
		   in either. -->
		<xsl:choose>
			<xsl:when test="string-length(FromTime)">
				<low>
					<xsl:attribute name="value">
						<xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/>
					</xsl:attribute>
				</low>
			</xsl:when>
			<xsl:when test="string-length(StartTime)">
				<low>
					<xsl:attribute name="value">
						<xsl:apply-templates select="StartTime" mode="fn-xmlToHL7TimeStamp"/>
					</xsl:attribute>
				</low>
			</xsl:when>
			<xsl:otherwise>
				<low nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-effectiveTime-high">
		<!-- This is a general-purpose template to produce the high sub-element for an 
			 effectiveTime element. Apply it to the node whose children are FromTime or
			 StartTime. The nullFlavor attribute will be emitted if there is no text
		   in either. This always produces an element; any choice about possibly not
		   producing it must be made at the calling point. -->
		<xsl:choose>
			<xsl:when test="string-length(ToTime)">
				<high>
					<xsl:attribute name="value">
						<xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/>
					</xsl:attribute>
				</high>
			</xsl:when>
			<xsl:when test="string-length(EndTime)">
				<high>
					<xsl:attribute name="value">
						<xsl:apply-templates select="EndTime" mode="fn-xmlToHL7TimeStamp"/>
					</xsl:attribute>
				</high>
			</xsl:when>
			<xsl:otherwise>
				<high nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-xmlToHL7TimeStamp">
		<!-- convert Z to -00:00 -->
		<xsl:variable name="text">
			<xsl:choose>
				<xsl:when test="contains(text(),'Z')">
					<xsl:value-of select="concat(substring-before(normalize-space(text()), 'Z'), '-00:00')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(text())"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- remove date/time separators while preserving milliseconds and timezone offset -->
		<xsl:choose>
			<xsl:when test="string-length($text) > 10"> 
				<xsl:value-of select="concat(translate(substring($text,1,10), '-', ''), translate(substring($text,12), ':', ''))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate($text, '-', '')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-xmlToHL7TimeStampYYYYMMDD">
		<xsl:value-of select="substring(translate(text(), 'TZ:- ', ''), 1, 8)"/>
	</xsl:template>	

	<xsl:template match="*" mode="fn-encounterLink-component">
	  <!-- Match can be Observation or any element that can have Result as a child -->
	  <!--
			StructuredMapping: encounterLink-component
			
			Field
			Path  : encounter
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: encounterLink-Detail
		-->
		<xsl:if test="string-length(EncounterNumber)">
			<!-- EncNum key is declared at top of this file. It returns Encounter elements. -->
			<xsl:variable name="encounter" select="key('EncNum', EncounterNumber)[1]"/>
			<xsl:if test="count($encounter) &gt; 0 and contains('|I|O|E|', concat('|', $encounter/EncounterType/text(), '|'))">
				<!-- above is the encounter-IsValid test -->
				<component>
					<xsl:apply-templates select="$encounter" mode="fn-encounterLink-Detail"/>
				</component>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="fn-encounterLink-entryRelationship">
	  <!-- Match can be Procedure, RadOrder, LabOrder, OtherOrder, Medication, Vaccination, Problem, Diagnosis -->
	  <!--
			StructuredMapping: encounterLink-entryRelationship
			
			Field
			Path  : encounter
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: encounterLink-Detail
		-->
		<xsl:if test="string-length(EncounterNumber)">
			<!-- EncNum key is declared at top of this file. It returns Encounter elements. -->
			<xsl:variable name="encounter" select="key('EncNum', EncounterNumber)[1]"/>
			<xsl:if test="count($encounter) &gt; 0 and contains('|I|O|E|', concat('|', $encounter/EncounterType/text(), '|'))">
				<!-- above is the encounter-IsValid test -->
				<entryRelationship typeCode="SUBJ" inversionInd="true">
					<xsl:apply-templates select="$encounter" mode="fn-encounterLink-Detail"/>
				</entryRelationship>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Encounter" mode="fn-encounterLink-Detail">
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
		<!-- ToDo: re-examine the root="None" scenario. -->
		
		<encounter classCode="ENC" moodCode="EVN">
			<id>
				<xsl:attribute name="root">
					<xsl:choose>
						<xsl:when test="string-length(HealthCareFacility/Organization/Code/text())">
							<xsl:apply-templates select="." mode="fn-oid-for-code">
								<xsl:with-param name="Code" select="HealthCareFacility/Organization/Code/text()"/>
							</xsl:apply-templates>
						</xsl:when>
						<!-- The next part may be too activist. May want to let bad SDA data fail elsewhere. -->
						<xsl:otherwise>None</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="extension"><xsl:apply-templates select="EncounterNumber" mode="fn-encounterNumber-converted"/></xsl:attribute>
			</id>
		</encounter>
	</xsl:template>

	<xsl:template match="Code" mode="fn-code-to-description">
		<xsl:param name="identityType"/>
		<xsl:param name="defaultDescription" select="''"/>		
		<!--
			If getDescriptionForOID finds no Description in the OID Registry for
			the specified Code, then return $defaultDescription if specified.
		-->
		<xsl:variable name="oidForCode">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
				<xsl:with-param name="Code" select="text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<!-- $descriptionForOID will be equal to $oidForCode if no Description was found. -->
		<xsl:variable name="descriptionForOID">
			<xsl:value-of select="isc:evaluate('getDescriptionForOID', $oidForCode, $identityType)"/>
		</xsl:variable>
		
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
	
	<xsl:template match="Status" mode="fn-snomed-Status">
		<xsl:param name="narrativeLink"/>
	<!--
		snomed-Status is a special case value-Coded template for
		status fields that have to be SNOMED status codes.
	-->
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
		<xsl:variable name="xsiType" select="'CD'"/><!-- ToDo: explain why this is a variable -->
		
		<xsl:variable name="sdaCodingStandardOID">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
				<xsl:with-param name="Code" select="SDACodingStandard/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:variable name="snomedStatusCodes">|55561003|73425007|90734009|7087005|255227004|415684004|410516002|413322009|</xsl:variable>
		<xsl:variable name="isValidSnomedCode" select="contains($snomedStatusCodes, concat('|', Code/text(), '|'))"/>
		
		<xsl:variable name="codeSystemOIDForTranslation">
			<xsl:choose>
				<xsl:when test="string-length($sdaCodingStandardOID)">
					<xsl:value-of select="$sdaCodingStandardOID"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$noCodeSystemOID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codeSystemNameForTranslation">
			<xsl:choose>
				<xsl:when test="string-length($sdaCodingStandardOID)">
					<xsl:value-of select="SDACodingStandard/text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$noCodeSystemName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:apply-templates select="." mode="fn-descriptionOrCode"/>
		</xsl:variable>
		
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
				<value code="{Code/text()}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}"
					displayName="{$description}">
					<xsl:if test="string-length($xsiType)">
						<xsl:attribute name="xsi:type">
							<xsl:value-of select="$xsiType"/>
						</xsl:attribute>
					</xsl:if>
					
					<xsl:if test="$sdaCodingStandardOID != $snomedOID"><translation
						  code="{Code/text()}" codeSystem="{$codeSystemOIDForTranslation}"
							codeSystemName="{$codeSystemNameForTranslation}" displayName="{Description/text()}"/>
					</xsl:if>
					<xsl:apply-templates select="PriorCodes/PriorCode[Type = 'O' or Type = 'A']" mode="fn-translation"/>
				</value>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:variable name="snomedStatusCode">
					<xsl:apply-templates select="." mode="fn-snomed-Status-Code"/>
				</xsl:variable>
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
				<value code="{$snomedStatusCode}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}"
					displayName="{$description2}">
					<xsl:if test="string-length($xsiType)">
						<xsl:attribute name="xsi:type">
							<xsl:value-of select="$xsiType"/>
						</xsl:attribute>
					</xsl:if>
					<translation code="{translate(Code/text(),' ','_')}"
						codeSystem="{$codeSystemOIDForTranslation}"
						codeSystemName="{$codeSystemNameForTranslation}" displayName="{$description}"/>
					<xsl:apply-templates select="PriorCodes/PriorCode[Type = 'O' or Type = 'A']" mode="fn-translation"/>
				</value>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Status" mode="fn-snomed-Status-Code">
	<!--
		snomed-Status-Code returns a SNOMED status code, based
		on the Code and Description properties and the list of
		valid SNOMED status codes.
	-->
		<xsl:variable name="codeUpper" select="translate(Code/text(), $lowerCase, $upperCase)"/>
		<xsl:variable name="descUpper" select="translate(Description/text(), $lowerCase, $upperCase)"/>
		
		<xsl:choose>
			<xsl:when
				test="contains('|55561003|73425007|90734009|7087005|255227004|415684004|410516002|413322009|', concat('|', Code/text(), '|'))">
				<xsl:value-of select="Code/text()"/>
			</xsl:when>
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
	
	<xsl:template match="*" mode="fn-generic-Coded">
	  <!-- generic-Coded has common logic for handling coded element fields. -->
		<xsl:param name="cdaElementName" select="'code'"/>
		<xsl:param name="hsCustomPairElementName"/>
		<xsl:param name="requiredCodeSystemOID"/>
		<xsl:param name="isCodeRequired" select="'0'"/>
		<xsl:param name="writeOriginalText" select="'1'"/>
		<xsl:param name="narrativeLink"/>
		<xsl:param name="xsiType"/>
		<xsl:param name="displayText"/>
		
		<!--
			cdaElementName is the name of the element being created (code, value, maritalStatusCode, etc.)
			
			If hsCustomPairElementName has content, this template goes into an alternate behavior
			to extract data from descendants of the NVPair element. The structure of the output
			is not affected.
			
      requiredCodeSystemOID is the OID of a specifically required codeSystem. It may be
      multiple OIDs, delimited by vertical bar.
			
			isCodeRequired indicates whether or not code nullFlavor is allowed.
			
			writeOriginalText is a flag indicating whether to emit an originalText element, and
			if so, the narrativeLink param, if populated, will go into the reference sub-element
			
			If xsiType is populated, its value is used for an xsi:Type attribute added to the
			element.
			
			displayText can override the SDA information as the source for displayName.
		-->

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
		
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="not(string-length($hsCustomPairElementName))">
				  <xsl:value-of select="translate(Code/text(),' ','_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="NVPair[Name/text() = concat($hsCustomPairElementName, 'Code')]/Value/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	  <xsl:variable name="codingStandard">
	    <xsl:choose>
	      <xsl:when test="not(string-length($hsCustomPairElementName))">
	        <xsl:value-of select="SDACodingStandard/text()"/>
	      </xsl:when>
	      <xsl:otherwise>
	        <xsl:value-of select="NVPair[Name/text() = concat($hsCustomPairElementName, 'CodingStandard')]/Value/text()"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  <xsl:variable name="sdaCodingStandardOID">
	    <xsl:apply-templates select="." mode="fn-oid-for-code">
	      <xsl:with-param name="Code" select="$codingStandard"/>
	    </xsl:apply-templates>
	  </xsl:variable>
	  <xsl:variable name="descriptionFromSDA">
	    <xsl:choose>
	      <xsl:when test="not(string-length($hsCustomPairElementName)) and string-length(Description/text())">
	        <xsl:value-of select="Description/text()"/>
	      </xsl:when>
	      <xsl:when test="string-length($hsCustomPairElementName) and
	        string-length(NVPair[Name/text() = concat($hsCustomPairElementName, 'Description')]/Value/text())">
	        <xsl:value-of select="NVPair[Name/text() = concat($hsCustomPairElementName, 'Description')]/Value/text()"/>
	      </xsl:when>
	      <xsl:otherwise>
	        <xsl:value-of select="$code"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  <xsl:variable name="description">
	    <xsl:choose>
	      <xsl:when test="string-length($displayText)">
	        <xsl:value-of select="$displayText"/>
	      </xsl:when>
	      <xsl:otherwise>
	        <xsl:value-of select="$descriptionFromSDA"/>
	      </xsl:otherwise>
	    </xsl:choose>
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
						<xsl:when test="string-length($sdaCodingStandardOID)">
							<xsl:value-of select="$sdaCodingStandardOID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$noCodeSystemOID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="codeSystemNameForTranslation">
					<xsl:choose>
						<xsl:when test="string-length($sdaCodingStandardOID)">
							<xsl:value-of select="$codingStandard"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$noCodeSystemName"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="needsCodeSystemOID" select="boolean(string-length($requiredCodeSystemOID))"/>				
				<!--
					If the requirements for this coded element require
					a code element to be exported regardless of the
					SDACodingStandard value, $noCodeSystem may need to
					be forced in as the code system.
				-->
				
				<xsl:variable name="codeSystemOIDPrimary">
					<xsl:choose>
						<xsl:when test="$needsCodeSystemOID and
						          not(contains(concat('|', $requiredCodeSystemOID, '|'), concat('|', $sdaCodingStandardOID, '|')))">
							<xsl:choose>
								<xsl:when test="not(contains($requiredCodeSystemOID,'|'))">
									<xsl:value-of select="$requiredCodeSystemOID"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring-before($requiredCodeSystemOID,'|')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="not($needsCodeSystemOID) and $isCodeRequired = '1' and not(string-length($sdaCodingStandardOID))">
							<xsl:value-of select="$noCodeSystemOID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$sdaCodingStandardOID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="codeSystemNamePrimary">
					<xsl:apply-templates select="." mode="fn-code-for-oid">
						<xsl:with-param name="OID" select="$codeSystemOIDPrimary"/>
					</xsl:apply-templates>
				</xsl:variable>
				
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
						<xsl:when test="$needsCodeSystemOID
							and not(contains(concat('|', $requiredCodeSystemOID, '|'), concat('|', $sdaCodingStandardOID, '|')))">true</xsl:when>
						<xsl:when test="not($needsCodeSystemOID) and $isCodeRequired = '0' and not(string-length($sdaCodingStandardOID))">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
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
						<xsl:when test="$needsCodeSystemOID and $isCodeRequired = '0'
							and not(contains(concat('|', $requiredCodeSystemOID, '|'), concat('|', $sdaCodingStandardOID, '|')))">true</xsl:when>
						<xsl:when test="not($needsCodeSystemOID) and $isCodeRequired = '0' and not(string-length($sdaCodingStandardOID))">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>					
						
				<xsl:element name="{$cdaElementName}">
					<xsl:choose>
						<xsl:when test="$makeNullFlavor = 'true'">
							<xsl:choose>
								<xsl:when test="$addTranslation = 'true'">
									<xsl:attribute name="nullFlavor">OTH</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="code">
								<xsl:value-of select="translate($code, ' ', '_')"/>
							</xsl:attribute>
							<xsl:attribute name="codeSystem">
								<xsl:value-of select="$codeSystemOIDPrimary"/>
							</xsl:attribute>
							<xsl:attribute name="codeSystemName">
								<xsl:value-of select="$codeSystemNamePrimary"/>
							</xsl:attribute>
							<xsl:if test="string-length($description)">
								<xsl:attribute name="displayName">
									<xsl:value-of select="$description"/>
								</xsl:attribute>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="string-length($xsiType)">
						<xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute>
					</xsl:if>
							
					<xsl:if test="$writeOriginalText = '1'">
						<originalText>
							<xsl:choose>
								<xsl:when test="string-length($narrativeLink)">
									<reference value="{$narrativeLink}"/>
								</xsl:when>
								<xsl:when test="string-length(OriginalText)">
									<xsl:value-of select="OriginalText"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$description"/>
								</xsl:otherwise>
							</xsl:choose>
						</originalText>
					</xsl:if>
							
					<xsl:if test="$addTranslation = 'true'">
						<translation code="{translate($code,' ','_')}"
							codeSystem="{$codeSystemOIDForTranslation}"
							codeSystemName="{$codeSystemNameForTranslation}" displayName="{$descriptionFromSDA}"/>
					</xsl:if>
					<xsl:apply-templates select="PriorCodes/PriorCode[Type = 'O' or Type = 'A']" mode="fn-translation"/>
				</xsl:element>
			</xsl:when>
			
			<xsl:otherwise>
			  <!--
				If there is no Code, then add as much information
				to this nullFlavored element as is available.
	  		-->
			  <xsl:variable name="CodingStandardIsOID">
			    <xsl:apply-templates select="." mode="fn-N-isOID">
			      <xsl:with-param name="input" select="$codingStandard"/>
			    </xsl:apply-templates>
			  </xsl:variable>
			  <xsl:variable name="CodingStandardOIDIsOID">
			    <xsl:apply-templates select="." mode="fn-N-isOID">
			      <xsl:with-param name="input" select="$sdaCodingStandardOID"/>
			    </xsl:apply-templates>
			  </xsl:variable>
			  <!-- 
					When attributes other than nullFlavor are exported, this
					logic has no control over the order in which the attributes
					actually appear in the output XML.
				-->
			  <xsl:element name="{$cdaElementName}">
					<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
					<xsl:if test="string-length($xsiType)">
						<xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute>
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
			    <xsl:choose>
			      <xsl:when test="$CodingStandardOIDIsOID='1'">
			        <xsl:attribute name="codeSystem">
			          <xsl:value-of select="$sdaCodingStandardOID"/>
			        </xsl:attribute>
			        <xsl:if test="string-length($description)">
			          <xsl:attribute name="displayName">
			            <xsl:value-of select="$description"/>
			          </xsl:attribute>
			        </xsl:if>
			      </xsl:when>
			      <xsl:when test="(string-length($codingStandard) and $CodingStandardIsOID='0') or (string-length($description))">
			        <translation>
			          <xsl:if test="string-length($codingStandard) and $CodingStandardIsOID='0'">
			            <xsl:attribute name="codeSystemName">
			              <xsl:value-of select="$codingStandard"/>
			            </xsl:attribute>
			          </xsl:if>
			          <xsl:if test="string-length($description)">
			            <xsl:attribute name="displayName">
			              <xsl:value-of select="$description"/>
			            </xsl:attribute>
			          </xsl:if>
			        </translation>
			      </xsl:when>
			    </xsl:choose>
			  </xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-code-for-oid">
	<!--
		code-for-oid returns the IdentityCode for a specified OID.
		If no IdentityCode is found, then $default is returned.
	-->
		<xsl:param name="OID"/>
		<xsl:param name="default" select="$OID"/>
		
		<xsl:value-of select="isc:evaluate('getCodeForOID',$OID,'',$default)"/>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-oid-for-code">
		<!--
		oid-for-code returns the OID for a specified IdentityCode.
		If no OID is found, then $default is returned.
  	-->
		<xsl:param name="Code"/>
		<xsl:param name="default" select="$Code"/>
		
		<xsl:value-of select="isc:evaluate('getOIDForCode',$Code,'',$default)"/>
	</xsl:template>
	
  <xsl:template match="node()" mode="fn-N-isOID">
    <xsl:param name="input"/>
    <!--
		Determine if the specified text is an OID. The context node is ignored.
		It is considered an OID if all of the following are true:
		- Starts with "1." or "2."
		- Is at least 10 characters long
		- Has 4 or more "."
		- Has no characters other than numbers and "."'s
	-->
    <!-- ToDoXSLT2: use some regular-expression matching functions; make this a boolean-valued function -->
    
    <xsl:choose>
      <xsl:when test="(starts-with($input,'1.') or starts-with($input,'2.')) and string-length($input)>10 and string-length(translate($input,translate($input,'.',''),''))>3 and not(string-length(translate($input,'0123456789.','')))">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="fn-telecom-regex">
	  <!-- match could be HomePhoneNumber, WorkPhoneNumber, MobilePhoneNumber -->
	  <!--
		telecom-regex implements pattern checking against
		two regular expressions: '\+?[-0-9().]+' and '.\d+.'
		
		ToDoXSLT2: This template is needed because fn:matches is not
		available to XSLT 1.0.
		
		Return the normalize-space of the original value if
		it passes, return nothing if it does not.
	-->
		<xsl:variable name="telecomToUse">
			<xsl:choose>
				<xsl:when test="starts-with(normalize-space(text()), '+')">
					<xsl:value-of select="substring(normalize-space(text()), 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(text())"/>
				</xsl:otherwise>
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
		<xsl:if test="substring($telecomToUse, 1, 1) = '0' or number(substring($telecomToUse, 1, 1))
             or (string-length($telecomToUse) > 1 and translate(substring($telecomToUse, 1, 1), '()-', '') = ''
                 and not(translate(substring($telecomToUse, 2), '0123456789', '') = $telecomToUse))">
			<xsl:value-of select="normalize-space(text())"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="EncounterNumber" mode="fn-encounterNumber-converted">
		<xsl:variable name="encounterNumberLower" select="translate(text(), $upperCase, $lowerCase)"/>
		<xsl:variable name="encounterNumberClean" select="translate(text(), ';:% &#34;', '_____')"/>
		<xsl:choose>
			<xsl:when test="starts-with($encounterNumberLower,'urn:uuid:')">
				<xsl:value-of select="substring($encounterNumberClean,10)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$encounterNumberClean"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Container" mode="fn-title-forDocument">
		<xsl:param name="title1"/>
		
		<xsl:variable name="title2">
			<!--<xsl:value-of select="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='IncompleteResult']/text()"/>-->
		  <xsl:value-of select="key('AdditionalInfoByKey','IncompleteResult')/text()"/>
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
	
	<xsl:template match="*" mode="fn-narrativeDateFromODBC">
		<!-- narrativeDateFromODBC takes a date value that is expected to be in ODBC format YYYY-MM-DDTHH:MM:SS with optional +/-hh:mm, and removes the
		     letter "T" and replaces "Z" with "-00:00" to provide for a better format for display in CDA section narratives. -->
		<xsl:choose>
			<xsl:when test="contains(text(),'Z')">
				<xsl:value-of select="concat(translate(text(),'TZ',' '), '-00:00')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate(text(),'T',' ')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-encompassingEncounterNumber">
	<!--
		encompassingEncounterNumber returns the SDA EncounterNumber
		of the encounter to export to CDA encompassingEncounter.
		This value will be used as the CDA encounter id/@extension.
	-->
		<!--<xsl:value-of select="/Container/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey = 'EncompassingEncounterNumber']/text()"/>-->
	  <xsl:value-of select="key('AdditionalInfoByKey','EncompassingEncounterNumber')/text()"/>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-encompassingEncounterOrganization">
	  <!--
		encompassingEncounterOrganization returns the SDA Encounter
		HealthCareFacility Organization Code of the encounter to
		export to CDA encompassingEncounter.  This value will be
		used as the CDA encounter id/@root.
	-->
	  <xsl:value-of select="key('AdditionalInfoByKey','EncompassingEncounterOrganization')/text()"/>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-encompassingEncounterToEncounters">
	  <!--
		encompassingEncounterToEncounters returns a flag to indicate
		whether to export the desired encompassingEncounter also
		to the Encounters section.  Return 1 = export to Encounters
		section, return anything else = do not export to Encounters
		section.
	-->
	  <xsl:value-of select="key('AdditionalInfoByKey','EncompassingEncounterToEncounters')/text()"/>
	</xsl:template>
	
	<xsl:template match="Category" mode="fn-problem-ProblemType">
		<!--
			Make the Problem Type export to be a conformant SNOMED CT code
			export where it's clear that that's what it's supposed to be.
		-->
		<!--
			The required value set for Problem Type Code is 2.16.840.1.113883.3.88.12.3221.7.2
			All codes are from SNOMED CT:
			404684003  Finding
			409586006  Complaint
			282291009  Diagnosis
			64572001   Condition
			248536006  Finding of functional performance and activity
			418799008  Symptom
			55607006   Problem
			373930000  Cognitive function finding
		-->
		<!--
			StructuredMapping: problem-ProblemType
			
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
		-->
		<xsl:variable name="problemTypeCodes"
			select="'|404684003|409586006|282291009|64572001|248536006|418799008|55607006|373930000|'"/>
		<xsl:variable name="descUpper" select="translate(Description/text(), $lowerCase, $upperCase)"/>
		<xsl:variable name="codeValue">
			<xsl:choose>
				<xsl:when test="contains($problemTypeCodes, concat('|', Code/text(), '|'))">
					<xsl:value-of select="Code/text()"/>
				</xsl:when>
				<xsl:when test="$descUpper = 'SYMPTOM'">418799008</xsl:when>
				<xsl:when test="$descUpper = 'PROBLEM'">55607006</xsl:when>
				<xsl:when test="$descUpper = 'FINDING'">404684003</xsl:when>
				<xsl:when test="$descUpper = 'COMPLAINT'">409586006</xsl:when>
				<xsl:when test="$descUpper = 'DIAGNOSIS'">282291009</xsl:when>
				<xsl:when test="$descUpper = 'CONDITION'">64572001</xsl:when>
				<xsl:when test="$descUpper = 'FINDING OF FUNCTIONAL PERFORMANCE AND ACTIVITY'">248536006</xsl:when>
				<xsl:when test="contains($descUpper, 'FINDING OF FUNCTIONAL')">248536006</xsl:when>
				<xsl:when test="$descUpper = 'COGNITIVE FUNCTION FINDING'">373930000</xsl:when>
				<xsl:when test="boolean(Code/text())">
					<xsl:value-of select="Code/text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($codeValue)">
				<xsl:variable name="descValue">
					<xsl:choose>
						<xsl:when test="string-length(Description/text())">
							<xsl:value-of select="Description/text()"/>
						</xsl:when>
						<xsl:when test="$codeValue = '418799008'">Symptom</xsl:when>
						<xsl:when test="$codeValue = '55607006'">Problem</xsl:when>
						<xsl:when test="$codeValue = '404684003'">Finding</xsl:when>
						<xsl:when test="$codeValue = '409586006'">Complaint</xsl:when>
						<xsl:when test="$codeValue = '282291009'">Diagnosis</xsl:when>
						<xsl:when test="$codeValue = '64572001'">Condition</xsl:when>
						<xsl:when test="$codeValue = '248536006'">Finding of functional performance and activity</xsl:when>
						<xsl:when test="$codeValue = '373930000'">Cognitive function finding</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$codeValue"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="loincCodeValue">
					<xsl:choose>
						<xsl:when test="$codeValue = '404684003'">75321-0</xsl:when>
						<xsl:when test="$codeValue = '409586006'">75322-8</xsl:when>
						<xsl:when test="$codeValue = '282291009'">29308-4</xsl:when>
						<xsl:when test="$codeValue = '64572001'">75323-6</xsl:when>
						<xsl:when test="$codeValue = '248536006'">75324-4</xsl:when>
						<xsl:when test="$codeValue = '418799008'">75325-1</xsl:when>
						<xsl:when test="$codeValue = '55607006'">75326-9</xsl:when>
						<xsl:when test="$codeValue = '373930000'">75275-8</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="codingStandard">
					<xsl:choose>
						<xsl:when test="string-length(SDACodingStandard/text())">
							<SDACodingStandard>
								<xsl:value-of select="SDACodingStandard/text()"/>
							</SDACodingStandard>
						</xsl:when>
						<xsl:when test="contains($problemTypeCodes, concat('|', $codeValue, '|'))">
							<SDACodingStandard>
								<xsl:value-of select="$snomedName"/>
							</SDACodingStandard>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="sdaCodingStandardOID">
					<xsl:apply-templates select="." mode="fn-oid-for-code">
						<xsl:with-param name="Code" select="$codingStandard"/>
					</xsl:apply-templates>
				</xsl:variable>

				<code>
					<xsl:attribute name="codeSystem">
						<xsl:value-of select="$sdaCodingStandardOID"/>
					</xsl:attribute>
					<xsl:attribute name="codeSystemName">
						<xsl:value-of select="$codingStandard"/>
					</xsl:attribute>
					<xsl:attribute name="code">
						<xsl:value-of select="$codeValue"/>
					</xsl:attribute>
					<xsl:attribute name="displayName">
						<xsl:value-of select="$descValue"/>
					</xsl:attribute>
					<originalText>
						<xsl:value-of select="$descValue"/>
					</originalText>
					<xsl:if test="string-length($loincCodeValue)">
						<translation>
							<xsl:attribute name="code">
								<xsl:value-of select="$loincCodeValue"/>
							</xsl:attribute>
							<xsl:attribute name="displayName">
								<xsl:choose>
									<xsl:when test="$codeValue = '418799008'">Symptom</xsl:when>
									<xsl:when test="$codeValue = '55607006'">Problem</xsl:when>
									<xsl:when test="$codeValue = '404684003'">Clinical finding</xsl:when>
									<xsl:when test="$codeValue = '409586006'">Complaint</xsl:when>
									<xsl:when test="$codeValue = '282291009'">Diagnosis</xsl:when>
									<xsl:when test="$codeValue = '64572001'">Condition</xsl:when>
									<xsl:when test="$codeValue = '248536006'">Functional performance</xsl:when>
									<xsl:when test="$codeValue = '373930000'">Cognitive Function</xsl:when>
									<xsl:when test="string-length(Description/text())">
										<xsl:value-of select="Description/text()"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$codeValue"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:attribute name="codeSystem">
								<xsl:value-of select="$loincOID"/>
							</xsl:attribute>
							<xsl:attribute name="codeSystemName">
								<xsl:value-of select="$loincName"/>
							</xsl:attribute>
						</translation>
					</xsl:if>
				</code>
			</xsl:when>
			<xsl:otherwise><!-- $codeValue came up empty -->
				<code nullFlavor="UNK"/>
		    </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-descriptionOrCode">
	<!--
		descriptionOrCode receives a node-spec for an SDA CodeTableDetail
		item, and returns the Description text if present, otherwise it
		returns the Code text.
	-->
		<xsl:choose>
			<xsl:when test="string-length(Description)">
				<xsl:value-of select="Description"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="Code"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-codeOrDescription">
	<!--
		codeOrDescription receives a node-spec for an SDA CodeTableDetail
		item, and returns the Code text if present, otherwise it returns
		the Description text.
	-->
		<xsl:choose>
			<xsl:when test="string-length(Code)">
				<xsl:value-of select="Code"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="Description"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
	<xsl:template match="*" mode="fn-originalTextOrDescriptionOrCode">
	<!--
		originalTextOrDescriptionOrCode receives a node-spec for an
		SDA CodeTableDetail item and returns the OriginalText text
		if present, otherwise it returns the Description text if
		present, otherwise it returns the Code text.
	-->
		<xsl:choose>
			<xsl:when test="string-length(OriginalText)">
				<xsl:value-of select="OriginalText"/>
			</xsl:when>
			<xsl:when test="string-length(Description)">
				<xsl:value-of select="Description"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="Code"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Address" mode="fn-addressSingleLine">
		<!-- Take the data from hl7:addr and format it into a single line of text. -->
		<xsl:variable name="city">
			<xsl:apply-templates select="City" mode="fn-descriptionOrCode"/>
		</xsl:variable>
		<xsl:variable name="state">
			<xsl:apply-templates select="State" mode="fn-codeOrDescription"/>
		</xsl:variable>
		<xsl:variable name="zip">
			<xsl:apply-templates select="Zip" mode="fn-codeOrDescription"/>
		</xsl:variable>
		<xsl:value-of select="concat(Street/text(), ', ', $city, ', ', $state, ' ', $zip)"/>
	</xsl:template>
	
	<!-- The next group of templates implements the unpacking scheme for
	     AdditionalDocumentInformation data. -->
  
  <xsl:template match="Element" mode="fn-I-AddlDocInfo-fromElement">
    <!--
		This template exports the sub-nodes of the AdditionalDocumentInfo XML data.
		In general, it handles most of the transform of that XML data to valid C32 CDA.
	  This template only does generic handling of the element. -->
        <xsl:element name="{Name/text()}">
          <xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
          <xsl:apply-templates select="Elements/Element" mode="fn-I-AddlDocInfo-fromElementChoice"/>
          <xsl:if test="string-length(translate(Value/text(),'&#9;&#10;&#13;&#32;',''))">
            <xsl:value-of select="Value/text()"/>
          </xsl:if>
        </xsl:element>
  </xsl:template>
  
	<xsl:template match="Element" mode="fn-I-AddlDocInfo-fromElementChoice">
	  <!--
		This template exports the sub-nodes of the AdditionalDocumentInfo XML data.
		This template in general handles most of the transform of that XML data to
		valid C32 CDA.  Specialized handling of certain elements is indicated by the
		xsl:when conditions in the processing of the current Element.
	 -->
	  <xsl:choose>
			<!-- xsl:when conditions are special cases where the data needs to be massaged for C32 purposes. -->
			<xsl:when test="Name/text()='effectiveTime'">
				<xsl:apply-templates select="." mode="fn-T-effectiveTime-IVL_TS-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="Name/text()='telecom'">
				<xsl:apply-templates select="." mode="fn-W-telecom-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="Name/text()='assignedEntity'">
				<xsl:apply-templates select="." mode="fn-W-assignedEntity-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="Name/text()='associatedEntity'">
				<xsl:apply-templates select="." mode="fn-W-associatedEntity-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="Name/text()='assignedAuthor'">
				<xsl:apply-templates select="." mode="fn-W-assignedAuthor-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="Name/text()='serviceEvent'">
				<xsl:apply-templates select="." mode="fn-W-serviceEvent-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="Name/text()='encompassingEncounter'">
				<xsl:apply-templates select="." mode="fn-W-encompassingEncounter-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="contains('|guardianOrganization|providerOrganization|manufacturerOrganization|wholeOrganization|representedOrganization|representedCustodianOrganization|receivedOrganization|scopingOrganization|serviceProviderOrganization|',concat('|',Name/text(),'|'))">
				<xsl:apply-templates select="." mode="fn-W-cName-organization-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="Name/text()='relatedEntity'">
				<xsl:apply-templates select="." mode="fn-W-relatedEntity-AddlDocInfo"/>
			</xsl:when>
			<xsl:when test="Name/text()='patientRole'">
				<xsl:apply-templates select="." mode="fn-W-patientRole-AddlDocInfo"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Otherwise, generic handling of the element. -->
				<xsl:element name="{Name/text()}">
					<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
					<xsl:apply-templates select="Elements/Element" mode="fn-I-AddlDocInfo-fromElementChoice"/>
					<xsl:if test="string-length(translate(Value/text(),'&#9;&#10;&#13;&#32;',''))">
						<xsl:value-of select="Value/text()"/>
					</xsl:if>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Attribute" mode="fn-A-fromNVPair">
		<xsl:attribute name="{Name/text()}"><xsl:value-of select="Value/text()"/></xsl:attribute>
	</xsl:template>
	
  <xsl:template match="Attribute" mode="fn-A-fromNVPair-noSpace">
    <!-- For telecom, remove spaces from the value because the regex used by the C32 validator does not allow it. -->
    <xsl:attribute name="{Name/text()}"><xsl:value-of select="translate(Value/text(),' ','')"/></xsl:attribute>
  </xsl:template>
  
  <xsl:template match="Elements" mode="fn-I-addr-AddlDocInfo">
	  <!-- Export nullFlavor for addr if it is completely missing from the current Elements collection. -->
	  <xsl:choose>
			<xsl:when test="Element[Name/text()='addr']">
				<xsl:apply-templates select="Element[Name/text()='addr']" mode="fn-I-AddlDocInfo-fromElement"/>
			</xsl:when>
			<xsl:otherwise><addr nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-assignedAuthor-AddlDocInfo">
	  <!-- assignedAuthor needs to have addr and telecom filled in with nullFlavor if missing from the current Elements collection.
	       It also needs to have representedOrganization filled in with nullFlavor if both assignedPerson 
	       and representedOrganization are missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements" mode="fn-I-addr-AddlDocInfo"/>
			<xsl:apply-templates select="Elements" mode="fn-I-telecom-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedPerson']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedAuthoringDevice']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:choose>
				<xsl:when test="Elements/Element[Name/text()='representedOrganization']">
					<xsl:apply-templates select="Elements/Element[Name/text()='representedOrganization']" mode="fn-W-cName-organization-AddlDocInfo"/>
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
	
	<xsl:template match="Element" mode="fn-W-assignedEntity-AddlDocInfo">
	  <!-- assignedEntity needs to have addr and telecom filled in with nullFlavor if missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements" mode="fn-I-id-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements" mode="fn-I-addr-AddlDocInfo"/>
			<xsl:apply-templates select="Elements" mode="fn-I-telecom-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedPerson']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='representedOrganization']" mode="fn-W-cName-organization-AddlDocInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-associatedEntity-AddlDocInfo">
	  <!-- associatedEntity needs to have addr and telecom filled in with nullFlavor if missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements" mode="fn-I-id-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements" mode="fn-I-addr-AddlDocInfo"/>
			<xsl:apply-templates select="Elements" mode="fn-I-telecom-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='associatedPerson']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='scopingOrganization']" mode="fn-W-cName-organization-AddlDocInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-cName-authenticator-AddlDocInfo">
	  <!-- Input is authenticator or legalAuthenticator. -->
	  <!-- These need to have time filled in with nullFlavor if missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements" mode="fn-I-time-TS-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='signatureCode']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedEntity']" mode="fn-W-assignedEntity-AddlDocInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-author-AddlDocInfo">
	  <!-- author needs to have time filled in with nullFlavor if missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='functionCode']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements" mode="fn-I-time-TS-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedAuthor']" mode="fn-W-assignedAuthor-AddlDocInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-dataEnterer-AddlDocInfo">
	  <!-- dataEnterer needs to have time filled in with nullFlavor if missing from HeaderInfo item. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='functionCode']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements" mode="fn-I-time-TS-AddlDocInfo"/>
	    <xsl:apply-templates select="Elements/Element[Name/text()='assignedEntity']" mode="fn-W-assignedEntity-AddlDocInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-encompassingEncounter-AddlDocInfo">
	  <!-- encompassingEncounter needs to have effectiveTime filled in with nullFlavor if missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:choose>
				<xsl:when test="Elements/Element[Name/text()='effectiveTime']">
					<xsl:apply-templates select="Elements/Element[Name/text()='effectiveTime']" mode="fn-T-effectiveTime-IVL_TS-AddlDocInfo"/>
				</xsl:when>
				<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="Elements/Element[Name/text()='dischargeDispositionCode']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='responsibleParty']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='encounterParticipant']" mode="fn-W-encounterParticipant-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='location']" mode="fn-I-AddlDocInfo-fromElement"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-encounterParticipant-AddlDocInfo">
	  <!-- encounterParticipant needs to have time filled in with nullFlavor if missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements" mode="fn-I-time-TS-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='assignedEntity']" mode="fn-W-assignedEntity-AddlDocInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Elements" mode="fn-I-id-AddlDocInfo">
	  <!-- Export nullFlavor for id if it is completely missing from the current Elements collection. -->
	  <xsl:choose>
			<xsl:when test="Element[Name/text()='id']">
				<xsl:apply-templates select="Element[Name/text()='id']" mode="fn-I-AddlDocInfo-fromElement"/>
			</xsl:when>
			<xsl:otherwise><id nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
  <xsl:template match="Element" mode="fn-W-informant-AddlDocInfo">
    <!-- informant needs its assignedEntity id, addr and telecom filled in with nullFlavor if they are missing. -->
    <xsl:element name="{Name/text()}">
      <xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
      <xsl:apply-templates select="Elements/Element[Name/text()='assignedEntity']" mode="fn-W-assignedEntity-AddlDocInfo"/>
      <xsl:apply-templates select="Elements/Element[Name/text()='relatedEntity']" mode="fn-W-relatedEntity-AddlDocInfo"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="Element" mode="fn-T-effectiveTime-IVL_TS-AddlDocInfo">
	  <!-- For time and effectiveTime that are typed as IVL_TS, make sure that any values include HHMMSS , because the C32 validator requires it. -->
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
				<!-- If the input is a TS value then export that value to low and set high to nullFlavor. -->
				<xsl:when test="Attributes/Attribute[Name/text()='value'] and not(Elements/Element)">
					<low>
						<xsl:attribute name="value">
							<xsl:apply-templates select="Attributes/Attribute[Name/text()='value']" mode="fn-S-TimeValue"/>
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
									<xsl:apply-templates select="Elements/Element[Name/text()='low']/Attributes/Attribute[Name/text()='value']" mode="fn-S-TimeValue"/>
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
									<xsl:apply-templates select="Elements/Element[Name/text()='high']/Attributes/Attribute[Name/text()='value']" mode="fn-S-TimeValue"/>
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
	
	<xsl:template match="Element" mode="fn-W-cName-organization-AddlDocInfo">
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
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='name']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements" mode="fn-I-telecom-AddlDocInfo"/>
			<xsl:apply-templates select="Elements" mode="fn-I-addr-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='standardIndustryClassCode']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='asOrganizationPartOf']" mode="fn-I-AddlDocInfo-fromElement"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-patientRole-AddlDocInfo">
	  <!-- patientRole needs to have addr and telecome filled in with nullFlavor if missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements" mode="fn-I-addr-AddlDocInfo"/>
			<xsl:apply-templates select="Elements" mode="fn-I-telecom-AddlDocInfo"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='patient']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='providerOrganization']" mode="fn-W-cName-organization-AddlDocInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-relatedEntity-AddlDocInfo">
	  <!-- relatedEntity needs to have addr, telecom, effectiveTime and time filled in with nullFlavor if missing from HeaderInfo item. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements" mode="fn-I-addr-AddlDocInfo"/>
			<xsl:apply-templates select="Elements" mode="fn-I-telecom-AddlDocInfo"/>
			<xsl:choose>
				<xsl:when test="Elements/Element[Name/text()='effectiveTime']">
					<xsl:apply-templates select="Elements/Element[Name/text()='effectiveTime']" mode="fn-T-effectiveTime-IVL_TS-AddlDocInfo"/>
				</xsl:when>
				<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="Elements/Element[Name/text()='relatedPerson']" mode="fn-I-AddlDocInfo-fromElement"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-serviceEvent-AddlDocInfo">
	  <!-- serviceEvent needs to have effectiveTime low and high filled in with nullFlavor if missing from the current Elements collection. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='id']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:apply-templates select="Elements/Element[Name/text()='code']" mode="fn-I-AddlDocInfo-fromElement"/>
			<xsl:choose>
				<xsl:when test="Elements/Element[Name/text()='effectiveTime']">
					<xsl:apply-templates select="Elements/Element[Name/text()='effectiveTime']" mode="fn-T-effectiveTime-IVL_TS-AddlDocInfo"/>
				</xsl:when>
				<xsl:otherwise>
					<effectiveTime>
						<low nullFlavor="UNK"/>
						<high nullFlavor="UNK"/>
					</effectiveTime>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="Elements/Element[Name/text()='performer']" mode="fn-I-AddlDocInfo-fromElement"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Elements" mode="fn-I-telecom-AddlDocInfo">
	  <!-- Export nullFlavor for telecom if it is completely missing from the current Elements collection. -->
	  <xsl:choose>
			<xsl:when test="Element[Name/text()='telecom']">
				<xsl:apply-templates select="Element[Name/text()='telecom']" mode="fn-W-telecom-AddlDocInfo"/>
			</xsl:when>
			<xsl:otherwise><telecom nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-W-telecom-AddlDocInfo">
	  <!-- For telecom, remove spaces from the value because the regex used by the C32 validator does not allow it. -->
	  <xsl:element name="{Name/text()}">
			<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair-noSpace"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Elements" mode="fn-I-time-TS-AddlDocInfo">
	  <!-- Export nullFlavor for TS time if it is completely missing from the current Elements collection. -->
	  <xsl:choose>
			<xsl:when test="Element[Name/text()='time']">
				<xsl:apply-templates select="Element[Name/text()='time']" mode="fn-E-cName-timeTS-AddlDocInfo"/>
			</xsl:when>
			<xsl:otherwise><time nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Element" mode="fn-E-cName-timeTS-AddlDocInfo">
	  <!-- For time and effectiveTime that are typed as TS, make sure any value include HHMMSS , because the C32 validator requires it. -->
	  <xsl:element name="{Name/text()}">
			<xsl:choose>
				<!-- If nullFlavor then export the specified nullFlavor plus any other attributes. -->
				<xsl:when test="Attributes/Attribute[Name/text()='nullFlavor']">
					<xsl:apply-templates select="Attributes/Attribute" mode="fn-A-fromNVPair"/>
				</xsl:when>
				<!-- If effectiveTime is just a single value then export that value. -->
				<xsl:when test="Attributes/Attribute[Name/text()='value']">
					<xsl:attribute name="value">
						<xsl:apply-templates select="Attributes/Attribute[Name/text()='value']" mode="fn-S-TimeValue"/>
					</xsl:attribute>
				</xsl:when>
				<!-- If we have an IVL_TS feeding this TS then take the first found of low and high and use that for value. -->
				<xsl:when test="Elements/Element[Name/text()='low'] or Elements/Element[Name/text()='high']">
					<xsl:choose>
						<xsl:when test="Elements/Element[Name/text()='low'] and not(string-length(Elements/Element[Name/text()='low']/Attributes/Attribute[Name/text()='nullFlavor']/Value/text()))">
							<xsl:attribute name="value">
								<xsl:apply-templates select="Elements/Element[Name/text()='low']/Attributes/Attribute[Name/text()='value']" mode="fn-S-TimeValue"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:when test="Elements/Element[Name/text()='high'] and not(string-length(Elements/Element[Name/text()='high']/Attributes/Attribute[Name/text()='nullFlavor']/Value/text()))">
							<xsl:attribute name="value">
								<xsl:apply-templates select="Elements/Element[Name/text()='high']/Attributes/Attribute[Name/text()='value']" mode="fn-S-TimeValue"/>
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
  
  <xsl:template match="Attribute" mode="fn-S-TimeValue">
    <!-- For a time or effectiveTime value, make sure that it includes HHMMSS, because the C32 validator requires it. -->
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
  
  <xsl:template match="Container" mode="fn-templateId-USRealmHeader">
    <!-- Template Id with extension for US Realm -->			
    <templateId root="{$ccda-USRealmHeader}"/>
    <templateId root="{$ccda-USRealmHeader}" extension="2015-08-01"/>	
  </xsl:template>	
  
  <!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="fn-text-to-UID">
		<xsl:param name="text"/>
		<xsl:value-of select="translate($text, ' ', '-')"/>
	</xsl:template>
	
	<xsl:template name="fn-unit-to-ucum">
		<!--- see https://loinc.org/usage/units -->		
		<xsl:param name="unit"/>
		<xsl:choose>
			<xsl:when test="$unit = 'lb'">[lb_av]</xsl:when>
			<xsl:when test="$unit = 'lbs'">[lb_av]</xsl:when>
			<xsl:when test="$unit = 'in'">[in_i]</xsl:when>
			<xsl:when test="$unit = 'GM/DL'">g/dL</xsl:when>
			<xsl:when test="$unit = 'K/MM3'">10*3/uL</xsl:when>
			<xsl:when test="$unit = 'M/MM3'">10*6/uL</xsl:when>
			<xsl:when test="$unit = '10^3/ul'">10*3/uL</xsl:when>
			<xsl:when test="$unit = '10+3/ul'">10*3/uL</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$unit"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>