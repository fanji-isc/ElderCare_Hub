<?xml version="1.0"?>
<!-- Convert from SDA2 to SDA3 -->
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" 
				exclude-result-prefixes="xsi isc"
				version="1.0">
<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>

 <xsl:variable name="exportConfiguration" select="document('CDA-Support-Files/Site/ExportProfile.xml')/exportConfiguration" /> 
<xsl:variable name="advanceDirectiveTypeCodes" select="$exportConfiguration/advanceDirectives/advanceDirectiveType/codes/text()" /> 

<!--  Copy everything under Container except the Patients element itself-->
<xsl:template match="Container">
	<xsl:copy>
		<xsl:apply-templates select="*[not(self::Patients)]"/>
		<xsl:apply-templates select="Patients/Patient"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="Patient">
	<!-- copy elements that go directly under Patient -->
	<xsl:copy>
		<xsl:apply-templates select="*[not(self::Alerts | self::Allergies | self::FamilyHistory | self::SocialHistory | self::PastHistory | self::Encounters | self::Guarantors)]"/>
	</xsl:copy>

	<!-- Add other Patient-level elements -->
	<xsl:apply-templates select="*[self::Alerts | self::Allergies | self::FamilyHistory | self::SocialHistory | self::PastHistory | self::Encounters | self::Guarantors]"/>

	<!-- Aggregate the encounter-level elements not included above -->
	<xsl:apply-templates select="Encounters"  mode="aggregate"/>
</xsl:template>

<!-- Aggregate Encounter-level data -->
<xsl:template match="Encounters" mode="aggregate">
	<xsl:if test="Encounter/Observations">
		<Observations>
			<xsl:apply-templates select="Encounter/Observations/Observation"/>
		</Observations>
	</xsl:if>
	<xsl:if test="Encounter/Problems">
		<Problems>
			<xsl:apply-templates select="Encounter/Problems/Problem"/>
		</Problems>
	</xsl:if>
	<xsl:if test="Encounter/PhysicalExams">
		<PhysicalExams>
			<xsl:apply-templates select="Encounter/PhysicalExams/PhysicalExam"/>
		</PhysicalExams>
	</xsl:if>
	<xsl:if test="Encounter/Procedures">
		<Procedures>
			<xsl:apply-templates select="Encounter/Procedures/Procedure"/>
		</Procedures>
	</xsl:if>
	<xsl:if test="Encounter/Diagnoses">
		<Diagnoses>
			<xsl:apply-templates select="Encounter/Diagnoses/Diagnosis"/>
		</Diagnoses>
	</xsl:if>
	<xsl:if test="Encounter/Documents">
		<Documents>
			<xsl:apply-templates select="Encounter/Documents/Document"/>
		</Documents>
	</xsl:if>

	<!-- Separate Vaccinations from Medications -->
	<xsl:variable name="medications" select="Encounter/Medications/Medication[not(OrderItem/OrderType = 'VXU')] | Encounter/Plan/Orders/Order[OrderItem/OrderType = 'MED']" /> 
	<xsl:if test="$medications">
		<Medications>
			<xsl:apply-templates select="$medications"/>
		</Medications>
	</xsl:if>
	<xsl:variable name="vaccinations" select="Encounter/Medications/Medication[OrderItem/OrderType = 'VXU'] | Encounter/Plan/Orders/Order[OrderItem/OrderType = 'VXU']" /> 
	<xsl:if test="$vaccinations">
		<Vaccinations>
			<xsl:apply-templates select="$vaccinations"/>
		</Vaccinations>
	</xsl:if>

	<!-- Transform a Results into an order with a result -->
	<xsl:variable name="radOrders" select="Encounter/Results/Result[InitiatingOrder/OrderItem/OrderType = 'RAD'] | Encounter/Plan/Orders/Order[OrderItem/OrderType = 'RAD']" /> 
	<xsl:variable name="otherOrders" select="Encounter/Results/Result[InitiatingOrder/OrderItem/OrderType = 'OTH'] | Encounter/Plan/Orders/Order[OrderItem/OrderType = 'OTH']" /> 
	<xsl:variable name="labOrders" select="Encounter/Results/LabResult | Encounter/Results/Result[InitiatingOrder/OrderItem/OrderType = 'LAB'] | Encounter/Plan/Orders/Order[OrderItem/OrderType = 'LAB']"/> 
	<xsl:if test="$radOrders">
		<RadOrders>
			<xsl:apply-templates select="$radOrders"/>
		</RadOrders>
	</xsl:if>
	<xsl:if test="$otherOrders">
		<OtherOrders>
			<xsl:apply-templates select="$otherOrders"/>
		</OtherOrders>
	</xsl:if>
	<xsl:if test="$labOrders">
		<LabOrders>
			<xsl:apply-templates select="$labOrders"/>
		</LabOrders>
	</xsl:if>
