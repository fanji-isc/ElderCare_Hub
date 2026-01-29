<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- EventReason parameter is accepted from HS.UI.Push.SendMessage.  Currently used for "Reason for Referral" only. -->
	<!-- EventReason is re-cast to match case-sensitivity conventions of the existing XSL. -->
	<xsl:param name="EventReason"/>
	<xsl:param name="eventReason" select="$EventReason"/>
	<xsl:param name="documentUniqueId" select="''"/>

	<!-- Global variable to hold the current date/time -->
	<xsl:variable name="currentDateTime" select="isc:evaluate('timestamp')"/>
	
	<!-- Global variable to hold the configuration found in the site's export profile -->
	<xsl:variable name="exportConfiguration" select="document('../../../Site/ExportProfile.xml')/exportConfiguration"/>
	
	<!-- Global variables to hold lower case string and upper case string -->
	<xsl:variable name="lowerCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	
	<!-- Global variables to hold required nullFlavor values -->
	<xsl:variable name="idNullFlavor" select="'UNK'"/>
	<xsl:variable name="addrNullFlavor" select="'UNK'"/>
	<xsl:variable name="confidentialityNullFlavor" select="'NI'"/>
	
	<!-- Global variable to hold valid LOINC vital sign codes. -->
	<xsl:variable name="loincVitalSignCodes">|9279-1|8867-4|2710-2|8480-6|8462-4|8310-5|8302-2|8306-3|8287-5|3141-9|</xsl:variable>
</xsl:stylesheet>
