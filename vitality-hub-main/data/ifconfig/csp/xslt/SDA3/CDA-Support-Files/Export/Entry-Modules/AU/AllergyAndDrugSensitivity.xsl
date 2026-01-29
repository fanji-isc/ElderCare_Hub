<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="allergies-Narrative-Discharge">
		<text>
			<table border="1" width="100%">
				<caption>Adverse Reactions</caption> 
				<thead>
					<tr>
						<th>Agent Description</th>
						<th>Reaction Type</th>
						<th>Reaction(s)</th>
						<th>Onset Date</th>
						<th>Inactive Date</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Allergy" mode="allergies-NarrativeDetail-Discharge"/>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="allergies-NarrativeDetail-Discharge">
		<xsl:variable name="allergyNumber" select="position()"/>
		
		<tr ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyNarrative/text(), position())}">
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyAllergen/text(), position())}"><xsl:apply-templates select="Allergy" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyCategory/text(), position())}"><xsl:apply-templates select="AllergyCategory" mode="originalTextOrDescriptionOrCode"/></td>
			<td>
				<xsl:if test="string-length(Reaction)">
					<content ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyReaction/text(), $allergyNumber, '-', position())}"><xsl:apply-templates select="Reaction" mode="descriptionOrCode"/></content>
				</xsl:if>
			</td>
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="InactiveTime" mode="narrativeDateFromODBC"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="allergies-Narrative">
		<text>
			<table border="1" width="100%">
				<caption>Adverse Reactions</caption> 
				<thead>
					<tr>
						<th>Substance/Agent</th>
						<th>Manifestation</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Allergy" mode="allergies-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="allergies-NarrativeDetail">
		<xsl:variable name="allergyNumber" select="position()"/>
		<xsl:variable name="allergyOK">
			<xsl:choose>
				<xsl:when test="not($documentExportType='NEHTAEventSummary')">1</xsl:when>
				<xsl:otherwise><xsl:apply-templates select="." mode="allergies-newlyDiscovered"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$allergyOK=1">
			<tr ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyNarrative/text(), position())}">
				<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyAllergen/text(), position())}"><xsl:apply-templates select="Allergy" mode="originalTextOrDescriptionOrCode"/></td>
				<td>
					<xsl:if test="string-length(Reaction)">
						<content ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyReaction/text(), $allergyNumber, '-', position())}"><xsl:value-of select="Reaction/Description/text()"/></content>
					</xsl:if>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="allergies-Entries">
		<xsl:apply-templates select="Allergy" mode="allergies-EntryDetail"/>
	</xsl:template>

	<xsl:template match="*" mode="allergies-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<xsl:variable name="allergyOK">
			<xsl:choose>
				<xsl:when test="not($documentExportType='NEHTAEventSummary')">1</xsl:when>
				<xsl:otherwise><xsl:apply-templates select="." mode="allergies-newlyDiscovered"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$allergyOK=1">
			<entry typeCode="DRIV">
				<xsl:choose>
					<xsl:when test="not($documentExportType='NEHTADischargeSummary')">
						<xsl:apply-templates select="." mode="allergies-actDetail">
							<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="allergies-observationDetail">
							<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</entry>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="allergies-NoData">
		<xsl:choose>
			<xsl:when test="$documentExportType='NEHTAEventSummary'">
				<text><xsl:value-of select="$exportConfiguration/allergies/emptySection/narrativeText/text()"/></text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="nehta-globalStatement">
					<xsl:with-param name="narrativeLink" select="$exportConfiguration/allergies/narrativeLinkPrefixes/allergyNarrative/text()"/>
					<xsl:with-param name="codeCode">
						<xsl:choose>
							<xsl:when test="$documentExportType='NEHTADischargeSummary'">103.16302.4.3.4</xsl:when>
							<xsl:when test="$documentExportType='NEHTASharedHealthSummary'">103.16302.120.1.1</xsl:when>
							<xsl:when test="$documentExportType='NEHTAeReferral'">103.16302.2.2.2</xsl:when>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="allergies-actDetail">
		<xsl:param name="narrativeLinkSuffix"/>
				
		<act classCode="ACT" moodCode="EVN">
			<xsl:apply-templates select="." mode="allergies-Detail">
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
		</act>
	</xsl:template>

	<xsl:template match="*" mode="allergies-observationDetail">
		<xsl:param name="narrativeLinkSuffix"/>
				
		<observation classCode="OBS" moodCode="EVN">
			<xsl:apply-templates select="." mode="allergies-Detail">
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
		</observation>
	</xsl:template>

	<xsl:template match="*" mode="allergies-Detail">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<id nullFlavor="{$idNullFlavor}"/>

		<code code="102.15517" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Adverse Reaction"/>
						
		<statusCode code="completed"/>				
		<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
		
		<xsl:if test="$documentExportType='NEHTADischargeSummary'">
			<xsl:choose>
				<xsl:when test="AllergyCategory">
					<xsl:apply-templates select="AllergyCategory" mode="allergies-category-value"/>
				</xsl:when>
				<xsl:otherwise><value xsi:type="CD" nullFlavor="NA"/></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<xsl:apply-templates select="Allergy" mode="participant-Allergy"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
		
		<xsl:choose>
			<xsl:when test="not($documentExportType='NEHTADischargeSummary')">
				<xsl:apply-templates select="Reaction" mode="observationNEHTA-Reaction"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="Reaction" mode="observation-Reaction"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	
	<xsl:template match="*" mode="participant-Allergy">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<participant typeCode="CAGNT">
			<participantRole classCode="MANU">
				<addr nullFlavor="{$addrNullFlavor}"/>
				<telecom nullFlavor="UNK"/>
				<playingEntity classCode="MMAT">
					<!-- Allergy Detail -->
					<xsl:apply-templates select="." mode="generic-Coded">
						<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyAllergen/text(), $narrativeLinkSuffix)"/>
					</xsl:apply-templates>
				</playingEntity>
			</participantRole>
		</participant>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-Reaction">
		<xsl:param name="narrativeLinkSuffix"/>

		<entryRelationship typeCode="MFST" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">				
				<id nullFlavor="{$idNullFlavor}"/>
				<code code="ASSERTION" codeSystem="2.16.840.1.113883.5.4"/>
				
				<text><xsl:apply-templates select="." mode="descriptionOrCode"/></text>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="parent::node()" mode="effectiveTime-FromTo"/>

				<!-- Allergy Detail -->
				<xsl:apply-templates select="." mode="value-CD"/>
			</observation>
		</entryRelationship>
	</xsl:template>	
	
	<!-- 
		allergies-category-value is adapted from allergies-category-code.
		This template is a special case coded entry template for allergy
		category, which must be a SNOMED allergy category code.
	-->
	<xsl:template match="*" mode="allergies-category-value">		
		<xsl:variable name="sdaCodingStandardOID"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
		<xsl:variable name="codeSystemOIDForTranslation">
			<xsl:choose>
				<xsl:when test="string-length($sdaCodingStandardOID)"><xsl:value-of select="$sdaCodingStandardOID"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codeSystemNameForTranslation">
			<xsl:choose>
				<xsl:when test="string-length($sdaCodingStandardOID)"><xsl:value-of select="SDACodingStandard/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<!-- If there is Code text, then work with it, otherwise it just gets nullFlavor. -->
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="snomedAllergyCategories">|420134006|418038007|419511003|418471000|419199007|416098002|414285001|59037007|235719002|</xsl:variable>
				<xsl:variable name="isValidSnomedCode" select="contains($snomedAllergyCategories, concat('|', Code/text(), '|'))"/>
				
				<xsl:choose>
				
					<!-- If SNOMED code system and a valid SNOMED code, then export as is. -->
					<xsl:when test="($sdaCodingStandardOID=$snomedOID) and ($isValidSnomedCode)">
						<value xsi:type="CD" code="{Code/text()}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}">
							<xsl:attribute name="displayName"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:attribute>
							<originalText><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></originalText>
						</value>
					</xsl:when>
					
					<!--
						If valid SNOMED code but not SNOMED code system, then export
						with SNOMED code system plugged in, plus export a <translation>
						with the data and code system that was actually received.
					-->
					<xsl:when test="$isValidSnomedCode">
						<value xsi:type="CD" code="{Code/text()}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}">
							<xsl:attribute name="displayName"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:attribute>
							<originalText><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></originalText>
						</value>
					</xsl:when>

					<!-- Otherwise, it's not a valid SNOMED code, make it into one. -->
					<xsl:otherwise>
						<xsl:variable name="descUpper" select="translate(Description/text(), $lowerCase, $upperCase)"/>
		
						<xsl:variable name="codeValue">
							<xsl:choose>
								<xsl:when test="contains($descUpper, 'DRUG')">416098002</xsl:when>
								<xsl:when test="contains($descUpper, 'FOOD')">414285001</xsl:when>
								<xsl:otherwise>419199007</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<value xsi:type="CD" code="{$codeValue}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}">
							<xsl:attribute name="displayName"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:attribute>
							<originalText><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></originalText>
						</value>
					</xsl:otherwise>
					
				</xsl:choose>
				</xsl:when>
			<xsl:otherwise>
				<value xsi:type="CD" nullFlavor="NA"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="observationNEHTA-Reaction">
		<entryRelationship typeCode="CAUS">
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="102.16474" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Reaction Event"/>
				<entryRelationship typeCode="MFST" inversionInd="true">
					<observation classCode="OBS" moodCode="EVN">
						<xsl:apply-templates select="." mode="generic-Coded"/>
						<text><xsl:apply-templates select="." mode="descriptionOrCode"/></text>
					</observation>
				</entryRelationship>
			</observation>
		</entryRelationship>
	</xsl:template>
</xsl:stylesheet>
