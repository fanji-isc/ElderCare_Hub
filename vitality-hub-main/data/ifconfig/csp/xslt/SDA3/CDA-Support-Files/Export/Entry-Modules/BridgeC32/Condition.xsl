<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Problem Variables -->
	<xsl:variable name="currentConditionStatusCodes" select="$exportConfiguration/problems/currentCondition/codes/text()"/>
	<xsl:variable name="currentConditionWindowInDays" select="$exportConfiguration/problems/currentCondition/windowInDays/text()"/>
	<xsl:variable name="problemObservationId" select="$exportConfiguration/problems/observationId/text()"/>
	<xsl:variable name="pregnancyCodes"><xsl:apply-templates select="." mode="conditions-PregnancyCodes"/></xsl:variable>
	
	<xsl:template match="*" mode="conditions-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions" select="true()"/>
		
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Condition Name</th>
						<th>Condition Details</th>
						<th>Condition Category</th>
						<th>Status</th>
						<th>Onset Date</th>
						<th>Resolution Date</th>
						<th>Last Treatment Date</th>
						<th>Treating Clinician</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Problems/Problem" mode="conditions-NarrativeDetail">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
						<xsl:with-param name="currentConditions" select="$currentConditions"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="conditions-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions"/>

		<xsl:variable name="includeInExport"><xsl:apply-templates select="." mode="includeConditionInExport"><xsl:with-param name="currentConditions" select="$currentConditions"></xsl:with-param></xsl:apply-templates></xsl:variable>

		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionNarrative/text(), $narrativeLinkSuffix)}">
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionDisplayName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="Problem" mode="descriptionOrCode"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionDescription/text(), $narrativeLinkSuffix)}"><xsl:value-of select="ProblemDetails/text()"/></td>
				<!-- problemCategoryLink hard-coded for Bridge C32 -->
				<td ID="{concat('problemCategoryLink-',$narrativeLinkSuffix)}"><xsl:apply-templates select="Category" mode="descriptionOrCode"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionStatus/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="Status" mode="descriptionOrCode"/></td>
				<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="EnteredOn" mode="narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="Clinician" mode="name-Person-Narrative"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="conditions-Entries">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions" select="true()"/>

		<xsl:apply-templates select="Problems/Problem" mode="conditions-EntryDetail">
			<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
			<xsl:with-param name="currentConditions" select="$currentConditions"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="conditions-EntryDetail">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions"/>

		<xsl:variable name="includeInExport"><xsl:apply-templates select="." mode="includeConditionInExport"><xsl:with-param name="currentConditions" select="$currentConditions"></xsl:with-param></xsl:apply-templates></xsl:variable>

		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<entry typeCode="DRIV">
				<act classCode="ACT" moodCode="EVN">
					<xsl:choose>
						<xsl:when test="not(Category/SDACodingStandard/text()=$loincName and contains($pregnancyCodes,concat('|',Category/Code/text(),'^')))">
							<xsl:apply-templates select="." mode="templateIds-problemEntry"/>
						</xsl:when>
						<xsl:otherwise>
								<xsl:apply-templates select="." mode="templateIds-problemEntry-pregnancy"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="." mode="id-ProblemConcern"/>
					
					<code nullFlavor="NA"/>
					<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionNarrative/text(), $narrativeLinkSuffix)}"/></text>

					<xsl:apply-templates select="." mode="statusCode-Problem"/>
					
					<!--
						HS.SDA3.Problem Clinician
						CDA Section: Problem List, History of Past Illness
						CDA Field: Treating Provider
						CDA XPath: entry/act/performer
					-->					
					<xsl:apply-templates select="Clinician" mode="performer"/>
					
					<!--
						HS.SDA3.Problem EnteredBy
						CDA Section: Problem List, History of Past Illness
						CDA Field: Author
						CDA XPath: entry/act/author
					-->					
					<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
					
					<!--
						HS.SDA3.Problem EnteredAt
						CDA Section: Problem List, History of Past Illness
						CDA Field: Author
						CDA XPath: entry/act/author/assignedAuthor/representedOrganization, entry/act/informant
					-->					
					<xsl:apply-templates select="EnteredAt" mode="informant"/>
					<xsl:choose>
						<xsl:when test="not(Category/SDACodingStandard/text()=$loincName and contains($pregnancyCodes,concat('|',Category/Code/text(),'^')))">
							<xsl:apply-templates select="." mode="observation-Problem">
								<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
								<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="observation-Problem-Pregnancy">
								<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
								<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
					
					<!--
						HS.SDA3.Problem Comments
						CDA Section: Problem List, History of Past Illness
						CDA Field: Problem Comments
						CDA XPath: entry/act/entryRelationship/act[code/@code='48767-8']
					-->					
					<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
					<!--
						HS.SDA3.Problem EncounterNumber
						CDA Section: Problem List, History of Past Illness
						CDA Field: Encounter
						CDA XPath: entry/act/entryRelationship/encounter
						
						This links the Problem to an encounter in the CDA Encounters section.
					-->
					<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
				</act>
			</entry>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="problems-NoData">
		<text><xsl:value-of select="$exportConfiguration/problems/emptySection/narrativeText/text()"/></text>
		 <entry typeCode="DRIV">
	  		<act classCode="ACT" moodCode="EVN">
	  			<xsl:apply-templates select="." mode="templateIds-problemEntry"/> 
	  			<id nullFlavor="NI"/> 
	  			<code nullFlavor="NA"/> 
	  			<text><reference value="#noProblems-1"/></text>
	  			<statusCode code="completed" /> 
	  			<effectiveTime>
	 				<low nullFlavor="UNK"/>
	 				<high nullFlavor="UNK"/>
	 			</effectiveTime>
				<entryRelationship typeCode="SUBJ" inversionInd="false">
					<observation classCode="OBS" moodCode="EVN">
						<xsl:apply-templates select="." mode="templateIds-problemObservation"/>
						<id nullFlavor="NI"/>
						<code nullFlavor="NI"/>
						<text><reference value="#noProblems-1"/></text>
						<statusCode code="completed"/> 
						<effectiveTime>
							<low nullFlavor="UNK"/>
							<high nullFlavor="UNK"/>
						</effectiveTime>
						<value nullFlavor="NI" xsi:type="CD"/>
					</observation>
				</entryRelationship>
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="pastIllness-NoData">
		<text>
			<table>
				<thead>
					<tr>
						<td>History of Past Illness</td>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>No records on file</td>
					</tr>
				</tbody>
			</table>
		</text>
		<entry>
			<act classCode="ACT" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-problemEntry"/>
				<id nullFlavor="UNK"/>
				<code nullFlavor="NA"/>
				<statusCode code="active"/>
				<effectiveTime>
					<low nullFlavor="UNK"/>
				</effectiveTime>
				<entryRelationship typeCode="SUBJ" inversionInd="false">
					<observation classCode="OBS" moodCode="EVN" negationInd="true">
						<xsl:apply-templates select="." mode="templateIds-problemObservation"/>
						<id nullFlavor="UNK"/>
						<code code="64572001" displayName="Disease" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}"/>
						<text>No known records</text>
						<statusCode code="completed"/>
						<effectiveTime>
							<low nullFlavor="UNK"/>
						</effectiveTime>
						<value xsi:type="CD" code="64572001" displayName="Disease" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}"/>
					</observation>
				</entryRelationship>
			</act>
		</entry>	
	</xsl:template>

	<xsl:template match="*" mode="admissionDiagnoses-NoData">
		<text><xsl:value-of select="$exportConfiguration/admissionDiagnoses/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="dischargeDiagnoses-NoData">
		<text><xsl:value-of select="$exportConfiguration/dischargeDiagnoses/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="diagnoses-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="diagnosisTypeCodes"/>
		
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Condition Name</th>
						<th>Status</th>
						<th>Diagnosis Date</th>
						<th>Treating Clinician</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Diagnoses/Diagnosis[contains(translate($diagnosisTypeCodes, $lowerCase, $upperCase), concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|')) = true()]" mode="diagnoses-NarrativeDetail">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="diagnoses-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory"/>
			
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="Diagnosis" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisStatus/text(), $narrativeLinkSuffix)}">
				<xsl:variable name="statusCode"><xsl:value-of select="Status/Code/text()"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="$statusCode = 'A'">Active</xsl:when>
					<xsl:when test="$statusCode = 'I'">Inactive</xsl:when>
					<xsl:otherwise>Unknown</xsl:otherwise>
				</xsl:choose>
			</td>
			<td><xsl:apply-templates select="IdentificationTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="DiagnosingClinician" mode="name-Person-Narrative"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="diagnoses-Entries">
		<xsl:param name="narrativeLinkCategory"/>			
		<xsl:param name="diagnosisTypeCodes"/>
		
		<xsl:apply-templates select="Diagnoses/Diagnosis[contains(translate($diagnosisTypeCodes, $lowerCase, $upperCase), concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|')) = true()]" mode="diagnoses-EntryDetail">
			<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="diagnoses-EntryDetail">
		<xsl:param name="narrativeLinkCategory"/>
			
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-problemEntry"/>
				
				<!--
					HS.SDA3.Diagnosis ExternalId
					CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
					CDA Field: Id
					CDA XPath: entry/act/id
				-->				
				<xsl:apply-templates select="." mode="id-External"/>

				<code nullFlavor="NA"/>
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisNarrative/text(), $narrativeLinkSuffix)}"/></text>

				<xsl:apply-templates select="." mode="statusCode-Diagnosis"/>
				
				<!--
					HS.SDA3.Diagnosis DiagnosingClinician
					CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
					CDA Field: Treating Provider
					CDA XPath: entry/act/performer or entry/act/entryRelationship/observation/performer
				-->
				<xsl:apply-templates select="DiagnosingClinician" mode="performer"/>
				
				<!--
					HS.SDA3.Diagnosis EnteredBy
					CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
					CDA Field: Author
					CDA XPath: entry/act/author
				-->				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					HS.SDA3.Diagnosis EnteredAt
					CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
					CDA Field: Author
					CDA XPath: entry/act/author/assignedAuthor/representedOrganization, entry/act/informant
				-->				
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				<xsl:apply-templates select="." mode="observation-Diagnosis">
					<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
				
				<!--
					HS.SDA3.Diagnosis EncounterNumber
					CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
					CDA Field: Encounter
					CDA XPath: entry/act/entryRelationship/encounter
					
					This links the Diagnosis to an encounter in the CDA Encounters section.
				-->
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="observation-Problem">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-problemObservation"/>
				
				<xsl:apply-templates select="." mode="id-ProblemObservation"/>
				
				<!--
					HS.SDA3.Problem Category
					CDA Section: Problem List, History of Past Illness
					CDA Field: Problem Type
					CDA XPath: entry/act/entryRelationship/observation/code
				-->
				<xsl:choose>
					<xsl:when test="Category">
						<xsl:apply-templates select="Category" mode="generic-Coded">
							<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$snomedOID"/></xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise><code nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
				
				<!--
					HS.SDA3.Problem ProblemDetails
					CDA Section: Problem List, History of Past Illness
					CDA Field: Problem Name
					CDA XPath: entry/act/entryRelationship/observation/text
					In the CDA export, text is only a reference to the narrative.
					The actual ProblemDetails text appears only in the narrative.
				-->
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionDescription/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					HS.SDA3.Problem FromTime
					HS.SDA3.Problem ToTime
					CDA Section: Problem List, History of Past Illness
					CDA Field: Problem Date
					CDA XPath: entry/act/entryRelationship/observation/effectiveTime
				-->
				<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="snomed-Status-Code"/></xsl:variable>
				<xsl:apply-templates select="." mode="effectiveTime-FromTo">
					<xsl:with-param name="includeHighTime" select="not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/>
				</xsl:apply-templates>
				
				<!--
					HS.SDA3.Problem Problem
					CDA Section: Problem List, History of Past Illness
					CDA Field: Problem Code
					CDA XPath: entry/act/entryRelationship/observation/value
				-->
				<xsl:apply-templates select="Problem" mode="value-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionDisplayName/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
					<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$snomedOID"/></xsl:with-param>
				</xsl:apply-templates>
				
				<!-- Problem Status -->
				<xsl:apply-templates select="Status" mode="observation-ProblemStatus"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionStatus/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-Problem-Pregnancy">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-pregnancyObservation"/>
				
				<id nullFlavor="NI"/>
				
				<xsl:variable name="conditionLOINCName">
					<xsl:value-of select="substring-before(substring-after($pregnancyCodes,concat('|',Category/Code/text(),'^')),'^')"/>
				</xsl:variable>
				
				<xsl:variable name="conditionDataType">
					<xsl:value-of select="substring-before(substring-after($pregnancyCodes,concat('|',Category/Code/text(),'^',$conditionLOINCName,'^')),'|')"/>
				</xsl:variable>
				
				<xsl:variable name="conditionName">
					<xsl:choose>
						<xsl:when test="string-length(Category/Description/text())">
							<xsl:value-of select="Category/Description/text()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$conditionLOINCName"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<!-- Condition Type -->
				<code code="{Category/Code/text()}" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="{$conditionName}"/>
								
				<!-- Condition Name -->
				<!-- problemCategoryLink hard-coded for Bridge C32 -->
				<text><reference value="{concat('#', 'problemCategoryLink-', $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!-- Effective Time -->
				<xsl:apply-templates select="EnteredOn" mode="effectiveTime"/>
				
				<!-- Condition Code -->
				<xsl:choose>
					<xsl:when test="$conditionDataType='INT' or $conditionDataType='PQ'">
						<value xsi:type="{$conditionDataType}">
							<xsl:attribute name="value">
								<xsl:choose>
									<xsl:when test="string-length(Problem/Code/text())">
										<xsl:value-of select="Problem/Code/text()"/>
									</xsl:when>
									<xsl:when test="string-length(Problem/Description/text())">
										<xsl:value-of select="Problem/Description/text()"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</value>
					</xsl:when>
					<xsl:when test="$conditionDataType='CE'">
						<xsl:apply-templates select="Problem" mode="value-Coded">
							<xsl:with-param name="xsiType">CE</xsl:with-param>
							<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$snomedOID"/></xsl:with-param>
					</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="$conditionDataType='TS'">
						<xsl:choose>
							<xsl:when test="string-length(ToTime/text())">
								<value xsi:type="TS"><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></value>
							</xsl:when>
							<xsl:when test="string-length(FromTime/text())">
								<value xsi:type="TS"><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></value>
							</xsl:when>
							<xsl:otherwise>
								<value xsi:type="TS" nullFlavor="UNK"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$conditionDataType='BL'">
						<value xsi:type="INT">1</value>
					</xsl:when>
				</xsl:choose>
				
				<!-- Problem Status -->
				<xsl:apply-templates select="Status" mode="observation-ProblemStatus"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionStatus/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="performer-Problem">
		<performer typeCode="PRF">
			<xsl:apply-templates select="parent::node()" mode="time"/>
			<xsl:apply-templates select="." mode="assignedEntity-performer"/>
			
			<entryRelationship typeCode="CAUS">
				<observation classCode="OBS" moodCode="EVN">
					<xsl:apply-templates select="." mode="templateIds-causeOfDeath"/>
					<code code="419620001" displayName="death" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}"/>
					<xsl:choose>
						<xsl:when test="../CauseOfDeath/text()='Y'">
							<effectiveTime>
								<xsl:choose>
									<xsl:when test="string-length(../FromTime/text())">
										<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
									</xsl:when>
									<xsl:when test="string-length(../TomTime/text())">
										<xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="nullFlavor">NA</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
							</effectiveTime>
						</xsl:when>
						<xsl:otherwise><effectiveTime nullFlavor="NA"/></xsl:otherwise>
					</xsl:choose>
				</observation>
			</entryRelationship>
			
		</performer>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-Diagnosis">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-problemObservation"/>
				
				<id root="{isc:evaluate('createGUID')}"/>
				
				<!-- Diagnosis Type -->
				<code code="282291009" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="Diagnosis"/>
				
				<!--
					HS.SDA3.Diagnosis Diagnosis
					CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
					CDA Field: Diagnosis Name
					CDA XPath: entry/act/entryRelationship/observation/text
					
					In the CDA export, text is only a reference to the narrative.
					The actual Diagnosis Name text appears only in the narrative.
					The CDA narrative uses the Description property of Diagnosis.
				-->
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisDescription/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					HS.SDA3.Diagnosis IdentificationTime
					CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
					CDA Field: Problem Date
					CDA XPath: entry/act/entryRelationship/observation/effectiveTime
				-->				
				<!--
					IHE mandates special handling of "aborted" and "completed" states when building <effectiveTime>:
					The <high> element shall be present for concerns in the completed or aborted state, and shall not be present otherwise.
				-->		
				<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="snomed-Status-Code"/></xsl:variable>
				<xsl:apply-templates select="." mode="effectiveTime-Identification">
					<xsl:with-param name="includeHighTime" select="not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/>
				</xsl:apply-templates>
				
				<!--
					HS.SDA3.Diagnosis Diagnosis
					CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
					CDA Field: Diagnosis Code
					CDA XPath: entry/act/entryRelationship/observation/value
				-->				
				<xsl:apply-templates select="Diagnosis" mode="value-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisDescription/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
				</xsl:apply-templates>
				
				<!-- Diagnosis Status -->
				<xsl:apply-templates select="Status" mode="observation-ProblemStatus"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisStatus/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="statusCode-Problem">
		<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="snomed-Status-Code"/></xsl:variable>
		<!--
			HS.SDA3.Problem Status
			CDA Section: Problem List, History of Past Illness
			CDA Field: Problem Status
			CDA XPath: entry/act/statusCode
		-->		
		<statusCode>
			<xsl:attribute name="code">
				<xsl:choose>
					<xsl:when test="contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|'))">active</xsl:when>
					<xsl:otherwise>completed</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</statusCode>

		<!--
			IHE mandates special handling of "aborted" and "completed" states when building <effectiveTime>:
			The <high> element shall be present for concerns in the completed or aborted state, and shall not be present otherwise.
		-->
		<xsl:apply-templates select="." mode="effectiveTime-FromTo">
			<xsl:with-param name="includeHighTime" select="not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="statusCode-Diagnosis">
		<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="snomed-Status-Code"/></xsl:variable>
		<statusCode>
			<xsl:attribute name="code">
				<xsl:choose>
					<xsl:when test="contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|'))">active</xsl:when>
					<xsl:otherwise>completed</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</statusCode>

		<!--
			IHE mandates special handling of "aborted" and "completed" states when building <effectiveTime>:
			The <high> element shall be present for concerns in the completed or aborted state, and shall not be present otherwise.
		-->		
		<xsl:apply-templates select="." mode="effectiveTime-Identification">
			<xsl:with-param name="includeHighTime" select="not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="observation-ProblemStatus">
		<xsl:param name="narrativeLink"/>
		
		<!--
			HS.SDA3.Diagnosis Status
			CDA Section: Hospital Admission Diagnosis, Discharge Diagnosis
			CDA Field: Diagnosis Status
			CDA XPath: entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']
		-->
		<!--
			HS.SDA3.Problem Status
			CDA Section: Problem List, History of Past Illness
			CDA Field: Problem Status
			CDA XPath: entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']
		-->		
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-problemStatus"/>
				
				<code code="33999-4" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Status"/>
				<text><reference value="{$narrativeLink}"/></text>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="." mode="snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="includeConditionInExport">
		<xsl:param name="currentConditions"/>
		
		<!-- Should this condition be "promoted" to the active problem list? -->
		<xsl:variable name="isCurrentCondition"><xsl:apply-templates select="." mode="currentCondition"/></xsl:variable>

		<xsl:choose>
			<xsl:when test="($currentConditions = true()) and ($isCurrentCondition = 1)">1</xsl:when>
			<xsl:when test="($currentConditions = false()) and ($isCurrentCondition = 0)">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="currentCondition">
		<xsl:choose>
			<xsl:when test="contains($currentConditionStatusCodes, concat('|', Status/Code/text(), '|'))">1</xsl:when>
			<xsl:when test="not(ToTime)">1</xsl:when>
			<xsl:when test="isc:evaluate('dateDiff', 'dd', translate(translate(FromTime/text(), 'Z', ''), 'T', ' ')) &lt;= $currentConditionWindowInDays">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Problem" mode="id-ProblemConcern">
		<!--
			HS.SDA3.Problem ExternalId
			CDA Section: Problem List, History of Past Illness
			CDA Field: Id
			CDA XPath: entry/act/id
		-->
		<xsl:apply-templates select="." mode="id-External"/>
	</xsl:template>
	
	<xsl:template match="Problem" mode="id-ProblemObservation">
		<xsl:choose>
			<xsl:when test="$problemObservationId='0'"><id nullFlavor="NI"/></xsl:when>
			<!--
				HS.SDA3.Problem ExternalId
				CDA Section: Problem List, History of Past Illness
				CDA Field: Id
				CDA XPath: entry/act/entryRelationship/observation/id
			-->
			<xsl:when test="$problemObservationId='1'"><xsl:apply-templates select="." mode="id-External"/></xsl:when>
			<xsl:when test="$problemObservationId='2'"><id root="{isc:evaluate('createUUID')}"/></xsl:when>
			<xsl:otherwise><id nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="conditions-PregnancyCodes">
		|11636-8^BIRTHS LIVE (REPORTED)^INT|
		|11637-6^BIRTHS PRETERM (REPORTED)^INT|
		|11638-4^BIRTHS STILL LIVING (REPORTED)^INT|
		|11639-2^BIRTHS TERM (REPORTED)^INT|
		|11640-0^BIRTHS TOTAL (REPORTED)^INT|
		|11612-9^ABORTIONS (REPORTED)^INT|
		|11613-7^ABORTIONS INDUCED (REPORTED)^INT|
		|11614-5^ABORTIONS SPONTANEOUS (REPORTED)^INT|
		|33065-4^ECTOPIC PREGNANCY (REPORTED)^INT|
		|11449-6^PREGNANCY STATUS^CE|
		|8678-5^MENSTRUAL STATUS^CE|
		|8665-2^DATE LAST MENSTRUAL PERIOD^TS|
		|11778-8^DELIVERY DATE (CLINICAL ESTIMATE)^TS|
		|11779-6^DELIVERY DATE (ESTIMATED FROM LAST MENSTRUAL PERIOD)^TS|
		|11780-4^DELIVERY DATE (ESTIMATED FROM OVULATION DATE)^TS|
		|11884-4^FETUS, GESTATIONAL AGE (CLINICAL ESTIMATE)^PQ|
		|11885-1^FETUS, GESTATIONAL AGE (ESTIMATED FROM LAST MENSTRUAL PERIOD)^PQ|
		|11886-9^FETUS, GESTATIONAL AGE (ESTIMATED FROM OVULATION DATE)^PQ|
		|11887-7^FETUS, GESTATIONAL AGE (ESTIMATED FROM SELECTED DELIVERY DATE)^PQ|
		|45371-2^MULTIPLE PREGNANCY^BL|
	</xsl:template>
		
	<xsl:template match="*" mode="templateIds-problemEntry">
		<xsl:if test="$hitsp-CDA-Condition"><templateId root="{$hitsp-CDA-Condition}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProblemAct"><templateId root="{$hl7-CCD-ProblemAct}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ConcernEntry"><templateId root="{$ihe-PCC-ConcernEntry}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ProblemConcernEntry"><templateId root="{$ihe-PCC-ProblemConcernEntry}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-problemEntry-pregnancy">
		<xsl:if test="$hitsp-CDA-Condition"><templateId root="{$hitsp-CDA-Condition}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProblemAct"><templateId root="{$hl7-CCD-ProblemAct}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-problemObservation">
		<xsl:if test="$hl7-CCD-ProblemObservation"><templateId root="{$hl7-CCD-ProblemObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ProblemEntry"><templateId root="{$ihe-PCC-ProblemEntry}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-pregnancyObservation">
		<xsl:if test="$hl7-CCD-ProblemObservation"><templateId root="{$hl7-CCD-ProblemObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SimpleObservations"><templateId root="{$ihe-PCC-SimpleObservations}"/></xsl:if>
		<xsl:if test="$ihe-PCC_CDASupplement-PregnancyObservation"><templateId root="{$ihe-PCC_CDASupplement-PregnancyObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-problemStatus">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProblemStatusObservation"><templateId root="{$hl7-CCD-ProblemStatusObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ProblemStatusObservation"><templateId root="{$ihe-PCC-ProblemStatusObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-causeOfDeath">
		<xsl:if test="$hl7-CCD-FamilyHistoryCauseOfDeathObservation"><templateId root="{$hl7-CCD-FamilyHistoryCauseOfDeathObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
