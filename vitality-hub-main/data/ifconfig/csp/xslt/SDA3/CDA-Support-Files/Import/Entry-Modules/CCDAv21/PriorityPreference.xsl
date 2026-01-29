<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7 isc xsi sdtc exsl set">

	<xsl:template match="hl7:observation" mode="ePP-Priority">
		<!--
			StructuredMapping: Priority

			Field
			Target: Priority
			Source: value
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" >Priority</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

</xsl:stylesheet>