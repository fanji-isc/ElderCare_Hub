<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="immunizations">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- C = Cancelled, D = Discontinued -->
		<xsl:variable name="immunizationCancelledStatusCodes">|C|D|</xsl:variable>
		<xsl:variable name="checkAdministrations" select="$exportConfiguration/immunizations/checkAdministrations/text()"/>
		<xsl:variable name="hasData" select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]/Administrations/Administration"/>
		<xsl:variable name="hasDataAdminCheck" select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/immunizations/emptySection/exportData/text()"/>
        <xsl:if test="($checkAdministrations='0')">
			<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
				<component>
					<section>
						<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
						
						<xsl:apply-templates select="." mode="templateIds-immunizationsSection"/>
						
						<code code="11369-6" displayName="History of Immunizations" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
						<title>Immunizations</title>
						
						<xsl:choose>
							<xsl:when test="$hasData">
								<xsl:apply-templates select="." mode="immunizations-Narrative"/>
								<xsl:apply-templates select="." mode="immunizations-Entries"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="." mode="immunizations-NoData"/>
							</xsl:otherwise>
						</xsl:choose>
					</section>
				</component>
			</xsl:if>
		</xsl:if>
        <xsl:if test="($checkAdministrations='1')">
			<xsl:if test="($hasDataAdminCheck) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
				<component>
					<section>
						<xsl:if test="not($hasDataAdminCheck)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
						
						<xsl:apply-templates select="." mode="templateIds-immunizationsSection"/>
						
						<code code="11369-6" displayName="History of Immunizations" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
						<title>Immunizations</title>
						
						<xsl:choose>
							<xsl:when test="$hasDataAdminCheck">
								<xsl:apply-templates select="." mode="immunizations-Narrative"/>
								<xsl:apply-templates select="." mode="immunizations-Entries"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="." mode="immunizations-NoData"/>
							</xsl:otherwise>
						</xsl:choose>
					</section>
				</component>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<!-- If the "entries required" templateId is needed then this template is overridden by *EntriesRequired.xsl -->
	<xsl:template match="*" mode="templateIds-immunizationsSection">
		<templateId root="{$ccda-ImmunizationsSectionEntriesOptional}"/>
	</xsl:template>
</xsl:stylesheet>