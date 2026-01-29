<?xml version="1.0" encoding="UTF-8"?>
<!-- used to convert a MetadataObject to a Notification (add the wrapper) registry -> publisher-->
<xsl:stylesheet 
version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
xmlns:ihe="urn:ihe:iti:xds-b:2007" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2"
xmlns:wsa="http://www.w3.org/2005/08/addressing"
>
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:include href="../../XDSb/Version1/MetadataObject-to-Message.xsl"/>

<xsl:param name="homeCommunityOID"/>
<xsl:param name="producerReference"/>

<xsl:template match="/">
<wsnt:Notify>
<wsnt:NotificationMessage>

<wsnt:ProducerReference>
<wsa:Address><xsl:value-of select="$producerReference"/></wsa:Address>
</wsnt:ProducerReference>
<wsnt:Message>
<xsl:apply-templates mode="lcmSubmitObjectsRequest" select="."/>
</wsnt:Message>
</wsnt:NotificationMessage>
</wsnt:Notify>
</xsl:template>


</xsl:stylesheet>
