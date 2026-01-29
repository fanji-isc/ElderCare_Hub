<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
xmlns:ihe="urn:ihe:iti:dsub:2009" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2"
>
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:include href="../../XDSb/Version1/Message-to-MetadataObject.xsl"/>

<xsl:template match="/">
<Metadata>
<xsl:apply-templates select="/wsnt:Notify/wsnt:NotificationMessage/wsnt:Message"/>
</Metadata>
</xsl:template>

<xsl:template match="/wsnt:Notify/wsnt:NotificationMessage/wsnt:ProducerReference">
</xsl:template>

<xsl:template match="/wsnt:Notify/wsnt:NotificationMessage/wsnt:SubscriptionReference">
</xsl:template>

<xsl:template match="/wsnt:Notify/wsnt:NotificationMessage/wsnt:Topic">
</xsl:template>

</xsl:stylesheet>
