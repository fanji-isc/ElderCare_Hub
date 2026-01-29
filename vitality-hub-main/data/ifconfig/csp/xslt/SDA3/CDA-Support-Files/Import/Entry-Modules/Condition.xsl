<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Condition">
		<Problem>
			<!--
				Field : Problem Encounter
				Target: HS.SDA3.Problem EncounterNumber
				Target: /Container/Problems/Problem/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/encounter/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Problem and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>

			<!--
				Field : Problem Author
				Target: HS.SDA3.Problem EnteredBy
				Target: /Container/Problems/Problem/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!--
				Field : Problem Information Source
				Target: HS.SDA3.Problem EnteredAt
				Target: /Container/Problems/Problem/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!--
				Field : Problem Author Time
				Target: HS.SDA3.Problem EnteredOn
				Target: /Container/Problems/Problem/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/author/time/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!--
				Field : Problem Concern Act Id
				Target: HS.SDA3.Problem ExternalId
				Target: /Container/Problems/Problem/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!--
				Field : Problem Start Date/Time
				Target: HS.SDA3.Problem FromTime
				Target: /Container/Problems/Problem/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/observation/effectiveTime/low/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/observation/effectiveTime/low/@value
			-->
			<!--
				Field : Problem End Date/Time
				Target: HS.SDA3.Problem ToTime
				Target: /Container/Problems/Problem/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/observation/effectiveTime/high/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/observation/effectiveTime/high/@value
			-->
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:effectiveTime/hl7:low" mode="FromTime"/>
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:effectiveTime/hl7:high" mode="ToTime"/>

			<!-- Problem Details -->
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:text" mode="ProblemDetails"/>
			
			<!--
				Field : Problem Code
				Target: HS.SDA3.Problem Problem
				Target: /Container/Problems/Problem/Problem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/observation/value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/observation/value
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:value" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Problem'"/>
			</xsl:apply-templates>

			<!--
				Field : Problem Type
				Target: HS.SDA3.Problem Category
				Target: /Container/Problems/Problem/Category
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/observation/code
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/observation/code
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Category'"/>
			</xsl:apply-templates>

			<!--
				Field : Problem Treating Provider
				Target: HS.SDA3.Problem Clinician
				Target: /Container/Problems/Problem/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/performer
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/performer
				StructuredMappingRef: Clinician
				Note  : Import gets SDA Clincian from either entry/act/performer
						or entry/act/entryRelationship/observation/performer.
						A CDA Problem entry will have either one or the other.
			-->
			<!--
				Field : Problem Treating Provider
				Target: HS.SDA3.Problem Clinician
				Target: /Container/Problems/Problem/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/observation/performer
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/observation/performer
				StructuredMappingRef: Clinician
				Note  : Import gets SDA Clincian from either entry/act/performer
						or entry/act/entryRelationship/observation/performer.
						A CDA Problem entry will have either one or the other.
			-->
			<xsl:apply-templates select="hl7:performer | hl7:entryRelationship/hl7:observation/hl7:performer" mode="Clinician"/>
			
			<!--
				Field : Problem Status
				Target: HS.SDA3.Problem Status
				Target: /Container/Problems/Problem/Status
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Status'"/>
			</xsl:apply-templates>

			<!--
				Field : Problem Comments
				Target: HS.SDA3.Problem Comments
				Target: /Container/Problems/Problem/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/act[code/@code='48767-8']/text
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Problem"/>
		</Problem>
	</xsl:template>

	<xsl:template match="*" mode="Diagnosis">
		<xsl:param name="diagnosisType"/>
		<xsl:param name="encounterID" select="''"/>

		<Diagnosis>
			<!--
				Field : Diagnosis Encounter
				Target: HS.SDA3.Diagnosis EncounterNumber
				Target: /Container/Diagnoses/Diagnosis/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/encounter/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/encounter/id
				Note  : If there is no encounter link on the CDA Diagnosis and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber>
				<xsl:choose>
					<xsl:when test="not(string-length($encounterID))"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$encounterID"/></xsl:otherwise>
				</xsl:choose>
			</EncounterNumber>

			<!--
				Field : Diagnosis Author (observation)
				Target: HS.SDA3.Diagnosis EnteredBy
				Target: /Container/Diagnoses/Diagnosis/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/observation/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/observation/author
				StructuredMappingRef: EnteredByDetail
				Note  : CDA author information for the Diagnosis may be located at the observation
				        level (for specific observations) or at the act level (to apply it to all
				        observations that do not have their own author data). As with all other
				        EnteredBy use of author in the CDA document, if author is not found at
				        either level then document-level author person is used.
			-->
			<!--
				Field : Diagnosis Author (act)
				Target: HS.SDA3.Diagnosis EnteredBy
				Target: /Container/Diagnoses/Diagnosis/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/author
				StructuredMappingRef: EnteredByDetail
				Note  : CDA author information for the Diagnosis may be located at the observation
				        level (for specific observations) or at the act level (to apply it to all
				        observations that do not have their own author data). As with all other
				        EnteredBy use of author in the CDA document, if author is not found at
				        either level then document-level author person is used.
			-->
			<xsl:choose>
				<xsl:when test="hl7:observation/hl7:author">
					<xsl:apply-templates select="hl7:observation" mode="EnteredBy"/>
				</xsl:when>
				<xsl:when test="name(parent::node())='act' and ../hl7:author">
					<xsl:apply-templates select=".." mode="EnteredBy"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:observation" mode="EnteredBy"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Diagnosis Information Source (observation)
				Target: HS.SDA3.Diagnosis EnteredAt
				Target: /Container/Diagnoses/Diagnosis/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/observation/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/observation/informant
				StructuredMappingRef: EnteredAt
				Note  : CDA informant information for the Diagnosis may be located at the observation
				        level (for specific observations) or at the act level (to apply it to all
				        observations that do not have their own informant data). As with all other
				        EnteredAt use of informant in the CDA document, if informant is not found at
				        either level then document-level informant is used.
			-->
			<!--
				Field : Diagnosis Information Source (act)
				Target: HS.SDA3.Diagnosis EnteredAt
				Target: /Container/Diagnoses/Diagnosis/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/informant
				StructuredMappingRef: EnteredAt
				Note  : CDA informant information for the Diagnosis may be located at the observation
				        level (for specific observations) or at the act level (to apply it to all
				        observations that do not have their own informant data). As with all other
				        EnteredAt use of informant in the CDA document, if informant is not found at
				        either level then document-level informant is used.
			-->
			<xsl:choose>
				<xsl:when test="hl7:observation/hl7:informant">
					<xsl:apply-templates select="hl7:observation" mode="EnteredAt"/>
				</xsl:when>
				<xsl:when test="name(parent::node())='act' and ../hl7:informant">
					<xsl:apply-templates select=".." mode="EnteredAt"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:observation" mode="EnteredAt"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Diagnosis Author Time (observation)
				Target: HS.SDA3.Diagnosis EnteredOn
				Target: /Container/Diagnoses/Diagnosis/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/observation/author/time/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/observation/author/time/@value
				Note  : CDA author information for the Diagnosis may be located at the observation
				        level (for specific observations) or at the act level (to apply it to all
				        observations that do not have their own author data). As with all other
				        EnteredOn use of author in the CDA document, if author is not found at
				        either level then document-level author is used.
			-->
			<!--
				Field : Diagnosis Author Time (act)
				Target: HS.SDA3.Diagnosis EnteredOn
				Target: /Container/Diagnoses/Diagnosis/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/author/time/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/author/time/@value
				Note  : CDA author information for the Diagnosis may be located at the observation
				        level (for specific observations) or at the act level (to apply it to all
				        observations that do not have their own author data). As with all other
				        EnteredOn use of author in the CDA document, if author is not found at
				        either level then document-level author is used.
			-->
			<!-- HS.SDA3.Diagnosis EnteredOn -->
			<xsl:choose>
				<xsl:when test="hl7:observation/hl7:author">
					<xsl:apply-templates select="hl7:observation/hl7:author/hl7:time" mode="EnteredOn"/>
				</xsl:when>
				<xsl:when test="name(parent::node())='act' and ../hl7:author">
					<xsl:apply-templates select="../hl7:author/hl7:time" mode="EnteredOn"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:observation/hl7:author/hl7:time" mode="EnteredOn"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Diagnosis Id
				Target: HS.SDA3.Diagnosis ExternalId
				Target: /Container/Diagnoses/Diagnosis/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/observation/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/observation/id
				StructuredMappingRef: ExternalId
			-->
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="hl7:observation" mode="ExternalId"/>
			
			<!--
				Field : Diagnosis Code
				Target: HS.SDA3.Diagnosis Diagnosis
				Target: /Container/Diagnoses/Diagnosis/Diagnosis
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/observation/value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/observation/value
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:observation/hl7:value" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Diagnosis'"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>

			<!--
				DiagnosisType is not imported from a specific CDA field.  It is
				determined by the CDA section that is currently being imported -
				either Hospital Admission Diagnosis (A|Admitting) or Discharge
				Diagnosis (D|Discharge).
			-->
			<xsl:if test="string-length($diagnosisType)">
				<DiagnosisType>
					<Code><xsl:value-of select="substring-before($diagnosisType, '|')"/></Code>
					<Description><xsl:value-of select="substring-after($diagnosisType, '|')"/></Description>
				</DiagnosisType>
			</xsl:if>
			
			<!--
				Field : Diagnosis Treating Provider
				Target: HS.SDA3.Diagnosis Clinician
				Target: /Container/Diagnoses/Diagnosis/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/performer
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/performer
				StructuredMappingRef: Clinician
				Note  : Import gets SDA Clincian from either entry/act/performer
						or entry/act/entryRelationship/observation/performer.
			-->
			<!--
				Field : Diagnosis Treating Provider
				Target: HS.SDA3.Diagnosis Clinician
				Target: /Container/Diagnoses/Diagnosis/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/observation/performer
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/observation/performer
				StructuredMappingRef: Clinician
				Note  : Import gets SDA Clincian from either entry/act/performer
						or entry/act/entryRelationship/observation/performer.
			-->
			<xsl:choose>
				<xsl:when test="../hl7:performer">
					<xsl:apply-templates select="../hl7:performer" mode="DiagnosingClinician"/>
				</xsl:when>
				<xsl:when test="hl7:observation/hl7:performer">
					<xsl:apply-templates select="hl7:observation/hl7:performer" mode="DiagnosingClinician"/>
				</xsl:when>
			</xsl:choose>
			
			<xsl:apply-templates select="hl7:observation/hl7:effectiveTime" mode="IdentificationTime"/>
			
			<!--
				Field : Diagnosis Status
				Target: HS.SDA3.Diagnosis Status
				Target: /Container/Diagnoses/Diagnosis/Status
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:observation/hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Status'"/>
			</xsl:apply-templates>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Diagnosis"/>
		</Diagnosis>
	</xsl:template>

	<xsl:template match="*" mode="IdentificationTime">
		<!--
			Field : Diagnosis Identification Date/Time
			Target: HS.SDA3.Diagnosis IdentificationTime
			Target: /Container/Diagnoses/Diagnosis/IdentificationTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.3']/entry/act/entryRelationship/observation/effectiveTime/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.7']/entry/act/entryRelationship/observation/effectiveTime/@value
			Note  : If CDA effectiveTime/@value is not present
					then SDA IdentificationTime is imported from
					effectiveTime/low/@value instead.
		-->
		<xsl:choose>
			<xsl:when test="@value"><IdentificationTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></IdentificationTime></xsl:when>
			<xsl:when test="hl7:low/@value"><IdentificationTime><xsl:value-of select="isc:evaluate('xmltimestamp', hl7:low/@value)"/></IdentificationTime></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="ProblemDetails">
		<!--
			Field : Problem Name
			Target: HS.SDA3.Problem ProblemDetails
			Target: /Container/Problems/Problem[not(Category/Code='248536006' or Category/Code='373930000')]/ProblemDetails
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.6']/entry/act/entryRelationship/observation/text
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.8']/entry/act/entryRelationship/observation/text
		-->
		<ProblemDetails><xsl:apply-templates select="." mode="TextValue"/></ProblemDetails>
	</xsl:template>
		
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-Problem">
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-Diagnosis">
	</xsl:template>
</xsl:stylesheet>
