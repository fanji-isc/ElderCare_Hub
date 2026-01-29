<?xml version="1.0" encoding="UTF-8"?>
<!--
PIXv3 Query Audit Message (ITI-45)
NOTE: This implementation is a best guess based off the draft CP-ITI-474-01 document
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
<xsl:variable name="eventType" select="'ITI-45,IHE Transactions,PIXv3 Query'"/>
<xsl:variable name="status"    select="/Root/Response//hl7:acknowledgement/hl7:typeCode/@code"/>
<xsl:variable name="isSource"  select="$actor='PIXv3Consumer'"/>

<xsl:template match="/Root">
<Aggregation>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110112,DCM,Query'"/>
<xsl:with-param name="EventActionCode" select="'E'"/> 
</xsl:call-template>
<xsl:call-template name="Source"/>
<xsl:call-template name="HumanRequestor"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<xsl:if test="Response//hl7:patient">
<xsl:apply-templates mode="Patient" select="Request//hl7:queryByParameter"/>
</xsl:if>
<xsl:call-template name="QueryParameters"/> 
</Aggregation>
</xsl:template>

</xsl:stylesheet>
