<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:ihe="urn:ihe:iti:xds-b:2007" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:date="http://exslt.org/dates-and-times" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template name="Document">
<rim:ExtrinsicObject>
<xsl:for-each select="Attributes">
<xsl:if test="text() !=''">
<xsl:attribute name="{@AttributesKey}"><xsl:value-of select="text()"/></xsl:attribute>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates mode="Identifiers" select="."/>
<xsl:attribute name='objectType'><xsl:value-of select="ObjectType/text()"/></xsl:attribute>
<xsl:attribute name='mimeType'><xsl:value-of select="MimeType/text()"/></xsl:attribute>
<xsl:attribute name='status'><xsl:value-of select="Status/text()"/></xsl:attribute>
<xsl:variable name='version'>
<xsl:choose>
<xsl:when test="Version/text()!=''">
<xsl:value-of select="Version/text()"/>
</xsl:when>
<xsl:otherwise>1</xsl:otherwise>
</xsl:choose>
</xsl:variable> 
<xsl:call-template name="EmbeddedDocumentSlots"/>
<xsl:call-template name="Slots"/>
<xsl:if test="SourceIdentifier/Value/text()!='' and not(Slot[Name/text()='urn:healthshare:slots:sourceId'])">
<rim:Slot name="urn:healthshare:slots:sourceId">
<rim:ValueList>
<rim:Value>
<xsl:value-of select="SourceIdentifier/Value/text()"/>
</rim:Value>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
<rim:VersionInfo versionName="{$version}"/>
<xsl:call-template name="DocumentClassifications">
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
<xsl:call-template name="Classifications">
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
<xsl:call-template name="ExternalIdentifiers">
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
<xsl:call-template name="DocumentExternalIdentifiers">
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
</rim:ExtrinsicObject>
</xsl:template>

<xsl:template name="RegistryPackages">
<xsl:for-each select="Submission/RegistryPackage">
<xsl:call-template name="RegistryPackage"/>
</xsl:for-each>
<xsl:for-each select="Submission/RegistryPackagesStream/RegistryPackage">
<xsl:call-template name="RegistryPackage"/>
</xsl:for-each>
</xsl:template>
<xsl:template name="RegistryPackage">
<rim:RegistryPackage objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:RegistryPackage">
<xsl:variable name='version'>
<xsl:choose>
<xsl:when test="Version/text()!=''">
<xsl:value-of select="Version/text()"/>
</xsl:when>
<xsl:otherwise>1</xsl:otherwise>
</xsl:choose>
</xsl:variable> 

<xsl:for-each select="Attributes">
<xsl:if test="text() !=''">
<xsl:attribute name="{@AttributesKey}"><xsl:value-of select="text()"/></xsl:attribute>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates mode="Identifiers" select="."/>
<xsl:attribute name='status'><xsl:value-of select="Status/text()"/></xsl:attribute>
<xsl:call-template name="EmbeddedRegistryPackageSlots"/>
<xsl:call-template name="Slots"/>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
<rim:VersionInfo versionName="{$version}"/>
<xsl:call-template name="RegistryPackageClassifications">
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
<xsl:call-template name="Classifications">
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

<xsl:if test="Node/@id">
<rim:Classification>
<xsl:attribute name="id"><xsl:value-of select="Node/@id"/></xsl:attribute>
<xsl:attribute name='lid'><xsl:value-of select="Node/@id"/></xsl:attribute>
<xsl:attribute name="classifiedObject"><xsl:value-of select="@id"/></xsl:attribute>
<xsl:attribute name="classificationNode"><xsl:value-of select="Node/Value/text()"/></xsl:attribute>
<xsl:attribute name="nodeRepresentation"/>
<xsl:attribute name="objectType">urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification</xsl:attribute>
</rim:Classification>
</xsl:if>
<xsl:call-template name="ExternalIdentifiers">
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
<xsl:call-template name="RegistryPackageExternalIdentifiers">
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
</rim:RegistryPackage>
</xsl:template>

<xsl:template name="ObjectRefs">
<xsl:for-each select="Submission/ObjectRef">
<rim:ObjectRef id="{text()}"/>
</xsl:for-each>
</xsl:template>

<xsl:template name="EmbeddedDocumentSlots">
<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'creationTime'"/>
<xsl:with-param name="value" select="CreationTime/text()"/>
</xsl:call-template>

