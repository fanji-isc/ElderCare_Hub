<?xml version="1.0" encoding="UTF-8"?>
<!-- 
DSUB Subscribe Audit Message (ITI-52) 
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
xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2"
exclude-result-prefixes="isc exsl hl7 lcm query rim rs xdsb xop xsi wsnt">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:include href="Base.xsl"/>

<!-- Globals used by the base stylesheet -->
<xsl:variable name="eventType" select="'ITI-52,IHE Transactions,Document Metadata Subscribe'"/>
<xsl:variable name="isSource"  select="($actor='DocumentMetadataSubscriber')"/>
<xsl:variable name="status" select="'AA'"/>

<xsl:template match="/Root">
<Aggregation>

<xsl:call-template name="Event">
<xsl:with-param name="EventID" select="'110112,DCM,Query'"/>
<xsl:with-param name="EventActionCode" select="'D'"/> 
</xsl:call-template>

<xsl:call-template name="Source"/>
<xsl:call-template name="HumanRequestor"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<xsl:apply-templates mode="Patient" select="Request/AdditionalInfo"/>
<AdditionalInfo>
<AdditionalInfoItem AdditionalInfoKey="SubscriptionAddress"><xsl:value-of select="Request/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='Address']/text()"/></AdditionalInfoItem>
</AdditionalInfo>
</Aggregation>
</xsl:template>

</xsl:stylesheet>
