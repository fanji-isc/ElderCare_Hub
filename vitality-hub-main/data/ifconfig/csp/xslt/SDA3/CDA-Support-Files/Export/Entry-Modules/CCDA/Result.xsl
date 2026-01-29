<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="diagnosticResults-Narrative">
		<xsl:param name="orderType"/>
		
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
					<xsl:apply-templates select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | OtherOrders/OtherOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResults-NarrativeDetail">
						<xsl:sort select="ResultTime" order="descending"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResults-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		

		<!--
			The NIST MU2 C-CDA validator logs an error if an @ID has
			no reference/@value pointing to it.  Export @ID only if
			the particular item in the narrative has a value.
		-->
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="../OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="ResultTime" mode="narrativeDateFromODBC"/></td>
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
								<xsl:apply-templates select="ResultItems/LabResultItem" mode="diagnosticResults-NarrativeDetail-LabResultItem">
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
			<xsl:choose>
				<xsl:when test="string-length(Comments/text())">
					<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValueComments/text(), $narrativeLinkSuffix, '-', position())}"><xsl:value-of select="Comments/text()"/></td>
				</xsl:when>
				<xsl:otherwise><td/></xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="diagnosticResults-Entries">
		<xsl:apply-templates select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | OtherOrders/OtherOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResults-EntryDetail">
			<xsl:sort select="ResultTime" order="descending"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResults-NoData">
		<text><xsl:value-of select="$exportConfiguration/results/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="diagnosticResults-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry>
			<!-- Result Battery -->
			<xsl:apply-templates select="." mode="battery-Results"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="battery-Results">
		<xsl:param name="narrativeLinkSuffix"/>
				
		<organizer classCode="BATTERY" moodCode="EVN">
			<xsl:apply-templates select="." mode="templateIds-ResultsOrganizer"/>
			
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
			<xsl:apply-templates select=".." mode="id-Filler"/>
			
			<!--
				Field : Result Order Placer Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/id[2]
				Source: HS.SDA3.AbstractOrder PlacerId
				Source: /Container/LabOrders/LabOrder/PlacerId
				Source: /Container/RadOrders/RadOrder/PlacerId
				Source: /Container/OtherOrders/OtherOrder/PlacerId
				StructuredMappingRef: id-Placer
			-->
			<xsl:apply-templates select=".." mode="id-Placer"/>
			
			<!--
				Field : Result Order Code
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/code
				Source: HS.SDA3.AbstractOrder OrderItem
				Source: /Container/LabOrders/LabOrder/OrderItem
				Source: /Container/RadOrders/RadOrder/OrderItem
				Source: /Container/OtherOrders/OtherOrder/OrderItem
				StructuredMappingRef: generic-Coded
			-->
			<xsl:apply-templates select="../OrderItem" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<!--
				Field : Result Status
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/statusCode
				Source: HS.SDA3.Result ResultStatus
				Source: /Container/LabOrders/LabOrder/Result/ResultStatus
				Source: /Container/RadOrders/RadOrder/Result/ResultStatus
				Source: /Container/OtherOrders/OtherOrder/Result/ResultStatus
				StructuredMappingRef: observation-ResultStatusCode
			-->
			<!-- <statusCode> -->
			<xsl:apply-templates select="." mode="observation-ResultStatusCode"/>
			
			<!--
				Field : Result Text Result Date/Time
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/effectiveTime/@value
				Source: HS.SDA3.Result ResultTime
				Source: /Container/LabOrders/LabOrder/Result/ResultTime
				Source: /Container/RadOrders/RadOrder/Result/ResultTime
				Source: /Container/OtherOrders/OtherOrder/Result/ResultTime
			-->
			<xsl:apply-templates select="." mode="effectiveTime-Result"/>
			
			<!--
				Field : Result Performer 
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/performer
				Source: HS.SDA3.Result PerformedAt
				Source: /Container/LabOrders/LabOrder/Result/PerformedAt
				Source: /Container/RadOrders/RadOrder/Result/PerformedAt
				Source: /Container/OtherOrders/OtherOrder/Result/PerformedAt
				StructuredMappingRef: performer-PerformedAt-Result
			-->
			<xsl:apply-templates select="PerformedAt" mode="performer-PerformedAt"/>
			
			<!--
				Field : Result Order Author
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/author
				Source: HS.SDA3.Result EnteredBy
				Source: /Container/LabOrders/LabOrder/Result/EnteredBy
				Source: /Container/RadOrders/RadOrder/Result/EnteredBy
				Source: /Container/OtherOrders/OtherOrder/Result/EnteredBy
				StructuredMappingRef: author-Human
			-->
			<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
			
			<!--
				Field : Result Order Information Source
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/informant
				Source: HS.SDA3.Result EnteredAt
				Source: /Container/LabOrders/LabOrder/Result/EnteredAt
				Source: /Container/RadOrders/RadOrder/Result/EnteredAt
				Source: /Container/OtherOrders/OtherOrder/Result/EnteredAt
				StructuredMappingRef: informant
			-->
			<xsl:apply-templates select="EnteredAt" mode="informant"/>
			
			<xsl:apply-templates select=".." mode="procedure-Results"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="ResultText" mode="results-Text"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="ResultItems/LabResultItem[string-length(ResultValue/text())>0]" mode="results-Atomic"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			
			<!--
				Field : Result Comments
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/act[code/@code='48767-8']/text
				Source: HS.SDA3.Result Comments
				Source: /Container/LabOrders/LabOrder/Result/Comments
				Source: /Container/RadOrders/RadOrder/Result/Comments
				Source: /Container/OtherOrders/OtherOrder/Result/Comments
				Note  : The export of Result Comments to component instead of entryRelationship
						is as per IHE PCC TF-2 section 6.3.4.6 Comments, which states that the
						Comment structure "can also be used in the <component> element when the
						comment appears within an <organizer>".  That allowance is made because
						the schema for organizer does not include entryRelationship.
			-->
			<xsl:apply-templates select="Comments" mode="comment-component"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
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
			<xsl:apply-templates select="parent::node()" mode="encounterLink-component"/>
		</organizer>
	</xsl:template>

	<xsl:template match="*" mode="procedure-Results">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component>
			<procedure classCode="PROC" moodCode="EVN">
				<xsl:apply-templates select="." mode="results-InitiatingOrder"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			</procedure>
		</component>
	</xsl:template>
	
	<xsl:template match="*" mode="results-InitiatingOrder">
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
		<xsl:apply-templates select="." mode="id-Placer"/>
		
		<!--
			Field : Result Procedure Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/code
			Source: HS.SDA3.AbstractOrder OrderItem
			Source: /Container/LabOrders/LabOrder/OrderItem
			Source: /Container/RadOrders/RadOrder/OrderItem
			Source: /Container/OtherOrders/OtherOrder/OrderItem
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="OrderItem" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
		
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
		<xsl:apply-templates select="." mode="observation-ResultStatusCode"/>
		
		<!--
			Field : Result Order Author Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/effectiveTime/@value
			Source: HS.SDA3.Result EnteredOn
			Source: /Container/LabOrders/LabOrder/EnteredOn
			Source: /Container/RadOrders/RadOrder/EnteredOn
			Source: /Container/OtherOrders/OtherOrder/EnteredOn
		-->
		<xsl:apply-templates select="EnteredOn" mode="effectiveTime"/>
		
		<xsl:apply-templates select="Specimen" mode="specimen"/>
		
		<!--
			Field : Result Ordering Clinician
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/performer[@typeCode="PRF"]
			Source: HS.SDA3.AbstractOrder OrderedBy
			Source: /Container/LabOrders/LabOrder/OrderedBy
			Source: /Container/RadOrders/RadOrder/OrderedBy
			Source: /Container/OtherOrders/OtherOrder/OrderedBy
			StructuredMappingRef: performer
		-->
		<xsl:apply-templates select="OrderedBy" mode="performer"/>
		
		<!--
			Field : Result VerifiedBy
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/performer[@typeCode="SPRF"]
			Source: HS.SDA3.AbstractOrder VerifiedBy
			Source: /Container/LabOrders/LabOrder/VerifiedBy
			Source: /Container/RadOrders/RadOrder/VerifiedBy
			Source: /Container/OtherOrders/OtherOrder/VerifiedBy
			StructuredMappingRef: performer-verifiedBy
		-->
		<xsl:apply-templates select="VerifiedBy" mode="performer-verifiedBy"/>
		
		<!--
			Field : Result Procedure Author
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/author
			Source: HS.SDA3.Result EnteredBy
			Source: /Container/LabOrders/LabOrder/EnteredBy
			Source: /Container/RadOrders/RadOrder/EnteredBy
			Source: /Container/OtherOrders/OtherOrder/EnteredBy
			StructuredMappingRef: author-Human
		-->
		<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
		
		<!--
			Field : Result Procedure Information Source
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/informant
			Source: HS.SDA3.Result EnteredAt
			Source: /Container/LabOrders/LabOrder/EnteredAt
			Source: /Container/RadOrders/RadOrder/EnteredAt
			Source: /Container/OtherOrders/OtherOrder/EnteredAt
			StructuredMappingRef: informant
		-->
		<xsl:apply-templates select="EnteredAt" mode="informant-noPatientIdentifier"/>
		
		<!--
			Field : Result Procedure Comments
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/entryRelationship/act[code/@code='48767-8']/text
			Source: HS.SDA3.AbstractOrder Comments
			Source: /Container/LabOrders/LabOrder/Comments
			Source: /Container/RadOrders/RadOrder/Comments
			Source: /Container/OtherOrders/OtherOrder/Comments
		-->
		<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-Result">
		<xsl:choose>
			<xsl:when test="string-length(ResultTime)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="ResultTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="LabResultItem" mode="effectiveTime-Observation">
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="ObservationTime"><xsl:attribute name="value"><xsl:apply-templates select="ObservationTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></xsl:when>
				<xsl:when test="AnalysisTime"><xsl:attribute name="value"><xsl:apply-templates select="AnalysisTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></xsl:when>
				<xsl:when test="string-length(../../ResultTime)"><xsl:attribute name="value"><xsl:apply-templates select="../../ResultTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></xsl:when>
				<xsl:otherwise><xsl:attribute name="nullFlavor">UNK</xsl:attribute></xsl:otherwise>
			</xsl:choose>
		</effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="specimen">
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
				<xsl:apply-templates select="." mode="templateIds-ResultsTextReport"/>
				
				<xsl:apply-templates select="." mode="id-External"/>
				
				<!--
					Field : Result Text Result Order Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/code
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/LabOrders/LabOrder/OrderItem
					Source: /Container/RadOrders/RadOrder/OrderItem
					Source: /Container/OtherOrders/OtherOrder/OrderItem
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="../../OrderItem" mode="generic-Coded"><xsl:with-param name="isCodeRequired" select="'1'"/></xsl:apply-templates>
				
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
				<xsl:apply-templates select=".." mode="observation-ResultStatusCode"/>
				
				<!--
					Field : Result Text Result Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
					Source: HS.SDA3.Result ResultTime
					Source: /Container/LabOrders/LabOrder/Result/ResultTime
					Source: /Container/RadOrders/RadOrder/Result/ResultTime
					Source: /Container/OtherOrders/OtherOrder/Result/ResultTime
				-->
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
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/code
					Source: HS.SDA3.LabResultItem TestItemCode
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemCode
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="TestItemCode" mode="generic-Coded">
					<xsl:with-param name="requiredCodeSystemOID" select="$loincOID"/>
				</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValue/text(), $narrativeLinkSuffix, '-', position())}"/></text>
				
				<!-- <statusCode> -->
				<xsl:apply-templates select="." mode="observation-TestItemStatusCode"/>
				

				<!--
					Field : Result Atomic Result Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
					Source: HS.SDA3.LabResultItem ObservationTime
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ObservationTime
				-->
				<xsl:apply-templates select="." mode="effectiveTime-Observation"/>

				
				<!--
					Field : Result Atomic Result Value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/value
					Source: HS.SDA3.LabResultItem ResultValue
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultValue
				-->
				<xsl:choose>
					<xsl:when test="TestItemCode/IsNumeric/text() = 'true'"><xsl:apply-templates select="ResultValue" mode="value-PQ"><xsl:with-param name="units" select="translate(ResultValueUnits, ' ', '_')"/></xsl:apply-templates></xsl:when>
					<xsl:otherwise><xsl:apply-templates select="ResultValue" mode="value-ST"/></xsl:otherwise>
				</xsl:choose>
				
				<xsl:apply-templates select="ResultInterpretation" mode="results-Interpretation"/>
				
				<!--
					Field : Result Test Performer 
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/performer
					Source: HS.SDA3.LabResultItem PerformedAt
					Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/PerformedAt
					StructuredMappingRef: performer-PerformedAt-LabResultItem
				-->
				<xsl:apply-templates select="PerformedAt" mode="performer-PerformedAt"/>
				
				<xsl:apply-templates select="TestItemStatus" mode="observation-TestItemStatus"/>
				
				<!--
					Field : Result Atomic Result Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
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
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/id
			Source: HS.SDA3.LabResultItem ExternalId
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ExternalId
			StructuredMappingRef: id-External
		-->
		<xsl:apply-templates select="." mode="id-External"/>
	</xsl:template>
	
	<xsl:template match="*" mode="results-Interpretation">
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
	
	<!-- observation-ResultStatusCode is for exporting a compliant <statusCode>. -->
	<xsl:template match="*" mode="observation-ResultStatusCode">
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
		<xsl:variable name="statusValueCode">
			<xsl:choose>
				<xsl:when test="contains('|F|FIN|',$statusValue)">completed</xsl:when>
				<xsl:when test="contains('|R|ENT|I|V|O|S|A|P|',$statusValue)">active</xsl:when>
				<xsl:when test="contains('|C|COR|K|',$statusValue)">completed</xsl:when>
				<xsl:when test="$statusValue = '|X|'">cancelled</xsl:when>
				<xsl:otherwise>completed</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<statusCode code="{$statusValueCode}"/>
	</xsl:template>
	
	<!-- observation-TestItemStatusCode is for exporting a compliant <statusCode>. -->
	<xsl:template match="*" mode="observation-TestItemStatusCode">
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
		<xsl:variable name="statusValueCode">
			<xsl:choose>
				<xsl:when test="contains('|F|K|C|D|U|',$statusValue)">completed</xsl:when>
				<xsl:when test="contains('|R|I|V|O|S|A|P|N|W|',$statusValue)">active</xsl:when>
				<xsl:when test="contains('|X|',$statusValue)">cancelled</xsl:when>
				<xsl:otherwise>completed</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<statusCode code="{$statusValueCode}"/>
	</xsl:template>
	
	<!--
		observation-TestItemStatus is for exporting the HS TestItemStatus
		with more complete support of HS-specific values.
	-->
	<xsl:template match="*" mode="observation-TestItemStatus">
		<!--
			Field : Result Test Status
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/entryRelationship/observation[code/@code='33999-4']/value/@code
			Source: HS.SDA3.LabResultItem TestItemStatus
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemStatus
		-->
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-resultStatusObservation"/>
				
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
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<xsl:apply-templates select="$status" mode="value-CE"/>
			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="results-ReferenceRange">
		<!--
			Field : Result Test Reference Range
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/referenceRange/observationRange/value
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
			Path: assignedEntity
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedEntity
		-->
		<performer typeCode="PRF">
			<xsl:apply-templates select="parent::node()" mode="time"/>
			<xsl:apply-templates select="." mode="assignedEntity"/>
		</performer>
	</xsl:template>
	
	<xsl:template match="*" mode="results-ReferenceRangeCode">
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-ResultsOrganizer">
		<templateId root="{$ccda-ResultOrganizer}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-ResultsTextReport">
		<templateId root="{$ccda-ResultObservation}"/>		
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-ResultsAtomicValues">
		<templateId root="{$ccda-ResultObservation}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-resultStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
