<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<!-- Administrative Observations can contain a variety
		of information from various SDA classes.
	-->
	<xsl:template match="*" mode="administrativeObservations">
		<xsl:variable name="hasDataHealthFunds" select="Encounters/Encounter/HealthFunds"/>
		<xsl:variable name="hasDataSpecialties" select="Encounters/Encounter/Specialties"/>
		
		<component>
			<section>
				<!-- IHE needs unique id for each and every section -->
				<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
				
				<code code="102.16080" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Administrative Observations"/>
				<title>Administrative Observations</title>
				
				<text mediaType="text/x-hl7-text+xml">
					<xsl:if test="$hasDataHealthFunds"><xsl:apply-templates select="Encounters" mode="administrativeObservations-DemographicsNarrative"/></xsl:if>
					<xsl:apply-templates select="Encounters" mode="administrativeObservations-SpecialtiesNarrative"/>
				</text>
				<xsl:apply-templates select="Encounters" mode="administrativeObservations-SpecialtiesEntries"/>
				<xsl:if test="$hasDataHealthFunds"><xsl:apply-templates select="Encounters" mode="administrativeObservations-DemographicsEntries"/></xsl:if>
			</section>
		</component>
	</xsl:template>
	
	<xsl:template match="*" mode="administrativeObservations-DemographicsNarrative">
		<table border="1" width="100%">
			<caption>DEMOGRAPHIC DATA</caption>
			<thead>
				<tr>
					<th>Field</th>
					<th>Result Value</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="set:distinct(Encounter/HealthFunds/HealthFund/HealthFund/Code)">
					<xsl:for-each select="set:distinct(../../MembershipNumber)">
						<xsl:apply-templates select=".." mode="administrativeObservations-payers-NarrativeDetail"/>
					</xsl:for-each>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="*" mode="administrativeObservations-SpecialtiesNarrative">
		<table border="1" width="100%">
			<caption>Specialties</caption>
			<thead>
				<tr>
					<th>Specialty</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="Encounter/Specialties/CareProviderType" mode="administrativeObservations-SpecialtiesNarrativeDetail"/>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="*" mode="administrativeObservations-payers-NarrativeDetail">
		<xsl:variable name="payersIdAndCodeInfo"><payersInfo xmlns=""><xsl:apply-templates select="." mode="payers-idAndcodeInfo"/></payersInfo></xsl:variable>
		<xsl:variable name="payersIdAndCode" select="exsl:node-set($payersIdAndCodeInfo)/payersInfo"/>

		<tr>
			<td>
				<xsl:choose>
					<xsl:when test="string-length($payersIdAndCode/ext:code/@displayName)"><xsl:value-of select="$payersIdAndCode/ext:code/@displayName"/></xsl:when>
					<xsl:when test="string-length(//HealthFund/Description/text())"><xsl:value-of select="//HealthFund/Description/text()"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="//HealthFund/Code/text()"/></xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="string-length($payersIdAndCode/ext:id/@extension) and not(string-length($payersIdAndCode/ext:id/@assigningAuthorityName))"><xsl:value-of select="$payersIdAndCode/ext:id/@extension"/></xsl:when>
					<xsl:when test="string-length($payersIdAndCode/ext:id/@extension) and string-length($payersIdAndCode/ext:id/@assigningAuthorityName)"><xsl:value-of select="concat($payersIdAndCode/ext:id/@extension,' (',$payersIdAndCode/ext:id/@assigningAuthorityName,')')"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="MembershipNumber/text()"/></xsl:otherwise>
				</xsl:choose>			
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="administrativeObservations-SpecialtiesNarrativeDetail">
		<tr>
			<td><xsl:apply-templates select="." mode="descriptionOrCode"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="administrativeObservations-DemographicsEntries">		
		<!-- Payers -->
		<xsl:for-each select="set:distinct(Encounter/HealthFunds/HealthFund/HealthFund/Code)">
			<xsl:for-each select="set:distinct(../../MembershipNumber)">
				<xsl:apply-templates select=".." mode="administrativeObservations-payers-EntryDetail"/>
			</xsl:for-each>
		</xsl:for-each>
		
	</xsl:template>
	
	<xsl:template match="*" mode="administrativeObservations-payers-EntryDetail">
		<ext:coverage2 typeCode="COVBY">
			<ext:entitlement classCode="COV" moodCode="EVN">
				<xsl:apply-templates select="." mode="payers-idAndcodeInfo"/>
				<xsl:apply-templates select="." mode="extEffectiveTime-FromTo"/>
				<ext:participant typeCode="BEN">
					<ext:participantRole classCode="PAT">
						<ext:id root="{$patientRoleId}"/>
					</ext:participantRole>
				</ext:participant>
			</ext:entitlement>
			<!-- Link this payer to all related encounters (when/where was this payment used?) noted in encounters section -->
			<!--<xsl:apply-templates select="//Encounter[HealthFunds/HealthFund/MembershipNumber=$membershipNumber]" mode="encounterLink-entryRelationship"/>-->
		</ext:coverage2>
	</xsl:template>
	
	<xsl:template match="*" mode="payers-idAndcodeInfo">
			<ext:id>
				<xsl:attribute name="root">
					<xsl:apply-templates select="." mode="oid-for-code">
						<xsl:with-param name="Code" select="HealthFund/Code"/>
					</xsl:apply-templates>
				</xsl:attribute>
				<xsl:attribute name="extension"><xsl:value-of select="MembershipNumber/text()"/></xsl:attribute>
				<xsl:if test="string-length(HealthFund/Description/text())"><xsl:attribute name="assigningAuthorityName"><xsl:value-of select="HealthFund/Description/text()"/></xsl:attribute></xsl:if>
			</ext:id>
			
			<xsl:variable name="entitlementCodeSystem">
				<xsl:choose>
					<xsl:when test="string-length(HealthFundPlan/SDACodingStandard/text())">
						<xsl:apply-templates select="." mode="oid-for-code">
							<xsl:with-param name="Code" select="HealthFundPlan/SDACodingStandard"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="not(string-length(HealthFundPlan/SDACodingStandard/text())) and number(HealthFundPlan/Code/text())>0 and not(number(HealthFundPlan/Code/text())>11)">1.2.36.1.2001.1001.101.104.16047</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="entitlementCodeSystemName">
				<xsl:choose>
					<xsl:when test="$entitlementCodeSystem='1.2.36.1.2001.1001.101.104.16047'">NCTIS Entitlement Type Values</xsl:when>
					<xsl:otherwise><xsl:value-of select="HealthFundPlan/SDACodingStandard/text()"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="entitlementDisplayName">
				<xsl:choose>
					<xsl:when test="string-length(HealthFundPlan/Description/text())">
						<xsl:value-of select="HealthFundPlan/Description/text()"/>
					</xsl:when>
					<xsl:when test="$entitlementCodeSystem='1.2.36.1.2001.1001.101.104.16047'">
						<xsl:choose>
							<xsl:when test="HealthFundPlan/Code/text()='1'">Medicare Benefits</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='2'">Pensioner Concession</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='3'">Commonwealth Seniors Health Concession</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='4'">Health Care Concession</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='5'">Repatriation Health Gold Benefits</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='6'">Repatriation Health White Benefits</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='7'">Repatriation Health Orange Benefits</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='8'">Safety Net Concession</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='9'">Safety Net Entitlement</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='10'">Medicare Prescriber Number</xsl:when>
							<xsl:when test="HealthFundPlan/Code/text()='11'">Medicare Pharmacy Approval Number</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise><xsl:value-of select="HealthFundPlan/Code/text()"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<ext:code code="{HealthFundPlan/Code/text()}">
				<xsl:attribute name="codeSystem">
					<xsl:choose>
						<xsl:when test="string-length($entitlementCodeSystem)"><xsl:value-of select="$entitlementCodeSystem"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="codeSystemName">
					<xsl:choose>
						<xsl:when test="string-length($entitlementCodeSystemName)"><xsl:value-of select="$entitlementCodeSystemName"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$noCodeSystemName"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="displayName">
					<xsl:if test="string-length($entitlementDisplayName)"><xsl:value-of select="$entitlementDisplayName"/></xsl:if>
				</xsl:attribute>
			</ext:code>
	</xsl:template>
	
	<xsl:template match="*" mode="extEffectiveTime-FromTo">
		<xsl:param name="includeHighTime" select="true()"/>
		
		<ext:effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(FromTime/text())">
					<low><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></low>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="string-length(ToTime/text()) and $includeHighTime = true()">
					<high><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></high>
				</xsl:when>
			</xsl:choose>
		</ext:effectiveTime>
	</xsl:template>
	
	<xsl:template match="*" mode="administrativeObservations-SpecialtiesEntries">
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="103.16028" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Specialty"/>
				<xsl:apply-templates select="Encounter/Specialties/CareProviderType" mode="value-CD"/>
			</observation>
		</entry>
	</xsl:template>
</xsl:stylesheet>
