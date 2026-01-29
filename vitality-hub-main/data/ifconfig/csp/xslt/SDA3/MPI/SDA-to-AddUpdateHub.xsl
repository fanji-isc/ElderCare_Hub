<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com"
				version="1.0">
	
	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
	<xsl:param name="legacyPatientIdentifiers"/>
	<xsl:key name="EncType" match="Encounter" use="EncounterType"/> 
	<xsl:key name="Clinician" match="OrderedBy" use="concat('ORD',Code,'_',SDACodingStandard)"/> 
	<xsl:key name="Clinician" match="ResultCopiesTo/CareProvider" use="concat('COP',Code,'_',SDACodingStandard)"/> 
	<xsl:key name="Clinician" match="AdmittingClinician" use="concat('ADM',Code,'_',SDACodingStandard)"/> 
	<xsl:key name="Clinician" match="AttendingClinicians/CareProvider" use="concat('ATT',Code,'_',SDACodingStandard)"/> 
	<xsl:key name="Clinician" match="ConsultingClinicians/CareProvider" use="concat('CON',Code,'_',SDACodingStandard)"/> 
	<xsl:key name="Clinician" match="FamilyDoctor" use="concat('PCP',Code,'_',SDACodingStandard)"/> 
	<xsl:key name="Clinician" match="ReferringClinician" use="concat('REF',Code,'_',SDACodingStandard)"/> 
	<xsl:template match="Container">
		<AddUpdateHubRequest>
		<Facility>
			<xsl:value-of select="SendingFacility"/>
		</Facility>
		<EventType>
		<xsl:variable name="eventType" select="substring(EventDescription,1,4)"/>
		<xsl:choose>
	  		<xsl:when test="$eventType='ADT_'">ADT</xsl:when>
	  		<xsl:when test="$eventType='ORM_'">ORD</xsl:when>
	  		<xsl:when test="$eventType='OMP_'">ORD</xsl:when>
	  		<xsl:when test="$eventType='VXU_'">ORD</xsl:when>
	  		<xsl:when test="$eventType='ORU_'">RES</xsl:when>
	  		<xsl:when test="$eventType='MDM_'">DOC</xsl:when>
	  		<xsl:when test="$eventType='REF_'">REF</xsl:when>
	  		<xsl:when test="$eventType='BAR_'">BAR</xsl:when>
			<xsl:when test="$eventType='SIU_'">SCH</xsl:when>
			<xsl:when test="$eventType='PPR_'">PRB</xsl:when>
			<xsl:when test="$eventType='RDE_'">ORD</xsl:when>
	  		<xsl:otherwise>
	  			<xsl:choose>
					<xsl:when test="RadOrders/RadOrder[Result] | OtherOrders/OtherOrder[Result] | LabOrders/LabOrder[Result]">RES</xsl:when>
					<xsl:when test="RadOrders/RadOrder[not(Result)] | OtherOrders/OtherOrder[not(Result)] | LabOrders/LabOrder[not(Result)]">ORD</xsl:when>
  					<xsl:when test="Medications | Vaccinations">ORD</xsl:when>
	  				<xsl:when test="Encounters">ADT</xsl:when>
	  				<xsl:when test="Documents">DOC</xsl:when>
	  				<xsl:otherwise>GEN</xsl:otherwise>
	  			</xsl:choose>
	  		</xsl:otherwise>
  		</xsl:choose>
		</EventType>
		<xsl:if test="EventDescription='ADT_A45' or EventDescription='ADT_A50'">
			<PriorEncounterNumber><xsl:value-of select="Encounters/Encounter/PriorVisitNumber"/></PriorEncounterNumber>
			<NewEncounterNumber><xsl:value-of select="Encounters/Encounter/EncounterNumber"/></NewEncounterNumber>
			<PriorEncounterMRN><xsl:value-of select="Patient/PriorPatientNumbers/PatientNumber[NumberType = 'MRN']/Number"/></PriorEncounterMRN>
			<PriorEncounterAA><xsl:value-of select="Patient/PriorPatientNumbers/PatientNumber[NumberType = 'MRN']/Organization/Code"/></PriorEncounterAA>
		</xsl:if>
		<MessageType>
		<xsl:variable name="msgType" select="substring(EventDescription,1,4)"/>
		<xsl:choose>
	  		<xsl:when test="$msgType='ADT_'">ADT</xsl:when>
	  		<xsl:when test="$msgType='ORM_'">ORD</xsl:when>
	  		<xsl:when test="$msgType='OMP_'">ORD</xsl:when>
	  		<xsl:when test="$msgType='VXU_'">VXU</xsl:when>
	  		<xsl:when test="$msgType='ORU_'">RES</xsl:when>
	  		<xsl:when test="$msgType='MDM_'">DOC</xsl:when>
	  		<xsl:when test="$msgType='REF_'">REF</xsl:when>
	  		<xsl:when test="$msgType='BAR_'">BAR</xsl:when>
			<xsl:when test="$msgType='SIU_'">SCH</xsl:when>
			<xsl:when test="$msgType='PPR_'">PRB</xsl:when>
			<xsl:when test="$msgType='RDE_'">ORD</xsl:when>
			<xsl:when test="EventDescription"><xsl:value-of select="substring-before(EventDescription,'_')"/></xsl:when>
	  		<xsl:otherwise>OTH</xsl:otherwise>
  		</xsl:choose>
		</MessageType>
		<xsl:apply-templates select="Patient" />
		<EncounterTypes>
			<xsl:apply-templates select="Encounters/Encounter" mode="EncounterTypes"/>
		</EncounterTypes>
		<IdentifiedClinicians>
			<xsl:apply-templates select="Encounters" mode="Clinicians"/>
			<xsl:apply-templates select="Patient/FamilyDoctor" mode="Clinicians"/>
			<xsl:apply-templates select="//OrderedBy"/>
			<xsl:apply-templates select="//ResultCopiesTo/CareProvider"/>
		</IdentifiedClinicians>
		<xsl:apply-templates select="AdditionalInfo" />
		<xsl:apply-templates select="Encounters" mode="EncounterInfo"/>
		</AddUpdateHubRequest>
	</xsl:template>
			
	<xsl:template match="AdditionalInfo">
		<xsl:copy-of select = "."/>
	</xsl:template>

	<xsl:template match="Patient">
		<xsl:if test="ActionCode='R'">
			<AddOrUpdate>F</AddOrUpdate>
		</xsl:if>
		<MPIID>
			<xsl:value-of select="MPIID"/>
		</MPIID>
		<MRN>
			<xsl:value-of select="PatientNumbers/PatientNumber[NumberType = 'MRN']/Number"/>
		</MRN>
		<AssigningAuthority>
			<xsl:value-of select="PatientNumbers/PatientNumber[NumberType = 'MRN']/Organization/Code"/>
		</AssigningAuthority>
		<FirstName>
			<xsl:value-of select="Name/GivenName"/>
		</FirstName>
		<MiddleName>
			<xsl:value-of select="Name/MiddleName"/>
		</MiddleName>
		<LastName>
			<xsl:value-of select="Name/FamilyName"/>
		</LastName>
		<Prefix>
			<xsl:value-of select="Name/NamePrefix"/>
		</Prefix>
		<Suffix>
			<xsl:value-of select="Name/NameSuffix"/>
		</Suffix>
		<Names>
			<xsl:for-each select='Aliases/Name'>
				<PersonName>
					<Given><xsl:value-of select="GivenName"/></Given>
					<Middle><xsl:value-of select="MiddleName"/></Middle>
					<Family><xsl:value-of select="FamilyName"/></Family>
					<Prefix><xsl:value-of select="NamePrefix"/></Prefix>
					<Suffix><xsl:value-of select="NameSuffix"/></Suffix>
					<Type><xsl:value-of select="Type"/></Type>
				</PersonName>
			</xsl:for-each>
		</Names>
 		<MothersMaidenSurname>
			<xsl:value-of select="MothersMaidenName"/>
		</MothersMaidenSurname>
		<Sex>
			<xsl:value-of select="Gender/Code"/>
		</Sex>
		<xsl:if test="string-length(Gender/Description)">
			<SexDescription>
				<xsl:value-of select="Gender/Description"/>
			</SexDescription>
		</xsl:if>
		<DOB>
			<xsl:value-of select="BirthTime"/>
		</DOB>
		<xsl:if test="string-length(BirthPlace)>0">
			<BirthPlace>
				<StreetLine><xsl:value-of select="BirthPlace/Street"/></StreetLine>
				<City><xsl:value-of select="BirthPlace/City/Code"/></City>
				<State><xsl:value-of select="BirthPlace/State/Code"/></State>
				<County><xsl:value-of select="BirthPlace/County/Code"/></County>
				<Country><xsl:value-of select="BirthPlace/Country/Code"/></Country>
				<PostalCode><xsl:value-of select="BirthPlace/Zip/Code"/></PostalCode>
			</BirthPlace>
		</xsl:if>
		<BirthOrder>
			<xsl:value-of select="BirthOrder"/>
		</BirthOrder>
		<Race>
			<xsl:choose>
				<xsl:when test="string-length(Race/Code)">
					<xsl:value-of select="Race/Code"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="Races/Race[1]/Code"/>
				</xsl:otherwise>
			</xsl:choose>
		</Race>
		<MaritalStatus>
			<xsl:value-of select="MaritalStatus/Code"/>
		</MaritalStatus>
		<ReligiousAffiliation>
			<xsl:value-of select="Religion/Code"/>
		</ReligiousAffiliation>
		<EthnicGroup>
			<xsl:value-of select="EthnicGroup/Code"/>
		</EthnicGroup>
		<Language>
			<xsl:value-of select="PrimaryLanguage/Code"/>
		</Language>
		<Street>
			<xsl:value-of select="Addresses/Address[1]/Street"/>
		</Street>
		<City>
			<xsl:value-of select="Addresses/Address[1]/City/Code"/>
		</City>
		<Zip>
			<xsl:value-of select="Addresses/Address[1]/Zip/Code"/>
		</Zip>
		<State>
			<xsl:value-of select="Addresses/Address[1]/State/Code"/>
		</State>
	    <County>
			<xsl:value-of select="Addresses/Address[1]/County/Code"/>
		</County>
		<Country>
			<xsl:value-of select="Addresses/Address[1]/Country/Code"/>
		</Country>
		<Telecoms>
			<xsl:if test="string-length(ContactInfo/HomePhoneNumber)">
				<Telecom>
					<PhoneNumber><xsl:value-of select="ContactInfo/HomePhoneNumber"/></PhoneNumber>
					<Use>H</Use>
					<Status>A</Status>
				</Telecom>
			</xsl:if>
			<xsl:if test="string-length(ContactInfo/WorkPhoneNumber)">
				<Telecom>
					<PhoneNumber><xsl:value-of select="ContactInfo/WorkPhoneNumber"/></PhoneNumber>
					<Use>WP</Use>
					<Status>A</Status>
				</Telecom>
			</xsl:if>
			<xsl:if test="string-length(ContactInfo/MobilePhoneNumber)">
				<Telecom>
					<PhoneNumber><xsl:value-of select="ContactInfo/MobilePhoneNumber"/></PhoneNumber>
					<Type>M</Type>
					<Use>MC</Use>
					<Status>A</Status>
				</Telecom>
			</xsl:if>
			<xsl:if test="string-length(ContactInfo/EmailAddress)">
				<Telecom>
					<Email><xsl:value-of select="ContactInfo/EmailAddress"/></Email>
					<Status>A</Status>
				</Telecom>
			</xsl:if>
		</Telecoms>
		<SSN>
			<xsl:value-of select="PatientNumbers/PatientNumber[NumberType = 'SSN']/Number"/>
		</SSN>
		<DeathStatus>
			<xsl:value-of select="IsDead"/>
		</DeathStatus>
		<DeathTime>
			<xsl:value-of select="DeathTime"/>
		</DeathTime>
		<CreatedBy>
			<xsl:value-of select="CreatedBy/Description"/>
		</CreatedBy>
		<CreatedOn>
			<xsl:value-of select="CreatedOn"/>
		</CreatedOn>
		<LastEnteredBy>
			<xsl:value-of select="EnteredBy/Description"/>
		</LastEnteredBy>
		<LastEnteredOn>
			<xsl:value-of select="EnteredOn"/>
		</LastEnteredOn>		
		<CommunicationPreference>
			<xsl:value-of select="CommunicationPreference"/>
		</CommunicationPreference>
		<xsl:if test="string-length(IsProtected)">
		<VIP>
			<xsl:value-of select="IsProtected"/>
		</VIP>
		</xsl:if>
		<Identifiers>
			<xsl:apply-templates select="PatientNumbers/PatientNumber"/>
			<xsl:apply-templates select="../Encounters" mode="HealthFunds"/>
		</Identifiers>
		<xsl:apply-templates select="SupportContacts/SupportContact"/>
		<xsl:copy-of select="Extension" />
		<xsl:copy-of select="CustomClassName" />
		<xsl:copy-of select="CustomXMLString" />
	</xsl:template>	
	
	<xsl:template match="Encounter" mode="EncounterTypes">
		<xsl:if test="generate-id(.)=generate-id(key('EncType',EncounterType)[1])"> 
			<EncounterTypesItem>
				<xsl:value-of select="EncounterType"/>
			</EncounterTypesItem>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="SupportContact">
		<xsl:variable name="Rel" select="Relationship/Code"/>
		<xsl:if test="$Rel='FTH'">
			<FathersName>
				<xsl:call-template name="SupportContact"/>	
			</FathersName>
		</xsl:if>
		<xsl:if test="$Rel='MTH'">
			<MothersName>
				<xsl:call-template name="SupportContact"/>	
			</MothersName>
		</xsl:if>
		<xsl:if test="$Rel='SPO'">
			<SpousesName>
				<xsl:call-template name="SupportContact"/>	
			</SpousesName>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="SupportContact">
		<Family>
			<xsl:value-of select="Name/FamilyName"/>
		</Family>
		<Given>
			<xsl:value-of select="Name/GivenName"/>
		</Given>
		<Middle>
			<xsl:value-of select="Name/MiddleName"/>
		</Middle>
	</xsl:template>

	<xsl:template match="PatientNumber">
		<xsl:choose>
			<xsl:when test="$legacyPatientIdentifiers=1">
				<xsl:if test="(NumberType = 'XX') or (NumberType = 'SN') or (NumberType = 'DL') or (NumberType = 'PPN')">
					<Identifier>
						<xsl:if test="string-length(Organization/Code) > 0" >
							<AssigningAuthorityName>
								<xsl:value-of select="Organization/Code"/>
							</AssigningAuthorityName>
						</xsl:if>
						<Extension>
							<xsl:value-of select="Number"/>
						</Extension>
						<Use>
							<xsl:value-of select="NumberType"/>
						</Use>
					</Identifier>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(NumberType = 'MRN') and not(NumberType = 'SSN')">
					<Identifier>
						<xsl:if test="string-length(Organization/Code) > 0" >
							<AssigningAuthorityName>
								<xsl:value-of select="Organization/Code"/>
							</AssigningAuthorityName>
						</xsl:if>
						<Extension>
							<xsl:value-of select="Number"/>
						</Extension>
						<Use>
							<xsl:value-of select="NumberType"/>
						</Use>
					</Identifier>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>

	<xsl:template match="Encounters" mode="HealthFunds">
		<xsl:for-each select="Encounter/HealthFunds/HealthFund[MembershipNumber!='']">
			<Identifier>
				<AssigningAuthorityName>
					<xsl:value-of select="HealthFundPlan/Code"/>
				</AssigningAuthorityName>
				<Extension>
					<xsl:value-of select="MembershipNumber"/>
				</Extension>
				<Use><xsl:text>SN</xsl:text></Use>
			</Identifier>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Encounters" mode="Clinicians">	
		<xsl:for-each select="Encounter">
			<xsl:apply-templates select="AttendingClinicians"/>
			<xsl:apply-templates select="ConsultingClinicians"/>
			<xsl:apply-templates select="ReferringClinician"/>
			<xsl:apply-templates select="AdmittingClinician"/>
		</xsl:for-each>
	</xsl:template>	
	
	<xsl:template match="Encounters" mode="EncounterInfo">
		<Encounters>
		<xsl:for-each select="Encounter">
		<xsl:if test="string-length(FromTime)">
			<AddUpdateHubEncounterInfo>
			<EncounterType><xsl:value-of select="EncounterType"/></EncounterType>
			<EncounterNumber><xsl:value-of select="EncounterNumber"/></EncounterNumber>
			<FromTime><xsl:value-of select="FromTime"/></FromTime>
			<xsl:if test="string-length(ToTime)">
				<ToTime><xsl:value-of select="ToTime"/></ToTime>
			</xsl:if>
			<IdentifiedClinicians>
				<xsl:apply-templates select="AttendingClinicians"/>
				<xsl:apply-templates select="ConsultingClinicians"/>
				<xsl:apply-templates select="ReferringClinician"/>
				<xsl:apply-templates select="AdmittingClinician"/>
			</IdentifiedClinicians>
			</AddUpdateHubEncounterInfo>
		</xsl:if>
		</xsl:for-each>
		</Encounters>
	</xsl:template>
	
	<xsl:template match="FamilyDoctor" mode="Clinicians">
		<xsl:call-template name="identifiedClinician">
			<xsl:with-param name="clinicianType" select="'PCP'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="AttendingClinicians">
		<xsl:for-each select="CareProvider">
			<xsl:call-template name="identifiedClinician">
				<xsl:with-param name="clinicianType" select="'ATT'"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="ConsultingClinicians">
		<xsl:for-each select="CareProvider">
			<xsl:call-template name="identifiedClinician">
				<xsl:with-param name="clinicianType" select="'CON'"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="ReferringClinician">
		<xsl:call-template name="identifiedClinician">
			<xsl:with-param name="clinicianType" select="'REF'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="AdmittingClinician">
		<xsl:call-template name="identifiedClinician">
			<xsl:with-param name="clinicianType" select="'ADM'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="OrderedBy">
		<xsl:call-template name="identifiedClinician">
			<xsl:with-param name="clinicianType" select="'ORD'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="ResultCopiesTo/CareProvider">
		<xsl:call-template name="identifiedClinician">
			<xsl:with-param name="clinicianType" select="'COP'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="identifiedClinician">
		<xsl:param name="clinicianType"/>
		<xsl:if test="generate-id(.)=generate-id(key('Clinician',concat($clinicianType,Code,'_',SDACodingStandard))[1])"> 
			<IdentifiedClinician>
				<ClinicianType><xsl:value-of select="$clinicianType"/></ClinicianType>
				<Number>
					<xsl:value-of select="Code"/>
				</Number>
				<AssigningAuthority>
					<xsl:value-of select="SDACodingStandard"/>
				</AssigningAuthority>
			</IdentifiedClinician>
		</xsl:if>
	</xsl:template>
			
</xsl:stylesheet>
