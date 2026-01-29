<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:isc="http://extension-functions.intersystems.com"
	xmlns:hl7="urn:hl7-org:v3"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:exsl="http://exslt.org/common"
	exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="ReasonForVisitSection">
		<!--
			The SDA source for Reason for Visit is Encounter/VisitDescription.
			This template is called within the context of an Encounter import.
			Because there is no CDA means to tie a Reason for Visit to an
			Encounter, it is assumed that any Reason for Visit that is found
			is intended for the currently-being-imported Encounter.
		-->
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-ReasonForVisitSection]" mode="ReasonForVisitSection-Narrative"/>
	</xsl:template>
			
	<xsl:template match="*" mode="ReasonForVisitSection-Narrative">
		<!--
			C-CDA Reason For Visit is narrative only, no entries.
			Get SDA VisitDescription using the narrative as the
			source.
		-->
		<VisitDescription>
			<xsl:apply-templates select="hl7:text" mode="importNarrative"/>
		</VisitDescription>
	</xsl:template>	
</xsl:stylesheet>
