<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sED-EncounterDiagnosesSection">
		<!-- Default (encompassing) encounter does not have a spec for Encounter Diagnosis. -->
			
		<!-- Entries using overridden encounter-->
		<xsl:apply-templates select="(key('sectionsByRoot',$ccda-EncountersSectionEntriesOptional) | key('sectionsByRoot',$ccda-EncountersSectionEntriesRequired))/hl7:entry/hl7:encounter[hl7:entryRelationship/hl7:act/hl7:templateId/@root=$ccda-EncounterDiagnosis]"
			                   mode="eED-EncounterDiagnosis-OverriddenEncounter"/>
	</xsl:template>
	
</xsl:stylesheet>