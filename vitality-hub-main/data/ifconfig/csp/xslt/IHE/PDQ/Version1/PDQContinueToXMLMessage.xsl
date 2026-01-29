<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wrapper="http://wrapper.intersystems.com" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="isc wrapper hl7">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="//node()">
<xsl:variable name="messageID" select="./hl7:id/@root"/>
<xsl:variable name="messageExtension" select="./hl7:id/@extension"/>
<xsl:variable name="queryID" select="./hl7:controlActProcess/hl7:queryContinuation/hl7:queryId/@root"/>
<xsl:variable name="queryExtension" select="./hl7:controlActProcess/hl7:queryContinuation/hl7:queryId/@extension"/>
<xsl:variable name="queryQuantity" select="./hl7:controlActProcess/hl7:queryContinuation/hl7:continuationQuantity/@value"/>
<xsl:variable name="startResultNumber" select="./hl7:controlActProcess/hl7:queryContinuation/hl7:startResultNumber/@value"/>
<xsl:variable name="senderDeviceOID" select="./hl7:sender/hl7:device/hl7:id/@root"/>
<xsl:variable name="senderDeviceName" select="./hl7:sender/hl7:device/hl7:id/@extension"/>
<xsl:variable name="receiverDeviceOID" select="./hl7:receiver/hl7:device/hl7:id/@root"/>
<xsl:variable name="receiverDeviceName" select="./hl7:receiver/hl7:device/hl7:id/@extension"/>

<XMLMessage>
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="MessageID"><xsl:value-of select="$messageID"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="MessageExtension"><xsl:value-of select="$messageExtension"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="QueryID"><xsl:value-of select="$queryID"/></AdditionalInfoItem>
<!-- add space to extension just in case it is empty -->
<AdditionalInfoItem AdditionalInfoKey="QueryExtension"><xsl:value-of select="$queryExtension"/> </AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="QueryQuantity"><xsl:value-of select="$queryQuantity"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="StartResultNumber"><xsl:value-of select="$startResultNumber"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="senderDeviceOID"><xsl:value-of select="$senderDeviceOID"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="senderDeviceName"><xsl:value-of select="$senderDeviceName"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="receiverDeviceOID"><xsl:value-of select="$receiverDeviceOID"/></AdditionalInfoItem>
<AdditionalInfoItem AdditionalInfoKey="receiverDeviceName"><xsl:value-of select="$receiverDeviceName"/></AdditionalInfoItem>
</AdditionalInfo>

</XMLMessage>
</xsl:template>

</xsl:stylesheet>
