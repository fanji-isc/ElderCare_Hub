<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Immunization Variables -->
	<!-- E = Executed, R = Replaced -->
	<xsl:variable name="immunizationExecutedStatusCodes">|E|R|</xsl:variable>
	<!-- H = On-Hold, INT = Intended (default, if no status value specified), IP = In-Progress -->
	<xsl:variable name="immunizationIntendedStatusCodes">|H|INT|IP|</xsl:variable>
	<!-- C = Cancelled, D = Discontinued -->
	<xsl:variable name="immunizationCancelledStatusCodes">|C|D|</xsl:variable>

	<xsl:template match="*" mode="immunizations-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Ordered Immunization Name</th>
						<th>Filled Immunization Name</th>
						<th>Date</th>
						<th>Status</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="immunizations-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="immunizations-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="DrugProduct" mode="originalTextOrDescriptionOrCode"/></td>
			<td>
				<xsl:choose>
					<xsl:when test="string-length(FromTime)"><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></xsl:when>
					<xsl:when test="string-length(EnteredOn)"><xsl:apply-templates select="EnteredOn" mode="narrativeDateFromODBC"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="'Unknown'"/></xsl:otherwise>
				</xsl:choose>
			</td>
			<td><xsl:apply-templates select="Status" mode="immunization-statusDescription"/></td>
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="immunizations-Entries">
		<xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]" mode="immunizations-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="immunizations-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<substanceAdministration classCode="SBADM" negationInd="false">
				<!-- The following template is defined in Export/Entry-Modules/Medication.xsl -->
				<xsl:apply-templates select="." mode="substanceAdministration-moodCode"/>
				
				<xsl:apply-templates select="." mode="templateIds-immunizationAdministration"/>
				
				<!-- External, Placer, and Filler IDs-->
				<!--
					HS.SDA3.Vaccination ExternalId
					CDA Section: Immunizations
					CDA Field: Id
					CDA XPath: entry/substanceAdministration/id
				-->
				<!--
					HS.SDA3.Vaccination PlacerId
					CDA Section: Immunizations
					CDA Field: Placer Id
					CDA XPath: entry/substanceAdministration/id
				-->
				<!--
					HS.SDA3.Vaccination FillerId
					CDA Section: Immunizations
					CDA Field: Filler Id
					CDA XPath: entry/substanceAdministration/id
				-->
				<xsl:apply-templates select="." mode="id-Medication"/>
				
				<code code="IMMUNIZ" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
				<text><reference value="{concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>

				<!-- 
					HS.SDA3.Vaccination FromTime
					HS.SDA3.Vaccination ToTime
					CDA Section: Immunizations
					CDA Field: Administered Date
					CDA XPath: entry/substanceAdministration/effectiveTime
					
					Export uses only the first found of FromTime or ToTime.
				-->
				<xsl:apply-templates select="." mode="effectiveTime-Immunization"/>
				<xsl:apply-templates select="OrderItem" mode="immunization-order"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<!--
					HS.SDA3.Vaccination OrderedBy
					CDA Section: Immunizations
					CDA Field: Clinician
					CDA XPath: entry/substanceAdministration/entryRelationship/supply/author
				-->				
				<xsl:apply-templates select="OrderedBy" mode="performer"/>
				
				<!--
					HS.SDA3.Vaccination EnteredBy
					CDA Section: Immunizations
					CDA Field: Author
					CDA XPath: entry/substanceAdministration/author
				-->				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				
				<!--
					HS.SDA3.Vaccination EnteredAt
					CDA Section: Immunizations
					CDA Field: Information Source
					CDA XPath: entry/substanceAdministration/author/assignedAuthor
				-->				
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				<xsl:apply-templates select="." mode="observation-immunizationStatus"/>
				<xsl:apply-templates select="." mode="immunization-seriesNumber"/>
				
				<!--
					HS.SDA3.Vaccination Comments
					CDA Section: Immunizations
					CDA Field: Comments
					CDA XPath: entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']
				-->				
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				<xsl:apply-templates select="DrugProduct" mode="immunization-supply"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<!-- 
					HS.SDA3.Vaccination EncounterNumber
					CDA Section: Immunizations
					CDA Field: Encounter
					CDA XPath: entry/procedure/entryRelationship/encounter
					This links the Vaccination to an encounter in the Encounters section.
				-->
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</substanceAdministration>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="immunizations-NoData">
		<text><xsl:value-of select="$exportConfiguration/immunizations/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="immunization-order">
		<xsl:param name="narrativeLink"/>
		
		<consumable typeCode="CSM">
			<manufacturedProduct classCode="MANU">
				<xsl:apply-templates select="." mode="templateIds-manufacturedProduct-Immunization"/>
				
				<!--
					HS.SDA3.Vaccination OrderItem
					CDA Section: Immunizations
					CDA Field: Medication Information
					CDA XPath: entry/substanceAdministration/consumable/manufacturedProduct
				-->				
				<xsl:apply-templates select="." mode="immunization-manufacturedMaterial"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
				<xsl:apply-templates select="." mode="immunization-manufacturerOrganization"/>
			</manufacturedProduct>
		</consumable>		
	</xsl:template>
	
	<xsl:template match="*" mode="immunization-supply">
		<xsl:param name="narrativeLink"/>

		<entryRelationship typeCode="REFR">
			<supply classCode="SPLY" moodCode="EVN">
				<xsl:apply-templates select="parent::node()" mode="id-PrescriptionNumber"/>
				
				<repeatNumber nullFlavor="UNK"/>				
				<xsl:apply-templates select="." mode="medication-quantity"/>
				
				<!--
					HS.SDA3.Vaccination DrugProduct
					CDA Section: Immunizations
					CDA Field: Immunization-Supply
					CDA XPath: entry/substanceAdministration/entryRelationship/supply
				-->				
				<product typeCode="PRD">
					<manufacturedProduct classCode="MANU">
						<xsl:apply-templates select="." mode="templateIds-manufacturedProduct-Immunization"/>
						
						<xsl:apply-templates select="." mode="immunization-manufacturedMaterial"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
						<xsl:apply-templates select="." mode="immunization-manufacturerOrganization"/>
					</manufacturedProduct>
				</product>
			</supply>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="immunization-manufacturedMaterial">
		<xsl:param name="narrativeLink"/>
		
		<manufacturedMaterial classCode="MMAT" determinerCode="KIND">
			<!-- 
				This field has slightly different requirements than other
				coded element fields.  Like many coded element fields, it
				has only one valid codeSystem - in this case, CVX.  However,
				it requires that if there is a <translation> on the code,
				then the codeSystem on it must be for RxNorm or NDC, or it
				must be nullFlavor.                                          
			-->
			<xsl:variable name="sdaCodingStandardOID"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
			<xsl:variable name="description"><xsl:apply-templates select="." mode="descriptionOrCode"/></xsl:variable>
			<!--
				2.16.840.1.113883.6.59 was retired by HL7. 2.16.840.1.113883.12.292
				is the correct OID for CVX. $sdaCodingStandard will get the old OID
				when the SDA streamlet SDACodingStandard actually has the old OID,
				or when the HS OID Registry still has the old OID entered for CVX.
			-->
			<xsl:choose>
				<xsl:when test="$sdaCodingStandardOID=$cvxOID or $sdaCodingStandardOID='2.16.840.1.113883.6.59'">
					<code code="{Code/text()}" codeSystem="{$cvxOID}" codeSystemName="{SDACodingStandard/text()}" displayName="{$description}">
						<originalText><reference value="{$narrativeLink}"/></originalText>
					</code>
				</xsl:when>
				<xsl:when test="$sdaCodingStandardOID=$rxNormOID or $sdaCodingStandardOID=$ndcOID">
					<code nullFlavor="UNK">
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
					<xsl:when test="string-length($description)"><xsl:value-of select="$description"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="'Unknown Immunization'"/></xsl:otherwise>
				</xsl:choose>
			</name>
			<xsl:apply-templates select="." mode="immunization-lotNumberText"/>
		</manufacturedMaterial>
	</xsl:template>
	
	<xsl:template match="*" mode="immunization-manufacturerOrganization">
		<!-- SDA does not have a medication manufacturer property. -->
		<manufacturerOrganization nullFlavor="UNK"/>
	</xsl:template>
	
	<xsl:template match="*" mode="immunization-lotNumberText">
		<!-- SDA does not have a medication lot number property. -->
		<lotNumberText/>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-immunizationStatus">
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-immunizationStatusObservation"/>
				
				<!-- 
					HS.SDA3.Vaccination Status
					CDA Section: Immunizations
					CDA Field: Status
					CDA XPath: entry/substanceAdministration/entryRelationship/observation[code/@code='33999-4']
				-->				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!-- Status Detail:  Hard-coded to "active" for an immunization -->
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<SDACodingStandard><xsl:value-of select="$snomedName"/></SDACodingStandard>
						<Code>55561003</Code>
						<Description>Active</Description>
					</Status>
				</xsl:variable>
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<xsl:apply-templates select="$status" mode="value-CE"/>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="immunization-statusDescription">
		<xsl:choose>
			<xsl:when test="text() = 'INT'"><xsl:text>Verified</xsl:text></xsl:when>
			<xsl:when test="text() = 'H'"><xsl:text>On Hold</xsl:text></xsl:when>
			<xsl:when test="text() = 'D'"><xsl:text>Discontinued</xsl:text></xsl:when>
			<xsl:when test="text() = 'IP'"><xsl:text>In Progress</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Completed</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="immunization-seriesNumber">
		<entryRelationship typeCode="SUBJ">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-immunizationSeriesNumberObservation"/>
				
				<!--
					HS.SDA3.Vaccination Vaccination
					CDA Section: Immunizations
					CDA Field: Medication Series Number
					CDA XPath: entry/substanceAdministration/entryRelationship/observation[code/@code='30973-2']
				-->					
				<code code="30973-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Dose number"/>
				<statusCode code="completed"/>
				<xsl:choose>
					<xsl:when test="Administrations"><value xsi:type="INT" value="{count(Administrations/Administration)}"/></xsl:when>
					<xsl:otherwise><value nullFlavor="UNK" xsi:type="INT"/></xsl:otherwise>
				</xsl:choose>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-Immunization">
		<xsl:choose>
			<xsl:when test="string-length(FromTime)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:when test="string-length(EnteredOn)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-immunizationAdministration">
		<xsl:if test="$hitsp-CDA-Immunization"><templateId root="{$hitsp-CDA-Immunization}"/></xsl:if>
		<xsl:if test="$hl7-CCD-MedicationActivity"><templateId root="{$hl7-CCD-MedicationActivity}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ImmunizationsEntry"><templateId root="{$ihe-PCC-ImmunizationsEntry}"/></xsl:if>
		<xsl:if test="$ihe-PCC-MedicationsEntry"><templateId root="{$ihe-PCC-MedicationsEntry}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SubstanceEntry"><templateId root="{$ihe-PCC-SubstanceEntry}"/></xsl:if>		
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-manufacturedProduct-Immunization">
		<xsl:if test="$hitsp-CDA-MedicationInformation"><templateId root="{$hitsp-CDA-MedicationInformation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-Product"><templateId root="{$hl7-CCD-Product}"/></xsl:if>
		<xsl:if test="$ihe-PCC-ProductEntry"><templateId root="{$ihe-PCC-ProductEntry}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-immunizationStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-MedicationStatusObservation"><templateId root="{$hl7-CCD-MedicationStatusObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-immunizationSeriesNumberObservation">
		<xsl:if test="$hl7-CCD-MedicationSeriesNumberObservation"><templateId root="{$hl7-CCD-MedicationSeriesNumberObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
