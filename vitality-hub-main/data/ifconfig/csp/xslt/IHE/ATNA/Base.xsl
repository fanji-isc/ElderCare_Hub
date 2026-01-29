<?xml version="1.0" encoding="UTF-8"?>
<!--
Base stylesheet for IHE Audit Messages
This will construct an HS.IHE.ATNA.Repository.Aggregation message, which should contain enough information
so that it can be transformed to an HS.IHE.ATNA.Repository.Data.AuditMessage in ATNA rfc 3881 format

Standards
http://tools.ietf.org/html/rfc3881
ftp://medical.nema.org/medical/dicom/supps/sup95_fz.pdf
http://www.ihe.net/Technical_Framework/upload/IHE_ITI_TF_Rev7-0_Vol2a_FT_2010-08-10.pdf
http://www.ihe.net/Technical_Framework/upload/IHE_ITI_TF_Rev7-0_Vol2b_FT_2010-08-10.pdf

Supplements
http://www.ihe.net/Technical_Framework/upload/IHE_ITI_Suppl_XCA_Rev2-1_TI_2010-08-10.pdf
http://www.ihe.net/Technical_Framework/upload/IHE_ITI_Suppl_XCPD_Rev2-1_TI_2010-08_10.pdf
http://www.ihe.net/Technical_Framework/upload/IHE_ITI_Suppl_On_Demand_Documents_Rev1-1_TI_2010-08-10.pdf
http://www.ihe.net/Technical_Framework/upload/IHE_ITI_Suppl_PIX_PDQ_HL7v3_Rev2-1_TI_2010-08-10.pdf

Change Proposals
ftp://ftp.ihe.net/IT_Infrastructure/TF_Maintenance-2010/CPs/FinalText/CP-ITI-403-FT.doc (XDSb Query base64 encoding clarification)
ftp://ftp.ihe.net/IT_Infrastructure/TF_Maintenance-2010/CPs/FinalText/CP-ITI-429-FT2.doc (XDSb Query homeCommunityId clarification)
ftp://ftp.ihe.net/IT_Infrastructure/TF_Maintenance-2010/CPs/Assigned/CP-ITI-474-01.doc (PIXv3/PDQv3 audit formats - INCOMPLETE)

HealthShare Clarifications / Deviations
- The Ensemble SessionId is used instead of the PID in Source/Destination ActiveParticipant elements
- Responders (such as a repository for a retrieve document message) will always include the "Human Requestor" section. The user
  will be determined by the inbound SAML token when present, otherwise will be the HealthShare services user (usually HS_Services)
- The MRN will be used for patient participants where a MPI ID is not available (PIX Add) using type code 
  EV(1,RFC-3881,"Medical Record Number") instead of EV(2,RFC-3881,"Patient Number")
  
Usage
- Each IHE transaction will have a separate stylesheet which imports this one and defines:
  - a template that matches /Root
  - a variable "eventType" for the transaction, i.e. 'IPateint Demographics Query'
  - a variable "status" for the status value, i.e. Response//hl7:acknowledgement/hl7:typeCode/@code
  - a variable "isSource" to indicate when the source is logging the event, as opposed to the destination, i.e. $actor='PDQv3Consumer'
- Most transaction templates will follow this pattern:
		<xsl:call-template name="Event">
			<xsl:with-param name="EventID"         select="...coded id..."/>
			<xsl:with-param name="EventActionCode" select="...action code..."/> 
		</xsl:call-template>
		<xsl:call-template name="Source"/>
		<xsl:call-template name="HumanRequestor"/>
		<xsl:call-template name="Destination"/>
		<xsl:call-template name="AuditSource"/>
		...transaction specific templates...
- 		
For historical reasons, some of the templates have redundant/unused parameters
-->

<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:exsl="http://exslt.org/common"
xmlns:hl7="urn:hl7-org:v3"
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
exclude-result-prefixes="isc exsl hl7 rim">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>

<!-- 
	STYLESHEET PARAMETERS
-->
<xsl:param name="actor"/>              <!-- IHE actor name (i.e. XDSbRegistry,PIXv3Manager,XCAInitiatingGateway,etc) -->
<xsl:param name="instance"/>           <!-- host_name:instance_name -->
<xsl:param name="namespace"/>          <!-- current namespace -->
<xsl:param name="auditSource"/>        <!-- source of the audit, usually the current classname -->
<xsl:param name="pid"/>                <!-- current process id -->
<xsl:param name="now"/>                <!-- current UTC time in XML format -->
<xsl:param name="session"/>            <!-- ensemble sessionId -->
<xsl:param name="homeCommunity"/>      <!-- community/domain values to avoid isc:evaluate callbacks -->
<xsl:param name="homeCommunityOID"/>  
<xsl:param name="affinityDomain"/>
<xsl:param name="affinityDomainOID"/>
<xsl:param name="homeCommunityOIDs"/>

<!-- 
	GLOBAL VARIABLES
-->
<xsl:variable name="sq">'</xsl:variable>

<!-- Nework values based on WS-Addressing used by every IHE Source/Destination ActiveParticpant -->
<!-- Source determined by wsa:ReplyTo unless it is the anonymous URL, then wsa:From is used -->
<xsl:variable name="wsaFrom">
<xsl:call-template name="getKeyValue">
<xsl:with-param name="key" select="'WSA:From'"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="wsaFromHost">
<xsl:call-template name="getNetworkHost">
<xsl:with-param name="url" select="$wsaFrom"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="wsaFromType">
<xsl:call-template name="getNetworkType">
<xsl:with-param name="host" select="$wsaFromHost"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="v2FromType">
<xsl:if test="$v2FromHost">
<xsl:call-template name="getNetworkType">
<xsl:with-param name="host" select="$v2FromHost"/>
</xsl:call-template>
</xsl:if>
</xsl:variable>

