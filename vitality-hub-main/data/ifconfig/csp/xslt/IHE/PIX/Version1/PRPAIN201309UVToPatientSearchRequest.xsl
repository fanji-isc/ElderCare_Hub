<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns="urn:ihe:iti:xds-b:2007" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wrapper="http://wrapper.intersystems.com" exclude-result-prefixes="isc wrapper">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:param name="userName"/>
<xsl:param name="userRoles"/>
<xsl:param name="gatewayName"/>

<xsl:template match="/hl7:PRPA_IN201309UV02">
<xsl:variable name="assigningAuthority" select="isc:evaluate('OIDtoCode',./hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList/hl7:patientIdentifier/hl7:value/@root)"/>
<xsl:variable name="mrn" select="./hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList/hl7:patientIdentifier/hl7:value/@extension"/>

<PatientSearchRequest>
<BreakTheGlass>false</BreakTheGlass>
<RequestingUser><xsl:value-of select="$userName"/></RequestingUser>
<RequestingUserRoles><xsl:value-of select="$userRoles"/></RequestingUserRoles>
<RequestingGateway><xsl:value-of select="$gatewayName"/></RequestingGateway>
<AssigningAuthority><xsl:value-of select="$assigningAuthority"/></AssigningAuthority>
<MRN><xsl:value-of select="$mrn"/></MRN>
<SearchMode>PIXPDQ</SearchMode>
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="SenderOID"><xsl:value-of select="hl7:sender/hl7:device/hl7:id/@root"/></AdditionalInfoItem>
<xsl:apply-templates select="./hl7:controlActProcess/hl7:queryByParameter/hl7:parameterList/hl7:dataSource" mode="scopingOrganization">
</xsl:apply-templates>
</AdditionalInfo>
</PatientSearchRequest>
</xsl:template>

<xsl:template match="*" mode="scopingOrganization">
<xsl:variable name="organizationCode" select="isc:evaluate('OIDtoCode',hl7:value/@root)"/>
<AdditionalInfoItem AdditionalInfoKey="{concat('scopingOrganization_',$organizationCode)}"/>
</xsl:template>

</xsl:stylesheet>
