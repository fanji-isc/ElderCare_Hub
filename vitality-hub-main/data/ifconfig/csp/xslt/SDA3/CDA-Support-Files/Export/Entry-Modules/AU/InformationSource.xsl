<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc hl7 xsi">

	<xsl:template match="Patient" mode="informationSource">
		<!-- Author - NEHTA wants document-level author to be a human. -->
		<xsl:apply-templates select="EnteredBy" mode="author-Document"/>
		
		<!-- Informant -->
		<!-- Removed, as this template is not allowed in NEHTA CDA specification -->
		<!-- <xsl:apply-templates select="$homeCommunity/Organization" mode="informant"/> -->
		
		<!-- Custodian -->
		<xsl:apply-templates select="$homeCommunity/Organization" mode="custodian"/>

		<!-- Legal Authenticator -->
		<xsl:apply-templates select="$legalAuthenticator/Contact" mode="legalAuthenticator"/>
	</xsl:template>
</xsl:stylesheet>
