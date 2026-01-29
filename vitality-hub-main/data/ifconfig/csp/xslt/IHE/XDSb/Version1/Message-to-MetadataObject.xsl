<?xml version="1.0" encoding="UTF-8"?>
<!-- *** This transform is not intended to be called or extended and may change at any time without notice *** -->
<xsl:stylesheet exclude-result-prefixes="isc exsl set wsnt wsa dsub lcm rim rs query xdsb xsi xop" version="1.0" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns:isc="http://extension-functions.intersystems.com" 
  xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
  xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" 
  xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
  xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
  xmlns:set="http://exslt.org/sets" 
  xmlns:xdsb="urn:ihe:iti:xds-b:2007" 
  xmlns:xop="http://www.w3.org/2004/08/xop/include" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2"
  xmlns:wsa="http://www.w3.org/2005/08/addressing"
  xmlns:dsub="urn:ihe:iti:dsub:2009"
  xmlns=""
  >
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:include href="Variables.xsl"/>
<xsl:param name="keepContentStream" select="'0'"/>
<xsl:variable name="sourceIdentifierId" select="//lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:RegistryPackage/rim:ExternalIdentifier[@identificationScheme='urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832']/@id"/>
<xsl:variable name="sourceIdentifierValue" select="//lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:RegistryPackage/rim:ExternalIdentifier[@identificationScheme='urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832']/@value"/>
<xsl:variable name="submissionTime" select="//lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:RegistryPackage/rim:Slot[@name='submissionTime']/rim:ValueList/rim:Value"/>

<xsl:template match="/">

<Metadata >
<xsl:apply-templates select="*"/>
<!-- if there isn't a StreamCollection call out to ensure we move the documents -->
<xsl:if test="not(XMLMessage/StreamCollection)">
<xsl:call-template name="StreamCollection"/>
</xsl:if>
<xsl:if test="keepContentStream='1'">
<xsl:apply-templates mode="CopyContentStream" select='XMLMessage/ContentStream'/>
</xsl:if>
<!-- Move direct data from AdditionalInfo into fields (from soap headers) -->
<xsl:apply-templates mode="MoveDirect" select='XMLMessage/AdditionalInfo'/>
</Metadata>
</xsl:template>

<xsl:template match="Name">
<Name><xsl:value-of select="text()"/></Name>
</xsl:template>

<xsl:template match="DocType">
</xsl:template>

<xsl:template match="query:AdhocQueryRequest">
</xsl:template>

<xsl:template match="AdditionalInfo">
<AdditionalInfo>
<xsl:copy-of select="*"/>
</AdditionalInfo>
</xsl:template>

<xsl:template match="SAMLData">
<SAMLData>
<xsl:copy-of select="*"/>
</SAMLData>
</xsl:template>

<!-- Move direct data from AdditionalInfo into fields (from soap headers) -->
<xsl:template match="*" mode="MoveDirect">
<xsl:if test="AdditionalInfoItem[@AdditionalInfoKey='Direct:METADATA-LEVEL']/text()!=''">
<DirectMetadataLevel><xsl:value-of select="AdditionalInfoItem[@AdditionalInfoKey='Direct:METADATA-LEVEL']/text()"/></DirectMetadataLevel>
</xsl:if>
<xsl:if test="AdditionalInfoItem[@AdditionalInfoKey='Direct:FROM']/text()!=''">
<DirectFrom><xsl:value-of select="AdditionalInfoItem[@AdditionalInfoKey='Direct:FROM']/text()"/></DirectFrom>
</xsl:if>

<xsl:if test="AdditionalInfoItem[@AdditionalInfoKey='Direct:TO']/text()!=''">
<xsl:variable name="DirectTo" select="AdditionalInfoItem[@AdditionalInfoKey='Direct:TO']/text()"/>

<DirectTo>
<xsl:call-template name="directSplit">
<xsl:with-param name="string" select="AdditionalInfoItem[@AdditionalInfoKey='Direct:TO']/text()"/>
</xsl:call-template>
</DirectTo>
</xsl:if>
</xsl:template>


