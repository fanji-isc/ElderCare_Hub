<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="isc hl7">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:param name="messageID"/>
<xsl:param name="receiverDeviceOID"/>
<xsl:param name="senderDeviceOID"/>
<xsl:param name="patientFirstName"/>
<xsl:param name="patientLastName"/>
<xsl:param name="facilityName"/>
<xsl:param name="creationTime"/>

<xsl:template match="//MergePatientRequest">
<xsl:variable name="assigningAuthority" select="isc:evaluate('CodetoOID',./AssigningAuthority/text())"/>
<xsl:variable name="mrn" select="./MRN/text()"/>
<xsl:variable name="priorAssigningAuthority" select="isc:evaluate('CodetoOID',./PriorAssigningAuthority/text())"/>
<xsl:variable name="priorMRN" select="./PriorMRN/text()"/>
<xsl:variable name="facility" select="isc:evaluate('CodetoOID',./Facility/text())"/>

<PRPA_IN201304UV02 xmlns="urn:hl7-org:v3"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
ITSVersion="XML_1.0">
<id root="{$messageID}"/>
<creationTime value="{$creationTime}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201304UV02"/>
<processingCode code="P"/>
<processingModeCode code="T"/>
<acceptAckCode code="AL"/>
<receiver typeCode="RCV">
<device classCode="DEV" determinerCode="INSTANCE">
<id root="{$receiverDeviceOID}"/>
</device>
</receiver>
<sender typeCode="SND">
<device classCode="DEV" determinerCode="INSTANCE">
<id root="{$senderDeviceOID}"/>
</device>
</sender>
<controlActProcess classCode="CACT" moodCode="EVN">
<code codeSystem="2.16.840.1.113883.1.6" code="PRPA_TE201304UV02"/>
<subject typeCode="SUBJ">
<registrationEvent classCode="REG" moodCode="EVN">
<id nullFlavor="NA"/>
<statusCode code="active"/>
<subject1 typeCode="SBJ">
<patient classCode="PAT">
<id root="{$assigningAuthority}" extension="{$mrn}"/>
<statusCode code="active"/>
<patientPerson>
<xsl:if test="($patientFirstName!='') or ($patientLastName!='')">
<name>
<xsl:if test="$patientFirstName !=''"><given><xsl:value-of select="$patientFirstName"/></given></xsl:if>
<xsl:if test="$patientLastName !=''"><family><xsl:value-of select="$patientLastName"/></family></xsl:if>
</name>
</xsl:if>
</patientPerson>
</patient>
</subject1>
<custodian typeCode="CST">
<assignedEntity classCode="ASSIGNED">
<id  root="{$facility}"/>
<assignedOrganization classCode="ORG" determinerCode="INSTANCE">
<name><xsl:value-of select="$facilityName"/></name>
</assignedOrganization>
</assignedEntity>
</custodian>
<replacementOf typeCode="RPLC">
<priorRegistration classCode="REG" moodCode="EVN">
<statusCode code="obsolete"/>
<subject1 typeCode="SBJ">
<priorRegisteredRole classCode="PAT">
<id root="{$priorAssigningAuthority}" extension="{$priorMRN}"/>
</priorRegisteredRole>
</subject1>
</priorRegistration>
</replacementOf>
</registrationEvent>
</subject>
</controlActProcess>
</PRPA_IN201304UV02>
</xsl:template>
</xsl:stylesheet>
