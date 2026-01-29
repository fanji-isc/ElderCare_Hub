<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="EncounterDiagnosesSection">
		<!-- Default (encompassing) encounter does not have a spec for Encounter Diagnosis. -->
			
		<!-- Entries using overridden encounter-->
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-EncountersSectionEntriesOptional or hl7:templateId/@root=$ccda-EncountersSectionEntriesRequired]/hl7:entry[not(.//@negationInd='true')]/hl7:encounter[hl7:entryRelationship/hl7:act/hl7:templateId/@root=$ccda-EncounterDiagnosis]" mode="EncounterDiagnosis-OverriddenEncounter"/>
	</xsl:template>
</xsl:stylesheet>
