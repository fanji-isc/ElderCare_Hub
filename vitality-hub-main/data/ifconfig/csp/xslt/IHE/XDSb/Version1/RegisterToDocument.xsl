<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:ihe="urn:ihe:iti:xds-b:2007" exclude-result-prefixes="isc rim rs lcm">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:param name="repositoryOID"/>
<xsl:template match="/lcm:SubmitObjectsRequest/rim:RegistryObjectList">
<Submission>
<xsl:call-template name="DocumentList"/>
<xsl:call-template name="RegistryPackageList"/>
<xsl:call-template name="Associations"/>
</Submission>
</xsl:template>

<xsl:template name="DocumentList">
<xsl:for-each select="rim:ExtrinsicObject">
<Document id="{@id}" lid="{@lid}">
<xsl:call-template name="Documents"/>
</Document>
</xsl:for-each>
</xsl:template>

<xsl:template name="RegistryPackageList">
<xsl:for-each select="rim:RegistryPackage">
<xsl:variable name="thisID" select="@id"/>
<RegistryPackage id="{@id}" lid="{@lid}">
<Type>
<xsl:choose>
<xsl:when test="//rim:Classification[@classificationNode='urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd'][@classifiedObject=$thisID]">SS</xsl:when>
<xsl:when test="//rim:Classification[@classificationNode='urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2'][@classifiedObject=$thisID]">F</xsl:when>
</xsl:choose>
</Type>
<xsl:choose>
<xsl:when test="string-length(rim:Classification/@classificationNode)>0">
<Node id="{rim:Classification[@classificationNode!='']/@id}">
<Value><xsl:value-of select="rim:Classification[@classificationNode!='']/@classificationNode"/></Value>
</Node>
</xsl:when>
<xsl:otherwise>
<Node id="{/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:Classification[@classifiedObject=$thisID]/@id}">
<Value><xsl:value-of select="/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:Classification[@classifiedObject=$thisID]/@classificationNode"/></Value>
</Node>
</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="RegistryPackageSlots"/>
<xsl:call-template name="RegistryPackageExternalIdentifiers"/>
<xsl:call-template name="RegistryPackageClassifications"/>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
</RegistryPackage>
</xsl:for-each>
</xsl:template>

<xsl:template name="Documents">
<xsl:variable name="documentID" select="@id"/>
<xsl:call-template name="DocumentSlots"/>
<DocumentID><xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab']/@value"/></DocumentID>
<PatientID><xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427']/@value"/></PatientID>
<ObjectType><xsl:value-of select="@objectType"/></ObjectType>
<MimeType><xsl:value-of select="@mimeType"/></MimeType>
<Status><xsl:value-of select="@status"/></Status>
<xsl:call-template name="DocumentClassifications"/>
<xsl:call-template name="DocumentExternalIdentifiers"/>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
<Version><xsl:value-of select="/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:Association[@associationType='urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember'][@targetObject=$documentID]/rim:Slot[@name='PreviousVersion']/rim:ValueList/rim:Value/text()"/></Version>
</xsl:template>

<xsl:template name="DocumentClassifications">
<xsl:for-each select="rim:Classification">
<xsl:choose>
<xsl:when test="@classificationScheme='urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a'">
<ClassCode id="{@id}">
<Code><xsl:value-of select="@nodeRepresentation"/></Code>
<CodingScheme><xsl:value-of select="rim:Slot[@name='codingScheme']/rim:ValueList/rim:Value/text()"/></CodingScheme>
<Name><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></Name>
</ClassCode>
</xsl:when>

<xsl:when test="@classificationScheme='urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d'">
<FormatCode id="{@id}">
<Code><xsl:value-of select="@nodeRepresentation"/></Code>
<CodingScheme><xsl:value-of select="rim:Slot[@name='codingScheme']/rim:ValueList/rim:Value/text()"/></CodingScheme>
<Name><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></Name>
</FormatCode>
</xsl:when>

<xsl:when test="@classificationScheme='urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1'">
<HealthCareFacilityTypeCode id="{@id}">
<Code><xsl:value-of select="@nodeRepresentation"/></Code>
<CodingScheme><xsl:value-of select="rim:Slot[@name='codingScheme']/rim:ValueList/rim:Value/text()"/></CodingScheme>
<Name><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></Name>
</HealthCareFacilityTypeCode>
</xsl:when>

<xsl:when test="@classificationScheme='urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead'">
<PracticeSettingCode id="{@id}">
<Code><xsl:value-of select="@nodeRepresentation"/></Code>
<CodingScheme><xsl:value-of select="rim:Slot[@name='codingScheme']/rim:ValueList/rim:Value/text()"/></CodingScheme>
<Name><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></Name>
</PracticeSettingCode>
</xsl:when>

<xsl:when test="@classificationScheme='urn:uuid:f0306f51-975f-434e-a61c-c59651d33983'">
<TypeCode id="{@id}">
<Code><xsl:value-of select="@nodeRepresentation"/></Code>
<CodingScheme><xsl:value-of select="rim:Slot[@name='codingScheme']/rim:ValueList/rim:Value/text()"/></CodingScheme>
<Name><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></Name>
</TypeCode>
</xsl:when>

