<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc">
  <!-- AlsoInclude: AuthorParticipation.xsl Comment.xsl -->
  
	<!-- Global variables that configure how Problems are treated -->
	<xsl:variable name="currentConditionStatusCodes" select="$exportConfiguration/problems/currentCondition/codes/text()"/>
	<xsl:variable name="currentConditionWindowInDays" select="$exportConfiguration/problems/currentCondition/windowInDays/text()"/>
	<xsl:variable name="problemObservationId" select="$exportConfiguration/problems/observationId/text()"/>
	
	<xsl:template match="*" mode="eCn-conditions-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="useCurrentConditions" select="true()"/>
		<xsl:param name="docs"/>
		
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
					<xsl:apply-templates select="Problems/Problem" mode="eCn-conditions-NarrativeDetail">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
						<xsl:with-param name="useCurrentConditions" select="$useCurrentConditions"/>
					</xsl:apply-templates>
				</tbody>
			</table>

			<!-- structured narrative documents (History of past Illness only) -->
			<xsl:if test="$narrativeLinkCategory = 'pastIllness'">
				<xsl:apply-templates mode="narrative-export-documents" select=".">
					<xsl:with-param name="docs" select="$docs"/>
					<xsl:with-param name="header" select="$exportConfiguration/narrative/section[templateId/@root=$ccda-HistoryOfPastIllnessSection]/title/text()"/>
				</xsl:apply-templates>
			</xsl:if>

		</text>
	</xsl:template>

	<xsl:template match="Problem" mode="eCn-conditions-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="useCurrentConditions"/>

		<xsl:variable name="includeInExport">
			<xsl:apply-templates select="." mode="eCn-includeConditionInExport">
				<xsl:with-param name="useCurrentConditions" select="$useCurrentConditions"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>
			<xsl:variable name="prefixSet" select="$exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes"/>
			
			<tr ID="{concat($prefixSet/conditionNarrative/text(), $narrativeLinkSuffix)}">
				<td ID="{concat($prefixSet/conditionDisplayName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="Problem" mode="fn-descriptionOrCode"/></td>
				<td ID="{concat($prefixSet/conditionDescription/text(), $narrativeLinkSuffix)}"><xsl:value-of select="ProblemDetails/text()"/></td>
				<td><xsl:apply-templates select="Category" mode="fn-descriptionOrCode"/></td>
				<td ID="{concat($prefixSet/conditionStatus/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="Status" mode="fn-descriptionOrCode"/></td>
				<td><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="ToTime" mode="fn-narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="EnteredOn" mode="fn-narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="Clinician" mode="fn-name-Person-Narrative"/></td>
				<td ID="{concat($prefixSet/conditionComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="eCn-conditions-Entries">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="useCurrentConditions" select="true()"/>

		<xsl:apply-templates select="Problems/Problem" mode="eCn-conditions-EntryDetail">
			<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
			<xsl:with-param name="useCurrentConditions" select="$useCurrentConditions"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Problem" mode="eCn-conditions-EntryDetail">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="useCurrentConditions"/>

		<xsl:variable name="includeInExport">
			<xsl:apply-templates select="." mode="eCn-includeConditionInExport">
				<xsl:with-param name="useCurrentConditions" select="$useCurrentConditions"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<entry typeCode="DRIV">
				<act classCode="ACT" moodCode="EVN">
					<xsl:call-template name="eCn-templateIds-problemEntry"/>
					
					<xsl:apply-templates select="." mode="eCn-id-ProblemConcern"/>
					
					<code code="CONC" codeSystem="{$actClassOID}" codeSystemName="{$actClassName}" displayName="Concern"/>

					<xsl:apply-templates select="." mode="eCn-statusCode-Problem"/>
					<!--
						Field : Problem Clinician
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/performer
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/performer
						Source: HS.SDA3.Problem Clinician
						Source: /Container/Problems/Problem/Clinician
						StructuredMappingRef: performer
						Note  : Problem Clinician is exported to entry/act/performer,
								but import looks at both entry/act/performer and
								entry/act/entryRelationship/observation/performer.
								An SDA Problem is exported to the Problem List section
								when Problem Category/Code is not equal to 248536006
								or 373930000, and Problem Status is a current condition
								status code, and the Problem ToTime indicates no end
								date or the end date is not in the past longer than the
								current condition time window.
								An SDA Problem is exported to the History of Past
								Illness section when Problem Category/Code is not
								equal to 248536006 or 373930000, and Problem Status
								is not a current condition status code, or the Problem
								ToTime indicates and end date that is in the past
								longer than the current condition time window.
					-->
					<xsl:apply-templates select="Clinician" mode="fn-performer"/>
					
					<!--
						Field : Problem Author
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/author
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/author
						Source: HS.SDA3.Problem EnteredBy
						Source: /Container/Problems/Problem/EnteredBy
						StructuredMappingRef: author-Human
						Note  : An SDA Problem is exported to the Problem List section
								when Problem Category/Code is not equal to 248536006 or
								373930000, and Problem Status is a current condition
								status code, and the Problem ToTime indicates no end
								date or the end date is not in the past longer than the
								current condition time window.
								An SDA Problem is exported to the History of Past
								Illness section when Problem Category/Code is not
								equal to 248536006 or 373930000, and Problem Status
								is not a current condition status code, or the Problem
								ToTime indicates and end date that is in the past
								longer than the current condition time window.
					-->
					<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
					
					<!--
						Field : Problem Information Source
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/informant
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/informant
						Source: HS.SDA3.Problem EnteredAt
						Source: /Container/Problems/Problem/EnteredAt
						StructuredMappingRef: informant
						Note  : An SDA Problem is exported to the Problem List section
								when Problem Category/Code is not equal to 248536006 or
								373930000, and Problem Status is a current condition
								status code, and the Problem ToTime indicates no end
								date or the end date is not in the past longer than the
								current condition time window.
								An SDA Problem is exported to the History of Past
								Illness section when Problem Category/Code is not
								equal to 248536006 or 373930000, and Problem Status
								is not a current condition status code, or the Problem
								ToTime indicates and end date that is in the past
								longer than the current condition time window.
					-->
					<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
					
					<xsl:variable name="prefixSet" select="$exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes"/>

					<xsl:apply-templates select="." mode="eCn-observation-Problem">
						<xsl:with-param name="prefixSet" select="$prefixSet"/>
						<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
					</xsl:apply-templates>
					
					<!--
						Field : Problem Comments
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/act[code/@code='48767-8']/text
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/act[code/@code='48767-8']/text
						Source: HS.SDA3.Problem Comments
						Source: /Container/Problems/Problem/Comments
						Note  : An SDA Problem is exported to the Problem List section
								when Problem Category/Code is not equal to 248536006 or
								373930000, and Problem Status is a current condition
								status code, and the Problem ToTime indicates no end
								date or the end date is not in the past longer than the
								current condition time window.
								An SDA Problem is exported to the History of Past
								Illness section when Problem Category/Code is not
								equal to 248536006 or 373930000, and Problem Status
								is not a current condition status code, or the Problem
								ToTime indicates and end date that is in the past
								longer than the current condition time window.
					-->
					<xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
						<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionComments/text(), $narrativeLinkSuffix)"/>
					</xsl:apply-templates>
					
					<!--
						Field : Problem Encounter
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship
						Source: HS.SDA3.Problem EncounterNumber
						Source: /Container/Problems/Problem/EncounterNumber
						StructuredMappingRef: encounterLink-entryRelationship
						Note  : An SDA Problem is exported to the Problem List section
								when Problem Category/Code is not equal to 248536006 or
								373930000, and Problem Status is a current condition
								status code, and the Problem ToTime indicates no end
								date or the end date is not in the past longer than the
								current condition time window.
								An SDA Problem is exported to the History of Past
								Illness section when Problem Category/Code is not
								equal to 248536006 or 373930000, and Problem Status
								is not a current condition status code, or the Problem
								ToTime indicates and end date that is in the past
								longer than the current condition time window.
					-->
					<xsl:apply-templates select="." mode="fn-encounterLink-entryRelationship"/>
				</act>
			</entry>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="eCn-conditions-NoKnownProblemEntry">
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<xsl:call-template name="eCn-templateIds-problemEntry"/>
				
				<xsl:apply-templates select="." mode="eCn-id-ProblemConcern"/>
				
				<code code="CONC" codeSystem="{$actClassOID}" codeSystemName="{$actClassName}" displayName="Concern"/>

				<xsl:apply-templates select="." mode="eCn-statusCode-Problem"/>

				<xsl:apply-templates select="." mode="eCn-observation-NoKnownProblem"/>
			</act>
		</entry>
	</xsl:template>	

