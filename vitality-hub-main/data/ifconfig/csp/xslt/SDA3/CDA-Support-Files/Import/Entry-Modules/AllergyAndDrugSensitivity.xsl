<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Allergy">
		<Allergy>
			<!--
				Field : Allergy Author
				Target: HS.SDA3.Allergy EnteredBy
				Target: /Container/Allergies/Allergy/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!--
				Field : Allergy Information Source
				Target: HS.SDA3.Allergy EnteredAt
				Target: /Container/Allergies/Allergy/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!--
				Field : Allergy Author Time
				Target: HS.SDA3.Allergy EnteredOn
				Target: /Container/Allergies/Allergy/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!--
				Field : Allergy Id
				Target: HS.SDA3.Allergy ExternalId
				Target: /Container/Allergies/Allergy/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/id
				StructuredMappingRef: ExternalId
			-->
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
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
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:effectiveTime/hl7:low" mode="FromTime"/>
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:effectiveTime/hl7:high" mode="ToTime"/>

			<!-- Allergy and Allergy Category -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ']/hl7:observation" mode="AllergyAndCategory"/>

			<!--
				Field : Allergy Clinician
				Target: HS.SDA3.Allergy Clinician
				Target: /Container/Allergies/Allergy/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/performer
				StructuredMappingRef: Clinician
			-->
			<xsl:apply-templates select="hl7:performer" mode="Clinician"/>
			
			<!-- Allergy Reaction -->
			<xsl:apply-templates select = "." mode = "AllergyReaction"/>

			<!-- Allergy Severity -->
			<xsl:apply-templates select = "." mode = "AllergySeverity"/>

			<!-- Allergy Status -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ']/hl7:observation/hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value" mode="AllergyStatus"/>

			<!--
				Field : Allergy Comments
				Target: HS.SDA3.Allergy Comments
				Target: /Container/Allergies/Allergy/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Allergy"/>
		</Allergy>
	</xsl:template>
	
	<xsl:template match="*" mode="AllergyAndCategory">
		<!--
			Field : Allergy Product Coded
			Target: HS.SDA3.Allergy Allergy
			Target: /Container/Allergies/Allergy/Allergy
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/participant/participantRole/playingEntity/code
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:participant/hl7:participantRole/hl7:playingEntity/hl7:code" mode="CodeTable">
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
		<xsl:apply-templates select="hl7:code" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'AllergyCategory'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="AllergyStatus">
		<!--
			Field : Allergy Status
			Target: HS.SDA3.Allergy Status
			Target: /Container/Allergies/Allergy/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='33999-4']/value/@code
		-->
		<Status>
			<xsl:choose>
				<xsl:when test="@code = '55561003'">A</xsl:when>
				<xsl:otherwise>I</xsl:otherwise>
			</xsl:choose>
		</Status>
	</xsl:template>
	
	<xsl:template match="*" mode="AllergyReaction">
		<!--
			Field : Allergy Reaction Coded
			Target: HS.SDA3.Allergy Reaction
			Target: /Container/Allergies/Allergy/Reaction
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='MFST']/observation/value
			StructuredMappingRef: CodeTableDetail
		-->
  		<xsl:choose>
    		<xsl:when test="(.//hl7:observation[hl7:templateId/@root=$hl7-CCD-ReactionObservation]/hl7:value/@code) or (.//hl7:observation[hl7:templateId/@root=$hl7-CCD-ReactionObservation]/hl7:value/hl7:translation/@code)">
      			<xsl:apply-templates select=".//hl7:observation[hl7:templateId/@root=$hl7-CCD-ReactionObservation]/hl7:value" mode="CodeTable">
       			 	<xsl:with-param name="hsElementName" select="'Reaction'"/>
     			 </xsl:apply-templates>
    		</xsl:when>
    		<xsl:otherwise>
      			<xsl:apply-templates select=".//hl7:observation[hl7:templateId/@root=$hl7-CCD-ReactionObservation]/hl7:text" mode="CodeTable">
        			<xsl:with-param name="hsElementName" select="'Reaction'"/>
      			</xsl:apply-templates>
    		</xsl:otherwise>
  		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="AllergySeverity">
		<!--
			Field : Allergy Severity Coded
			Target: HS.SDA3.Allergy Severity
			Target: /Container/Allergies/Allergy/Severity
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.6.1']/entry/act/entryRelationship/observation/entryRelationship/observation[code/@code='SEV']/value
			StructuredMappingRef: CodeTableDetail
		-->
  		<xsl:choose>
    		<xsl:when test="(.//hl7:observation[hl7:templateId/@root=$hl7-CCD-SeverityObservation]/hl7:value/@code) or (.//hl7:observation[hl7:templateId/@root=$hl7-CCD-SeverityObservation]/hl7:value/hl7:translation/@code)">
      			<xsl:apply-templates select=".//hl7:observation[hl7:templateId/@root=$hl7-CCD-SeverityObservation]/hl7:value" mode = "CodeTable">
        			<xsl:with-param name="hsElementName" select="'Severity'"/>
					<xsl:with-param name="importOriginalText" select="'1'"/>
      			</xsl:apply-templates>
    		</xsl:when>
   			 <xsl:otherwise>
      			<xsl:apply-templates select=".//hl7:observation[hl7:templateId/@root=$hl7-CCD-SeverityObservation]/hl7:text" mode = "CodeTable">
        			<xsl:with-param name="hsElementName" select="'Severity'"/>
 					<xsl:with-param name="importOriginalText" select="'1'"/>
 				</xsl:apply-templates>
    		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-Allergy">
	</xsl:template>
</xsl:stylesheet>
