<?xml version="1.0" encoding="UTF-8"?>
<!--
HS.Message.IHE.XCAI.RetrieveResponse -> ihe:RetrieveDocumentSetResponse 
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xdsb="urn:ihe:iti:xds-b:2007"
	xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
	xmlns:xop="http://www.w3.org/2004/08/xop/include"
	xmlns:isc="http://extension-functions.intersystems.com" 
	exclude-result-prefixes="isc">
	
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:include href="../../XDSI/Version1/RetrieveResponse-Export.xsl"/>

<xsl:template match="/">
	<xsl:apply-templates select="XCAI-RetrieveResponse" mode="RetrieveResponse"/>
</xsl:template>

</xsl:stylesheet>
