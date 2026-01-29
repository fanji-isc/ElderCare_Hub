<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:ihe="urn:ihe:iti:xds-b:2007" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<!-- status: 'Success' or 'Failure' -->
<xsl:param name="status"/>

<xsl:template match="/">
<RegistryResponse xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<xsl:attribute name="status">
<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:', $status)"/>
</xsl:attribute>

<xsl:if test="$status = 'Failure'">
<RegistryErrorList>
<xsl:attribute name="highestSeverity">
<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:', Submission/HighestError/text())"/>
</xsl:attribute>
<xsl:for-each select='Submission/Error'>
<RegistryError location="{Location/text()}">
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
</xsl:if>
</RegistryResponse>

</xsl:template>
</xsl:stylesheet>