</xsl:template>

<!-- Copy elements that go directly under Encounter -->
<xsl:template match="Encounter">
	<xsl:copy>
		<!-- this computed property needs to be manually set here -->
		<EndTime>
			<xsl:choose>
				<xsl:when test="string-length(EndTime)=0">
					<xsl:if test="not(EncounterType = 'I')"><xsl:value-of  select="StartTime"/></xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="EndTime"/>
				</xsl:otherwise>
			</xsl:choose>
		</EndTime>
		<xsl:apply-templates select="*[not(self::Observations | self::PhysicalExams | self::Medications | self::Problems | self::Procedures | self::Diagnoses | self::Documents | self::Results)]"/>
	</xsl:copy>
</xsl:template>

<!-- Flatten HealthFund -->
<xsl:template match="HealthFunds/HealthFund">
	<xsl:copy>
		<!-- First check for HealthFundPlan (which should have a HealthFund) -->
		<!-- If none then check for HealthFund -->
		<xsl:choose>
			<xsl:when test="HealthFundPlan">
				<xsl:copy-of select="HealthFundPlan/HealthFund"/>
				<HealthFundPlan>
					<xsl:apply-templates select="HealthFundPlan/*"/>
				</HealthFundPlan>
			</xsl:when>
			<xsl:when test="HealthFund">
				<xsl:copy-of select="HealthFund"/>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>
<!-- "No op" - These should not get copied, they are handled in the template above -->
<xsl:template match="HealthFund/HealthFund | HealthFund/HealthFundPlan | HealthFund/HealthFundPlan/HealthFund"/>

<!-- Add Encounter Number to aggregated items pulled from encounters -->
<xsl:template match ="Observation | Document | /Container/Patients/Patient/Encounters/Encounter/Problems/Problem | /Container/Patients/Patient/Encounters/Encounter/Procedures/Procedure | /Container/Patients/Patient/Encounters/Encounter/Diagnoses/Diagnosis">
	<xsl:copy>
		<xsl:call-template name="EncounterNumber">
			<xsl:with-param name="encNum" select="../../VisitNumber"/>
		</xsl:call-template>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<xsl:template match ="Medication">
	<xsl:variable name="orderType">
		<xsl:choose>
			<xsl:when test = "DrugProduct/OrderType"><xsl:value-of select="DrugProduct/OrderType"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="OrderItem/OrderType"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="orderElement">
		<xsl:call-template name="OrderElement">
			<xsl:with-param name="orderType" select="$orderType"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:element name="{$orderElement}">
		<xsl:call-template name="EncounterNumber">
			<xsl:with-param name="encNum" select="../../VisitNumber"/>
		</xsl:call-template>
		<!-- Move OrderCategory up one level if present.
		     If both DrugProduct and OrderItem have an OrderCategory, merge them. -->
		<xsl:choose>
			<xsl:when test = "DrugProduct/OrderCategory and OrderItem/OrderCategory">
				<xsl:call-template name="MergeOrderCats">
					<xsl:with-param name="orderCat1" select="DrugProduct/OrderCategory"/>
					<xsl:with-param name="orderCat2" select="OrderItem/OrderCategory"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test = "DrugProduct/OrderCategory">
				<OrderCategory>
					<xsl:apply-templates select="DrugProduct/OrderCategory/*"/>
				</OrderCategory>
			</xsl:when>
			<xsl:when test = "OrderItem/OrderCategory">
				<OrderCategory>
					<xsl:apply-templates select="OrderItem/OrderCategory/*"/>
				</OrderCategory>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- Merge two order categories, with preference shown to the first one given -->
