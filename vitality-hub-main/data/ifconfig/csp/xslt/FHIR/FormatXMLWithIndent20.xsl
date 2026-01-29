<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml" exclude-result-prefixes="h" version="2.0">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->
<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

<xsl:template match="element()">
<xsl:copy>
<xsl:apply-templates select="@*, node()"/>
</xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()">
<xsl:copy/>
</xsl:template>

</xsl:stylesheet>
