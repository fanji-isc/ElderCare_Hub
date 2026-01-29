<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:sdtc="urn:hl7-org:sdtc" exclude-result-prefixes="isc hl7 xsi exsl sdtc">
	<xsl:include href="InformationSource.xsl"/>
	<xsl:include href="LanguageSpoken.xsl"/>
	
	<xsl:template match="*" mode="PersonalInformation">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode"><xsl:with-param name="informationType">Patient</xsl:with-param></xsl:call-template>
		
		<!-- Information Source module -->
		<xsl:apply-templates select="/hl7:ClinicalDocument" mode="InformationSource"/>
		
		<xsl:variable name="hasLegal" select="hl7:patient/hl7:name[(@use='L' or not(@use)) and not(@nullFlavor)]"/>
		<xsl:variable name="hasAlias" select="hl7:patient/hl7:name[@use='P']"/>
		
		<!--
			Field : Patient Name
			Target: /ClinicalDocument/recordTarget/patientRole/patient/name[@use='L']
			Source: /Container/Patient/Name
			Source: HS.SDA3.Patient Name
			StructuredMappingRef: ContactName
		-->
		<!--
			Field : Patient Alias Names
			Target: /ClinicalDocument/recordTarget/patientRole/patient/name[@use='P']
			Source: /Container/Patient/Aliases/Name
			Source: HS.SDA3.Patient Aliases.Name
			StructuredMappingRef: ContactName
		-->
		<xsl:apply-templates select="hl7:patient/hl7:name[(@use='L' or not(@use)) and not(@nullFlavor)][1]" mode="ContactName"/>
		
		<xsl:if test="$hasAlias">
			<Aliases>
				<xsl:apply-templates select="hl7:patient/hl7:name[@use='P']" mode="ContactName"/>
			</Aliases>
		</xsl:if>
		
		<xsl:if test="not($hasLegal)">
			<BlankNameReason>
				<xsl:choose>
					<xsl:when test="$hasAlias">S</xsl:when>
					<xsl:otherwise>U</xsl:otherwise>
				</xsl:choose>
			</BlankNameReason>
		</xsl:if>
		
		<!--
			Field : Patient Gender
			Target: HS.SDA3.Patient Gender
			Target: /Container/Patient/Gender
			Source: /ClinicalDocument/recordTarget/patientRole/patient/administrativeGenderCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:patient/hl7:administrativeGenderCode" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'Gender'"/>
		</xsl:apply-templates>

		<!--
			Field : Patient Marital Status
			Target: HS.SDA3.Patient MaritalStatus
			Target: /Container/Patient/MaritalStatus
			Source: /ClinicalDocument/recordTarget/patientRole/patient/maritalStatusCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:patient/hl7:maritalStatusCode" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'MaritalStatus'"/>
		</xsl:apply-templates>
		
		<!--
			Field : Patient Religion
			Target: HS.SDA3.Patient Religion
			Target: /Container/Patient/Religion
			Source: /ClinicalDocument/recordTarget/patientRole/patient/religiousAffiliationCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:patient/hl7:religiousAffiliationCode" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'Religion'"/>
		</xsl:apply-templates>

		<!-- Birth Time -->
		<xsl:apply-templates select="hl7:patient/hl7:birthTime" mode="BirthTime"/>
		
		<!--
			Field : Patient Race
			Target: HS.SDA3.Patient Races
			Target: /Container/Patient/Races/Race[1]
			Source: /ClinicalDocument/recordTarget/patientRole/patient/raceCode
			StructuredMappingRef: CodeTableDetail
		-->
		<!--
			Field : Patient Additional Races
			Target: HS.SDA3.Patient Races
			Target: /Container/Patient/Races/Race[2..n]
			Source: /ClinicalDocument/recordTarget/patientRole/patient/sdtc:raceCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:if test="hl7:patient/hl7:raceCode or hl7:patient/sdtc:raceCode">
			<Races>
				<xsl:apply-templates select="hl7:patient/hl7:raceCode" mode="CodeTable">
					<xsl:with-param name="hsElementName" select="'Race'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="hl7:patient/sdtc:raceCode" mode="CodeTable">
					<xsl:with-param name="hsElementName" select="'Race'"/>
				</xsl:apply-templates>
			</Races>
		</xsl:if>
		
		<!-- Language Module -->
		<xsl:apply-templates select="hl7:patient" mode="LanguageSpoken"/>

		<!--
			Field : Patient Ethnicity
			Target: HS.SDA3.Patient EthnicGroup
			Target: /Container/Patient/EthnicGroup
			Source: /ClinicalDocument/recordTarget/patientRole/patient/ethnicGroupCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:patient/hl7:ethnicGroupCode" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'EthnicGroup'"/>
		</xsl:apply-templates>

		<!-- Patient Numbers -->
		<xsl:apply-templates select="." mode="PatientNumbers"/>
		
		<!-- Patient Addresses -->
		<xsl:apply-templates select="." mode="Addresses"/>
		
		<!--
			Field : Patient Contact Information
			Target: HS.SDA3.Patient ContactInfo
			Target: /Container/Patient/ContactInfo
			Source: /ClinicalDocument/recordTarget/patientRole
			StructuredMappingRef: ContactInfo
		-->
		<xsl:apply-templates select="." mode="ContactInfo"/>
			
		<!-- Custom SDA Data-->
		<xsl:apply-templates select="." mode="ImportCustom-PersonalInformation"/>
	</xsl:template>

	<xsl:template match="*" mode="PatientNumbers">
		<!--
			Field : Person ID
			Target: HS.SDA3.Patient PatientNumbers.PatientNumber.Number
			Target: /Container/Patient/PatientNumbers/PatientNumber[NumberType='MRN']/Number
			Source: /ClinicalDocument/recordTarget/patientRole/patient/id/@extension
		-->
		<!--
			Field : Person ID Assigning Authority Code
			Target: HS.SDA3.Patient PatientNumbers.PatientNumber.Organization.Code
			Target: /Container/Patient/PatientNumbers/PatientNumber[NumberType='MRN']/Organization/Code
			Source: /ClinicalDocument/recordTarget/patientRole/patient/id/@root
		-->
		<PatientNumbers><xsl:apply-templates select="hl7:id" mode="PatientNumber"/></PatientNumbers>
	</xsl:template>

	<xsl:template match="*" mode="PatientNumber">
		<PatientNumber>
			<Number><xsl:value-of select="@extension"/></Number>
			<Organization>
				<Code><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="@root"/></xsl:apply-templates></Code>
				<Description><xsl:value-of select="isc:evaluate('getDescriptionForOID', @root, 'AssigningAuthority')"/></Description>
			</Organization>
			<NumberType>
				<xsl:choose>
					<xsl:when test="@root='2.16.840.1.113883.4.1'">SSN</xsl:when>
					<xsl:otherwise>MRN</xsl:otherwise>
				</xsl:choose>
			</NumberType>
		</PatientNumber>
	</xsl:template>
	
	<!--
		MRNAndAAOID returns a string containing the patient Assigning
		Authority OID and the MRN, separated by vertical bar.
	-->
	<xsl:template match="*" mode="MRNAndAAOID">
		<xsl:value-of select="concat(hl7:id[@root and @extension and not(@root='2.16.840.1.113883.4.1')][1]/@root, '|', hl7:id[@root and @extension and not(@root='2.16.840.1.113883.4.1')][1]/@extension)"/>
	</xsl:template>

	<xsl:template match="*" mode="BirthTime">
		<!--
			Field : Patient Date of Birth
			Target: HS.SDA3.Patient BirthTime
			Target: /Container/Patient/BirthTime
			Source: /ClinicalDocument/recordTarget/patientRole/patient/birthTime/@value
		-->
		<BirthTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></BirthTime>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is /hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole.
	-->
	<xsl:template match="*" mode="ImportCustom-PersonalInformation">
	</xsl:template>
</xsl:stylesheet>
