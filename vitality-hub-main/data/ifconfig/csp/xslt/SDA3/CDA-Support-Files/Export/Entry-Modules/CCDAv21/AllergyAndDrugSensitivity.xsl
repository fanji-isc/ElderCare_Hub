<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc xsi exsl">
  <!-- AlsoInclude: AuthorParticipation.xsl Comment.xsl -->
  
	<xsl:variable name="allergyObservationId" select="$exportConfiguration/allergies/observationId/text()"/>
	
	<xsl:template match="*" mode="eADS-allergies-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Allergy Name</th>
						<th>Allergy Type</th>
						<th>Status</th>
						<th>Severity</th>
						<th>Criticality</th>
						<th>Reaction(s)</th>
						<th>Onset Date</th>
						<th>Inactive Date</th>
						<th>Treating Clinician</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Allergy" mode="eADS-allergies-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="Allergy" mode="eADS-allergies-NarrativeDetail">
		<xsl:variable name="allergyNumber" select="position()"/>
		
		<tr ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyNarrative/text(), position())}">
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyAllergen/text(), position())}"><xsl:apply-templates select="Allergy" mode="fn-originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyCategory/text(), position())}"><xsl:apply-templates select="AllergyCategory" mode="fn-originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyStatus/text(), position())}">
				<xsl:variable name="statusCode"><xsl:value-of select="Status/text()"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="$statusCode = 'A'">Active</xsl:when>
					<xsl:when test="$statusCode = 'C'">To Be Confirmed</xsl:when>
					<xsl:when test="$statusCode = 'I'">Inactive</xsl:when>
					<xsl:when test="$statusCode = 'R'">Resolved</xsl:when>
					<xsl:otherwise>Unknown</xsl:otherwise>
				</xsl:choose>
			</td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergySeverity/text(), position())}"><xsl:apply-templates select="Severity" mode="fn-originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyCriticality/text(), position())}"><xsl:apply-templates select="Criticality" mode="fn-originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyReaction/text(), $allergyNumber)}"><xsl:apply-templates select="Reaction" mode="fn-descriptionOrCode"/></td>
			<td><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="InactiveTime" mode="fn-narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="Clinician" mode="fn-name-Person-Narrative"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyComments/text(), position())}"><xsl:value-of select="Comments/text()"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="eADS-allergies-Entries">
		<xsl:apply-templates select="Allergy" mode="eADS-allergies-EntryDetail"/>
	</xsl:template>

	<xsl:template match="Allergy" mode="eADS-allergies-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<xsl:call-template name="eADS-templateIds-allergiesEntry"/>
				
				<!--
				Field : Allergy Problem Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/id
				Source: HS.SDA3.Allergy ExternalId
				Source: /Container/Allergies/Allergy/ExternalId
				StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="fn-id-External"/>			
				
				<code code="CONC" displayName="Concern" codeSystem="{$actClassOID}" codeSystemName="{$actClassName}"/>	
				
				<text><reference value="{concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyNarrative/text(), $narrativeLinkSuffix)}"/></text>
				
				<xsl:apply-templates select="." mode="eADS-statusCode-Allergy"/>
				
				<!--
					Field : Allergy Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/performer
					Source: HS.SDA3.Allergy Clinician
					Source: /Container/Allergies/Allergy/Clinician
					StructuredMappingRef: performer
				-->
				<xsl:apply-templates select="Clinician" mode="fn-performer"/>
				
				<!--
					Field : Allergy Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/author
					Source: HS.SDA3.Allergy EnteredBy
					Source: /Container/Allergies/Allergy/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>

				<!--
					Field : Allergy Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/informant
					Source: HS.SDA3.Allergy EnteredAt
					Source: /Container/Allergies/Allergy/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<xsl:apply-templates select="." mode="eADS-observation-main">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
				
				<!--
					Field : Allergy Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.Allergy Comments
					Source: /Container/Allergies/Allergy/Comments
				-->
				<xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyComments/text(), $narrativeLinkSuffix)"/>
				</xsl:apply-templates>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="eADS-observation-NoKnownAllergiesEntry">
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<xsl:call-template name="eADS-templateIds-allergiesEntry"/>
				
				<xsl:apply-templates select="." mode="fn-id-External"/>			
				
				<code code="CONC" displayName="Concern" codeSystem="{$actClassOID}" codeSystemName="{$actClassName}"/>	

				<statusCode code="active"/>

				<effectiveTime><low nullFlavor="NA"/></effectiveTime>

				<xsl:apply-templates select="." mode="eADS-observation-NoKnownAllergy"/>
			</act>
		</entry>
	</xsl:template>	