<xsl:otherwise>
<Classification id="{@id}">
<ClassifiedObject><xsl:value-of select="@classifiedObject"/></ClassifiedObject>
<ClassificationScheme><xsl:value-of select="@classificationScheme"/></ClassificationScheme>
<NodeRepresentation><xsl:value-of select="@nodeRepresentation"/></NodeRepresentation>
<ClassificationNode><xsl:value-of select="@classificationNode"/></ClassificationNode>
<xsl:call-template name="Slots"/>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
</Classification>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

<xsl:template name="RegistryPackageClassifications">
<xsl:for-each select="rim:Classification">
<xsl:choose>
<xsl:when test="@classificationScheme='urn:uuid:aa543740-bdda-424e-8c96-df4873be8500'">
<ContentTypeCode id="{@id}">
<Code><xsl:value-of select="@nodeRepresentation"/></Code>
<CodingScheme><xsl:value-of select="rim:Slot[@name='codingScheme']/rim:ValueList/rim:Value/text()"/></CodingScheme>
<Name><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></Name>
</ContentTypeCode>
</xsl:when>

<xsl:otherwise>
<xsl:if test="string-length(@classificationNode)=0">
<Classification id="{@id}">
<ClassifiedObject><xsl:value-of select="@classifiedObject"/></ClassifiedObject>
<ClassificationScheme><xsl:value-of select="@classificationScheme"/></ClassificationScheme>
<NodeRepresentation><xsl:value-of select="@nodeRepresentation"/></NodeRepresentation>
<ClassificationNode><xsl:value-of select="@classificationNode"/></ClassificationNode>
<xsl:call-template name="Slots"/>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
</Classification>
</xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>


<xsl:template name="Classifications">
<xsl:for-each select="rim:Classification">
<Classification id="{@id}">
<ClassifiedObject><xsl:value-of select="@classifiedObject"/></ClassifiedObject>
<ClassificationScheme><xsl:value-of select="@classificationScheme"/></ClassificationScheme>
<NodeRepresentation><xsl:value-of select="@nodeRepresentation"/></NodeRepresentation>
<ClassificationNode><xsl:value-of select="@classificationNode"/></ClassificationNode>
<xsl:call-template name="Slots"/>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
</Classification>

</xsl:for-each>
</xsl:template>

<xsl:template name="Associations">
<xsl:for-each select="rim:Association">
<Association type="{@associationType}" id="{@id}" lid="{@lid}">
<xsl:call-template name="Classifications"/>
<SourceObject><xsl:value-of select="@sourceObject"/></SourceObject>
<TargetObject><xsl:value-of select="@targetObject"/></TargetObject>
<xsl:call-template name="AssociationSlots"/>
</Association>
</xsl:for-each>
</xsl:template>


<xsl:template name="DocumentSlots">
<SubmissionTime><xsl:value-of select="/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:RegistryPackage/rim:Slot[@name='submissionTime']/rim:ValueList/rim:Value"/></SubmissionTime>
<SourceIdentifier id="{/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:RegistryPackage/rim:ExternalIdentifier[@identificationScheme='urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832']/@id}"><Value><xsl:value-of select="/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:RegistryPackage/rim:ExternalIdentifier[@identificationScheme='urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832']/@value"/></Value></SourceIdentifier>
<xsl:for-each select="rim:Slot">
<xsl:choose>
<xsl:when test="@name='size'">
<Size><xsl:value-of select="rim:ValueList/rim:Value/text()"/></Size>
</xsl:when>
<xsl:when test="@name='hash'">
<Hash><xsl:value-of select="rim:ValueList/rim:Value/text()"/></Hash>
</xsl:when>
<xsl:when test="@name='serviceStartTime'">
<ServiceStartTime><xsl:value-of select="rim:ValueList/rim:Value/text()"/></ServiceStartTime>
</xsl:when>
<xsl:when test="@name='serviceStopTime'">
<ServiceStopTime><xsl:value-of select="rim:ValueList/rim:Value/text()"/></ServiceStopTime>
</xsl:when>
<xsl:when test="@name='submissionTime'">
<SubmissionTime><xsl:value-of select="rim:ValueList/rim:Value/text()"/></SubmissionTime>
</xsl:when>
<xsl:when test="@name='repositoryUniqueId'">
<RepositoryUniqueID><xsl:value-of select="rim:ValueList/rim:Value/text()"/></RepositoryUniqueID>
</xsl:when>
<xsl:when test="@name='sourcePatientId'">
<SourcePatientID><xsl:value-of select="rim:ValueList/rim:Value/text()"/></SourcePatientID>
</xsl:when>
<xsl:when test="@name='creationTime'">
<CreationTime><xsl:value-of select="rim:ValueList/rim:Value/text()"/></CreationTime>
</xsl:when>
<xsl:when test="@name='languageCode'">
<LanguageCode><xsl:value-of select="rim:ValueList/rim:Value/text()"/></LanguageCode>
</xsl:when>
<xsl:when test="@name='documentAvailability'">
<Availability><xsl:value-of select="rim:ValueList/rim:Value/text()"/></Availability>
</xsl:when>
<xsl:otherwise>
<Slot>
<Name><xsl:value-of select="@name"/></Name>
<ValueList>
<xsl:for-each select="rim:ValueList/rim:Value">
<ValueListItem><xsl:value-of select="text()"/></ValueListItem>
</xsl:for-each>
</ValueList>
</Slot>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

