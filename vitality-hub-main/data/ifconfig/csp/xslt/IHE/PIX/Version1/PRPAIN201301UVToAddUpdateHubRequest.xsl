<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wrapper="http://wrapper.intersystems.com" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="isc wrapper hl7">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:param name="userName"/>
<xsl:param name="userRoles"/>

<!-- we use node because it could be a 201301 or 201302 -->
<xsl:template match="/*[local-name()]">
<xsl:variable name="registrationRoot" select="./hl7:controlActProcess/hl7:subject/hl7:registrationEvent"/>

<xsl:variable name="messageID" select="./hl7:id/@root"/>
<xsl:variable name="messageExtension" select="./hl7:id/@extension"/>
<xsl:variable name="patientRoot" select="./hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient"/>
<xsl:variable name="patientPerson" select="$patientRoot/hl7:patientPerson"/>

<xsl:variable name="patientFirstName" select="$patientPerson/hl7:name[@use='L' or not(@use)]/hl7:given/text()"/>
<xsl:variable name="patientMiddleName" select="$patientPerson/hl7:name[@use='L' or not(@use)]/hl7:given[2]/text()"/>
<xsl:variable name="patientLastName" select="$patientPerson/hl7:name[@use='L' or not(@use)]/hl7:family/text()"/>

<xsl:variable name="patientGender" select="$patientPerson/hl7:administrativeGenderCode/@code"/>
<xsl:variable name="patientBirthTime" select="isc:evaluate('xmltimestamp', ./hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient/hl7:patientPerson/hl7:birthTime/@value)"/>
<xsl:variable name="facilityCode" select="isc:evaluate('OIDtoCode',$patientRoot/hl7:providerOrganization/hl7:id/@root)"/>
<xsl:variable name="facilityName" select="$patientRoot/hl7:providerOrganization/hl7:name/text()"/>
<xsl:variable name="facilityContactPhone" select="$patientRoot/hl7:providerOrganization/hl7:contactParty/hl7:telecom/@value"/>
<xsl:variable name="assigningAuthority" select="isc:evaluate('OIDtoCode',$patientRoot/hl7:id/@root)"/>
<xsl:variable name="assigningAuthorityName" select="$patientRoot/hl7:id/@assigningAuthorityName"/>
<xsl:variable name="patientSSN" select="$patientPerson/hl7:asOtherIDs/hl7:id[@root='2.16.840.1.113883.4.1']/@extension"/>
<xsl:variable name="mrn" select="$patientRoot/hl7:id/@extension"/>
<xsl:variable name="patientTelephone" select="$patientPerson/hl7:telecom/@value"/>
<xsl:variable name="senderDeviceOID" select="isc:evaluate('OIDtoCode',./hl7:sender/hl7:device/hl7:id/@root)"/>
<xsl:variable name="senderDeviceName" select="./hl7:sender/hl7:device/hl7:id/@extension"/>
<xsl:variable name="receiverDeviceOID" select="isc:evaluate('OIDtoCode',./hl7:receiver/hl7:device/hl7:id/@root)"/>
<xsl:variable name="receiverDeviceName" select="./hl7:receiver/hl7:device/hl7:id/@extension"/>

<AddUpdateHubRequest>
<AssigningAuthority><xsl:value-of select="$assigningAuthority"/></AssigningAuthority>
<DOB><xsl:value-of select="$patientBirthTime"/></DOB>
<Facility><xsl:value-of select="$facilityCode"/></Facility>
<Prefix><xsl:value-of select="$patientPerson/hl7:name/hl7:prefix/text()"/></Prefix>
<FirstName><xsl:value-of select="$patientFirstName"/></FirstName>
<LastName><xsl:value-of select="$patientLastName"/></LastName>
<Suffix><xsl:value-of select="$patientPerson/hl7:name/hl7:suffix/text()"/></Suffix>

<Names>
<xsl:for-each select="$patientPerson/hl7:name">
<!-- add Pseudonym -->
<xsl:if test="@use='A'">
<PersonName>
<xsl:apply-templates select="." mode="name"/>
<Type>Alias</Type>
</PersonName>
</xsl:if>
</xsl:for-each>
<xsl:variable name="familyAtBirth" select="$patientPerson/hl7:name/hl7:family[@qualifier='BR']/text()"/>
<xsl:variable name="givenAtBirth" select="$patientPerson/hl7:name/hl7:given[@qualifier='BR']/text()"/>
<xsl:variable name="prefixAtBirth" select="$patientPerson/hl7:name/hl7:prefix[@qualifier='BR']/text()"/>
<xsl:if test="($familyAtBirth!='') or ($givenAtBirth!='') or ($prefixAtBirth!='')">
<PersonName>
<Family><xsl:value-of select="$familyAtBirth"/></Family>
<Given><xsl:value-of select="$givenAtBirth"/></Given>
<Prefix><xsl:value-of select="$prefixAtBirth"/></Prefix>
<Type>Birth</Type>
</PersonName>
</xsl:if>
</Names>

