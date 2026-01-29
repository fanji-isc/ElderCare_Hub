<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
version="1.0" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007" 
xmlns:xop="http://www.w3.org/2004/08/xop/include" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:hl7="urn:hl7-org:v3"
xmlns="urn:hl7-org:v3"
exclude-result-prefixes="isc">
  
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
 
<xsl:variable name="lang">
<xsl:if test="string-length(/*[local-name()]/Language/text()) and /*[local-name()]/Language/text()!='en-US'">
<xsl:value-of select="/*[local-name()]/Language/text()"/>
</xsl:if>
</xsl:variable>

<xsl:template match="/">
<xsl:apply-templates select="ProvideAndRegisterRequest"/>
<xsl:apply-templates select="RegisterRequest"/>
<xsl:apply-templates select="UpdateDocumentSetRequest"/>
</xsl:template>

<xsl:template match="RegisterRequest">
<xsl:apply-templates mode="SubmitObjectsRequest" select="."/>
</xsl:template>

<xsl:template match="UpdateDocumentSetRequest">
<xsl:apply-templates mode="SubmitObjectsRequest" select="."/>
</xsl:template>

<xsl:template match="ProvideAndRegisterRequest">
<xdsb:ProvideAndRegisterDocumentSetRequest>
<xsl:apply-templates mode="SubmitObjectsRequest" select="."/>
<!-- XOP document content pointer(s) -->
<xsl:for-each select="Documents/ProvidedDocument">
<xsl:variable name="documentID"><xsl:call-template name="VariableID"><xsl:with-param name="value" select="@id"/></xsl:call-template></xsl:variable>
<xsl:choose>
<xsl:when test="Body/text()!=''">
<xdsb:Document id="{$documentID}"><xsl:value-of select='Body/text()'/></xdsb:Document>
</xsl:when>
<xsl:otherwise>
<!-- the attachment is done before calling the template so use the ID defined -->
<xdsb:Document id="{$documentID}"><xop:Include href="{concat('cid:',@id)}"/></xdsb:Document>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xdsb:ProvideAndRegisterDocumentSetRequest>
</xsl:template>

<xsl:template name="SubmitObjectsRequest" mode="SubmitObjectsRequest" match="*">
<xsl:variable name="OnlyRegister" select="/RegisterRequest!='' or /UpdateDocumentSetRequest!=''"/>
<xsl:variable name="submissionSetID">
<xsl:call-template name="VariableID"><xsl:with-param name="value" select="@id"/></xsl:call-template>
</xsl:variable>
<lcm:SubmitObjectsRequest>
<rim:RegistryObjectList>

<!-- XDSDocumentEntry -->
<xsl:for-each select="Documents/ProvidedDocument">
<xsl:variable name="docUUID" select="concat('urn:uuid:',@id)"/>
<xsl:variable name="documentID">
<xsl:call-template name="VariableID"><xsl:with-param name="value" select="@id"/></xsl:call-template>
</xsl:variable>

<!-- DocSource generating entryUUID to support RPLC option -->
<xsl:element name="rim:ExtrinsicObject">
<xsl:attribute name="id"><xsl:value-of select="$documentID"/></xsl:attribute>
<xsl:attribute name="mimeType"><xsl:value-of select="MimeType/text()"/></xsl:attribute>
<xsl:if test="@lid!=''">
<xsl:attribute name="lid"><xsl:call-template name="VariableID"><xsl:with-param name="value" select="@lid"/></xsl:call-template></xsl:attribute>
</xsl:if>
<!-- Added home for Metadata update test -->
<xsl:if test="@home">
<xsl:attribute name="home">
<xsl:value-of select="@home"/>
</xsl:attribute>
</xsl:if>
<xsl:choose>
<xsl:when test="@type='Stable'">
<xsl:attribute name="objectType"><xsl:value-of select="'urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1'"/></xsl:attribute>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="objectType"><xsl:value-of select="'urn:uuid:34268e47-fdf5-41a6-ba33-82133c465248'"/></xsl:attribute>
</xsl:otherwise>
</xsl:choose>
<xsl:if test="AvailabilityStatus">
<xsl:attribute name="status">
<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:StatusType:',AvailabilityStatus/text())"/> 
</xsl:attribute>
</xsl:if>

