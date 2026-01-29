<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:param name="senderDeviceOID"/>
<xsl:param name="receiverDeviceOID"/>
<xsl:param name="messageID"/>
<xsl:param name="messageExtension"/>
<xsl:param name="queryID"/>
<xsl:param name="queryExtension"/>
<xsl:param name="homeCommunityOID"/>


<xsl:template match="/PatientSearchMatch">
<xsl:call-template name="main"/>
</xsl:template>

<xsl:template match="/PatientSearchRequest">
<xsl:call-template name="main"/>
</xsl:template>
<xsl:template name="main">
<xsl:variable name="AssigningAuthority" select="isc:evaluate('CodetoOID',./AssigningAuthority/text())"/>
<xsl:variable name="Facility" select="isc:evaluate('CodetoOID',./Facility/text())"/>

<xsl:variable name="MRN" select="./MRN/text()"/>
<xsl:variable name="MPIID" select="./MPIID/text()"/>
<xsl:variable name="FirstName" select="./FirstName/text()"/>
<xsl:variable name="MiddleName" select="./MiddleName/text()"/>
<xsl:variable name="LastName" select="./LastName/text()"/>
<xsl:variable name="Sex" select="./Sex/text()"/>
<xsl:variable name="DOB" select="translate(./DOB/text(),'-','')"/>
<xsl:variable name="City" select="./City/text()"/>
<xsl:variable name="Street" select="./Street/text()"/>
<xsl:variable name="State" select="./State/text()"/>
<xsl:variable name="Zip" select="./Zip/text()"/>
<xsl:variable name="SSN" select="./SSN/text()"/>
<xsl:variable name="MaxMatches" select="./MaxMatches/text()"/>
<xsl:variable name="exactMatch"><xsl:apply-templates select="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='ExactMatch']" mode="additionalInfoValue"/></xsl:variable>

<PRPA_IN201305UV02 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns="urn:hl7-org:v3"
xmlns:hl7="urn:hl7-org:v3"
ITSVersion="XML_1.0">
<id root="{$messageID}" extension="{$messageExtension}"/>
<creationTime value="{isc:evaluate('timestamp')}"/>
<interactionId root="2.16.840.1.113883.1.6" extension="PRPA_IN201305UV02"/>
<processingCode code="T"/>
<processingModeCode code="T"/>
<acceptAckCode code="AL"/>
<receiver typeCode="RCV">
<device classCode="DEV" determinerCode="INSTANCE">
<xsl:if test="$receiverDeviceOID !=''">
<id root="{$receiverDeviceOID}"/></xsl:if>
</device>
</receiver>
<sender typeCode="SND">
<device classCode="DEV" determinerCode="INSTANCE">
<id root="{$senderDeviceOID}"/>
<xsl:if test="$homeCommunityOID !=''">
<asAgent classCode="AGNT">
<representedOrganization classCode="ORG" determinerCode="INSTANCE">
<id root="{$homeCommunityOID}"/>
</representedOrganization>
</asAgent>
</xsl:if>
</device>
</sender>
<controlActProcess moodCode="EVN" classCode="CACT">
<code code="PRPA_TE201305UV02" codeSystem="2.16.840.1.113883.1.6"/>
<queryByParameter>
<queryId root="{$queryID}">
 <xsl:if test="string-length($queryExtension)>0">
 <xsl:attribute name="extension"><xsl:value-of select="$queryExtension"/></xsl:attribute>
 </xsl:if>
