<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="*" mode="sNRS-nonXMLBody">
		<xsl:if test="Documents">

			<xsl:for-each select="Documents/Document">

				<!-- Media types supoorted -->
				<xsl:variable name="mediaType">
					<xsl:choose>
						<xsl:when test="contains(FileType, 'MSWORD')">application/msword</xsl:when>
						<xsl:when test="contains(FileType, 'PDF')">application/pdf</xsl:when>
						<xsl:when test="contains(FileType, 'Plain')">text/plain</xsl:when>						
						<xsl:when test="contains(FileType, 'RTF')">text/rtf</xsl:when>
						<xsl:when test="contains(FileType, 'HTML')">text/html</xsl:when>			
						<xsl:when test="contains(FileType, 'GIF')">image/gif</xsl:when>	
						<xsl:when test="contains(FileType, 'TIF')">image/tiff</xsl:when>			
						<xsl:when test="contains(FileType, 'JPEG')">image/jpeg</xsl:when>		
						<xsl:when test="contains(FileType, 'PNG')">image/png</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<component>
					<nonXMLBody>
						<text>
							<xsl:choose>
								<xsl:when test="DocumentURL">		
									<!-- Reference to unstructured data file -->	
									<reference value="{DocumentURL}"/>
								</xsl:when>		
								<xsl:otherwise>
									<!-- Stream of unstructured data -->										
									<xsl:if test="string-length($mediaType)">
										<!-- Only process supported media type -->	
										<xsl:attribute name="mediaType"><xsl:value-of select="$mediaType"/></xsl:attribute>
										<!-- representation can only be B64 when media is supported -->										
										<xsl:attribute name="representation">B64</xsl:attribute>									
										<xsl:value-of select="Stream"/>	
									</xsl:if>	
								</xsl:otherwise>
							</xsl:choose>		
						</text>		
					</nonXMLBody>
				</component>

			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>