<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'creationTime'"/>
<xsl:with-param name="Value"	select="CreationTime/text()"/>
</xsl:call-template>

<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'languageCode'"/>
<xsl:with-param name="Value"	select="LanguageCode/text()"/>
</xsl:call-template>

<xsl:if test="LegalAuthenticator/text()!=''">
<rim:Slot name="legalAuthenticator"><rim:ValueList><rim:Value><xsl:value-of select="LegalAuthenticator/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
</xsl:if>

<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'serviceStartTime'"/>
<xsl:with-param name="Value"	select="ServiceStartTime/text()"/>
</xsl:call-template>

<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'serviceStopTime'"/>
<xsl:with-param name="Value"	select="ServiceStopTime/text()"/>
</xsl:call-template>

<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'sourcePatientId'"/>
<xsl:with-param name="Value"	select="SourcePatientId/text()"/>
</xsl:call-template>

<xsl:if test='Size/text()'>
<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'size'"/>
<xsl:with-param name="Value"	select="Size/text()"/>
</xsl:call-template>
</xsl:if>

<xsl:if test='Hash/text()'>
<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'hash'"/>
<xsl:with-param name="Value"	select="Hash/text()"/>
</xsl:call-template>
</xsl:if>

<xsl:if test='URI/text()'>
<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'uri'"/>
<xsl:with-param name="Value"	select="URI/text()"/>
</xsl:call-template>
</xsl:if>

<xsl:if test='RepositoryUniqueId/text()'>
<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'repositoryUniqueId'"/>
<xsl:with-param name="Value"	select="RepositoryUniqueId/text()"/>
</xsl:call-template>
</xsl:if>

<xsl:if test="SourcePatientInfo/Value">
<rim:Slot name="sourcePatientInfo">
<rim:ValueList>
<xsl:for-each select="SourcePatientInfo/Value">
<rim:Value><xsl:value-of select="./text()"/></rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>

<!-- don't include Availability when sending to repository-->
<xsl:if test='Availability/text() and $OnlyRegister'>
<xsl:call-template name="Slot">
<xsl:with-param name="Name"		select="'documentAvailability'"/>
<xsl:with-param name="Value"	select="Availability/text()"/>
</xsl:call-template>
</xsl:if>

<xsl:for-each select="DocumentSlots/Slot">
<xsl:variable name="CustomSlot" select="string-length(substring-after(@name,'urn:'))"/>
<xsl:if test="$CustomSlot !=0 or $OnlyRegister">
<rim:Slot name="{@name}">
<rim:ValueList>
<xsl:for-each select="ValueList/SlotValue">
<rim:Value><xsl:value-of select="text()"/></rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>
</xsl:for-each>
<xsl:if test="Version/text()!=''">
<rim:VersionInfo versionName="{Version/text()}"></rim:VersionInfo>
</xsl:if>
<xsl:if test="Title/text()!=''"><rim:Name><xsl:apply-templates mode="LocalizedString" select="Title"/></rim:Name></xsl:if>
<xsl:if test="Comments/text()!=''"><rim:Description><xsl:apply-templates mode="LocalizedString" select="Comments"/></rim:Description></xsl:if>
	    
<xsl:if test="ClassCode/Code/text() !=''">
<rim:Classification classificationScheme="urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a" 
	classifiedObject="{$documentID}" id="{isc:evaluate('createID','ClassCode')}" 
	nodeRepresentation="{ClassCode/Code/text()}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="codingScheme">
<rim:ValueList><rim:Value><xsl:value-of select="ClassCode/Scheme/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<rim:Name><xsl:apply-templates mode="LocalizedString" select="ClassCode/Description"/></rim:Name>
</rim:Classification>
</xsl:if>

<xsl:for-each select="ConfidentialityCode">
<xsl:if test="Code/text() !=''">
<rim:Classification classificationScheme="urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f" 
	classifiedObject="{$documentID}" id="{isc:evaluate('createID','ConfidentialityCode')}" 
	nodeRepresentation="{Code/text()}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="codingScheme">
