<?xml version="1.0" encoding="UTF-8"?>
<!-- 
RMD RemoveMetadataDocuments Audit Message (ITI-86) Audit for Repository
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
xmlns:rmd="urn:ihe:iti:rmd:2017"

exclude-result-prefixes="isc exsl hl7 lcm query rim rs xdsb xop xsi">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:include href="Base.xsl"/>

<!-- Globals used by the base stylesheet -->
<xsl:variable name="eventType" select="'ITI-86,IHE Transactions,Remove Documents'"/>
<xsl:variable name="status"    select="/Root/Response//rs:RegistryResponse/@status"/>
<xsl:variable name="isSource"  select="not($actor='XDSbRepository')"/>

<xsl:template match="/Root">
<Aggregation>

<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110110,DCM,PatientRecord'"/>
<xsl:with-param name="EventActionCode" select="'D'"/> 
</xsl:call-template>

<xsl:call-template name="Source"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>
<Documents>
<xsl:apply-templates select="Request/UniqueIdentifier"/>
</Documents>
</Aggregation>
</xsl:template>

<xsl:template match="UniqueIdentifier">
<Document>
	<DocumentID>
		<xsl:value-of select="@UniqueIdentifierKey"/>
	</DocumentID>
	<RepositoryID>
		<xsl:value-of select="text()"/>
	</RepositoryID>
</Document>
</xsl:template>

</xsl:stylesheet>
