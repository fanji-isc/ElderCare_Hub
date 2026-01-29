<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="InformationSource">
		<!--
			Field : Patient Author
			Target: HS.SDA3.Patient EnteredBy
			Target: /Container/Patient/EnteredBy
			Source: /ClinicalDocument/author[not(assignedAuthor/assignedAuthoringDevice)]
			StructuredMappingRef: EnteredByDetail
		-->
		<xsl:apply-templates select="$defaultAuthorRootPath" mode="EnteredBy"/>
		
		<!--
			Field : Patient Information Source
			Target: HS.SDA3.Patient EnteredAt
			Target: /Container/Patient/EnteredAt
			Source: /ClinicalDocument/author[not(assignedAuthor/assignedAuthoringDevice)]
			StructuredMappingRef: EnteredAt
		-->
		<xsl:apply-templates select="$defaultInformantRootPath" mode="EnteredAt"/>
		
		<!--
			Field : Patient Author Time
			Target: HS.SDA3.Patient EnteredOn
			Target: /Container/Patient/EnteredOn
			Source: /ClinicalDocument/effectiveTime
		-->
		<xsl:apply-templates select="/hl7:ClinicalDocument/hl7:effectiveTime" mode="EnteredOn"/>
	</xsl:template>
</xsl:stylesheet>
