<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc">

	<xsl:template match="*" mode="sM-medications">
		<xsl:param name="sectionRequired" select="'0'"/>
		<xsl:param name="entriesRequired" select="'0'"/>
		
		<!-- C = Cancelled, D = Discontinued -->
		<xsl:variable name="medicationCancelledStatusCodes">|C|D|</xsl:variable>
		<!-- Exclude medications whose FromTime is after today, as those belong in Plan of Care. -->
		<xsl:variable name="hasData" select="count(Medications/Medication[(not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|'))))
			                                                     and not(isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)])"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/medications/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="$hasData = 0"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sM-templateIds-medicationsSection">
						<xsl:with-param name="entriesRequired" select="$entriesRequired"/>
					</xsl:call-template>
					
					<code code="10160-0" displayName="History of Medication Use" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Medications</title>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="." mode="eM-medications-Narrative"><xsl:with-param name="narrativeLinkCategory">medications</xsl:with-param></xsl:apply-templates>
							<xsl:apply-templates select="." mode="eM-medications-Entries"><xsl:with-param name="narrativeLinkCategory">medications</xsl:with-param></xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eM-medications-NoData"><xsl:with-param name="narrativeLinkCategory">medications</xsl:with-param></xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sM-templateIds-medicationsSection">
		<xsl:param name="entriesRequired"/>
		<xsl:choose>
			<xsl:when test="$entriesRequired = '1'">
				<templateId root="{$ccda-MedicationsSectionEntriesRequired}"/>
				<templateId root="{$ccda-MedicationsSectionEntriesRequired}" extension="2014-06-09"/>
			</xsl:when>
			<xsl:otherwise>
				<templateId root="{$ccda-MedicationsSectionEntriesOptional}"/>
				<templateId root="{$ccda-MedicationsSectionEntriesOptional}" extension="2014-06-09"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>