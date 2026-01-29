<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
  <!-- AlsoInclude: Interventions.xsl Outcomes.xsl (other Sections) AuthorParticipation.xsl HealthcareProvider.xsl Support.xsl (entries) -->
  
	<xsl:template match="*" mode="sCP-Section">
		<CarePlans>
			<CarePlan>
				<!--
					Field : Care Plan Type
					Target: HS.SDA3.CarePlan Type
					Target: /Container/CarePlans/CarePlan/Type
					Source: /ClinicalDocument/code
				-->
				<xsl:apply-templates select="hl7:code" mode="sCP-CarePlanCode" />				

				<!--
					Field : Care Plan Care Provider
					Target: HS.SDA3.CarePlan Care Provider
					Target: /Container/CarePlans/CarePlan/Providers
					Source: /ClinicalDocument/documentationOf/serviceEvent/performer
				-->
				<Providers>
					<xsl:apply-templates select="hl7:documentationOf/hl7:serviceEvent/hl7:performer" mode="eHP-DocumentProvider-performer" />
				</Providers>

				<!--
					Field : Care Plan Support Contacts
					Target: HS.SDA3.CarePlan Support Contacts
					Target: /Container/CarePlans/CarePlan/SupportContacts
					Source: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity/
				-->
				<xsl:apply-templates select="hl7:participant[@typeCode='IND']" mode="eS-Support-CarePlan" />			

				<!--
					Field : Care Plan SetId
					Target: HS.SDA3.CarePlan SetId
					Target: /Container/CarePlans/CarePlan/SetId
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.1.15']/setId
				-->
				<xsl:apply-templates select="hl7:setId" mode="sCP-SetId" />

				<!--
					Field : Care Plan Version
					Target: HS.SDA3.CarePlan Version
					Target: /Container/CarePlans/CarePlan/Version
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.1.15']/versionNumber
				-->
				<xsl:apply-templates select="hl7:versionNumber" mode="sCP-Version" />

				<!--
					Field : Care Plan Authors
					Target: HS.SDA3.CarePlan Authors
					Target: /Container/CarePlans/CarePlan/Providers
					Source: /ClinicalDocument/author
				-->
				<Authors>
					<xsl:apply-templates select="hl7:author" mode="eAP-DocumentProvider" />
				</Authors>

				<!--
					Field : Care Plan Organizations
					Target: HS.SDA3.CarePlan Organizations
					Target: /Container/CarePlans/CarePlan/Organizations
					Source: /ClinicalDocument/participant[@typeCode='LOC']/associatedEntity/scopingOrganization
				-->
				<Organizations>
					<xsl:apply-templates select="hl7:participant[@typeCode='LOC']" mode="eS-Organization-CarePlan" />
				</Organizations>

				<!--
					Field : Care Plan Health Concern IDs
					Target: HS.SDA3.CarePlan HealthConcernIds
					Target: /Container/CarePlans/CarePlan/HealthConcernIds
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.58']/entry/act/id
				-->
				<xsl:variable name="healthConcernIds" select="hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.58']/hl7:entry/hl7:act/hl7:id" />
				<xsl:if test="$healthConcernIds">
					<HealthConcernIds>
						<xsl:apply-templates select="$healthConcernIds"  mode="fn-W-pName-ExternalId-reference" >
							<xsl:with-param name="hsElementName">HealthConcernIdsItem</xsl:with-param>
						</xsl:apply-templates>
					</HealthConcernIds>
				</xsl:if>

				<!--
					Field : Care Plan Goal IDs
					Target: HS.SDA3.CarePlan goalIds
					Target: /Container/CarePlans/CarePlan/goalIds
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.60']/entry/observation/id
				-->
				<xsl:variable name="goalIds" select="hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.60']/hl7:entry/hl7:observation/hl7:id" />
				<xsl:if test="$goalIds">
					<GoalIds>
						<xsl:apply-templates select="$goalIds"  mode="fn-W-pName-ExternalId-reference" >
							<xsl:with-param name="hsElementName">GoalIdsItem</xsl:with-param>
						</xsl:apply-templates>
					</GoalIds>
				</xsl:if>

				<!-- Interventions -->
				<xsl:apply-templates select="." mode="sIn-Section"/>

				<!-- Outcomes -->
				<xsl:apply-templates select="." mode="sHSO-Section"/>
			</CarePlan>
		</CarePlans>
	</xsl:template>

	<xsl:template match="hl7:code" mode="sCP-CarePlanCode">
		<xsl:apply-templates select="." mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'Type'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:versionNumber" mode="sCP-Version">
		<Version><xsl:value-of select="@value" /></Version>
	</xsl:template>

	<xsl:template match="hl7:setId" mode="sCP-SetId">
		<SetId><xsl:value-of select="@root" /></SetId>
	</xsl:template>
	
</xsl:stylesheet>