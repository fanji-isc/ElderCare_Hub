<?xml version="1.0" encoding="UTF-8"?>
<!-- 
XDSb Delete Document Set Audit Message (ITI-62) 
-->
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:exsl="http://exslt.org/common"
xmlns:hl7="urn:hl7-org:v3"
xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007" 
xmlns:xop="http://www.w3.org/2004/08/xop/include" 
exclude-result-prefixes="isc exsl hl7 lcm query rim rs xdsb xop xsi">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:include href="Base.xsl"/>

<!-- Globals used by the base stylesheet -->
<xsl:variable name="eventType" select="'ITI-62,IHE Transactions,Remove Metadata'"/>
<xsl:variable name="status"    select="/Root/Response//rs:RegistryResponse/@status"/>
<xsl:variable name="isSource"  select="not($actor='XDSbRegistry')"/>

<xsl:template match="/Root">
<Aggregation>

<xsl:choose>
<xsl:when test="$actor='XDSbRegistry'">
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110110,DCM,Patient Record'"/>
<xsl:with-param name="EventActionCode" select="'D'"/> 
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="Event">
<xsl:with-param name="EventID"         select="'110106,DCM,Export'"/>
<xsl:with-param name="EventActionCode" select="'D'"/> 
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>

<xsl:call-template name="Source"/>
<xsl:call-template name="Destination"/>
<xsl:call-template name="AuditSource"/>

<xsl:for-each select="/Root/Response/AdditionalInfo/AdditionalInfoItem">
	<xsl:variable name='key' select = '@AdditionalInfoKey'/>
	<xsl:variable name='keyValue' select='.'/>

	<xsl:if test='$key="$patient"'>
		<xsl:call-template name="Patient">
		<xsl:with-param name="id" select="$keyValue"/>
		</xsl:call-template>
	</xsl:if>


</xsl:for-each>

<CustomPairs>
<xsl:for-each select="/Root/Response/AdditionalInfo/AdditionalInfoItem">
	<xsl:variable name='key' select = '@AdditionalInfoKey'/>
	<xsl:variable name='keyValue' select='.'/>
	<xsl:if test='starts-with($key,"$uuid_")'>
		<xsl:variable name='refID' select = 'substring($key,7)'/>
		<xsl:variable name='refType' select ='$keyValue'/>
		<xsl:variable name="typeCode">
			<xsl:choose>
				<xsl:when test="$refType='urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1'">urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1,IHE XDS Metadata,document entry object type</xsl:when>
				<xsl:when test="$refType='urn:uuid:34268e47-fdf5-41a6-ba33-82133c465248'">urn:uuid:34268e47-fdf5-41a6-ba33-82133c465248,IHE XDS Metadata,on-demand document entry object type</xsl:when>
				<xsl:when test="$refType='urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd'">urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd,IHE XDS Metadata,submission set classification node</xsl:when>
				<xsl:when test="$refType='urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2'">urn:uuid:d9d542f3-6cc4-48b6-8870-ea235fbc94c2,IHE XDS Metadata,folder classification node</xsl:when>
				<xsl:when test="$refType='HasMember'">urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember,IHE XDS Metadata,has-member association type</xsl:when>
				<xsl:when test="$refType='Replaces'">urn:ihe:iti:2007:AssociationType:RPLC,IHE XDS Metadata,replacement relationship association type</xsl:when>
				<xsl:when test="$refType='Transforms'">urn:ihe:iti:2007:AssociationType:XFRM,IHE XDS Metadata,transformation relationship association type</xsl:when>
				<xsl:when test="$refType='Appends'">urn:ihe:iti:2007:AssociationType:APND,IHE XDS Metadata,append relationship association type</xsl:when>
				<xsl:when test="$refType='TransformsAndReplaces'">urn:ihe:iti:2007:AssociationType:XFRM_RPLC,IHE XDS Metadata,replace-transformation relationship association type</xsl:when>
				<xsl:when test="$refType='Signs'">urn:ihe:iti:2007:AssociationType:signs,IHE XDS Metadata,digital signature relationship association type</xsl:when>
				<xsl:when test="$refType='IsSnapshotOf'">urn:ihe:iti:2010:AssociationType:IsSnapshotOf,IHE XDS Metadata,is-snapshot relationship association type</xsl:when>
				<xsl:otherwise>urn:ihe:iti:2017:ObjectRef,IHE XDS Metadata,registry object reference</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<CustomPair>
			<Name>deleted_ref::<xsl:value-of select="$refID"/></Name>
			<Value><xsl:value-of select='$typeCode'/></Value>
		</CustomPair>
	</xsl:if>

</xsl:for-each>
</CustomPairs>

</Aggregation>
</xsl:template>
</xsl:stylesheet>
