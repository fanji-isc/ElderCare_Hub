<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:dns="http://ns.electronichealth.net.au/hi/svc/ConsumerSearchIHIBatchSyncRequest/3.0"
xmlns:s02="http://ns.electronichealth.net.au/hi/svc/ConsumerSearchIHI/3.0"
xmlns:x01="http://ns.electronichealth.net.au/hi/xsd/consumermessages/SearchIHI/3.0"
version="1.0" exclude-result-prefixes="isc xsl dns s02 x01" >

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

<xsl:template match="/*[local-name()]/dns:searchIHIBatchRequest/x01:searchIHI/s02:SAMLData">
</xsl:template>

</xsl:stylesheet>

