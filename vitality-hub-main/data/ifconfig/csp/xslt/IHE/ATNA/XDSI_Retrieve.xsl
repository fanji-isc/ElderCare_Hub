<?xml version="1.0" encoding="UTF-8"?>
<!-- 
XDSI Cross Gateway Retrieve Imaging Document Set [RAD-69] 
-->
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:exsl="http://exslt.org/common"
xmlns:hl7="urn:hl7-org:v3"
xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007" 
xmlns:xop="http://www.w3.org/2004/08/xop/include"
xmlns:iherad="urn:ihe:rad:xdsi-b:2009"
exclude-result-prefixes="isc exsl hl7 lcm query rim rs xdsb xop xsi iherad">
<xsl:import href="XCAI_Retrieve.xsl"/>
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>

<xsl:variable name="eventType" select="'RAD-69,IHE Transactions,Retrieve Imaging Document Set'"/>
</xsl:stylesheet>