<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="clinicalSynopsis">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Encounters/Encounter/VisitDescription"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/clinicalSynopsis/emptySection/exportData/text()"/>

		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="102.15513.4.1.1" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Clinical Synopsis"/>
					<title>Clinical Synopsis</title>
					
					<xsl:apply-templates select="." mode="clinicalSynopsis-Narrative"/>
					<xsl:apply-templates select="." mode="clinicalSynopsis-EntryDetail"/>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
