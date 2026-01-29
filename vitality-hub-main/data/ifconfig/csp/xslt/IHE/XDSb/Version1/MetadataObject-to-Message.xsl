<?xml version="1.0" encoding="UTF-8"?>
<!-- *** This transform is not intended to be called or extended and may change at any time without notice *** -->
<!-- 

Convert XDSb metadata into a XDSb Provide or XDSb Register message
REMEMBER: Sequence matters - objects (slots, classifications, IDs), associations, ObjectRefs
-->
<xsl:stylesheet 
version="1.0" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007" 
xmlns:xop="http://www.w3.org/2004/08/xop/include" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:include href="Variables.xsl"/>

<xsl:param name="messageName" select='/Metadata/Name/text()'/>
<xsl:param name="soapAction"/>
<xsl:param name="serviceName"/>
<xsl:param name="queryType"/>
<xsl:param name="queryReturnType" select="'LeafClass'"/>

<xsl:template match="/Metadata">
<xsl:choose>
<xsl:when test="$messageName = $xdsbProvideAndRegisterRequest">
<xsl:apply-templates mode="xdsbProvideAndRegisterRequest" select="."/>
</xsl:when>
<xsl:when test="$messageName = $xdsbProvideAndRegisterResponse">
<xsl:apply-templates mode="xdsbProvideAndRegisterResponse" select="."/>
</xsl:when>
<xsl:when test="$messageName = $xdsbRegisterRequest">
<xsl:apply-templates mode="lcmSubmitObjectsRequest" select="."/>
</xsl:when>
<xsl:when test="$messageName = $xdsbRegisterOnDemandRequest">
<xsl:apply-templates mode="lcmSubmitObjectsRequest" select="."/>
</xsl:when>
<xsl:when test="$messageName = $xdsbRetrieveResponse">
<xsl:apply-templates mode="xdsbRetrieveResponse" select="."/>
</xsl:when>
<xsl:when test="$messageName = $xdsbQueryRequest">
<xsl:apply-templates mode="xdsbQueryRequest" select="."/>
</xsl:when>
<xsl:when test="$messageName = 'XDM_DistributeDocumentSetOnMediaRequest'">
<xsl:apply-templates mode="lcmSubmitObjectsRequest" select="."/>
</xsl:when>
<xsl:otherwise>
Error: Message <xsl:value-of select="$messageName"/> not supported.
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="Errors">
</xsl:template>

<xsl:template mode="xdsbProvideAndRegisterRequest" match="Metadata">
<xdsb:ProvideAndRegisterDocumentSetRequest>
<xsl:apply-templates mode="lcmSubmitObjectsRequest" select="."/>
<xsl:apply-templates mode="xopDocument" select="Document"/>
</xdsb:ProvideAndRegisterDocumentSetRequest>
</xsl:template>

<xsl:template mode="xdsbProvideAndRegisterResponse" match="*">
<xsl:variable name="highestError">
<xsl:choose>
<xsl:when test="Errors/HighestError/text()='Error'"><xsl:value-of select="$error"/></xsl:when>
<xsl:when test="Errors/HighestError/text()='Warning'"><xsl:value-of select="$warning"/></xsl:when>
</xsl:choose>
</xsl:variable>

<xsl:variable name="status">
<xsl:choose>
<xsl:when test="$highestError=$error"><xsl:value-of select="$failure"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$success"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>

<RegistryResponse xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" status="{$status}">
<xsl:if test="Errors/Error">
<rs:RegistryErrorList highestSeverity="{$highestError}">
<xsl:for-each select="Errors/Error">
<xsl:variable name="severity">
<xsl:choose>
<xsl:when test="Severity/text()='Error'"><xsl:value-of select="$error"/></xsl:when>
<xsl:when test="Severity/text()='Warning'"><xsl:value-of select="$warning"/></xsl:when>
</xsl:choose>
</xsl:variable>
<rs:RegistryError codeContext="{Description/text()}" errorCode="{Code/text()}" location="{Location/text()}" severity="{$severity}"/>
</xsl:for-each>
</rs:RegistryErrorList>
</xsl:if>
</RegistryResponse>
</xsl:template>


