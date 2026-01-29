<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:hl7="urn:hl7-org:v3" xmlns:isc="http://extension-functions.intersystems.com" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" version="1.0" xmlns:wrapper="http://wrapper.intersystems.com" xmlns:ihe="urn:ihe:iti:xds-b:2007" exclude-result-prefixes="wrapper isc hl7 ihe query rim">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:param name="messageID"/>
<xsl:param name="creationTime"/>
<xsl:param name="targetMessageID" select="/root/support/hl7:PRPA_IN201305UV02/hl7:id/@root"/>
<xsl:param name="targetMessageExtension" select="/root/support/hl7:PRPA_IN201305UV02/hl7:id/@extension"/>
<xsl:param name="queryID" select="/root/support/hl7:PRPA_IN201305UV02/hl7:controlActProcess/hl7:queryByParameter/hl7:queryId/@root"/>
<xsl:param name="queryExtension" select="/root/support/hl7:PRPA_IN201305UV02/hl7:controlActProcess/hl7:queryByParameter/hl7:queryId/@extension"/>
<xsl:param name="queryStatus" select="''"/>

<xsl:template match="/root">
<PRPA_IN201306UV02 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns="urn:hl7-org:v3" ITSVersion="XML_1.0">
<id root="{$messageID}"/>
<creationTime value="{$creationTime}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201306UV02"/>
<processingCode code="T"/>
<processingModeCode code="I"/>
<acceptAckCode code="NE"/>
<xsl:call-template name="devices"/>
<acknowledgement>
<typeCode code="AA"/>
<targetMessage>
<id>
<xsl:if test="$targetMessageID !=''"><xsl:attribute name="root"><xsl:value-of select="$targetMessageID"/></xsl:attribute></xsl:if>
<xsl:if test="$targetMessageExtension !=''"><xsl:attribute name="extension"><xsl:value-of select="$targetMessageExtension"/></xsl:attribute></xsl:if>
</id>
</targetMessage>
</acknowledgement>
<controlActProcess classCode="CACT" moodCode="EVN">
<code code="PRPA_TE201306UV02" codeSystem="2.16.840.1.113883.1.6"/>
<!-- copy each subject -->
<xsl:for-each select="XCPDQueryResponses/hl7:PRPA_IN201306UV02/hl7:controlActProcess/hl7:subject/.">
<xsl:copy-of select = "."/>
</xsl:for-each>
<queryAck>
<queryId>
<xsl:if test="$queryID !=''"><xsl:attribute name="root"><xsl:value-of select="$queryID"/></xsl:attribute></xsl:if>
<xsl:if test="$queryExtension !=''"><xsl:attribute name="extension"><xsl:value-of select="$queryExtension"/></xsl:attribute></xsl:if>
</queryId>
<queryResponseCode code="{$queryStatus}"/>
</queryAck>
<xsl:copy-of select = "/root/support/hl7:PRPA_IN201305UV02/hl7:controlActProcess/hl7:queryByParameter/."/>
</controlActProcess>
</PRPA_IN201306UV02>
</xsl:template>
<xsl:template name="devices">
<!-- need to copy devices but reverse them  -->
<receiver typeCode="RCV">
<xsl:copy-of select = "/root/support/hl7:PRPA_IN201305UV02/hl7:sender/hl7:device/."/>
  </receiver>
<sender typeCode="SND">
<xsl:copy-of select = "/root/support/hl7:PRPA_IN201305UV02/hl7:receiver/hl7:device/."/>
</sender>
</xsl:template>

</xsl:stylesheet>
