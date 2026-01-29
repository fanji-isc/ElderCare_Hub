<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
  <!-- Entry module has non-parallel name. AlsoInclude: AllergyAndDrugSensitivity.xsl -->
  
	<xsl:template match="*" mode="sAOAR-AllergiesSection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-AllergiesSectionEntriesOptional) | key('sectionsByRoot',$ccda-AllergiesSectionEntriesRequired)" mode="sAOAR-Allergies"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sAOAR-Allergies">
		<xsl:variable name="IsNoDataSection">
			<xsl:apply-templates select="." mode="sAOAR-IsNoDataSection-Allergies"/>
		</xsl:variable>
		
		<xsl:if test="$IsNoDataSection='0' or $documentActionCode='XFRM'">
			<Allergies>
				<!-- Process CDA Append/Transform/Replace Directive -->
				<xsl:call-template name="ActionCode">
					<xsl:with-param name="informationType" select="'Allergy'"/>
				</xsl:call-template>
				
				<xsl:if test="$IsNoDataSection='0'">
					<xsl:apply-templates select="hl7:entry[not(.//@negationInd='true')]/hl7:act" mode="eADS-Allergy"/>
				</xsl:if>
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
	<xsl:template match="hl7:section" mode="sAOAR-IsNoDataSection-Allergies">
		<!-- SNOMED code 160244002 is for "No Known allergies". -->
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1">
				<xsl:variable name="firstObsv" select="hl7:entry[1]/hl7:act/hl7:entryRelationship/hl7:observation"/>
				<xsl:choose>
					<xsl:when test="$firstObsv/hl7:value/@code='160244002' and $firstObsv/hl7:value/@codeSystem=$snomedOID">1</xsl:when>
					<xsl:when test="$firstObsv/hl7:id/@nullFlavor='NI'">1</xsl:when>
					<xsl:when test="$firstObsv/hl7:id and not($firstObsv/hl7:participant) and not($firstObsv/hl7:entryRelationship[@typeCode='MFST'])">1</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>