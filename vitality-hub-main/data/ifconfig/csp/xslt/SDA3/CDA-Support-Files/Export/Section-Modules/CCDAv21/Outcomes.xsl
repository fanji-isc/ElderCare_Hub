<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com"
  xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

  <xsl:template match="*" mode="sHSO-HealthStatusAndOutcomes">
    <xsl:param name="sectionRequired" select="'0'"/>
    <xsl:param name="entriesRequired" select="'0'"/>
    
    <xsl:variable name="hasData" select="count(CarePlans/CarePlan/Outcomes/Outcome)"/>
    <xsl:if test="($hasData > 0) or ($sectionRequired = '1')">
      <component>
        <section>
          <xsl:if test="$hasData = 0">
            <xsl:attribute name="nullFlavor">NI</xsl:attribute>
          </xsl:if>
          <xsl:call-template name="sHSO-templateIds-outcomes"/>
          <code code="11383-7" displayName="Outcomes" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>

          <title>Health Status and Outcomes Section</title>
          <xsl:choose>
            <xsl:when test="$hasData > 0">
              <xsl:apply-templates select="CarePlans/CarePlan/Outcomes" mode="eHSO-outcomes-Narrative"/>
              <xsl:apply-templates select="CarePlans/CarePlan/Outcomes" mode="eHSO-outcomes-Entries"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="eHSO-outcomes-NoData"/>
            </xsl:otherwise>
          </xsl:choose>
        </section>
      </component>
    </xsl:if>
  </xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  
  <xsl:template name="sHSO-templateIds-outcomes">
    <templateId root="{$ccda-HealthStatusAndOutcomesSection}"/>
  </xsl:template>

</xsl:stylesheet>