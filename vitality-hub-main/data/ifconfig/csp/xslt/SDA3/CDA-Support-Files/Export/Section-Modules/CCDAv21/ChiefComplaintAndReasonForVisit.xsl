<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="*" mode="sEDRFV-chiefComplaintAndReasonForVisit">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="encounterSet" select="Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())]"/>
		<xsl:variable name="hasData" select="count($encounterSet)"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/chiefComplaintAndReasonForVisit/emptySection/exportData/text()"/>

		<!-- imported section narratives -->
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-ChiefComplaintAndReasonForVisitSection]/code/@code)]"/>
		<xsl:variable name="hasDocs" select="count($docs)"/>

		<xsl:if test="($hasDocs > 0) or ($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="($hasDocs = 0) and ($hasData = 0)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sEDRFV-templateIds-ccda-chiefComplaintAndReasonForVisitSection"/>
					
					<code code="46239-0" displayName="CHIEF COMPLAINT AND REASON FOR VISIT" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Chief Complaint and Reason for Visit</title>
					
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
							<text>							
								<xsl:for-each select="$encounterSet">									
									<content>
										<xsl:value-of select="VisitDescription/text()"/>
									</content>
								</xsl:for-each>	
							</text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="sEDRFV-chiefComplaintAndReasonForVisit-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="sEDRFV-chiefComplaintAndReasonForVisit-NoData">
		<text><xsl:value-of select="$exportConfiguration/chiefComplaintAndReasonForVisit/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sEDRFV-templateIds-ccda-chiefComplaintAndReasonForVisitSection">
		<templateId root="{$ccda-ChiefComplaintAndReasonForVisitSection}"/>
		<templateId root="{$ccda-ChiefComplaintAndReasonForVisitSection}" extension="2015-08-01"/>
	</xsl:template>
</xsl:stylesheet>