<xsl:template mode="xdsbRetrieveResponse" match="*">
<xsl:variable name="highestError">
<xsl:choose>
<xsl:when test="Errors/HighestError/text()='Error'"><xsl:value-of select="$error"/></xsl:when>
<xsl:when test="Errors/HighestError/text()='Warning'"><xsl:value-of select="$warning"/></xsl:when>
</xsl:choose>
</xsl:variable>

<xsl:variable name="status">
<xsl:choose>
<xsl:when test="not(//Document)"><xsl:value-of select="$failure"/></xsl:when>
<xsl:when test="$highestError=$error"><xsl:value-of select="$partial"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$success"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xdsb:RetrieveDocumentSetResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<rs:RegistryResponse status="{$status}"> 
<xsl:if test="Errors/Error or not(//Document)">
<rs:RegistryErrorList highestSeverity="{$highestError}">
<xsl:for-each select="Errors/Error">
<xsl:variable name="severity">
<xsl:choose>
<xsl:when test="Severity/text()='Error'"><xsl:value-of select="$error"/></xsl:when>
<xsl:when test="Severity/text()='Warning'"><xsl:value-of select="$warning"/></xsl:when>
</xsl:choose>
</xsl:variable>
<rs:RegistryError codeContext="{Description/text()}" errorCode="{Code/text()}" location="{Location/text()}" severity="{$severity}"/>
</xsl:for-each>
<xsl:if test="not(//Document)">
<rs:RegistryError codeContext="No documents generated" errorCode="XDSbRepository" location="" severity="{$error}"/>
</xsl:if>
</rs:RegistryErrorList>
</xsl:if>
</rs:RegistryResponse>

<xsl:for-each select="Document">
<xdsb:DocumentResponse>
<xsl:if test="@home"><xdsb:HomeCommunityId><xsl:value-of select="@home"/></xdsb:HomeCommunityId></xsl:if>
<xdsb:RepositoryUniqueId><xsl:value-of select="RepositoryUniqueId/text()"/></xdsb:RepositoryUniqueId> 
<xdsb:DocumentUniqueId><xsl:value-of select="DocumentUniqueIdentifier/Value/text()"/></xdsb:DocumentUniqueId> 
<xsl:choose>
<xsl:when test="Snapshot">
<xdsb:NewDocumentUniqueId><xsl:value-of select="Snapshot/UniqueId/text()"/></xdsb:NewDocumentUniqueId>
<xsl:if test="Snapshot/RepositoryUniqueId">
<!-- only return repository if document was persisted -->
<xdsb:NewRepositoryUniqueId><xsl:value-of select="Snapshot/RepositoryUniqueId/text()"/></xdsb:NewRepositoryUniqueId>
</xsl:if>
<xdsb:mimeType><xsl:value-of select="Snapshot/MimeType/text()"/></xdsb:mimeType> 
<xdsb:Document>
<xop:Include xmlns="http://www.w3.org/2004/08/xop/include" xmlns:xop="http://www.w3.org/2004/08/xop/include" href="{concat('cid:',Snapshot/@id)}" /> 
</xdsb:Document>
</xsl:when>
<xsl:otherwise>
<xdsb:mimeType><xsl:value-of select="MimeType/text()"/></xdsb:mimeType> 
<xdsb:Document>
<xop:Include xmlns="http://www.w3.org/2004/08/xop/include" xmlns:xop="http://www.w3.org/2004/08/xop/include" href="{concat('cid:',@id)}" /> 
</xdsb:Document>
</xsl:otherwise>
</xsl:choose>
</xdsb:DocumentResponse>
</xsl:for-each>
</xdsb:RetrieveDocumentSetResponse>
</xsl:template>

<xsl:template mode="lcmSubmitObjectsRequest" match="Metadata">
<lcm:SubmitObjectsRequest>
<rim:RegistryObjectList>
<xsl:apply-templates mode="rimExtrinsicObject" select="Document"/>
<xsl:apply-templates mode="rimRegistryPackage" select="Submission"/>
<xsl:apply-templates mode="rimRegistryPackage" select="Folder"/>
<xsl:apply-templates mode="rimAssociation" select="Association"/>
<xsl:apply-templates mode="rimObjectRef" select="ObjectRef"/>
<!-- workaround for orion, which needs this classification in the list, not the submission package 
<xsl:call-template name="isSubmission"/>
-->
</rim:RegistryObjectList>
</lcm:SubmitObjectsRequest>
</xsl:template>

