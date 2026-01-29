<?xml version="1.0" encoding="UTF-8"?>
<!--
xdsb:RetrieveDocumentSetResponse -> HS.Message.IHE.XDSI.RetrieveResponse  
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xdsb="urn:ihe:iti:xds-b:2007"
	xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
	xmlns:xop="http://www.w3.org/2004/08/xop/include"
	xmlns:isc="http://extension-functions.intersystems.com" 
	exclude-result-prefixes="isc">
	
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:template match="/">
	<xsl:apply-templates select="xdsb:RetrieveDocumentSetResponse"/>	
</xsl:template>

<xsl:template match="xdsb:RetrieveDocumentSetResponse">
	<XDSI-RetrieveResponse>
		<xsl:apply-templates select="." mode="RetrieveResponse"/>
	</XDSI-RetrieveResponse>
</xsl:template>

<xsl:template match="xdsb:RetrieveDocumentSetResponse" mode="RetrieveResponse">
	<xsl:apply-templates select="rs:RegistryResponse" />
	<DocumentResponses>
		<xsl:apply-templates select="xdsb:DocumentResponse" />
	</DocumentResponses>		
</xsl:template>

<xsl:template match="rs:RegistryResponse">
	<Status>
		<xsl:value-of select="substring-after(@status,'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:')"/>
	</Status>
	<xsl:apply-templates select="rs:RegistryErrorList"/>
</xsl:template>

<xsl:template match="rs:RegistryErrorList">
	<Errors>
		<HighestError>
			<xsl:value-of select="substring-after(@highestSeverity,'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:')"/>
		</HighestError>
		<xsl:apply-templates select="rs:RegistryError"/>
	</Errors>
</xsl:template>

<xsl:template match="rs:RegistryError">
	<Error>
		<Code>
			<xsl:value-of select="@errorCode"/>
		</Code>
		<Severity>
			<xsl:value-of select="substring-after(@severity,'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:')"/>
		</Severity>
		<Description>
			<xsl:value-of select="@codeContext"/>
		</Description>
		<Location>
			<xsl:value-of select="@location"/>
		</Location>
	</Error>
</xsl:template>
	
<xsl:template match="xdsb:DocumentResponse">
	<DocumentResponse>
		<HomeCommunityId>	
			<xsl:value-of select="substring-after(xdsb:HomeCommunityId/text(),'urn:oid:')"/>
		</HomeCommunityId>
		<RepositoryUniqueId>
			<xsl:value-of select="xdsb:RepositoryUniqueId/text()"/>
		</RepositoryUniqueId>
		<DocumentUniqueId>
			<xsl:value-of select="xdsb:DocumentUniqueId/text()"/>
		</DocumentUniqueId>
		<MimeType>
			<xsl:value-of select="xdsb:mimeType/text()"/>
		</MimeType>
		<xsl:choose>
			<xsl:when test="string-length(xdsb:Document/xop:Include/@href) > 0">
				<XOP>
					<xsl:value-of select="substring-after(xdsb:Document/xop:Include/@href,'cid:')"/>
				</XOP>
			</xsl:when>
			<xsl:otherwise>
				<Body>
					<xsl:value-of select="xdsb:Document/text()"/>
				</Body>
			</xsl:otherwise>
		</xsl:choose>
	</DocumentResponse>
</xsl:template>

</xsl:stylesheet>
