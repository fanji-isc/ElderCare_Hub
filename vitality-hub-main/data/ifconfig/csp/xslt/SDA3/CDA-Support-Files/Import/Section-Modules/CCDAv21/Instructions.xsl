<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sIns-InstructionsSection">
		<!--
			Although C-CDA Instructions section has both narrative and entries, 
			we get SDA NoteText using the narrative as the source as there is no 
			gurantee on the way the entry is tied to the narrative in the C-CDA document.
		-->		
		<xsl:if test="hl7:text">
			<xsl:choose>
				<xsl:when test="hl7:text/hl7:table/hl7:tbody/hl7:tr">		
					<!--Map instruction in each table row to a recommendation -->
					<xsl:for-each select="hl7:text/hl7:table/hl7:tbody/hl7:tr">
						<Recommendation>
							<NoteText><xsl:apply-templates select="." mode="fn-importNarrative"/></NoteText>
						</Recommendation>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>		
					<!--Default is to get text content directly where there is no table-->			
					<Recommendation>						
						<NoteText><xsl:apply-templates select="hl7:text" mode="fn-importNarrative"/></NoteText>
					</Recommendation>
				</xsl:otherwise>			
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>