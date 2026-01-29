<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:ihe="urn:ihe:iti:xds-b:2007" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:date="http://exslt.org/dates-and-times" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:include href="RegistryObjectToMetadata.xsl"/>
<xsl:param name="status" select="'Success'"/>
<xsl:template match="/">
<query:AdhocQueryResponse status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:{$status}">
<!-- status is success -->
<xsl:choose>
<xsl:when test="$status = 'Success'">
<rim:RegistryObjectList>
<xsl:call-template name="Documents"/>
<xsl:call-template name="RegistryPackages"/>
<xsl:call-template name="ObjectRefs"/>
<xsl:call-template name="Associations"/>
</rim:RegistryObjectList>
</xsl:when>
<!-- status is failure -->
<xsl:otherwise>
<RegistryErrorList>
<xsl:attribute name="highestSeverity">
<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:', Submission/HighestError/text())"/>
</xsl:attribute>
<xsl:for-each select='Submission/Error'>
<RegistryError location="">
<xsl:attribute name="errorCode">
<xsl:value-of select="Code/text()"/>
</xsl:attribute>
<xsl:attribute name="codeContext">
<xsl:value-of select="Description/text()"/>
</xsl:attribute>
<xsl:attribute name="severity">
<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:', Severity/text())"/>
</xsl:attribute>
</RegistryError>
</xsl:for-each>
</RegistryErrorList>
<rim:RegistryObjectList>
</rim:RegistryObjectList>
</xsl:otherwise>
</xsl:choose>

</query:AdhocQueryResponse>
</xsl:template>

<xsl:template name="Documents">
<xsl:for-each select="Submission/DocumentsStream/Document">
<xsl:call-template name="Document"/>
</xsl:for-each>
<xsl:for-each select="Submission/Document">
<xsl:call-template name="Document"/>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
