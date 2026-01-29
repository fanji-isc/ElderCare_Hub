<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc">
  <!-- Entry module has non-parallel name. AlsoInclude: Condition.xsl -->
  
	<xsl:variable name="dischargeDiagnosisTypeCodes" select="translate($exportConfiguration/dischargeDiagnoses/diagnosisType/codes/text(), $lowerCase, $upperCase)"/>
	
	<xsl:template match="*" mode="sDD-dischargeDiagnoses">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="count(Diagnoses/Diagnosis[contains($dischargeDiagnosisTypeCodes, concat('|',translate(DiagnosisType/Code/text(),$lowerCase,$upperCase),'|'))])"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeDiagnoses/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="$hasData = 0"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sDD-templateIds-dischargeDiagnosesSection"/>
					
					<code code="11535-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Hospital Discharge Diagnoses">
						<translation code="78375-3" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Discharge diagnosis" />
					</code>
					<title>Hospital Discharge Diagnoses</title>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="." mode="eCn-diagnoses-Narrative">
								<xsl:with-param name="diagnosisTypeCodes" select="$dischargeDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">dischargeDiagnoses</xsl:with-param>
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="eCn-diagnoses-Entries">
								<xsl:with-param name="diagnosisTypeCodes" select="$dischargeDiagnosisTypeCodes"/>
								<xsl:with-param name="narrativeLinkCategory">dischargeDiagnoses</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eCn-dischargeDiagnoses-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sDD-templateIds-dischargeDiagnosesSection">
		<templateId root="{$ccda-HospitalDischargeDiagnosisSection}"/>
		<templateId root="{$ccda-HospitalDischargeDiagnosisSection}" extension="2015-08-01"/>
	</xsl:template>
</xsl:stylesheet>