<xsl:template mode="rimExtrinsicObject" match="Document">
<rim:ExtrinsicObject id="{@id}" mimeType="{MimeType/text()}">
<xsl:if test="@lid">
<xsl:attribute name="lid">
<xsl:value-of select="@lid"/>
</xsl:attribute>
</xsl:if>
<xsl:if test="@home">
<xsl:attribute name="home">
<xsl:value-of select="@home"/>
</xsl:attribute>
</xsl:if>

<xsl:apply-templates mode="rimObjectType" select="."/>
<xsl:apply-templates mode="rimStatus" select="AvailabilityStatus"/>

<xsl:apply-templates mode="rimSlotFromField" select="CreationTime"/>
<xsl:apply-templates mode="rimSlotFromField" select="LanguageCode"/>
<xsl:apply-templates mode="rimSlotFromField" select="ServiceStartTime"/>
<xsl:apply-templates mode="rimSlotFromField" select="ServiceStopTime"/>
<xsl:apply-templates mode="rimSlotFromField" select="LegalAuthenticator"/>
<xsl:apply-templates mode="rimSlotFromField" select="SourcePatientId"/>
<xsl:apply-templates mode="rimSlotFromField" select="Size"/>
<xsl:apply-templates mode="rimSlotFromField" select="Hash"/>
<xsl:apply-templates mode="rimSlotFromField" select="SourcePatientInfo"/>
<xsl:apply-templates mode="rimSlotFromField" select="RepositoryUniqueId"/>
<xsl:if test="Availability">
<rim:Slot name="documentAvailability">
<rim:ValueList>
<rim:Value><xsl:value-of select="Availability/text()"/></rim:Value>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:if test="URI">
<rim:Slot name="URI">
<rim:ValueList>
<rim:Value><xsl:value-of select="URI/text()"/></rim:Value>
</rim:ValueList>
</rim:Slot>
</xsl:if>
<xsl:apply-templates select="Slot" mode="rimSlot"/>
<xsl:apply-templates mode="rimName" select="Name"/>
<xsl:apply-templates mode="rimDescription" select="Description"/>
<xsl:if test="Version/text()!=''">
<rim:VersionInfo versionName="{Version/text()}"/>
</xsl:if>

<xsl:apply-templates mode="rimClassification" select="ClassCode"/>
<xsl:apply-templates mode="rimClassification" select="ConfidentialityCode"/>
<xsl:apply-templates mode="rimClassification" select="FormatCode"/>
<xsl:apply-templates mode="rimClassification" select="HealthCareFacilityTypeCode"/>
<xsl:apply-templates mode="rimClassification" select="PracticeSettingCode"/>
<xsl:apply-templates mode="rimClassification" select="TypeCode"/>
<xsl:apply-templates mode="rimClassification" select="EventCodeList"/>

<xsl:apply-templates mode="genericClassification" select="Classification"/>
<xsl:apply-templates mode="rimAuthor" select="Author"/>

<!-- XDM does not require patient identifier -->
<xsl:if test="string-length(PatientIdentifier/Value/text())">
<xsl:apply-templates mode="rimExternalIdentifier" select="PatientIdentifier"/>
</xsl:if>
<xsl:apply-templates mode="rimExternalIdentifier" select="DocumentUniqueIdentifier"/>
<xsl:apply-templates mode="genericExternalIdentifiers" select="ExternalIdentifier"/>

</rim:ExtrinsicObject>
</xsl:template>