<xsl:template name="MergeOrderCats">
	<xsl:param name="orderCat1"/>
	<xsl:param name="orderCat2"/>
	<OrderCategory>
		<xsl:choose>
			<xsl:when test="$orderCat1/Code">
				<xsl:apply-templates select="$orderCat1/Code"/>
			</xsl:when>
			<xsl:when test="$orderCat2/Code">
				<xsl:apply-templates select="$orderCat2/Code"/>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="$orderCat1/Description">
				<xsl:apply-templates select="$orderCat1/Description"/>
			</xsl:when>
			<xsl:when test="$orderCat2/Description">
				<xsl:apply-templates select="$orderCat2/Description"/>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="$orderCat1/SDACodingStandard">
				<xsl:apply-templates select="$orderCat1/SDACodingStandard"/>
			</xsl:when>
			<xsl:when test="$orderCat2/SDACodingStandard">
				<xsl:apply-templates select="$orderCat2/SDACodingStandard"/>
			</xsl:when>
		</xsl:choose>
	</OrderCategory>
</xsl:template>

<!-- Move results under their initiating order, and add Encounter Number -->
<xsl:template match ="Result | LabResult">
	<xsl:variable name="orderElement">
		<xsl:call-template name="OrderElement">
			<xsl:with-param name="orderType" select="InitiatingOrder/OrderItem/OrderType"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:element name="{$orderElement}">
		<xsl:call-template name="EncounterNumber">
			<xsl:with-param name="encNum" select="../../VisitNumber"/>
		</xsl:call-template>
		<xsl:apply-templates select="InitiatingOrder"/>
		<Result>
			<xsl:apply-templates select="*[not(self::InitiatingOrder)]"/>
		</Result>
	</xsl:element>
</xsl:template>

<!-- Put planned order under the appropriate order type, and add Encounter Number -->
<xsl:template match ="Order">
	<xsl:variable name="orderElement">
		<xsl:call-template name="OrderElement">
			<xsl:with-param name="orderType" select="OrderItem/OrderType"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:element name="{$orderElement}">
		<xsl:call-template name="EncounterNumber">
			<xsl:with-param name="encNum" select="../../../VisitNumber"/>
		</xsl:call-template>
		<!-- Move OrderCategory up one level if present.
		     If both DrugProduct and OrderItem have an OrderCategory, merge them. -->
		<xsl:choose>
			<xsl:when test = "DrugProduct/OrderCategory and OrderItem/OrderCategory">
				<xsl:call-template name="MergeOrderCats">
					<xsl:with-param name="orderCat1" select="DrugProduct/OrderCategory"/>
					<xsl:with-param name="orderCat2" select="OrderItem/OrderCategory"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test = "DrugProduct/OrderCategory">
				<OrderCategory>
					<xsl:apply-templates select="DrugProduct/OrderCategory/*"/>
				</OrderCategory>
			</xsl:when>
			<xsl:when test = "OrderItem/OrderCategory">
				<OrderCategory>
					<xsl:apply-templates select="OrderItem/OrderCategory/*"/>
				</OrderCategory>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<!-- Determine the order element based on the order type-->
<xsl:template name="OrderElement">
	<xsl:param name="orderType"/>
	<xsl:choose>
		<xsl:when test="$orderType = 'RAD'">RadOrder</xsl:when>
		<xsl:when test="$orderType = 'OTH'">OtherOrder</xsl:when>
		<xsl:when test="$orderType = 'MED'">Medication</xsl:when>
		<xsl:when test="$orderType = 'VXU'">Vaccination</xsl:when>
		<xsl:otherwise>LabOrder</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Don't copy outer Order element for Results (to flatten it into the RadOrder, LabOrder, or OtherOrder)-->
<xsl:template match = "InitiatingOrder">
		<!-- Move OrderCategory up one level if present -->
		<xsl:if test = "OrderItem/OrderCategory">
			<OrderCategory>
				<xsl:apply-templates select="OrderItem/OrderCategory/*"/>
			</OrderCategory>
		</xsl:if>
		<xsl:apply-templates/>
