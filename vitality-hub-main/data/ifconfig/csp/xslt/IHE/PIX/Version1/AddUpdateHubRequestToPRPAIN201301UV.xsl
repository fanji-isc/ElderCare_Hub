<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns="urn:hl7-org:v3" 
xmlns:isc="http://extension-functions.intersystems.com" 
version="1.0" 
exclude-result-prefixes="isc" >

<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:param name="receiverDeviceOID"/>
<xsl:param name="senderDeviceOID"/>
<xsl:param name="messageID" select="''"/>
<xsl:param name="creationTime" select="''"/>


<xsl:template match="/AddUpdateHubRequest">	

<xsl:choose>
<xsl:when test="AddOrUpdate='U'">
<PRPA_IN201302UV02 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" ITSVersion="XML_1.0">
<id root="{$messageID}"/>
<creationTime value="{$creationTime}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201302UV02"/>
<xsl:apply-templates select="." mode="body"/>
</PRPA_IN201302UV02>
</xsl:when>
<xsl:otherwise>
<PRPA_IN201301UV02 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" ITSVersion="XML_1.0">
<id root="{$messageID}"/>
<creationTime value="{$creationTime}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201301UV02"/>
<xsl:apply-templates select="." mode="body"/>
</PRPA_IN201301UV02>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="*" mode="body">
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
<xsl:choose>
<xsl:when test="AddOrUpdate='U'">
<code codeSystem="2.16.840.1.113883.1.6" code="PRPA_TE201302UV02"/>
</xsl:when>
<xsl:otherwise>
<code codeSystem="2.16.840.1.113883.1.6" code="PRPA_TE201301UV02"/>
</xsl:otherwise>
</xsl:choose>
<subject typeCode="SUBJ" contextConductionInd="false">
<registrationEvent  classCode="REG" moodCode="EVN">
<id nullFlavor="NA"/>
<statusCode code="active"/>
<subject1 typeCode="SBJ">
<patient classCode="PAT">
<id root="{isc:evaluate('CodetoOID',./AssigningAuthority/text())}" extension="{./MRN/text()}"/>
<statusCode code="active"/>
<patientPerson classCode="PSN" determinerCode="INSTANCE">
<xsl:variable name="familyAtBirth"><xsl:value-of select="./Names/PersonName/Type[text()='Birth']/../Family/text()"/></xsl:variable>
<xsl:variable name="givenAtBirth"><xsl:value-of select="./Names/PersonName/Type[text()='Birth']/../Given/text()"/></xsl:variable>
<xsl:variable name="prefixAtBirth"><xsl:value-of select="./Names/PersonName/Type[text()='Birth']/../Prefix/text()"/></xsl:variable>
<name>
<xsl:if test="Prefix/text()!='' or $prefixAtBirth!=''">
<prefix>
<xsl:choose>
<xsl:when test="Prefix/text()!='' and (Prefix/text()=$prefixAtBirth)">
<xsl:attribute name="qualifier">BR</xsl:attribute>
<xsl:value-of select='Prefix/text()'/>
</xsl:when>
<xsl:when test="Prefix/text()!=''">
<xsl:value-of select='Prefix/text()'/>
</xsl:when>
<xsl:when test="$prefixAtBirth!=''">
<xsl:attribute name="qualifier">BR</xsl:attribute>
<xsl:value-of select='$prefixAtBirth'/>
</xsl:when>
</xsl:choose>
</prefix>
</xsl:if>

<xsl:if test="FirstName/text()!='' or $givenAtBirth!=''">
<given>
<xsl:choose>
<xsl:when test="FirstName/text()!='' and (FirstName/text()=$givenAtBirth)">
<xsl:attribute name="qualifier">BR</xsl:attribute>
<xsl:value-of select='FirstName/text()'/>
</xsl:when>
<xsl:when test="FirstName/text()!=''">
<xsl:value-of select='FirstName/text()'/>
</xsl:when>
<xsl:when test="$givenAtBirth!=''">
<xsl:attribute name="qualifier">BR</xsl:attribute>
<xsl:value-of select='$givenAtBirth'/>
</xsl:when>
</xsl:choose>
</given>
</xsl:if>

<xsl:if test="./MiddleName/text()!=''"><given><xsl:value-of select='./MiddleName/text()'/></given></xsl:if>

<xsl:if test="LastName/text()!='' or $familyAtBirth!=''">
<xsl:choose>
<xsl:when test="LastName/text()!='' and (LastName/text()=$familyAtBirth)">
<family qualifier="BR">
<xsl:value-of select='LastName/text()'/>
</family>
</xsl:when>
<xsl:when test="LastName/text()!=''">
<family>
<xsl:value-of select='LastName/text()'/>
</family>
<xsl:if test="$familyAtBirth!=''">
<family qualifier="BR">
<xsl:value-of select='$familyAtBirth'/>
</family>
</xsl:if>
</xsl:when>
<xsl:when test="$familyAtBirth!=''">
<family>
<xsl:attribute name="qualifier">BR</xsl:attribute>
<xsl:value-of select='$familyAtBirth'/>
</family>
</xsl:when>
</xsl:choose>
</xsl:if>

<xsl:if test="./Suffix/text()!=''"><suffix><xsl:value-of select='./Suffix/text()'/></suffix></xsl:if>
</name>

<xsl:for-each select="./Names/PersonName">
<xsl:call-template name="personNames"/>
</xsl:for-each>

