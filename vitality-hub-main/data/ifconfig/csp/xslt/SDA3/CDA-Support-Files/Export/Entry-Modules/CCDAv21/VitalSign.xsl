<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xsi">
  <!-- AlsoInclude: AuthorParticipation.xsl Comment.xsl -->
	
	<!-- Used to group observations by encounter number, or null-string when there is no number -->
	<xsl:key name="ObservationByEncNum" match="/Container/Observations/Observation" use="EncounterNumber" />	
	<xsl:key name="ObservationByEncNum" match="/Container/Observations/Observation[string-length(EncounterNumber) = 0]" use="''" /> 	
	<!-- The following key is to ensure that the "key table" is populated with at least one row, but we never want to retrieve that row. -->	
	<xsl:key name="ObservationByEncNum" match="/Container" use="'NEVER_MATCH_THIS!'"/>
  
	<xsl:template match="*" mode="eVS-vitalSigns-Narrative">
		<xsl:param name="validVitalSigns"/>
		
		<!--
			validVitalSigns contains the ObservationCodes of those
			Observations that are okay to export to Vital Signs.
		-->
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Vital Name</th>
						<th>Observation Time</th>
						<th>Observation Value</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<!-- Vital signs are grouped by encounter -->
					<xsl:for-each select="/Container/Encounters/Encounter">
						<xsl:call-template name="vitalSigns-Narrative-Encounter">
							<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
							<xsl:with-param name="encounterNumber" select="EncounterNumber"/>
							<xsl:with-param name="narrativeLinkSuffix1" select="position()"/>
						</xsl:call-template>
					</xsl:for-each>

					<!-- And get those with no encounter number-->
					<xsl:call-template name="vitalSigns-Narrative-Encounter">
						<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
						<xsl:with-param name="encounterNumber" select="''"/>
						<xsl:with-param name="narrativeLinkSuffix1" select="'0'"/>
					</xsl:call-template>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="Observations" mode="eVS-vitalSigns-NarrativeDetail-Encounter">
		<xsl:param name="validVitalSigns"/>
		<xsl:param name="encounterNumber"/>
		<xsl:param name="narrativeLinkSuffix1"/>

		<xsl:choose>			
			<xsl:when test="string-length($encounterNumber) > 0">
				<xsl:apply-templates select="key('ObservationByEncNum', $encounterNumber)[contains($validVitalSigns, concat('|', ObservationCode/Code/text(), '|'))]" mode="eVS-observation-Narrative-vitalSign">
					<xsl:with-param name="narrativeLinkSuffix1" select="$narrativeLinkSuffix1"/>
				</xsl:apply-templates>
			</xsl:when>
			<!--For Observations without an encounter number-->			
			<xsl:otherwise>
				<xsl:apply-templates select="key('ObservationByEncNum', '')[contains($validVitalSigns, concat('|', ObservationCode/Code/text(), '|'))]" mode="eVS-observation-Narrative-vitalSign">
					<xsl:with-param name="narrativeLinkSuffix1" select="$narrativeLinkSuffix1"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Observation" mode="eVS-observation-Narrative-vitalSign">
		<xsl:param name="narrativeLinkSuffix1"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="concat($narrativeLinkSuffix1,'-',position())"/>		
		<xsl:variable name="observationCode">
			<xsl:apply-templates select="ObservationCode" mode="fn-originalTextOrDescriptionOrCode"/>
		</xsl:variable>
		
		<xsl:variable name="observationCodeForUnit">
			<xsl:apply-templates select="ObservationCode" mode="eVS-getObservationCode"/>
		</xsl:variable>
		
		<xsl:variable name="observationUnit">
			<xsl:choose>
				<xsl:when test="$observationCodeForUnit = '9279-1'">/min</xsl:when>
				<xsl:when test="$observationCodeForUnit = '8867-4'">/min</xsl:when>
				<!-- 2710-2 is deprecated, mapped to 59408-5 --> 
				<xsl:when test="$observationCodeForUnit = '2710-2'">%</xsl:when>
				<xsl:when test="$observationCodeForUnit = '59408-5'">%</xsl:when>
				<xsl:when test="$observationCodeForUnit = '8480-6'">mm[Hg]</xsl:when>
				<xsl:when test="$observationCodeForUnit = '8462-4'">mm[Hg]</xsl:when>
				<xsl:when test="string-length(ObservationCode/ObservationValueUnits/Code/text())"><xsl:value-of select="ObservationCode/ObservationValueUnits/Code/text()"/></xsl:when>
				<xsl:when test="string-length(ObservationCode/ObservationValueUnits/Description/text())"><xsl:value-of select="ObservationCode/ObservationValueUnits/Description/text()"/></xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="observationValue">
			<xsl:choose>
				<xsl:when test="string-length(ObservationValue/text()) and string-length($observationUnit)">
					<xsl:value-of select="concat(ObservationValue/text(),' ',$observationUnit)"/>
				</xsl:when>
				<xsl:when test="string-length(ObservationValue/text())">
					<xsl:value-of select="ObservationValue/text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!--
			The NIST MU2 C-CDA validator logs an error if an @ID
			has no reference/@value pointing to it.  Export @ID 
			for Comments only if it has a value.
		-->
		<tr ID="{concat($exportConfiguration/vitalSigns/narrativeLinkPrefixes/vitalSignNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/vitalSigns/narrativeLinkPrefixes/vitalSignIdentifier/text(), $narrativeLinkSuffix)}"><xsl:value-of select="$observationCode"/></td>
			<td><xsl:apply-templates select="ObservationTime" mode="fn-narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/vitalSigns/narrativeLinkPrefixes/vitalSignValue/text(), $narrativeLinkSuffix)}"><xsl:value-of select="$observationValue"/></td>
			<xsl:choose>
				<xsl:when test="string-length(Comments/text())">
					<td ID="{concat($exportConfiguration/vitalSigns/narrativeLinkPrefixes/vitalSignComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
				</xsl:when>
				<xsl:otherwise><td/></xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="eVS-vitalSigns-Entries">
		<xsl:param name="validVitalSigns"/>
		<!-- Vital signs are grouped by encounter -->
		<xsl:for-each select="/Container/Encounters/Encounter">
			<xsl:call-template name="vitalSigns-Entries-Encounter">
				<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
				<xsl:with-param name="encounterNumber" select="EncounterNumber"/>
				<xsl:with-param name="narrativeLinkSuffix1" select="position()"/>
			</xsl:call-template>
		</xsl:for-each>

		<!-- And get those with no encounter number-->
		<xsl:call-template name="vitalSigns-Entries-Encounter">
			<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
			<xsl:with-param name="encounterNumber" select="''"/>
			<xsl:with-param name="narrativeLinkSuffix1" select="'0'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Observation" mode="eVS-encounterHasValids">
		<xsl:param name="encounterNumber"/>
		<xsl:param name="validVitalSigns"/>
		<!-- ToDoXSLT2: use a quantified expression instead of this template -->
		
		<xsl:choose>
			<!--$encounterNumber is not empty-->
			<xsl:when test="$encounterNumber">
				<xsl:if test="string(EncounterNumber/text())=string($encounterNumber) and contains($validVitalSigns,concat('|',ObservationCode/Code/text(),'|'))">1</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!--$encounterNumber is empty thus do not check EncounterNumber-->
				<xsl:if test="contains($validVitalSigns,concat('|',ObservationCode/Code/text(),'|'))">1</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Observations" mode="eVS-vitalSigns-EntryDetail">
		<xsl:param name="validVitalSigns"/>
		<xsl:param name="encounterNumber"/>
		<xsl:param name="narrativeLinkSuffix1"/>

		<xsl:variable name="first" select="key('ObservationByEncNum',$encounterNumber)[1]"/>
		<!-- validVitalSigns contains the ObservationCodes of those Observations that are okay to export to Vital Signs. -->
		<entry>
			<organizer classCode="CLUSTER" moodCode="EVN">
				<xsl:call-template name="eVS-templateIds-vitalSignsEntry"/>

				<xsl:apply-templates select="." mode="fn-id-External"/>
				<code code="46680005" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="Vital signs">
					<translation code="74728-7" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Vital signs" />
				</code>
				<statusCode code="completed"/>
				
				<effectiveTime nullFlavor="UNK"/>
				
				<xsl:choose>
					<xsl:when test="string-length($encounterNumber) > 0">
						<xsl:apply-templates select="key('ObservationByEncNum', $encounterNumber)[contains($validVitalSigns,concat('|',ObservationCode/Code/text(),'|'))]" mode="eVS-observation">
							<xsl:with-param name="narrativeLinkSuffix1" select="$narrativeLinkSuffix1"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="key('ObservationByEncNum', '')[contains($validVitalSigns,concat('|',ObservationCode/Code/text(),'|'))]" mode="eVS-observation">
							<xsl:with-param name="narrativeLinkSuffix1" select="$narrativeLinkSuffix1"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>

				<!--
					Field : Vital Sign Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component
					Source: HS.SDA3.Observation EncounterNumber
					Source: /Container/Observations/Observation/EncounterNumber
					StructuredMappingRef: encounterLink-component
					Note  : This links the Vital Sign observation to an encounter in the Encounters section.
				-->
				<xsl:apply-templates select="$first" mode="fn-encounterLink-component"/>
			</organizer>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="eVS-vitalSigns-NoData">
		<text><xsl:value-of select="$exportConfiguration/vitalSigns/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="Observation" mode="eVS-observation">
		<xsl:param name="narrativeLinkSuffix1"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="concat($narrativeLinkSuffix1,'-',position())"/>		
		
		<component>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eVS-templateIds-vitalSignObservation"/>
				
				<!--
					Field : Vital Sign Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/id
					Source: HS.SDA3.Observation ExternalId
					Source: /Container/Observations/Observation/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="fn-id-External"/>
				
				<xsl:apply-templates select="ObservationCode" mode="eVS-code-observation"/>
				
				<text><reference value="{concat('#', $exportConfiguration/vitalSigns/narrativeLinkPrefixes/vitalSignNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					Field : Vital Sign Observation Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/effectiveTime/@value
					Source: HS.SDA3.Observation ObservationTime
					Source: /Container/Observations/Observation/ObservationTime
				-->
				<xsl:choose>
					<xsl:when test="string-length(ObservationTime/text())">
						<xsl:apply-templates select="ObservationTime" mode="fn-effectiveTime-singleton"/>
					</xsl:when>
					<xsl:otherwise>
						<effectiveTime nullFlavor="UNK"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Vital Sign Result
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation
					Source: HS.SDA3.Observation
					Source: /Container/Observations/Observation
					StructuredMappingRef: eVS-value-observation
				-->
				<xsl:apply-templates select="." mode="eVS-value-observation"/>
				
				<!--
					Field : Vital Sign Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/performer
					Source: HS.SDA3.Observation Clinician
					Source: /Container/Observations/Observation/Clinician
					StructuredMappingRef: performer
				-->
				<xsl:apply-templates select="Clinician" mode="fn-performer"/>
				
				<!--
					Field : Vital Sign Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/author
					Source: HS.SDA3.Observation EnteredBy
					Source: /Container/Observations/Observation/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				
				<!--
					Field : Vital Sign Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/informant
					Source: HS.SDA3.Observation EnteredAt
					Source: /Container/Observations/Observation/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<xsl:apply-templates select="." mode="eVS-observation-entryRelationship"/>
				
				<!--
					Field : Vital Sign Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.Observation Comments
					Source: /Container/Observations/Observation/Comments
				-->
				<xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/vitalSigns/narrativeLinkPrefixes/vitalSignComments/text(), $narrativeLinkSuffix)"/>
				</xsl:apply-templates>
			</observation>
		</component>
	</xsl:template>

	<xsl:template match="Observation" mode="eVS-observation-entryRelationship">
		<!--
			The Consolidated CDA spec states that Status should be
			hard-coded to "completed" and expresed in statusCode/@code
			as part of the vital sign component/observation.  This
			entryRelationsip for Status is being retained only for
			backward compatibility for consumers who may be using it.
		-->
		<entryRelationship typeCode="REFR">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eVS-templateIds-vitalSignObservationStatus"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>				
				<value xsi:type="CE" code="completed" codeSystem="{$actStatusOID}" codeSystemName="{$actStatusName}" displayName="completed"/>
			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="Observation|Target" mode="eVS-value-observation">
		<!--
			StructuredMapping: eVS-value-observation
			
			Field
			Path  : value/@value
			Source: ObservationValue
			Source: ./ObservationValue

			Field
			Path  : value/@unit
			Source: ObservationValueUnits
			Source: ./ObservationValueUnits
		-->

		<!--
			ObservationValue is a String that may be just be a
			value, or a value and unit, separated by a space.
		-->
		<xsl:variable name="obsVal">
			<xsl:choose>
				<xsl:when test="string-length(substring-before(ObservationValue/text(), ' '))">
					<xsl:value-of select="substring-before(ObservationValue/text(), ' ')"/>
				</xsl:when>
				<xsl:when test="string-length(ObservationValue/text())">
					<xsl:value-of select="ObservationValue/text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<value>
			<xsl:choose>
				<!-- The number($obsVal) test depends on there being NO vital signs that would be zero. -->
				<xsl:when test="number($obsVal)">
					<xsl:variable name="codeValue">
						<xsl:apply-templates select="ObservationCode" mode="eVS-getObservationCode"/>
					</xsl:variable>
					<!--
						Use the LOINC code to determine the unit. If not able to get it
						from LOINC code, see if it was included in ObservationValue.
					-->
					<xsl:variable name="obsUnit">
						<xsl:choose>
							<xsl:when test="$codeValue = '9279-1'">/min</xsl:when>
							<xsl:when test="$codeValue = '8867-4'">/min</xsl:when>
							<xsl:when test="$codeValue = '2710-2'">%</xsl:when>
							<xsl:when test="$codeValue = '59408-5'">%</xsl:when>							
							<xsl:when test="$codeValue = '8480-6'">mm[Hg]</xsl:when>
							<xsl:when test="$codeValue = '8462-4'">mm[Hg]</xsl:when>
							<xsl:when test="string-length(ObservationCode/ObservationValueUnits/Code/text())"><xsl:value-of select="ObservationCode/ObservationValueUnits/Code/text()"/></xsl:when>
							<xsl:when test="string-length(ObservationCode/ObservationValueUnits/Description/text())"><xsl:value-of select="ObservationCode/ObservationValueUnits/Description/text()"/></xsl:when>
							<xsl:when test="string-length(substring-after(ObservationValue/text(), ' '))"><xsl:value-of select="substring-after(ObservationValue/text(), ' ')"/></xsl:when>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:attribute name="xsi:type">PQ</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="$obsVal"/></xsl:attribute>
					<xsl:attribute name="unit">
						<xsl:call-template name="fn-unit-to-ucum">
							<xsl:with-param name="unit" select="$obsUnit"/>
						</xsl:call-template>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="xsi:type">ST</xsl:attribute>
					<xsl:value-of select="text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</value>
	</xsl:template>

	<xsl:template match="ObservationCode" mode="eVS-code-observation">
		<!--
			Field : Vital Sign Result Type (Vital Sign LOINC Code)
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation/id
			Source: HS.SDA3.Observation ObservationCode
			Source: /Container/Observations/Observation/ObservationCode
		-->
		
		<xsl:choose>
			<!--
				If there is Code text, then work with it, otherwise code nullFlavor=UNK.
				$loincVitalSignCodes is a global variable set up in Variables.xsl.
			-->

			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="isValidLoincCode" select="contains($loincVitalSignCodes, concat('|', Code/text(), '|'))"/>
				<xsl:variable name="sdaCodingStandardOID">
					<xsl:apply-templates select="." mode="fn-oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="description"><xsl:apply-templates select="." mode="fn-descriptionOrCode"/></xsl:variable>
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
				
					<!--
						If LOINC code system and valid LOINC code then export
						the data as is.
					-->
					<xsl:when test="($sdaCodingStandardOID=$loincOID) and ($isValidLoincCode)">
						<code code="{Code/text()}" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="{$description}">
							<originalText><xsl:apply-templates select="." mode="fn-originalTextOrDescriptionOrCode"/></originalText>
							<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="fn-translation"/>					
						</code>
					</xsl:when>
					
					<!--
						If valid LOINC code but not the LOINC code system then
						export the data with LOINC code system plugged in, and
						export a <translation> with the data and code system
						that was actually received.
					-->
					<xsl:when test="$isValidLoincCode">
						<code code="{Code/text()}" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="{$description}">
							<originalText><xsl:apply-templates select="." mode="fn-originalTextOrDescriptionOrCode"/></originalText>
							<translation code="{Code/text()}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{$description}"/>
							<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="fn-translation"/>					
						</code>
					</xsl:when>
					
					<!-- Otherwise, it's not a LOINC code, try to make it one. -->
					<xsl:otherwise>
						<xsl:variable name="codeValue">
							<xsl:apply-templates select="." mode="eVS-getObservationCode"/>
						</xsl:variable>
						<code code="{translate($codeValue,' ','_')}" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="{$description}">
							<originalText><xsl:apply-templates select="." mode="fn-originalTextOrDescriptionOrCode"/></originalText>
							<translation code="{translate(Code/text(),' ','_')}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{$description}"/>
							<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="fn-translation"/>					
						</code>
					</xsl:otherwise>
		
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<code nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ObservationCode" mode="eVS-getObservationCode">		
		<!--
			The ObservationCode Code and Description are evaluated
			to determine which LOINC code this Observation is or
			can be construed as.
			
			$loincVitalSignCodes is a global variable set up in Variables.xsl.
		-->
		<xsl:variable name="descUpper" select="translate(Description/text(), $lowerCase, $upperCase)"/>
		<xsl:choose>
			<xsl:when test="contains($loincVitalSignCodes, concat('|', Code/text(), '|'))"><xsl:value-of select="Code/text()"/></xsl:when>
			<xsl:when test="contains($descUpper, 'SYSTOLIC')">8480-6</xsl:when>
			<xsl:when test="contains($descUpper, 'DIASTOLIC')">8462-4</xsl:when>
			<xsl:when test="contains($descUpper, 'TEMP')">8310-5</xsl:when>
			<xsl:when test="contains($descUpper, 'HEIGHT')">8302-2</xsl:when>
			<xsl:when test="contains($descUpper, 'HEART RATE')">8867-4</xsl:when>
			<xsl:when test="contains($descUpper, 'PULSE')">8867-4</xsl:when>
			<xsl:when test="contains($descUpper, 'WEIGHT')">3141-9</xsl:when>
			<xsl:when test="contains($descUpper, 'O2 SAT')">59408-5</xsl:when>
			<xsl:when test="contains($descUpper, 'O2SAT')">59408-5</xsl:when>
			<xsl:when test="contains($descUpper, 'SO2')">59408-5</xsl:when>
			<xsl:when test="contains($descUpper, 'CRANIUM')">8287-5</xsl:when>
			<xsl:when test="contains($descUpper, 'SKULL')">8287-5</xsl:when>
			<xsl:when test="contains($descUpper, 'HEAD')">8287-5</xsl:when>
			<xsl:when test="contains($descUpper, 'RESPIRATORY')">9279-1</xsl:when>
			<xsl:when test="contains($descUpper, 'RESP RATE')">9279-1</xsl:when>
			<xsl:when test="contains($descUpper, 'RESPIRATION')">9279-1</xsl:when>
			<xsl:when test="contains($descUpper, 'BMI')">39156-5</xsl:when>
			<xsl:when test="contains($descUpper, 'BODY MASS')">39156-5</xsl:when>
			<xsl:otherwise><xsl:value-of select="Code/text()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="vitalSigns-Narrative-Encounter">
		<xsl:param name="validVitalSigns"/>
		<xsl:param name="encounterNumber"/>
		<xsl:param name="narrativeLinkSuffix1"/>
		
		<!-- Make sure the encounter has valid vital signs before exporting for the encounter. -->
		<xsl:variable name="encounterHasValidVitals">
			<xsl:apply-templates select="/Container/Observations/Observation" mode="eVS-encounterHasValids">
				<xsl:with-param name="encounterNumber" select="$encounterNumber"/>
				<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:if test="string-length($encounterHasValidVitals) and count(key('ObservationByEncNum',$encounterNumber))>0">			
			<xsl:apply-templates select="/Container/Observations" mode="eVS-vitalSigns-NarrativeDetail-Encounter">
				<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
				<xsl:with-param name="encounterNumber" select="$encounterNumber"/>
				<xsl:with-param name="narrativeLinkSuffix1" select="$narrativeLinkSuffix1"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="vitalSigns-Entries-Encounter">
		<xsl:param name="validVitalSigns"/>
		<xsl:param name="encounterNumber"/>
		<xsl:param name="narrativeLinkSuffix1"/>
		
		<!-- Make sure the encounter has valid vital signs before exporting for the encounter. -->
		<xsl:variable name="encounterHasValidVitals">
			<xsl:apply-templates select="/Container/Observations/Observation" mode="eVS-encounterHasValids">
				<xsl:with-param name="encounterNumber" select="$encounterNumber"/>
				<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
			</xsl:apply-templates>
		</xsl:variable>		

		<xsl:if test="string-length($encounterHasValidVitals) and count(key('ObservationByEncNum',$encounterNumber))>0">
			<xsl:apply-templates select="/Container/Observations" mode="eVS-vitalSigns-EntryDetail">
				<xsl:with-param name="validVitalSigns" select="$validVitalSigns"/>
				<xsl:with-param name="encounterNumber" select="$encounterNumber"/>
				<xsl:with-param name="narrativeLinkSuffix1" select="$narrativeLinkSuffix1"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="eVS-templateIds-vitalSignsEntry">
		<templateId root="{$ccda-VitalSignsOrganizer}"/>
		<templateId root="{$ccda-VitalSignsOrganizer}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eVS-templateIds-vitalSignObservation">
		<templateId root="{$ccda-VitalSignObservation}"/>
		<templateId root="{$ccda-VitalSignObservation}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="eVS-templateIds-vitalSignObservationStatus">
		<xsl:if test="$hl7-CCD-StatusObservation">
			<templateId root="{$hl7-CCD-StatusObservation}"/>
			<templateId root="{$hl7-CCD-StatusObservation}" extension="2015-08-01"/>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