</xsl:template>

<!-- "No op" - OrderCategory should not get copied; the various templates for orders move it up a level in the SDA -->
<xsl:template match="OrderCategory" />

<!-- Separate Advance Directives from Alerts-->
<xsl:template match="/Container/Patients/Patient/Alerts">
	<xsl:variable name="numAlerts" select="count(Alert)"/>
	<xsl:variable name="numADs" select="count(Alert[contains($advanceDirectiveTypeCodes, concat('|', AlertType/Code/text(), '|'))])"/>
  	<xsl:if test="$numADs > 0">
		<AdvanceDirectives>
			<xsl:for-each select="Alert">
				<xsl:if test="contains($advanceDirectiveTypeCodes, concat('|', AlertType/Code/text(), '|'))">
					<xsl:apply-templates select="." mode="AdvanceDirective"/>
				</xsl:if>
			</xsl:for-each>
		</AdvanceDirectives>
	</xsl:if>
	<xsl:if test="$numAlerts > $numADs">
		<Alerts>
			<xsl:for-each select="Alert">
				<xsl:if test="not(contains($advanceDirectiveTypeCodes, concat('|', AlertType/Code/text(), '|')))">
					<xsl:apply-templates select="."/>
				</xsl:if>
			</xsl:for-each>
		</Alerts>
	</xsl:if>
</xsl:template>
<xsl:template match="Alert" mode="AdvanceDirective">
	<AdvanceDirective><xsl:apply-templates/></AdvanceDirective>
</xsl:template>

<!--  ******************************************************
       Change singular to plural and other modifications
      ******************************************************-->
<xsl:template match="/Container/Patients/Patient/PatientNumber">
	<PatientNumbers>
		<xsl:apply-templates/>
	</PatientNumbers>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/PriorPatientNumber">
	<PriorPatientNumbers>
		<xsl:apply-templates/>
	</PriorPatientNumbers>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/Address">
	<Addresses>
		<xsl:apply-templates/>
	</Addresses>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/Alias">
	<Aliases>
		<xsl:apply-templates/>
	</Aliases>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/FamilyHistory">
	<FamilyHistories>
			<xsl:apply-templates/>
	</FamilyHistories>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/SocialHistory">
	<SocialHistories>
		<xsl:apply-templates/>
	</SocialHistories>
</xsl:template>

<!-- Flatten SocialHistory -->
<xsl:template match="/Container/Patients/Patient/SocialHistory/SocialHistory">
	<xsl:copy>
		<!-- First check for SocialHabitQty (which should have a SocialHabit) -->
		<!-- If none then check for SocialHabit -->
		<xsl:choose>
			<xsl:when test="SocialHabitQty">
				<xsl:copy-of select="SocialHabitQty/SocialHabit"/>
				<SocialHabitQty>
					<xsl:apply-templates select="SocialHabitQty/*"/>
				</SocialHabitQty>
			</xsl:when>
			<xsl:when test="SocialHabit">
				<xsl:copy-of select="SocialHabit"/>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>
<!-- "No op" - These should not get copied, they are handled in the template above -->
<xsl:template match="SocialHabit | SocialHabitQty"/>

<xsl:template match="/Container/Patients/Patient/PastHistory">
	<IllnessHistories>
		<xsl:apply-templates/>
	</IllnessHistories>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/PastHistory/PastHistory">
	<IllnessHistory>
		<xsl:apply-templates/>
	</IllnessHistory>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/NextOfKin">
	<SupportContacts>
		<xsl:apply-templates/>
	</SupportContacts>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/NextOfKin/NextOfKin">
	<SupportContact>
		<xsl:apply-templates/>
	</SupportContact>
</xsl:template>

<xsl:template match="/Container/Patients/Patient/Allergies/Allergies">
    <Allergy>
		<!-- Move AllergyCategory up one level, OR change AllergyType to AllergyCategory -->
		<xsl:choose>
			<xsl:when test="./Allergy/AllergyCategory">
				<xsl:copy-of select="./Allergy/AllergyCategory"/>
			</xsl:when>
			<xsl:when test="./AllergyType">
				<AllergyCategory>
					<xsl:apply-templates select="./AllergyType/*"/>
				</AllergyCategory>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates />
    </Allergy>
