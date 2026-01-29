<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Entry module has non-parallel name. AlsoInclude: AllergyAndDrugSensitivity.xsl -->
  
	<xsl:template match="*" mode="sAOAR-allergies">
		<xsl:param name="sectionRequired" select="'0'"/>
		<xsl:param name="entriesRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="count(Allergies)"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/allergies/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData > 0) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:call-template name="sAOAR-templateIds-allergiesSection">
						<xsl:with-param name="entriesRequired" select="$entriesRequired"/>
					</xsl:call-template>
					
					<code code="48765-2" displayName="Allergies, Adverse Reactions, Alerts" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Allergies, Adverse Reactions, Alerts</title>
					
					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="Allergies" mode="eADS-allergies-Narrative"/>
							<xsl:apply-templates select="Allergies" mode="eADS-allergies-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<!--Note that for no known problems, the section cannot have the
							nullFalvor attribute present and set to "NI".
							-->
							<xsl:apply-templates select="." mode="eADS-allergies-NoKnownAllergies"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<!-- If the "entries required" templateId is needed then this template is overridden by *EntriesRequired.xsl -->
	<xsl:template name="sAOAR-templateIds-allergiesSection">
		<xsl:param name="entriesRequired"/>
		<xsl:choose>
			<xsl:when test="$entriesRequired = '1'">
				<templateId root="{$ccda-AllergiesSectionEntriesRequired}"/>
				<templateId root="{$ccda-AllergiesSectionEntriesRequired}" extension="2015-08-01"/>
			</xsl:when>
			<xsl:otherwise>
				<templateId root="{$ccda-AllergiesSectionEntriesOptional}"/>
				<templateId root="{$ccda-AllergiesSectionEntriesOptional}" extension="2015-08-01"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>