<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="DiagnosticInvestigations">
		<!-- Pathology Test Result (Lab Results) -->
		<xsl:variable name="pathologyTestResults" select="hl7:component/hl7:section[hl7:code/@code='102.16144' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']/hl7:entry"/>
		<xsl:if test="$pathologyTestResults">
			<LabOrders>
				<xsl:apply-templates select="$pathologyTestResults" mode="LabResults"/>
			</LabOrders>
		</xsl:if>
		
		<!-- Imaging Examination Result (Radiology) -->
		<xsl:variable name="imagingExaminationResults" select="hl7:component/hl7:section[hl7:code/@code='102.16145' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']/hl7:entry"/>
		<xsl:if test="$imagingExaminationResults">
			<RadOrders>
				<xsl:apply-templates select="$imagingExaminationResults" mode="RadResults"/>
			</RadOrders>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
