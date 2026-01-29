<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="diagnosticResults-Narrative">
		<xsl:param name="orderType"/>
		
		<text>
			<xsl:choose>
				<xsl:when test="$orderType = 'LAB'">
					<xsl:apply-templates select="LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResults-NarrativeDetail-LabResults">
						<xsl:sort select="ResultTime" order="descending"/>
						<xsl:with-param name="narrativeLinkCategory">results</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$orderType = 'RAD'">
					<table border="1" width="100%">
						<caption>Imaging Examination Result(s)</caption>
						<thead>
							<tr>
								<th>Test Description</th>
								<th>Test Time</th>
								<th>Test Comments</th>
								<th>Text Results</th>
								<th>Result Comments</th>
							</tr>
						</thead>
						<xsl:apply-templates select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResults-ImagingResults-NarrativeDetail">
							<xsl:sort select="ResultTime" order="descending"/>
							<xsl:with-param name="narrativeLinkCategory">imagingExaminationResults</xsl:with-param>
						</xsl:apply-templates>
					</table>
				</xsl:when>
			</xsl:choose>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResults-NarrativeDetail-LabResults">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<table border="1" width="100%">
		
			<xsl:choose>
				<xsl:when test="position()=1">
					<caption>Pathology Test Result(s)</caption>
				</xsl:when>
				<xsl:otherwise>
					<caption>  </caption>
				</xsl:otherwise>
			</xsl:choose>
			
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
				<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}">
					<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="../OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
					<td><xsl:apply-templates select="ResultTime" mode="narrativeDateFromODBC"/></td>
					<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="../Comments/text()"/></td>
					<!-- Used at RSNA to deal with HTML content: <td ID="{concat($exportConfiguration/results/narrativeLinkPrefixes/resultText/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="ResultText" mode="copy"/></td> -->
					<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultText/text(), $narrativeLinkSuffix)}"><xsl:value-of select="ResultText/text()"/></td>
					<td>
						<xsl:if test="string-length(ResultItems)">
							<xsl:apply-templates select="ResultItems" mode="diagnosticResults-NarrativeDetail-AtomicResults">
								<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
								<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
							</xsl:apply-templates>
						</xsl:if>
					</td>
					<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
				</tr>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="*" mode="diagnosticResults-NarrativeDetail-AtomicResults">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		<list>
			<item>
				<table border="1" width="100%">
					<caption>Atomic Results</caption>
					<thead>
						<tr>
							<th>Test Item</th>
							<th>Value</th>
							<th>Reference Range</th>
							<th>Comments</th>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="LabResultItem"
							mode="diagnosticResults-NarrativeDetail-LabResults-LabResultItem">
							<xsl:with-param name="narrativeLinkCategory"
								select="$narrativeLinkCategory"/>
							<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"
							/>
						</xsl:apply-templates>
					</tbody>
				</table>
			</item>
		</list>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResults-NarrativeDetail-LabResults-LabResultItem">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:variable name="testItemDescription"><xsl:apply-templates select="TestItemCode" mode="originalTextOrDescriptionOrCode"/></xsl:variable>
		<tr>
			<td><xsl:value-of select="$testItemDescription"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValue/text(), $narrativeLinkSuffix, '-', position())}"><xsl:value-of select="concat(ResultValue/text(), ' ', ResultValueUnits/text())"/></td>
			<td><xsl:value-of select="ResultNormalRange/text()"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValueComments/text(), $narrativeLinkSuffix, '-', position())}"><xsl:value-of select="Comments/text()"/></td>
		</tr>
	</xsl:template>	
	
	<xsl:template match="*" mode="diagnosticResults-ImagingResults-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory" select="'imagingExaminationResults'"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tbody>
			<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultNarrative/text(), $narrativeLinkSuffix)}">
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="../OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
				<td><xsl:apply-templates select="ResultTime" mode="narrativeDateFromODBC"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultTestComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="../Comments/text()"/></td>
				<!-- Used at RSNA to deal with HTML content: <td ID="{concat($exportConfiguration/results/narrativeLinkPrefixes/resultText/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="ResultText" mode="copy"/></td> -->
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultText/text(), $narrativeLinkSuffix)}"><xsl:value-of select="ResultText/text()"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
			</tr>
		</tbody>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResultsNEHTA-Entries">
		<xsl:param name="orderType"/>
		
		<xsl:choose>
			<xsl:when test="$orderType='LAB'">
				<xsl:apply-templates select="LabOrders/LabOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResultsNEHTA-EntryDetail">
					<xsl:sort select="ResultTime" order="descending"/>
					<xsl:with-param name="narrativeLinkCategory" select="'results'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$orderType='RAD'">
				<xsl:apply-templates select="RadOrders/RadOrder/Result[string-length(ResultText/text()) or string-length(ResultItems)]" mode="diagnosticResultsNEHTA-EntryDetail">
					<xsl:sort select="ResultTime" order="descending"/>
					<xsl:with-param name="narrativeLinkCategory" select="'imagingExaminationResults'"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResultsNEHTA-EntryDetail">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry>
			<!-- Result Battery -->
			<xsl:apply-templates select="." mode="battery-diagnosticResultsNEHTA">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="battery-diagnosticResultsNEHTA">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<observation classCode="OBS" moodCode="EVN">
			<!-- NEHTA wants only one <id> here. -->
			<xsl:choose>
				<xsl:when test="string-length(../PlacerId/text())">
					<xsl:apply-templates select=".." mode="id-Placer"/>
				</xsl:when>
				<xsl:when test="string-length(../FillerId/text())">
					<xsl:apply-templates select=".." mode="id-Filler"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select=".." mode="id-Placer"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select=".." mode="results-InitiatingOrder">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
			
			<xsl:apply-templates select=".." mode="diagnosticResultsNEHTA-testSpecimenDetails"/>
			
			<xsl:apply-templates select="ResultStatus" mode="observation-ResultStatus"/>
			
		<xsl:if test="$narrativeLinkCategory='imagingExaminationResults'">
			<!-- There is no SDA for Findings, but it is required. -->
			<entryRelationship typeCode="REFR">
				<observation classCode="OBS" moodCode="EVN">
					<id root="{isc:evaluate('createUUID')}"/>
					<code code="103.16503" codeSystem="1.2.36.1.2001.1001.101" codeSystemName="NCTIS Data Components" displayName="Findings"/>
					<text xsi:type="ST">No findings recorded.</text>
				 </observation>
			 </entryRelationship>
		 </xsl:if>

			<!-- Test Result Group -->
			<entryRelationship typeCode="COMP">
				<organizer classCode="BATTERY" moodCode="EVN">
					<xsl:apply-templates select=".." mode="id-Filler"/>
					<xsl:apply-templates select="../OrderItem" mode="generic-Coded"></xsl:apply-templates>
					
					<statusCode code="completed"/>
			
					<xsl:apply-templates select="." mode="effectiveTime-Result"/>
					<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
					<xsl:apply-templates select="EnteredAt" mode="informant"/>
			
					<xsl:apply-templates select="ResultText" mode="results-Text">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
						<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="ResultItems/LabResultItem[string-length(ResultValue/text())>0]" mode="results-Atomic">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
						<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
					</xsl:apply-templates>
				</organizer>
			</entryRelationship>
			
			<xsl:apply-templates select="." mode="effectiveTime-diagnosticResultsNEHTA">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
			</xsl:apply-templates>
			
		</observation>
	</xsl:template>

	<xsl:template match="*" mode="procedure-diagnosticResultsNEHTA">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component>
			<procedure classCode="PROC" moodCode="EVN">
				<xsl:apply-templates select="." mode="results-InitiatingOrder">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</procedure>
		</component>
	</xsl:template>

	<xsl:template match="*" mode="results-InitiatingOrder">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		<xsl:apply-templates select="OrderItem" mode="generic-Coded"></xsl:apply-templates>
		<statusCode code="completed"/>
		<xsl:apply-templates select="EnteredOn" mode="effectiveTime"/>
		<xsl:apply-templates select="OrderedBy" mode="performer"/>
		<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
		<xsl:apply-templates select="EnteredAt" mode="informant-noPatientIdentifier"/>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-Result">
		<xsl:choose>
			<xsl:when test="string-length(ResultTime)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="ResultTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-diagnosticResultsNEHTA">
		<xsl:param name="narrativeLinkCategory"/>
		
		<entryRelationship typeCode="COMP">
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<xsl:choose>
					<xsl:when test="$narrativeLinkCategory='results'">
						<code code="103.16605" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Pathology Test Result DateTime"/>
					</xsl:when>
					<xsl:otherwise>
						<code code="103.16589" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Imaging Examination Result DateTime"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="string-length(ResultTime)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="ResultTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
					<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="diagnosticResultsNEHTA-testSpecimenDetails">
		<entryRelationship typeCode="SUBJ">
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="102.16156.2.2.1" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Test Specimen Detail"/>
				<xsl:choose>
					<xsl:when test="string-length(SpecimenCollectedTime/text())"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="SpecimenCollectedTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
					<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="Specimen" mode="specimen"/>
				<xsl:variable name="receivedTime"><xsl:apply-templates select="SpecimenReceivedTime" mode="xmlToHL7TimeStamp"/></xsl:variable>
				<xsl:if test="string-length($receivedTime)">
					<entryRelationship typeCode="COMP">
						<observation classCode="OBS" moodCode="EVN">
							<code code="103.11014" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="DateTime Received"/>
							<value xsi:type="TS" value="{$receivedTime}"/>
						</observation>
					</entryRelationship>
				</xsl:if>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="specimen">
		<!--
			Field : Result Specimen
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.28']/entry/organizer/component/procedure/specimen/specimenRole/specimenPlayingEntity/code
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
		<!--
			Field : Result Specimen (for C37)
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.3.3.2.1']/entry/act/organizer/component/procedure/specimen/specimenRole/specimenPlayingEntity/code
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
				<xsl:apply-templates select="." mode="id-External"/>
				<xsl:apply-templates select="../../OrderItem" mode="generic-Coded"><xsl:with-param name="isCodeRequired" select="'1'"/></xsl:apply-templates>
				<text><xsl:value-of select="text()"/></text>
				<statusCode code="completed"/>
				<xsl:apply-templates select="parent::node()" mode="effectiveTime-Result"/>
				<value nullFlavor="NA" xsi:type="CD"/>
					<xsl:apply-templates select="../Comments" mode="comment-Result">
						<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultComments/text(), $narrativeLinkSuffix)"/>
					</xsl:apply-templates>
			</observation>
		</component>
	</xsl:template>	
	
	<xsl:template match="*" mode="results-Atomic">
		<xsl:param name="narrativeLinkCategory" select="'results'"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<component typeCode="COMP">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="id-results-Atomic"/>
				<xsl:apply-templates select="TestItemCode" mode="generic-Coded">
					<xsl:with-param name="isCodeRequired" select="'1'"/>
				</xsl:apply-templates>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="parent::node()/parent::node()" mode="effectiveTime-Result"/>
				
				<xsl:choose>
					<xsl:when test="TestItemCode/IsNumeric/text() = 'true'"><xsl:apply-templates select="ResultValue" mode="value-PQ"><xsl:with-param name="units" select="translate(ResultValueUnits, ' ', '_')"/></xsl:apply-templates></xsl:when>
					<xsl:otherwise><xsl:apply-templates select="ResultValue" mode="value-ST"/></xsl:otherwise>
				</xsl:choose>
				
				<xsl:apply-templates select="ResultInterpretation" mode="results-Interpretation"/>
				<xsl:apply-templates select="TestItemStatus" mode="observation-TestItemStatus"/>
				<xsl:apply-templates select="Comments" mode="comment-Result">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/resultValueComments/text(), $narrativeLinkSuffix, '-', position())"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="ResultNormalRange" mode="results-ReferenceRange"/>
			</observation>
		</component>
	</xsl:template>	
	
	<xsl:template match="*" mode="id-results-Atomic">
		<id root="{isc:evaluate('createUUID')}"/>
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
		<xsl:apply-templates select="." mode="nehta-Observation-Status"/>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-TestItemStatus">
		<xsl:apply-templates select="." mode="nehta-Observation-Status"/>
	</xsl:template>
	
	<xsl:template match="*" mode="nehta-Observation-Status">
		<entryRelationship typeCode="COMP">
			<observation classCode="OBS" moodCode="EVN">
				<code code="308552006" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT-AU" codeSystemVersion="20110531" displayName="report status"/>
				<text/>
				<statusCode code="completed"/>
				
				<!-- Status Detail -->
				<xsl:variable name="statusValue" select="concat('|',translate(text(), $lowerCase, $upperCase),'|')"/>
				<xsl:variable name="statusValueCode">
					<xsl:choose>
						<xsl:when test="contains('|3|F|',$statusValue)">3</xsl:when>
						<xsl:when test="contains('|2|R|V|A|P|',$statusValue)">2</xsl:when>
						<xsl:when test="contains('|4|C|K|',$statusValue)">4</xsl:when>
						<xsl:when test="contains('|1|I|O|S|',$statusValue)">1</xsl:when>
						<xsl:when test="contains('|5|X|',$statusValue)">5</xsl:when>
						<xsl:otherwise>unknown</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<!-- codeSystemName "NCTIS Result Status Values" is OID 1.2.36.1.2001.1001.101.104.16501 -->
						<SDACodingStandard>NCTIS Result Status Values</SDACodingStandard>
						<Code><xsl:value-of select="$statusValueCode"/></Code>
						<Description>
							<xsl:choose>
								<xsl:when test="$statusValueCode = '1'">Registered</xsl:when>
								<xsl:when test="$statusValueCode = '2'">Interim</xsl:when>
								<xsl:when test="$statusValueCode = '3'">Final</xsl:when>
								<xsl:when test="$statusValueCode = '4'">Amended</xsl:when>
								<xsl:when test="$statusValueCode = '5'">Cancelled</xsl:when>
								<xsl:otherwise>unknown</xsl:otherwise>
							</xsl:choose>
						</Description>
					</Status>
				</xsl:variable>
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<xsl:apply-templates select="$status" mode="value-CD"/>
			</observation>
		</entryRelationship>
	</xsl:template>
		
<xsl:template match="*" mode="results-ReferenceRange">
		<!--
			Field : Result Test Reference Range
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.28']/entry/organizer/component/observation/referenceRange/observationRange/value
			Source: HS.SDA3.LabResultItem ResultNormalRange
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/ResultNormalRange
		-->
		<!--
			Field : Result Test Reference Range (for C37)
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
			</observationRange>
		</referenceRange>
	</xsl:template>
		
	<xsl:template match="*" mode="performer-PerformedAt">
		<!-- NEHTA wants a performing person, not organization. -->
		<xsl:choose>
			<xsl:when test="../EnteredBy">
				<xsl:apply-templates select="../EnteredBy" mode="performer-PerformedBy"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="../../../EnteredBy" mode="performer-PerformedBy"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="performer-PerformedBy">
		<xsl:if test="$documentExportType='NEHTADischargeSummary' or $documentExportType='NEHTASharedHealthSummary'">
			<performer typeCode="PRF">
				<xsl:apply-templates select="parent::node()" mode="time"/>
				<xsl:apply-templates select="." mode="assignedEntity"/>
			</performer>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="results-ReferenceRangeCode">
		<code code="260395002" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="normal range"/>
	</xsl:template>
</xsl:stylesheet>
