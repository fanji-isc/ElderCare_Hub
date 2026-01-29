<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="PlanOfCareSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$planSectionTemplateId]" mode="PlanOfCareSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCareSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-Plan"/></xsl:variable>
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and (not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<OtherOrders>
					<xsl:apply-templates select="$sectionEntries" mode="PlanOfCare"/>
				</OtherOrders>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<OtherOrders>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'OtherOrder'"/>
					</xsl:apply-templates>
				</OtherOrders>
			</xsl:when>
		</xsl:choose>

		<xsl:if test="$isNoDataSection='0'">
			<!-- Procedure Entries -->
			<xsl:apply-templates select="hl7:entry[hl7:procedure/hl7:templateId/@root=$ihe-PCC_CDASupplement-ProcedureEntry and not(.//@negationInd='true')]" mode="PlanOfCare-Procedures"/>
		</xsl:if>
	</xsl:template>
		
	<xsl:template match="*" mode="PlanOfCare">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'OtherOrder'"/>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:observation" mode="Plan"/>
	</xsl:template>
	
	<!-- Determine if the Plan section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is the $sectionRootPath for the Plan of Care section.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include plan data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-Plan">
		<xsl:choose>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
