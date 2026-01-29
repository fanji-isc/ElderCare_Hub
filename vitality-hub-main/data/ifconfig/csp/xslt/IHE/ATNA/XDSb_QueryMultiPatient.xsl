<?xml version="1.0" encoding="UTF-8"?>
<!-- 
XDSb Multi-Patient Stored Query Audit Message (ITI-51) 
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
<xsl:variable name="eventType" select="'ITI-51,IHE Transactions,Multi-Patient Query'"/>
<xsl:variable name="status"    select="/Root/Response//query:AdhocQueryResponse/@status"/>
<!-- When XCA-RG queries a local registry, it must audit the XDSb_QueryRequest as an XDSb consumer -->
<xsl:variable name="isSource"  select="$actor='XDSbConsumer' or $actor='XCARespondingGateway'"/>

<xsl:template match="/Root">
<xsl:for-each select="Request//rim:Slot[@name='$XDSDocumentEntryPatientId' or @name='$XDSFolderPatientId']/rim:ValueList/rim:Value">
<xsl:apply-templates select="/Root" mode="singlePatientForMulti">
<xsl:with-param name="id" select="translate(text(),$sq,'')"/>
</xsl:apply-templates>
</xsl:for-each>
</xsl:template>

<!-- ITI-51 requires one patient per audit message. -->
<xsl:template match="*" mode="singlePatientForMulti">
<xsl:param name="id"/>
<Aggregation>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110112,DCM,Query'"/>
<xsl:with-param name="EventActionCode" select="'E'"/> 
</xsl:call-template>
<xsl:call-template name="Source"/>
<xsl:call-template name="HumanRequestor"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="$id"/>
</xsl:call-template>
<xsl:call-template name="QueryParameters"/> 
</Aggregation>
</xsl:template>

</xsl:stylesheet>
