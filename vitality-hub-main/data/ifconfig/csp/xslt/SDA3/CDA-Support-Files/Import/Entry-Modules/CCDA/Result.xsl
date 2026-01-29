<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">
	
	<xsl:template match="*" mode="Result">
		<xsl:param name="elementName"/>
		<xsl:variable name="orderRootPath" select="hl7:act | .//hl7:procedure"/>
		<!-- resultOrganizerTemplateId is set up in ImportProfile.xsl, may be customized -->
		<xsl:variable name="resultRootPath" select=".//hl7:organizer[hl7:templateId/@root=$ccda-ResultOrganizer]"/>
 		<xsl:variable name="hasAtomicResults" select="count($resultRootPath/hl7:component/hl7:observation[(hl7:value/@value or string-length(normalize-space(hl7:value/text()))) and not(hl7:value/@nullFlavor)]) > 0"/>
		
		<xsl:element name="{$elementName}">
			<!--
				Field : Result Order Encounter
				Target: HS.SDA3.AbstractOrder EncounterNumber
				Target: /Container/LabOrders/LabOrder/EncounterNumber
				Target: /Container/RadOrders/RadOrder/EncounterNumber
				Target: /Container/OtherOrders/OtherOrder/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Result and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>
			
			<!--
				Field : Result Order Author
				Target: HS.SDA3.AbstractOrder EnteredBy
				Target: /Container/LabOrders/LabOrder/EnteredBy
				Target: /Container/RadOrders/RadOrder/EnteredBy
				Target: /Container/OtherOrders/OtherOrder/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="$orderRootPath" mode="EnteredBy"/>
			
			<!--
				Field : Result Order Information Source
				Target: HS.SDA3.AbstractOrder EnteredAt
				Target: /Container/LabOrders/LabOrder/EnteredAt
				Target: /Container/RadOrders/RadOrder/EnteredAt
				Target: /Container/OtherOrders/OtherOrder/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="$orderRootPath" mode="EnteredAt"/>
			
			<!--
				Field : Result Order Entering Organization
				Target: HS.SDA3.AbstractOrder EnteringOrganization
				Target: /Container/LabOrders/LabOrder/EnteringOrganization
				Target: /Container/RadOrders/RadOrder/EnteringOrganization
				Target: /Container/OtherOrders/OtherOrder/EnteringOrganization
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/informant
				StructuredMappingRef: EnteringOrganization
			-->
			<xsl:apply-templates select="$orderRootPath" mode="EnteringOrganization"/>
			
			<!--
				Field : Result Order Ordering Clinician
				Target: HS.SDA3.AbstractOrder OrderedBy
				Target: /Container/LabOrders/LabOrder/OrderedBy
				Target: /Container/RadOrders/RadOrder/OrderedBy
				Target: /Container/OtherOrders/OtherOrder/OrderedBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/performer[@typeCode="PRF"]
				StructuredMappingRef: DoctorDetail
			-->
			<xsl:apply-templates select="$orderRootPath/hl7:performer[@typeCode='PRF' or not(@typeCode)]" mode="OrderedBy"/>
			
			<!--
				Field : Result Order Verifying Clinician
				Target: HS.SDA3.AbstractOrder VerifiedBy
				Target: /Container/LabOrders/LabOrder/VerifiedBy
				Target: /Container/RadOrders/RadOrder/VerifiedBy
				Target: /Container/OtherOrders/OtherOrder/VerifiedBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/performer[@typeCode="SPRF"]
				StructuredMappingRef: DoctorDetail
			-->
			<xsl:apply-templates select="$orderRootPath/hl7:performer[@typeCode='SPRF']" mode="VerifiedBy"/>
			
			<!--
				Field : Result Order Author Time
				Target: HS.SDA3.AbstractOrder EnteredOn
				Target: /Container/LabOrders/LabOrder/EnteredOn
				Target: /Container/RadOrders/RadOrder/EnteredOn
				Target: /Container/OtherOrders/OtherOrder/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/author/time/@value
			-->
			<xsl:apply-templates select="$orderRootPath/hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!--
				Field : Result Order Id
				Target: HS.SDA3.AbstractOrder ExternalId
				Target: /Container/LabOrders/LabOrder/ExternalId
				Target: /Container/RadOrders/RadOrder/ExternalId
				Target: /Container/OtherOrders/OtherOrder/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/id[1]
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="hl7:act | $resultRootPath" mode="ExternalId"/>
			
			<!--
				Field : Result Order Placer Id
				Target: HS.SDA3.AbstractOrder PlacerId
				Target: /Container/LabOrders/LabOrder/PlacerId
				Target: /Container/RadOrders/RadOrder/PlacerId
				Target: /Container/OtherOrders/OtherOrder/PlacerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/id[2]
				StructuredMappingRef: PlacerId
			-->
			<xsl:apply-templates select="$resultRootPath" mode="PlacerId"/>
			
			<!--
				Field : Result Order Filler Id
				Target: HS.SDA3.AbstractOrder FillerId
				Target: /Container/LabOrders/LabOrder/FillerId
				Target: /Container/RadOrders/RadOrder/FillerId
				Target: /Container/OtherOrders/OtherOrder/FillerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/id[3]
				StructuredMappingRef: FillerId
			-->
			<xsl:apply-templates select="$resultRootPath" mode="FillerId"/>
			
			<!--
				Field : Result Order Code
				Target: HS.SDA3.AbstractOrder OrderItem
				Target: /Container/LabOrders/LabOrder/OrderItem
				Target: /Container/RadOrders/RadOrder/OrderItem
				Target: /Container/OtherOrders/OtherOrder/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/code
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="$resultRootPath/hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>
			
			<!--
				OrderCategory does not have a direct source from CDA.
				OrderCategory is imported only if custom logic is
				added to template order-category-code.
			-->
			<xsl:variable name="hsOrderCategory"><xsl:apply-templates select="$resultRootPath" mode="order-category-code"/></xsl:variable>
			<xsl:if test="string-length($hsOrderCategory)">
				<OrderCategory>
					<Code>
						<xsl:value-of select="$hsOrderCategory"/>
					</Code>
				</OrderCategory>
			</xsl:if>
			
			<!-- Order status not tracked in CCD, so assume Executed. -->
			<Status>E</Status>
			
			<!-- Specimen -->
			<xsl:apply-templates select=".//hl7:specimen/hl7:specimenRole/hl7:specimenPlayingEntity/hl7:code" mode="Specimen"/>
			
			<!--
				Field : Result Order Comments
				Target: HS.SDA3.AbstractOrder Comments
				Target: /Container/LabOrders/LabOrder/Comments
				Target: /Container/RadOrders/RadOrder/Comments
				Target: /Container/OtherOrders/OtherOrder/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="$orderRootPath" mode="Comment"/>

			<!--
				Field : Result Effective Time
				Target: HS.SDA3.AbstractOrder SpecimenCollectedTime
				Target: /Container/LabOrders/LabOrder/SpecimenCollectedTime
				Target: /Container/RadOrders/RadOrder/SpecimenCollectedTime
				Target: /Container/OtherOrders/OtherOrder/SpecimenCollectedTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
			-->
			<xsl:variable name="observationTimes" select="$resultRootPath/hl7:component/hl7:observation/hl7:effectiveTime[@value]"/>
			<xsl:apply-templates select="$observationTimes" mode="SpecimenCollectedTime"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="$resultRootPath" mode="ImportCustom-Order"/>
			
			<Result>
				<!--
					Field : Result Author
					Target: HS.SDA3.Result EnteredBy
					Target: /Container/LabOrders/LabOrder/Result/EnteredBy
					Target: /Container/RadOrders/RadOrder/Result/EnteredBy
					Target: /Container/OtherOrders/OtherOrder/Result/EnteredBy
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/author
					StructuredMappingRef: EnteredByDetail
				-->
				<xsl:apply-templates select="$resultRootPath" mode="EnteredBy"/>
				
				<!--
					Field : Result Information Source
					Target: HS.SDA3.Result EnteredAt
					Target: /Container/LabOrders/LabOrder/Result/EnteredAt
					Target: /Container/RadOrders/RadOrder/Result/EnteredAt
					Target: /Container/OtherOrders/OtherOrder/Result/EnteredAt
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/informant
					StructuredMappingRef: EnteredAt
				-->
				<xsl:apply-templates select="$resultRootPath" mode="EnteredAt"/>
				
				<!--
					Field : Result Author Time
					Target: HS.SDA3.Result EnteredOn
					Target: /Container/LabOrders/LabOrder/Result/EnteredOn
					Target: /Container/RadOrders/RadOrder/Result/EnteredOn
					Target: /Container/OtherOrders/OtherOrder/Result/EnteredOn
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/author/time/@value
				-->
				<xsl:apply-templates select="$resultRootPath/hl7:author/hl7:time" mode="EnteredOn"/>
				
				<!--
					Field : Result Performer
					Target: HS.SDA3.Result PerformedAt
					Target: /Container/LabOrders/LabOrder/Result/PerformedAt
					Target: /Container/RadOrders/RadOrder/Result/PerformedAt
					Target: /Container/OtherOrders/OtherOrder/Result/PerformedAt
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/performer
					StructuredMappingRef: PerformedAt
				-->
				<xsl:apply-templates select="$resultRootPath/hl7:performer" mode="PerformedAt"/>
				
				<!-- Result Time -->
				<xsl:variable name="resultTimeFromResults">
					<xsl:apply-templates select="$resultRootPath/hl7:component/hl7:observation[hl7:effectiveTime/@value]" mode="ResultTimeFromResults"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($resultRootPath/hl7:effectiveTime/@value)">
						<xsl:apply-templates select="$resultRootPath/hl7:effectiveTime" mode="ResultTime"/>
					</xsl:when>
					<xsl:when test="string-length($resultTimeFromResults)">
						<ResultTime><xsl:value-of select="isc:evaluate('xmltimestamp', $resultTimeFromResults)"/></ResultTime>
					</xsl:when>
				</xsl:choose>
				
				<!-- Result Status Code -->
				<xsl:apply-templates select="$resultRootPath/hl7:statusCode" mode="ResultStatus"/>
				
				<!--
					Field : Result Comments
					Target: HS.SDA3.Result Comments
					Target: /Container/LabOrders/LabOrder/Result/Comments
					Target: /Container/RadOrders/RadOrder/Result/Comments
					Target: /Container/OtherOrders/OtherOrder/Result/Comments
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/act[code/@code='48767-8']/text
				-->
				<xsl:apply-templates select="$resultRootPath" mode="Comment-Component"/>
				
				<!-- Result (process text report or atomic results, but not both) -->
				<xsl:choose>
					<xsl:when test="$hasAtomicResults = true()">
						<ResultType>AT</ResultType>
						<ResultItems><xsl:apply-templates select="$resultRootPath/hl7:component/hl7:observation[not(@negationInd='true') and not(hl7:value/@code)]" mode="LabResultItem"/></ResultItems>
					</xsl:when>
					<!--
						Field : Result Text Results
						Target: HS.SDA3.Result ResultText
						Target: /Container/LabOrders/LabOrder/Result/ResultText
						Target: /Container/RadOrders/RadOrder/Result/ResultText
						Target: /Container/OtherOrders/OtherOrder/Result/ResultText
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/text
					-->
					<xsl:otherwise><ResultText><xsl:apply-templates select="$resultRootPath/hl7:component/hl7:observation/hl7:text" mode="TextValue"/></ResultText></xsl:otherwise>
				</xsl:choose>
				
				<!-- Custom SDA Data-->
				<xsl:apply-templates select="$resultRootPath" mode="ImportCustom-Result"/>
			</Result>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*" mode="ResultTimeFromResults">
		<xsl:if test="position()=1"><xsl:value-of select="hl7:effectiveTime/@value"/></xsl:if>
	</xsl:template>

	<!-- 
		Field: Result Effective Time
		Target: HS.SDA3.AbstractOrder SpecimenCollectedTime
		Target: /Container/LabOrders/LabOrder/SpecimenCollectedTime
		Target: /Container/RadOrders/RadOrder/SpecimenCollectedTime
		Target: /Container/OtherOrders/OtherOrder/SpecimenCollectedTime
		Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
	-->
	<xsl:template match = "*" mode="SpecimenCollectedTime">
		<xsl:if test="position()=1">
			<SpecimenCollectedTime>
				<xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/>
			</SpecimenCollectedTime>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="Specimen">
		<!--
			Field : Result Specimen
			Target: HS.SDA3.AbstractOrder Specimen
			Target: /Container/LabOrders/LabOrder/Specimen
			Target: /Container/RadOrders/RadOrder/Specimen
			Target: /Container/OtherOrders/OtherOrder/Specimen
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/procedure/specimen/specimenRole/specimenPlayingEntity/code
			Note  : SDA Specimen is a string property.  The CDA specimen code
					and description are imported to SDA Specimen into a single
					string, delimited by ampersand.
		-->
		<xsl:variable name="labSpecimenCode">
			<xsl:choose>
				<xsl:when test="string-length(@code)"><xsl:value-of select="@code"/></xsl:when>
				<xsl:when test="string-length(@displayName)"><xsl:value-of select="@displayName"/></xsl:when>
				<xsl:when test="string-length(hl7:originalText/text())"><xsl:value-of select="hl7:originalText/text()"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="labSpecimenDescription">
			<xsl:choose>
				<xsl:when test="string-length(@displayName)"><xsl:value-of select="@displayName"/></xsl:when>
				<xsl:when test="string-length(hl7:originalText/text())"><xsl:value-of select="hl7:originalText/text()"/></xsl:when>
				<xsl:when test="string-length(@code)"><xsl:value-of select="@code"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="string-length($labSpecimenCode) and string-length($labSpecimenDescription)"><Specimen><xsl:value-of select="concat($labSpecimenCode, '&amp;', $labSpecimenDescription)"/></Specimen></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="ResultTime">
		<!--
			Field : Result Date/Time
			Target: HS.SDA3.Result ResultTime
			Target: /Container/LabOrders/LabOrder/Result/ResultTime
			Target: /Container/RadOrders/RadOrder/Result/ResultTime
			Target: /Container/OtherOrders/OtherOrder/Result/ResultTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/effectiveTime/@value
		-->
		<xsl:if test="@value"><ResultTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></ResultTime></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="ResultStatus">
		<!--
			Field : Result Status
			Target: HS.SDA3.Result ResultStatus
			Target: /Container/LabOrders/LabOrder/Result/ResultStatus
			Target: /Container/RadOrders/RadOrder/Result/ResultStatus
			Target: /Container/OtherOrders/OtherOrder/Result/ResultStatus
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/statusCode/@code
			Note  : CDA statusCode/@code is mapped to SDA Status as follows:
					CDA statusCode/@code = 'active', SDA Status = 'R'
					CDA statusCode/@code = 'completed', SDA Status = 'F'
					CDA statusCode/@code = 'corrected', SDA Status = 'C'
					CDA statusCode/@code = 'cancelled', SDA Status = 'X'
		-->
		<xsl:if test="@code">
			<ResultStatus>
				<xsl:choose>
					<xsl:when test="@code = 'active'">R</xsl:when>
					<xsl:when test="@code = 'completed'">F</xsl:when>
					<xsl:when test="@code = 'corrected'">C</xsl:when>
					<xsl:when test="@code = 'cancelled'">X</xsl:when>
				</xsl:choose>
			</ResultStatus>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="LabResultItem">
		<LabResultItem>
			<xsl:apply-templates select="." mode="TestItemCode"/>			
			<xsl:apply-templates select="hl7:value" mode="ResultValue"/>
			<xsl:apply-templates select="hl7:interpretationCode" mode="ResultInterpretation"/>
			<xsl:choose>
				<xsl:when test="count(hl7:referenceRange/hl7:observationRange) > 1">
					<xsl:apply-templates select="hl7:referenceRange/hl7:observationRange[hl7:interpretationCode/@code='N']" mode="ResultNormalRange"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:referenceRange/hl7:observationRange" mode="ResultNormalRange"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				TestItemStatus
				
				entryRelationship is where HS looks for the TestItemStatus
				in order to support more than just the Result Status value
				set (OID 2.16.840.1.113883.11.20.9.39).
				
				If not there, then use <statusCode>.
			-->
			<xsl:choose>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value">
					<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value" mode="TestItemStatus"/>
				</xsl:when>
				<xsl:when test="hl7:statusCode">
					<xsl:apply-templates select="hl7:statusCode" mode="TestItemStatus"/>
				</xsl:when>
			</xsl:choose>
			
			<!--
				Field : Result Test Performer
				Target: HS.SDA3.LabResultItem PerformedAt
				Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/PerformedAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/performer
				StructuredMappingRef: PerformedAt
				Note  : If CDA observation-level performer is not present
						then SDA PerformedAt is imported from the CDA
						organizer-level performer.
			-->
			<xsl:choose>
				<xsl:when test="hl7:performer"><xsl:apply-templates select="hl7:performer" mode="PerformedAt" /></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="parent::node()/parent::node()/hl7:performer" mode="PerformedAt" /></xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Result Test Comments
				Target: HS.SDA3.LabResultItem Comments
				Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="Comment"/>

			<!--
				Field : Result Test Observation Time
				Target: HS.SDA3.LabResultItem ObservationTime
				Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ObservationTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/effectiveTime/@value
			-->
			<xsl:apply-templates select="hl7:effectiveTime" mode="ObservationTime"/>

		</LabResultItem>
	</xsl:template>
	<xsl:template match="hl7:effectiveTime" mode="ObservationTime">
		<ObservationTime>
			<xsl:value-of select="isc:evaluate('xmltimestamp', @value)" />
		</ObservationTime>
	</xsl:template>
	<xsl:template match="*" mode="TestItemCode">
		<!--
			Field : Result Test Code
			Target: HS.SDA3.LabResultItem TestItemCode
			Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/code
			StructuredMappingRef: CodeTableDetail
		-->
		<!--
			Field : Result Test Code IsNumeric
			Target: HS.SDA3.LabResultItem TestItemCode.IsNumeric
			Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemCode/IsNumeric
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/value/@xsi:type
			Note  : If value/@xsi:type equals 'PQ' or 'ST', then
					IsNumeric is true. Otherwise, IsNumeric is false.
		-->
		<xsl:variable name="referenceLink" select="substring-after(hl7:code/hl7:originalText/hl7:reference/@value, '#')"/>
		<xsl:variable name="referenceValue">
			<xsl:choose>
				<xsl:when test="string-length($referenceLink)">
					<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="codingStandard">
			<xsl:choose>
				<xsl:when test="string-length(hl7:code/@codeSystem) and not(hl7:code/@codeSystem=$noCodeSystemOID)"><xsl:value-of select="normalize-space(hl7:code/@codeSystem)"/></xsl:when>
				<xsl:when test="hl7:code/@nullFlavor and string-length(hl7:code/hl7:translation[1]/@codeSystem) and not(hl7:code/hl7:translation[1]/@codeSystem=$noCodeSystemOID)"><xsl:value-of select="normalize-space(hl7:code/hl7:translation[1]/@codeSystem)"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!--
			Let originalText retain line feeds and excess white
			space, but only if there is anything more than line
			feeds and excess white space.
		-->
		<xsl:variable name="originalText">
			<xsl:choose>
				<xsl:when test="string-length(normalize-space($referenceValue))"><xsl:value-of select="$referenceValue"/></xsl:when>
				<xsl:when test="string-length(normalize-space(hl7:code/hl7:originalText/text()))"><xsl:value-of select="hl7:code/hl7:originalText/text()"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="string-length(normalize-space(hl7:code/@code))"><xsl:value-of select="normalize-space(hl7:code/@code)"/></xsl:when>
				<xsl:when test="hl7:code/@nullFlavor and string-length(hl7:code/hl7:translation[1]/@code)"><xsl:value-of select="normalize-space(hl7:code/hl7:translation[1]/@code)"/></xsl:when>
				<xsl:when test="string-length(normalize-space($referenceValue))"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
				<xsl:when test="string-length(normalize-space(hl7:code/hl7:originalText/text()))"><xsl:value-of select="normalize-space(hl7:code/hl7:originalText/text())"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="string-length(normalize-space(hl7:code/@displayName))"><xsl:value-of select="normalize-space(hl7:code/@displayName)"/></xsl:when>
				<xsl:when test="hl7:code/@nullFlavor and string-length(hl7:code/hl7:translation[1]/@displayName)"><xsl:value-of select="normalize-space(hl7:code/hl7:translation[1]/@displayName)"/></xsl:when>
				<xsl:when test="string-length(normalize-space($referenceValue))"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
				<xsl:when test="string-length(normalize-space(hl7:code/hl7:originalText/text()))"><xsl:value-of select="normalize-space(hl7:code/hl7:originalText/text())"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- useFirstTranslation indicates whether or not we used hl7:translation[1] for the primary imported data. -->
		<xsl:variable name="useFirstTranslation">
			<xsl:choose>
				<xsl:when test="hl7:code/@nullFlavor and string-length(hl7:code/hl7:translation[1]/@code) and not(string-length(normalize-space(hl7:code/@code)))">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<TestItemCode>
			<xsl:if test="string-length($codingStandard)">
				<SDACodingStandard>
					<xsl:apply-templates select="." mode="code-for-oid">
						<xsl:with-param name="OID" select="$codingStandard"/>
					</xsl:apply-templates>
				</SDACodingStandard>
			</xsl:if>
			<Code><xsl:value-of select="$code"/></Code>
			<Description><xsl:value-of select="$description"/></Description>
			<xsl:if test="string-length($originalText)">
				<OriginalText><xsl:value-of select="$originalText"/></OriginalText>
			</xsl:if>
			<IsNumeric>
				<xsl:choose>
					<xsl:when test="(hl7:value/@xsi:type = 'PQ') or (hl7:value/@xsi:type = 'ST')">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</IsNumeric>

			<!-- Prior Codes -->
			<xsl:apply-templates select="hl7:code" mode="PriorCodes">
				<xsl:with-param name="useFirstTranslation" select="$useFirstTranslation"/>
			</xsl:apply-templates>
		</TestItemCode>
	</xsl:template>
	
	<xsl:template match="*" mode="TestItemStatus">
		<!--
			Field : Result Test Status
			Target: HS.SDA3.LabResultItem TestItemStatus
			Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemStatus
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/entryRelationship/observation[code/@code='33999-4']/value/@code
			Note  : When importing SDA TestItemStatus, only the first found
					of CDA Test Status and CDA Test Status Code is used.  The
					mapping of CDA @code to SDA TestItemStatus is as follows:
					@code = 'corrected', TestItemStatus = 'C'
					@code = 'final', TestItemStatus = 'F'
					@code = 'partial', TestItemStatus = 'A'
					@code = 'preliminary', TestItemStatus = 'P'
					@code = 'active', TestItemStatus = 'P'
					@code = 'entered', TestItemStatus = 'R'
					@code = 'deleted', TestItemStatus = 'D'
					@code = 'in progress', TestItemStatus = 'I'
					@code = 'cancelled', TestItemStatus = 'X'
					@code = 'cannot result', TestItemStatus = 'X'
					@code = 'not tested', TestItemStatus = 'N'
					@code = 'updated to final', TestItemStatus = 'U'
					@code = 'wrong', TestItemStatus = 'W'
		-->
		<!--
			Field : Result Test Status
			Target: HS.SDA3.LabResultItem TestItemStatus
			Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/TestItemStatus
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/statusCode
			Note  : When importing SDA TestItemStatus, only the first found
					of CDA Test Status and CDA Test Status Code is used.  The
					mapping of CDA @code to SDA TestItemStatus is as follows:
					CDA @code = 'corrected', SDA TestItemStatus = 'C'
					CDA @code = 'final', SDA TestItemStatus = 'F'
					CDA @code = 'partial', SDA TestItemStatus = 'A'
					CDA @code = 'preliminary', SDA TestItemStatus = 'P'
					CDA @code = 'active', SDA TestItemStatus = 'P'
					CDA @code = 'entered', SDA TestItemStatus = 'R'
					CDA @code = 'deleted', SDA TestItemStatus = 'D'
					CDA @code = 'in progress', SDA TestItemStatus = 'I'
					CDA @code = 'cancelled', SDA TestItemStatus = 'X'
					CDA @code = 'cannot result', SDA TestItemStatus = 'X'
					CDA @code = 'not tested', SDA TestItemStatus = 'N'
					CDA @code = 'updated to final', SDA TestItemStatus = 'U'
					CDA @code = 'wrong', SDA TestItemStatus = 'W'
		-->
		<xsl:if test="@code">
			<TestItemStatus>
				<xsl:choose>
					<xsl:when test="@code = 'corrected'">C</xsl:when>
					<xsl:when test="@code = 'final'">F</xsl:when>
					<xsl:when test="@code = 'partial'">A</xsl:when>
					<xsl:when test="@code = 'preliminary'">P</xsl:when>
					<xsl:when test="@code = 'completed'">F</xsl:when>
					<xsl:when test="@code = 'active'">P</xsl:when>
					<xsl:when test="@code = 'entered'">R</xsl:when>
					<xsl:when test="@code = 'deleted'">D</xsl:when>
					<xsl:when test="@code = 'in progress'">I</xsl:when>
					<xsl:when test="@code = 'cancelled'">X</xsl:when>
					<xsl:when test="@code = 'cannot result'">X</xsl:when>
					<xsl:when test="@code = 'not tested'">N</xsl:when>
					<xsl:when test="@code = 'updated to final'">U</xsl:when>
					<xsl:when test="@code = 'wrong'">W</xsl:when>
				</xsl:choose>
			</TestItemStatus>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="ResultValue">
		<!--
			Field : Result Test Value
			Target: HS.SDA3.LabResultItem ResultValue
			Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultValue
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/value/@value
			Note  : If CDA result value/@xsi:type is not 'PQ' then SDA
					ResultValue is imported from CDA result value/text()
					instead of from value/@value.
		-->
		<!--
			Field : Result Test Value Unit
			Target: HS.SDA3.LabResultItem ResultValueUnits
			Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultValueUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/value/@unit
		-->
		<xsl:choose>
			<xsl:when test="@xsi:type='PQ'">
				<xsl:if test="@value"><ResultValue><xsl:value-of select="@value"/></ResultValue></xsl:if>
				<xsl:if test="@unit"><ResultValueUnits><xsl:value-of select="translate(@unit, '_', ' ')"/></ResultValueUnits></xsl:if>
			</xsl:when>
			<xsl:when test="string-length(translate(text(),'&#10;',''))">
				<ResultValue><xsl:value-of select="text()"/></ResultValue>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="referenceLink" select="substring-after(hl7:originalText/hl7:reference/@value, '#')"/>
				<xsl:if test="string-length($referenceLink)">
					<xsl:if test="string-length(translate(key('narrativeKey', $referenceLink),'&#10;',''))">
						<ResultValue><xsl:apply-templates select="key('narrativeKey', $referenceLink)" mode="importNarrative"/></ResultValue>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="ResultInterpretation">
		<!--
			Field : Result Interpretation
			Target: HS.SDA3.LabResultItem ResultInterpretation
			Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultInterpretation
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/interpretationCode/@code
		-->
		<xsl:if test="@code"><ResultInterpretation><xsl:value-of select="@code"/></ResultInterpretation></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="ResultNormalRange">
		<!--
			Field : Result Test Reference Range
			Target: HS.SDA3.LabResultItem ResultNormalRange
			Target: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultNormalRange
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.3.1']/entry/organizer/component/observation/referenceRange/observationRange/value
		-->
		<xsl:if test="hl7:value or hl7:text">
			<ResultNormalRange>
				<xsl:choose>
					<xsl:when test="hl7:value and hl7:value/hl7:low/@value and hl7:value/hl7:high/@value"><xsl:value-of select="concat(hl7:value/hl7:low/@value, '-', hl7:value/hl7:high/@value)"/></xsl:when>
					<xsl:when test="hl7:value and hl7:value/hl7:low/@value and hl7:value/hl7:high/@nullFlavor"><xsl:value-of select="concat('>=', hl7:value/hl7:low/@value)"/></xsl:when>
					<xsl:when test="hl7:value and hl7:value/hl7:low/@nullFlavor and hl7:value/hl7:high/@value"><xsl:value-of select="concat('&lt;=', hl7:value/hl7:high/@value)"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="hl7:text/text()"/></xsl:otherwise>
				</xsl:choose>						
			</ResultNormalRange>
		</xsl:if>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		
		The input node spec is $resultRootPath.
		
		Override this template with logic to determine and
		return an OrderCategory Code.  If none is returned
		then no OrderCategory Code will be imported.
	-->
	<xsl:template match="*" mode="order-category-code">
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		
		The input node spec is $resultRootPath.
	-->
	<xsl:template match="*" mode="ImportCustom-Order">
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		
		The input node spec is $resultRootPath.
	-->
	<xsl:template match="*" mode="ImportCustom-Result">
	</xsl:template>
</xsl:stylesheet>
