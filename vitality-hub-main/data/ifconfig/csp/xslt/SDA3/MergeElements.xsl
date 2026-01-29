<?xml version="1.0"?>
<!-- Combine node sets under the same top-level elements in SDA-->
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>

<!-- Insert the first element, then loop through the node sets of subsequent elements with the same name -->
<xsl:template match="/Container/*"> 
	<xsl:variable name="elementName" select="local-name()"/>
	<xsl:if test="count(preceding-sibling::*[name()=$elementName])=0">
			<xsl:copy>
				<xsl:apply-templates/>
				<xsl:for-each select="following-sibling::*[name()=$elementName]">
						<xsl:apply-templates/>
				</xsl:for-each>
			</xsl:copy>
		</xsl:if>
</xsl:template>

<!-- Identity template to copy all other elements not explicitly matched-->
<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>