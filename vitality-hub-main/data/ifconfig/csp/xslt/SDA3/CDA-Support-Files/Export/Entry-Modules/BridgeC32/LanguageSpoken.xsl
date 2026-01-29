<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<xsl:template match="*" mode="languagesSpoken">
		<xsl:apply-templates select="PrimaryLanguage" mode="languageCommunication"/>		
		<xsl:apply-templates select="OtherLanguages/PatientLanguage" mode="languageCommunication"/>		
	</xsl:template>
	
	<xsl:template match="PrimaryLanguage" mode="languageCommunication">
		
		<!--
			HS.SDA3.Patient PrimaryLanguage
			CDA Section: Document Header - Language Spoken
			CDA Field: Language
			CDA XPath: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication
		-->	
		<xsl:if test="string-length(Code/text())">
			<languageCommunication>
				<xsl:if test="$hitsp-CDA-LanguageSpoken"><templateId root="{$hitsp-CDA-LanguageSpoken}"/></xsl:if>
				<xsl:if test="$ihe-PCC-LanguageCommunication"><templateId root="{$ihe-PCC-LanguageCommunication}"/></xsl:if>
			
				<languageCode code="{Code/text()}"/>
				<modeCode code="ESP" codeSystem="{$languageAbilityModeOID}" codeSystemName="{$languageAbilityModeName}" displayName="Expressed spoken"/>
				<preferenceInd value="true"/>
			</languageCommunication>
		</xsl:if>
	</xsl:template>

	<xsl:template match="PatientLanguage" mode="languageCommunication">
		
		<!--
			HS.SDA3.Patient OtherLanguages
			CDA Section: Document Header - Language Spoken
			CDA Field: Language
			CDA XPath: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication
		-->	
		<xsl:if test="string-length(PreferredLanguage/Code/text())">
			<languageCommunication>
				<xsl:if test="$hitsp-CDA-LanguageSpoken"><templateId root="{$hitsp-CDA-LanguageSpoken}"/></xsl:if>
				<xsl:if test="$ihe-PCC-LanguageCommunication"><templateId root="{$ihe-PCC-LanguageCommunication}"/></xsl:if>
			
				<languageCode code="{PreferredLanguage/Code/text()}"/>
				<modeCode code="ESP" codeSystem="{$languageAbilityModeOID}" codeSystemName="{$languageAbilityModeName}" displayName="Expressed spoken"/>
				<preferenceInd value="false"/>
			</languageCommunication>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