<xsl:template name="directSplit">
<xsl:param name="string" select="''" />
<xsl:variable name="delim" select="';'"/>
<xsl:choose>
	<xsl:when test="not(contains($string, $delim))">
		<DirectToItem>
			<xsl:value-of select="$string"/>
		</DirectToItem>
	</xsl:when>
	<xsl:otherwise>
		<xsl:variable name="current" select="substring-before($string, $delim)"/>
		<xsl:variable name="remainder" select="substring-after($string, $delim)"/>
		<xsl:if test="string-length($current)">
			<DirectToItem>
				<xsl:value-of select="$current"/>
			</DirectToItem>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="not(contains($remainder, $delim))">
				<DirectToItem>
					<xsl:value-of select="$remainder"/>
				</DirectToItem>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="directSplit">
					<xsl:with-param name="string" select="$remainder"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="*" mode="CopyContentStream">
<xsl:copy-of select="."/>
</xsl:template>

<xsl:template name="StreamCollection" match="StreamCollection">
<StreamCollection>
<xsl:copy-of select="/XMLMessage/StreamCollection/MIMEAttachment"/>
<xsl:for-each select="//xdsb:ProvideAndRegisterDocumentSetRequest/xdsb:Document">
<xsl:if test="not(xop:Include/@href)"> 
<MIMEAttachment>
<ContentId><xsl:value-of select="@id"/></ContentId>
<ContentType>application/octet-stream</ContentType>
<ContentTransferEncoding>binary</ContentTransferEncoding>
<Body><xsl:value-of select="text()"/></Body>
</MIMEAttachment>
</xsl:if>
</xsl:for-each>
</StreamCollection>
</xsl:template>

<xsl:template match="wsnt:Notify">
<xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="wsnt:NotificationMessage">
<xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="wsnt:Message">
<xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="wsnt:SubscriptionReference">
<xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="wsnt:Topic">
<xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="wsnt:ProducerReference">
<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="wsa:Address">
<xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="wsa:ReferenceParameters">
<xsl:apply-templates select="*"/>
</xsl:template>
<xsl:template match="dsub:SubscriptionId">
<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="lcm:ObjectRefList">
<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="lcm:ObjectRef">
<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="lcm:SubmitObjectsRequest">
<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="query:AdhocQueryResponse">
<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="rs:RegistryResponse">
<Status><xsl:value-of select="@status"/></Status>
<xsl:apply-templates select="*"/>
</xsl:template>


<!-- Used for Retrieve Document Requests -->
<xsl:template match="xdsb:DocumentRequest">
<Document id="{@id}" lid="{@lid}">
<xsl:if test="xdsb:HomeCommunityId">
<xsl:attribute name="home">
<xsl:value-of select="xdsb:HomeCommunityId/text()"/>
</xsl:attribute>
</xsl:if>
<DocumentUniqueIdentifier>
<Value><xsl:value-of select="xdsb:DocumentUniqueId/text()"/></Value>
</DocumentUniqueIdentifier>
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
<Association type="{@associationType}" id="{@id}" lid="{@lid}" sourceObject="{@sourceObject}" targetObject="{@targetObject}">
<xsl:apply-templates select="rim:Classification" mode="genericClassification"/>
<xsl:apply-templates select="rim:Slot" mode="genericSlot"/>
</Association>
</xsl:template>


<!-- provide and register document -->
<xsl:template match="rim:ExtrinsicObject">
<xsl:variable name="docUUID" select="@id"/>
<Document id="{$docUUID}" lid="{@lid}" type="{@objectType}" home="{@home}" status="{@status}">
<SubmissionTime><xsl:value-of select="$submissionTime"/></SubmissionTime>
<SourceIdentifier id="{$sourceIdentifierId}">
<Value><xsl:value-of select="$sourceIdentifierValue"/></Value>
</SourceIdentifier>
<XOP>
<xsl:choose>
<xsl:when test="../../../xdsb:Document[@id=$docUUID]/xop:Include/@href">
<xsl:value-of select="../../../xdsb:Document[@id=$docUUID]/xop:Include/@href"/>
</xsl:when>
<xsl:otherwise>cid:<xsl:value-of select="@id"/></xsl:otherwise>
</xsl:choose>
</XOP>
<MimeType>
<xsl:value-of select="@mimeType"/>
</MimeType>
<xsl:apply-templates select="rim:Name" mode="getValueText"/>
<xsl:apply-templates select="rim:Description" mode="getValueText"/>
<Version>
<xsl:value-of select="rim:VersionInfo/@versionName"/>
</Version>

<xsl:apply-templates mode="documentClassifications" select="rim:Classification"/>

