<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0">
<xsl:param name="homeCommunityID"/>
<xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="@*|node()">
<xsl:copy>
<xsl:apply-templates select="@*|node()"/>
</xsl:copy>
</xsl:template>

<xsl:template match="rs:RegistryError">
<xsl:element name="rs:RegistryError">
<xsl:attribute name="location">urn:oid:<xsl:value-of select="$homeCommunityID"/></xsl:attribute>
<xsl:attribute name="codeContext"><xsl:value-of select="@codeContext"/></xsl:attribute>
<xsl:attribute name="errorCode"><xsl:value-of select="@errorCode"/></xsl:attribute>
<xsl:attribute name="severity"><xsl:value-of select="@severity"/></xsl:attribute>
</xsl:element>
</xsl:template>

<xsl:template match="rim:ExtrinsicObject">
<xsl:element name="rim:ExtrinsicObject">
<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
<xsl:attribute name="home">urn:oid:<xsl:value-of select="$homeCommunityID"/></xsl:attribute>
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:template>

<xsl:template match="rim:ObjectRef">
<xsl:element name="rim:ObjectRef">
<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
<xsl:attribute name="home">urn:oid:<xsl:value-of select="$homeCommunityID"/></xsl:attribute>
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:template>

<xsl:template match="rim:RegistryPackage">
<xsl:element name="rim:RegistryPackage">
<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
<xsl:attribute name="home">urn:oid:<xsl:value-of select="$homeCommunityID"/></xsl:attribute>
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:template>

</xsl:stylesheet>
