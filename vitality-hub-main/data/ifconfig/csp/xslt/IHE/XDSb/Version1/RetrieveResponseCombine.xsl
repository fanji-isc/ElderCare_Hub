<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
version="1.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007"
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0"
xmlns:exsl="http://exslt.org/common"
xmlns:set="http://exslt.org/sets"
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
exclude-result-prefixes="isc exsl set">

<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:variable name="failure" select="'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Failure'"/>
<xsl:variable name="partial" select="'urn:ihe:iti:2007:ResponseStatusType:PartialSuccess'"/>
<xsl:variable name="success" select="'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success'"/>
<xsl:variable name="warning" select="'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Warning'"/>
<xsl:variable name="error" select="'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error'"/>

<xsl:template match="/Result">
<XMLMessage>
<Name>XDSb_RetrieveResponse</Name> 
<ContentStream>
<xdsb:RetrieveDocumentSetResponse>
<xsl:variable name="haveFailure" select="//rs:RegistryResponse[@status=$failure]"/>
<xsl:variable name="havePartial" select="//rs:RegistryResponse[@status=$partial]"/>
<xsl:variable name="haveSuccess" select="//rs:RegistryResponse[@status=$success]"/>
<xsl:variable name="haveException" select="//Error"/>
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
<xsl:when test="$haveError"><xsl:value-of select="$error"/></xsl:when>
<xsl:when test="$haveWarning"><xsl:value-of select="$warning"/></xsl:when>
</xsl:choose>
</xsl:variable>
<!--
<vars>
<haveFailure><xsl:if test="$haveFailure">1</xsl:if></haveFailure>
<havePartial><xsl:if test="$havePartial">1</xsl:if></havePartial>
<haveSuccess><xsl:if test="$haveSuccess">1</xsl:if></haveSuccess>
<haveException><xsl:if test="$haveException">1</xsl:if></haveException>
<haveError><xsl:if test="$haveError">1</xsl:if></haveError>
<haveWarning><xsl:if test="$haveWarning">1</xsl:if></haveWarning>
<highest><xsl:value-of select="$highest"/></highest>
<status><xsl:value-of select="$status"/></status>
</vars>
-->
<rs:RegistryResponse status="{$status}"> 
<xsl:if test="$haveError or $haveWarning">
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
  </rs:RegistryErrorList>
</xsl:if>
</rs:RegistryResponse>

<xsl:copy-of select="//xdsb:DocumentResponse"/>
</xdsb:RetrieveDocumentSetResponse>
</ContentStream>
</XMLMessage>
</xsl:template>
</xsl:stylesheet>
