<?xml version="1.0" encoding="UTF-8"?>
<!--
HS.Message.IHE.XDSI.RetrieveResponse -> ihe:RetrieveDocumentSetResponse 
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
	<xsl:apply-templates select="XDSI-RetrieveResponse" mode="RetrieveResponse"/>
</xsl:template>

<xsl:template match="*" mode="RetrieveResponse">
	<xdsb:RetrieveDocumentSetResponse>
		<rs:RegistryResponse>
			<xsl:attribute name="status">
				<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:', Status/text())" />
			</xsl:attribute>
			<xsl:apply-templates select="Errors"/>
		</rs:RegistryResponse> 
		<xsl:apply-templates select="DocumentResponses/DocumentResponse"/>			
	</xdsb:RetrieveDocumentSetResponse>
</xsl:template>

<xsl:template match="Errors">
	<rs:RegistryErrorList>
		<xsl:attribute name="highestSeverity">
			<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:', HighestError/text())" />
		</xsl:attribute>
		<xsl:apply-templates select="Error" />
	</rs:RegistryErrorList>
</xsl:template>

<xsl:template match="Error">
	<rs:RegistryError>
		<xsl:attribute name="codeContext">
			<xsl:value-of select="Description/text()"/>
		</xsl:attribute> 
		<xsl:attribute name="errorCode">
			<xsl:value-of select="Code/text()"/>
		</xsl:attribute> 
		<xsl:attribute name="location">
			<xsl:value-of select="Location/text()"/>
		</xsl:attribute> 
		<xsl:attribute name="severity">
			<xsl:value-of select="concat('urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:', Severity/text())" />
		</xsl:attribute> 
	</rs:RegistryError> 
</xsl:template>

<xsl:template match="DocumentResponse">
	<xdsb:DocumentResponse>
		<xsl:if test="string-length(HomeCommunityId/text()) > 0">
			<xdsb:HomeCommunityId>
				<xsl:value-of select= "concat('urn:oid:', HomeCommunityId/text())" />
			</xdsb:HomeCommunityId>
		</xsl:if>
		<xdsb:RepositoryUniqueId>
			<xsl:value-of select= "RepositoryUniqueId/text()" />
		</xdsb:RepositoryUniqueId>
		<xdsb:DocumentUniqueId>
			<xsl:value-of select= "DocumentUniqueId/text()" />
		</xdsb:DocumentUniqueId>
		<xdsb:mimeType>
			<xsl:value-of select= "MimeType/text()" />
		</xdsb:mimeType>
		<xdsb:Document>
			<xsl:choose>
				<!-- prefer attachments if both XOP and Body are not null -->
				<xsl:when test="string-length(XOP/text()) > 0">
					<xop:Include>
						<xsl:attribute name="href">
							<xsl:value-of select="concat('cid:', XOP/text())" />
						</xsl:attribute>
					</xop:Include>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="Body/text()" />
				</xsl:otherwise>
			</xsl:choose>
		</xdsb:Document>
	</xdsb:DocumentResponse>
</xsl:template>

</xsl:stylesheet>
