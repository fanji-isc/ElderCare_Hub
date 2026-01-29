<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:hl7="urn:hl7-org:v3" xmlns:isc="http://extension-functions.intersystems.com" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" version="1.0" xmlns:wrapper="http://wrapper.intersystems.com" xmlns:ihe="urn:ihe:iti:xds-b:2007" exclude-result-prefixes="wrapper isc hl7 ihe query rim">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:param name="MessageType"/>
<xsl:template match="/">
<PatientSearchResponse>
<Results>
<xsl:apply-templates select="hl7:PRPA_IN201306UV02/hl7:controlActProcess/hl7:subject/hl7:registrationEvent"/>
</Results>
<xsl:if test="hl7:PRPA_IN201306UV02/hl7:acknowledgement/hl7:typeCode/@code!='AA'">
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="ErrStatusText"><xsl:value-of select="hl7:PRPA_IN201306UV02/hl7:acknowledgement/hl7:acknowledgementDetail[@typeCode='E']/hl7:text/text()"/></AdditionalInfoItem>
</AdditionalInfo>
</xsl:if>
<xsl:if test="hl7:PRPA_IN201306UV02/hl7:controlActProcess/hl7:queryAck/hl7:resultRemainingQuantity/@value">
<xsl:variable name="total"><xsl:value-of select="hl7:PRPA_IN201306UV02/hl7:controlActProcess/hl7:queryAck/hl7:resultTotalQuantity/@value"/></xsl:variable>
<xsl:variable name="remaining"><xsl:value-of select="hl7:PRPA_IN201306UV02/hl7:controlActProcess/hl7:queryAck/hl7:resultRemainingQuantity/@value"/></xsl:variable>
<xsl:if test="(number($remaining))>0">
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="ContinuationPointer"><xsl:value-of select="((number($total)-number($remaining))+1)"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="OriginalQueryID"><xsl:value-of select="hl7:PRPA_IN201306UV02/hl7:controlActProcess/hl7:queryAck/hl7:queryId/@root"/></AdditionalInfoItem>
</AdditionalInfo>
</xsl:if>
</xsl:if>
</PatientSearchResponse>

</xsl:template>

<xsl:template match="hl7:PRPA_IN201306UV02/hl7:controlActProcess/hl7:subject/hl7:registrationEvent">
<xsl:variable name="custodian" select="isc:evaluate('OIDtoCode',hl7:custodian/hl7:assignedEntity/hl7:id/@root)"/>

<xsl:for-each select="hl7:subject1/hl7:patient">
<PatientSearchMatch>
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="Custodian"><xsl:value-of select="$custodian"/></AdditionalInfoItem>
</AdditionalInfo>
<xsl:variable name="patientRoot" select="."/>
<xsl:variable name="personRoot" select="$patientRoot/hl7:patientPerson"/>

<Identifiers>
<xsl:for-each select="hl7:id">
<Identifier>
<Root><xsl:value-of select="isc:evaluate('OIDtoCode',@root)"/></Root>
<Extension><xsl:value-of select="@extension"/></Extension>
</Identifier>
</xsl:for-each>
<xsl:for-each select="hl7:patientPerson/hl7:asOtherIDs/hl7:id">
<xsl:if test="@root != '2.16.840.1.113883.4.1'">
<Identifier>
<Root><xsl:value-of select="isc:evaluate('OIDtoCode',@root)"/></Root>
<Extension><xsl:value-of select="@extension"/></Extension>
</Identifier>
</xsl:if>
</xsl:for-each>
</Identifiers>
<xsl:if test="string-length(hl7:patientPerson/hl7:asOtherIDs/hl7:id[@root='2.16.840.1.113883.4.1']/@extension)">
<SSN><xsl:value-of select="hl7:patientPerson/hl7:asOtherIDs/hl7:id[@root='2.16.840.1.113883.4.1']/@extension"/></SSN>
</xsl:if>
<Telecoms>
<xsl:for-each select='$personRoot/hl7:telecom'>
<Telecom>
<xsl:if test="@use !=''"><xsl:attribute name="use"><xsl:value-of select="@use"/></xsl:attribute></xsl:if>
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

<Facility><xsl:value-of select="isc:evaluate('OIDtoCode',$patientRoot/hl7:providerOrganization/hl7:id/@root)"/></Facility>

<xsl:for-each select="hl7:id">

<Prefix><xsl:value-of select="$personRoot/hl7:name/hl7:prefix/text()"/></Prefix>
<LastName><xsl:value-of select="$personRoot/hl7:name/hl7:family"/></LastName>
<FirstName><xsl:value-of select="$personRoot/hl7:name/hl7:given[1]"/></FirstName>
<MiddleName><xsl:value-of select="$personRoot/hl7:name/hl7:given[2]"/></MiddleName>
<Suffix><xsl:value-of select="$personRoot/hl7:name/hl7:suffix/text()"/></Suffix>
<DOB><xsl:value-of select="isc:evaluate('xmltimestamp',$personRoot/hl7:birthTime/@value)"/></DOB>
<Sex><xsl:value-of select="$personRoot/hl7:administrativeGenderCode/@code"/></Sex>

<Addresses>
<xsl:for-each select='$personRoot/hl7:addr'>
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
</xsl:for-each>

<xsl:for-each select='$personRoot/hl7:personalRelationship'> 
<xsl:variable name="relationshipType" select="hl7:code/@code"/>
<xsl:choose>
<xsl:when test="$relationshipType = 'MTH' or ($relationshipType='NMTH') or ($relationshipType='NMTHF') or ($relationshipType='ADOPTM') or ($relationshipType='STPMTH')">
<MothersName>
<xsl:apply-templates select="hl7:relationshipHolder1/hl7:name"/>
</MothersName>
</xsl:when> 
<xsl:when test="($relationshipType = 'FTH') or ($relationshipType='ADOPTF') or ($relationshipType='NFTH') or ($relationshipType='NFTHF') or ($relationshipType='STPFTH')">
<FathersName>
<xsl:apply-templates select="hl7:relationshipHolder1/hl7:name"/>
</FathersName>
</xsl:when> 
</xsl:choose> 
</xsl:for-each> 

<xsl:choose>
<xsl:when test="string-length(hl7:subjectOf1/hl7:queryMatchObservation[hl7:code/@code='IHE_PDQ']/hl7:value/@value)">
<RankOrScore><xsl:value-of select="hl7:subjectOf1/hl7:queryMatchObservation[hl7:code/@code='IHE_PDQ']/hl7:value/@value"/></RankOrScore>
</xsl:when>
<!-- This condition is considered invalid by Connectathon. However since it has been seen in examples, it is provided for here. -->
<xsl:when test="string-length(hl7:subjectOf1/hl7:queryMatchObservation[hl7:code/@code='IHE_PDQ']/hl7:value/text())">
<RankOrScore><xsl:value-of select="hl7:subjectOf1/hl7:queryMatchObservation[hl7:code/@code='IHE_PDQ']/hl7:value/text()"/></RankOrScore>
</xsl:when>
</xsl:choose>

</PatientSearchMatch>

</xsl:for-each>
</xsl:template>

<xsl:template name="name" match="hl7:name">
<Prefix><xsl:value-of select="hl7:prefix/text()"/></Prefix>
<Given><xsl:value-of select="hl7:given/text()"/></Given>
<Family><xsl:value-of select="hl7:family/text()"/></Family>
<Suffix><xsl:value-of select="hl7:suffix/text()"/></Suffix>
</xsl:template>

</xsl:stylesheet>