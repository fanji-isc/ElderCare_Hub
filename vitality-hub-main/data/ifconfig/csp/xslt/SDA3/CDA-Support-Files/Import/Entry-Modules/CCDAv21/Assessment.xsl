<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com"
  xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="isc hl7 xsi exsl">

  <xsl:template match="*" mode="eA-Assessment">
    <!--
      Field : Assessment
      Target: HS.SDA3.Document NoteText
      Target: /Container/Documents/Document[DocumentType/Description/text()='Assessment' or DocumentType/Code/text()='Assessment']/NoteText
      Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.8']/text/table
	  -->

    <!--
      Field : Assessment
      Target: HS.SDA3.Document EncounterNumber
      Target: /Container/Documents/Document[DocumentType/Description/text()='Assessment' or DocumentType/Code/text()='Assessment']/EncounterNumber
      Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.8']/text/table
    -->

    <Document>

      <DocumentType>
        <Code>Assessment</Code>
        <Description>Assessment</Description>
      </DocumentType>

      <NoteText>
        <xsl:value-of select="hl7:td[contains(@ID, 'Assessment')]/text()"/>  
      </NoteText>

      <EncounterNumber>
        <xsl:value-of select="hl7:td[contains(@ID, 'EncounterNumber')]/text()"/>
      </EncounterNumber>

      <!-- Custom SDA Data-->
      <xsl:apply-templates select="." mode="eA-ImportCustom-Assessment"/>

    </Document>

  </xsl:template>

  <!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:act.
	-->
  <xsl:template match="*" mode="eA-ImportCustom-Assessment"> </xsl:template>

</xsl:stylesheet>