<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'languageCode'"/>
<xsl:with-param name="value" select="LanguageCode/text()"/>
</xsl:call-template>

<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'serviceStartTime'"/>
<xsl:with-param name="value" select="ServiceStartTime/text()"/>
</xsl:call-template>

<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'serviceStopTime'"/>
<xsl:with-param name="value" select="ServiceStopTime/text()"/>
</xsl:call-template>

<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'sourcePatientId'"/>
<xsl:with-param name="value" select="SourcePatientID/text()"/>
</xsl:call-template>

<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'hash'"/>
<xsl:with-param name="value" select="Hash/text()"/>
</xsl:call-template>

<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'size'"/>
<xsl:with-param name="value" select="Size/text()"/>
</xsl:call-template>

<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'repositoryUniqueId'"/>
<xsl:with-param name="value" select="RepositoryUniqueID/text()"/>
</xsl:call-template>

<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'documentAvailability'"/>
<xsl:with-param name="value" select="Availability/text()"/>
</xsl:call-template>

</xsl:template>


<xsl:template name="EmbeddedRegistryPackageSlots">
<xsl:call-template name="EmbeddedSlot">
<xsl:with-param name="field" select="'submissionTime'"/>
<xsl:with-param name="value" select="SubmissionTime/text()"/>
</xsl:call-template>
</xsl:template>


<xsl:template name="EmbeddedSlot">
<xsl:param name="field"/>
<xsl:param name="value"/>
<xsl:if test="$value!=''">
<rim:Slot>
<xsl:attribute name="name"><xsl:value-of select="$field"/></xsl:attribute>
<rim:ValueList>
<rim:Value>
<xsl:value-of select="$value"/>
</rim:Value>
</rim:ValueList>
</rim:Slot>
</xsl:if>
</xsl:template>

<xsl:template name="AssociationSlots">
<xsl:for-each select="Slot">
<rim:Slot>
<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
<rim:ValueList>
<xsl:for-each select="ValueList/SlotValue">
<rim:Value>
<xsl:value-of select="text()"/>
</rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:for-each>
</xsl:template>


<xsl:template name="Slots">
<xsl:for-each select="Slot">
<rim:Slot>
<xsl:attribute name="name"><xsl:value-of select="Name"/></xsl:attribute>
<rim:ValueList>
<xsl:for-each select="ValueList/ValueListItem">
<rim:Value>
<xsl:value-of select="text()"/>
</rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:for-each>
</xsl:template>

<xsl:template name="DocumentClassifications">
<xsl:param name="version"/>
<xsl:call-template name="DocumentClassification">
<xsl:with-param name="field" select="'urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a'"/>
<xsl:with-param name="value" select="ClassCode"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

<xsl:call-template name="DocumentClassification">
<xsl:with-param name="field" select="'urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d'"/>
<xsl:with-param name="value" select="FormatCode"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

<xsl:call-template name="DocumentClassification">
<xsl:with-param name="field" select="'urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1'"/>
<xsl:with-param name="value" select="HealthCareFacilityTypeCode"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

<xsl:call-template name="DocumentClassification">
<xsl:with-param name="field" select="'urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead'"/>
<xsl:with-param name="value" select="PracticeSettingCode"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

<xsl:call-template name="DocumentClassification">
<xsl:with-param name="field" select="'urn:uuid:f0306f51-975f-434e-a61c-c59651d33983'"/>
<xsl:with-param name="value" select="TypeCode"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

</xsl:template>

