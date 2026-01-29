<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="ImmunizationsSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$immunizationsSectionTemplateId]" mode="ImmunizationsSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="ImmunizationsSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-Immunizations"/></xsl:variable>
		<!--
			Include an entry in sectionEntries if:
			(
			- It has no encounter link, OR its encounter link points to an encounter within the document.
			)
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
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and ((not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))) and (((string-length(substring-after(hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#')) and string-length(normalize-space(key('narrativeKey', substring-after(hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#'))))) or (string-length(normalize-space(hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/text())))) or (hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@code) or ((hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@nullFlavor) and (hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:translation/@code)))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Vaccinations>
					<xsl:apply-templates select="$sectionEntries" mode="Immunizations"/>
				</Vaccinations>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Vaccinations>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Vaccination'"/>
					</xsl:apply-templates>
				</Vaccinations>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
		
	<xsl:template match="*" mode="Immunizations">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Vaccination'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
				
		<xsl:apply-templates select="hl7:substanceAdministration" mode="Medication">
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
	<xsl:template match="*" mode="IsNoDataSection-Immunizations">
		<xsl:choose>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and hl7:entry[1]/hl7:substanceAdministration[1]/hl7:code/@nullFlavor='NI' and hl7:entry[1]/hl7:substanceAdministration[1]/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@nullFlavor='NI'">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and hl7:entry[1]/hl7:substanceAdministration[1]/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/@nullFlavor='NI'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
