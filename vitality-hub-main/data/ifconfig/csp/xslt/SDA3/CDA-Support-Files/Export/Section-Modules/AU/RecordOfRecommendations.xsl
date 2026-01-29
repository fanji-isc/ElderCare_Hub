<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="recordOfRecommendations">
		<xsl:variable name="hasData" select="Encounters/Encounter/RecommendationsProvided"/>
		
		<component>
			<section>					
				<!-- IHE needs unique id for each and every section -->
				<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
				
				<code code="101.20016" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Record of Recommendations and Information Provided"/>
				<title>Record of Recommendations and Information Provided</title>
				
				<xsl:choose>
					<xsl:when test="$hasData">
						<xsl:apply-templates select="." mode="recommendations-Narrative"/>
						<xsl:apply-templates select="." mode="recommendations-Entries"/>
					</xsl:when>
					<xsl:otherwise>
						<text>No recommendations provided.</text>
					</xsl:otherwise>
				</xsl:choose>
			</section>
		</component>
	</xsl:template>
</xsl:stylesheet>
