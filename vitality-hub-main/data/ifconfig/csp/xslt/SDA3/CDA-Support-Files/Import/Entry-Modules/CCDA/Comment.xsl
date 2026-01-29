<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Comment">
		<xsl:param name="elementName" select="'Comments'"/>

		<xsl:variable name="textValue"><xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ']/hl7:act[hl7:templateId/@root=$ccda-CommentActivity]/hl7:text" mode="TextValue"/></xsl:variable>

		<xsl:if test="string-length($textValue)"><xsl:element name="{$elementName}"><xsl:value-of select="$textValue"/></xsl:element></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="Comment-Component">
		<xsl:param name="elementName" select="'Comments'"/>

		<xsl:variable name="textValue"><xsl:apply-templates select="hl7:component[@typeCode='COMP']/hl7:act[hl7:templateId/@root=$ccda-CommentActivity]/hl7:text" mode="TextValue"/></xsl:variable>

		<xsl:if test="string-length($textValue)"><xsl:element name="{$elementName}"><xsl:value-of select="$textValue"/></xsl:element></xsl:if>
	</xsl:template>
</xsl:stylesheet>