<xsl:template mode="rimRegistryPackage" match="Submission">
<rim:RegistryPackage id="{@id}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:RegistryPackage">
<xsl:apply-templates mode="rimSlotFromField" select="SubmissionTime"/>
<xsl:apply-templates mode="rimSlotFromField" select="IntendedRecipient"/>
<xsl:apply-templates mode="rimName" select="Name"/>
<xsl:apply-templates mode="rimDescription" select="Description"/>
<xsl:apply-templates mode="rimClassification" select="ContentTypeCode"/>
<xsl:apply-templates mode="genericClassification" select="Classification"/>
<xsl:apply-templates mode="rimAuthor" select="Author"/>
<!-- XDM does not require patient identifier -->
<xsl:if test="string-length(PatientIdentifier/Value/text())">
<xsl:apply-templates mode="rimExternalIdentifier" select="PatientIdentifier"/>
</xsl:if>
<xsl:apply-templates mode="rimExternalIdentifier" select="UniqueIdentifier"/>
<xsl:apply-templates mode="rimExternalIdentifier" select="SourceIdentifier"/>
<xsl:apply-templates mode="genericExternalIdentifiers" select="ExternalIdentifier"/>
</rim:RegistryPackage>
<xsl:apply-templates mode="isSubmission" select="."/>
</xsl:template>

<!-- added so we can put this classification inside or outside the reg pkg into the reg object list -->
<xsl:template name="isSubmission" mode='isSubmission' match="Submission">
<rim:Classification
id="{isc:evaluate('createID','isSS')}"
classifiedObject="{@id}"
classificationNode="urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd"
 objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"/>
</xsl:template>

<xsl:template mode="rimRegistryPackage" match="Folder">
<rim:RegistryPackage id="{@id}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:RegistryPackage">
<xsl:if test="@lid !=''">
<xsl:attribute name="lid"><xsl:value-of select="@lid"/></xsl:attribute>
</xsl:if>

<xsl:apply-templates mode="rimName" select="Name"/>
<xsl:apply-templates mode="rimDescription" select="Description"/>
<xsl:apply-templates mode="rimClassification" select="CodeList"/>
<xsl:apply-templates mode="genericClassification" select="Classification"/>
<rim:Classification 
id="{isc:evaluate('createID','isFolder')}"
classifiedObject="{concat('urn:uuid:',EntryUUID/text())}"
classificationNode="urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2" 
 objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"/>
<xsl:apply-templates mode="rimExternalIdentifier" select="PatientId"/>
<xsl:apply-templates mode="rimExternalIdentifier" select="UniqueId"/>
<xsl:apply-templates mode="genericExternalIdentifiers" select="ExternalIdentifier"/>
</rim:RegistryPackage>
</xsl:template>

<xsl:template mode="rimAssociation" match="Association">
<rim:Association
associationType="{@type}"
id="{@id}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association"
sourceObject="{@sourceObject}" 
targetObject="{@targetObject}">
<xsl:apply-templates select="Classification" mode="genericClassification"/>
<xsl:apply-templates select="Slot" mode="rimSlot"/>
</rim:Association>

</xsl:template>

<xsl:template mode="rimObjectRef" match="ObjectRef">
<rim:ObjectRef id="{@id}"/>
</xsl:template>

<!-- XOP document content pointer(s) -->
<xsl:template mode="xopDocument" match="Document">
<xsl:choose>
<xsl:when test="string-length(Body/text())">
<xdsb:Document id="{@id}">
<xsl:value-of select="Body/text()"/>
</xdsb:Document>
</xsl:when>
<xsl:when test="string-length(XOP)=0">
<xdsb:Document id="{@id}">
<xop:Include xmlns="http://www.w3.org/2004/08/xop/include" xmlns:xop="http://www.w3.org/2004/08/xop/include" href="{concat('cid:',@id)}" /> 
</xdsb:Document>
</xsl:when>
<xsl:otherwise>
<xdsb:Document id="{@id}">
<xop:Include xmlns="http://www.w3.org/2004/08/xop/include" xmlns:xop="http://www.w3.org/2004/08/xop/include" href="{XOP}" /> 
</xdsb:Document>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template mode="rimSlotFromField" match="*">
<xsl:param name="localname" select="concat(translate(substring(local-name(),1,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'	),substring(local-name(),2))"/>
<rim:Slot name="{$localname}"> 
<rim:ValueList>
<xsl:choose>
<xsl:when test="Value">
<xsl:for-each select="Value">
<rim:Value><xsl:value-of select="text()"/></rim:Value> 
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<rim:Value><xsl:value-of select="text()"/></rim:Value> 
</xsl:otherwise>
</xsl:choose>
</rim:ValueList> 
</rim:Slot>
</xsl:template>

