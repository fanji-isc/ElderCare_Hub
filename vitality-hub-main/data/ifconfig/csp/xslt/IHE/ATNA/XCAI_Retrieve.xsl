<?xml version="1.0" encoding="UTF-8"?>
<!-- 
XCAI Cross Gateway Retrieve Imaging Document Set [RAD-75] 
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
xmlns:iherad="urn:ihe:rad:xdsi-b:2009"
exclude-result-prefixes="isc exsl hl7 lcm query rim rs xdsb xop xsi iherad">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:include href="Base.xsl"/>

<!-- Globals used by the base stylesheet -->
<xsl:variable name="eventType" select="'RAD-75,IHE Transactions,Cross Gateway Retrieve Imaging Document Set'"/>
<xsl:variable name="status"    select="/Root/Response//rs:RegistryResponse/@status"/>
<xsl:variable name="isSource"  select="$actor='RespondingImagingGateway' or $actor='ImagingDocumentSource'"/>

<xsl:template match="/Root">

	<Aggregation>

	<!-- 
	EventIdentification
	-->
	<xsl:choose>
		<xsl:when test="$isSource">
			<xsl:call-template name="Event">
				<xsl:with-param name="EventID"         select="'110104,DCM,DICOM Instances Transferred'"/>
				<xsl:with-param name="EventActionCode" select="'R'"/> 
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="Event">
				<xsl:with-param name="EventID"         select="'110103,DCM,DICOM Instances Accessed'"/>
				<xsl:with-param name="EventActionCode" select="'R'"/> 
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>

	<!--
	Source (the imaging consumer or init-gw)
	-->
	<SourceURI>
		<xsl:value-of select="$wsaReplyToOrFrom"/>
	</SourceURI>
	<SourceNetworkAccess>
		<xsl:value-of select="$wsaReplyToOrFromHost"/>
	</SourceNetworkAccess>

	<EnsembleSessionId>
		<xsl:value-of select="$session"/>
	</EnsembleSessionId>

	<xsl:call-template name="HumanRequestor"/>

	<!--
	Destination (the imaging source or resp-gw)
	-->
	<DestinationURI>
		<xsl:value-of select="$wsaTo"/>
	</DestinationURI>
	<DestinationNetworkAccess>
		<xsl:value-of select="$wsaToHost"/>
	</DestinationNetworkAccess>

	<!-- 
	Audit Source
	-->
	<xsl:call-template name="AuditSource"/>

	<!-- 
	Patient
	
	XDS-I/XCA-I messages do not have a patient context, but the field is required 
	-->
	<Patients>
		<Patient>
			<IdentifierType>MPIID</IdentifierType>
		</Patient>
	</Patients>

	<!-- 
		Studies (using the Documents collection and exception in HS.IHE.ATNA.Repository.AggregationToDICOMAuditMessage)
	-->
	<xsl:for-each select="Request//iherad:StudyRequest">
		<xsl:call-template name="Document">
			<xsl:with-param name="DocumentID" select="@studyInstanceUID"/>
	 	</xsl:call-template>
	</xsl:for-each>

	</Aggregation>
</xsl:template>
</xsl:stylesheet>

