<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl isc">

	<xsl:template match="*" mode="nonXMLBody">
		<xsl:if test="Documents">
			<xsl:for-each select="Documents/Document">
				<xsl:variable name="mediaType">
					<xsl:choose>
						<xsl:when test="contains(FileType/text(), 'DOC')">application/msword</xsl:when>
						<xsl:when test="contains(FileType/text(), 'PDF')">application/pdf</xsl:when>
						<xsl:when test="contains(FileType/text(), 'RTF')">text/rtf</xsl:when>
						<xsl:when test="not(string-length(DocumentURL/text()))">text/plain</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="representation">
					<xsl:choose>
						<xsl:when test="contains(FileType/text(), 'DOC')">B64</xsl:when>
						<xsl:when test="contains(FileType/text(), 'PDF')">B64</xsl:when>
						<xsl:when test="contains(FileType/text(), 'RTF')">B64</xsl:when>
						<xsl:when test="not(string-length(DocumentURL/text()))">TXT</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<component>
					<nonXMLBody>
						<xsl:choose>
							<!-- Stream of unstructured data -->
							<xsl:when test="string-length($mediaType)">
								<text mediaType="{$mediaType}" representation="{$representation}">
									<xsl:choose>
										<xsl:when test="($representation = 'B64')"><xsl:value-of select="Stream/text()"/></xsl:when>
										<xsl:when test="($representation = 'TXT')"><xsl:value-of select="NoteText/text()"/></xsl:when>
									</xsl:choose>
								</text>
							</xsl:when>
							<!-- Reference to unstructured data -->
							<xsl:when test="string-length(DocumentURL/text())">
								<text>
									<reference value="{DocumentURL/text()}"/>
								</text>
							</xsl:when>
						</xsl:choose>
					</nonXMLBody>
				</component>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
