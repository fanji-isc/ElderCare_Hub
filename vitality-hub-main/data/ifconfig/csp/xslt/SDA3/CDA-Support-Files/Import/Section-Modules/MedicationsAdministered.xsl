<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="MedicationsAdministeredSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$medicationsAdministeredSectionTemplateId]" mode="MedicationsAdministeredSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="MedicationsAdministeredSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-Medications"/></xsl:variable>
		<!--
			Include an entry if:
			- It has no encounter link, OR its encounter link points to an encounter within the document.
			AND
			- It includes originalText for its manufacturedMaterial code, OR manufacturedMaterial code is not nullFlavor.
		-->
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and ((not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))) and ((string-length(substring-after(hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#')) or not(hl7:substanceAdministration/hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@nullFlavor)))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Medications>
					<xsl:apply-templates select="$sectionEntries" mode="MedicationsAdministered"/>
				</Medications>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Medications>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Medication'"/>
						<xsl:with-param name="actionScope" select="$medicationsAdministeredPharmacyStatus"/>
					</xsl:apply-templates>
				</Medications>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="MedicationsAdministered">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Medication'"/>
			<xsl:with-param name="actionScope" select="$medicationsAdministeredPharmacyStatus"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:substanceAdministration" mode="Medication">
			<xsl:with-param name="pharmacyStatus" select="$medicationsAdministeredPharmacyStatus"/>
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
