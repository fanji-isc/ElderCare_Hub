<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="advanceDirectives-Narrative">		
		<xsl:param name="validAdvanceDirectives"/>
		
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Directive</th>
						<th>Decision</th>
						<th>Effective Date</th>
						<th>Termination Date</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="AdvanceDirective[(AlertType/SDACodingStandard/text()=$snomedName or AlertType/SDACodingStandard/text()=$snomedOID) and contains(concat('|',$validAdvanceDirectives),concat('|',AlertType/Code/text(),'|'))]" mode="advanceDirectives-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="advanceDirectives-NarrativeDetail">
		<xsl:variable name="isOtherDirective"><xsl:apply-templates select="." mode="OtherDirectiveObservation" /></xsl:variable>
 		<xsl:variable name="hasAlertValue"><xsl:apply-templates select="." mode="HasAlertValue-AdvanceDirective" /></xsl:variable>
		<xsl:if test="$isOtherDirective='false' and $hasAlertValue='true'">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>
			<tr ID="{concat($exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveNarrative/text(), $narrativeLinkSuffix)}">
				<td ID="{concat($exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveType/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="AlertType" mode="descriptionOrCode"/></td>
				<td><xsl:apply-templates select="Alert" mode="descriptionOrCode"/></td>
				<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
				<td ID="{concat($exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="advanceDirectives-Entries">
		<xsl:param name="validAdvanceDirectives"/>
		
		<xsl:apply-templates select="AdvanceDirective[(AlertType/SDACodingStandard/text()=$snomedName or AlertType/SDACodingStandard/text()=$snomedOID) and contains(concat('|',$validAdvanceDirectives),concat('|',AlertType/Code/text(),'|'))]" mode="advanceDirectives-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="advanceDirectives-EntryDetail">
	<xsl:variable name="isOtherDirective"><xsl:apply-templates select="." mode="OtherDirectiveObservation" /></xsl:variable>
	<xsl:variable name="hasAlertValue"><xsl:apply-templates select="." mode="HasAlertValue-AdvanceDirective" /></xsl:variable>
	<xsl:if test="$isOtherDirective='false' and $hasAlertValue='true'">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-AdvanceDirectiveEntry"/>
				
				<!--
					Field : Advance Directive Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/id
					Source: HS.SDA3.AdvanceDirective ExternalId
					Source: /Container/AdvanceDirectives/AdvanceDirective/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="id-External"/>
				
				<xsl:apply-templates select="AlertType" mode="code-AdvanceDirectiveType"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="." mode="effectiveTime-AdvanceDirective"/>
				
				<xsl:apply-templates select="Alert" mode="value-AdvanceDirective">
					<xsl:with-param name="hasAlertValue" select="$hasAlertValue"/>
				</xsl:apply-templates>
				
				<!--
					Field : Advance Directive Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/author
					Source: HS.SDA3.AdvanceDirective EnteredBy
					Source: /Container/AdvanceDirectives/AdvanceDirective/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>

				<!--
					Field : Advance Directive Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/informant
					Source: HS.SDA3.AdvanceDirective EnteredAt
					Source: /Container/AdvanceDirectives/AdvanceDirective/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<xsl:apply-templates select="." mode="participant-AdvanceDirective"/>
				
				<!--
					Field : Advance Directive Free Text Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.AdvanceDirective Comments
					Source: /Container/AdvanceDirectives/AdvanceDirective/Comments
				-->
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			</observation>
		</entry>
	</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="advanceDirectives-NoData">
		<text><xsl:value-of select="$exportConfiguration/advanceDirectives/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="AlertType" mode="code-AdvanceDirectiveType">
		<xsl:param name="narrativeLinkSuffix"/>
		<!--
			Field : Advance Directive Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/code
			Source: HS.SDA3.AdvanceDirective AlertType
			Source: /Container/AdvanceDirectives/AdvanceDirective/AlertType
			StructuredMappingRef: generic-Coded
			Note  : The recommended value set for Advance Directive Type Code is 2.16.840.1.113883.1.11.20.2
					(PHVS_AdvanceDirectiveType_HL7_CCD).  All codes are from SNOMED CT.
					304251008  Resuscitation
					52765003   Intubation
					225204009  IV Fluid and Support
					89666000   CPR
					281789004  Antibiotics
					78823007   Life Support
					61420007   Tube Feedings
					
					The code list is defined and configurable in ExportProfile.xml.
		-->
		<xsl:apply-templates select="." mode="generic-Coded">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveType/text(), $narrativeLinkSuffix)"/>
			<xsl:with-param name="requiredCodeSystemOID" select="$snomedOID"/>
			<xsl:with-param name="isCodeRequired" select="'1'"/>
			<xsl:with-param name="writeOriginalText" select="'1'"/>
			<xsl:with-param name="cdaElementName" select="'code'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="Alert" mode="value-AdvanceDirective">
		<xsl:param name="hasAlertValue"/>
		<!--
			Field : Advance Directive Value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/value
			Source: HS.SDA3.AdvanceDirective Alert
			Source: /Container/AdvanceDirectives/AdvanceDirective/Alert
			StructuredMappingRef: generic-Coded
			Note  : We only allow xsi:type="CD" with a SNOMED CT coded value
		-->
		<xsl:choose>
			<xsl:when test="$hasAlertValue='true'">
				<xsl:apply-templates select="." mode="generic-Coded">
					<xsl:with-param name="xsiType">CD</xsl:with-param>
					<xsl:with-param name="requiredCodeSystemOID" select="$snomedOID"/>
					<xsl:with-param name="isCodeRequired" select="'1'"/>
					<xsl:with-param name="writeOriginalText" select="'1'"/>
					<xsl:with-param name="cdaElementName" select="'value'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Custodian:  name, address, or other contact information for the person or organization that can provide a copy of the document -->
	<xsl:template match="*" mode="participant-AdvanceDirective">
		<participant typeCode="CST">
			<participantRole classCode="AGNT">
				<playingEntity>
					<name nullFlavor="UNK"/>
				</playingEntity>
			</participantRole>
		</participant>
	</xsl:template>

	<xsl:template match="*" mode="effectiveTime-AdvanceDirective">
		<!--
			Field : Advance Directive Effective Date - Start
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/effectiveTime/low/@value
			Source: HS.SDA3.AdvanceDirective FromTime
			Source: /Container/AdvanceDirectives/AdvanceDirective/FromTime
			Note  : CDA effectiveTime for Advance Directive uses SDA FromTime for low, or if SDA FromTime is empty, uses /low/@nullFlavor="UNK"
		-->
		<!--
			Field : Advance Directive Effective Date - End
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.35']/entry/observation/effectiveTime/high/@value
			Source: HS.SDA3.AdvanceDirective ToTime
			Source: /Container/AdvanceDirectives/AdvanceDirective/ToTime
			Note  : CDA effectiveTime for Advance Directive uses SDA ToTime for high, or if SDA ToTime is empty, uses /high/@nullFlavor="UNK"
		-->
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(FromTime/text())">
					<low><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low>
				</xsl:when>
				<xsl:otherwise>
					<low nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="string-length(ToTime/text())">
					<high><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></high>
				</xsl:when>
				<xsl:when test="not(string-length(ToTime/text()))">
					<high nullFlavor="UNK"/>
				</xsl:when>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-AdvanceDirectiveEntry">
		<xsl:if test="$hitsp-CDA-AdvanceDirective"><templateId root="{$hitsp-CDA-AdvanceDirective}"/></xsl:if>
		<xsl:if test="$hl7-CCD-AdvanceDirectiveObservation"><templateId root="{$hl7-CCD-AdvanceDirectiveObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SimpleObservations"><templateId root="{$ihe-PCC-SimpleObservations}"/></xsl:if>
		<xsl:if test="$ihe-PCC_CDASupplement-AdvanceDirectiveObservation"><templateId root="{$ihe-PCC_CDASupplement-AdvanceDirectiveObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="OtherDirectiveObservation">
		<xsl:value-of select="contains('|71388002|AD|', concat('|', AlertType/Code/text(), '|'))"/>
   	</xsl:template>
   	
   	<xsl:template match="*" mode="HasAlertValue-AdvanceDirective">
		<xsl:variable name="codeUpper" select="translate(Alert/Code/text(), $lowerCase, $upperCase)"/>
		<xsl:variable name="descUpper" select="translate(Alert/Description/text(), $lowerCase, $upperCase)"/>
			<xsl:value-of select="(string-length($codeUpper)&gt;0) and not(contains('|N|NO|Y|YES|T|TRUE|F|FALSE|',concat('|',$codeUpper,'|'))) and not(contains('|N|NO|Y|YES|T|TRUE|F|FALSE|',concat('|',$descUpper,'|')))"/>
   	</xsl:template>

</xsl:stylesheet>
