<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" exclude-result-prefixes="isc query rim rs lcm">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:param name="patientID"/>

<xsl:template match="/">
<query:AdhocQueryRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" >
<query:ResponseOption returnComposedObjects="{query:AdhocQueryRequest/query:ResponseOption/@returnComposedObjects}" returnType="{query:AdhocQueryRequest/query:ResponseOption/@returnType}" /> 
<rim:AdhocQuery xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" id="{/query:AdhocQueryRequest/rim:AdhocQuery/@id}">
<xsl:call-template name="Slot"/>
</rim:AdhocQuery>
</query:AdhocQueryRequest>
</xsl:template>

<xsl:template name="Slot">
<xsl:for-each select="/query:AdhocQueryRequest/rim:AdhocQuery/rim:Slot">
<rim:Slot>
<xsl:if test="@name"><xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute></xsl:if>
<xsl:variable name="slotName" select="@name"/>
<rim:ValueList>
<xsl:for-each select="rim:ValueList/rim:Value">
<xsl:choose>
<xsl:when test="$slotName ='$patientId'"><rim:Value>'<xsl:value-of select="$patientID"/>'</rim:Value></xsl:when>
<xsl:when test="$slotName ='$XDSDocumentEntryPatientId'"><rim:Value>'<xsl:value-of select="$patientID"/>'</rim:Value></xsl:when> 
<xsl:when test="$slotName ='$XDSFolderPatientId'"><rim:Value>'<xsl:value-of select="$patientID"/>'</rim:Value></xsl:when> 
<xsl:otherwise><rim:Value><xsl:value-of select="text()"/></rim:Value></xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>