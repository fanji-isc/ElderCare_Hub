<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- AlsoInclude: LanguageSpoken.xsl -->
	
	<xsl:key name="PatientNumberByNumberType" match="PatientNumbers/PatientNumber" use="NumberType"/>
  <xsl:key name="PatientNumberByNumberType" match="/Container" use="'NEVER_MATCH_THIS!'"/>
  <!-- Second line in the above key is to ensure that the "key table" is populated
       with at least one row, but we never want to retrieve that row. -->
  
	<xsl:template match="Patient" mode="ePI-personInformation">
		<recordTarget>
			<patientRole>
				<!-- Patient ID -->
				<xsl:apply-templates select="." mode="ePI-id-Patient"/>
				
				<!--
					Field : Patient Addresses
					Target: /ClinicalDocument/recordTarget/patientRole/addr
					Source: /Container/Patient/Addresses
					Source: HS.SDA3.Patient Addresses
					StructuredMappingRef: addresses-Patient
				-->
				<xsl:apply-templates select="." mode="fn-addresses-Patient"/>
				
				<!--
					Field : Patient Contact Information
					Target: /ClinicalDocument/recordTarget/patientRole/telecom
					Source: /Container/Patient/ContactInfo
					Source: HS.SDA3.Patient ContactInfo
					StructuredMappingRef: telecom
				-->
				<xsl:apply-templates select="." mode="fn-telecom"/>
				
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
						<xsl:apply-templates select="." mode="fn-name-Person"/>
					</xsl:if>
					<xsl:if test="$hasAlias">
						<xsl:apply-templates select="Aliases/Name" mode="fn-name-Person-Other" />
					</xsl:if>
					
					<!-- Gender -->
					<xsl:apply-templates select="." mode="fn-code-administrativeGender"/>
					
					<!-- Date of Birth -->
					<xsl:choose>
						<xsl:when test="BirthTime"><xsl:apply-templates select="BirthTime" mode="ePI-birthTime-MU3"/></xsl:when>
						<xsl:otherwise><birthTime nullFlavor="UNK" /></xsl:otherwise>
					</xsl:choose>
					
					
					<!-- Marital Status -->
					<xsl:apply-templates select="MaritalStatus" mode="fn-code-maritalStatus"/>
					
					<!-- Religion -->
					<xsl:apply-templates select="Religion" mode="fn-code-religiousAffiliation"/>
					
					<!-- Race Codes - if only in Race then get only from Race, otherwise get all from Races -->
					<xsl:choose>
						<xsl:when test="string-length(Race) and not(string-length(Races))">
							<xsl:apply-templates select="Race" mode="fn-code-race"/>
						</xsl:when>
						<xsl:when test="string-length(Races)">
							<xsl:apply-templates select="Races/Race[1]" mode="fn-code-race"/>
							<xsl:apply-templates select="Races/Race[position()>1]" mode="fn-code-additionalRace"/>
						</xsl:when>
						<xsl:otherwise><raceCode nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>

					<!-- Ethnic Group Code -->
					<xsl:apply-templates select="." mode="ePI-code-ethnicGroup-patient"/>
					
					<!-- Languages Spoken -->
					<xsl:apply-templates select="." mode="eLS-languagesSpoken"/>
				</patient>
			</patientRole>
		</recordTarget>
	</xsl:template>
	
	<xsl:template match="Patient" mode="ePI-id-Patient">
		<xsl:variable name="hasPatientMRN" select="string-length(PatientNumbers/PatientNumber/Number)" />
		<xsl:variable name="assigningAuthority">
			<xsl:choose>
				<xsl:when test="MPIID"><xsl:value-of select="$homeCommunityOID"/></xsl:when>
				<xsl:when test="not($hasPatientMRN)" />
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="fn-oid-for-code">
						<xsl:with-param name="Code" select="key('PatientNumberByNumberType','MRN')[1]/Organization/Code/text()"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="assigningAuthorityName">
			<xsl:choose>
				<xsl:when test="MPIID"><xsl:value-of select="$homeCommunityName"/></xsl:when>
				<xsl:when test="not($hasPatientMRN)" />
				<xsl:when test="string-length(key('PatientNumberByNumberType','MRN')[1]/Organization/Code/text())">
					<xsl:value-of select="key('PatientNumberByNumberType','MRN')[1]/Organization/Code/text()"/>
				</xsl:when>				
				<xsl:when test="string-length(key('PatientNumberByNumberType','MRN')[1]/Organization/Description/text())">
					<xsl:value-of select="key('PatientNumberByNumberType','MRN')[1]/Organization/Description/text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="patientIdentifier">
			<xsl:choose>
				<xsl:when test="MPIID"><xsl:value-of select="MPIID/text()"/></xsl:when>
				<xsl:when test="not($hasPatientMRN)" />
				<xsl:otherwise><xsl:value-of select="key('PatientNumberByNumberType','MRN')[1]/Number/text()"/></xsl:otherwise>
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
					<xsl:if test="string-length($assigningAuthorityName)">
						<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="$assigningAuthorityName"/></xsl:attribute>
					</xsl:if>
				</id>
			</xsl:when>
			<xsl:otherwise><id nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="BirthTime" mode="ePI-birthTime">
		<!--
			Field : Patient Date of Birth
			Target: /ClinicalDocument/recordTarget/patientRole/patient/birthTime/@value
			Source: /Container/Patient/BirthTime
			Source: HS.SDA3.Patient BirthTime
		-->
		<birthTime>
			<xsl:attribute name="value"><xsl:apply-templates select="." mode="fn-xmlToHL7TimeStamp"/></xsl:attribute>
		</birthTime>
	</xsl:template>

	<xsl:template match="BirthTime" mode="ePI-birthTime-MU3">
		<!--
			Field : Patient Date of Birth
			Target: /ClinicalDocument/recordTarget/patientRole/patient/birthTime/@value
			Source: /Container/Patient/BirthTime
			Source: HS.SDA3.Patient BirthTime
		-->
		<birthTime>
			<xsl:attribute name="value"><xsl:apply-templates select="." mode="fn-xmlToHL7TimeStampYYYYMMDD"/></xsl:attribute>
		</birthTime>
	</xsl:template>
	
	
	<xsl:template match="Patient" mode="ePI-code-ethnicGroup-patient">
		<xsl:choose>
			<xsl:when test="string-length(EthnicGroup)">
				<xsl:apply-templates select="EthnicGroup" mode="fn-code-ethnicGroup"/>
			</xsl:when>
			<xsl:otherwise><ethnicGroupCode nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>