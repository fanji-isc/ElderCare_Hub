<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:ihe:iti:xds-b:2007" xmlns:xdsb="urn:ihe:iti:xds-b:2007" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   exclude-result-prefixes="isc xdsb">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:template match="/DocumentRequests">
<RetrieveDocumentSetRequest xmlns="urn:ihe:iti:xds-b:2007" >
<xsl:for-each select="./Request/DocumentRequest">
<DocumentRequest>
<HomeCommunityId>urn:oid:<xsl:value-of select="./HomeCommunityId/text()"/></HomeCommunityId>
<RepositoryUniqueId><xsl:value-of select="./RepositoryUniqueId/text()"/></RepositoryUniqueId>
<DocumentUniqueId><xsl:value-of select="./DocumentUniqueId/text()"/></DocumentUniqueId>
</DocumentRequest>
</xsl:for-each>
</RetrieveDocumentSetRequest>
</xsl:template>
</xsl:stylesheet>
