<?xml version="1.0" encoding="UTF-8"?>
<!--
PIXv3 Patient Identity Feed Audit Message (ITI-44: Revise)
-->
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:exsl="http://exslt.org/common"
xmlns:hl7="urn:hl7-org:v3"
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
exclude-result-prefixes="isc hl7 exsl rim">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:include href="Base.xsl"/>

<!-- Globals used by the base stylesheet -->
<xsl:variable name="eventType" select="'ITI-44,IHE Transactions,Patient Identity Feed'"/>
<xsl:variable name="status"    select="/Root/Response//hl7:acknowledgement/hl7:typeCode/@code"/>
<xsl:variable name="isSource"  select="not($actor='PIXv3Manager')"/>
<xsl:variable name="v2SendingFacility" select="isc:evaluate('OIDtoCode',//hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient/hl7:providerOrganization/hl7:id/@root)"/>

<xsl:template match="/Root">
<Aggregation>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110110,DCM,Patient Record'"/>
<xsl:with-param name="EventActionCode" select="'U'"/> <!-- One patient is updated -->
</xsl:call-template>
<xsl:call-template name="Source"/>
<xsl:call-template name="HumanRequestor"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<xsl:apply-templates mode="Patient" select="Request//hl7:patient"/>
</Aggregation>

<Aggregation>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110110,DCM,Patient Record'"/>
<xsl:with-param name="EventActionCode" select="'D'"/> <!-- one patient is "deleted" -->
</xsl:call-template>
<xsl:call-template name="Source"/>
<xsl:call-template name="HumanRequestor"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="concat(Request//hl7:priorRegisteredRole/hl7:id/@extension,'^^^&amp;',Request//hl7:priorRegisteredRole/hl7:id/@root,'&amp;ISO')"/>
</xsl:call-template>
</Aggregation>
</xsl:template>

</xsl:stylesheet>
