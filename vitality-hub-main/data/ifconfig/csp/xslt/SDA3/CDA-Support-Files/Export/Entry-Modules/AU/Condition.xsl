<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- Problem Variables -->
	<xsl:variable name="currentConditionStatusCodes" select="$exportConfiguration/problems/currentCondition/codes/text()"/>
	<xsl:variable name="currentConditionWindowInDays" select="$exportConfiguration/problems/currentCondition/windowInDays/text()"/>
	
	<xsl:template match="*" mode="conditions-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions" select="true()"/>
		
		<text>
			<table border="1" width="100%">
			<caption>Problems/Diagnoses</caption>
				<thead>
					<tr>
						<th>Type</th>
						<th>Description</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Problems/Problem" mode="conditions-NarrativeDetail">
						<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
						<xsl:with-param name="currentConditions" select="$currentConditions"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="conditions-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions"/>

		<xsl:variable name="includeInExport"><xsl:apply-templates select="." mode="includeConditionInExport"><xsl:with-param name="currentConditions" select="$currentConditions"></xsl:with-param></xsl:apply-templates></xsl:variable>

		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionNarrative/text(), $narrativeLinkSuffix)}">
				<td><xsl:apply-templates select="Category" mode="descriptionOrCode"/></td>
				<td><xsl:apply-templates select="Problem" mode="descriptionOrCode"/></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="conditions-Entries">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions" select="true()"/>

		<xsl:apply-templates select="Problems/Problem" mode="conditions-EntryDetail">
			<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
			<xsl:with-param name="currentConditions" select="$currentConditions"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="conditions-EntryDetail">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions"/>

		<xsl:variable name="includeInExport"><xsl:apply-templates select="." mode="includeConditionInExport"><xsl:with-param name="currentConditions" select="$currentConditions"></xsl:with-param></xsl:apply-templates></xsl:variable>

		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<entry typeCode="DRIV">
				<observation classCode="OBS" moodCode="EVN">
					<xsl:apply-templates select="." mode="id-External"/>
					
					<!-- Condition Type -->
					<xsl:choose>
						<xsl:when test="Category">
							<xsl:apply-templates select="Category" mode="generic-Coded">
								<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$snomedOID"/></xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise><code nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					
					<!-- Condition Code -->
					<xsl:apply-templates select="Problem" mode="value-Coded">
						<xsl:with-param name="xsiType">CD</xsl:with-param>
						<xsl:with-param name="requiredCodeSystemOID"><xsl:value-of select="$snomedOID"/></xsl:with-param>
					</xsl:apply-templates>
					
					<!-- Comments -->
					<xsl:apply-templates select="Comments" mode="comment-Condition">
						<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionComments/text(), $narrativeLinkSuffix)"/>
					</xsl:apply-templates>
					
					<!-- Link this problem to encounter noted in encounters section -->
					<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
				</observation>
			</entry>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="problems-NoData">
		<xsl:call-template name="nehta-globalStatement">
			<xsl:with-param name="narrativeLink" select="$exportConfiguration/problems/narrativeLinkPrefixes/conditionNarrative/text()"/>
			<xsl:with-param name="codeCode">103.16302.4.3.1</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="*" mode="includeConditionInExport">
		<xsl:param name="currentConditions"/>
		
		<!-- Should this condition be "promoted" to the active problem list? -->
		<xsl:variable name="isCurrentCondition"><xsl:apply-templates select="." mode="currentCondition"/></xsl:variable>

		<xsl:choose>
			<xsl:when test="($currentConditions = true()) and ($isCurrentCondition = 1)">1</xsl:when>
			<xsl:when test="($currentConditions = false()) and ($isCurrentCondition = 0)">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="currentCondition">
		<xsl:choose>
			<xsl:when test="contains($currentConditionStatusCodes, concat('|', Status/Code/text(), '|'))">1</xsl:when>
			<xsl:when test="not(ToTime)">1</xsl:when>
			<xsl:when test="isc:evaluate('dateDiff', 'dd', translate(translate(FromTime/text(), 'Z', ''), 'T', ' ')) &lt;= $currentConditionWindowInDays">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
