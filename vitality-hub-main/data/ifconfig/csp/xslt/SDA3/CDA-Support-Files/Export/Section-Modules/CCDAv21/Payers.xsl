<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="exsl set">
  <!-- Entry module has non-parallel name. AlsoInclude: InsuranceProvider.xsl -->
  
	<xsl:template match="*" mode="sP-payers">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="count(Encounters/Encounter/HealthFunds)"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/payers/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="$hasData = 0"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sP-templateIds-payersSection"/>
					
					<code code="48768-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Payers"/>
					<title>Payers</title>
					
					<!-- We just want each distinct insurance policy, so sort it
					     out here and feed *that* to the Entry-Modules templates. -->
					<xsl:variable name="insuranceInformation">
						<Insurance xmlns="">
						<xsl:for-each select="set:distinct(Encounters/Encounter/HealthFunds/HealthFund/HealthFund/Code)">
							<xsl:choose>
								<xsl:when test="../../MembershipNumber">
									<!-- Make groupings of the "outer" HealthFund elements. -->
									<xsl:for-each select="set:distinct(../../MembershipNumber)">
										<xsl:copy-of select=".."/>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<!-- When the (outer) HealthFund does not have a MembershipNumber, we can't aggregate it into a group. -->
									<xsl:copy-of select="../.."/>
								</xsl:otherwise>
							</xsl:choose>							
						</xsl:for-each>
						</Insurance>
					</xsl:variable>
					<xsl:variable name="insurance" select="exsl:node-set($insuranceInformation)/Insurance"/>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="$insurance" mode="eIP-payers-Narrative"/>
							<xsl:apply-templates select="$insurance" mode="eIP-payers-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eIP-payers-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sP-templateIds-payersSection">
		<templateId root="{$ccda-PayersSection}"/>
		<templateId root="{$ccda-PayersSection}" extension="2015-08-01"/>
	</xsl:template>
	
</xsl:stylesheet>