<?xml version="1.0" encoding="UTF-8"?>
<!-- 
XDSb RegisterDocumentSet-b Audit Message (ITI-42) 
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
exclude-result-prefixes="isc exsl hl7 lcm query rim rs xdsb xop xsi">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:include href="Base.xsl"/>

<!-- Globals used by the base stylesheet -->
<xsl:variable name="eventType" select="'ITI-57,IHE Transactions,Update Document Set'"/>
<xsl:variable name="status"    select="/Root/Response//rs:RegistryResponse/@status"/>
<xsl:variable name="isSource"  select="not($actor='XDSbRegistry')"/>

<xsl:template match="/Root">
<Aggregation>

<xsl:choose>
<xsl:when test="$actor='XDSbRegistry'">
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110107,DCM,Import'"/>
<xsl:with-param name="EventActionCode" select="'U'"/> 
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110106,DCM,Export'"/>
<xsl:with-param name="EventActionCode" select="'U'"/> 
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>

<xsl:call-template name="Source"/>
<xsl:call-template name="HumanRequestor"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<xsl:apply-templates mode="Patient" select="Request//rim:RegistryPackage"/>
<xsl:apply-templates mode="SubmissionSet" select="Request//rim:RegistryPackage"/>

</Aggregation>
</xsl:template>
</xsl:stylesheet>
