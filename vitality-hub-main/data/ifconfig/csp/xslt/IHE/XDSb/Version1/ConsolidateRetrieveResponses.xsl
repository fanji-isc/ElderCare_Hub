<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:ihe:iti:xds-b:2007" xmlns:xdsb="urn:ihe:iti:xds-b:2007" xmlns:xop="http://www.w3.org/2004/08/xop/include" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" exclude-result-prefixes="isc query rim rs lcm xdsb">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:param name="homeCommunityID"/>
<xsl:param name="status"/>

<xsl:variable name="failure" select="'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Failure'"/>
<xsl:variable name="partial" select="'urn:ihe:iti:2007:ResponseStatusType:PartialSuccess'"/>
<xsl:variable name="success" select="'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success'"/>
<xsl:variable name="warning" select="'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Warning'"/>
<xsl:variable name="error" select="'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error'"/>

<xsl:template match="/xdsb:XDSbRetrieveResponses">
<RetrieveDocumentSetResponse xmlns="urn:ihe:iti:xds-b:2007" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" >
<xsl:variable name="haveFailure" select="//rs:RegistryResponse[@status=$failure]"/>
<xsl:variable name="havePartial" select="//rs:RegistryResponse[@status=$partial]"/>
<xsl:variable name="haveSuccess" select="//rs:RegistryResponse[@status=$success]"/>
<xsl:variable name="haveException" select="count(//xdsb:Error)"/>
<xsl:variable name="status">
<xsl:choose>
<xsl:when test="($haveFailure or $haveException) and not($havePartial or $haveSuccess)"><xsl:value-of select="$failure"/></xsl:when>
<xsl:when test="($haveFailure or $haveException) or $havePartial"><xsl:value-of select="$partial"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$success"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="haveError" select="//rs:RegistryError[@severity=$error]"/>
<xsl:variable name="haveWarning" select="//rs:RegistryError[@severity=$warning]"/>
<xsl:variable name="highest">
<xsl:choose>
<xsl:when test="$haveException"><xsl:value-of select="$error"/></xsl:when>
<xsl:when test="$haveError"><xsl:value-of select="$error"/></xsl:when>
<xsl:when test="$haveWarning"><xsl:value-of select="$warning"/></xsl:when>
</xsl:choose>
</xsl:variable>



<rs:RegistryResponse status='{$status}'>
<xsl:if test="$haveError or $haveWarning or $haveException">
<rs:RegistryErrorList highestSeverity="{$highest}">
  <xsl:copy-of select="//rs:RegistryError"/>
  <xsl:for-each select="//Error">
  <xsl:variable name="severity">
  <xsl:choose>
  <xsl:when test="Severity/text()='Warning'"><xsl:value-of select="$warning"/></xsl:when>
  <xsl:otherwise><xsl:value-of select="$error"/></xsl:otherwise>
  </xsl:choose>
  </xsl:variable>
  <rs:RegistryError codeContext="{Description/text()}" errorCode="{Code/text()}" location="{Location/text()}" severity="{$severity}" /> 
  </xsl:for-each>
<xsl:for-each select="//xdsb:Error">
<xsl:element name="rs:RegistryError">
<xsl:if test="./xdsb:Location!=''">
<xsl:attribute name="location"><xsl:value-of select="./xdsb:Location"/></xsl:attribute>
</xsl:if>
<xsl:attribute name="errorCode">
<xsl:value-of select="./xdsb:Code/text()"/>
</xsl:attribute>
<xsl:attribute name="codeContext">
<xsl:value-of select="./xdsb:Description/text()"/>
</xsl:attribute>
<xsl:attribute name="severity">
<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:', ./xdsb:Severity/text())"/>
</xsl:attribute>
</xsl:element>
</xsl:for-each>
</rs:RegistryErrorList>
</xsl:if>
</rs:RegistryResponse>
<xsl:for-each select="xdsb:RetrieveDocumentSetResponse/xdsb:DocumentResponse">
<xsl:element name="DocumentResponse">
<xsl:copy-of select="@*|node()"/>
</xsl:element>
</xsl:for-each>
</RetrieveDocumentSetResponse>
</xsl:template>

</xsl:stylesheet>
