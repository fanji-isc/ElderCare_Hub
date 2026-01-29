<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
  <!-- Entry module has non-parallel name. AlsoInclude: Condition.xsl -->
  
	<xsl:template match="*" mode="sPL-problems">
		<xsl:param name="sectionRequired" select="'0'"/>
		<xsl:param name="entriesRequired" select="'0'"/>
		
		<xsl:variable name="currentConditionStatusCodes" select="$exportConfiguration/problems/currentCondition/codes/text()"/>
		<xsl:variable name="currentConditionWindowInDays" select="$exportConfiguration/problems/currentCondition/windowInDays/text()"/>		

		<!--
			Exclude Problems with Category of 248536006 (Finding of functional
			performance and activity) or 373930000 (Cognitive function finding).
			These belong in the Functional Status section.
		-->
		<xsl:variable name="hasData" select="count(Problems/Problem[(not(Category/Code/text()='248536006') and not(Category/Code/text()='373930000'))
		  and (not(ToTime)
			     or contains($currentConditionStatusCodes, concat('|', Status/Code/text(), '|'))
		    	 or (isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt;= $currentConditionWindowInDays))])"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/problems/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<!-- <xsl:if test="$hasData = 0"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if> -->
					<xsl:call-template name="sPL-templateIds-problemsSection">
						<xsl:with-param name="entriesRequired" select="$entriesRequired"/>
					</xsl:call-template>
					
					<code code="11450-4" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Problem list"/>
					<title>Problems</title>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="." mode="eCn-conditions-Narrative">
								<xsl:with-param name="useCurrentConditions" select="true()"/>
								<xsl:with-param name="narrativeLinkCategory">problems</xsl:with-param>
							</xsl:apply-templates>
							
							<xsl:apply-templates select="." mode="eCn-conditions-Entries">
								<xsl:with-param name="useCurrentConditions" select="true()"/>
								<xsl:with-param name="narrativeLinkCategory">problems</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<!--Note that for no known problems, the section cannot have the
							nullFalvor attribute present and set to "NI".
							-->
							<xsl:apply-templates select="." mode="eCn-problems-NoKnownProblem"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<!-- If the "entries required" templateId is needed then this template is overridden by *EntriesRequired.xsl -->
	<xsl:template name="sPL-templateIds-problemsSection">
		<xsl:param name="entriesRequired"/>
		<xsl:choose>
			<xsl:when test="$entriesRequired = '1'">
				<templateId root="{$ccda-ProblemSectionEntriesRequired}"/>
				<templateId root="{$ccda-ProblemSectionEntriesRequired}" extension="2015-08-01"/>
			</xsl:when>
			<xsl:otherwise>
				<templateId root="{$ccda-ProblemSectionEntriesOptional}"/>
				<templateId root="{$ccda-ProblemSectionEntriesOptional}" extension="2015-08-01"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>