<xsl:template name="DocumentClassification">
<xsl:param name="field"/>
<xsl:param name="value"/>
<xsl:param name="IID"/>
<xsl:param name="version"/>
<xsl:if test="$value/Code/text()!=''">
<rim:Classification>
<xsl:attribute name="id"><xsl:value-of select="$value/@id"/></xsl:attribute>
<xsl:attribute name='lid'><xsl:value-of select="$value/@id"/></xsl:attribute>
<xsl:attribute name="classifiedObject"><xsl:value-of select="$IID"/></xsl:attribute>
<xsl:attribute name="classificationScheme"><xsl:value-of select="$field"/></xsl:attribute>
<xsl:attribute name="nodeRepresentation"><xsl:value-of select="$value/Code/text()"/></xsl:attribute>
<xsl:attribute name="objectType">urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification</xsl:attribute>
<rim:Slot name="codingScheme">
<rim:ValueList>
<rim:Value><xsl:value-of select="$value/CodingScheme/text()"/></rim:Value>
</rim:ValueList>
</rim:Slot>
<rim:Name>
<xsl:for-each select="$value/Name">
<rim:LocalizedString> 
<xsl:attribute name="value"><xsl:value-of select="text()"/></xsl:attribute>
<xsl:if test="@Charset !=''">
<xsl:attribute name="charset"><xsl:value-of select="@Charset"/></xsl:attribute>
</xsl:if>
<xsl:if test="@Lang !=''">
<xsl:attribute name="xml:lang"><xsl:value-of select="@Lang"/></xsl:attribute>
</xsl:if>
</rim:LocalizedString> 
</xsl:for-each>
</rim:Name>
<rim:VersionInfo versionName="{$version}"/>
</rim:Classification>
</xsl:if>
</xsl:template>

<xsl:template name="RegistryPackageClassifications">
<xsl:param name="version"/>
<xsl:call-template name="RegistryPackageClassification">
<xsl:with-param name="field" select="'urn:uuid:aa543740-bdda-424e-8c96-df4873be8500'"/>
<xsl:with-param name="value" select="ContentTypeCode"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

</xsl:template>

<xsl:template name="RegistryPackageClassification">
<xsl:param name="field"/>
<xsl:param name="value"/>
<xsl:param name="IID"/>
<xsl:param name="version"/>
<xsl:if test="$value/Code/text()!=''">
<rim:Classification>
<xsl:attribute name="id"><xsl:value-of select="$value/@id"/></xsl:attribute>
<xsl:attribute name='lid'><xsl:value-of select="$value/@id"/></xsl:attribute>
<xsl:attribute name="classifiedObject"><xsl:value-of select="$IID"/></xsl:attribute>
<xsl:attribute name="classificationScheme"><xsl:value-of select="$field"/></xsl:attribute>
<xsl:attribute name="nodeRepresentation"><xsl:value-of select="$value/Code/text()"/></xsl:attribute>
<xsl:attribute name="objectType">urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification</xsl:attribute>
<rim:Slot name="codingScheme">
<rim:ValueList>
<rim:Value><xsl:value-of select="$value/CodingScheme/text()"/></rim:Value>
</rim:ValueList>
</rim:Slot>
<rim:Name>
<xsl:for-each select="$value/Name">
<rim:LocalizedString> 
<xsl:attribute name="value"><xsl:value-of select="text()"/></xsl:attribute>
<xsl:if test="@Charset !=''">
<xsl:attribute name="charset"><xsl:value-of select="@Charset"/></xsl:attribute>
</xsl:if>
<xsl:if test="@Lang !=''">
<xsl:attribute name="xml:lang"><xsl:value-of select="@Lang"/></xsl:attribute>
</xsl:if>
</rim:LocalizedString> 
</xsl:for-each>
</rim:Name>
<rim:VersionInfo versionName="{$version}"/>
</rim:Classification>
</xsl:if>
</xsl:template>



<xsl:template name="Classifications">
<xsl:param name="version"/>
<xsl:for-each select="Classification">
<rim:Classification>
<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
<xsl:attribute name='lid'><xsl:value-of select="@id"/></xsl:attribute>
<xsl:attribute name="classifiedObject"><xsl:value-of select="ClassifiedObject/text()"/></xsl:attribute>
<xsl:if test="ClassificationScheme/text()!=''">
<xsl:attribute name="classificationScheme"><xsl:value-of select="ClassificationScheme/text()"/></xsl:attribute>
</xsl:if>
<xsl:if test="ClassificationNode/text()!=''">
<xsl:attribute name="classificationNode"><xsl:value-of select="ClassificationNode/text()"/></xsl:attribute>
</xsl:if>
<xsl:attribute name="nodeRepresentation"><xsl:value-of select="NodeRepresentation/text()"/></xsl:attribute>
<xsl:attribute name="objectType">urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification</xsl:attribute>
<xsl:call-template name="Slots"/>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
<rim:VersionInfo versionName="{$version}"/>
</rim:Classification>
</xsl:for-each>
</xsl:template>

