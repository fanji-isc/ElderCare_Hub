<?xml version="1.0" encoding="UTF-8"?>
<!--
PDQv2 Patient Demographics Query Audit Message (ITI-21)
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
<xsl:variable name="eventType" select="'ITI-64,IHE Transactions,Notify XAD-PID Link Change'"/>

<xsl:param name="v2UserRoles" select="''"/>

<xsl:variable name="v2SendingApplication"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'SendingApplication'"/></xsl:call-template></xsl:variable>
<xsl:variable name="v2SendingFacility"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'SendingFacility'"/></xsl:call-template></xsl:variable>
<xsl:variable name="v2ReceivingApplication"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'ReceivingApplication'"/></xsl:call-template></xsl:variable>
<xsl:variable name="v2ReceivingFacility"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'ReceivingFacility'"/></xsl:call-template></xsl:variable>
<xsl:variable name="v2FromHost"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'FromHost'"/></xsl:call-template></xsl:variable>
<xsl:variable name="v2ToHost"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'ToHost'"/></xsl:call-template></xsl:variable>
<xsl:variable name="v2HL7Message"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'HL7Message'"/></xsl:call-template></xsl:variable>
<xsl:variable name="v2MSH10"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'MessageID'"/></xsl:call-template></xsl:variable>
<xsl:variable name="status"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'Status'"/></xsl:call-template></xsl:variable>
<xsl:variable name="mpiid"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'MPIID'"/></xsl:call-template></xsl:variable>
<xsl:variable name="priormpiid"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'PriorMPIID'"/></xsl:call-template></xsl:variable>
<xsl:variable name="mrn"><xsl:call-template name="getKeyValue"><xsl:with-param name="key" select="'MRN'"/></xsl:call-template></xsl:variable>

<xsl:variable name="isSource"  select="$actor='PIXManager'"/>

<xsl:template match="/Root">
<Aggregation>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110110,DCM,Patient Record'"/>
<xsl:with-param name="EventActionCode" select="'U'"/> 
</xsl:call-template>
<xsl:call-template name="Source"/>
<xsl:call-template name="HumanRequestor"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="$mrn"/>
<xsl:with-param name="name" select="' '"/>
</xsl:call-template>
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="$mpiid"/>
<xsl:with-param name="name" select="' '"/>
</xsl:call-template>
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="$priormpiid"/>
<xsl:with-param name="name" select="' '"/></xsl:call-template>

</Aggregation>

</xsl:template>


</xsl:stylesheet>
