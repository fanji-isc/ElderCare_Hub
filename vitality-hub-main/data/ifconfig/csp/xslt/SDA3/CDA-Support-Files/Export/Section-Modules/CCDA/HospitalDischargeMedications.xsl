<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="dischargeMedications">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- C = Cancelled, D = Discontinued -->
		<xsl:variable name="medicationCancelledStatusCodes">|C|D|</xsl:variable>
		<xsl:variable name="hasData" select="Medications/Medication[not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeMedications/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-dischargeMedicationsSection"/>
					
					<code code="10183-2" displayName="HOSPITAL DISCHARGE MEDICATIONS" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Hospital Discharge Medications</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="medications-Narrative"><xsl:with-param name="narrativeLinkCategory">dischargeMedications</xsl:with-param></xsl:apply-templates>
							<xsl:apply-templates select="." mode="medications-Entries"><xsl:with-param name="narrativeLinkCategory">dischargeMedications</xsl:with-param></xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="medications-NoData"><xsl:with-param name="narrativeLinkCategory">dischargeMedications</xsl:with-param></xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- If the "entries required" templateId is needed then this template is overridden by *EntriesRequired.xsl -->
	<xsl:template match="*" mode="templateIds-dischargeMedicationsSection">
		<templateId root="{$ccda-HospitalDischargeMedicationsSectionEntriesOptional}"/>
	</xsl:template>
</xsl:stylesheet>
