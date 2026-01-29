<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Immunization Variables -->
	<!-- E = Executed, R = Replaced -->
	<xsl:variable name="immunizationExecutedStatusCodes">|E|R|</xsl:variable>
	<!-- H = On-Hold, INT = Intended (default, if no status value specified), IP = In-Progress -->
	<xsl:variable name="immunizationIntendedStatusCodes">|H|INT|IP|</xsl:variable>
	<!-- C = Cancelled, D = Discontinued -->
	<xsl:variable name="immunizationCancelledStatusCodes">|C|D|</xsl:variable>
  <!-- If you wish to block exporting vaccination(s) with zero administrations (default), export profile code should be 0.
	   If you wish to include exporting vaccination(s) with zero administrations, export profile code should be 1.-->
  <xsl:variable name="checkAdministrations" select="$exportConfiguration/immunizations/checkAdministrations/text()"/>

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
				  <xsl:choose>
				    <xsl:when test="$checkAdministrations='1'">
			            <xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|'))) and not(Administrations/Administration)] | Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]/Administrations/Administration" mode="immunizations-NarrativeDetail-Combined"/>					</xsl:when>
					<xsl:otherwise>
					    <xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]/Administrations/Administration" mode="immunizations-NarrativeDetail"/>
					</xsl:otherwise>
				  </xsl:choose>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="immunizations-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="../../OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="../../DrugProduct" mode="originalTextOrDescriptionOrCode"/></td>
			<td>
				<xsl:choose>
					<xsl:when test="string-length(Administrations/Administration/FromTime)"><xsl:apply-templates select="Administrations/Administration/FromTime" mode="narrativeDateFromODBC"/></xsl:when>
					<xsl:when test="string-length(FromTime)"><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="'Unknown'"/></xsl:otherwise>
				</xsl:choose>
			</td>
			<td><xsl:apply-templates select="../../Status" mode="immunization-statusDescription"/></td>
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="../../Comments/text()"/></td>
		</tr>
	</xsl:template>
	
    <!-- This template exports a combines list of Vaccinations with no administrations plus Vaccinations with administrations-->
    <xsl:template match="*" mode="immunizations-NarrativeDetail-Combined">
	  <xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)}">
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../OrderItem" mode="originalTextOrDescriptionOrCode"/>
				  </xsl:otherwise>
				</xsl:choose>
			</td>
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)}">
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="DrugProduct" mode="originalTextOrDescriptionOrCode"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../DrugProduct" mode="originalTextOrDescriptionOrCode"/>
				  </xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="string-length(FromTime)"><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></xsl:when>
					<xsl:when test="string-length(EnteredOn)"><xsl:apply-templates select="EnteredOn" mode="narrativeDateFromODBC"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="'Unknown'"/></xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="Status" mode="immunization-statusDescription"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../Status" mode="immunization-statusDescription"/>
				  </xsl:otherwise>
				</xsl:choose>
			</td>
			<td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)}">
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:value-of select="Comments/text()"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:value-of select="../../Comments/text()"/>
				  </xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="immunizations-Entries">
	  <xsl:choose>
		<xsl:when test="$checkAdministrations='1'">
		  <xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|'))) and not(Administrations/Administration)] | Vaccinations/Vaccination/Administrations/Administration" mode="immunizations-EntryDetail-Combined"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|')))]/Administrations/Administration" mode="immunizations-EntryDetail"/>
		</xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="immunizations-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<substanceAdministration classCode="SBADM" negationInd="false">
				<!-- The following template is defined in Export/Entry-Modules/Medication.xsl -->
				<xsl:apply-templates select="../../." mode="substanceAdministration-moodCode"/>
				
				<xsl:apply-templates select="../../." mode="templateIds-immunizationAdministration"/>
				
				<!-- External, Placer, and Filler IDs-->
				<!--
					Field : Immunization Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[1]
					Source: HS.SDA3.Vaccination ExternalId
					Source: /Container/Vaccinations/Vaccination/ExternalId
					StructuredMappingRef: id-External
				-->
				<!--
					Field : Immunization Placer Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[2]
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: /Container/Vaccinations/Vaccination/PlacerId
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
					Field : Immunization Filler Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[3]
					Source: HS.SDA3.AbstractOrder FillerId
					Source: /Container/Vaccinations/Vaccination/FillerId
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
				<xsl:apply-templates select="../../." mode="id-Medication"/>
				
				<code code="IMMUNIZ" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
				<text><reference value="{concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				<xsl:apply-templates select="." mode="effectiveTime-Immunization"/>
				
				<!--
					Field : Immunization Route
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/routeCode
					Source: HS.SDA3.AbstractMedication Route
					Source: /Container/Immunizations/Immunization/Route
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="../../Route" mode="code-route"/>
				
				<xsl:apply-templates select="../../." mode="immunization-doseQuantity"/>
				
				<xsl:apply-templates select="../../OrderItem" mode="immunization-order"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<!--
					Field : Immunization Ordering Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/performer
					Source: HS.SDA3.AbstractOrder OrderedBy
					Source: /Container/Vaccinations/Vaccination/OrderedBy
					StructuredMappingRef: performer
				-->
				<xsl:apply-templates select="../../OrderedBy" mode="performer"/>
				
				<!--
					Field : Immunization Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author
					Source: HS.SDA3.AbstractOrder EnteredBy
					Source: /Container/Vaccinations/Vaccination/EnteredBy
					StructuredMappingRef: assignedAuthor-Human
				-->				
				<!--
					Field : Immunization Author Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/author/time
					Source: HS.SDA3.Administration EnteredOn
					Source: /Container/Vaccinations/Vaccination/Administrations/Administration/EnteredOn
				-->				
				<author typeCode="AUT">
					<xsl:choose>
						<xsl:when test="string-length(EnteredOn)">
							<time><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></time>
						</xsl:when>
						<xsl:otherwise>
							<time nullFlavor="UNK"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="../../EnteredBy" mode="assignedAuthor-Human"/>
				</author>

				<!--
					Field : Immunization Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/informant
					Source: HS.SDA3.AbstractOrder EnteredAt
					Source: /Container/Vaccinations/Vaccination/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="../../EnteredAt" mode="informant"/>
				
				<xsl:apply-templates select="." mode="observation-immunizationStatus"/>
				
				<!--
					Field : Immunization Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.AbstractOrder Comments
					Source: /Container/Vaccinations/Vaccination/Comments
				-->
				<xsl:apply-templates select="../../Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<xsl:apply-templates select="../../DrugProduct" mode="immunization-supply"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<!--
					Field : Immunization Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship
					Source: HS.SDA3.AbstractOrder EncounterNumber
					Source: /Container/Vaccinations/Vaccination/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : This links the Immunization to an encounter in the Encounters section.
				-->
				<xsl:apply-templates select="../../." mode="encounterLink-entryRelationship"/>
			</substanceAdministration>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="immunizations-EntryDetail-Combined">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<substanceAdministration classCode="SBADM" negationInd="false">
				<!-- The following template is defined in Export/Entry-Modules/Medication.xsl -->
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="." mode="substanceAdministration-moodCode"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../." mode="substanceAdministration-moodCode"/>
				  </xsl:otherwise>
				</xsl:choose>
				
				<xsl:apply-templates select="." mode="templateIds-immunizationAdministration"/>
				
				<!-- External, Placer, and Filler IDs-->
				<!--
					Field : Immunization Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[1]
					Source: HS.SDA3.Vaccination ExternalId
					Source: /Container/Vaccinations/Vaccination/ExternalId
					StructuredMappingRef: id-External
				-->
				<!--
					Field : Immunization Placer Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[2]
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: /Container/Vaccinations/Vaccination/PlacerId
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
					Field : Immunization Filler Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[3]
					Source: HS.SDA3.AbstractOrder FillerId
					Source: /Container/Vaccinations/Vaccination/FillerId
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
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="." mode="id-Medication"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../." mode="id-Medication"/>
				  </xsl:otherwise>
				</xsl:choose>
				
				<code code="IMMUNIZ" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
				<text><reference value="{concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>

				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="." mode="effectiveTime-Immunization-NoAdmin"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="." mode="effectiveTime-Immunization"/>
				  </xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Immunization Route
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/routeCode
					Source: HS.SDA3.AbstractMedication Route
					Source: /Container/Immunizations/Immunization/Route
					StructuredMappingRef: generic-Coded
				-->
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="Route" mode="code-route"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../Route" mode="code-route"/>
				  </xsl:otherwise>
				</xsl:choose>
				
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="." mode="immunization-doseQuantity"/>
				 </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../." mode="immunization-doseQuantity"/>
				  </xsl:otherwise>
				</xsl:choose>
				
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="OrderItem" mode="immunization-order"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../OrderItem" mode="immunization-order"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				  </xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Immunization Ordering Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/performer
					Source: HS.SDA3.AbstractOrder OrderedBy
					Source: /Container/Vaccinations/Vaccination/OrderedBy
					StructuredMappingRef: performer
				-->
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="OrderedBy" mode="performer"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../OrderedBy" mode="performer"/>
				  </xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Immunization Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author
					Source: HS.SDA3.AbstractOrder EnteredBy
					Source: /Container/Vaccinations/Vaccination/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				  </xsl:when>
				  <xsl:otherwise>
					<author typeCode="AUT">
						<xsl:choose>
							<xsl:when test="string-length(EnteredOn)">
								<time><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></time>
							</xsl:when>
							<xsl:otherwise>
								<time nullFlavor="UNK"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="../../EnteredBy" mode="assignedAuthor-Human"/>
					</author>
				  </xsl:otherwise>
				</xsl:choose>

				<!--
					Field : Immunization Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/informant
					Source: HS.SDA3.AbstractOrder EnteredAt
					Source: /Container/Vaccinations/Vaccination/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="EnteredAt" mode="informant"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../EnteredAt" mode="informant"/>
				  </xsl:otherwise>
				</xsl:choose>
				
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="." mode="observation-immunizationStatus"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../." mode="observation-immunizationStatus"/>
				  </xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Immunization Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.AbstractOrder Comments
					Source: /Container/Vaccinations/Vaccination/Comments
				-->
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				  </xsl:otherwise>
				</xsl:choose>
				
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="DrugProduct" mode="immunization-supply"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../DrugProduct" mode="immunization-supply"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				  </xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Immunization Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship
					Source: HS.SDA3.AbstractOrder EncounterNumber
					Source: /Container/Vaccinations/Vaccination/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : This links the Immunization to an encounter in the Encounters section.
				-->
				<xsl:choose>
				  <xsl:when test="local-name()='Vaccination'">
					<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:apply-templates select="../../." mode="encounterLink-entryRelationship"/>
				  </xsl:otherwise>
				</xsl:choose>
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
					Field : Immunization Ordered Product
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/Vaccinations/Vaccination/OrderItem
					StructuredMappingRef: immunization-manufacturedMaterial
				-->
				<xsl:apply-templates select="." mode="immunization-manufacturedMaterial"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
			</manufacturedProduct>
		</consumable>		
	</xsl:template>
	
	<xsl:template match="*" mode="immunization-supply">
		<xsl:param name="narrativeLink"/>

		<entryRelationship typeCode="REFR">
			<supply classCode="SPLY" moodCode="EVN">
				<!--
					Field : Immunization Prescription Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
					Source: HS.SDA3.AbstractMedication PrescriptionNumber
					Source: /Container/Vaccinations/Vaccination/PrescriptionNumber
					StructuredMappingRef: id-PrescriptionNumber
				-->
				<xsl:apply-templates select="parent::node()" mode="id-PrescriptionNumber"/>
				
				<repeatNumber nullFlavor="UNK"/>
							
				<!--
					Field : Immunization Quantity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity
					Source: HS.SDA3.AbstractMedication DrugProduct
					Source: /Container/Vaccinations/Vaccination/DrugProduct
					StructuredMappingRef: medication-quantity
				-->
				<xsl:apply-templates select="." mode="medication-quantity"/>
				
				<!--
					Field : Immunization Supply
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/Vaccinations/Vaccination/OrderItem
					StructuredMappingRef: immunization-manufacturedMaterial
				-->
				<product typeCode="PRD">
					<manufacturedProduct classCode="MANU">
						<xsl:apply-templates select="." mode="templateIds-manufacturedProduct-Immunization"/>
						
						<xsl:apply-templates select="." mode="immunization-manufacturedMaterial"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
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
			<!--
				StructuredMapping: immunization-manufacturedMaterial
				
				Field
				Path: code/@code
				Source: Code
				Source: Code/text()
				Note  : The code element is exported with attributes only when the SDA OrderItem SDACodingStandard indicates CVX.
				
				Field
				Path: code/@displayName
				Source: Description
				Source: Description/text()
				Note  : The code element is exported with attributes only when the SDA OrderItem SDACodingStandard indicates CVX.
				
				Field
				Path: code/translation/@code
				Source: Code
				Source: Code/text()
				Note  : The code translation element is exported only when the SDA OrderItem SDACodingStandard indicates RXNORM.
				
				Field
				Path: code/translation/@displayName
				Source: Description
				Source: Description/text()
				Note  : The code translation element is exported only when the SDA OrderItem SDACodingStandard indicates RXNORM.
				
				Field
				Path: name/text()
				Source: Description
				Source: Description/text()
			-->
			<xsl:choose>
				<xsl:when test="$sdaCodingStandardOID=$cvxOID or $sdaCodingStandardOID='2.16.840.1.113883.6.59'">
					<code code="{Code/text()}" codeSystem="{$cvxOID}" codeSystemName="{$cvxName}" displayName="{$description}">
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
		</manufacturedMaterial>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-immunizationStatus">
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-immunizationStatusObservation"/>
				
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
			<xsl:when test="text() = 'C'"><xsl:text>Cancelled</xsl:text></xsl:when>			
			<xsl:otherwise><xsl:text>Completed</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="effectiveTime-Immunization">
		<!--
			Field : Immunization Administered From Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/low/@value
			Source: HS.SDA3.Administration FromTime
			Source: /Container/Vaccinations/Vaccination/Administrations/Administration/FromTime
			Note: When ToTime is present, FromTime maps to low value of a range.  When ToTime is not present, FromTime simply maps to effectiveDate/@value.
		-->
		<!--
			Field : Immunization Administered To Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/high/@value
			Source: HS.SDA3.Administration ToTime
			Source: /Container/Vaccinations/Vaccination/Administrations/Administration/ToTime
		-->
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(ToTime/text())">
					<xsl:apply-templates select="." mode="effectiveTime-low"/>
					<xsl:apply-templates select="." mode="effectiveTime-high"/>
				</xsl:when>
				<xsl:when test="string-length(FromTime/text())">
					<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
				</xsl:otherwise>		
			</xsl:choose>
		</effectiveTime>
	</xsl:template>

	<xsl:template match="*" mode="effectiveTime-Immunization-NoAdmin">
		<!--
			Field : Immunization Administered Date/Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/@value
			Source: HS.SDA3.AbstractOrder FromTime
			Source: /Container/Vaccinations/Vaccination/FromTime
			Source: /Container/Vaccinations/Vaccination/EnteredOn
			Note  : CDA effectiveTime for Immunization uses only a single time
					value, SDA FromTime or EnteredOn, whichever is found first.
		-->
		<xsl:choose>
			<xsl:when test="string-length(FromTime)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:when test="string-length(EnteredOn)"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
			<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="immunization-doseQuantity">
		<!--
			Field : Immunization Dose Quantity
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/doseQuantity/@value
			Source: HS.SDA3.AbstractMedication DoseQuantity
			Source: /Container/Immunizations/Immunization/DoseQuantity
		-->
		<!--
			Field : Immunization Dose Quantity Unit
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/doseQuantity/@unit
			Source: HS.SDA3.AbstractMedication DoseUoM
			Source: /Container/Immunizations/Immunization/DoseUoM
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

	<xsl:template match="*" mode="templateIds-immunizationAdministration">
		<templateId root="{$ccda-ImmunizationActivity}"/>		
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-manufacturedProduct-Immunization">
		<templateId root="{$ccda-ImmunizationMedicationInformation}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-immunizationStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-MedicationStatusObservation"><templateId root="{$hl7-CCD-MedicationStatusObservation}"/></xsl:if>
	</xsl:template>

</xsl:stylesheet>