<rim:ValueList><rim:Value><xsl:value-of select="Scheme/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<xsl:if test="Description/text() !=''">
<rim:Name><xsl:apply-templates mode="LocalizedString" select="Description"/></rim:Name>
</xsl:if>
</rim:Classification>
</xsl:if>
</xsl:for-each>

<xsl:if test="FormatCode/Code/text()!=''">
<rim:Classification classificationScheme="urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d" 
	classifiedObject="{$documentID}" id="{isc:evaluate('createID','FormatCode')}" 
	nodeRepresentation="{FormatCode/Code/text()}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="codingScheme">
<rim:ValueList><rim:Value><xsl:value-of select="FormatCode/Scheme/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<rim:Name><xsl:apply-templates mode="LocalizedString" select="FormatCode/Description"/></rim:Name>
</rim:Classification>
</xsl:if>

<xsl:if test="HealthcareFacilityTypeCode/Code/text() !=''">
<rim:Classification classificationScheme="urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1" 
	classifiedObject="{$documentID}" id="{isc:evaluate('createID','HealthcareFacilityTypeCode')}" 
	nodeRepresentation="{HealthcareFacilityTypeCode/Code/text()}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="codingScheme">
<rim:ValueList><rim:Value><xsl:value-of select="HealthcareFacilityTypeCode/Scheme/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<rim:Name><xsl:apply-templates mode="LocalizedString" select="HealthcareFacilityTypeCode/Description"/></rim:Name>
</rim:Classification>
</xsl:if>

<xsl:if test="PracticeSettingCode/Code/text()!=''">
<rim:Classification classificationScheme="urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead" 
	classifiedObject="{$documentID}" id="{isc:evaluate('createID','PracticeSettingCode')}" 
	nodeRepresentation="{PracticeSettingCode/Code/text()}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="codingScheme">
<rim:ValueList><rim:Value><xsl:value-of select="PracticeSettingCode/Scheme/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<rim:Name><xsl:apply-templates mode="LocalizedString" select="PracticeSettingCode/Description"/></rim:Name>
</rim:Classification>
</xsl:if>

<xsl:if test="TypeCode/Code/text()!=''">
<rim:Classification classificationScheme="urn:uuid:f0306f51-975f-434e-a61c-c59651d33983" 
classifiedObject="{$documentID}" id="{isc:evaluate('createID','TypeCode')}" 
nodeRepresentation="{TypeCode/Code/text()}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="codingScheme">
<rim:ValueList><rim:Value><xsl:value-of select="TypeCode/Scheme/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<rim:Name><xsl:apply-templates mode="LocalizedString" select="TypeCode/Description"/></rim:Name>
</rim:Classification>
</xsl:if>

<xsl:for-each select="EventCodeList">
<rim:Classification classificationScheme="urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4" 
classifiedObject="{$documentID}" id="{isc:evaluate('createID','EventCode')}" 
nodeRepresentation="{Code/text()}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="codingScheme">
<rim:ValueList><rim:Value><xsl:value-of select="Scheme/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<rim:Name><xsl:apply-templates mode="LocalizedString" select="Description"/></rim:Name>
</rim:Classification>
</xsl:for-each>

<xsl:for-each select='Author'>
<rim:Classification classificationScheme="urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d" 
	classifiedObject="{$documentID}" id="{isc:evaluate('createID','DocumentAuthor')}" 
	nodeRepresentation="" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="authorPerson">
<rim:ValueList><rim:Value><xsl:value-of select="AuthorPerson/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<xsl:if test='AuthorInstitution/Value'>
<rim:Slot name="authorInstitution">
<rim:ValueList>
<xsl:for-each select="AuthorInstitution/Value">
<rim:Value><xsl:value-of select="text()"/></rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:if test='AuthorRole/Value'>
<rim:Slot name="authorRole">
<rim:ValueList>
<xsl:for-each select="AuthorRole/Value">
<rim:Value><xsl:value-of select="text()"/></rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:if test='AuthorSpecialty/Value'>
<rim:Slot name="authorSpecialty">
<rim:ValueList>
<xsl:for-each select="AuthorSpecialty/Value">
<rim:Value><xsl:value-of select="text()"/></rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:if test='AuthorTelecommunication/Value'>
<rim:Slot name="authorTelecommunication">
<rim:ValueList>
<xsl:for-each select="AuthorTelecommunication/Value">
<rim:Value><xsl:value-of select="text()"/></rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>
</rim:Classification>
</xsl:for-each>

