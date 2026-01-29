<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:hl7-org:v3">

<!-- The templates/modes in this file are typically invoked from a peer module (PersonalInformation)
		 rather than the top-level transformation. -->

	<xsl:template match="*" mode="eLS-languagesSpoken">
		<!-- Notice that both of the instructions below use the same mode and depend on the match patterns
		     of the respective templates to distinguish which one will be called, and hence which 
		     languageCommunication/preferenceInd/@value will be emitted. -->
		<xsl:apply-templates select="PrimaryLanguage" mode="eLS-languageCommunication"/>		
		<xsl:apply-templates select="OtherLanguages/PatientLanguage" mode="eLS-languageCommunication"/>		
	</xsl:template>
	
	<xsl:template match="PrimaryLanguage" mode="eLS-languageCommunication">
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
		<xsl:if test="string-length(Code/text())">
			<languageCommunication>
				<xsl:apply-templates select="Code" mode="eLS-languageCode"/>
				<preferenceInd value="true"/>
			</languageCommunication>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="PatientLanguage" mode="eLS-languageCommunication">
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
		<xsl:if test="string-length(PreferredLanguage/Code/text())">
			<languageCommunication>
				<xsl:apply-templates select="PreferredLanguage/Code" mode="eLS-languageCode"/>
				<preferenceInd value="false"/>
			</languageCommunication>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Code" mode="eLS-languageCode">
		<languageCode>
			<xsl:attribute name="code">
				<xsl:choose>
					<xsl:when test="string-length(text()) = 3 and not(string-length(translate(text(), concat($upperCase, $lowerCase), '')))">
						<xsl:value-of select="translate(text(), $upperCase, $lowerCase)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="text()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</languageCode>
	</xsl:template>
	
</xsl:stylesheet>