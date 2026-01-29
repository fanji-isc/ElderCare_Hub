<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" 
version="1.0" xmlns:hl7="urn:hl7-org:v3" xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:param name="ackTypeCode" select="'AA'"/>
<xsl:param name="homeCommunityOID" select="''"/>
<xsl:param name="queryStatus" select="''"/>
<xsl:param name="resultQuantity" select="'0'"/>
<xsl:param name="resultQuantityInitial" select="'0'"/>
<xsl:param name="resultQuantityRemaining" select="'0'"/>
<xsl:param name="XCPD" select="'0'"/>
<xsl:param name="messageID" select="''"/>
<xsl:param name="creationTime" select="''"/>

<xsl:variable name="targetMessageID">
<xsl:choose>
<xsl:when test="/root/request/hl7:PRPA_IN201305UV02">
<xsl:value-of select="/root/request/hl7:PRPA_IN201305UV02/hl7:id/@root"/>
</xsl:when>
<xsl:when test="/root/request/hl7:QUQI_IN000003UV01">
<xsl:value-of select="/root/request/hl7:QUQI_IN000003UV01/hl7:id/@root"/>
</xsl:when>
</xsl:choose>
</xsl:variable>
<xsl:variable name="targetMessageExtension">
<xsl:choose>
<xsl:when test="/root/request/hl7:PRPA_IN201305UV02">
<xsl:value-of select="/root/request/hl7:PRPA_IN201305UV02/hl7:id/@extension"/>
</xsl:when>
<xsl:when test="/root/request/hl7:QUQI_IN000003UV01">
<xsl:value-of select="/root/request/hl7:QUQI_IN000003UV01/hl7:id/@extension"/>
</xsl:when>
</xsl:choose>
</xsl:variable>
<xsl:variable name="queryID" select="/root/originalRequest/hl7:PRPA_IN201305UV02/hl7:controlActProcess/hl7:queryByParameter/hl7:queryId/@root"/>
<xsl:variable name="queryExtension" select="/root/originalRequest/hl7:PRPA_IN201305UV02/hl7:controlActProcess/hl7:queryByParameter/hl7:queryId/@extension"/>

<xsl:template match="/">
<PRPA_IN201306UV02 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns="urn:hl7-org:v3" ITSVersion="XML_1.0">
<id root="{$messageID}"/>
<creationTime value="{$creationTime}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201306UV02"/>
<processingCode code="T"/>
<!--<processingModeCode code="I"/> updated to T for PDQ-->
<processingModeCode code="T"/>
<acceptAckCode code="NE"/>
<xsl:call-template name="devices"/>
<acknowledgement>
<typeCode code="{$ackTypeCode}"/>
<targetMessage>
<id>
<xsl:if test="$targetMessageID !=''"><xsl:attribute name="root"><xsl:value-of select="$targetMessageID"/></xsl:attribute></xsl:if>
<xsl:if test="$targetMessageExtension !=''"><xsl:attribute name="extension"><xsl:value-of select="$targetMessageExtension"/></xsl:attribute></xsl:if>
</id>
</targetMessage>
<xsl:if test="$ackTypeCode != 'AA'">
<xsl:call-template name="errors"/>
</xsl:if>
</acknowledgement>
<controlActProcess moodCode="EVN"  classCode="CACT">
<code code="PRPA_TE201306UV02" codeSystem="2.16.840.1.113883.1.6"/>
<xsl:for-each select="/root/PatientSearchResponse/Results/PatientSearchMatch">
<xsl:variable name="patient" select="."/>

<subject typeCode="SUBJ" contextConductionInd="false">
<registrationEvent moodCode="EVN" classCode="REG">
<id nullFlavor="NA"/>
<statusCode code="active"/>
<subject1 typeCode="SBJ">
<patient classCode="PAT">
<xsl:variable name="person" select="."/>
<id root="{isc:evaluate('CodetoOID',IDs/Match[1]/AssigningAuthority/text())}" extension="{IDs/Match[1]/MRN}"/>
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

<xsl:if test="MiddleName/text()!=''"><given><xsl:value-of select="MiddleName/text()"/></given></xsl:if>

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

<xsl:if test="Suffix/text()!=''"><suffix><xsl:value-of select="Suffix/text()"/></suffix></xsl:if>
</name>
<xsl:for-each select="./Names/PersonName">
<xsl:call-template name="personNames"/>
</xsl:for-each>

<xsl:for-each select="Telecoms/Telecom">
<telecom>
<xsl:choose>
<xsl:when test="Use/text()!=''">
<xsl:attribute name="use">
<xsl:value-of select="Use/text()"/>
 </xsl:attribute>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="use">H</xsl:attribute>
</xsl:otherwise>
</xsl:choose>

<xsl:choose>
 <xsl:when test="string-length(PhoneNumberFull) != 0">
  <xsl:attribute name="value"><xsl:value-of select="concat('tel:',PhoneNumberFull/text())"/> 
  </xsl:attribute>
 </xsl:when>
 <xsl:when test="string-length(Email) != 0">
  <xsl:attribute name="value"><xsl:value-of select="concat('mailto:',Email/text())"/> 
  </xsl:attribute>
 </xsl:when>
 <xsl:otherwise/>
</xsl:choose>
 </telecom>
</xsl:for-each>
<administrativeGenderCode code="{Sex/text()}"/>
<birthTime value="{isc:evaluate('dateNoDash',DOB/text())}"/>
<xsl:for-each select='Addresses/Address'>
<addr>
<xsl:if test="Use/text()!=''">
<xsl:attribute name="use">
<xsl:value-of select="Use/text()"/>
 </xsl:attribute>
