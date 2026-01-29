<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="administeredMedications">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- C = Cancelled, D = Discontinued -->
		<xsl:variable name="medicationCancelledStatusCodes">|C|D|</xsl:variable>
		<xsl:variable name="hasData" select="Medications/Medication[contains('E|I|O', key('EncNum', EncounterNumber)/EncounterType) and not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/administeredMedications/emptySection/exportData/text()"/>
		
		<xsl:if test="$hasData or (not($hasData) and ($exportSectionWhenNoData = 1))">
			<component>
				<section>
					<xsl:call-template name="templateIds-administeredMedicationsSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createGUID')}"/>

					<code code="18610-6" displayName="Medication Administered" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Medications Administered</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="medications-Narrative"><xsl:with-param name="narrativeLinkCategory">administeredMedications</xsl:with-param></xsl:apply-templates>
							<xsl:apply-templates select="." mode="medications-Entries"><xsl:with-param name="narrativeLinkCategory">administeredMedications</xsl:with-param></xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="administeredMedications-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="templateIds-administeredMedicationsSection">
		<xsl:if test="$hitsp-CDA-MedicationsAdministeredSection"><templateId root="{$hitsp-CDA-MedicationsAdministeredSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SelectMedsAdministered"><templateId root="{$ihe-PCC-SelectMedsAdministered}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
