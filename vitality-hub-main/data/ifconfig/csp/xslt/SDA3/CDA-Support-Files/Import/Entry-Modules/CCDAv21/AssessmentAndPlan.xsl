<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">
  <!-- AlsoInclude: Comment.xsl -->
  
	<xsl:template match="hl7:act" mode="eANP-AssessmentAndPlan-EntryDetail">
		<Document>
		
			<!-- ExternalId -->
			<xsl:if test="string-length(hl7:id/@root)">
			
				<xsl:variable name="rootIsUUID">
					<xsl:choose>
						<xsl:when test="not(starts-with(hl7:id/@root,'urn:uuid:')) and string-length(hl7:id/@root)>30 and contains(translate(hl7:id/@root,concat($lowerCase,'0123456789abcdef'),''),'---')">1</xsl:when>
						<xsl:when test="starts-with(hl7:id/@root,'urn:uuid:') and string-length(hl7:id/@root)>40 and contains(translate(substring(hl7:id/@root,9),concat($lowerCase,'0123456789abcdef'),''),'---')">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<!--
					Field : Document id
					Target: HS.SDA3.Document ExternalId
					Target: /Container/Documents/Document/ExternalId
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/id
					Note  : Logic for importing CDA id to SDA3 ExternalId as ExternalId|ExternalIdAssigningAuthority:
							
							If root is oid, and extension is present, and assigningAuthorityName is present:
							ExternalId = extension, ExternalIdAssigningAuthority = assigningAuthorityName
							
							If root is oid, and extension is present, and assigningAuthorityName is absent:
							ExternalId = extension, ExternalIdAssigningAuthority = code for oid (using root)
							
							If root is oid, and extension is absent, and assigningAuthorityName is present:
							ExternalId = root, ExternalIdAssigningAuthority = assigningAuthorityName
							
							If root is oid, and extension is absent, and assigningAuthorityName is absent:
							ExternalId = root
							
							If root is uuid, and extension is present, and assigningAuthorityName is present:
							ExternalId = extension, ExternalIdAssigningAuthority = assigningAuthorityName
							
							If root is uuid, and extension is present, and assigningAuthorityName is absent:
							ExternalId = extension
							
							If root is uuid, and extension is absent, and assigningAuthorityName is present:
							ExternalId = root, ExternalIdAssigningAuthority = assigningAuthorityName
							
							If root is uuid, and extension is absent, and assigningAuthorityName is absent:
							ExternalId = root
				-->
				<xsl:choose>
					<xsl:when test="$rootIsUUID='0'">
						<xsl:choose>
							<xsl:when test="string-length(hl7:id/@extension)">
								<xsl:choose>
									<xsl:when test="string-length(hl7:id/@assigningAuthorityName)">
										<!-- root is oid, extension present, assigningAuthorityName present -->
										<ExternalId><xsl:value-of select="concat(hl7:id/@extension,'|',hl7:id/@assigningAuthorityName)"/></ExternalId>
									</xsl:when>
									<xsl:otherwise>
										<!-- root is oid, extension present, assigningAuthorityName absent -->
										<xsl:variable name="externalIdAA">
											<xsl:apply-templates select="." mode="fn-code-for-oid">
												<xsl:with-param name="OID" select="hl7:id/@root"/>
											</xsl:apply-templates>
										</xsl:variable>
										<ExternalId><xsl:value-of select="concat(hl7:id/@extension,'|',$externalIdAA)"/></ExternalId>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="string-length(hl7:id/@assigningAuthorityName)">
										<!-- root is oid, extension absent, assigningAuthorityName present -->
										<ExternalId><xsl:value-of select="concat(hl7:id/@root,'|',hl7:id/@assigningAuthorityName)"/></ExternalId>
									</xsl:when>
									<xsl:otherwise>
										<!-- root is oid, extension absent, assigningAuthorityName absent -->
										<ExternalId><xsl:value-of select="hl7:id/@root"/></ExternalId>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string-length(hl7:id/@extension)">
								<xsl:choose>
									<xsl:when test="string-length(hl7:id/@assigningAuthorityName)">
										<!-- root is uuid, extension present, assigningAuthorityName present -->
										<ExternalId><xsl:value-of select="concat(hl7:id/@extension,'|',hl7:id/@assigningAuthorityName)"/></ExternalId>
									</xsl:when>
									<xsl:otherwise>
										<!-- root is uuid, extension present, assigningAuthorityName absent -->
										<ExternalId><xsl:value-of select="hl7:id/@extension"/></ExternalId>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="string-length(hl7:id/@assigningAuthorityName)">
										<!-- root is uuid, extension absent, assigningAuthorityName present -->
										<ExternalId><xsl:value-of select="concat(hl7:id/@root,'|',hl7:id/@assigningAuthorityName)"/></ExternalId>
									</xsl:when>
									<xsl:otherwise>
										<!-- root is uuid, extension absent, assigningAuthorityName absent -->
										<ExternalId><xsl:value-of select="hl7:id/@root"/></ExternalId>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			
			<!--
				Field : Document Encounter
				Target: HS.SDA3.Document EncounterNumber
				Target: /Container/Documents/Document/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/entryRelationship/encounter/id
				Note  : SDA EncounterNumber is imported only when it is explicitly
						stated on the entry.  encompassingEncounter is not used
						for these entries.
			-->
			<xsl:if test=".//hl7:encounter">
				<EncounterNumber><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></EncounterNumber>
			</xsl:if>
			
			<!--
				Field : Document NoteText
				Target: HS.SDA3.Document NoteText
				Target: /Container/Documents/Document/NoteText
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/entryRelationship/act[templateId/@root='2.16.840.1.113883.3.88.11.83.11']/text
				Note  : The Document NoteText is imported from the first found of CDA comment
						entryRelationship, the text element, or code/originalText.
			-->
			<!--
				Field : Document NoteText
				Target: HS.SDA3.Document NoteText
				Target: /Container/Documents/Document/NoteText
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/text/reference/@value
				Note  : The Document NoteText is imported from the first found of CDA comment
						entryRelationship, the text element, or code/originalText.
			-->
			<!--
				Field : Document NoteText
				Target: HS.SDA3.Document NoteText
				Target: /Container/Documents/Document/NoteText
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/originalText/reference/@value
				Note  : The Document NoteText is imported from the first found of CDA comment
						entryRelationship, the text element, or code/originalText.
			-->
			<xsl:choose>
				<xsl:when test="hl7:entryRelationship[@typeCode='SUBJ']/hl7:act[hl7:templateId/@root=$ccda-CommentActivity]/hl7:text">
					<xsl:apply-templates select="." mode="eCm-Comment">
					  <xsl:with-param name="emitElementName" select="'NoteText'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>

					<xsl:variable name="textReferenceLink" select="substring-after(hl7:text/hl7:reference/@value, '#')"/>
					<xsl:variable name="textReferenceValue">
						<xsl:if test="string-length($textReferenceLink)">
							<xsl:value-of select="key('narrativeKey', $textReferenceLink)"/>
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="originalTextReferenceLink" select="substring-after(hl7:code/hl7:originalText/hl7:reference/@value, '#')"/>
					<xsl:variable name="originalTextReferenceValue">
						<xsl:if test="string-length($originalTextReferenceLink)">
							<xsl:value-of select="key('narrativeKey', $originalTextReferenceLink)"/>
						</xsl:if>
					</xsl:variable>
		
					<xsl:choose>
						<xsl:when test="string-length(normalize-space($textReferenceValue))">
							<NoteText>
								<xsl:value-of select="$textReferenceValue"/>
							</NoteText>
						</xsl:when>
						<xsl:when test="string-length(normalize-space(hl7:text/text()))">
							<NoteText>						
								<xsl:value-of select="//hl7:text/hl7:table/hl7:tbody/hl7:tr/hl7:td[contains(@ID,'Comments')]/text()"/>
							</NoteText>
						</xsl:when>
						<xsl:when test="string-length(normalize-space($originalTextReferenceValue))">
							<NoteText>
								<xsl:value-of select="$originalTextReferenceValue"/>
							</NoteText>
						</xsl:when>
						<xsl:when test="string-length(normalize-space(hl7:code/hl7:originalText/text()))">
							<NoteText>
								<xsl:value-of select="hl7:code/hl7:originalText/text()"/>
							</NoteText>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- DocumentType -->
			<DocumentType><Code>AssessmentAndPlan</Code></DocumentType>
			
			<!--
				Field : Document Name
				Target: HS.SDA3.Document DocumentName
				Target: /Container/Documents/Document/DocumentName
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@displayName
				Note  : The SDA3 DocumentName string-type property is populated with the
						first found of CDA code/@displayName, code/@originalText, or code/@code.
			-->
			<DocumentName>
				<xsl:choose>
					<xsl:when test="string-length(hl7:code/@displayName)">
						<xsl:value-of select="hl7:code/@displayName"/>
					</xsl:when>
					<xsl:when test="string-length(hl7:code/hl7:originalText/text())">
						<xsl:value-of select="hl7:code/hl7:originalText/text()"/>
					</xsl:when>
					<xsl:when test="string-length(hl7:code/@code)">
						<xsl:value-of select="hl7:code/@code"/>
					</xsl:when>
					<xsl:otherwise>(no name)</xsl:otherwise>
				</xsl:choose>
			</DocumentName>
			
			<!--
				Field : Document Start Date/Time
				Target: HS.SDA3.Document FromTime
				Target: /Container/Documents/Document/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/effectiveTime/low/@value
				Note  : Assessment and Plan Entry effectiveTime is typed as
						IVL_TS in the schema, but it is allowed to alternatively
						just be a single value effectiveTime.
			-->
			<!--
				Field : Document End Date/Time
				Target: HS.SDA3.Document ToTime
				Target: /Container/Documents/Document/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/effectiveTime/high/@value
				Note  : Assessment and Plan Entry effectiveTime is typed as
						IVL_TS in the schema, but it is allowed to alternatively
						just be a single value effectiveTime.
			-->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/@value">
					<xsl:apply-templates select="hl7:effectiveTime" mode="fn-FromTime"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-FromTime"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Document Code Code
				Target: HS.SDA3.Document CustomPairs.NVPair.Value
				Target: /Container/Documents/Document/CustomPairs/NVPair[Name/text()='DocumentNameCode'/Value/text()
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@code
				Note  : The DocumentName CustomPair-based coded entry is used to hold
						the Assessment and Plan Entry code information.
			-->
			<!--
				Field : Document Code Description
				Target: HS.SDA3.Document CustomPairs.NVPair.Value
				Target: /Container/Documents/Document/CustomPairs/NVPair[Name/text()='DocumentNameDescription'/Value/text()
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@displayName
				Note  : If Description does not have a value and Code has a value
						then Code is used to populate @displayName.
			-->
			<!--
				Field : Document Code CodingStandard
				Target: HS.SDA3.Document CustomPairs.NVPair.Value
				Target: /Container/Documents/Document/CustomPairs/NVPair[Name/text()='DocumentNameCodingStandard'/Value/text()
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@codeSystem
				Note  : CodingStandard is intended to be a text name representation
						of the code system.  @codeSystem is an OID value.  It is derived
						by cross-referencing CodingStandard with the HealthShare OID
						Registry.
			-->
			<CustomPairs>
				<!-- DocumentName coded entry CustomPairs -->
				<xsl:apply-templates select="hl7:code" mode="fn-CodeTable-CustomPair">
					<xsl:with-param name="emitElementName" select="'DocumentName'"/>
				</xsl:apply-templates>
				<!-- MoodCode is essential to preserving semantics of the entry -->
				<NVPair>
					<Name>MoodCode</Name>
					<Value><xsl:value-of select="@moodCode"/></Value>
				</NVPair>
			</CustomPairs>
			
			<!-- Custom SDA Data-->
		  <xsl:apply-templates select="." mode="eANP-ImportCustom-AssessmentAndPlan"/>
		</Document>
	</xsl:template>
	
  <!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:act.
	-->
  <xsl:template match="*" mode="eANP-ImportCustom-AssessmentAndPlan">
	</xsl:template>
  
</xsl:stylesheet>