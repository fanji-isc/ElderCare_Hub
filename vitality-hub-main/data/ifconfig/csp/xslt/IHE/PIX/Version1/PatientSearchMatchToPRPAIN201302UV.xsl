<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:param name="creationTime"/>
<xsl:param name="messageID"/>
<xsl:param name="messageExtension"/>
<xsl:param name="receiverDeviceOID"/>
<xsl:param name="senderDeviceOID"/>
<xsl:param name="custodian" select="''"/>
<xsl:param name="custodianName" select="''"/>
<xsl:param name="PriorMPIID" select="''"/>

<xsl:template match="/PatientSearchMatch">
<PRPA_IN201302UV02 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  xmlns="urn:hl7-org:v3" ITSVersion="XML_1.0">
<id>
<xsl:if test="$messageID !=''"><xsl:attribute name="root"><xsl:value-of select="$messageID"/></xsl:attribute></xsl:if>
<xsl:if test="$messageExtension !=''"><xsl:attribute name="extension"><xsl:value-of select="$messageExtension"/></xsl:attribute></xsl:if>
</id>
<creationTime value='{$creationTime}'></creationTime>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201302UV02"/>
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
<code code="PRPA_TE201302UV02" codeSystem="2.16.840.1.113883.1.6"/>
<subject typeCode="SUBJ">
<registrationEvent classCode="REG" moodCode="EVN">
<id nullFlavor="NA"/>
<statusCode code="active"/>
<subject1 typeCode="SBJ">
<patient classCode="PAT">
<xsl:for-each select="Identifiers/Identifier">
<id root="{isc:evaluate('CodetoOID',Root)}" extension="{Extension}"/>
</xsl:for-each>
<statusCode code="active"/>	
<patientPerson classCode="PSN" determinerCode="INSTANCE">
<name>
<xsl:if test="FirstName/text()!=''"><given><xsl:value-of select="FirstName/text()"/></given></xsl:if>
<xsl:if test="LastName/text()!=''"><family><xsl:value-of select="LastName/text()"/></family></xsl:if>
</name>

<xsl:if test="Sex/text()!=''">
<administrativeGenderCode code="{Sex/text()}"/>
</xsl:if>
<xsl:if test="DOB/text()!=''">
<birthTime value="{isc:evaluate('dateNoDash',DOB/text())}"/>
</xsl:if>
<addr>
<xsl:if test="Street/text()!=''">
<streetAddressLine><xsl:value-of select="Street/text()"/></streetAddressLine>
</xsl:if>
<xsl:if test="City/text()!=''">
<city><xsl:value-of select="City/text()"/></city>
</xsl:if>
<xsl:if test="State/text()!=''">
<state><xsl:value-of select="State/text()"/></state>
</xsl:if>
<xsl:if test="Zip/text()!=''">
<postalCode><xsl:value-of select="Zip/text()"/></postalCode>
</xsl:if>
</addr>
</patientPerson>

<xsl:if test="string-length(Facility/text())">
<providerOrganization classCode="ORG" determinerCode="INSTANCE">
<id root="{isc:evaluate('CodetoOID',Facility/text())}"/>
<name><xsl:value-of select="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='FacilityName']/text()"/></name>
<contactParty classCode="CON">
<xsl:choose>
<xsl:when test="string-length(AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='FacilityTelephone']/text())">
<telecom value="tel:{AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='FacilityTelephone']/text()}"></telecom>
</xsl:when>
<xsl:otherwise><telecom nullFlavor="UNK"/></xsl:otherwise>
</xsl:choose>
</contactParty>
</providerOrganization>
</xsl:if>

</patient>
</subject1>
<xsl:if test="$PriorMPIID!=''">
<replacementOf>
<priorRegistration>
<subject1>
<priorRegisteredRole>
<id extension="{$PriorMPIID}" root="{isc:evaluate('CodetoOID',$custodian)}" /> 
</priorRegisteredRole>
</subject1>
</priorRegistration>
</replacementOf>
</xsl:if>
<custodian typeCode="CST">
<assignedEntity classCode="ASSIGNED">
<id root="{isc:evaluate('CodetoOID',$custodian)}"/>
<assignedOrganization classCode="ORG" determinerCode="INSTANCE">
<name><xsl:value-of select="$custodianName"/></name>
</assignedOrganization>
</assignedEntity>
</custodian>
</registrationEvent>
</subject>
</controlActProcess>
</PRPA_IN201302UV02>
</xsl:template>



</xsl:stylesheet>
