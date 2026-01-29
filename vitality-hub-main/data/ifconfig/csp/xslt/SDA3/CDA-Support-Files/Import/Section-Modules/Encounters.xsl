<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Encounters">		
		<xsl:variable name="duplicatedEncounterID">
			<xsl:choose>
				<!-- If encompassingEncounter id has @extension then assume it has a valid @root. -->
				<xsl:when test="string-length($encompassingEncounterID) and string-length(hl7:componentOf/hl7:encompassingEncounter/hl7:id/@extension)">
					<xsl:value-of select="$sectionRootPath[hl7:templateId/@root=$encountersSectionTemplateId]/hl7:entry/hl7:encounter[hl7:id/@root=/hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter/hl7:id/@root and hl7:id/@extension=$encompassingEncounterID]/hl7:id/@extension"/>
				</xsl:when>
				<xsl:when test="string-length($encompassingEncounterID)">
					<xsl:value-of select="$sectionRootPath[hl7:templateId/@root=$encountersSectionTemplateId]/hl7:entry/hl7:encounter[hl7:id/@root=$encompassingEncounterID]/hl7:id/@root"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="duplicatedEncounterOrg">
			<xsl:choose>
				<!-- If encompassingEncounter id has @extension then assume it has a valid @root. -->
				<xsl:when test="string-length($duplicatedEncounterID) and string-length(hl7:componentOf/hl7:encompassingEncounter/hl7:id/@extension)">
					<xsl:value-of select="$sectionRootPath[hl7:templateId/@root=$encountersSectionTemplateId]/hl7:entry/hl7:encounter[hl7:id/@root=/hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter/hl7:id/@root and hl7:id/@extension=$encompassingEncounterID]/hl7:id/@root"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Encounter in encompassingEncounter and not duplicated in the Encounters section -->
		<xsl:if test="string-length($encompassingEncounterID) and not(string-length($duplicatedEncounterID))"><xsl:apply-templates select="hl7:componentOf/hl7:encompassingEncounter" mode="DefaultEncounter"/></xsl:if>
			
		<!-- Encounters that are in the Encounters section and not in encompassingEncounter -->
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$encountersSectionTemplateId]/hl7:entry/hl7:encounter[not(hl7:id/@root=$duplicatedEncounterOrg and hl7:id/@extension=$duplicatedEncounterID) and not(not(hl7:id/@extension) and hl7:id/@root=$duplicatedEncounterID)]" mode="OverriddenEncounter"/>
		
		<!-- Encounter that is both in encompassingEncounter and in the Encounters section -->
		<xsl:if test="string-length($duplicatedEncounterID) and string-length($duplicatedEncounterOrg)">
			<xsl:apply-templates select="." mode="DuplicatedEncounter">
				<xsl:with-param name="duplicatedEncounterID" select="$duplicatedEncounterID"/>
				<xsl:with-param name="duplicatedEncounterOrg" select="$duplicatedEncounterOrg"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
