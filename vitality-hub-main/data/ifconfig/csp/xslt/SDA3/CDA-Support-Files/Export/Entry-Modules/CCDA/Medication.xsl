<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Medication Variables -->
	<xsl:variable name="includeHistoricalMedications" select="$exportConfiguration/medications/currentMedication/includeHistoricalMedications/text()"/>
	<xsl:variable name="currentMedicationWindowInDays" select="$exportConfiguration/medications/currentMedication/windowInDays/text()"/>
	<xsl:variable name="hideCurrentMedicationsColumn" select="$exportConfiguration/medications/currentMedication/hideNarrativeColumn/text()"/>

	<!-- E = Executed, R = Replaced -->
	<xsl:variable name="medicationExecutedStatusCodes">|E|R|</xsl:variable>
	<!-- H = On-Hold, INT = Intended (default, if no status value specified), IP = In-Progress -->
	<xsl:variable name="medicationIntendedStatusCodes">|H|INT|IP|</xsl:variable>
	<!-- C = Cancelled, D = Discontinued -->
	<xsl:variable name="medicationCancelledStatusCodes">|C|D|</xsl:variable>

	<xsl:template match="*" mode="medications-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
			
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Ordered Medication Name</th>
						<th>Filled Medication Name</th>
						<th>Start Date</th>
						<th>Stop Date</th>
						<xsl:if test="not($hideCurrentMedicationsColumn='1')"><th>Current Medication?</th></xsl:if>
						<th>Ordering Clinician</th>
						<th>Indication</th>
						<th>Dosage</th>
						<th>Frequency</th>
						<th>Signature (SIG)</th>
						<th>Comments</th>
						<th>Components</th>
					</tr>
				</thead>
				<tbody>
					<xsl:choose>
						<xsl:when test="$narrativeLinkCategory = 'administeredMedications'">
							<xsl:apply-templates select="Medications/Medication[contains('E|I|O', key('EncNum', EncounterNumber)/EncounterType) and not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|'))) and (string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(key('EncNum', EncounterNumber)/FromTime/text(), 'TZ', ' '), translate(FromTime/text(), 'TZ', ' ')) &gt;= 0) and (not(string-length(key('EncNum', EncounterNumber)/ToTime/text())) or (string-length(ToTime/text()) and string-length(key('EncNum', EncounterNumber)/ToTime/text()) and isc:evaluate('dateDiff', 'dd', translate(key('EncNum', EncounterNumber)/ToTime/text(), 'TZ', ' '), translate(ToTime/text(), 'TZ', ' ')) &lt;= 0))]" mode="medications-NarrativeDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$narrativeLinkCategory = 'dischargeMedications'">
							<xsl:apply-templates select="Medications/Medication[not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="medications-NarrativeDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<!-- For Medications list, exclude medications whose FromTime is after today, as those belong in Plan of Care. -->
							<xsl:apply-templates select="Medications/Medication[(not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))) and not(isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)]" mode="medications-NarrativeDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="medications-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory"/>

		<xsl:variable name="isCurrentMedication"><xsl:apply-templates select="." mode="currentMedication"/></xsl:variable>
		<xsl:variable name="includeInExport"><xsl:apply-templates select="." mode="includeMedicationInExport"/></xsl:variable>
		
		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationNarrative/text(), $narrativeLinkSuffix)}">
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="DrugProduct" mode="originalTextOrDescriptionOrCode"/></td>
				<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
				<xsl:if test="not($hideCurrentMedicationsColumn='1')">
					<td>
						<xsl:choose>
							<xsl:when test="$isCurrentMedication = 1">Yes</xsl:when>
							<xsl:otherwise>No</xsl:otherwise>
						</xsl:choose>
					</td>
				</xsl:if>
				<td><xsl:apply-templates select="OrderedBy" mode="name-Person-Narrative"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationIndication/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Indication/text()"/></td>
				<td><xsl:value-of select="concat(DoseQuantity/text(), DoseUoM/Code/text())"/></td>
				<td><xsl:apply-templates select="Frequency" mode="descriptionOrCode"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationSignature/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="medication-textInstruction"/></td>
				<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
				<td>
					<xsl:if test="ComponentMeds/DrugProduct">
						<list>
							<xsl:apply-templates select="ComponentMeds/DrugProduct" mode="Medications-NarrativeDetail-componentMed">
								<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
								<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
							</xsl:apply-templates>
						</list>
					</xsl:if>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="DrugProduct" mode="Medications-NarrativeDetail-componentMed">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:variable name="narrativeLinkSuffix-component" select="concat($narrativeLinkSuffix,'-',position())"/>
		<xsl:variable name="componentDescription">
			<xsl:apply-templates select="." mode="descriptionOrCode"/>
		</xsl:variable>
		<xsl:variable name="componentText">
			<xsl:choose>
				<xsl:when test="string-length(StrengthQty/text()) and not(string-length(BaseQty/text()))">
					<xsl:value-of select="concat($componentDescription,' ',StrengthQty/text(),StrengthUnits/Description/text())"/>
				</xsl:when>
				<xsl:when test="string-length(StrengthQty/text()) and string-length(BaseQty/text())">
					<xsl:value-of select="concat($componentDescription,' ',StrengthQty/text(),StrengthUnits/Description/text(),'/',BaseQty/text(),BaseUnits/Description/text())"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<item><content ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationComponent/text(), $narrativeLinkSuffix-component)}"><xsl:value-of select="$componentText"/></content></item>
	</xsl:template>

	<xsl:template match="*" mode="medications-Entries">
		<xsl:param name="narrativeLinkCategory"/>

		<xsl:choose>
			<xsl:when test="$narrativeLinkCategory = 'administeredMedications'">
				<xsl:apply-templates select="Medications/Medication[contains('E|I|O', key('EncNum', EncounterNumber)/EncounterType) and not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|'))) and (string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(key('EncNum', EncounterNumber)/FromTime/text(), 'TZ', ' '), translate(FromTime/text(), 'TZ', ' ')) &gt;= 0) and (not(string-length(key('EncNum', EncounterNumber)/ToTime/text())) or (string-length(ToTime/text()) and string-length(key('EncNum', EncounterNumber)/ToTime/text()) and isc:evaluate('dateDiff', 'dd', translate(key('EncNum', EncounterNumber)/ToTime/text(), 'TZ', ' '), translate(ToTime/text(), 'TZ', ' ')) &lt;= 0))]" mode="medications-EntryDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$narrativeLinkCategory = 'dischargeMedications'">
				<xsl:apply-templates select="Medications/Medication[not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="dischargeMedications-EntryDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<!-- For Medications list, exclude medications whose FromTime is after today, as those belong in Plan of Care. -->
				<xsl:apply-templates select="Medications/Medication[(not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))) and not(isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)]" mode="medications-EntryDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template match="*" mode="dischargeMedications-EntryDetail">
		<xsl:param name="narrativeLinkCategory"/>

		<xsl:variable name="includeInExport"><xsl:apply-templates select="." mode="includeMedicationInExport"/></xsl:variable>
		
		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<entry typeCode="DRIV">
				<act classCode="ACT" moodCode="EVN">
					<xsl:apply-templates select="." mode="templateIds-dischargeMedicationEntry"/>
					<id nullFlavor="UNK"/>
					<code code="10183-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Discharge medication" />
					<statusCode code="completed"/>
					<entryRelationship typeCode="SUBJ">
						<xsl:apply-templates select="." mode="substanceAdministration">
							<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
							<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
						</xsl:apply-templates>
					</entryRelationship>
				</act>
			</entry>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="medications-EntryDetail">
		<xsl:param name="narrativeLinkCategory"/>

		<xsl:variable name="includeInExport"><xsl:apply-templates select="." mode="includeMedicationInExport"/></xsl:variable>
		
		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<entry typeCode="DRIV">
				<xsl:apply-templates select="." mode="substanceAdministration">
					<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</entry>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="medications-NoData">
		<xsl:param name="narrativeLinkCategory"/>
		
		<text><xsl:value-of select="$exportConfiguration/*[local-name() = $narrativeLinkCategory]/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="substanceAdministration">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>

		<substanceAdministration classCode="SBADM">
			<xsl:apply-templates select="." mode="substanceAdministration-moodCode"/>			
			<xsl:apply-templates select="." mode="templateIds-medicationAdministration"/>
			
			<!-- External, Placer, and Filler IDs-->
			<!--
				Field : Medication Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id[1]
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id[1]
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id[1]
				Source: HS.SDA3.Medication ExternalId
				Source: /Container/Medications/Medication/ExternalId
				StructuredMappingRef: id-External
			-->
			<!--
				Field : Medication Placer Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id[2]
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id[2]
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id[2]
				Source: HS.SDA3.AbstractOrder PlacerId
				Source: /Container/Medications/Medication/PlacerId
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
			<!--
				Field : Medication Filler Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id[3]
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id[3]
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id[3]
				Source: HS.SDA3.AbstractOrder FillerId
				Source: /Container/Medications/Medication/FillerId
				StructuredMappingRef: id-Filler
				Note  : SDA FillerId is exported to CDA id if one of these conditions is met:
						- Both SDA EnteringOrganization/Organization/Code and SDA FillerId have a value
						- Both SDA EnteredAt/Code and SDA FillerId have a value
						
						For example, if EnteringOrganization/Organization/Code equals "CGH", and
						CGH has OID 1.3.6.1.4.1.21367.2010.1.2.300.2.1, and FillerID equals 7676,
						then this is exported
						
						<id root="1.3.6.1.4.1.21367.2010.1.2.300.2.1" extension="7676" assigningAuthorityName="CGH-FillerId"/>
						
						Otherwise, a CDA id is exported with a GUID and some placeholder text.
						For example
						
						<id root="fcbcb478-fceb-11e3-ae03-31c1b7edac00" assigningAuthorityName="CGH-UnspecifiedFillerId"/>
			-->
			<xsl:apply-templates select="." mode="id-Medication"/>

			<code nullFlavor="NA"/>
			<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationSignature/text(), $narrativeLinkSuffix)}"/></text>
			<statusCode code="completed"/>
			
			<xsl:apply-templates select="." mode="medication-duration"/>
			<xsl:apply-templates select="Frequency" mode="medication-frequency"/>
			
			<!--
				Field : Medication Route
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/routeCode
				Source: HS.SDA3.AbstractMedication Route
				Source: /Container/Medications/Medication/Route
				StructuredMappingRef: generic-Coded
			-->
			<xsl:apply-templates select="Route" mode="code-route"/>
			
			<xsl:apply-templates select="." mode="medication-doseQuantity"/>
			<xsl:apply-templates select="." mode="medication-rateAmount"/>
			<xsl:apply-templates select="OrderItem" mode="medication-consumable"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<!--
				Field : Medication Author
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/author
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/author
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/author
				Source: HS.SDA3.AbstractOrder EnteredBy
				Source: /Container/Medications/Medication/EnteredBy
				StructuredMappingRef: author-Human
			-->
			<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
			
			<!--
				Field : Medication Information Source
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/informant
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/informant
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/informant
				Source: HS.SDA3.AbstractOrder EnteredAt
				Source: /Container/Medications/Medication/EnteredAt
				StructuredMappingRef: informant
			-->
			<xsl:apply-templates select="EnteredAt" mode="informant"/>
			
			<!--
				Field : Medication Comments
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Source: HS.SDA3.AbstractOrder Comments
				Source: /Container/Medications/Medication/Comments
			-->
			<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<xsl:apply-templates select="Status" mode="observation-MedicationOrderStatus"/>
			<xsl:apply-templates select="." mode="medication-indication">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
			
			<!-- Indicate supply both as ordered item and as filled drug product (if available) -->
			<xsl:apply-templates select="OrderItem" mode="medication-supplyOrder"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			<xsl:apply-templates select="DrugProduct" mode="medication-supplyFill"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<xsl:apply-templates select="ComponentMeds/DrugProduct" mode="medication-componentMed">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
			
			<!--
				Field : Medication Encounter
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship
				Source: HS.SDA3.AbstractOrder EncounterNumber
				Source: /Container/Medications/Medication/EncounterNumber
				StructuredMappingRef: encounterLink-entryRelationship
				Note  : This links the Medication to an encounter in the Encounters section.
			-->
			<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
		</substanceAdministration>
	</xsl:template>
	
	<xsl:template match="DrugProduct" mode="medication-componentMed">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>

		<xsl:variable name="narrativeLinkSuffix-component" select="concat($narrativeLinkSuffix,'-',position())"/>
		
		<entryRelationship typeCode="COMP">
			<substanceAdministration classCode="SBADM" moodCode="EVN">
				<templateId root="2.16.840.1.113883.10.20.22.4.16" />				
				
				<xsl:apply-templates select="." mode="id-External"/>

				<code nullFlavor="NA"/>
				<statusCode code="completed"/>
				
				<effectiveTime xsi:type="IVL_TS">
					<low nullFlavor="UNK"/>
					<high nullFlavor="UNK"/>
				</effectiveTime>
				
				<xsl:apply-templates select="." mode="medication-consumable"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationComponent/text(), $narrativeLinkSuffix-component)"/></xsl:apply-templates>
			</substanceAdministration>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-duration">
		<!--
			Field : Medication Duration Start Date/Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Source: HS.SDA3.AbstractOrder FromTime
			Source: /Container/Medications/Medication/FromTime
		-->
		<!--
			Field : Medication Duration End Date/Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Source: HS.SDA3.AbstractOrder ToTime
			Source: /Container/Medications/Medication/ToTime
		-->
		<xsl:apply-templates select="." mode="effectiveTime-IVL_TS"/>
	</xsl:template>

	<xsl:template match="*" mode="medication-frequency">
		<xsl:apply-templates select="." mode="effectiveTime-PIVL_TS"/>
	</xsl:template>

	<xsl:template match="*" mode="medication-doseQuantity">
		<!--
			Field : Medication Dose Quantity
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/doseQuantity/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/doseQuantity/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/doseQuantity/@value
			Source: HS.SDA3.AbstractMedication DoseQuantity
			Source: /Container/Medications/Medication/DoseQuantity
		-->
		<!--
			Field : Medication Dose Quantity Unit
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/doseQuantity/@unit
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/doseQuantity/@unit
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/doseQuantity/@unit
			Source: HS.SDA3.AbstractMedication DoseUoM
			Source: /Container/Medications/Medication/DoseUoM
		-->
		<xsl:choose>
			<xsl:when test="string-length(DoseQuantity)">
				<doseQuantity value="{DoseQuantity/text()}">
					<xsl:if test="string-length(DoseUoM/Code)"><xsl:attribute name="unit"><xsl:value-of select="DoseUoM/Code/text()"/></xsl:attribute></xsl:if>
				</doseQuantity>
			</xsl:when>
			<xsl:otherwise><doseQuantity nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<xsl:template match="*" mode="medication-quantity">
		<!--
			StructuredMapping: medication-quantity
			
			Field
			Path  : @value
			Source: BaseQty
			Source: BaseQty/text()
			
			Field
			Path  : @unit
			Source: BaseUnits
			Source: BaseUnits/text()
		-->
		<xsl:choose>
			<xsl:when test="string-length(BaseQty)">
				<quantity value="{BaseQty/text()}">
					<xsl:if test="string-length(BaseUnits)">
						<xsl:attribute name="unit"><xsl:apply-templates select="BaseUnits" mode="descriptionOrCode"/></xsl:attribute>
					</xsl:if>
				</quantity>
			</xsl:when>
			<!-- IHE Supply Entry wants the quantity information or nothing at all (no nullFlavor) -->
		</xsl:choose>		
	</xsl:template>
	
	<xsl:template match="*" mode="medication-fills">
		<xsl:choose>
			<xsl:when test="number(NumberOfRefills/text()) or NumberOfRefills/text()='0'">
				<repeatNumber value="{number(NumberOfRefills/text()+1)}"/>
			</xsl:when>
			<xsl:otherwise><repeatNumber nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<xsl:template match="*" mode="medication-rateAmount">
		<!--
			Field : Medication Rate Quantity Amount
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/rateQuantity/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/rateQuantity/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/rateQuantity/@value
			Source: HS.SDA3.AbstractMedication RateAmount
			Source: /Container/Medications/Medication/RateAmount
		-->
		<!--
			Field : Medication Rate Quantity Unit
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/rateQuantity/@unit
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/rateQuantity/@unit
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/rateQuantity/@unit
			Source: HS.SDA3.AbstractMedication RateUnits
			Source: /Container/Medications/Medication/RateUnits
		-->
		<xsl:choose>
			<xsl:when test="string-length(RateAmount)">
				<rateQuantity value="{RateAmount/text()}">
					<xsl:if test="string-length(RateUnits/Code)"><xsl:attribute name="unit"><xsl:value-of select="RateUnits/Code/text()"/></xsl:attribute></xsl:if>
				</rateQuantity>
			</xsl:when>
			<xsl:otherwise><rateQuantity nullFlavor="NI"/></xsl:otherwise>
		</xsl:choose>			
	</xsl:template>
	
	<xsl:template match="*" mode="medication-consumable">
		<xsl:param name="narrativeLink"/>
		
		<!--
			Field : Medication Ordered Product - Consumable
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial
			Source: HS.SDA3.AbstractOrder OrderItem
			Source: /Container/Medications/Medication/OrderItem
			StructuredMappingRef: medication-manufacturedMaterial
			Note  : Medication OrderItem is exported to consumable to
					indicate the product that was actually ordered.
		-->
		<consumable typeCode="CSM">
			<xsl:apply-templates select="." mode="medication-manufacturedProduct"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
		</consumable>		
	</xsl:template>

	<xsl:template match="*" mode="medication-supplyOrder">
		<xsl:param name="narrativeLink"/>
		
		<!--
			Field : Medication Ordered Product - Supply Intended
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']
			Source: /Container/Medications/Medication
			Note  : Medication OrderItem is exported to supply with
					moodCode='INT' to indicate the prescription for
					the product but the prescription has not yet been
					filled.
		-->
		<entryRelationship typeCode="REFR">
			<supply classCode="SPLY" moodCode="INT">
				<xsl:apply-templates select="." mode="templateIds-medicationSupply-INT"/>
				
				<!--
					Field : Medication Placer Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/id
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: /Container/Medications/Medication/PlacerId
					StructuredMappingRef: id-Placer
				-->
				<xsl:apply-templates select="parent::node()" mode="id-Placer"/>
				
				<statusCode code="completed"/>
				
				<!--
					Field : Medication Fills Order
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/repeatNumber/@value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/repeatNumber/@value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/repeatNumber/@value
					Source: HS.SDA3.AbstractMedication NumberOfRefills
					Source: /Container/Medications/Medication/NumberOfRefills
					Note  : CDA repeatNumber is intended to be number of fills.
							Therefore CDA repeatNumber equals SDA NumberOfRefills+1.
				-->
				<xsl:apply-templates select="parent::node()" mode="medication-fills"/>
				
				<!--
					Field : Medication Quantity Order
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/quantity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/quantity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/quantity
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/Medications/Medication/OrderItem
					StructuredMappingRef: medication-quantity
				-->
				<xsl:apply-templates select="parent::node()" mode="medication-quantity"/>
				
				<!--
					Field : Medication Product Supply Order
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/product/manufacturedProduct/manufacturedMaterial
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/product/manufacturedProduct/manufacturedMaterial
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/product/manufacturedProduct/manufacturedMaterial
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/Medications/Medication/OrderItem
					StructuredMappingRef: medication-manufacturedMaterial
				-->
				<product typeCode="PRD">
					<xsl:apply-templates select="." mode="medication-manufacturedProduct"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>					
				</product>

				<!--
					Field : Medication Ordering Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
					Source: HS.SDA3.AbstractOrder OrderedBy
					Source: /Container/Medications/Medication/OrderedBy
					Note  : C-CDA 1.1 specifies that Ordering Provider is an author - as opposed to performer - on the Supply Order.
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="parent::node()/OrderedBy" mode="author-Human"/>
			</supply>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="medication-supplyFill">
		<xsl:param name="narrativeLink"/>
		
		<!--
			Field : Medication Ordered Product - Supply Dispensed
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']
			Source: /Container/Medications/Medication
			Note  : Medication OrderItem is exported to supply with
					moodCode='EVN' to indicate the prescription has
					been filled, and to indicate the actual product
					that was dispensed.
		-->
		<entryRelationship typeCode="REFR">
			<supply classCode="SPLY" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-medicationSupply-EVN"/>
				
				<!--
					Field : Medication Prescription Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
					Source: HS.SDA3.AbstractMedication PrescriptionNumber
					Source: /Container/Medications/Medication/PrescriptionNumber
					StructuredMappingRef: id-PrescriptionNumber
				-->
				<xsl:apply-templates select="parent::node()" mode="id-PrescriptionNumber"/>
				
				<statusCode code="completed"/>
				
				<!--
					Field : Medication Fills Filled
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/repeatNumber/@value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/repeatNumber/@value
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/repeatNumber/@value
					Source: HS.SDA3.AbstractMedication NumberOfRefills
					Source: /Container/Medications/Medication/NumberOfRefills
					Note  : CDA repeatNumber is intended to be number of fills.
							Therefore CDA repeatNumber equals SDA NumberOfRefills+1.
				-->
				<xsl:apply-templates select="parent::node()" mode="medication-fills"/>
				
				<!--
					Field : Medication Quantity Filled
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity
					Source: HS.SDA3.AbstractMedication DrugProduct
					Source: /Container/Medications/Medication/DrugProduct
					StructuredMappingRef: medication-quantity
				-->
				<xsl:apply-templates select="." mode="medication-quantity"/>
				
				<!--
					Field : Medication Ordered Product Supply Fill
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial
					Source: HS.SDA3.AbstractMedication DrugProduct
					Source: /Container/Medications/Medication/DrugProduct
					StructuredMappingRef: medication-manufacturedMaterial
				-->
				<product typeCode="PRD">
					<xsl:apply-templates select="." mode="medication-manufacturedProduct"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>					
				</product>
			</supply>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="medication-manufacturedProduct">
		<xsl:param name="narrativeLink"/>
		
		<manufacturedProduct classCode="MANU">
			<xsl:apply-templates select="." mode="templateIds-manufacturedProduct-Medication"/>
			
			<xsl:apply-templates select="." mode="medication-manufacturedMaterial"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
		</manufacturedProduct>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-manufacturedMaterial">
		<xsl:param name="narrativeLink"/>
		
		<manufacturedMaterial classCode="MMAT" determinerCode="KIND">
			<!--
				This field has some unique requirements.  See HITSP/C83 v2.0
				sections 2.2.2.8.10 through 2.2.2.8.14.  <translation> is
				used here differently than <translation> on just about every
				other CDA export coded field.  Plus this field has two code
				systems that are valid for it, instead of just one.
			-->
			<xsl:variable name="sdaCodingStandardOID"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>			
			<xsl:variable name="description"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:variable>
			<!--
				StructuredMapping: medication-manufacturedMaterial
				
				Field
				Path  : code/@code
				Source: Code
				Source: Code/text()
				Note  : The code element is exported with attributes only when the SDA OrderItem SDACodingStandard indicates RXNORM.
				
				Field
				Path  : code/@displayName
				Source: Description
				Source: Description/text()
				Note  : The code element is exported with attributes only when the SDA OrderItem SDACodingStandard indicates RXNORM or NDC (National Drug Codes).
				
				Field
				Path  : code/translation/@code
				Source: Code
				Source: Code/text()
				Note  : The code translation element is exported only when the SDA OrderItem SDACodingStandard indicates RXNORM or NDC (National Drug Codes).
				
				Field
				Path  : code/translation/@displayName
				Source: Description
				Source: Description/text()
				Note  : The code translation element is exported only when the SDA OrderItem SDACodingStandard indicates RXNORM or NDC (National Drug Codes).
				
				Field
				Path  : name/text()
				Source: ProductName
				Source: ProductName/text()
				Note  : If ProductName is not present then Description is used.
			-->
			<xsl:choose>
				<xsl:when test="$sdaCodingStandardOID=$rxNormOID or $sdaCodingStandardOID=$ndcOID">
					<code code="{translate(Code/text(),' ','_')}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}" displayName="{$description}">
						<originalText><reference value="{$narrativeLink}"/></originalText>
						<translation code="{translate(Code/text(),' ','_')}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}" displayName="{$description}"/>
					</code>
				</xsl:when>
				<xsl:otherwise>
					<code nullFlavor="UNK">
						<originalText><reference value="{$narrativeLink}"/></originalText>
						<translation nullFlavor="UNK"/>
					</code>
				</xsl:otherwise>
			</xsl:choose>
			
			<name>
				<xsl:choose>
					<xsl:when test="string-length(ProductName)"><xsl:value-of select="ProductName/text()"/></xsl:when>
					<xsl:when test="string-length($description)"><xsl:value-of select="$description"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="'Unknown Medication'"/></xsl:otherwise>
				</xsl:choose>
			</name>
		</manufacturedMaterial>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-patientInstructions">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="true">
			<act classCode="ACT" moodCode="INT">
				<xsl:apply-templates select="." mode="templateIds-patientInstructions"/>
				
				<code code="PINSTRUCT" codeSystem="1.3.6.1.4.1.19376.1.5.3.2" codeSystemName="IHEActCode"/>
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationInstructions/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
			</act>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-indication">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>

		<!--
			Field : Medication Indication
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Source: HS.SDA3.AbstractMedication Indication
			Source: /Container/Medications/Medication/Indication
			Note  : SDA Indication is a string property that is exported as a coded value.
		-->
		
		<!-- Condition being treated -->
		<xsl:if test="string-length(Indication)">
			<entryRelationship typeCode="RSON">
				<observation classCode="OBS" moodCode="EVN">				
					<xsl:apply-templates select="." mode="templateIds-indication"/>
					
					<id nullFlavor="{$idNullFlavor}"/>
					
					<!-- SDA does not have an Indication Type property.  "Problem" is hard-coded and adequate. -->
					<code code="55607006" displayName="Problem" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}"/>
					
					<statusCode code="completed"/>
					<effectiveTime nullFlavor="UNK"/>
					
					<!--
						In SDA, Indication is a %String property.
												
						C-CDA allows the use of nullFlavor when the Indication
						is not known to be a SNOMED code.  Because Indication
						is %String, this template exports nullFlavor plus a
						a translation element that uses $noCodeSystemOID as
						the codeSystem.
					-->
					<xsl:variable name="indicationInformation">
						<Indication xmlns="">
							<Code><xsl:value-of select="translate(Indication/text(),' ','_')"/></Code>
							<Description><xsl:value-of select="Indication/text()"/></Description>
						</Indication>
					</xsl:variable>
					
					<xsl:variable name="indication" select="exsl:node-set($indicationInformation)/Indication"/>
					
					<xsl:apply-templates select="$indication" mode="value-Coded">
						<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationIndication/text(), $narrativeLinkSuffix)"/>
						<xsl:with-param name="xsiType" select="'CD'"/>
						<xsl:with-param name="requiredCodeSystemOID" select="$snomedOID"/>
					</xsl:apply-templates>
				</observation>
			</entryRelationship>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="observation-MedicationOrderStatus">
		<!--
			Field : Medication Status
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/observation[code/@code='33999-4']/value/@code
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/observation[code/@code='33999-4']/value/@code
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/observation[code/@code='33999-4']/value/@code
			Source: HS.SDA3.AbstractOrder Status
			Source: /Container/Medications/Medication/Status
		-->
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-medicationOrderStatusObservation"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!-- Status Detail:  Medication Order Status in SDA can be one of D, C, R, H, IP, or E -->
				<xsl:variable name="statusValue" select="translate(text(), $lowerCase, $upperCase)"/>
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<SDACodingStandard><xsl:value-of select="$snomedName"/></SDACodingStandard>
						<Code>
							<xsl:choose>
								<xsl:when test="$statusValue = 'H'">421139008</xsl:when>
								<xsl:when test="$statusValue = 'IP'">55561003</xsl:when>
								<xsl:otherwise>73425007</xsl:otherwise>
							</xsl:choose>
						</Code>
						<Description>
							<xsl:choose>
								<xsl:when test="$statusValue = 'H'">On Hold</xsl:when>
								<xsl:when test="$statusValue = 'IP'">Active</xsl:when>
								<xsl:otherwise>Inactive</xsl:otherwise>
							</xsl:choose>
						</Description>
					</Status>
				</xsl:variable>
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<xsl:apply-templates select="$status" mode="snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="includeMedicationInExport">
		<xsl:variable name="isCurrentMedication"><xsl:apply-templates select="." mode="currentMedication"/></xsl:variable>
		<xsl:choose>
			<xsl:when test="($includeHistoricalMedications = 1)">1</xsl:when>
			<xsl:when test="($includeHistoricalMedications = 0) and ($isCurrentMedication = 1)">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="currentMedication">
		<xsl:variable name="isWithinCurrentMedicationWindow" select="isc:evaluate('dateDiff', 'dd', translate(translate(FromTime/text(), 'Z', ''), 'T', ' ')) &lt;= $currentMedicationWindowInDays"/>
		<xsl:variable name="isInactiveOrCanceled" select="contains('|I|CA|C|', concat('|', Status/text(), '|'))"/>
		<xsl:variable name="isNotEnded" select="not(ToTime)"/>
		
		<xsl:choose>
			<xsl:when test="$isWithinCurrentMedicationWindow and not($isInactiveOrCanceled)">1</xsl:when>
			<xsl:when test="(not($isWithinCurrentMedicationWindow) and $isNotEnded) and not($isInactiveOrCanceled)">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="substanceAdministration-moodCode">
		<!-- According to CCD specification, moodCode for a substanceAdministration must be either EVN (Event) or INT (Intended, default) -->
		<xsl:attribute name="moodCode">
			<xsl:choose>
				<xsl:when test="string-length(DrugProduct)">EVN</xsl:when>
				<xsl:when test="contains($medicationExecutedStatusCodes, concat('|', Status/text(), '|'))">EVN</xsl:when>
				<xsl:when test="contains($medicationIntendedStatusCodes, concat('|', Status/text(), '|'))">INT</xsl:when>
				<xsl:otherwise>INT</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="*" mode="medication-textInstruction">		
		<!--
			Field : Medication Free Text Sig
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/text
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/text
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/text
			Source: HS.SDA3.AbstractOrder TextInstruction
			Source: /Container/Medications/Medication/TextInstruction
		-->
		<xsl:choose>
			<xsl:when test="string-length(DosageStep[1]/TextInstruction/text())">
				<xsl:value-of select="DosageStep[1]/TextInstruction/text()"/>
			</xsl:when>
			<xsl:when test="string-length(TextInstruction/text())">
				<xsl:value-of select="TextInstruction/text()"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-medicationAdministration">
		<templateId root="{$ccda-MedicationActivity}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-dischargeMedicationEntry">
		<templateId root="{$ccda-DischargeMedication}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-manufacturedProduct-Medication">
		<templateId root="{$ccda-MedicationInformation}"/>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-patientInstructions">
		<templateId root="{$ccda-Instructions}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-indication">
		<templateId root="{$ccda-Indication}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-medicationOrderStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-MedicationStatusObservation"><templateId root="{$hl7-CCD-MedicationStatusObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-medicationSupply-INT">
		<templateId root="{$ccda-MedicationSupplyOrder}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-medicationSupply-EVN">
		<templateId root="{$ccda-MedicationDispense}"/>
	</xsl:template>
</xsl:stylesheet>