<!-- patient id -->
<rim:ExternalIdentifier 
id="{isc:evaluate('createID')}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"
registryObject="{$documentID}"
identificationScheme="urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427"
value="{PatientId/text()}">
<rim:Name><xsl:call-template name="LocalizedString"><xsl:with-param name="value" select="'XDSDocumentEntry.patientId'"/></xsl:call-template></rim:Name>
</rim:ExternalIdentifier>

<!-- document unique id -->
<rim:ExternalIdentifier 
id="{isc:evaluate('createID')}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"
registryObject="{$documentID}"
identificationScheme="urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab"
value="{UniqueId/text()}">
<rim:Name><xsl:call-template name="LocalizedString"><xsl:with-param name="value" select="'XDSDocumentEntry.uniqueId'"/></xsl:call-template></rim:Name>
</rim:ExternalIdentifier>
</xsl:element>
</xsl:for-each>

<!-- XDSSubmissionSet -->
<rim:RegistryPackage id="{$submissionSetID}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:RegistryPackage">
<rim:Slot name="submissionTime">
<rim:ValueList><rim:Value><xsl:value-of select="isc:evaluate('createHL7Timestamp')"/></rim:Value></rim:ValueList>
</rim:Slot>

<xsl:for-each select="IntendedRecipient/Value">
<rim:Slot name="intendedRecipient">
<rim:ValueList><rim:Value><xsl:value-of select="text()"/></rim:Value></rim:ValueList>
</rim:Slot>
</xsl:for-each>

<xsl:if test="Title/text()!=''"><rim:Name><xsl:apply-templates mode="LocalizedString" select="Title" /></rim:Name></xsl:if>
<xsl:if test="Comments/text()!=''"><rim:Description><xsl:apply-templates mode="LocalizedString" select="Comments" /></rim:Description></xsl:if>

<xsl:if test="ContentTypeCode/Code/text()!=''">
<rim:Classification classificationScheme="urn:uuid:aa543740-bdda-424e-8c96-df4873be8500" 
	classifiedObject="{$submissionSetID}" id="{isc:evaluate('createID','ContentTypeCode')}" 
	nodeRepresentation="{ContentTypeCode/Code/text()}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="codingScheme">
<rim:ValueList><rim:Value><xsl:value-of select="ContentTypeCode/Scheme/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<rim:Name><xsl:apply-templates mode="LocalizedString" select="ContentTypeCode/Description"/></rim:Name>
</rim:Classification>
</xsl:if>

<xsl:for-each select="Author">
<rim:Classification classificationScheme="urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d" 
	classifiedObject="{$submissionSetID}" id="{isc:evaluate('createID','SubmissionSetAuthor')}" 
	nodeRepresentation="" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification">
<rim:Slot name="authorPerson">
<rim:ValueList><rim:Value><xsl:value-of select="AuthorPerson/text()"/></rim:Value></rim:ValueList>
</rim:Slot>
<xsl:for-each select="AuthorInstitution/Value">
<rim:Slot name="authorInstitution">
<rim:ValueList><rim:Value><xsl:value-of select="text()"/></rim:Value></rim:ValueList>
</rim:Slot>
</xsl:for-each>
<xsl:for-each select="AuthorRole/Value">
<rim:Slot name="authorRole">
<rim:ValueList><rim:Value><xsl:value-of select="text()"/></rim:Value></rim:ValueList>
</rim:Slot>
</xsl:for-each>
<xsl:for-each select="AuthorSpecialty/Value">
<rim:Slot name="authorSpecialty">
<rim:ValueList><rim:Value><xsl:value-of select="text()"/></rim:Value></rim:ValueList>
</rim:Slot>
</xsl:for-each>
<xsl:for-each select="AuthorTelecommunication/Value">
<rim:Slot name="authorTelecommunication">
<rim:ValueList><rim:Value><xsl:value-of select="text()"/></rim:Value></rim:ValueList>
</rim:Slot>
</xsl:for-each>
</rim:Classification>
</xsl:for-each>

