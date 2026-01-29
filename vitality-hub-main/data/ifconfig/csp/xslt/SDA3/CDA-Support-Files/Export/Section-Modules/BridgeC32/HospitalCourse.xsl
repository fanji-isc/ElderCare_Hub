<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="hospitalCourse">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="Encounters/Encounter/HospitalCourse"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/hospitalCourse/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:apply-templates select="." mode="templateIds-hospitalCourseSection"/>
					
					<!-- IHE needs unique id for each and every section -->
					<id root="{$homeCommunityOID}" extension="{isc:evaluate('createUUID')}"/>
					
					<code code="8648-8" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="HOSPITAL COURSE"/>
					<title>Hospital Course</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="Encounters/Encounter/HospitalCourse" mode="hospitalCourse-Narrative"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="hospitalCourse-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="hospitalCourse-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Event</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="Event">
						<tr>
							<td><xsl:value-of select="text()"/></td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="hospitalCourse-NoData">
		<text><xsl:value-of select="$exportConfiguration/hospitalCourse/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-hospitalCourseSection">
		<xsl:if test="$hitsp-CDA-HospitalCourseSection"><templateId root="{$hitsp-CDA-HospitalCourseSection}"/></xsl:if>
		<xsl:if test="$ihe-PCC-HospitalCourse"><templateId root="{$ihe-PCC-HospitalCourse}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
