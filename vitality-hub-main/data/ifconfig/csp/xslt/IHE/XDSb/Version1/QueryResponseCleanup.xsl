<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" 
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
version="1.0"  exclude-result-prefixes="isc">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
<query:AdhocQueryResponse xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
 status="{/QueryResponse/ContentStream/query:AdhocQueryResponse/@status}" 
 >
<rim:RegistryObjectList xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0"/>
<xsl:for-each select="/QueryResponse/Document">
<xsl:variable name="foundID" select="@id"/>
<xsl:copy-of select="/QueryResponse/ContentStream/query:AdhocQueryResponse/rim:RegistryObjectList/rim:ExtrinsicObject[@id=$foundID]"/>
</xsl:for-each>
</query:AdhocQueryResponse>
</xsl:template>


</xsl:stylesheet>