</queryId>
<statusCode code="new"/>
<responseModalityCode code="R"/> 
<responsePriorityCode code="I"/> 
<xsl:if test="string-length($homeCommunityOID)=0">
<xsl:choose>
<xsl:when test="string-length($MaxMatches)">
<initialQuantity value="{$MaxMatches}"/>
</xsl:when>
<xsl:otherwise>
<initialQuantity value="999"/>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
<xsl:if test="string-length(./MinMatchPercentage/text())">
<matchCriterionList>
<minimumDegreeMatch>
<value value="{./MinMatchPercentage/text()}"/>
</minimumDegreeMatch>
</matchCriterionList>
</xsl:if>
<parameterList>
<xsl:if test="$Sex!=''">
<livingSubjectAdministrativeGender>
<value code="{$Sex}"/>
<semanticsText>LivingSubject.administrativeGender</semanticsText>
</livingSubjectAdministrativeGender>
</xsl:if>
<xsl:if test="$DOB!=''">
<livingSubjectBirthTime>
<value value="{$DOB}"/>
<semanticsText>LivingSubject.birthTime</semanticsText>
</livingSubjectBirthTime>
</xsl:if>
<xsl:choose>
<xsl:when test="$MRN !=''">
<livingSubjectId>
<value extension="{$MRN}" root="{$AssigningAuthority}"/>
<semanticsText>LivingSubject.id</semanticsText>
</livingSubjectId>
</xsl:when>
<xsl:when test="$MPIID !=''">
<livingSubjectId>
<value extension="{$MPIID}" root="{$AssigningAuthority}"/>
<semanticsText>LivingSubject.id</semanticsText>
</livingSubjectId>
</xsl:when>
</xsl:choose>
<xsl:if test="$SSN !=''">
<livingSubjectId>
<value extension="{$SSN}" root="2.16.840.1.113883.4.1"/>
<semanticsText>LivingSubject.id</semanticsText>
</livingSubjectId>
</xsl:if>

<xsl:if test="$FirstName!='' or $LastName!=''">
<livingSubjectName>
<value>
<xsl:if test="$exactMatch!=1">
<xsl:attribute name="use">SRCH</xsl:attribute>
</xsl:if>
<xsl:if test="./Prefix/text()!=''"><prefix><xsl:value-of select="./Prefix/text()"/></prefix></xsl:if>
<xsl:if test="$FirstName!=''"><given><xsl:value-of select="$FirstName"/></given></xsl:if>
<xsl:if test="$MiddleName!=''"><given><xsl:value-of select="$MiddleName"/></given></xsl:if>
<xsl:if test="$LastName!=''"><family><xsl:value-of select="$LastName"/></family></xsl:if>
<xsl:if test="./Suffix/text()!=''"><suffix><xsl:value-of select="./Suffix/text()"/></suffix></xsl:if>
</value>
<semanticsText>LivingSubject.name</semanticsText>
</livingSubjectName>
</xsl:if>
<xsl:if test="MothersMaidenSurname/text()!=''">
<mothersMaidenName>
<value><xsl:value-of select="MothersMaidenSurname/text()"/></value>
<semanticsText>mothersMaidenName</semanticsText>
</mothersMaidenName>
</xsl:if>

<xsl:choose>
<xsl:when test="AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey='ScopingOrganizations']">
<xsl:apply-templates select="AdditionalInfo/AdditionalInfoItem[starts-with(@AdditionalInfoKey,'scopingOrganization_')]" mode="scopingOrganization">
</xsl:apply-templates>
</xsl:when>
<xsl:when test="($Facility!='')">
<otherIDsScopingOrganization>
<value root="{$Facility}"/>
<semanticsText>OtherIDs.scopingOrganization.id</semanticsText>
</otherIDsScopingOrganization>
</xsl:when>
</xsl:choose>

<xsl:if test="($Street!='') or ($City!='') or ($State!='') or ($Zip!='')">
<patientAddress>
<value>
<xsl:if test="$Street!=''">
<streetAddressLine><xsl:value-of select="$Street"/></streetAddressLine>
</xsl:if>
<xsl:if test="$City!=''">
<city><xsl:value-of select="$City"/></city>
</xsl:if>
<xsl:if test="$State!=''">
<state><xsl:value-of select="$State"/></state>
</xsl:if>
<xsl:if test="$Zip!=''">
<postalCode><xsl:value-of select="$Zip"/></postalCode>
</xsl:if>
</value>
<semanticsText>LivingSubject.address</semanticsText> 
</patientAddress>
</xsl:if>
</parameterList>
</queryByParameter>
</controlActProcess>
</PRPA_IN201305UV02>
</xsl:template>

<xsl:template match="*" mode="additionalInfoValue">
<xsl:value-of select="text()"/>
</xsl:template>

<xsl:template match="*" mode="scopingOrganization">
<otherIDsScopingOrganization xmlns="urn:hl7-org:v3">
<value root="{isc:evaluate('CodetoOID',substring-after(@AdditionalInfoKey,'scopingOrganization_'))}"/>
<semanticsText>OtherIDs.scopingOrganization.id</semanticsText>
</otherIDsScopingOrganization>
</xsl:template>

</xsl:stylesheet>
