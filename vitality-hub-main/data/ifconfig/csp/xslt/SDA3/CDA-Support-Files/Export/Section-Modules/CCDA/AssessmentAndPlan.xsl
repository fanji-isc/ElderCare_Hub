<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="assessmentAndPlan">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Documents/Document[DocumentType/Code/text()='AssessmentAndPlan']"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/assessmentAndPlan/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-assessmentAndPlanSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="51847-2" displayName="Assessment and Plan" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Assessment and Plan</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="assessmentAndPlan-Narrative"/>
							<xsl:apply-templates select="." mode="assessmentAndPlan-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="assessmentAndPlan-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-assessmentAndPlanSection">
		<xsl:if test="$ccda-AssessmentAndPlanSection"><templateId root="{$ccda-AssessmentAndPlanSection}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
