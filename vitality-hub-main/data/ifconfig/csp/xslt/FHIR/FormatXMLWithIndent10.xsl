<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc" version="1.0">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->
<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

<xsl:template match="//@* | //node()">
<xsl:copy>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates select="node()"/>
</xsl:copy>
</xsl:template>
</xsl:stylesheet>
