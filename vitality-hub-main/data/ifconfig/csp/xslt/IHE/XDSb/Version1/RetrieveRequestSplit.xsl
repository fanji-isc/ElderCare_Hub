<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
version="1.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007"
xmlns:exsl="http://exslt.org/common"
xmlns:set="http://exslt.org/sets"
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
exclude-result-prefixes="isc exsl set">

<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:template match="/XMLMessage">
<Messages>
<xsl:for-each select="set:distinct(//xdsb:RepositoryUniqueId/text())">
<xsl:call-template name="XMLMessage">
<xsl:with-param name="repoOID" select="."/>
</xsl:call-template>
</xsl:for-each>
</Messages>
</xsl:template>

<xsl:template name="XMLMessage">
<xsl:param name="repoOID"/>
<XMLMessage>
<Name>XDSb_RetrieveRequest</Name> 

<ContentStream>
<RetrieveDocumentSetRequest xmlns="urn:ihe:iti:xds-b:2007">
<xsl:for-each select="//xdsb:DocumentRequest[xdsb:RepositoryUniqueId/text()=$repoOID]">
<DocumentRequest>
<HomeCommunityId><xsl:value-of select="xdsb:HomeCommunityId/text()"/></HomeCommunityId>
<RepositoryUniqueId><xsl:value-of select="xdsb:RepositoryUniqueId/text()"/></RepositoryUniqueId> 
<DocumentUniqueId><xsl:value-of select="xdsb:DocumentUniqueId/text()"/></DocumentUniqueId> 
</DocumentRequest>
</xsl:for-each>
</RetrieveDocumentSetRequest>
</ContentStream>

<AdditionalInfo>
<xsl:for-each select="/XMLMessage/AdditionalInfo/AdditionalInfoItem">
<xsl:copy-of select="."/>
</xsl:for-each>
<xsl:call-template name="AddInfo">
<xsl:with-param name="key">SOAPAction</xsl:with-param>
<xsl:with-param name="value">urn:ihe:iti:2007:RetrieveDocumentSet</xsl:with-param>
</xsl:call-template>
<xsl:call-template name="AddInfo">
<xsl:with-param name="key">ServiceName</xsl:with-param>
<xsl:with-param name="value">
<xsl:value-of select="isc:evaluate('getServiceNameFromOID',$repoOID,'Repository','XDSb.Retrieve')"/>
</xsl:with-param>
</xsl:call-template>
<xsl:call-template name="AddInfo">
<xsl:with-param name="key">Repository</xsl:with-param>
<xsl:with-param name="value" select="$repoOID"/>
</xsl:call-template>
</AdditionalInfo>
</XMLMessage>
</xsl:template>

<xsl:template name="AddInfo">
<xsl:param name="key"/>
<xsl:param name="value"/>
<xsl:if test="not(/XMLMessage/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey=$key])">
<AdditionalInfoItem AdditionalInfoKey="{$key}">
<xsl:value-of select="$value"/>
</AdditionalInfoItem>
</xsl:if>
</xsl:template>
</xsl:stylesheet>
