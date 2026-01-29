<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="eIS-InformationSource">
		<!--
			Field : Patient Author
			Target: HS.SDA3.Patient EnteredBy
			Target: /Container/Patient/EnteredBy
			Source: /ClinicalDocument/author[not(assignedAuthor/assignedAuthoringDevice)]
			StructuredMappingRef: EnteredByDetail
		-->
		<xsl:apply-templates select="$defaultAuthorRootPath" mode="fn-EnteredBy"/>
		
		<!--
			Field : Patient Information Source
			Target: HS.SDA3.Patient EnteredAt
			Target: /Container/Patient/EnteredAt
			Source: /ClinicalDocument/author[not(assignedAuthor/assignedAuthoringDevice)]
			StructuredMappingRef: EnteredAt
		-->
		<xsl:apply-templates select="$defaultAuthorRootPath" mode="fn-EnteredAt"/>
		
		<!--
			Field : Patient Author Time
			Target: HS.SDA3.Patient EnteredOn
			Target: /Container/Patient/EnteredOn
			Source: /ClinicalDocument/effectiveTime/@value
		-->
		<xsl:apply-templates select="$input/hl7:effectiveTime" mode="fn-EnteredOn"/>
	</xsl:template>
	
</xsl:stylesheet>