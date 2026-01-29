<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- EventReason parameter is accepted from HS.UI.Push.SendMessage.  Currently used for "Reason for Referral" only. -->
	<!-- EventReason is re-cast to match case-sensitivity conventions of the existing XSL. -->
	<xsl:param name="EventReason"/>
	<xsl:param name="eventReason" select="$EventReason"/> 
	<xsl:param name="documentUniqueId" select="''"/>

	<!-- Global variable to hold the current date/time -->
	<xsl:variable name="currentDateTime" select="isc:evaluate('timestamp')"/>
	
	<!-- Global variable to hold the time zone offset -->
	<xsl:variable name="currentTimeZoneOffset">
		<xsl:choose>
			<xsl:when test="contains($currentDateTime,'-')">
				<xsl:value-of select="concat('-',substring-after($currentDateTime,'-'))"/>
			</xsl:when>
			<xsl:when test="contains($currentDateTime,'+')">
				<xsl:value-of select="concat('+',substring-after($currentDateTime,'+'))"/>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	
	<!-- Global variable to hold the configuration found in the site's export profile -->
	<xsl:variable name="exportConfiguration" select="document('../../../Site/ExportProfile.xml')/exportConfiguration"/>
	
	<!-- Global variables to hold lower case string and upper case string -->
	<xsl:variable name="lowerCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	
	<!-- Global variables to hold required nullFlavor values -->
	<xsl:variable name="idNullFlavor" select="'NA'"/>
	<xsl:variable name="addrNullFlavor" select="'NA'"/>
	<xsl:variable name="confidentialityNullFlavor" select="'NA'"/>
	
	<!-- Global variables to hold HI Service OID and prefixes -->
	<xsl:variable name="hiServiceOID" select="'1.2.36.1.2001.1003.0'"/>
	<xsl:variable name="ihiPrefix" select="'800360'"/>
	<xsl:variable name="hpiiPrefix" select="'800361'"/>
	<xsl:variable name="hpioPrefix" select="'800362'"/>
	
	<!-- Global variable to hold the UUID that is used for /ClinicalDocument/recordTarget/patientRole/id -->
	<xsl:variable name="patientRoleId" select="isc:evaluate('createUUID')"/>
	
	<!-- Global variable to hold valid LOINC vital sign codes. -->
	<xsl:variable name="loincVitalSignCodes">|9279-1|8867-4|2710-2|8480-6|8462-4|8310-5|8302-2|8306-3|8287-5|3141-9|</xsl:variable>
</xsl:stylesheet>
