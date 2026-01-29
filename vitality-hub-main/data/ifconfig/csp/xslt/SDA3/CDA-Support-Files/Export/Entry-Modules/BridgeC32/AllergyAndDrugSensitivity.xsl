<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:variable name="allergyObservationId" select="$exportConfiguration/allergies/observationId/text()"/>
	
	<xsl:template match="*" mode="allergies-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Allergy Name</th>
						<th>Allergy Type</th>
						<th>Status</th>
						<th>Severity</th>
						<th>Reaction(s)</th>
						<th>Onset Date</th>
						<th>Inactive Date</th>
						<th>Treating Clinician</th>
						<th>Comments</th>
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
		
		<tr ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyNarrative/text(), position())}">
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyAllergen/text(), position())}"><xsl:apply-templates select="Allergy" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyCategory/text(), position())}"><xsl:apply-templates select="AllergyCategory" mode="originalTextOrDescriptionOrCode"/></td>
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
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergySeverity/text(), position())}"><xsl:apply-templates select="Severity" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyReaction/text(), $allergyNumber)}"><xsl:apply-templates select="Reaction" mode="descriptionOrCode"/></td>
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="InactiveTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="Clinician" mode="name-Person-Narrative"/></td>
			<td ID="{concat($exportConfiguration/allergies/narrativeLinkPrefixes/allergyComments/text(), position())}"><xsl:value-of select="Comments/text()"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="allergies-Entries">
		<xsl:apply-templates select="Allergy" mode="allergies-EntryDetail"/>
	</xsl:template>

	<xsl:template match="*" mode="allergies-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-allergiesEntry"/>
				
				<xsl:apply-templates select="." mode="id-AllergyProblem"/>
				
				<code nullFlavor="NA"/>
				<text><reference value="{concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyNarrative/text(), $narrativeLinkSuffix)}"/></text>

				<xsl:apply-templates select="." mode="statusCode-Allergy"/>
				
				<!--
					HS.SDA3.Allergy Clinician
					CDA Section: Allergies
					CDA Field: Allergy Clinician
					CDA XPath: entry/act/performer
				-->				
				<xsl:apply-templates select="Clinician" mode="performer"/>
				
				<!--
					HS.SDA3.Allergy EnteredBy
					CDA Section: Allergies
					CDA Field: Author
					CDA XPath: entry/act/author
				-->				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					HS.SDA3.Allergy EnteredAt
					CDA Section: Allergies
					CDA Field: Informant
					CDA XPath: entry/act/informant
				-->				
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				<xsl:apply-templates select="." mode="allergies-Detail"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				
				<!--
					HS.SDA3.Allergy Comments
					CDA Section: Allergies
					CDA Field: Comments
					CDA XPath: entry/act/entryRelationship/act[code/@code='48767-8']
				-->				
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="allergies-NoData">
		<text><xsl:value-of select="$exportConfiguration/allergies/emptySection/narrativeText/text()"/></text>
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-allergiesEntry"/>
				<id nullFlavor="NI"/>
				<code nullFlavor="NA"/>
				<text><reference value="#noAllergies-1"/></text>
				<statusCode code="active"/>						
				<effectiveTime>
					<low nullFlavor="NA"/>
				</effectiveTime>							
				<entryRelationship typeCode="SUBJ" inversionInd="false">
					<observation classCode="OBS" moodCode="EVN">
						<xsl:apply-templates select="." mode="templateIds-allergiesCategory"/>
						<id nullFlavor="NI"/>
						<code code="420134006" codeSystem="{$snomedOID}" displayName="Propensity to adverse reactions (disorder)" codeSystemName="{$snomedName}"/>
						<text><reference value="#noAllergies-1"/></text>
						<statusCode code="completed"/>
						<effectiveTime>
							<low nullFlavor="UNK"/>
						</effectiveTime>
						<value xsi:type="CD" code="160244002" codeSystem="{$snomedOID}" displayName="No Known allergies" codeSystemName="{$snomedName}">
							<originalText>
								<reference value="#noAllergies-1"/>
							</originalText>
						</value>
					</observation>
				</entryRelationship>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="allergies-Detail">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-allergiesCategory"/>
				
				<xsl:apply-templates select="." mode="id-AllergyObservation"/>

				<xsl:choose>
					<xsl:when test="AllergyCategory">
						<xsl:apply-templates select="AllergyCategory" mode="allergies-category-code">
							<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyCategory/text(), $narrativeLinkSuffix)"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise><code nullFlavor="NA"/></xsl:otherwise>
				</xsl:choose>
				
				<text><reference value="{concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyCategory/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					HS.SDA3.Allergy FromTime
					HS.SDA3.Allergy ToTime
					CDA Section: Allergies
					CDA Field: Adverse Event Date
					CDA XPath: entry/act/entryRelationship/observation/effectiveTime
				-->				
				<xsl:apply-templates select="." mode="effectiveTime-FromTo">
					<xsl:with-param name="includeHighTime" select="(string-length(ToTime/text())>0)"/>
				</xsl:apply-templates>
				<value xsi:type="CD" nullFlavor="NA"/>
				
				<xsl:apply-templates select="Allergy" mode="participant-Allergy"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				<xsl:apply-templates select="Reaction" mode="observation-Reaction"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				<xsl:apply-templates select="Severity" mode="observation-Severity"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				<xsl:apply-templates select="Status" mode="observation-AllergyStatus"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="participant-Allergy">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<participant typeCode="CSM">
			<participantRole classCode="MANU">
				<addr nullFlavor="{$addrNullFlavor}"/>
				<telecom nullFlavor="UNK"/>
				
				<!--
					HS.SDA3.Allergy Allergy
					CDA Section: Allergies
					CDA Field: Product Coded
					CDA XPath: entry/act/entryRelationship/observation/participant/participantRole/playingEntity/code
				-->				
				<playingEntity classCode="MMAT">
					<xsl:apply-templates select="." mode="generic-Coded">
						<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyAllergen/text(), $narrativeLinkSuffix)"/>
					</xsl:apply-templates>

					<name><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></name>
				</playingEntity>
			</participantRole>
		</participant>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-Reaction">
		<xsl:param name="narrativeLinkSuffix"/>

		<entryRelationship typeCode="MFST" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-allergiesReaction"/>
				
				<id root="{isc:evaluate('createGUID')}"/>
				<code code="ASSERTION" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>

				<text><reference value="{concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyReaction/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					HS.SDA3.Allergy FromTime
					HS.SDA3.Allergy ToTime
					CDA Section: Allergies
					CDA Field: Adverse Event Date
					CDA XPath: entry/act/entryRelationship/observation/entryRelationship[@typeCode='MFST']/observation/effectiveTime
				-->				
				<xsl:apply-templates select="parent::node()" mode="effectiveTime-FromTo">
					<xsl:with-param name="includeHighTime" select="(string-length(parent::node()/ToTime/text())>0)"/>
				</xsl:apply-templates>

				<!-- 
					HS.SDA3.Allergy Reaction
					CDA Section: Allergies
					CDA Field: Reaction Coded
					CDA XPath: entry/act/entryRelationship/observation/entryRelationship[@typeCode='MFST']/observation/value
				-->
				<xsl:apply-templates select="." mode="value-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyReaction/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
				</xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-Severity">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-allergiesSeverity"/>
				
				<id root="{isc:evaluate('createGUID')}"/>
				
				<code code="SEV" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}" displayName="Severity observation"/>
				<statusCode code="completed"/>
				
				<!-- 
					HS.SDA3.Allergy Severity
					CDA Section: Allergies
					CDA Field: Severity Coded
					CDA XPath: entry/act/entryRelationship/observation/entryRelationship[@typeCode='SUBJ']/observation[code/@code='SEV']/value
				-->				
				<xsl:apply-templates select="." mode="value-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergySeverity/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
				</xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-AllergyStatus">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-allergiesStatus"/>

				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<text><reference value="{concat('#', $exportConfiguration/allergies/narrativeLinkPrefixes/allergyStatus/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					Status Detail
					
					SDA Allergy Status is String, and so it has no
					code system.  Force in the SNOMED code system.
				-->
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
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<!--
					HS.SDA3.Allergy Status
					CDA Section: Allergies
					CDA Field: Allergy Status
					CDA XPath: entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
					
					SDA Allergy Status is %String, and so SNOMED codeSystem
					is defaulted in during export to CDA.
				-->				
				<xsl:apply-templates select="$status" mode="value-CE"/>

			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="statusCode-Allergy">
		<!--
			HealthShare recognizes these states:  A = Active, R = resolved, I = Inactive, C = ToBeConfirmed
			
			We will map HealthShare to CDA as follows:
			A and C = active
			I = aborted
			R = completed				
		-->
		
		<!--
			HS.SDA3.Allergy Status
			CDA Section: Allergies
			CDA Field: Allergy Status Code
			CDA XPath: entry/act/statusCode
		-->		
		<statusCode>
			<xsl:attribute name="code">
				<xsl:choose>
					<xsl:when test="contains('A|C', Status/text())">active</xsl:when>
					<xsl:when test="text() = 'I'">aborted</xsl:when>
					<xsl:otherwise>completed</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</statusCode>
		
		<!--
			IHE mandates special handling of "aborted" and "completed" states when building <effectiveTime>:
				The <high> element shall be present for concerns in the completed or aborted state, and shall not be present otherwise.
		-->
		<!--
			HS.SDA3.Allergy FromTime
			HS.SDA3.Allergy ToTime
			CDA Section: Allergies
			CDA Field: Adverse Event Date
			CDA XPath: entry/act/effectiveTime
		-->		
		<xsl:apply-templates select="." mode="effectiveTime-FromTo">
			<xsl:with-param name="includeHighTime" select="not(contains('A|C', Status/text()))"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="allergies-category-code">
		<!--
			allergies-category-code is a special case coded entry template
			for allergy category, which must be a SNOMED allery category.
		-->
		<xsl:param name="narrativeLink"/>
		<xsl:param name="xsiType"/>
		
		<!--
			HS.SDA3.Allergy AllergyCategory
			CDA Section: Allergies
			CDA Field: Adverse Event Type
			CDA XPath: entry/act/entryRelationship/observation/code
		-->		
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
				
					<!--
						If we got the SNOMED code system and a valid SNOMED code,
						then export the data as is.
					-->
					<xsl:when test="($sdaCodingStandardOID=$snomedOID) and ($isValidSnomedCode)">
						<code code="{Code/text()}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}">
							<xsl:attribute name="displayName"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:attribute>
							<xsl:if test="string-length($xsiType)"><xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute></xsl:if>
							<originalText>
								<xsl:choose>
									<xsl:when test="string-length($narrativeLink)"><reference value="{$narrativeLink}"/></xsl:when>
									<xsl:otherwise><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></xsl:otherwise>
								</xsl:choose>
							</originalText>
							
							<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="translation"/>					
						</code>
					</xsl:when>
					
					<!--
						If we got a valid SNOMED code but didn't get the SNOMED
						code system, then export the data with SNOMED code system
						plugged in, and also export a <translation> with the data
						and code system that was actually received.
					-->
					<xsl:when test="$isValidSnomedCode">
						<code code="{Code/text()}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}">
							<xsl:attribute name="displayName"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:attribute>
							<xsl:if test="string-length($xsiType)"><xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute></xsl:if>
							<originalText><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></originalText>
							<translation code="{Code/text()}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{Description/text()}"/>
							<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="translation"/>					
						</code>
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
								<xsl:when test="string-length(Description)"><xsl:value-of select="Description"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$code"/></xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<code code="{$code}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="{$description}">
							<xsl:if test="string-length($xsiType)"><xsl:attribute name="xsi:type"><xsl:value-of select="$xsiType"/></xsl:attribute></xsl:if>
							<originalText>
								<xsl:choose>
									<xsl:when test="string-length($narrativeLink)"><reference value="{$narrativeLink}"/></xsl:when>
									<xsl:otherwise><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></xsl:otherwise>
								</xsl:choose>
							</originalText>
							
							<translation code="{translate(Code/text(),' ','_')}" codeSystem="{$codeSystemOIDForTranslation}" codeSystemName="{$codeSystemNameForTranslation}" displayName="{$description}"/>
							<xsl:apply-templates select="PriorCodes/PriorCode[Type='O']" mode="translation"/>					
						</code>
					</xsl:otherwise>
					
				</xsl:choose>
				</xsl:when>
			<xsl:otherwise>
				<code nullFlavor="NA"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Allergy" mode="id-AllergyProblem">
		<!--
			HS.SDA3.Allergy ExternalId
			CDA Section: Allergies
			CDA Field: Id
			CDA XPath: entry/act/id
		-->
		<xsl:apply-templates select="." mode="id-External"/>
	</xsl:template>
	
	<xsl:template match="Allergy" mode="id-AllergyObservation">
		<xsl:choose>
			<xsl:when test="$allergyObservationId='0'"><id nullFlavor="NI"/></xsl:when>
			<!--
				HS.SDA3.Allergy ExternalId
				CDA Section: Allergies
				CDA Field: Id
				CDA XPath: entry/act/entryRelationship/observation/id
			-->
			<xsl:when test="$allergyObservationId='1'"><xsl:apply-templates select="." mode="id-External"/></xsl:when>
			<xsl:when test="$allergyObservationId='2'"><id root="{isc:evaluate('createUUID')}"/></xsl:when>
			<xsl:otherwise><id nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-allergiesEntry">
		<xsl:if test="$hitsp-CDA-AllergyAndDrugSensitivityModule"><templateId root="{$hitsp-CDA-AllergyAndDrugSensitivityModule}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProblemAct"><templateId root="{$hl7-CCD-ProblemAct}"/></xsl:if>
		<xsl:if test="$ihe-PCC-AllergyAndIntoleranceConcern"><templateId root="{$ihe-PCC-AllergyAndIntoleranceConcern}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ConcernEntry"><templateId root="{$ihe-PCC-ConcernEntry}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-allergiesCategory">
		<xsl:if test="$hl7-CCD-AlertObservation"><templateId root="{$hl7-CCD-AlertObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProblemObservation"><templateId root="{$hl7-CCD-ProblemObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ProblemEntry"><templateId root="{$ihe-PCC-ProblemEntry}"/></xsl:if>
		<xsl:if test="$ihe-PCC-AllergiesAndIntolerances"><templateId root="{$ihe-PCC-AllergiesAndIntolerances}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-allergiesReaction">
		<xsl:if test="$hl7-CCD-ReactionObservation"><templateId root="{$hl7-CCD-ReactionObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProblemObservation"><templateId root="{$hl7-CCD-ProblemObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ProblemEntry"><templateId root="{$ihe-PCC-ProblemEntry}"/></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-allergiesSeverity">
		<xsl:if test="$hl7-CCD-SeverityObservation"><templateId root="{$hl7-CCD-SeverityObservation}"/></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-allergiesStatus">
		<xsl:if test="$hl7-CCD-AlertStatusObservation"><templateId root="{$hl7-CCD-AlertStatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProblemStatusObservation"><templateId root="{$hl7-CCD-ProblemStatusObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ProblemStatusObservation"><templateId root="{$ihe-PCC-ProblemStatusObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
