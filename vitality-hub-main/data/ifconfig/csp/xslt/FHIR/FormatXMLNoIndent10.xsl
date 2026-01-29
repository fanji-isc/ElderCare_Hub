<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:h="http://www.w3.org/1999/xhtml" exclude-result-prefixes="isc h" version="1.0">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->
<xsl:output method="xml" indent="no" encoding="UTF-8"/>
<xsl:strip-space elements="*" />
<xsl:preserve-space elements="h:head h:title h:meta h:body h:div h:p h:span h:em h:strong h:h1 h:h2 h:h3 h:h4 h:h5 h:h6 h:address h:dfn h:code h:samp h:kbd h:var h:cite h:abbr h:acronym h:blockquote h:q h:br h:pre h:ul h:ol h:li h:dl h:dt h:dd h:dir h:menu h:table h:caption h:thead h:tfoot h:tbody h:colgroup h:col h:tr h:th h:td" />

<xsl:template match="//@* | //node()">
<xsl:copy>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates select="node()"/>
</xsl:copy>
</xsl:template>
</xsl:stylesheet>