<xsl:variable name="wsaTo">
<xsl:call-template name="getKeyValue">
<xsl:with-param name="key" select="'WSA:To'"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="wsaToHost">
<xsl:call-template name="getNetworkHost">
<xsl:with-param name="url" select="$wsaTo"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="wsaToType">
<xsl:call-template name="getNetworkType">
<xsl:with-param name="host" select="$wsaToHost"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="v2ToType">
<xsl:if test="$v2ToHost">
<xsl:call-template name="getNetworkType">
<xsl:with-param name="host" select="$v2ToHost"/>
</xsl:call-template>
</xsl:if>
</xsl:variable>

<xsl:variable name="wsaReplyTo">
<xsl:call-template name="getKeyValue">
<xsl:with-param name="key" select="'WSA:ReplyTo'"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="wsaReplyToHost">
<xsl:call-template name="getNetworkHost">
<xsl:with-param name="url" select="$wsaReplyTo"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="wsaReplyToType">
<xsl:call-template name="getNetworkType">
<xsl:with-param name="host" select="$wsaReplyToHost"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="useReplyTo" select="not($wsaReplyTo='' or ($wsaReplyTo='http://www.w3.org/2005/08/addressing/anonymous'))"/>
<xsl:variable name="wsaReplyToOrFrom">
<xsl:choose>
<xsl:when test="$useReplyTo"><xsl:value-of select="$wsaReplyTo"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$wsaFrom"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="wsaReplyToOrFromHost">
<xsl:choose>
<xsl:when test="$useReplyTo"><xsl:value-of select="$wsaReplyToHost"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$wsaFromHost"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="wsaReplyToOrFromType">
<xsl:choose>
<xsl:when test="$useReplyTo"><xsl:value-of select="$wsaReplyToType"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$wsaFromType"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:template name="Event">
<xsl:param name="EventID"/>
<xsl:param name="EventActionCode"/>
<xsl:param name="EventDateTime" select="$now"/>
<xsl:param name="EventOutcomeIndicator"/>
<xsl:param name="EventTypeCode" select="$eventType"/>

<xsl:variable name="hsEvent">
	<xsl:choose>
		<xsl:when test="substring-before($EventTypeCode,',')='ITI-44'">
			<xsl:choose>
				<xsl:when test="$EventActionCode='C'">PIXv3 Add</xsl:when>
				<xsl:when test="$EventActionCode='U'">PIXv3 Update</xsl:when>
				<xsl:when test="$EventActionCode='D'">PIXv3 Delete</xsl:when>
				<xsl:otherwise>Patient Identity Feed</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="substring-before($EventTypeCode,',')='ITI-8'">
			<xsl:choose>
				<xsl:when test="$EventActionCode='C'">PIXv2 Add</xsl:when>
				<xsl:when test="$EventActionCode='U'">PIXv2 Update</xsl:when>
				<xsl:when test="$EventActionCode='D'">PIXv2 Delete</xsl:when>
				<xsl:otherwise>Patient Identity Feed</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="substring-before($EventTypeCode,',')='110122' and $EventOutcomeIndicator='0'">LoginFailure</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="substring-after(substring-after($eventType,','),',')"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<EventInfo>
	<xsl:value-of select="concat($EventTypeCode,'^',$EventID)"/>
</EventInfo>
<EventType>
	<xsl:value-of select="$hsEvent"/>
</EventType>
<xsl:if test="$EventActionCode">
	<ActionCode>
		<xsl:value-of select="$EventActionCode"/>
	</ActionCode>
</xsl:if>
<xsl:if test="$EventDateTime">
	<EventDateTime>
		<xsl:value-of select="$EventDateTime"/>
	</EventDateTime>
</xsl:if>
<Outcome>
	<xsl:choose>
		<xsl:when test="string-length($EventOutcomeIndicator)"><xsl:value-of select="$EventOutcomeIndicator"/></xsl:when>
		<xsl:when test="/Root/Status">8</xsl:when>  <!-- any %Status code is considered a system failure -->
		<xsl:when test="$status='AA' or $status='CA'">0</xsl:when>
		<xsl:when test="$status='urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success'">0</xsl:when>
		<xsl:when test="$status='1'">0</xsl:when>
		<xsl:otherwise>4</xsl:otherwise> 
	</xsl:choose>
</Outcome>
<IsSource><xsl:value-of select="$isSource"/></IsSource>
<CustomPairs>
	<xsl:apply-templates select="//CustomAuditInfoItem" mode="CustomPair"/>
</CustomPairs>
</xsl:template>

<xsl:template mode="CustomPair" match="*">
	<CustomPair>
		<Name><xsl:value-of select="."/></Name>
		<Value><xsl:value-of select="@CustomAuditInfoKey"/></Value>
	</CustomPair>
</xsl:template>

<xsl:template name="ActiveParticipant">
<xsl:param name="UserID"/>
<xsl:param name="AlternativeUserID"/>
<xsl:param name="UserName"/>
<xsl:param name="UserIsRequestor"/>
<xsl:param name="RoleIDCode"/>
<xsl:param name="NetworkAccessPointTypeCode"/>
<xsl:param name="NetworkAccessPointID"/>

<ActiveParticipant>

<xsl:attribute name="UserID">
<xsl:choose>
<xsl:when test="string-length($UserID)">
<xsl:value-of select="$UserID"/>
</xsl:when>
<xsl:otherwise>Unknown</xsl:otherwise>
</xsl:choose>
</xsl:attribute>

