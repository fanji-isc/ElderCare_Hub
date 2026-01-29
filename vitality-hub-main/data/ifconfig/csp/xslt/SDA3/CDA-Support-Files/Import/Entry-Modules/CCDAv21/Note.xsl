<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc hl7 xsi">
	
	<xsl:template match="hl7:act" mode="eN-Note">
		<Document>
			<xsl:apply-templates select="." mode="eN-EncounterNumber"/>
			<xsl:apply-templates select="." mode="eN-ExternalId"/>
			<xsl:apply-templates select="." mode="eN-DocumentNumber"/>
			<xsl:apply-templates select="." mode="eN-DocumentType"/>
			<xsl:apply-templates select="." mode="eN-Category"/>
			<xsl:apply-templates select="." mode="eN-EnteredBy"/>
			<xsl:apply-templates select="." mode="eN-EnteredAt"/>
			<xsl:apply-templates select="." mode="eN-EnteredOn"/>
			<xsl:apply-templates select="." mode="eN-Clinician"/>
			<xsl:apply-templates select="." mode="eN-AuthorizationTime"/>
			<xsl:apply-templates select="." mode="eN-DocumentTime"/>
			<xsl:apply-templates select="." mode="eN-DocumentName"/>
			<xsl:apply-templates select="." mode="eN-FileType"/>
			<xsl:apply-templates select="." mode="eN-Status"/>
			<xsl:apply-templates select="." mode="eN-NoteText-and-Format"/>
			<xsl:apply-templates select="." mode="eN-Stream"/>
			<xsl:apply-templates select="." mode="eN-ImportCustom-Document"/>
		</Document>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-EncounterNumber">
		<!--
			Field : Document EncounterNumber
			Target: HS.SDA3.Document EncounterNumber
			Target: /Container/Documents/Document/EncounterNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/entryRelationship/encounter/id
			Note  : If the CDA encounter link @extension is present then
					it is imported to SDA EncounterNumber.  Otherwise if
					the encounter link @root is present then it is used.
					If there is no encounter link on the CDA Medication and
					there is an encompassingEncounter in the CDA document
					header then the id from the encompassingEncounter is
					imported to SDA EncounterNumber.
		-->
		<xsl:if test=".//hl7:encounter">
			<EncounterNumber><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></EncounterNumber>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-ExternalId">
			<!--
				Field : Document Id
				Target: HS.SDA3.Document ExternalId
				Target: /Container/Documents/Document/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/id[2]
				StructuredMappingRef: ExternalId
				Note  : ExternalId is only populated when hl7:id[2] exists as for SDA Documents
				        the DocumentNumber takes precedence
			-->
		<xsl:apply-templates select="hl7:id[2]" mode="fn-W-pName-ExternalId-reference">
			<xsl:with-param name="hsElementName" select="'ExternalId'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-DocumentNumber">
			<!--
				Field : Document Number
				Target: HS.SDA3.Document DocumentNumber
				Target: /Container/Documents/Document/DocumentNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/id[1]
				StructuredMappingRef: ExternalId
			-->
		<xsl:apply-templates select="hl7:id[1]" mode="fn-W-pName-ExternalId-reference">
			<xsl:with-param name="hsElementName" select="'DocumentNumber'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-DocumentType">
		<!--
			Field : Document Type
			Target: HS.SDA3.Document DocumentType
			Target: /Container/Documents/Document/DocumentType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/code/translation
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/code
			StructuredMappingRef: CodeTableDetail
			Note  : The section code is used when a more specific type isn't provided
		-->
		<xsl:choose>
			<xsl:when test = "string-length(hl7:code/hl7:translation[1]/@code)">
				<xsl:apply-templates select="hl7:code/hl7:translation[1]" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'DocumentType'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="../../hl7:code" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'DocumentType'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-Category">
		<!--
			Field : Document Category
			Target: HS.SDA3.Document Category
			Target: /Container/Documents/Document/Category
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/code
			StructuredMappingRef: CodeTableDetail
			Note  : The section code is used as the document category
		-->
		<xsl:apply-templates select="../../hl7:code" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'Category'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-EnteredBy">
		<!--
			Field : Document Author
			Target: HS.SDA3.Document EnteredBy
			Target: /Container/Documents/Document/EnteredBy
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/author
			StructuredMappingRef: EnteredByDetail
		-->
		<xsl:apply-templates select="." mode="fn-EnteredBy"/>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-EnteredAt">
		<!--
			Field : Document Information Source
			Target: HS.SDA3.Document EnteredAt
			Target: /Container/Documents/Document/EnteredAt
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/author/representedOrganization
			StructuredMappingRef: EnteredAt
		-->
		<xsl:apply-templates select="." mode="fn-EnteredAt"/>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-EnteredOn">
		<!--
			Field : Document Author Time
			Target: HS.SDA3.Document EnteredOn
			Target: /Container/Documents/Document/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/author/time/@value
		-->
		<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-Clinician">
		<!--
			Field : Document Clinician
			Target: HS.SDA3.Document Clinician
			Target: /Container/Documents/Document/Clinician
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/participant[@typeCode = 'LA']
			StructuredMappingRef: DocumentClinician
		-->
		<xsl:variable name="clin" select="hl7:participant[@typeCode = 'LA']"/>
		<xsl:if test="$clin">
			<Clinician>
				<xsl:apply-templates select="$clin" mode="eN-fn-CareProviderDetail"/>
			</Clinician>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-AuthorizationTime">
		<!--
			Field : Document Signed Time
			Target: HS.SDA3.Document AuthorizationTime
			Target: /Container/Documents/Document/AuthorizationTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/participant[@typeCode = 'LA']/time/@value
		-->
		<xsl:apply-templates select="hl7:participant[@typeCode = 'LA']/hl7:time" mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'AuthorizationTime'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-DocumentTime">
		<!--
			Field : Document Time
			Target: HS.SDA3.Document DocumentTime
			Target: /Container/Documents/Document/DocumentTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/effectiveTime/@value
		-->
		<xsl:apply-templates select="hl7:effectiveTime" mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'DocumentTime'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-DocumentName">
		<!--
			Field : Document Name
			Target: HS.SDA3.Document DocumentName
			Target: /Container/Documents/Document/DocumentName
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/code/translation[1]/@displayName
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/code/@displayName
			Note  : Section code/@displayName is used if a more specific one is not available
		-->
		<DocumentName>
			<xsl:choose>
				<xsl:when test="string-length(hl7:code/hl7:translation[1]/@displayName)">
					<xsl:value-of select="hl7:code/hl7:translation[1]/@displayName"/>
				</xsl:when>
				<xsl:when test="string-length(../../hl7:code/@displayName)">
					<xsl:value-of select="../../hl7:code/@displayName"/>
				</xsl:when>
				<xsl:otherwise>Note</xsl:otherwise>
			</xsl:choose>
		</DocumentName>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-FileType">
		<!--
			Field : Document Media Type
			Target: HS.SDA3.Document FileType
			Target: /Container/Documents/Document/FileType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/text/@mediaType
			Note  : Supports types from NLM VSAC SupportedFileFormats (2.16.840.1.113883.11.20.7.1) value-set
		-->
		<FileType>
			<xsl:choose>
				<xsl:when test="hl7:text/@mediaType = 'application/msword'">MSWORD</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'application/pdf'   ">PDF</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'audio'             ">AUDIO</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'audio/basic'       ">BASICAUDIO</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'audio/k32adpcm'    ">K32ADPCM</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'audio/mpeg'        ">AUDIOMPEG</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'image/gif'         ">GIF</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'image/jpeg'        ">JPEG</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'image/png'         ">PNG</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'image/tiff'        ">TIFF</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'text/html'         ">HTML</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'text/rtf'          ">RTF</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'video'             ">VIDEO</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'video/mp4'         ">MP4</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'video/mpeg'        ">VIDEOMPEG</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'video/quicktime'   ">QUICKTIME</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'video/webm'        ">WEBM</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'video/x-avi'       ">X-AVI</xsl:when>
				<xsl:when test="hl7:text/@mediaType = 'video/x-ms-wmv'    ">WMV</xsl:when>
				<xsl:otherwise>TXT</xsl:otherwise>
			</xsl:choose>
		</FileType>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-Status">
		<!--
			Field : Document Status
			Target: HS.SDA3.Document Status
			Target: /Container/Documents/Document/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/statusCode/@code
			Note  : CDA statusCode/@code is mapped to SDA Status as follows (HL7v2 TXA:19 code table):
					CDA statusCode/@code = 'cancelled', SDA Status = 'CA'
					CDA statusCode/@code = 'obsolete', SDA Status = 'OB'
					CDA statusCode/@code = 'unavailable', SDA Status = 'UN'
					otherwsie SDA Status = 'AV'
		-->
		<xsl:variable name="status" select="hl7:statusCode/@code"/>
		<xsl:if test="string-length($status)">
			<Status>
				<Code>
					<xsl:choose>
						<xsl:when test="$status = 'cancelled'">CA</xsl:when>
						<xsl:when test="$status = 'obsolete'">OB</xsl:when>
						<xsl:when test="$status = 'unavailable'">UN</xsl:when>
						<xsl:otherwise>AV</xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description>
					<xsl:choose>
						<xsl:when test="$status = 'cancelled'">Deleted</xsl:when>
						<xsl:when test="$status = 'obsolete'">Obsolete</xsl:when>
						<xsl:when test="$status = 'unavailable'">Unavailable for patient care</xsl:when>
						<xsl:otherwise>Available for patient care</xsl:otherwise>
					</xsl:choose>
				</Description>
			</Status>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-Stream">
		<!--
			Field : Document Stream
			Target: HS.SDA3.Document Stream
			Target: /Container/Documents/Document/Stream
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/text[@representation='B64']
			Note  : Stream will be populated only when a base-64 content is provided
		-->
		<xsl:if test="string-length(hl7:text[@representation = 'B64']/text())">
			<Stream>
				<xsl:value-of select="translate(hl7:text/text(),'&#13;&#10;&#32;','')"/>
			</Stream>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eN-NoteText-and-Format">
		<!--
			Field : Document Note Text
			Target: HS.SDA3.Document NoteText
			Target: /Container/Documents/Document/NoteText
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/text
			Note  : NoteText is extracted from the narrative reference as formatted plain text
		-->
		<!--
			Field : Document Note Format
			Target: HS.SDA3.Document FormatCode
			Target: /Container/Documents/Document/FormatCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.65']/entry/act/text
			StructuredMappingRef: CodeTableDetail
			Note  : FormatCode is FIXED if text is determined to be fixed with, NARRATIVE if composed of CCDA StuctDoc elements, or left empty
		-->
		<xsl:apply-templates mode="narrative-import" select="hl7:text"/>
	</xsl:template>

	<xsl:template match="*" mode="eN-ImportCustom-Document">
		<!--
			This empty template may be overridden with custom logic.
			The input node spec is normally $sectionRootPath/hl7:entry/hl7:act.
		-->
	</xsl:template>

	<xsl:template match="hl7:participant" mode="eN-fn-CareProviderDetail">
		<!-- copy of fn-CareProviderDetail for hl7:participant to avoid any backward-compatibilty issues -->

		<!--
			StructuredMapping: DocumentClinician
			
			Field
			Path  : Code
			XPath : Code/text()
			Source: participantRole/id/@extension
			Note  : If id/@extension is not available then a string assembled from the discrete parts of participantRole/playingEntity/name is used.
			
			Field
			Path  : Description
			XPath : Description/text()
			Source: participantRole/playingEntity/name
			Note  : The value used for SDA Description is a string assembled from the discrete parts of assignedEntity/assignedPerson/name.
			
			Field
			Path  : ContactName
			XPath : ContactName
			Source: assignedEntity/assignedPerson/name
			StructuredMappingRef: ContactName
			
			Field
			Path  : Address
			XPath : Address
			Source: assignedEntity/addr
			StructuredMappingRef: Address
			
			Field
			Path  : ContactInfo
			XPath : ContactInfo
			Source: assignedEntity
			StructuredMappingRef: ContactInfo
			
			Field
			Path  : CareProviderType.Code
			XPath : CareProviderType/Code/text()
			Source: functionCode/@code
			
			Field
			Path  : CareProviderType.Description
			XPath : CareProviderType/Description/text()
			Source: functionCode/@displayName
			
			Field
			Path  : CareProviderType.SDACodingStandard
			XPath : CareProviderType/SDACodingStandard/text()
			Source: functionCode/@codeSystem
		-->
		<xsl:variable name="entityPath" select="hl7:participantRole"/>
		
		<xsl:if test="$entityPath = true()">
			<xsl:variable name="personPath" select="$entityPath/hl7:playingEntity"/>
			
			<xsl:if test="$personPath = true() and not($personPath/hl7:name/@nullFlavor)">
				<xsl:variable name="translation1code" select="hl7:functionCode/hl7:translation[1]/@code"/>
				<xsl:variable name="isNullFunctionCode" select="string-length(hl7:functionCode/@nullFlavor) > 0"/>
				<xsl:variable name="codeOrTranslation">
					<!-- 0 = no data, 1 = use hl7:functionCode, 2 = use hl7:functionCode/hl7:translation[1] -->
					<xsl:choose>
						<xsl:when test="$isNullFunctionCode and $translation1code and hl7:functionCode/hl7:translation[1]/@codeSystem">2</xsl:when>
						<xsl:when test="not($isNullFunctionCode) and $translation1code and hl7:functionCode/hl7:translation[1]/@codeSystem=$noCodeSystemOID">2</xsl:when>
						<xsl:when test="hl7:functionCode/@code and not($isNullFunctionCode)">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianFunctionCode">
					<xsl:choose>
						<xsl:when test="$codeOrTranslation='1'">
							<xsl:value-of select="hl7:functionCode/@code"/>
						</xsl:when>
						<xsl:when test="$codeOrTranslation='2'">
							<xsl:value-of select="$translation1code"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianAssigningAuthority">
					<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$entityPath/hl7:id/@root"/></xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="clinicianID" select="$entityPath/hl7:id/@extension"/>
				<xsl:variable name="clinicianName">
					<xsl:apply-templates select="$personPath/hl7:name" mode="fn-ContactNameString"/>
				</xsl:variable>
				
				<xsl:if test="string-length($clinicianAssigningAuthority) and not($clinicianAssigningAuthority=$noCodeSystemOID) and not($clinicianAssigningAuthority=$noCodeSystemName)">
					<SDACodingStandard><xsl:value-of select="$clinicianAssigningAuthority"/></SDACodingStandard>
				</xsl:if>
				<Code>
					<xsl:choose>
						<xsl:when test="string-length($clinicianID)"><xsl:value-of select="$clinicianID"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$clinicianName"/></xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description><xsl:value-of select="$clinicianName"/></Description>
				<!-- Contact Name and Contact Information -->
				<xsl:apply-templates select="$personPath/hl7:name" mode="fn-T-pName-ContactName"/>
				<xsl:apply-templates select="$entityPath/hl7:addr" mode="fn-T-pName-address"/>
				<xsl:apply-templates select="$entityPath" mode="fn-T-pName-ContactInfo"/>
				
				<!-- Contact Type -->
				<xsl:if test="string-length($clinicianFunctionCode)">
					<CareProviderType>
						<xsl:variable name="clinicianFunctionCodeSystem">
							<xsl:choose>
								<xsl:when test="$codeOrTranslation='1' and not(hl7:functionCode/@codeSystem=$noCodeSystemOID)">
									<xsl:value-of select="hl7:functionCode/@codeSystem"/>
								</xsl:when>
								<xsl:when test="$codeOrTranslation='2' and not(hl7:functionCode/hl7:translation[1]/@codeSystem=$noCodeSystemOID)">
									<xsl:value-of select="hl7:functionCode/hl7:translation[1]/@codeSystem"/>
								</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="string-length($clinicianFunctionCodeSystem)">
							<SDACodingStandard>
								<xsl:apply-templates select="." mode="fn-code-for-oid">
									<xsl:with-param name="OID" select="$clinicianFunctionCodeSystem"/>
								</xsl:apply-templates>
							</SDACodingStandard>
						</xsl:if>
						<Code><xsl:value-of select="$clinicianFunctionCode"/></Code>
						<Description>
							<xsl:choose>
								<xsl:when test="$codeOrTranslation = '1'">
									<xsl:value-of select="hl7:functionCode/@displayName"/>
								</xsl:when>
								<xsl:when test="$codeOrTranslation = '2'">
									<xsl:value-of select="hl7:functionCode/hl7:translation[1]/@displayName"/>
								</xsl:when>
							</xsl:choose>
						</Description>
					</CareProviderType>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>