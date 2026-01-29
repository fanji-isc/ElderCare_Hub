<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="HealthFunds">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'HealthFund'"/>
		</xsl:call-template>
		
		<xsl:apply-templates select=".//hl7:act[hl7:templateId/@root=$ccda-CoverageActivity and not(.//@negationInd='true')]" mode="HealthFund"/>
	</xsl:template>

	<!--
		Templates to import payers as MemberEnrollments when configured
	-->
	<xsl:template match="*" mode="PayersSection">
		<xsl:if test="$memberEnrollmentImportMode = '1'">
			<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-PayersSection]" mode="PayersSectionEntries"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:section" mode="PayersSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-Payers-MemberEnrollments"/></xsl:variable>

		<xsl:if test="$isNoDataSection='0' or $documentActionCode='XFRM'">
			<MemberEnrollments>
				<!-- Process CDA Append/Transform/Replace Directive -->
				<xsl:call-template name="ActionCode">
					<xsl:with-param name="informationType" select="'MemberEnrollment'"/>
				</xsl:call-template>
				
				<xsl:if test="$isNoDataSection='0'">
					<xsl:apply-templates select=".//hl7:act[hl7:templateId/@root=$ccda-CoverageActivity and not(.//@negationInd='true')]" mode="MemberEnrollment"/>
				</xsl:if>
			</MemberEnrollments>
		</xsl:if>
	</xsl:template>

  <!--
		Determine if the Payers section is present but has or indicates no data present.
		This logic is applied only if the section is present and importing MemberEnrollments.
		The input node spec is $payersSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include payers data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="IsNoDataSection-Payers-MemberEnrollments">
		<xsl:choose>
			<xsl:when test="count(hl7:entry) = 0">1</xsl:when>
			<xsl:when test="count(.//hl7:act[hl7:templateId/@root=$ccda-CoverageActivity and not(.//@negationInd='true')]) = 0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>