<?xml version="1.0"?>
<!-- Removes filterable SDA data for all encounters other than the selected encounter -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				version="1.0">
<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
<xsl:param name="visitNumber"/>

<xsl:template match="Encounter | Diagnosis |  Observation | Problem | PhysicalExam | Procedure | Document | Medication | Vaccination | LabOrder[Result] | RadOrder[Result] | OtherOrder[Result]">
	<xsl:if test="EncounterNumber =$visitNumber">
		<xsl:copy-of select="."/>
	</xsl:if>
</xsl:template>

<xsl:template match="@* | node()">
	<xsl:copy>
  		<xsl:apply-templates select="@* | node()" /> 
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
