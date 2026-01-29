<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="xsi exsl">
  <!-- AlsoInclude: AuthorParticipation.xsl Comment.xsl -->

	<xsl:template match="*" mode="eR-diagnosticResults-Narrative">
		<xsl:param name="orderType"/>
		<xsl:param name="resultList"/>
		
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Test Description</th>
						<th>Test Time</th>
						<th>Test Comments</th>
						<th>Text Results</th>
						<th>Atomic Results</th>
						<th>Result Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="$resultList" mode="eR-diagnosticResults-NarrativeDetail">
						<xsl:sort select="ResultTime" order="descending"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="eR-diagnosticResults-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		

		<!--
			The NIST MU2 C-CDA validator logs an error if an @ID has
			no reference/@value pointing to it.  Export @ID only if
			the particular item in the narrative has a value.
		-->
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="../OrderItem" mode="fn-originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="ResultTime" mode="fn-narrativeDateFromODBC"/></td>
			<xsl:choose>
				<xsl:when test="string-length(../Comments/text())">
					<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="../Comments/text()"/></td>
				</xsl:when>
				<xsl:otherwise><td/></xsl:otherwise>
			</xsl:choose>
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
								<xsl:apply-templates select="ResultItems/LabResultItem" mode="eR-diagnosticResults-NarrativeDetail-LabResultItem">
									<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
									<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
								</xsl:apply-templates>
							</tbody>
						</table>
					</item></list>
				</td>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="string-length(Comments/text())">
					<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
				</xsl:when>
				<xsl:otherwise><td/></xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>
	
	<xsl:template match="LabResultItem" mode="eR-diagnosticResults-NarrativeDetail-LabResultItem">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:variable name="testItemDescription"><xsl:apply-templates select="TestItemCode" mode="fn-originalTextOrDescriptionOrCode"/></xsl:variable>
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
			<xsl:choose>
				<xsl:when test="string-length(Comments/text())">
					<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValueComments/text(), $narrativeLinkSuffix, '-', position())}"><xsl:value-of select="Comments/text()"/></td>
				</xsl:when>
				<xsl:otherwise><td/></xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="eR-diagnosticResults-Entries">
		<xsl:param name="resultList"/>

		<xsl:apply-templates select="$resultList" mode="eR-diagnosticResults-EntryDetail">
			<xsl:sort select="ResultTime" order="descending"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="eR-diagnosticResults-NoData">
		<text><xsl:value-of select="$exportConfiguration/results/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="Result" mode="eR-diagnosticResults-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry>
			<!-- Result Battery -->
			<xsl:apply-templates select="." mode="eR-battery-Results"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
		</entry>
	</xsl:template>
	
	<xsl:template match="Result" mode="eR-battery-Results">
		<xsl:param name="narrativeLinkSuffix"/>
				
		<organizer classCode="BATTERY" moodCode="EVN">
			<xsl:call-template name="eR-templateIds-ResultsOrganizer"/>
			
			<!--
				Field : Result Order Filler Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/id[1]
				Source: HS.SDA3.AbstractOrder FillerId
				Source: /Container/LabOrders/LabOrder/FillerId
				Source: /Container/RadOrders/RadOrder/FillerId
				Source: /Container/OtherOrders/OtherOrder/FillerId
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
			<xsl:apply-templates select=".." mode="fn-id-Filler"/>
			
			<!--
				Field : Result Order Placer Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/id[2]
				Source: HS.SDA3.AbstractOrder PlacerId
				Source: /Container/LabOrders/LabOrder/PlacerId
				Source: /Container/RadOrders/RadOrder/PlacerId
				Source: /Container/OtherOrders/OtherOrder/PlacerId
				StructuredMappingRef: id-Placer
			-->
			<xsl:apply-templates select=".." mode="fn-id-Placer"/>
			
			<!--
				Field : Result Order Code
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/code
				Source: HS.SDA3.AbstractOrder OrderItem
				Source: /Container/LabOrders/LabOrder/OrderItem
				Source: /Container/RadOrders/RadOrder/OrderItem
				Source: /Container/OtherOrders/OtherOrder/OrderItem
				StructuredMappingRef: generic-Coded
			-->
			<xsl:apply-templates select="../OrderItem" mode="fn-generic-Coded">
				<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/>
			</xsl:apply-templates>
			
			<!--
				Field : Result Status
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/statusCode
				Source: HS.SDA3.Result ResultStatus
				Source: /Container/LabOrders/LabOrder/Result/ResultStatus
				Source: /Container/RadOrders/RadOrder/Result/ResultStatus
				Source: /Container/OtherOrders/OtherOrder/Result/ResultStatus
				StructuredMappingRef: observation-ResultStatusCode
			-->
			<xsl:apply-templates select="." mode="eR-observation-ResultStatusCode"/>
			
			<!-- 
				Field : Result Text Result Date/Time
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/effectiveTime/organizer
				Source: HS.SDA3.Result ResultTime
				Source: /Container/LabOrders/LabOrder/Result/ResultTime
				Source: /Container/RadOrders/RadOrder/Result/ResultTime
				Source: /Container/OtherOrders/OtherOrder/Result/ResultTime
			-->
			<xsl:apply-templates select="." mode="eR-effectiveTime-AnalysisSpan" />
			
			<!--
				Field : Result Performer 
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/performer
				Source: HS.SDA3.Result PerformedAt
				Source: /Container/LabOrders/LabOrder/Result/PerformedAt
				Source: /Container/RadOrders/RadOrder/Result/PerformedAt
				Source: /Container/OtherOrders/OtherOrder/Result/PerformedAt
				StructuredMappingRef: performer-PerformedAt-Result
			-->
			<xsl:apply-templates select="PerformedAt" mode="eR-performer-PerformedAt"/>
			
			<!--
				Field : Result Order Author
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/author
				Source: HS.SDA3.Result EnteredBy
				Source: /Container/LabOrders/LabOrder/Result/EnteredBy
				Source: /Container/RadOrders/RadOrder/Result/EnteredBy
				Source: /Container/OtherOrders/OtherOrder/Result/EnteredBy
				StructuredMappingRef: author-Human
			-->
			<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
			
			<!--
				Field : Result Order Information Source
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/informant
				Source: HS.SDA3.Result EnteredAt
				Source: /Container/LabOrders/LabOrder/Result/EnteredAt
				Source: /Container/RadOrders/RadOrder/Result/EnteredAt
				Source: /Container/OtherOrders/OtherOrder/Result/EnteredAt
				StructuredMappingRef: informant
			-->
			<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
			
			<xsl:apply-templates select=".." mode="eR-procedure-Results"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="ResultText" mode="eR-results-Text"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="ResultItems/LabResultItem[string-length(ResultValue/text())>0]" mode="eR-results-Atomic"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			
			<!--
				Field : Result Order Encounter
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component
				Source: HS.SDA3.AbstractOrder EncounterNumber
				Source: /Container/LabOrders/LabOrder/EncounterNumber
				Source: /Container/RadOrders/RadOrder/EncounterNumber
				Source: /Container/OtherOrders/OtherOrder/EncounterNumber
				StructuredMappingRef: encounterLink-component
				Note  : This links the Result to an encounter in the Encounters section.
			-->
			<xsl:apply-templates select=".." mode="fn-encounterLink-component"/>
		</organizer>
	</xsl:template>

	<!-- Match can be any element that can have Result as a child -->
	<xsl:template match="*" mode="eR-procedure-Results">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component>
			<procedure classCode="PROC" moodCode="EVN">
				<!--
					Field : Result Procedure Placer Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/id
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: /Container/LabOrders/LabOrder/PlacerId
					Source: /Container/RadOrders/RadOrder/PlacerId
					Source: /Container/OtherOrders/OtherOrder/PlacerId
					StructuredMappingRef: id-Placer
					Note  : SDA PlacerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA PlacerId have a value
							- Both SDA EnteredAt/Code and SDA PlacerId have a value
							
							For example, if EnteringOrganization/Organization/Code equals "CGH", and
							CGH has OID 1.3.6.1.4.1.21367.2010.1.2.300.2.1, and PlacerId equals 7676,
							then this is exported
							
							<id root="1.3.6.1.4.1.21367.2010.1.2.300.2.1" extension="7676" assigningAuthorityName="CGH-PlacerId"/>
							
							Otherwise, a CDA id is exported with a GUID and some placeholder text.
							For example
							
							<id root="fcbcb478-fceb-11e3-ae03-31c1b7edac00" assigningAuthorityName="CGH-UnspecifiedPlacerId"/>
				-->
				<xsl:apply-templates select="." mode="fn-id-Placer"/>
				
				<!--
					Field : Result Procedure Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/code
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/LabOrders/LabOrder/OrderItem
					Source: /Container/RadOrders/RadOrder/OrderItem
					Source: /Container/OtherOrders/OtherOrder/OrderItem
					StructuredMappingRef: generic-Coded
				-->
						<xsl:apply-templates select="OrderItem" mode="fn-generic-Coded">
							<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/>
						</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}"/></text>
				
				<!--
					Field : Result Procedure Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/statusCode
					Source: HS.SDA3.Result ResultStatus
					Source: /Container/LabOrders/LabOrder/Result/ResultStatus
					Source: /Container/RadOrders/RadOrder/Result/ResultStatus
					Source: /Container/OtherOrders/OtherOrder/Result/ResultStatus
					StructuredMappingRef: observation-ResultStatusCode
				-->
				<!-- <statusCode> -->
				<xsl:apply-templates select="." mode="eR-observation-ResultStatusCode"/>
				
				<!--
					Field : Result Order Author Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/effectiveTime/@value
					Source: HS.SDA3.Result EnteredOn
					Source: /Container/LabOrders/LabOrder/EnteredOn
					Source: /Container/RadOrders/RadOrder/EnteredOn
					Source: /Container/OtherOrders/OtherOrder/EnteredOn
				-->
				<xsl:apply-templates select="EnteredOn" mode="fn-effectiveTime-singleton"/>
				
				<xsl:apply-templates select="Specimen" mode="eR-specimen"/>
				
				<!--
					Field : Result Ordering Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/performer
					Source: HS.SDA3.AbstractOrder OrderedBy
					Source: /Container/LabOrders/LabOrder/OrderedBy
					Source: /Container/RadOrders/RadOrder/OrderedBy
					Source: /Container/OtherOrders/OtherOrder/OrderedBy
					StructuredMappingRef: performer
				-->
				<xsl:apply-templates select="OrderedBy" mode="fn-performer"/>
				
				<!--
					Field : Result Procedure Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/author
					Source: HS.SDA3.Result EnteredBy
					Source: /Container/LabOrders/LabOrder/EnteredBy
					Source: /Container/RadOrders/RadOrder/EnteredBy
					Source: /Container/OtherOrders/OtherOrder/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				
				<!--
					Field : Result Procedure Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/informant
					Source: HS.SDA3.Result EnteredAt
					Source: /Container/LabOrders/LabOrder/EnteredAt
					Source: /Container/RadOrders/RadOrder/EnteredAt
					Source: /Container/OtherOrders/OtherOrder/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant-noPatientIdentifier"/>
				
				<!--
					Field : Result Procedure Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.Result Comments
					Source: /Container/LabOrders/LabOrder/Comments
					Source: /Container/RadOrders/RadOrder/Comments
					Source: /Container/OtherOrders/OtherOrder/Comments
				-->
				<xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestComments/text(), $narrativeLinkSuffix)"/>
				</xsl:apply-templates>
			</procedure>
		</component>
	</xsl:template>
	
	<xsl:template match="LabResultItem" mode="eR-effectiveTime-ObservationAnalysisResultTime">
		<effectiveTime>		
			<xsl:choose>
				<xsl:when test="string-length(ObservationTime)">		
					<xsl:attribute name="value"><xsl:apply-templates select="ObservationTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute>					
				</xsl:when>				
	 			<xsl:when test="string-length(AnalysisTime)">
					<xsl:attribute name="value"><xsl:apply-templates select="AnalysisTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="string-length(../../ResultTime)">
					<xsl:attribute name="value"><xsl:apply-templates select="../../ResultTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute>
				</xsl:when>	 	
				<xsl:otherwise><xsl:attribute name="nullFlavor">UNK</xsl:attribute></xsl:otherwise>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>


	<xsl:template match="Result" mode="eR-effectiveTime-AnalysisSpan">
		<!--
			Source: /Container/LabOrders/LabOrder/Result
			Source: /Container/RadOrders/RadOrder/Result
			Source: /Container/OtherOrders/OtherOrder/Result
		-->
		<xsl:choose>
			<xsl:when test="ResultItems/LabResultItem/AnalysisTime">
				<effectiveTime>
					<low>
						<xsl:attribute name="value">
							<xsl:for-each select="ResultItems/LabResultItem/AnalysisTime">
								<xsl:sort select="." order="ascending"/>
								<xsl:if test="position() = 1">
									<xsl:apply-templates select="." mode="fn-xmlToHL7TimeStamp"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>
					</low>
					<high>
						<xsl:attribute name="value">
							<xsl:for-each select="ResultItems/LabResultItem/AnalysisTime">
								<xsl:sort select="." order="descending"/>
								<xsl:if test="position() = 1">
									<xsl:apply-templates select="." mode="fn-xmlToHL7TimeStamp"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>
					</high>
				</effectiveTime>
			</xsl:when>
			<xsl:when test="ResultTime">
				<effectiveTime>
					<low>
						<xsl:attribute name="value">
							<xsl:apply-templates select="ResultTime" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:attribute>
					</low>
					<high>
						<xsl:attribute name="value">
							<xsl:apply-templates select="ResultTime" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:attribute>
					</high>
				</effectiveTime>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Specimen" mode="eR-specimen">
		<!--
			Field : Result Specimen
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/specimen/specimenRole/specimenPlayingEntity/code
			Source: HS.SDA3.AbstractOrder Specimen
			Source: /Container/LabOrders/LabOrder/Specimen
			Source: /Container/RadOrders/RadOrder/Specimen
			Source: /Container/OtherOrders/OtherOrder/Specimen
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
					
					<xsl:apply-templates select="exsl:node-set($specimenInformation)/Specimen" mode="fn-generic-Coded"/>
				</specimenPlayingEntity>
			</specimenRole>
		</specimen>
	</xsl:template>

	<xsl:template match="ResultText" mode="eR-results-Text">
		<!--
			Source: /Container/LabOrders/LabOrder/Result/ResultText
			Source: /Container/RadOrders/RabOrder/Result/ResultText
			Source: /Container/OtherOrders/OtherOrder/Result/ResultText
		-->
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eR-templateIds-ResultsTextReport"/>
				
				<xsl:apply-templates select="." mode="fn-id-External"/>
				
				<!--
					Field : Result Text Result Order Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/code
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/LabOrders/LabOrder/OrderItem
					Source: /Container/RadOrders/RadOrder/OrderItem
					Source: /Container/OtherOrders/OtherOrder/OrderItem
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="../../OrderItem" mode="fn-generic-Coded"><xsl:with-param name="isCodeRequired" select="'1'"/></xsl:apply-templates>
				
				<!--
					Field : Result Text
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/text
					Source: HS.SDA3.Result ResultText
					Source: /Container/LabOrders/LabOrder/Result/ResultText
					Source: /Container/RadOrders/RadOrder/Result/ResultText
					Source: /Container/OtherOrders/OtherOrder/Result/ResultText
					Note  : CDA text results appear only in the Results section narrative.
							The text element in the structured body is just a link
							to the text in the narrative.
				-->
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultText/text(), $narrativeLinkSuffix)}"/></text>
				
				<!--
					Field : Result Text Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/statusCode
					Source: HS.SDA3.Result ResultStatus
					Source: /Container/LabOrders/LabOrder/Result/ResultStatus
					Source: /Container/RadOrders/RadOrder/Result/ResultStatus
					Source: /Container/OtherOrders/OtherOrder/Result/ResultStatus
					StructuredMappingRef: observation-ResultStatusCode
				-->
				<!-- <statusCode> -->
				<xsl:apply-templates select=".." mode="eR-observation-ResultStatusCode"/>
				
				<!--
					Field : Result Text Result Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
					Source: HS.SDA3.Result ResultTime
					Source: /Container/LabOrders/LabOrder/Result/ResultTime
					Source: /Container/RadOrders/RadOrder/Result/ResultTime
					Source: /Container/OtherOrders/OtherOrder/Result/ResultTime
				-->
				<xsl:choose>
					<xsl:when test="string-length(../ResultTime/text())">
						<xsl:apply-templates select="../ResultTime" mode="fn-effectiveTime-singleton"/>
					</xsl:when>
					<xsl:otherwise>
						<effectiveTime nullFlavor="UNK"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<value nullFlavor="NA" xsi:type="CD"/>
			</observation>
		</component>
	</xsl:template>

	<xsl:template match="LabResultItem" mode="eR-results-Atomic">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component typeCode="COMP">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eR-templateIds-ResultsAtomicValues"/>
				
				<!--
				Field : Result Atomic Result Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/id
				Source: HS.SDA3.LabResultItem ExternalId
				Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ExternalId
				StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="fn-id-External"/>
				
				<!--
					Field : Result Test Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/code
					Source: HS.SDA3.LabResultItem TestItemCode
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemCode
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="TestItemCode" mode="fn-generic-Coded">
					<xsl:with-param name="requiredCodeSystemOID" select="$loincOID"/>
				</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValue/text(), $narrativeLinkSuffix, '-', position())}"/></text>
				
				<!-- <statusCode> -->
				<xsl:apply-templates select="." mode="eR-observation-TestItemStatusCode"/>
				
				<!--
					Field : Result Atomic Result Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
					Source: HS.SDA3.LabResultItem ObservationTime
					Source: /Container/LabOrders/LabOrder/Result/LabResultItems/LabResultItem/ObservationTime
				-->

				<!--
					Field : Result Atomic Result Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
					Source: HS.SDA3.LabResultItem AnalysisTime
					Source: /Container/LabOrders/LabOrder/Result/LabResultItems/LabResultItem/AnalysisTime
				-->

				<!--
					Field : Result Atomic Result Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
					Source: HS.SDA3.Result ResultTime
					Source: /Container/LabOrders/LabOrder/Result/ResultTime
				-->				
				<xsl:apply-templates select="." mode="eR-effectiveTime-ObservationAnalysisResultTime"/>
				
				<!--
					Field : Result Atomic Result Value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/value
					Source: HS.SDA3.LabResultItem ResultValue
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultValue
				-->
				<xsl:variable name="resultUnits">
					<xsl:call-template name="fn-unit-to-ucum">
						<xsl:with-param name="unit" select="translate(ResultValueUnits/text(), ' ', '_')" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="TestItemCode/IsNumeric/text() = 'true'">
						<xsl:apply-templates select="ResultValue" mode="fn-value-PQ"><xsl:with-param name="units" select="$resultUnits"/></xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise><xsl:apply-templates select="ResultValue" mode="fn-value-ST"/></xsl:otherwise>
				</xsl:choose>
				
				<xsl:apply-templates select="ResultInterpretation" mode="eR-results-Interpretation"/>
				
				<!--
					Field : Result Test Performer 
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/performer
					Source: HS.SDA3.LabResultItem PerformedAt
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/PerformedAt
					StructuredMappingRef: performer-PerformedAt-LabResultItem
				-->
				<xsl:apply-templates select="PerformedAt" mode="eR-performer-PerformedAt"/>
				
				<xsl:apply-templates select="TestItemStatus" mode="eR-observation-TestItemStatus"/>
				
				<!--
					Field : Result Atomic Result Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.LabResultItem Comments
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/Comments
				-->
				<xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValueComments/text(), $narrativeLinkSuffix, '-', position())"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="ResultNormalRange" mode="eR-results-ReferenceRange"/>
			</observation>
		</component>
	</xsl:template>
	
	<xsl:template match="ResultInterpretation" mode="eR-results-Interpretation">
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
		
		<!--
			Field : Result Interpretation
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/interpretationCode
			Source: HS.SDA3.LabResultItem ResultInterpretation
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultInterpretation
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="exsl:node-set($interpretationInformation)/Interpretation" mode="fn-generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$observationInterpretationOID"/></xsl:with-param>
			<xsl:with-param name="writeOriginalText">0</xsl:with-param>
			<xsl:with-param name="cdaElementName">interpretationCode</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- Match can be Result or any element that can have Result as a child -->
	<xsl:template match="*" mode="eR-observation-ResultStatusCode">
		<!-- observation-ResultStatusCode is for exporting a compliant <statusCode>. -->
		<!--
			StructuredMapping: observation-ResultStatusCode
			
			Field
			Path  : @code
			Source: CurrentProperty
			Source: ./
		-->
		<!--
			Status Detail			
			HS.SDA3.Result ResultStatus can have any value defined
			in ^OEC("RESST"), whose initial values are taken from
			HS-Default-ResultStatus.txt, whose values are taken
			from the HL7v2.5 code table for result status.  COR,
			FIN and ENT are supported only as deprecated values.
			
			The required value set for this field is Result Status
			(OID 2.16.840.1.113883.11.20.9.39), which includes only
			aborted, active, cancelled, completed, held, and suspended.
			Corrected results (C, COR, K) get a statusCode of completed.
			If not able to discern a status, default to "completed".
		-->
		<xsl:variable name="statusValue" select="concat('|',translate(ResultStatus/text(), $lowerCase, $upperCase),'|')"/>
		
		<statusCode>
			<xsl:attribute name="code">
			<xsl:choose>
				<xsl:when test="contains('|F|FIN|',$statusValue)">completed</xsl:when>
				<xsl:when test="contains('|R|ENT|I|V|O|S|A|P|',$statusValue)">active</xsl:when>
				<xsl:when test="contains('|C|COR|K|',$statusValue)">completed</xsl:when>
				<xsl:when test="$statusValue = '|X|'">cancelled</xsl:when>
				<xsl:otherwise>completed</xsl:otherwise>
			</xsl:choose>
			</xsl:attribute>
		</statusCode>
	</xsl:template>
	
	<xsl:template match="LabResultItem" mode="eR-observation-TestItemStatusCode">
		<!-- observation-TestItemStatusCode is for exporting a compliant <statusCode>. -->
		<!--
			Field : Result Test Status Code
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/statusCode/@code
			Source: HS.SDA3.LabResultItem TestItemStatus
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemStatus
			Note  : Status Detail
			
					The statusValue values explicitly supported here are taken
					from the legacy observation-TestItemStatus template from
					the C32 export, and from the values that are found in
					^websys.StandardTypeD("STD","TestItemStatusHealthShare")
					in a default installation of an access gateway, as of
					12/31/2013.
					
					A = Active
					R = Entered
					F = Final
					C = Corrected
					K = Corrected
					P = Preliminary
					I = In Progress
					D = Deleted
					O = No Result
					S = Partial
					X = Cannot Result
					N = Not Tested
					U = Updated to Final
					V = Verified
					W = Wrong
					
					The required value set for this field is Result Status
					(OID 2.16.840.1.113883.11.20.9.39), which includes only
					aborted, active, cancelled, completed, held, and suspended.
					Corrected results (C or K) get a statusCode of completed.
					If not able to discern a status, default to "completed".
		-->
		<xsl:variable name="statusValue" select="concat('|',translate(TestItemStatus/text(), $lowerCase, $upperCase), '|')"/>
		
		<statusCode>
			<xsl:attribute name="code">
			<xsl:choose>
				<xsl:when test="contains('|F|K|C|D|U|',$statusValue)">completed</xsl:when>
				<xsl:when test="contains('|R|I|V|O|S|A|P|N|W|',$statusValue)">active</xsl:when>
				<xsl:when test="contains('|X|',$statusValue)">cancelled</xsl:when>
				<xsl:otherwise>completed</xsl:otherwise>
			</xsl:choose>
			</xsl:attribute>
		</statusCode>
	</xsl:template>
	
	<xsl:template match="TestItemStatus" mode="eR-observation-TestItemStatus">
		<!--
			observation-TestItemStatus is for exporting the HS TestItemStatus
			with more complete support of HS-specific values.
		-->
		<!--
			Field : Result Test Status
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/entryRelationship/observation[code/@code='33999-4']/value
			Source: HS.SDA3.LabResultItem TestItemStatus
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemStatus
		-->
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:call-template name="eR-templateIds-resultStatusObservation"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<text/>
				<statusCode code="completed"/>
				
				<!-- Status Detail -->
				<xsl:variable name="statusValue" select="translate(text(), $lowerCase, $upperCase)"/>
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<SDACodingStandard><xsl:value-of select="$actStatusName"/></SDACodingStandard>
						<Code>
							<xsl:choose>
								<xsl:when test="$statusValue = 'A'">partial</xsl:when>
								<xsl:when test="$statusValue = 'C'">corrected</xsl:when>
								<xsl:when test="$statusValue = 'F'">final</xsl:when>
								<xsl:when test="$statusValue = 'K'">corrected</xsl:when>
								<xsl:when test="$statusValue = 'P'">preliminary</xsl:when>
								<xsl:when test="$statusValue = 'R'">entered</xsl:when>
								<xsl:when test="$statusValue = 'I'">in progress</xsl:when>
								<xsl:when test="$statusValue = 'D'">deleted</xsl:when>
								<xsl:when test="$statusValue = 'O'">no result</xsl:when>
								<xsl:when test="$statusValue = 'S'">partial</xsl:when>
								<xsl:when test="$statusValue = 'X'">cannot result</xsl:when>
								<xsl:when test="$statusValue = 'N'">not tested</xsl:when>
								<xsl:when test="$statusValue = 'U'">updated to final</xsl:when>
								<xsl:when test="$statusValue = 'W'">wrong</xsl:when>
								<xsl:otherwise>unknown</xsl:otherwise>
							</xsl:choose>
						</Code>
						<Description>
							<xsl:choose>
								<xsl:when test="$statusValue = 'A'">partial</xsl:when>
								<xsl:when test="$statusValue = 'C'">corrected</xsl:when>
								<xsl:when test="$statusValue = 'F'">final</xsl:when>
								<xsl:when test="$statusValue = 'K'">corrected</xsl:when>
								<xsl:when test="$statusValue = 'P'">preliminary</xsl:when>
								<xsl:when test="$statusValue = 'R'">entered</xsl:when>
								<xsl:when test="$statusValue = 'I'">in progress</xsl:when>
								<xsl:when test="$statusValue = 'D'">deleted</xsl:when>
								<xsl:when test="$statusValue = 'O'">no result</xsl:when>
								<xsl:when test="$statusValue = 'S'">partial</xsl:when>
								<xsl:when test="$statusValue = 'X'">cannot result</xsl:when>
								<xsl:when test="$statusValue = 'N'">not tested</xsl:when>
								<xsl:when test="$statusValue = 'U'">updated to final</xsl:when>
								<xsl:when test="$statusValue = 'W'">wrong</xsl:when>
								<xsl:otherwise>unknown</xsl:otherwise>
							</xsl:choose>
						</Description>
					</Status>
				</xsl:variable>
				
				<xsl:apply-templates select="exsl:node-set($statusInformation)/Status" mode="fn-value-CE"/>
			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="ResultNormalRange" mode="eR-results-ReferenceRange">
		<!--
			Field : Result Test Reference Range
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/referenceRange/observationRange/value
			Source: HS.SDA3.LabResultItem ResultNormalRange
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultNormalRange
		-->
		<referenceRange typeCode="REFV">
			<observationRange classCode="OBS" moodCode="EVN.CRT">
				<!-- Don't do this; the template is empty!
					xsl:apply-templates select="." mode="eR-results-ReferenceRangeCode"/ -->
				<xsl:variable name="text"><xsl:value-of select="translate(text(), '()', '')"/></xsl:variable>
				<xsl:variable name="textSub2"><xsl:value-of select="substring($text,2)"/></xsl:variable>
				
				<!-- Number of colons, slashes or dashes in the text. -->
				<xsl:variable name="colons" select="string-length(translate($text,translate($text,':',''),''))"/>
				<xsl:variable name="slashes" select="string-length(translate($text,translate($text,'/',''),''))"/>
				<xsl:variable name="dashes" select="string-length(translate($text,translate($text,'-',''),''))"/>
				
				<!-- number() on 0, 0.0, or 0.00 returns false, so separate tests for those numbers are necessary. -->
				<xsl:variable name="ltgtNumeric">
					<xsl:choose>
						<xsl:when test="$colons>1 or $slashes>1">5</xsl:when>
						<!-- ex: 5.0:6.0 -->
						<xsl:when test="$colons=1">
							<xsl:variable name="beforeColon" select="substring-before($text,':')"/>
							<xsl:variable name="afterColon" select="substring-after($text,':')"/>
							<xsl:choose>
								<xsl:when test="(number($beforeColon) or $beforeColon='0' or $beforeColon='0.0' or $beforeColon='0.00')
									          and (number($afterColon) or $afterColon='0' or $afterColon='0.0' or $afterColon='0.00')">0</xsl:when>
								<xsl:otherwise>5</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- ex: 5.0/6.0 -->
						<xsl:when test="$slashes=1">
							<xsl:variable name="beforeSlash" select="substring-before($text,'/')"/>
							<xsl:variable name="afterSlash" select="substring-after($text,'/')"/>
							<xsl:choose>
								<xsl:when test="(number($beforeSlash) or $beforeSlash='0' or $beforeSlash='0.0' or $beforeSlash='0.00')
									          and (number($afterSlash) or $afterSlash='0' or $afterSlash='0.0' or $afterSlash='0.00')">0</xsl:when>
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
								<xsl:when test="(number($beforeDash) or $beforeDash='0' or $beforeDash='0.0' or $beforeDash='0.00')
									          and (number($afterDash) or $afterDash='0' or $afterDash='0.0' or $afterDash='0.00')">0</xsl:when>
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
								<xsl:when test="(number($beforeDash3) or $beforeDash3='0' or $beforeDash3='0.0' or $beforeDash3='0.00')
									          and (number($afterDash3) or $afterDash3='0' or $afterDash3='0.0' or $afterDash3='0.00')">0</xsl:when>
								<xsl:otherwise>5</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="not(number($text))">5</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- At this point, $ltgtNumeric tells us:
				     0: conventionally-delimited range or an unpunctuated number
				     1: starts with greater-than-or-equal (= last) and has a number
				     2: starts with greater-than-or-equal (= first) and has a number
				     3: starts with less-than-or-equal (= last) and has a number
				     4: starts with less-than-or-equal (= first) and has a number
				     5: too complex to parse -->
				<xsl:choose>
					<xsl:when test="../TestItemCode/IsNumeric/text() = 'true' and $ltgtNumeric &lt; 5">
						<xsl:apply-templates select="." mode="fn-value-IVL_PQ">
							<xsl:with-param name="referenceRangeLowValue">
								<xsl:choose>
									<xsl:when test="$ltgtNumeric='1'"><xsl:value-of select="normalize-space(substring-after($text,'>='))"/></xsl:when>
									<xsl:when test="$ltgtNumeric='2'"><xsl:value-of select="normalize-space(substring-after($text,'=>'))"/></xsl:when>
									<xsl:when test="$ltgtNumeric='3'"/>
									<xsl:when test="$ltgtNumeric='4'"/>
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
									<xsl:when test="$ltgtNumeric='1'"/>
									<xsl:when test="$ltgtNumeric='2'"/>
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
							<xsl:with-param name="referenceRangeUnits" select="translate(../ResultValueUnits/text(),' ','_')"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<text><xsl:value-of select="$text"/></text>
						<value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ST">
							<xsl:value-of select="$text"/>
            </value>
					</xsl:otherwise>
				</xsl:choose>
			</observationRange>
		</referenceRange>
	</xsl:template>
	
	<xsl:template match="*" mode="eR-results-InitiatingOrder">
		<!-- UNUSED -->
		<!-- Match can be any element that can have Result as a child -->
		<xsl:param name="narrativeLinkSuffix"/>
		
		<!--
			Field : Result Procedure Placer Id
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/id
			Source: HS.SDA3.AbstractOrder PlacerId
			Source: /Container/LabOrders/LabOrder/PlacerId
			Source: /Container/RadOrders/RadOrder/PlacerId
			Source: /Container/OtherOrders/OtherOrder/PlacerId
			StructuredMappingRef: id-Placer
			Note  : SDA PlacerId is exported to CDA id if one of these conditions is met:
					- Both SDA EnteringOrganization/Organization/Code and SDA PlacerId have a value
					- Both SDA EnteredAt/Code and SDA PlacerId have a value
					
					For example, if EnteringOrganization/Organization/Code equals "CGH", and
					CGH has OID 1.3.6.1.4.1.21367.2010.1.2.300.2.1, and PlacerId equals 7676,
					then this is exported
					
					<id root="1.3.6.1.4.1.21367.2010.1.2.300.2.1" extension="7676" assigningAuthorityName="CGH-PlacerId"/>
					
					Otherwise, a CDA id is exported with a GUID and some placeholder text.
					For example
					
					<id root="fcbcb478-fceb-11e3-ae03-31c1b7edac00" assigningAuthorityName="CGH-UnspecifiedPlacerId"/>
		-->
		<xsl:apply-templates select="." mode="fn-id-Placer"/>
		
		<!--
			Field : Result Procedure Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/code
			Source: HS.SDA3.AbstractOrder OrderItem
			Source: /Container/LabOrders/LabOrder/OrderItem
			Source: /Container/RadOrders/RadOrder/OrderItem
			Source: /Container/OtherOrders/OtherOrder/OrderItem
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="OrderItem" mode="fn-generic-Coded">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/>
		</xsl:apply-templates>
		
		<text><reference value="{concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}"/></text>
		
		<!--
			Field : Result Procedure Status
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/statusCode
			Source: HS.SDA3.Result ResultStatus
			Source: /Container/LabOrders/LabOrder/Result/ResultStatus
			Source: /Container/RadOrders/RadOrder/Result/ResultStatus
			Source: /Container/OtherOrders/OtherOrder/Result/ResultStatus
			StructuredMappingRef: observation-ResultStatusCode
		-->
		<!-- <statusCode> -->
		<xsl:apply-templates select="." mode="eR-observation-ResultStatusCode"/>
		
		<!--
			Field : Result Order Author Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/effectiveTime/@value
			Source: HS.SDA3.Result EnteredOn
			Source: /Container/LabOrders/LabOrder/EnteredOn
			Source: /Container/RadOrders/RadOrder/EnteredOn
			Source: /Container/OtherOrders/OtherOrder/EnteredOn
		-->
		<xsl:apply-templates select="EnteredOn" mode="fn-effectiveTime-singleton"/>
		
		<xsl:apply-templates select="Specimen" mode="eR-specimen"/>
		
		<!--
			Field : Result Ordering Clinician
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/performer
			Source: HS.SDA3.AbstractOrder OrderedBy
			Source: /Container/LabOrders/LabOrder/OrderedBy
			Source: /Container/RadOrders/RadOrder/OrderedBy
			Source: /Container/OtherOrders/OtherOrder/OrderedBy
			StructuredMappingRef: performer
		-->
		<xsl:apply-templates select="OrderedBy" mode="fn-performer"/>
		
		<!--
			Field : Result Procedure Author
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/author
			Source: HS.SDA3.Result EnteredBy
			Source: /Container/LabOrders/LabOrder/EnteredBy
			Source: /Container/RadOrders/RadOrder/EnteredBy
			Source: /Container/OtherOrders/OtherOrder/EnteredBy
			StructuredMappingRef: assignedAuthor-Human
		-->
		<xsl:apply-templates select="EnteredBy" mode="fn-author-Human"/>
		
		<!--
			Field : Result Procedure Information Source
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/informant
			Source: HS.SDA3.Result EnteredAt
			Source: /Container/LabOrders/LabOrder/EnteredAt
			Source: /Container/RadOrders/RadOrder/EnteredAt
			Source: /Container/OtherOrders/OtherOrder/EnteredAt
			StructuredMappingRef: informant
		-->
		<xsl:apply-templates select="EnteredAt" mode="fn-informant-noPatientIdentifier"/>
		
		<!--
			Field : Result Procedure Comments
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/entryRelationship/act[code/@code='48767-8']/text
			Source: HS.SDA3.Result Comments
			Source: /Container/LabOrders/LabOrder/Comments
			Source: /Container/RadOrders/RadOrder/Comments
			Source: /Container/OtherOrders/OtherOrder/Comments
		-->
		<xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
			<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestComments/text(), $narrativeLinkSuffix)"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="eR-results-ReferenceRangeCode">
		<!-- UNUSED -->
	</xsl:template>
	
	<xsl:template match="LabResultItem" mode="eR-id-results-Atomic">
		<!-- UNUSED -->
		<!--
			Field : Result Atomic Result Id
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/id
			Source: HS.SDA3.LabResultItem ExternalId
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ExternalId
			StructuredMappingRef: id-External
		-->
		<xsl:apply-templates select="." mode="fn-id-External"/>
	</xsl:template>
	
	<xsl:template match="PerformedAt" mode="eR-performer-PerformedAt">
		<!-- this is the same as fn-performer except for the assignedEntity processing -->
		<!--
			StructuredMapping: performer-PerformedAt-Result
			
			Field
			Path: time/@value
			Source: ParentProperty.EnteredOn
			Source: ../EnteredOn
			
			Field
			Path: ./
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
		<performer typeCode="PRF">
			<xsl:apply-templates select=".." mode="fn-time"/>
			<xsl:apply-templates select="." mode="fn-assignedEntity"/>
		</performer>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eR-templateIds-ResultsOrganizer">
		<templateId root="{$ccda-ResultOrganizer}"/>
		<templateId root="{$ccda-ResultOrganizer}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eR-templateIds-ResultsTextReport">
		<templateId root="{$ccda-ResultObservation}"/>
		<templateId root="{$ccda-ResultObservation}" extension="2015-08-01"/>		
	</xsl:template>
	
	<xsl:template name="eR-templateIds-ResultsAtomicValues">
		<templateId root="{$ccda-ResultObservation}"/>
		<templateId root="{$ccda-ResultObservation}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eR-templateIds-resultStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/>
<templateId root="{$hl7-CCD-StatusObservation}" extension="2015-08-01"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
