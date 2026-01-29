<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="socialHistory-Narrative">
		<xsl:param name="sdaSmokingCodes"/>
		<xsl:param name="exportUnknownSmokingStatus"/>
		
		<table border="1" width="100%">
			<thead>
				<tr>
					<th>Social Habit</th>
					<th>Start Date</th>
					<th>Stop Date</th>
					<th>Comments</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="SocialHistory" mode="socialHistory-NarrativeDetail">
					<xsl:with-param name="sdaSmokingCodes" select="$sdaSmokingCodes"/>
				</xsl:apply-templates>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-NarrativeDetail">
		<xsl:param name="sdaSmokingCodes"/>
		
		<xsl:if test="not(contains(concat('|',$sdaSmokingCodes),concat('|',SocialHabit/Code/text(),'|')))">
			<tr ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryNarrative/text(), position())}">
				<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), position())}"><xsl:apply-templates select="SocialHabit" mode="descriptionOrCode"/></td>
				<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
				<td><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></td>
				<xsl:choose>
					<xsl:when test="string-length(SocialHabitComments/text())">
						<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryComments/text(), position())}"><xsl:value-of select="SocialHabitComments/text()"/></td>
					</xsl:when>
					<xsl:otherwise><td/></xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-Narrative-Smoking">
		<xsl:param name="sdaSmokingCodes"/>
		<xsl:param name="exportUnknownSmokingStatus"/>
		
		<table border="1" width="100%">
			<thead>
				<tr>
					<th>Smoking Status</th>
					<th>Start Date</th>
					<th>Stop Date</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="SocialHistory" mode="socialHistory-NarrativeDetail-Smoking">
					<xsl:with-param name="sdaSmokingCodes" select="$sdaSmokingCodes"/>
				</xsl:apply-templates>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-NarrativeDetail-Smoking">
		<xsl:param name="sdaSmokingCodes"/>
		
		<xsl:variable name="startTime"><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></xsl:variable>
		<xsl:variable name="stopTime"><xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/></xsl:variable>
		<xsl:variable name="dU"><xsl:value-of select="translate(SocialHabit/Description/text(),$lowerCase,$upperCase)"/></xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="string-length(SocialHabit/Description/text())">
					<xsl:value-of select="SocialHabit/Description/text()"/>
				</xsl:when>
				<xsl:when test="SocialHabit/Code/text()='449868002'">Current every day smoker</xsl:when>
				<xsl:when test="SocialHabit/Code/text()='428041000124106'">Current some day smoker</xsl:when>
				<xsl:when test="SocialHabit/Code/text()='8517006'">Former smoker</xsl:when>
				<xsl:when test="SocialHabit/Code/text()='266919005'">Never smoker</xsl:when>
				<xsl:when test="SocialHabit/Code/text()='77176002'">Smoker, current status unknown</xsl:when>
				<xsl:when test="SocialHabit/Code/text()='266927001'">Unknown if ever smoked</xsl:when>
				<xsl:when test="SocialHabit/Code/text()='428071000124103'">Heavy tobacco smoker</xsl:when>
				<xsl:when test="SocialHabit/Code/text()='428061000124105'">Light tobacco smoker</xsl:when>
				<xsl:otherwise><xsl:value-of select="SocialHabit/Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="contains(concat('|',$sdaSmokingCodes),concat('|',SocialHabit/Code/text(),'|'))">
			<tr ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryNarrative/text(), position())}">
				<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), position())}"><xsl:value-of select="$description"/></td>
				<!-- If person never was a smoker or smoking status is unknown, then do not display FromTime. -->
				<xsl:choose>
					<xsl:when test="SocialHabit/Code/text()='266927001' or SocialHabit/Code/text()='266919005' or $dU='UNKNOWN IF EVER SMOKED' or $dU='NEVER SMOKER'">
						<td/>
					</xsl:when>
					<xsl:otherwise>
						<td><xsl:value-of select="$startTime"/></td>
					</xsl:otherwise>
				</xsl:choose>
				<!-- Display ToTime only when person is a former smoker. -->
				<xsl:choose>
					<xsl:when test="SocialHabit/Code/text()='8517006'or $dU='FORMER SMOKER'">
						<td><xsl:value-of select="$stopTime"/></td>
					</xsl:when>
					<xsl:otherwise>
						<td/>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-Entries">
		<xsl:param name="sdaSmokingCodes"/>
		
		<xsl:apply-templates select="SocialHistory" mode="socialHistory-EntryDetail">
			<xsl:with-param name="sdaSmokingCodes" select="$sdaSmokingCodes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-EntryDetail">
		<xsl:param name="sdaSmokingCodes"/>
		
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:choose>
					<xsl:when test="not(contains(concat('|',$sdaSmokingCodes),concat('|',SocialHabit/Code/text(),'|')))">
						<xsl:apply-templates select="." mode="socialHistory-EntryDetail-NonSmoking">
							<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="socialHistory-EntryDetail-Smoking">
							<xsl:with-param name="sdaSmokingCodes" select="$sdaSmokingCodes"/>
							<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-EntryDetail-NonSmoking">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:apply-templates select="." mode="templateIds-socialHistoryEntry"/>
	
		<!--
			Field : Social History Id
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/id
			Source: HS.SDA3.SocialHistory ExternalId
			Source: /Container/SocialHistories/SocialHistory/ExternalId
			StructuredMappingRef: id-External
		-->
		<xsl:apply-templates select="." mode="id-External"/>
		
		<!--
			Field : Social History Type
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/code
			Source: HS.SDA3.SocialHistory SocialHabit
			Source: /Container/SocialHistories/SocialHistory/SocialHabit
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="SocialHabit" mode="generic-Coded"/>
				
		<text><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}"/></text>
		<statusCode code="completed"/>
		
		<!--
			Field : Social History Start Date
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/effectiveTime/low/@value
			Source: HS.SDA3.SocialHistory FromTime
			Source: /Container/SocialHistories/SocialHistory/FromTime
		-->
		<!--
			Field : Social History End Date
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/effectiveTime/high/@value
			Source: HS.SDA3.SocialHistory ToTime
			Source: /Container/SocialHistories/SocialHistory/ToTime
		-->
		<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
		
		<!--
			Field : Social History Social Habit Quantity
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/value/text()
			Source: HS.SDA3.SocialHistory SocialHabitQty.Description
			Source: /Container/SocialHistories/SocialHistory/SocialHabitQty/Description
		-->
		<xsl:choose>
			<xsl:when test="string-length(SocialHabitQty/Description)">
				<xsl:apply-templates select="SocialHabitQty/Description" mode="value-ST"/>
			</xsl:when>
			<xsl:otherwise><xsl:apply-templates select="SocialHabitQty/Code" mode="value-ST"/></xsl:otherwise>
		</xsl:choose>
		
		<!--
			Field : Social History Author
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/author
			Source: HS.SDA3.SocialHistory EnteredBy
			Source: /Container/SocialHistories/SocialHistory/EnteredBy
			StructuredMappingRef: author-Human
		-->
		<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
						
		<!--
			Field : Social History Information Source
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/informant
			Source: HS.SDA3.SocialHistory EnteredAt
			Source: /Container/SocialHistories/SocialHistory/EnteredAt
			StructuredMappingRef: informant
		-->
		<xsl:apply-templates select="EnteredAt" mode="informant"/>
		
		<xsl:apply-templates select="Status" mode="observation-socialHistoryStatus"/>
		
		<!--
			Field : Social History Comments
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/entryRelationship/act[code/@code='48767-8']/text
			Source: HS.SDA3.SocialHistory SocialHabitComments
			Source: /Container/SocialHistories/SocialHistory/SocialHabitComments
		-->
		<xsl:apply-templates select="SocialHabitComments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-EntryDetail-Smoking">
		<xsl:param name="sdaSmokingCodes"/>
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:apply-templates select="." mode="templateIds-smokingStatusEntry"/>
	
		<xsl:apply-templates select="." mode="id-External"/>
		
		<code code="ASSERTION" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
		<statusCode code="completed"/>
		
		<xsl:variable name="cU" select="translate(SocialHabit/Code/text(),$lowerCase,$upperCase)"/>
		<xsl:variable name="dU" select="translate(SocialHabit/Description/text(),$lowerCase,$upperCase)"/>
		
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="$cU='CURRENT EVERY DAY SMOKER' or $dU='CURRENT EVERY DAY SMOKER'">449868002</xsl:when>
				<xsl:when test="$cU='CURRENT SOME DAY SMOKER' or $dU='CURRENT SOME DAY SMOKER'">428041000124106</xsl:when>
				<xsl:when test="$cU='FORMER SMOKER' or $dU='FORMER SMOKER'">8517006</xsl:when>
				<xsl:when test="$cU='NEVER SMOKER' or $dU='NEVER SMOKER'">266919005</xsl:when>
				<xsl:when test="$cU='SMOKER, CURRENT STATUS UNKNOWN' or $dU='SMOKER, CURRENT STATUS UNKNOWN'">77176002</xsl:when>
				<xsl:when test="$cU='UNKNOWN IF EVER SMOKED' or $dU='UNKNOWN IF EVER SMOKED'">266927001</xsl:when>
				<xsl:when test="$cU='HEAVY TOBACCO SMOKER' or $dU='HEAVY TOBACCO SMOKER'">428071000124103</xsl:when>
				<xsl:when test="$cU='LIGHT TOBACCO SMOKER' or $dU='LIGHT TOBACCO SMOKER'">428061000124105</xsl:when>
				<xsl:otherwise><xsl:value-of select="SocialHabit/Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="string-length(SocialHabit/Description/text())">
					<xsl:value-of select="SocialHabit/Description/text()"/>
				</xsl:when>
				<xsl:when test="$code='449868002'">Current every day smoker</xsl:when>
				<xsl:when test="$code='428041000124106'">Current some day smoker</xsl:when>
				<xsl:when test="$code='8517006'">Former smoker</xsl:when>
				<xsl:when test="$code='266919005'">Never smoker</xsl:when>
				<xsl:when test="$code='77176002'">Smoker, current status unknown</xsl:when>
				<xsl:when test="$code='266927001'">Unknown if ever smoked</xsl:when>
				<xsl:when test="$code='428071000124103'">Heavy tobacco smoker</xsl:when>
				<xsl:when test="$code='428061000124105'">Light tobacco smoker</xsl:when>
				<xsl:otherwise><xsl:value-of select="SocialHabit/Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="SocialHabit/Code/text()='266927001' or $dU='UNKNOWN IF EVER SMOKED'">
				<effectiveTime>
					<low nullFlavor="NASK"/>
				</effectiveTime>
			</xsl:when>
			<xsl:when test="SocialHabit/Code/text()='266919005' or $dU='NEVER SMOKER'">
				<effectiveTime>
					<low nullFlavor="NA"/>
				</effectiveTime>
			</xsl:when>
			<xsl:when test="SocialHabit/Code/text()='8517006' or $dU='FORMER SMOKER'">
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="effectiveTime-FromTo">
					<xsl:with-param name="includeHighTime" select="false()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
				
		<!-- Because this is already detected to be a SNOMED smoking status, force in SNOMED for the codeSystem. -->
		<value xsi:type="CD" code="{$code}" displayName="{$description}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}">
			<originalText><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}"/></originalText>
		</value>
		
		<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
		
		<xsl:apply-templates select="EnteredAt" mode="informant"/>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-NoData">
		<text><xsl:value-of select="$exportConfiguration/socialHistory/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-NoData-Smoking-Narrative">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<table border="1" width="100%">
			<thead>
				<tr>
					<th>Smoking Status</th>
					<th>Start Date</th>
					<th>Stop Date</th>
				</tr>
			</thead>
			<tbody>
				<tr ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryNarrative/text(), $narrativeLinkSuffix)}">
					<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}">Unknown if ever smoked</td>
					<td/>
					<td/>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-NoData-Smoking-EntryDetail">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-smokingStatusEntry"/>
				<id nullFlavor="UNK"/>
				<code code="ASSERTION" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
				<statusCode code="completed"/>
				<effectiveTime>
					<low nullFlavor="NASK"/>
				</effectiveTime>
				<value xsi:type="CD" code="266927001" displayName="Unknown if ever smoked" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}">
					<originalText><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}"/></originalText>
				</value>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="GenderIdentity" mode="socialHistory-Narrative-GenderIdentity">
		<xsl:param name="genderIdentityDate"/>
		
		<xsl:variable name="narrativeLinkSuffix">G</xsl:variable>
		<table border="1" width="100%">
			<thead>
				<tr>
					<th>Social History</th>
					<th>Observation</th>
					<th>Date</th>
				</tr>
			</thead>
			<tbody>
				<tr ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryNarrative/text(), $narrativeLinkSuffix)}">
					<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}">Gender identity</td>
					<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryObservation/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="." mode="descriptionOrCode"/></td>
					<td><xsl:apply-templates select="$genderIdentityDate" mode="narrativeDateFromODBC"/></td>
				</tr>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="GenderIdentity" mode="socialHistory-GenderIdentity-EntryDetail">
		<xsl:param name="genderIdentityDate"/>
		<xsl:variable name="narrativeLinkSuffix">G</xsl:variable>

		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-socialHistoryEntry"/>
				<code code="76691-5" displayName="Gender identity">
					<originalText><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}"/></originalText>
				</code>
				<text><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>

				<xsl:if test="string-length($genderIdentityDate)">
					<effectiveTime xsi:type="IVL_TS">
						<low><xsl:attribute name="value"><xsl:apply-templates select="$genderIdentityDate" mode="xmlToHL7TimeStamp"/></xsl:attribute></low>
					</effectiveTime>
				</xsl:if>

				<!--
					Field : Patient GenderIdentity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation[code/@code='76691-5']/value
					Source: HS.SDA3.Patient GenderIdentity
					Source: /Container/Patient/GenderIdentity
				-->
				<value>
					<xsl:attribute name="code"><xsl:value-of select="Code/text()"/></xsl:attribute>
					<xsl:attribute name="displayName"><xsl:value-of select="Description/text()"/></xsl:attribute>
					<xsl:attribute name="codeSystem"><xsl:value-of select="SDACodingStandard/text()"/></xsl:attribute>
					<originalText><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistoryObservation/text(), $narrativeLinkSuffix)}"/></originalText>
				</value>
			</observation>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="observation-socialHistoryStatus">
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-socialHistoryStatusObservation"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!-- Status Detail -->
				<xsl:variable name="statusValue" select="translate(text(), $lowerCase, $upperCase)"/>
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<SDACodingStandard><xsl:value-of select="$snomedName"/></SDACodingStandard>
						<Code>
							<xsl:choose>
								<xsl:when test="$statusValue = 'I'">73425007</xsl:when>
								<xsl:otherwise>55561003</xsl:otherwise>
							</xsl:choose>
						</Code>
						<Description>
							<xsl:choose>
								<xsl:when test="$statusValue = 'I'">Inactive</xsl:when>
								<xsl:otherwise>Active</xsl:otherwise>
							</xsl:choose>
						</Description>
					</Status>
				</xsl:variable>
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<!--
					Field : Social History Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/entryRelationship/observation[code/@code='33999-4']/value/@code
					Source: HS.SDA3.SocialHistory Status
					Source: /Container/SocialHistories/SocialHistory/Status
					Note  : SDA SocialHistory Status value of I is exported
							as CDA value for Inactive, and all other Status
							values are exported as CDA value for Active.
							Because SDA SocialHistory Status is %String,
							export automatically populates the the SNOMED
							code system in for this value.
				-->
				<xsl:apply-templates select="$status" mode="snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-socialHistoryEntry">
		<templateId root="{$ccda-SocialHistoryObservation}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-smokingStatusEntry">
		<templateId root="{$ccda-SmokingStatusObservation}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-socialHistoryStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-SocialHistoryStatusObservation"><templateId root="{$hl7-CCD-SocialHistoryStatusObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
