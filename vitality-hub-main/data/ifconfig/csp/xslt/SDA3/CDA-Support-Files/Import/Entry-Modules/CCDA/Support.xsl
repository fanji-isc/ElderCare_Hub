<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Support">
		<!-- ActionCode is not supported for SupportContact, causes parse error in SDA3. -->
		
		<xsl:if test="hl7:participant[@typeCode='IND']">
			<SupportContacts>
				<xsl:apply-templates select="hl7:participant[@typeCode='IND']" mode="NextOfKin"/>
			</SupportContacts>
		</xsl:if>

		<xsl:if test="$patientGenderIdentityImportMode = '1'">
			<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-SocialHistorySection]/hl7:entry/hl7:observation" mode="GenderIdentity"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="GenderIdentity">
		<!--
				Field : Patient GenderIdentity
				Target: HS.SDA3.Patient GenderIdentity
				Target: /Container/Patient/GenderIdentity
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation[templateId/@root="2.16.840.1.113883.10.20.22.4.38" and code/@code='76691-5']
		-->
		<xsl:if test="hl7:templateId/@root=$ccda-SocialHistoryObservation and hl7:code/@code='76691-5'">
			<xsl:apply-templates select="hl7:value" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'GenderIdentity'"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="NextOfKin">
		<SupportContact>
			<!--
				Field : Support Contact Id
				Target: HS.SDA3.SupportContact ExternalId
				Target: /Container/SupportContacts/SupportContact/ExternalId
				Source: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!--
				Field : Support Contact Name
				Target: HS.SDA3.SupportContact Name
				Target: /Container/SupportContacts/SupportContact/Name
				Source: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity/associatedPerson/name
				StructuredMappingRef: ContactName
			-->
			<xsl:apply-templates select="hl7:associatedEntity/hl7:associatedPerson/hl7:name" mode="ContactName"/>
			
			<!--
				Field : Support Contact Relationship
				Target: HS.SDA3.SupportContact Relationship
				Target: /Container/SupportContacts/SupportContact/Relationship
				Source: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity/code
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:associatedEntity/hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Relationship'"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>

			<!-- Contact Type -->
			<xsl:apply-templates select="hl7:associatedEntity" mode="ContactType"/>
			
			<!--
				Field : Support Contact Address
				Target: HS.SDA3.SupportContact Address
				Target: /Container/SupportContacts/SupportContact/Address
				Source: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity/addr
				StructuredMappingRef: Address
			-->
			<xsl:apply-templates select="hl7:associatedEntity/hl7:addr[1]" mode="Address"/>
			
			<!--
				Field : Support Contact Phone / Email / URL
				Target: HS.SDA3.SupportContact ContactInfo
				Target: /Container/SupportContacts/SupportContact/ContactInfo
				Source: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity
				StructuredMappingRef: ContactInfo
			-->
			<xsl:apply-templates select="hl7:associatedEntity" mode="ContactInfo"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-SupportContact"/>
		</SupportContact>
	</xsl:template>
	
	<xsl:template match="*" mode="ContactType">
		<!--
			Field : Support Contact Type Code
			Target: HS.SDA3.SupportContact ContactType.Code
			Target: /Container/SupportContacts/SupportContact/ContactType/Code
			Source: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity/@classCode
			Note  : CDA @classCode is mapped to SDA Contact Type as follows:
					CDA @classCode = 'AGNT', SDA Code = 'F', SDA Description = 'Federal Agency'
					CDA @classCode = 'CAREGIVER', SDA Code = 'O', SDA Description = 'Other'
					CDA @classCode = 'ECON', SDA Code = 'C', SDA Description = 'Emergency Contact'
					CDA @classCode = 'GUARD', SDA Code = 'S', SDA Description = 'State Agency'
					CDA @classCode = 'NOK', SDA Code = 'N', SDA Description = 'Next-of-Kin'
					CDA @classCode = 'PRS', SDA Code = 'U', SDA Description = 'Unknown'
					CDA @classCode = any other value including missing, SDA Code = 'U', SDA Description = 'Unknown'
		-->
		<!--
			Field : Support Contact Type Description
			Target: HS.SDA3.SupportContact ContactType.Description
			Target: /Container/SupportContacts/SupportContact/ContactType/Description
			Source: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity/@classCode
			Note  : CDA @classCode is mapped to SDA Contact Type as follows:
					CDA @classCode = 'AGNT', SDA Code = 'F', SDA Description = 'Federal Agency'
					CDA @classCode = 'CAREGIVER', SDA Code = 'O', SDA Description = 'Other'
					CDA @classCode = 'ECON', SDA Code = 'C', SDA Description = 'Emergency Contact'
					CDA @classCode = 'GUARD', SDA Code = 'S', SDA Description = 'State Agency'
					CDA @classCode = 'NOK', SDA Code = 'N', SDA Description = 'Next-of-Kin'
					CDA @classCode = 'PRS', SDA Code = 'U', SDA Description = 'Unknown'
					CDA @classCode = any other value including missing, SDA Code = 'U', SDA Description = 'Unknown'
		-->
		<ContactType>
			<Code>
				<xsl:choose>
					<xsl:when test="@classCode = 'AGNT'"><xsl:text>F</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'CAREGIVER'"><xsl:text>O</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'ECON'"><xsl:text>C</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'GUARD'"><xsl:text>S</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'NOK'"><xsl:text>N</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'PRS'"><xsl:text>U</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text>U</xsl:text></xsl:otherwise>
				</xsl:choose>
			</Code>
			<Description>
				<xsl:choose>
					<xsl:when test="@classCode = 'AGNT'"><xsl:text>Federal Agency</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'CAREGIVER'"><xsl:text>Other</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'ECON'"><xsl:text>Emergency Contact</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'GUARD'"><xsl:text>State Agency</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'NOK'"><xsl:text>Next-of-Kin</xsl:text></xsl:when>
					<xsl:when test="@classCode = 'PRS'"><xsl:text>Unknown</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text>Unknown</xsl:text></xsl:otherwise>
				</xsl:choose>
			</Description>
		</ContactType>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is /hl7:ClinicalDocument.
	-->
	<xsl:template match="*" mode="ImportCustom-SupportContact">
	</xsl:template>
</xsl:stylesheet>
