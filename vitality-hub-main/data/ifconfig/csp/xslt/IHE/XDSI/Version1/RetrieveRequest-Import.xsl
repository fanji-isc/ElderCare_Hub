<?xml version="1.0" encoding="UTF-8"?>
<!--
iherad:RetrieveImagingDocumentSetRequest -> HS.Message.IHE.XDSI.RetrieveRequest  
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xdsb="urn:ihe:iti:xds-b:2007"
	xmlns:iherad="urn:ihe:rad:xdsi-b:2009"
	xmlns:isc="http://extension-functions.intersystems.com" 
	exclude-result-prefixes="isc">
	
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:template match="/">
	<xsl:apply-templates select="iherad:RetrieveImagingDocumentSetRequest"/>
</xsl:template>

<xsl:template match="iherad:RetrieveImagingDocumentSetRequest">
	<XDSI-RetrieveRequest>
		<xsl:apply-templates select="." mode="RetrieveRequest"/>
	</XDSI-RetrieveRequest>
</xsl:template>

<xsl:template match="iherad:RetrieveImagingDocumentSetRequest" mode="RetrieveRequest">
	<Studies>
		<xsl:apply-templates select="iherad:StudyRequest"/>
	</Studies>
	<xsl:apply-templates select="iherad:TransferSyntaxUIDList"/>
</xsl:template>

<xsl:template match="iherad:StudyRequest">
	<StudyRequest>
		<StudyInstanceUID><xsl:value-of select="@studyInstanceUID"/></StudyInstanceUID>
		<Series>
			<xsl:apply-templates select="iherad:SeriesRequest"/>
		</Series>
	</StudyRequest> 
</xsl:template>

<xsl:template match="iherad:SeriesRequest">
	<SeriesRequest>
		<SeriesInstanceUID><xsl:value-of select="@seriesInstanceUID"/></SeriesInstanceUID>
		<DocumentRequests>
			<xsl:apply-templates select="xdsb:DocumentRequest"/>
		</DocumentRequests>		
	</SeriesRequest>
</xsl:template>

<xsl:template match="xdsb:DocumentRequest">
	<DocumentRequest>
		<HomeCommunityId><xsl:value-of select="substring-after(xdsb:HomeCommunityId/text(),'urn:oid:')"/></HomeCommunityId>
		<RepositoryUniqueId><xsl:value-of select="xdsb:RepositoryUniqueId/text()"/></RepositoryUniqueId>
		<DocumentUniqueId><xsl:value-of select="xdsb:DocumentUniqueId/text()"/></DocumentUniqueId>
	</DocumentRequest>
</xsl:template>

<xsl:template match="iherad:TransferSyntaxUIDList">
	<TransferSyntaxes>
		<xsl:apply-templates select="iherad:TransferSyntaxUID"/>
	</TransferSyntaxes>
</xsl:template>

<xsl:template match="iherad:TransferSyntaxUID">
	<TransferSyntax><xsl:value-of select="text()"/></TransferSyntax>
</xsl:template>

</xsl:stylesheet>
