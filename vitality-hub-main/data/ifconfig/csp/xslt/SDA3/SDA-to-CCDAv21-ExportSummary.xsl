<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:import href="SDA-to-CCDAv21-TocRefSummary.xsl"/>
	
	<xsl:template match="*" mode="document-isExportSummary">1</xsl:template>
	
	<xsl:template match="*" mode="document-originalTitle">C-CDA2.1 Export Summary</xsl:template>
</xsl:stylesheet>