<xsl:if test="string-length($AlternativeUserID)">
<xsl:attribute name="AlternativeUserID">
<xsl:value-of select="$AlternativeUserID"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$UserName">
<xsl:attribute name="UserName">
<xsl:value-of select="$UserName"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$UserIsRequestor">
<xsl:attribute name="UserIsRequestor">
<xsl:value-of select="$UserIsRequestor"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$NetworkAccessPointTypeCode">
<xsl:attribute name="NetworkAccessPointTypeCode">
<xsl:value-of select="$NetworkAccessPointTypeCode"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$NetworkAccessPointID">
<xsl:attribute name="NetworkAccessPointID">
<xsl:value-of select="$NetworkAccessPointID"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$RoleIDCode">
<xsl:call-template name="CodedValues">
<xsl:with-param name="name" select="'RoleIDCode'"/>
<xsl:with-param name="string" select="$RoleIDCode"/>
</xsl:call-template>
</xsl:if>

</ActiveParticipant>
</xsl:template>


<!-- Template to record user-->
<xsl:template name="HumanRequestor">
<xsl:choose>
	<xsl:when test="string-length(//SAMLData)">
		<UserName>
			<xsl:choose>
				<xsl:when test="//SAMLData/Subject">
					<!-- XUA information available -->
					<xsl:value-of select="concat(//SAMLData/SubjectSPProvidedID/text(),'&lt;', //SAMLData/Subject/text(), '@', //SAMLData/Issuer/text(),'&gt;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="//SAMLData/UserName/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</UserName>
		<FacilityInternal>
			<xsl:value-of select="//SAMLData/Organization"/>
		</FacilityInternal>
		<Roles>
			<xsl:value-of select="translate(//SAMLData/HSRoles/text(),',',';')"/>
		</Roles>
	</xsl:when>
<xsl:otherwise>
		<UserName>
			<xsl:value-of select="//AdditionalInfoItem[@AdditionalInfoKey='USER:UserID']/text()"/>
		</UserName>
		<UserFullName>
			<xsl:value-of select="//AdditionalInfoItem[@AdditionalInfoKey='USER:FullName']/text()"/>
		</UserFullName>
		<Roles>
			<xsl:choose>
				<xsl:when test="string-length(translate(//AdditionalInfoItem[@AdditionalInfoKey='USER:Roles']/text(),',',';'))">
					<xsl:value-of select="translate(//AdditionalInfoItem[@AdditionalInfoKey='USER:Roles']/text(),',',';')"/>
				</xsl:when>
				<xsl:when test="$v2UserRoles and string-length($v2UserRoles)">
					<xsl:value-of select="$v2UserRoles"/>
				</xsl:when>
			</xsl:choose>
		</Roles>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- Template to record the Source -->
<xsl:template name="Source">
<SourceURI>
<xsl:choose>
	<xsl:when test="string-length($wsaReplyToOrFrom)">
		<xsl:value-of select="$wsaReplyToOrFrom"/>
	</xsl:when>
	<xsl:when test="($v2SendingApplication and string-length($v2SendingApplication)) or ($v2SendingFacility and string-length($v2SendingFacility))">
		<xsl:choose>
			<xsl:when test="($v2SendingApplication and string-length($v2SendingApplication)) and ($v2SendingFacility and string-length($v2SendingFacility))">
				<xsl:value-of select="concat($v2SendingApplication, '|', $v2SendingFacility)"/>
			</xsl:when>
			<xsl:when test="($v2SendingApplication and string-length($v2SendingApplication)) and not ($v2SendingFacility and string-length($v2SendingFacility))">
				<xsl:value-of select="concat($v2SendingApplication, '|Unknown')"/>
			</xsl:when>
			<xsl:when test="not($v2SendingApplication and string-length($v2SendingApplication)) and ($v2SendingFacility and string-length($v2SendingFacility))">
				<xsl:value-of select="concat('Unknown|', $v2SendingFacility)"/>
			</xsl:when>
		</xsl:choose>
		</xsl:when>
</xsl:choose>
</SourceURI>
<xsl:if test="$isSource">
	<EnsembleSessionId>
		<xsl:value-of select="$session"/>
	</EnsembleSessionId>
</xsl:if>
<SourceNetworkAccess>
	<xsl:choose>
		<xsl:when test="string-length($wsaReplyToOrFromHost)">
			<xsl:value-of select="$wsaReplyToOrFromHost"/>
		</xsl:when>
		<xsl:when test="$v2FromHost and string-length($v2FromHost)">
			<xsl:value-of select="$v2FromHost"/>
		</xsl:when>
	</xsl:choose>
</SourceNetworkAccess>
</xsl:template>

<!-- Template to record the Destination  -->
<xsl:template name="Destination">
<DestinationURI>
<xsl:choose>
	<xsl:when test="string-length($wsaTo)">
		<xsl:value-of select="$wsaTo"/>
	</xsl:when>
		<xsl:when test="($v2ReceivingApplication and string-length($v2ReceivingApplication)) or ($v2ReceivingFacility and string-length($v2ReceivingFacility))">
		<xsl:choose>
		<xsl:when test="($v2ReceivingApplication and string-length($v2ReceivingApplication)) and ($v2ReceivingFacility and string-length($v2ReceivingFacility))">
			<xsl:value-of select="concat($v2ReceivingApplication, '|', $v2ReceivingFacility)"/>
		</xsl:when>
		<xsl:when test="($v2ReceivingApplication and string-length($v2ReceivingApplication)) and not ($v2ReceivingFacility and string-length($v2ReceivingFacility))">
			<xsl:value-of select="concat($v2ReceivingApplication, '|Unknown')"/>
		</xsl:when>
		<xsl:when test="not($v2ReceivingApplication and string-length($v2ReceivingApplication)) and ($v2ReceivingFacility and string-length($v2ReceivingFacility))">
			<xsl:value-of select="concat('Unknown|', $v2ReceivingFacility)"/>
		</xsl:when>
	</xsl:choose>
	</xsl:when>
