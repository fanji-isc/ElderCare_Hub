<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:hl7="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:param name="messageID"/>
<xsl:param name="messageExtension"/>
<xsl:param name="creationTime"/>
<xsl:param name="typeCode" select="'CA'"/>
<xsl:variable name="targetMessageID" select="/root/originalRequest/*[local-name()]/hl7:id/@root"/>
<xsl:variable name="targetMessageExtension" select="/root/originalRequest/*[local-name()]/hl7:id/@extension"/>

<xsl:template match="/">
<MCCI_IN000002UV01 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" ITSVersion="XML_1.0">
<id>
<xsl:if test="$messageID != ''">
<xsl:attribute name='root'><xsl:value-of select="$messageID"/></xsl:attribute>
</xsl:if>
<xsl:if test="$messageExtension != ''">
<xsl:attribute name='extension'><xsl:value-of select="$messageExtension"/></xsl:attribute>
</xsl:if>
</id>
<creationTime value="{$creationTime}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="MCCI_IN000002UV01"/>
<processingCode code="P"/>
<processingModeCode code="R"/>
<acceptAckCode code="NE"/>
<xsl:call-template name="devices"/>
<acknowledgement>
<typeCode code="{$typeCode}"/>
<targetMessage>
<id>
<xsl:if test="$targetMessageID != ''">
<xsl:attribute name='root'><xsl:value-of select="$targetMessageID"/></xsl:attribute>
</xsl:if>
<xsl:if test="$targetMessageExtension != ''">
<xsl:attribute name='extension'><xsl:value-of select="$targetMessageExtension"/></xsl:attribute>
</xsl:if>
</id>
</targetMessage>
<xsl:if test="$typeCode != 'CA'"> 
<xsl:call-template name="errors"/>
</xsl:if>

</acknowledgement>
</MCCI_IN000002UV01>
</xsl:template>


<xsl:template name="errors">
<xsl:for-each select="root/Errors/Error">
<acknowledgementDetail xmlns="urn:hl7-org:v3" typeCode="E">
<code code="{./Code}"/>
<xsl:if test="./Description!=''"><text><xsl:value-of select="./Description"/></text></xsl:if>
<xsl:if test="./Location!=''"><location><xsl:value-of select="./Location"/></location></xsl:if>
</acknowledgementDetail>
</xsl:for-each>
</xsl:template>

<xsl:template name="devices">
<!-- need to copy devices but reverse them  -->
<hl7:receiver typeCode="RCV">
<xsl:copy-of select = "/root/originalRequest/*[local-name()]/hl7:sender/hl7:device/."/>
</hl7:receiver>
<hl7:sender typeCode="SND">
<xsl:copy-of select = "/root/originalRequest/*[local-name()]/hl7:receiver/hl7:device/."/>
</hl7:sender>
</xsl:template>

</xsl:stylesheet>
