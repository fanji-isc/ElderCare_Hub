<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="familyHistory-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Family Member</th>
						<th>Diagnosis</th>
						<th>Comments</th>
						<th>Start Date</th>
						<th>Stop Date</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="set:distinct(FamilyHistory/FamilyMember/Code)">
						<xsl:variable name="currentFamilyMember" select="text()"/>
						
						<xsl:apply-templates select="/Container/FamilyHistories/FamilyHistory[FamilyMember/Code/text() = $currentFamilyMember]" mode="familyHistory-NarrativeDetail">
							<xsl:with-param name="familyMemberIndex" select="position()"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="familyHistory-NarrativeDetail">
		<xsl:param name="familyMemberIndex"/>
		<xsl:variable name="familyHistoryIndex" select="position()"/>
		
		<tr ID="{concat($exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryNarrative/text(), $familyMemberIndex, '-', $familyHistoryIndex)}">
			<td><xsl:apply-templates select="FamilyMember" mode="descriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryDiagnosis/text(), $familyMemberIndex, '-', $familyHistoryIndex)}"><xsl:apply-templates select="Diagnosis" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryComments/text(), $familyMemberIndex, '-', $familyHistoryIndex)}"><xsl:value-of select="NoteText/text()"/></td>
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="familyHistory-Entries">
		<xsl:apply-templates select="." mode="familyHistory-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="familyHistory-EntryDetail">
		<xsl:for-each select="set:distinct(FamilyHistory/FamilyMember/Code)">
			<xsl:variable name="currentFamilyMember" select="text()"/>

			<entry>
				<organizer classCode="CLUSTER" moodCode="EVN">
					<xsl:apply-templates select="." mode="templateIds-familyHistoryOrganizer"/>
					
					<id root="{isc:evaluate('createUUID')}"/>
					<statusCode code="completed"/>
					
					<!--
						Field : Family History Family Member Relationship
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/subject/relatedSubject/code
						Source: HS.SDA3.FamilyHistory FamilyMember
						Source: /Container/FamilyHistories/FamilyHistory/FamilyMember
						StructuredMappingRef: generic-Coded
					-->
					<xsl:apply-templates select="/Container/FamilyHistories/FamilyHistory[FamilyMember/Code/text() = $currentFamilyMember][1]/FamilyMember" mode="subject"/>
					
					<xsl:apply-templates select="/Container/FamilyHistories/FamilyHistory[FamilyMember/Code/text() = $currentFamilyMember]" mode="familyHistory-observation">
						<xsl:with-param name="familyMemberIndex" select="position()"/>
					</xsl:apply-templates>
				</organizer>
			</entry>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="*" mode="familyHistory-NoData">
		<text><xsl:value-of select="$exportConfiguration/familyHistory/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="familyHistory-observation">
		<xsl:param name="familyMemberIndex"/>
		<xsl:variable name="familyHistoryIndex" select="position()"/>

		<component>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-familyHistoryObservation"/>
				
				<!--
					Field : Family History Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/component/observation/id
					Source: HS.SDA3.FamilyHistory ExternalId
					Source: /Container/FamilyHistories/FamilyHistory/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="id-External"/>

				<code code="ASSERTION" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
				<text><reference value="{concat('#', $exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryDiagnosis/text(), $familyMemberIndex, '-', $familyHistoryIndex)}"/></text>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="." mode="familyHistory-effectiveTime"/>
				
				<!--
					Field : Family History Family Member Condition
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/component/observation/value/text()
					Source: HS.SDA3.FamilyHistory Diagnosis
					Source: /Container/FamilyHistories/FamilyHistory/Diagnosis
				-->
				<xsl:apply-templates select="Diagnosis/Description" mode="value-ST"/>
				
				<!--
					Field : Family History Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/component/observation/author
					Source: HS.SDA3.FamilyHistory EnteredBy
					Source: /Container/FamilyHistories/FamilyHistory/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					Field : Family History Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/component/observation/informant
					Source: HS.SDA3.FamilyHistory EnteredAt
					Source: /Container/FamilyHistories/FamilyHistory/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
					
				<xsl:apply-templates select="Status" mode="observation-familyHistoryStatus"/>
				
				<!--
					Field : Family History Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.FamilyHistory NoteText
					Source: /Container/FamilyHistories/FamilyHistory/NoteText
				-->
				<xsl:apply-templates select="NoteText" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryComments/text(), $familyMemberIndex, '-', $familyHistoryIndex)"/></xsl:apply-templates>
			</observation>
		</component>
	</xsl:template>
	
	<xsl:template match="*" mode="familyHistory-effectiveTime">
		<!--
			Family History IHE PCC Simple Observation (1.3.6.1.4.1.19376.1.5.3.1.4.13)
			wants effectiveTime to be a single value.
		-->
		<xsl:variable name="effectiveTime">
			<xsl:choose>
				<xsl:when test="string-length(FromTime/text())">
					<xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/>
				</xsl:when>
				<xsl:when test="string-length(ToTime/text())">
					<xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Family History effectiveTime should be precise only to the date. -->
		<!--
			Field : Family History Family Member Condition Start Date
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/component/observation/effectiveTime/low/@value
			Source: HS.SDA3.FamilyHistory FromTime
			Source: /Container/FamilyHistories/FamilyHistory/FromTime
			Note  : CDA effectiveTime for Family History uses only one time
					value.  It uses either SDA FromTime or ToTime, whichever
					is found first.
		-->
		<!--
			Field : Family History Family Member Condition End Date
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/component/observation/effectiveTime/high/@value
			Source: HS.SDA3.FamilyHistory ToTime
			Source: /Container/FamilyHistories/FamilyHistory/ToTime
			Note  : CDA effectiveTime for Family History uses only one time
					value.  It uses either SDA FromTime or ToTime, whichever
					is found first.
		-->
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length($effectiveTime)">
					<xsl:attribute name="value"><xsl:value-of select="substring($effectiveTime,1,8)"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise><xsl:attribute name="nullFlavor">UNK</xsl:attribute></xsl:otherwise>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-familyHistoryStatus">
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-familyHistoryStatusObservation"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!--
					FamilyHistory Status is exported as Inactive if the status
					in CDA is I, otherwise it is exported as Active for any
					other CDA status.  SDA FamilyHistory Status is String, so
					this export forces in the SNOMED code system.
				-->
				<xsl:variable name="statusValue" select="translate(text(), $lowerCase, $upperCase)"/>
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<SDACodingStandard><xsl:value-of select="$snomedName"/></SDACodingStandard>
						<Code>
							<xsl:choose>
								<xsl:when test="$statusValue = 'I'">73425007</xsl:when>
								<xsl:otherwise>55561003</xsl:otherwise>
							</xsl:choose>
						</Code>
						<Description>
							<xsl:choose>
								<xsl:when test="$statusValue = 'I'">Inactive</xsl:when>
								<xsl:otherwise>Active</xsl:otherwise>
							</xsl:choose>
						</Description>
					</Status>
				</xsl:variable>
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<!--
					Field : Family History Family Member Problem Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.14']/entry/organizer/component/observation/entryRelationship/observation[code/@code='33999-4']/value/@code
					Source: HS.SDA3.FamilyHistory Status
					Source: /Container/FamilyHistories/FamilyHistory/Status
					Note  : SDA FamilyHistory Status is %String, and so SNOMED
							codeSystem is defaulted in during export to CDA.
				-->
				<xsl:apply-templates select="$status" mode="snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-familyHistoryOrganizer">
		<xsl:if test="$hitsp-CDA-FamilyHistoryOrganizer"><templateId root="{$hitsp-CDA-FamilyHistoryOrganizer}"/></xsl:if>
		<xsl:if test="$hl7-CCD-FamilyHistoryOrganizer"><templateId root="{$hl7-CCD-FamilyHistoryOrganizer}"/></xsl:if>
		<xsl:if test="$ihe-PCC-FamilyHistoryOrganizer"><templateId root="{$ihe-PCC-FamilyHistoryOrganizer}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-familyHistoryObservation">
		<xsl:if test="$hitsp-CDA-FamilyHistory"><templateId root="{$hitsp-CDA-FamilyHistory}"/></xsl:if>
		<xsl:if test="$hl7-CCD-FamilyHistoryObservation"><templateId root="{$hl7-CCD-FamilyHistoryObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SimpleObservations"><templateId root="{$ihe-PCC-SimpleObservations}"/></xsl:if>
		<xsl:if test="$ihe-PCC_CDASupplement-FamilyHistoryObservation"><templateId root="{$ihe-PCC_CDASupplement-FamilyHistoryObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-familyHistoryStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
