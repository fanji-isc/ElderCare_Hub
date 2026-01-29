<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 sdtc xsi exsl">
	<!-- Match could be hl7:assignedEntity, hl7:author, hl7:informant -->
	<xsl:template match="hl7:author" mode="eAP-DocumentProvider">
		
		<!--
			StructuredMapping: DocumentProvider/Provider
			
			Field
			Path  : Name
			XPath : Name
			Source: assignedAuthor/assignedPerson
						
			Field
			Path  : Address
			XPath : Address
			Source: assignedAuthor/addr
			StructuredMappingRef: Address
			
			Field
			Path  : ContactInfo
			XPath : ContactInfo
			Source: assignedAuthor
			StructuredMappingRef: ContactInfo
		-->		
        <DocumentProvider>
          <Provider>
			<xsl:apply-templates select="hl7:time" mode="fn-I-timestamp">
				<xsl:with-param name="emitElementName" >EnteredOn</xsl:with-param>
			</xsl:apply-templates>
			<xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name" mode="fn-T-pName-ContactName"/>				
			<xsl:apply-templates select="hl7:assignedAuthor/hl7:addr" mode="fn-T-pName-address"/>
			<xsl:apply-templates select="hl7:assignedAuthor" mode="fn-T-pName-ContactInfo"/>
			<xsl:apply-templates select="hl7:assignedAuthor/hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" >ContactType</xsl:with-param>
			</xsl:apply-templates>
          </Provider>
        </DocumentProvider>          	
	</xsl:template>

</xsl:stylesheet>