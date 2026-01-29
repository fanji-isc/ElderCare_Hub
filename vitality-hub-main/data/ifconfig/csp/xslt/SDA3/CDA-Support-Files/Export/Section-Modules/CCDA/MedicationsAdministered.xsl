<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="administeredMedications">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- C = Cancelled, D = Discontinued -->
		<xsl:variable name="medicationCancelledStatusCodes">|C|D|</xsl:variable>
		<!--
			Select medications that meet all these criteria:
			- Does not have a Status of C or D
			- Has an EncounterNumber
			- The encounter has EncounterType E, I or O
			- The FromTime of the medication is on or after the FromTime of the encounter
			- The encounter does not have a ToTime, OR the encounter has a ToTime and the
			  medication has a ToTime and the medication ToTime is on or before the ToTime
			  of the encounter
		-->
		<xsl:variable name="hasData" select="Medications/Medication[contains('E|I|O', key('EncNum', EncounterNumber)/EncounterType) and not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|'))) and (string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(key('EncNum', EncounterNumber)/FromTime/text(), 'TZ', ' '), translate(FromTime/text(), 'TZ', ' ')) &gt;= 0) and (not(string-length(key('EncNum', EncounterNumber)/ToTime/text())) or (string-length(ToTime/text()) and string-length(key('EncNum', EncounterNumber)/ToTime/text()) and isc:evaluate('dateDiff', 'dd', translate(key('EncNum', EncounterNumber)/ToTime/text(), 'TZ', ' '), translate(ToTime/text(), 'TZ', ' ')) &lt;= 0))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/administeredMedications/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-administeredMedicationsSection"/>
					
					<code code="29549-3" displayName="Medications Administered" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Medications Administered</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="medications-Narrative"><xsl:with-param name="narrativeLinkCategory">administeredMedications</xsl:with-param></xsl:apply-templates>
							<xsl:apply-templates select="." mode="medications-Entries"><xsl:with-param name="narrativeLinkCategory">administeredMedications</xsl:with-param></xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="medications-NoData"><xsl:with-param name="narrativeLinkCategory">administeredMedications</xsl:with-param></xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-administeredMedicationsSection">
		<templateId root="{$ccda-MedicationsAdministeredSection}"/>
	</xsl:template>
</xsl:stylesheet>
