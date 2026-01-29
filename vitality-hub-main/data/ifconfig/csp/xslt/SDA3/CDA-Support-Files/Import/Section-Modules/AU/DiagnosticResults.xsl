<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

<!-- Insert an order with corresponding Laboratory results-->
	<xsl:template match="*" mode="LabResults">		
		<xsl:if test="isc:evaluate('varGet', 'LabOrderActionCodeDone')=0">
			<xsl:call-template name="ActionCode">
				<xsl:with-param name="informationType" select="'LabOrder'"/>
				<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
				<xsl:with-param name="positionOneRequired" select="'0'"/>
			</xsl:call-template>
			<xsl:if test="isc:evaluate('varSet', 'LabOrderActionCodeDone', '1')"></xsl:if>
		</xsl:if>
		<xsl:apply-templates select="." mode="Result"><xsl:with-param name="elementName" select="'LabOrder'"/></xsl:apply-templates>
	</xsl:template>

<!-- Insert an order with corresponding Radiology results-->
	<xsl:template match="*" mode="RadResults">
		<xsl:if test="isc:evaluate('varGet', 'RadOrderActionCodeDone')=0">
			<xsl:call-template name="ActionCode">
				<xsl:with-param name="informationType" select="'RadOrder'"/>
				<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
				<xsl:with-param name="positionOneRequired" select="'0'"/>
			</xsl:call-template>
			<xsl:if test="isc:evaluate('varSet', 'RadOrderActionCodeDone', '1')"></xsl:if>
		</xsl:if>
		<xsl:apply-templates select="." mode="Result"><xsl:with-param name="elementName" select="'RadOrder'"/></xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
