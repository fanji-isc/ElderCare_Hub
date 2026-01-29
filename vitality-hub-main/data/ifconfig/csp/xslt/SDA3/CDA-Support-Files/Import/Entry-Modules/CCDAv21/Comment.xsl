<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="eCm-Comment">
		<xsl:param name="emitElementName" select="'Comments'"/>
		
		<xsl:variable name="textValue">
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ']/hl7:act[hl7:templateId/@root=$ccda-CommentActivity]/hl7:text" mode="fn-TextValue"/>
		</xsl:variable>

		<xsl:if test="string-length($textValue) > 0">
			<xsl:element name="{$emitElementName}"><xsl:value-of select="$textValue"/></xsl:element>			
		</xsl:if>

	</xsl:template>	
</xsl:stylesheet>