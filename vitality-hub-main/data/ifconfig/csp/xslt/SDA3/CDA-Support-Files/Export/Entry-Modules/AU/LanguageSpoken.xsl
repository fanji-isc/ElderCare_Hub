<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<xsl:template match="*" mode="languagesSpoken">
		<xsl:apply-templates select="PrimaryLanguage" mode="languageCommunication"/>		
		<xsl:apply-templates select="OtherLanguages/PatientLanguage" mode="languageCommunication"/>		
	</xsl:template>
	
	<xsl:template match="PrimaryLanguage" mode="languageCommunication">
		<!--
			Field : Patient Primary Language
			Target: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication[1]/languageCode/@code
			Source: /Container/Patient/PrimaryLanguage/Code
			Source: HS.SDA3.Patient PrimaryLanguage
		-->
		<!--
			Field : Patient Other Languages
			Target: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication[2..n]/languageCode/@code
			Source: /Container/Patient/OtherLanguages/PatientLanguage/PreferredLanguage/Code
			Source: HS.SDA3.Patient OtherLanguages.PatientLanguage
		-->
		<xsl:if test="string-length(Code/text())">
			<languageCommunication>
				<xsl:if test="$hitsp-CDA-LanguageSpoken"><templateId root="{$hitsp-CDA-LanguageSpoken}"/></xsl:if>
				<xsl:if test="$ihe-PCC-LanguageCommunication"><templateId root="{$ihe-PCC-LanguageCommunication}"/></xsl:if>
			
				<languageCode code="{Code/text()}"/>
				<preferenceInd value="true"/>
			</languageCommunication>
		</xsl:if>
	</xsl:template>

	<xsl:template match="PatientLanguage" mode="languageCommunication">
		<xsl:if test="string-length(PreferredLanguage/Code/text())">
			<languageCommunication>
				<xsl:if test="$hitsp-CDA-LanguageSpoken"><templateId root="{$hitsp-CDA-LanguageSpoken}"/></xsl:if>
				<xsl:if test="$ihe-PCC-LanguageCommunication"><templateId root="{$ihe-PCC-LanguageCommunication}"/></xsl:if>
			
				<languageCode code="{PreferredLanguage/Code/text()}"/>
				<preferenceInd value="false"/>
			</languageCommunication>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