<xsl:for-each select='Telecoms/Telecom'>
<telecom value="{concat('tel:', PhoneNumberFull/text())}" use="{Use/text()}"/>
</xsl:for-each>
<xsl:if test="Sex/text()!=''"><administrativeGenderCode code="{./Sex/text()}"/></xsl:if>
<xsl:if test="DOB/text()!=''"><birthTime value="{isc:evaluate('dateNoDash',DOB/text())}"/></xsl:if>
<xsl:for-each select='Addresses/Address'>
<addr>
<xsl:if test="Use/text()!=''">
<xsl:attribute name="use"><xsl:value-of select="Use/text()"/></xsl:attribute>
</xsl:if>
<xsl:if test="StreetLine/text()!=''"><streetAddressLine><xsl:value-of select="StreetLine/text()"/></streetAddressLine></xsl:if>
<xsl:if test="City/text()!=''"><city><xsl:value-of select="City/text()"/></city></xsl:if>
<xsl:if test="State/text()!=''"><state><xsl:value-of select="State/text()"/></state></xsl:if>
<xsl:if test="PostalCode/text()!=''"><postalCode><xsl:value-of select="PostalCode/text()"/></postalCode></xsl:if>
<xsl:if test="Country/text()!=''"><country><xsl:value-of select="Country/text()"/></country></xsl:if>
</addr>
</xsl:for-each>
<xsl:for-each select="Identifiers/Identifier">
<xsl:if test="Root/text()!=''">
<asOtherIDs classCode = 'OTHR'>
<id root="{isc:evaluate('CodetoOID',Root/text())}" extension="{Extension/text()}"/>
<scopingOrganization classCode="ORG" determinerCode="INSTANCE">
<id root="{isc:evaluate('CodetoOID',Root/text())}"/>
</scopingOrganization>
</asOtherIDs>
</xsl:if>
</xsl:for-each>
<xsl:if test="MothersName">
<xsl:call-template name="personalRelationship">
<xsl:with-param name="property" select="MothersName"/>
<xsl:with-param name="type" select="'MTH'"/>
</xsl:call-template>
</xsl:if>
<xsl:if test="FathersName">
<xsl:call-template name="personalRelationship">
<xsl:with-param name="property" select="FathersName"/>
<xsl:with-param name="type" select="'FTH'"/>
</xsl:call-template>
</xsl:if>
<xsl:if test="SpousesName">
<xsl:call-template name="personalRelationship">
<xsl:with-param name="property" select="SpousesName"/>
<xsl:with-param name="type" select="'SPS'"/>
</xsl:call-template>
</xsl:if>
</patientPerson>

<providerOrganization classCode="ORG" determinerCode="INSTANCE">
<id root="{isc:evaluate('CodetoOID',Facility/text())}"/>
<name><xsl:value-of select="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='FacilityName']/text()"/></name>
<contactParty classCode="CON">
<telecom value="tel:{AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='FacilityTelephone']/text()}"></telecom>
</contactParty>
</providerOrganization>
</patient>
</subject1>
<custodian typeCode="CST">
<assignedEntity classCode="ASSIGNED">
<id root="{isc:evaluate('CodetoOID',AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='AffinityDomain']/text())}"/>
<assignedOrganization classCode="ORG" determinerCode="INSTANCE">
<name><xsl:value-of select="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='AffinityDomainName']/text()"/></name>
</assignedOrganization>   
</assignedEntity>
</custodian>
</registrationEvent>
</subject>
</controlActProcess>
</xsl:template>

<xsl:template name="personNames">
<!-- If including other types, we don't want to include Birth as that is done in the primary name section -->
<xsl:if test="Type/text() = 'Alias'">
<name>
<xsl:attribute name="use">A</xsl:attribute>
<xsl:if test="./Prefix/text()!=''"><prefix><xsl:value-of select='./Prefix/text()'/></prefix></xsl:if>
<given><xsl:value-of select='./Given/text()'/></given>
<xsl:if test="./MiddleName/text()!=''"><given><xsl:value-of select='./MiddleName/text()'/></given></xsl:if>
<family>
<xsl:value-of select='./Family/text()'/></family>
<xsl:if test="./Suffix/text()!=''"><suffix><xsl:value-of select='./Suffix/text()'/></suffix></xsl:if>
</name>
</xsl:if>
</xsl:template>

<xsl:template name="personalRelationship">
<xsl:param name="property"/>
<xsl:param name="type"/>
<personalRelationship classCode="PRS">
<code code="{$type}" codeSystem="2.16.840.1.113883.5.111" codeSystemName="PersonalRelationshipRoleType"/>
<relationshipHolder1 classCode="PSN" determinerCode="INSTANCE">
<name>
<xsl:if test="$property/Prefix/text()!=''"><prefix><xsl:value-of select='$property/Prefix/text()'/></prefix></xsl:if>
<xsl:if test="$property/Given/text()!=''"><given><xsl:value-of select='$property/Given/text()'/></given></xsl:if>
<xsl:if test="$property/Middle/text()!=''"><given><xsl:value-of select='$property/Middle/text()'/></given></xsl:if>
<xsl:if test="$property/Family/text()!=''"><family><xsl:value-of select='$property/Family/text()'/></family></xsl:if>
<xsl:if test="$property/Suffix/text()!=''"><suffix><xsl:value-of select='$property/Suffix/text()'/></suffix></xsl:if>
</name>
</relationshipHolder1>
</personalRelationship>
</xsl:template>

</xsl:stylesheet>
