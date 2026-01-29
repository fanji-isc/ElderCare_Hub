<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc exsl">

	<xsl:template match="Documents" mode="eN-notes-NoData">
		<xsl:param name="config" />
		<text><xsl:value-of select="$config/emptySection/narrativeText/text()"/></text>
	</xsl:template>  

	<xsl:template match="Documents" mode="eN-notes-Narrative">
		<xsl:param name="docs" />
		<xsl:param name="config" />

		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Date/Time</th>
						<th>Note</th>
						<th>Provider</th>
						<th>Source</th>
					</tr>
				</thead>
				<tbody>
					<xsl:variable name="documents" select="."/>
					<xsl:for-each select="$docs">
						<xsl:variable name="doc" select="."/>
						<xsl:apply-templates mode="eN-notes-NarrativeDetail" select="$documents/Document[generate-id(.) = $doc/@id]">
							<xsl:with-param name="config" select="$config"/>
							<xsl:with-param name="narrativeLinkSuffix" select="$doc/@pos"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="Document" mode="eN-notes-NarrativeDetail">
		<xsl:param name="config" />
		<xsl:param name="narrativeLinkSuffix" />

		<tr ID="{concat($exportConfiguration/notes/narrativeLinkPrefixes/noteNarrative/text(), $narrativeLinkSuffix)}">
			<td><xsl:apply-templates select="DocumentTime" mode="fn-narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/notes/narrativeLinkPrefixes/noteText/text(), $narrativeLinkSuffix)}">
				<xsl:apply-templates mode="narrative-export" select="." />
			</td>
			<td><xsl:value-of select="EnteredBy/Description/text()"/></td>
			<td><xsl:value-of select="EnteredAt/Description/text()" /></td>
		</tr>
	</xsl:template>

	<xsl:template match="Documents" mode="eN-notes-Entries">
		<xsl:param name="docs" />
		<xsl:param name="config" />

		<xsl:variable name="documents" select="."/>
		<xsl:for-each select="$docs">
			<xsl:variable name="doc" select="."/>
			<xsl:apply-templates mode="eN-notes-EntryDetail" select="$documents/Document[generate-id(.) = $doc/@id]">
				<xsl:with-param name="config" select="$config"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$doc/@pos"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="Document" mode="eN-notes-EntryDetail">
		<xsl:param name="config" />
		<xsl:param name="narrativeLinkSuffix" />

		<xsl:variable name="mediaType"><xsl:apply-templates select="." mode="eN-notes-mediaType"/></xsl:variable>

		<entry>
			<act classCode="ACT" moodCode="EVN">
				<xsl:call-template name="eN-templateIds-noteEntry"/>

				<!--
					Field : Document Number
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/id[1]
					Source: HS.SDA3.Document DocumentNumber
					Source: /Container/Documents/Document/DocumentNumber
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="eN-notes-id-DocumentNumber"/>

				<!--
					Field : Document Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/code/translation
					Source: HS.SDA3.Document DocumentType
					Source: /Container/Documents/Document/DocumentType
					StructuredMappingRef: generic-Coded
					Note  : The document type is always the first translation since the code must be the generic LOINC "Note" code
				-->
				<code code="34109-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Note">
					<!-- use the DocumentType if LOINC, else use the computed category -->
					<xsl:choose>
						<xsl:when test="DocumentType/SDACodingStandard/text() = 'LN'">
							<translation code="{DocumentType/Code/text()}" displayName="{DocumentType/Description/text()}" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" />
						</xsl:when>
						<xsl:otherwise>
							<translation code="{$config/code/text()}" displayName="{$config/name/text()}" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC"/>
						</xsl:otherwise>
					</xsl:choose>
				</code>

				<!--
					Field : Document Media Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/text/@mediaType
					Source: HS.SDA3.Document FileType
					Source: /Container/Documents/Document/FileType
					Note  : Supports types from NLM VSAC SupportedFileFormats (2.16.840.1.113883.11.20.7.1) value-set
				-->
				<!--
					Field : Document Stream
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/text[@representation='B64']
					Source: HS.SDA3.Document Stream
					Source: /Container/Documents/Document/Stream
					Note  : Exported only when a base-64 content in Stream is provided
				-->
				<!--
					Field : Document Note Text
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/text
					Source: HS.SDA3.Document NoteText
					Source: /Container/Documents/Document/NoteText
					Note  : NoteText is put int the narrative with newlines replaced with <br/>
				-->
				<text>
					<xsl:if test="not($mediaType = 'TXT')">
						<xsl:attribute name="mediaType"><xsl:value-of select="$mediaType"/></xsl:attribute>
						<xsl:attribute name="representation">B64</xsl:attribute>
						<xsl:value-of select="Stream/text()"/>
					</xsl:if>
					<reference value="{concat('#', $exportConfiguration/notes/narrativeLinkPrefixes/noteText/text(), $narrativeLinkSuffix)}"/>
				</text>

				<!--
					Field : Document Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/statusCode/@code
					Source: HS.SDA3.Document Status
					Source: /Container/Documents/Document/Status
					Note  : SDA Status is mapped to CDA statusCode/@code as follows (HL7v2 TXA:19 code table):
							SDA Status = 'CA', CDA statusCode/@code = 'cancelled'
							SDA Status = 'OB', CDA statusCode/@code = 'obsolete'
							SDA Status = 'UN', CDA statusCode/@code = 'unavailable'
							otherwsie SDA Status = 'completed'
				-->
				<xsl:variable name="status" select="Status/text()"/>
				<statusCode>
					<xsl:attribute name="code">
						<xsl:choose>
							<xsl:when test="$status = 'CA'">cancelled</xsl:when>
							<xsl:when test="$status = 'OB'">obsolete</xsl:when>
							<xsl:when test="$status = 'UN'">unavailable</xsl:when>
							<xsl:otherwise>completed</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</statusCode>

				<!--
					Field : Document Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/effectiveTime/@value
					Source: HS.SDA3.Document DocumentTime
					Source: /Container/Documents/Document/DocumentTime
					Note  : clinically relevant time
				-->
				<xsl:choose>
					<xsl:when test="string-length(DocumentTime/text()) > 0">
						<xsl:apply-templates select="DocumentTime" mode="fn-effectiveTime-singleton"/>
					</xsl:when>
					<xsl:otherwise>
						<effectiveTime nullFlavor="UNK"/>
					</xsl:otherwise>
				</xsl:choose>

				<!--
					Field : Document Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/author
					Source: HS.SDA3.Document EnteredBy
					Source: /Container/Documents/Document/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<!--
					Field : Document Author Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/author/time/@value
					Source: HS.SDA3.Document EnteredOn
					Source: /Container/Documents/Document/EnteredOn
				-->
				<!--
					Field : Document Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/author/representedOrganization
					Source: HS.SDA3.Document EnteredAt
					Source: /Container/Documents/Document/EnteredAt
					StructuredMappingRef: representedOrganization
				-->
				<xsl:choose>
					<xsl:when test="EnteredBy">
						<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
					</xsl:when>
					<xsl:otherwise>
						<author>
							<templateId root="2.16.840.1.113883.10.20.22.4.119" />
							<time nullFlavor="UNK"/>
							<assignedAuthor>
								<id nullFlavor="UNK"/>
							</assignedAuthor>
						</author>
					</xsl:otherwise>
				</xsl:choose>

				<!--
					Field : Document Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/participant[@typeCode = 'LA']
					Source: HS.SDA3.Document Clinician
					Source: /Container/Documents/Document/Clinician
					StructuredMappingRef: noteParticipant
				-->
				<xsl:apply-templates select="Clinician" mode="eN-notes-participant"/>

				<!--
					Field : Document EncounterNumber
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/entryRelationship/encounter/id
					Source: HS.SDA3.Document EncounterNumber
					Source: /Container/Documents/Document/EncounterNumber
					Note  : This links the Dcoument to an encounter in the Encounters section.
				-->
				<xsl:apply-templates select="." mode="eN-notes-encounterLink-entryRelationship"/>
			</act>
		</entry>

	</xsl:template>

	<xsl:template match="Clinician" mode="eN-notes-participant">
		<!--
			StructuredMapping: noteParticipant
		
			Field
			Path  : time/@value
			Source: AuthorizationTime
			Source: ./AuthorizationTime
			
			Field
			Path  : participantRole
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: noteParticipantRole
		-->
		<!--
			StructuredMapping: noteParticipantRole
			
			Field
			Path  : id
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : playingEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: notePlayingEntity
		-->
		<!--
			StructuredMapping: notePlayingEntity

			Field
			Path  : name
			Source: Name
			Source: ./Name
			StructuredMappingRef: name-Person

			Field
			Path  : addr
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
			
			Field
			Path  : telecom
			Source: ContactInfo
			Source: ./ContactInfo
			StructuredMappingRef: telecom
		-->
		<participant typeCode="LA">
			<time>
				<xsl:choose>
					<xsl:when test="string-length(../AuthorizationTime/text())">
						<xsl:attribute name="value">
							<xsl:apply-templates select="../AuthorizationTime" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</time>
			<participantRole>
				<xsl:apply-templates select="." mode="fn-id-Clinician"/>
				<playingEntity>
					<xsl:apply-templates select="." mode="fn-name-Person"/>
				</playingEntity>
			</participantRole>
		</participant>
	</xsl:template>

	<!-- determine note mediaType -->
	<xsl:template match="Document" mode="eN-notes-mediaType">
		<xsl:variable name="fileType" select="FileType/text()"/>
		<xsl:choose>
			<xsl:when test="$fileType = 'DOC'        ">application/msword</xsl:when>
			<xsl:when test="$fileType = 'MSWORD'     ">application/msword</xsl:when>
			<xsl:when test="$fileType = 'PDF'        ">application/pdf</xsl:when>
			<xsl:when test="$fileType = 'AUDIO'      ">audio</xsl:when>
			<xsl:when test="$fileType = 'BASICAUDIO' ">audio/basic</xsl:when>
			<xsl:when test="$fileType = 'K32ADPCM'   ">audio/k32adpcm</xsl:when>
			<xsl:when test="$fileType = 'AUDIOMPEG'  ">audio/mpeg</xsl:when>
			<xsl:when test="$fileType = 'GIF'        ">image/gif</xsl:when>
			<xsl:when test="$fileType = 'JPEG'       ">image/jpeg</xsl:when>
			<xsl:when test="$fileType = 'PNG'        ">image/png</xsl:when>
			<xsl:when test="$fileType = 'TIFF'       ">image/tiff</xsl:when>
			<xsl:when test="$fileType = 'HTML'       ">text/html</xsl:when>
			<xsl:when test="$fileType = 'RTF'        ">text/rtf</xsl:when>
			<xsl:when test="$fileType = 'VIDEO'      ">video</xsl:when>
			<xsl:when test="$fileType = 'MP4'        ">video/mp4</xsl:when>
			<xsl:when test="$fileType = 'VIDEOMPEG'  ">video/mpeg</xsl:when>
			<xsl:when test="$fileType = 'QUICKTIME'  ">video/quicktime</xsl:when>
			<xsl:when test="$fileType = 'WEBM'       ">video/webm</xsl:when>
			<xsl:when test="$fileType = 'X-AVI'      ">video/x-avi</xsl:when>
			<xsl:when test="$fileType = 'WMV'        ">video/x-ms-wmv</xsl:when>
			<xsl:otherwise>TXT</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- copy of fn-id-External that uses DocumentNumber instead -->
	<xsl:template match="Document" mode="eN-notes-id-DocumentNumber">
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(DocumentNumber)">
				<id>
					<xsl:attribute name="root">
						<xsl:apply-templates select="." mode="fn-oid-for-code">
							<xsl:with-param name="Code" select="EnteredAt/Code/text()"/>
						</xsl:apply-templates>
					</xsl:attribute>
					<xsl:attribute name="extension">
						<xsl:value-of select="DocumentNumber/text()"/>
					</xsl:attribute>
					<xsl:attribute name="assigningAuthorityName">
						<xsl:value-of select="concat(EnteredAt/Code/text(), '-DocumentNumber')"/>
					</xsl:attribute>
				</id>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
		Copy of fn-encounterLink-entryRelationship that uses @typeCode compliant 
		with C-CDA Notes Activity (COMP instead of SUBJ).
	-->
	<xsl:template match="Document" mode="eN-notes-encounterLink-entryRelationship">
		<xsl:if test="string-length(EncounterNumber)">
			<xsl:variable name="encounter" select="key('EncNum', EncounterNumber)[1]"/>
			<xsl:if test="count($encounter) &gt; 0 and contains('|I|O|E|', concat('|', $encounter/EncounterType/text(), '|'))">
				<entryRelationship typeCode="COMP" inversionInd="true">
					<xsl:apply-templates select="$encounter" mode="fn-encounterLink-Detail"/>
				</entryRelationship>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="eN-templateIds-noteEntry">
		<templateId root="{$ccda-NoteActivity}" extension="2016-11-01"/>
	</xsl:template>

</xsl:stylesheet>