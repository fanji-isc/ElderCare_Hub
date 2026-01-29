<?xml version="1.0"?>
<!-- Convert from SDA3 to SDA2 -->
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com"
				exclude-result-prefixes="xsi isc"
				version="1.0">
<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>

<!-- Keys to put encounter-level fields under the correct encounter -->
<xsl:key name="EncNum" match="Observations/Observation" use="concat('OBS','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="Problems/Problem" use="concat('PROB','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="Diagnoses/Diagnosis" use="concat('DIAG','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="PhysicalExams/PhysicalExam" use="concat('PHYS','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="Procedures/Procedure" use="concat('PROC','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="Documents/Document" use="concat('DOC','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="Medications/Medication" use="concat('MED','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="Vaccinations/Vaccination" use="concat('MED','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="RadOrder[Result]" use="concat('RES','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="LabOrder[Result]" use="concat('RES','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="OtherOrder[Result]" use="concat('RES','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="RadOrder[not(Result)]" use="concat('PLAN','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="LabOrder[not(Result)]" use="concat('PLAN','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="OtherOrder[not(Result)]" use="concat('PLAN','_',EncounterNumber)" /> 
<xsl:key name="EncNum" match="Encounter" use="concat('ENC','_',EncounterNumber)" /> 

<!-- Keys for elements with no encounters, to be moved under the silent encounter -->
<xsl:key name="EncNum" match="Observations/Observation[string-length(EncounterNumber) = 0]" use="'OBS_S'" /> 
<xsl:key name="EncNum" match="Problems/Problem[string-length(EncounterNumber) = 0]" use="'PROB_S'" /> 
<xsl:key name="EncNum" match="Diagnoses/Diagnosis[string-length(EncounterNumber) = 0]" use="'DIAG_S'" /> 
<xsl:key name="EncNum" match="PhysicalExams/PhysicalExam[string-length(EncounterNumber) = 0]" use="'PHYS_S'" /> 
<xsl:key name="EncNum" match="Procedures/Procedure[string-length(EncounterNumber) = 0]" use="'PROC_S'" /> 
<xsl:key name="EncNum" match="Documents/Document[string-length(EncounterNumber) = 0]" use="'DOC_S'" /> 
<xsl:key name="EncNum" match="Medications/Medication[string-length(EncounterNumber) = 0]" use="'MED_S'" /> 
<xsl:key name="EncNum" match="Vaccinations/Vaccination[string-length(EncounterNumber) = 0]" use="'MED_S'" /> 
<xsl:key name="EncNum" match="RadOrder[Result and string-length(EncounterNumber) = 0]" use="'RES_S'" /> 
<xsl:key name="EncNum" match="LabOrder[Result and string-length(EncounterNumber) = 0]" use="'RES_S'" /> 
<xsl:key name="EncNum" match="OtherOrder[Result and string-length(EncounterNumber) = 0]" use="'RES_S'" /> 
<xsl:key name="EncNum" match="RadOrder[not(Result) and string-length(EncounterNumber) = 0]" use="'PLAN_S'" /> 
<xsl:key name="EncNum" match="LabOrder[not(Result) and string-length(EncounterNumber) = 0]" use="'PLAN_S'" /> 
<xsl:key name="EncNum" match="OtherOrder[not(Result) and string-length(EncounterNumber) = 0]" use="'PLAN_S'"/> 
<xsl:key name="EncNum" match="Patient" use="'Dummy'"/> 

<!-- Move patient-level fields from the Container to the Patient -->
<xsl:template match="/Container">
	<xsl:copy>
		<xsl:apply-templates select="*[self::SessionId | self::ControlId | self::Action | self::EventDescription | self::UpdateECRDemographics | self::SendingFacility | self::AdditionalInfo]"/>
		<Patients>
			<Patient>
				<xsl:apply-templates select="*[self::Patient | self::Allergies | self::FamilyHistories | self::SocialHistories | self::IllnessHistories | self::Encounters | self::Guarantors]"/>
				<!-- Advance directives are considered alerts-->
				<xsl:if test = "Alerts | AdvanceDirectives">
					<Alerts>
							<xsl:for-each select="Alerts/Alert | AdvanceDirectives/AdvanceDirective">
								<xsl:apply-templates select="."/>
							</xsl:for-each>
					</Alerts>
				</xsl:if>

				<!-- Possibly create a silent encounter  when there are no other encounters-->
				<xsl:if test="not(Encounters)">
					<Encounters>
						<xsl:call-template name="SilentEncounter"/>
					</Encounters>
				</xsl:if>
			</Patient>
		</Patients>
	</xsl:copy>
</xsl:template>

<!--Don't copy the Patient node itself, as it's manually inserted above, to allow for inclusion of other SDA3 Container-level patient data -->
<xsl:template match="Patient">
		<xsl:apply-templates/>
</xsl:template>

<!-- Possibly add a silent encounter to an existing collection of encounters -->
<xsl:template match="Encounters">
	<xsl:copy>
		<xsl:apply-templates/>
		<xsl:call-template name="SilentEncounter"/>
	</xsl:copy>
</xsl:template>

<!-- Move encounter-level data from the Container to the appropriate encounter -->
<xsl:template match="Encounter">
	<xsl:copy>
		<xsl:apply-templates/>
		<xsl:call-template name="MoveUnderEncounter">
			<xsl:with-param name="encNum" select="EncounterNumber"/>
		</xsl:call-template>
	</xsl:copy>
</xsl:template>

<!-- Move encounter-level data from the Container to the appropriate encounter -->
<xsl:template name="MoveUnderEncounter">
	<xsl:param name="encNum"/>
		<xsl:call-template name="MoveToEncounter">
			<xsl:with-param name= "group" select="'Observations'"/>
			<xsl:with-param name="key" select="concat('OBS','_',$encNum)"/>
		</xsl:call-template>
		<xsl:call-template name="MoveToEncounter">
			<xsl:with-param name= "group" select="'Problems'"/>
			<xsl:with-param name="key" select="concat('PROB','_',$encNum)"/>
		</xsl:call-template>
		<xsl:call-template name="MoveToEncounter">
			<xsl:with-param name= "group" select="'Diagnoses'"/>
			<xsl:with-param name="key" select="concat('DIAG','_',$encNum)"/>
		</xsl:call-template>
		<xsl:call-template name="MoveToEncounter">
			<xsl:with-param name= "group" select="'PhysicalExams'"/>
			<xsl:with-param name="key" select="concat('PHYS','_',$encNum)"/>
		</xsl:call-template>
		<xsl:call-template name="MoveToEncounter">
			<xsl:with-param name= "group" select="'Documents'"/>
			<xsl:with-param name="key" select="concat('DOC','_',$encNum)"/>
		</xsl:call-template>
		<xsl:call-template name="MoveToEncounter">
			<xsl:with-param name= "group" select="'Procedures'"/>
			<xsl:with-param name="key" select="concat('PROC','_',$encNum)"/>
		</xsl:call-template>
		<xsl:call-template name="MoveToEncounter">
			<xsl:with-param name= "group" select="'Medications'"/>
			<xsl:with-param name="key" select="concat('MED','_',$encNum)"/>
		</xsl:call-template>
		<xsl:call-template name="MoveToEncounter">
			<xsl:with-param name= "group" select="'Results'"/>
			<xsl:with-param name="key" select="concat('RES','_',$encNum)"/>
		</xsl:call-template>
		<xsl:if test="count(key('EncNum',concat('PLAN','_',$encNum)))>0">
			<Plan>
				<xsl:call-template name="MoveToEncounter">
					<xsl:with-param name= "group" select="'Orders'"/>
					<xsl:with-param name="key" select="concat('PLAN','_',$encNum)"/>
				</xsl:call-template>
			</Plan>
		</xsl:if>
</xsl:template>

<!-- Move a data group from the Container to the appropriate encounter -->
<xsl:template name="MoveToEncounter">
	<xsl:param name="group"/>
	<xsl:param name="key"/>
	<xsl:if test="count(key('EncNum',$key))>0">
		<xsl:element name="{$group}">
			<xsl:for-each select="key('EncNum', $key)">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- Retain Encounter Number as Visit Number, but only for the Encounter itself-->
<xsl:template match="Encounter/EncounterNumber">
	<VisitNumber><xsl:value-of select="."/></VisitNumber>
</xsl:template>
<xsl:template match="EncounterNumber">
</xsl:template>

<!-- Possibly create a silent encounter when there is encounter-level data with no encounter number, and move the data under it -->
<xsl:template name="SilentEncounter">
	<xsl:variable name="dataType">
		<xsl:choose>
			<xsl:when test="count(key('EncNum','OBS_S'))>0">OBS</xsl:when>
			<xsl:when test="count(key('EncNum','PROB_S'))>0">PROB</xsl:when>
			<xsl:when test="count(key('EncNum','DIAG_S'))>0">DIAG</xsl:when>
			<xsl:when test="count(key('EncNum','PHYS_S'))>0">PHYS</xsl:when>
			<xsl:when test="count(key('EncNum','PROC_S'))>0">PROC</xsl:when>
			<xsl:when test="count(key('EncNum','DOC_S'))>0">DOC</xsl:when>
			<xsl:when test="count(key('EncNum','MED_S'))>0">MED</xsl:when>
			<xsl:when test="count(key('EncNum','RES_S'))>0">RES</xsl:when>
			<xsl:when test="count(key('EncNum','PLAN_S'))>0">PLAN</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="string-length($dataType)>0">
		<xsl:apply-templates select="key('EncNum', concat($dataType,'_S'))[1]" mode="CreateSilentEncounter"/>
	</xsl:if>
</xsl:template>

<!-- Create a silent encounter with data from the first element with no encounter, copying all other such data under it -->
<xsl:template match="*" mode="CreateSilentEncounter">
	<Encounter>
		<VisitNumber><xsl:value-of select="isc:evaluate('generateVisitNumber')"/></VisitNumber>
		<EncounterType>S</EncounterType>
		<StartTime><xsl:value-of select="FromTime | ObservationTime | IdentificationTime | PhysExamTime | ProcedureTime | DocumentTime | SpecimenReceivedTime"/></StartTime>
		<xsl:copy-of select="EnteredAt"/>
		<xsl:copy-of select="EnteredOn"/>
		<xsl:copy-of select="EnteredBy"/>
		<xsl:call-template name="MoveUnderEncounter">
			<xsl:with-param name="encNum" select="'S'"/>
		</xsl:call-template>
	</Encounter>
</xsl:template>

<!-- Nest HealthFund into HealthFundPlan, if present -->
<xsl:template match="HealthFunds/HealthFund">
	<xsl:copy>
		<xsl:choose>
			<xsl:when test="HealthFundPlan">
				<HealthFundPlan>
					<xsl:copy-of select="HealthFundPlan/*"/>
					<xsl:copy-of select="HealthFund"/>
				</HealthFundPlan>
			</xsl:when>
			<xsl:when test="HealthFund">
				<xsl:copy-of select="HealthFund"/>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="*[not(self::HealthFund | self::HealthFundPlan)]" />
	</xsl:copy>
</xsl:template>

<!-- Change Vaccination to Medication-->
<xsl:template match="Vaccination | Medication">
	<Medication>
		<xsl:apply-templates select="*[not(self::GroupId | self::ExternalId)]"/>
		<xsl:choose>
			<xsl:when test="GroupId">
				<ExternalId><xsl:value-of select="GroupId"/></ExternalId>
			</xsl:when>
			<xsl:when test="ExternalId">
				<ExternalId><xsl:value-of select="ExternalId"/></ExternalId>
			</xsl:when>
		</xsl:choose>
	</Medication>
</xsl:template>

<!-- Move order data to Initiating Order under results -->
<xsl:template match="RadOrder | OtherOrder | LabOrder">
	<xsl:choose>
		<xsl:when test="Result">
			<xsl:variable name="resultElement">
				<xsl:choose>
					<xsl:when test="Result/ResultItems">LabResult</xsl:when>
					<xsl:otherwise>Result</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:element name="{$resultElement}">
				<InitiatingOrder>
					<xsl:apply-templates select="*[not(self::Result | self::GroupId | self::ExternalId)]"/>
					<xsl:choose>
						<xsl:when test="GroupId">
							<ExternalId><xsl:value-of select="GroupId"/></ExternalId>
						</xsl:when>
						<xsl:when test="ExternalId">
							<ExternalId><xsl:value-of select="ExternalId"/></ExternalId>
						</xsl:when>
					</xsl:choose>
				</InitiatingOrder>
				<xsl:apply-templates select="Result"/>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<Order>
				<xsl:apply-templates select="*[not(self::GroupId | self::ExternalId)]"/>
				<xsl:choose>
					<xsl:when test="GroupId">
						<ExternalId><xsl:value-of select="GroupId"/></ExternalId>
					</xsl:when>
					<xsl:when test="ExternalId">
						<ExternalId><xsl:value-of select="ExternalId"/></ExternalId>
					</xsl:when>
				</xsl:choose>
			</Order>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Don't include parent element (already inserted above) -->
<xsl:template match = "Result">
		<xsl:apply-templates/>
</xsl:template>

<!-- "No op" - Do not copy OrderCategory, it is handled in the DrugProduct and OrderItem template -->
<xsl:template match = "OrderCategory"/>

<!-- For DrugProduct and OrderItem, move OrderCategory down from parent and put OrderType back in -->
<xsl:template match = "DrugProduct | OrderItem">
	<xsl:copy>
		<xsl:variable name="orderType">
			<xsl:call-template name="GetOrderType">
				<xsl:with-param name="parentElt" select="name(..)"/>
			</xsl:call-template>
		</xsl:variable>
		
		<OrderType><xsl:value-of select="$orderType"/></OrderType>
		<xsl:if test="../OrderCategory">
			<OrderCategory>
				<xsl:copy-of select="../OrderCategory/*"/>
				<OrderType><xsl:value-of select="$orderType"/></OrderType>
			</OrderCategory>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<xsl:template name="GetOrderType">
	<xsl:param name="parentElt"/>
	<xsl:choose>
		<xsl:when test="$parentElt = 'RadOrder'">RAD</xsl:when>
		<xsl:when test="$parentElt = 'OtherOrder'">OTH</xsl:when>
		<xsl:when test="$parentElt = 'Medication'">MED</xsl:when>
		<xsl:when test="$parentElt = 'ComponentMeds'">MED</xsl:when>
		<xsl:when test="$parentElt = 'Vaccination'">VXU</xsl:when>
		<xsl:otherwise>LAB</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ******************************************************
       Change plural to singluar and other modifications
       ******************************************************-->
<xsl:template match="AdvanceDirective">
	<Alert>
		<xsl:apply-templates/>
	</Alert>
</xsl:template>

<xsl:template match="PatientNumbers">
	<PatientNumber>
		<xsl:apply-templates/>
	</PatientNumber>
</xsl:template>

<xsl:template match="PriorPatientNumbers">
	<PriorPatientNumber>
		<xsl:apply-templates/>
	</PriorPatientNumber>
</xsl:template>

<xsl:template match="Addresses">
	<Address>
		<xsl:apply-templates/>
	</Address>
</xsl:template>

<xsl:template match="Aliases">
	<Alias>
		<xsl:apply-templates/>
	</Alias>
</xsl:template>

<xsl:template match="FamilyHistories">
	<FamilyHistory>
			<xsl:apply-templates/>
	</FamilyHistory>
</xsl:template>

<xsl:template match="SocialHistories">
	<SocialHistory>
		<xsl:apply-templates/>
	</SocialHistory>
</xsl:template>

<!-- Nest SocialHabit into SocialHabitQty, if present -->
<xsl:template match="SocialHistory">
	<xsl:copy>
		<xsl:choose>
			<xsl:when test="SocialHabitQty">
				<SocialHabitQty>
					<xsl:copy-of select="SocialHabitQty/*"/>
					<xsl:copy-of select="SocialHabit"/>
				</SocialHabitQty>
			</xsl:when>
			<xsl:when test="SocialHabit">
				<xsl:copy-of select="SocialHabit"/>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="*[not(self::SocialHabit | self::SocialHabitQty)]" />
	</xsl:copy>
</xsl:template>

<xsl:template match="IllnessHistories">
	<PastHistory>
		<xsl:apply-templates/>
	</PastHistory>
</xsl:template>

<xsl:template match="IllnessHistory">
	<PastHistory>
		<!-- If present, change AssociatedEncounter or EncounterNumber to LinkedEncounterNumber -->
		<xsl:choose>
			<xsl:when test="./AssociatedEncounter">
				<LinkedEncounterNumber><xsl:value-of select="./AssociatedEncounter"/></LinkedEncounterNumber>
			</xsl:when>
			<xsl:when test="./EncounterNumber">
				<LinkedEncounterNumber><xsl:value-of select="./EncounterNumber"/></LinkedEncounterNumber>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="*[not(self::AssociatedEncounter)]"/>
	</PastHistory>
</xsl:template>

<xsl:template match="SupportContacts | SupportContact">
	<NextOfKin>
		<xsl:apply-templates/>
	</NextOfKin>
</xsl:template>

<xsl:template match="/Container/Allergies/Allergy">
	<Allergies>
		<!-- If present, move AllergyCategory down one level -->
		<xsl:choose>
			<xsl:when test="./AllergyCategory">
				<Allergy>
					<xsl:copy-of select="./Allergy/*"/>
					<xsl:copy-of select="./AllergyCategory"/>
				</Allergy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="./Allergy"/>
			</xsl:otherwise>
		</xsl:choose>
		<!-- If present, change AssociatedEncounter or EncounterNumber to LinkedEncounterNumber -->
		<xsl:choose>
			<xsl:when test="./AssociatedEncounter">
				<LinkedEncounterNumber><xsl:value-of select="./AssociatedEncounter"/></LinkedEncounterNumber>
			</xsl:when>
			<xsl:when test="./EncounterNumber">
				<LinkedEncounterNumber><xsl:value-of select="./EncounterNumber"/></LinkedEncounterNumber>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="*[not(self::AllergyCategory | self::Allergy | self::AssociatedEncounter)]" />
	</Allergies>
</xsl:template>

<!-- Nest PhysExam, PhysExamObs, and PhysExamObsQualifier elements -->
<xsl:template match="PhysicalExam">
	<xsl:copy>
		<xsl:choose>
			<xsl:when test="PhysExamObsQualifier">
				<PhysExamObsQualifier>
					<xsl:copy-of select="PhysExamObsQualifier/*"/>
					<PhysExamObs>
						<xsl:copy-of select="PhysExamObs/*"/>
						<PhysExam>
							<xsl:copy-of select="PhysExamCode/*"/>
						</PhysExam>
					</PhysExamObs>
				</PhysExamObsQualifier>
			</xsl:when>
			<xsl:when test="PhysExamObs">
				<PhysExamObs>
					<xsl:copy-of select="PhysExamObs/*"/>
					<PhysExam>
						<xsl:copy-of select="PhysExamCode/*"/>
					</PhysExam>
				</PhysExamObs>
			</xsl:when>
			<xsl:when test="PhysExamCode">
				<xsl:copy-of select="PhysExamCode"/>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="*[not(self::PhysExamCode | self::PhysExamObs | self::PhysExamObsQualifier)]" />
	</xsl:copy>
</xsl:template>

<xsl:template match="ResultType">
	<HL7ResultType><xsl:value-of select="."/></HL7ResultType>
</xsl:template>

<xsl:template match="Observation">
	<xsl:copy>
		<xsl:apply-templates select="*[not(self::GroupId | self::ExternalId)]"/>
		<xsl:choose>
			<xsl:when test="GroupId">
				<ExternalId><xsl:value-of select="GroupId"/></ExternalId>
			</xsl:when>
			<xsl:when test="ExternalId">
				<ExternalId><xsl:value-of select="ExternalId"/></ExternalId>
			</xsl:when>
		</xsl:choose>
	</xsl:copy>
</xsl:template>

<!--  ***********************************
        Convert date/time elements 
        ***********************************-->
<xsl:template match="Address/FromTime | InsuredAddress/FromTime | Guarantor/FromTime">
	<StartDate><xsl:value-of select="."/></StartDate>
</xsl:template>
<xsl:template match="Address/ToTime | InsuredAddress/ToTime | Guarantor/ToTime">
	<EndDate><xsl:value-of select="."/></EndDate>
</xsl:template>

<xsl:template match="Encounter/FromTime | Administration/FromTime | DosageStep/FromTime | RadOrder/FromTime | LabOrder/FromTime | OtherOrder/FromTime | Organization/FromTime | Medication/FromTime | Vaccination/FromTime">
	<StartTime><xsl:value-of select="."/></StartTime>
</xsl:template>
<xsl:template match="Encounter/ToTime | Administration/ToTime | DosageStep/ToTime | RadOrder/ToTime | LabOrder/ToTime | OtherOrder/ToTime | Organization/ToTime | Medication/ToTime | Vaccination/ToTime">
	<EndTime><xsl:value-of select="."/></EndTime>
</xsl:template>
<!-- SDA3 Encounter EndTime does not get copied to SDA2 -->
<xsl:template match="Encounter/EndTime"/>

<xsl:template match="HealthFund/FromTime">
	<EffectiveDate><xsl:value-of select="."/></EffectiveDate>
</xsl:template>
<xsl:template match="HealthFund/ToTime">
	<ExpirationDate><xsl:value-of select="."/></ExpirationDate>
</xsl:template>

<!-- Remove non-backwards compatible elements, -->
<xsl:template match="CustomObjects | UpdatedOn">
</xsl:template>

<!-- Identity template to copy all elements not explicitly mentioned-->
<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>