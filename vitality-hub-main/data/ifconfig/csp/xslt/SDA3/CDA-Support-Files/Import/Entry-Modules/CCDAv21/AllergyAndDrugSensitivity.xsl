<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
	<!-- AlsoInclude: Comment.xsl -->
	
	<xsl:template match="hl7:act" mode="eADS-Allergy">
		<Allergy>
			<!-- Allergy and Allergy Category -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ']/hl7:observation" mode="eADS-AllergyAndCategory"/>

			<!--
				Field : Allergy Clinician
				Target: HS.SDA3.Allergy Clinician
				Target: /Container/Allergies/Allergy/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/performer
				StructuredMappingRef: Clinician
			-->
			<xsl:apply-templates select="hl7:performer" mode="fn-Clinician"/>
			
			<!-- Allergy Reaction -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ']/hl7:observation/hl7:entryRelationship[@typeCode='MFST']" mode="eADS-Reaction"/>

			<!-- Allergy Criticality -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ']/hl7:observation/hl7:entryRelationship/hl7:observation[hl7:templateId/@root=$ccda-CriticalityObservation]" mode="eADS-Criticality"/>

			<!-- Allergy Status -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ']/hl7:observation/hl7:entryRelationship/hl7:observation[hl7:templateId/@root=$ccda-AllergyStatusObservation]" mode="eADS-Status"/>

			<!--
				Field : Allergy Author
				Target: HS.SDA3.Allergy EnteredBy
				Target: /Container/Allergies/Allergy/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!--
				Field : Allergy Information Source
				Target: HS.SDA3.Allergy EnteredAt
				Target: /Container/Allergies/Allergy/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!--
				Field : Allergy Author Time
				Target: HS.SDA3.Allergy EnteredOn
				Target: /Container/Allergies/Allergy/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
			
			<!--
				Field : Adverse Event Start Date
				Target: HS.SDA3.Allergy FromTime
				Target: /Container/Allergies/Allergy/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/effectiveTime/low/@value
			-->
			<!--
				Field : Adverse Event End Date
				Target: HS.SDA3.Allergy ToTime
				Target: /Container/Allergies/Allergy/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/effectiveTime/high/@value
			-->
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>

			<!--
				Field : Allergy Id
				Target: HS.SDA3.Allergy ExternalId
				Target: /Container/Allergies/Allergy/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/id
				StructuredMappingRef: ExternalId
			-->
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
			
			<!--
				Field : Allergy Comments
				Target: HS.SDA3.Allergy Comments
				Target: /Container/Allergies/Allergy/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="eCm-Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eADS-ImportCustom-Allergy"/>
		</Allergy>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eADS-AllergyAndCategory">
		<!--
			Field : Allergy Product Coded
			Target: HS.SDA3.Allergy Allergy
			Target: /Container/Allergies/Allergy/Allergy
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/participant/participantRole/playingEntity/code
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:participant/hl7:participantRole/hl7:playingEntity/hl7:code" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'Allergy'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>		
		<!--
			Field : Adverse Event Type
			Target: HS.SDA3.Allergy AllergyCategory
			Target: /Container/Allergies/Allergy/AllergyCategory
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/code
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'AllergyCategory'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:entryRelationship" mode="eADS-Reaction">
		<!-- The mode formerly known as AllergyReaction -->
		<!--
			Field : Allergy Reaction Coded
			Target: HS.SDA3.Allergy Reaction
			Target: /Container/Allergies/Allergy/Reaction
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='MFST']/observation/value
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:choose>
			<xsl:when test="hl7:observation/hl7:value/@code or hl7:observation/hl7:value/hl7:translation/@code">
				<xsl:apply-templates select="hl7:observation/hl7:value" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'Reaction'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="hl7:observation/hl7:text" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'Reaction'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		<!-- Allergy Severity -->
		<xsl:apply-templates select="hl7:observation/hl7:entryRelationship/hl7:observation[hl7:templateId/@root=$ccda-SeverityObservation]" mode="eADS-Severity"/>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eADS-Severity">
		<!-- The mode formerly known as AllergySeverity -->
		<!--
			Field : Allergy Severity Coded
			Target: HS.SDA3.Allergy Severity
			Target: /Container/Allergies/Allergy/Severity
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='SEV']/value
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:choose>
			<xsl:when test="hl7:value/@code or hl7:value/hl7:translation/@code">
				<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'Severity'"/>
					<xsl:with-param name="importOriginalText" select="'1'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="hl7:text" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'Severity'"/>
					<xsl:with-param name="importOriginalText" select="'1'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:observation" mode="eADS-Criticality">
		<!--
			Field : Allergy Criticality Coded
			Target: HS.SDA3.Allergy Criticality
			Target: /Container/Allergies/Allergy/Criticality
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation[templateId/@root='2.16.840.1.113883.10.20.22.4.7']/entryRelationship/observation[templateId/@root='2.16.840.1.113883.10.20.22.4.145']/value
		-->
		<Criticality>
			<Code>
				<xsl:choose>
					<xsl:when test="hl7:value/@code = 'CRITH'">H</xsl:when>
					<xsl:when test="hl7:value/@code = 'CRITL'">L</xsl:when>
					<xsl:otherwise>U</xsl:otherwise>
				</xsl:choose>
			</Code>
			<Description>
				<xsl:choose>
					<xsl:when test="hl7:value/@code = 'CRITH'">high criticality</xsl:when>
					<xsl:when test="hl7:value/@code = 'CRITL'">low criticality</xsl:when>
					<xsl:otherwise>unable to assess criticality</xsl:otherwise>
				</xsl:choose>
			</Description>
		</Criticality>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eADS-Status">
		<!-- The mode formerly known as AllergyStatus -->
		<!--
			Field : Allergy Status
			Target: HS.SDA3.Allergy Status
			Target: /Container/Allergies/Allergy/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value
		-->
		<Status>
			<xsl:choose>
				<xsl:when test="hl7:value/@code = '55561003'">A</xsl:when>
				<xsl:otherwise>I</xsl:otherwise>
			</xsl:choose>
		</Status>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="eADS-ImportCustom-Allergy">
	</xsl:template>
	
</xsl:stylesheet>