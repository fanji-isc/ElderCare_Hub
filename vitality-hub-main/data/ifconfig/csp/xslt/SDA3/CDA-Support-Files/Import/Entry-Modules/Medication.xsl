<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Medication">
		<!--
			medicationType:
			MED    = Medication from CDA Medications, Medications Administered, or Hospital Discharge Medications
			VXU    = Vaccination from CDA Immunizations
		-->
		<xsl:param name="medicationType" select="'MED'"/>
		<xsl:param name="pharmacyStatus" select="''"/>

		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="$medicationType = 'MED'">Medication</xsl:when>
				<xsl:otherwise>Vaccination</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="{$elementName}">
			<!--
				Field : Medication Encounter
				Target: HS.SDA3.AbstractOrder EncounterNumber
				Target: /Container/Medications/Medication/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/encounter/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/encounter/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Medication and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<!--
				Field : Immunization Encounter
				Target: HS.SDA3.AbstractOrder EncounterNumber
				Target: /Container/Vaccinations/Vaccination/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Immunization and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>

			<!--
				Field : Medication Author
				Target: HS.SDA3.AbstractOrder EnteredBy
				Target: /Container/Medications/Medication/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/author
				StructuredMappingRef: EnteredByDetail
			-->
			<!--
				Field : Immunization Author
				Target: HS.SDA3.AbstractOrder EnteredBy
				Target: /Container/Vaccinations/Vaccination/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!--
				Field : Medication Information Source
				Target: HS.SDA3.AbstractOrder EnteredAt
				Target: /Container/Medications/Medication/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteredAt
			-->
			<!--
				Field : Immunization Information Source
				Target: HS.SDA3.AbstractOrder EnteredAt
				Target: /Container/Vaccinations/Vaccination/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- Medication EnteredOn -->
			<xsl:if test="$medicationType!='VXU'">
				<xsl:apply-templates select="." mode="AuthorTime"/>
			</xsl:if> 
			
			<!--
				Field : Medication Id
				Target: HS.SDA3.AbstractOrder ExternalId
				Target: /Container/Medications/Medication/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/id
				StructuredMappingRef: ExternalId
			-->
			<!--
				Field : Immunization Id
				Target: HS.SDA3.AbstractOrder ExternalId
				Target: /Container/Vaccinations/Vaccination/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="ExternalId"/>

			<!--
				Field : Medication Entering Organization
				Target: HS.SDA3.AbstractOrder EnteringOrganization
				Target: /Container/Medications/Medication/EnteringOrganization
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteringOrganization
			-->
			<!--
				Field : Immunization Entering Organization
				Target: HS.SDA3.AbstractOrder EnteringOrganization
				Target: /Container/Vaccinations/Vaccination/EnteringOrganization
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteringOrganization
			-->
			<xsl:apply-templates select="." mode="EnteringOrganization"/>
			
			<!--
				Field : Medication Ordering Clinician
				Target: HS.SDA3.AbstractOrder OrderedBy
				Target: /Container/Medications/Medication/OrderedBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
			-->
			<!--
				Field : Immunization Ordering Clinician
				Target: HS.SDA3.AbstractOrder OrderedBy
				Target: /Container/Vaccinations/Vaccination/OrderedBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
			-->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:author" mode="OrderedBy-Author"/>

			<!--
				Field : Medication Placer Id
				Target: HS.SDA3.AbstractOrder PlacerId
				Target: /Container/Medications/Medication/PlacerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/id[2]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/id[2]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/id[2]
				StructuredMappingRef: PlacerId
			-->
			<!--
				Field : Immunization Placer Id
				Target: HS.SDA3.AbstractOrder PlacerId
				Target: /Container/Vaccinations/Vaccination/PlacerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/id[2]
				StructuredMappingRef: PlacerId
			-->
			<xsl:apply-templates select="." mode="PlacerId"/>
			
			<!--
				Field : Medication Filler Id
				Target: HS.SDA3.AbstractOrder FillerId
				Target: /Container/Medications/Medication/FillerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/id[3]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/id[3]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/id[3]
				StructuredMappingRef: FillerId
			-->
			<!--
				Field : Immunization Filler Id
				Target: HS.SDA3.AbstractOrder FillerId
				Target: /Container/Vaccinations/Vaccination/FillerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/id[3]
				StructuredMappingRef: FillerId
			-->
			<xsl:apply-templates select="." mode="FillerId"/>

			<!--
				Field : Medication Start Date/Time
				Target: HS.SDA3.AbstractOrder FromTime
				Target: /Container/Medications/Medication/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			-->
			<!--
				Field : Medication End Date/Time
				Target: HS.SDA3.AbstractOrder ToTime
				Target: /Container/Medications/Medication/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			-->
			<xsl:if test="$medicationType!='VXU'">
				<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']/hl7:low" mode="StartTime"/>
				<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']/hl7:high" mode="EndTime"/>
			</xsl:if>
			
			<!--
				Field : Medication Coded Product Name
				Target: HS.SDA3.AbstractOrder OrderItem
				Target: /Container/Medications/Medication/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				StructuredMappingRef: CodeTableDetail
			-->
			<!--
				Field : Immunization Coded Product Name
				Target: HS.SDA3.AbstractOrder OrderItem
				Target: /Container/Vaccinations/Vaccination/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>

			<!-- Frequency -->
			<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='PIVL_TS']" mode="Frequency"/>			

			<!-- Duration -->
			<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']" mode="Duration"/>			

			<!-- Medication Status -->
			<xsl:apply-templates select="." mode="MedicationStatus"><xsl:with-param name="statusMedicationType" select="$medicationType"/></xsl:apply-templates>
			
			<!-- Pharmacy Status -->
			<xsl:if test="string-length($pharmacyStatus)">
				<PharmacyStatus><xsl:value-of select="$pharmacyStatus"/></PharmacyStatus>
			</xsl:if>
			
			<!-- Prescription Number -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN' and not(hl7:id/@nullFlavor)]" mode="PrescriptionNumber"/>

			<!-- Drug Product -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']" mode="DrugProduct"><xsl:with-param name="medicationType" select="$medicationType"/></xsl:apply-templates>
			
			<!-- Dose Quantity -->
			<xsl:apply-templates select="hl7:doseQuantity" mode="DoseQuantity"/>
			
			<!--
				Field : Medication Number of Refills
				Target: HS.SDA3.AbstractMedication NumberOfRefills
				Target: /Container/Medications/Medication/NumberOfRefills
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/repeatNumber/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/repeatNumber/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/repeatNumber/@value
				Note  : The SDA NumberOfRefills is equal to the CDA repeatNumber/@value minus 1.
			-->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']" mode="NumberOfRefills"/>
			
			<!-- Rate Amount -->
			<xsl:apply-templates select="hl7:rateQuantity" mode="RateAmount"/>				

			<!--
				Field : Medication Route
				Target: HS.SDA3.AbstractMedication Route
				Target: /Container/Medications/Medication/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/routeCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/routeCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/routeCode
				StructuredMappingRef: CodeTableDetail
			-->
			<!--
				Field : Immunization Route
				Target: HS.SDA3.AbstractMedication Route
				Target: /Container/Vaccinations/Vaccination/Route
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/routeCode
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:routeCode" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'Route'"/>
			</xsl:apply-templates>
			
			<!-- Indication -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='RSON']" mode="Indication"/>
			
			<!-- Free-text SIG -->
			<xsl:if test="$medicationType='MED'"><xsl:apply-templates select="hl7:text" mode="Signature"/></xsl:if>
			
			<!--
				Field : Medication Comments
				Target: HS.SDA3.AbstractOrder Comments
				Target: /Container/Medications/Medication/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
			-->
			<!--
				Field : Immunization Comments
				Target: HS.SDA3.AbstractOrder Comments
				Target: /Container/Vaccinations/Vaccination/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Component Medications -->
			<xsl:if test="hl7:entryRelationship[@typeCode='COMP']">
				<ComponentMeds>
					<xsl:apply-templates select="hl7:entryRelationship[@typeCode='COMP']/hl7:substanceAdministration" mode="ComponentMed">
						<xsl:with-param name="medicationType" select="$medicationType"/>
					</xsl:apply-templates>
				</ComponentMeds>
			</xsl:if>

			<xsl:if test="$medicationType='VXU'">
				<xsl:variable name="authorTimes" select="hl7:author/hl7:time | hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time"/>
				<xsl:variable name="startTimes" select="./hl7:effectiveTime[@value] | hl7:effectiveTime/hl7:low"/>
				<xsl:variable name="endTimes" select="hl7:effectiveTime/hl7:high"/>

				<xsl:if test="(count($authorTimes) = 1) or (count($startTimes) = 1) or (count($endTimes) = 1)">
					<Administrations>
						<Administration>
							<!-- Vaccination EnteredOn -->
							<xsl:if test="count($authorTimes) = 1">
								<xsl:apply-templates select="." mode="AuthorTime"/>
							</xsl:if>
							
							<!--
								Field : Immunization Start Date/Time
								Target: HS.SDA3.AbstractOrder FromTime
								Target: /Container/Vaccinations/Vaccination/Administrations/Administration/FromTime
								Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/effectiveTime/@value
								Note  : SDA Vaccination FromTime uses either CDA Immunization effectiveTime/@value
										or effectiveTime/low/@value.  Both values will not be present, and for
										CDA Immunization it is most likely that only effectiveTime/@value will
										be present.
							-->
							<!--
								Field : Immunization End Date/Time
								Target: HS.SDA3.AbstractOrder ToTime
								Target: /Container/Vaccinations/Vaccination/Administrations/Administration/ToTime
								Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
								Note  : SDA Vaccination ToTime uses CDA Immunization effectiveTime/high/@value
										but it is very unlikely that that value will be present.  This is okay, as
										importing only SDA Vaccination FromTime is sufficient.
							-->
							<xsl:if test="count($startTimes) = 1">
								<xsl:apply-templates select="./hl7:effectiveTime[@value] | hl7:effectiveTime/hl7:low" mode="StartTime"/>
							</xsl:if>
							<xsl:if test="count($endTimes) = 1">
								<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="EndTime"/>
							</xsl:if>

						</Administration>
					</Administrations>
				</xsl:if> 
			</xsl:if> 
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Medication">
				<xsl:with-param name="medicationType" select="$medicationType"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*" mode="DrugProduct">
		<xsl:param name="medicationType"/>
		
		<!--
			Field : Medication Coded Product Name
			Target: HS.SDA3.AbstractMedication DrugProduct
			Target: /Container/Medications/Medication/DrugProduct
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial/code
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial/code
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial/code
			StructuredMappingRef: CodeTableDetail
		-->
		<!--
			Field : Immunization Coded Product Name
			Target: HS.SDA3.AbstractMedication DrugProduct
			Target: /Container/Vaccinations/Vaccination/DrugProduct
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial/code
			StructuredMappingRef: CodeTableDetail
		-->
		
		<xsl:variable name="useFirstTranslation" select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:translation[1]/@codeSystem=$noCodeSystemOID"/>
		
		<DrugProduct>		
			<xsl:apply-templates select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="CodeTableDetail">
				<xsl:with-param name="hsElementName" select="'DrugProduct'"/>
				<xsl:with-param name="useFirstTranslation" select="$useFirstTranslation"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="hl7:quantity[not(@nullFlavor)]" mode="DrugProductQuantity"/>
			
			<!--
				Field : Medication Text Product Name
				Target: HS.SDA3.AbstractMedication DrugProduct.ProductName
				Target: /Container/Medications/Medication/DrugProduct/ProductName
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial/name
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial/name
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial/name
			-->
			<!--
				Field : Immunization Text Product Name
				Target: HS.SDA3.AbstractMedication DrugProduct.ProductName
				Target: /Container/Vaccinations/Vaccination/DrugProduct/ProductName
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct/manufacturedMaterial/name
			-->
			<ProductName><xsl:value-of select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name"/></ProductName>
		</DrugProduct>
	</xsl:template>

	<xsl:template match="*" mode="PrescriptionNumber">
		<!--
			Field : Medication Prescription Id
			Target: HS.SDA3.AbstractMedication PrescriptionNumber
			Target: /Container/Medications/Medication/PrescriptionNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Note  : If CDA id/@extension is present then it is
					imported to SDA PrescriptionNumber.  Otherwise
					if id/@root is present then import that value
					to PrescriptionNumber.
		-->
		<!--
			Field : Immunization Prescription Id
			Target: HS.SDA3.AbstractMedication PrescriptionNumber
			Target: /Container/Vaccinations/Vaccination/PrescriptionNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Note  : If CDA id/@extension is present then it is
					imported to SDA PrescriptionNumber.  Otherwise
					if id/@root is present then import that value
					to PrescriptionNumber.
		-->
		<PrescriptionNumber>
			<xsl:choose>
				<xsl:when test="hl7:id/@extension"><xsl:value-of select="hl7:id/@extension"/></xsl:when>
				<xsl:when test="hl7:id/@root"><xsl:value-of select="hl7:id/@root"/></xsl:when>
			</xsl:choose>
		</PrescriptionNumber>
	</xsl:template>

	<xsl:template match="*" mode="DrugProductQuantity">
		<!--
			Field : Medication Quantity Ordered
			Target: HS.SDA3.DrugProduct BaseQty
			Target: /Container/Medications/Medication/DrugProduct/BaseQty
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity/@value
		-->
		<!--
			Field : Immunization Quantity Ordered
			Target: HS.SDA3.DrugProduct BaseQty
			Target: /Container/Vaccinations/Vaccination/DrugProduct/BaseQty
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity/@value
		-->
		<!--
			Field : Medication Quantity Ordered Unit
			Target: HS.SDA3.DrugProduct BaseUnits
			Target: /Container/Medications/Medication/DrugProduct/BaseUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity/@unit
		-->
		<!--
			Field : Immunization Quantity Ordered Unit
			Target: HS.SDA3.DrugProduct BaseUnits
			Target: /Container/Vaccinations/Vaccination/DrugProduct/BaseUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity/@unit
		-->
		<BaseQty><xsl:value-of select="@value"/></BaseQty>
		<BaseUnits><Code><xsl:value-of select="@unit"/></Code><Description><xsl:value-of select="@unit"/></Description></BaseUnits>
	</xsl:template>

	<xsl:template match="*" mode="DoseQuantity">
		<!--
			Field : Medication Dose Quantity
			Target: HS.SDA3.AbstractMedication DoseQuantity
			Target: /Container/Medications/Medication/DoseQuantity
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/doseQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/doseQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/doseQuantity/@value
		-->
		<!--
			Field : Immunization Dose Quantity
			Target: HS.SDA3.AbstractMedication DoseQuantity
			Target: /Container/Vaccinations/Vaccination/DoseQuantity
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/doseQuantity/@value
		-->
		<xsl:variable name="doseQuantity">
			<xsl:choose>
				<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
				<xsl:when test="hl7:low/@value"><xsl:value-of select="hl7:low/@value"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($doseQuantity)"><DoseQuantity><xsl:value-of select="$doseQuantity"/></DoseQuantity></xsl:if>
		
		<!--
			Field : Medication Dose Quantity Unit
			Target: HS.SDA3.AbstractMedication DoseUoM
			Target: /Container/Medications/Medication/DoseUoM
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/doseQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/doseQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/doseQuantity/@unit
		-->
		<!--
			Field : Immunization Dose Quantity Unit
			Target: HS.SDA3.AbstractMedication DoseUoM
			Target: /Container/Vaccinations/Vaccination/DoseUoM
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/doseQuantity/@unit
		-->
		<xsl:variable name="doseUnits">
			<xsl:choose>
				<xsl:when test="@unit"><xsl:value-of select="@unit"/></xsl:when>
				<xsl:when test="hl7:low/@unit"><xsl:value-of select="hl7:low/@unit"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($doseUnits)">
			<DoseUoM>
				<Code><xsl:value-of select="$doseUnits"/></Code>
				<Description><xsl:value-of select="$doseUnits"/></Description>
			</DoseUoM>			
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="NumberOfRefills">
		<xsl:if test="hl7:repeatNumber/@value > 0">
			<NumberOfRefills><xsl:value-of select="hl7:repeatNumber/@value - 1"/></NumberOfRefills>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="RateAmount">
		<!--
			Field : Medication Rate Quantity Amount
			Target: HS.SDA3.AbstractMedication RateAmount
			Target: /Container/Medications/Medication/RateAmount
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/rateQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/rateQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/rateQuantity/@value
		-->
		<!--
			Field : Immunization Rate Quantity Amount
			Target: HS.SDA3.AbstractMedication RateAmount
			Target: /Container/Vaccinations/Vaccination/RateAmount
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/rateQuantity/@value
		-->
		<xsl:variable name="rateAmount">
			<xsl:choose>
				<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
				<xsl:when test="hl7:low/@value"><xsl:value-of select="hl7:low/@value"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($rateAmount)"><RateAmount><xsl:value-of select="$rateAmount"/></RateAmount></xsl:if>
		
		<!--
			Field : Medication Rate Quantity Unit
			Target: HS.SDA3.AbstractMedication RateUnits
			Target: /Container/Medications/Medication/RateUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/rateQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/rateQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/rateQuantity/@unit
		-->
		<!--
			Field : Immunization Rate Quantity Unit
			Target: HS.SDA3.AbstractMedication RateUnits
			Target: /Container/Vaccinations/Vaccination/RateUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/rateQuantity/@unit
		-->
		<xsl:variable name="rateUnits">
			<xsl:choose>
				<xsl:when test="@unit"><xsl:value-of select="@unit"/></xsl:when>
				<xsl:when test="hl7:low/@unit"><xsl:value-of select="hl7:low/@unit"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($rateUnits)">
			<RateUnits>
				<Code><xsl:value-of select="$rateUnits"/></Code>
				<Description><xsl:value-of select="$rateUnits"/></Description>
			</RateUnits>			
		</xsl:if>		
	</xsl:template>
	
	<xsl:template match="*" mode="Frequency">
		<!--
			Field : Medication Frequency
			Target: HS.SDA3.AbstractOrder Frequency
			Target: /Container/Medications/Medication/Frequency
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Note  : In CDA, hl7:period/@value + hl7:period/@unit always indicates an interval.
					@institutionSpecified indicates whether the original data was a
					frequency (true) or an interval (false).
					Even though the SDA property name is Frequency, it may be used to
					import an interval.
		-->
				
		<xsl:variable name="frequency">
			<xsl:choose>
				<xsl:when test="hl7:period/@unit='h' or hl7:period/@unit='hr' or starts-with(hl7:period/@unit,'hour')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="hl7:period/@value='12'">BID</xsl:when>
								<xsl:when test="hl7:period/@value='8'">TID</xsl:when>
								<xsl:when test="hl7:period/@value='6'">QID</xsl:when>
								<xsl:when test="hl7:period/@value='24'">QD</xsl:when>
								<xsl:when test="hl7:period/@value='48'">QOD</xsl:when>
								<xsl:when test="hl7:period/@value='4'">6xD</xsl:when>
								<xsl:when test="hl7:period/@value='3'">8xD</xsl:when>
								<xsl:when test="hl7:period/@value='2'">12xD</xsl:when>
								<xsl:when test="hl7:period/@value='1'">24xD</xsl:when>
								<xsl:when test="not(contains(number(24 div hl7:period/@value),'.'))"><xsl:value-of select="concat(number(24 div hl7:period/@value),'xD')"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',hl7:period/@value,'H')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',hl7:period/@value,'H')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="hl7:period/@unit='d' or starts-with(hl7:period/@unit,'day')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="hl7:period/@value='1'">QD</xsl:when>
								<xsl:when test="hl7:period/@value='2'">QOD</xsl:when>
								<xsl:when test="hl7:period/@value='7'">1xW</xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',hl7:period/@value,'D')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',hl7:period/@value,'D')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="hl7:period/@unit='w' or hl7:period/@unit='wk' or starts-with(hl7:period/@unit,'week')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="hl7:period/@value='1'">1xW</xsl:when>
								<xsl:when test="hl7:period/@value='52'">1xY</xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',hl7:period/@value,'W')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',hl7:period/@value,'W')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="hl7:period/@unit='mo' or hl7:period/@unit='mon' or starts-with(hl7:period/@unit,'month')">
					<xsl:value-of select="concat('Q',hl7:period/@value,'MON')"/>
				</xsl:when>
				<xsl:when test="hl7:period/@unit='y' or hl7:period/@unit='yr' or starts-with(hl7:period/@unit,'year')">
					<xsl:value-of select="concat('Q',hl7:period/@value,'Y')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string-length($frequency)">
			<Frequency>
				<Code><xsl:value-of select="$frequency"/></Code> 
				<Description><xsl:value-of select="$frequency"/></Description>
			</Frequency>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="MedicationStatus">
		<xsl:param name="statusMedicationType" select="'MED'"/>
		
		<!--
			Field : Medication Order Status
			Target: HS.SDA3.AbstractOrder Status
			Target: /Container/Medications/Medication/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Note  : If CDA supply moodCode='EVN' then Status='E'.
					If CDA status entryRelationship code='421139008' then SDA Status='H'.
					If CDA status entryRelationship code='55561003' then SDA Status='IP'.
					Otherwise SDA Status='I'.
		-->
		<!--
			Field : Immunization Order Status
			Target: HS.SDA3.AbstractOrder Status
			Target: /Container/Vaccinations/Vaccination/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Note  : If importing to SDA Vaccination and CDA substanceAdministration/@negationInd='true' then SDA Status='C'.
					If CDA supply moodCode='EVN' then Status='E'.
					If CDA status entryRelationship code='421139008' then SDA Status='H'.
					If CDA status entryRelationship code='55561003' then SDA Status='IP'.
					Otherwise SDA Status='I'.
		-->
		<Status>
			<xsl:choose>
				<xsl:when test="($statusMedicationType='VXU') and (../hl7:substanceAdministration/@negationInd='true')">C</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode = 'EVN']">E</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value/@code = '421139008'">H</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value/@code = '55561003'">IP</xsl:when>
				<xsl:otherwise>I</xsl:otherwise>
			</xsl:choose>
		</Status>
	</xsl:template>
	
	<xsl:template match="*" mode="Indication">
		<!--
			Field : Medication Indication
			Target: HS.SDA3.AbstractMedication Indication
			Target: /Container/Medications/Medication/Indication
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Note  : In C32, Indication is a string, not a coded element.
		-->
		<!--
			Field : Immunization Indication
			Target: HS.SDA3.AbstractMedication Indication
			Target: /Container/Vaccinations/Vaccination/Indication
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Note  : In C32, Indication is a string, not a coded element.
		-->
		<Indication><xsl:apply-templates select="hl7:observation/hl7:text" mode="TextValue"/></Indication>
	</xsl:template>
	
	<xsl:template match="*" mode="Signature">
		<!--
			Field : Medication Free Text Sig
			Target: HS.SDA3.AbstractOrder TextInstruction
			Target: /Container/Medications/Medication/TextInstruction
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/text
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/text
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/text
		-->
		<!--
			Field : Immunization Free Text Sig
			Target: HS.SDA3.AbstractOrder TextInstruction
			Target: /Container/Vaccinations/Vaccination/TextInstruction
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/text
		-->
		<xsl:variable name="sigText"><xsl:apply-templates select="." mode="TextValue"/></xsl:variable>
		<xsl:if test="string-length($sigText)"><TextInstruction><xsl:value-of select="$sigText"/></TextInstruction></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="PatientInstructions">
		<PatientInstruction><xsl:apply-templates select="." mode="TextValue"/></PatientInstruction>
	</xsl:template>

	<xsl:template match="*" mode="Duration">
		<!--
			Field : Medication Duration Start
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Medications/Medication/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
		-->
		<!--
			Field : Medication Duration End
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Medications/Medication/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.19']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.21']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.22']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
		-->
		<!--
			Field : Immunization Duration
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Vaccinations/Vaccination/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/effectiveTime/@value
			Note  : CDA Immunization will most likely only have effectiveTime/@value.
					In that case effectiveTime/@value is used as the start and end
					time when calculating Duration.
		-->
		<!--
			Field : Immunization Duration
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Vaccinations/Vaccination/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Note  : CDA Immunization will most likely only have effectiveTime/@value.
					In that case effectiveTime/@value is used as the start and end
					time when calculating Duration.
		-->
		<xsl:variable name="medicationStartDateTime" select="@value | hl7:low/@value"/>
		<xsl:variable name="medicationEndDateTime" select="@value | hl7:high/@value"/>
		<!--
			The Duration is the number of days from start date to
			end date, inclusive.  For example a duration of Monday
			the 1st through Friday the 5th is 5 days, not 5-1=4 days.
		-->
		<xsl:variable name="durationTemp" select="isc:evaluate('dateDiff', 'dd', concat(substring($medicationStartDateTime,5,2), '-', substring($medicationStartDateTime,7,2), '-', substring($medicationStartDateTime,1,4)), concat(substring($medicationEndDateTime,5,2), '-', substring($medicationEndDateTime,7,2), '-', substring($medicationEndDateTime,1,4)))"/>
		<xsl:variable name="durationValueInDays">
			<xsl:choose>
				<xsl:when test="string-length($durationTemp)"><xsl:value-of select="number($durationTemp + 1)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string-length($durationValueInDays)">
			<Duration>
				<Code><xsl:value-of select="concat($durationValueInDays, 'd')"/></Code>
				<xsl:choose>
					<xsl:when test="$durationValueInDays>1"><Description><xsl:value-of select="concat($durationValueInDays, ' days')"/></Description></xsl:when>
					<xsl:otherwise><Description><xsl:value-of select="concat($durationValueInDays, ' day')"/></Description></xsl:otherwise>
				</xsl:choose>
			</Duration>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="ComponentMed">
		<xsl:param name="medicationType"/>
		
		<DrugProduct>
			<xsl:choose>
				<xsl:when test="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@code">
					<xsl:apply-templates select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="CodeTable"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="componentName">
						<xsl:choose>
						<xsl:when test="string-length(substring-after(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#'))">
							<xsl:value-of select="normalize-space(key('narrativeKey', substring-after(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#')))"/>
						</xsl:when>
						<xsl:when test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/text())">
							<xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/text()"/>
						</xsl:when>
						<xsl:when test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name/text())">
							<xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name/text()"/>
						</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<Code><xsl:value-of select="$componentName"/></Code>
					<Description><xsl:value-of select="$componentName"/></Description>
				</xsl:otherwise>
			</xsl:choose>
		</DrugProduct>
	</xsl:template>

	<xsl:template match="*" mode="AuthorTime">
		<!--
			Field : Medication Author Time
			Target: HS.SDA3.AbstractOrder EnteredOn
			Target: /Container/Medications/Medication/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/author/time/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/author/time/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/author/time/@value
		-->
		<!--
			Field : Immunization Author Time
			Target: HS.SDA3.AbstractOrder EnteredOn
			Target: /Container/Vaccinations/Vaccination/Administrations/Administration/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author/time/@value
		-->
		<!--
			Field : Medication Author Time
			Target: HS.SDA3.AbstractOrder EnteredOn
			Target: /Container/Medications/Medication/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/supply[@moodCode='EVN']/author/time/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/supply[@moodCode='EVN']/author/time/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/supply[@moodCode='EVN']/author/time/@value
		-->
		<!--
			Field : Immunization Author Time
			Target: HS.SDA3.AbstractOrder EnteredOn
			Target: /Container/Vaccinations/Vaccination/Administrations/Administration/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/supply[@moodCode='EVN']/author/time/@value
		-->
		<xsl:choose>
			<xsl:when test="hl7:author/hl7:time">
				<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			</xsl:when>
			<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time">
				<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time" mode="EnteredOn"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:substanceAdministration.
	-->
	<xsl:template match="*" mode="ImportCustom-Medication">
		<xsl:param name="medicationType" select="'MED'"/>
	</xsl:template>
</xsl:stylesheet>
