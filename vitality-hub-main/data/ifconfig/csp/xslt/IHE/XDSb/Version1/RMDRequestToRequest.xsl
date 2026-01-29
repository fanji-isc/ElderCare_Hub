<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:rmd="urn:ihe:iti:rmd:2017"
xmlns:xds="urn:ihe:iti:xds-b:2007"
exclude-result-prefixes="isc rmd xds xsi">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
<DeleteDocumentSetRequest>
<xsl:apply-templates select="/rmd:RemoveDocumentsRequest/xds:DocumentRequest"/>
</DeleteDocumentSetRequest>
</xsl:template>

<xsl:template match="/rmd:RemoveDocumentsRequest/xds:DocumentRequest">
<UniqueIdentifier UniqueIdentifierKey="{xds:DocumentUniqueId/text()}"><xsl:value-of select="xds:RepositoryUniqueId/text()"/></UniqueIdentifier>
</xsl:template>

</xsl:stylesheet>
