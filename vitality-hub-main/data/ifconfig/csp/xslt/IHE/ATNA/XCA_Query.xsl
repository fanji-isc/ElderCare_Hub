<?xml version="1.0" encoding="UTF-8"?>
<!-- 
XCA CrossGatewayQuery Audit Message (ITI-38) 
-->

<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:exsl="http://exslt.org/common"
xmlns:hl7="urn:hl7-org:v3"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
exclude-result-prefixes="isc hl7 exsl rim xsi query">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:include href="Base.xsl"/>

<!-- Globals used by the base stylesheet -->
<xsl:variable name="eventType" select="'ITI-38,IHE Transactions,Cross Gateway Query'"/>
<xsl:variable name="status"    select="/Root/Response//query:AdhocQueryResponse/@status"/>
<xsl:variable name="isSource"  select="$actor='XCAInitiatingGateway'"/>

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
<xsl:apply-templates mode="Patient" select="Request//rim:AdhocQuery"/>
<xsl:call-template name="QueryParameters"/> 
</Aggregation>
</xsl:template>

</xsl:stylesheet>
