<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="PlanOfCareSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-PlanOfCareSection]" mode="PlanOfCareSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCareSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-Plan"/></xsl:variable>
		
		<xsl:if test="$isNoDataSection='0'">
			<xsl:apply-templates select="hl7:entry[hl7:observation/hl7:templateId/@root=$ccda-PlanOfCareActivityObservation and not(.//@negationInd='true')]" mode="PlanOfCare-Orders"/>
			<xsl:apply-templates select="hl7:entry[hl7:substanceAdministration/hl7:templateId/@root=$ccda-PlanOfCareActivitySubstanceAdministration and not(.//@negationInd='true')]" mode="PlanOfCare-Medications"/>
			<xsl:apply-templates select="hl7:entry[hl7:encounter/hl7:templateId/@root=$ccda-PlanOfCareActivityEncounter and hl7:encounter/@moodCode='INT' and not(.//@negationInd='true')]" mode="PlanOfCare-Appointments"/>
			<xsl:apply-templates select="hl7:entry[hl7:encounter/hl7:templateId/@root=$ccda-PlanOfCareActivityEncounter and hl7:encounter/@moodCode='RQO' and not(.//@negationInd='true')]" mode="PlanOfCare-Referrals"/>
			<xsl:apply-templates select="hl7:entry[hl7:procedure/hl7:templateId/@root=$ccda-PlanOfCareActivityProcedure and not(.//@negationInd='true')]" mode="PlanOfCare-Procedures"/>
			<xsl:apply-templates select="hl7:entry[hl7:act/hl7:templateId/@root=$ccda-PlanOfCareActivityAct and not(.//@negationInd='true')]" mode="PlanOfCare-Goals"/>
			<xsl:apply-templates select="hl7:entry[hl7:act/hl7:templateId/@root=$ccda-Instructions and not(.//@negationInd='true')]" mode="PlanOfCare-Instructions"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Order'"/>
			<xsl:with-param name="actionScope" select="'OTH'"/>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:observation[not(.//@negationInd='true')]" mode="Plan"/>
	</xsl:template>
	
	<!--
		Determine if the Plan section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $planSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include plan data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-Plan">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
