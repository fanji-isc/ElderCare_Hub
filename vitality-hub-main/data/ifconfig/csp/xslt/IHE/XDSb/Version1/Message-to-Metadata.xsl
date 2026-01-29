<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="isc exsl set" version="1.0" xmlns:exsl="http://exslt.org/common" xmlns:isc="http://extension-functions.intersystems.com" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:set="http://exslt.org/sets" xmlns:xdsb="urn:ihe:iti:xds-b:2007" xmlns:xop="http://www.w3.org/2004/08/xop/include" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
	<xsl:include href="Variables.xsl"/>
	<xsl:param name="includeSlots" select="1"/>
	<xsl:template match="/">
		<Metadata>
			<xsl:choose>
				<xsl:when test="XMLMessage/ContentStream">
					<xsl:apply-templates select="XMLMessage/ContentStream/*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="*"/>
					<!-- more typical pass the contentstream into the transform -->
				</xsl:otherwise>
			</xsl:choose>
		</Metadata>
	</xsl:template>
	<xsl:template match="query:AdhocQueryResponse">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	<xsl:template match="xdsb:DocumentRequest">
		<Document id="{@id}" lid="{@lid}">
			<xsl:if test="xdsb:HomeCommunityId">
				<xsl:attribute name="home">
					<xsl:value-of select="xdsb:HomeCommunityId/text()"/>
				</xsl:attribute>
			</xsl:if>
			<UniqueId>
				<xsl:value-of select="xdsb:DocumentUniqueId/text()"/>
			</UniqueId>
			<RepositoryUniqueId>
				<xsl:value-of select="xdsb:RepositoryUniqueId/text()"/>
			</RepositoryUniqueId>
		</Document>
	</xsl:template>
	<xsl:template match="rim:RegistryObjectList">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	<xsl:template match="rs:RegistryErrorList">
		<Errors>
			<xsl:apply-templates select="rs:RegistryError"/>
		</Errors>
	</xsl:template>
	<xsl:template match="rs:RegistryError">
		<Error>
			<Code>
				<xsl:value-of select="@errorCode"/>
			</Code>
			<Severity>
				<xsl:value-of select="substring-after(@severity,'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:')"/>
			</Severity>
			<Description>
				<xsl:value-of select="@codeContext"/>
			</Description>
			<Location>
				<xsl:value-of select="@location"/>
			</Location>
		</Error>
	</xsl:template>
	<xsl:template match="rim:ObjectRef">
		<ObjectRef id="{@id}">
			<xsl:if test="@home">
				<xsl:attribute name="home">
					<xsl:value-of select="@home"/>
				</xsl:attribute>
			</xsl:if>
		</ObjectRef>
	</xsl:template>
	<xsl:template match="rim:Association">
		<Association child="{@targetObject}" parent="{@sourceObject}" type="{@associationType}" id="{@id}" status="{@status}" />
	</xsl:template>
	<xsl:template match="rim:ExtrinsicObject">
		<xsl:variable name="docUUID" select="@id"/>
		<Document id="{$docUUID}" lid="{@lid}">
			<xsl:if test="@home">
				<xsl:attribute name="home">
					<xsl:value-of select="@home"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="@objectType = $xdsbOnDemandDocument">OnDemand</xsl:when>
					<xsl:otherwise>Stable</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<URI>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='URI']"/>
			</URI>
			<XOP>
				<xsl:value-of select="//xdsb:ProvideAndRegisterDocumentSetRequest/xdsb:Document[@id=$docUUID]/xop:Include/@href"/>
			</XOP>
			<MimeType>
				<xsl:value-of select="@mimeType"/>
			</MimeType>
			<AvailabilityStatus>
				<xsl:apply-templates mode="getStatus" select="@status"/>
			</AvailabilityStatus>
			<Size>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='size']"/>
			</Size>
			<Hash>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='hash']"/>
			</Hash>
			<RepositoryUniqueId>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='repositoryUniqueId']"/>
			</RepositoryUniqueId>
			<SourcePatientId>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='sourcePatientId']"/>
			</SourcePatientId>
			<SourcePatientInfo>
				<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='sourcePatientInfo']"/>
			</SourcePatientInfo>
			<LanguageCode>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='languageCode']"/>
			</LanguageCode>
			<CreationTime>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='creationTime']"/>
			</CreationTime>
			<ServiceStartTime>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='serviceStartTime']"/>
			</ServiceStartTime>
			<ServiceStopTime>
				<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='serviceStopTime']"/>
			</ServiceStopTime>
			<Title>
				<xsl:value-of select="rim:Name/rim:LocalizedString/@value"/>
			</Title>
			<Comments>
				<xsl:value-of select="rim:Description/rim:LocalizedString/@value"/>
			</Comments>
			<xsl:for-each select="rim:Classification[@classificationScheme='urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d']">
				<Author>
					<AuthorPerson>
						<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='authorPerson']"/>
					</AuthorPerson>
					<AuthorInstitution>
						<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='authorInstitution']"/>
					</AuthorInstitution>
					<AuthorRole>
						<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='authorRole']"/>
					</AuthorRole>
					<AuthorSpecialty>
						<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='authorSpecialty']"/>
					</AuthorSpecialty>
					<!-- AuthorTelecommunication added for Direct XDR Support -->
					<AuthorTelecommunication>
						<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='authorTelecommunication']"/>
					</AuthorTelecommunication>
				</Author>
			</xsl:for-each>
			<Version>
			<xsl:value-of select="rim:VersionInfo/@versionName"/>
			</Version>
			<ClassCode>
				<xsl:apply-templates mode="getClassification" select="rim:Classification[@classificationScheme='urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a']"/>
			</ClassCode>
			<xsl:for-each select="rim:Classification[@classificationScheme='urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f']">
				<ConfidentialityCode>
					<xsl:apply-templates mode="getClassification" select="."/>
				</ConfidentialityCode>
			</xsl:for-each>
			<xsl:for-each select="rim:Classification[@classificationScheme='urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4']">
				<EventCodeList>
					<xsl:apply-templates mode="getClassification" select="."/>
				</EventCodeList>
			</xsl:for-each>
			<FormatCode>
				<xsl:apply-templates mode="getClassification" select="rim:Classification[@classificationScheme='urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d']"/>
			</FormatCode>
			<HealthcareFacilityTypeCode>
				<xsl:apply-templates mode="getClassification" select="rim:Classification[@classificationScheme='urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1']"/>
			</HealthcareFacilityTypeCode>
			<PracticeSettingCode>
				<xsl:apply-templates mode="getClassification" select="rim:Classification[@classificationScheme='urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead']"/>
			</PracticeSettingCode>
			<TypeCode>
				<xsl:apply-templates mode="getClassification" select="rim:Classification[@classificationScheme='urn:uuid:f0306f51-975f-434e-a61c-c59651d33983']"/>
			</TypeCode>
			<PatientId>
				<xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427']/@value"/>
			</PatientId>
			<UniqueId>
				<xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab']/@value"/>
			</UniqueId>
			<xsl:if test="$includeSlots='1'">
				<DocumentSlots>
					<xsl:for-each select="rim:Slot">
					<!-- Don't include parsed slots -->
					<xsl:choose>
					<xsl:when test="@name='size'"></xsl:when>
					<xsl:when test="@name='hash'"></xsl:when>
					<xsl:when test="@name='serviceStartTime'"></xsl:when>
					<xsl:when test="@name='serviceStopTime'"></xsl:when>
					<xsl:when test="@name='submissionTime'"></xsl:when>
					<xsl:when test="@name='repositoryUniqueId'"></xsl:when>
					<xsl:when test="@name='sourcePatientId'"></xsl:when>
					<xsl:when test="@name='creationTime'"></xsl:when>
					<xsl:when test="@name='languageCode'"></xsl:when>
					<xsl:when test="@name='sourcePatientInfo'"></xsl:when>
					<xsl:when test="@name='documentAvailability'"></xsl:when>
					<xsl:otherwise>
							<Slot name="{@name}">
								<ValueList>
									<xsl:for-each select="rim:ValueList/rim:Value">
										<SlotValue>
											<xsl:value-of select="text()"/>
										</SlotValue>
									</xsl:for-each>
								</ValueList>
							</Slot>
					</xsl:otherwise>
					</xsl:choose>

					</xsl:for-each>
				</DocumentSlots>
			</xsl:if>
		</Document>
	</xsl:template>
	<xsl:template match="rim:RegistryPackage">
		<xsl:variable name="thisID" select="@id"/>
		<xsl:if test="//rim:Classification[@classificationNode='urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd'][@classifiedObject=$thisID]">
			<Submission home="{@home}" id="{@id}">
				<xsl:apply-templates mode="registryPackage" select="."/>
				<xsl:apply-templates mode="registryPackageSubmission" select="."/>
			</Submission>
		</xsl:if>
		<xsl:if test="//rim:Classification[@classificationNode='urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2'][@classifiedObject=$thisID]">
			<Folder home="{@home}" id="{@id}" status="{@status}" lid="{@lid}">
				<xsl:apply-templates mode="registryPackage" select="."/>
				<xsl:apply-templates mode="registryPackageFolder" select="."/>
			</Folder>
		</xsl:if>
	</xsl:template>
	<xsl:template match="rim:RegistryPackage" mode="registryPackage">
		<xsl:for-each select="rim:Classification[@classificationScheme='urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d']">
			<Author>
				<AuthorPerson>
					<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='authorPerson']"/>
				</AuthorPerson>
				<AuthorInstitution>
					<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='authorInstitution']"/>
				</AuthorInstitution>
				<AuthorRole>
					<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='authorRole']"/>
				</AuthorRole>
				<AuthorSpecialty>
					<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='authorSpecialty']"/>
				</AuthorSpecialty>
				<!-- AuthorTelecommunication added for Direct XDR Support -->
				<AuthorTelecommunication>
					<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='authorTelecommunication']"/>
				</AuthorTelecommunication>
			</Author>
		</xsl:for-each>
		<Comments>
			<xsl:value-of select="rim:Description/rim:LocalizedString/@value"/>
		</Comments>
		
		<!-- Pull a collection of all submission set slots , added for direct support -->
		<SubmissionSlots>
			<!-- using // due to lack of clarity in XDR Direct documentation, should clean this up later, if needed-->
			<xsl:for-each select=".//rim:Slot">
				<Slot name="{@name}">
					<ValueList>
						<xsl:for-each select="rim:ValueList/rim:Value">
							<SlotValue>
								<xsl:value-of select="text()"/>
							</SlotValue>
						</xsl:for-each>
					</ValueList>
				</Slot>
			</xsl:for-each>
		</SubmissionSlots>
	</xsl:template>
	<xsl:template match="rim:RegistryPackage" mode="registryPackageSubmission">
		<AvailabilityStatus>
			<xsl:apply-templates mode="getStatus" select="@status"/>
		</AvailabilityStatus>
		<PatientId>
			<xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446']/@value"/>
		</PatientId>
		<ContentTypeCode>
			<xsl:apply-templates mode="getClassification" select="rim:Classification[@classificationScheme='urn:uuid:aa543740-bdda-424e-8c96-df4873be8500']"/>
		</ContentTypeCode>
		<IntendedRecipient>
			<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='intendedRecipient']"/>
		</IntendedRecipient>
		<SourceId>
			<xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832']/@value"/>
		</SourceId>
		<SubmissionTime>
			<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='submissionTime']"/>
		</SubmissionTime>
		<Title>
			<xsl:value-of select="rim:Name/rim:LocalizedString/@value"/>
		</Title>
		<UniqueId>
			<xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8']/@value"/>
		</UniqueId>
	</xsl:template>
	<xsl:template match="rim:RegistryPackage" mode="registryPackageFolder">
		<LastUpdateTime>
			<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='lastUpdateTime']"/>
		</LastUpdateTime>
		<PatientId>
			<xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:f64ffdf0-4b97-4e06-b79f-a52b38ec2f8a']/@value"/>
		</PatientId>
		<Title>
			<xsl:value-of select="rim:Name/rim:LocalizedString/@value"/>
		</Title>
		<UniqueId>
			<xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:75df8f67-9973-4fbe-a900-df66cefecc5a']/@value"/>
		</UniqueId>
		<Version><xsl:value-of select="rim:VersionInfo/@versionName"/></Version>
	</xsl:template>
	<xsl:template match="@objectType" mode="getObjectType">
		<xsl:choose>
			<xsl:when test=". = 'urn:uuid:34268e47-fdf5-41a6-ba33-82133c465248'">OnDemand</xsl:when>
			<xsl:otherwise>Stable</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="@status" mode="getStatus">
		<xsl:value-of select="substring-after(., 'urn:oasis:names:tc:ebxml-regrep:StatusType:')"/>
	</xsl:template>
	<xsl:template match="rim:Slot" mode="getSlotValue">
		<xsl:value-of select="rim:ValueList/rim:Value/text()"/>
	</xsl:template>
	<xsl:template match="rim:Slot" mode="getSlotValues">
		<xsl:for-each select="rim:ValueList/rim:Value">
			<Value>
				<xsl:value-of select="text()"/>
			</Value>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="rim:Classification" mode="getClassification">
		<Code>
			<xsl:value-of select="@nodeRepresentation"/>
		</Code>
		<Scheme>
			<xsl:apply-templates mode="getSlotValue" select="rim:Slot"/>
		</Scheme>
		<Description>
			<xsl:value-of select="rim:Name/rim:LocalizedString/@value"/>
		</Description>
	</xsl:template>
</xsl:stylesheet>
