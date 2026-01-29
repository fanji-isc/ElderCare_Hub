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
		<xsl:variable name="descriptionToUse">
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
				<td ID="{concat($exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), position())}"><xsl:value-of select="$descriptionToUse"/></td>
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
			HS.SDA3.SocialHistory ExternalId
			CDA Section: Social History
			CDA Field: Social History Entry
			CDA XPath: entry/observation/id
		-->	
		<xsl:apply-templates select="." mode="id-External"/>
		
		<!--
			HS.SDA3.SocialHistory SocialHabit
			CDA Section: Social History
			CDA Field: Social History Type
			CDA XPath: entry/observation/code/value
		-->		
		<xsl:apply-templates select="SocialHabit" mode="generic-Coded"/>
				
		<text><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}"/></text>
		<statusCode code="completed"/>

		<!--
			HS.SDA3.SocialHistory EnteredOn
			CDA Section: Social History
			CDA Field: Social History Dates
			CDA XPath: entry/observation/effectiveTime
		-->						
		<xsl:apply-templates select="EnteredOn" mode="effectiveTime"/>
		
		<!--
			HS.SDA3.SocialHistory SocialHabitQty
			CDA Section: Social History
			CDA Field: Social History Observed Value
			CDA XPath: entry/observation
		-->		
		<xsl:choose>
			<xsl:when test="string-length(SocialHabitQty/Description)">
				<xsl:apply-templates select="SocialHabitQty/Description" mode="value-ST"/>
			</xsl:when>
			<xsl:otherwise><xsl:apply-templates select="SocialHabitQty/Code" mode="value-ST"/></xsl:otherwise>
		</xsl:choose>
		
		<!--
			HS.SDA3.SocialHistory EnteredBy
			CDA Section: Social History
			CDA Field: Author
			CDA XPath: entry/observation/author
		-->		
		<xsl:apply-templates select="EnteredBy" mode="author-Human"/>

		<!--
			HS.SDA3.SocialHistory EnteredAt
			CDA Section: Social History
			CDA Field: Information Source
			CDA XPath: entry/observation/informant
		-->
		<xsl:apply-templates select="EnteredAt" mode="informant"/>
		<xsl:apply-templates select="Status" mode="observation-socialHistoryStatus"/>
		
		<!--
			HS.SDA3.SocialHistory SocialHabitComments
			CDA Section: Social History
			CDA Field: Social History Comments
			CDA XPath: entry/observation/entryRelationship/observation[code/@code='33999-4']/value
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
		
		<xsl:variable name="codeToUse">
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
		
		<xsl:variable name="descriptionToUse">
			<xsl:choose>
				<xsl:when test="string-length(SocialHabit/Description/text())">
					<xsl:value-of select="SocialHabit/Description/text()"/>
				</xsl:when>
				<xsl:when test="$codeToUse='449868002'">Current every day smoker</xsl:when>
				<xsl:when test="$codeToUse='428041000124106'">Current some day smoker</xsl:when>
				<xsl:when test="$codeToUse='8517006'">Former smoker</xsl:when>
				<xsl:when test="$codeToUse='266919005'">Never smoker</xsl:when>
				<xsl:when test="$codeToUse='77176002'">Smoker, current status unknown</xsl:when>
				<xsl:when test="$codeToUse='266927001'">Unknown if ever smoked</xsl:when>
				<xsl:when test="$codeToUse='428071000124103'">Heavy tobacco smoker</xsl:when>
				<xsl:when test="$codeToUse='428061000124105'">Light tobacco smoker</xsl:when>
				<xsl:otherwise><xsl:value-of select="SocialHabit/Code/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!--
			HS.SDA3.SocialHistory EnteredOn
			CDA Section: Social History
			CDA Field: Social History Dates
			CDA XPath: entry/observation/effectiveTime
		-->		
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
			
		<!--
			HS.SDA3.SocialHistory SocialHabit
			CDA Section: Social History
			CDA Field: Social History Type
			CDA XPath: entry/observation/code/value
		-->			
		<!-- Because this is already detected to be a SNOMED smoking status, force in SNOMED for the codeSystem. -->
		<value xsi:type="CD" code="{$codeToUse}" displayName="{$descriptionToUse}" codeSystem="{$snomedOID}" codeSystemName="{$snomedName}">
			<originalText><reference value="{concat('#', $exportConfiguration/socialHistory/narrativeLinkPrefixes/socialHistorySocialHabit/text(), $narrativeLinkSuffix)}"/></originalText>
		</value>
		
		<!--
			HS.SDA3.SocialHistory EnteredBy
			CDA Section: Social History
			CDA Field: Author
			CDA XPath: entry/observation/author
		-->		
		<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
		
		<!--
			HS.SDA3.SocialHistory EnteredAt
			CDA Section: Social History
			CDA Field: Information Source
			CDA XPath: entry/observation/informant
		-->		
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
	
	<xsl:template match="*" mode="observation-socialHistoryStatus">
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-socialHistoryStatusObservation"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!--
					Status Detail
					
					SocialHistory Status in SDA export is only I for Inactive or any
					other value for Active. SDA SocialHistory Status is String, so
					it comes here with no code system. Force the SNOMED OID in.
				-->
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
				
				<xsl:apply-templates select="$status" mode="snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>

	<xsl:template match="*" mode="templateIds-socialHistoryEntry">
		<xsl:if test="$hitsp-CDA-SocialHistory"><templateId root="{$hitsp-CDA-SocialHistory}"/></xsl:if>
		<xsl:if test="$hl7-CCD-SocialHistoryObservation"><templateId root="{$hl7-CCD-SocialHistoryObservation}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SimpleObservations"><templateId root="{$ihe-PCC-SimpleObservations}"/></xsl:if>
		<xsl:if test="$ihe-PCC-SocialHistoryObservation"><templateId root="{$ihe-PCC-SocialHistoryObservation}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-smokingStatusEntry">
		<templateId root="{$ccda-SmokingStatusObservation}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-socialHistoryStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
		<xsl:if test="$hl7-CCD-SocialHistoryStatusObservation"><templateId root="{$hl7-CCD-SocialHistoryStatusObservation}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
