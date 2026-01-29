<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="dischargeDiagnoses">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="dischargeDiagnosisTypeCodes" select="$exportConfiguration/dischargeDiagnoses/diagnosisType/codes/text()"/>
		<xsl:variable name="hasData" select="Diagnoses/Diagnosis[contains(translate($dischargeDiagnosisTypeCodes, $lowerCase, $upperCase), concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|')) = true()]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeDiagnoses/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-dischargeDiagnosesSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="11535-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="HOSPITAL DISCHARGE DX"/>
					<title>Discharge Diagnoses</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
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
	
	<xsl:template match="*" mode="templateIds-dischargeDiagnosesSection">
		<xsl:if test="$hitsp-CDA-DischargeDiagnosisSection"><templateId root="{$hitsp-CDA-DischargeDiagnosisSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-DischargeDiagnosis"><templateId root="{$ihe-PCC-DischargeDiagnosis}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
