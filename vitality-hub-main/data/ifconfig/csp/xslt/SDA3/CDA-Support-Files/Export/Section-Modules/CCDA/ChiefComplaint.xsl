<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="chiefComplaint">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())]"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/chiefComplaint/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-ccda-chiefComplaintSection"/>
					
					<code code="10154-3" displayName="CHIEF COMPLAINT" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Chief Complaint</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="chiefComplaint-Narrative-ReasonForVisit"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="chiefComplaint-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="chiefComplaint-Narrative-ReasonForVisit">
		<text>
			<content>
				<xsl:value-of select="Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())]/VisitDescription/text()"/>
			</content>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="chiefComplaint-NoData">
		<text><xsl:value-of select="$exportConfiguration/chiefComplaint/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-ccda-chiefComplaintSection">
		<templateId root="{$ccda-ChiefComplaintSection}"/>
	</xsl:template>
</xsl:stylesheet>