<xsl:template name="Associations">
<xsl:for-each select="Submission/Association">
<xsl:call-template name="Association"/>
</xsl:for-each>
<xsl:for-each select="Submission/AssociationsStream/Association">
<xsl:call-template name="Association"/>
</xsl:for-each>

</xsl:template>
<xsl:template name="Association">
<rim:Association>
<xsl:apply-templates mode="Identifiers" select="."/>
<xsl:attribute name="sourceObject"><xsl:value-of select="SourceObject/text()"/></xsl:attribute>
<xsl:attribute name="targetObject"><xsl:value-of select="TargetObject/text()"/></xsl:attribute>
<xsl:attribute name="associationType"><xsl:value-of select="@type"/></xsl:attribute>
<xsl:attribute name='status'><xsl:value-of select="Status/text()"/></xsl:attribute>
<xsl:for-each select="Attributes">
<xsl:if test="text() !=''">
<xsl:attribute name="{@AttributesKey}"><xsl:value-of select="text()"/></xsl:attribute>
</xsl:if>
</xsl:for-each>
<xsl:call-template name="AssociationSlots"/>
<xsl:call-template name="Classifications"/>
</rim:Association>
</xsl:template>

<xsl:template name="Name">
<xsl:choose>
<xsl:when test="Title/ValueText !=''">
<rim:Name>
<rim:LocalizedString> 
<xsl:attribute name="value"><xsl:value-of select="Title/ValueText"/></xsl:attribute>
<xsl:if test="Title/Charset !=''">
<xsl:attribute name="charset"><xsl:value-of select="Title/Charset"/></xsl:attribute>
</xsl:if>
<xsl:if test="Title/Lang !=''">
<xsl:attribute name="xml:lang"><xsl:value-of select="Title/Lang"/></xsl:attribute>
</xsl:if>
</rim:LocalizedString> 
</rim:Name>
</xsl:when>
<xsl:when test="Name/ValueText !=''">
<rim:Name>
<rim:LocalizedString> 
<xsl:attribute name="value"><xsl:value-of select="Name/ValueText"/></xsl:attribute>
<xsl:if test="Name/Charset !=''">
<xsl:attribute name="charset"><xsl:value-of select="Name/Charset"/></xsl:attribute>
</xsl:if>
<xsl:if test="Name/Lang !=''">
<xsl:attribute name="xml:lang"><xsl:value-of select="Name/Lang"/></xsl:attribute>
</xsl:if>
</rim:LocalizedString> 
</rim:Name>
</xsl:when>
</xsl:choose>
</xsl:template>

<xsl:template name="Description">
<xsl:choose>
<xsl:when test="Comments/ValueText !=''">
<rim:Description>
<rim:LocalizedString> 
<xsl:attribute name="value"><xsl:value-of select="Comments/ValueText"/></xsl:attribute>
<xsl:if test="Comments/Charset !=''">
<xsl:attribute name="charset"><xsl:value-of select="Comments/Charset"/></xsl:attribute>
</xsl:if>
<xsl:if test="Comments/Lang !=''">
<xsl:attribute name="xml:lang"><xsl:value-of select="Comments/Lang"/></xsl:attribute>
</xsl:if>
</rim:LocalizedString> 
</rim:Description>
</xsl:when>
<xsl:when test="Description/ValueText !=''">
<rim:Description>
<rim:LocalizedString> 
<xsl:attribute name="value"><xsl:value-of select="Description/ValueText"/></xsl:attribute>
<xsl:if test="Description/Charset !=''">
<xsl:attribute name="charset"><xsl:value-of select="Description/Charset"/></xsl:attribute>
</xsl:if>
<xsl:if test="Description/Lang !=''">
<xsl:attribute name="xml:lang"><xsl:value-of select="Description/Lang"/></xsl:attribute>
</xsl:if>
</rim:LocalizedString> 
</rim:Description>
</xsl:when>
</xsl:choose>
</xsl:template>

<xsl:template name="DocumentExternalIdentifiers">
<xsl:param name="version"/>
<xsl:call-template name="CodedExternalIdentifier">
<xsl:with-param name="field" select="'urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427'"/>
<xsl:with-param name="value" select="PatientIdentifier"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="name" select="'XDSDocumentEntry.patientId'"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

<xsl:call-template name="CodedExternalIdentifier">
<xsl:with-param name="field" select="'urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab'"/>
<xsl:with-param name="value" select="DocumentUniqueIdentifier"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="name" select="'XDSDocumentEntry.uniqueId'"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

