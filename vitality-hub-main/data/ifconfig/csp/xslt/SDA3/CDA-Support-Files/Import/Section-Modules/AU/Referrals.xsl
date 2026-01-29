<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Referrals">
		<Referrals>
			<!-- Process CDA Append/Transform/Replace Directive -->
			<xsl:call-template name="ActionCode">
				<xsl:with-param name="informationType" select="'Referral'"/>
				<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
			</xsl:call-template>
						
			<Referral>
				<!-- Referral Reason, PlacerId and FillerId -->
				<xsl:apply-templates select="hl7:entry[hl7:observation/hl7:code/@code='42349-1' and hl7:observation/hl7:code/@codeSystem=$loincOID]" mode="Referral-reason"/>
				
				<!-- Referring Provider -->
				
				<!-- ReferredTo Provider -->
				<xsl:apply-templates select="/hl7:ClinicalDocument/hl7:participant[@typeCode='REFT' and hl7:associatedEntity/@classCode='PROV']" mode="Referral-referredToProvider"/>
				
				<!-- ReferredTo Organization -->
				<xsl:apply-templates select="/hl7:ClinicalDocument/hl7:participant[@typeCode='REFT' and hl7:associatedEntity/@classCode='PROV']" mode="Referral-referredToOrganization"/>
				
				<!-- Validity Duration -->
				<xsl:apply-templates select="hl7:entry[hl7:observation/hl7:code/@code='103.16622' and hl7:observation/hl7:code/@codeSystem=$nctisOID]" mode="Referral-validityDuration"/>
				
				<!-- EnteredOn -->
				<xsl:apply-templates select="hl7:entry[hl7:observation/hl7:code/@code='103.16620' and hl7:observation/hl7:code/@codeSystem=$nctisOID]" mode="Referral-dateTime"/>
			</Referral>
		</Referrals>
	</xsl:template>
	
	<xsl:template match="*" mode="Referral-reason">
		<xsl:apply-templates select="hl7:observation/hl7:id" mode="Referral-id"/>
		<ReferralReason><xsl:value-of select="hl7:observation/hl7:value/text()"/></ReferralReason>
	</xsl:template>
	
	<xsl:template match="*" mode="Referral-id">
		<xsl:choose>
			<xsl:when test="contains(@assigningAuthorityName,'-PlacerId')">
				<PlacerId><xsl:apply-templates select="." mode="Id"/></PlacerId>
			</xsl:when>
			<xsl:when test="contains(@assigningAuthorityName,'-FillerId')">
				<FillerId><xsl:apply-templates select="." mode="Id"/></FillerId>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="Referral-validityDuration">
		<xsl:variable name="durationCode" select="substring(translate(hl7:observation/hl7:value/hl7:width/@unit,$lowerCase,$upperCase),1,1)"/>
		<xsl:variable name="durationDescription">
			<xsl:choose>
				<xsl:when test="$durationCode='D'">Days</xsl:when>
				<xsl:when test="$durationCode='W'">Weeks</xsl:when>
				<xsl:when test="$durationCode='M'">Months</xsl:when>
				<xsl:when test="$durationCode='Y'">Years</xsl:when>
				<xsl:otherwise><xsl:value-of select="$durationCode"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($durationCode) and string-length(hl7:observation/hl7:value/hl7:width/@value)">
			<ValidityDuration>
				<Code><xsl:value-of select="$durationCode"/></Code>
				<Description><xsl:value-of select="$durationDescription"/></Description>
				<Factor><xsl:value-of select="hl7:observation/hl7:value/hl7:width/@value"/></Factor>
			</ValidityDuration>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="Referral-dateTime">
		<xsl:apply-templates select="hl7:observation/hl7:value" mode="EnteredOn"/>
	</xsl:template>
	
	<xsl:template match="*" mode="Referral-referredToProvider">
		<ReferredToProvider><xsl:apply-templates select="." mode="DoctorDetail"/></ReferredToProvider>
	</xsl:template>
	
	<xsl:template match="*" mode="Referral-referredToOrganization">
		<xsl:apply-templates select="hl7:associatedEntity/hl7:associatedPerson" mode="HealthCareFacilityDetail">
			<xsl:with-param name="elementName" select="'ReferredToOrganization'"/>
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
