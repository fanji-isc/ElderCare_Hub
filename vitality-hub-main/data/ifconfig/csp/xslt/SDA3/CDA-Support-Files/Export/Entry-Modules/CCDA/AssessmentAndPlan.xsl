<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="Container" mode="assessmentAndPlan-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Assessment or Activity</th>
						<th>Date</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Documents/Document[DocumentType/Code/text()='AssessmentAndPlan']" mode="assessmentAndPlan-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="Document" mode="assessmentAndPlan-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<xsl:variable name="narrativeDate"><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></xsl:variable>
		
		<tr ID="{concat($exportConfiguration/assessmentAndPlan/narrativeLinkPrefixes/assessmentAndPlanNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/assessmentAndPlan/narrativeLinkPrefixes/assessmentAndPlanDescription/text(), $narrativeLinkSuffix)}"><xsl:value-of select="DocumentName"/></td>
			<td><xsl:value-of select="substring-before($narrativeDate,' ')"/></td>
			<td ID="{concat($exportConfiguration/assessmentAndPlan/narrativeLinkPrefixes/assessmentAndPlanComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="NoteText/text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="Container" mode="assessmentAndPlan-NoData">
		<text><xsl:value-of select="$exportConfiguration/assessmentAndPlan/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="Container" mode="assessmentAndPlan-Entries">
		<xsl:apply-templates select="Documents/Document[DocumentType/Code/text()='AssessmentAndPlan']" mode="assessmentAndPlan-Entry"/>
	</xsl:template>
	
	<xsl:template match="Document" mode="assessmentAndPlan-Entry">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
			
		<xsl:apply-templates select="." mode="assessmentAndPlan-EntryDetail">
			<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="Document" mode="assessmentAndPlan-EntryDetail">
		<xsl:param name="narrativeLinkSuffix"/>		
		
		<entry typeCode="DRIV">
			<act classCode="ACT">
				<xsl:attribute name="moodCode">
					<xsl:choose>
						<xsl:when test="string-length(CustomPairs/NVPair[Name/text()='MoodCode']/Value/text())">
							<xsl:value-of select="CustomPairs/NVPair[Name/text()='MoodCode']/Value/text()"/>
						</xsl:when>
						<xsl:otherwise>INT</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="." mode="templateIds-assessmentAndPlanEntry"/>

				<!--
					Field : Assessment and Plan Entry id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/id
					Source: HS.SDA3.Document ExternalId
					Source: /Container/Documents/Document/ExternalId
					Note  : Logic for exporting SDA3 ExternalId to CDA id
							
							ExternalId is piece 1 by vertical bar of ExternalId
							ExternalIdAssigningAuthority is piece 2 by vertical bar of ExternalId
							
							If ExternalId is present and ExternalIdAssigningAuthority is present:
							Try to convert ExternalIdAssigningAuthority to OID, then
							id/@root = ExternalIdAssigningAuthority, id/@extension = ExternalId
							
							If ExternalId is OID and ExternalIdAssigningAuthority is absent:
							id/@root = ExternalId
							
							If ExternalId is UUID and ExternalIdAssigningAuthority is absent:
							id/@root = ExternalId
							
							If ExternalId is present but is not OID or UUID, and ExternalIdAssigningAuthority is absent:
							id/@root = generatedUUID, id/@extension = ExternalId
							
							If ExternalId is absent and ExternalIdAssigningAuthority is present:
							id/@nullFlavor = UNK
							
							If ExternalId is absent and ExternalIdAssigningAuthority is absent:
							id/@nullFlavor = UNK
				-->
				<xsl:variable name="externalId">
					<xsl:choose>
						<xsl:when test="contains(ExternalId/text(),'|')">
							<xsl:value-of select="substring-before(ExternalId/text(),'|')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="ExternalId/text()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="externalIdAA" select="substring-after(ExternalId/text(),'|')"/>
				<xsl:choose>
					<xsl:when test="string-length($externalId)">
						<xsl:choose>
							<xsl:when test="string-length($externalIdAA)">
								<!-- ExternalId present, ExternalIdAssigningAuthority present -->
								<xsl:variable name="externalIdOID">
									<xsl:apply-templates select="." mode="oid-for-code">
										<xsl:with-param name="Code" select="$externalIdAA"/>
									</xsl:apply-templates>
								</xsl:variable>
								<id root="{$externalIdOID}" extension="{$externalId}">
									<xsl:if test="not($externalIdOID=$externalIdAA)">
										<xsl:attribute name="assigningAuthorityName">
											<xsl:value-of select="$externalIdAA"/>
										</xsl:attribute>
									</xsl:if>
								</id>
							</xsl:when>
							<xsl:otherwise>
								<!-- ExternalId present, ExternalIdAssigningAuthority absent -->
								<xsl:variable name="ExternalIdIsOID">
									<xsl:apply-templates select="." mode="isOID">
										<xsl:with-param name="text" select="$externalId"/>
									</xsl:apply-templates>
								</xsl:variable>
								<xsl:variable name="ExternalIdIsUUID">
									<xsl:choose>
										<xsl:when test="not(starts-with(ExternalId/text(),'urn:uuid:')) and string-length(ExternalId/text())>30 and contains(translate(ExternalId/text(),concat($lowerCase,'0123456789abcdef'),''),'---')">1</xsl:when>
										<xsl:when test="starts-with(ExternalId/text(),'urn:uuid:') and string-length(ExternalId/text())>40 and contains(translate(substring(ExternalId/text(),9),concat($lowerCase,'0123456789abcdef'),''),'---')">1</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="($ExternalIdIsOID='1') or ($ExternalIdIsUUID='1')">
										<id root="{$externalId}"/>
									</xsl:when>
									<xsl:otherwise>
										<id root="{isc:evaluate('createUUID')}" extension="{$externalId}"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise><id nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Assessment and Plan Entry Code Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@code
					Source: HS.SDA3.Document CustomPairs.NVPair.Value
					Source: /Container/Documents/Document/CustomPairs/NVPair[Name/text()='DocumentNameCode'/Value/text()
				-->
				<!--
					Field : Assessment and Plan Entry Code Description
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@displayName
					Source: HS.SDA3.Document CustomPairs.NVPair.Value
					Source: /Container/Documents/Document/CustomPairs/NVPair[Name/text()='DocumentNameDescription'/Value/text()
					Note  : If Description does not have a value and Code has a value
							then Code is used to populate @displayName.
				-->
				<!--
					Field : Assessment and Plan Entry Code CodingStandard
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@codeSystem
					Source: HS.SDA3.Document CustomPairs.NVPair.Value
					Source: /Container/Documents/Document/CustomPairs/NVPair[Name/text()='DocumentNameCodingStandard'/Value/text()
					Note  : CodingStandard is intended to be a text name representation
							of the code system.  @codeSystem is an OID value.  It is derived
							by cross-referencing CodingStandard with the HealthShare OID
							Registry.
				-->
				<!--
					Field : Assessment and Plan Entry Code CodingStandard Name
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@codeSystemName
					Source: HS.SDA3.Document CustomPairs.NVPair.Value
					Source: /Container/Documents/Document/CustomPairs/NVPair[Name/text()='DocumentNameCodingStandard'/Value/text()
				-->
				<!--
					Field : Assessment and Plan Entry Text
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/text/reference/@value
					Source: HS.SDA3.Document NoteText
					Source: /Container/Documents/Document/NoteText
					Note  : The actual text is exported to the section narrative.
							originalText/reference/@value is just a pointer to the text.
				-->
				<xsl:apply-templates select="CustomPairs" mode="generic-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/assessmentAndPlan/narrativeLinkPrefixes/assessmentAndPlanDescription/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="hsCustomPairElementName" select="'DocumentName'"/>
				</xsl:apply-templates>
								
				<text><reference value="{concat('#', $exportConfiguration/assessmentAndPlan/narrativeLinkPrefixes/assessmentAndPlanNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="new"/>
				
				<!--
					Field : Assessment and Plan Entry Start Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/effectiveTime/low/@value
					Source: HS.SDA3.Document FromTime
					Source: /Container/Documents/Document/FromTime
					Note  : Assessment and Plan Entry effectiveTime is typed as
							IVL_TS in the schema, but it is allowed to alternatively
							just be a single value effectiveTime.
				-->
				<!--
					Field : Assessment and Plan Entry End Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/effectiveTime/high/@value
					Source: HS.SDA3.Document ToTime
					Source: /Container/Documents/Document/ToTime
					Note  : Assessment and Plan Entry effectiveTime is typed as
							IVL_TS in the schema, but it is allowed to alternatively
							just be a single value effectiveTime.
				-->
				<effectiveTime>
					<xsl:choose>
						<xsl:when test="string-length(ToTime/text())">
							<xsl:apply-templates select="." mode="effectiveTime-low"/>
							<xsl:apply-templates select="." mode="effectiveTime-high"/>
						</xsl:when>
						<xsl:when test="string-length(FromTime/text())">
							<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</effectiveTime>
				
				<!--
					Field : Assessment and Plan Entry Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/author
					Source: HS.SDA3.Document EnteredBy
					Source: /Container/Documents/Document/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					Field : Assessment and Plan Entry Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/informant
					Source: HS.SDA3.Document EnteredAt
					Source: /Container/Documents/Document/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!--
					Field : Assessment and Plan Entry Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/entryRelationship
					Source: HS.SDA3.Document EncounterNumber
					Source: /Container/Documents/Document/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
				-->
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-assessmentAndPlanEntry">
		<xsl:if test="$ccda-PlanOfCareActivityAct"><templateId root="{$ccda-PlanOfCareActivityAct}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