<xsl:apply-templates mode="documentSlots" select="rim:Slot"/>
<xsl:apply-templates mode="externalIdentifiers" select="rim:ExternalIdentifier"/>
<!--
<xsl:call-template name="ExternalIdentifiers"/>
<PatientIdentifier>
<xsl:apply-templates mode="getSerialIdentifier" select="rim:ExternalIdentifier[rim:Name/rim:LocalizedString/@value='XDSDocumentEntry.patientId']"/>
</PatientIdentifier>
<DocumentUniqueIdentifier>
<xsl:apply-templates mode="getSerialIdentifier" select="rim:ExternalIdentifier[rim:Name/rim:LocalizedString/@value='XDSDocumentEntry.uniqueId']"/>
</DocumentUniqueIdentifier>
<xsl:call-template name="DocumentSlots"/>
-->

</Document>

</xsl:template>


<!-- all registry package items -->
<xsl:template match="rim:RegistryPackage">
<xsl:variable name="thisID" select="@id"/>
<!-- submission set or folder -->
<xsl:variable name="nodeType">
<xsl:choose>
<!-- submission set or folder -->
<xsl:when test="rim:Classification/@classificationNode='urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd'">S.<xsl:value-of select="rim:Classification[@classificationNode='urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd']/@id"/></xsl:when>
<xsl:when test="rim:Classification/@classificationNode='urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2'">F.<xsl:value-of select="rim:Classification[@classificationNode='urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2']/@id"/></xsl:when>
<xsl:when test="../rim:Classification[@classificationNode='urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd'][@classifiedObject=$thisID]">S.<xsl:value-of select="../rim:Classification[@classificationNode='urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd'][@classifiedObject=$thisID]/@id"/></xsl:when>
<xsl:otherwise>Unknown</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<xsl:when test="substring-before($nodeType,'.')='S'">
<Submission id="{@id}">
<Node id="{substring-after($nodeType,'.')}"></Node>
<xsl:apply-templates mode="registryPackage" select="."/>
<xsl:apply-templates mode="registryPackageSubmission" select="."/>
</Submission>
</xsl:when>
<xsl:when test="substring-before($nodeType,'.')='F'">
<Folder home="{@home}" id="{@id}" lid="{@lid}">
<Node id="{substring-after($nodeType,'.')}"></Node>
<xsl:apply-templates mode="registryPackage" select="."/>
<xsl:apply-templates mode="registryPackageFolder" select="."/>
</Folder>
</xsl:when>
<xsl:otherwise>
<!-- only the last error will be reported -->
<Error>
<Code>UnknownRegistryPackageType</Code>
<Severity>Error</Severity>
<Description>id=<xsl:value-of select="@id"/> has no classification for the node type</Description>
<Location/>
</Error>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- common template called from all registry package items -->
<xsl:template match="rim:RegistryPackage" mode="registryPackage">
<!--
<xsl:for-each select="rim:Classification[@classificationScheme='urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d']">
<chooseauthor value="{.}"/>
<xsl:apply-templates mode="author" select="."/>
</xsl:for-each>
-->
<AvailabilityStatus>
<xsl:value-of select="@status"/>
</AvailabilityStatus>
<xsl:apply-templates mode="getValueText" select="rim:Name"/>
<xsl:apply-templates mode="getValueText" select="rim:Description"/>
<xsl:apply-templates mode="externalIdentifiers" select="rim:ExternalIdentifier"/>

</xsl:template>

<xsl:template match="rim:Classification" mode="author">
<Author id="{@id}">
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
</xsl:template>