<!-- 	<xsl:template match="*" mode="eADS-allergies-NoData">
		<text><xsl:value-of select="$exportConfiguration/allergies/emptySection/narrativeText/text()"/></text>
	</xsl:template> -->

	<xsl:template match="*" mode="eADS-allergies-NoKnownAllergies">
		<!--For expressing No Known Allergies, both a text and an entry of Allergy Concern Act are needed-->
		<text><xsl:value-of select="$exportConfiguration/allergies/emptySection/narrativeText/text()"/></text>
		<xsl:apply-templates select="." mode="eADS-observation-NoKnownAllergiesEntry"/>
	</xsl:template>	

	<xsl:template match="Allergy" mode="eADS-observation-main">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eADS-templateIds-allergiesCategory"/>
				
				<xsl:apply-templates select="." mode="eADS-id-AllergyObservation"/>
				
				<code code="ASSERTION" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
				
				<statusCode code="completed"/>				
				
				<!--
					Field : Allergy Start Date
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/effectiveTime/low/@value
					Source: HS.SDA3.Allergy FromTime
					Source: /Container/Allergies/Allergy/FromTime
				-->
				<!--
					Field : Allergy End Date
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/effectiveTime/high/@value
					Source: HS.SDA3.Allergy ToTime
					Source: /Container/Allergies/Allergy/ToTime
				-->
				<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>
				
				<!--
					Field : Allergy Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/code
					Source: HS.SDA3.Allergy AllergyCategory
					Source: /Container/Allergies/Allergy/AllergyCategory
				-->
				<xsl:choose>
					<xsl:when test="AllergyCategory">
						<xsl:apply-templates select="AllergyCategory" mode="eADS-value-AllergyCategory">
							<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyCategory/text(), $narrativeLinkSuffix)"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise><code nullFlavor="NA"/></xsl:otherwise>
				</xsl:choose>
				
				<!-- 
					The author is duplicated here to be more in line with the rev3 companion guide
					and for 2015 Cures Act validation while remaining backward compatabile.
				-->
				<!--
					Field : Allergy Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/author
					Source: HS.SDA3.Allergy EnteredBy
					Source: /Container/Allergies/Allergy/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>

				<xsl:apply-templates select="Allergy" mode="eADS-participant-Allergy"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				<xsl:apply-templates select="Reaction" mode="eADS-observation-Reaction"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				<xsl:apply-templates select="Criticality" mode="eADS-observation-Criticality"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				<xsl:apply-templates select="Status" mode="eADS-observation-AllergyStatus"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="eADS-observation-NoKnownAllergy">
		<entryRelationship typeCode="SUBJ" inversionInd="false">
		    <!-- No Known Allergies -->
            <!-- The negationInd = true negates the observation/value -->
            <!-- The use of negationInd corresponds with the newer Observation.valueNegationInd -->
			<observation classCode="OBS" moodCode="EVN" negationInd="true">
				<xsl:call-template name="eADS-templateIds-allergiesCategory"/>
				
				<xsl:apply-templates select="." mode="eADS-id-AllergyObservation"/>
				
				<code code="ASSERTION" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
				
				<statusCode code="completed"/>				
				
                <effectiveTime>
                    <low nullFlavor="NA"/>
                </effectiveTime>
                    
                <value xsi:type="CD" code="419199007"
                        displayName="Allergy to substance (disorder)"
                        codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT"/>				
               
                <participant typeCode="CSM">
                    <participantRole classCode="MANU">
                        <playingEntity classCode="MMAT">
                            <code nullFlavor="NA"/>
                        </playingEntity>
                    </participantRole>
                </participant>

			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="Allergy" mode="eADS-participant-Allergy">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<participant typeCode="CSM">
			<participantRole classCode="MANU">
				<addr nullFlavor="{$addrNullFlavor}"/>
				<telecom nullFlavor="UNK"/>

				<!--
					Field : Allergy Product Coded
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/participant/participantRole/playingEntity/code
					Source: HS.SDA3.Allergy Allergy
					Source: /Container/Allergies/Allergy/Allergy
					StructuredMappingRef: generic-Coded
				-->
				
				<playingEntity classCode="MMAT">
					<xsl:apply-templates select="." mode="fn-generic-Coded">
						<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyAllergen/text(), $narrativeLinkSuffix)"/>
					</xsl:apply-templates>

					<name><xsl:apply-templates select="." mode="fn-originalTextOrDescriptionOrCode"/></name>
				</playingEntity>
			</participantRole>
		</participant>
	</xsl:template>
	
	<xsl:template match="Reaction" mode="eADS-observation-Reaction">
		<xsl:param name="narrativeLinkSuffix"/>

		<entryRelationship typeCode="MFST" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eADS-templateIds-allergiesReaction"/>
				
				<id nullFlavor="{$idNullFlavor}"/>
				<code code="ASSERTION" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>

				<text><reference value="{concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyReaction/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					Field : Allergy Start Date
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='MFST']/observation/effectiveTime/low/@value
					Source: HS.SDA3.Allergy FromTime
					Source: /Container/Allergies/Allergy/FromTime
				-->
				<!--
					Field : Allergy End Date
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='MFST']/observation/effectiveTime/high/@value
					Source: HS.SDA3.Allergy ToTime
					Source: /Container/Allergies/Allergy/ToTime
				-->
				<xsl:apply-templates select=".." mode="fn-effectiveTime-FromTo"/>

				<!--
					Field : Allergy Reaction Coded
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='MFST']/observation/value
					Source: HS.SDA3.Allergy Reaction
					Source: /Container/Allergies/Allergy/Reaction
				-->
				<xsl:apply-templates select="." mode="fn-value-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyReaction/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
				</xsl:apply-templates>

				<xsl:apply-templates select="../Severity" mode="eADS-observation-Severity"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>

			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="Severity" mode="eADS-observation-Severity">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eADS-templateIds-allergiesSeverity"/>
				
				<code code="SEV" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}" displayName="Severity observation"/>
				<statusCode code="completed"/>
				
				<!--
					Field : Allergy Severity Coded
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='SEV']/value
					Source: HS.SDA3.Allergy Severity
					Source: /Container/Allergies/Allergy/Severity
				-->
				<xsl:apply-templates select="." mode="fn-value-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergySeverity/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
				</xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="Criticality" mode="eADS-observation-Criticality">
		<xsl:param name="narrativeLinkSuffix"/>

		<entryRelationship typeCode="SUBJ" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eADS-templateIds-allergiesCriticality"/>
				
				<code code="82606-5" displayName="Criticality" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<text><reference value="{concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyCriticality/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					Field : Allergy Criticality Coded
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation[templateId/@root='2.16.840.1.113883.10.20.22.4.7']/entryRelationship/observation[templateId/@root='2.16.840.1.113883.10.20.22.4.145']/value
					Source: HS.SDA3.Allergy Criticality
					Source: /Container/Allergies/Allergy/Criticality
				-->
				<value xsi:type="CD" codeSystem="2.16.840.1.113883.5.1063" codeSystemName="ObservationValue">
					<xsl:attribute name="code">
						<xsl:choose>
							<xsl:when test="Code/text() = 'H'">CRITH</xsl:when>
							<xsl:when test="Code/text() = 'L'">CRITL</xsl:when>
							<xsl:otherwise>CRITU</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="displayName">
						<xsl:choose>
							<xsl:when test="Code/text() = 'H'">high criticality</xsl:when>
							<xsl:when test="Code/text() = 'L'">low criticality</xsl:when>
							<xsl:otherwise>unable to assess criticality</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</value>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="Status" mode="eADS-observation-AllergyStatus">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="REFR" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eADS-templateIds-allergiesStatus"/>

				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<text><reference value="{concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyStatus/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<SDACodingStandard><xsl:value-of select="$snomedName"/></SDACodingStandard>
						<Code>
							<xsl:choose>
								<xsl:when test="contains('A|C', text())">55561003</xsl:when>
								<xsl:otherwise>73425007</xsl:otherwise>
							</xsl:choose>
						</Code>
						<Description>
							<xsl:choose>
								<xsl:when test="contains('A|C', text())">Active</xsl:when>
								<xsl:otherwise>Inactive</xsl:otherwise>
							</xsl:choose>
						</Description>
					</Status>
				</xsl:variable>
				
				<!--
					Field : Allergy Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
					Source: HS.SDA3.Allergy Status
					Source: /Container/Allergies/Allergy/Status
					Note  : SDA Allergy Status is %String, and so SNOMED
							codeSystem is defaulted in during export to CDA.
				-->
				<xsl:apply-templates select="exsl:node-set($statusInformation)/Status" mode="fn-value-CE"/>

			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="Allergy" mode="eADS-statusCode-Allergy">
		<!--
			Field : Allergy Status
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/statusCode
			Source: HS.SDA3.Allergy Status
			Source: /Container/Allergies/Allergy/Status
			Note  : HealthShare recognizes these states:  A = Active, R = resolved, I = Inactive, C = ToBeConfirmed
					
					SDA Status is mapped to CDA status as follows:
					A and C = active
					I = aborted
					R = completed
					
					For C-CDA, the presence or absence of effectiveTime/high may override the status from HS.
		-->
		<statusCode>
			<xsl:attribute name="code">
				<xsl:choose>
					<xsl:when test="contains('A|C', Status/text())">active</xsl:when>
					<xsl:when test="text() = 'I'">aborted</xsl:when>
					<xsl:when test="not(string-length(ToTime/text()))">active</xsl:when>
					<xsl:otherwise>completed</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</statusCode>
		
		<!--
			IHE mandates special handling of "aborted" and "completed" states when building <effectiveTime>:
				The <high> element shall be present for concerns in the completed or aborted state, and shall not be present otherwise.
		-->
		<!--
			Field : Allergy Start Date
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/effectiveTime/low/@value
			Source: HS.SDA3.Allergy FromTime
			Source: /Container/Allergies/Allergy/FromTime
		-->
		<!--
			Field : Allergy End Date
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/effectiveTime/high/@value
			Source: HS.SDA3.Allergy ToTime
			Source: /Container/Allergies/Allergy/ToTime
		-->
		<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo">
			<xsl:with-param name="includeHighTime" select="not(contains('A|C', Status/text()))"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="AllergyCategory" mode="eADS-value-AllergyCategory">
		<xsl:param name="narrativeLink"/>
		<xsl:param name="xsiType" select="'CD'"/>
		<!--
		allergies-category-code is a special case coded entry template
		for allergy category, which must be a SNOMED allergy category.
		-->
		
		<xsl:variable name="sdaCodingStandardOID"><xsl:apply-templates select="." mode="fn-oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
				
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
				<xsl:variable name="snomedAllergyCategories"
					>|420134006|418038007|419511003|418471000|419199007|416098002|414285001|59037007|235719002|</xsl:variable>
				<xsl:variable name="isValidSnomedCode" select="contains($snomedAllergyCategories, concat('|', Code/text(), '|'))"/>

				<xsl:choose>
					<!-- If SNOMED code system and a valid SNOMED code, then export as is. -->
					<xsl:when test="($sdaCodingStandardOID = $snomedOID) and ($isValidSnomedCode)">
						<value code="{Code/text()}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}">
							<xsl:attribute name="displayName">
								<xsl:apply-templates select="." mode="fn-descriptionOrCode"/>
							</xsl:attribute>
							<xsl:if test="string-length($xsiType)">
								<xsl:attribute name="xsi:type">
									<xsl:value-of select="$xsiType"/>
								</xsl:attribute>
							</xsl:if>
							<originalText>
								<xsl:choose>
									<xsl:when test="string-length($narrativeLink)">
										<reference value="{$narrativeLink}"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="." mode="fn-originalTextOrDescriptionOrCode"/>
									</xsl:otherwise>
								</xsl:choose>
							</originalText>
							<xsl:apply-templates select="PriorCodes/PriorCode[Type = 'O']" mode="fn-translation"/>
						</value>
					</xsl:when>

					<!--
						If valid SNOMED code but not SNOMED code system, then export
						with SNOMED code system plugged in, plus export a <translation>
						with the data and code system that was actually received.
					-->
					<xsl:when test="$isValidSnomedCode">
						<value code="{Code/text()}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}">
							<xsl:attribute name="displayName">
								<xsl:apply-templates select="." mode="fn-descriptionOrCode"/>
							</xsl:attribute>
							<xsl:if test="string-length($xsiType)">
								<xsl:attribute name="xsi:type">
									<xsl:value-of select="$xsiType"/>
								</xsl:attribute>
							</xsl:if>
							<originalText>
								<xsl:apply-templates select="." mode="fn-originalTextOrDescriptionOrCode"/>
							</originalText>
							<translation code="{Code/text()}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{Description/text()}"/>
							<xsl:apply-templates select="PriorCodes/PriorCode[Type = 'O']" mode="fn-translation"/>
						</value>
					</xsl:when>

					<!-- Otherwise, it's not a valid SNOMED code, make it into one. -->
					<xsl:otherwise>
						<xsl:variable name="descUpper" select="translate(Description/text(), $lowerCase, $upperCase)"/>
						<xsl:variable name="code">
							<xsl:choose>
								<xsl:when test="contains($descUpper, 'DRUG')">416098002</xsl:when>
								<xsl:when test="contains($descUpper, 'FOOD')">414285001</xsl:when>
								<xsl:otherwise>419199007</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="description">
							<xsl:choose>
								<xsl:when test="string-length(Description)">
									<xsl:value-of select="Description"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$code"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<value code="{$code}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="{$description}">
							<xsl:if test="string-length($xsiType)">
								<xsl:attribute name="xsi:type">
									<xsl:value-of select="$xsiType"/>
								</xsl:attribute>
							</xsl:if>
							<originalText>
								<xsl:choose>
									<xsl:when test="string-length($narrativeLink)">
										<reference value="{$narrativeLink}"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="." mode="fn-originalTextOrDescriptionOrCode"/>
									</xsl:otherwise>
								</xsl:choose>
							</originalText>
							<translation code="{translate(Code/text(),' ','_')}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{$description}"/>
							<xsl:apply-templates select="PriorCodes/PriorCode[Type = 'O']" mode="fn-translation"/>
						</value>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<value nullFlavor="NA"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Allergy | *" mode="eADS-id-AllergyObservation">
		<xsl:choose>
			<xsl:when test="$allergyObservationId='0'"><id nullFlavor="NI"/></xsl:when>
			<!--
				Field : Allergy Observation Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/id
				Source: HS.SDA3.Allergy ExternalId
				Source: /Container/Allergies/Allergy/ExternalId
				StructuredMappingRef: id-External
				Note  : Export of allergy observation-level id is dependent upon
						the value of ExportProfile.xml configuration item
						/exportConfiguration/allergies/observationId.
						When the setting is 1, the SDA ExternalId is used.
						When the setting is 2, a GUID is exported.
						Otherwise <id nullFlavor="NI"/> is exported.
			-->
			<xsl:when test="$allergyObservationId='1'"><xsl:apply-templates select="." mode="fn-id-External"/></xsl:when>
			<xsl:when test="$allergyObservationId='2'"><id root="{isc:evaluate('createUUID')}"/></xsl:when>
			<xsl:otherwise><id nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Allergy" mode="eADS-id-AllergyProblem">
		<!-- UNUSED -->
		<!--
			Field : Allergy Problem Id
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/id
			Source: HS.SDA3.Allergy ExternalId
			Source: /Container/Allergies/Allergy/ExternalId
			StructuredMappingRef: id-External
		-->
		<xsl:apply-templates select="." mode="fn-id-External"/>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eADS-templateIds-allergiesEntry">
		<templateId root="{$ccda-AllergyProblemAct}"/>
		<templateId root="{$ccda-AllergyProblemAct}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eADS-templateIds-allergiesCategory">
		<templateId root="{$ccda-AllergyIntoleranceObservation}"/>
		<templateId root="{$ccda-AllergyIntoleranceObservation}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="eADS-templateIds-allergiesReaction">
		<templateId root="{$ccda-ReactionObservation}"/>
		<templateId root="{$ccda-ReactionObservation}" extension="2014-06-09"/>
	</xsl:template>

	<xsl:template name="eADS-templateIds-allergiesSeverity">
		<templateId root="{$ccda-SeverityObservation}"/>
		<templateId root="{$ccda-SeverityObservation}" extension="2014-06-09"/>
	</xsl:template>

	<xsl:template name="eADS-templateIds-allergiesCriticality">
		<templateId root="{$ccda-CriticalityObservation}"/>
	</xsl:template>

	<xsl:template name="eADS-templateIds-allergiesStatus">
		<templateId root="{$ccda-AllergyStatusObservation}"/>
		<templateId root="{$ccda-AllergyStatusObservation}" extension="2014-06-09"/>
	</xsl:template>
</xsl:stylesheet>
