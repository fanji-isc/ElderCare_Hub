<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wrapper="http://wrapper.intersystems.com" exclude-result-prefixes="isc wrapper hl7">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:param name="userName"/>
<xsl:param name="userRoles"/>
<xsl:param name="gatewayName"/>
<xsl:param name="nationalPatientIdentifierAA" select="''"/>
<xsl:param name="nationalPatientIdentifierAAoid" select="isc:evaluate('CodetoOID',$nationalPatientIdentifierAA)"/>

<xsl:template match="/hl7:PRPA_IN201305UV02">
<xsl:variable name="parameterList" select="./hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList"/>
<xsl:variable name="assigningAuthority" select="isc:evaluate('OIDtoCode',$parameterList/hl7:livingSubjectId/hl7:value[not(@root='2.16.840.1.113883.4.1')]/@root)"/>
<xsl:variable name="mrn" select="$parameterList/hl7:livingSubjectId/hl7:value[not(@root='2.16.840.1.113883.4.1')]/@extension"/>

<xsl:variable name="sex" select="$parameterList/hl7:livingSubjectAdministrativeGender/hl7:value/@code"/>
<xsl:variable name="lastname" select="$parameterList/hl7:livingSubjectName/hl7:value/hl7:family"/>
<!-- if 'use' attribute appears it is an indication of fuzzy matching -->
<xsl:variable name="nameSRCH" select="$parameterList/hl7:livingSubjectName/hl7:value/@use"/>
<xsl:variable name="firstname" select="$parameterList/hl7:livingSubjectName/hl7:value/hl7:given"/>
<xsl:variable name="patientBirthTime" select="isc:evaluate('xmltimestamp',$parameterList/hl7:livingSubjectBirthTime/hl7:value/@value)"/>
<xsl:variable name="queryID" select="./hl7:controlActProcess/hl7:queryByParameter/hl7:queryId/@root"/>
<xsl:variable name="queryExtension" select="./hl7:controlActProcess/hl7:queryByParameter/hl7:queryId/@extension"/>
<xsl:variable name="initialQuantity" select="./hl7:controlActProcess/hl7:queryByParameter/hl7:initialQuantity/@value"/>
<xsl:variable name="minMatchScore" select="./hl7:controlActProcess/hl7:queryByParameter/hl7:matchCriterionList/hl7:minimumDegreeMatch/hl7:value/@value"/>

<PatientSearchRequest>
<xsl:choose>
<xsl:when test="$nationalPatientIdentifierAA !=''">
<xsl:apply-templates select="./hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList/hl7:livingSubjectId" mode="nationalID"/>
</xsl:when>
<xsl:otherwise>
<DOB><xsl:value-of select="$patientBirthTime"/></DOB>
<Suffix><xsl:value-of select="$parameterList/hl7:livingSubjectName/hl7:value/hl7:suffix"/></Suffix>
<LastName><xsl:value-of select="$lastname"/></LastName>
<MiddleName><xsl:value-of select="$parameterList/hl7:livingSubjectName/hl7:value/hl7:given[2]"/></MiddleName>
<FirstName><xsl:value-of select="$firstname"/></FirstName>
<Prefix><xsl:value-of select="$parameterList/hl7:livingSubjectName/hl7:value/hl7:prefix"/></Prefix>
<Sex><xsl:value-of select="$sex"/></Sex>
<Street><xsl:value-of select="$parameterList/hl7:patientAddress/hl7:value/hl7:streetAddressLine"/></Street>
<City><xsl:value-of select="$parameterList/hl7:patientAddress/hl7:value/hl7:city"/></City>
<State><xsl:value-of select="$parameterList/hl7:patientAddress/hl7:value/hl7:state"/></State>
<Zip><xsl:value-of select="$parameterList/hl7:patientAddress/hl7:value/hl7:postalCode"/></Zip>
<SSN><xsl:value-of select="$parameterList/hl7:livingSubjectId/hl7:value[@root='2.16.840.1.113883.4.1']/@extension"/></SSN>
<AssigningAuthority><xsl:value-of select="$assigningAuthority"/></AssigningAuthority>
<MRN><xsl:value-of select="$mrn"/></MRN>
<MothersMaidenSurname><xsl:value-of select="$parameterList/hl7:mothersMaidenName/hl7:value"/></MothersMaidenSurname>
</xsl:otherwise>
</xsl:choose>
<BreakTheGlass>false</BreakTheGlass>
<RequestingUser><xsl:value-of select="$userName"/></RequestingUser>
<RequestingUserRoles><xsl:value-of select="$userRoles"/></RequestingUserRoles>
<RequestingGateway><xsl:value-of select="$gatewayName"/></RequestingGateway>
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="QueryID"><xsl:value-of select="$queryID"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="QueryExtension"><xsl:value-of select="$queryExtension"/> </AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="MinMatchScore"><xsl:value-of select="$minMatchScore"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="InitialQuantity"><xsl:value-of select="$initialQuantity"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="nameSRCH"><xsl:value-of select="$nameSRCH"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="receiverDeviceOID"><xsl:value-of select="/*[local-name()]/hl7:receiver/hl7:device/hl7:id/@root"/></AdditionalInfoItem>
</AdditionalInfo>

<SearchMode>PIXPDQ</SearchMode>
</PatientSearchRequest>
</xsl:template>

<xsl:template name="ids" match="hl7:livingSubjectId" mode="nationalID">
<xsl:variable name="root" select="hl7:value/@root"/>
<xsl:if test="$root=$nationalPatientIdentifierAAoid">
<Identifiers>
<Identifier>
<Root><xsl:value-of select="$nationalPatientIdentifierAA"/></Root>
<Extension><xsl:value-of select="hl7:value/@extension"/></Extension>
</Identifier>
</Identifiers>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
