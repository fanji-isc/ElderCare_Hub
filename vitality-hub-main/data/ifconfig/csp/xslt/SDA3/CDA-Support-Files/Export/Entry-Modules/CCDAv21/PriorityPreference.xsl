<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="Priority" mode="ePP-entryRelationship">
		<xsl:param name="relationshipTypeCode" select="'REFR'"/>

		<entryRelationship typeCode="{$relationshipTypeCode}">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="ePP-templateIds"/>
				<id nullFlavor="NI"/>
				<code code="225773000" displayName="Preference"  codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" />
				<xsl:apply-templates select="."	mode="fn-generic-Coded" >
					<xsl:with-param name="cdaElementName">value</xsl:with-param>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
				</xsl:apply-templates>
			</observation>
		</entryRelationship>
		
	</xsl:template>

    <xsl:template match="*" mode="ePP-templateIds">
        <templateId root="{$ccda-PriorityPreference}"/>
    </xsl:template>

</xsl:stylesheet>