<MRN><xsl:value-of select="$mrn"/></MRN>
<MiddleName><xsl:value-of select="$patientMiddleName"/></MiddleName>
<SSN><xsl:value-of select="$patientSSN"/></SSN>
<Sex><xsl:value-of select="$patientGender"/></Sex>
<Telephone><xsl:value-of select="$patientTelephone"/></Telephone>

<xsl:for-each select="$patientPerson/hl7:personalRelationship">
<xsl:variable name="roleCode" select="hl7:code/@code"/>
<xsl:if test="($roleCode='MTH') or ($roleCode='NMTH') ">
<MothersName>
<xsl:apply-templates select="hl7:relationshipHolder1/hl7:name" mode="name"/>
</MothersName>
</xsl:if>
<xsl:if test="($roleCode='FTH') or ($roleCode='NFTH') or ($roleCode='NFTHF') ">
<FathersName>
<xsl:apply-templates select="hl7:relationshipHolder1/hl7:name" mode="name"/>
</FathersName>
</xsl:if>
<xsl:if test="$roleCode='SPS'">
<SpousesName>
<xsl:apply-templates select="hl7:relationshipHolder1/hl7:name" mode="name"/>
</SpousesName>
</xsl:if>
</xsl:for-each>

<Telecoms>
<xsl:for-each select='$patientPerson/hl7:telecom'>
<Telecom>
<xsl:if test="@use !=''">
<Use><xsl:value-of select="@use"/></Use>
</xsl:if>
<xsl:variable name="phoneNumber">
<xsl:choose>
<xsl:when test="contains(@value,'tel:')">
<xsl:value-of select="substring-after(@value,'tel:')" />
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="@value" />
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<PhoneNumberFull><xsl:value-of select='$phoneNumber'/></PhoneNumberFull>
</Telecom>

</xsl:for-each>
</Telecoms>
<Addresses>
<xsl:for-each select='$patientPerson/hl7:addr'>
<Address>
<xsl:if test="@use !=''"><Use><xsl:value-of select="@use"/></Use></xsl:if>
<StreetLine><xsl:value-of select="hl7:streetAddressLine/text()"/></StreetLine>
<City><xsl:value-of select="hl7:city/text()"/></City>
<State><xsl:value-of select="hl7:state/text()"/></State>
<PostalCode><xsl:value-of select="hl7:postalCode/text()"/></PostalCode>
<Country><xsl:value-of select="hl7:country/text()"/></Country>
</Address>
</xsl:for-each>
</Addresses>

<DoMPIUpdate>1</DoMPIUpdate>
<AddOrUpdate>F</AddOrUpdate>
<xsl:if test='count($patientPerson/hl7:asOtherIDs/hl7:id)!=0'>
<Identifiers>
<xsl:for-each select="$patientPerson/hl7:asOtherIDs">
<xsl:if test="not(hl7:id[@root='2.16.840.1.113883.4.1'])">
<Identifier>
<Root><xsl:value-of select="isc:evaluate('getCodeForOID',hl7:id/@root,'',concat('Unknown OID:',hl7:id/@root))"/></Root>
<Extension><xsl:value-of select="hl7:id/@extension"/></Extension>
<AssigningAuthorityName><xsl:value-of select="isc:evaluate('getCodeForOID',hl7:id/@root,'',concat('Unknown OID:',hl7:id/@root))"/></AssigningAuthorityName>
<!-- <Use> will be set afterward by the PIX Manager Process. -->
</Identifier>
</xsl:if>
</xsl:for-each>
</Identifiers>
</xsl:if>
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="MessageID"><xsl:value-of select="$messageID"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="MessageExtension"><xsl:value-of select="$messageExtension"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="facilityContactPhone"><xsl:value-of select="$facilityContactPhone"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="facilityName"><xsl:value-of select="$facilityName"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="assigningAuthorityName"><xsl:value-of select="$assigningAuthorityName"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="senderDeviceOID"><xsl:value-of select="$senderDeviceOID"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="senderDeviceName"><xsl:value-of select="$senderDeviceName"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="receiverDeviceOID"><xsl:value-of select="$receiverDeviceOID"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="receiverDeviceName"><xsl:value-of select="$receiverDeviceName"/></AdditionalInfoItem>

<!-- prior id -->
<AdditionalInfoItem AdditionalInfoKey="priorID"><xsl:value-of select="$registrationRoot/hl7:replacementOf/hl7:priorRegistration/hl7:subject1/hl7:priorRegisteredRole/hl7:id/@root"/>_<xsl:value-of select="$registrationRoot/hl7:replacementOf/hl7:priorRegistration/hl7:subject1/hl7:priorRegisteredRole/hl7:id/@extension"/></AdditionalInfoItem>

</AdditionalInfo>
</AddUpdateHubRequest>


</xsl:template>
<xsl:template match="*" mode="name">
<Family><xsl:value-of select="hl7:family/text()"/></Family>
<Given><xsl:value-of select="hl7:given/text()"/></Given>
<Middle><xsl:value-of select="hl7:given[2]/text()"/></Middle>
<Prefix><xsl:value-of select="hl7:prefix/text()"/></Prefix>
<Suffix><xsl:value-of select="hl7:suffix/text()"/></Suffix>
</xsl:template>

</xsl:stylesheet>
