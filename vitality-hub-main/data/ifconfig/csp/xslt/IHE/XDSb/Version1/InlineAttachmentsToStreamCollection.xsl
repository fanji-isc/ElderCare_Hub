<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xop="http://www.w3.org/2004/08/xop/include">
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
	
	
	<xsl:template match="/">
		<XMLMessage>
			<Name><xsl:value-of select="XMLMessage/Name/text()"/></Name>
			<!-- Content Stream-->
			<!--<xsl:copy-of select="/XMLMessage/ContentStream" xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0"/>-->
			<xsl:apply-templates select="XMLMessage/ContentStream" mode="copyNode"/>
			<!--AdditionalData-->
			<xsl:copy-of select="/XMLMessage/AdditionalInfo"/>
			
			<!--StreamCollection-->
			<StreamCollection>
				<xsl:apply-templates mode="InlineStream" select="//node()[not(xop:Include) and local-name()='Document']"/>
				<xsl:apply-templates mode="StreamCopy" select="/XMLMessage/StreamCollection"></xsl:apply-templates>
			</StreamCollection>
				
			<!--SAML Data-->
			<xsl:copy-of select="/XMLMessage/SAMLData"/>
		
		</XMLMessage>
	</xsl:template>
	<xsl:template mode="StreamCopy" match="*">
		<xsl:copy-of select="MIMEAttachment"/>
	</xsl:template>
	<xsl:template match="*" mode="InlineStream">
		<xsl:variable name="docId"><xsl:value-of select="@id"/></xsl:variable>
		<xsl:variable name="contentType">
			<xsl:value-of select="//rim:ExtrinsicObject[@id=$docId]/@mimeType"/>
		</xsl:variable>
		<MIMEAttachment>
			<ContentId><xsl:value-of select="$docId"/></ContentId>
			<ContentType><xsl:value-of select="$contentType"/></ContentType>
			<ContentTransferEncoding>7bit</ContentTransferEncoding>
			<Body><xsl:value-of select="text()"/></Body>
		</MIMEAttachment>
	</xsl:template>
	<xsl:template mode="ContentStream" match="*">
		<xsl:apply-templates select="node()" mode="copyNode"/>	
	</xsl:template>
	<xsl:template mode="copyNode" match="@* | node()">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="local-name()='Document' and not(node()[local-name()='Include'])">
					<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
					<xop:Include href="cid:{@id}" xmlns:xop="http://www.w3.org/2004/08/xop/include" />
				</xsl:when>
				<xsl:when test="local-name()='Document' and node()[local-name()='Include']">
					<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
					<xsl:copy-of select="*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="copyNode" select="@* | node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>