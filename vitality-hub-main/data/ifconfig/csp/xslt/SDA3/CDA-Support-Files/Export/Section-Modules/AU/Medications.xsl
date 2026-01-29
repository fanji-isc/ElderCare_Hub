<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="medications">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- I = Inactive, CA = Cancelled, C = Cancelled, D = Discontinued -->
		<xsl:variable name="medicationInactiveOrCancelledStatusCodes">|I|CA|C|D|</xsl:variable>
		<xsl:variable name="hasData" select="Medications/Medication[not(contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|')))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/medications/emptySection/exportData/text()"/>

		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>

					<code code="101.16146" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Medications"/>
					<title>Medications</title>
	
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:choose>
								<xsl:when test="$documentExportType='NEHTASharedHealthSummary'">
									<xsl:apply-templates select="." mode="medications-Narrative-sharedHealthSummary">
										<xsl:with-param name="narrativeLinkCategory">medications</xsl:with-param>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:when test="$documentExportType='NEHTAEventSummary'">
									<xsl:apply-templates select="." mode="medications-Narrative-eventSummary">
										<xsl:with-param name="narrativeLinkCategory">medications</xsl:with-param>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:when test="$documentExportType='NEHTAeReferral'">
									<xsl:apply-templates select="." mode="medications-Narrative-referral">
										<xsl:with-param name="narrativeLinkCategory">medications</xsl:with-param>
									</xsl:apply-templates>
								</xsl:when>
							</xsl:choose>
							<xsl:apply-templates select="." mode="medications-Entries">
								<xsl:with-param name="narrativeLinkCategory">medications</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="medications-NoData">
								<xsl:with-param name="narrativeLinkCategory">medications</xsl:with-param>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
