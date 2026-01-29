<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<xsl:template match="Patient" mode="personInformation">
		<recordTarget>
			<patientRole>
				<!-- Patient ID -->
				<xsl:apply-templates select="." mode="id-Patient"/>
				
				<!--
					Field : Patient Addresses
					Target: /ClinicalDocument/recordTarget/patientRole/addr
					Source: /Container/Patient/Addresses
					Source: HS.SDA3.Patient Addresses
					StructuredMappingRef: addresses-Patient
				-->
				<xsl:apply-templates select="." mode="addresses-Patient"/>
				
				<!--
					Field : Patient Contact Information
					Target: /ClinicalDocument/recordTarget/patientRole/telecom
					Source: /Container/Patient/ContactInfo
					Source: HS.SDA3.Patient ContactInfo
					StructuredMappingRef: telecom
				-->
				<!-- Telecoms -->
				<xsl:apply-templates select="." mode="telecom"/>
				
				<patient>
					<xsl:variable name="hasLegal" select="string-length(Name)"/>
					<xsl:variable name="hasAlias" select="string-length(Aliases/Name)"/>
					
					<!--
						Field : Patient Name
						Target: /ClinicalDocument/recordTarget/patientRole/patient/name[@use='L']
						Source: /Container/Patient/Name
						Source: HS.SDA3.Patient Name
						StructuredMappingRef: name-Person
					-->
					<!--
						Field : Patient Alias Names
						Target: /ClinicalDocument/recordTarget/patientRole/patient/name[@use='P']
						Source: /Container/Patient/Aliases/Name
						Source: HS.SDA3.Patient Aliases.Name
						StructuredMappingRef: name-Person-Other
					-->
					<xsl:if test="($hasLegal) or (not($hasLegal) and not($hasAlias))">
						<xsl:apply-templates select="." mode="name-Person"/>
					</xsl:if>
					<xsl:if test="$hasAlias">
						<xsl:apply-templates select="Aliases" mode="name-Person-Other">
							<xsl:with-param name="use" select="'P'"/>
						</xsl:apply-templates>
					</xsl:if>
					
					<!-- Gender -->
					<xsl:apply-templates select="." mode="code-administrativeGender"/>
					
					<!-- Date of Birth -->
					<xsl:apply-templates select="BirthTime" mode="birthTime"/>
					
					<!-- Marital Status -->
					<xsl:apply-templates select="MaritalStatus" mode="code-maritalStatus"/>
					
					<!-- Religion -->
					<xsl:apply-templates select="Religion" mode="code-religiousAffiliation"/>
					
					<!-- Race Codes - if only in Race then get only from Race, otherwise get all from Races -->
					<xsl:choose>
						<xsl:when test="string-length(Race) and not(string-length(Races))">
							<xsl:apply-templates select="Race" mode="code-race"/>
						</xsl:when>
						<xsl:when test="string-length(Races)">
							<xsl:apply-templates select="Races/Race[1]" mode="code-race"/>
							<xsl:apply-templates select="Races/Race[position()>1]" mode="code-additionalRace"/>
						</xsl:when>
					</xsl:choose>
					
					<!-- Ethnic Group Code -->
					<xsl:apply-templates select="." mode="code-ethnicGroup-patient"/>
					
					<!-- Languages Spoken -->
					<xsl:apply-templates select="." mode="languagesSpoken"/>
				</patient>
			</patientRole>
		</recordTarget>
	</xsl:template>
	
	<xsl:template match="Patient" mode="id-Patient">
		<xsl:variable name="assigningAuthority">
			<xsl:choose>
				<xsl:when test="MPIID"><xsl:value-of select="$homeCommunityOID"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Organization/Code" mode="code-to-oid"><xsl:with-param name="identityType" select="'AssigningAuthority'"/></xsl:apply-templates></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="assigningAuthorityName">
			<xsl:choose>
				<xsl:when test="MPIID"><xsl:value-of select="$homeCommunityName"/></xsl:when>
				<xsl:when test="string-length(PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Organization/Description/text())"><xsl:value-of select="PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Organization/Description/text()"/></xsl:when>
				<xsl:when test="string-length(PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Organization/Code/text())"><xsl:value-of select="PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Organization/Code/text()"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="patientIdentifier">
			<xsl:choose>
				<xsl:when test="MPIID"><xsl:value-of select="MPIID/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Number/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!--
			Field : Person ID Assigning Authority Code
			Target: /ClinicalDocument/recordTarget/patientRole/id/@root
			Source: HS.SDA3.Patient PatientNumbers.PatientNumber.Organization.Code
			Source: /Container/Patient/PatientNumbers/PatientNumber[NumberType='MRN']/Organization/Code
			Note  : If /Container/Patient/MPIID has a value, then the HomeCommunity OID is populated into @root.
		-->
		<!--
			Field : Person ID
			Target: /ClinicalDocument/recordTarget/patientRole/id/@extension
			Source: HS.SDA3.Patient PatientNumbers.PatientNumber.Number
			Source: /Container/Patient/PatientNumbers/PatientNumber[NumberType='MRN']/Number
			Note  : If /Container/Patient/MPIID has a value, then the MPIID is populated into @extension.
		-->
		<!--
			Field : Person ID Assigning Authority Description
			Target: /ClinicalDocument/recordTarget/patientRole/id/@assigningAuthorityName
			Source: HS.SDA3.Patient PatientNumbers.PatientNumber.Organization.Description
			Source: /Container/Patient/PatientNumbers/PatientNumber[NumberType='MRN']/Organization/Description
			Note  : If /Container/Patient/MPIID has a value, then the HomeCommunity Name is populated into @assigningAuthorityName.
		-->
		<!-- The presence of a comma (,) indicates that multiple MPIIDs are being reported for the patient.  In this case, we "mask" the IDs since we can't report a single one. -->
		<xsl:choose>
			<xsl:when test="contains($patientIdentifier, ',')"><id nullFlavor="MSK"/></xsl:when>
			<xsl:when test="not(string-length($assigningAuthority) and string-length($patientIdentifier))"><id nullFlavor="UNK"/></xsl:when>
			<xsl:when test="string-length($assigningAuthority) and string-length($patientIdentifier)">
				<id root="{$assigningAuthority}" extension="{$patientIdentifier}">
					<xsl:if test="string-length($assigningAuthorityName)"><xsl:attribute name="assigningAuthorityName"><xsl:value-of select="$assigningAuthorityName"/></xsl:attribute></xsl:if>
				</id>
			</xsl:when>
			<xsl:otherwise><id nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="BirthTime" mode="birthTime">
		<!--
			Field : Patient Date of Birth
			Target: /ClinicalDocument/recordTarget/patientRole/patient/birthTime/@value
			Source: /Container/Patient/BirthTime
			Source: HS.SDA3.Patient BirthTime
		-->
		<birthTime>
			<xsl:attribute name="value"><xsl:apply-templates select="." mode="xmlToHL7TimeStamp"/></xsl:attribute>
		</birthTime>
	</xsl:template>
	
	<xsl:template match="*" mode="code-ethnicGroup-patient">
		<xsl:choose>
			<xsl:when test="string-length(EthnicGroup)">
				<xsl:apply-templates select="EthnicGroup" mode="code-ethnicGroup"/>
			</xsl:when>
			<xsl:otherwise><ethnicGroupCode nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
