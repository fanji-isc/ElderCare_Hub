<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="chiefComplaintAndReasonForVisit">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="string-length(Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())])>0"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/chiefComplaintAndReasonForVisit/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-ccda-chiefComplaintAndReasonForVisitSection"/>
					
					<code code="46239-0" displayName="CHIEF COMPLAINT AND REASON FOR VISIT" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Chief Complaint and Reason for Visit</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="chiefComplaintAndReasonForVisit-Narrative-ReasonForVisit"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="chiefComplaintAndReasonForVisit-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="chiefComplaintAndReasonForVisit-Narrative-ReasonForVisit">
		<text>
			<content>
				<xsl:value-of select="Encounters/Encounter[string-length(VisitDescription/text()) and string-length(EncounterNumber/text())]/VisitDescription/text()"/>
			</content>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="chiefComplaintAndReasonForVisit-NoData">
		<text><xsl:value-of select="$exportConfiguration/chiefComplaintAndReasonForVisit/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-ccda-chiefComplaintAndReasonForVisitSection">
		<templateId root="{$ccda-ChiefComplaintAndReasonForVisitSection}"/>
	</xsl:template>
</xsl:stylesheet>
