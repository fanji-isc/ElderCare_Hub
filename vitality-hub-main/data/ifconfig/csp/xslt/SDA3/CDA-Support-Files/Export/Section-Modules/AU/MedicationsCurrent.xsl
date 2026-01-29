<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="medications-Current">
		<xsl:param name="sectionRequired" select="'0'"/>
	
		<!-- I = Inactive, CA = Cancelled, C = Cancelled, D = Discontinued -->
		<xsl:variable name="medicationInactiveOrCancelledStatusCodes">|I|CA|C|D|</xsl:variable>
		<!-- Current Medications is only for Discharge Summary, which is a single-encounter document.
			A medication is considered current if:
			(Medication Status code is NOT one of the Inactive or Cancelled codes)
			AND
			(
			Medication ToTime is blank
			OR
			Encounter ToTime has a value AND Medication ToTime has a value AND Medication ToTime is at or after the Encounter ToTime
			)
		-->
		<xsl:variable name="hasData" select="Medications/Medication[not(contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|'))) and ((not(string-length(ToTime/text())) or (string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and not(isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) > 0))))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeCurrentMedications/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="101.16146.4.1.1" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Current Medications On Discharge"/>
					<title>Current Medications On Discharge</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="medications-Narrative-dischargeCurrent">
								<xsl:with-param name="narrativeLinkCategory">dischargeCurrentMedications</xsl:with-param>
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="medications-Entries">
								<xsl:with-param name="narrativeLinkCategory">dischargeCurrentMedications</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="medications-NoData">
								<xsl:with-param name="narrativeLinkCategory">dischargeCurrentMedications</xsl:with-param>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
