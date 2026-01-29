<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Allergy-Discharge">
		<Allergy>
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- From and To Time -->
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:effectiveTime/hl7:low" mode="FromTime"/>
			<xsl:apply-templates select="hl7:entryRelationship/hl7:observation/hl7:effectiveTime/hl7:high" mode="ToTime"/>
			
			<!-- Allergy and Allergy Category -->
			<xsl:apply-templates select="." mode="AllergyAndCategory-Discharge"/>
			
			<!-- Allergy Reaction -->
			<xsl:apply-templates select = "hl7:entryRelationship[@typeCode='MFST']" mode = "AllergyReaction-Discharge"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Allergy-Discharge"/>
		</Allergy>
	</xsl:template>
	
	<xsl:template match="*" mode="AllergyAndCategory-Discharge">
		<xsl:apply-templates select="hl7:participant/hl7:participantRole/hl7:playingEntity/hl7:code" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'Allergy'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="hl7:value" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'AllergyCategory'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="AllergyReaction-Discharge">
  		<xsl:choose>
    		<xsl:when test="hl7:observation/hl7:value">
      			<xsl:apply-templates select="hl7:observation/hl7:value" mode="CodeTable">
       			 	<xsl:with-param name="hsElementName" select="'Reaction'"/>
     			 </xsl:apply-templates>
    		</xsl:when>
 		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="Allergy">
		<Allergy>
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- From and To Time -->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
			
			<!-- Allergy and Allergy Category -->
			<xsl:apply-templates select="." mode="AllergyAndCategory"/>
			
			<!-- Allergy Reaction -->
			<xsl:apply-templates select = "hl7:entryRelationship/hl7:observation[hl7:code/@code='102.16474' and hl7:code/@codeSystem=$nctisOID]/hl7:entryRelationship[@typeCode='MFST']" mode = "AllergyReaction"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-Allergy"/>
		</Allergy>
	</xsl:template>
	
	<xsl:template match="*" mode="AllergyAndCategory">
		<xsl:apply-templates select="hl7:participant/hl7:participantRole/hl7:playingEntity/hl7:code" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'Allergy'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="hl7:value" mode="CodeTable">
			<xsl:with-param name="hsElementName" select="'AllergyCategory'"/>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="AllergyReaction">
  		<xsl:choose>
    		<xsl:when test="hl7:observation/hl7:code">
      			<xsl:apply-templates select="hl7:observation/hl7:code" mode="CodeTable">
       			 	<xsl:with-param name="hsElementName" select="'Reaction'"/>
     			 </xsl:apply-templates>
    		</xsl:when>
 		</xsl:choose>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:observation.
	-->
	<xsl:template match="*" mode="ImportCustom-Allergy-Discharge">
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-Allergy">
	</xsl:template>
</xsl:stylesheet>
