<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" 
	xmlns:isc="http://extension-functions.intersystems.com" version="1.0" exclude-result-prefixes="isc hl7">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:template match="/">
<PatientSearchResponse>
<Results>
<xsl:apply-templates select="hl7:PRPA_IN201310UV02/hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1"/>
</Results>
<xsl:if test="hl7:PRPA_IN201310UV02/hl7:acknowledgement/hl7:typeCode/@code!='AA'">
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="ErrStatusText"><xsl:value-of select="hl7:PRPA_IN201310UV02/hl7:acknowledgement/hl7:acknowledgementDetail[@typeCode='E']/hl7:text/text()"/></AdditionalInfoItem>
</AdditionalInfo>
</xsl:if>
</PatientSearchResponse>
</xsl:template>
<xsl:template match="hl7:PRPA_IN201310UV02/hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1">
<xsl:for-each select="hl7:patient">
<xsl:variable name="patientRoot" select="."/>
<xsl:variable name="personRoot" select="$patientRoot/hl7:patientPerson"/>

<PatientSearchMatch>
<Facility><xsl:value-of select="isc:evaluate('OIDtoCode',hl7:providerOrganization/hl7:id/@root)"/></Facility>
<LastName><xsl:value-of select="$personRoot/hl7:name/hl7:family"/></LastName>
<FirstName><xsl:value-of select="$personRoot/hl7:name/hl7:given[1]"/></FirstName>
<MiddleName><xsl:value-of select="$personRoot/hl7:name/hl7:given[2]"/></MiddleName>
<DOB><xsl:value-of select="isc:evaluate('xmltimestamp',$personRoot/hl7:birthTime/@value)"/></DOB>
<Sex><xsl:value-of select="$personRoot/hl7:administrativeGenderCode/@code"/></Sex>
<Identifiers>
<xsl:for-each select="$patientRoot/hl7:id">
<Identifier>
<Root><xsl:value-of select="isc:evaluate('OIDtoCode',@root)"/></Root>
<Extension><xsl:value-of select="@extension"/></Extension>
</Identifier>
</xsl:for-each>
<xsl:for-each select="$personRoot/hl7:asOtherIDs/hl7:id">
<Identifier>
<Root><xsl:value-of select="isc:evaluate('OIDtoCode',@root)"/></Root>
<Extension><xsl:value-of select="@extension"/></Extension>
</Identifier>
</xsl:for-each>
</Identifiers>
</PatientSearchMatch>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
