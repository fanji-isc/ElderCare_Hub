<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Immunization Variables -->
	<!-- E = Executed, R = Replaced -->
	<xsl:variable name="immunizationExecutedStatusCodes">|E|R|</xsl:variable>
	<!-- H = On-Hold, INT = Intended (default, if no status value specified), IP = In-Progress -->
	<xsl:variable name="immunizationIntendedStatusCodes">|H|INT|IP|</xsl:variable>
	<!-- C = Cancelled, D = Discontinued -->
	<xsl:variable name="immunizationCancelledStatusCodes">|C|D|</xsl:variable>

	<xsl:template match="*" mode="immunizations-Narrative">
		<text>
			<table border="1" width="100%">
				<caption>Immunisations - Administered Immunisations</caption>
				<thead>
					<tr>
						<th>Ordered Immunisation Name</th>
						<th>Date</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="immunizations-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="immunizations-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td>
				<xsl:choose>
					<xsl:when test="string-length(FromTime)"><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></xsl:when>
					<xsl:when test="string-length(EnteredOn)"><xsl:apply-templates select="EnteredOn" mode="narrativeDateFromODBC"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="'Unknown'"/></xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="immunizations-Entries">
		<xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="immunizations-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="immunizations-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<substanceAdministration classCode="SBADM" negationInd="false">
				<!-- The following template is defined in Export/Entry-Modules/Medication.xsl -->
				<xsl:apply-templates select="." mode="substanceAdministration-moodCode"/>			
				
				<!-- NEHTA allows for only one <id> here. -->
				<xsl:apply-templates select="." mode="id-Medication"/>
				
				<xsl:apply-templates select="." mode="effectiveTime-Immunization"/>
				<xsl:apply-templates select="OrderItem" mode="immunization-order"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				<xsl:apply-templates select="OrderedBy" mode="performer"/>
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!-- Link this medication to encounter noted in encounters section -->
				<!--<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>-->
			</substanceAdministration>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="immunizations-NoData">
		<xsl:param name="narrativeLinkCategory"/>
		
		<xsl:call-template name="nehta-globalStatement">
			<xsl:with-param name="narrativeLink" select="$exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text()"/>
			<xsl:with-param name="codeCode" select="'103.16302.120.1.5'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="*" mode="immunization-order">
		<xsl:param name="narrativeLink"/>
		
		<consumable typeCode="CSM">
			<manufacturedProduct classCode="MANU">
				<xsl:apply-templates select="." mode="immunization-manufacturedMaterial"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
			</manufacturedProduct>
		</consumable>		
	</xsl:template>
	
	<xsl:template match="*" mode="immunization-manufacturedMaterial">
		<xsl:param name="narrativeLink"/>
		
		<manufacturedMaterial classCode="MMAT" determinerCode="KIND">
			<!-- This field has slightly different requirements than other    -->
			<!-- coded element fields.  Like many coded element fields, it    -->
			<!-- has only one valid codeSystem - in this case, CVX.  However, -->
			<!-- it requires that if there is a <translation> on the code,    -->
			<!-- then the codeSystem on it must be for RxNorm or NDC, or it   -->
			<!-- must be nullFlavor.                                          -->
			<xsl:variable name="sdaCodingStandardOID">
				<xsl:choose>
					<xsl:when test="string-length(SDACodingStandard/text())">
						<xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$noCodeSystemOID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="sdaCodingStandardName">
				<xsl:choose>
					<xsl:when test="string-length(SDACodingStandard/text())">
						<xsl:value-of select="SDACodingStandard/text()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$noCodeSystemName"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="description"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:variable>

			<code code="{Code/text()}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{$sdaCodingStandardName}" displayName="{$description}">
				<originalText><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></originalText>
			</code>
		</manufacturedMaterial>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-Immunization">
		<xsl:choose>
			<xsl:when test="string-length(FromTime)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:when test="string-length(EnteredOn)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
