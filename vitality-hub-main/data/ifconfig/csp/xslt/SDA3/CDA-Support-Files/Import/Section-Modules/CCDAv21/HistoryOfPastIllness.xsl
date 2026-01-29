<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
	<!-- AlsoInclude: Condition.xsl -->
	
	<xsl:template match="*" mode="sHOPasI-ResolvedProblemsSection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-HistoryOfPastIllnessSection)" mode="sHOPasI-ResolvedProblemsSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sHOPasI-ResolvedProblemsSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sHOPasI-IsNoDataSection-ResolvedProblems"/></xsl:variable>
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and (not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Problems>
					<xsl:apply-templates select="$sectionEntries" mode="sHOPasI-ResolvedProblems"/>
				</Problems>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Problems>
					<xsl:apply-templates select="." mode="fn-XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Problem'"/>
						<xsl:with-param name="actionScope" select="'PAST'"/>
					</xsl:apply-templates>
				</Problems>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="sHOPasI-ResolvedProblems">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Problem'"/>
			<xsl:with-param name="actionScope" select="'PAST'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:act[not(.//@negationInd='true')]" mode="eCn-Condition"/>
	</xsl:template>
	
	<!-- Determine if the Resolved Problems (Past Illness) section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $resolvedProblemSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include past illness data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sHOPasI-IsNoDataSection-ResolvedProblems">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and (hl7:entry[1]/hl7:act[1]/hl7:entryRelationship[1]/hl7:observation/@negationInd='true')">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
