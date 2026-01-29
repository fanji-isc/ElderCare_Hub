<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" exclude-result-prefixes="isc" >
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:param name="receiverDeviceOID"/>
<xsl:param name="senderDeviceOID"/>
<xsl:param name="messageID" select="''"/>
<xsl:param name="creationTime" select="''"/>

<xsl:param name="queryID" />
<xsl:param name="queryExtension" select="'1'"/>


<xsl:template match="/PatientSearchRequest">
<xsl:variable name="MRN" select="./MRN/text()"/>
<xsl:variable name="Facility" select="isc:evaluate('CodetoOID',Facility/text())"/>
<xsl:variable name="AssigningAuthority">
<xsl:choose>
<xsl:when test="AssigningAuthority/text() != ''"><xsl:value-of select="isc:evaluate('CodetoOID',AssigningAuthority/text())"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$Facility"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>

<PRPA_IN201309UV02 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns="urn:hl7-org:v3"
xmlns:hl7="www.hl7.org"
ITSVersion="XML_1.0">
<id root="{$messageID}"/>
<creationTime value="{$creationTime}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201309UV02"/>
<processingCode code="P"/>
<processingModeCode code="T"/>
<acceptAckCode code="AL"/>
<receiver typeCode="RCV">
<device classCode="DEV" determinerCode="INSTANCE">
<id root="{$receiverDeviceOID}"/>
</device>
</receiver>
<sender typeCode="SND">
<device classCode="DEV" determinerCode="INSTANCE">
<id root="{$senderDeviceOID}"/>
</device>
</sender>
<controlActProcess classCode="CACT" moodCode="EVN">
<code code="PRPA_TE201309UV02" codeSystem="2.16.840.1.113883.1.6"/>
<authorOrPerformer typeCode="AUT">
<assignedPerson classCode="ASSIGNED"/>
</authorOrPerformer>
<queryByParameter>
<queryId root="{$queryID}" extension="{$queryExtension}"/>
<statusCode code="new"/>
<responsePriorityCode code="I"/>
<parameterList>

<xsl:choose>
<xsl:when test="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='ScopingOrganizations']">
<xsl:apply-templates select="AdditionalInfo/AdditionalInfoItem[starts-with(@AdditionalInfoKey,'scopingOrganization_')]" mode="scopingOrganization">
</xsl:apply-templates>
</xsl:when>
<xsl:when test="$Facility!=''">
<dataSource xmlns="urn:hl7-org:v3">
<value root="{$Facility}"/>
<semanticsText>DataSource.id</semanticsText>
</dataSource>
</xsl:when>
</xsl:choose>

<patientIdentifier>
<value root="{$AssigningAuthority}" extension="{$MRN}"/>
<semanticsText>Patient.Id</semanticsText>
</patientIdentifier>

</parameterList>

</queryByParameter>
</controlActProcess>
</PRPA_IN201309UV02>
</xsl:template>

<xsl:template match="*" mode="scopingOrganization">
<dataSource xmlns="urn:hl7-org:v3">
<value root="{isc:evaluate('CodetoOID',substring-after(@AdditionalInfoKey,'scopingOrganization_'))}"/>
<semanticsText>DataSource.id</semanticsText>
</dataSource>
</xsl:template>

</xsl:stylesheet>
