<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com"
  xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

  <xsl:template match="*" mode="sIn-Interventions">
    <xsl:param name="sectionRequired" select="'0'"/>
    <xsl:param name="entriesRequired" select="'0'"/>
    
    <xsl:variable name="hasData" select="count(CarePlans/CarePlan/Interventions/Intervention)"/>

    <!-- imported section narratives -->
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-InterventionsSection]/code/@code)]"/>
    <xsl:variable name="hasDocs" select="count($docs)"/>

    <xsl:if test="($hasDocs > 0) or ($hasData > 0) or ($sectionRequired = '1')">
      <component>
        <section>
          <xsl:if test="($hasDocs = 0) and ($hasData = 0)">
            <xsl:attribute name="nullFlavor">NI</xsl:attribute>
          </xsl:if>
          <xsl:call-template name="sIn-templateIds-interventions"/>
          <code code="62387-6" displayName="Interventions" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
          <title>Interventions Section</title>
          <xsl:choose>
            <xsl:when test="$hasData > 0">
              <xsl:apply-templates select="CarePlans/CarePlan/Interventions" mode="eIn-interventions-Narrative">
                <xsl:with-param name="docs" select="$docs"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="CarePlans/CarePlan/Interventions" mode="eIn-interventions-Entries"/>
            </xsl:when>
            <xsl:when test="$hasDocs > 0">
              <text>
                <xsl:apply-templates mode="narrative-export-documents" select=".">
                  <xsl:with-param name="docs" select="$docs"/>
                </xsl:apply-templates>
              </text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="eIn-interventions-NoData"/>
            </xsl:otherwise>
          </xsl:choose>
        </section>
      </component>
    </xsl:if>
  </xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  
  <xsl:template name="sIn-templateIds-interventions">
    <templateId root="{$ccda-InterventionsSection}" extension="2015-08-01"/>
  </xsl:template>

</xsl:stylesheet>