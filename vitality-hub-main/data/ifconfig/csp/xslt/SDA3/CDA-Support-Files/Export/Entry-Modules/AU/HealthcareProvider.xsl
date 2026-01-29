<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="participant-primaryHealthcareProvider">
		<participant typeCode="PART">
		<functionCode code="PCP"/>
		<associatedEntity classCode="PROV">
			<xsl:choose>
				<xsl:when test="string-length(SDACodingStandard/text()) and string-length(Code/text())">
					<xsl:apply-templates select="." mode="id-Clinician"/>
				</xsl:when>
				<xsl:otherwise>
					<id root="{isc:evaluate('createUUID')}"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="." mode="careProviderType-ANZSCO"/>
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			<xsl:apply-templates select="." mode="telecom"/>
			<xsl:apply-templates select="." mode="associatedPerson"/>
		</associatedEntity>
		</participant>
	</xsl:template>
	
	<xsl:template match="*" mode="participant-refereeHealthcareProvider">
		<participant typeCode="REFT">
		<associatedEntity classCode="PROV">
			<xsl:choose>
				<xsl:when test="string-length(SDACodingStandard/text()) and string-length(Code/text())">
					<xsl:apply-templates select="." mode="id-Clinician"/>
				</xsl:when>
				<xsl:otherwise>
					<id root="{isc:evaluate('createUUID')}"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="." mode="careProviderType-ANZSCO"/>
			<xsl:apply-templates select="." mode="address-WorkPrimary"/>
			<xsl:apply-templates select="." mode="telecom"/>
			<xsl:apply-templates select="." mode="associatedPerson-Referee"/>
		</associatedEntity>
		</participant>
	</xsl:template>
</xsl:stylesheet>
