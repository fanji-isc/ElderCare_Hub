<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sHDI-DischargeInstructionsSection-Narrative">
		<!--
			C-CDA Hospital Discharge Instructions is narrative only,
			no entries. Get SDA NoteText using the narrative as the
			source.
		-->
		<Recommendation>
			<NoteText><xsl:apply-templates select="hl7:text" mode="fn-importNarrative"/></NoteText>
		</Recommendation>
	</xsl:template>
	
</xsl:stylesheet>