<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
version="1.0" 

xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007" 
xmlns:xop="http://www.w3.org/2004/08/xop/include" 

xmlns:exsl="http://exslt.org/common"
xmlns:set="http://exslt.org/sets"
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
exclude-result-prefixes="isc exsl set">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:include href="Variables.xsl"/>
<xsl:param name="includeSlots" select='0'/>

<xsl:template match="/">
<Metadata>
<xsl:choose>
<xsl:when test="XMLMessage/ContentStream">
<xsl:apply-templates select="XMLMessage/ContentStream/*"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="*"/>   <!-- more typical pass the contentstream into the transform -->
</xsl:otherwise>
</xsl:choose>
</Metadata>
</xsl:template>

<xsl:template match="query:RetrieveDocumentSetResponse">
<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="xdsb:DocumentResponse">
<Document id='' type=''>
<xsl:if test="xdsb:HomeCommunityId">
<xsl:attribute name="home"><xsl:value-of select="xdsb:HomeCommunityId/text()"/></xsl:attribute>
</xsl:if>

<UniqueId>
<xsl:value-of select="xdsb:DocumentUniqueId/text()"/>
</UniqueId>

<RepositoryUniqueId>
<xsl:value-of select="xdsb:RepositoryUniqueId/text()"/>
</RepositoryUniqueId> 

<MimeType>
<xsl:value-of select="xdsb:mimeType/text()"/>
</MimeType> 

<XOP><xsl:value-of select="substring(xdsb:Document/xop:Include/@href,5)"/></XOP>

</Document>
</xsl:template>

<xsl:template match="rs:RegistryErrorList">
<Errors>
<xsl:apply-templates select="rs:RegistryError"/>
</Errors>
</xsl:template>

<xsl:template match="rs:RegistryError">
<Error>
<Code><xsl:value-of select="@errorCode"/></Code>
<Severity><xsl:value-of select="substring-after(@severity,'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:')"/></Severity>
<Description><xsl:value-of select="@codeContext"/></Description>
<Location><xsl:value-of select="@location"/></Location>
</Error>
</xsl:template>


<xsl:template mode="getStatus" match="@status">
<xsl:value-of select="substring-after(., 'urn:oasis:names:tc:ebxml-regrep:StatusType:')"/>
</xsl:template>


</xsl:stylesheet>