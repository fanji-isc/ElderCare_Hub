<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sM-MedicationsSection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-MedicationsSectionEntriesOptional) | key('sectionsByRoot',$ccda-MedicationsSectionEntriesRequired)" mode="sM-MedicationsSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sM-MedicationsSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sM-IsNoDataSection-Medications"/></xsl:variable>
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
				<Medications>
					<xsl:apply-templates select="$sectionEntries" mode="sM-Medications"/>
				</Medications>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Medications>
					<xsl:apply-templates select="." mode="fn-XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Medication'"/>
						<xsl:with-param name="actionScope" select="$medicationsPharmacyStatus"/>
					</xsl:apply-templates>
				</Medications>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="sM-Medications">		
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Medication'"/>
			<xsl:with-param name="actionScope" select="'MEDICATIONS'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:substanceAdministration" mode="eM-Medication">
			<xsl:with-param name="pharmacyStatus" select="$medicationsPharmacyStatus"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- Determine if a Medications section is present but has or indicates no data present.
		This template is used for medications, discharge medications, and medications administered.
		This logic is applied only if the section is present.
		The input node spec is $medicationSection, $dischargeMedicationSection or $medicationsAdministeredSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Return 1 if the section is present and explicitly indicates "No Data" according to HS standard logic.
		Otherwise Return 0 (section is present and appears to include medications data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sM-IsNoDataSection-Medications">
		<!-- SNOMED code 182849000 is for "No Known medications". -->
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1">
				<xsl:variable name="firstCode" select="hl7:entry[1]/hl7:substanceAdministration[1]/hl7:code"/>
				<xsl:choose>
					<xsl:when test="$firstCode/@code='182849000' and $firstCode/@codeSystem=$snomedOID">1</xsl:when>
					<xsl:when test="hl7:entry[1]/hl7:substanceAdministration[1]/@negationInd='true'
						          and hl7:entry[1]/hl7:substanceAdministration[1]/hl7:id/@nullFlavor='NI'
						          and $firstCode/@nullFlavor='NI'">1</xsl:when>
					<xsl:when test="hl7:entry[1]/hl7:substanceAdministration[1]/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/@nullFlavor='NI'">1</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>