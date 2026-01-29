<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc hl7 xsi">
	<!-- AlsoInclude: Comment.xsl -->
	
	<xsl:template match="hl7:substanceAdministration" mode="eM-Medication">
		<!--
			medicationType:
			MED    = Medication from CDA Medications, Medications Administered, or Hospital Discharge Medications
			MEDPOC = Medication from CDA Plan of Care
			VXU    = Vaccination from CDA Immunizations
		-->
		<xsl:param name="medicationType" select="'MED'"/>
		
		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="$medicationType = 'MED'">Medication</xsl:when>
				<xsl:when test="$medicationType = 'MEDPOC'">Medication</xsl:when>
				<xsl:otherwise>Vaccination</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="{$elementName}">
			<!--
				Field : Medication Placer Id
				Target: HS.SDA3.AbstractOrder PlacerId
				Target: /Container/Medications/Medication/PlacerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id[2]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id[2]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id[2]
				StructuredMappingRef: PlacerId
			-->
			<!--
				Field : Immunization Placer Id
				Target: HS.SDA3.AbstractOrder PlacerId
				Target: /Container/Vaccinations/Vaccination/PlacerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[2]
				StructuredMappingRef: PlacerId
			-->
			<xsl:apply-templates select="." mode="fn-PlacerId"/>
			
			<!--
				Field : Medication Filler Id
				Target: HS.SDA3.AbstractOrder FillerId
				Target: /Container/Medications/Medication/FillerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id[3]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id[3]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id[3]
				StructuredMappingRef: FillerId
			-->
			<!--
				Field : Immunization Filler Id
				Target: HS.SDA3.AbstractOrder FillerId
				Target: /Container/Vaccinations/Vaccination/FillerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[3]
				StructuredMappingRef: FillerId
			-->
			<xsl:apply-templates select="." mode="fn-FillerId"/>

			<!--
				Field : Medication Coded Product Name
				Target: HS.SDA3.AbstractOrder OrderItem
				Target: /Container/Medications/Medication/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				StructuredMappingRef: CodeTableDetail
			-->
			<!--
				Field : Immunization Coded Product Name
				Target: HS.SDA3.AbstractOrder OrderItem
				Target: /Container/Vaccinations/Vaccination/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>

			<!--
				Field : Medication Author
				Target: HS.SDA3.AbstractOrder EnteredBy
				Target: /Container/Medications/Medication/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/author
				StructuredMappingRef: EnteredByDetail
			-->
			<!--
				Field : Immunization Author
				Target: HS.SDA3.AbstractOrder EnteredBy
				Target: /Container/Vaccinations/Vaccination/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!--
				Field : Medication Information Source
				Target: HS.SDA3.AbstractOrder EnteredAt
				Target: /Container/Medications/Medication/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteredAt
			-->
			<!--
				Field : Immunization Information Source
				Target: HS.SDA3.AbstractOrder EnteredAt
				Target: /Container/Vaccinations/Vaccination/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!-- Medication EnteredOn -->
			<xsl:if test="$medicationType!='VXU'">
				<xsl:apply-templates select="." mode="eM-AuthorTime"/>
			</xsl:if> 
			
			<!--
				Field : Medication Id
				Target: HS.SDA3.AbstractOrder ExternalId
				Target: /Container/Medications/Medication/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id
				StructuredMappingRef: ExternalId
			-->
			<!--
				Field : Immunization Id
				Target: HS.SDA3.AbstractOrder ExternalId
				Target: /Container/Vaccinations/Vaccination/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>

			<!--
				Field : Medication Entering Organization
				Target: HS.SDA3.AbstractOrder EnteringOrganization
				Target: /Container/Medications/Medication/EnteringOrganization
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteringOrganization
			-->
			<!--
				Field : Immunization Entering Organization
				Target: HS.SDA3.AbstractOrder EnteringOrganization
				Target: /Container/Vaccinations/Vaccination/EnteringOrganization
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteringOrganization
			-->
			<xsl:apply-templates select="." mode="fn-EnteringOrganization"/>
			
			<!--
				Field : Medication Ordering Clinician
				Target: HS.SDA3.AbstractOrder OrderedBy
				Target: /Container/Medications/Medication/OrderedBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
			-->
			<!--
				Field : Immunization Ordering Clinician
				Target: HS.SDA3.AbstractOrder OrderedBy
				Target: /Container/Vaccinations/Vaccination/OrderedBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
			-->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:author" mode="fn-OrderedBy-Author"/>

			<!-- Frequency -->
			<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='PIVL_TS']" mode="eM-Frequency"/>			

			<!-- Duration -->
			<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']" mode="eM-Duration"/>			

			<!-- Medication Status -->
			<xsl:apply-templates select="." mode="eM-Status">
				<xsl:with-param name="statusMedicationType" select="$medicationType"/>
			</xsl:apply-templates>
						
			<!-- Free-text SIG, TextInstruction -->
			<xsl:if test="$medicationType='MED' or $medicationType='MEDPOC'">
				<xsl:apply-templates select="hl7:text" mode="eM-TextInstruction"/>
			</xsl:if>

			<!-- Number of Refills -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT'][hl7:repeatNumber]" mode="eM-NumberOfRefills"/>
			<!-- The connotation of repeatNumber will vary, based on the moodCode. -->
			
			<!--
				Field : Medication Start Date/Time
				Target: HS.SDA3.AbstractOrder FromTime
				Target: /Container/Medications/Medication/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			-->
			<!--
				Field : Medication End Date/Time
				Target: HS.SDA3.AbstractOrder ToTime
				Target: /Container/Medications/Medication/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			-->
			<xsl:if test="$medicationType!='VXU'">
				<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']/hl7:low" mode="fn-StartTime"/>
				<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']/hl7:high" mode="fn-EndTime"/>
			</xsl:if>
			
			<!-- Drug Product -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']" mode="eM-DrugProduct">
				<xsl:with-param name="medicationType" select="$medicationType"/>
			</xsl:apply-templates>

			<!-- Rate Amount -->
			<xsl:apply-templates select="hl7:rateQuantity" mode="eM-RateAmountAndUnits"/>	

			<!-- Dose Quantity -->
			<xsl:apply-templates select="hl7:doseQuantity" mode="eM-DoseQuantityAndUoM"/>
			
			<!--
				Field : Medication Route
				Target: HS.SDA3.AbstractMedication Route
				Target: /Container/Medications/Medication/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/routeCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/routeCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/routeCode
				StructuredMappingRef: CodeTableDetail
			-->
			<!--
				Field : Immunization Route
				Target: HS.SDA3.AbstractMedication Route
				Target: /Container/Vaccinations/Vaccination/Route
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/routeCode
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:routeCode" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'Route'"/>
			</xsl:apply-templates>
			
			<!-- Indication -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='RSON']" mode="eM-Indication"/>
			
			<!--
				Field : Medication Comments
				Target: HS.SDA3.AbstractOrder Comments
				Target: /Container/Medications/Medication/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
			-->
			<!--
				Field : Immunization Comments
				Target: HS.SDA3.AbstractOrder Comments
				Target: /Container/Vaccinations/Vaccination/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="eCm-Comment"/>
			
			<!-- Component Medications -->
			<xsl:if test="hl7:entryRelationship[@typeCode='COMP']">
				<ComponentMeds>
					<xsl:apply-templates select="hl7:entryRelationship[@typeCode='COMP']/hl7:substanceAdministration" mode="eM-ComponentMed">
						<xsl:with-param name="medicationType" select="$medicationType"/>
					</xsl:apply-templates>
				</ComponentMeds>
			</xsl:if>
			
			<!-- Prescription Number -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']" mode="eM-PrescriptionNumber"/>

			<!-- Check if there is data to include in <Administrations> -->
			<xsl:variable name="refusalObservations" select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation[@moodCode='EVN' and hl7:templateId/@root=$ccda-ImmunizationRefusalReason]"/>
			
			<xsl:variable name="authorTimes" select="hl7:author/hl7:time | hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time"/>
			<xsl:variable name="startTimes" select="./hl7:effectiveTime[@value] | hl7:effectiveTime/hl7:low"/>
			<xsl:variable name="endTimes" select="hl7:effectiveTime/hl7:high"/>

			<!-- 
				Include <Administrations> if there is a LotNumber, RefusalReason, EnteredOn, FromTime or ToTime. 
				Note that EnteredOn, FromTime and ToTime are only included if there is exactly one value for the given field. 
			-->
			<xsl:if test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:lotNumberText) or count($refusalObservations) > 0 
				or ($medicationType='VXU' and ((count($authorTimes) = 1) or (count($startTimes) = 1) or (count($endTimes) = 1)))">
				<Administrations>
					<Administration>
						<!--
							Field : Vaccination Lot Number
							Target: HS.SDA3.Administration LotNumber
							Target: /Container/Vaccinations/Vaccination/Administrations/Administration/LotNumber
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/lotNumberText
						-->
						<xsl:for-each select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial">
							<xsl:if test="hl7:lotNumberText/text()">
								<LotNumber><xsl:value-of select="hl7:lotNumberText/text()" /></LotNumber>
							</xsl:if>
						</xsl:for-each>
						
						<!--
							Field : Vaccination RefusalReason
							Target: HS.SDA3.Administration RefusalReason
							Target: /Container/Vaccinations/Vaccination/Administrations/Administration/RefusalReason
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation[@moodCode='EVN' and hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.53']
						-->
						<xsl:for-each select="$refusalObservations">
							<RefusalReason>
								<Code><xsl:value-of select="hl7:code/@code" /></Code>
								<Description><xsl:value-of select="hl7:code/@displayName" /></Description>
							</RefusalReason>
						</xsl:for-each>

						<xsl:if test="$medicationType='VXU'">
							<!-- Vaccination EnteredOn -->
							<xsl:if test="count($authorTimes) = 1">
								<xsl:apply-templates select="." mode="eM-AuthorTime"/>
							</xsl:if>

							<!--
								Field : Immunization Start Date/Time
								Target: HS.SDA3.AbstractOrder FromTime
								Target: /Container/Vaccinations/Vaccination/Administrations/Administration/FromTime
								Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/@value
								Note  : SDA Vaccination FromTime uses either CDA Immunization effectiveTime/@value
										or effectiveTime/low/@value.  Both values will not be present, and for
										CDA Immunization it is most likely that only effectiveTime/@value will
										be present.
							-->
							<!--
								Field : Immunization End Date/Time
								Target: HS.SDA3.AbstractOrder ToTime
								Target: /Container/Vaccinations/Vaccination/Administrations/Administration/ToTime
								Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
								Note  : SDA Vaccination ToTime uses CDA Immunization effectiveTime/high/@value
										but it is very unlikely that that value will be present.  This is okay, as
										importing only SDA Vaccination FromTime is sufficient.
							-->
							<xsl:if test="count($startTimes) = 1">
								<xsl:apply-templates select="./hl7:effectiveTime[@value] | hl7:effectiveTime/hl7:low" mode="fn-StartTime"/>
							</xsl:if>
							<xsl:if test="count($endTimes) = 1">
								<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-EndTime"/>
							</xsl:if>
						</xsl:if> 
					</Administration>
				</Administrations>
			</xsl:if> 

			<!--
				Field : Medication Encounter
				Target: HS.SDA3.AbstractOrder EncounterNumber
				Target: /Container/Medications/Medication/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/encounter/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/encounter/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/encounter/id
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
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Immunization and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></EncounterNumber>

			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eM-ImportCustom-Medication">
				<xsl:with-param name="medicationType" select="$medicationType"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="hl7:supply" mode="eM-DrugProduct">
		<!--
			Field : Medication Coded Product Name
			Target: HS.SDA3.AbstractMedication DrugProduct
			Target: /Container/Medications/Medication/DrugProduct
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/code
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/code
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/code
			StructuredMappingRef: CodeTableDetail
		-->
		<!--
			Field : Immunization Coded Product Name
			Target: HS.SDA3.AbstractMedication DrugProduct
			Target: /Container/Vaccinations/Vaccination/DrugProduct
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/code
			StructuredMappingRef: CodeTableDetail
		-->
		
		<xsl:variable name="useFirstTranslation" select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:translation[1]/@codeSystem=$noCodeSystemOID"/>
		
		<DrugProduct>		
			<xsl:apply-templates select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="fn-CodeTableDetail">
				<xsl:with-param name="emitElementName" select="'DrugProduct'"/>
				<xsl:with-param name="useFirstTranslation" select="$useFirstTranslation"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="hl7:quantity[not(@nullFlavor)]" mode="eM-DrugProductQuantity"/>
			
			<!--
				Field : Medication Text Product Name
				Target: HS.SDA3.AbstractMedication DrugProduct.ProductName
				Target: /Container/Medications/Medication/DrugProduct/ProductName
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/name
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/name
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/name
			-->
			<!--
				Field : Immunization Text Product Name
				Target: HS.SDA3.AbstractMedication DrugProduct.ProductName
				Target: /Container/Vaccinations/Vaccination/DrugProduct/ProductName
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/name
			-->
			<ProductName><xsl:value-of select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name"/></ProductName>
		</DrugProduct>
	</xsl:template>

	<xsl:template match="hl7:supply" mode="eM-PrescriptionNumber">
		<!--
			Field : Medication Prescription Id
			Target: HS.SDA3.AbstractMedication PrescriptionNumber
			Target: /Container/Medications/Medication/PrescriptionNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Note  : If CDA id/@extension is present then it is
					imported to SDA PrescriptionNumber.  Otherwise
					if id/@root is present then import that value
					to PrescriptionNumber.
		-->
		<!--
			Field : Immunization Prescription Id
			Target: HS.SDA3.AbstractMedication PrescriptionNumber
			Target: /Container/Vaccinations/Vaccination/PrescriptionNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
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

	<xsl:template match="hl7:quantity" mode="eM-DrugProductQuantity">
		<!--
			Field : Medication Quantity Ordered
			Target: HS.SDA3.DrugProduct BaseQty
			Target: /Container/Medications/Medication/DrugProduct/BaseQty
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/quantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@value
		-->
		<!--
			Field : Immunization Quantity Ordered
			Target: HS.SDA3.DrugProduct BaseQty
			Target: /Container/Vaccinations/Vaccination/DrugProduct/BaseQty
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@value
		-->
		<!--
			Field : Medication Quantity Ordered Unit
			Target: HS.SDA3.DrugProduct BaseUnits
			Target: /Container/Medications/Medication/DrugProduct/BaseUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/quantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@unit
		-->
		<!--
			Field : Immunization Quantity Ordered Unit
			Target: HS.SDA3.DrugProduct BaseUnits
			Target: /Container/Vaccinations/Vaccination/DrugProduct/BaseUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@unit
		-->
		<BaseQty><xsl:value-of select="@value"/></BaseQty>
		<BaseUnits><Code><xsl:value-of select="@unit"/></Code><Description><xsl:value-of select="@unit"/></Description></BaseUnits>
	</xsl:template>

	<xsl:template match="hl7:doseQuantity" mode="eM-DoseQuantityAndUoM">
		<!-- The mode formerly known as DoseQuantity -->
		<!--
			Field : Medication Dose Quantity
			Target: HS.SDA3.AbstractMedication DoseQuantity
			Target: /Container/Medications/Medication/DoseQuantity
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/doseQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/doseQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/doseQuantity/@value
		-->
		<!--
			Field : Immunization Dose Quantity
			Target: HS.SDA3.AbstractMedication DoseQuantity
			Target: /Container/Vaccinations/Vaccination/DoseQuantity
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/doseQuantity/@value
		-->
		<xsl:variable name="doseQuantity">
			<xsl:choose>
				<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
				<xsl:when test="hl7:low/@value"><xsl:value-of select="hl7:low/@value"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($doseQuantity)">
			<DoseQuantity><xsl:value-of select="$doseQuantity"/></DoseQuantity>
		</xsl:if>
		
		<!--
			Field : Medication Dose Quantity Unit
			Target: HS.SDA3.AbstractMedication DoseUoM
			Target: /Container/Medications/Medication/DoseUoM
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/doseQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/doseQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/doseQuantity/@unit
		-->
		<!--
			Field : Immunization Dose Quantity Unit
			Target: HS.SDA3.AbstractMedication DoseUoM
			Target: /Container/Vaccinations/Vaccination/DoseUoM
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/doseQuantity/@unit
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

	<xsl:template match="hl7:supply" mode="eM-NumberOfRefills">
		<!--
			Field : Medication Number of Refills
			Target: HS.SDA3.AbstractMedication NumberOfRefills
			Target: /Container/Medications/Medication/NumberOfRefills
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/repeatNumber/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/repeatNumber/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/repeatNumber/@value
			Note  : The SDA NumberOfRefills is equal to the CDA repeatNumber/@value minus 1.
		-->
		<xsl:if test="hl7:repeatNumber/@value > 0">
			<NumberOfRefills><xsl:value-of select="hl7:repeatNumber/@value - 1"/></NumberOfRefills>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:rateQuantity" mode="eM-RateAmountAndUnits">
		<!-- The mode formerly known as RateAmount -->		
		<!--
			Field : Medication Rate Quantity Amount
			Target: HS.SDA3.AbstractMedication RateAmount
			Target: /Container/Medications/Medication/RateAmount
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/rateQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/rateQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/rateQuantity/@value
		-->
		<!--
			Field : Immunization Rate Quantity Amount
			Target: HS.SDA3.AbstractMedication RateAmount
			Target: /Container/Vaccinations/Vaccination/RateAmount
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/rateQuantity/@value
		-->
		<xsl:variable name="rateAmount">
			<xsl:choose>
				<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
				<xsl:when test="hl7:low/@value"><xsl:value-of select="hl7:low/@value"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($rateAmount)">
			<RateAmount><xsl:value-of select="$rateAmount"/></RateAmount>
		</xsl:if>
		
		<!--
			Field : Medication Rate Quantity Unit
			Target: HS.SDA3.AbstractMedication RateUnits
			Target: /Container/Medications/Medication/RateUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/rateQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/rateQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/rateQuantity/@unit
		-->
		<!--
			Field : Immunization Rate Quantity Unit
			Target: HS.SDA3.AbstractMedication RateUnits
			Target: /Container/Vaccinations/Vaccination/RateUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/rateQuantity/@unit
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
	
	<xsl:template match="hl7:effectiveTime" mode="eM-Frequency">
		<!--
			Field : Medication Frequency
			Target: HS.SDA3.AbstractOrder Frequency
			Target: /Container/Medications/Medication/Frequency
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Note  : In CDA, hl7:period/@value + hl7:period/@unit always indicates an interval.
					@institutionSpecified indicates whether the original data was a
					frequency (true) or an interval (false).
					Even though the SDA property name is Frequency, it may be used to
					import an interval.
		-->			
		<xsl:variable name="frequency">
			<xsl:variable name="periodUnit" select="hl7:period/@unit"/>
			<xsl:variable name="periodValue" select="hl7:period/@value"/>
			<xsl:choose>
				<xsl:when test="$periodUnit='h' or $periodUnit='hr' or starts-with($periodUnit,'hour')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="$periodValue='12'">BID</xsl:when>
								<xsl:when test="$periodValue='8'">TID</xsl:when>
								<xsl:when test="$periodValue='6'">QID</xsl:when>
								<xsl:when test="$periodValue='24'">QD</xsl:when>
								<xsl:when test="$periodValue='48'">QOD</xsl:when>
								<xsl:when test="$periodValue='4'">6xD</xsl:when>
								<xsl:when test="$periodValue='3'">8xD</xsl:when>
								<xsl:when test="$periodValue='2'">12xD</xsl:when>
								<xsl:when test="$periodValue='1'">24xD</xsl:when>
								<xsl:when test="not(contains(number(24 div $periodValue),'.'))"><xsl:value-of select="concat(number(24 div $periodValue),'xD')"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'H')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'H')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$periodUnit='d' or starts-with($periodUnit,'day')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="$periodValue='1'">QD</xsl:when>
								<xsl:when test="$periodValue='2'">QOD</xsl:when>
								<xsl:when test="$periodValue='7'">1xW</xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'D')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'D')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$periodUnit='w' or $periodUnit='wk' or starts-with($periodUnit,'week')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="$periodValue='1'">1xW</xsl:when>
								<xsl:when test="$periodValue='52'">1xY</xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'W')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'W')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$periodUnit='mo' or $periodUnit='mon' or starts-with($periodUnit,'month')">
					<xsl:value-of select="concat('Q',$periodValue,'MON')"/>
				</xsl:when>
				<xsl:when test="$periodUnit='y' or $periodUnit='yr' or starts-with($periodUnit,'year')">
					<xsl:value-of select="concat('Q',$periodValue,'Y')"/>
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

	<xsl:template match="hl7:substanceAdministration" mode="eM-Status">
		<!-- The mode formerly known as MedicationStatus -->
		<xsl:param name="statusMedicationType" select="'MED'"/>	
		<!--
			Field : Medication Order Status
			Target: HS.SDA3.AbstractOrder Status
			Target: /Container/Medications/Medication/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Note  : If CDA supply moodCode='EVN' then Status='E'.
					If CDA status entryRelationship code='421139008' then SDA Status='H'.
					If CDA status entryRelationship code='55561003' then SDA Status='IP'.
					Otherwise SDA Status='I'.
		-->
		<!--
			Field : Immunization Order Status
			Target: HS.SDA3.AbstractOrder Status
			Target: /Container/Vaccinations/Vaccination/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Note  : If importing to SDA Vaccination and CDA substanceAdministration/@negationInd='true' then SDA Status='C'.
					If CDA supply moodCode='EVN' then Status='E'.
					If CDA status entryRelationship code='421139008' then SDA Status='H'.
					If CDA status entryRelationship code='55561003' then SDA Status='IP'.
					Otherwise SDA Status='I'.
		-->
		<Status>
			<xsl:choose>
				<xsl:when test="($statusMedicationType='VXU') and (../hl7:substanceAdministration/@negationInd='true')">C</xsl:when>
				<xsl:when test="($statusMedicationType='MEDPOC')">P</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode = 'EVN']">E</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value/@code = '421139008'">H</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value/@code = '55561003'">IP</xsl:when>
				<xsl:otherwise>I</xsl:otherwise>
			</xsl:choose>
		</Status>
	</xsl:template>
	
	<xsl:template match="hl7:entryRelationship" mode="eM-Indication">
		<!--
			Field : Medication Indication
			Target: HS.SDA3.AbstractMedication Indication
			Target: /Container/Medications/Medication/Indication
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Note  : In SDA, Indication is a String property.  However,
					in C-CDA it is a coded element.  For SDA Indication
					string, use the first found of these:
					- value/@displayName
					- value/originalText
					- value/@code
					- value/translation/@displayname
					- value/translation/@code
		-->
		<!--
			Field : Immunization Indication
			Target: HS.SDA3.AbstractMedication Indication
			Target: /Container/Vaccinations/Vaccination/Indication
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Note  : In SDA, Indication is a String property.  However,
					in C-CDA it is a coded element.  For SDA Indication
					string, use the first found of these:
					- value/@displayName
					- value/originalText
					- value/@code
					- value/translation/@displayname
					- value/translation/@code
		-->	
		<xsl:variable name="obsValue" select="hl7:observation/hl7:value"/>
		<xsl:variable name="originalTextReferenceLink" select="substring-after($obsValue/hl7:originalText/hl7:reference/@value, '#')"/>
		<xsl:variable name="originalTextReferenceValue">
			<xsl:if test="string-length($originalTextReferenceLink)">
				<xsl:value-of select="normalize-space(key('narrativeKey', $originalTextReferenceLink))"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="indication">
			<xsl:choose>
				<xsl:when test="string-length($obsValue/@displayName)">
					<xsl:value-of select="$obsValue/@displayName"/>
				</xsl:when>
				<xsl:when test="string-length($originalTextReferenceValue)">
					<xsl:value-of select="$originalTextReferenceValue"/>
				</xsl:when>
				<xsl:when test="string-length($obsValue/@code)">
					<xsl:value-of select="$obsValue/@code"/>
				</xsl:when>
				<xsl:when test="string-length($obsValue/hl7:translation/@displayName)">
					<xsl:value-of select="$obsValue/hl7:translation/@displayName"/>
				</xsl:when>
				<xsl:when test="string-length($obsValue/hl7:translation/@code)">
					<xsl:value-of select="$obsValue/hl7:translation/@code"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="string-length($indication)">
			<Indication><xsl:value-of select="$indication"/></Indication>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:text" mode="eM-TextInstruction">
		<!-- The mode formerly known as Signature -->
		<!--
			Field : Medication Free Text Sig
			Target: HS.SDA3.AbstractOrder TextInstruction
			Target: /Container/Medications/Medication/TextInstruction
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/text
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/text
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/text
		-->
		<!--
			Field : Immunization Free Text Sig
			Target: HS.SDA3.AbstractOrder TextInstruction
			Target: /Container/Vaccinations/Vaccination/TextInstruction
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/text
		-->
		<xsl:variable name="sigText"><xsl:apply-templates select="." mode="fn-TextValue"/></xsl:variable>
		<xsl:if test="string-length(normalize-space($sigText))">
			<TextInstruction><xsl:value-of select="$sigText"/></TextInstruction>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:effectiveTime" mode="eM-Duration">
		<!--
			Field : Medication Duration Start
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Medications/Medication/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
		-->
		<!--
			Field : Medication Duration End
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Medications/Medication/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
		-->
		<!--
			Field : Immunization Duration
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Vaccinations/Vaccination/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/@value
			Note  : CDA Immunization will most likely only have effectiveTime/@value.
					In that case effectiveTime/@value is used as the start and end
					time when calculating Duration.
		-->
		<!--
			Field : Immunization Duration
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Vaccinations/Vaccination/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
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
		<xsl:variable name="durationTemp"
			select="
				isc:evaluate('dateDiff', 'dd',
				concat(substring($medicationStartDateTime, 5, 2), '-', substring($medicationStartDateTime, 7, 2), '-', substring($medicationStartDateTime, 1, 4)),
				concat(substring($medicationEndDateTime, 5, 2), '-', substring($medicationEndDateTime, 7, 2), '-', substring($medicationEndDateTime, 1, 4)))"/>
		<xsl:variable name="durationValueInDays">
			<xsl:if test="string-length($durationTemp)">
				<xsl:value-of select="number($durationTemp) + 1"/>
			</xsl:if>
			<!-- otherwise, the null string -->
		</xsl:variable>

		<xsl:if test="string-length($durationValueInDays)">
			<Duration>
				<Code>
					<xsl:value-of select="concat($durationValueInDays, 'd')"/>
				</Code>
				<xsl:choose>
					<xsl:when test="$durationValueInDays > 1">
						<Description>
							<xsl:value-of select="concat($durationValueInDays, ' days')"/>
						</Description>
					</xsl:when>
					<xsl:otherwise>
						<Description>
							<xsl:value-of select="concat($durationValueInDays, ' day')"/>
						</Description>
					</xsl:otherwise>
				</xsl:choose>
			</Duration>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:substanceAdministration" mode="eM-ComponentMed">
		<xsl:param name="medicationType"/>
		
		<DrugProduct>
			<xsl:choose>
				<xsl:when test="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@code">
					<xsl:apply-templates select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="fn-CodeTable"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="componentName">
						<xsl:choose>
							<xsl:when test="string-length(substring-after(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#'))">
								<xsl:value-of	select="normalize-space(key('narrativeKey', substring-after(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#')))"/>
							</xsl:when>
							<xsl:when test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/text())">
								<xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/text()"/>
							</xsl:when>
							<xsl:when test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name/text())">
								<xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name/text()"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<Code>
						<xsl:value-of select="$componentName"/>
					</Code>
					<Description>
						<xsl:value-of select="$componentName"/>
					</Description>
				</xsl:otherwise>
			</xsl:choose>
		</DrugProduct>
	</xsl:template>

	<xsl:template match="*" mode="eM-AuthorTime">
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
			<xsl:when test="hl7:author/hl7:time/@value">
				<xsl:apply-templates select="hl7:author/hl7:time/@value" mode="fn-E-paramName-timestamp">
					<xsl:with-param name="emitElementName" select="'EnteredOn'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time/@value">
				<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time/@value" mode="fn-E-paramName-timestamp">
					<xsl:with-param name="emitElementName" select="'EnteredOn'"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:substanceAdministration.
		The medicationType is passed down from mode="eM-Medication" (see comments at top of that template).
	-->
	<xsl:template match="*" mode="eM-ImportCustom-Medication">
		<xsl:param name="medicationType" select="'MED'"/>
	</xsl:template>
	
</xsl:stylesheet>