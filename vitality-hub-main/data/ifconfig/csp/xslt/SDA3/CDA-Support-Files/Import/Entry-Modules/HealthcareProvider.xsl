<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="HealthcareProvider">
		<!--
			Field : Healthcare Provider Family Doctor
			Target: HS.SDA3.Patient FamilyDoctor
			Target: /Container/Patient/FamilyDoctor
			Source: /ClinicalDocument/documentationOf/serviceEvent/performer[(functionCode/@codeSystem='2.16.840.1.113883.12.443' and functionCode/@code='PP')]
			StructuredMappingRef: DoctorDetail
		-->
		<xsl:apply-templates select="hl7:serviceEvent/hl7:performer[hl7:functionCode/@codeSystem=$providerRoleOID and hl7:functionCode/@code='PP'][1]" mode="FamilyDoctor"/>
	</xsl:template>
</xsl:stylesheet>