<!-- Generic <Slot> element generator -->
<xsl:template mode="rimSlot" match="*">
<xsl:param name="localname" select="concat(translate(substring(local-name(),1,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'	),substring(local-name(),2))"/>
<rim:Slot name="{@name}"> 
<rim:ValueList>
<xsl:choose>
<xsl:when test="ValueList">
<xsl:for-each select="ValueList/Value">
<rim:Value><xsl:value-of select="text()"/></rim:Value> 
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<rim:Value><xsl:value-of select="text()"/></rim:Value> 
</xsl:otherwise>
</xsl:choose>
</rim:ValueList> 
</rim:Slot>
</xsl:template>

<!-- Generic <Classification> element generator -->
<xsl:template mode="rimClassification" match="*">
<xsl:if test="Code">
<xsl:variable name="thisID">
<xsl:choose>
<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
<xsl:otherwise><xsl:value-of select="isc:evaluate('createID',concat('x',local-name()))"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:element name="rim:Classification">
<xsl:attribute name="classificationScheme">
<xsl:choose>
<xsl:when test="local-name() = 'ClassCode'">urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a</xsl:when>
<xsl:when test="local-name() = 'ConfidentialityCode'">urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f</xsl:when>
<xsl:when test="local-name() = 'ContentTypeCode'">urn:uuid:aa543740-bdda-424e-8c96-df4873be8500</xsl:when>
<xsl:when test="local-name() = 'EventCodeList'">urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4</xsl:when>
<xsl:when test="local-name() = 'FormatCode'">urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d</xsl:when>
<xsl:when test="local-name() = 'HealthCareFacilityTypeCode'">urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1</xsl:when>
<xsl:when test="local-name() = 'TypeCode'">urn:uuid:f0306f51-975f-434e-a61c-c59651d33983</xsl:when>
<xsl:when test="local-name() = 'PracticeSettingCode'">urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead</xsl:when>
<xsl:when test="local-name() = 'CodeList'">urn:uuid:1ba97051-7806-41a8-a48b-8fce7af683c5</xsl:when>
</xsl:choose>
</xsl:attribute>
<xsl:attribute name="classifiedObject"><xsl:value-of select="../@id"/></xsl:attribute>
<xsl:attribute name="id"><xsl:value-of select="$thisID"/></xsl:attribute>
<xsl:attribute name="nodeRepresentation"><xsl:value-of select="Code/text()"/></xsl:attribute>
<xsl:attribute name="objectType">urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification</xsl:attribute>

<xsl:apply-templates mode="rimSlotFromField" select="CodingScheme"/>
<xsl:apply-templates mode="rimName" select="Name"/>
<xsl:apply-templates mode="rimDescription" select="Description"/>
</xsl:element>
</xsl:if>
</xsl:template>

<!-- Specialized version of the rimClassification generator for authors -->
<xsl:template mode="rimAuthor" match="Author">
<xsl:element name="rim:Classification">
<xsl:attribute name="id">
<xsl:choose>
<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
<xsl:otherwise><xsl:value-of select="isc:evaluate('createID',concat('x',local-name()))"/></xsl:otherwise>
</xsl:choose>
</xsl:attribute>
<xsl:attribute name="nodeRepresentation"/>
<xsl:attribute name="objectType">urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification</xsl:attribute>
<xsl:attribute name="classifiedObject"><xsl:value-of select="../@id"/></xsl:attribute>
<xsl:attribute name="classificationScheme">
<xsl:choose>
<xsl:when test="local-name(..) = 'Submission'">urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d</xsl:when>
<xsl:otherwise>urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d</xsl:otherwise>
</xsl:choose>                                                
</xsl:attribute>
<xsl:apply-templates mode="rimSlotFromField" select="AuthorPerson"/>
<xsl:apply-templates mode="rimSlotFromField" select="AuthorTelecommunication"/>
<xsl:apply-templates mode="rimSlotFromField" select="AuthorInstitution"/>
<xsl:apply-templates mode="rimSlotFromField" select="AuthorRole"/>
<xsl:apply-templates mode="rimSlotFromField" select="AuthorSpecialty"/>
</xsl:element>
</xsl:template>

