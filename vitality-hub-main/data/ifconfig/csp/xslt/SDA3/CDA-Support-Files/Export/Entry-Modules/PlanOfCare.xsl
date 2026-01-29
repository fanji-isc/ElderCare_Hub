<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:variable name="POCeffectiveTimeCenter" select="$exportConfiguration/planOfCare/effectiveTimeCenter/text()"/>
	<xsl:template match="*" mode="planOfCare-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Planned Activity</th>
						<th>Planned Date</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="RadOrders/RadOrder[not(Result)] | LabOrders/LabOrder[not(Result)] | OtherOrders/OtherOrder[not(Result)] | Appointments/Appointment[Status/text()='BOOKED'] | Procedures/Procedure[CustomPairs/NVPair[Name/text()='PlanOfCare' or Name/text()='PlanOfTreatment']] | CustomObjects/CustomObject[CustomType/text()='PlanOfCareGoal']" mode="planOfCare-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareNarrative/text(), $narrativeLinkSuffix)}">
			<xsl:choose>
				<xsl:when test="local-name()='LabOrder' or local-name()='RadOrder' or local-name()='OtherOrder'">
					<td><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
					<td><xsl:apply-templates select="ProcedureTime" mode="narrativeDateFromODBC"/></td>
					<td ID="{concat($exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Comments/text()"/></td>
				</xsl:when>
				<xsl:when test="local-name()='Appointment'">
					<td><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></td>
					<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
					<td ID="{concat($exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(), $narrativeLinkSuffix)}"><xsl:value-of select="Notes/text()"/></td>
				</xsl:when>
				<xsl:when test="local-name()='Procedure'">
					<td><xsl:apply-templates select="Procedure" mode="originalTextOrDescriptionOrCode"/></td>
					<td><xsl:apply-templates select="ProcedureTime" mode="narrativeDateFromODBC"/></td>
					<td ID="{concat($exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(), $narrativeLinkSuffix)}"></td>
				</xsl:when>
				<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareGoal'">
					<td><xsl:value-of select="CustomPairs/NVPair[Name/text()='PlanOfCareGoalDescription']/Value/text()"/></td>
					<td><xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/></td>
					<td ID="{concat($exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(), $narrativeLinkSuffix)}"></td>
				</xsl:when>
			</xsl:choose>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NoData">
		<text><xsl:value-of select="$exportConfiguration/planOfCare/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="planOfCare-Entries">
		<xsl:apply-templates select="RadOrders/RadOrder[not(Result)] 
		| LabOrders/LabOrder[not(Result)] 
		| OtherOrders/OtherOrder[not(Result)] 
		| Appointments/Appointment[Status/text()='BOOKED'] 
		| Procedures/Procedure[((CustomPairs/NVPair/Name/text()='PlanOfCare') or (CustomPairs/NVPair/Name/text()='PlanOfTreatment')) 
			or (((Status/Code/text()='active') or not(string-length(Status/Code/text()))) 
				and ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)))]
		| CustomObjects/CustomObject[CustomType/text()='PlanOfCareGoal']" mode="planOfCare-Entry"/>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-Entry">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
			
		<xsl:choose>
			<xsl:when test="local-name()='LabOrder' or local-name()='RadOrder' or local-name()='OtherOrder'">
				<xsl:apply-templates select="." mode="planOfCare-EntryDetail">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="local-name()='Appointment'">
				<xsl:apply-templates select="." mode="planOfCare-EntryDetailEncounter">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="local-name()='Procedure'">
				<xsl:apply-templates select="." mode="planOfCare-EntryDetailProcedure">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareGoal'">
				<xsl:apply-templates select="." mode="planOfCare-EntryDetail-Goal">
					<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail">
		<xsl:param name="narrativeLinkSuffix"/>		
		
		<entry typeCode="DRIV">
			<observation classCode="OBS" moodCode="RQO">
				<xsl:apply-templates select="." mode="templateIds-planOfCareEntry"/>

				<!-- External, Placer, and Filler IDs-->
				<xsl:apply-templates select="." mode="id-External"/>
				<xsl:apply-templates select="." mode="id-Placer"/>
				<xsl:apply-templates select="." mode="id-Filler"/>
				
				<xsl:apply-templates select="OrderItem" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="active"/>

				<!-- Effective Time -->
				<xsl:apply-templates select="." mode="effectiveTime">
					<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
				</xsl:apply-templates>
				
				<value xsi:type="BL" value="true"/>

				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>

				<!-- Link this care plan to encounter noted in encounters section -->
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetailEncounter">
		<xsl:param name="narrativeLinkSuffix"/>		
		
		<entry typeCode="DRIV">
			<encounter classCode="ENC" moodCode="PRMS">
				<xsl:apply-templates select="." mode="templateIds-planOfCareEntryEncounter"/>

				<!-- External, Placer, and Filler IDs-->
				<xsl:apply-templates select="." mode="id-External"/>
				<xsl:apply-templates select="." mode="id-Placer"/>
				<xsl:apply-templates select="." mode="id-Filler"/>
				
				<xsl:apply-templates select="OrderItem" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareNarrative/text(), $narrativeLinkSuffix)}"/></text>

				<!-- Effective Time -->
				<xsl:apply-templates select="." mode="effectiveTime">
					<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="CareProvider" mode="performer"/>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
			</encounter>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetailProcedure">
		<xsl:param name="narrativeLinkSuffix"/>		
		
		<entry typeCode="DRIV">
			<procedure classCode="PROC" moodCode="INT">
				<xsl:apply-templates select="." mode="templateIds-planOfCareEntryProcedure"/>

				<!-- External, Placer, and Filler IDs-->
				<xsl:apply-templates select="." mode="id-External"/>
				<xsl:apply-templates select="." mode="id-Placer"/>
				<xsl:apply-templates select="." mode="id-Filler"/>
				
				<xsl:apply-templates select="Procedure" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="active"/>

				<!-- Effective Time -->
				<xsl:apply-templates select="." mode="effectiveTime-procedure">
					<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="Clinician" mode="performer"/>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
			</procedure>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail-Goal">
		<xsl:param name="narrativeLinkSuffix"/>		
		
		<entry typeCode="DRIV">
			<procedure classCode="PROC" moodCode="INT">
				<xsl:apply-templates select="." mode="templateIds-planOfCareEntryProcedure"/>
				
				<xsl:apply-templates select="." mode="id-External"/>
				
				<xsl:apply-templates select="CustomPairs" mode="generic-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="hsCustomPairElementName" select="'PlanOfCareGoal'"/>
					<xsl:with-param name="xsiType" select="'CE'"/>
					<xsl:with-param name="writeOriginalText" select="'0'"/>
				</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareNarrative/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="active"/>
				
				<xsl:choose>
					<xsl:when test="string-length(FromTime/text()) or string-length(ToTime/text())">
						<xsl:apply-templates select="." mode="effectiveTime">
							<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<effectiveTime nullFlavor="UNK"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
			</procedure>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareEntry">
		<xsl:if test="$hitsp-CDA-PlanOfCare"><templateId root="{$hitsp-CDA-PlanOfCare}"/></xsl:if>
		<xsl:if test="$hl7-CCD-PlanOfCareActivity"><templateId root="{$hl7-CCD-PlanOfCareActivity}"/></xsl:if>
		<xsl:if test="$ihe-PCC-CarePlan-ObservationRequest"><templateId root="{$ihe-PCC-CarePlan-ObservationRequest}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareEntryEncounter">
		<xsl:if test="$hitsp-CDA-PlanOfCare"><templateId root="{$hitsp-CDA-PlanOfCare}"/></xsl:if>
		<xsl:if test="$ihe-PCC_CDASupplement-Encounters"><templateId root="{$ihe-PCC_CDASupplement-Encounters}"/></xsl:if>
		<xsl:if test="$hl7-CCD-PlanOfCareActivity"><templateId root="{$hl7-CCD-PlanOfCareActivity}"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareEntryProcedure">
		<xsl:if test="$hitsp-CDA-PlanOfCare"><templateId root="{$hitsp-CDA-PlanOfCare}"/></xsl:if>
		<xsl:if test="$ihe-PCC_CDASupplement-ProcedureEntry"><templateId root="{$ihe-PCC_CDASupplement-ProcedureEntry}"/></xsl:if>
		<xsl:if test="$hl7-CCD-PlanOfCareActivity"><templateId root="{$hl7-CCD-PlanOfCareActivity}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
