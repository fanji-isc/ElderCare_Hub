<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!--
		assignedEntity overrides assignedEntity from ../Functions.xsl.
	
		CDA R2 validation - which is needed as a prerequisite of
		XPHR validation - rejects sdtc:patient under assignedEntity.
		This override removes the code that calls id-sdtcPatient.
	-->
	<xsl:template match="*" mode="assignedEntity">
		<xsl:param name="includePatientIdentifier" select="true()"/>
		<!--
			StructuredMapping: assignedEntity
		
			Field
			Path  : id
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : addr
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
			
			Field
			Path  : telecom
			Source: ContactInfo
			Source: ./ContactInfo
			StructuredMappingRef: telecom
			
			Field
			Path  : assignedPerson
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedPerson
			
			Field
			Path  : representedOrganization
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: representedOrganization
		-->
		
		<assignedEntity>
			<!-- Contact Identifier -->
			<xsl:apply-templates select="." mode="id-Clinician"/>
			
			<!-- Entity Address -->
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			
			<!-- Entity Telecom -->
			<xsl:apply-templates select="." mode="telecom"/>
			
			<!-- Assigned Person -->
			<xsl:apply-templates select="." mode="assignedPerson"/>
			
			<!-- Represented Organization -->
			<xsl:apply-templates select="." mode="representedOrganization"/>
		</assignedEntity>
	</xsl:template>
	
	<!--
		id-External overrides id-External from ../Functions.xsl.
	
		This version exports a GUID when EnteredAt and/or ExternalId
		is unknown, as opposed to exporting nullFlavor.
	-->
	<xsl:template match="*" mode="id-External">
		<!--
			StructuredMapping: id-External
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : SDA ExternalId is exported as id/@extension only when EnteredAt/Code
					is also present.  In that case the OID for EnteredAt/Code is also
					exported, as id/@root.  Otherwise <id root="<GUID>"/> is exported.
		-->
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(ExternalId)">
				<id>
					<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
					<xsl:attribute name="extension"><xsl:value-of select="ExternalId/text()"/></xsl:attribute>
					<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-ExternalId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise><id root="{isc:evaluate('createGUID')}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		code-route overrides code-route from ../Functions.xsl
		
		This version exports the HL7 RouteOfAdministration OID
		(2.16.840.1.113883.5.112) instead of the NCI Thesaurus
		Route Of Administration OID (2.16.840.1.113883.3.26.1.1).
	-->
	<xsl:template match="*" mode="code-route">
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID">2.16.840.1.113883.5.112</xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">routeCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<!--
		id-Medication overrides id-Medication from ../Functions.xsl
		
		This version uses id-ExternalPlacerOrFiller instead of
		exporting multiple <id>'s because XPHR allows for exporting
		only one <id> for each medication and immunization.
	-->
	<xsl:template match="*" mode="id-Medication">
		<xsl:apply-templates select="." mode="id-ExternalPlacerOrFiller"/>
	</xsl:template>
</xsl:stylesheet>
