<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  
  
  <xsl:template match="NoteText" mode="eIns-Instructions-NarrativeDetail">
    <xsl:param name="narrativeLinkSuffix" select="'Instructions-'"/>		    
    
      <tr ID="{concat($exportConfiguration/instructions/narrativeLinkPrefixes/instructionsNarrative/text(), $narrativeLinkSuffix)}">
        <td>		        
          <xsl:value-of select="text()"/>
        </td>
      </tr>  

  </xsl:template>

  
  <xsl:template match="NoteText" mode="eIns-Instructions-Entry">
    <xsl:param name="narrativeLinkSuffix" select="'Instructions-'"/>
    
    <entry typeCode="DRIV">
      <act classCode="ACT" moodCode="INT">
        <xsl:call-template name="eIns-templateIds-Instruction"/>
        
        <xsl:apply-templates select="." mode="fn-id-External"/>
        
        <xsl:apply-templates select="." mode="fn-generic-Coded">
          <xsl:with-param name="isCodeRequired" select="'1'"/>
          <xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/instructions/narrativeLinkPrefixes/instructionsNarrative/text(), $narrativeLinkSuffix)"/>
          <xsl:with-param name="xsiType" select="'CE'"/>
          <xsl:with-param name="writeOriginalText" select="'0'"/>
        </xsl:apply-templates> 
        
        <text>
          <reference value="{concat('#', $exportConfiguration/instructions/narrativeLinkPrefixes/instructionsNarrative/text(), $narrativeLinkSuffix)}"/>
        </text>
        
        <statusCode code="completed"/>
      </act>
    </entry>
  </xsl:template>

  
  <xsl:template name="eIns-templateIds-Instruction">
    <templateId root="{$ccda-Instructions}"/>
    <templateId root="{$ccda-Instructions}" extension="2014-06-09"/>
  </xsl:template>
</xsl:stylesheet>