</xsl:if>
<streetAddressLine><xsl:value-of select="StreetLine/text()"/></streetAddressLine>
<xsl:if test="City/text() !=''"><city><xsl:value-of select="City/text()"/></city></xsl:if>
<xsl:if test="State/text() != ''"><state><xsl:value-of select="State/text()"/></state></xsl:if>
<xsl:if test="Country/text() != ''"><country><xsl:value-of select="Country/text()"/></country></xsl:if>
<xsl:if test="PostalCode/text() != ''"><postalCode><xsl:value-of select="PostalCode/text()"/></postalCode></xsl:if>
</addr>
</xsl:for-each>
<xsl:if test="count($person/IDs/Match)>1">
<xsl:for-each select="$person/IDs/Match">
<xsl:if test="position()>1">
<xsl:variable name="per" select="."/>
<asOtherIDs classCode = '{$per/AssigningAuthorityType/text()}'>
<id root="{isc:evaluate('CodetoOID',$per/AssigningAuthority/text())}" extension="{$per/MRN/text()}"/>
<scopingOrganization classCode="ORG" determinerCode="INSTANCE">
<id root="{isc:evaluate('CodetoOID',$per/AssigningAuthorityScopingOrganization/text())}"/>
</scopingOrganization>
</asOtherIDs>
</xsl:if>
</xsl:for-each>
</xsl:if>
<xsl:if test="SSN/text() !=''">
<asOtherIDs classCode='CIT'><id root='2.16.840.1.113883.4.1' extension='{SSN/text()}'/>
<scopingOrganization classCode="ORG" determinerCode="INSTANCE"><id root="2.16.840.1.113883.4.1"/></scopingOrganization>
</asOtherIDs>
</xsl:if>
<xsl:if test="MothersName/Given/text()!=''">
<xsl:call-template name="personalRelationship">
<xsl:with-param name="property" select="MothersName"/>
<xsl:with-param name="type" select="'MTH'"/>
</xsl:call-template>
</xsl:if>
<xsl:if test="FathersName/Given/text()!=''">
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

<xsl:if test="$person/Facility/text() != ''">
<providerOrganization classCode="ORG" determinerCode="INSTANCE">
<id root="{isc:evaluate('CodetoOID',$person/Facility/text())}"/>
<name/>
<contactParty classCode="CON"/>
</providerOrganization>
</xsl:if>
<subjectOf1>
<queryMatchObservation classCode="COND" moodCode="EVN">
<code code="IHE_PDQ"/>
<xsl:choose>
<xsl:when test="string-length($patient/RankOrScore/text())">
<value xsi:type="INT" value="{$patient/RankOrScore/text()}"/>
</xsl:when>
<xsl:otherwise>
<value xsi:type="INT" nullFlavor="UNK"/>
</xsl:otherwise>
</xsl:choose>
</queryMatchObservation>
</subjectOf1>
</patient>
</subject1>
<xsl:if test="string-length($homeCommunityOID)>0">
<custodian typeCode="CST">
<assignedEntity classCode="ASSIGNED">
<!-- Required element containing the homeCommunityId for the community responding to the request -->
<id root="{$homeCommunityOID}"/>
<!-- Required element defining whether the responding community supports the QIL transaction for this patient -->
<code code="NotHealthDataLocator" codeSystem="1.3.6.1.4.1.19376.1.2.27.2"/>
</assignedEntity>
</custodian>
</xsl:if>
</registrationEvent>
</subject>
</xsl:for-each>
<queryAck>
<queryId root="{$queryID}">
<xsl:if test="$queryExtension != ''">
 <xsl:attribute name="extension"><xsl:value-of select="$queryExtension"/></xsl:attribute>
  </xsl:if>
  </queryId>
<statusCode code="deliveredResponse"/>
<queryResponseCode code="{$queryStatus}"/>
<xsl:if test="$XCPD != '1'">
<resultTotalQuantity value="{$resultQuantity}"/>
<resultCurrentQuantity value="{$resultQuantityInitial}"/>
<resultRemainingQuantity value="{$resultQuantityRemaining}"/>
</xsl:if>
</queryAck>
<xsl:call-template name="parameters"/>
</controlActProcess>
</PRPA_IN201306UV02>
</xsl:template>

<xsl:template name="devices">
<!-- need to copy devices but reverse them  -->
<hl7:receiver typeCode="RCV">
<xsl:copy-of select = "/root/originalRequest/*[local-name()]/hl7:sender/hl7:device/."/>
  </hl7:receiver>
<hl7:sender typeCode="SND">
<xsl:copy-of select = "/root/originalRequest/*[local-name()]/hl7:receiver/hl7:device/."/>
</hl7:sender>
</xsl:template>

<xsl:template name="parameters">
<!-- need to copy queryByParameter section from /root/PRPAIN201305UV02/controlActProcess   -->
<xsl:copy-of select = "/root/originalRequest/*[local-name()]/hl7:controlActProcess/hl7:queryByParameter/."/>
</xsl:template>

<xsl:template name="errors">
<xsl:for-each select="/root/Errors/Error">
<acknowledgementDetail xmlns="urn:hl7-org:v3" typeCode="E">
<code code="{./Code}"/>
<xsl:if test="./Description!=''"><text><xsl:value-of select="./Description"/></text></xsl:if>
<xsl:if test="./Location!=''"><location><xsl:value-of select="./Location"/></location></xsl:if>
</acknowledgementDetail>
</xsl:for-each>
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