</xsl:template>
<!-- "No op" - These should not get copied, they are handled in the template above -->
<xsl:template match="AllergyCategory | AllergyType"/>
  
<!--  Flatten PhysicalExam -->
<xsl:template match="PhysicalExam">
	<PhysicalExam>
		<xsl:call-template name="EncounterNumber">
			<xsl:with-param name="encNum" select="../../VisitNumber"/>
		</xsl:call-template>
		<!-- For PhysExamCode, PhysExamObs, and PhysExamObsQualifier: -->
		<!-- First check for PhysExamObsQualifier (which should have a PhysExamObs, which should have a PhysExam) -->
		<!-- If none then check for PhysExamObs (which should have a PhysExam) -->
		<!-- If none then check for PhysExamCode -->
		<xsl:choose>
			<xsl:when test="PhysExamObsQualifier">
				<PhysExamCode>
					<xsl:apply-templates select="PhysExamObsQualifier/PhysExamObs/PhysExam/*"/>
				</PhysExamCode>
				<PhysExamObs>
					<xsl:apply-templates select="PhysExamObsQualifier/PhysExamObs/*"/>
				</PhysExamObs>
				<PhysExamObsQualifier>
					<xsl:apply-templates select="PhysExamObsQualifier/*"/>
				</PhysExamObsQualifier>
			</xsl:when>
			<xsl:when test="PhysExamObs">
				<PhysExamCode>
					<xsl:apply-templates select="PhysExamObs/PhysExam/*"/>
				</PhysExamCode>
				<PhysExamObs>
					<xsl:apply-templates select="PhysExamObs/*"/>
				</PhysExamObs>
			</xsl:when>
			<xsl:when test="PhysExamCode">
				<xsl:copy-of select="PhysExamCode"/>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates/>
	</PhysicalExam>
</xsl:template>
<!-- "No op" - These should not get copied, they are handled in the template above -->
<xsl:template match="PhysExam | PhysExamCode | PhysExamObs | PhysExamObsQualifier"/>

<!--  Standardize date/time elements -->
<xsl:template match="StartDate | StartTime | EffectiveDate">
	<FromTime><xsl:value-of select="."/></FromTime>
</xsl:template>
<xsl:template match="EndDate | EndTime | ExpirationDate">
	<ToTime><xsl:value-of select="."/></ToTime>
</xsl:template>

<!--  Change VisitNumber-->
<xsl:template match="VisitNumber">
	<xsl:call-template name="EncounterNumber">
		<xsl:with-param name="encNum" select="."/>
	</xsl:call-template>
</xsl:template>

<!-- Change LinkedEncounterNumber-->
<xsl:template match="LinkedEncounterNumber">
	<AssociatedEncounter><xsl:value-of select="."/></AssociatedEncounter>
</xsl:template>

<!--  Change HL7ResultType -->
<xsl:template match="HL7ResultType">
	<ResultType><xsl:value-of select="."/></ResultType>
</xsl:template>

<!-- Remove obsolete elements, -->
<xsl:template match="Plan | AdvanceDirective | OrderType">
</xsl:template>

<!-- Copy additional info -->
<xsl:template match="AdditionalInfo">
	<xsl:copy-of select = "."/>
</xsl:template>

<!-- Add encounter number  -->
<xsl:template name="EncounterNumber">
	<xsl:param name="encNum"/>
	<xsl:if test="$encNum">
		<EncounterNumber>
			<xsl:value-of select="$encNum"/>
		</EncounterNumber>
	</xsl:if>
</xsl:template>

<!-- For Observations and Orders, map SDA2 ExternalId to SDA3 GroupId -->
<xsl:template match="Observation/ExternalId | Medication/ExternalId | Order/ExternalId | InitiatingOrder/ExternalId">
<GroupId><xsl:value-of select="."/></GroupId>
</xsl:template>

<!-- Identity template to copy all elements not explicitly mentioned-->
<xsl:template match="@*|node()">
	<xsl:if test="local-name()!='EId'">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:if>
</xsl:template>
	
</xsl:stylesheet>