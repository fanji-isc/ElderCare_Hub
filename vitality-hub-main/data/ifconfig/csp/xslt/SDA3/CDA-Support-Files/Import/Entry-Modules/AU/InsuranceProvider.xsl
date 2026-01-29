<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="HealthFund">
		<xsl:apply-templates select="ext:entitlement" mode="HealthFundDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="HealthFundDetail">
		<HealthFund>
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- Effective Date - in SDA3 is FromTime -->
			<xsl:apply-templates select="ext:effectiveTime/hl7:low[not(@nullFlavor)]" mode="FromTime"/>

			<!-- Expiration Date - in SDA3 is ToTime -->
			<xsl:apply-templates select="ext:effectiveTime/hl7:high[not(@nullFlavor)]" mode="ToTime"/>

			<!-- Health Plan Details -->
			<xsl:apply-templates select="." mode="HealthPlanDetail"/>			
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-HealthFund"/>
		</HealthFund>
	</xsl:template>
	
	<xsl:template match="*" mode="HealthPlanDetail">
		<xsl:variable name="healthFundCode">
			<xsl:choose>
				<xsl:when test="ext:id[1]/@root">
					<xsl:apply-templates select="." mode="code-for-oid">
						<xsl:with-param name="OID" select="ext:id[1]/@root"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="string-length(ext:id[1]/@extension)">
						<xsl:value-of select="ext:id[1]/@extension"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="healthFundDescription">
			<xsl:choose>
				<xsl:when test="ext:id[1]/@assigningAuthorityName">
					<xsl:value-of select="ext:id[1]/@assigningAuthorityName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="isc:evaluate('getDescriptionForOID', ext:id[1]/@root)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
				
		<HealthFund>
			<Code><xsl:value-of select="$healthFundCode"/></Code>
			<Description><xsl:value-of select="$healthFundDescription"/></Description>
		</HealthFund>
		
		<xsl:variable name="healthFundPlanCode"><xsl:value-of select="ext:code/@code"/></xsl:variable>
		<xsl:variable name="healthFundPlanDescription"><xsl:value-of select="ext:code/@displayName"/></xsl:variable>

		<xsl:apply-templates select="ext:code" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'HealthFundPlan'"/>
		</xsl:apply-templates>
		
		<MembershipNumber><xsl:value-of select="ext:id/@extension"/></MembershipNumber>

	</xsl:template>
		
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath .//hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-HealthFund">
	</xsl:template>
</xsl:stylesheet>
