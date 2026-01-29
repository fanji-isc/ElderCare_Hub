<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<!-- Extra entry module used. AlsoInclude: AdvanceDirective.xsl Comment.xsl -->
	
	<xsl:template match="*" mode="sAD-advanceDirectives">
		<xsl:param name="sectionRequired" select="'0'"/>
		<xsl:param name="entriesRequired" select="'0'"/>
		
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/advanceDirectives/emptySection/exportData/text()"/>
		
		<!--
			We only want to export Advance Directives that are from
			the required value set for Advance Directive Type Code
			(2.16.840.1.113883.1.11.20.2) or have a description that
			can be converted to a valid Advance Directive Type Code.
			The valid type codes are defined in ExportProfile.xml.
		-->
		<!--<xsl:variable name="advanceDirectiveTypeCodes" select="$exportConfiguration/advanceDirectives/advanceDirectiveType/codes/text()"/>-->
		<xsl:variable name="allowedAdvanceDirectives">
			<xsl:for-each select="AdvanceDirectives/AdvanceDirective">
				<xsl:call-template name="sAD-advanceDirectives-validAdvanceDirective">
					<xsl:with-param name="validCodes" select="$exportConfiguration/advanceDirectives/advanceDirectiveType/codes/text()"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:if test="(string-length($allowedAdvanceDirectives)) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not(string-length($allowedAdvanceDirectives))"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sAD-templateIds-advanceDirectivesSection">
						<xsl:with-param name="entriesRequired" select="$entriesRequired"/>
					</xsl:call-template>
					
					<code code="42348-3" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Advance Directives</title>
					
					<xsl:choose>
						<xsl:when test="string-length($allowedAdvanceDirectives)">
							<xsl:apply-templates select="AdvanceDirectives" mode="eAD-advanceDirectives-Narrative">
								<xsl:with-param name="validAdvanceDirectives" select="concat('|',$allowedAdvanceDirectives)"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="AdvanceDirectives" mode="eAD-advanceDirectives-Entries">
								<xsl:with-param name="validAdvanceDirectives" select="concat('|',$allowedAdvanceDirectives)"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eAD-advanceDirectives-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sAD-advanceDirectives-validAdvanceDirective">
		<xsl:param name="validCodes"/>
		<xsl:variable name="codeUpper" select="translate(Alert/Code/text(), $lowerCase, $upperCase)"/>
		<xsl:variable name="descUpper" select="translate(Alert/Description/text(), $lowerCase, $upperCase)"/>
		<xsl:if test="(AlertType/SDACodingStandard/text()=$snomedName or AlertType/SDACodingStandard/text()=$snomedOID) and contains($validCodes, concat('|', AlertType/Code/text(), '|')) and (string-length($codeUpper)&gt;0) and not(contains('|N|NO|Y|YES|T|TRUE|F|FALSE|',concat('|',$codeUpper,'|'))) and not(contains('|N|NO|Y|YES|T|TRUE|F|FALSE|',concat('|',$descUpper,'|')))"><xsl:value-of select="concat(AlertType/Code/text(), '|')"/></xsl:if>
	</xsl:template>
	
	<xsl:template name="sAD-templateIds-advanceDirectivesSection">
		<xsl:param name="entriesRequired"/>
		<xsl:choose>
			<xsl:when test="$entriesRequired = '1'">
				<templateId root="{$ccda-AdvanceDirectivesSectionEntriesRequired}"/>
				<templateId root="{$ccda-AdvanceDirectivesSectionEntriesRequired}" extension="2015-08-01"/>				
			</xsl:when>
			<xsl:otherwise>
				<templateId root="{$ccda-AdvanceDirectivesSectionEntriesOptional}"/>
				<templateId root="{$ccda-AdvanceDirectivesSectionEntriesOptional}" extension="2015-08-01"/>				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
