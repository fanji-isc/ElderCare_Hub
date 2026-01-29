<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- These status codes disqualify an order from appearing in Plan of Care. -->
	<xsl:variable name="notPlanOfCareStatus">|C|D|E|I|R|</xsl:variable>
	<xsl:variable name="POCeffectiveTimeCenter" select="$exportConfiguration/planOfCare/effectiveTimeCenter/text()"/>
	
	<xsl:template match="*" mode="planOfCare-Narrative">
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Planned Activity</th>
						<th>Planned Date</th>
						<th>Details</th>
						<th>Comments</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="RadOrders/RadOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]" mode="planOfCare-NarrativeDetail"/>
					<xsl:apply-templates select="LabOrders/LabOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]" mode="planOfCare-NarrativeDetail"/>
					<xsl:apply-templates select="OtherOrders/OtherOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]" mode="planOfCare-NarrativeDetail"/>
					<xsl:apply-templates select="Appointments/Appointment[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0]" mode="planOfCare-NarrativeDetail"/>
					<xsl:apply-templates select="Referrals/Referral[not(string-length(ToTime/text())) or isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' ')) &lt; 0]" mode="planOfCare-NarrativeDetail"/>
					<xsl:apply-templates select="Medications/Medication[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0 and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]" mode="planOfCare-NarrativeDetail"/>
					<xsl:apply-templates select="Procedures/Procedure[((CustomPairs/NVPair/Name/text()='PlanOfCare') or (CustomPairs/NVPair/Name/text()='PlanOfTreatment')) 
						or (((Status/Code/text()='active') or not(string-length(Status/Code/text()))) 
							and ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)))]" mode="planOfCare-NarrativeDetail"/>
					<xsl:apply-templates select="CustomObjects/CustomObject[CustomType/text()='PlanOfCareGoal']" mode="planOfCare-NarrativeDetail"/>
					<xsl:apply-templates select="CustomObjects/CustomObject[CustomType/text()='PlanOfCareInstructions']" mode="planOfCare-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix">
			<xsl:choose>
				<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareGoal'">
					<xsl:value-of select="concat('Goal-',position())"/>
				</xsl:when>
				<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareInstructions'">
					<xsl:value-of select="concat('Instructions-',position())"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="concat(local-name(),'-',position())"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="activityType">
			<xsl:choose>
				<xsl:when test="local-name()='LabOrder' or local-name()='RadOrder' or local-name()='OtherOrder'">
					<xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-OrderType"/>
				</xsl:when>
				<xsl:when test="local-name()='Appointment'">Future Appointment</xsl:when>
				<xsl:when test="local-name()='Referral'">Referral</xsl:when>
				<xsl:when test="local-name()='Medication'">Medication</xsl:when>
				<xsl:when test="local-name()='Procedure'">Procedure</xsl:when>
				<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareGoal'">Goal</xsl:when>
				<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareInstructions'">Instructions</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="activityTime">
			<xsl:choose>
				<xsl:when test="local-name()='LabOrder' or local-name()='RadOrder' or local-name()='OtherOrder'">
					<xsl:choose>
						<xsl:when test="string-length(SpecimenCollectedTime/text())">
							<xsl:apply-templates select="SpecimenCollectedTime" mode="narrativeDateFromODBC"/>
						</xsl:when>
						<xsl:when test="string-length(FromTime/text())">
							<xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="local-name()='Appointment'">
					<xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/>
				</xsl:when>
				<xsl:when test="local-name()='Referral'">
					<xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/>
				</xsl:when>
				<xsl:when test="local-name()='Medication'">
					<xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/>
				</xsl:when>
				<xsl:when test="local-name()='Procedure'">
					<xsl:choose>
						<xsl:when test="string-length(ProcedureTime/text())">
							<xsl:apply-templates select="ProcedureTime" mode="narrativeDateFromODBC"/>
						</xsl:when>
						<xsl:when test="string-length(FromTime/text())">
							<xsl:apply-templates select="FromTime" mode="narrativeDateFromODBC"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareGoal'">
					<xsl:apply-templates select="ToTime" mode="narrativeDateFromODBC"/>
				</xsl:when>
				<!-- Activity time for Instructions is intentionally omitted. -->
			</xsl:choose>
		</xsl:variable>
		
		<tr ID="{concat($exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareNarrative/text(), $narrativeLinkSuffix)}">
			<td><xsl:value-of select="$activityType"/></td>
			<td><xsl:value-of select="$activityTime"/></td>
			<td ID="{concat($exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)}">
				<xsl:choose>
					<xsl:when test="local-name()='LabOrder' or local-name()='RadOrder' or local-name()='OtherOrder' or local-name()='Medication'">
						<xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-OrderDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='Appointment'">
						<xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-AppointmentDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='Referral'">
						<xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-ReferralDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='Procedure'">
						<xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-ProcedureDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareGoal'">
						<xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-GoalDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='CustomObject' and CustomType/text()='PlanOfCareInstructions'">
						<xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-InstructionsDetails"/>
					</xsl:when>
				</xsl:choose>
			</td>
			<td>
				<xsl:if test="(local-name()='LabOrder' or local-name()='RadOrder' or local-name()='OtherOrder' or local-name()='Medication') and string-length(Comments/text())">
					<xsl:attribute name="ID"><xsl:value-of select="concat($exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(), $narrativeLinkSuffix)"/></xsl:attribute>
					<xsl:value-of select="Comments/text()"/>
				</xsl:if>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail-OrderType">
		<!-- This template assumes that the Order has no Result.      -->
		<!-- DateDiff 0 = today, >0 = before today, <0 = after today. -->
		<xsl:variable name="fromTimeDateDiff" select="isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' '))"/>
		<xsl:variable name="collectTimeDateDiff" select="isc:evaluate('dateDiff', 'dd', translate(SpecimenCollectedTime/text(), 'TZ', ' '))"/>
		<xsl:choose>
			<xsl:when test="Status/text()='P'">Future Scheduled Test</xsl:when>
			<xsl:when test="Status/text()='H' or Status/text()='Q' or Status/text()='S' or Status/text()='IP'">Diagnostic Test Pending</xsl:when>
			<xsl:when test="string-length(SpecimenCollectedTime/text()) and $collectTimeDateDiff &gt;= 0">Diagnostic Test Pending</xsl:when>
			<xsl:when test="string-length(FromTime/text()) and $fromTimeDateDiff &gt;= 0">Diagnostic Test Pending</xsl:when>
			<xsl:otherwise>Future Scheduled Test</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail-OrderDetails">
		<xsl:variable name="testCode"><xsl:apply-templates select="OrderItem" mode="codeOrDescription"/></xsl:variable>
		<xsl:variable name="testDesc"><xsl:apply-templates select="OrderItem" mode="originalTextOrDescriptionOrCode"/></xsl:variable>
		
		<xsl:value-of select="concat($testDesc,' [code = ',$testCode,']')"/>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail-AppointmentDetails">
		<!-- Name can be for a person, or if person not provided, then organization. -->
		<xsl:variable name="appointmentName">
			<xsl:choose>
				<xsl:when test="CareProvider">
					<xsl:apply-templates select="CareProvider" mode="careProviderName"/>
				</xsl:when>
				<xsl:when test="Location">
					<xsl:apply-templates select="Location/Organization" mode="organizationName"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Address can be for a person, or if person not provided, then organization. -->
		<xsl:variable name="appointmentAddress">
			<xsl:choose>
				<xsl:when test="CareProvider/Address">
					<xsl:apply-templates select="CareProvider/Address" mode="addressSingleLine"/>
				</xsl:when>
				<xsl:when test="Location/Organization/Address">
					<xsl:apply-templates select="Location/Organization/Address" mode="addressSingleLine"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($appointmentName)">
				<xsl:value-of select="concat($appointmentName,', ',$appointmentAddress)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$appointmentAddress"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail-ReferralDetails">
		<!-- Name can be for a person, or if person not provided, then organization. -->
		<xsl:variable name="referralName">
			<xsl:choose>
				<xsl:when test="ReferredToProvider">
					<xsl:apply-templates select="ReferredToProvider" mode="careProviderName"/>
				</xsl:when>
				<xsl:when test="ReferredToOrganization">
					<xsl:apply-templates select="ReferredToOrganization/Organization" mode="organizationName"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Address can be for a person, or if person not provided, then organization. -->
		<xsl:variable name="referralAddress">
			<xsl:choose>
				<xsl:when test="ReferredToProvider/Address">
					<xsl:apply-templates select="ReferredToProvider/Address" mode="addressSingleLine"/>
				</xsl:when>
				<xsl:when test="ReferredToOrganization/Organization/Address">
					<xsl:apply-templates select="ReferredToOrganization/Organization/Address" mode="addressSingleLine"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="referralReason">
			<xsl:choose>
				<xsl:when test="string-length(ReferralReason/text())">
					<xsl:value-of select="concat(', Reason: ',ReferralReason/text())"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($referralName)">
				<xsl:value-of select="concat($referralName,', ',$referralAddress,$referralReason)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($referralAddress,$referralReason)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="careProviderName">
		<!-- Format the name into prefix, first, last, suffix. For display in narrative. -->
		<xsl:variable name="normalizedDescription" select="normalize-space(Description/text())"/>
		<xsl:choose>
			<xsl:when test="string-length($normalizedDescription) or Name">
				<xsl:variable name="contactPrefix" select="Name/NamePrefix/text()"/>
				<xsl:variable name="contactFirstName">
					<xsl:choose>
						<xsl:when test="string-length(Name/GivenName/text())">
							<xsl:value-of select="Name/GivenName/text()"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,',')">
							<xsl:value-of select="normalize-space(substring-after($normalizedDescription,','))"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription)">
							<xsl:value-of select="normalize-space(substring-before($normalizedDescription,' '))"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="contactLastName">
					<xsl:choose>
						<xsl:when test="string-length(Name/FamilyName/text())">
							<xsl:value-of select="Name/FamilyName/text()"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,',')">
							<xsl:value-of select="normalize-space(substring-before($normalizedDescription,','))"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription) and contains($normalizedDescription,' ')">
							<xsl:value-of select="normalize-space(substring-after($normalizedDescription,' '))"/>
						</xsl:when>
						<xsl:when test="string-length($normalizedDescription)">
							<xsl:value-of select="$normalizedDescription"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="contactSuffix" select="Name/ProfessionalSuffix/text()"/>
				
				<xsl:choose>
					<xsl:when test="string-length($contactPrefix) and string-length($contactSuffix)">
						<xsl:value-of select="concat($contactPrefix,' ',$contactFirstName,' ',$contactLastName,' ',$contactSuffix)"/>
					</xsl:when>
					<xsl:when test="not(string-length($contactPrefix)) and string-length($contactSuffix)">
						<xsl:value-of select="concat($contactFirstName,' ',$contactLastName,' ',$contactSuffix)"/>
					</xsl:when>
					<xsl:when test="string-length($contactPrefix) and not(string-length($contactSuffix))">
						<xsl:value-of select="concat($contactPrefix,' ',$contactFirstName,' ',$contactLastName)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($contactFirstName,' ',$contactLastName)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="organizationName">
		<xsl:apply-templates select="." mode="descriptionOrCode"/>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail-ProcedureDetails">
		<xsl:apply-templates select="Procedure" mode="descriptionOrCode"/>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail-GoalDetails">
		<xsl:value-of select="concat(CustomPairs/NVPair[Name/text()='PlanOfCareGoalDescription']/Value/text(),' [code = ',CustomPairs/NVPair[Name/text()='PlanOfCareGoalCode']/Value/text(),']')"/>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail-InstructionsDetails">
		<xsl:if test="CustomPairs/NVPair[Name/text()='PlanOfCareInstructionsText']/Value/text()">
			<xsl:apply-templates select="CustomPairs/NVPair[Name='PlanOfCareInstructionsText']" mode="planOfCare-NarrativeDetail-InstructionsDetailsLines"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NarrativeDetail-InstructionsDetailsLines">
		<xsl:if test="position()>1"><br/></xsl:if>
		<xsl:value-of select="Value/text()"/>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-NoData">
		<text><xsl:value-of select="$exportConfiguration/planOfCare/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-Entries">
		<xsl:apply-templates select="RadOrders/RadOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]" mode="planOfCare-EntryDetail-Order"/>
		<xsl:apply-templates select="LabOrders/LabOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]" mode="planOfCare-EntryDetail-Order"/>
		<xsl:apply-templates select="OtherOrders/OtherOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]" mode="planOfCare-EntryDetail-Order"/>
		<xsl:apply-templates select="Appointments/Appointment[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0]" mode="planOfCare-EntryDetail-Appointment"/>
		<xsl:apply-templates select="Referrals/Referral[not(string-length(ToTime/text())) or isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' ')) &lt; 0]" mode="planOfCare-EntryDetail-Referral"/>
		<xsl:apply-templates select="Medications/Medication[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0 and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]" mode="planOfCare-EntryDetail-Medication"/>
		<xsl:apply-templates select="Procedures/Procedure[((CustomPairs/NVPair/Name/text()='PlanOfCare') or (CustomPairs/NVPair/Name/text()='PlanOfTreatment')) 
			or (((Status/Code/text()='active') or not(string-length(Status/Code/text()))) 
				and ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)))]" mode="planOfCare-EntryDetail-Procedure"/>
		<xsl:apply-templates select="CustomObjects/CustomObject[CustomType/text()='PlanOfCareGoal']" mode="planOfCare-EntryDetail-Goal"/>
		<xsl:apply-templates select="CustomObjects/CustomObject[CustomType/text()='PlanOfCareInstructions']" mode="planOfCare-EntryDetail-Instructions"/>
		
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail-Order">
		<xsl:variable name="narrativeLinkSuffix" select="concat(local-name(),'-',position())"/>
		
		<xsl:variable name="planOfCareOrderType"><xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-OrderType"/></xsl:variable>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS">
				<xsl:attribute name="moodCode">
					<xsl:choose>
						<xsl:when test="$planOfCareOrderType='Diagnostic Test Pending'">INT</xsl:when>
						<xsl:otherwise>RQO</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="." mode="templateIds-planOfCareActivityObservation"/>
				
				<xsl:apply-templates select="." mode="id-ExternalPlacerFiller"/>
				
				<xsl:apply-templates select="OrderItem" mode="generic-Coded"/>
				
				<statusCode code="new"/>
				
				<xsl:apply-templates select="." mode="effectiveTime">
					<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				<xsl:apply-templates select="Comments" mode="comment-entryRelationship"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<!-- Link this care plan to encounter noted in encounters section -->
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail-Medication">
		<xsl:variable name="narrativeLinkSuffix" select="concat(local-name(),'-',position())"/>
		
		<xsl:variable name="planOfCareOrderType"><xsl:apply-templates select="." mode="planOfCare-NarrativeDetail-OrderType"/></xsl:variable>
		
		<entry typeCode="DRIV">
			<substanceAdministration classCode="SBADM" moodCode="RQO">
				<xsl:apply-templates select="." mode="templateIds-planOfCareActivitySubstanceAdministration"/>
				
				<xsl:apply-templates select="." mode="id-ExternalPlacerFiller"/>
				
				<code nullFlavor="NA"/>
				<statusCode code="new"/>
				
				<xsl:apply-templates select="." mode="medication-duration"/>
				<xsl:apply-templates select="Frequency" mode="medication-frequency"/>
				<xsl:apply-templates select="Route" mode="code-route"/>
				<xsl:apply-templates select="." mode="medication-doseQuantity"/>
				<xsl:apply-templates select="." mode="medication-rateAmount"/>
				<xsl:apply-templates select="OrderItem" mode="medication-consumable"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/> 
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!-- Link this care plan to encounter noted in encounters section -->
				<xsl:apply-templates select="." mode="encounterLink-entryRelationship"/>
			</substanceAdministration>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail-Appointment">
		<xsl:variable name="narrativeLinkSuffix" select="concat('Appointment-',position())"/>
		
		<entry typeCode="DRIV">
			<encounter classCode="ENC" moodCode="INT">
				<xsl:apply-templates select="." mode="templateIds-planOfCareActivityEncounter"/>
				
				<xsl:apply-templates select="." mode="id-ApptExternalPlacerFiller"/>
				
				<xsl:apply-templates select="Type" mode="generic-Coded"></xsl:apply-templates>
				
				<statusCode code="new"/>
				
				<xsl:apply-templates select="." mode="effectiveTime">
					<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
				</xsl:apply-templates>
				
				<!-- Appointment Care Provider -->
				<xsl:apply-templates select="CareProvider" mode="performer"/>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!-- Appointment location -->
				<!-- The encounter-location template is located in Export/Entry-Modules/CCDA/Encounter.xsl -->
				<xsl:apply-templates select="Location" mode="encounter-location"/>
			</encounter>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail-Referral">
		<xsl:variable name="narrativeLinkSuffix" select="concat('Referral-',position())"/>
		
		<entry typeCode="DRIV">
			<encounter classCode="ENC" moodCode="RQO">
				<xsl:apply-templates select="." mode="templateIds-planOfCareActivityEncounter"/>
				
				<xsl:apply-templates select="." mode="id-ExternalPlacerFiller"/>
				
				<code nullFlavor="UNK">
					<originalText><xsl:value-of select="ReferralReason/text()"/></originalText>
				</code>
				
				<statusCode code="new"/>
				
				<xsl:apply-templates select="." mode="effectiveTime-FromTo">
					<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
				</xsl:apply-templates>
				
				<!-- Referee Care Provider -->
				<xsl:apply-templates select="ReferredToProvider" mode="performer"/>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
				
				<!-- Referee location -->
				<!-- The encounter-location template is located in Export/Entry-Modules/CCDA/Encounter.xsl -->
				<xsl:apply-templates select="ReferredToOrganization" mode="encounter-location"/>
			</encounter>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail-Procedure">
		<xsl:variable name="narrativeLinkSuffix" select="concat('Procedure-',position())"/>
		
		<entry typeCode="DRIV">
			<procedure classCode="PROC" moodCode="RQO">
				<xsl:apply-templates select="." mode="templateIds-planOfCareActivityProcedure"/>
				
				<xsl:apply-templates select="." mode="id-ExternalPlacerFiller"/>
				
				<xsl:apply-templates select="Procedure" mode="generic-Coded"><xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)"/></xsl:apply-templates>
				
				<statusCode code="active"/>
				
				<xsl:apply-templates select="." mode="effectiveTime-procedure">
					<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
			</procedure>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail-Goal">
		<xsl:variable name="narrativeLinkSuffix" select="concat('Goal-',position())"/>	
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="INT">
				<xsl:apply-templates select="." mode="templateIds-planOfCareActivityAct"/>
				
				<xsl:apply-templates select="." mode="id-External"/>
				
				<xsl:apply-templates select="CustomPairs" mode="generic-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="hsCustomPairElementName" select="'PlanOfCareGoal'"/>
					<xsl:with-param name="xsiType" select="'CE'"/>
					<xsl:with-param name="writeOriginalText" select="'0'"/>
				</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<xsl:if test="string-length(FromTime/text()) or string-length(ToTime/text())">
					<xsl:apply-templates select="." mode="effectiveTime">
						<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="planOfCare-EntryDetail-Instructions">
		<xsl:variable name="narrativeLinkSuffix" select="concat('Instructions-',position())"/>	
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="INT">
				<xsl:apply-templates select="." mode="templateIds-planOfCareInstruction"/>
				
				<xsl:apply-templates select="." mode="id-External"/>
				
				<xsl:apply-templates select="CustomPairs" mode="generic-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)"/>
					<xsl:with-param name="hsCustomPairElementName" select="'PlanOfCareInstructions'"/>
					<xsl:with-param name="xsiType" select="'CE'"/>
					<xsl:with-param name="writeOriginalText" select="'0'"/>
				</xsl:apply-templates>
				
				<text><reference value="{concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<xsl:if test="string-length(FromTime/text()) or string-length(ToTime/text())">
					<xsl:apply-templates select="." mode="effectiveTime">
						<xsl:with-param name="POCeffectiveTimeCenter" select="$POCeffectiveTimeCenter"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<xsl:apply-templates select="EnteredBy" mode="author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="informant"/>
			</act>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="observation-PlanStatus">
		<entryRelationship typeCode="REFR" inversionInd="false">
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="templateIds-planStatusObservation"/>
				
				<code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
				<statusCode code="completed"/>
				
				<!-- Status Detail -->
				<xsl:variable name="statusValue" select="translate(text(), $lowerCase, $upperCase)"/>
				<xsl:variable name="statusInformation">
					<Status xmlns="">
						<SDACodingStandard><xsl:value-of select="$snomedName"/></SDACodingStandard>
						<Code>
							<xsl:choose>
								<xsl:when test="$statusValue = 'A'">55561003</xsl:when>
								<xsl:when test="$statusValue = 'H'">421139008</xsl:when>
								<xsl:otherwise>73425007</xsl:otherwise>
							</xsl:choose>
						</Code>
						<Description>
							<xsl:choose>
								<xsl:when test="$statusValue = 'A'">Active</xsl:when>
								<xsl:when test="$statusValue = 'H'">On Hold</xsl:when>
								<xsl:otherwise>Inactive</xsl:otherwise>
							</xsl:choose>
						</Description>
					</Status>
				</xsl:variable>
				<xsl:variable name="status" select="exsl:node-set($statusInformation)/Status"/>
				
				<xsl:apply-templates select="$status" mode="snomed-Status"/>
			</observation>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="id-ExternalPlacerFiller">
		<!--
			This template is an alternative to the separate id-External,
			id-Placer and id-Filler templates.  This template exports
			only the <id> elements that are needed, instead of exporting
			possibly excess nullFlavor and/or uuid-valued ids.
		-->
		<xsl:variable name="hasExternal" select="string-length(EnteredAt/Code) and string-length(ExternalId)"/>
		<xsl:variable name="hasPlacer" select="(string-length(EnteringOrganization/Organization/Code) and string-length(PlacerId)) or (string-length(EnteredAt/Code) and string-length(PlacerId))"/>
		<xsl:variable name="hasFiller" select="(string-length(EnteringOrganization/Organization/Code) and string-length(FillerId)) or (string-length(EnteredAt/Code) and string-length(FillerId))"/>
		
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(ExternalId)">
				<id>
					<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
					<xsl:attribute name="extension"><xsl:value-of select="ExternalId/text()"/></xsl:attribute>
					<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-ExternalId')"/></xsl:attribute>
				</id>
			</xsl:when>
		</xsl:choose>
	
		<xsl:choose>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(PlacerId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-PlacerId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(PlacerId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-PlacerId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="not($hasExternal)">
				<id root="{isc:evaluate('createGUID')}" assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedPlacerId')}"/>
			</xsl:when>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(FillerId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-FillerId')"/></xsl:attribute>
			 	</id>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(FillerId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-FillerId')"/></xsl:attribute>
				</id>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="id-ApptExternalPlacerFiller">
		<!--
			This template is an alternative to the separate id-External,
			id-Placer and id-Filler templates.  This template exports
			only the <id> elements that are needed, instead of exporting
			possibly excess nullFlavor and/or uuid-valued ids.
		-->
		<xsl:variable name="hasExternal" select="string-length(EnteredAt/Code) and string-length(ExternalId)"/>
		<xsl:variable name="hasPlacer" select="(string-length(EnteringOrganization/Organization/Code) and string-length(PlacerApptId)) or (string-length(EnteredAt/Code) and string-length(PlacerApptId))"/>
		<xsl:variable name="hasFiller" select="(string-length(EnteringOrganization/Organization/Code) and string-length(FillerApptId)) or (string-length(EnteredAt/Code) and string-length(FillerApptId))"/>
		
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(ExternalId)">
				<id>
					<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
					<xsl:attribute name="extension"><xsl:value-of select="ExternalId/text()"/></xsl:attribute>
					<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-ExternalId')"/></xsl:attribute>
				</id>
			</xsl:when>
		</xsl:choose>
	
		<xsl:choose>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(PlacerApptId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerApptId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-PlacerApptId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(PlacerApptId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerApptId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-PlacerApptId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="not($hasExternal)">
				<id root="{isc:evaluate('createGUID')}" assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedPlacerApptId')}"/>
			</xsl:when>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="string-length(EnteringOrganization/Organization/Code) and string-length(FillerApptId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerApptId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-FillerApptId')"/></xsl:attribute>
			 	</id>
			</xsl:when>
			<xsl:when test="string-length(EnteredAt/Code) and string-length(FillerApptId)">
				<id>
			 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerApptId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-FillerApptId')"/></xsl:attribute>
				</id>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareActivityAct">
		<templateId root="{$ccda-PlanOfCareActivityAct}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareActivityEncounter">
		<templateId root="{$ccda-PlanOfCareActivityEncounter}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareActivityObservation">
		<templateId root="{$ccda-PlanOfCareActivityObservation}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareActivityProcedure">
		<templateId root="{$ccda-PlanOfCareActivityProcedure}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareActivitySubstanceAdministration">
		<templateId root="{$ccda-PlanOfCareActivitySubstanceAdministration}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareActivitySupply">
		<templateId root="{$ccda-PlanOfCareActivitySupply}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareInstruction">
		<templateId root="{$ccda-Instructions}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation"><templateId root="{$hl7-CCD-StatusObservation}"/></xsl:if>
	</xsl:template>	
</xsl:stylesheet>
