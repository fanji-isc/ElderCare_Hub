<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="FamilyHistory">
		<xsl:for-each select="hl7:organizer/hl7:component[not(hl7:observation/@negationInd='true')]">
			<FamilyHistory>				
				<!--
					Field : Family History Author
					Target: HS.SDA3.FamilyHistory EnteredBy
					Target: /Container/FamilyHistories/FamilyHistory/EnteredBy
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/author
					StructuredMappingRef: EnteredByDetail
				-->
				<xsl:apply-templates select="hl7:observation" mode="EnteredBy"/>
				
				<!--
					Field : Family History Information Source
					Target: HS.SDA3.FamilyHistory EnteredAt
					Target: /Container/FamilyHistories/FamilyHistory/EnteredAt
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/informant
					StructuredMappingRef: EnteredAt
				-->
				<xsl:apply-templates select="hl7:observation" mode="EnteredAt"/>
				
				<!--
					Field : Family History Author Time
					Target: HS.SDA3.FamilyHistory EnteredOn
					Target: /Container/FamilyHistories/FamilyHistory/EnteredOn
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/author/time/@value
				-->
				<xsl:apply-templates select="hl7:observation/hl7:author/hl7:time" mode="EnteredOn"/>
				
				<!--
					Field : Family History Id
					Target: HS.SDA3.FamilyHistory ExternalId
					Target: /Container/FamilyHistories/FamilyHistory/ExternalId
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/id
					StructuredMappingRef: ExternalId
				-->
				<xsl:apply-templates select="hl7:observation" mode="ExternalId"/>
				
				<!--
					Field : Family History Family Member Condition Start Date
					Target: HS.SDA3.FamilyHistory FromTime
					Target: /Container/FamilyHistories/FamilyHistory/FromTime
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/effectiveTime/low/@value
				-->
				<!--
					Field : Family History Family Member Condition End Date
					Target: HS.SDA3.FamilyHistory ToTime
					Target: /Container/FamilyHistories/FamilyHistory/ToTime
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/effectiveTime/high/@value
				-->
				<!--
					CDA FamilyHistory effectiveTime should have only
					a single value, but allow for low and high.
				-->
				<xsl:choose>
					<xsl:when test="hl7:observation/hl7:effectiveTime/@value">
						<xsl:apply-templates select="hl7:observation/hl7:effectiveTime" mode="FromTime"/>
						<xsl:apply-templates select="hl7:observation/hl7:effectiveTime" mode="ToTime"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="hl7:observation/hl7:effectiveTime/hl7:low" mode="FromTime"/>
						<xsl:apply-templates select="hl7:observation/hl7:effectiveTime/hl7:high" mode="ToTime"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Family History Family Member Relationship
					Target: HS.SDA3.FamilyHistory FamilyMember
					Target: /Container/FamilyHistories/FamilyHistory/FamilyMember
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/subject/relatedSubject/code
					StructuredMappingRef: CodeTableDetail
				-->
				<xsl:apply-templates select="../hl7:subject/hl7:relatedSubject[@classCode='PRS']/hl7:code" mode="CodeTable">
					<xsl:with-param name="hsElementName" select="'FamilyMember'"/>
				</xsl:apply-templates>
				
				<!--
					Field : Family History Family Member Condition
					Target: HS.SDA3.FamilyHistory Diagnosis
					Target: /Container/FamilyHistories/FamilyHistory/Diagnosis
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/value
					StructuredMappingRef: CodeTableDetail
				-->
				<xsl:apply-templates select="hl7:observation/hl7:value" mode="CodeTable">
					<xsl:with-param name="hsElementName" select="'Diagnosis'"/>
					<xsl:with-param name="importOriginalText" select="'1'"/>
				</xsl:apply-templates>

				<!--
					Field : Family History Family Member Problem Status
					Target: HS.SDA3.FamilyHistory Status
					Target: /Container/FamilyHistories/FamilyHistory/Status
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/entryRelationship/observation[code/@code='33999-4']/value/@code
					Note  : CDA Family Member Problem Status value/@code of
							55561003 is imported into SDA Status as "A".  All
							other values (including blank) are imported as "I".
				-->
				<Status>
					<xsl:variable name="familyHistoryStatus" select="hl7:observation/hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value/@code"/>
					<xsl:choose>
						<xsl:when test="$familyHistoryStatus = '55561003'"><xsl:text>A</xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>I</xsl:text></xsl:otherwise>
					</xsl:choose>
				</Status>
	 			
				<!--
					Field : Family History Comments
					Target: HS.SDA3.FamilyHistory NoteText
					Target: /Container/FamilyHistories/FamilyHistory/NoteText
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
				-->
				<xsl:apply-templates select="hl7:observation" mode="Comment">
					<xsl:with-param name="elementName" select="'NoteText'"/>
				</xsl:apply-templates>
				
				<!-- Custom SDA Data-->
				<xsl:apply-templates select="." mode="ImportCustom-FamilyHistory"/>
			</FamilyHistory>
		</xsl:for-each>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry.
	-->
	<xsl:template match="*" mode="ImportCustom-FamilyHistory">
	</xsl:template>
</xsl:stylesheet>
