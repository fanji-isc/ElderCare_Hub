<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Condition">
		<Problem>
			<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- From and To Time -->
			<xsl:apply-templates select="hl7:effectiveTime" mode="FromTime"/>
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation[hl7:code/@code='103.15510' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']/hl7:value" mode="ToTime"/>
			
			<!-- Problem -->
			<xsl:apply-templates select="hl7:value" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Problem'"/>
			</xsl:apply-templates>
			
			<!-- Problem Type -->
			<xsl:if test="not($documentTypeOID=$nehta-sharedHealthSummary) and not($documentTypeOID=$nehta-eReferral)">
				<xsl:apply-templates select="hl7:code" mode="CodeTable">
					<xsl:with-param name="hsElementName" select="'Category'"/>
				</xsl:apply-templates>
			</xsl:if>

			<!-- Problem Status -->
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:entryRelationship[@typeCode='REFR']/hl7:observation/hl7:value" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Status'"/>
			</xsl:apply-templates>

			<!-- Comments -->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Problem"/>
		</Problem>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-Problem">
	</xsl:template>
</xsl:stylesheet>
