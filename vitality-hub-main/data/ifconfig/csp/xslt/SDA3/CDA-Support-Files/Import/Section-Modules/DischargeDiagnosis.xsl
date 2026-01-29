<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="DischargeDiagnosesSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$dischargeDiagnosesSectionTemplateId]" mode="DischargeDiagnosesSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="DischargeDiagnosesSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-DischargeDiagnosis"/></xsl:variable>
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and (not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Diagnoses>
					<xsl:apply-templates select="$sectionEntries" mode="DischargeDiagnoses"/>
				</Diagnoses>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Diagnoses>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Diagnosis'"/>
						<xsl:with-param name="actionScope" select="'DISCHARGE'"/>
					</xsl:apply-templates>
			</Diagnoses>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="DischargeDiagnoses">
		<xsl:variable name="entryEncounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:variable>
		
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Diagnosis'"/>
			<xsl:with-param name="actionScope" select="'DISCHARGE'"/>
			<xsl:with-param name="encounterNumber"><xsl:value-of select="$entryEncounterNumber"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:act/hl7:entryRelationship[@typeCode='SUBJ' and hl7:observation[@classCode='OBS']]" mode="Diagnosis">
			<xsl:with-param name="diagnosisType" select="'D|Discharge'"/>
			<xsl:with-param name="encounterID"><xsl:value-of select="$entryEncounterNumber"/></xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- Determine if the Discharge Diagnosis section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is the $sectionRootPath for the Discharge Diagnosis section.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include discharge diagnosis data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-DischargeDiagnosis">
		<xsl:choose>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
