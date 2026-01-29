<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="assessments">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="assessmentDiagnosisTypeCodes" select="$exportConfiguration/assessments/diagnosisType/codes/text()"/>
		<xsl:variable name="hasData" select="Diagnoses/Diagnosis[contains(translate($assessmentDiagnosisTypeCodes, $lowerCase, $upperCase), concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|')) = true()]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/assessments/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-assessmentsSection"/>
					
					<code code="51848-0" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Assessments"/>
					<title>Assessments</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="diagnoses-Narrative">
								<xsl:with-param name="diagnosisTypeCodes" select="$assessmentDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">assessments</xsl:with-param>
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="diagnoses-Entries">
								<xsl:with-param name="diagnosisTypeCodes" select="$assessmentDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">assessments</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="assessments-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="assessments-NoData">
		<text><xsl:value-of select="$exportConfiguration/assessments/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-assessmentsSection">
		<templateId root="{$ccda-AssessmentSection}"/>
	</xsl:template>
</xsl:stylesheet>
