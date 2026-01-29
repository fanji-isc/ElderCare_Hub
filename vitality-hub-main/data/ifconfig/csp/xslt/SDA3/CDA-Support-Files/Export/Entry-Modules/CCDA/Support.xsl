<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="Patient" mode="nextOfKin">
		<xsl:apply-templates select="SupportContacts/SupportContact" mode="participant-NextOfKin"/>
	</xsl:template>
	
	<xsl:template match="SupportContact" mode="participant-NextOfKin">
		<!--
			Field : Support Contact
			Target: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity
			Source: HS.SDA3.SupportContact
			Source: /Container/Patient/SupportContacts/SupportContact
			StructuredMappingRef: associatedEntity
		-->
		<participant typeCode="IND">			
			<!-- According to CCD, this should represent the time during which the SupportContact provides support.  Not known in SDA. -->
			<time nullFlavor="UNK"/>
			
			<!-- Here, the address will always be constructed as Work-Primary since SDA doesn't have an addressUse field.  We should fix this. -->
			<xsl:apply-templates select="." mode="associatedEntity">
				<xsl:with-param name="contactType">
					<xsl:choose>
						<xsl:when test="ContactType/Code/text() = 'F'"><xsl:text>AGNT</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'C'"><xsl:text>ECON</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'N'"><xsl:text>NOK</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'O'"><xsl:text>CAREGIVER</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'S'"><xsl:text>GUARD</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'U'"><xsl:text>PRS</xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>PRS</xsl:text></xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:apply-templates>
		</participant>
	</xsl:template>
</xsl:stylesheet>