</xsl:choose>
</DestinationURI>
<xsl:if test="not($isSource)">
	<EnsembleSessionId>
		<xsl:value-of select="$session"/>
	</EnsembleSessionId>
</xsl:if>
<DestinationNetworkAccess>
<xsl:choose>
	<xsl:when test="string-length($wsaToHost)">
		<xsl:value-of select="$wsaToHost"/>
	</xsl:when>
	<xsl:when test="$v2ToHost and string-length($v2ToHost)">
		<xsl:value-of select="$v2ToHost"/>
	</xsl:when>
</xsl:choose>
</DestinationNetworkAccess>
</xsl:template>

<!-- Template to record audit source.  Even though the parameters are here, they are not used -->
<xsl:template name="AuditSource">
<xsl:param name="AuditEnterpriseSiteID" select="$homeCommunity"/>
<xsl:param name="AuditSourceID" select="concat($instance,':',$namespace,':',$auditSource)"/>
<xsl:param name="AuditSourceTypeCode" select="'4'"/>
<AuditSourceID>
	<xsl:value-of select="concat($instance,':',$namespace,':',$auditSource)"/>
</AuditSourceID>
</xsl:template>

<xsl:template name="ParticipantObject">
<xsl:param name="ParticipantObjectTypeCode"/>
<xsl:param name="ParticipantObjectTypeCodeRole"/>
<xsl:param name="ParticipantObjectDataLifeCycle"/>
<xsl:param name="ParticipantObjectIDTypeCode"/>
<xsl:param name="ParticipantObjectSensitivity"/>
<xsl:param name="ParticipantObjectID"/>
<xsl:param name="ParticipantObjectName"/>
<xsl:param name="ParticipantObjectQuery"/>
<xsl:param name="ParticipantObjectDetail"/>
												
<ParticipantObjectIdentification>
<xsl:if test="$ParticipantObjectID">
<xsl:attribute name="ParticipantObjectID">
<xsl:value-of select="$ParticipantObjectID"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$ParticipantObjectTypeCode">
<xsl:attribute name="ParticipantObjectTypeCode">
<xsl:value-of select="$ParticipantObjectTypeCode"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$ParticipantObjectTypeCodeRole">
<xsl:attribute name="ParticipantObjectTypeCodeRole">
<xsl:value-of select="$ParticipantObjectTypeCodeRole"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$ParticipantObjectDataLifeCycle">
<xsl:attribute name="ParticipantObjectDataLifeCycle">
<xsl:value-of select="$ParticipantObjectDataLifeCycle"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$ParticipantObjectSensitivity">
<xsl:attribute name="ParticipantObjectSensitivity">
<xsl:value-of select="$ParticipantObjectSensitivity"/>
</xsl:attribute>
</xsl:if>

<xsl:if test="$ParticipantObjectIDTypeCode">
<xsl:call-template name="CodedValue">
<xsl:with-param name="name" select="'ParticipantObjectIDTypeCode'"/> 
<xsl:with-param name="attr" select="$ParticipantObjectIDTypeCode"/>
</xsl:call-template>
</xsl:if>

<xsl:if test="$ParticipantObjectName">
<ParticipantObjectName>
<xsl:value-of select="$ParticipantObjectName"/>
</ParticipantObjectName>
</xsl:if>

<xsl:if test="$ParticipantObjectQuery">
<ParticipantObjectQuery>
<xsl:value-of select="isc:evaluate('encode',$ParticipantObjectQuery)"/>
</ParticipantObjectQuery>
</xsl:if>

<xsl:if test="$ParticipantObjectDetail">
<xsl:for-each select="exsl:node-set($ParticipantObjectDetail)/pair">
<ParticipantObjectDetail type="{@type}" value="{isc:evaluate('encode',@value)}"/>
</xsl:for-each>
</xsl:if>
</ParticipantObjectIdentification>
</xsl:template>

<!-- Specialized ParticipantObject section for patients, that will distinguish between MPI and MRN -->
<xsl:template name="Patient">
<xsl:param name="id"/>    <!-- HL7 CX format: id^^^&aa&ISO -->
<xsl:param name="name"/>  <!-- HL7 XCN format: id^last^first^middle^suffix^prefix^aa -->

<xsl:if test="string-length($id)">
<Patients><Patient> <!-- We'll rely on XML import to reolve the multiple collections into a single one -->
<xsl:variable name="aa" select="substring-before(substring-after($id,'^^^&amp;'),'&amp;ISO')"/>
<xsl:variable name="request" select="/Root/Request/ContentStream/node()"/>

