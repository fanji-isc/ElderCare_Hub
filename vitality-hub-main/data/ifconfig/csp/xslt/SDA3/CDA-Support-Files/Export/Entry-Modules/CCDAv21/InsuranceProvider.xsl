<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="sdtc exsl">

	<xsl:variable name="patientInfo" select="/Container/Patient"/>
	
	<xsl:template match="*" mode="eIP-payers-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Payer Name</th>
						<th>Policy Type</th>
						<th>Policy Number</th>
						<th>Effective Date</th>
						<th>Expiration Date</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="HealthFund" mode="eIP-payers-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-payers-NarrativeDetail">
		<tr ID="{concat($exportConfiguration/payers/narrativeLinkPrefixes/payerNarrative/text(), position())}">
			<td ID="{concat($exportConfiguration/payers/narrativeLinkPrefixes/payerPlanName/text(), position())}">
				<xsl:choose>
					<xsl:when test="string-length(HealthFundPlan/Description)"><xsl:value-of select="HealthFundPlan/Description/text()"/></xsl:when>
					<xsl:when test="string-length(//HealthFund/Description/text())"><xsl:value-of select="//HealthFund/Description/text()"/></xsl:when>
					<xsl:when test="string-length(HealthFundPlan/Code)"><xsl:value-of select="HealthFundPlan/Code/text()"/></xsl:when>
					<xsl:when test="string-length(//HealthFund/Code)"><xsl:value-of select="//HealthFund/Code/text()"/></xsl:when>
				</xsl:choose>
			</td>
			<td><xsl:value-of select="PlanType/text()"/></td>
			<td><xsl:value-of select="MembershipNumber/text()"/></td>
			<td><xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="fn-narrativeDateFromODBC"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="eIP-payers-Entries">
		<xsl:apply-templates select="HealthFund" mode="eIP-payers-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-payers-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<xsl:variable name="membershipNumber" select="MembershipNumber"/>
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="EVN">
				<xsl:call-template name="eIP-templateIds-payerEntry"/>
				
				<id nullFlavor="UNK"/>
				
				<code code="48768-6" displayName="Payment Sources" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!-- Health Plan Detail -->
				<entryRelationship typeCode="COMP">
					<act classCode="ACT" moodCode="EVN">
						<xsl:call-template name="eIP-templateIds-healthPlanPolicy"/>
						
						<!--
							Field : Payer Group Id
							Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/id
							Source: HS.SDA3.HealthFund GroupNumber
							Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/GroupNumber
							StructuredMappingRef: id-PayerGroup
						-->
						<xsl:apply-templates select="." mode="fn-id-PayerGroup"/>
						
						<xsl:choose>
							<xsl:when test="string-length(PlanType)">
								<xsl:apply-templates select="PlanType" mode="eIP-code-healthPlanType"/>
							</xsl:when>
							<xsl:otherwise>
								<code nullFlavor="UNK"/>
							</xsl:otherwise>
						</xsl:choose>
						<statusCode code="completed"/>
						<xsl:apply-templates select="." mode="eIP-performer-healthPlan"/>
						<xsl:apply-templates select="." mode="eIP-participant-healthPlan"/>
						<xsl:apply-templates select="." mode="eIP-participant-healthPlanSubscriber"/>
						
						<!-- Health Fund Plan -->
						<xsl:apply-templates select="." mode="eIP-healthPlan-authorizationActivity-healthPlan">
							<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
						</xsl:apply-templates>
					</act>
				</entryRelationship>
				
				<!-- Payers section data is not intended to be encounter-based. -->
				<!-- NIST validation does not allow for a link to an encounter. -->
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="eIP-payers-NoData">
		<text><xsl:value-of select="$exportConfiguration/payers/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-performer-healthPlan">
		<performer typeCode="PRF">
			<xsl:call-template name="eIP-templateIds-healthPlanPerformerPayer"/>
			<xsl:apply-templates select="." mode="eIP-assignedEntity-healthPlan"/>
		</performer>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-assignedEntity-healthPlan">
		<assignedEntity>
			<!-- Health Plan Identifier -->
			
			<!--
				Field : Payer Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity/id
				Source: HS.SDA3.HealthFund HealthFund
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund
				StructuredMappingRef: id-Facility
			-->
			<xsl:apply-templates select="HealthFund" mode="fn-id-Facility"/>
			
			<!--
				The applicable rule:
				HITSP/C83 Insurance Providers, Financial Responsibility Party Type
				element, if the Health Insurance Type of the encompassing Payment
				Provider (i.e. cda:code) is anything other than PP, then the Financial
				Responsibility Party Type code attribute shall be set to PAYOR.
				See HITSP/C83 Section 2.2.2.5.14, rule C83-[DE-5.14-CDA-3].
			-->
			<!--
				Field : Payer Type
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity/code/@code
				Source: HS.SDA3.HealthFund HealthFund.InsuredRelationship
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund/InsuredRelationship
				Note  : If SDA PlanType='PP' then @code is exported as 'PAYOR'. 
						If SDA InsuredRelationship='SELF' then @code is exported as 'PAT'.
						Otherwise @code is exported as 'GUAR'.
			-->
			<xsl:choose>
				<xsl:when test="not(PlanType/text()='PP')">
					<code code="PAYOR" displayName="Payor" codeSystem="{$roleClassOID}" codeSystemName="{$roleClassName}"/>
				</xsl:when>
				<xsl:when test="not(string-length(InsuredRelationship/Code/text())) or translate(InsuredRelationship/Code/text(),$lowerCase,$upperCase)='SELF'">
					<code code="PAT" displayName="Patient" codeSystem="{$roleClassOID}" codeSystemName="{$roleClassName}"/>
				</xsl:when>
				<xsl:otherwise>
					<code code="GUAR" displayName="Guarantor" codeSystem="{$roleClassOID}" codeSystemName="{$roleClassName}"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--
				Field : Payer Address
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity/addr
				Source: HS.SDA3.HealthFund HealthFund.Address
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund/Address
				StructuredMappingRef: address
			-->
			<xsl:apply-templates select="HealthFund" mode="fn-address-WorkPrimary"/>
			
			<!--
				Field : Payer Contact Information
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity/telecom
				Source: HS.SDA3.HealthFund HealthFund.ContactInfo
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund/ContactInfo
				StructuredMappingRef: telecom
			-->
			<xsl:apply-templates select="HealthFund" mode="fn-telecom"/>
			
			<!--
				Field : Payer Organization
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity/representedOrganization
				Source: HS.SDA3.HealthFund HealthFund.ContactInfo
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund/ContactInfo
				StructuredMappingRef: representedOrganization-HealthPlan
			-->
			<xsl:apply-templates select="HealthFund" mode="eIP-representedOrganization-HealthPlan"/>
		</assignedEntity>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-representedOrganization-HealthPlan">
		<!--
			StructuredMapping: representedOrganization-HealthPlan
			
			Field
			Path  : id
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: id-Facility
			
			Field
			Path  : name
			Source: Code
			Source: Code/text()
			Note  : If Code has an IdentityCode entry in the OID Registry and that
			entry has a Description, then that Description is used as the value
			for name.  Otherwise, HealthFund Description is used.
			
			Field
			Path  : telecom
			Source: ContactInfo
			Source: ./ContactInfo
			StructuredMappingRef: telecom
			
			Field
			Path  : addr
			Source: Address
			Source: ./Address
			StructuredMappingRef: address
		-->
		<xsl:choose>
			<xsl:when test="string-length(Code/text())">
				<xsl:variable name="organizationName">
					<xsl:apply-templates select="Code" mode="fn-code-to-description">
						<xsl:with-param name="identityType" select="'AssigningAuthority'"/>
						<xsl:with-param name="defaultDescription" select="Description/text()"/>
					</xsl:apply-templates>
				</xsl:variable>
				
				<representedOrganization>
					<xsl:apply-templates select="." mode="fn-id-Facility"/>
					<xsl:choose>
						<xsl:when test="string-length($organizationName)">
							<name><xsl:value-of select="$organizationName"/></name>
						</xsl:when>
						<xsl:otherwise><name nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="." mode="fn-telecom"/>
					<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>					
				</representedOrganization>
			</xsl:when>
			<xsl:otherwise>
				<representedOrganization>
					<id nullFlavor="{$idNullFlavor}"/>
					<name nullFlavor="UNK"/>
					<telecom nullFlavor="UNK"/>
					<addr nullFlavor="{$addrNullFlavor}"/>
				</representedOrganization>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-participant-healthPlan">
		<participant typeCode="COV">
			<xsl:call-template name="eIP-templateIds-healthPlanParticipantCovered"/>
			
			<!--
				Field : Payer Health Plan Effective Date
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship[@typeCode='COMP']/act/participant[@typeCode='COV']/time/low/@value
				Source: HS.SDA3.HealthFund FromTime
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/FromTime
			-->
			<!--
				Field : Payer Health Plan Expiration Date
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship[@typeCode='COMP']/act/participant[@typeCode='COV']/time/high/@value
				Source: HS.SDA3.HealthFund ToTime
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/ToTime
			-->
			<xsl:apply-templates select="." mode="fn-time"/>
			
			<xsl:apply-templates select="." mode="eIP-participantRole-healthPlan"/>
		</participant>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-participant-healthPlanSubscriber">
		<participant typeCode="HLD">
			<xsl:call-template name="eIP-templateIds-healthPlanParticipantPolicyHolder"/>
			<xsl:apply-templates select="." mode="eIP-participantRole-healthPlanSubscriber"/>
		</participant>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-participantRole-healthPlan">
		<participantRole classCode="PAT">
		
			<!--
				Field : Payer Health Plan Member Number
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship[@typeCode='COMP']/act/participant[@typeCode='COV']/participantRole/id
				Source: HS.SDA3.HealthFund MembershipNumber
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/MembershipNumber
				StructuredMappingRef: id-PayerMember
			-->
			<xsl:apply-templates select="." mode="eIP-id-PayerMember"/>
			
			<!--
				Field : Payer Patient Relationship to Subscriber
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant/participantRole/code/@code
				Source: HS.SDA3.HealthFund InsuredRelationship
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredRelationship
				Note  : For RoleCode, valid codes are: FAMDEP, HANDIC, INJ, SELF, SPON STUD, FSTUD, PSTUD
			-->
			<xsl:choose>
				<xsl:when test="string-length(InsuredRelationship)">
					<code code="{InsuredRelationship/Code/text()}" codeSystem="{$roleCodeOID}" codeSystemName="{$roleCodeName}">
						<xsl:attribute name="displayName"><xsl:apply-templates select="InsuredRelationship" mode="fn-descriptionOrCode"/></xsl:attribute>
					</code>
				</xsl:when>
				<xsl:otherwise>
					<code code="SELF" displayName="Self Pay" codeSystem="{$roleCodeOID}" codeSystemName="{$roleCodeName}"/>
				</xsl:otherwise>
			</xsl:choose>
						
			<addr nullFlavor="{$addrNullFlavor}"/>
			<telecom nullFlavor="UNK"/>
			
			<!--
				//Patient or some other relative path back up to
				/Container/Patient from here doesn't seem to work.
				Use the $patientInfo variable which is created at
				the top of this stylesheet.
			-->
			<xsl:apply-templates select="$patientInfo" mode="eIP-playingEntity-healthPlan"/>
		</participantRole>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-participantRole-healthPlanSubscriber">
		<participantRole>
			<id nullFlavor="{$idNullFlavor}"/>
			<!--
				Field : Payer Health Plan Subscriber Address
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant/participantRole/addr
				Source: HS.SDA3.HealthFund InsuredAddress
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredAddress
				StructuredMappingRef: address
			-->
			<xsl:apply-templates select="." mode="fn-address-HomePrimary"/>
			
			<!--
				Field : Payer Health Plan Subscriber Phone/Email/URL
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant/participantRole/telecom
				Source: HS.SDA3.HealthFund InsuredContact
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredContact
				StructuredMappingRef: telecom
			-->
			<xsl:apply-templates select="." mode="fn-telecom"/>
			
			<xsl:variable name="subscriberInformation">
				<Subscriber xmlns="">
					<Name>
						<FamilyName><xsl:value-of select="InsuredName/FamilyName/text()"/></FamilyName>
						<GivenName><xsl:value-of select="InsuredName/GivenName/text()"/></GivenName>
						<MiddleName><xsl:value-of select="InsuredName/MiddleName/text()"/></MiddleName>
					</Name>
				</Subscriber>
			</xsl:variable>
			
			<xsl:apply-templates select="exsl:node-set($subscriberInformation)/Subscriber" mode="eIP-playingEntity-healthPlan"/>
		</participantRole>
	</xsl:template>
	
	<!-- match can be Subscriber or Patient $ -->
	<xsl:template match="Patient | Subscriber" mode="eIP-playingEntity-healthPlan">
		<playingEntity>
			<!--
				Field : Payer Health Plan Subscriber Name
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant/participantRole/playingEntity/name
				Source: HS.SDA3.HealthFund InsuredName
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredName
				StructuredMappingRef: name-Person
			-->
			<xsl:apply-templates select="." mode="fn-name-Person"/>
		</playingEntity>
	</xsl:template>
	
	<xsl:template match="PlanType" mode="eIP-code-healthPlanType">
		<!--
			SDA HealthFund PlanType is String but in CDA it
			is a coded element.  Therefore SDA PlanType is
			converted to CodeTableDetail before export.
		-->
		<xsl:variable name="healthPlanTypeInformation">
			<PlanType xmlns="">
				<Code><xsl:value-of select="text()"/></Code>
				<Description><xsl:value-of select="text()"/></Description>
			</PlanType>
		</xsl:variable>
		
		<!-- Health Plan Type requires the X12N-1336 coding system. -->
		
		<!--
			Field : Payer Health Insurance Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/code/translation/@code
			Source: HS.SDA3.HealthFund PlanType
			Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/PlanType
			Note  : SDA PlanType is a string property that is exported to
					code/translation/@code instead of code/@code, due to the lack
					of an SDACodingStandard value.
		-->
		<xsl:apply-templates select="exsl:node-set($healthPlanTypeInformation)/PlanType" mode="fn-generic-Coded">
			<xsl:with-param name="requiredCodeSystemOID" select="$x12n1336OID"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-id-PayerMember">
		<!--
			StructuredMapping: id-PayerMember
			
			Field
			Path  : @extension
			Source: CurrentProperty
			Source: ./
			Note  : SDA MembershipNumber is exported as @extension only when HealthFund Code
					or HealthFundPlan Code is also present.  In either of those cases the OID for
					Code is also exported, as @root.  Otherwise <id nullFlavor="UNK"/> is exported.
		-->
		<xsl:choose>
			<xsl:when test="string-length(MembershipNumber)">
				<xsl:choose>
					<xsl:when test="string-length(HealthFund/Code)">
						<id>
							<xsl:attribute name="root">
								<xsl:apply-templates select="." mode="fn-oid-for-code"><xsl:with-param name="Code" select="HealthFund/Code/text()"/></xsl:apply-templates>
							</xsl:attribute>
							<xsl:attribute name="extension">
								<xsl:call-template name="fn-text-to-UID"><xsl:with-param name="text" select="MembershipNumber/text()"/></xsl:call-template>
							</xsl:attribute>
							<xsl:attribute name="assigningAuthorityName">
								<xsl:value-of select="concat(HealthFund/Code/text(), '-PayerMemberId')"/>
							</xsl:attribute>
						</id>
					</xsl:when>
					<xsl:when test="string-length(HealthFundPlan/HealthFund/Code)">
						<id>
							<xsl:attribute name="root">
								<xsl:apply-templates select="." mode="fn-oid-for-code"><xsl:with-param name="Code" select="HealthFundPlan/HealthFund/Code/text()"/></xsl:apply-templates>
							</xsl:attribute>
							<xsl:attribute name="extension">
								<xsl:value-of select="MembershipNumber/text()"/>
							</xsl:attribute>
							<xsl:attribute name="assigningAuthorityName">
								<xsl:value-of select="concat(HealthFundPlan/HealthFund/Code/text(), '-PayerMemberId')"/>
							</xsl:attribute>
						</id>
					</xsl:when>
					<xsl:otherwise>
						<id nullFlavor="{$idNullFlavor}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<id nullFlavor="{$idNullFlavor}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="HealthFund" mode="eIP-healthPlan-authorizationActivity-healthPlan">
		<!--
			healthPlan-authorizationActivity-healthPlan exports an
			authorization activity to describe information regarding
			the health plan name.  As opposed to the other possible
			format for authorization activity, which could be for
			describing authorized procedures or providers.
		-->
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entryRelationship typeCode="REFR">
			<act classCode="ACT" moodCode="DEF">
				<id nullFlavor="UNK"/>
				<code nullFlavor="UNK"/>
				<text>
					<reference value="{concat('#', $exportConfiguration/payers/narrativeLinkPrefixes/payerPlanName/text(), $narrativeLinkSuffix)}"/>
				</text>
				<statusCode code="active"/>
			</act>
		</entryRelationship>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eIP-templateIds-payerEntry">
		<templateId root="{$ccda-CoverageActivity}"/>
		<templateId root="{$ccda-CoverageActivity}" extension="2015-08-01"/>
	</xsl:template>

	<xsl:template name="eIP-templateIds-healthPlanPolicy">
		<templateId root="{$ccda-PolicyActivity}"/>
		<templateId root="{$ccda-PolicyActivity}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eIP-templateIds-healthPlanPerformerPayer">
		<templateId root="{$ccda-PerformerPayer}"/>
		<templateId root="{$ccda-PerformerPayer}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eIP-templateIds-healthPlanParticipantCovered">
		<templateId root="{$ccda-ParticipantCovered}"/>
		<templateId root="{$ccda-ParticipantCovered}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eIP-templateIds-healthPlanParticipantPolicyHolder">
		<templateId root="{$ccda-ParticipantPolicyHolder}"/>
		<templateId root="{$ccda-ParticipantPolicyHolder}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eIP-templateIds-healthPlanAuthorizationActivity">
		<!-- UNUSED, but available -->
		<templateId root="{$ccda-AuthorizationActivity}"/>
		<templateId root="{$ccda-AuthorizationActivity}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template name="eIP-templateIds-healthPlanPerformerGuarantor">
		<!-- UNUSED, but available -->
		<templateId root="{$ccda-PerformerGuarantor}"/>
		<templateId root="{$ccda-PerformerGuarantor}" extension="2015-08-01"/>
	</xsl:template>
	
</xsl:stylesheet>