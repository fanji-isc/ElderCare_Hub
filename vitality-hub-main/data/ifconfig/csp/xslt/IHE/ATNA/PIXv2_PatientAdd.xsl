<?xml version="1.0" encoding="UTF-8"?>
<!--
PIXv2 Patient Identity Feed Audit Message (ITI-8: Add)
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

<xsl:param name="v2SendingApplication" select="''"/>
<xsl:param name="v2SendingFacility" select="''"/>
<xsl:param name="v2ReceivingApplication" select="''"/>
<xsl:param name="v2ReceivingFacility" select="''"/>
<xsl:param name="v2UserRoles" select="''"/>
<xsl:param name="v2FromHost" select="''"/>
<xsl:param name="v2ToHost" select="''"/>
<xsl:param name="v2HL7Message" select="''"/>
<xsl:param name="v2MSH10" select="''"/>
<xsl:param name="v2Status" select="''"/>
<xsl:param name="v2Patients" select="''"/>

<!-- Globals used by the base stylesheet -->
<xsl:variable name="eventType" select="'ITI-8,IHE Transactions,Patient Identity Feed'"/>
<xsl:variable name="status"><xsl:value-of select="$v2Status"/></xsl:variable>
<xsl:variable name="isSource"  select="not($actor='PIXv2Manager')"/>

<xsl:template match="/Root">
<Aggregation>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110110,DCM,Patient Record'"/>
<xsl:with-param name="EventActionCode" select="'C'"/> 
</xsl:call-template>
<xsl:call-template name="Source"/>
<xsl:call-template name="HumanRequestor"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<xsl:apply-templates mode="PIXv2Patient" select=".">
<xsl:with-param name="patientString" select="$v2Patients"/>
</xsl:apply-templates>
</Aggregation>
</xsl:template>

</xsl:stylesheet>