<xsl:choose>
	<xsl:when test="$aa=$affinityDomainOID">
		<IdentifierType><xsl:value-of select="'MPIID'"/></IdentifierType>
		<Identifier><xsl:value-of select="substring-before($id,'^')"/></Identifier>
	</xsl:when>
	<xsl:when test="contains($homeCommunityOIDs,concat('|',$aa,'|'))">
		<IdentifierType><xsl:value-of select="'MPIID'"/></IdentifierType>
		<Identifier><xsl:value-of select="substring-before($id,'^')"/></Identifier>
	</xsl:when>
	<!-- Test on actor name rather than on existence of v2 variable value. --> 
	<xsl:when test="$actor='PIXv2Manager' or $actor='PIXv2Source' or $actor='PIXv2Consumer' or $actor='PDQv2Consumer' or $actor='PDQv2Supplier'">
		<IdentifierType><xsl:value-of select="'MRN'"/></IdentifierType>
		<xsl:variable name="MRN" select="substring-before($id,'^')"/>
		<xsl:variable name="aacode" select="isc:evaluate('OIDtoCode',$aa)"/>
		<Identifier><xsl:value-of select="concat($v2SendingFacility,'^',$MRN,'^',$aacode)"/></Identifier>
	</xsl:when>
	<xsl:otherwise> 
		<IdentifierType><xsl:value-of select="'MRN'"/></IdentifierType> 
		<xsl:variable name="MRN" select="substring-before($id,'^')"/> 
		<xsl:variable name="aacode" select="isc:evaluate('OIDtoCode',$aa)"/> 
		<xsl:variable name="facilityOID" select="$request/hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient/hl7:providerOrganization/hl7:id/@root"/> 
		<xsl:variable name="facilityName" select="$request/hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient/hl7:providerOrganization/hl7:name/text()"/> 
		<xsl:variable name="facilityCode"> 
			<xsl:choose> 
			<xsl:when test="string-length($facilityOID)"> 
			<xsl:value-of select="isc:evaluate('OIDtoCode',$facilityOID)"/> 
			</xsl:when> 
			<xsl:when test="string-length($facilityName)"> 
			<xsl:value-of select="$facilityName"/> 
			</xsl:when> 
			<xsl:otherwise> 
				<xsl:variable name="custodianFacilityOID" select="$request/hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:custodian/hl7:assignedEntity/hl7:id/@root"/> 
				<xsl:variable name="custodianFacilityName" select="$request/hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:custodian/hl7:assignedEntity/hl7:id/hl7:assignedOrganization/hl7:name/text()"/> 
				<xsl:choose> 
				<xsl:when test="string-length($custodianFacilityOID)"> 
				<xsl:value-of select="isc:evaluate('OIDtoCode',$custodianFacilityOID)"/> 
				</xsl:when> 
				<xsl:when test="string-length($custodianFacilityName)"> 
				<xsl:value-of select="$custodianFacilityName"/> 
				</xsl:when> 
				<xsl:otherwise> 
				<xsl:value-of select="$aacode"/>
				</xsl:otherwise> 
				</xsl:choose> 
			</xsl:otherwise> 
			</xsl:choose> 
		</xsl:variable> 
		<Identifier><xsl:value-of select="concat($facilityCode,'^',$MRN,'^',$aacode)"/></Identifier> 
	</xsl:otherwise> 
</xsl:choose>
<xsl:if test="string-length($name)"><PatientName><xsl:value-of select="$name"/></PatientName></xsl:if>
<RequestId>
	<xsl:choose>
		<!-- Test on actor name rather than on existence of v2 variable value. --> 
		<xsl:when test="$actor='PIXv2Manager' or $actor='PIXv2Source' or $actor='PIXv2Consumer' or $actor='PDQv2Consumer' or $actor='PDQv2Supplier' or $eventType='ITI-64,IHE Transactions,Notify XAD-PID Link Change'">
			<xsl:value-of select="concat('MSH-10,',isc:evaluate('encode',$v2MSH10))"/>
		</xsl:when>
		<xsl:when test="$request/hl7:id/@root">
			<xsl:value-of select="concat('II,',$request/hl7:id/@root)"/>
		</xsl:when>
	</xsl:choose>
</RequestId>
</Patient></Patients>

</xsl:if>

</xsl:template>

<xsl:template name="Document">
<xsl:param name="DocumentID"/>
<xsl:param name="RepositoryID"/>
<xsl:param name="HomeCommunityID"/>
	<Documents><Document>
		<DocumentID>
			<xsl:value-of select="$DocumentID"/>
		</DocumentID>
		<RepositoryID>
			<xsl:value-of select="$RepositoryID"/>
		</RepositoryID>
		<HomeCommunityID>
			<xsl:value-of select="$HomeCommunityID"/>
		</HomeCommunityID>
	</Document></Documents>

</xsl:template>

<!--
	RFC 3881 HELPER FUNCTIONS
-->
<xsl:template name="CodedValue">
<xsl:param name="name"/>
<xsl:param name="attr"/>
<xsl:param name="delim" select="','"/>

<xsl:variable name="code" 					select="isc:evaluate('piece',$attr,$delim,1)"/>
<xsl:variable name="codeSystemName" select="isc:evaluate('piece',$attr,$delim,2)"/>
<xsl:variable name="displayName" 		select="isc:evaluate('piece',$attr,$delim,3)"/>

<xsl:element name="{$name}">
<xsl:attribute name="code"><xsl:value-of select="$code"/></xsl:attribute>
<xsl:if test="string-length($codeSystemName)"><xsl:attribute name="codeSystemName"><xsl:value-of select="$codeSystemName"/></xsl:attribute></xsl:if>
<xsl:if test="string-length($displayName)"><xsl:attribute name="displayName"><xsl:value-of select="$displayName"/></xsl:attribute></xsl:if>
</xsl:element>
</xsl:template>

