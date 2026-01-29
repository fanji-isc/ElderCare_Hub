<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
  <!-- AlsoInclude: Medication.xsl -->
  
	<xsl:template match="*" mode="sIm-ImmunizationsSection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-ImmunizationsSectionEntriesOptional) | key('sectionsByRoot',$ccda-ImmunizationsSectionEntriesRequired)" mode="sIm-ImmunizationsSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sIm-ImmunizationsSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sIm-IsNoDataSection-Immunizations"/></xsl:variable>
		<!--
			Include an entry in sectionEntries if:
			(It has no encounter link, OR its encounter link points to an encounter within the document.)
			AND
			(
			- It includes originalText (text inline or text in narrative) under manufacturedMaterial code.
			OR
			- It includes manufacturedMaterial code/@code.
			OR
			- manufacturedMaterial code is nullFlavor AND it includes manufacturedMaterial code/translation/@code.
			)
			
			The last three conditions are intended to help prevent importing empty
			SDA OrderItem (i.e., <OrderItem><Code/><Description/></OrderItem>).
		-->
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and 
			((not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root)))
			  or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|'))
			  or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|')))
			and (((string-length(substring-after(hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#'))
			       and string-length(normalize-space(key('narrativeKey', substring-after(hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#')))))
			      or (string-length(normalize-space(hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/text()))))
			     or (hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@code)
			     or ((hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@nullFlavor)
			         and (hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:translation/@code)))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Vaccinations>
					<xsl:apply-templates select="$sectionEntries" mode="sIm-Immunizations"/>
				</Vaccinations>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Vaccinations>
					<xsl:apply-templates select="." mode="fn-XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Vaccination'"/>
					</xsl:apply-templates>
				</Vaccinations>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
		
	<xsl:template match="hl7:entry" mode="sIm-Immunizations">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Vaccination'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:substanceAdministration" mode="eM-Medication">
			<xsl:with-param name="medicationType" select="'VXU'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- Determine if the Immunizations section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $immunizationSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Return 1 if there is one hl7:entry and the hl7:code elements or the hl7:manufacturedMaterial indicated nullFlavor.
		Otherwise Return 0 (section is present and appears to include immunizations data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sIm-IsNoDataSection-Immunizations">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1">
				<xsl:variable name="firstMaterial" select="hl7:entry[1]/hl7:substanceAdministration[1]/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial"/>
				<xsl:choose>
					<xsl:when test="hl7:entry[1]/hl7:substanceAdministration[1]/hl7:code/@nullFlavor='NI'
						            and $firstMaterial/hl7:code/@nullFlavor='NI'">1</xsl:when>
					<xsl:when test="$firstMaterial/@nullFlavor='NI'">1</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>