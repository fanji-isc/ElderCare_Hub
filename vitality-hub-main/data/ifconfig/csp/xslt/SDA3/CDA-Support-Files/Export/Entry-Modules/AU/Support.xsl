<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="Patient" mode="nextOfKin">
		<xsl:apply-templates select="SupportContacts/SupportContact" mode="participant-NextOfKin"/>
	</xsl:template>

	<xsl:template match="SupportContact" mode="participant-NextOfKin">
		<participant typeCode="IRCP">
			<!-- Here, the address will always be constructed as Work-Primary since SDA doesn't have an addressUse field.  We should fix this. -->
			<xsl:apply-templates select="." mode="associatedEntity">
				<xsl:with-param name="contactType">CON</xsl:with-param>
			</xsl:apply-templates>
		</participant>
	</xsl:template>
</xsl:stylesheet>
