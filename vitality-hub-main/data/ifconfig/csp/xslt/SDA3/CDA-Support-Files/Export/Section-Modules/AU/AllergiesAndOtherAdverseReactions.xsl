<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="allergies">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData">
			<xsl:choose>
				<xsl:when test="$documentExportType='NEHTADischargeSummary' or $documentExportType='NEHTASharedHealthSummary' or $documentExportType='NEHTAeReferral'">
					<xsl:value-of select="Allergies"/>
				</xsl:when>
				<xsl:when test="$documentExportType='NEHTAEventSummary'">
					<xsl:apply-templates select="Allergies/Allergy" mode="allergies-newlyDiscovered"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/allergies/emptySection/exportData/text()"/>

		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>

					<code code="101.20113" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Adverse Reactions"/>
					<title>Adverse Reactions</title>
	
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:choose>
								<xsl:when test="$documentExportType='NEHTADischargeSummary'">
									<xsl:apply-templates select="Allergies" mode="allergies-Narrative-Discharge"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="Allergies" mode="allergies-Narrative"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:apply-templates select="Allergies" mode="allergies-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="allergies-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="allergies-newlyDiscovered">
		<!-- This logic depends on there being one and only one Encounter in the SDA Container. -->
		<xsl:variable name="allergyStart">
			<xsl:choose>
				<xsl:when test="string-length(DiscoveryTime/text())">
					<xsl:value-of select="DiscoveryTime/text()"/>
				</xsl:when>
				<xsl:when test="string-length(FromTime/text())">
					<xsl:value-of select="FromTime/text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Need to have an allergy start to compare against -->
		<xsl:if test="string-length($allergyStart)">
			<!-- Must be on or after Encounter start date -->
			<xsl:if test="not(isc:evaluate('dateDiff', 'dd', translate($allergyStart, 'TZ', ' '), translate(/Container/Encounters/Encounter/FromTime/text(), 'TZ', ' ')) > 0)">
				<xsl:choose>
					<!-- If there is an Encounter end date then allergy must start on or before that -->
					<xsl:when test="string-length(/Container/Encounters/Encounter/ToTime/text())">
						<xsl:if test="isc:evaluate('dateDiff', 'dd', translate($allergyStart, 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) > 0">1</xsl:if>
					</xsl:when>
					<!-- Otherwise if no Encounter end date then allergy is considered started within Encounter -->
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
