<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Medication Variables -->
	<xsl:variable name="includeHistoricalMedications" select="$exportConfiguration/medications/currentMedication/includeHistoricalMedications/text()"/>
	<xsl:variable name="currentMedicationWindowInDays" select="$exportConfiguration/medications/currentMedication/windowInDays/text()"/>

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
						<th>Current Medication?</th>
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
							<xsl:apply-templates select="Medications/Medication[contains('E|I|O', key('EncNum', EncounterNumber)/EncounterType) and not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="medications-NarrativeDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="Medications/Medication[not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="medications-NarrativeDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
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
				<td>
					<xsl:choose>
						<xsl:when test="$isCurrentMedication = 1">Yes</xsl:when>
						<xsl:otherwise>No</xsl:otherwise>
					</xsl:choose>
				</td>
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
				<xsl:apply-templates select="Medications/Medication[contains('E|I|O', key('EncNum', EncounterNumber)/EncounterType)  and not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="medications-EntryDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="Medications/Medication[not(contains($medicationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="medications-EntryDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
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
		<text><xsl:value-of select="$exportConfiguration/medications/emptySection/narrativeText/text()"/></text>
		<entry typeCode="DRIV">
			<substanceAdministration classCode="SBADM" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-medicationAdministration"/>
				<id nullFlavor="NI"/>
				<code code="182849000" codeSystem="{$snomedOID}" displayName="No Drug Therapy Prescribed" codeSystemName="{$snomedName}"/>
				<statusCode code="completed"/>							
				<consumable>
					<manufacturedProduct>
						<xsl:apply-templates select="." mode="templateIds-manufacturedProduct-Medication"/>
						<manufacturedMaterial>										
							<code>
								<originalText>
									<reference value="#noMedications-1"/>
								</originalText>
							</code>										
						</manufacturedMaterial>
					</manufacturedProduct>
				</consumable>
			</substanceAdministration>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="substanceAdministration">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>

		<substanceAdministration classCode="SBADM">
			<xsl:apply-templates select="." mode="substanceAdministration-moodCode"/>			
			<xsl:apply-templates select="." mode="templateIds-medicationAdministration">
				<xsl:with-param name="hasComponentMeds" select="ComponentMeds"/>
			</xsl:apply-templates>
			
			<!-- External, Placer, and Filler IDs-->
			<!--
				HS.SDA3.Medication ExternalId
				CDA Field: Id
				CDA XPath: entry/substanceAdministration/id
			-->
			<!--
				HS.SDA3.Medication PlacerId
				CDA Field: Placer Id
				CDA XPath: entry/substanceAdministration/id
				monkey off your back
			-->
			<!--
				HS.SDA3.Medication FillerId
				CDA Field: Filler Id
				CDA XPath: entry/substanceAdministration/id
			-->			
			<xsl:apply-templates select="." mode="id-Medication"/>

			<code nullFlavor="NA"/>
			<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationSignature/text(), $narrativeLinkSuffix)}"/></text>
			<statusCode code="completed"/>
			
			<xsl:apply-templates select="." mode="medication-duration"/>
			<xsl:apply-templates select="Frequency" mode="medication-frequency"/>
			
			<!--
				HS.SDA3.Medication Route
				CDA Field: Route
				CDA XPath: entry/substanceAdministration/routeCode
			-->			
			<xsl:apply-templates select="Route" mode="code-route"/>
			<xsl:apply-templates select="." mode="medication-doseQuantity"/>
			<xsl:apply-templates select="." mode="medication-rateAmount"/>
			<xsl:apply-templates select="OrderItem" mode="medication-consumable"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			<xsl:apply-templates select="EnteredBy" mode="author-Human"/> 
			<xsl:apply-templates select="EnteredAt" mode="informant"/>
			<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			<xsl:apply-templates select="ComponentMeds/DrugProduct" mode="substanceAdministration-componentMed">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="Status" mode="observation-MedicationOrderStatus"/>
			<xsl:apply-templates select="." mode="medication-indication">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
			
			<!-- Indicate supply both as ordered item and as filled drug product (if available) -->
			<xsl:apply-templates select="OrderItem" mode="medication-supplyOrder"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			<xsl:apply-templates select="DrugProduct" mode="medication-supplyFill"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			
			<!-- Link this medication to encounter noted in encounters section -->
			<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
		</substanceAdministration>
	</xsl:template>
	
	<xsl:template match="DrugProduct" mode="substanceAdministration-componentMed">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>

		<xsl:variable name="narrativeLinkSuffix-component" select="concat($narrativeLinkSuffix,'-',position())"/>
		
		<entryRelationship typeCode="COMP">
			<substanceAdministration classCode="SBADM">
				<xsl:apply-templates select="." mode="substanceAdministration-moodCode"/>			
				<xsl:apply-templates select="." mode="templateIds-medicationAdministration"/>
				
				<!-- External, Placer, and Filler IDs-->
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
			HS.SDA3.Medication FromTime
			HS.SDA3.Medication ToTime
			CDA Field: Duration
			CDA XPath: entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']
		-->	
		<xsl:apply-templates select="." mode="effectiveTime-IVL_TS"/>
	</xsl:template>

	<xsl:template match="*" mode="medication-frequency">
		<xsl:apply-templates select="." mode="effectiveTime-PIVL_TS"/>
	</xsl:template>

	<xsl:template match="*" mode="medication-doseQuantity">
		<!--
			HS.SDA3.Medication DoseQuantity
			CDA Field: Dose
			CDA XPath: entry/substanceAdministration/doseQuantity/@value
		-->
		<!--
			HS.SDA3.Medication DoseUoM
			CDA Field: Dose
			CDA XPath: entry/substanceAdministration/doseQuantity/@unit
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
			HS.SDA3.Medication BaseQty
			CDA Field: Quantity Ordered
			CDA XPath: entry/substanceAdministration/entryRelationship/supply/quantity/@value
		-->
		<!--
			HS.SDA3.Medication BaseUnits
			CDA Field: Quantity Ordered
			CDA XPath: entry/substanceAdministration/entryRelationship/supply/quantity/@unit
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
		<!--
			HS.SDA3.Medication NumberOfRefills
			CDA Field: Fills
			CDA XPath: entry/substanceAdministration/entryRelationship/supply/repeatNumber/@value
		-->		
		<xsl:choose>
			<xsl:when test="number(NumberOfRefills/text()) or NumberOfRefills/text()='0'">
				<repeatNumber value="{number(NumberOfRefills/text()+1)}"/>
			</xsl:when>
			<xsl:otherwise><repeatNumber nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<xsl:template match="*" mode="medication-rateAmount">
		<!--
			HS.SDA3.Medication RateAmount
			CDA Field: Rate Quantity Amount
			CDA XPath: entry/substanceAdministration/rateQuantity/@value
		-->
		<!--
			HS.SDA3.Medication RateUnits
			CDA Field: Rate Quantity Amount
			CDA XPath: entry/substanceAdministration/rateQuantity/@unit
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
		
		<consumable typeCode="CSM">
			<xsl:apply-templates select="." mode="medication-manufacturedProduct"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
		</consumable>		
	</xsl:template>

	<xsl:template match="*" mode="medication-supplyOrder">
		<xsl:param name="narrativeLink"/>
		
		<entryRelationship typeCode="REFR">
			<supply classCode="SPLY" moodCode="INT">
				<xsl:apply-templates select="." mode="templateIds-medicationSupply-INT"/>
				
				<xsl:apply-templates select="parent::node()" mode="id-Placer"/>
				
				<xsl:apply-templates select="parent::node()" mode="medication-fills"/>
				
				<xsl:apply-templates select="parent::node()" mode="medication-quantity"/>
				
				<product typeCode="PRD">
					<xsl:apply-templates select="." mode="medication-manufacturedProduct"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>					
				</product>

				<xsl:apply-templates select="parent::node()/OrderedBy" mode="author-Human"/>
			</supply>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="medication-supplyFill">
		<xsl:param name="narrativeLink"/>
		
		<entryRelationship typeCode="REFR">
			<supply classCode="SPLY" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-medicationSupply-EVN"/>
				
				<xsl:apply-templates select="parent::node()" mode="id-PrescriptionNumber"/>
				
				<xsl:apply-templates select="parent::node()" mode="medication-fills"/>
				
				<xsl:apply-templates select="." mode="medication-quantity"/>
				
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
				
				originalText is linked to text in the narrative.  For component
				medications, the narrative text will include the strength and
				strength volume values if provided by the SDA data.
			-->
			<xsl:variable name="sdaCodingStandardOID"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>			
			<xsl:variable name="description"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:variable>
			<xsl:choose>
				<xsl:when test="$sdaCodingStandardOID=$rxNormOID or $sdaCodingStandardOID=$ndcOID">
					<code code="{Code/text()}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}" displayName="{$description}">
						<originalText><reference value="{$narrativeLink}"/></originalText>
						<translation code="{Code/text()}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}" displayName="{$description}"/>
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

		<!-- Condition being treated -->
		<xsl:if test="string-length(Indication)">
			<entryRelationship typeCode="RSON">
				<observation classCode="OBS" moodCode="EVN">				
					<xsl:apply-templates select="." mode="templateIds-indication"/>
					
					<id nullFlavor="{$idNullFlavor}"/>
										
					<!-- Force in the SNOMED OID. -->
					<code code="{translate(Indication/text(),' ','_')}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}" displayName="{Indication/text()}"/>
					
					<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationIndication/text(), $narrativeLinkSuffix)}"/></text>
					<statusCode code="completed"/>
					<effectiveTime nullFlavor="UNK"/>
				</observation>
			</entryRelationship>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="observation-MedicationOrderStatus">
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
			HS.SDA3.Medication TextInstruction
			CDA Field: Free Text Sig
			CDA XPath: entry/substanceAdministration/text
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
		<xsl:param name="hasComponentMeds" select="'0'"/>
		
		<xsl:if test="$hitsp-CDA-Medication"><templateId root="{$hitsp-CDA-Medication}"/></xsl:if>
		<xsl:if test="$hl7-CCD-MedicationActivity"><templateId root="{$hl7-CCD-MedicationActivity}"/></xsl:if>
		<xsl:if test="$ihe-PCC-MedicationsEntry"><templateId root="{$ihe-PCC-MedicationsEntry}"/></xsl:if>
		<xsl:choose>
			<xsl:when test="not($hasComponentMeds) or $hasComponentMeds='0'">
				<xsl:if test="$ihe-PCC-SubstanceEntry"><templateId root="{$ihe-PCC-SubstanceEntry}"/></xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$ihe-PCC-CombinationMedicationEntry"><templateId root="{$ihe-PCC-CombinationMedicationEntry}"/></xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-manufacturedProduct-Medication">
		<xsl:if test="$hitsp-CDA-MedicationInformation"><templateId root="{$hitsp-CDA-MedicationInformation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-Product"><templateId root="{$hl7-CCD-Product}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ProductEntry"><templateId root="{$ihe-PCC-ProductEntry}"/></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-patientInstructions">
		<xsl:if test="$hl7-CCD-PatientInstruction"><templateId root="{$hl7-CCD-PatientInstruction}"/></xsl:if>
		<xsl:if test="$ihe-PCC-PatientMedicationInstructions"><templateId root="{$ihe-PCC-PatientMedicationInstructions}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-indication">
		<xsl:if test="$hl7-CCD-ProblemObservation"><templateId root="{$hl7-CCD-ProblemObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-medicationOrderStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-MedicationStatusObservation"><templateId root="{$hl7-CCD-MedicationStatusObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-medicationSupply-INT">
		<xsl:if test="$hl7-CCD-SupplyActivity"><templateId root="{$hl7-CCD-SupplyActivity}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SupplyEntry"><templateId root="{$ihe-PCC-SupplyEntry}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-medicationSupply-EVN">
		<xsl:if test="$hl7-CCD-SupplyActivity"><templateId root="{$hl7-CCD-SupplyActivity}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SupplyEntry"><templateId root="{$ihe-PCC-SupplyEntry}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
