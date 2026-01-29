<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2"
xmlns:wsa="http://www.w3.org/2005/08/addressing"
>
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:include href="../../XDSb/Version1/MetadataObject-to-Message.xsl"/>

<xsl:param name="subscriptionAddress"/>
<xsl:param name="topic"/>
<xsl:param name="homeCommunityOID"/>
<xsl:param name="producerReference"/>

<xsl:template match="/">
<wsnt:Notify>
<wsnt:NotificationMessage>
<wsnt:SubscriptionReference>
<wsa:Address><xsl:value-of select='$subscriptionAddress'/></wsa:Address>
<!-- are full and minimal different -->
</wsnt:SubscriptionReference>
<xsl:if test="$topic='M'">
<xsl:call-template name="Minimal"/>
</xsl:if>
<xsl:if test="$topic='F'">
<xsl:call-template name='Full'/>
</xsl:if>
<xsl:if test="$topic='S'">
<xsl:call-template name='SubmissionSet'/>
</xsl:if>
</wsnt:NotificationMessage>
</wsnt:Notify>
</xsl:template>


<xsl:template name="Minimal">
<xsl:variable name="top" select="Metadata"/>
<wsnt:Topic Dialect="http://docs.oasis-open.org/wsn/t-1/TopicExpression/Simple">ihe:MinimalDocumentEntry</wsnt:Topic>
<wsnt:ProducerReference>
<wsa:Address><xsl:value-of select="$producerReference"/></wsa:Address>
</wsnt:ProducerReference>
<wsnt:Message>
<lcm:SubmitObjectsRequest>
<rim:RegistryObjectList>
<xsl:for-each select="$top/Document">
<rim:ObjectRef id="{@id}" />
</xsl:for-each>
<xsl:for-each select="$top/Folder">
<rim:ObjectRef id="{@id}" />
</xsl:for-each>
<!--
<xsl:for-each select="$top/Submission">
<rim:ObjectRef id="{@id}" />
</xsl:for-each>
<xsl:for-each select="$top/Association">
<rim:ObjectRef id="{@id}" />
</xsl:for-each>
-->
</rim:RegistryObjectList>
</lcm:SubmitObjectsRequest>
</wsnt:Message>
</xsl:template>

<xsl:template name="Full">
<wsnt:Topic Dialect="http://docs.oasis-open.org/wsn/t-1/TopicExpression/Simple">ihe:FullDocumentEntry</wsnt:Topic>
<wsnt:ProducerReference>
<wsa:Address><xsl:value-of select="$producerReference"/></wsa:Address>
</wsnt:ProducerReference>
<wsnt:Message>
 <xsl:apply-templates select='Metadata' mode='lcmSubmitObjectsRequest'/>
</wsnt:Message>
</xsl:template>

<xsl:template name="SubmissionSet">
<wsnt:Topic Dialect="http://docs.oasis-open.org/wsn/t-1/TopicExpression/Simple">ihe:SubmissionSetMetadata</wsnt:Topic>
<wsnt:ProducerReference>
<wsa:Address><xsl:value-of select="$producerReference"/></wsa:Address>
</wsnt:ProducerReference>
<wsnt:Message>
 <xsl:apply-templates select='Metadata' mode='lcmSubmitObjectsRequest'/>
</wsnt:Message>
</xsl:template>

</xsl:stylesheet>
