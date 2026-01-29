<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="advanceDirectives">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/advanceDirectives/emptySection/exportData/text()"/>
		
		<!--
			We only want to export Advance Directives that are from
			the required value set for Advance Directive Type Code
			(2.16.840.1.113883.1.11.20.2) or have a description that
			can be converted to a valid Advance Directive Type Code.
			The valid type codes are defined in ExportProfile.xml.
		-->
		<xsl:variable name="advanceDirectiveTypeCodes" select="$exportConfiguration/advanceDirectives/advanceDirectiveType/codes/text()"/>
		<xsl:variable name="validAdvanceDirectives">
			<xsl:apply-templates select="AdvanceDirectives/AdvanceDirective" mode="advanceDirectives-validAdvanceDirective"><xsl:with-param name="validCodes" select="$advanceDirectiveTypeCodes"/></xsl:apply-templates>
		</xsl:variable>
		
		<xsl:if test="(string-length($validAdvanceDirectives)) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-advanceDirectivesSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="42348-3" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Advance Directives</title>
					
					<xsl:choose>
						<xsl:when test="string-length($validAdvanceDirectives)">
							<xsl:apply-templates select="AdvanceDirectives" mode="advanceDirectives-Narrative">
								<xsl:with-param name="validAdvanceDirectives" select="$validAdvanceDirectives"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="AdvanceDirectives" mode="advanceDirectives-Entries">
								<xsl:with-param name="validAdvanceDirectives" select="$validAdvanceDirectives"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="advanceDirectives-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="advanceDirectives-validAdvanceDirective">
		<xsl:param name="validCodes"/>
		<xsl:variable name="codeUpper" select="translate(Alert/Code/text(), $lowerCase, $upperCase)"/>
		<xsl:variable name="descUpper" select="translate(Alert/Description/text(), $lowerCase, $upperCase)"/>
		<xsl:if test="(AlertType/SDACodingStandard/text()=$snomedName or AlertType/SDACodingStandard/text()=$snomedOID) and contains($validCodes, concat('|', AlertType/Code/text(), '|')) and (string-length($codeUpper)&gt;0) and not(contains('|N|NO|Y|YES|T|TRUE|F|FALSE|',concat('|',$codeUpper,'|'))) and not(contains('|N|NO|Y|YES|T|TRUE|F|FALSE|',concat('|',$descUpper,'|')))"><xsl:value-of select="concat(AlertType/Code/text(), '|')"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-advanceDirectivesSection">
		<xsl:if test="$hitsp-CDA-AdvanceDirectivesSection"><templateId root="{$hitsp-CDA-AdvanceDirectivesSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-AdvanceDirectivesSection"><templateId root="{$hl7-CCD-AdvanceDirectivesSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-AdvanceDirectives"><templateId root="{$ihe-PCC-AdvanceDirectives}"/></xsl:if>
		<xsl:if test="$ihe-PCC-CodedAdvanceDirectives"><templateId root="{$ihe-PCC-CodedAdvanceDirectives}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
