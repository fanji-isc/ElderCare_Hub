<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="socialHistory-Narrative">
		<table border="1" width="100%">
			<thead>
				<tr>
					<th>Social Habit</th>
					<th>Comments</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="SocialHistory" mode="socialHistory-NarrativeDetail"/>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="*" mode="socialHistory-NarrativeDetail">
		<tr ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryNarrative/text(), position())}">
			<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), position())}"><xsl:apply-templates select="SocialHabit" mode="descriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryComments/text(), position())}"><xsl:value-of select="SocialHabitComments/text()"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="socialHistory-Entries">
		<xsl:apply-templates select="SocialHistory" mode="socialHistory-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-socialHistoryEntry"/>
				
				<!--
					Field : Social History Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/id
					Source: HS.SDA3.SocialHistory ExternalId
					Source: /Container/SocialHistories/SocialHistory/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="id-External"/>
				
				<!--
					Field : Social History Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/code
					Source: HS.SDA3.SocialHistory SocialHabit
					Source: /Container/SocialHistories/SocialHistory/SocialHabit
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="SocialHabit" mode="generic-Coded"/>
				
				<text><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
					Field : Social History Start Date
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/effectiveTime/low/@value
					Source: HS.SDA3.SocialHistory FromTime
					Source: /Container/SocialHistories/SocialHistory/FromTime
				-->
				<!--
					Field : Social History End Date
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/effectiveTime/high/@value
					Source: HS.SDA3.SocialHistory ToTime
					Source: /Container/SocialHistories/SocialHistory/ToTime
				-->
				<xsl:apply-templates select="." mode="socialHistory-effectiveTime"/>
				
				<!--
					Field : Social History Social Habit Quantity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/value/text()
					Source: HS.SDA3.SocialHistory SocialHabitQty.Description
					Source: /Container/SocialHistories/SocialHistory/SocialHabitQty/Description
				-->
				<xsl:choose>
					<xsl:when test="string-length(SocialHabitQty/Description)">
						<xsl:apply-templates select="SocialHabitQty/Description" mode="value-ST"/>
					</xsl:when>
					<xsl:otherwise><xsl:apply-templates select="SocialHabitQty/Code" mode="value-ST"/></xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Social History Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/author
					Source: HS.SDA3.SocialHistory EnteredBy
					Source: /Container/SocialHistories/SocialHistory/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					Field : Social History Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/informant
					Source: HS.SDA3.SocialHistory EnteredAt
					Source: /Container/SocialHistories/SocialHistory/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
							
				<xsl:apply-templates select="Status" mode="observation-socialHistoryStatus"/>
				
				<!--
					Field : Social History Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.SocialHistory SocialHabitComments
					Source: /Container/SocialHistories/SocialHistory/SocialHabitComments
				-->
				<xsl:apply-templates select="SocialHabitComments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			</observation>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="socialHistory-NoData">
		<text><xsl:value-of select="$exportConfiguration/socialHistory/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-effectiveTime">
		<!--
			Social History IHE PCC Simple Observation (1.3.6.1.4.1.19376.1.5.3.1.4.13)
			wants effectiveTime to be a single value.
		-->
		
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(FromTime/text())">
					<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="string-length(ToTime/text())">
					<xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise><xsl:attribute name="nullFlavor">UNK</xsl:attribute></xsl:otherwise>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-socialHistoryStatus">
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-socialHistoryStatusObservation"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!-- Status Detail -->
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
					Field : Social History Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation/entryRelationship/observation[code/@code='33999-4']/value/@code
					Source: HS.SDA3.SocialHistory Status
					Source: /Container/SocialHistories/SocialHistory/Status
					Note  : SDA SocialHistory Status value of I is exported
							as CDA value for Inactive, and all other Status
							values are exported as CDA value for Active.
							Because SDA SocialHistory Status is %String,
							export automatically populates the the SNOMED
							code system in for this value.
				-->
				<xsl:apply-templates select="$status" mode="snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="GenderIdentity" mode="socialHistory-Narrative-GenderIdentity">
		<xsl:param name="genderIdentityDate"/>
		
		<xsl:variable name="narrativeLinkSuffix">G</xsl:variable>
		<table border="1" width="100%">
			<thead>
				<tr>
					<th>Social History</th>
					<th>Observation</th>
					<th>Date</th>
				</tr>
			</thead>
			<tbody>
				<tr ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryNarrative/text(), $narrativeLinkSuffix)}">
					<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}">Gender identity</td>
					<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryObservation/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="descriptionOrCode"/></td>
					<td><xsl:apply-templates select="$genderIdentityDate" mode="narrativeDateFromODBC"/></td>
				</tr>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="GenderIdentity" mode="socialHistory-GenderIdentity-EntryDetail">
		<xsl:param name="genderIdentityDate"/>
		
		<xsl:variable name="narrativeLinkSuffix">G</xsl:variable>
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-socialHistoryEntry"/>
				<code code="76691-5" displayName="Gender identity">
					<originalText><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}"/></originalText>
				</code>
				<text><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>

				<xsl:if test="string-length($genderIdentityDate)">
					<effectiveTime xsi:type="IVL_TS">
						<low><xsl:attribute name="value"><xsl:apply-templates select="$genderIdentityDate" mode="xmlToHL7TimeStamp"/></xsl:attribute></low>
					</effectiveTime>
				</xsl:if>

				<!--
					Field : Patient GenderIdentity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.16']/entry/observation[code/@code='76691-5']/value
					Source: HS.SDA3.Patient GenderIdentity
					Source: /Container/Patient/GenderIdentity
				-->
				<value>
					<xsl:attribute name="code"><xsl:value-of select="Code/text()"/></xsl:attribute>
					<xsl:attribute name="displayName"><xsl:value-of select="Description/text()"/></xsl:attribute>
					<xsl:attribute name="codeSystem"><xsl:value-of select="SDACodingStandard/text()"/></xsl:attribute>
					<originalText><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryObservation/text(), $narrativeLinkSuffix)}"/></originalText>
				</value>
			</observation>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-socialHistoryEntry">
		<xsl:if test="$hitsp-CDA-SocialHistory"><templateId root="{$hitsp-CDA-SocialHistory}"/></xsl:if>
		<xsl:if test="$hl7-CCD-SocialHistoryObservation"><templateId root="{$hl7-CCD-SocialHistoryObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SimpleObservations"><templateId root="{$ihe-PCC-SimpleObservations}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SocialHistoryObservation"><templateId root="{$ihe-PCC-SocialHistoryObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-socialHistoryStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-SocialHistoryStatusObservation"><templateId root="{$hl7-CCD-SocialHistoryStatusObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
