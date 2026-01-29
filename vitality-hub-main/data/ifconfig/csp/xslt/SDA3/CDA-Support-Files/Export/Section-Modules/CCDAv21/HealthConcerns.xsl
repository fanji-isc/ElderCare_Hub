<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com"
  xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

  <xsl:template match="*" mode="sHC-HealthConcerns">
    <xsl:param name="sectionRequired" select="'0'"/>
    <xsl:param name="entriesRequired" select="'0'"/>
    
    <xsl:variable name="hasData" select="count(HealthConcerns/HealthConcern)"/>
    <xsl:if test="($hasData > 0) or ($sectionRequired = '1')">
      <component>
        <section>
          <xsl:if test="$hasData = 0">
            <xsl:attribute name="nullFlavor">NI</xsl:attribute>
          </xsl:if>
          <xsl:call-template name="sHC-templateIds-healthConcerns"/>
          <code code="75310-3" displayName="Health Concerns Document" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
          <title>Health Concerns Section</title>
          <xsl:choose>
            <xsl:when test="$hasData > 0">
              <xsl:apply-templates select="HealthConcerns" mode="eHC-healthConcerns-Narrative"/>
              <xsl:apply-templates select="HealthConcerns" mode="eHC-healthConcerns-Entries"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="sHC-healthConcerns-NoData"/>
            </xsl:otherwise>
          </xsl:choose>
        </section>
      </component>
    </xsl:if>
  </xsl:template>

  <xsl:template name="sHC-healthConcerns-NoData">
    <text><xsl:value-of select="$exportConfiguration/healthConcern/emptySection/narrativeText/text()"/></text>
  </xsl:template>  


  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  
  <xsl:template name="sHC-templateIds-healthConcerns">
    <templateId root="{$ccda-HealthConcernsSection}" extension="2015-08-01"/>
  </xsl:template>

</xsl:stylesheet>