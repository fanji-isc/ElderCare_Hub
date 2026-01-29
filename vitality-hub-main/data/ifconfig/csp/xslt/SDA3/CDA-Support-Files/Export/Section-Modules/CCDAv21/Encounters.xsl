<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com"
	xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Extra entry module used. AlsoInclude: Encounter.xsl Condition.xsl -->
	
	<xsl:template match="*" mode="sE-encounters">
		<xsl:param name="sectionRequired" select="'0'"/>
		<xsl:param name="entriesRequired" select="'0'"/>

<!-- ToDo: set up xsl:key for these over in Functions.xsl -->
		<xsl:variable name="encompassingEncNum">
			<xsl:apply-templates select="." mode="fn-encompassingEncounterNumber"/>
		</xsl:variable>
		<xsl:variable name="encompassingEncOrg">
			<xsl:apply-templates select="." mode="fn-encompassingEncounterOrganization"/>
		</xsl:variable>
		<xsl:variable name="encompassingEncToEncounters">
			<xsl:apply-templates select="." mode="fn-encompassingEncounterToEncounters"/>
		</xsl:variable>

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
		<xsl:variable name="allowableEncounters" select="Encounters/Encounter[not(contains('|G|S|', concat('|', EncounterType/text(), '|')))
				and not(EncounterNumber/text() = $encompassingEncNum and HealthCareFacility/Organization/Code/text() = $encompassingEncOrg and not($encompassingEncToEncounters = '1'))]"/>
		<xsl:variable name="hasData" select="count($allowableEncounters) > 0"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/encounters/emptySection/exportData/text()"/>

		<xsl:if test="$hasData or ($exportSectionWhenNoData = '1') or ($sectionRequired = '1')">
			<component>
				<section>
					<xsl:call-template name="sE-templateIds-encountersSection">
						<xsl:with-param name="entriesRequired" select="$entriesRequired"/>
					</xsl:call-template>

					<code code="46240-8" displayName="History of Encounters" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Encounters</title>

					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="Encounters" mode="eE-encounters-Narrative">
								<xsl:with-param name="encounterList" select="$allowableEncounters"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="Encounters" mode="eE-encounters-Entries">
								<xsl:with-param name="encounterList" select="$allowableEncounters"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eE-encounters-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>

	<!-- ***************************** NAMED TEMPLATES ************************************ -->

	<xsl:template name="sE-templateIds-encountersSection">
		<xsl:param name="entriesRequired"/>
		<xsl:choose>
			<xsl:when test="$entriesRequired = '1'">
				<templateId root="{$ccda-EncountersSectionEntriesRequired}"/>
				<templateId root="{$ccda-EncountersSectionEntriesRequired}" extension="2015-08-01"/>
			</xsl:when>
			<xsl:otherwise>
				<templateId root="{$ccda-EncountersSectionEntriesOptional}"/>
				<templateId root="{$ccda-EncountersSectionEntriesOptional}" extension="2015-08-01"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
