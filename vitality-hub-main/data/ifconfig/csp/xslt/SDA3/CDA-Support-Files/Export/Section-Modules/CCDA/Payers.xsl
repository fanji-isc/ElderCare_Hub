<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="payers">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Encounters/Encounter/HealthFunds"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/payers/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-payersSection"/>
					
					<code code="48768-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Payers"/>
					<title>Payers</title>
					
					<!-- We just want each distinct insurance policy, so sort it  -->
					<!-- out here and feed *that* to the Entry-Modules templates. -->
					<xsl:variable name="insuranceInformation">
						<Insurance xmlns="">
						<xsl:for-each select="set:distinct(Encounters/Encounter/HealthFunds/HealthFund/HealthFund/Code)">
							<xsl:for-each select="set:distinct(../../MembershipNumber)">
								<xsl:copy-of select=".."/>
							</xsl:for-each>
						</xsl:for-each>
						</Insurance>
					</xsl:variable>
					<xsl:variable name="insurance" select="exsl:node-set($insuranceInformation)/Insurance"/>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="$insurance" mode="payers-Narrative"/>
							<xsl:apply-templates select="$insurance" mode="payers-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="payers-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-payersSection">
		<templateId root="{$ccda-PayersSection}"/>
	</xsl:template>
</xsl:stylesheet>
