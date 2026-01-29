<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2" xmlns:wsa="http://www.w3.org/2005/08/addressing" exclude-result-prefixes="isc exsl">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:template match="/SubscriptionRequest">
<wsnt:Subscribe 
	xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2" 
	xmlns:a="http://www.w3.org/2005/08/addressing" 
	xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0"> 
<wsnt:ConsumerReference>
<wsa:Address><xsl:value-of select="RecipientAddress/text()"/></wsa:Address> 
</wsnt:ConsumerReference> 
<wsnt:Filter>
<wsnt:TopicExpression Dialect="http://docs.oasis-open.org/wsn/t-1/TopicExpression/Simple"><xsl:value-of select="Topic/text()"/></wsnt:TopicExpression>
<xsl:variable name='PatientSlotName'>
<xsl:choose>
<xsl:when test="Type/text()='urn:uuid:aa2332d0-f8fe-11e0-be50-0800200c9a66'">$XDSDocumentEntryPatientId</xsl:when>
<xsl:when test="Type/text()='urn:uuid:9376254e-da05-41f5-9af3-ac56d63d8ebd'">$XDSFolderPatientId</xsl:when>
<xsl:when test="Type/text()='urn:uuid:fbede94e-dbdc-4f6b-bc1f-d730e677cece'">$XDSSubmissionSetPatientId</xsl:when>
</xsl:choose>
</xsl:variable>
<rim:AdhocQuery id="{Type/text()}">
<rim:Slot name="{$PatientSlotName}">
<rim:ValueList>
<rim:Value>'<xsl:value-of select="PatientID/text()"/>'</rim:Value>
</rim:ValueList>
</rim:Slot>

<xsl:for-each select='FilterItems'>
<rim:Slot name="{Item/text()}">
<rim:ValueList>
<xsl:for-each select='Values/ValuesItem'>
<rim:Value>('<xsl:value-of select="text()"/>')</rim:Value>
</xsl:for-each>
</rim:ValueList>
</rim:Slot>
</xsl:for-each>

</rim:AdhocQuery>
</wsnt:Filter>
<xsl:if test="TerminationTime/text()!=''">
<wsnt:InitialTerminationTime><xsl:value-of select="TerminationTime/text()"/></wsnt:InitialTerminationTime>
</xsl:if>
</wsnt:Subscribe>
</xsl:template>

</xsl:stylesheet>
