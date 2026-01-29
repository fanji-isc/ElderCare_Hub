<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="encounters">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="encompassingEncNum"><xsl:apply-templates select="." mode="encompassingEncounterNumber"/></xsl:variable>
		<xsl:variable name="encompassingEncOrg"><xsl:apply-templates select="." mode="encompassingEncounterOrganization"/></xsl:variable>
		<xsl:variable name="encompassingEncToEncounters"><xsl:apply-templates select="." mode="encompassingEncounterToEncounters"/></xsl:variable>
		
		<!--
			An encounter qualifies for the Encounters section when:
			- The SDA EncounterType is not G or S
			AND
			(
			- The encounter was not designated for encompassingEncounter
			OR
			- The encounter was designated for encompassingEncounter AND it was requested to also be in Encounters section
			)
		-->
		<xsl:variable name="hasData" select="Encounters/Encounter[not(contains('|G|S|', concat('|', EncounterType/text(), '|'))) and not(EncounterNumber/text()=$encompassingEncNum and HealthCareFacility/Organization/Code/text()=$encompassingEncOrg and not($encompassingEncToEncounters='1'))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/encounters/emptySection/exportData/text()"/>
		
		<xsl:if test="$hasData">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-encountersSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="46240-8" displayName="History of Encounters" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Encounters</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="Encounters" mode="encounters-Narrative"/>
							<xsl:apply-templates select="Encounters" mode="encounters-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="encounters-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-encountersSection">
		<xsl:if test="$hitsp-CDA-EncountersSection"><templateId root="{$hitsp-CDA-EncountersSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-EncountersSection"><templateId root="{$hl7-CCD-EncountersSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-EncounterHistories"><templateId root="{$ihe-PCC-EncounterHistories}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
