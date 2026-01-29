<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="Document" mode="eA-assessment-NarrativeDetail">	
		<xsl:param name="AssessmentNarrativeDetailSuffix"/>				
					
		<xsl:if test="string-length(NoteText/text()) > 0" >
			<tr>
				<td ID="{concat('Assessment-', $AssessmentNarrativeDetailSuffix)}">
					<xsl:value-of select="NoteText/text()"/>
				</td>
				<td ID="{concat('EncounterNumber-', $AssessmentNarrativeDetailSuffix)}">
					<xsl:value-of select="EncounterNumber/text()"/>
				</td>	
			</tr>
		</xsl:if>			

	</xsl:template>
	
</xsl:stylesheet>
