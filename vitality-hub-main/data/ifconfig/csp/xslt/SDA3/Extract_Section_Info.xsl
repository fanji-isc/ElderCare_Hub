<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:xalan="http://xml.apache.org/xslt" exclude-result-prefixes="hl7 xalan" >

	<!--This utility tool is used to extract section name and OID from a CCDA document.
		It was originally created for using at NA2017.
	-->
	<xsl:output method="xml" indent="yes" xalan:indent-amount="8"/>
	<xsl:template match="/hl7:ClinicalDocument">
		<sectionInfos>
			<xsl:for-each select="hl7:component/hl7:structuredBody/hl7:component/hl7:section">
				<sectionInfo>
					<sectionName><xsl:value-of select="hl7:title/text()"/></sectionName>
					<sectionOID><xsl:value-of select="hl7:templateId[1]/@root"/></sectionOID>
				</sectionInfo>
			</xsl:for-each>
		</sectionInfos>
	</xsl:template>

</xsl:stylesheet>
