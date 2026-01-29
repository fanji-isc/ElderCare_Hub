<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="hl7:ClinicalDocument" mode="sRFV-ReasonForVisitSection">
		<!--
			The SDA source for Reason for Visit is Encounter/VisitDescription.
			This template is called within the context of an Encounter import.
			Because there is no CDA means to tie a Reason for Visit to an
			Encounter, it is assumed that any Reason for Visit that is found
			is intended for the currently-being-imported Encounter.
		-->
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-ReasonForVisitSection)" mode="sRFV-ReasonForVisitSection-Narrative"/>
	</xsl:template>
			
	<xsl:template match="hl7:section" mode="sRFV-ReasonForVisitSection-Narrative">
		<!--
			C-CDA Reason For Visit is narrative only, no entries.
			Get SDA VisitDescription using the narrative as the
			source.
		-->
		<VisitDescription>
			<xsl:apply-templates select="hl7:text" mode="fn-importNarrative"/>
		</VisitDescription>
	</xsl:template>
	
</xsl:stylesheet>