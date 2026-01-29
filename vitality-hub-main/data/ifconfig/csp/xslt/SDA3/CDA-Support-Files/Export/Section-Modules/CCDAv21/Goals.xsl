<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

    <xsl:template match="*" mode="sG-Goals">
        <xsl:param name="sectionRequired" select="'0'"/>
        <xsl:param name="entriesRequired" select="'0'"/>
        <xsl:variable name="hasData" select="count(Goals/Goal)"/>

        <!-- imported section narratives -->
        <xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-GoalsSection]/code/@code)]"/>
        <xsl:variable name="hasDocs" select="count($docs)"/>

        <xsl:if test="($hasDocs > 0) or ($hasData > 0) or ($sectionRequired='1')">
            <component>
                <section>
                    <xsl:if test="($hasDocs = 0) and ($hasData = 0)">
                        <xsl:attribute name="nullFlavor">NI</xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="sG-templateIds-goals"/>
                    <code code="61146-7" displayName="Goals" codeSystem="{$loincOID}" codeSystemName="{$loincName}" />
                    <title>Goals Section</title>
                    <xsl:choose>
                        <xsl:when test="$hasData > 0">
                            <xsl:apply-templates select="Goals" mode="eG-goals-Narrative">
                              <xsl:with-param name="docs" select="$docs"/>
                            </xsl:apply-templates>
                            <xsl:apply-templates select="Goals" mode="eG-goals-Entries"/>
                        </xsl:when>
                        <xsl:when test="$hasDocs > 0">
                          <text>
                            <xsl:apply-templates mode="narrative-export-documents" select=".">
                              <xsl:with-param name="docs" select="$docs"/>
                            </xsl:apply-templates>
                          </text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="sG-goals-NoData"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </section>
            </component>
        </xsl:if>
    </xsl:template>

    <xsl:template name="sG-goals-NoData">
        <text><xsl:value-of select="$exportConfiguration/goal/emptySection/narrativeText/text()"/></text>
    </xsl:template>    

  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  
  <xsl:template name="sG-templateIds-goals">
    <templateId root="{$ccda-GoalsSection}"/>
  </xsl:template>

</xsl:stylesheet>