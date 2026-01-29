<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="vitalSigns">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/vitalSigns/emptySection/exportData/text()"/>
		
		<!--
			We only want to export Observations that are LOINC vital signs or can
			be converted to LOINC vital signs. Parse all Observations and build
			validVitalSigns with the codes of those that we want to export. This
			is done to prevent another parse of Observations later.
			
			$loincVitalSignCodes is a global variable set up in Variables.xsl.
		-->
		<xsl:variable name="validVitalSigns">
			<xsl:apply-templates select="Observations/Observation" mode="vitalSigns-validVitalSign"/>
		</xsl:variable>
		
		<xsl:if test="string-length($validVitalSigns) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not(string-length($validVitalSigns))"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-vitalSignsSection"/>
					
					<code code="8716-3" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Vital Signs"/>
					<title>Vital Signs</title>
					
					<xsl:choose>
						<xsl:when test="string-length($validVitalSigns)">
							<xsl:apply-templates select="." mode="vitalSigns-Narrative">
								<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="vitalSigns-Entries">
								<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="vitalSigns-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="vitalSigns-validVitalSign">		
		<xsl:variable name="dU" select="translate(ObservationCode/Description/text(), $lowerCase, $upperCase)"/>
		<xsl:if test="contains($loincVitalSignCodes, concat('|', ObservationCode/Code/text(), '|')) or contains($dU,'RESPIRATORY') or contains($dU,'RESP RATE') or contains($dU,'RESPIRATION') or contains($dU,'HEART RATE') or contains($dU,'PULSE') or contains($dU,'O2 SAT') or contains($dU,'O2SAT') or contains($dU,'SO2') or contains($dU,'SYSTOLIC') or contains($dU,'DIASTOLIC') or contains($dU, 'TEMP') or contains($dU,'CRANIUM') or contains($dU,'SKULL') or contains($dU,'HEAD') or contains($dU,'WEIGHT') or contains($dU,'HEIGHT') or contains($dU,'BMI') or contains($dU,'BODY MASS')"><xsl:value-of select="concat(ObservationCode/Code/text(), '|')"/></xsl:if>
		<!-- Use the following line instead, when we decide to support BSA. -->
		<!--<xsl:if test="contains($loincVitalSignCodes, concat('|', ObservationCode/Code/text(), '|')) or contains($dU,'RESPIRATORY') or contains($dU,'RESP RATE') or contains($dU,'RESPIRATION') or contains($dU,'HEART RATE') or contains($dU,'PULSE') or contains($dU,'O2 SAT') or contains($dU,'O2SAT') or contains($dU,'SO2') or contains($dU,'SYSTOLIC') or contains($dU,'DIASTOLIC') or contains($dU, 'TEMP') or contains($dU,'CRANIUM') or contains($dU,'SKULL') or contains($dU,'HEAD') or contains($dU,'WEIGHT') or contains($dU,'HEIGHT') or contains($dU,'BMI') or contains($dU,'BODY MASS') or contains($dU,'BSA') or contains($dU,'BODY SURFACE')"><xsl:value-of select="concat(ObservationCode/Code/text(), '|')"/></xsl:if>-->
	</xsl:template>
	
	<!-- If the "entries required" templateId is needed then this template is overridden by *EntriesRequired.xsl -->
	<xsl:template match="*" mode="templateIds-vitalSignsSection">
		<templateId root="{$ccda-VitalSignsSectionEntriesOptional}"/>		
	</xsl:template>
</xsl:stylesheet>
