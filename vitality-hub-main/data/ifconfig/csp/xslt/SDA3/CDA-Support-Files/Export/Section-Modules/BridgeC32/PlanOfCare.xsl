<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="planOfCare">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="RadOrders/RadOrder[not(Result)] | LabOrders/LabOrder[not(Result)] | OtherOrders/OtherOrder[not(Result)]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/planOfCare/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-planOfCareSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="18776-5" displayName="Treatment Plan" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Plan of Care</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="planOfCare-Narrative"/>
							<xsl:apply-templates select="." mode="planOfCare-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="planOfCare-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareSection">
		<xsl:if test="$hitsp-CDA-PlanOfCareSection"><templateId root="{$hitsp-CDA-PlanOfCareSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-PlanOfCareSection"><templateId root="{$hl7-CCD-PlanOfCareSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-AssessmentAndPlanSection"><templateId root="{$hl7-CCD-AssessmentAndPlanSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-CarePlan"><templateId root="{$ihe-PCC-CarePlan}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
