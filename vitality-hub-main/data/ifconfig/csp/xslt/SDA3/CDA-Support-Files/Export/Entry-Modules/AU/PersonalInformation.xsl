<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:template match="Patient" mode="personInformation">
		<recordTarget>
			<patientRole>
				<!-- Patient ID - NEHTA just wants a UUID -->
				<id root="{$patientRoleId}"/>

				<!-- Addresses -->
				<xsl:apply-templates select="." mode="address-Person"/>
								
				<!-- Telecoms -->
				<xsl:apply-templates select="." mode="telecom"/>
				
				<patient>
					<!-- Name -->
					<xsl:apply-templates select="." mode="name-Person"/>
					
					<!-- Gender -->
					<xsl:apply-templates select="." mode="code-administrativeGender"/>

					<!-- Date of Birth -->
					<xsl:apply-templates select="BirthTime" mode="birthTime"/>
					
					<!-- Marital Status -->
					<xsl:apply-templates select="MaritalStatus" mode="code-maritalStatus"/>
					
					<!-- Religion -->
					<xsl:apply-templates select="Religion" mode="code-religiousAffiliation"/>

					<!-- Race Code -->
					<xsl:apply-templates select="Race" mode="code-race"/>

					<!-- Indigenous Status -->
					<xsl:apply-templates select="EthnicGroup" mode="code-ethnicGroup"/>
					
					<!-- Death Indicator -->
					<xsl:apply-templates select="." mode="deathIndicator"/>
					
					<!-- Death Time -->
					<xsl:apply-templates select="DeathTime" mode="deathTime"/>
					
					<!-- asEntityIdentifier for IHI -->
					<xsl:apply-templates select="PatientNumbers/PatientNumber[NumberType/text() = 'NI'][1]/Number" mode="asEntityIdentifier-IHI"/>
					
					<!-- asEntityIdentifier for MRN or MPIID -->
					<xsl:apply-templates select="." mode="asEntityIdentifier-PatientId"/>
					
					<!-- Languages Spoken -->
					<xsl:apply-templates select="." mode="languagesSpoken"/>
				</patient>
			</patientRole>
		</recordTarget>
	</xsl:template>
		
	<xsl:template match="Patient" mode="asEntityIdentifier-PatientId">
		<xsl:variable name="assigningAuthorityName">
			<xsl:value-of select="PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Organization/Code"/>
		</xsl:variable>
		<xsl:variable name="assigningAuthority">
			<xsl:choose>
				<xsl:when test="MPIID"><xsl:value-of select="$homeCommunityOID"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Organization/Code" mode="code-to-oid"><xsl:with-param name="identityType" select="'AssigningAuthority'"/></xsl:apply-templates></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="patientIdentifier">
			<xsl:choose>
				<xsl:when test="MPIID"><xsl:value-of select="MPIID/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="PatientNumbers/PatientNumber[NumberType/text() = 'MRN'][1]/Number/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="not(contains($patientIdentifier, ',')) and string-length($assigningAuthority) and string-length($patientIdentifier)">
			<ext:asEntityIdentifier classCode="IDENT">
				<ext:id root="{$assigningAuthority}" extension="{$patientIdentifier}" assigningAuthorityName="{$assigningAuthorityName}"/>
				<ext:code code="MR" codeSystem="2.16.840.1.113883.12.203" codeSystemName="Identifier Type (HL7)" />
			</ext:asEntityIdentifier>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="asEntityIdentifier-IHI">
		<xsl:variable name="patientIdentifier">
			<xsl:choose>
				<xsl:when test="starts-with(text(),concat($hiServiceOID,'.',$ihiPrefix))">
					<xsl:value-of select="text()"/>
				</xsl:when>
				<xsl:when test="starts-with(text(),$ihiPrefix) and not(text()=$ihiPrefix)">
					<xsl:value-of select="concat($hiServiceOID,'.',text())"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="string-length($patientIdentifier)">
			<ext:asEntityIdentifier classCode="IDENT">
				<ext:id assigningAuthorityName="IHI" root="{$patientIdentifier}"/>
				<ext:assigningGeographicArea classCode="PLC">
					<ext:name>National Identifier</ext:name>
				</ext:assigningGeographicArea>
			</ext:asEntityIdentifier>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="BirthTime" mode="birthTime">
		<xsl:variable name="birthTime"><xsl:apply-templates select="." mode="xmlToHL7TimeStamp"/></xsl:variable>
		<birthTime>
			<xsl:attribute name="value"><xsl:value-of select="substring($birthTime,1,8)"/></xsl:attribute>
		</birthTime>
	</xsl:template>
	
	<xsl:template match="*" mode="deathIndicator">
		<xsl:variable name="indicator">
			<xsl:choose>
				<xsl:when test="not(string-length(IsDead/text())) and string-length(DeathTime/text())">true</xsl:when>
				<xsl:when test="IsDead/text()='1'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<ext:deceasedInd value="{$indicator}"/>
	</xsl:template>
	
	<xsl:template match="DeathTime" mode="deathTime">
		<xsl:if test="string-length(text())">
			<xsl:variable name="deathTime"><xsl:apply-templates select="." mode="xmlToHL7TimeStamp"/></xsl:variable>
			<ext:deceasedTime>
				<xsl:attribute name="value"><xsl:value-of select="substring($deathTime,1,8)"/></xsl:attribute>
			</ext:deceasedTime>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