</xsl:template>

<xsl:template name="CodedExternalIdentifier">
<xsl:param name="field"/>
<xsl:param name="value"/>
<xsl:param name="IID"/>
<xsl:param name="name"/>
<xsl:param name="version"/>
<xsl:if test="$value/Value/text()!=''">

<rim:ExternalIdentifier>
<xsl:attribute name="id"><xsl:value-of select="$value/@id"/></xsl:attribute>
<xsl:attribute name='lid'><xsl:value-of select="$value/@iid"/></xsl:attribute>
<xsl:attribute name="registryObject"><xsl:value-of select="$IID"/></xsl:attribute>
<xsl:attribute name="identificationScheme"><xsl:value-of select="$field"/></xsl:attribute>
<xsl:attribute name="value"><xsl:value-of select="$value/Value/text()"/></xsl:attribute>
<rim:Name>
<rim:LocalizedString value="{$name}"></rim:LocalizedString>
</rim:Name>
<rim:VersionInfo versionName="{$version}"/>
</rim:ExternalIdentifier>
</xsl:if>
</xsl:template>

<xsl:template name="RegistryPackageExternalIdentifiers">
<xsl:param name="version"/>
<!-- submission set identifiers -->
<xsl:if test="Node/Value/text()='urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd'">
<xsl:call-template name="CodedExternalIdentifier">
<xsl:with-param name="field" select="'urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832'"/>
<xsl:with-param name="value" select="SourceIdentifier"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="name" select="'XDSSubmissionSet.sourceId'"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

<xsl:call-template name="CodedExternalIdentifier">
<xsl:with-param name="field" select="'urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8'"/>
<xsl:with-param name="value" select="UniqueIdentifier"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="name" select="'XDSSubmissionSet.uniqueId'"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>

<xsl:call-template name="CodedExternalIdentifier">
<xsl:with-param name="field" select="'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446'"/>
<xsl:with-param name="value" select="PatientIdentifier"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="name" select="'XDSSubmissionSet.patientId'"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
</xsl:if>
       
 <!-- folder identifiers -->
<xsl:if test="Node/Value/text()='urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2'">
<xsl:call-template name="CodedExternalIdentifier">
<xsl:with-param name="field" select="'urn:uuid:75df8f67-9973-4fbe-a900-df66cefecc5a'"/>
<xsl:with-param name="value" select="UniqueIdentifier"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="name" select="'XDSFolder.uniqueId'"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>


<xsl:call-template name="CodedExternalIdentifier">
<xsl:with-param name="field" select="'urn:uuid:f64ffdf0-4b97-4e06-b79f-a52b38ec2f8a'"/>
<xsl:with-param name="value" select="PatientIdentifier"/>
<xsl:with-param name="IID" select="@id"/>
<xsl:with-param name="name" select="'XDSFolder.patientId'"/>
<xsl:with-param name="version" select="$version"/>
</xsl:call-template>
</xsl:if>
</xsl:template>

<xsl:template name="ExternalIdentifiers">
<xsl:param name="version"/>
<xsl:for-each select="ExternalIdentifier">
<xsl:if test="@id">
<rim:ExternalIdentifier>
<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
<xsl:attribute name="lid"><xsl:value-of select="@lid"/></xsl:attribute>
<xsl:attribute name="registryObject"><xsl:value-of select="RegistryObject/text()"/></xsl:attribute>
<xsl:attribute name="identificationScheme"><xsl:value-of select="IdentificationScheme/text()"/></xsl:attribute>
<xsl:attribute name="value"><xsl:value-of select="IdentificationValue/text()"/></xsl:attribute>
<xsl:call-template name="Name"/>
<xsl:call-template name="Description"/>
<rim:VersionInfo versionName="{$version}"/>
</rim:ExternalIdentifier>
</xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template mode="Identifiers" match="*">
<xsl:attribute name='id'><xsl:value-of select="@id"/></xsl:attribute>
<xsl:attribute name='lid'><xsl:choose><xsl:when test="@lid"><xsl:value-of select="@lid"/></xsl:when><xsl:otherwise><xsl:value-of select="@id"/></xsl:otherwise></xsl:choose></xsl:attribute>
</xsl:template>
</xsl:stylesheet>