<xsl:template name="CodedValues">
<xsl:param name="name"/>
<xsl:param name="string"/>
<xsl:param name="delim1" select="';'"/>
<xsl:param name="delim2" select="','"/>
<xsl:variable name="pieces">
<xsl:call-template name="split">
<xsl:with-param name="string" select="$string"/>
<xsl:with-param name="delim" select="$delim1"/>
</xsl:call-template>
</xsl:variable>
<xsl:for-each select="exsl:node-set($pieces)/piece">
<xsl:call-template name="CodedValue">
<xsl:with-param name="name" select="$name"/>
<xsl:with-param name="attr" select="text()"/>
<xsl:with-param name="delim" select="$delim2"/>
</xsl:call-template>
</xsl:for-each>
</xsl:template>


<!--
	IHE HELPER FUNCTIONS
-->
<!-- Create a patient section from a HL7 node -->
<xsl:template mode="Patient" match="hl7:patient">
<xsl:call-template name="Patient">
<xsl:with-param name="id">
<xsl:choose>
<xsl:when test="hl7:id"><xsl:value-of select="concat(hl7:id/@extension,'^^^&amp;',hl7:id/@root,'&amp;ISO')"/></xsl:when>
<xsl:when test="hl7:patientPerson/hl7:asOtherIDs[@classCode='PAT']/hl7:id"><xsl:value-of select="concat(hl7:patientPerson/hl7:asOtherIDs[@classCode='PAT']/hl7:id/@extension,'^^^&amp;',hl7:patientPerson/hl7:asOtherIDs[@classCode='PAT']/hl7:id/@root,'&amp;ISO')"/></xsl:when>
</xsl:choose>
</xsl:with-param>
<xsl:with-param name="name">
<xsl:if test="hl7:patientPerson/hl7:name/hl7:family">
<xsl:value-of select="concat('^',hl7:patientPerson/hl7:name/hl7:family/text(),'^',hl7:patientPerson/hl7:name/hl7:given/text())"/>
</xsl:if>
</xsl:with-param>
</xsl:call-template>
</xsl:template>

<!--
	Create a patient section from a HL7 node for a PDQv3_QueryResponse.
	The Patient template above for hl7:patient seems to assume that the
	response hl7:patient/hl7:id will be the PatientIds. Currently this
	is not the case, as the hl7:patient/hl7:id contains the first Match
	ID encountered in the PatientSearchResponse, which isn't necessarily
	the PatientId.
-->
<xsl:template mode="PDQv3Patient" match="hl7:patient">
<xsl:call-template name="Patient">
<!--
	If the AA for id equals the affinity domain, then use it.
	Otherwise if there is an asOtherIDs whose AA equals the affinity domain, then use that.
	Otherwise if id is there then use it.
	Otherwise use the first asOtherIDs whose AA is an AA defined in the HS AA config table.
-->
<xsl:with-param name="id">
<xsl:choose>
<xsl:when test="hl7:id/@root=$affinityDomainOID and string-length(hl7:id/@extension)">
<xsl:value-of select="concat(hl7:id/@extension,'^^^&amp;',hl7:id/@root,'&amp;ISO')"/>
</xsl:when>
<xsl:when test="hl7:patientPerson/hl7:asOtherIDs[hl7:id/@root=$affinityDomainOID]">
<xsl:value-of select="concat(hl7:patientPerson/hl7:asOtherIDs[hl7:id/@root=$affinityDomainOID]/hl7:id/@extension,'^^^&amp;',$affinityDomainOID,'&amp;ISO')"/>
</xsl:when>
<xsl:when test="hl7:id">
<xsl:value-of select="concat(hl7:id/@extension,'^^^&amp;',hl7:id/@root,'&amp;ISO')"/>
</xsl:when>
<xsl:when test="hl7:patientPerson/hl7:asOtherIDs[@classCode='PAT']/hl7:id">
<xsl:value-of select="concat(hl7:patientPerson/hl7:asOtherIDs[@classCode='PAT']/hl7:id/@extension,'^^^&amp;',hl7:patientPerson/hl7:asOtherIDs[@classCode='PAT']/hl7:id/@root,'&amp;ISO')"/>
</xsl:when>
</xsl:choose>
</xsl:with-param>
<xsl:with-param name="name">
<xsl:if test="hl7:patientPerson/hl7:name/hl7:family">
<xsl:value-of select="concat('^',hl7:patientPerson/hl7:name/hl7:family/text(),'^',hl7:patientPerson/hl7:name/hl7:given/text())"/>
</xsl:if>
</xsl:with-param>
</xsl:call-template>
</xsl:template>

<!-- Create a patient section from a HL7 query -->
<xsl:template mode="Patient" match="hl7:queryByParameter">
<!-- try for the MPI ID if present, otherwise the first ID listed -->
<xsl:variable name="mpi" select="hl7:parameterList/hl7:livingSubjectId/hl7:value[@root=$affinityDomainOID]"/>
<xsl:variable name="mrn" select="hl7:parameterList/hl7:livingSubjectId[1]/hl7:value"/>
<xsl:variable name="mrn2" select="hl7:parameterList/hl7:patientIdentifier[hl7:semanticsText/text()='Patient.Id']/hl7:value"/>
<xsl:variable name="name" select="hl7:parameterList/hl7:livingSubjectName[1]/hl7:value"/>

<xsl:call-template name="Patient">
<xsl:with-param name="id">
<xsl:choose>
<xsl:when test="$mpi"><xsl:value-of select="concat($mpi/@extension,'^^^&amp;',$mpi/@root,'&amp;ISO')"/></xsl:when>
<xsl:when test="$mrn"><xsl:value-of select="concat($mrn/@extension,'^^^&amp;',$mrn/@root,'&amp;ISO')"/></xsl:when>
<xsl:when test="$mrn2"><xsl:value-of select="concat($mrn2/@extension,'^^^&amp;',$mrn2/@root,'&amp;ISO')"/></xsl:when>
</xsl:choose>
</xsl:with-param>
<xsl:with-param name="name">
<xsl:if test="$name"><xsl:value-of select="concat('^',$name/hl7:family/text(),'^',$name/hl7:given/text())"/></xsl:if>
</xsl:with-param>
</xsl:call-template>
</xsl:template>

