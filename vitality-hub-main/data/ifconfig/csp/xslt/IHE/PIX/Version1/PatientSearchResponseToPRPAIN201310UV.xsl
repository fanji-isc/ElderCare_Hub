<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:param name="creationTime"/>
<xsl:param name="custodian"/>
<xsl:param name="custodianName"/>
<xsl:param name="messageID"/>
<xsl:param name="messageExtension"/>
<xsl:variable name="originalRequest" select="/root/originalRequest/*[local-name()]"/>
<xsl:variable name="targetMessageID" select="/root/originalRequest/*[local-name()]/hl7:id/@root"/>
<xsl:variable name="targetMessageExtension" select="/root/originalRequest/*[local-name()]/hl7:id/@extension"/>
<xsl:variable name="queryID" select="/root/originalRequest/*[local-name()]/hl7:controlActProcess/hl7:queryByParameter/hl7:queryId/@root"/>
<xsl:variable name="queryExtension" select="/root/originalRequest/*[local-name()]/hl7:controlActProcess/hl7:queryByParameter/hl7:queryId/@extension"/>
<xsl:param name="queryStatus" select='OK'/>
<xsl:param name="ackTypeCode" select='AA'/>

<xsl:template match="/root">
<PRPA_IN201310UV02 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" ITSVersion="XML_1.0">
<id>
<xsl:if test="$messageID !=''"><xsl:attribute name="root"><xsl:value-of select="$messageID"/></xsl:attribute></xsl:if>
<xsl:if test="$messageExtension !=''"><xsl:attribute name="extension"><xsl:value-of select="$messageExtension"/></xsl:attribute></xsl:if>
</id>
<creationTime value='{$creationTime}'></creationTime>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201310UV02"/>
<processingCode code="P"/>
<processingModeCode code="T"/>
<acceptAckCode code="NE"/>
<xsl:call-template name="devices"/>
<acknowledgement>
<typeCode code="{$ackTypeCode}"/>
<targetMessage>
<id>
<xsl:if test="$targetMessageID !=''"><xsl:attribute name="root"><xsl:value-of select="$targetMessageID"/></xsl:attribute></xsl:if>
<xsl:if test="$targetMessageExtension !=''"><xsl:attribute name="extension"><xsl:value-of select="$targetMessageExtension"/></xsl:attribute></xsl:if>
</id>
</targetMessage>
<!-- AA for queries -->
<xsl:if test="$ackTypeCode != 'AA'"> 
<xsl:call-template name="errors"/>
</xsl:if>
</acknowledgement>
<controlActProcess classCode="CACT" moodCode="EVN">
<code code="PRPA_TE201310UV02"/>
<xsl:if test="$queryStatus = 'OK'">
<subject typeCode="SUBJ">
<xsl:for-each select="PatientSearchResponse/Results/PatientSearchMatch">
<xsl:variable name="person" select="."/>
<xsl:variable name="Facility" select="isc:evaluate('CodetoOID',./Facility/text())"/>
<xsl:variable name="patientID" select="./MRN/text()"/>
<registrationEvent classCode="REG" moodCode="EVN">
<id nullFlavor="NA"/>
<statusCode code="active"/>
<subject1 typeCode="SBJ">
<patient classCode="PAT">
<xsl:for-each select="./IDs/Match">
<xsl:variable name="per" select="."/>
<id root="{isc:evaluate('CodetoOID',$per/AssigningAuthority)}" extension="{$per/MRN}" assigningAuthorityName="{$per/AssigningAuthority}"/>
</xsl:for-each>
<statusCode code="active"/>	
<patientPerson classCode="PSN" determinerCode="INSTANCE">
<name>
<xsl:if test="$person/FirstName/text()!=''"><given><xsl:value-of select="$person/FirstName/text()"/></given></xsl:if>
<xsl:if test="$person/LastName/text()!=''"><family><xsl:value-of select="$person/LastName/text()"/></family></xsl:if>
</name>
</patientPerson>
<xsl:if test="$Facility !=''">
<providerOrganization classCode="ORG" determinerCode="INSTANCE">
<id root="{$Facility}"/>
<name><xsl:value-of select="./AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='FacilityName']/text()"/></name>
<xsl:variable name="telecom" select="./AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='FacilityTelephone']/text()"/>
<contactParty classCode="CON"><telecom value="{$telecom}"/></contactParty>
</providerOrganization>
</xsl:if>
</patient>
</subject1>
<custodian typeCode="CST">
<assignedEntity classCode="ASSIGNED">
<id root="{isc:evaluate('CodetoOID',$custodian)}"/>
<assignedOrganization classCode="ORG" determinerCode="INSTANCE">
<name><xsl:value-of select="$custodianName"/></name>
</assignedOrganization>
</assignedEntity>
</custodian>
</registrationEvent>
</xsl:for-each>
</subject>
</xsl:if>
<queryAck>
<queryId>
<xsl:if test="$queryID !=''"><xsl:attribute name="root"><xsl:value-of select="$queryID"/></xsl:attribute></xsl:if>
<xsl:if test="$queryExtension !=''"><xsl:attribute name="extension"><xsl:value-of select="$queryExtension"/></xsl:attribute></xsl:if>
</queryId>
<xsl:choose>
<xsl:when test="$queryStatus = 'AE'">
<statusCode code="aborted"/>
</xsl:when>
<xsl:otherwise>
<statusCode code="deliveredResponse"/>
</xsl:otherwise>
</xsl:choose>
<queryResponseCode code="{$queryStatus}"/>
</queryAck>
<xsl:call-template name="parameters"/>
</controlActProcess>
</PRPA_IN201310UV02>
</xsl:template>

<xsl:template name="errors">
<xsl:for-each select="/root/Errors/Error">
<acknowledgementDetail xmlns="urn:hl7-org:v3" typeCode="E">
<code code="{./Code}"/>
<xsl:if test="./Description!=''"><text><xsl:value-of select="./Description"/></text></xsl:if>
<xsl:if test="./Location!=''"><location><xsl:value-of select="./Location"/></location></xsl:if>
</acknowledgementDetail>
</xsl:for-each>
</xsl:template>


<xsl:template name="parameters">
<xsl:copy-of select = "$originalRequest/hl7:controlActProcess/hl7:queryByParameter/."/>
</xsl:template>

<xsl:template name="devices">
<!-- need to copy devices but reverse them  -->
<hl7:receiver typeCode="RCV">
<xsl:copy-of select = "$originalRequest/hl7:sender/hl7:device/."/>
</hl7:receiver>
<hl7:sender typeCode="SND">
<xsl:copy-of select = "$originalRequest/hl7:receiver/hl7:device/."/>
</hl7:sender>
</xsl:template>

</xsl:stylesheet>
