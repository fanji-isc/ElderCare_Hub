<!--Used to remove the top Container node to allow multiple containers to be concattenated in a PureQuery response-->
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" 
				exclude-result-prefixes="xsi isc"
				version="1.0">
<xsl:output method="xml" indent="no" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:template match="node() | @*">
  <xsl:copy>
    <xsl:apply-templates select="node() | @*" />
  </xsl:copy>
</xsl:template>

<!-- template for the document element -->
<xsl:template match="/*">
  <xsl:apply-templates select="node()" />
</xsl:template>	
</xsl:stylesheet>