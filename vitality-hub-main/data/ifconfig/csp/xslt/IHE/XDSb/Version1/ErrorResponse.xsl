<?xml version="1.0" encoding="UTF-8"?>
<!-- Create an error response for various XDSb messages   -->
<!-- Invoked whenever there is an unrecoverable exception -->
<xsl:stylesheet version="1.0" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>		
<xsl:include href="Variables.xsl"/>

<xsl:param name="responseName"/>
<xsl:param name="errorMessage"/>

<xsl:template match="/">
<XMLMessage>
<Name>
<xsl:value-of select="$responseName"/>
</Name>
<xsl:choose>
<xsl:when test="$responseName = $xdsbRetrieveResponse"><xsl:call-template name="xdsbRetrieve"/></xsl:when>
<xsl:when test="$responseName = $xdsbProvideAndRegisterResponse"><xsl:call-template name="xdsbProvideAndRegister"/></xsl:when>
</xsl:choose>
</XMLMessage>
</xsl:template>

<xsl:template name="xdsbRetrieve">
<ContentStream>
<RetrieveDocumentSetResponse xmlns="urn:ihe:iti:xds-b:2007">
<RegistryResponse status="{$failure}" xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0">
<RegistryErrorList highestSeverity="{$error}">
<RegistryError errorCode="XDSbRepository" codeContext="{$errorMessage}" severity="{$error}" location=""/>
</RegistryErrorList>
</RegistryResponse>
</RetrieveDocumentSetResponse>
</ContentStream>
</xsl:template>

<xsl:template name="xdsbProvideAndRegister">
<ContentStream>
<RetrieveDocumentSetResponse xmlns="urn:ihe:iti:xds-b:2007">
<RegistryResponse status="{$failure}" xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0">
<RegistryErrorList highestSeverity="{$error}">
<RegistryError errorCode="XDSbRepository" codeContext="{$errorMessage}" severity="{$error}" location=""/>
</RegistryErrorList>
</RegistryResponse>
</RetrieveDocumentSetResponse>
</ContentStream>
</xsl:template>

</xsl:stylesheet>