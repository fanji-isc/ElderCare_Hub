<?xml version="1.0"?>
<!-- Reduces input SDA to a patient containing just a list of encounters with basic information in reverse chronological order by default-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				version="1.0">
<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
<xsl:param name="sortOrder" select="''"/>

<xsl:template match="/">
<Container>
	<Encounters>
		<xsl:apply-templates select="/Container/Encounters/Encounter">
			<xsl:sort select="string-length(EndTime)=0" order="{$sortOrder}"/>
			<xsl:sort select="EndTime" order="{$sortOrder}"/>
			<xsl:sort select="FromTime" order="{$sortOrder}"/>
		</xsl:apply-templates>
	</Encounters>
</Container>
</xsl:template>

 <xsl:template match="Encounter">
	<xsl:if test="not(EncounterType = 'S' or EncounterType = 'G')">
		<xsl:copy>
			<xsl:for-each select="EncounterNumber | FromTime | ToTime | EncounterType | ExternalId">
				<xsl:copy><xsl:apply-templates /></xsl:copy>
			</xsl:for-each>
			<HealthCareFacility><Organization><Code><xsl:value-of select="HealthCareFacility/Organization/Code"/></Code></Organization></HealthCareFacility>
		</xsl:copy>
	</xsl:if>  
</xsl:template>

</xsl:stylesheet>