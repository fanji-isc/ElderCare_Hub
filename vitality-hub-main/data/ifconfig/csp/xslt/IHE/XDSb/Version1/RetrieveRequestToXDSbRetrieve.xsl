<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:xdsb="urn:ihe:iti:xds-b:2007"
version="1.0"  exclude-result-prefixes="isc">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/RetrieveRequest">
<xdsb:RetrieveDocumentSetRequest>
<xsl:for-each select="Documents/ProvidedDocument">
<xdsb:DocumentRequest>
<xsl:if test="@home!=''">
<xdsb:HomeCommunityId><xsl:value-of select="@home"/></xdsb:HomeCommunityId>
</xsl:if>
<xdsb:RepositoryUniqueId><xsl:value-of select="RepositoryUniqueId/text()"/></xdsb:RepositoryUniqueId> 
<xdsb:DocumentUniqueId><xsl:value-of select="UniqueId/text()"/></xdsb:DocumentUniqueId> 
</xdsb:DocumentRequest>
</xsl:for-each>
</xdsb:RetrieveDocumentSetRequest>

</xsl:template>


</xsl:stylesheet>
