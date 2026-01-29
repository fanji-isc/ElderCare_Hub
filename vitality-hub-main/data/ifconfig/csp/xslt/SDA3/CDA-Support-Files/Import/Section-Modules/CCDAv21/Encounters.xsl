<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sE-Encounters">
		<xsl:variable name="hasEncompassing" select="string-length($encompassingEncounterID) > 0"/>
		<xsl:variable name="encompassingRoot" select="$input/hl7:componentOf/hl7:encompassingEncounter/hl7:id/@root"/>
		<xsl:variable name="duplicatedEncounterID">
			<xsl:choose>
				<!-- If encompassingEncounter id has @extension then assume it has a valid @root. -->
				<xsl:when test="$hasEncompassing and string-length(hl7:componentOf/hl7:encompassingEncounter/hl7:id/@extension)">
					<xsl:value-of select="(key('sectionsByRoot',$ccda-EncountersSectionEntriesOptional) | key('sectionsByRoot',$ccda-EncountersSectionEntriesRequired))/hl7:entry/hl7:encounter[
						hl7:id/@root=$encompassingRoot and hl7:id/@extension=$encompassingEncounterID]/hl7:id/@extension"/>
				</xsl:when>
				<xsl:when test="$hasEncompassing">
					<xsl:value-of select="(key('sectionsByRoot',$ccda-EncountersSectionEntriesOptional) | key('sectionsByRoot',$ccda-EncountersSectionEntriesRequired))/hl7:entry/hl7:encounter[
						hl7:id/@root=$encompassingEncounterID]/hl7:id/@root"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="hasDuplicated" select="string-length($duplicatedEncounterID) > 0"/>		
		<xsl:variable name="duplicatedEncounterOrg">
			<xsl:choose>
				<!-- If encompassingEncounter id has @extension then assume it has a valid @root. -->
				<xsl:when test="$hasDuplicated and string-length(hl7:componentOf/hl7:encompassingEncounter/hl7:id/@extension)">
					<xsl:value-of select="(key('sectionsByRoot',$ccda-EncountersSectionEntriesOptional) | key('sectionsByRoot',$ccda-EncountersSectionEntriesRequired))/hl7:entry/hl7:encounter[
						hl7:id/@root=$encompassingRoot and hl7:id/@extension=$encompassingEncounterID]/hl7:id/@root"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Encounter in encompassingEncounter and not duplicated in the Encounters section -->
		<xsl:if test="$hasEncompassing and not($hasDuplicated)">
			<xsl:apply-templates select="hl7:componentOf/hl7:encompassingEncounter" mode="eE-DefaultEncounter"/>
		</xsl:if>
		
		<!-- Encounters that are in the Encounters section and not in encompassingEncounter -->
		<xsl:apply-templates
			select="(key('sectionsByRoot',$ccda-EncountersSectionEntriesOptional) | key('sectionsByRoot',$ccda-EncountersSectionEntriesRequired))/hl7:entry/hl7:encounter[
			                                                                            not(hl7:id/@root=$duplicatedEncounterOrg and hl7:id/@extension=$duplicatedEncounterID)
			                                                                        and not(not(hl7:id/@extension) and hl7:id/@root=$duplicatedEncounterID)]"
			mode="eE-OverriddenEncounter"/>
		
		<!-- Encounter that is both in encompassingEncounter and in the Encounters section -->
		<xsl:if test="$hasDuplicated and string-length($duplicatedEncounterOrg)">
			<xsl:apply-templates select="." mode="eE-DuplicatedEncounter">
				<xsl:with-param name="duplicatedEncounterID" select="$duplicatedEncounterID"/>
				<xsl:with-param name="duplicatedEncounterOrg" select="$duplicatedEncounterOrg"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>