<xsl:template match="Classification" mode="genericClassification">
<rim:Classification>
<xsl:attribute name="id">
<xsl:choose>
<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
<xsl:otherwise><xsl:value-of select="isc:evaluate('createID',concat('x',local-name()))"/></xsl:otherwise>
</xsl:choose>
</xsl:attribute>
<xsl:attribute name="nodeRepresentation"><xsl:value-of select="Code/text()"/></xsl:attribute>
<xsl:attribute name="classificationScheme"><xsl:value-of select="ClassificationScheme/text()"/></xsl:attribute>
<xsl:attribute name="classifiedObject"><xsl:value-of select="../@id"/></xsl:attribute>
<xsl:attribute name="objectType">urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification</xsl:attribute>

<rim:Slot name="codingScheme">
<rim:ValueList>
<rim:Value><xsl:value-of select="CodingScheme/text()"/></rim:Value>
</rim:ValueList>
</rim:Slot>
<xsl:apply-templates select="Name" mode="rimName"/>
<xsl:apply-templates select="Description" mode="rimDescription"/>
<xsl:apply-templates select="Slot" mode="genericSlotsNoCodingScheme"/>
</rim:Classification>
</xsl:template>

<xsl:template match="ExternalIdentifier" mode="genericExternalIdentifiers">
<rim:ExternalIdentifier>
<xsl:attribute name="id">
<xsl:choose>
<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
<xsl:otherwise><xsl:value-of select="isc:evaluate('createID',concat('x',local-name()))"/></xsl:otherwise>
</xsl:choose>
</xsl:attribute>
<xsl:attribute name="objectType">urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier</xsl:attribute>
<xsl:attribute name="registryObject"><xsl:value-of select="../@id"/></xsl:attribute>
<xsl:attribute name="value"><xsl:value-of select="Value/text()"/></xsl:attribute>
<xsl:attribute name="identificationScheme"><xsl:value-of select="IdentificationScheme/text()"/></xsl:attribute>
<xsl:apply-templates mode="rimName" select="Name"/>
<xsl:apply-templates mode="rimDescription" select="Description"/>
</rim:ExternalIdentifier>
</xsl:template>

<!-- copy Generic Slots but don't move one named codingScheme -->
<xsl:template match="Slot" mode="genericSlotsNoCodingScheme">
<xsl:if test="@name !='codingScheme'">
<xsl:apply-templates select="." mode="genericSlot"/>
</xsl:if>
</xsl:template>

<xsl:template match="Slot" mode="genericSlot">
<rim:Slot name="{@name}">
<rim:ValueList>
<xsl:for-each select="ValueList/Value">
<rim:Value>
<xsl:value-of select="text()"/>
</rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:template>


<xsl:template mode="rimObjectType" match="Document">
<xsl:attribute name="objectType">
<xsl:choose>
<xsl:when test="@type='OnDemand'">
<xsl:value-of select="'urn:uuid:34268e47-fdf5-41a6-ba33-82133c465248'"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="'urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:attribute>
</xsl:template>

<xsl:template mode="rimStatus" match="AvailabilityStatus">
<xsl:attribute name="status">
<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:StatusType:',text())"/>
</xsl:attribute>
</xsl:template>

<xsl:template mode="rimLocalizedString" match="*">
<rim:LocalizedString>
<xsl:if test="@Charset">
<xsl:attribute name="charset">
<xsl:value-of select="@Charset"/>
</xsl:attribute>
</xsl:if>
<xsl:if test="@Lang">
<xsl:attribute name="xml:lang">
<xsl:value-of select="@Lang"/>
</xsl:attribute>
</xsl:if>
<xsl:attribute name="value">
<xsl:value-of select="text()"/>
</xsl:attribute>
</rim:LocalizedString>
</xsl:template>

<xsl:template mode="rimName" match="*">
<xsl:if test="text()">
<rim:Name>
<xsl:apply-templates select="." mode="rimLocalizedString"/>
</rim:Name>
</xsl:if>
</xsl:template>

<xsl:template mode="rimDescription" match="*">
<xsl:if test="text()">
<rim:Description>
<xsl:apply-templates select="." mode="rimLocalizedString"/>
</rim:Description>
</xsl:if>
</xsl:template>

