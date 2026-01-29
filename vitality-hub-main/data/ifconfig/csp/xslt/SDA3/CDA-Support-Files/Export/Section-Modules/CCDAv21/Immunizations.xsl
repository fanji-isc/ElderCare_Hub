<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="*" mode="sIm-immunizations">
		<xsl:param name="sectionRequired" select="'0'"/>
		<xsl:param name="entriesRequired" select="'0'"/>
		
		<!-- C = Cancelled, D = Discontinued -->
		<xsl:variable name="immunizationCancelledStatusCodes">|C|D|</xsl:variable>
		<xsl:variable name="checkAdministrations" select="$exportConfiguration/immunizations/checkAdministrations/text()"/>
		<xsl:variable name="hasData">
		<xsl:choose>
			<xsl:when test="$checkAdministrations='0'">
				<xsl:value-of select="count(Vaccinations/Vaccination/Administrations/Administration)"/>
			</xsl:when>
			<xsl:otherwise>
			<xsl:value-of select="count(Vaccinations/Vaccination)"/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/immunizations/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="$hasData = 0"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sIm-templateIds-immunizationsSection">
						<xsl:with-param name="entriesRequired" select="$entriesRequired"/>
					</xsl:call-template>
					
					<code code="11369-6" displayName="History of Immunizations" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Immunizations</title>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="." mode="eI-immunizations-Narrative"/>
							<xsl:apply-templates select="." mode="eI-immunizations-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eI-immunizations-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->

	<xsl:template name="sIm-templateIds-immunizationsSection">
		<xsl:param name="entriesRequired"/>
		<xsl:choose>
			<xsl:when test="$entriesRequired = '1'">
				<templateId root="{$ccda-ImmunizationsSectionEntriesRequired}"/>
				<templateId root="{$ccda-ImmunizationsSectionEntriesRequired}" extension="2015-08-01"/>
			</xsl:when>
			<xsl:otherwise>
				<templateId root="{$ccda-ImmunizationsSectionEntriesOptional}"/>
				<templateId root="{$ccda-ImmunizationsSectionEntriesOptional}" extension="2015-08-01"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>