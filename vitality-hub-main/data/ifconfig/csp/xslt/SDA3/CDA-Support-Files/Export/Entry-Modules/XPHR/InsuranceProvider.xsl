<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!--
		payers-EntryDetail overrides payers-EntryDetail from ../InsuranceProvider.xsl.
		This version exports an XPHR-specific code/@code and code/@displayName.
	-->
	<xsl:template match="*" mode="payers-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<xsl:variable name="membershipNumber" select="MembershipNumber"/>
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="DEF">
				<xsl:apply-templates select="." mode="templateIds-payerEntry"/>
				
				<id nullFlavor="UNK"/>
				
				<code code="35525-4" displayName="FINANCING AND INSURANCE" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<xsl:apply-templates select="." mode="effectiveTime-healthPlan"/>

				<!-- Health Plan Detail -->
				<entryRelationship typeCode="COMP">
					<act classCode="ACT" moodCode="EVN">
						<xsl:apply-templates select="." mode="templateIds-healthPlanPolicy"/>
						
						<!--
							Field : Payer Group Id
							Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/id
							Source: HS.SDA3.HealthFund GroupNumber
							Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/GroupNumber
							StructuredMappingRef: id-PayerGroup
						-->
						<xsl:apply-templates select="." mode="id-PayerGroup"/>
						<xsl:choose>
							<xsl:when test="string-length(PlanType)">
								<xsl:apply-templates select="PlanType" mode="code-healthPlanType"/>
							</xsl:when>
							<xsl:otherwise>
								<code nullFlavor="UNK"/>
							</xsl:otherwise>
						</xsl:choose>
						<statusCode code="completed"/>
						<xsl:apply-templates select="." mode="performer-healthPlan"/>
						<xsl:apply-templates select="." mode="participant-healthPlan"/>
						<xsl:apply-templates select="." mode="participant-healthPlanSubscriber"/>
					</act>
				</entryRelationship>
			</act>
		</entry>
	</xsl:template>
	
	<!--
		playingEntity-healthPlan overrides playingEntity-healthPlan from ../InsuranceProvider.xsl.
		This version omits sdtc:birthTime.
	-->
	<xsl:template match="*" mode="playingEntity-healthPlan">
		<playingEntity>
		
			<!--
				Field : Payer Health Plan Subscriber Name
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.1.5.3.7']/entry/act/entryRelationship/act/participant/participantRole/playingEntity/name
				Source: HS.SDA3.HealthFund InsuredName
				Source: /Container/Encounters/Encounter/HealthFunds/HealthFund/InsuredName
				StructuredMappingRef: name-Person
			-->
			<xsl:apply-templates select="." mode="name-Person"/>
		</playingEntity>
	</xsl:template>
</xsl:stylesheet>
