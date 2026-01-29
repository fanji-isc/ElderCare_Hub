<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="PresentIllness">
		<IllnessHistory>
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>

			<!-- From and To Time -->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
				
			<!-- Condition -->
			<xsl:apply-templates select="hl7:text" mode="presentIllness-Condition"/>
			
			<!-- Note Text -->
			<NoteText><xsl:apply-templates select="hl7:entryRelationship/hl7:act[hl7:code/@code='103.16630' and hl7:code/@codeSystem=$nctisOID]/hl7:text" mode="TextValue"/></NoteText>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-IllnessHistory"/>
		</IllnessHistory>
	</xsl:template>
	
	<xsl:template match="*" mode="presentIllness-Condition">
		<xsl:if test="string-length(text())">
			<Condition>
				<Code><xsl:value-of select="text()"/></Code>
				<Description><xsl:value-of select="text()"/></Description>
			</Condition>
		</xsl:if>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is $sectionRootPath/hl7:entry/hl7:act.
	-->
	<xsl:template match="*" mode="ImportCustom-IllnessHistory">
	</xsl:template>
</xsl:stylesheet>
