<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" exclude-result-prefixes="isc query rim rs lcm">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:param name="homeCommunityID"/>
<xsl:param name="status"/>

<xsl:template match="/XDSbQueryResponses">
<query:AdhocQueryResponse xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0"
	xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" status="{$status}">

<rim:RegistryObjectList>
<xsl:for-each select="query:AdhocQueryResponse/rim:RegistryObjectList">
<xsl:call-template name="ExtrinsicObject"/>
<xsl:call-template name="RegistryPackage"/>
<xsl:call-template name="Association"/>
<xsl:call-template name="ObjectRef"/>
</xsl:for-each>
</rim:RegistryObjectList>
<xsl:call-template name="errors"/>
</query:AdhocQueryResponse>
</xsl:template>

<xsl:template name="ExtrinsicObject">
<xsl:for-each select="rim:ExtrinsicObject">
<xsl:element name="rim:ExtrinsicObject">
<xsl:choose>
<xsl:when test="@home"><xsl:attribute name="home"><xsl:value-of select="@home"/></xsl:attribute></xsl:when>
<xsl:otherwise><xsl:attribute name="home"><xsl:text>urn:oid:</xsl:text><xsl:value-of select="$homeCommunityID"/></xsl:attribute></xsl:otherwise>
</xsl:choose>
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template name="RegistryPackage">
<xsl:for-each select="rim:RegistryPackage">
<xsl:element name="rim:RegistryPackage">
<xsl:choose>
<xsl:when test="@home"><xsl:attribute name="home"><xsl:value-of select="@home"/></xsl:attribute></xsl:when>
<xsl:otherwise><xsl:attribute name="home"><xsl:text>urn:oid:</xsl:text><xsl:value-of select="$homeCommunityID"/></xsl:attribute></xsl:otherwise>
</xsl:choose>
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template name="Association">
<xsl:for-each select="rim:Association">
<xsl:element name="rim:Association">
<xsl:choose>
<xsl:when test="@home"><xsl:attribute name="home"><xsl:value-of select="@home"/></xsl:attribute></xsl:when>
<xsl:otherwise><xsl:attribute name="home"><xsl:text>urn:oid:</xsl:text><xsl:value-of select="$homeCommunityID"/></xsl:attribute></xsl:otherwise>
</xsl:choose>
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template name="ObjectRef">
<xsl:for-each select="rim:ObjectRef">
<xsl:element name="rim:ObjectRef">
<xsl:choose>
<xsl:when test="@home"><xsl:attribute name="home"><xsl:value-of select="@home"/></xsl:attribute></xsl:when>
<xsl:otherwise><xsl:attribute name="home"><xsl:text>urn:oid:</xsl:text><xsl:value-of select="$homeCommunityID"/></xsl:attribute></xsl:otherwise>
</xsl:choose>
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:for-each>
</xsl:template>


<xsl:template name="errors">
<xsl:if test="count(query:AdhocQueryResponse/rs:RegistryErrorList/rs:RegistryError) or count(/XDSbQueryResponses/Errors/Error)">
<rs:RegistryErrorList>
<xsl:for-each select="query:AdhocQueryResponse/rs:RegistryErrorList/rs:RegistryError">
<xsl:element name="rs:RegistryError">
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:for-each>
<xsl:for-each select="/XDSbQueryResponses/Errors/Error">
<xsl:element name="rs:RegistryError">
<xsl:if test="./Location!=''">
<xsl:attribute name="location"><xsl:value-of select="./Location"/></xsl:attribute>
</xsl:if>
<xsl:attribute name="errorCode">
<xsl:value-of select="Code/text()"/>
</xsl:attribute>
<xsl:attribute name="codeContext">
<xsl:value-of select="Description/text()"/>
</xsl:attribute>
<xsl:attribute name="severity">
<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:', Severity/text())"/>
</xsl:attribute>
</xsl:element>
</xsl:for-each>
</rs:RegistryErrorList>
</xsl:if>
</xsl:template>


</xsl:stylesheet>