<!-- This will un-compact the code table storage in streamlets -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:isc="http://extension-functions.intersystems.com"
				version="1.0"
				exclude-result-prefixes="isc">
	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
	<xsl:strip-space elements="*"/>

<xsl:template match="/">
<xsl:apply-templates mode="noc3"/>
</xsl:template>

<xsl:template match="@*|node()" mode="noc3">
	<xsl:choose>
		<xsl:when test="local-name()='Code'">
			<Code><xsl:value-of select="."/></Code>
			<xsl:variable name="desc" select="../Description"/>
			<xsl:if test="string($desc)=''"><Description><xsl:value-of select="."/></Description></xsl:if>
		</xsl:when>
		<xsl:when test="local-name()!='c3'">
			<xsl:copy>
			  <xsl:apply-templates select="@*|node()" mode="noc3"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="c3process"/>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
<xsl:template name="c3process">
	<xsl:variable name="c3val" select="."/>
	<xsl:variable name="compact" select="concat($c3val,'^^')"/>
	<xsl:variable name="codesys" select="substring-before($compact,'^')"/>
	<xsl:variable name="rest" select="substring-after($compact,'^')"/>
	<xsl:variable name="code" select="substring-before($rest,'^')"/>
	<xsl:variable name="desc" select="substring-before(substring-after($rest,'^'),'^')"/>
	<xsl:if test="$codesys!=''">
		<SDACodingStandard><xsl:value-of select="$codesys"/></SDACodingStandard>
	</xsl:if>
	<Code><xsl:value-of select="$code"/></Code>
	<Description><!--xsl:value-of select="$desc"/-->
	<xsl:choose>
		<xsl:when test="$desc=''"><xsl:value-of select="$code"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$desc"/></xsl:otherwise>
	</xsl:choose>
	</Description>
</xsl:template>

</xsl:stylesheet>