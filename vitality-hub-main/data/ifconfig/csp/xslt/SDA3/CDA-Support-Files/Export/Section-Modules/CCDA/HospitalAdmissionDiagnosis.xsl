<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:variable name="admissionDiagnosisTypeCodes" select="translate($exportConfiguration/admissionDiagnoses/diagnosisType/codes/text(), $lowerCase, $upperCase)"/>
	
	<xsl:template match="*" mode="admissionDiagnoses">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData"><xsl:apply-templates select="." mode="admissionDiagnoses-hasData"/></xsl:variable>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/admissionDiagnoses/emptySection/exportData/text()"/>
		
		<xsl:if test="(string-length($hasData)) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not(string-length($hasData))"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-admissionDiagnosesSection"/>
					
					<code code="46241-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Hospital Admission Diagnoses"/>
					<title>Hospital Admission Diagnoses</title>
					
					<xsl:choose>
						<xsl:when test="string-length($hasData)">
							<xsl:apply-templates select="." mode="diagnoses-Narrative">
								<xsl:with-param name="diagnosisTypeCodes" select="$admissionDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">admissionDiagnoses</xsl:with-param>
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="diagnoses-Entries">
								<xsl:with-param name="diagnosisTypeCodes" select="$admissionDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">admissionDiagnoses</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="admissionDiagnoses-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="admissionDiagnoses-hasData">
		<xsl:value-of select="Diagnoses/Diagnosis[contains($admissionDiagnosisTypeCodes, concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|'))]"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-admissionDiagnosesSection">
		<templateId root="{$ccda-HospitalAdmissionDiagnosisSection}"/>
	</xsl:template>
</xsl:stylesheet>