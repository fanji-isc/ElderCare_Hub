<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:template match="*" mode="comment-component">
		<xsl:param name="narrativeLink"/>
		
		<component>
			<xsl:apply-templates select="." mode="comment"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
		</component>
	</xsl:template>

	<xsl:template match="*" mode="comment-entryRelationship">
		<xsl:param name="narrativeLink"/>

		<entryRelationship typeCode="SUBJ" inversionInd="true">
			<xsl:apply-templates select="." mode="comment"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="comment">
		<xsl:param name="narrativeLink"/>
		
		<act classCode="ACT" moodCode="EVN"> 
			<xsl:apply-templates select="." mode="templateIds-comments"/>
			
			<code code="48767-8" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Annotation Comment"/> 
			<text><reference value="{$narrativeLink}"/></text>
			<statusCode code="completed"/>
			
			<!-- Author (Human) -->
			<xsl:apply-templates select="parent::node()/Clinician | parent::node()/DiagnosingClinician | parent::node()/OrderedBy | parent::node()/VerifiedBy | parent::node()/parent::node()/VerifiedBy | parent::node()/Result/VerifiedBy" mode="author-Human"/>
		</act>
	</xsl:template>
	
	<xsl:template match="*" mode="comment-medication">
		<entryRelationship typeCode="COMP">
			<act classCode="INFRM" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="103.16044" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Additional Comments"/>
				<text xsi:type="ST"><xsl:value-of select="text()"/></text>
			</act>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="comment-Result">
		<entryRelationship typeCode="COMP">
			<act classCode="INFRM" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="281296001" codeSystem="{$snomedOID}" codeSystemName="SNOMED CT-AU" codeSystemVersion="20110531" displayName="result comments"/>
				<text xsi:type="ST"><xsl:value-of select="text()"/></text>
			</act>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="comment-Condition">
		<entryRelationship typeCode="COMP">
			<act classCode="INFRM" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="103.16545" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Problem/Diagnosis Comment"/>
				<text xsi:type="ST"><xsl:value-of select="text()"/></text>
			</act>
		</entryRelationship>
	</xsl:template>
</xsl:stylesheet>