<!-- Create a patient section from an XDSb query -->
<xsl:template mode="Patient" match="rim:AdhocQuery">
<xsl:variable name="patientId">
<xsl:choose>
<xsl:when test="rim:Slot[@name='$XDSDocumentEntryPatientId']">
<xsl:value-of select="rim:Slot[@name='$XDSDocumentEntryPatientId']/rim:ValueList/rim:Value/text()"/>
</xsl:when>
<xsl:when test="rim:Slot[@name='$XDSSubmissionSetPatientId']">
<xsl:value-of select="rim:Slot[@name='$XDSSubmissionSetPatientId']/rim:ValueList/rim:Value/text()"/>
</xsl:when>
<xsl:when test="rim:Slot[@name='$XDSFolderPatientId']">
<xsl:value-of select="rim:Slot[@name='$XDSFolderPatientId']/rim:ValueList/rim:Value/text()"/>
</xsl:when>
<xsl:when test="rim:Slot[@name='$patientId']">
<xsl:value-of select="rim:Slot[@name='$patientId']/rim:ValueList/rim:Value/text()"/>
</xsl:when>
<xsl:otherwise>
<!-- Worst case check additional info for queries like GetDocuments which does not have a patient parameter -->
<xsl:call-template name="getKeyValue">
<xsl:with-param name="key" select="'PatientId'"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<!-- If the patient cannot be determined from the query, then use the first document from the response -->
<xsl:choose>
<xsl:when test="string-length($patientId)">
<!-- Add the patient section, removing any single quotes from the id -->
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="translate($patientId,$sq,'')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates mode="Patient" select="/Root/Response//rim:ExtrinsicObject[1]"/>
</xsl:otherwise>
</xsl:choose>

</xsl:template>

<!-- Create a patient section from an XDSb submission set -->
<xsl:template mode="Patient" match="rim:RegistryPackage">
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446']/@value"/>
</xsl:call-template>
</xsl:template>

<!-- Create a patient section from an XDSb ExtrinsicObject -->
<xsl:template mode="Patient" match="rim:ExtrinsicObject">
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427']/@value"/>
<xsl:with-param name="name">
<xsl:if test="rim:Slot[@name='sourcePatientInfo']/rim:ValueList/rim:Value[contains(text(),'PID-5')]">
<xsl:value-of select="concat('^',substring-after(rim:Slot[@name='sourcePatientInfo']/rim:ValueList/rim:Value[contains(text(),'PID-5')]/text(),'|'))"/>
</xsl:if>
</xsl:with-param>
</xsl:call-template>
</xsl:template>

<xsl:template mode="Patient" match="AdditionalInfo">
<xsl:variable name="patientId">
<xsl:call-template name="getKeyValue">
<xsl:with-param name="key" select="'PatientId'"/>
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="Patient">
<xsl:with-param name="id" select="$patientId"/>
</xsl:call-template>
</xsl:template>

<!-- Create a submission set section -->
<xsl:template mode="SubmissionSet" match="rim:RegistryPackage">
<SubmissionSetUniqueID>
	<xsl:value-of select="rim:ExternalIdentifier[@identificationScheme='urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8']/@value"/>
</SubmissionSetUniqueID>
</xsl:template>

<!-- Specialized ParticipantObject for query transaction (PIXv3,PDQv3 and XDSb) -->
<xsl:template name="QueryParameters">
<xsl:variable name="request" select="/Root/Request/ContentStream/node()"/>

<xsl:choose>
	<xsl:when test="$request//hl7:queryByParameter">
		<Criteria>
			<xsl:apply-templates mode="nodeset2string" select="$request//hl7:queryByParameter"/>
		</Criteria>
		<QueryRequestID>
			<xsl:value-of select="concat($request//hl7:queryId/@extension,'^^^&amp;',$request//hl7:queryId/@root,'&amp;ISO')"/>
		</QueryRequestID>
		<AdditionalInfo><AdditionalInfoItem AdditionalInfoKey="MSH-10"><xsl:value-of select="concat($request/hl7:id/@extension,'^^^&amp;',$request/hl7:id/@root,'&amp;ISO')"/></AdditionalInfoItem></AdditionalInfo>
	</xsl:when>
	<xsl:when test="$request//rim:AdhocQuery/@id">
		<Criteria>
			<xsl:apply-templates mode="nodeset2string" select="$request"/>
		</Criteria>
		<QueryRequestID>
			<xsl:value-of select="$request//rim:AdhocQuery/@id"/>
			<!-- for this flavor, we will assume encoding of UTF8, which will need to be exported when we transform this to an ATNA audit message-->
		</QueryRequestID>
				<AdditionalInfo><AdditionalInfoItem AdditionalInfoKey="QueryEncoding">UTF-8</AdditionalInfoItem>
				<xsl:if test="$request//rim:AdhocQuery/@home">
					<AdditionalInfoItem AdditionalInfoKey="urn:ihe:iti:xca:2010:homeCommunityId"><xsl:value-of select="$request//rim:AdhocQuery/@home"/></AdditionalInfoItem>
				</xsl:if>
				</AdditionalInfo>
	</xsl:when>
	<xsl:when test="$v2MSH10 and $v2HL7Message">
		<Criteria>
			<xsl:value-of select="$v2HL7Message"/>
		</Criteria>
		<QueryRequestID>
			<xsl:value-of select="$v2MSH10"/>
		</QueryRequestID>
		<AdditionalInfo><AdditionalInfoItem AdditionalInfoKey="MSH-10"><xsl:value-of select="$v2MSH10"/></AdditionalInfoItem></AdditionalInfo>
	</xsl:when>
