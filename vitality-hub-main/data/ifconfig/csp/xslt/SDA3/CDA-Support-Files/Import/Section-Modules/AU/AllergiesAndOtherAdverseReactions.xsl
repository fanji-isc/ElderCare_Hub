<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Allergies-Discharge">
		<Allergies>
			<!-- Process CDA Append/Transform/Replace Directive -->
			<xsl:call-template name="ActionCode">
				<xsl:with-param name="informationType" select="'Allergy'"/>
			</xsl:call-template>
			
			<xsl:apply-templates select="hl7:entry/hl7:observation" mode="Allergy-Discharge"/>
		</Allergies>
	</xsl:template>
	
	<xsl:template match="*" mode="Allergies">
		<Allergies>
			<!-- Process CDA Append/Transform/Replace Directive -->
			<xsl:call-template name="ActionCode">
				<xsl:with-param name="informationType" select="'Allergy'"/>
			</xsl:call-template>
			
			<xsl:apply-templates select="hl7:entry/hl7:act" mode="Allergy"/>
		</Allergies>
	</xsl:template>
</xsl:stylesheet>