<xsl:template match="rim:ExternalIdentifier" mode="externalIdentifiers">
<xsl:choose>
<!-- document DocumentUniqueIdentifier -->
<xsl:when test="@identificationScheme='urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab'">
<DocumentUniqueIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></DocumentUniqueIdentifier>
</xsl:when>
<!-- document PatientIdentifier -->
<xsl:when test="@identificationScheme='urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427'">
<PatientIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></PatientIdentifier>
</xsl:when>
<!-- SubmissionSet SourceIdentifier -->
<xsl:when test="@identificationScheme='urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832'">
<SourceIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></SourceIdentifier>
</xsl:when>
<!-- submission set patient id -->
<xsl:when test="@identificationScheme='urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446'">
<PatientIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></PatientIdentifier>
</xsl:when>
<!-- submission set unique id -->
<xsl:when test="@identificationScheme='urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8'">
<UniqueIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></UniqueIdentifier>
</xsl:when>
<!-- folder patient id -->
<xsl:when test="@identificationScheme='urn:uuid:f64ffdf0-4b97-4e06-b79f-a52b38ec2f8a'">
<PatientIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></PatientIdentifier>
</xsl:when>
<!-- folder unique id -->
<xsl:when test="@identificationScheme='urn:uuid:75df8f67-9973-4fbe-a900-df66cefecc5a'">
<UniqueIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></UniqueIdentifier>
</xsl:when>
<xsl:otherwise>
<ExternalIdentifier id="{@id}">
<!--<RegistryObject><xsl:value-of select="@registryObject"/></RegistryObject>-->
<IdentificationScheme><xsl:value-of select="@identificationScheme"/></IdentificationScheme>
<Value><xsl:value-of select="@value"/></Value>
<xsl:apply-templates mode="getValueText" select="rim:Name"/>
<xsl:apply-templates mode="getValueText" select="rim:Description"/>
<!--
<Name><xsl:apply-templates mode="localizedString" select="Name"/></Name>
<Description><xsl:apply-templates mode="localizedString" select="Description"/></Description>
-->
</ExternalIdentifier>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="rim:Slot" mode="documentSlots">
<xsl:choose>
<xsl:when test="@name='size'">
<Size>
<xsl:apply-templates mode="getSlotValue" select="."/>
</Size>
</xsl:when>
<xsl:when test="@name='hash'">
<Hash>
<xsl:apply-templates mode="getSlotValue" select="."/>
</Hash>
</xsl:when>
<xsl:when test="@name='URI'">
<URI>
<xsl:apply-templates mode="getSlotValue" select="."/>
</URI>
</xsl:when>
<xsl:when test="@name='serviceStartTime'">
<ServiceStartTime>
<xsl:apply-templates mode="getSlotValue" select="."/>
</ServiceStartTime>
</xsl:when>
<xsl:when test="@name='serviceStopTime'">
<ServiceStopTime>
<xsl:apply-templates mode="getSlotValue" select="."/>
</ServiceStopTime>
</xsl:when>
<xsl:when test="@name='repositoryUniqueId'">
<RepositoryUniqueId>
<xsl:apply-templates mode="getSlotValue" select="."/>
</RepositoryUniqueId>
</xsl:when>
<xsl:when test="@name='sourcePatientId'">
<SourcePatientId>
<xsl:apply-templates mode="getSlotValue" select="."/>
</SourcePatientId>
</xsl:when>
<xsl:when test="@name='creationTime'">
<CreationTime>
<xsl:apply-templates mode="getSlotValue" select="."/>
</CreationTime>
</xsl:when>
<xsl:when test="@name='languageCode'">
<LanguageCode>
<xsl:apply-templates mode="getSlotValue" select="."/>
</LanguageCode>
</xsl:when>
<xsl:when test="@name='sourcePatientInfo'">
<SourcePatientInfo>
<xsl:apply-templates mode="getSlotValues" select="."/>
</SourcePatientInfo>
</xsl:when>
<xsl:when test="@name='documentAvailability'">
<Availability>
<xsl:apply-templates mode="getSlotValue" select="."/>
</Availability>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="." mode="genericSlot"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="rim:Slot" mode="submissionSlots">
<xsl:choose>
<xsl:when test="@name='intendedRecipient'">
<IntendedRecipient>
<xsl:apply-templates mode="getSlotValues" select="."/>
</IntendedRecipient>
</xsl:when>
<xsl:when test="@name='submissionTime'">
<SubmissionTime>
<xsl:apply-templates mode="getSlotValue" select="."/>
</SubmissionTime>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="." mode="genericSlot"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Generic Slots -->
<xsl:template name="Slots" mode="genericSlots">
<xsl:for-each select="rim:Slot">
<xsl:apply-templates select="." mode="genericSlot"/>
</xsl:for-each>
</xsl:template>

<!-- copy Generic Slots but don't move one named codingScheme -->
<xsl:template match="rim:Slot" mode="genericSlotsNoCodingScheme">
<xsl:if test="@name !='codingScheme'">
<xsl:apply-templates select="." mode="genericSlot"/>
</xsl:if>
</xsl:template>

