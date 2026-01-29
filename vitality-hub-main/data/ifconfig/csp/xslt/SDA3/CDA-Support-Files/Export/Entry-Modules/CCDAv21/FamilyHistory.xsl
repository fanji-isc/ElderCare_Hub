<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc exsl set">
  <!-- AlsoInclude: AuthorParticipation.xsl Comment.xsl -->
	
	<xsl:key name="FamilyHistoryByMember" match="/Container/FamilyHistories/FamilyHistory" use="FamilyMember/Code"/>
  <xsl:key name="FamilyHistoryByMember" match="/Container" use="'NEVER_MATCH_THIS!'"/>
  <!-- Second line in the above key is to ensure that the "key table" is populated
       with at least one row, but we never want to retrieve that row. -->
  
	<xsl:template match="*" mode="eFH-familyHistory-Narrative">
		<xsl:param name="docs"/>

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
						
						<xsl:apply-templates select="key('FamilyHistoryByMember',$currentFamilyMember)" mode="eFH-familyHistory-NarrativeDetail">
							<xsl:with-param name="familyMemberIndex" select="position()"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</tbody>
			</table>

			<!-- structured narrative documents -->
			<xsl:apply-templates mode="narrative-export-documents" select="..">
				<xsl:with-param name="docs" select="$docs"/>
				<xsl:with-param name="header" select="$exportConfiguration/narrative/section[templateId/@root=$ccda-FamilyHistorySection]/title/text()"/>
			</xsl:apply-templates>

		</text>
	</xsl:template>

	<xsl:template match="FamilyHistory" mode="eFH-familyHistory-NarrativeDetail">
		<xsl:param name="familyMemberIndex"/>
		<xsl:variable name="familyHistoryIndex" select="position()"/>
		
		<tr ID="{concat($exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryNarrative/text(), $familyMemberIndex, '-', $familyHistoryIndex)}">
			<td><xsl:apply-templates select="FamilyMember" mode="fn-descriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryDiagnosis/text(), $familyMemberIndex, '-', $familyHistoryIndex)}"><xsl:apply-templates select="Diagnosis" mode="fn-originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryComments/text(), $familyMemberIndex, '-', $familyHistoryIndex)}"><xsl:value-of select="NoteText/text()"/></td>
			<td><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="fn-narrativeDateFromODBC"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="eFH-familyHistory-Entries">
		<xsl:apply-templates select="." mode="eFH-familyHistory-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="FamilyHistories" mode="eFH-familyHistory-EntryDetail">
		<xsl:for-each select="set:distinct(FamilyHistory/FamilyMember/Code)">
			<xsl:variable name="currentFamilyMember" select="text()"/>

			<entry>
				<organizer classCode="CLUSTER" moodCode="EVN">
					<xsl:call-template name="eFH-templateIds-familyHistoryOrganizer"/>
					
					<id root="{isc:evaluate('createUUID')}"/>
					<statusCode code="completed"/>
					
					<!--
						Field : Family History Family Member Relationship
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/subject/relatedSubject/code
						Source: HS.SDA3.FamilyHistory FamilyMember
						Source: /Container/FamilyHistories/FamilyHistory/FamilyMember
						StructuredMappingRef: generic-Coded
					-->
					<xsl:apply-templates select="key('FamilyHistoryByMember',$currentFamilyMember)[1]/FamilyMember" mode="fn-subject"/>
					
					<xsl:apply-templates select="key('FamilyHistoryByMember',$currentFamilyMember)" mode="eFH-familyHistory-observation">
						<xsl:with-param name="familyMemberIndex" select="position()"/>
					</xsl:apply-templates>
				</organizer>
			</entry>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="*" mode="eFH-familyHistory-NoData">
		<text><xsl:value-of select="$exportConfiguration/familyHistory/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="FamilyHistory" mode="eFH-familyHistory-observation">
		<xsl:param name="familyMemberIndex"/>
		<xsl:variable name="familyHistoryIndex" select="position()"/>

		<component>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eFH-templateIds-familyHistoryObservation"/>
				
				<!--
					Field : Family History Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/id
					Source: HS.SDA3.FamilyHistory ExternalId
					Source: /Container/FamilyHistories/FamilyHistory/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="fn-id-External"/>

				<!--
					In C-CDA, code here is Problem Type. Export is hard-coded
					to Condition because SDA Family History does not have a
					Problem Type property.
				-->
				<code code="64572001" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="Condition">
					<translation code="75323-6" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Condition"/>
				</code>
				<text><reference value="{concat('#', $exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryDiagnosis/text(), $familyMemberIndex, '-', $familyHistoryIndex)}"/></text>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="." mode="eFH-familyHistory-effectiveTime"/>
				
				<!--
					Field : Family History Family Member Condition
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/value
					Source: HS.SDA3.FamilyHistory Diagnosis
					Source: /Container/FamilyHistories/FamilyHistory/Diagnosis
					StructuredMappingRef: value-Coded
				-->
				<xsl:apply-templates select="Diagnosis" mode="fn-value-Coded">
					<xsl:with-param name="xsiType" select="'CD'"/>
					<xsl:with-param name="requiredCodeSystemOID" select="$snomedOID"/>
					<xsl:with-param name="isCodeRequired" select="'1'"/>
				</xsl:apply-templates>
				
				<!--
					Field : Family History Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/author
					Source: HS.SDA3.FamilyHistory EnteredBy
					Source: /Container/FamilyHistories/FamilyHistory/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				
				<!--
					Field : Family History Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/informant
					Source: HS.SDA3.FamilyHistory EnteredAt
					Source: /Container/FamilyHistories/FamilyHistory/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<xsl:apply-templates select="Status" mode="eFH-observation-familyHistoryStatus"/>
				
				<!--
					Field : Family History Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.FamilyHistory NoteText
					Source: /Container/FamilyHistories/FamilyHistory/NoteText
				-->
				<xsl:apply-templates select="NoteText" mode="eCm-entryRelationship-comments">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/familyHistory/narrativeLinkPrefixes/familyHistoryComments/text(), $familyMemberIndex, '-', $familyHistoryIndex)"/>
				</xsl:apply-templates>
			</observation>
		</component>
	</xsl:template>
	
	<xsl:template match="FamilyHistory" mode="eFH-familyHistory-effectiveTime">
		<!-- C-CDA Family History effectiveTime can be TS or IVL_TS. -->
		<xsl:variable name="effectiveTimeLow"><xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/></xsl:variable>
		<xsl:variable name="effectiveTimeHigh"><xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/></xsl:variable>
		<xsl:variable name="hasLow" select="string-length($effectiveTimeLow) &gt; 0"/>
		<xsl:variable name="hasHigh" select="string-length($effectiveTimeHigh) &gt; 0"/>
		
		<!-- Family History effectiveTime should be precise only to the date. -->
		<!--
			Field : Family History Family Member Condition Start Date
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/effectiveTime/low/@value
			Source: HS.SDA3.FamilyHistory FromTime
			Source: /Container/FamilyHistories/FamilyHistory/FromTime
			Note  : If only one of FromTime or ToTime is present then
					that single time is exported only at effectiveTime/@value.
		-->
		<!--
			Field : Family History Family Member Condition End Date
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/effectiveTime/high/@value
			Source: HS.SDA3.FamilyHistory ToTime
			Source: /Container/FamilyHistories/FamilyHistory/ToTime
			Note  : If only one of FromTime or ToTime is present then
					that single time is exported only at effectiveTime/@value.
		-->
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="$hasLow">
					<xsl:choose>
						<xsl:when test="$hasHigh and not($effectiveTimeLow=$effectiveTimeHigh)">
							<low>
								<xsl:attribute name="value"><xsl:value-of select="substring($effectiveTimeLow,1,8)"/></xsl:attribute>
							</low>
							<high>
								<xsl:attribute name="value"><xsl:value-of select="substring($effectiveTimeHigh,1,8)"/></xsl:attribute>
							</high>
						</xsl:when>
						<xsl:when test="$effectiveTimeLow=$effectiveTimeHigh">
							<xsl:attribute name="value"><xsl:value-of select="substring($effectiveTimeLow,1,8)"/></xsl:attribute>
						</xsl:when>
						<xsl:when test="not($hasHigh)">
							<xsl:attribute name="value"><xsl:value-of select="substring($effectiveTimeLow,1,8)"/></xsl:attribute>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="not($hasLow) and $hasHigh">
					<xsl:attribute name="value"><xsl:value-of select="substring($effectiveTimeHigh,1,8)"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise><xsl:attribute name="nullFlavor">UNK</xsl:attribute></xsl:otherwise>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="Status" mode="eFH-observation-familyHistoryStatus">
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eFH-templateIds-familyHistoryStatusObservation"/>
				
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
				
				<!--
					Field : Family History Family Member Problem Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.15']/entry/organizer/component/observation/entryRelationship/observation[code/@code='33999-4']/value
					Source: HS.SDA3.FamilyHistory Status
					Source: /Container/FamilyHistories/FamilyHistory/Status
					StructuredMappingRef: snomed-Status
					Note  : SDA FamilyHistory Status is %String, and so SNOMED
							codeSystem is defaulted in during export to CDA.
				-->
				<xsl:apply-templates select="exsl:node-set($statusInformation)/Status" mode="fn-snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eFH-templateIds-familyHistoryOrganizer">
		<templateId root="{$ccda-FamilyHistoryOrganizer}"/>
		<templateId root="{$ccda-FamilyHistoryOrganizer}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eFH-templateIds-familyHistoryObservation">
		<templateId root="{$ccda-FamilyHistoryObservation}"/>
		<templateId root="{$ccda-FamilyHistoryObservation}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eFH-templateIds-familyHistoryStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/>
<templateId root="{$hl7-CCD-StatusObservation}" extension="2015-08-01"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
