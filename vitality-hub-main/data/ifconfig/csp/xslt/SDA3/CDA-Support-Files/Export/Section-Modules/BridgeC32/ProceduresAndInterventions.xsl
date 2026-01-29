<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="procedures">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Procedures"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/procedures/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-proceduresSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="47519-4" displayName="History of Procedures" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Procedures and Interventions</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="procedures-Narrative"/>
							<xsl:apply-templates select="." mode="procedures-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="procedures-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-proceduresSection">
		<xsl:if test="$hitsp-CDA-ProceduresAndInterventionsSection"><templateId root="{$hitsp-CDA-ProceduresAndInterventionsSection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProceduresSection"><templateId root="{$hl7-CCD-ProceduresSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ListOfSurgeries"><templateId root="{$ihe-PCC-ListOfSurgeries}"/></xsl:if>		
	</xsl:template>
</xsl:stylesheet>