<xsl:template match="rim:Slot" mode="genericSlot">
<Slot name="{@name}">
<ValueList>
<xsl:for-each select="rim:ValueList/rim:Value">
<Value>
<xsl:value-of select="text()"/>
</Value>
</xsl:for-each>
</ValueList>
</Slot>
</xsl:template>


<xsl:template match="rim:Classification" mode="genericClassification">
<Classification id="{@id}">
<Code><xsl:value-of select="@nodeRepresentation"/></Code>
<CodingScheme><xsl:value-of select="rim:Slot[@name='codingScheme']/rim:ValueList/rim:Value/text()"/></CodingScheme>
<ClassificationScheme><xsl:value-of select="@classificationScheme"/></ClassificationScheme>
<xsl:apply-templates select="rim:Name" mode="getValueText"/>
<xsl:apply-templates select="rim:Description" mode="getValueText"/>
<xsl:apply-templates mode="genericSlotsNoCodingScheme" select="rim:Slot"/>
</Classification>
</xsl:template>

<xsl:template match="rim:RegistryPackage" mode="registryPackageSubmission">
<!--<xsl:call-template name="ExternalIdentifiers"/>-->
<xsl:apply-templates mode="registryPackageClassifications" select="rim:Classification"/>

<xsl:apply-templates mode="submissionSlots" select="rim:Slot"/>

<!-- moved ot external identifiers 
<SourceId>
<xsl:value-of select="rim:ExternalIdentifier[rim:Name/rim:LocalizedString/@value='XDSSubmissionSet.sourceId']/@value"/>
</SourceId>
<UniqueId>
<xsl:value-of select="rim:ExternalIdentifier[rim:Name/rim:LocalizedString/@value='XDSSubmissionSet.uniqueId']/@value"/>
</UniqueId>
<IntendedRecipient>
<xsl:apply-templates mode="getSlotValues" select="rim:Slot[@name='intendedRecipient']"/>
</IntendedRecipient>
<SubmissionTime>
<xsl:apply-templates mode="getSlotValue" select="rim:Slot[@name='submissionTime']"/>
</SubmissionTime>
-->
</xsl:template>

<xsl:template match="rim:RegistryPackage" mode="registryPackageFolder">
<xsl:apply-templates mode="registryPackageClassifications" select="rim:Classification"/>
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


<xsl:template match="rim:Classification" mode="registryPackageClassifications">

<xsl:choose>
<xsl:when test="@classificationScheme='urn:uuid:aa543740-bdda-424e-8c96-df4873be8500'">
<ContentTypeCode>
<xsl:apply-templates mode="getClassification" select="."/>
</ContentTypeCode>
</xsl:when>
<xsl:when test="@classificationScheme='urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d'">
<xsl:apply-templates mode="author" select="."/>
</xsl:when>
<xsl:otherwise>
<Classification id="{@id}">
<Code>
<xsl:value-of select="@nodeRepresentation"/>
</Code>
<Name><xsl:apply-templates mode="localizedString" select="Name"/></Name>
<Description><xsl:apply-templates mode="localizedString" select="Description"/></Description>
<xsl:apply-templates mode="genericSlot" select="rim:Slot"/>
</Classification>
</xsl:otherwise>
</xsl:choose>
</xsl:template>



