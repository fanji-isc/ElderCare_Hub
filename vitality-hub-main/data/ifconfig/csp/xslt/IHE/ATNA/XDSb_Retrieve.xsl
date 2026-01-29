<?xml version="1.0" encoding="UTF-8"?>
<!-- 
XDSb RetrieveDocumentSet-b Audit Message (ITI-43) 
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
<xsl:variable name="eventType" select="'ITI-43,IHE Transactions,Retrieve Document Set'"/>
<xsl:variable name="status"    select="/Root/Response//rs:RegistryResponse/@status"/>
<xsl:variable name="isSource"  select="$actor='XDSbConsumer' or $actor='XDSbOnDemandSource'"/>

<xsl:template match="/Root">
<Aggregation>

<xsl:choose>
<xsl:when test="$actor='XDSbConsumer' or $actor='XDSbOnDemandSource'">
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110107,DCM,Import'"/>
<xsl:with-param name="EventActionCode" select="'C'"/> 
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110106,DCM,Export'"/>
<xsl:with-param name="EventActionCode" select="'R'"/> 
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>

<SourceURI>
	<xsl:value-of select="$wsaTo"/>
</SourceURI>
<xsl:if test="not($actor='XDSbConsumer' or $actor='XDSbOnDemandSource')">
	<EnsembleSessionId><xsl:value-of select="$session"/></EnsembleSessionId>
</xsl:if>
<SourceNetworkAccess>
	<xsl:value-of select="$wsaToHost"/>
</SourceNetworkAccess>

<xsl:call-template name="HumanRequestor"/>

<DestinationURI>
	<xsl:value-of select="$wsaReplyToOrFrom"/>
</DestinationURI>
<xsl:if test="$actor='XDSbConsumer' or $actor='XDSbOnDemandSource'">
	<EnsembleSessionId><xsl:value-of select="$session"/></EnsembleSessionId>
</xsl:if>
<DestinationNetworkAccess>
	<xsl:value-of select="$wsaReplyToOrFromHost"/>
</DestinationNetworkAccess>

<xsl:call-template name="AuditSource"/>

<!-- As a consumer, HS will put the patientId into AdditionalInfo since XDSb Retrieve does not have one in the request or response but it is a required field for IHE -->
<!-- The Patient section is not part of the repository audit -->
<xsl:if test="$actor='XDSbConsumer' or $actor='XDSbOnDemandSource'">
<xsl:call-template name="Patient">
<xsl:with-param name="id">
<xsl:call-template name="getKeyValue">
<xsl:with-param name="key" select="'PatientId'"/>
</xsl:call-template>
</xsl:with-param>
</xsl:call-template>
</xsl:if>

<!-- Document -->
<xsl:for-each select="Response//xdsb:DocumentResponse">
	<xsl:call-template name="Document">
		<xsl:with-param name="DocumentID" select="xdsb:DocumentUniqueId/text()"/>
		<xsl:with-param name="RepositoryID" select="xdsb:RepositoryUniqueId/text()"/>
		<xsl:with-param name="HomeCommunityID">
			<xsl:choose>
				<xsl:when test="xdsb:HomeCommunityId">
					<xsl:value-of select="xdsb:HomeCommunityId/text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$homeCommunityOID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:for-each>

</Aggregation>
</xsl:template>
</xsl:stylesheet>
