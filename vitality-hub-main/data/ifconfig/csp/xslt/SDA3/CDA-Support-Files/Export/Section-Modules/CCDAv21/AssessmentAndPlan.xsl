<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
  
  <xsl:template match="*" mode="sANP-assessmentAndPlan">
    <xsl:param name="sectionRequired" select="'0'"/>
    
    <xsl:variable name="hasData" select="Documents/Document[DocumentType/Description/text()='AssessmentAndPlan' or DocumentType/Code/text()='AssessmentAndPlan']"/>
    <xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/assessmentAndPlan/emptySection/exportData/text()"/>

    <!-- imported section narratives -->
    <xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-AssessmentAndPlanSection]/code/@code)]"/>
    <xsl:variable name="hasDocs" select="count($docs)"/>

    <xsl:if test="($hasDocs > 0) or ($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
      <component>
        <section>
          <xsl:call-template name="sANP-templateIds-assessmentAndPlanSection"/>
          
          <!-- IHE needs unique id for each and every section -->
          <id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
          
          <code code="51847-2" displayName="Assessment and Plan" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
          <title>Assessment and Plan</title>
          
          <xsl:choose>
            <xsl:when test="$hasData">
              <xsl:apply-templates select="." mode="eANP-assessmentAndPlan-Narrative">
                <xsl:with-param name="docs" select="$docs"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="eANP-assessmentAndPlan-Entries"/>
            </xsl:when>
            <xsl:when test="$hasDocs > 0">
              <text>
                <xsl:apply-templates mode="narrative-export-documents" select=".">
                  <xsl:with-param name="docs" select="$docs"/>
                </xsl:apply-templates>
              </text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="eANP-assessmentAndPlan-NoData"/>
            </xsl:otherwise>
          </xsl:choose>
        </section>
      </component>
    </xsl:if>
  </xsl:template>
  
  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  
  <xsl:template name="sANP-templateIds-assessmentAndPlanSection">
    <xsl:if test="$ccda-AssessmentAndPlanSection"><templateId root="{$ccda-AssessmentAndPlanSection}"/></xsl:if>
  </xsl:template>
  
</xsl:stylesheet>