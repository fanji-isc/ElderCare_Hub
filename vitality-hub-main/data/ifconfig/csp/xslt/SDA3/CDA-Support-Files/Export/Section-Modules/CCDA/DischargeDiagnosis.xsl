<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:variable name="dischargeDiagnosisTypeCodes" select="translate($exportConfiguration/dischargeDiagnoses/diagnosisType/codes/text(), $lowerCase, $upperCase)"/>
	
	<xsl:template match="*" mode="dischargeDiagnoses">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData"><xsl:apply-templates select="." mode="dischargeDiagnoses-hasData"/></xsl:variable>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeDiagnoses/emptySection/exportData/text()"/>
		
		<xsl:if test="(string-length($hasData)) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-dischargeDiagnosesSection"/>
					
					<code code="11535-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Hospital Discharge Diagnoses"/>
					<title>Hospital Discharge Diagnoses</title>
					
					<xsl:choose>
						<xsl:when test="string-length($hasData)">
							<xsl:apply-templates select="." mode="diagnoses-Narrative">
								<xsl:with-param name="diagnosisTypeCodes" select="$dischargeDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">dischargeDiagnoses</xsl:with-param>
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="diagnoses-Entries">
								<xsl:with-param name="diagnosisTypeCodes" select="$dischargeDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">dischargeDiagnoses</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="dischargeDiagnoses-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="dischargeDiagnoses-hasData">
		<xsl:value-of select="Diagnoses/Diagnosis[contains($dischargeDiagnosisTypeCodes, concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|'))]"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-dischargeDiagnosesSection">
		<templateId root="{$ccda-HospitalDischargeDiagnosisSection}"/>
	</xsl:template>
</xsl:stylesheet>