<!-- submission set patient id -->
<rim:ExternalIdentifier 
id="{isc:evaluate('createID')}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"
registryObject="{$submissionSetID}"
identificationScheme="urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446"
value="{PatientId/text()}">
<rim:Name><xsl:call-template name="LocalizedString"><xsl:with-param name="value" select="'XDSSubmissionSet.patientId'"/></xsl:call-template></rim:Name>
</rim:ExternalIdentifier>

<!-- submission set unique id -->
<rim:ExternalIdentifier 
id="{isc:evaluate('createID')}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"
registryObject="{$submissionSetID}"
identificationScheme="urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8"
value="{UniqueId/text()}">
<rim:Name><xsl:call-template name="LocalizedString"><xsl:with-param name="value" select="'XDSSubmissionSet.uniqueId'"/></xsl:call-template></rim:Name>
</rim:ExternalIdentifier>

<!-- submission set source id -->
<rim:ExternalIdentifier 
id="{isc:evaluate('createID')}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"
registryObject="{$submissionSetID}"
identificationScheme="urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832"
value="{SourceId/text()}">
<rim:Name><xsl:call-template name="LocalizedString"><xsl:with-param name="value" select="'XDSSubmissionSet.sourceId'"/></xsl:call-template></rim:Name>
</rim:ExternalIdentifier>
</rim:RegistryPackage>


<!-- Classification: Indicate which RegistryPackage is a XSDSubmissionSet -->
<rim:Classification 
id="{isc:evaluate('createID','isSS')}"
classifiedObject="{$submissionSetID}"
classificationNode="urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"/>

<!-- Folders -->
<xsl:for-each select="Folders/StoredFolder">
<xsl:variable name="thisID">
<xsl:call-template name="VariableID"><xsl:with-param name="value" select="@id"/></xsl:call-template>
</xsl:variable>

<xsl:element name="rim:RegistryPackage">
<xsl:attribute name="id"><xsl:value-of select="$thisID"/></xsl:attribute>
<xsl:if test="@lid!=''">
<xsl:attribute name="lid"><xsl:call-template name="VariableID"><xsl:with-param name="value" select="@lid"/></xsl:call-template></xsl:attribute>
</xsl:if>
<xsl:attribute name="status"><xsl:value-of select="@status"/></xsl:attribute>
<xsl:if test="Title/text()!=''"><rim:Name><xsl:apply-templates mode="LocalizedString" select="Title"/></rim:Name></xsl:if>
<xsl:if test="Comments/text()!=''"><rim:Description><xsl:apply-templates mode="LocalizedString" select="Comments"/></rim:Description></xsl:if>

<xsl:for-each select='CodeList'>
<rim:Classification
id="{isc:evaluate('createID','CodeList')}"
classificationScheme="urn:uuid:1ba97051-7806-41a8-a48b-8fce7af683c5"
classifiedObject="{$thisID}" 
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"
nodeRepresentation="{Code/text()}">
<xsl:if test="Description/text()!=''"><rim:Name><xsl:apply-templates mode="LocalizedString" select="Description"/></rim:Name></xsl:if>
<rim:Slot name="codingScheme">
<rim:ValueList>
<rim:Value><xsl:value-of select='Scheme/text()'/></rim:Value>
</rim:ValueList>
</rim:Slot>
</rim:Classification>
</xsl:for-each>
<rim:ExternalIdentifier 
identificationScheme="urn:uuid:f64ffdf0-4b97-4e06-b79f-a52b38ec2f8a"
value="{PatientId/text()}" 
id="{isc:evaluate('createID','PatientId')}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"
registryObject="{$thisID}">
<rim:Name><xsl:call-template name="LocalizedString"><xsl:with-param name="value" select="'XDSFolder.patientId'"/></xsl:call-template></rim:Name>
</rim:ExternalIdentifier>