</xsl:choose>

</xsl:template>

<xsl:template match="*" mode="PIXv2Patient">
<xsl:param name="patientString"/>
<xsl:apply-templates select="." mode="PDQv2Patient">
<xsl:with-param name="patientString" select="$patientString"/>
</xsl:apply-templates>
</xsl:template>

<!--
For PIX and PDQ v2, a string representing the patient(s) is constructed
and passed into this transform.  The format of the string is: 
|patientIdentifier1~patientName1|..|patientIdentifierN~patientNameN|
-->
<xsl:template match="*" mode="PDQv2Patient">
<xsl:param name="patientString"/>

<xsl:variable name="currentString" select="substring-before(substring-after($patientString,'|'),'|')"/>
<xsl:variable name="identifier" select="substring-before($currentString,'~')"/>
<xsl:variable name="patientName" select="substring-after($currentString,'~')"/>

<xsl:call-template name="Patient">
<xsl:with-param name="id" select="$identifier"/>
<xsl:with-param name="name" select="$patientName"/>
</xsl:call-template>

<xsl:variable name="nextString" select="substring-after($patientString,concat('|',$currentString,'|'))"/>

<xsl:if test="string-length($nextString)">
<xsl:apply-templates select="." mode="PDQv2Patient">
<xsl:with-param name="patientString" select="$nextString"/>
</xsl:apply-templates>
</xsl:if>
</xsl:template>

<!--
	GENERAL FUNCTIONS
-->
<!-- Get the value of an AdditionalInfoKey, checking request first, then response, otherwise null -->
<xsl:template name="getKeyValue">
<xsl:param name="key"/>
<xsl:choose>
<xsl:when test="/Root/Request/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey=$key]/text()">
<xsl:value-of select="/Root/Request/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey=$key]/text()"/>
</xsl:when>
<xsl:when test="/Root/Response/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey=$key]/text()">
<xsl:value-of select="/Root/Response/AdditionalInfo/AdditionalInfoItem[@AdditionalInfoKey=$key]/text()"/>
</xsl:when>
<xsl:otherwise/>
</xsl:choose>
</xsl:template>

<!-- Return the host part of a URL -->
<xsl:template name="getNetworkHost">
<xsl:param name="url"/>
<xsl:variable name="url0" select="translate($url,'\','/')"/>
<xsl:variable name="url1">
<xsl:choose> <!-- remove protocol -->
<xsl:when test="contains($url0,'://')"><xsl:value-of select="substring-after($url0,'://')"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$url0"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="url2">
<xsl:choose> <!-- remove path -->
<xsl:when test="contains($url1,'/')"><xsl:value-of select="substring-before($url1,'/')"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$url1"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="url3">
<xsl:choose> <!-- remove port -->
<xsl:when test="contains($url2,':')"><xsl:value-of select="substring-before($url2,':')"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$url2"/></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:value-of select="$url3"/>
</xsl:template>

<!-- Returns 1 if host is a DNS name, 2 if IP Address, otherwise null -->
<xsl:template name="getNetworkType">
<xsl:param name="host"/>
<xsl:choose>
<xsl:when test="$host=''"/>
<xsl:when test="translate($host,'0123456789.','')=''">2</xsl:when>
<xsl:otherwise>1</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- reduced implementation of the EXSLT str:split function since Xalan doesn't implement it -->
<xsl:template name="split">
<xsl:param name="string" select="''" />
<xsl:param name="delim" select="','" />
<xsl:choose>
<xsl:when test="not($string)"/>
<xsl:otherwise>
<xsl:call-template name="split-recursive">
<xsl:with-param name="string" select="$string" />
<xsl:with-param name="delim" select="$delim" />
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="split-recursive">
<xsl:param name="string" />
<xsl:param name="delim" />
<xsl:choose>
<xsl:when test="contains($string, $delim)">
<xsl:if test="not(starts-with($string, $delim))">
<piece><xsl:value-of select="substring-before($string, $delim)" /></piece>
</xsl:if>
<xsl:call-template name="split-recursive">
<xsl:with-param name="string" select="substring-after($string, $delim)" />
<xsl:with-param name="delim" select="$delim" />
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<piece><xsl:value-of select="$string" /></piece>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Returns a string from a node-set (not escaped) -->
<!-- Used for populating base-64 encoded detail sections -->
<xsl:template mode="nodeset2string" match="node()">
<xsl:if test="local-name()">
<xsl:text>&lt;</xsl:text>
<xsl:value-of select="local-name()"/>
<xsl:apply-templates mode="nodeset2string" select="@*"/>
<xsl:choose>
<xsl:when test="node()">
<xsl:text>&gt;</xsl:text>
<xsl:apply-templates mode="nodeset2string" select="node()"/>
<xsl:value-of select="text()"/>
<xsl:text>&lt;/</xsl:text>
<xsl:value-of select="local-name()"/>
<xsl:text>&gt;</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>/&gt;</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>
<xsl:template mode="nodeset2string" match="@*">
<xsl:text> </xsl:text>
<xsl:value-of select="local-name()"/>
<xsl:text>="</xsl:text>
<xsl:value-of select="."/>
<xsl:text>"</xsl:text>
</xsl:template>

</xsl:stylesheet>
