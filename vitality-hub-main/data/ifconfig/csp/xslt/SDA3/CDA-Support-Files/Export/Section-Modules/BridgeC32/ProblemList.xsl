<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="problems">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="currentConditionStatusCodes" select="$exportConfiguration/problems/currentCondition/codes/text()"/>
		<xsl:variable name="currentConditionWindowInDays" select="$exportConfiguration/problems/currentCondition/windowInDays/text()"/>
		<xsl:variable name="hasData" select="Problems/Problem[contains($currentConditionStatusCodes, concat('|', Status/Code/text(), '|')) or not(ToTime) or (isc:evaluate('dateDiff', 'dd', translate(translate(FromTime/text(), 'Z', ''), 'T', ' ')) &lt;= $currentConditionWindowInDays)]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/problems/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-problemsSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="11450-4" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Problem list"/>
					<title>Problems</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="conditions-Narrative">
								<xsl:with-param name="currentConditions" select="true()"/>
								<xsl:with-param name="narrativeLinkCategory">problems</xsl:with-param>
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="conditions-Entries">
								<xsl:with-param name="currentConditions" select="true()"/>
								<xsl:with-param name="narrativeLinkCategory">problems</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="problems-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-problemsSection">
		<xsl:if test="$hitsp-CDA-ProblemListSection"><templateId root="{$hitsp-CDA-ProblemListSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProblemSection"><templateId root="{$hl7-CCD-ProblemSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ActiveProblems"><templateId root="{$ihe-PCC-ActiveProblems}"/></xsl:if>		
	</xsl:template>
</xsl:stylesheet>