<!-- 	<xsl:template match="*" mode="eCn-problems-NoData">
		<text><xsl:value-of select="$exportConfiguration/problems/emptySection/narrativeText/text()"/></text>
	</xsl:template> -->

	<xsl:template match="*" mode="eCn-problems-NoKnownProblem">
		<!--For expressing No Known Problems, both a text and an entry of Problem Concern Act are needed-->
		<text><xsl:value-of select="$exportConfiguration/problems/emptySection/narrativeText/text()"/></text>
		<xsl:apply-templates select="." mode="eCn-conditions-NoKnownProblemEntry"/>
	</xsl:template>	
	
	<xsl:template match="*" mode="eCn-pastIllness-NoData">
		<text><xsl:value-of select="$exportConfiguration/pastIllness/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="eCn-admissionDiagnoses-NoData">
		<text><xsl:value-of select="$exportConfiguration/admissionDiagnoses/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="eCn-dischargeDiagnoses-NoData">
		<text><xsl:value-of select="$exportConfiguration/dischargeDiagnoses/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="eCn-diagnoses-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="diagnosisTypeCodes"/><!-- This was previously uppercased -->
		
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
					<xsl:apply-templates select="Diagnoses/Diagnosis[contains($diagnosisTypeCodes, concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|'))]" mode="eCn-diagnoses-NarrativeDetail">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="Diagnosis" mode="eCn-diagnoses-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory"/>
			
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		<xsl:variable name="prefixSet" select="$exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes"/>		
		
		<tr ID="{concat($prefixSet/diagnosisNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($prefixSet/diagnosisDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="Diagnosis" mode="fn-originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($prefixSet/diagnosisStatus/text(), $narrativeLinkSuffix)}">
				<xsl:choose>
					<xsl:when test="Status/Code/text() = 'A'">Active</xsl:when>
					<xsl:when test="Status/Code/text() = 'I'">Inactive</xsl:when>
					<xsl:otherwise>Unknown</xsl:otherwise>
				</xsl:choose>
			</td>
			<td><xsl:apply-templates select="IdentificationTime" mode="fn-narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="DiagnosingClinician" mode="fn-name-Person-Narrative"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="eCn-diagnoses-Entries">
		<xsl:param name="narrativeLinkCategory"/>			
		<xsl:param name="diagnosisTypeCodes"/><!-- This was previously uppercased -->
		
		<xsl:apply-templates select="Diagnoses/Diagnosis[contains($diagnosisTypeCodes, concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|'))]" mode="eCn-diagnoses-EntryDetail">
			<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Diagnosis" mode="eCn-diagnoses-EntryDetail">
		<xsl:param name="narrativeLinkCategory"/>
			
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<xsl:choose>
					<xsl:when test="$narrativeLinkCategory='admissionDiagnoses'">
						<xsl:call-template name="eCn-templateIds-hospitalAdmissionDiagnosis"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="eCn-templateIds-hospitalDischargeDiagnosis"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Diagnosis Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/id
					Source: HS.SDA3.Diagnosis ExternalId
					Source: /Container/Diagnoses/Diagnosis/ExternalId
					StructuredMappingRef: id-External
					Note  : An SDA Diagnosis is exported to the Hospital Admission
							Diagnosis section when DiagnosisType/Code is one of the
							admission diagnosis codes defined in ExportProfile.xml.
							An SDA Diagnosis is exported to the Hospital Discharge
							Diagnosis section when DiagnosisType/Code is one of the
							discharge diagnosis codes defined in ExportProfile.xml.
				-->
				<xsl:apply-templates select="." mode="fn-id-External"/>

				<xsl:choose>
					<xsl:when test="$narrativeLinkCategory='admissionDiagnoses'">
						<code code="46241-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Hospital Admission Diagnosis"/>
					</xsl:when>
					<xsl:otherwise>
						<code code="11535-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Hospital Discharge Diagnosis"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates select="." mode="eCn-statusCode-Diagnosis"/>
				
				<!--
					Field : Diagnosis Treating Provider
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/performer
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/performer
					Source: HS.SDA3.Diagnosis DiagnosingClinician
					Source: /Container/Diagnoses/Diagnosis/DiagnosingClinician
					StructuredMappingRef: performer
					Note  : SDA DiagnosingClinician is exported to entry/act/performer,
							but import looks for DiagnosingClinician in entry/act/performer and
							entry/act/entryRelationship/observation/performer when importing
							CDA to SDA.
							An SDA Diagnosis is exported to the Hospital Admission
							Diagnosis section when DiagnosisType/Code is one of the
							admission diagnosis codes defined in ExportProfile.xml.
							An SDA Diagnosis is exported to the Hospital Discharge
							Diagnosis section when DiagnosisType/Code is one of the
							discharge diagnosis codes defined in ExportProfile.xml.
				-->
				<xsl:apply-templates select="DiagnosingClinician" mode="fn-performer"/>
				
				<!--
					Field : Diagnosis Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/author
					Source: HS.SDA3.Diagnosis EnteredBy
					Source: /Container/Diagnoses/Diagnosis/EnteredBy
					StructuredMappingRef: author-Human
					Note  : An SDA Diagnosis is exported to the Hospital Admission
							Diagnosis section when DiagnosisType/Code is one of the
							admission diagnosis codes defined in ExportProfile.xml.
							An SDA Diagnosis is exported to the Hospital Discharge
							Diagnosis section when DiagnosisType/Code is one of the
							discharge diagnosis codes defined in ExportProfile.xml.
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				
				<!--
					Field : Diagnosis Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/informant
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/informant
					Source: HS.SDA3.Diagnosis EnteredAt
					Source: /Container/Diagnoses/Diagnosis/EnteredAt
					StructuredMappingRef: informant
					Note  : An SDA Diagnosis is exported to the Hospital Admission
							Diagnosis section when DiagnosisType/Code is one of the
							admission diagnosis codes defined in ExportProfile.xml.
							An SDA Diagnosis is exported to the Hospital Discharge
							Diagnosis section when DiagnosisType/Code is one of the
							discharge diagnosis codes defined in ExportProfile.xml.
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<xsl:apply-templates select="." mode="eCn-observation-Diagnosis">
					<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
				
				<!--
					Field : Diagnosis Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/entryRelationship
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/entryRelationship
					Source: HS.SDA3.Diagnosis EncounterNumber
					Source: /Container/Diagnoses/Diagnosis/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : An SDA Diagnosis is exported to the Hospital Admission
							Diagnosis section when DiagnosisType/Code is one of the
							admission diagnosis codes defined in ExportProfile.xml.
							An SDA Diagnosis is exported to the Hospital Discharge
							Diagnosis section when DiagnosisType/Code is one of the
							discharge diagnosis codes defined in ExportProfile.xml.
				-->
				<xsl:apply-templates select="." mode="fn-encounterLink-entryRelationship"/>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="Problem" mode="eCn-observation-Problem">
		<xsl:param name="prefixSet"/>
		<xsl:param name="narrativeLinkSuffix"/>
		<xsl:param name="entryRelationshipType" select="'SUBJ'"/>
				
		<entryRelationship typeCode="{$entryRelationshipType}" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eCn-templateIds-problemObservation"/>
				
				<xsl:apply-templates select="." mode="eCn-id-ProblemObservation"/>
				
				<!--
					Field : Problem Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/code
					Source: HS.SDA3.Problem Category
					Source: /Container/Problems/Problem/Category
					StructuredMappingRef: problem-ProblemType
					Note  : An SDA Problem is exported to the Problem List section
							when Problem Category/Code is not equal to 248536006 or
							373930000, and Problem Status is a current condition
							status code, and the Problem ToTime indicates no end
							date or the end date is not in the past longer than the
							current condition time window.
							An SDA Problem is exported to the History of Past
							Illness section when Problem Category/Code is not
							equal to 248536006 or 373930000, and Problem Status
							is not a current condition status code, or the Problem
							ToTime indicates and end date that is in the past
							longer than the current condition time window.
				-->
				<xsl:choose>
					<xsl:when test="Category">
						<xsl:apply-templates select="Category" mode="fn-problem-ProblemType"/>
					</xsl:when>
					<xsl:otherwise><code nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Problem Name
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/text
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/text
					Source: HS.SDA3.Problem ProblemDetails
					Source: /Container/Problems/Problem/ProblemDetails
					Note  : An SDA Problem is exported to the Problem List section
							when Problem Category/Code is not equal to 248536006 or
							373930000, and Problem Status is a current condition
							status code, and the Problem ToTime indicates no end
							date or the end date is not in the past longer than the
							current condition time window.
							An SDA Problem is exported to the History of Past
							Illness section when Problem Category/Code is not
							equal to 248536006 or 373930000, and Problem Status
							is not a current condition status code, or the Problem
							ToTime indicates and end date that is in the past
							longer than the current condition time window.
				-->
				<xsl:if test="$prefixSet/conditionDescription/text()">
					<text><reference value="{concat('#', $prefixSet/conditionDescription/text(), $narrativeLinkSuffix)}"/></text>
				</xsl:if>
				<statusCode code="completed"/>

				<!--
					Field : Problem Start Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/effectiveTime/low/@value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/effectiveTime/low/@value
					Source: HS.SDA3.Problem FromTime
					Source: /Container/Problems/Problem/FromTime
					Note  : An SDA Problem is exported to the Problem List section
							when Problem Category/Code is not equal to 248536006 or
							373930000, and Problem Status is a current condition
							status code, and the Problem ToTime indicates no end
							date or the end date is not in the past longer than the
							current condition time window.
							An SDA Problem is exported to the History of Past
							Illness section when Problem Category/Code is not
							equal to 248536006 or 373930000, and Problem Status
							is not a current condition status code, or the Problem
							ToTime indicates and end date that is in the past
							longer than the current condition time window.
				-->
				<!--
					Field : Problem End Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/effectiveTime/high/@value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/effectiveTime/high/@value
					Source: HS.SDA3.Problem ToTime
					Source: /Container/Problems/Problem/ToTime
					Note  : An SDA Problem is exported to the Problem List section
							when Problem Category/Code is not equal to 248536006 or
							373930000, and Problem Status is a current condition
							status code, and the Problem ToTime indicates no end
							date or the end date is not in the past longer than the
							current condition time window.
							An SDA Problem is exported to the History of Past
							Illness section when Problem Category/Code is not
							equal to 248536006 or 373930000, and Problem Status
							is not a current condition status code, or the Problem
							ToTime indicates and end date that is in the past
							longer than the current condition time window.
				-->
				<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="fn-snomed-Status-Code"/></xsl:variable>
				<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo">
					 <xsl:with-param name="includeHighTime" select="boolean(ToTime) or not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/>
				</xsl:apply-templates>
				
				<!--
					Field : Problem Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/value
					Source: HS.SDA3.Problem Problem
					Source: /Container/Problems/Problem/Problem
					StructuredMappingRef: value-Coded
					Note  : An SDA Problem is exported to the Problem List section
							when Problem Category/Code is not equal to 248536006 or
							373930000, and Problem Status is a current condition
							status code, and the Problem ToTime indicates no end
							date or the end date is not in the past longer than the
							current condition time window.
							An SDA Problem is exported to the History of Past Illness
							section when Problem Category/Code is not equal to 248536006
							or 373930000, and Problem Status is not a current condition
							status code, or the Problem ToTime indicates and end date
							that is in the past longer than the current condition time
							window.
				-->
				<xsl:apply-templates select="Problem" mode="fn-value-Coded">
					<xsl:with-param name="narrativeLink" select="substring(
						concat('#', $prefixSet/conditionDisplayName/text(), $narrativeLinkSuffix),
						1 div string-length($prefixSet/conditionDisplayName/text()))"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
					<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$snomedOID"/></xsl:with-param>
				</xsl:apply-templates>
				

				<!-- 
					The author is duplicated here to be more in line with the rev3 companion guide
					and for 2015 Cures Act validation while remaining backward compatabile.
				-->
				<!--
					Field : Problem Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/author
					Source: HS.SDA3.Problem EnteredBy
					Source: /Container/Problems/Problem/EnteredBy
					StructuredMappingRef: author-Human
					Note  : An SDA Problem is exported to the Problem List section
							when Problem Category/Code is not equal to 248536006 or
							373930000, and Problem Status is a current condition
							status code, and the Problem ToTime indicates no end
							date or the end date is not in the past longer than the
							current condition time window.
							An SDA Problem is exported to the History of Past
							Illness section when Problem Category/Code is not
							equal to 248536006 or 373930000, and Problem Status
							is not a current condition status code, or the Problem
							ToTime indicates and end date that is in the past
							longer than the current condition time window.
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>

				<!-- Problem Status -->
				<xsl:apply-templates select="Status" mode="eCn-observation-ProblemStatus">
					<xsl:with-param name="narrativeLink" select="substring(
						concat('#', $prefixSet/conditionStatus/text(), $narrativeLinkSuffix),
						1 div string-length($prefixSet/conditionStatus/text()))"/>
				</xsl:apply-templates>
			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="eCn-observation-NoKnownProblem">
		<!--
			No known problems entry-relationship
		-->
		<entryRelationship typeCode="SUBJ" >
			<!--
				No known problems entry-relationship
				The negationInd = true negates the observation/value
	            The use of negationInd corresponds with the newer Observation.valueNegationInd
			-->			
			<observation classCode="OBS" moodCode="EVN" negationInd="true">
				<xsl:call-template name="eCn-templateIds-problemObservation"/>
				
				<xsl:apply-templates select="." mode="eCn-id-ProblemObservation"/>

             	<code code="55607006" displayName="Problem" codeSystemName="SNOMED-CT" codeSystem="2.16.840.1.113883.6.96">
                	<translation code="75326-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Problem"/>
              	</code>					

				<statusCode code="completed"/>

 				<!-- N/A - author/time records when this assertion was made -->
                <effectiveTime>
                    <low nullFlavor="NA"/>
                </effectiveTime>

                <value xsi:type="CD" code="55607006" displayName="Problem" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT">
                   <originalText></originalText>
                </value> 
				
			</observation>
		</entryRelationship>
	</xsl:template>	
	
	<xsl:template match="Diagnosis | Encounter | *" mode="eCn-observation-Diagnosis">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:variable name="prefixSet" select="$exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eCn-templateIds-problemObservation"/>
				
				<id nullFlavor="NI"/>
				
				<!-- Diagnosis Type -->
				<code code="282291009" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="Diagnosis">
					<translation code="29308-4" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Diagnosis"/>
				</code>
				<!--
					Field : Diagnosis Name
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/entryRelationship/observation/text
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/entryRelationship/observation/text
					Source: HS.SDA3.Diagnosis Diagnosis.Description
					Source: /Container/Diagnoses/Diagnosis/Diagnosis/Description
					Note  : For CDA export, text is only a reference to the narrative.
							The actual Diagnosis Name text appears only in the narrative.
							The CDA narrative uses the Diagnosis Description property.
							An SDA Diagnosis is exported to the Hospital Admission
							Diagnosis section when DiagnosisType/Code is one of the
							admission diagnosis codes defined in ExportProfile.xml.
				-->
				<text><reference value="{concat('#', $prefixSet/diagnosisDescription/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					Field : Diagnosis Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/entryRelationship/observation/effectiveTime/low/@value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/entryRelationship/observation/effectiveTime/low/@value
					Source: HS.SDA3.Diagnosis IdentificationTime
					Source: /Container/Diagnoses/Diagnosis/IdentificationTime
					Note  : An SDA Diagnosis is exported to the Hospital Admission
							Diagnosis section when DiagnosisType/Code is one of the
							admission diagnosis codes defined in ExportProfile.xml.
							An SDA Diagnosis is exported to the Hospital Discharge
							Diagnosis section when DiagnosisType/Code is one of the
							discharge diagnosis codes defined in ExportProfile.xml.
				-->
				<!--
					IHE mandates special handling of "aborted" and "completed" states when building <effectiveTime>:
					The <high> element shall be present for concerns in the completed or aborted state, and shall not be present otherwise.
				-->		
				<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="fn-snomed-Status-Code"/></xsl:variable>
				<xsl:apply-templates select="." mode="fn-effectiveTime-Identification">
					<xsl:with-param name="includeHighTime" select="not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/>
				</xsl:apply-templates>
				
				<!--
					Field : Diagnosis Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/entryRelationship/observation/value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/entryRelationship/observation/value
					Source: HS.SDA3.Diagnosis Diagnosis
					Source: /Container/Diagnoses/Diagnosis/Diagnosis
					StructuredMappingRef: value-Coded
					Note  : An SDA Diagnosis is exported to the Hospital Admission
							Diagnosis section when DiagnosisType/Code is one of the
							admission diagnosis codes defined in ExportProfile.xml.
							An SDA Diagnosis is exported to the Hospital Discharge
							Diagnosis section when DiagnosisType/Code is one of the
							discharge diagnosis codes defined in ExportProfile.xml.
				-->
				<xsl:apply-templates select="Diagnosis" mode="fn-value-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $prefixSet/diagnosisDescription/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
				</xsl:apply-templates>
				
				<!-- Diagnosis Status -->
				<!--
					Don't export Status for Encounter Diagnoses because it
					requires including a link to a Status value in the narrative,
					and there is no room for another narrative column for Status.
				-->
				<xsl:if test="not($narrativeLinkCategory='encounterDiagnoses')">
					<xsl:apply-templates select="Status" mode="eCn-observation-ProblemStatus">
						<xsl:with-param name="narrativeLink" select="concat('#', $prefixSet/diagnosisStatus/text(), $narrativeLinkSuffix)"/>
					</xsl:apply-templates>
				</xsl:if>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="Problem | *" mode="eCn-statusCode-Problem">
		<!--
			Field : Problem Status
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/statusCode/@code
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/statusCode/@code
			Source: HS.SDA3.Problem Status
			Source: /Container/Problems/Problem/Status
			Note  : An SDA Problem is exported to the Problem List section
					when Problem Category/Code is not equal to 248536006 or
					373930000, and Problem Status is a current condition
					status code, and the Problem ToTime indicates no end
					date or the end date is not in the past longer than the
					current condition time window.
					An SDA Problem is exported to the History of Past
					Illness section when Problem Category/Code is not
					equal to 248536006 or 373930000, and Problem Status
					is not a current condition status code, or the Problem
					ToTime indicates and end date that is in the past
					longer than the current condition time window.
		-->
		
		<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="fn-snomed-Status-Code"/></xsl:variable>
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
		<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo">
			<xsl:with-param name="includeHighTime" select="boolean(ToTime) or not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/> 
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Diagnosis" mode="eCn-statusCode-Diagnosis">
		<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="fn-snomed-Status-Code"/></xsl:variable>
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
		<xsl:apply-templates select="." mode="fn-effectiveTime-Identification">
			<xsl:with-param name="includeHighTime" select="not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Status | *" mode="eCn-observation-ProblemStatus">
		<xsl:param name="narrativeLink"/>
		
		<!--
			Field : Diagnosis Status
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.43']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.24']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
			Source: HS.SDA3.Diagnosis Status
			Source: /Container/Diagnoses/Diagnosis/Status
			StructuredMappingRef: snomed-Status
			Note  : An SDA Diagnosis is exported to the Hospital Admission
					Diagnosis section when DiagnosisType/Code is one of the
					admission diagnosis codes defined in ExportProfile.xml.
					An SDA Diagnosis is exported to the Hospital Discharge
					Diagnosis section when DiagnosisType/Code is one of the
					discharge diagnosis codes defined in ExportProfile.xml.
		-->
		<!--
			Field : Problem Status
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
			Source: HS.SDA3.Problem Status
			Source: /Container/Problems/Problem/Status
			StructuredMappingRef: snomed-Status
			Note  : An SDA Problem is exported to the Problem List section
					when Problem Category/Code is not equal to 248536006 or
					373930000, and Problem Status is a current condition
					status code, and the Problem ToTime indicates no end
					date or the end date is not in the past longer than the
					current condition time window.
					An SDA Problem is exported to the History of Past
					Illness section when Problem Category/Code is not
					equal to 248536006 or 373930000, and Problem Status
					is not a current condition status code, or the Problem
					ToTime indicates and end date that is in the past
					longer than the current condition time window.
		-->
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eCn-templateIds-problemStatus"/>
				
				<code code="33999-4" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Status"/>
				<text><reference value="{$narrativeLink}"/></text>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="." mode="fn-snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="Problem" mode="eCn-includeConditionInExport">
		<xsl:param name="useCurrentConditions"/>
		
		<!-- Should this condition be "promoted" to the active problem list? -->
		<xsl:variable name="isCurrentCondition"><xsl:apply-templates select="." mode="eCn-currentCondition"/></xsl:variable>

		<xsl:choose>
			<!-- Exclude Functional Status and Cognitive Status. -->
			<xsl:when test="Category/Code/text()='248536006' or Category/Code/text()='373930000'">0</xsl:when>
			<xsl:when test="($useCurrentConditions = true()) and ($isCurrentCondition = 1)">1</xsl:when>
			<xsl:when test="($useCurrentConditions = false()) and ($isCurrentCondition = 0)">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Problem | *" mode="eCn-id-ProblemConcern">
		<!--
			Field : Problem Id
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/id
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/id
			Source: HS.SDA3.Problem ExternalId
			Source: /Container/Problems/Problem/ExternalId
			StructuredMappingRef: id-External
			Note  : An SDA Problem is exported to the Problem List section
					when Problem Category/Code is not equal to 248536006 or
					373930000, and Problem Status is a current condition
					status code, and the Problem ToTime indicates no end
					date or the end date is not in the past longer than the
					current condition time window.
					An SDA Problem is exported to the History of Past Illness
					section when Problem Category/Code is not equal to 248536006
					or 373930000, and Problem Status is not a current condition
					status code, or the Problem ToTime indicates and end date
					that is in the past longer than the current condition time
					window.
		-->
		<xsl:apply-templates select="." mode="fn-id-External"/>
	</xsl:template>
	
	<xsl:template match="Problem | *" mode="eCn-id-ProblemObservation">
		<xsl:choose>
			<xsl:when test="$problemObservationId='0'"><id nullFlavor="NI"/></xsl:when>
			<!--
				Field : Problem Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/id
				Source: HS.SDA3.Problem ExternalId
				Source: /Container/Problems/Problem/ExternalId
				StructuredMappingRef: id-External
				Note  : An SDA Problem is exported to the Problem List section
						when Problem Category/Code is not equal to 248536006 or
						373930000, and Problem Status is a current condition
						status code, and the Problem ToTime indicates no end
						date or the end date is not in the past longer than the
						current condition time window.
						An SDA Problem is exported to the History of Past Illness
						section when Problem Category/Code is not equal to 248536006
						or 373930000, and Problem Status is not a current condition
						status code, or the Problem ToTime indicates and end date
						that is in the past longer than the current condition time
						window.
			-->
			<xsl:when test="$problemObservationId='1'"><xsl:apply-templates select="." mode="fn-id-External"/></xsl:when>
			<xsl:when test="$problemObservationId='2'"><id root="{isc:evaluate('createUUID')}"/></xsl:when>
			<xsl:otherwise><id nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
  <xsl:template match="*" mode="eCn-currentCondition">
    <xsl:choose>
      <xsl:when test="not(ToTime)">1</xsl:when>
      <xsl:when test="contains($currentConditionStatusCodes, concat('|', Status/Code/text(), '|'))">1</xsl:when>
      <xsl:when test="isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt;= $currentConditionWindowInDays">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eCn-templateIds-problemEntry">
		<templateId root="{$ccda-ProblemConcernAct}"/>
		<templateId root="{$ccda-ProblemConcernAct}" extension="2015-08-01"/>
	</xsl:template>

	<xsl:template name="eCn-templateIds-problemObservation">
		<templateId root="{$ccda-ProblemObservation}"/>
		<templateId root="{$ccda-ProblemObservation}" extension="2015-08-01"/>
	</xsl:template>

	<xsl:template name="eCn-templateIds-problemStatus">
		<templateId root="{$ccda-ProblemStatus}"/>
		<templateId root="{$ccda-ProblemStatus}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="eCn-templateIds-hospitalAdmissionDiagnosis">
		<templateId root="{$ccda-HospitalAdmissionDiagnosis}"/>
		<templateId root="{$ccda-HospitalAdmissionDiagnosis}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eCn-templateIds-hospitalDischargeDiagnosis">
		<templateId root="{$ccda-HospitalDischargeDiagnosis}"/>
		<templateId root="{$ccda-HospitalDischargeDiagnosis}" extension="2014-06-09"/>
	</xsl:template>
  
</xsl:stylesheet>