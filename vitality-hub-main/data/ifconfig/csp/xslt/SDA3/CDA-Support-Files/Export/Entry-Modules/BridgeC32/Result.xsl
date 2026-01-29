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
					<!-- With HITSP C37, we only export LAB results (not RAD or OTH) -->
					<xsl:choose>
						<xsl:when test="$orderType = 'LAB'">
							<xsl:apply-templates select="LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResults-NarrativeDetail">
								<xsl:sort select="ResultTime" order="descending"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | OtherOrders/OtherOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResults-NarrativeDetail">
								<xsl:sort select="ResultTime" order="descending"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResults-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		

		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="../OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="ResultTime" mode="narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="../Comments/text()"/></td>
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

	<xsl:template match="*" mode="diagnosticResultsC32-Entries">
		<xsl:apply-templates select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)] | OtherOrders/OtherOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResultsC32-EntryDetail">
			<xsl:sort select="ResultTime" order="descending"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="diagnosticResultsC37-Entries">
		<xsl:param name="orderType"/>

		<!-- With HITSP C37, we only export LAB results (not RAD or OTH) -->
		<xsl:apply-templates select="LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResultsC37-EntryDetail">
			<xsl:sort select="ResultTime" order="descending"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResults-NoData">
		<text><xsl:value-of select="$exportConfiguration/results/emptySection/narrativeText/text()"/></text>
		<entry>
			<procedure classCode="PROC" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-ResultsC32Procedure"/>
				
				<id nullFlavor="NI"/>
				<code nullFlavor="NI"><originalText><reference value="#noProcedures-1"/></originalText></code>
				<text><reference nullFlavor="NI"/></text>
				<statusCode code="completed"/>
			</procedure>
		</entry>
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<templateId root="2.16.840.1.113883.3.88.11.83.15.1"/>
				<templateId root="2.16.840.1.113883.10.20.1.31"/>
				<templateId root="1.3.6.1.4.1.19376.1.5.3.1.4.13"/>
				
				<id nullFlavor="NI"/>
				<code code="ASSERTION" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
				<text><reference value="#noResults-1"/></text>
				<statusCode code="completed"/>
				<effectiveTime nullFlavor="NI"/>
				<value xsi:type="ST">This patient has no known results.</value>
			</observation>
		</entry>		
	</xsl:template>

	<xsl:template match="*" mode="diagnosticResultsC32-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry>
			<!-- Result Battery -->
			<xsl:apply-templates select="." mode="battery-ResultsC32"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="diagnosticResultsC37-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<xsl:apply-templates select="." mode="templateIds-ResultsC37Entry"/>

			<act classCode="ACT" moodCode="EVN">
				<xsl:apply-templates select=".." mode="results-InitiatingOrder"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
				
				<!-- Result Battery -->
				<entryRelationship typeCode="COMP">
					<xsl:apply-templates select="." mode="battery-ResultsC37"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>					
				</entryRelationship>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="battery-ResultsC32">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<organizer classCode="BATTERY" moodCode="EVN">
			<xsl:apply-templates select="." mode="templateIds-ResultsOrganizer"/>
			
			<!--
				HS.SDA3.AbstractOrder FillerId
				CDA Section: Results
				CDA Field: Result ID
				CDA XPath: entry/organizer/id
				
				AbstractOrder is sub-classed by HS.SDA3.LabOrder, HS.SDA3.RadOrder, HS.SDA3.OtherOrder
			-->			
			<xsl:apply-templates select=".." mode="id-Filler"/>
			
			<!--
				HS.SDA3.AbstractOrder OrderItem
				CDA Section: Results
				CDA Field: Result Type
				CDA XPath: entry/organizer/code
				
				AbstractOrder is sub-classed by HS.SDA3.LabOrder, HS.SDA3.RadOrder, HS.SDA3.OtherOrder
			-->			
			<xsl:apply-templates select="../OrderItem" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<statusCode code="completed"/>
			
			<xsl:apply-templates select="." mode="effectiveTime-Result"/>
			
			<!--
				HS.SDA3.AbstractOrder OrderItem
				CDA Section: Results
				CDA Field: Result Date/Time
				CDA XPath: entry/organizer/effectiveTime
				
				AbstractOrder is sub-classed by HS.SDA3.LabOrder, HS.SDA3.RadOrder, HS.SDA3.OtherOrder
			-->			
			<xsl:apply-templates select="PerformedAt" mode="performer-PerformedAt"/>
			<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
			<xsl:apply-templates select="EnteredAt" mode="informant"/>
			
			<xsl:apply-templates select=".." mode="procedure-ResultsC32"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="ResultText" mode="results-Text"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="ResultItems/LabResultItem[string-length(ResultValue/text())>0]" mode="results-Atomic"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="Comments" mode="comment-component"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<!-- Link this battery to encounter noted in encounters section -->
			<xsl:apply-templates select="parent::node()" mode="encounterLink-component"/>
		</organizer>
	</xsl:template>

	<xsl:template match="*" mode="battery-ResultsC37">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<organizer classCode="BATTERY" moodCode="EVN">
			<xsl:apply-templates select="." mode="templateIds-ResultsOrganizer"/>
			
			<xsl:apply-templates select=".." mode="id-Filler"/>
			<xsl:apply-templates select="../OrderItem" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<statusCode code="completed"/>
			
			<xsl:apply-templates select="." mode="effectiveTime-Result"/>
			<xsl:apply-templates select="PerformedAt" mode="performer-PerformedAt"/>
			<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
			<xsl:apply-templates select="EnteredAt" mode="informant-noPatientIdentifier"/>				
			
			<xsl:apply-templates select="ResultStatus" mode="observation-ResultStatus"/>
			<xsl:apply-templates select="ResultText" mode="results-Text"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="ResultItems/LabResultItem[string-length(ResultValue/text())>0]" mode="results-Atomic"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			<xsl:apply-templates select="Comments" mode="comment-component"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
		</organizer>
	</xsl:template>

	<xsl:template match="*" mode="procedure-ResultsC32">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component>
			<procedure classCode="PROC" moodCode="EVN">
				<!-- This might be the same as a regular procedure:  consider merging two templates into one -->
				<xsl:apply-templates select="." mode="templateIds-ResultsC32Procedure"/>
				
				<xsl:apply-templates select="." mode="results-InitiatingOrder"><xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/></xsl:apply-templates>
			</procedure>
		</component>
	</xsl:template>
	
	<xsl:template match="*" mode="results-InitiatingOrder">
		<xsl:param name="narrativeLinkSuffix"/>
		<xsl:apply-templates select="." mode="id-Placer"/>
		<xsl:apply-templates select="OrderItem" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
		<text><reference value="{concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}"/></text>
		<statusCode code="completed"/>
		<!-- Bridge C32 wants effectiveTime present as nullFlavor when there is no value to report. -->
		<xsl:choose>
			<xsl:when test="EnteredOn">
				<xsl:apply-templates select="EnteredOn" mode="effectiveTime"/>
			</xsl:when>
			<xsl:otherwise>
				<effectiveTime nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="Specimen" mode="specimen"/>
		<xsl:apply-templates select="OrderedBy" mode="performer"/>
		<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
		<xsl:apply-templates select="EnteredAt" mode="informant-noPatientIdentifier"/>
		<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/results/narrativeLinkPrefixes/resultTestComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-Result">
		<xsl:choose>
			<xsl:when test="string-length(ResultTime)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="ResultTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="specimen">
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
				
				<xsl:apply-templates select="." mode="id-External"/>
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
				<xsl:apply-templates select="PerformedAt" mode="performer-PerformedAt"/>
				<xsl:apply-templates select="TestItemStatus" mode="observation-TestItemStatus"/>
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValueComments/text(), $narrativeLinkSuffix, '-', position())"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="ResultNormalRange" mode="results-ReferenceRange"/>
			</observation>
		</component>
	</xsl:template>
	
	<xsl:template match="*" mode="id-results-Atomic">
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

	<xsl:template match="*" mode="observation-ResultStatus">
		<component>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-resultStatusObservation"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<text/>
				<statusCode code="completed"/>
				
				<!--
					Status Detail
				
					text() is from HS.SDA3.Result ResultStatus, which
					can have any value defined in ^OEC("RESST"), whose
					initial values are in HS-Default-ResultStatus.txt,
					whose values are taken from the HL7v2.5 code table
					for result status.  COR, FIN and ENT are supported
					only as deprecated values.  Use C, F or R instead.
				-->
				<xsl:variable name="statusValue" select="concat('|',translate(text(), $lowerCase, $upperCase),'|')"/>
				<xsl:variable name="statusValueCode">
					<xsl:choose>
						<xsl:when test="contains('|F|FIN|',$statusValue)">completed</xsl:when>
						<xsl:when test="contains('|R|ENT|I|V|O|S|A|P|',$statusValue)">active</xsl:when>
						<xsl:when test="contains('|C|COR|K|',$statusValue)">corrected</xsl:when>
						<xsl:when test="$statusValue = '|X|'">cancelled</xsl:when>
						<xsl:otherwise>unknown</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<SDACodingStandard><xsl:value-of select="$actStatusName"/></SDACodingStandard>
						<Code><xsl:value-of select="$statusValueCode"/></Code>
						<Description><xsl:value-of select="$statusValueCode"/></Description>
					</Status>
				</xsl:variable>
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<xsl:apply-templates select="$status" mode="value-CE"/>
			</observation>
		</component>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-TestItemStatus">
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
						<SDACodingStandard><xsl:value-of select="$snomedName"/></SDACodingStandard>
						<Code>
							<xsl:choose>
								<xsl:when test="$statusValue = 'A'">partial</xsl:when>
								<xsl:when test="$statusValue = 'C'">corrected</xsl:when>
								<xsl:when test="$statusValue = 'F'">final</xsl:when>
								<xsl:when test="$statusValue = 'K'">corrected</xsl:when>
								<xsl:when test="$statusValue = 'P'">preliminary</xsl:when>
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
		<performer typeCode="PRF">
			<xsl:apply-templates select="parent::node()" mode="time"/>
			<xsl:apply-templates select="." mode="assignedEntity-performer"/>
		</performer>
	</xsl:template>
	
	<xsl:template match="*" mode="results-ReferenceRangeCode">
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-ResultsOrganizer">
		<xsl:if test="$hl7-CCD-ResultOrganizer"><templateId root="{$hl7-CCD-ResultOrganizer}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-ResultsC32Procedure">
		<xsl:if test="$hitsp-CDA-Procedure"><templateId root="{$hitsp-CDA-Procedure}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ProcedureActivity"><templateId root="{$hl7-CCD-ProcedureActivity}"/></xsl:if>
		<xsl:if test="$ihe-PCC_CDASupplement-ProcedureEntry"><templateId root="{$ihe-PCC_CDASupplement-ProcedureEntry}"/></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-ResultsC32TextReport">
		<xsl:if test="$hitsp-CDA-Results"><templateId root="{$hitsp-CDA-Results}"/></xsl:if>
		<xsl:if test="$hitsp-CDA-Results-C83v2"><templateId root="{$hitsp-CDA-Results-C83v2}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ResultObservation"><templateId root="{$hl7-CCD-ResultObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SimpleObservations"><templateId root="{$ihe-PCC-SimpleObservations}"/></xsl:if>		
	</xsl:template>

	<xsl:template match="*" mode="templateIds-ResultsAtomicValues">
		<xsl:if test="$hitsp-CDA-Results"><templateId root="{$hitsp-CDA-Results}"/></xsl:if>
		<xsl:if test="$hitsp-CDA-Results-C83v2"><templateId root="{$hitsp-CDA-Results-C83v2}"/></xsl:if>
		<xsl:if test="$hl7-CCD-ResultObservation"><templateId root="{$hl7-CCD-ResultObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SimpleObservations"><templateId root="{$ihe-PCC-SimpleObservations}"/></xsl:if>
		<xsl:if test="$ihe-PCC-LaboratoryObservation"><templateId root="{$ihe-PCC-LaboratoryObservation}"/></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-ResultsC37Entry">
		<xsl:if test="$hitsp-CDA-Results"><templateId root="{$hitsp-CDA-Results}"/></xsl:if>
		<xsl:if test="$ihe-PCC-LaboratoryReportEntry"><templateId root="{$ihe-PCC-LaboratoryReportEntry}" extension="Lab.Report.Data.Processing.Entry"/></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-resultStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
