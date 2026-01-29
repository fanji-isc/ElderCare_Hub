<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- E = Executed, R = Replaced -->
	<xsl:variable name="medicationExecutedStatusCodes">|E|R|</xsl:variable>
	<!-- H = On-Hold, INT = Intended (default, if no status value specified), IP = In-Progress -->
	<xsl:variable name="medicationIntendedStatusCodes">|H|INT|IP|</xsl:variable>
	<!-- I = Inactive, CA = Cancelled, C = Cancelled, D = Discontinued -->
	<xsl:variable name="medicationInactiveOrCancelledStatusCodes">|I|CA|C|D|</xsl:variable>
	
	<xsl:template match="*" mode="medications-Narrative-dischargeCurrent">
		<xsl:param name="narrativeLinkCategory"/>
			
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Ordered Medication Name</th>
						<th>Filled Medication Name</th>
						<th>Start Date</th>
						<th>Stop Date</th>
						<th>Indication</th>
						<th>Dosage</th>
						<th>Directions</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Medications/Medication[not(contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|'))) and ((not(string-length(ToTime/text())) or (string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and not(isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) > 0))))]" mode="medications-NarrativeDetail-dischargeCurrent">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="medications-NarrativeDetail-dischargeCurrent">
		<xsl:param name="narrativeLinkCategory"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="DrugProduct" mode="originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationIndication/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Indication/text()"/></td>
			<td><xsl:value-of select="concat(DoseQuantity/text(), DoseUoM/Code/text())"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationSignature/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="medication-textInstruction"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="medications-Narrative-dischargeCeased">
		<xsl:param name="narrativeLinkCategory"/>
			
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Ordered Medication Name</th>
						<th>Filled Medication Name</th>
						<th>Start Date</th>
						<th>Stop Date</th>
						<th>Indication</th>
						<th>Change Made</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Medications/Medication[contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|')) or (string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) > 0)]" mode="medications-NarrativeDetail-dischargeCeased">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="medications-NarrativeDetail-dischargeCeased">
		<xsl:param name="narrativeLinkCategory"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="DrugProduct" mode="originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationIndication/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Indication/text()"/></td>
			<td>Ceased</td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="medications-Narrative-sharedHealthSummary">
		<xsl:param name="narrativeLinkCategory"/>
			
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Ordered Medication Name</th>
						<th>Filled Medication Name</th>
						<th>Start Date</th>
						<th>Stop Date</th>
						<th>Indication</th>
						<th>Directions</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Medications/Medication[not(contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="medications-NarrativeDetail-sharedHealthSummary">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="medications-NarrativeDetail-sharedHealthSummary">
		<xsl:param name="narrativeLinkCategory"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="DrugProduct" mode="originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationIndication/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Indication/text()"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationSignature/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="medication-textInstruction"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="medications-Narrative-eventSummary">
		<xsl:param name="narrativeLinkCategory"/>
			
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Ordered Medication Name</th>
						<th>Filled Medication Name</th>
						<th>Start Date</th>
						<th>Stop Date</th>
						<th>Indication</th>
						<th>Dosage</th>
						<th>Directions</th>
						<th>Change Type</th>
						<th>Change or Recommendation?</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Medications/Medication" mode="medications-NarrativeDetail-eventSummary">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="medications-NarrativeDetail-eventSummary">
		<xsl:param name="narrativeLinkCategory"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="DrugProduct" mode="originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationIndication/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Indication/text()"/></td>
			<td><xsl:value-of select="concat(DoseQuantity/text(), DoseUoM/Code/text())"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationSignature/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="medication-textInstruction"/></td>
			<xsl:variable name="changeCode"><xsl:apply-templates select="." mode="medication-ChangeType-code"/></xsl:variable>
			<xsl:variable name="changeDescription"><xsl:apply-templates select="." mode="medication-ChangeType-description"><xsl:with-param name="code" select="$changeCode"/></xsl:apply-templates></xsl:variable>
			<td><xsl:value-of select="$changeDescription"/></td>
			<td>Change</td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="medications-Narrative-referral">
		<xsl:param name="narrativeLinkCategory"/>
			
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Ordered Medication Name</th>
						<th>Filled Medication Name</th>
						<th>Directions</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Medications/Medication" mode="medications-NarrativeDetail-referral">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="medications-NarrativeDetail-referral">
		<xsl:param name="narrativeLinkCategory"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="DrugProduct" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationSignature/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="medication-textInstruction"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="medications-Entries">
		<xsl:param name="narrativeLinkCategory"/>

		<xsl:choose>
			<xsl:when test="$narrativeLinkCategory = 'dischargeCurrentMedications'">
				<xsl:apply-templates select="Medications/Medication[not(contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|'))) and ((not(string-length(ToTime/text())) or (string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and not(isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) > 0))))]" mode="medications-EntryDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$narrativeLinkCategory = 'dischargeCeasedMedications'">
				<xsl:apply-templates select="Medications/Medication[contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|')) or (string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) > 0)]" mode="medications-EntryDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="Medications/Medication[not(contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="medications-EntryDetail"><xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template match="*" mode="medications-EntryDetail">
		<xsl:param name="narrativeLinkCategory"/>

		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<xsl:apply-templates select="." mode="substanceAdministration">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
		</entry>

	</xsl:template>

	<xsl:template match="*" mode="medications-NoData">
		<xsl:param name="narrativeLinkCategory"/>
		
		<!-- Event Summary has no specification for Medications Exclusion Statement -->
		
		<xsl:variable name="codeCode">
			<xsl:choose>
				<xsl:when test="$narrativeLinkCategory='dischargeCurrentMedications'">103.16302.4.3.2</xsl:when>
				<xsl:when test="$narrativeLinkCategory='dischargeCeasedMedications'">103.16302.4.3.3</xsl:when>
				<xsl:when test="$documentExportType='NEHTASharedHealthSummary'">103.16302.120.1.2</xsl:when>
				<xsl:when test="$documentExportType='NEHTAeReferral'">103.16302.2.2.1</xsl:when>
				<xsl:when test="$documentExportType='NEHTASpecialistLetter'">103.16302.132.1.1</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="nehta-globalStatement">
			<xsl:with-param name="narrativeLink" select="$exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationNarrative/text()"/>
			<xsl:with-param name="codeCode" select="$codeCode"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="*" mode="substanceAdministration">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>

		<substanceAdministration classCode="SBADM">
			<xsl:apply-templates select="." mode="substanceAdministration-moodCode"/>
						
			<!-- NEHTA allows for only one <id> here. -->
			<xsl:apply-templates select="." mode="id-Medication"/>
			
			<text xsi:type="ST"><xsl:apply-templates select="." mode="medication-textInstruction"/></text>
			<xsl:choose>
				<xsl:when test="$narrativeLinkCategory='dischargeCurrentMedications'"><statusCode code="active"/></xsl:when>
				<xsl:when test="$narrativeLinkCategory='dischargeCeasedMedications'"><statusCode code="cancelled"/></xsl:when>
				<xsl:otherwise><statusCode code="completed"/></xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="." mode="medication-duration"/>
			<xsl:apply-templates select="Route" mode="code-route"/>
			<xsl:apply-templates select="." mode="medication-doseQuantity"/>
			<xsl:apply-templates select="." mode="medication-rateAmount"/>
			<xsl:apply-templates select="OrderItem" mode="medication-consumable"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			<xsl:apply-templates select="EnteredBy" mode="author-Human"/> 
			<xsl:apply-templates select="EnteredAt" mode="informant"/>
			<xsl:apply-templates select="Comments" mode="comment-medication"/>
			<xsl:apply-templates select="Status" mode="observation-MedicationOrderStatus"/>
			<xsl:apply-templates select="." mode="medication-indication">
				<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
			</xsl:apply-templates>
			
			<!-- Discharge Current Medications does not require Change Detail -->
			
			<!-- Shared Health Summary and e-Referral have no spec for Change Type -->
			
			<!-- Only Discharge Ceased Medications requires Change Detail -->
			<xsl:if test="$narrativeLinkCategory='dischargeCeasedMedications'">
				<xsl:apply-templates select="." mode="medication-changeDetail"/>
			</xsl:if>
			
			<!-- Only Event Summary requires Change Type -->
			<xsl:if test="$documentExportType='NEHTAEventSummary'">
				<xsl:apply-templates select="." mode="medication-changeType"/>
			</xsl:if>
			
			<xsl:apply-templates select="DrugProduct" mode="medication-supplyFill"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationFilledName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
						
			<!-- Link this medication to encounter noted in encounters section -->
			<xsl:if test="not($narrativeLinkCategory='dischargeCurrentMedications') and not($narrativeLinkCategory='dischargeCeasedMedications')">
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</xsl:if>
			
		</substanceAdministration>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-duration">
		<xsl:apply-templates select="." mode="effectiveTime-IVL_TS"/>
	</xsl:template>

	<xsl:template match="*" mode="medication-frequency">
		<xsl:apply-templates select="." mode="effectiveTime-PIVL_TS"/>
	</xsl:template>

	<xsl:template match="*" mode="medication-doseQuantity">
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
		<xsl:variable name="quantityDispensedString">
			<xsl:choose>
				<xsl:when test="string-length(BaseQty/text())">
					<xsl:choose>
						<xsl:when test="string-length(BaseUnits/Description)">
							<xsl:value-of select="concat(BaseQty/text(),' ',BaseUnits/Description/text())"/>
						</xsl:when>
						<xsl:when test="string-length(BaseUnits/Code)">
							<xsl:value-of select="concat(BaseQty/text(),' ',BaseUnits/Code/text())"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="BaseQty/text()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>unknown</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<text xsi:type="ST"><xsl:value-of select="$quantityDispensedString"/></text>
		
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
	
	<xsl:template match="*" mode="medication-supplyFill">
		<xsl:param name="narrativeLink"/>
		
		<entryRelationship typeCode="REFR">
			<supply classCode="SPLY" moodCode="EVN">
				<xsl:apply-templates select="parent::node()" mode="id-PrescriptionNumber"/>
				
				<xsl:apply-templates select="." mode="medication-quantity"/>
			</supply>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="medication-manufacturedProduct">
		<xsl:param name="narrativeLink"/>
		
		<manufacturedProduct classCode="MANU">
			<xsl:apply-templates select="." mode="medication-manufacturedMaterial"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
		</manufacturedProduct>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-manufacturedMaterial">
		<xsl:param name="narrativeLink"/>
		
		<manufacturedMaterial classCode="MMAT" determinerCode="KIND">
			<xsl:variable name="sdaCodingStandardOID"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
			<xsl:variable name="description"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:variable>
			<xsl:choose>
				<xsl:when test="string-length(SDACodingStandard/text())">
					<code code="{Code/text()}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}" displayName="{$description}">
						<originalText><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></originalText>
					</code>
				</xsl:when>
				<xsl:otherwise>
					<code code="{Code/text()}" codeSystem="{$noCodeSystemOID}" codeSystemName="{$noCodeSystemName}" displayName="{$description}">
						<originalText><xsl:apply-templates select="." mode="originalTextOrDescriptionOrCode"/></originalText>
					</code>
				</xsl:otherwise>
			</xsl:choose>
		</manufacturedMaterial>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-patientInstructions">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="true">
			<act classCode="ACT" moodCode="INT">				
				<code code="PINSTRUCT" codeSystem="1.3.6.1.4.1.19376.1.5.3.2" codeSystemName="IHEActCode"/>
				<text><reference value="{concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/medicationInstructions/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
			</act>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-indication">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="narrativeLinkSuffix"/>

		<xsl:variable name="indicationActMood">
			<xsl:choose>
				<xsl:when test="$narrativeLinkCategory='dischargeCurrentMedications'">RQO</xsl:when>
				<xsl:when test="$narrativeLinkCategory='dischargeCeasedMedications'">RQO</xsl:when>
				<xsl:otherwise>EVN</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="indicationDisplayName">
			<xsl:choose>
				<xsl:when test="$narrativeLinkCategory='dischargeCurrentMedications'">Reason for Therapeutic Good</xsl:when>
				<xsl:when test="$narrativeLinkCategory='dischargeCeasedMedications'">Reason for Therapeutic Good</xsl:when>
				<xsl:otherwise>Clinical Indication</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Condition being treated -->
		<xsl:if test="string-length(Indication)">
			<entryRelationship typeCode="RSON">
				<act classCode="INFRM" moodCode="{$indicationActMood}">
					<id nullFlavor="{$idNullFlavor}"/>
		
					<code code="103.10141" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="{$indicationDisplayName}"/>
					
					<text xsi:type="ST"><xsl:value-of select="Indication/text()"/></text>
					<statusCode code="completed"/>
					<effectiveTime nullFlavor="UNK"/>
				</act>
			</entryRelationship>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="observation-MedicationOrderStatus">
		<entryRelationship typeCode="SUBJ" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				
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
				
				<xsl:apply-templates select="$status" mode="generic-Coded"/>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="substanceAdministration-moodCode">
		<!-- According to AU Specifications, moodCode for a substanceAdministration must be EVN (Event) -->
		<xsl:attribute name="moodCode">EVN</xsl:attribute>
	</xsl:template>

	<xsl:template match="*" mode="medication-changeDetail">
		<!-- Discharge Summary seems to be okay with this. -->
		<entryRelationship typeCode="SPRT">
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code><originalText>Ceased</originalText></code>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-changeType">
		<!--
			If Cancelled or Discontinued during Encounter, then 03 Cancelled
			ElseIf EndTime at or before end of Encounter, then 05 Ceased
			ElseIf StartTime before start of Encounter and EndTime after end of Encounter, then 01 Unchanged
			ElseIf StartTime at or after start of Encounter, and Intended, then 04 Prescribed
			ElseIf StartTime at or after start of Encounter, then 01 Unchanged
		-->
		<xsl:variable name="changeTypeCode"><xsl:apply-templates select="." mode="medication-ChangeType-code"/></xsl:variable>
		
		<xsl:variable name="changeTypeDisplayName">
			<xsl:apply-templates select="." mode="medication-ChangeType-description">
				<xsl:with-param name="code" select="$changeTypeCode"/>
			</xsl:apply-templates>
		</xsl:variable>

		<entryRelationship typeCode="SPRT" inversionInd="true">
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="103.16593" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Change Type"/>
				<!-- Change Type is not stored in SDA, therefore export Change Type Description in <text>. -->
				<text><xsl:value-of select="$changeTypeDisplayName"/></text>
				<!--
					Change Type Codes:
					01 = Unchanged
					02 = Changed
					03 = Cancelled
					04 = Prescribed
					05 = Ceased
					06 = Suspended
				-->
				<value xsi:type="CD" code="{$changeTypeCode}" codeSystem="1.2.36.1.2001.1001.101.104.16592" codeSystemName="NCTIS Change Type Values" displayName="{$changeTypeDisplayName}"/>
				<entryRelationship typeCode="COMP">
					<observation classCode="OBS" moodCode="EVN">
						<id root="{isc:evaluate('createUUID')}"/>
						<code code="103.16595" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Recommendation or Change"/>
						<!--
							Recommendation or Change Codes:
							01 = A recommendation to make the change.
							02 = The change has been made.
							
							Hard-code to 02 for now.
						-->
						<value xsi:type="CD" code="02" codeSystem="1.2.36.1.2001.1001.101.104.16594" codeSystemName="NCTIS Recommendation or Change Values" displayName="The change has been made."/>
					</observation>
				</entryRelationship>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-ChangeType-code">
		<xsl:choose>
			<xsl:when test="contains($medicationInactiveOrCancelledStatusCodes, concat('|', Status/text(), '|')) and (string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and not(isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) &lt; 0)) and (string-length(ToTime/text()) and not(isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/FromTime/text(), 'TZ', ' ')) > 0))">03</xsl:when>
			<xsl:when test="string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and not(isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) &lt; 0)">05</xsl:when>
			<xsl:when test="(string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/FromTime/text(), 'TZ', ' ')) > 0) and (string-length(/Container/Encounters/Encounter/ToTime/text()) and string-length(ToTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/ToTime/text(), 'TZ', ' ')) > 0)">01</xsl:when>
			<xsl:when test="contains($medicationIntendedStatusCodes, concat('|', Status/text(), '|')) and (string-length(FromTime/text()) and not(isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' '), translate(/Container/Encounters/Encounter/FromTime/text(), 'TZ', ' ')) > 0))">04</xsl:when>
			<xsl:otherwise>01</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-ChangeType-description">
		<xsl:param name="code"/>
		
		<xsl:choose>
			<xsl:when test="$code='01'">Unchanged</xsl:when>
			<xsl:when test="$code='02'">Changed</xsl:when>
			<xsl:when test="$code='03'">Cancelled</xsl:when>
			<xsl:when test="$code='04'">Prescribed</xsl:when>
			<xsl:when test="$code='05'">Ceased</xsl:when>
			<xsl:when test="$code='06'">Suspended</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="medication-textInstruction">
		<xsl:choose>
			<xsl:when test="string-length(DosageStep[1]/TextInstruction/text())">
				<xsl:value-of select="DosageStep[1]/TextInstruction/text()"/>
			</xsl:when>
			<xsl:when test="string-length(TextInstruction/text())">
				<xsl:value-of select="TextInstruction/text()"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
