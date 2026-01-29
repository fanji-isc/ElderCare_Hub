<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:variable name="labOrderPerformers">
		<xsl:for-each select="set:distinct(/Container/LabOrders/LabOrder//PerformedAt/Code)">1</xsl:for-each>
	</xsl:variable>
	
	<xsl:template match="*" mode="diagnosticResults-Narrative">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Test Description</th>
						<th>Test Time</th>
						<th>Text Results</th>
						<th>Atomic Results</th>
						<th>Result Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="." mode="diagnosticResults-NarrativeDetail"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResults-NarrativeDetail">
		<xsl:param name="narrativeLinkSuffix"/>
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="../OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="ResultTime" mode="narrativeDateFromODBC"/></td>
			<!-- Used at RSNA to deal with HTML content: <td ID="{concat($exportConfiguration/results/narrativeLinkPrefixes/resultText/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="ResultText" mode="copy"/></td> -->
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultText/text(), $narrativeLinkSuffix)}"><xsl:value-of select="ResultText/text()"/></td>
			<xsl:if test="string-length(ResultItems)">
				<td>
					<list><item>
						<table border="1" width="100%">
							<thead>
								<tr>
									<th>Test Item</th>
									<th>Value</th>
									<th>Reference Range</th>
									<th>Comments</th>
								</tr>
							</thead>
							<tbody>
								<xsl:apply-templates select="ResultItems/LabResultItem" mode="diagnosticResults-NarrativeDetail-LabResultItem">
									<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
									<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
								</xsl:apply-templates>
							</tbody>
						</table>
					</item></list>
				</td>
			</xsl:if>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResults-NarrativeDetail-LabResultItem">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:variable name="testItemDescription"><xsl:apply-templates select="TestItemCode" mode="originalTextOrDescriptionOrCode"/></xsl:variable>
		<tr>
			<td><xsl:value-of select="concat($testItemDescription, ' (test code = ', TestItemCode/Code/text(), ')')"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValue/text(), $narrativeLinkSuffix, '-', position())}">
				<xsl:choose>
					<xsl:when test="string-length(ResultValueUnits/text())">
						<xsl:value-of select="concat(ResultValue/text(), ' ', ResultValueUnits/text())"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ResultValue/text()"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td><xsl:value-of select="ResultNormalRange/text()"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValueComments/text(), $narrativeLinkSuffix, '-', position())}"><xsl:value-of select="Comments/text()"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="diagnosticResultsXDLAB-Entries">
		<xsl:param name="narrativeLinkSuffix"/>
		<xsl:apply-templates select="." mode="diagnosticResultsXDLAB-EntryDetail"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
	</xsl:template>
		
	<xsl:template match="*" mode="diagnosticResults-NoData">
		<text><xsl:value-of select="$exportConfiguration/results/emptySection/narrativeText/text()"/></text>
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<templateId root="2.16.840.1.113883.3.88.11.83.15.1"/>
				<templateId root="2.16.840.1.113883.10.20.1.31"/>
				<templateId root="1.3.6.1.4.1.19376.1.5.3.1.4.13"/>
				
				<id nullFlavor="NI"/>
				<code code="ASSERTION" codeSystem="2.16.840.1.113883.5.4"/>
				<text><reference value="#noResults-1"/></text>
				<statusCode code="completed"/>
				<effectiveTime nullFlavor="NI"/>
				<value xsi:type="ST">This patient has no known results.</value>
			</observation>
		</entry>		
	</xsl:template>

	<xsl:template match="*" mode="diagnosticResultsXDLAB-EntryDetail">
		<xsl:param name="narrativeLinkSuffix"/>		
		
		<entry typeCode="DRIV">
			<xsl:apply-templates select="." mode="templateIds-ResultsXDLABEntry"/>

			<act classCode="ACT" moodCode="EVN">
				<code code="26436-6" displayName="LABORATORY STUDIES" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!-- Result Battery -->
				<entryRelationship typeCode="COMP">
					<xsl:apply-templates select="." mode="battery-ResultsXDLAB"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>					
				</entryRelationship>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="battery-ResultsXDLAB">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<organizer classCode="BATTERY" moodCode="EVN">
			<xsl:apply-templates select="." mode="templateIds-LabBatteryOrganizer"/>
			
			<!--
				Field : Result Order Filler Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/id[1]
				Source: HS.SDA3.AbstractOrder FillerId
				Source: /Container/LabOrders/LabOrder/FillerId
				StructuredMappingRef: id-Filler
				Note  : SDA FillerId is exported to CDA id if one of these conditions is met:
						- Both SDA EnteringOrganization/Organization/Code and SDA FillerId have a value
						- Both SDA EnteredAt/Code and SDA FillerId have a value
						
						For example, if EnteringOrganization/Organization/Code equals "CGH", and
						CGH has OID 1.3.6.1.4.1.21367.2010.1.2.300.2.1, and FillerId equals 7676,
						then this is exported
						
						<id root="1.3.6.1.4.1.21367.2010.1.2.300.2.1" extension="7676" assigningAuthorityName="CGH-FillerId"/>
						
						Otherwise, a CDA id is exported with a GUID and some placeholder text.
						For example
						
						<id root="fcbcb478-fceb-11e3-ae03-31c1b7edac00" assigningAuthorityName="CGH-UnspecifiedFillerId"/>
			-->
			<xsl:apply-templates select=".." mode="id-Filler"/>
			
			<!--
				Field : Result Order Code
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/code
				Source: HS.SDA3.AbstractOrder OrderItem
				Source: /Container/LabOrders/LabOrder/OrderItem
				StructuredMappingRef: generic-Coded
			-->
			<xsl:apply-templates select="../OrderItem" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<statusCode code="completed"/>
			
			<!--
				Field : Result Date/Time
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/effectiveTime/@value
				Source: HS.SDA3.Result ResultTime
				Source: /Container/LabOrders/LabOrder/Result/ResultTime
			-->
			<xsl:apply-templates select="." mode="effectiveTime-Result"/>
			
			<xsl:apply-templates select="../Specimen" mode="specimen"/>
			
			<!--
				Field : Result Performer
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/performer
				Source: HS.SDA3.Result PerformedAt
				Source: /Container/LabOrders/LabOrder/Result/PerformedAt
				StructuredMappingRef: performer-PerformedAt-Result
			-->
			<xsl:apply-templates select="PerformedAt" mode="performer-PerformedAt"/>
			
			<!--
				Field : Result Order Author
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/author/author
				Source: HS.SDA3.Result EnteredBy
				Source: /Container/LabOrders/LabOrder/Result/EnteredBy
				StructuredMappingRef: assignedAuthor-Human
			-->
			<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
			
			<!--
				Field : Result Order Information Source
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/informant
				Source: HS.SDA3.Result EnteredAt
				Source: /Container/LabOrders/LabOrder/Result/EnteredAt
				StructuredMappingRef: informant
			-->
			<xsl:apply-templates select="EnteredAt" mode="informant-noPatientIdentifier"/>				
			
			<xsl:apply-templates select="ResultText" mode="results-Text"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="ResultItems/LabResultItem[string-length(ResultValue/text())>0]" mode="results-Atomic"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			
			<!--
				Field : Result Comments
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/component/act[code/@code='48767-8']/text
				Source: HS.SDA3.Result Comments
				Source: /Container/LabOrders/LabOrder/Result/Comments
			-->
			<xsl:apply-templates select="Comments" mode="comment-component"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
		</organizer>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-Result">
		<xsl:choose>
			<xsl:when test="string-length(ResultTime)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="ResultTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="specimen">
		<!--
			Field : Result Specimen
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/specimen/specimenRole/specimenPlayingEntity/code
			Source: HS.SDA3.AbstractOrder Specimen
			Source: /Container/LabOrders/LabOrder/Specimen
			Note  : SDA Specimen is a string property.  However, a Code-and-Description
					may be simulated in the SDA string by using an ampersand-separated
					string.  For example "UR" followed by ampersand followed by "Urine"
					will cause the export of code/@code="UR" and code/@displayName="Urine".
					The Specimen Type OID is forced into code/@codeSystem.
		-->
		<xsl:variable name="specimenCode">
			<xsl:choose>
				<xsl:when test="string-length(substring-before(text(), '&amp;'))">
					<xsl:value-of select="substring-before(text(), '&amp;')"/>
				</xsl:when>
				<xsl:when test="string-length(text())">
					<xsl:value-of select="text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="specimenDescription">
			<xsl:choose>
				<xsl:when test="string-length(substring-after(text(), '&amp;'))">
					<xsl:value-of select="substring-after(text(), '&amp;')"/>
				</xsl:when>
				<xsl:when test="string-length(text())">
					<xsl:value-of select="text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<specimen typeCode="SPC">
			<specimenRole classCode="SPEC">
				<specimenPlayingEntity>
					<!-- Specimen Detail -->
					<xsl:variable name="specimenInformation">
						<Specimen xmlns="">
							<SDACodingStandard><xsl:value-of select="$specimenTypeName"/></SDACodingStandard>
							<Code><xsl:value-of select="$specimenCode"/></Code>
							<Description><xsl:value-of select="$specimenDescription"/></Description>
						</Specimen>
					</xsl:variable>
					<xsl:variable name="specimen" select="exsl:node-set($specimenInformation)/Specimen"/>
					
					<xsl:apply-templates select="$specimen" mode="generic-Coded"/>
				</specimenPlayingEntity>
			</specimenRole>
		</specimen>
	</xsl:template>

	<xsl:template match="*" mode="results-Text">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:if test="(local-name(../../*)='LabOrder') and $ihe-PCC-LaboratoryObservation"><templateId root="{$ihe-PCC-LaboratoryObservation}"/></xsl:if>
				<xsl:apply-templates select="." mode="templateIds-ResultsC32TextReport"/>
				
				<!--
					Field : Result Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/component/observation/id[1]
					Source: HS.SDA3.AbstractOrder ExternalId
					Source: /Container/LabOrders/LabOrder/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="id-External"/>
				
				<!--
					Field : Result Text Result Order Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/component/observation/code
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/LabOrders/LabOrder/OrderItem
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="../../OrderItem" mode="generic-Coded"><xsl:with-param name="isCodeRequired" select="'1'"/></xsl:apply-templates>
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultText/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				<xsl:apply-templates select="parent::node()" mode="effectiveTime-Result"/>
				<value nullFlavor="NA" xsi:type="CD"/>
			</observation>
		</component>
	</xsl:template>

	<xsl:template match="*" mode="results-Atomic">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component typeCode="COMP">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-ResultsAtomicValues"/>
				
				<xsl:apply-templates select="." mode="id-results-Atomic"/>
				
				<!--
					Field : Result Test Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/component/observation/code
					Source: HS.SDA3.LabResultItem TestItemCode
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemCode
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="TestItemCode" mode="generic-Coded">
					<xsl:with-param name="isCodeRequired" select="'1'"/>
				</xsl:apply-templates>
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValue/text(), $narrativeLinkSuffix, '-', position())}"/></text>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="parent::node()/parent::node()" mode="effectiveTime-Result"/>
				
				<xsl:choose>
					<xsl:when test="TestItemCode/IsNumeric/text() = 'true'"><xsl:apply-templates select="ResultValue" mode="value-PQ"><xsl:with-param name="units" select="translate(ResultValueUnits, ' ', '_')"/></xsl:apply-templates></xsl:when>
					<xsl:otherwise><xsl:apply-templates select="ResultValue" mode="value-ST"/></xsl:otherwise>
				</xsl:choose>
				
				<xsl:apply-templates select="ResultInterpretation" mode="results-Interpretation"/>
				
				<!--
					Field : Result Item Performer 
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/performer
					Source: HS.SDA3.Result PerformedAt
					Source: /Container/LabOrders/LabOrder/Result/PerformedAt
					StructuredMappingRef: performer-PerformedAt-Result
				-->
				<xsl:apply-templates select="PerformedAt" mode="performer-PerformedAt"/>
				
				<!--
					Field : Result Atomic Result Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.LabResultItem Comments
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/Comments
				-->
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValueComments/text(), $narrativeLinkSuffix, '-', position())"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="ResultNormalRange" mode="results-ReferenceRange"/>
			</observation>
		</component>
	</xsl:template>
	
	<xsl:template match="*" mode="id-results-Atomic">
		<!--
			Field : Result Atomic Result Id
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/component/observation/id[1]
			Source: HS.SDA3.LabResultItem ExternalId
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ExternalId
			StructuredMappingRef: id-External
		-->
		<xsl:apply-templates select="." mode="id-External"/>
	</xsl:template>
	
	<xsl:template match="*" mode="results-Interpretation">
		<!--
			Field : Result Interpretation
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/component/observation/interpretationCode
			Source: HS.SDA3.LabResultItem ResultInterpretation
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultInterpretation
		-->
		<xsl:variable name="interpretationInformation">
			<Interpretation xmlns="">
				<SDACodingStandard><xsl:value-of select="$observationInterpretationName"/></SDACodingStandard>
				<Code>
					<xsl:choose>
						<xsl:when test="text() = 'A'">A</xsl:when>
						<xsl:when test="text() = 'AA'">A</xsl:when>
						<xsl:when test="text() = 'H'">H</xsl:when>
						<xsl:when test="text() = 'HH'">H</xsl:when>
						<xsl:when test="text() = 'L'">L</xsl:when>
						<xsl:when test="text() = 'LL'">L</xsl:when>
						<xsl:otherwise>N</xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description>
					<xsl:choose>
						<xsl:when test="text() = 'A'">Abnormal</xsl:when>
						<xsl:when test="text() = 'AA'">Abnormal</xsl:when>
						<xsl:when test="text() = 'H'">High</xsl:when>
						<xsl:when test="text() = 'HH'">High</xsl:when>
						<xsl:when test="text() = 'L'">Low</xsl:when>
						<xsl:when test="text() = 'LL'">Low</xsl:when>
						<xsl:otherwise>Normal</xsl:otherwise>
					</xsl:choose>
				</Description>
			</Interpretation>
		</xsl:variable>
		<xsl:variable name="interpretation" select="exsl:node-set($interpretationInformation)/Interpretation"/>
		
		<xsl:apply-templates select="$interpretation" mode="code-interpretation"/>
	</xsl:template>
	
	<xsl:template match="*" mode="results-ReferenceRange">
		<!--
			Field : Result Test Reference Range
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/entryRelationship/organizer/component/observation/referenceRange/observationRange/value
			Source: HS.SDA3.LabResultItem ResultNormalRange
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultNormalRange
		-->
		<referenceRange typeCode="REFV">
			<observationRange classCode="OBS" moodCode="EVN.CRT">
				<xsl:apply-templates select="." mode="results-ReferenceRangeCode"/>
				<xsl:variable name="text"><xsl:value-of select="translate(text(), '()', '')"/></xsl:variable>
				<xsl:variable name="textSub2"><xsl:value-of select="substring($text,2)"/></xsl:variable>
				
				<!-- Number of colons, slashes or dashes in the text. -->
				<xsl:variable name="colons" select="string-length(translate($text,translate($text,':',''),''))"/>
				<xsl:variable name="slashes" select="string-length(translate($text,translate($text,'/',''),''))"/>
				<xsl:variable name="dashes" select="string-length(translate($text,translate($text,'-',''),''))"/>
				
				<!-- number() on 0, 0.0, or 0.00 returns false, so separate tests for those numbers is necessary. -->
				<xsl:variable name="ltgtNumeric">
					<xsl:choose>
						<xsl:when test="$colons>1 or $slashes>1">5</xsl:when>
						<!-- ex: 5.0:6.0 -->
						<xsl:when test="$colons=1">
							<xsl:variable name="beforeColon" select="substring-before($text,':')"/>
							<xsl:variable name="afterColon" select="substring-after($text,':')"/>
							<xsl:choose>
								<xsl:when test="(number($beforeColon) or $beforeColon='0' or $beforeColon='0.0' or $beforeColon='0.00') and (number($afterColon) or $afterColon='0' or $afterColon='0.0' or $afterColon='0.00')">0</xsl:when>
								<xsl:otherwise>5</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- ex: 5.0/6.0 -->
						<xsl:when test="$slashes=1">
							<xsl:variable name="beforeSlash" select="substring-before($text,'/')"/>
							<xsl:variable name="afterSlash" select="substring-after($text,'/')"/>
							<xsl:choose>
								<xsl:when test="(number($beforeSlash) or $beforeSlash='0' or $beforeSlash='0.0' or $beforeSlash='0.00') and (number($afterSlash) or $afterSlash='0' or $afterSlash='0.0' or $afterSlash='0.00')">0</xsl:when>
								<xsl:otherwise>5</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="starts-with($text,'>=') and number(substring-after($text,'>='))">1</xsl:when>
						<xsl:when test="starts-with($text,'=>') and number(substring-after($text,'=>'))">2</xsl:when>
						<xsl:when test="starts-with($text,'&lt;=') and number(substring-after($text,'&lt;='))">3</xsl:when>
						<xsl:when test="starts-with($text,'=&lt;') and number(substring-after($text,'=&lt;'))">4</xsl:when>
						<!-- ex: 5.0-6.0 -->
						<xsl:when test="$dashes=1">
							<xsl:variable name="beforeDash" select="substring-before($text,'-')"/>
							<xsl:variable name="afterDash" select="substring-after($text,'-')"/>
							<xsl:choose>
								<xsl:when test="(number($beforeDash) or $beforeDash='0' or $beforeDash='0.0' or $beforeDash='0.00') and (number($afterDash) or $afterDash='0' or $afterDash='0.0' or $afterDash='0.00')">0</xsl:when>
								<xsl:otherwise>5</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- If more than one dash then the first char must be a dash. -->
						<xsl:when test="$dashes>1 and not(starts-with($text,'-'))">5</xsl:when>
						<!-- If two dashes then left side of a dash must be negative number (ex: -4-3). -->
						<xsl:when test="$dashes=2">
							<xsl:variable name="afterDash2" select="substring-after($textSub2,'-')"/>
							<xsl:choose>
								<xsl:when test="number($afterDash2) or $afterDash2='0' or $afterDash2='0.0' or $afterDash2='0.00'">0</xsl:when>
								<xsl:otherwise>5</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- If three dashes, then must be negative numbers on both sides of a dash (ex: negative 5 to negative 2). -->
						<xsl:when test="$dashes=3">
							<xsl:variable name="beforeDash3" select="substring-before($textSub2,'-')"/>
							<xsl:variable name="afterDash3" select="substring-after($textSub2,'-')"/>
							<xsl:choose>
								<xsl:when test="(number($beforeDash3) or $beforeDash3='0' or $beforeDash3='0.0' or $beforeDash3='0.00') and (number($afterDash3) or $afterDash3='0' or $afterDash3='0.0' or $afterDash3='0.00')">0</xsl:when>
								<xsl:otherwise>5</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="not(number($text))">5</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="parent::node()/TestItemCode/IsNumeric/text() = 'true' and $ltgtNumeric&lt;5">
						<xsl:apply-templates select="." mode="value-IVL_PQ">
							<xsl:with-param name="referenceRangeLowValue">
								<xsl:choose>
									<xsl:when test="$ltgtNumeric='1'"><xsl:value-of select="normalize-space(substring-after($text,'>='))"/></xsl:when>
									<xsl:when test="$ltgtNumeric='2'"><xsl:value-of select="normalize-space(substring-after($text,'=>'))"/></xsl:when>
									<xsl:when test="$ltgtNumeric='3'"></xsl:when>
									<xsl:when test="$ltgtNumeric='4'"></xsl:when>
									<!-- Provide for negative number as low value when dash is delimiter. -->
									<xsl:when test="starts-with($text,'-')">
										<xsl:choose>
											<xsl:when test="contains($textSub2, '-') and not(contains($textSub2, ':')) and not(contains($textSub2, '/'))">
												<xsl:value-of select="concat('-',normalize-space(substring-before($textSub2, '-')))"/>
											</xsl:when>
											<xsl:when test="contains($text, ':')">
												<xsl:value-of select="normalize-space(substring-before($text, ':'))"/>
											</xsl:when>
											<xsl:when test="contains($text, '/')">
												<xsl:value-of select="normalize-space(substring-before($text, '/'))"/>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="contains($text, '-')"><xsl:value-of select="normalize-space(substring-before($text, '-'))"/></xsl:when>
									<xsl:when test="contains($text, ':')"><xsl:value-of select="normalize-space(substring-before($text, ':'))"/></xsl:when>
									<xsl:when test="contains($text, '/')"><xsl:value-of select="normalize-space(substring-before($text, '/'))"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="normalize-space($text)"/></xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="referenceRangeHighValue">
								<xsl:choose>
									<xsl:when test="$ltgtNumeric='1'"></xsl:when>
									<xsl:when test="$ltgtNumeric='2'"></xsl:when>
									<xsl:when test="$ltgtNumeric='3'"><xsl:value-of select="normalize-space(substring-after($text,'&lt;='))"/></xsl:when>
									<xsl:when test="$ltgtNumeric='4'"><xsl:value-of select="normalize-space(substring-after($text,'=&lt;'))"/></xsl:when>
									<!-- Provide for negative number as low value when dash is delimiter. -->
									<xsl:when test="starts-with($text, '-')">
										<xsl:choose>
											<xsl:when test="contains($textSub2, '-') and not(contains($text, ':')) and not(contains($text, '/'))">
												<xsl:value-of select="normalize-space(substring-after($textSub2, '-'))"/>
											</xsl:when>
											<xsl:when test="contains($textSub2, ':')">
												<xsl:value-of select="normalize-space(substring-after($textSub2, ':'))"/>
											</xsl:when>
											<xsl:when test="contains($textSub2, '/')">
												<xsl:value-of select="normalize-space(substring-after($textSub2, '/'))"/>
											</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="contains($text, '-')"><xsl:value-of select="normalize-space(substring-after($text, '-'))"/></xsl:when>
									<xsl:when test="contains($text, ':')"><xsl:value-of select="normalize-space(substring-after($text, ':'))"/></xsl:when>
									<xsl:when test="contains($text, '/')"><xsl:value-of select="normalize-space(substring-after($text, '/'))"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="normalize-space($text)"/></xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="referenceRangeUnits" select="translate(parent::node()/ResultValueUnits/text(),' ','_')"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<text><xsl:value-of select="$text"/></text>
					</xsl:otherwise>
				</xsl:choose>
				
				<interpretationCode code="N" codeSystem="{$observationInterpretationOID}" codeSystemName="{$observationInterpretationName}" displayName="Normal"/>
			</observationRange>
		</referenceRange>
	</xsl:template>
	
	<xsl:template match="*" mode="performer-PerformedAt">
		<!--
			StructuredMapping: performer-PerformedAt-Result
			
			Field
			Path: time/@value
			Source: ParentProperty.EnteredOn
			Source: ../EnteredOn
			
			Field
			Path: assignedEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity
		-->
		<!--
			StructuredMapping: performer-PerformedAt-LabResultItem
			
			Field
			Path: time/low/@value
			Source: ParentProperty.FromTime
			Source: ../FromTime
			
			Field
			Path: time/high/@value
			Source: ParentProperty.ToTime
			Source: ../ToTime
			
			Field
			Path: ./
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity
		-->
		<xsl:if test="string-length($labOrderPerformers)>1">
			<performer typeCode="PRF">
				<xsl:apply-templates select="parent::node()" mode="time"/>
				<xsl:apply-templates select="." mode="assignedEntity">
					<xsl:with-param name="includePatientIdentifier" select="false()"/>
				</xsl:apply-templates>
			</performer>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="results-ReferenceRangeCode">
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-LabBatteryOrganizer">
		<xsl:if test="$ihe-PCC-LabBatteryOrganizer"><templateId root="{$ihe-PCC-LabBatteryOrganizer}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-ResultsAtomicValues">
		<xsl:if test="$ihe-PCC-LaboratoryObservation"><templateId root="{$ihe-PCC-LaboratoryObservation}"/></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-ResultsXDLABEntry">
		<xsl:if test="$ihe-PCC-LaboratoryReportEntry"><templateId root="{$ihe-PCC-LaboratoryReportEntry}" extension="Lab.Report.Data.Processing.Entry"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
