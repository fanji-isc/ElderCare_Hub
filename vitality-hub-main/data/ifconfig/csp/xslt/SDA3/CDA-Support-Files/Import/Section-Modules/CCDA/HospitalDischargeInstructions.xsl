<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:isc="http://extension-functions.intersystems.com"
	xmlns:hl7="urn:hl7-org:v3"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:exsl="http://exslt.org/common"
	exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="DischargeInstructionsSection-Narrative">
		<!--
			C-CDA Hospital Discharge Instructions is narrative only,
			no entries. Get SDA NoteText using the narrative as the
			source.
		-->
		<Recommendation>
			<NoteText><xsl:apply-templates select="hl7:text" mode="importNarrative"/></NoteText>
		</Recommendation>
	</xsl:template>
</xsl:stylesheet>
