<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
  <!-- AlsoInclude: AuthorParticipation.xsl Comment.xsl -->
	
	<xsl:template match="AdvanceDirectives" mode="eAD-advanceDirectives-Narrative">		
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
					<xsl:apply-templates select="AdvanceDirective[(AlertType/SDACodingStandard/text()=$snomedName or AlertType/SDACodingStandard/text()=$snomedOID) and contains($validAdvanceDirectives,concat('|',AlertType/Code/text(),'|'))]" mode="eAD-advanceDirectives-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="AdvanceDirective" mode="eAD-advanceDirectives-NarrativeDetail">
		<xsl:variable name="isOtherDirective"><xsl:apply-templates select="." mode="eAD-OtherDirectiveObservation" /></xsl:variable>
 		<xsl:variable name="hasAlertValue"><xsl:apply-templates select="." mode="eAD-HasAlertValue-AdvanceDirective" /></xsl:variable>
		<xsl:if test="$isOtherDirective='false' and $hasAlertValue='true'">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>
			<tr ID="{concat($exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveNarrative/text(), $narrativeLinkSuffix)}">
				<td ID="{concat($exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveType/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="AlertType" mode="fn-descriptionOrCode"/></td>
				<td><xsl:apply-templates select="Alert" mode="fn-descriptionOrCode"/></td>
				<td><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="ToTime" mode="fn-narrativeDateFromODBC"/></td>
				<td ID="{concat($exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="AdvanceDirectives" mode="eAD-advanceDirectives-Entries">
		<xsl:param name="validAdvanceDirectives"/>
		
		<xsl:apply-templates select="AdvanceDirective[(AlertType/SDACodingStandard/text()=$snomedName or AlertType/SDACodingStandard/text()=$snomedOID) and contains($validAdvanceDirectives,concat('|',AlertType/Code/text(),'|'))]" mode="eAD-advanceDirectives-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="AdvanceDirective" mode="eAD-advanceDirectives-EntryDetail">
	<xsl:variable name="isOtherDirective"><xsl:apply-templates select="." mode="eAD-OtherDirectiveObservation" /></xsl:variable>
	<xsl:variable name="hasAlertValue"><xsl:apply-templates select="." mode="eAD-HasAlertValue-AdvanceDirective" /></xsl:variable>
	<xsl:if test="$isOtherDirective='false' and $hasAlertValue='true'">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eAD-templateIds-AdvanceDirectiveEntry"/>
				
				<!--
					Field : Advance Directive Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/id
					Source: HS.SDA3.AdvanceDirective ExternalId
					Source: /Container/AdvanceDirectives/AdvanceDirective/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="fn-id-External"/>
				
				<xsl:apply-templates select="AlertType" mode="eAD-code-AdvanceDirectiveType"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				
				<statusCode code="completed"/>
				
				<!--
					Field : Advance Directive Effective Date - Start
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/effectiveTime/low/@value
					Source: HS.SDA3.AdvanceDirective FromTime
					Source: /Container/AdvanceDirectives/AdvanceDirective/FromTime
					Note  : CDA effectiveTime for Advance Directive uses SDA FromTime for low, or if SDA FromTime is empty, uses /low/@nullFlavor="NA"
				-->
				<!--
					Field : Advance Directive Effective Date - End
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/effectiveTime/high/@value
					Source: HS.SDA3.AdvanceDirective ToTime
					Source: /Container/AdvanceDirectives/AdvanceDirective/ToTime
					Note  : CDA effectiveTime for Advance Directive uses SDA ToTime for high, or if SDA ToTime is empty, uses /high/@nullFlavor="NA"
				-->
				<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo">
					<xsl:with-param name="includeHighTime" select="true()"/>
					<xsl:with-param name="paramNullFlavor" select="'NA'"/>
				</xsl:apply-templates>

				<xsl:apply-templates select="Alert" mode="eAD-value-AdvanceDirective">
					<xsl:with-param name="hasAlertValue" select="$hasAlertValue"/>
				</xsl:apply-templates>
				
				<!--
					Field : Advance Directive Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/author
					Source: HS.SDA3.AdvanceDirective EnteredBy
					Source: /Container/AdvanceDirectives/AdvanceDirective/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				
				<!--
					Field : Advance Directive Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/informant
					Source: HS.SDA3.AdvanceDirective EnteredAt
					Source: /Container/AdvanceDirectives/AdvanceDirective/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<xsl:apply-templates select="." mode="eAD-participant-AdvanceDirective"/>
				
				<!--
					Field : Advance Directive Free Text Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.AdvanceDirective Comments
					Source: /Container/AdvanceDirectives/AdvanceDirective/Comments
				-->
				<xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveComments/text(), $narrativeLinkSuffix)"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="." mode="eAD-reference-AdvanceDirective"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			</observation>
		</entry>
	</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="eAD-advanceDirectives-NoData">
		<text><xsl:value-of select="$exportConfiguration/advanceDirectives/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="AlertType" mode="eAD-code-AdvanceDirectiveType">
		<xsl:param name="narrativeLinkSuffix"/>
		<!--
			Field : Advance Directive Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/code
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
		<xsl:variable name="descValue"><xsl:apply-templates select="." mode="fn-descriptionOrCode"/></xsl:variable>
		<code codeSystem="2.16.840.1.113883.6.96" codeSystemName="SCT">
			<xsl:attribute name="code"><xsl:value-of select="Code/text()"/></xsl:attribute>
			<xsl:attribute name="displayName"><xsl:value-of select="$descValue"/></xsl:attribute>
			<xsl:attribute name="codeSystemName"><xsl:value-of select="$snomedName"/></xsl:attribute>
			<xsl:attribute name="codeSystem"><xsl:value-of select="$snomedOID"/></xsl:attribute>
			<originalText>
				<reference>
					<xsl:attribute name="value">
						<xsl:value-of select="concat('#', $exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveType/text(), $narrativeLinkSuffix)"/>
					</xsl:attribute>
				</reference>
			</originalText>
			<!-- 
				CCDA 2.1 Implementation Guide Section 3.2 item 5a states that 
				Advance Directive Observation SHALL have this translation element cardinality [1..1].
				Due to that required constraint, PriorCodes from SDA AlertType will not be used in the code element.
			-->
			<translation code="75320-2" displayName="Advance Directive" codeSystemName="{$loincName}" codeSystem="{$loincOID}"/>
		</code>
	</xsl:template>
	
	<xsl:template match="Alert" mode="eAD-value-AdvanceDirective">
		<xsl:param name="hasAlertValue"/>
		<!--
			Field : Advance Directive Value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.21.1']/entry/observation/value
			Source: HS.SDA3.AdvanceDirective Alert
			Source: /Container/AdvanceDirectives/AdvanceDirective/Alert
			StructuredMappingRef: generic-Coded
			Note  : We only allow xsi:type="CD" with a SNOMED CT coded value
		-->
		<xsl:choose>
			<xsl:when test="$hasAlertValue='true'">
				<xsl:apply-templates select="." mode="fn-generic-Coded">
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
	<xsl:template match="AdvanceDirective" mode="eAD-participant-AdvanceDirective">
		<participant typeCode="CST">
			<xsl:call-template name="eAD-templateIds-AdvanceDirectiveParticipant"/>
			<participantRole classCode="AGNT">
				<playingEntity>
					<name nullFlavor="UNK"/>
				</playingEntity>
			</participantRole>
		</participant>
	</xsl:template>
	
	<xsl:template match="AdvanceDirective" mode="eAD-reference-AdvanceDirective">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<!-- For now we only support AD code and description, and point to the narrative for text. -->
		<reference typeCode="REFR">
			<seperatableInd value="false"/>
			<externalDocument>
				<id root="{isc:evaluate('createUUID')}"/>
				<text mediaType="text/html">
					<reference value="{concat('#', $exportConfiguration/advanceDirectives/narrativeLinkPrefixes/advanceDirectiveNarrative/text(), $narrativeLinkSuffix)}"/>
				</text>
			</externalDocument>
		</reference>
	</xsl:template>
	
	<!-- The eAD-effectiveTime-AdvanceDirective mode is no longer used. Use fn-effectiveTime-FromTo instead. -->
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eAD-templateIds-AdvanceDirectiveEntry">
		<templateId root="{$ccda-AdvanceDirectiveObservation}"/>
		<templateId root="{$ccda-AdvanceDirectiveObservation}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eAD-templateIds-AdvanceDirectiveParticipant">
		<templateId root="{$ccda-AdvanceDirectiveParticipant}"/>
		<templateId root="{$ccda-AdvanceDirectiveParticipant}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template match="*" mode="eAD-OtherDirectiveObservation">
		<xsl:value-of select="contains('|71388002|AD|', concat('|', AlertType/Code/text(), '|'))"/>
   	</xsl:template>
   	
   	<xsl:template match="*" mode="eAD-HasAlertValue-AdvanceDirective">
		<xsl:variable name="codeUpper" select="translate(Alert/Code/text(), $lowerCase, $upperCase)"/>
		<xsl:variable name="descUpper" select="translate(Alert/Description/text(), $lowerCase, $upperCase)"/>
			<xsl:value-of select="(string-length($codeUpper)&gt;0) and not(contains('|N|NO|Y|YES|T|TRUE|F|FALSE|',concat('|',$codeUpper,'|'))) and not(contains('|N|NO|Y|YES|T|TRUE|F|FALSE|',concat('|',$descUpper,'|')))"/>
   	</xsl:template>
</xsl:stylesheet>
