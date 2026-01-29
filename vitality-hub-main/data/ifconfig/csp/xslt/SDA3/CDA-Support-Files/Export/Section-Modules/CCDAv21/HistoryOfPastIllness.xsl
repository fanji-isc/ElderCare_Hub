<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
  <!-- Entry module has non-parallel name. AlsoInclude: Condition.xsl -->
  
	<xsl:template match="*" mode="sHOPasI-pastIllness">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="currentConditionStatusCodes" select="$exportConfiguration/problems/currentCondition/codes/text()"/>
		<xsl:variable name="currentConditionWindowInDays" select="$exportConfiguration/problems/currentCondition/windowInDays/text()"/>
		<xsl:variable name="hasData" select="count(Problems/Problem[not(contains($currentConditionStatusCodes, concat('|', Status/Code/text(), '|'))
			                                       or not(ToTime)
			                                       or (isc:evaluate('dateDiff', 'dd', translate(translate(FromTime/text(), 'Z', ''), 'T', ' ')) &lt;= $currentConditionWindowInDays))])"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/pastIllness/emptySection/exportData/text()"/>

		<!-- imported section narratives -->
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-HistoryOfPastIllnessSection]/code/@code)]"/>
		<xsl:variable name="hasDocs" select="count($docs)"/>

		<xsl:if test="($hasDocs > 0) or ($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="($hasDocs = 0) and ($hasData = 0)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sHOPasI-templateIds-pastIllnessSection"/>
					
					<code code="11348-0" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="History of Past Illness"/>
					<title>History of Past Illness</title>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="." mode="eCn-conditions-Narrative">
								<xsl:with-param name="useCurrentConditions" select="false()"/>
								<xsl:with-param name="narrativeLinkCategory">pastIllness</xsl:with-param>
								<xsl:with-param name="docs" select="$docs"/>
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="eCn-conditions-Entries">
								<xsl:with-param name="useCurrentConditions" select="false()"/>
								<xsl:with-param name="narrativeLinkCategory">pastIllness</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$hasDocs > 0">
							<text>
								<xsl:apply-templates mode="narrative-export-documents" select=".">
									<xsl:with-param name="docs" select="$docs"/>
								</xsl:apply-templates>
							</text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eCn-pastIllness-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sHOPasI-templateIds-pastIllnessSection">
		<templateId root="{$ccda-HistoryOfPastIllnessSection}"/>
		<templateId root="{$ccda-HistoryOfPastIllnessSection}" extension="2015-08-01"/>
	</xsl:template>
	
</xsl:stylesheet>