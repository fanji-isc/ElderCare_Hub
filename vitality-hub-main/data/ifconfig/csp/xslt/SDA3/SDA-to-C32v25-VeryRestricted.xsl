<?xml version="1.0" encoding="UTF-8"?>
<!-- C32v25 summary with very-restricted confidentialityCode -->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<xsl:include href="SDA-to-C32v25.xsl"/>

	<xsl:template mode="document-confidentialityCode" match="Container">
	<confidentialityCode code="V" codeSystem="2.16.840.1.113883.5.25" displayName="Very Restricted"/>
	</xsl:template>
</xsl:stylesheet>
