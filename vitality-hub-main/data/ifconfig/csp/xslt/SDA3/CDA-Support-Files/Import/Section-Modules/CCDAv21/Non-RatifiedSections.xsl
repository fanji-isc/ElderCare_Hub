<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="isc hl7">
	<!-- AlsoInclude: String-Functions.xsl -->
	
	<xsl:template match="*" mode="sNRS-CareConsiderationsSection">
		<xsl:apply-templates select="key('sectionsByRoot',$careConsiderationsSectionTemplateId)" mode="sNRS-CareConsiderationsSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="hl7:section" mode="sNRS-CareConsiderationsSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sNRS-IsNoDataSection-CareConsiderations"/></xsl:variable>
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and (not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Documents>
					<xsl:apply-templates select="$sectionEntries" mode="sNRS-CareConsiderations"/>
				</Documents>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Documents>
					<xsl:apply-templates select="." mode="fn-XFRMAllEncounters">
						<xsl:with-param name="informationType">Document</xsl:with-param>
					</xsl:apply-templates>
				</Documents>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="sNRS-CareConsiderations">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:if test="position() = 1">
			<xsl:call-template name="ActionCode">
				<xsl:with-param name="informationType">Document</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:apply-templates select="." mode="sNRS-Document-main">
			<xsl:with-param name="disclaimerPosition" select="count($careConsiderationSection/hl7:text/hl7:table)"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="sNRS-Document-main">
		<!-- The template formerly known as CareConsideration (singular) -->
		<xsl:param name="disclaimerPosition"/>
		
		<Document>
			<EncounterNumber><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></EncounterNumber>

			<!-- EnteredBy -->
			<xsl:apply-templates select="hl7:act/hl7:author" mode="fn-EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="hl7:act/hl7:informant" mode="fn-EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:act/hl7:effectiveTime" mode="fn-EnteredOn"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="hl7:act/hl7:id[1]" mode="fn-ExternalId"/>
			
			<!-- Document Time -->
			<!-- go direct instead of mode="DocumentTime" -->
			<xsl:apply-templates select="hl7:act/hl7:effectiveTime" mode="fn-I-timestamp">
				<xsl:with-param name="emitElementName" select="'DocumentTime'"/>
			</xsl:apply-templates>
			
			<!-- Document Number -->
			<xsl:apply-templates select="hl7:act" mode="sNRS-DocumentNumber"/>

			<!-- Document Name -->
			<xsl:apply-templates select="hl7:act/hl7:code" mode="sNRS-DocumentName"/>
			
			<!-- Document Type -->
			<xsl:apply-templates select="hl7:act" mode="sNRS-DocumentType"/>

			<!-- File Type (always HTML for a care consideration) -->
			<FileType>HTML</FileType>

			<!-- Document Stream -->
			<xsl:apply-templates select="../hl7:text" mode="sNRS-Stream-Note">
				<xsl:with-param name="documentPosition" select="position()"/>
				<xsl:with-param name="disclaimerPosition" select="$disclaimerPosition"/>
			</xsl:apply-templates>

			<!-- Document Status -->
			<xsl:apply-templates select="hl7:act/hl7:entryRelationship[@typeCode = 'SUBJ']/hl7:observation[hl7:code/@code = 'SEV']/hl7:value" mode="sNRS-Status"/>

			<!-- Clinician -->
			<xsl:apply-templates select="hl7:act/hl7:performer" mode="fn-Clinician"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="sNRS-ImportCustom-CareConsideration"/>
		</Document>
	</xsl:template>

	<xsl:template match="hl7:act" mode="sNRS-DocumentNumber">
		<DocumentNumber>
			<xsl:text>CaseID:</xsl:text>
			<xsl:apply-templates select="hl7:id[2]" mode="fn-S-Id"/>
			<xsl:text>|</xsl:text>
			<xsl:text>TrackingID:</xsl:text>
			<xsl:apply-templates select="hl7:id[1]" mode="fn-S-Id"/>
		</DocumentNumber>
	</xsl:template>

	<xsl:template match="hl7:value" mode="sNRS-Status">
		<!-- The template formerly known as DocumentStatus -->
		<Status>
			<Code>AV</Code>
			<Description><xsl:value-of select="@displayName"/></Description>
		</Status>
	</xsl:template>
	
	<xsl:template match="hl7:code" mode="sNRS-DocumentName">
		<DocumentName><xsl:apply-templates select="." mode="fn-TextValue"/></DocumentName>
	</xsl:template>
	
	<xsl:template match="hl7:act" mode="sNRS-DocumentType">
		<DocumentType>
			<SDACodingStandard>
				<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$activeHealthManagementOID"/></xsl:apply-templates>
			</SDACodingStandard>
			<Code>
				<xsl:choose>
					<xsl:when test="hl7:templateId[@root=$other-ActiveHealth-ProviderCareConsiderationsEntry]">P</xsl:when>
					<xsl:when test="hl7:templateId[@root=$other-ActiveHealth-MemberCareConsiderationsEntry]">M</xsl:when>
					<xsl:otherwise>O</xsl:otherwise>
				</xsl:choose>				
			</Code>
			<Description>
				<xsl:choose>
					<xsl:when test="hl7:templateId[@root=$other-ActiveHealth-ProviderCareConsiderationsEntry]">Provider Care Consideration</xsl:when>
					<xsl:when test="hl7:templateId[@root=$other-ActiveHealth-MemberCareConsiderationsEntry]">Member Care Consideration</xsl:when>
					<xsl:otherwise>Other Care Consideration</xsl:otherwise>
				</xsl:choose>				
			</Description>
		</DocumentType>
	</xsl:template>
	
	<xsl:template match="hl7:text" mode="sNRS-Stream-Note">
		<!-- The template formerly known as CareConsiderationNote -->
		<xsl:param name="documentPosition"/>
		<xsl:param name="disclaimerPosition"/>
		
		<xsl:variable name="careConsideration">
			&lt;html&gt;
			&lt;h1&gt;Care Consideration&lt;/h1&gt;						
			<xsl:call-template name="xml-to-string">
				<xsl:with-param name="node-set" select="hl7:table[$documentPosition]"/>
			</xsl:call-template>
			&lt;br&gt;&lt;hr/&gt;
			&lt;h1&gt;Disclaimer, FAQ, and Call-back Number&lt;/h1&gt;						
			<xsl:call-template name="xml-to-string">
				<xsl:with-param name="node-set" select="hl7:table[$disclaimerPosition]"/>
			</xsl:call-template>						
			&lt;/html&gt;
		</xsl:variable>
		
		<xsl:if test="string-length($careConsideration)">
			<Stream><xsl:value-of select="isc:evaluate('encode', $careConsideration)"/></Stream>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="sNRS-Documents">
		<!-- This template is currently UNUSED -->
		<!-- For transforming USD nonXMLBofy to Documents/Document -->
		<xsl:param name="encounterID"/>
		<xsl:param name="encounterStartDateTime"/>

		<xsl:if test="$nonXMLBodyRootPath">
			<Documents>
				<xsl:for-each select="$nonXMLBodyRootPath">
					<xsl:variable name="fileType">
						<xsl:choose>
							<xsl:when test="contains(hl7:text/@mediaType, 'msword')">MSWORD</xsl:when>				
							<xsl:when test="contains(hl7:text/@mediaType, 'pdf')">PDF</xsl:when>
							<xsl:when test="contains(hl7:text/@mediaType, 'plain')">Plain Text</xsl:when>			
							<xsl:when test="contains(hl7:text/@mediaType, 'rtf')">RTF</xsl:when>
							<xsl:when test="contains(hl7:text/@mediaType, 'html')">HTML</xsl:when>
							<xsl:when test="contains(hl7:text/@mediaType, 'gif')">GIF</xsl:when>
							<xsl:when test="contains(hl7:text/@mediaType, 'tiff')">TIFF</xsl:when>
							<xsl:when test="contains(hl7:text/@mediaType, 'jpeg')">JPEG</xsl:when>
							<xsl:when test="contains(hl7:text/@mediaType, 'png')">PNG</xsl:when>
						</xsl:choose>
					</xsl:variable>			

					<Document>
						<EncounterNumber><xsl:value-of select="$encounterID"/></EncounterNumber>
						<DocumentName>
							<xsl:value-of select="$input/hl7:title/text()"/>
						</DocumentName>						
						<xsl:choose>
							<xsl:when test="string-length($fileType)">
								<FileType><xsl:value-of select="$fileType"/></FileType>
								<Stream><xsl:value-of select="hl7:text/text()"/></Stream>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="/hl7:ClinicalDocument/hl7:component/hl7:nonXMLBody/hl7:text">					
									<DocumentURL><xsl:value-of select="hl7:reference/@value"/></DocumentURL>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</Document>
				</xsl:for-each>
			</Documents>
		</xsl:if>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry.
	-->
	<xsl:template match="*" mode="sNRS-ImportCustom-CareConsideration">
	</xsl:template>
	
	<!-- Determine if the Care Considerations section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $careConsiderationSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include care considerations data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sNRS-IsNoDataSection-CareConsiderations">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>