<xsl:template name="RegistryPackageSlots">
<xsl:for-each select="rim:Slot">
<xsl:choose>
<xsl:when test="@name='submissionTime'">
<SubmissionTime><xsl:value-of select="rim:ValueList/rim:Value/text()"/></SubmissionTime>
</xsl:when>
<xsl:otherwise>
<Slot>
<Name><xsl:value-of select="@name"/></Name>
<ValueList>
<xsl:for-each select="rim:ValueList/rim:Value">
<ValueListItem><xsl:value-of select="text()"/></ValueListItem>
</xsl:for-each>
</ValueList>
</Slot>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

<xsl:template name="AssociationSlots">
<xsl:for-each select="rim:Slot">
<Slot name="{@name}">
<ValueList><xsl:for-each select="rim:ValueList/rim:Value">
<SlotValue><xsl:value-of select="text()"/></SlotValue>
</xsl:for-each>
</ValueList>
</Slot>
</xsl:for-each>

</xsl:template>

<xsl:template name="Slots">
<xsl:for-each select="rim:Slot">
<Slot>
<Name><xsl:value-of select="@name"/></Name>
<ValueList>
<xsl:for-each select="rim:ValueList/rim:Value">
<ValueListItem><xsl:value-of select="text()"/></ValueListItem>
</xsl:for-each>
</ValueList>
</Slot>
</xsl:for-each>
</xsl:template>

<xsl:template name="DocumentExternalIdentifiers">
<xsl:for-each select="rim:ExternalIdentifier">
<xsl:choose>
<xsl:when test="@identificationScheme='urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab'">
<DocumentUniqueIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></DocumentUniqueIdentifier>
</xsl:when>
<xsl:when test="@identificationScheme='urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427'">
<PatientIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></PatientIdentifier>
</xsl:when>
<xsl:otherwise>
<ExternalIdentifier id="{@id}">
<RegistryObject><xsl:value-of select="@registryObject"/></RegistryObject>
<IdentificationScheme><xsl:value-of select="@identificationScheme"/></IdentificationScheme>
<IdentificationValue><xsl:value-of select="@value"/></IdentificationValue>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
</ExternalIdentifier>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

<xsl:template name="RegistryPackageExternalIdentifiers">
<xsl:for-each select="rim:ExternalIdentifier">
<xsl:choose>
<!-- submission set items -->
<!--Source id -->
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

<!-- folder items -->
<!-- folder set patient id -->
<xsl:when test="@identificationScheme='urn:uuid:f64ffdf0-4b97-4e06-b79f-a52b38ec2f8a'">
<PatientIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></PatientIdentifier>
</xsl:when>
<!-- folder set unique id -->
<xsl:when test="@identificationScheme='urn:uuid:75df8f67-9973-4fbe-a900-df66cefecc5a'">
<UniqueIdentifier id="{@id}"><Value><xsl:value-of select="@value"/></Value></UniqueIdentifier>
</xsl:when>
<xsl:otherwise>
<ExternalIdentifier id="{@id}">
<RegistryObject><xsl:value-of select="@registryObject"/></RegistryObject>
<IdentificationScheme><xsl:value-of select="@identificationScheme"/></IdentificationScheme>
<IdentificationValue><xsl:value-of select="@value"/></IdentificationValue>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
</ExternalIdentifier>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

<xsl:template name="ExternalIdentifiers">
<xsl:for-each select="rim:ExternalIdentifier">
<ExternalIdentifier id="{@id}">
<RegistryObject><xsl:value-of select="@registryObject"/></RegistryObject>
<IdentificationScheme><xsl:value-of select="@identificationScheme"/></IdentificationScheme>
<IdentificationValue><xsl:value-of select="@value"/></IdentificationValue>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
</ExternalIdentifier>
</xsl:for-each>
</xsl:template>

<xsl:template name="Name">
<Title>
<ValueText><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></ValueText>
<Charset><xsl:value-of select="rim:Name/rim:LocalizedString/@charset"/></Charset>
<Lang><xsl:value-of select="rim:Name/rim:LocalizedString/@xml:lang"/></Lang>
</Title>
</xsl:template>

<xsl:template name="Description">
<Comments>
<ValueText><xsl:value-of select="rim:Description/rim:LocalizedString/@value"/></ValueText>
<Charset><xsl:value-of select="rim:Description/rim:LocalizedString/@charset"/></Charset>
<Lang><xsl:value-of select="rim:Description/rim:LocalizedString/@xml:lang"/></Lang>
</Comments>
</xsl:template>

</xsl:stylesheet>