<xsl:template mode="rimString" match="*">
<rim:LocalizedString value="{text()}"/>
</xsl:template>

<xsl:template mode="rimExternalIdentifier" match="*">
<xsl:variable name='thisID'>
<xsl:choose>
<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
<xsl:otherwise><xsl:value-of select="isc:evaluate('createID','xid')"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<rim:ExternalIdentifier 
id="{$thisID}"
objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"
registryObject="{../@id}"
value="{Value/text()}">

<xsl:choose>
<xsl:when test="local-name(..) = 'Document'">
<xsl:choose>
<xsl:when test="local-name() = 'PatientIdentifier'">
<xsl:attribute name="identificationScheme">urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427</xsl:attribute>
<rim:Name><rim:LocalizedString value="XDSDocumentEntry.patientId"/></rim:Name>
</xsl:when>
<xsl:when test="local-name() = 'DocumentUniqueIdentifier'">
<xsl:attribute name="identificationScheme">urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab</xsl:attribute>
<rim:Name><rim:LocalizedString value="XDSDocumentEntry.uniqueId"/></rim:Name>
</xsl:when>
</xsl:choose>
</xsl:when>
<xsl:when test="local-name(..) = 'Folder'">
<xsl:choose>
<xsl:when test="local-name() = 'PatientIdentifier'">
<xsl:attribute name="identificationScheme">urn:uuid:f64ffdf0-4b97-4e06-b79f-a52b38ec2f8a</xsl:attribute>
<rim:Name><rim:LocalizedString value="XDSFolder.patientId"/></rim:Name>
</xsl:when>
<xsl:when test="local-name() = 'UniqueIdentifier'">
<xsl:attribute name="identificationScheme">urn:uuid:75df8f67-9973-4fbe-a900-df66cefecc5a</xsl:attribute>
<rim:Name><rim:LocalizedString value="XDSFolder.uniqueId"/></rim:Name>
</xsl:when>
</xsl:choose>
</xsl:when>
<xsl:when test="local-name(..) = 'Submission'">
<xsl:choose>
<xsl:when test="local-name() = 'PatientIdentifier'">
<xsl:attribute name="identificationScheme">urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446</xsl:attribute>
<rim:Name><rim:LocalizedString value="XDSSubmissionSet.patientId"/></rim:Name>
</xsl:when>
<xsl:when test="local-name() = 'UniqueIdentifier'">
<xsl:attribute name="identificationScheme">urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8</xsl:attribute>
<rim:Name><rim:LocalizedString value="XDSSubmissionSet.uniqueId"/></rim:Name>
</xsl:when>
<xsl:when test="local-name() = 'SourceIdentifier'">
<xsl:attribute name="identificationScheme">urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832</xsl:attribute>
<rim:Name><rim:LocalizedString value="XDSSubmissionSet.sourceId"/></rim:Name>
</xsl:when>
</xsl:choose>
</xsl:when>
</xsl:choose>

</rim:ExternalIdentifier>
</xsl:template>

<xsl:template mode="xdsbQueryRequest" match="Metadata">
<query:AdhocQueryRequest>
<query:ResponseOption returnComposedObjects="true" returnType="{$queryReturnType}"/>

<rim:AdhocQuery id="{$queryType}" xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0">
<xsl:if test="Document[1]/@home">
<xsl:attribute name="home"><xsl:value-of select="Document[1]/@home"/></xsl:attribute>
</xsl:if>

<!-- Add filter for each document with a UUID -->
<xsl:if test="Document[@id]">
<rim:Slot name="$XDSDocumentEntryEntryUUID">
<rim:ValueList>
<xsl:for-each select="Document[@id]">
<rim:Value>('<xsl:value-of select="@id"/>')</rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>

<!-- Add filter for each document without a UUID but with a UniqueId -->
<xsl:if test="Document[not(@id) and UniqueId/text()]">
<rim:Slot name="$XDSDocumentEntryUniqueId">
<rim:ValueList>
<xsl:for-each select="Document[not(@id) and UniqueId/text()]">
<rim:Value>('<xsl:value-of select="UniqueId/text()"/>')</rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>

</rim:AdhocQuery>
</query:AdhocQueryRequest>
</xsl:template>
</xsl:stylesheet>
