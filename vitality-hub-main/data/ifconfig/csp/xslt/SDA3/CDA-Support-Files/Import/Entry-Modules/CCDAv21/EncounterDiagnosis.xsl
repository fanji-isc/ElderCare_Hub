<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" exclude-result-prefixes="hl7">
	<!-- AlsoInclude: Condition.xsl -->
	
	<xsl:template match="*" mode="eED-EncounterDiagnosis-OverriddenEncounter">
		<!-- Encounters using an <encounter> id -->
		<!--
			$encounterIDTemp is used as an intermediate so that
			$encounterID can be set such that "000nnn" does NOT
			match "nnn" when comparing encounter numbers.
			
			The EncounterId template is in Import/Entry-Modules/CCDA/Encounter.xsl.
			This template assumes that Encounter.xsl is included in the
			current transform.
		-->
		<xsl:variable name="encounterIDTemp"><xsl:apply-templates select="." mode="fn-S-formatEncounterId"/></xsl:variable>
		
		<Diagnoses>
			<xsl:apply-templates select="hl7:entryRelationship/hl7:act[hl7:templateId/@root=$ccda-EncounterDiagnosis]/hl7:entryRelationship" mode="eCn-Diagnosis">
				<xsl:with-param name="diagnosisType" select="D|Discharge"/>
				<xsl:with-param name="encounterID" select="string($encounterIDTemp)"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="." mode="eED-ImportCustom-EncounterDiagnosis"/>
		</Diagnoses>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
	
		The input node spec is $sectionRootPath/hl7:entry/hl7:encounter
	-->
	<xsl:template match="*" mode="eED-ImportCustom-EncounterDiagnosis">
	</xsl:template>
	
</xsl:stylesheet>