<rim:ExternalIdentifier 
id="{isc:evaluate('createID','UniqueId')}"
identificationScheme="urn:uuid:75df8f67-9973-4fbe-a900-df66cefecc5a" 
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"
value="{UniqueId/text()}"
registryObject="{$thisID}">
<rim:Name><xsl:call-template name="LocalizedString"><xsl:with-param name="value" select="'XDSFolder.uniqueId'"/></xsl:call-template></rim:Name>
</rim:ExternalIdentifier>

<rim:Classification 
id="{isc:evaluate('createID','FolderClassification')}"
classifiedObject="{$thisID}" 
classificationNode="urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"/>

</xsl:element>
</xsl:for-each>

<!-- Association: Insert documents into submission set -->
<xsl:for-each select="Associations/StoredAssociation">
<xsl:variable name="parentID">
<xsl:call-template name="VariableID"><xsl:with-param name="value" select="@parent"/></xsl:call-template>
</xsl:variable>
<xsl:variable name="childID">
<xsl:call-template name="VariableID"><xsl:with-param name="value" select="@child"/></xsl:call-template>
</xsl:variable>
<rim:Association
id="{isc:evaluate('createID','association')}"
sourceObject="{$parentID}" 
targetObject="{$childID}" 
associationType="{@type}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association">
<!-- added check for @child=/ProvideAndRegisterRequest/@id for DMP France project -->
<xsl:if test="(($parentID=$submissionSetID) or ($childID=$submissionSetID)) and @type='urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember' ">
<rim:Slot name="SubmissionSetStatus">
<rim:ValueList>
<rim:Value><xsl:choose><xsl:when test="SubmissionSetStatus/text()=''">Original</xsl:when><xsl:otherwise><xsl:value-of select="SubmissionSetStatus/text()"/></xsl:otherwise></xsl:choose></rim:Value>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:if test="PreviousVersion/text()!=''">
<rim:Slot name="PreviousVersion">
<rim:ValueList>
<rim:Value><xsl:value-of select="PreviousVersion/text()"/></rim:Value>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:if test="AssociationPropagation/text()!=''">
<rim:Slot name="AssociationPropagation">
<rim:ValueList>
<rim:Value><xsl:value-of select="AssociationPropagation/text()"/></rim:Value>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:if test="@type='urn:ihe:iti:2010:AssociationType:UpdateAvailabilityStatus'">
<rim:Slot name="NewStatus">
<rim:ValueList>
<rim:Value><xsl:value-of select="@newStatus"/></rim:Value>
</rim:ValueList>
</rim:Slot>
<rim:Slot name="OriginalStatus">
<rim:ValueList>
<rim:Value><xsl:value-of select="@originalStatus"/></rim:Value>
</rim:ValueList>
</rim:Slot>
</xsl:if>

</rim:Association>
</xsl:for-each>
</rim:RegistryObjectList>
</lcm:SubmitObjectsRequest>
</xsl:template>

<xsl:template name="Slot">
<xsl:param name="Name"/>
<xsl:param name="Value"/>

<xsl:if test="$Value!=''">
<rim:Slot name="{$Name}">
<rim:ValueList><rim:Value><xsl:value-of select="$Value"/></rim:Value></rim:ValueList>
</rim:Slot>
</xsl:if>
</xsl:template>

<!-- dual purpose template, value is either the matched node's text for apply-templates, or an explicit string sent as a parameter with call-template -->
<xsl:template name="LocalizedString" mode="LocalizedString" match="*">
<xsl:param name="value" select="text()"/>
<rim:LocalizedString value="{$value}">
<xsl:if test="string-length($lang)>0">
<xsl:attribute name="xml:lang">
<xsl:value-of select="$lang"/>
</xsl:attribute>
</xsl:if>
</rim:LocalizedString>
</xsl:template>

<xsl:template name="VariableID">
<xsl:param name="value"/>
<xsl:if test="string-length($value)=36">
<xsl:value-of select="concat('urn:uuid:',$value)"/>
</xsl:if>
<xsl:if test="string-length($value)!=36">
<xsl:value-of select="$value"/>
</xsl:if>
</xsl:template>

</xsl:stylesheet>