<xsl:template match="rim:Classification" mode="documentClassifications">
<xsl:choose>
<xsl:when test="@classificationScheme='urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a'">
<ClassCode>
<xsl:apply-templates mode="getClassification" select="."/>
</ClassCode>
</xsl:when>
<xsl:when test="@classificationScheme='urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f'">
<ConfidentialityCode>
<xsl:apply-templates mode="getClassification" select="."/>
</ConfidentialityCode>
</xsl:when>
<xsl:when test="@classificationScheme='urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4'">
<EventCodeList>
<xsl:apply-templates mode="getClassification" select="."/>
</EventCodeList>
</xsl:when>
<xsl:when test="@classificationScheme='urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d'">
<FormatCode>
<xsl:apply-templates mode="getClassification" select="."/>
</FormatCode>
</xsl:when>
<xsl:when test="@classificationScheme='urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1'">
<HealthCareFacilityTypeCode>
<xsl:apply-templates mode="getClassification" select="."/>
</HealthCareFacilityTypeCode>
</xsl:when>
<xsl:when test="@classificationScheme='urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead'">
<PracticeSettingCode>
<xsl:apply-templates mode="getClassification" select="."/>
</PracticeSettingCode>
</xsl:when>
<xsl:when test="@classificationScheme='urn:uuid:f0306f51-975f-434e-a61c-c59651d33983'">
<TypeCode>
<xsl:apply-templates mode="getClassification" select="."/>
</TypeCode>
</xsl:when>
<xsl:when test="@classificationScheme='urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d'">
<xsl:apply-templates mode="author" select="."/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates mode="genericClassification" select="."/>
<!--
<Classification>
<Code>
<xsl:value-of select="@nodeRepresentation"/>
</Code>
<CodingScheme>
<xsl:apply-templates mode="getSlotValue" select="rim:Slot"/>
</CodingScheme>
<xsl:apply-templates mode="getValueText" select="rim:Name"/>
<xsl:apply-templates mode="getValueText" select="rim:Description"/>
<IID>
<xsl:value-of select="@id"/>
</IID>
</Classification>
-->
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="xdsb:Document">
</xsl:template>


<!-- 

<xsl:for-each select="rim:Classification[]">
<chooseauthor hehe='1' value="{.}"/>
<xsl:apply-templates mode="author" select="*"/>
</xsl:for-each>
-->

<!-- classification with a specific database slot -->
<xsl:template match="rim:Classification" mode="getClassification">
<xsl:attribute name="id">
<xsl:value-of select="@id"/>
</xsl:attribute>
<Code>
<xsl:value-of select="@nodeRepresentation"/>
</Code>
<CodingScheme>
<xsl:apply-templates mode="getSlotValue" select="rim:Slot"/>
</CodingScheme>

<xsl:apply-templates mode="getValueText" select="rim:Name"/>
<xsl:apply-templates mode="getValueText" select="rim:Description"/>
<!--
<Title><ValueText><xsl:apply-templates mode="localizedString" select="rim:Name"/></ValueText></Title>
<Comments><ValueText><xsl:apply-templates mode="localizedString" select="rim:Description"/></ValueText></Comments>
<DisplayName>
<xsl:value-of select="rim:Name/rim:LocalizedString/@value"/>
</DisplayName>
<IID>
<xsl:value-of select="@id"/>
</IID>
-->
</xsl:template>

<xsl:template name="LocalizedString" mode="localizedString" >
<Name>
<xsl:if test="rim:LocalizedString/@charset">
<xsl:attribute name="Charset">
<xsl:value-of select="rim:LocalizedString/@charset"/>
</xsl:attribute>
</xsl:if>
<xsl:if test="rim:LocalizedString/@xml:lang">
<xsl:attribute name="Lang">
<xsl:value-of select="rim:LocalizedString/@xml:lang"/>
</xsl:attribute>
</xsl:if>
<xsl:value-of select="rim:LocalizedString/@value"/>
</Name>
</xsl:template>


<xsl:template match="rim:ExternalIdentifier" mode="getSerialIdentifier">
<!--
<IID>
<xsl:value-of select="@id"/>
</IID>
-->
<Value>
<xsl:value-of select="@value"/>
</Value>
</xsl:template>

<xsl:template match="rim:Name" mode="getValueText">
<Name>
<xsl:apply-templates mode="getValueText" select="rim:LocalizedString"/>
</Name>
</xsl:template>

<xsl:template match="rim:Description" mode="getValueText">
<Description>
<xsl:apply-templates mode="getValueText" select="rim:LocalizedString"/>
</Description>
</xsl:template>

<xsl:template match="rim:LocalizedString" mode="getValueText">
<xsl:if test="@charset">
<xsl:attribute name="Charset">
<xsl:value-of select="@charset"/>
</xsl:attribute>
</xsl:if>
<xsl:if test="@xml:lang">
<xsl:attribute name="Lang">
<xsl:value-of select="@xml:lang"/>
</xsl:attribute>
</xsl:if>
<xsl:if test="@value"><xsl:value-of select="@value"/></xsl:if>

<!--
<xsl:if test="@charset"><Charset><xsl:value-of select="@charset"/></Charset></xsl:if>
<xsl:if test="@lang"><Lang><xsl:value-of select="@xml:lang"/></Lang></xsl:if>
-->
</xsl:template>

</xsl:stylesheet>
