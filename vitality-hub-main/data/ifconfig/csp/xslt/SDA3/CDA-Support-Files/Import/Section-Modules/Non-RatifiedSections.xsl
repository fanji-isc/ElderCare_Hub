<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">
	
	<xsl:template match="*" mode="CareConsiderationsSection">
		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$careConsiderationsSectionTemplateId]" mode="CareConsiderationsSectionEntries"/>
	</xsl:template>
	
	<xsl:template match="*" mode="CareConsiderationsSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="IsNoDataSection-CareConsiderations"/></xsl:variable>
		<xsl:variable name="sectionEntries" select="hl7:entry[not(.//@negationInd='true') and (not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		
		<xsl:choose>
			<xsl:when test="$sectionEntries and $isNoDataSection='0'">
				<Documents>
					<xsl:apply-templates select="$sectionEntries" mode="CareConsiderations"/>
				</Documents>
			</xsl:when>
			<xsl:when test="$isNoDataSection='1' and $documentActionCode='XFRM'">
				<Documents>
					<xsl:apply-templates select="." mode="XFRMAllEncounters">
						<xsl:with-param name="informationType">Document</xsl:with-param>
					</xsl:apply-templates>
				</Documents>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="CareConsiderations">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:if test="position() = 1"><xsl:call-template name="ActionCode"><xsl:with-param name="informationType">Document</xsl:with-param></xsl:call-template></xsl:if>
		
		<xsl:apply-templates select="." mode="CareConsideration">
			<xsl:with-param name="disclaimerPosition" select="count($sectionRootPath[hl7:templateId/@root=$careConsiderationsSectionTemplateId]/hl7:text/hl7:table)"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="CareConsideration">
		<xsl:param name="disclaimerPosition"/>
		
		<Document>
			<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>

			<!-- EnteredBy -->
			<xsl:apply-templates select="hl7:act/hl7:author" mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="hl7:act/hl7:informant" mode="EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:act/hl7:effectiveTime" mode="EnteredOn"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="hl7:act/hl7:id[1]" mode="ExternalId"/>
			
			<!-- Document Time -->
			<xsl:apply-templates select="hl7:act/hl7:effectiveTime" mode="DocumentTime"/>
			
			<!-- Document Number -->
			<xsl:apply-templates select="hl7:act" mode="DocumentNumber"/>

			<!-- Document Name -->
			<xsl:apply-templates select="hl7:act/hl7:code" mode="DocumentName"/>
			
			<!-- Document Type -->
			<xsl:apply-templates select="hl7:act" mode="DocumentType"/>

			<!-- File Type (always HTML for a care consideration) -->
			<FileType>HTML</FileType>

			<!-- Document Stream -->
			<xsl:apply-templates select="../hl7:text" mode="CareConsiderationNote">
				<xsl:with-param name="documentPosition" select="position()"/>
				<xsl:with-param name="disclaimerPosition" select="$disclaimerPosition"/>
			</xsl:apply-templates>

			<!-- Document Status -->
			<xsl:apply-templates select="hl7:act/hl7:entryRelationship[@typeCode = 'SUBJ']/hl7:observation[hl7:code/@code = 'SEV']/hl7:value" mode="DocumentStatus"/>

			<!-- Clinician -->
			<xsl:apply-templates select="hl7:act/hl7:performer" mode="Clinician"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-CareConsideration"/>
		</Document>
	</xsl:template>

	<xsl:template match="*" mode="DocumentTime">
		<DocumentTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></DocumentTime>
	</xsl:template>
	
	<xsl:template match="*" mode="DocumentNumber">
		<DocumentNumber>
			<xsl:text>CaseID:</xsl:text>
			<xsl:apply-templates select="hl7:id[2]" mode="Id"/>
			<xsl:text>|</xsl:text>
			<xsl:text>TrackingID:</xsl:text>
			<xsl:apply-templates select="hl7:id[1]" mode="Id"/>
		</DocumentNumber>
	</xsl:template>

	<xsl:template match="*" mode="DocumentStatus">
		<Status>
			<Code>AV</Code>
			<Description><xsl:value-of select="@displayName"/></Description>
		</Status>
	</xsl:template>
	
	<xsl:template match="*" mode="DocumentName">
		<DocumentName><xsl:apply-templates select="." mode="TextValue"/></DocumentName>
	</xsl:template>
	
	<xsl:template match="*" mode="DocumentType">
		<DocumentType>
			<SDACodingStandard><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$activeHealthManagementOID"/></xsl:apply-templates></SDACodingStandard>
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
	
	<xsl:template match="*" mode="CareConsiderationNote">
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
		
		<xsl:if test="string-length($careConsideration)"><Stream><xsl:value-of select="isc:evaluate('encode', $careConsideration)"/></Stream></xsl:if>
		
	</xsl:template>

	<xsl:template match="*" mode="Documents">
		<xsl:param name="encounterID"/>
		<xsl:param name="encounterStartDateTime"/>

		<xsl:if test="$nonXMLBodyRootPath">
			<Documents>
				<xsl:if test="$nonXMLBodyRootPath">
					<xsl:for-each select="$nonXMLBodyRootPath">
						<xsl:variable name="fileType">
							<xsl:choose>
								<xsl:when test="contains(hl7:text/@mediaType, 'doc')">DOC</xsl:when>
								<xsl:when test="contains(hl7:text/@mediaType, 'pdf')">PDF</xsl:when>
								<xsl:when test="contains(hl7:text/@mediaType, 'rtf')">RTF</xsl:when>
								<xsl:otherwise>TXT</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<Document>
							<EncounterNumber><xsl:value-of select="$encounterID"/> </EncounterNumber>
							<DocumentName><xsl:value-of select="/hl7:ClinicalDocument/hl7:title/text()"/></DocumentName>
							<FileType><xsl:value-of select="$fileType"/></FileType>
							<xsl:choose>
								<xsl:when test="$fileType = 'TXT'"><NoteText><xsl:value-of select="hl7:text/text()"/></NoteText></xsl:when>
								<xsl:otherwise><Stream><xsl:value-of select="hl7:text/text()"/></Stream></xsl:otherwise>
							</xsl:choose>
						</Document>
					</xsl:for-each>
				</xsl:if>
			</Documents>
		</xsl:if>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry.
	-->
	<xsl:template match="*" mode="ImportCustom-CareConsideration">
	</xsl:template>
	
	<!-- Determine if the Care Considerations section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is the $sectionRootPath for the Care Considerations section.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include care considerations data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-CareConsiderations">
		<xsl:choose>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
