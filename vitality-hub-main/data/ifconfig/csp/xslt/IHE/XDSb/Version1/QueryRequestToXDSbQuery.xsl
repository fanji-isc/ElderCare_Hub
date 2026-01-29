<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" 
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
version="1.0"  exclude-result-prefixes="isc">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>


<xsl:template match="/QueryRequest">

<query:AdhocQueryRequest>
<query:ResponseOption returnComposedObjects="true" returnType="{ReturnType/text()}"/>
<rim:AdhocQuery id="urn:uuid:{QueryType}">
<xsl:choose>
<xsl:when test="HomeCommunityOID/text()!=''">
<xsl:attribute name="home">urn:oid:<xsl:value-of select='HomeCommunityOID/text()'/></xsl:attribute>
</xsl:when>
<xsl:when test="HomeCommunity/text()!=''">
<xsl:attribute name="home">urn:oid:<xsl:value-of select='isc:evaluate("CodetoOID",HomeCommunity/text(),"","")'/></xsl:attribute>
</xsl:when>
</xsl:choose>
<xsl:for-each select="Parameters/QueryItem">
<xsl:if test="substring(ItemName,1,4)!='urn:'">  <!-- exclude custom slot values -->
<rim:Slot name="{ItemName}">
<rim:ValueList>
<xsl:variable name='single' select='SingleValue/text()'/>
<xsl:for-each select="Values/ValuesItem">
<rim:Value><xsl:if test="$single='false'">(</xsl:if><xsl:if test="not(number(text()))">'</xsl:if><xsl:value-of select='text()'/><xsl:if test="not(number(text()))">'</xsl:if><xsl:if test="$single='false'">)</xsl:if></rim:Value>
</xsl:for-each>
<xsl:for-each select="CodedValues/CodedValue">
<rim:Value><xsl:if test="$single='false'">(</xsl:if><xsl:if test="not(number(text()))">'</xsl:if><xsl:value-of select='Code/text()'/>^^<xsl:value-of select='Scheme/text()'/><xsl:if test="not(number(text()))">'</xsl:if><xsl:if test="$single='false'">)</xsl:if></rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:if>
</xsl:for-each>
</rim:AdhocQuery>
</query:AdhocQueryRequest>
</xsl:template>

</xsl:stylesheet>
