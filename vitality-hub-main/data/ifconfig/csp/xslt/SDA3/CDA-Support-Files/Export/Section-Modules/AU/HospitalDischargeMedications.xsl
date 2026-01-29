<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="dischargeMedications">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Medications"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/dischargeMedications/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="101.16022" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Medications"/>
					<title>Medications</title>
					
					<text mediaType="text/x-hl7-text+xml">
						<paragraph>This section may contain the following subsections Current Medications On Discharge and Ceased Medications.</paragraph> 
					</text>
					
					<xsl:apply-templates select="." mode="medications-Current">
					<xsl:with-param name="sectionRequired" select="$sectionRequired"/>
				</xsl:apply-templates>
						
					<xsl:apply-templates select="." mode="medications-Ceased">
					<xsl:with-param name="sectionRequired" select="$sectionRequired"/>
				</xsl:apply-templates>
						
				</section>
			</component>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
