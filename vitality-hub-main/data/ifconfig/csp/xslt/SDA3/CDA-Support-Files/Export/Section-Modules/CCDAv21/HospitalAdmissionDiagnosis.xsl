<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Entry module has non-parallel name. AlsoInclude: Condition.xsl -->
  
	<xsl:variable name="admissionDiagnosisTypeCodes" select="translate($exportConfiguration/admissionDiagnoses/diagnosisType/codes/text(), $lowerCase, $upperCase)"/>
	
	<xsl:template match="*" mode="sHAD-admissionDiagnoses">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData">
			<xsl:value-of select="count(Diagnoses/Diagnosis[contains($admissionDiagnosisTypeCodes, concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|'))])"/>
		</xsl:variable>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/admissionDiagnoses/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="$hasData = 0"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sHAD-templateIds-admissionDiagnosesSection"/>
					
					<code code="46241-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Hospital Admission Diagnoses">
						<translation code="42347-5" codeSystem="{$loincOID}" displayName="Admission Diagnosis"></translation>
					</code>

					<title>Hospital Admission Diagnoses</title>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="." mode="eCn-diagnoses-Narrative">
								<xsl:with-param name="diagnosisTypeCodes" select="$admissionDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">admissionDiagnoses</xsl:with-param>
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="eCn-diagnoses-Entries">
								<xsl:with-param name="diagnosisTypeCodes" select="$admissionDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">admissionDiagnoses</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eCn-admissionDiagnoses-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sHAD-templateIds-admissionDiagnosesSection">
		<templateId root="{$ccda-HospitalAdmissionDiagnosisSection}"/>
		<templateId root="{$ccda-HospitalAdmissionDiagnosisSection}" extension="2015-08-01"/>
	</xsl:template>
</xsl:stylesheet>