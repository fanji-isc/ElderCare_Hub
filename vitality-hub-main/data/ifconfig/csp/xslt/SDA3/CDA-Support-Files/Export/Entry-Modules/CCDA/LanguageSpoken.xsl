<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<xsl:template match="*" mode="languagesSpoken">
		<xsl:apply-templates select="PrimaryLanguage" mode="languageCommunication"/>		
		<xsl:apply-templates select="OtherLanguages/PatientLanguage" mode="languageCommunication"/>		
	</xsl:template>
	
	<xsl:template match="PrimaryLanguage" mode="languageCommunication">
		<!--
			Field : Patient Primary Language
			Target: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication[preferenceInd/@value = 'true']/languageCode/@code
			Source: /Container/Patient/PrimaryLanguage/Code
			Source: HS.SDA3.Patient PrimaryLanguage.Code
			Note  : C-CDA for MU2 wants an ISO 639-2 lower case three-letter
					language code.  If the code from SDA is three letters
					then import assumes that it is a 639-2 code, and sets it
					to lower case.  Otherwise, it is used as is.
		-->
		<xsl:variable name="codeToUse">
			<xsl:choose>
				<xsl:when test="string-length(Code/text())=3 and not(string-length(translate(Code/text(),concat($upperCase,$lowerCase),'')))">
					<xsl:value-of select="translate(Code/text(),$upperCase,$lowerCase)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="Code/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($codeToUse)">
			<languageCommunication>
				<languageCode code="{$codeToUse}"/>
				<preferenceInd value="true"/>
			</languageCommunication>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="PatientLanguage" mode="languageCommunication">
		<!--
			Field : Patient Other Languages
			Target: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication[preferenceInd/@value != 'true']/languageCode/@code
			Source: /Container/Patient/OtherLanguages/PatientLanguage/PreferredLanguage/Code
			Source: HS.SDA3.Patient OtherLanguages.PatientLanguage.PreferredLanguage.Code
			Note  : C-CDA for MU2 wants an ISO 639-2 lower case three-letter
					language code.  If the code from SDA is three letters
					then import assumes that it is a 639-2 code, and sets it
					to lower case.  Otherwise, it is used as is.
		-->
		<xsl:variable name="codeToUse">
			<xsl:choose>
				<xsl:when test="string-length(PreferredLanguage/Code/text())=3 and not(string-length(translate(PreferredLanguage/Code/text(),concat($upperCase,$lowerCase),'')))">
					<xsl:value-of select="translate(PreferredLanguage/Code/text(),$upperCase,$lowerCase)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="PreferredLanguage/Code/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($codeToUse)">
			<languageCommunication>
				<languageCode code="{$codeToUse}"/>
				<preferenceInd value="false"/>
			</languageCommunication>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
