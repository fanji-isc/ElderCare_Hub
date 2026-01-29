<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sN-NotesSection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-NotesSection)" mode="sN-NotesSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sN-NotesSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sM-IsNoDataSection-Notes"/></xsl:variable>

		<!--
			Include an entry in sectionEntries if:
			(It has no encounter link, OR its encounter link points to an encounter within the document.)
			AND (note exclude list is null OR note code is not in exclude list)
			AND (note include list is null OR not code is in include list)
			AND (section exclude list is null OR section code is not in exclude list)
			AND (section include list is null OR section code is in include list)
		-->
		<xsl:variable name="sectionCode" select="hl7:code/@code"/>
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true')
		and ((not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root)))
		    or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|'))
		    or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|')))
		and (not(string-length($noteExcludeNotes)) 
		    or not(contains($noteExcludeNotes,concat('|',hl7:act/hl7:code/hl7:translation[1]/@code,'|'))))
		and (not(string-length($noteIncludeNotes)) 
		    or contains($noteIncludeNotes,concat('|',hl7:act/hl7:code/hl7:translation[1]/@code,'|')))
		and (not(string-length($noteExcludeSections)) 
		    or not(contains($noteExcludeSections,concat('|',$sectionCode,'|'))))
		and (not(string-length($noteIncludeSections)) 
		    or contains($noteIncludeSections,concat('|',$sectionCode,'|')))
		]"/>

		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Documents>
					<xsl:apply-templates select="$sectionEntries" mode="sN-Notes"/>
				</Documents>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Documents>
					<xsl:apply-templates select="." mode="fn-XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Document'"/>
					</xsl:apply-templates>
				</Documents>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="sN-Notes">		
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Document'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:act" mode="eN-Note"/>
	</xsl:template>
	
	<!-- 
		Determine if a Notes section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		Return 1 if the section is present and there is no hl7:entry element.
		Return 1 if the section is present and explicitly indicates "No Data" according to HS standard logic.
		Otherwise Return 0 (section is present and appears to include medications data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sM-IsNoDataSection-Notes">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>