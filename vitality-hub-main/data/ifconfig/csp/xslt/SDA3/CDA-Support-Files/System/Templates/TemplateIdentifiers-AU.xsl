<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">
	<xsl:include href="TemplateIdentifiers-HITSP.xsl"/>
	<xsl:include href="TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="TemplateIdentifiers-IHE.xsl"/>
	<xsl:include href="TemplateIdentifiers-Other.xsl"/>
	
	<!-- NEHTA Document Templates -->
	<xsl:variable name="nehta-DischargeSummary">1.2.36.1.2001.1001.101.100.1002.4</xsl:variable>
	<xsl:variable name="nehta-eReferral">1.2.36.1.2001.1001.101.100.1002.2</xsl:variable>
	<xsl:variable name="nehta-eventSummary">1.2.36.1.2001.1001.101.100.1002.136</xsl:variable>
	<xsl:variable name="nehta-sharedHealthSummary">1.2.36.1.2001.1001.101.100.1002.120</xsl:variable>
	<xsl:variable name="nehta-specialistLetter">1.2.36.1.2001.1001.101.100.1002.132</xsl:variable>
	
	<xsl:variable name="nehta-renderingSpecification">1.2.36.1.2001.1001.100.149</xsl:variable>
</xsl:stylesheet>
