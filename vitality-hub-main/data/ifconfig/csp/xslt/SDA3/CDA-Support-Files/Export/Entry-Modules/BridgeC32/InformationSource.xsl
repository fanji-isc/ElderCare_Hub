<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc hl7 xsi">

	<xsl:template match="Patient" mode="informationSource">
		<!-- Document level Human author is handled differently  -->
		<!-- than the entry-level Human authors.  For now, omit  -->
		<!-- the person info and just use the organization info. -->
		<xsl:apply-templates select="$homeCommunity/Organization" mode="author-Document"/>
		
		<!-- Author (Software Device) -->
		<xsl:apply-templates select="$homeCommunity/Organization" mode="author-Device"/>
		
		<!-- Informant -->
		<xsl:apply-templates select="$homeCommunity/Organization" mode="informant"/>
		
		<!-- Custodian -->
		<xsl:apply-templates select="$homeCommunity/Organization" mode="custodian"/>

		<!-- Legal Authenticator -->
		<xsl:apply-templates select="$legalAuthenticator/Contact" mode="legalAuthenticator"/>
	</xsl:template>
</xsl:stylesheet>
