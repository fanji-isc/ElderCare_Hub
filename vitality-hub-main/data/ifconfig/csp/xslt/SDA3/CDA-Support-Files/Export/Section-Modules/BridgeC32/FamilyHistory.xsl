<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="familyHistory">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="FamilyHistories"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/familyHistory/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templatedIds-familyHistorySection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="10157-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Family History</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="FamilyHistories" mode="familyHistory-Narrative"/>
							<xsl:apply-templates select="FamilyHistories" mode="familyHistory-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="familyHistory-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templatedIds-familyHistorySection">
		<xsl:if test="$hitsp-CDA-FamilyHistorySection"><templateId root="{$hitsp-CDA-FamilyHistorySection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-FamilyHistorySection"><templateId root="{$hl7-CCD-FamilyHistorySection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-FamilyMedicalHistory"><templateId root="{$ihe-PCC-FamilyMedicalHistory}"/></xsl:if>
		<xsl:if test="$ihe-PCC-CodedFamilyMedicalHistory"><templateId root="{$ihe-PCC-CodedFamilyMedicalHistory}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
