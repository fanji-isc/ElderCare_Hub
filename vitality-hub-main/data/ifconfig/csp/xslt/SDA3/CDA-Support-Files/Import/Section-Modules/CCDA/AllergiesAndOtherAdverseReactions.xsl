<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="AllergiesSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-AllergiesSectionEntriesOptional or hl7:templateId/@root=$ccda-AllergiesSectionEntriesRequired]" mode="Allergies"/>
	</xsl:template>
	
	<xsl:template match="*" mode="Allergies">
		<xsl:variable name="IsNoDataSection">
			<xsl:apply-templates select="." mode="IsNoDataSection-Allergies"/>
		</xsl:variable>
		
		<xsl:if test="$IsNoDataSection='0' or $documentActionCode='XFRM'">
			<Allergies>
				<!-- Process CDA Append/Transform/Replace Directive -->
				<xsl:call-template name="ActionCode">
					<xsl:with-param name="informationType" select="'Allergy'"/>
				</xsl:call-template>
				
				<xsl:apply-templates select="hl7:entry[$IsNoDataSection='0' and not(.//@negationInd='true')]/hl7:act" mode="Allergy"/>
			</Allergies>
		</xsl:if>
	</xsl:template>
	
	<!-- Determine if the Allergies section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is the $sectionRootPath for the Allergies section.
		Return 1 if the section is present and there is no hl7:entry element.
		Return 1 if the section is present and explicitly indicates "No Data" according to HS standard logic.
		Otherwise Return 0 (section is present and appears to include allergies data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-Allergies">
		<!-- SNOMED code 160244002 is for "No Known allergies". -->
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and hl7:entry[1]/hl7:act/hl7:entryRelationship/hl7:observation/hl7:value/@code='160244002' and hl7:entry[1]/hl7:act/hl7:entryRelationship/hl7:observation/hl7:value/@codeSystem=$snomedOID">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and hl7:entry[1]/hl7:act/hl7:entryRelationship/hl7:observation/hl7:id/@nullFlavor='NI'">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and hl7:entry[1]/hl7:act/hl7:entryRelationship/hl7:observation/hl7:id and not(hl7:entry[1]/hl7:act/hl7:entryRelationship/hl7:observation/hl7:participant) and not(hl7:entry[1]/hl7:act/hl7:entryRelationship/hl7:observation/hl7:entryRelationship[@typeCode='MFST'])">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
