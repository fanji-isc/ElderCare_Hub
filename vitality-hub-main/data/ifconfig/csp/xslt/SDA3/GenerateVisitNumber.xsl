<?xml version="1.0"?>
<!-- Generate an encounter number for encounters that lack on in SDA3 -->
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc" version="1.0">
<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>

<xsl:template match="Encounter">
	<xsl:variable name="visitNumber">
		<xsl:choose>
			<xsl:when test="string-length(EncounterNumber) = 0"><xsl:value-of select="isc:evaluate('generateVisitNumber')"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="EncounterNumber"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:copy>
			<EncounterNumber><xsl:value-of select="$visitNumber"/></EncounterNumber>
			<xsl:apply-templates select="*[not(self::EncounterNumber)]"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>

