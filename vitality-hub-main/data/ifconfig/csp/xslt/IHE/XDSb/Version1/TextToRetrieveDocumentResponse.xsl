<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns="urn:ihe:iti:xds-b:2007" xmlns:ihe="urn:ihe:iti:xds-b:2007" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xop="http://www.w3.org/2004/08/xop/include" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:include href="Variables.xsl"/>
<xsl:param name="repositoryOID"/>
<xsl:param name="status"/>
<xsl:variable name="prefix" select="'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:'"/>

<xsl:template match="/">

<ihe:RetrieveDocumentSetResponse xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:ihe="urn:ihe:iti:xds-b:2007" xmlns="urn:ihe:iti:xds-b:2007" xmlns:xop="http://www.w3.org/2004/08/xop/include">
<rs:RegistryResponse>
<xsl:attribute name="status">
<xsl:choose>
<xsl:when test="$status='Success'">
<xsl:value-of select='$success'/>
</xsl:when>
<xsl:when test="$status='Failure'">
<xsl:value-of select='$failure'/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select='$partial'/>
</xsl:otherwise>
</xsl:choose>
</xsl:attribute>

<xsl:if test="$status != 'Success'">
<rs:RegistryErrorList highestSeverity="{concat($prefix,/root/Errors/HighestError/text())}">
<xsl:for-each select='/root/Errors/Error'>
<xsl:variable name="severity"/>
<rs:RegistryError codeContext="{Description/text()}" errorCode="{Code/text()}" location="{Location/text()}" severity="{concat($prefix,Severity/text())}" /> 
</xsl:for-each>
</rs:RegistryErrorList>
</xsl:if>
</rs:RegistryResponse>
<xsl:for-each select='root/DocInfo'>
<xsl:call-template name="DocumentResponse"/>
</xsl:for-each>
</ihe:RetrieveDocumentSetResponse>
</xsl:template>
<xsl:template name="DocumentResponse">
<xsl:for-each select=".">
<xsl:variable name='ContentId' select='@ContentId'/>
<xsl:variable name='mimeType' select='@mimeType'/>
<xsl:variable name='text' select='text()'/>  <!-- text is only set in testing scenarios where the document should be returned inline -->
<DocumentResponse>
<RepositoryUniqueId><xsl:value-of select='$repositoryOID'/></RepositoryUniqueId>
<DocumentUniqueId><xsl:value-of select='@id'/></DocumentUniqueId>
<mimeType><xsl:value-of select='$mimeType'/></mimeType>
<xsl:choose>
<xsl:when test="$text!=''">
<Document><xsl:value-of select='$text'/></Document>
</xsl:when>
<xsl:otherwise>
<Document><xop:Include href="{$ContentId}"/></Document>
</xsl:otherwise>
</xsl:choose>
</DocumentResponse>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>