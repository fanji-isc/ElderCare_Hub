<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="socialHistory">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="boolean(SocialHistories) or boolean(Patient/GenderIdentity)"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/socialHistory/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-socialHistorySection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="29762-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Social History</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<text>
								<xsl:apply-templates select="SocialHistories" mode="socialHistory-Narrative"/>
								<xsl:apply-templates select="Patient/GenderIdentity" mode="socialHistory-Narrative-GenderIdentity">
									<xsl:with-param name="genderIdentityDate" select="Patient/EnteredOn"/>
								</xsl:apply-templates>
							</text>
							<xsl:apply-templates select="SocialHistories" mode="socialHistory-Entries"/>
							<xsl:apply-templates select="Patient/GenderIdentity" mode="socialHistory-GenderIdentity-EntryDetail">
								<xsl:with-param name="genderIdentityDate" select="Patient/EnteredOn"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="socialHistory-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-socialHistorySection">
		<xsl:if test="$hitsp-CDA-SocialHistorySection"><templateId root="{$hitsp-CDA-SocialHistorySection}"/></xsl:if>
		<xsl:if test="$hl7-CCD-SocialHistorySection"><templateId root="{$hl7-CCD-SocialHistorySection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SocialHistory"><templateId root="{$ihe-PCC-SocialHistory}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
