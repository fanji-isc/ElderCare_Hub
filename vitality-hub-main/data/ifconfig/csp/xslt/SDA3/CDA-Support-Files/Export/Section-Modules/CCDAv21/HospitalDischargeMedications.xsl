<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Entry module has non-parallel name. AlsoInclude: Medication.xsl -->

  <xsl:template match="*" mode="sHDM-dischargeMedications">
    <xsl:param name="sectionRequired" select="'0'"/>
    <xsl:param name="entriesRequired" select="'0'"/>

    <!-- C = Cancelled, D = Discontinued -->
    <xsl:variable name="medicationCancelledStatusCodes">|C|D|</xsl:variable>
    <xsl:variable name="hasData" select="count(Medications/Medication[not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))])"/>
    <xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeMedications/emptySection/exportData/text()"/>

    <xsl:if test="($hasData > 0) or ($exportSectionWhenNoData = '1') or ($sectionRequired = '1')">
      <component>
        <section>
          <xsl:if test="$hasData = 0">
            <xsl:attribute name="nullFlavor">NI</xsl:attribute>
          </xsl:if>

          <xsl:call-template name="sHDM-templateIds-dischargeMedicationsSection"/>

          <code code="10183-2" displayName="HOSPITAL DISCHARGE MEDICATIONS" codeSystem="{$loincOID}" codeSystemName="{$loincName}">
            <translation code="75311-1" displayName="Discharge Medications" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
          </code>

          <title>Hospital Discharge Medications</title>

          <xsl:choose>
            <xsl:when test="$hasData > 0">
              <xsl:apply-templates select="." mode="eM-medications-Narrative">
                <xsl:with-param name="narrativeLinkCategory">dischargeMedications</xsl:with-param>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="eM-medications-Entries">
                <xsl:with-param name="narrativeLinkCategory">dischargeMedications</xsl:with-param>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="eM-medications-NoData">
                <xsl:with-param name="narrativeLinkCategory">dischargeMedications</xsl:with-param>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </section>
      </component>
    </xsl:if>
  </xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->

  <xsl:template name="sHDM-templateIds-dischargeMedicationsSection">
    <xsl:param name="entriesRequired"/>
    <xsl:choose>
      <xsl:when test="$entriesRequired = '1'">
        <templateId root="{$ccda-HospitalDischargeMedicationsSectionEntriesRequired}"/>
        <templateId root="{$ccda-HospitalDischargeMedicationsSectionEntriesRequired}" extension="2015-08-01"/>
      </xsl:when>
      <xsl:otherwise>
        <templateId root="{$ccda-HospitalDischargeMedicationsSectionEntriesOptional}"/>
        <templateId root="{$ccda-HospitalDischargeMedicationsSectionEntriesOptional}" extension="2015-08-01"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>