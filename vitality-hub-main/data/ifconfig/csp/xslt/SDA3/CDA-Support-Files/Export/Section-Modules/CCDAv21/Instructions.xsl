<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	

	<!--The assumption is that only the first Encounter is concerned when exporting to the instruction section-->
	<xsl:template match="*" mode="sIns-Instructions">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="count(Encounters/Encounter[1]/RecommendationsProvided/Recommendation[string-length(NoteText/text())>0])"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/instructions/emptySection/exportData/text()"/>

		<!-- imported section narratives -->
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-InstructionsSection]/code/@code)]"/>
		<xsl:variable name="hasDocs" select="count($docs)"/>

		<xsl:if test="($hasDocs > 0) or ($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="($hasDocs = 0) and ($hasData = 0)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sIns-templateIds-instructionsSection"/>
					
					<code code="69730-0" displayName="INSTRUCTIONS" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Instructions</title>
					
					<xsl:choose>
						<!-- use imported structured narrative document if there is one -->
						<xsl:when test="$hasDocs > 0">
							<text>
								<xsl:apply-templates mode="narrative-export-documents" select=".">
									<xsl:with-param name="docs" select="$docs"/>
								</xsl:apply-templates>
							</text>
						</xsl:when>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="Encounters/Encounter[1]" mode="sIns-Instructions-Narrative"/>
							<xsl:apply-templates select="Encounters/Encounter[1]" mode="sIns-Instructions-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="sIns-Instructions-NoData"/>
						</xsl:otherwise>
					</xsl:choose>				

				</section>
			</component>
		</xsl:if>
	</xsl:template>	

	<xsl:template match="Encounter" mode="sIns-Instructions-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Instruction</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="RecommendationsProvided/Recommendation" >
						<xsl:variable name="narrativeLinkSuffix" select="concat('Instructions-',position())"/>	
						
						<xsl:apply-templates select="NoteText" mode="eIns-Instructions-NarrativeDetail">
							<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
						</xsl:apply-templates>
    				</xsl:for-each> 					
				</tbody>
			</table>
		</text>		
	</xsl:template>

	<xsl:template match="Encounter" mode="sIns-Instructions-Entries">
    	<xsl:for-each select="RecommendationsProvided/Recommendation" >
        	<xsl:variable name="narrativeLinkSuffix" select="concat('Instructions-',position())"/>

		    <xsl:apply-templates select="NoteText" mode="eIns-Instructions-Entry">
		    	<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
		    </xsl:apply-templates>
    	</xsl:for-each>
  	</xsl:template>
	
	<xsl:template match="*" mode="sIns-Instructions-NoData">
		<text>
			<xsl:value-of select="$exportConfiguration/instructions/emptySection/narrativeText/text()"/>
		</text>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sIns-templateIds-instructionsSection">
		<templateId root="{$ccda-InstructionsSection}"/>
		<templateId root="{$ccda-InstructionsSection}" extension="2014-06-09"/>
	</xsl:template>


</xsl:stylesheet>
