<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:dns="http://ns.electronichealth.net.au/hi/svc/ProviderSearchForProviderOrganisation/5.0.0"
version="1.0" exclude-result-prefixes="isc xsl dns" >

<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:template match="//@* | //node()">
<xsl:copy>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates select="node()"/>
</xsl:copy>
</xsl:template>

<xsl:template match="/*[local-name()]/dns:AdditionalInfo">
</xsl:template>

<xsl:template match="/*[local-name()]/dns:SAMLData">
</xsl:template>

</xsl:stylesheet>

