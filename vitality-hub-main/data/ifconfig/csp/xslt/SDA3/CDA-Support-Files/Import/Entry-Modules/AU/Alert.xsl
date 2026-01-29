<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Alert">		
		<Alert>
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- Alert Type -->
			<xsl:apply-templates select="." mode="AlertType"/>
			
			<!-- Alert -->
			<xsl:apply-templates select="." mode="AlertAlert"/>
						
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Alert"/>
		</Alert>
	</xsl:template>
	
	<xsl:template match="*" mode="AlertAlert">
		<xsl:apply-templates select="hl7:value" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'Alert'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="AlertType">
		<xsl:apply-templates select="hl7:code" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'AlertType'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.	
		The input node spec is $sectionRootPath/hl7:entry/hl7:observation.
	-->
	<xsl:template match="*" mode="ImportCustom-Alert">
	</xsl:template>
</xsl:stylesheet>
