<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc">
  <!-- Entry module has non-parallel name. AlsoInclude: Medication.xsl -->

  <xsl:template match="*" mode="sMA-administeredMedications">
    <xsl:param name="sectionRequired" select="'0'"/>

    <!-- C = Cancelled, D = Discontinued -->
    <xsl:variable name="medicationCancelledStatusCodes">|C|D|</xsl:variable>
    <!--
			Select medications that meet all these criteria:
			- The encounter has EncounterType E, I or O
			- Does not have a Status of C or D
			- Has an EncounterNumber
			- The FromTime of the medication is on or after the FromTime of the encounter
			- The encounter does not have a ToTime, OR the encounter has a ToTime and the
			  medication has a ToTime and the medication ToTime is on or before the ToTime
			  of the encounter
		-->
    <xsl:variable name="hasData" select="count(Medications/Medication[contains('E|I|O', key('EncNum', EncounterNumber)/EncounterType)
        and not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))
        and (string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(key('EncNum', EncounterNumber)/FromTime/text(), 'TZ', ' '), translate(FromTime/text(), 'TZ', ' ')) &gt;= 0)
        and (not(string-length(key('EncNum', EncounterNumber)/ToTime/text()))
        or (string-length(ToTime/text())
            and string-length(key('EncNum', EncounterNumber)/ToTime/text())
            and isc:evaluate('dateDiff', 'dd', translate(key('EncNum', EncounterNumber)/ToTime/text(), 'TZ', ' '), translate(ToTime/text(), 'TZ', ' ')) &lt;= 0))])"/>
    <xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/administeredMedications/emptySection/exportData/text()"/>

    <xsl:if test="($hasData > 0) or ($exportSectionWhenNoData = '1') or ($sectionRequired = '1')">
      <component>
        <section>
          <xsl:if test="$hasData = 0">
            <xsl:attribute name="nullFlavor">NI</xsl:attribute>
          </xsl:if>

          <xsl:call-template name="sMA-templateIds-administeredMedicationsSection"/>

          <code code="29549-3" displayName="Medications Administered" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
          <title>Medications Administered</title>

          <xsl:choose>
            <xsl:when test="$hasData > 0">
              <xsl:apply-templates select="." mode="eM-medications-Narrative">
                <xsl:with-param name="narrativeLinkCategory">administeredMedications</xsl:with-param>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="eM-medications-Entries">
                <xsl:with-param name="narrativeLinkCategory">administeredMedications</xsl:with-param>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="eM-medications-NoData">
                <xsl:with-param name="narrativeLinkCategory">administeredMedications</xsl:with-param>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </section>
      </component>
    </xsl:if>
  </xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->

  <xsl:template name="sMA-templateIds-administeredMedicationsSection">
    <templateId root="{$ccda-MedicationsAdministeredSection}"/>
    <templateId root="{$ccda-MedicationsAdministeredSection}" extension="2014-06-09"/>
  </xsl:template>

</xsl:stylesheet>