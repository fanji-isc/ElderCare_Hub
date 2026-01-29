<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="event">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<component>
			<section>					
				<!-- IHE needs unique id for each and every section -->
				<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
				
				<code code="101.16006" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Event"/>
				<title>Event</title>
				<text mediaType="text/x-hl7-text+xml">
					<paragraph>This section may contain the following subsections Problems/Diagnoses This Visit, Clinical Interventions Performed This Visit and Clinical Synopsis and Diagnostic Investigations.</paragraph>
				</text>
				
				<!-- Problems/Diagnoses -->
				<xsl:apply-templates select="." mode="problems">
					<xsl:with-param name="sectionRequired" select="$sectionRequired"/>
				</xsl:apply-templates>
					
				<!-- Clinical Interventions Performed This Visit -->
				<xsl:apply-templates select="." mode="procedures"/>
					
				<!-- Clinical Synoposis -->
				<xsl:apply-templates select="." mode="clinicalSynopsis">
					<xsl:with-param name="sectionRequired" select="$sectionRequired"/>
				</xsl:apply-templates>
					
				<!-- Diagnostic Investigations -->
				<xsl:apply-templates select="." mode="diagnosticInvestigations"/>
					
			</section>
		</component>
	</xsl:template>
</xsl:stylesheet>
