<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Problem Variables -->
	<xsl:variable name="currentConditionStatusCodes" select="$exportConfiguration/problems/currentCondition/codes/text()"/>
	<xsl:variable name="currentConditionWindowInDays" select="$exportConfiguration/problems/currentCondition/windowInDays/text()"/>
	<xsl:variable name="problemObservationId" select="$exportConfiguration/problems/observationId/text()"/>
	
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
				<td><xsl:apply-templates select="Category" mode="descriptionOrCode"/></td>
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
					<xsl:apply-templates select="." mode="templateIds-problemEntry"/>
					
					<xsl:apply-templates select="." mode="id-ProblemConcern"/>
					
					<code code="CONC" codeSystem="{$actClassOID}" codeSystemName="{$actClassName}" displayName="Concern"/>

					<xsl:apply-templates select="." mode="statusCode-Problem"/>
					
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
					<xsl:apply-templates select="Clinician" mode="performer"/>
					
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
					<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
					
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
					<xsl:apply-templates select="EnteredAt" mode="informant"/>
					
					<xsl:apply-templates select="." mode="observation-Problem">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
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
					<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
					
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
					<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
				</act>
			</entry>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="problems-NoData">
		<text><xsl:value-of select="$exportConfiguration/problems/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="pastIllness-NoData">
		<text><xsl:value-of select="$exportConfiguration/pastIllness/emptySection/narrativeText/text()"/></text>
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
				<xsl:choose>
					<xsl:when test="$narrativeLinkCategory='admissionDiagnoses'">
						<xsl:apply-templates select="." mode="templateIds-hospitalAdmissionDiagnosis"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="templateIds-hospitalDischargeDiagnosis"/>
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
				<xsl:apply-templates select="." mode="id-External"/>

				<xsl:choose>
					<xsl:when test="$narrativeLinkCategory='admissionDiagnoses'">
						<code code="46241-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Hospital Admission Diagnosis"/>
					</xsl:when>
					<xsl:otherwise>
						<code code="11535-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Hospital Discharge Diagnosis"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates select="." mode="statusCode-Diagnosis"/>
				
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
				<xsl:apply-templates select="DiagnosingClinician" mode="performer"/>
				
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
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
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
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<xsl:apply-templates select="." mode="observation-Diagnosis">
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
						<xsl:apply-templates select="Category" mode="problem-ProblemType"/>
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
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionDescription/text(), $narrativeLinkSuffix)}"/></text>
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
				<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="snomed-Status-Code"/></xsl:variable>
				<xsl:apply-templates select="." mode="effectiveTime-FromTo">
					<xsl:with-param name="includeHighTime" select="not(contains($currentConditionStatusCodes, concat('|', $snomedStatusCode, '|')))"/>
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
	
	<xsl:template match="*" mode="observation-Diagnosis">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-problemObservation"/>
				
				<id nullFlavor="NI"/>
				
				<!-- Diagnosis Type -->
				<code code="282291009" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="Diagnosis"/>
				
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
							For CDA export, text is only a reference to the narrative.
							The actual Diagnosis Name text appears only in the narrative.
							The CDA narrative uses the Diagnosis Description property.
							An SDA Diagnosis is exported to the Hospital Discharge
							Diagnosis section when DiagnosisType/Code is one of the
							discharge diagnosis codes defined in ExportProfile.xml.
				-->
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisDescription/text(), $narrativeLinkSuffix)}"/></text>
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
				<xsl:variable name="snomedStatusCode"><xsl:apply-templates select="Status" mode="snomed-Status-Code"/></xsl:variable>
				<xsl:apply-templates select="." mode="effectiveTime-Identification">
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
				<xsl:apply-templates select="Diagnosis" mode="value-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisDescription/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="xsiType">CD</xsl:with-param>
				</xsl:apply-templates>
				
				<!-- Diagnosis Status -->
				<!--
					Don't export Status for Encounter Diagnoses because it
					requires including a link to a Status value in the narrative,
					and there is no room for another narrative column for Status.
				-->
				<xsl:if test="not($narrativeLinkCategory='encounterDiagnoses')">
					<xsl:apply-templates select="Status" mode="observation-ProblemStatus"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/diagnosisStatus/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				</xsl:if>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="statusCode-Problem">
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
			<!-- Exclude Functional Status and Cognitive Status. -->
			<xsl:when test="Category/Code/text()='248536006' or Category/Code/text()='373930000'">0</xsl:when>
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
		<xsl:apply-templates select="." mode="id-External"/>
	</xsl:template>
	
	<xsl:template match="Problem" mode="id-ProblemObservation">
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
			<xsl:when test="$problemObservationId='1'"><xsl:apply-templates select="." mode="id-External"/></xsl:when>
			<xsl:when test="$problemObservationId='2'"><id root="{isc:evaluate('createUUID')}"/></xsl:when>
			<xsl:otherwise><id nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-problemEntry">
		<templateId root="{$ccda-ProblemConcernAct}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-problemObservation">
		<templateId root="{$ccda-ProblemObservation}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-problemStatus">
		<templateId root="{$ccda-ProblemStatus}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-hospitalAdmissionDiagnosis">
		<templateId root="{$ccda-HospitalAdmissionDiagnosis}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-hospitalDischargeDiagnosis">
		<templateId root="{$ccda-HospitalDischargeDiagnosis}"/>
	</xsl:template>
</xsl:stylesheet>
