<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="eER-entryRelationship">
		<xsl:param name="relationshipTypeCode" select="'REFR'"/>

		<entryRelationship typeCode="{$relationshipTypeCode}">
			<act classCode="ACT" moodCode="EVN">
				<xsl:apply-templates select="." mode="eER-templateIds"/>
				<xsl:apply-templates select="." mode="fn-id-External-CarePlan">
		          <xsl:with-param name="externalId" select="."/>
		        </xsl:apply-templates>
				<code nullFlavor="NP" />
				<statusCode code="completed" />
			</act>
		</entryRelationship>
	</xsl:template>

    <xsl:template match="*" mode="eER-templateIds">
        <templateId root="{$ccda-EntryReference}"/>
    </xsl:template>
</xsl:stylesheet>