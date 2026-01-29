<?xml version="1.0" encoding="UTF-8"?>
<!--
HS.Message.IHE.XDSI.RetrieveRequest -> iherad:RetrieveImagingDocumentSetRequest 
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
	<xsl:apply-templates select="XDSI-RetrieveRequest" mode="RetrieveRequest"/>
</xsl:template>

<xsl:template match="*" mode="RetrieveRequest">
 	<iherad:RetrieveImagingDocumentSetRequest>
		<xsl:apply-templates select="Studies"/>
		<xsl:apply-templates select="TransferSyntaxes"/>			
	</iherad:RetrieveImagingDocumentSetRequest>
 </xsl:template>

<xsl:template match="Studies">
	<xsl:apply-templates select="StudyRequest"/>
</xsl:template>

<xsl:template match="StudyRequest">
	<iherad:StudyRequest>
		<xsl:attribute name="studyInstanceUID">
			<xsl:value-of select="StudyInstanceUID/text()"/>
		</xsl:attribute> 
		<xsl:apply-templates select="Series"/>
	</iherad:StudyRequest> 
</xsl:template>

<xsl:template match="Series">
	<xsl:apply-templates select="SeriesRequest"/>
</xsl:template>

<xsl:template match="SeriesRequest">
	<iherad:SeriesRequest>
		<xsl:attribute name="seriesInstanceUID">
			<xsl:value-of select="SeriesInstanceUID/text()"/>
		</xsl:attribute> 
		<xsl:apply-templates select="DocumentRequests"/>
	</iherad:SeriesRequest>
</xsl:template>

<xsl:template match="DocumentRequests">
	<xsl:apply-templates select="DocumentRequest"/>
</xsl:template>

<xsl:template match="DocumentRequest">
	<xdsb:DocumentRequest>
		<xsl:if test="string-length(HomeCommunityId/text()) > 0">
			<xdsb:HomeCommunityId>urn:oid:<xsl:value-of select="HomeCommunityId/text()"/></xdsb:HomeCommunityId>
		</xsl:if>
		<xdsb:RepositoryUniqueId><xsl:value-of select="RepositoryUniqueId/text()"/></xdsb:RepositoryUniqueId>
		<xdsb:DocumentUniqueId><xsl:value-of select="DocumentUniqueId/text()"/></xdsb:DocumentUniqueId>
	</xdsb:DocumentRequest>
</xsl:template>

<xsl:template match="TransferSyntaxes">
	<iherad:TransferSyntaxUIDList>
		<xsl:apply-templates select="TransferSyntax"/>						 
	</iherad:TransferSyntaxUIDList> 
</xsl:template>

<xsl:template match="TransferSyntax">
	<iherad:TransferSyntaxUID><xsl:value-of select="text()"/></iherad:TransferSyntaxUID>
</xsl:template>

</xsl:stylesheet>
