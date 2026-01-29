<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="medications-Ceased">
		<xsl:param name="sectionRequired" select="'0'"/>

		<!-- I = Inactive, CA = Cancelled, C = Cancelled, D = Discontinued -->
		<xsl:variable name="medicationInactiveOrCancelledStatusCodes">|I|CA|C|D|</xsl:variable>
		<!-- Ceased Medications is only for Discharge Summary, which is a single-encounter document.
			A medication is considered ceased if:
			(Medication Status code is one of the Inactive or Cancelled codes)
			OR
			(Encounter ToTime has a value AND Medication ToTime has a value AND Medication ToTime is before the Encounter ToTime)
		-->
		<xsl:variable name="hasData" select="Medications/Medication[contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|')) or (string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) > 0)]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeCeasedMedications/emptySection/exportData/text()"/>

		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="101.16146.4.1.2" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Ceased Medications"/>
					<title>Ceased Medications</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="medications-Narrative-dischargeCeased">
								<xsl:with-param name="narrativeLinkCategory">dischargeCeasedMedications</xsl:with-param>
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="medications-Entries">
								<xsl:with-param name="narrativeLinkCategory">dischargeCeasedMedications</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="medications-NoData">
								<xsl:with-param name="narrativeLinkCategory">dischargeCeasedMedications</xsl:with-param>
							</xsl:apply-templates>
					</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
