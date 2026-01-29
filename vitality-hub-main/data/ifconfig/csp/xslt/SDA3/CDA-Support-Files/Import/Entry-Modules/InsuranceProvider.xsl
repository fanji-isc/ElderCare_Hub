<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

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

	<xsl:template match="*" mode="HealthFund">
		<HealthFund>
			<xsl:apply-templates select="." mode="HealthPlan"/>
		</HealthFund>
	</xsl:template>

	<xsl:template match="hl7:act" mode="MemberEnrollment">
		<MemberEnrollment>
			<xsl:apply-templates select="." mode="HealthPlan">
				<xsl:with-param name="planMode" select="'MemberEnrollment'"/>
			</xsl:apply-templates>
		</MemberEnrollment>
	</xsl:template>

	<xsl:template match="hl7:act" mode="HealthPlan">
		<xsl:param name="planMode" select="'HealthFund'"/>
		<!--
			Field : Payer Author
			Target: HS.SDA3.HealthFund EnteredBy
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/EnteredBy
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/author
			StructuredMappingRef: EnteredByDetail
		-->
		<!--
			Field : Payer Author
			Target: HS.SDA3.MemberEnrollment EnteredBy
			Target: /Container/MemberEnrollments/MemberEnrollment/EnteredBy
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/author
			StructuredMappingRef: EnteredByDetail
		-->
		<xsl:apply-templates select="." mode="EnteredBy"/>
		
		<!--
			Field : Payer Information Source
			Target: HS.SDA3.HealthFund EnteredAt
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/EnteredAt
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/informant
			StructuredMappingRef: EnteredAt
		-->
		<!--
			Field : Payer Information Source
			Target: HS.SDA3.MemberEnrollment EnteredAt
			Target: /Container/MemberEnrollments/MemberEnrollment/EnteredAt
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/informant
			StructuredMappingRef: EnteredAt
		-->
		<xsl:apply-templates select="." mode="EnteredAt"/>
		
		<!--
			Field : Payer Author Time
			Target: HS.SDA3.HealthFund EnteredOn
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/author/time/@value
		-->
		<!--
			Field : Payer Author Time
			Target: HS.SDA3.MemberEnrollment EnteredOn
			Target: /Container/MemberEnrollments/MemberEnrollment/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/author/time/@value
		-->
		<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
		
		<!--
			Field : Payer Id
			Target: HS.SDA3.HealthFund ExternalId
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/ExternalId
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/id
			StructuredMappingRef: ExternalId
		-->
		<!--
			Field : Payer Id
			Target: HS.SDA3.MemberEnrollment ExternalId
			Target: /Container/MemberEnrollments/MemberEnrollment/ExternalId
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/id
			StructuredMappingRef: ExternalId
		-->
		<!-- Override ExternalId with the <id> values from the source CDA -->
		<xsl:apply-templates select="." mode="ExternalId"/>
		
		<!--
			Field : Payer Health Plan Effective Date
			Target: HS.SDA3.HealthFund FromTime
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/FromTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/effectiveTime/low/@value
		-->
		<!--
			Field : Payer Health Plan Expiration Date
			Target: HS.SDA3.HealthFund ToTime
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/ToTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/effectiveTime/high/@value
		-->
		<!--
			Field : Payer Health Plan Effective Date
			Target: HS.SDA3.MemberEnrollment FromTime
			Target: /Container/MemberEnrollments/MemberEnrollment/FromTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/effectiveTime/low/@value
		-->
		<!--
			Field : Payer Health Plan Expiration Date
			Target: HS.SDA3.MemberEnrollment ToTime
			Target: /Container/MemberEnrollments/MemberEnrollment/ToTime
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/effectiveTime/high/@value
		-->
		<xsl:apply-templates select="hl7:effectiveTime/hl7:low[not(@nullFlavor)]" mode="FromTime"/>
		
		<xsl:apply-templates select="hl7:effectiveTime/hl7:high[not(@nullFlavor)]" mode="ToTime"/>
		
		<!-- Health Plan Details -->
		<xsl:apply-templates select=".//hl7:act[hl7:templateId/@root=$payerPlanDetailsImportConfiguration]" mode="HealthPlanDetail">
			<xsl:with-param name="planMode" select="$planMode"/>
		</xsl:apply-templates>		
		
		<!-- Custom SDA Data-->
		<xsl:choose>
			<xsl:when test="$planMode = 'MemberEnrollment'">
				<xsl:apply-templates select="." mode="ImportCustom-MemberEnrollment"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="ImportCustom-HealthFund"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="HealthPlanDetail">
		<xsl:param name="planMode" select="'HealthFund'"/>

		<!-- Fund ID -->
		<xsl:choose>
			<xsl:when test="hl7:performer[@typeCode='PRF'][1]/hl7:assignedEntity/hl7:id[1][not(@nullFlavor)]">
				<xsl:choose>
					<xsl:when test="$planMode = 'MemberEnrollment'">
						<HealthFund> <!-- uses full SDA object, not just the CodeTableDetail -->
							<xsl:apply-templates select="hl7:performer[@typeCode='PRF'][1]/hl7:assignedEntity" mode="FundId"/>
						</HealthFund>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="hl7:performer[@typeCode='PRF'][1]/hl7:assignedEntity" mode="FundId"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- Retain participant template call for backward compatibility. -->
			<xsl:when test="hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id[not(@nullFlavor)]">
				<xsl:choose>
					<xsl:when test="$planMode = 'MemberEnrollment'">
						<HealthFund> <!-- uses full SDA object, not just the CodeTableDetail -->
							<xsl:apply-templates select="hl7:participant[@typeCode='COV']/hl7:participantRole" mode="FundId"/>
						</HealthFund>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="hl7:participant[@typeCode='COV']/hl7:participantRole" mode="FundId"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
		
		<!-- Plan ID -->
		<xsl:choose>
			<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:act/hl7:text">
				<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']" mode="PlanId-entryRelationship">
					<xsl:with-param name="planMode" select="$planMode"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- Retain participant template call for backward compatibility. -->
			<xsl:when test="hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id[not(@nullFlavor)]">
				<xsl:apply-templates select="hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id[not(@nullFlavor)]" mode="PlanId-participant">
					<xsl:with-param name="planMode" select="$planMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>

		<!-- MemberEnrollment.OtherPayers -->
		<xsl:if test="$planMode = 'MemberEnrollment'">
			<xsl:if test="hl7:performer[@typeCode='PRF' and position()>1]">
				<OtherPayors>
					<xsl:apply-templates select="hl7:performer[@typeCode='PRF' and position()>1]/hl7:assignedEntity" mode="FundId"/>
				</OtherPayors>
			</xsl:if>
		</xsl:if>
		
		<!-- Group Name and Group Number -->
		<xsl:if test="$planMode = 'HealthFund'">
			<xsl:apply-templates select="hl7:id" mode="GroupNameAndNumber"/>
		</xsl:if>

		<!--
			Field : Payer Health Insurance Type
			Target: HS.SDA3.HealthFund PlanType
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/PlanType
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/code
			Note  : SDA PlanType is a string property that is populated with
					the first found of code/@code, code/@displayName or
					code/originalText/text().
		-->
		<xsl:if test="$planMode = 'HealthFund'">
			<xsl:apply-templates select="hl7:code" mode="Code-HealthPlanType"/>
		</xsl:if>

		<!-- Insured Person -->
		<xsl:if test="$planMode = 'HealthFund'">
			<xsl:apply-templates select="hl7:participant[@typeCode='HLD']/hl7:participantRole" mode="PolicyHolder"/>
		</xsl:if>

		<!--
			Field : Payer Patient Relationship to Subscriber
			Target: HS.SDA3.HealthFund InsuredRelationship
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredRelationship
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant[@typeCode='COV']/participantRole/code
			StructuredMappingRef: CodeTableDetail
		-->
		<!--
			Field : Payer Patient Relationship to Subscriber
			Target: HS.SDA3.MemberEnrollment IndividualRelationshipCode
			Target: /Container/MemberEnrollments/MemberEnrollment/IndividualRelationshipCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant[@typeCode='COV']/participantRole/code
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:participant[@typeCode='COV']/hl7:participantRole" mode="PolicyHolderRelationship">
			<xsl:with-param name="planMode" select="$planMode"/>
		</xsl:apply-templates>
		
		<!--
			Field : Payer Member ID
			Target: HS.SDA3.HealthFund MembershipNumber
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/MembershipNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant[@typeCode='COV']/participantRole/id/@extension
		-->
		<!--
			Field : Payer Member ID
			Target: HS.SDA3.MemberEnrollment MemberEnrollmentNumber
			Target: /Container/MemberEnrollments/MemberEnrollment/MemberEnrollmentNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant[@typeCode='COV']/participantRole/id/@extension
		-->
		<!--
			Field : Payer Subscriber ID
			Target: HS.SDA3.MemberEnrollment PlanSpecificSubscriberID
			Target: /Container/MemberEnrollments/MemberEnrollment/PlanSpecificSubscriberID
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant[@typeCode='COV']/participantRole/id/@extension
		-->
		<xsl:apply-templates select="hl7:participant[@typeCode='COV']/hl7:participantRole/hl7:id[not(@nullFlavor)]" mode="MembershipNumber">
			<xsl:with-param name="planMode" select="$planMode"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="GroupNameAndNumber">
		<!--
			Field : Payer Group Name
			Target: HS.SDA3.HealthFund GroupName
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/GroupName
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/id/@root
		-->
		<!--
			Field : Payer Group Number
			Target: HS.SDA3.HealthFund GroupNumber
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/GroupNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/id/@extension
		-->
		<xsl:if test="string-length(@root)">
			<GroupName>
				<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="@root"/></xsl:apply-templates>
			</GroupName>
		</xsl:if>
		
		<xsl:if test="string-length(@extension)">
			<GroupNumber><xsl:value-of select="@extension"/></GroupNumber>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="Code-HealthPlanType">
		<PlanType>
			<xsl:choose>
				<xsl:when test="string-length(@code)"><xsl:value-of select="@code"/></xsl:when>
				<xsl:when test="string-length(@displayName)"><xsl:value-of select="@displayName"/></xsl:when>
				<xsl:when test="string-length(originalText/text())"><xsl:value-of select="originalText/text()"/></xsl:when>
			</xsl:choose>
		</PlanType>
	</xsl:template>

	<xsl:template match="*" mode="FundId">
		<!--
			Field : Payer Fund Id
			Target: HS.SDA3.HealthFund HealthFund
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/performer/assignedEntity
		-->
		<!--
			Field : Payer Fund Address
			Target: HS.SDA3.HealthFund HealthFund.Address
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund/Address
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/performer/assignedEntity/addr
			StructuredMappingRef: Address
		-->
		<!--
			Field : Payer Fund Contact Information
			Target: HS.SDA3.HealthFund HealthFund.ContactInfo
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/HealthFund/ContactInfo
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/performer/assignedEntity
			StructuredMappingRef: ContactInfo
		-->

		<!--
			Field : Payer Fund Id
			Target: HS.SDA3.MemberEnrollment HealthFund
			Target: /Container/MemberEnrollments/MemberEnrollment/HealthFund
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/performer/assignedEntity
		-->
		<!--
			Field : Payer Fund Address
			Target: HS.SDA3.MemberEnrollment HealthFund.Address
			Target: /Container/MemberEnrollments/MemberEnrollment/HealthFund/Address
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/performer/assignedEntity/addr
			StructuredMappingRef: Address
		-->
		<!--
			Field : Payer Fund Contact Information
			Target: HS.SDA3.MemberEnrollment HealthFund.ContactInfo
			Target: /Container/MemberEnrollments/MemberEnrollment/HealthFund/ContactInfo
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/performer/assignedEntity
			StructuredMappingRef: ContactInfo
		-->

		<xsl:variable name="healthPlanCode">
			<xsl:choose>
				<xsl:when test="string-length(hl7:id[1]/@extension)">
					<xsl:value-of select="hl7:id[1]/@extension"/>
				</xsl:when>
				<xsl:when test="hl7:id[1]/@root">
					<xsl:apply-templates select="." mode="code-for-oid">
						<xsl:with-param name="OID" select="hl7:id[1]/@root"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="healthPlanDescription">
			<xsl:choose>
				<xsl:when test="string-length(hl7:id[1]/@extension)">
					<xsl:value-of select="hl7:id[1]/@extension"/>
				</xsl:when>
				<xsl:when test="hl7:id[1]/@root">
					<xsl:value-of select="isc:evaluate('getDescriptionForOID', hl7:id[1]/@root)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<HealthFund>
			<Code><xsl:value-of select="$healthPlanCode"/></Code>
			<Description><xsl:value-of select="$healthPlanDescription"/></Description>
			<xsl:apply-templates select="hl7:addr" mode="Address"/>
			<xsl:apply-templates select="." mode="ContactInfo"/>
		</HealthFund>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanId-participant">
		<xsl:param name="planMode" select="'HealthFund'"/>
		<xsl:variable name="healthPlanCode">
			<xsl:choose>
				<xsl:when test="string-length(hl7:id[1]/@extension)">
					<xsl:value-of select="hl7:id[1]/@extension"/>
				</xsl:when>
				<xsl:when test="hl7:id[1]/@root">
					<xsl:apply-templates select="." mode="code-for-oid">
						<xsl:with-param name="OID" select="hl7:id[1]/@root"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="healthPlanDescription">
			<xsl:choose>
				<xsl:when test="string-length(hl7:id[1]/@extension)">
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
	
	<xsl:template match="*" mode="PlanId-entryRelationship">		
		<xsl:param name="planMode" select="'HealthFund'"/>
		<xsl:variable name="textReferenceLink" select="substring-after(hl7:act/hl7:text/hl7:reference/@value, '#')"/>
		<xsl:variable name="textValue">
			<xsl:choose>
				<xsl:when test="string-length($textReferenceLink)">
					<xsl:value-of select="normalize-space(key('narrativeKey', $textReferenceLink))"/>
				</xsl:when>
				<xsl:when test="string-length(hl7:act/hl7:text/text())">
					<xsl:value-of select="normalize-space(hl7:act/hl7:text/text())"/>
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
	
	<xsl:template match="*" mode="PolicyHolder">
		<!--
			Field : Payer Health Plan Subscriber Name
			Target: HS.SDA3.HealthFund InsuredName
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredName
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant[@typeCode='HLD']/participantRole/playingEntity/name
			StructuredMappingRef: ContactName
		-->
		<xsl:if test="hl7:playingEntity/hl7:name"><xsl:apply-templates select="hl7:playingEntity/hl7:name" mode="ContactName"><xsl:with-param name="elementName" select="'InsuredName'"/></xsl:apply-templates></xsl:if>
		
		<!--
			Field : Payer Health Plan Subscriber Address
			Target: HS.SDA3.HealthFund InsuredAddress
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredAddress
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant[@typeCode='HLD']/participantRole/addr
			StructuredMappingRef: Address
		-->
		<xsl:apply-templates select="hl7:addr" mode="Address"><xsl:with-param name="elementName" select="'InsuredAddress'"/></xsl:apply-templates>
		
		<!--
			Field : Payer Health Plan Subscriber Phone/Email/URL
			Target: HS.SDA3.HealthFund InsuredContact
			Target: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredContact
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant[@typeCode='HLD']/participantRole
			StructuredMappingRef: ContactInfo
		-->
		<xsl:apply-templates select="." mode="ContactInfo"><xsl:with-param name="elementName" select="'InsuredContact'"/></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="PolicyHolderRelationship">
		<xsl:param name="planMode" select="'HealthFund'"/>
		<xsl:apply-templates select="hl7:code" mode="CodeTable">
			<xsl:with-param name="hsElementName">
				<xsl:choose>
					<xsl:when test="$planMode = 'MemberEnrollment'">IndividualRelationshipCode</xsl:when>
					<xsl:otherwise>InsuredRelationship</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="MembershipNumber">
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
		This empty template may be overridden with custom logic for HealthFunds
		The input node spec is $sectionRootPath .//hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-HealthFund">
	</xsl:template>

	<!--
		This empty template may be overridden with custom logic for MemberEnrollments
		The input node spec is $sectionRootPath .//hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-MemberEnrollment">
	</xsl:template>
</xsl:stylesheet>
