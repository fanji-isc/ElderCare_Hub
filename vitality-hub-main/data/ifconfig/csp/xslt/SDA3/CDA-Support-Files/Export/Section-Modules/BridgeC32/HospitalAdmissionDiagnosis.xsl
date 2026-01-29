<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="admissionDiagnoses">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="admissionDiagnosisTypeCodes" select="'|A|'"/>	
		<xsl:variable name="hasData" select="Diagnoses/Diagnosis[contains($admissionDiagnosisTypeCodes, concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|'))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/admissionDiagnoses/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-admissionDiagnosesSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="46241-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="HOSPITAL ADMISSION DX"/>
					<title>Hospital Admission Diagnoses</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
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
	
	<xsl:template match="*" mode="templateIds-admissionDiagnosesSection">
		<xsl:if test="$hitsp-CDA-HospitalAdmissionDiagnosisSection"><templateId root="{$hitsp-CDA-HospitalAdmissionDiagnosisSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-HospitalAdmissionDiagnosis"><templateId root="{$ihe-PCC-HospitalAdmissionDiagnosis}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>