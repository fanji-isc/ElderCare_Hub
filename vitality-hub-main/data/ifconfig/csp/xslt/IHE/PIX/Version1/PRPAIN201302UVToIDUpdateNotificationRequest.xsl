<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wrapper="http://wrapper.intersystems.com" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="isc wrapper hl7">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<!-- we use node because it could be a 201301 or 201302 -->
<xsl:template match="/*[local-name()]">
<xsl:variable name="registrationRoot" select="./hl7:controlActProcess/hl7:subject/hl7:registrationEvent"/>
<xsl:variable name="patientRoot" select="./hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient"/>
<xsl:variable name="patientPerson" select="$patientRoot/hl7:patientPerson"/>
<IDUpdateNotificationRequest>
<xsl:if test="count($patientRoot/hl7:id)>0 or count($patientPerson/hl7:asOtherIDs)>0">
<Identifiers>
<xsl:for-each select="$patientRoot/hl7:id">
<Identifier>
<Root><xsl:value-of select="isc:evaluate('getCodeForOID',@root,'',concat('Unknown OID:',@root))"/></Root>
<Extension><xsl:value-of select="@extension"/></Extension>
<AssigningAuthorityName><xsl:value-of select="isc:evaluate('getCodeForOID',@root,'',concat('Unknown OID:',@root))"/></AssigningAuthorityName>
<!-- <Use> will be set afterward by the PIX Consumer Process. -->
</Identifier>
</xsl:for-each>
<xsl:for-each select="$patientPerson/hl7:asOtherIDs">
<Identifier>
<Root><xsl:value-of select="isc:evaluate('getCodeForOID',hl7:id/@root,'',concat('Unknown OID:',hl7:id/@root))"/></Root>
<Extension><xsl:value-of select="hl7:id/@extension"/></Extension>
<AssigningAuthorityName><xsl:value-of select="isc:evaluate('getCodeForOID',hl7:id/@root,'',concat('Unknown OID:',hl7:id/@root))"/></AssigningAuthorityName>
<!-- <Use> will be set afterward by the PIX Consumer Process. -->
</Identifier>
</xsl:for-each>
</Identifiers>
</xsl:if>
<!-- prior ID is also in Additional info so that we can check the affinity domain -->
<PriorMPIID><xsl:value-of select="$registrationRoot/hl7:replacementOf/hl7:priorRegistration/hl7:subject1/hl7:priorRegisteredRole/hl7:id/@extension"/></PriorMPIID>
<AdditionalInfo>
<!-- prior id -->
<AdditionalInfoItem AdditionalInfoKey="priorID"><xsl:value-of select="$registrationRoot/hl7:replacementOf/hl7:priorRegistration/hl7:subject1/hl7:priorRegisteredRole/hl7:id/@root"/>_<xsl:value-of select="$registrationRoot/hl7:replacementOf/hl7:priorRegistration/hl7:subject1/hl7:priorRegisteredRole/hl7:id/@extension"/></AdditionalInfoItem>
</AdditionalInfo>
</IDUpdateNotificationRequest>


</xsl:template>

</xsl:stylesheet>
