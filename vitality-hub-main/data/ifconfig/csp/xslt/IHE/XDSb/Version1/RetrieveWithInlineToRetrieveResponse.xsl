<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:xdsb="urn:ihe:iti:xds-b:2007"
version="1.0"  exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:template match="/root/original/xdsb:RetrieveDocumentSetResponse">
<xdsb:RetrieveDocumentSetResponse>
<rs:RegistryResponse xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" status="{./rs:RegistryResponse/@status}"/>
<xsl:for-each select="xdsb:DocumentResponse">
<xdsb:DocumentResponse>
<xsl:if test="xdsb:HomeCommunityId/text()!=''">
<xdsb:HomeCommunityId><xsl:value-of select="xdsb:HomeCommunityId/text()"/></xdsb:HomeCommunityId>
</xsl:if>
<xdsb:RepositoryUniqueId><xsl:value-of select="xdsb:RepositoryUniqueId/text()"/></xdsb:RepositoryUniqueId> 
<xdsb:DocumentUniqueId><xsl:value-of select="xdsb:DocumentUniqueId/text()"/></xdsb:DocumentUniqueId> 
<xdsb:mimeType><xsl:value-of select="xdsb:mimeType/text()"/></xdsb:mimeType>
<xsl:choose>
<xsl:when test="/root/document[position()]/text()=''">
<xdsb:Document><xsl:copy-of select="xdsb:Document/node()"/></xdsb:Document>
</xsl:when>
<xsl:otherwise>
<xdsb:Document><xsl:copy-of select="/root/document[position()]/node()"/></xdsb:Document>
</xsl:otherwise>
</xsl:choose>
</xdsb:DocumentResponse>
</xsl:for-each>
</xdsb:RetrieveDocumentSetResponse>
</xsl:template>

</xsl:stylesheet>
