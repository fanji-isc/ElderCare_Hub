<?xml version="1.0" encoding="UTF-8"?>
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
xmlns:a="http://www.w3.org/2005/08/addressing"
>
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<!-- used by the notification broker to transform subscription requests -->
<xsl:template match="/">
<xsl:variable name="apos" select='"&apos;"' />
<Subscription>
<RecipientAddress><xsl:value-of select='/wsnt:Subscribe/wsnt:ConsumerReference/a:Address/text()'/></RecipientAddress>
<TerminationTime><xsl:value-of select='wsnt:Subscribe/wsnt:InitialTerminationTime/text()'/></TerminationTime>
<Topic><xsl:value-of select='/wsnt:Subscribe/wsnt:Filter/wsnt:TopicExpression/text()'/></Topic>
<Type><xsl:value-of select='/wsnt:Subscribe/wsnt:Filter/rim:AdhocQuery/@id'/></Type>
<xsl:apply-templates select='/wsnt:Subscribe/wsnt:Filter/rim:AdhocQuery/rim:Slot'/>
</Subscription>
</xsl:template>

<xsl:template name="Item" match="rim:Slot">
<FilterItems>
<Item><xsl:value-of select='@name'/></Item>
<Values>
<xsl:for-each select='rim:ValueList/rim:Value'>
<ValuesItem><xsl:value-of select="text()"/></ValuesItem>
</xsl:for-each>
</Values>
</FilterItems>
</xsl:template>

</xsl:stylesheet>