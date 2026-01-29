<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:param name="senderDeviceOID"/>
<xsl:param name="receiverDeviceOID"/>
<xsl:param name="messageID"/>
<xsl:param name="messageExtension"/>
<xsl:param name="queryID"/>
<xsl:param name="queryExtension"/>
<xsl:param name="homeCommunityOID"/>
<xsl:param name="XCPDAssigningAuthority"/>
<xsl:param name="XCPDPatientID"/>


<xsl:template match="/PatientSearchMatch">
<xsl:call-template name="main"/>
</xsl:template>

<xsl:template match="/PatientSearchRequest">
<xsl:call-template name="main"/>
</xsl:template>
<xsl:template name="main">
<xsl:variable name="continuationQuantity" select="./MaxMatches/text()"/>
<xsl:variable name="startResultNumber"><xsl:apply-templates select="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='ContinuationPointer']" mode="additionalInfoValue"/></xsl:variable>
<xsl:variable name="cancelQuery"><xsl:apply-templates select="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='CancelQuery']" mode="additionalInfoValue"/></xsl:variable>
<xsl:variable name="messageName">
<xsl:choose>
<xsl:when test="string-length($cancelQuery)">QUQI_IN000003UV01_Cancel</xsl:when>
<xsl:otherwise>QUQI_IN000003UV01</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:element name="{$messageName}"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="urn:hl7-org:v3 http://www.intersystems.com/healthshare/ihe/schema/HL7V3/NE2008/multicacheschemas/QUQI_IN000003UV01.xsd"
xmlns="urn:hl7-org:v3"
xmlns:hl7="urn:hl7-org:v3">
<xsl:attribute name="ITSVersion">XML_1.0</xsl:attribute>
<id root="{$messageID}" extension="{$messageExtension}"/>
<creationTime value="{isc:evaluate('timestamp')}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="QUQI_IN000003UV01"/>
<processingCode code="T"/>
<processingModeCode code="T"/>
<acceptAckCode code="AL"/>
<receiver typeCode="RCV">
<device classCode="DEV" determinerCode="INSTANCE">
<xsl:if test="$receiverDeviceOID !=''">
<id root="{$receiverDeviceOID}"/></xsl:if>
</device>
</receiver>
<sender typeCode="SND">
<device classCode="DEV" determinerCode="INSTANCE">
<id root="{$senderDeviceOID}"/>
<xsl:if test="$homeCommunityOID !=''">
<asAgent classCode="AGNT">
<representedOrganization classCode="ORG" determinerCode="INSTANCE">
<id root="{$homeCommunityOID}"/>
</representedOrganization>
</asAgent>
</xsl:if>
</device>
</sender>
<acknowledgement>
<typeCode code="AA"/>
<targetMessage>
<id root="{$messageID}"/>
</targetMessage>
</acknowledgement>
<controlActProcess moodCode="EVN" classCode="CACT">
<code code="PRPA_TE000003UV01" codeSystem="2.16.840.1.113883.1.6"/>
<xsl:if test="$XCPDAssigningAuthority !=''">
<authorOrPerformer typeCode="AUT">
<assignedDevice classCode="ASSIGNED"><id root="{isc:evaluate('CodetoOID',$XCPDAssigningAuthority)}"/></assignedDevice>
</authorOrPerformer>
</xsl:if>

<queryContinuation>
<queryId root="{$queryID}">
 <xsl:if test="string-length($queryExtension)>0">
 <xsl:attribute name="extension"><xsl:value-of select="$queryExtension"/></xsl:attribute>
 </xsl:if>
</queryId>
<xsl:choose>
<xsl:when test="string-length($cancelQuery)">
<continuationQuantity value="0"/>
<statusCode code="aborted"/>
</xsl:when>
<xsl:otherwise>
<startResultNumber value="{$startResultNumber}"/>
<continuationQuantity value="{$continuationQuantity}"/>
<statusCode code="waitContinuedQueryResponse"/>
</xsl:otherwise>
</xsl:choose>
</queryContinuation>
</controlActProcess>
</xsl:element>
</xsl:template>

<xsl:template match="*" mode="additionalInfoValue">
<xsl:value-of select="text()"/>
</xsl:template>

</xsl:stylesheet>
