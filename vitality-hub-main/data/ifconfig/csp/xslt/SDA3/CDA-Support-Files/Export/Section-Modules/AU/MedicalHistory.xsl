<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="medicalHistory">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<component>
			<section>
				<!-- IHE needs unique id for each and every section -->
				<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
				
				<xsl:variable name="sectionTitle">
					<xsl:choose>
						<xsl:when test="$documentExportType='NEHTASharedHealthSummary'">Medical History</xsl:when>
						<xsl:when test="$documentExportType='NEHTAEventSummary'">Diagnoses/Interventions</xsl:when>
						<xsl:when test="$documentExportType='NEHTAeReferral'">Medical History</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<code code="101.16117" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="{$sectionTitle}"/>
				<title><xsl:value-of select="$sectionTitle"/></title>
				
				<!-- Medical History Narrative - Problems/Diagnoses, Procedures, Other -->
				<xsl:apply-templates select="." mode="medicalHistory-Narrative"/>
				
				<!-- Medical History Entries - Problems/Diagnoses -->
				<xsl:variable name="hasProblemsData" select="Problems/Problem"/>
				<xsl:variable name="exportProblemsSectionWhenNoData" select="$exportConfiguration/problems/emptySection/exportData/text()"/>
				<xsl:choose>
					<xsl:when test="$hasProblemsData">
						<xsl:apply-templates select="." mode="medicalHistory-Problems-Entries"/>
					</xsl:when>
					<xsl:when test="not($hasProblemsData) and (($exportProblemsSectionWhenNoData='1') or ($sectionRequired='1'))">
						<xsl:apply-templates select="." mode="medicalHistory-Problems-NoData"/>
					</xsl:when>
				</xsl:choose>
				
				<!-- Medical History Entries - Procedures -->
				<xsl:variable name="hasProceduresData" select="Procedures/Procedure"/>
				<xsl:variable name="exportProceduresSectionWhenNoData" select="$exportConfiguration/procedures/emptySection/exportData/text()"/>
				<xsl:choose>
					<xsl:when test="$hasProceduresData">
						<xsl:apply-templates select="." mode="procedures-Entries"/>
					</xsl:when>
					<xsl:when test="not($hasProceduresData) and (($exportProceduresSectionWhenNoData='1') or ($sectionRequired='1'))">
						<xsl:apply-templates select="." mode="medicalHistory-Procedures-NoData"/>
					</xsl:when>
				</xsl:choose>
				
				<!-- Medical History Entries - Other Medical History Items -->
				<xsl:apply-templates select="." mode="medicalHistory-Other-Entries"/>
			</section>
		</component>
	</xsl:template>
</xsl:stylesheet>
