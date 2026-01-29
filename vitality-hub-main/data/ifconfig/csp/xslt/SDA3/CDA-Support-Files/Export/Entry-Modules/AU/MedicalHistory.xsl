<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="medicalHistory-Narrative">
		<text>
			<xsl:choose>
				<xsl:when test="Problems">
					<xsl:apply-templates select="." mode="medicalHistory-Problems-Narrative">
						<xsl:with-param name="narrativeLinkCategory" select="'problems'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="medicalHistory-Problems-Narrative-NoData"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when test="Procedures">
					<xsl:apply-templates select="." mode="medicalHistory-Procedures-Narrative"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="medicalHistory-Procedures-Narrative-NoData"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:if test="IllnessHistories">
				<xsl:apply-templates select="." mode="medicalHistory-Other-Narrative"/>
			</xsl:if>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Problems-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions" select="true()"/>
		
		<table border="1" width="100%">
		<caption>Medical History - Problems/Diagnoses</caption>
			<thead>
				<tr>
					<th>Type</th>
					<th>Description</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="Problems/Problem" mode="medicalHistory-Problems-NarrativeDetail">
					<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
					<xsl:with-param name="currentConditions" select="$currentConditions"/>
				</xsl:apply-templates>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="*" mode="medicalHistory-Problems-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions"/>

		<xsl:variable name="includeInExport"><xsl:apply-templates select="." mode="includeConditionInExport"><xsl:with-param name="currentConditions" select="$currentConditions"></xsl:with-param></xsl:apply-templates></xsl:variable>

		<xsl:if test="($includeInExport = 1)">
			<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
			
			<tr ID="{concat($exportConfiguration/*[local-name() = $narrativeLinkCategory]/narrativeLinkPrefixes/conditionNarrative/text(), $narrativeLinkSuffix)}">
				<td><xsl:value-of select="Problem/Description/text()"/></td>
				<td><xsl:value-of select="Category/Description/text()"/></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Problems-Narrative-NoData">
		<table>
			<caption>Medical History - Problem Diagnosis - Exclusion Statement</caption>
			<thead>
				<tr>
					<th>Exclusion Statement</th>
				</tr>
			</thead>
			<tbody>
				<tr ID="{concat($exportConfiguration/problems/narrativeLinkPrefixes/conditionNarrative/text(),'1')}">
					<td>None known</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Procedures-Narrative">
		<table border="1" width="100%">
			<caption>Medical History - Procedures</caption>
			<thead>
				<tr>
					<th>Procedure</th>
					<th>Date / Time Performed</th>
					<th>Performing Clinician</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="Procedures/Procedure" mode="medicalHistory-Procedures-NarrativeDetail"/>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="*" mode="medicalHistory-Procedures-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/procedures/narrativeLinkPrefixes/procedureNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/procedures/narrativeLinkPrefixes/procedureDescription/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Procedure/Description/text()"/></td>
			<td><xsl:apply-templates select="ProcedureTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="Clinician" mode="name-Person-Narrative"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Procedures-Narrative-NoData">
		<table>
			<caption>Medical History - Procedures - Exclusion Statement</caption>
			<thead>
				<tr>
					<th>Exclusion Statement</th>
				</tr>
			</thead>
			<tbody>
				<tr ID="{concat($exportConfiguration/procedures/narrativeLinkPrefixes/procedureNarrative/text(),'1')}">
					<td>None known</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Other-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="currentConditions" select="true()"/>
		
		<table border="1" width="100%">
			<caption>Medical History - Medical History Item</caption>
			<thead>
				<tr>
					<th>Start Time</th>
					<th>End Time</th>
					<th>Item Description</th>
					<th>Item Comment</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="IllnessHistories/IllnessHistory" mode="medicalHistory-Other-NarrativeDetail"/>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="*" mode="medicalHistory-Other-NarrativeDetail">
		<xsl:param name="narrativeLinkCategory"/>
				
		<tr ID="{concat($exportConfiguration/pastIllness/narrativeLinkPrefixes/conditionNarrative/text(),position())}">
			<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="Condition" mode="descriptionOrCode"/></td>
			<td><xsl:value-of select="NoteText/text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Problems-Entries">
		<xsl:choose>
			<xsl:when test="Problems/Problem">
				<xsl:apply-templates select="Problems/Problem" mode="medicalHistory-Problems-EntryDetail"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="medicalHistory-Problems-NoData"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Problems-NoData">
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<code code="103.16302.120.1.3" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Global Statement"/>
				<value code="01" codeSystem="1.2.36.1.2001.1001.101.104.16299" codeSystemName="NCTIS Global Statement Values" displayName="None known" xsi:type="CD"/>
			</observation>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="medicalHistory-Problems-EntryDetail">
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="282291009" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT-AU" displayName="Diagnosis interpretation" />
				<xsl:variable name="fromTimeXml">
					<xsl:choose>
						<xsl:when test="string-length(FromTime/text())">
							<xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($fromTimeXml)"><effectiveTime value="{$fromTimeXml}"/></xsl:when>
					<xsl:otherwise><effectiveTime nullFlavor="NA"/></xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="Problem" mode="value-CD"/>
				<xsl:if test="string-length(ToTime/text())">
					<entryRelationship typeCode="SUBJ">
						<observation classCode="OBS" moodCode="EVN">
							<id root="{isc:evaluate('createUUID')}"/>
							<code code="103.15510" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Date of Resolution/Remission"/>
							<value xsi:type="IVL_TS">
								<xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="xmlToHL7TimeStamp"/></xsl:attribute>
							</value>
						</observation>
					</entryRelationship>
				</xsl:if>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Procedures-NoData">
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<code code="103.16302.120.1.4" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Global Statement"/>
				<value code="01" codeSystem="1.2.36.1.2001.1001.101.104.16299" codeSystemName="NCTIS Global Statement Values" displayName="None known" xsi:type="CD"/>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Other-Entries">
		<xsl:apply-templates select="IllnessHistories/IllnessHistory" mode="medicalHistory-Other-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Other-EntryDetail">
		<xsl:variable name="medicalHistoryItemDisplayName">
			<xsl:choose>
				<xsl:when test="$documentExportType='NEHTASharedHealthSummary' or $documentExportType='NEHTAeReferral'">Other Medical History Item</xsl:when>
				<xsl:when test="$documentExportType='NEHTAEventSummary'">Medical History Item</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<entry>
			<act classCode="ACT" moodCode="EVN">
				<id root="{isc:evaluate('createUUID')}"/>
				<code code="102.16627" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="{$medicalHistoryItemDisplayName}"/>
				<text xsi:type="ST"><xsl:apply-templates select="Condition" mode="descriptionOrCode"/></text>
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
				<xsl:apply-templates select="NoteText" mode="medicalHistory-Other-Comment"/>
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="medicalHistory-Other-Comment">
		<xsl:if test="string-length(text())">
			<entryRelationship typeCode="COMP">
				<act classCode="INFRM" moodCode="EVN">
					<code code="103.16630" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Medical History Item Comment"/>
					<text xsi:type="ST"><xsl:value-of select="text()"/></text>
				</act>
			</entryRelationship>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
