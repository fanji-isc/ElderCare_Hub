<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="isc hl7">

	<!-- 
		Payers import into Encouter HealthPlan (default) and/or MemberEnrollment 
		based on the site import configuration. The templates in this file use the 
		$planMode parameter to handle differences between these two targets.

		Main differences:
		* HealthFund.HealthFundPlan      MemberEnrollment.InsuranceTypeOrProductCode
		* HealthFund.GroupName           n/a
		* HealthFund.GroupNumber         n/a
		* HealthFund.PlanType            n/a
		* HealthFund.InsuredName         n/a
		* HealthFund.InsuredAddress      n/a
		* HealthFund.InsuredContact      n/a
		* HealthFund.InsuredRelationship MemberEnrollment.IndividualRelationshipCode
		* HealthFund.MembershipNumber    MemberEnrollment.MemberEnrollmentNumber
		                                 MemberEnrollment.PlanSpecificSubscriberID
		* n/a                            MemberEnrollment.OtherPayors (from guarantors)

	-->

	<xsl:template match="hl7:act" mode="eIP-HealthFund">
		<HealthFund>
			<xsl:apply-templates select="." mode="eIP-HealthPlan"/>
		</HealthFund>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eIP-MemberEnrollment">
		<MemberEnrollment>
			<xsl:apply-templates select="." mode="eIP-HealthPlan">
				<xsl:with-param name="planMode" select="'MemberEnrollment'"/>
			</xsl:apply-templates>
		</MemberEnrollment>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eIP-HealthPlan">
		<xsl:param name="planMode" select="'HealthFund'"/>

		<!--
			Field : Payer Author
			Target: HS.SDA3.HealthFund EnteredBy
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/EnteredBy
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/author
			StructuredMappingRef: EnteredByDetail
		-->
		<!--
			Field : Payer Author
			Target: HS.SDA3.MemberEnrollment EnteredBy
			Target: /Container/MemberEnrollments/MemberEnrollment/EnteredBy
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/author
			StructuredMappingRef: EnteredByDetail
		-->
		<xsl:apply-templates select="." mode="fn-EnteredBy"/>
		
		<!--
			Field : Payer Information Source
			Target: HS.SDA3.HealthFund EnteredAt
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/EnteredAt
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/informant
			StructuredMappingRef: EnteredAt
		-->
		<!--
			Field : Payer Information Source
			Target: HS.SDA3.MemberEnrollment EnteredAt
			Target: /Container/MemberEnrollments/MemberEnrollment/EnteredAt
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/informant
			StructuredMappingRef: EnteredAt
		-->
		<xsl:apply-templates select="." mode="fn-EnteredAt"/>
		
		<!--
			Field : Payer Author Time
			Target: HS.SDA3.HealthFund EnteredOn
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/author/time/@value
		-->
		<!--
			Field : Payer Author Time
			Target: HS.SDA3.MemberEnrollment EnteredOn
			Target: /Container/MemberEnrollments/MemberEnrollment/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/author/time/@value
		-->
		<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
		
		<!--
			Field : Payer Id
			Target: HS.SDA3.HealthFund ExternalId
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/ExternalId
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/id
			StructuredMappingRef: ExternalId
		-->
		<!--
			Field : Payer Id
			Target: HS.SDA3.MemberEnrollment ExternalId
			Target: /Container/MemberEnrollments/MemberEnrollment/ExternalId
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/id
			StructuredMappingRef: ExternalId
		-->
		<!-- Override ExternalId with the <id> values from the source CDA -->
		<xsl:apply-templates select="." mode="fn-ExternalId"/>
		
		<!--
			Field : Payer Health Plan Effective Date
			Target: HS.SDA3.HealthFund FromTime
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/FromTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship[@typeCode='COMP']/act/participant[@typeCode='COV']/time/low/@value
		-->
		<!--
			Field : Payer Health Plan Expiration Date
			Target: HS.SDA3.HealthFund ToTime
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/ToTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship[@typeCode='COMP']/act/participant[@typeCode='COV']/time/high/@value
		-->
		<!--
			Field : Payer Health Plan Effective Date
			Target: HS.SDA3.HealthFund FromTime
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/FromTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/effectiveTime/low/@value
		-->
		<!--
			Field : Payer Health Plan Expiration Date
			Target: HS.SDA3.HealthFund ToTime
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/ToTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/effectiveTime/high/@value
		-->
		<!--
			Field : Payer Health Plan Effective Date
			Target: HS.SDA3.MemberEnrollment FromTime
			Target: /Container/MemberEnrollments/MemberEnrollment/FromTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship[@typeCode='COMP']/act/participant[@typeCode='COV']/time/low/@value
		-->
		<!--
			Field : Payer Health Plan Expiration Date
			Target: HS.SDA3.MemberEnrollment ToTime
			Target: /Container/MemberEnrollments/MemberEnrollment/ToTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship[@typeCode='COMP']/act/participant[@typeCode='COV']/time/high/@value
		-->
		<!--
			Field : Payer Health Plan Effective Date
			Target: HS.SDA3.MemberEnrollment FromTime
			Target: /Container/MemberEnrollments/MemberEnrollment/FromTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/effectiveTime/low/@value
		-->
		<!--
			Field : Payer Health Plan Expiration Date
			Target: HS.SDA3.MemberEnrollment ToTime
			Target: /Container/MemberEnrollments/MemberEnrollment/ToTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/effectiveTime/high/@value
		-->
		<xsl:choose>
			<xsl:when test="hl7:entryRelationship[@typeCode='COMP']/hl7:act/hl7:participant[@typeCode='COV']/hl7:time">
				<xsl:apply-templates select="hl7:entryRelationship[@typeCode='COMP']/hl7:act/hl7:participant[@typeCode='COV']/hl7:time/hl7:low[not(@nullFlavor)]" mode="fn-FromTime"/>
				<xsl:apply-templates select="hl7:entryRelationship[@typeCode='COMP']/hl7:act/hl7:participant[@typeCode='COV']/hl7:time/hl7:high[not(@nullFlavor)]" mode="fn-ToTime"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="hl7:effectiveTime/hl7:low[not(@nullFlavor)]" mode="fn-FromTime"/>
				<xsl:apply-templates select="hl7:effectiveTime/hl7:high[not(@nullFlavor)]" mode="fn-ToTime"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- Health Plan Details -->
		<xsl:apply-templates select="hl7:entryRelationship[@typeCode='COMP']/hl7:act[hl7:templateId/@root=$ccda-PolicyActivity]" mode="eIP-HealthPlanDetail">
			<xsl:with-param name="planMode" select="$planMode"/>
		</xsl:apply-templates>
		
		<!-- Custom SDA Data-->
		<xsl:choose>
			<xsl:when test="$planMode = 'MemberEnrollment'">
				<xsl:apply-templates select="." mode="eIP-ImportCustom-MemberEnrollment"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="eIP-ImportCustom-HealthFund"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:act" mode="eIP-HealthPlanDetail">
		<xsl:param name="planMode" select="'HealthFund'"/>
		<xsl:variable name="performerAndEntity" select="hl7:performer[hl7:templateId/@root=$ccda-PerformerPayer]/hl7:assignedEntity"/>
		<!-- Fund ID -->
		<xsl:if test="$performerAndEntity/hl7:id[1][not(@nullFlavor)]">
			<xsl:choose>
				<xsl:when test="$planMode = 'MemberEnrollment'">
					<HealthFund> <!-- uses full SDA object, not just the CodeTableDetail -->
						<xsl:apply-templates select="$performerAndEntity" mode="eIP-HealthFund"/>
					</HealthFund>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$performerAndEntity" mode="eIP-HealthFund"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<!-- Plan ID -->
		<xsl:choose>
			<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:act[@moodCode='DEF']/hl7:text">
				<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']" mode="eIP-HealthFundPlan-Authorization">
					<xsl:with-param name="planMode" select="$planMode"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$performerAndEntity/hl7:id[1][not(@nullFlavor)]">
				<xsl:apply-templates select="$performerAndEntity/hl7:id[1][not(@nullFlavor)]" mode="eIP-HealthFundPlan-Performer">
					<xsl:with-param name="planMode" select="$planMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
		
		<!-- MemberEnrollment.OtherPayers -->
		<xsl:if test="$planMode = 'MemberEnrollment'">
			<xsl:variable name="guarantor" select="hl7:performer[hl7:templateId/@root=$ccda-PerformerGuarantor]"/>
			<xsl:if test="$guarantor/hl7:assignedEntity/hl7:id[not(@nullFlavor)]">
				<OtherPayors>
					<xsl:apply-templates select="$guarantor/hl7:assignedEntity[hl7:id[not(@nullFlavor)]]" mode="eIP-HealthFund"/>
				</OtherPayors>
			</xsl:if>
		</xsl:if>

		<!-- Group Name and Group Number -->
		<xsl:if test="$planMode = 'HealthFund'">
			<xsl:apply-templates select="hl7:id" mode="eIP-GroupNameAndNumber"/>
		</xsl:if>

		<!--
			Field : Payer Health Insurance Type
			Target: HS.SDA3.HealthFund PlanType
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/PlanType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/code
			Note  : SDA PlanType is a string property that is populated with
					the first found of code/@code, code/@displayName or
					code/originalText/text().
		-->
		<xsl:if test="$planMode = 'HealthFund'">
			<xsl:apply-templates select="hl7:code" mode="eIP-PlanType"/>
		</xsl:if>
		
		<!-- Insured Person -->
		<xsl:if test="$planMode = 'HealthFund'"> 
			<xsl:apply-templates select="hl7:participant[@typeCode='HLD']/hl7:participantRole" mode="eIP-PolicyHolder"/>
		</xsl:if>
		
		<!--
			Field : Payer Patient Relationship to Subscriber
			Target: HS.SDA3.HealthFund InsuredRelationship
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredRelationship
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant[@typeCode='COV']/participantRole/code
			StructuredMappingRef: CodeTableDetail
		-->
		<!--
			Field : Payer Patient Relationship to Subscriber
			Target: HS.SDA3.MemberEnrollment IndividualRelationshipCode
			Target: /Container/MemberEnrollments/MemberEnrollment/IndividualRelationshipCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant[@typeCode='COV']/participantRole/code
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:variable name="policyHolder" select="hl7:participant[@typeCode='COV']/hl7:participantRole"/>
		<xsl:apply-templates select="$policyHolder" mode="eIP-PolicyHolderRelationship">
			<xsl:with-param name="planMode" select="$planMode"/>
		</xsl:apply-templates>

		<!--
			Field : Payer Member ID
			Target: HS.SDA3.HealthFund MembershipNumber
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/MembershipNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant[@typeCode='COV']/participantRole/id/@extension
		-->
		<xsl:apply-templates select="$policyHolder/hl7:id[not(@nullFlavor)]" mode="eIP-MembershipNumber">
			<xsl:with-param name="planMode" select="$planMode"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:id" mode="eIP-GroupNameAndNumber">
		<!--
			Field : Payer Group Name
			Target: HS.SDA3.HealthFund GroupName
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/GroupName
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/id/@root
		-->
		<!--
			Field : Payer Group Number
			Target: HS.SDA3.HealthFund GroupNumber
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/GroupNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/id/@extension
		-->
		<xsl:if test="string-length(@root)">
			<GroupName>
				<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="@root"/></xsl:apply-templates>
			</GroupName>
		</xsl:if>
		
		<xsl:if test="string-length(@extension)">
			<GroupNumber><xsl:value-of select="@extension"/></GroupNumber>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:code" mode="eIP-PlanType">
		<!-- The mode formerly known as Code-HealthPlanType -->
		<PlanType>
			<xsl:choose>
				<xsl:when test="string-length(@code)"><xsl:value-of select="@code"/></xsl:when>
				<xsl:when test="string-length(@displayName)"><xsl:value-of select="@displayName"/></xsl:when>
				<xsl:when test="string-length(originalText/text())"><xsl:value-of select="originalText/text()"/></xsl:when>
			</xsl:choose>
		</PlanType>
	</xsl:template>

	<xsl:template match="hl7:assignedEntity" mode="eIP-HealthFund">
		<!-- The mode formerly known as FundId -->
		<!--
			Field : Payer Fund Id
			Target: HS.SDA3.HealthFund HealthFund
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity
		-->
		<!--
			Field : Payer Fund Address
			Target: HS.SDA3.HealthFund HealthFund.Address
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund/Address
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity/addr
			StructuredMappingRef: Address
		-->
		<!--
			Field : Payer Fund Contact Information
			Target: HS.SDA3.HealthFund HealthFund.ContactInfo
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund/ContactInfo
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity
			StructuredMappingRef: ContactInfo
		-->

		<!--
			Field : Payer Fund Id
			Target: HS.SDA3.MemberEnrollment HealthFund
			Target: /Container/MemberEnrollments/MemberEnrollment/HealthFund/HealthFund
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity
		-->
		<!--
			Field : Payer Fund Address
			Target: HS.SDA3.MemberEnrollment HealthFund.Address
			Target: /Container/MemberEnrollments/MemberEnrollment/HealthFund/HealthFund/Address
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity/addr
			StructuredMappingRef: Address
		-->
		<!--
			Field : Payer Fund Contact Information
			Target: HS.SDA3.MemberEnrollment HealthFund.ContactInfo
			Target: /Container/MemberEnrollments/MemberEnrollment/HealthFund/HealthFund/ContactInfo
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity
			StructuredMappingRef: ContactInfo
		-->

		<!--
			Field : Payer Fund Id
			Target: HS.SDA3.MemberEnrollment OtherPayors.HealthFund
			Target: /Container/MemberEnrollments/MemberEnrollment/OtherPayors/HealthFund
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity
		-->
		<!--
			Field : Payer Fund Address
			Target: HS.SDA3.MemberEnrollment OtherPayors.HealthFund.Address
			Target: /Container/MemberEnrollments/MemberEnrollment/OtherPayors/HealthFund/Address
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity/addr
			StructuredMappingRef: Address
		-->
		<!--
			Field : Payer Fund Contact Information
			Target: HS.SDA3.MemberEnrollment OtherPayors.HealthFund.ContactInfo
			Target: /Container/MemberEnrollments/MemberEnrollment/OtherPayors/HealthFund/ContactInfo
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer/assignedEntity
			StructuredMappingRef: ContactInfo
		-->
		<xsl:variable name="hasExtension" select="string-length(hl7:id[1]/@extension) > 0"/>
		<xsl:variable name="healthFundCode">
			<xsl:choose>
				<xsl:when test="$hasExtension">
					<xsl:value-of select="hl7:id[1]/@extension"/>
				</xsl:when>
				<xsl:when test="hl7:id[1]/@root">
					<xsl:apply-templates select="." mode="fn-code-for-oid">
						<xsl:with-param name="OID" select="hl7:id[1]/@root"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="healthFundDescription">
			<xsl:choose>
				<xsl:when test="$hasExtension">
					<xsl:value-of select="hl7:id[1]/@extension"/>
				</xsl:when>
				<xsl:when test="hl7:id[1]/@root">
					<xsl:value-of select="isc:evaluate('getDescriptionForOID', hl7:id[1]/@root)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<HealthFund>
			<Code><xsl:value-of select="$healthFundCode"/></Code>
			<Description><xsl:value-of select="$healthFundDescription"/></Description>
			<xsl:apply-templates select="hl7:addr" mode="fn-T-pName-address"/>
			<xsl:apply-templates select="." mode="fn-T-pName-ContactInfo"/>
		</HealthFund>
	</xsl:template>

	<xsl:template match="hl7:entryRelationship" mode="eIP-HealthFundPlan-Authorization">
		<xsl:param name="planMode" select="'HealthFund'"/>
		<!-- The mode formerly known as PlanId-Authorization -->
		<!--
			Field : Payer Health Plan Insurance Information SourceId
			Target: HS.SDA3.HealthFund HealthFundPlan
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFundPlan
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/entryRelationship[@typeCode='REFR']/act/text
			Note  : Import template PlanId-Authorization gets the health
					plan id and name from a C-CDA Authorization Activity.
		-->
		<!--
			Field : Payer Health Plan Insurance Information SourceId
			Target: HS.SDA3.MemberEnrollment InsuranceTypeOrProductCode
			Target: /Container/MemberEnrollments/MemberEnrollment/InsuranceTypeOrProductCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/entryRelationship[@typeCode='REFR']/act/text
			Note  : Import template PlanId-Authorization gets the health
					plan id and name from a C-CDA Authorization Activity.
		-->
		
		<xsl:variable name="textReferenceLink" select="substring-after(hl7:act/hl7:text/hl7:reference/@value, '#')"/>
		<xsl:variable name="textValue">
			<xsl:choose>
				<xsl:when test="string-length($textReferenceLink)">
					<xsl:value-of select="normalize-space(key('narrativeKey', $textReferenceLink))"/>
				</xsl:when>
				<xsl:when test="string-length(hl7:act/hl7:text/text())">
					<xsl:value-of select="hl7:act/hl7:text/text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="string-length($textValue)">
			<xsl:choose>
				<xsl:when test="$planMode = 'MemberEnrollment'">
					<InsuranceTypeOrProductCode>
						<Code><xsl:value-of select="$textValue"/></Code>
						<Description><xsl:value-of select="$textValue"/></Description>
					</InsuranceTypeOrProductCode>
				</xsl:when>
				<xsl:otherwise>
					<HealthFundPlan>
						<Code><xsl:value-of select="$textValue"/></Code>
						<Description><xsl:value-of select="$textValue"/></Description>
					</HealthFundPlan>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:id" mode="eIP-HealthFundPlan-Performer">
		<xsl:param name="planMode" select="'HealthFund'"/>
		<!-- The mode formerly known as PlanId-Performer -->
		<!--
			Field : Payer Health Plan Insurance Information SourceId
			Target: HS.SDA3.HealthFund HealthFundPlan
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFundPlan
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer[templateId/@root='2.16.840.1.113883.10.20.22.4.87']/assignedEntity/id
			Note  : Import template PlanId-Performer gets the health plan id
					and name from a Performer within a C-CDA Policy Activity.
		-->
		<!--
			Field : Payer Health Plan Insurance Information SourceId
			Target: HS.SDA3.MemberEnrollment InsuranceTypeOrProductCode
			Target: /Container/MemberEnrollments/MemberEnrollment/InsuranceTypeOrProductCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/performer[templateId/@root='2.16.840.1.113883.10.20.22.4.87']/assignedEntity/id
			Note  : Import template PlanId-Performer gets the health plan id
					and name from a Performer within a C-CDA Policy Activity.
		-->
		<xsl:variable name="hasExtension" select="string-length(hl7:id[1]/@extension) > 0"/>
		<xsl:variable name="healthPlanCode">
			<xsl:choose>
				<xsl:when test="$hasExtension">
					<xsl:value-of select="hl7:id[1]/@extension"/>
				</xsl:when>
				<xsl:when test="hl7:id[1]/@root">
					<xsl:apply-templates select="." mode="fn-code-for-oid">
						<xsl:with-param name="OID" select="hl7:id[1]/@root"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="healthPlanDescription">
			<xsl:choose>
				<xsl:when test="$hasExtension">
					<xsl:value-of select="hl7:id[1]/@extension"/>
				</xsl:when>
				<xsl:when test="hl7:id[1]/@root">
					<xsl:value-of select="isc:evaluate('getDescriptionForOID', hl7:id[1]/@root)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$planMode = 'MemberEnrollment'">
				<InsuranceTypeOrProductCode>
					<Code><xsl:value-of select="$healthPlanCode"/></Code>
					<Description><xsl:value-of select="$healthPlanDescription"/></Description>
				</InsuranceTypeOrProductCode>
			</xsl:when>
			<xsl:otherwise>
				<HealthFundPlan>
					<Code><xsl:value-of select="$healthPlanCode"/></Code>
					<Description><xsl:value-of select="$healthPlanDescription"/></Description>
				</HealthFundPlan>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:participantRole" mode="eIP-PolicyHolder">
		<!--
			Field : Payer Health Plan Subscriber Name
			Target: HS.SDA3.HealthFund InsuredName
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredName
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant/participantRole/playingEntity/name
			StructuredMappingRef: ContactName
		-->
		<xsl:if test="hl7:playingEntity/hl7:name">
			<xsl:apply-templates select="hl7:playingEntity/hl7:name" mode="fn-T-pName-ContactName">
				<xsl:with-param name="emitElementName" select="'InsuredName'"/>
			</xsl:apply-templates>
		</xsl:if>
		
		<!--
			Field : Payer Health Plan Subscriber Address
			Target: HS.SDA3.HealthFund InsuredAddress
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredAddress
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant/participantRole/addr
			StructuredMappingRef: Address
		-->
		<xsl:apply-templates select="hl7:addr" mode="fn-T-pName-address">
			<xsl:with-param name="emitElementName" select="'InsuredAddress'"/>
		</xsl:apply-templates>
		
		<!--
			Field : Payer Health Plan Subscriber Phone/Email/URL
			Target: HS.SDA3.HealthFund InsuredContact
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredContact
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.18']/entry/act/entryRelationship/act/participant/participantRole
			StructuredMappingRef: ContactInfo
		-->
		<xsl:apply-templates select="." mode="fn-T-pName-ContactInfo">
			<xsl:with-param name="emitElementName" select="'InsuredContact'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:participantRole" mode="eIP-PolicyHolderRelationship">
		<xsl:param name="planMode" select="'HealthFund'"/>
		<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName">
				<xsl:choose>
					<xsl:when test="$planMode = 'MemberEnrollment'">IndividualRelationshipCode</xsl:when>
					<xsl:otherwise>InsuredRelationship</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:id" mode="eIP-MembershipNumber">
		<xsl:param name="planMode" select="'HealthFund'"/>
		<xsl:choose>
			<xsl:when test="$planMode = 'MemberEnrollment'">
				<MemberEnrollmentNumber><xsl:value-of select="@extension"/></MemberEnrollmentNumber>
				<PlanSpecificSubscriberID><xsl:value-of select="@extension"/></PlanSpecificSubscriberID>
			</xsl:when>
			<xsl:otherwise>
				<MembershipNumber><xsl:value-of select="@extension"/></MembershipNumber>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally hl7:entry//hl7:act (note: any descendant, not just children).
	-->
	<xsl:template match="*" mode="eIP-ImportCustom-HealthFund">
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally hl7:entry//hl7:act (note: any descendant, not just children).
	-->
	<xsl:template match="*" mode="eIP-ImportCustom-MemberEnrollment">
	</xsl:template>

</xsl:stylesheet>