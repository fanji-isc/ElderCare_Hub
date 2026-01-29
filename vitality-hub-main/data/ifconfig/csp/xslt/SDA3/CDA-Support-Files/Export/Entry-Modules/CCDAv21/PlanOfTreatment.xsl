<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc xsi">
  <!-- AlsoInclude: AuthorParticipation.xsl Comment.xsl Encounter.xsl Goals.xsl Medication.xsl -->
	
	<xsl:template match="*" mode="ePOT-planOfTreatment-Narrative">
		<xsl:param name="disqualifyCodes"/><!-- These status codes disqualify an order from appearing in Plan of Care/Treatment. -->
		<xsl:param name="docs"/>

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
					<!-- For orders, look at the Status. For other items, look at whether the pertinent date is in the future (i.e. dateDiff is less than zero). -->
					<xsl:apply-templates select="RadOrders/RadOrder[not(Result) and not(contains($disqualifyCodes,concat('|',Status/text(),'|')))]" mode="ePOT-planOfTreatment-NarrativeDetail"/>
					<xsl:apply-templates select="LabOrders/LabOrder[not(Result) and not(contains($disqualifyCodes,concat('|',Status/text(),'|')))]" mode="ePOT-planOfTreatment-NarrativeDetail"/>
					<xsl:apply-templates select="OtherOrders/OtherOrder[not(Result) and not(contains($disqualifyCodes,concat('|',Status/text(),'|')))]" mode="ePOT-planOfTreatment-NarrativeDetail"/>
					<xsl:apply-templates select="Appointments/Appointment[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0]" mode="ePOT-planOfTreatment-NarrativeDetail"/>
					<xsl:apply-templates select="Referrals/Referral[not(string-length(ToTime/text())) or isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' ')) &lt; 0]" mode="ePOT-planOfTreatment-NarrativeDetail"/>
					<xsl:apply-templates select="Medications/Medication[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0 and not(contains($disqualifyCodes,concat('|',Status/text(),'|')))]" mode="ePOT-planOfTreatment-NarrativeDetail"/>
					<xsl:apply-templates select="Procedures/Procedure[((CustomPairs/NVPair/Name/text()='PlanOfCare') or (CustomPairs/NVPair/Name/text()='PlanOfTreatment')) 
						or (((Status/Code/text()='active') or not(string-length(Status/Code/text()))) 
							and ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)))]" mode="ePOT-planOfTreatment-NarrativeDetail"/>
					<xsl:apply-templates select="Documents/Document[DocumentType/Description/text()='PlanOfCareInstruction' or DocumentType/Code/text()='PlanOfCareInstruction']" mode="ePOT-planOfTreatment-NarrativeDetail"/>
					<xsl:apply-templates select="Goals/Goal" mode="ePOT-planOfTreatment-NarrativeDetail"/>					
				</tbody>
			</table>

			<!-- structured narrative documents -->
			<xsl:apply-templates mode="narrative-export-documents" select=".">
				<xsl:with-param name="docs" select="$docs"/>
				<xsl:with-param name="header" select="$exportConfiguration/narrative/section[templateId/@root=$ccda-PlanOfCareSection]/title/text()"/>
			</xsl:apply-templates>

		</text>
	</xsl:template>
	
	<xsl:template match="*" mode="ePOT-planOfTreatment-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix">
			<xsl:choose>
				<xsl:when test="local-name()='Document' and (DocumentType/Description/text()='PlanOfCareInstruction' or DocumentType/Code/text()='PlanOfCareInstruction')">
					<xsl:value-of select="concat('Instructions-',position())"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="concat(local-name(),'-', position())"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="activityType">
			<xsl:choose>
				<xsl:when test="local-name()='LabOrder' or local-name()='RadOrder' or local-name()='OtherOrder'">
					<xsl:apply-templates select="." mode="ePOT-formatOrderType-Narrative"/>
				</xsl:when>
				<xsl:when test="local-name()='Appointment'">Future Appointment</xsl:when>
				<xsl:when test="local-name()='Referral'">Referral</xsl:when>
				<xsl:when test="local-name()='Medication'">Medication</xsl:when>
				<xsl:when test="local-name()='Procedure'">Procedure</xsl:when>
				<xsl:when test="local-name()='Goal'">Goal</xsl:when>
				<xsl:when test="local-name()='Document' and (DocumentType/Description/text()='PlanOfCareInstruction' or Code/text()='PlanOfCareInstruction')">Instructions</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="activityTime">
			<xsl:choose>
				<xsl:when test="local-name()='LabOrder' or local-name()='RadOrder' or local-name()='OtherOrder'">
					<xsl:choose>
						<xsl:when test="string-length(SpecimenCollectedTime/text())">
							<xsl:apply-templates select="SpecimenCollectedTime" mode="fn-narrativeDateFromODBC"/>
						</xsl:when>
						<xsl:when test="string-length(FromTime/text())">
							<xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="local-name()='Appointment' or local-name()='Referral' or local-name()='Medication'">
					<xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/>
				</xsl:when>
				<xsl:when test="local-name()='Procedure'">
					<xsl:choose>
						<xsl:when test="string-length(ProcedureTime/text())">
							<xsl:apply-templates select="ProcedureTime" mode="fn-narrativeDateFromODBC"/>
						</xsl:when>
						<xsl:when test="string-length(FromTime/text())">
							<xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="local-name()='Goal'">
					<xsl:apply-templates select="ToTime" mode="fn-narrativeDateFromODBC"/>
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
						<xsl:apply-templates select="." mode="ePOT-NarrativeDetail-OrderDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='Appointment'">
						<xsl:apply-templates select="." mode="ePOT-NarrativeDetail-AppointmentDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='Referral'">
						<xsl:apply-templates select="." mode="ePOT-NarrativeDetail-ReferralDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='Procedure'">
						<xsl:apply-templates select="." mode="ePOT-NarrativeDetail-ProcedureDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='Goal'">
						<xsl:apply-templates select="." mode="ePOT-NarrativeDetail-GoalDetails"/>
					</xsl:when>
					<xsl:when test="local-name()='Document' and (DocumentType/Description/text()='PlanOfCareInstruction' or DocumentType/Code/text()='PlanOfCareInstruction')">
						<xsl:apply-templates select="." mode="ePOT-NarrativeDetail-InstructionsDetails"/>
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
	
	<xsl:template match="LabOrder | RadOrder | OtherOrder" mode="ePOT-formatOrderType-Narrative">
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
	
	<xsl:template match="LabOrder | RadOrder | OtherOrder | Medication" mode="ePOT-NarrativeDetail-OrderDetails">
		<xsl:variable name="testCode"><xsl:apply-templates select="OrderItem" mode="fn-codeOrDescription"/></xsl:variable>
		<xsl:variable name="testDesc"><xsl:apply-templates select="OrderItem" mode="fn-originalTextOrDescriptionOrCode"/></xsl:variable>
		
		<xsl:value-of select="concat($testDesc,' [code = ',$testCode,']')"/>
	</xsl:template>
	
	<xsl:template match="Appointment" mode="ePOT-NarrativeDetail-AppointmentDetails">
		<!-- Name can be for a person, or if person not provided, then organization. -->
		<xsl:variable name="appointmentName">
			<xsl:choose>
				<xsl:when test="CareProvider">
					<xsl:apply-templates select="CareProvider" mode="ePOT-careProviderName"/>
				</xsl:when>
				<xsl:when test="Location">
					<xsl:apply-templates select="Location/Organization" mode="fn-descriptionOrCode"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Address can be for a person, or if person not provided, then organization. -->
		<xsl:variable name="appointmentAddress">
			<xsl:choose>
				<xsl:when test="CareProvider/Address">
					<xsl:apply-templates select="CareProvider/Address" mode="fn-addressSingleLine"/>
				</xsl:when>
				<xsl:when test="Location/Organization/Address">
					<xsl:apply-templates select="Location/Organization/Address" mode="fn-addressSingleLine"/>
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
	
	<xsl:template match="Referral" mode="ePOT-NarrativeDetail-ReferralDetails">
		<!-- Name can be for a person, or if person not provided, then organization. -->
		<xsl:variable name="referralName">
			<xsl:choose>
				<xsl:when test="ReferredToProvider">
					<xsl:apply-templates select="ReferredToProvider" mode="ePOT-careProviderName"/>
				</xsl:when>
				<xsl:when test="ReferredToOrganization">
					<xsl:apply-templates select="ReferredToOrganization/Organization" mode="fn-descriptionOrCode"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Address can be for a person, or if person not provided, then organization. -->
		<xsl:variable name="referralAddress">
			<xsl:choose>
				<xsl:when test="ReferredToProvider/Address">
					<xsl:apply-templates select="ReferredToProvider/Address" mode="fn-addressSingleLine"/>
				</xsl:when>
				<xsl:when test="ReferredToOrganization/Organization/Address">
					<xsl:apply-templates select="ReferredToOrganization/Organization/Address" mode="fn-addressSingleLine"/>
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
	
	<xsl:template match="CareProvider | ReferredToProvider" mode="ePOT-careProviderName">
		<!-- Format the name into prefix, first, last, suffix. For display in narrative. -->
		<xsl:variable name="normalizedDescription" select="normalize-space(Description/text())"/>
		<xsl:variable name="hasDesc" select="boolean(string-length($normalizedDescription))"/>

		<xsl:if test="$hasDesc or Name">
			<xsl:variable name="contactFirstName">
				<xsl:choose>
					<xsl:when test="string-length(Name/GivenName/text())">
						<xsl:value-of select="Name/GivenName/text()"/>
					</xsl:when>
					<xsl:when test="$hasDesc and contains($normalizedDescription, ',')">
						<xsl:value-of select="normalize-space(substring-after($normalizedDescription, ','))"/>
					</xsl:when>
					<xsl:when test="$hasDesc">
						<xsl:value-of select="normalize-space(substring-before($normalizedDescription, ' '))"/>
						<!-- This will also work correctly for strings like "Dr. Smith" when all is done. -->
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="contactLastName">
				<xsl:choose>
					<xsl:when test="string-length(Name/FamilyName/text())">
						<xsl:value-of select="Name/FamilyName/text()"/>
					</xsl:when>
					<xsl:when test="$hasDesc and contains($normalizedDescription, ',')">
						<xsl:value-of select="normalize-space(substring-before($normalizedDescription, ','))"/>
					</xsl:when>
					<xsl:when test="$hasDesc and contains($normalizedDescription, ' ')">
						<xsl:value-of select="normalize-space(substring-after($normalizedDescription, ' '))"/>
					</xsl:when>
					<xsl:when test="$hasDesc">
						<xsl:value-of select="$normalizedDescription"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:value-of select="normalize-space(concat(Name/NamePrefix/text(), ' ', $contactFirstName, ' ',
				$contactLastName, ' ', Name/ProfessionalSuffix/text()))"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Procedure" mode="ePOT-NarrativeDetail-ProcedureDetails">
		<xsl:apply-templates select="Procedure" mode="fn-descriptionOrCode"/>
	</xsl:template>
	
	<xsl:template match="Goal" mode="ePOT-NarrativeDetail-GoalDetails">
		<xsl:value-of select="Description/text()"/>
	</xsl:template>

	<xsl:template match="Document" mode="ePOT-NarrativeDetail-InstructionsDetails">
		<xsl:if test="DocumentType/Description/text()='PlanOfCareInstruction' or DocumentType/Code/text()='PlanOfCareInstruction'">
			<xsl:value-of select="NoteText/text()"/>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template match="*" mode="ePOT-planOfTreatment-NoData">
		<text><xsl:value-of select="$exportConfiguration/planOfCare/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="ePOT-planOfTreatment-Entries">
		<xsl:param name="disqualifyCodes"/><!-- These status codes disqualify an order from appearing in Plan of Care/Treatment. -->
		
		<xsl:apply-templates select="RadOrders/RadOrder[not(Result) and not(contains($disqualifyCodes,concat('|',Status/text(),'|')))]" mode="ePOT-EntryDetail-Order"/>
		<xsl:apply-templates select="LabOrders/LabOrder[not(Result) and not(contains($disqualifyCodes,concat('|',Status/text(),'|')))]" mode="ePOT-EntryDetail-Order"/>
		<xsl:apply-templates select="OtherOrders/OtherOrder[not(Result) and not(contains($disqualifyCodes,concat('|',Status/text(),'|')))]" mode="ePOT-EntryDetail-Order"/>
		<xsl:apply-templates select="Appointments/Appointment[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0]" mode="ePOT-EntryDetail-Appointment"/>
		<xsl:apply-templates select="Referrals/Referral[not(string-length(ToTime/text())) or isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' ')) &lt; 0]" mode="ePOT-EntryDetail-Referral"/>
		<xsl:apply-templates select="Medications/Medication[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0 and not(contains($disqualifyCodes,concat('|',Status/text(),'|')))]" mode="ePOT-EntryDetail-Medication"/>
		<xsl:apply-templates select="Procedures/Procedure[((CustomPairs/NVPair/Name/text()='PlanOfCare') or (CustomPairs/NVPair/Name/text()='PlanOfTreatment')) 
			or (((Status/Code/text()='active') or not(string-length(Status/Code/text()))) 
				and ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)))]" mode="ePOT-EntryDetail-Procedure"/>
		<xsl:apply-templates select="Goals/Goal" mode="ePOT-EntryDetail-Goal"/>		
		<xsl:apply-templates select="Documents/Document[DocumentType/Description/text()='PlanOfCareInstruction' or DocumentType/Code/text()='PlanOfCareInstruction']" mode="ePOT-EntryDetail-Instructions"/>
	</xsl:template>
	
	<xsl:template match="LabOrder | RadOrder | OtherOrder" mode="ePOT-EntryDetail-Order">		
		<xsl:variable name="planOfTreatmentOrderType"><xsl:apply-templates select="." mode="ePOT-formatOrderType-Narrative"/></xsl:variable>
		
		<entry typeCode="DRIV">
			<observation classCode="OBS">
				<xsl:attribute name="moodCode">
					<xsl:choose>
						<xsl:when test="$planOfTreatmentOrderType='Diagnostic Test Pending'">INT</xsl:when>
						<xsl:otherwise>RQO</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:call-template name="ePOT-templateIds-planOfCareActivityObservation"/>
				
			  <!--
					Field : Plan of Treatment Order Placer/Filler Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/id
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: HS.SDA3.AbstractOrder FillerId
					Source: /Container/LabOrders/LabOrder/PlacerId
					Source: /Container/RadOrders/RadOrder/PlacerId
					Source: /Container/OtherOrders/OtherOrder/PlacerId
					Source: /Container/LabOrders/LabOrder/FillerId
					Source: /Container/RadOrders/RadOrder/FillerId
					Source: /Container/OtherOrders/OtherOrder/FillerId
					Note  : SDA PlacerId or FillerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA PlacerId/FillerId have a value
							- Both SDA EnteredAt/Code and SDA PlacerId/FillerId have a value
			  -->
			  <xsl:apply-templates select="." mode="ePOT-id-ExternalPlacerFiller"/>
				
			  <!--
					Field : Plan of Treatment Order Item coded
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/code
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/LabOrders/LabOrder/OrderItem
					Source: /Container/RadOrders/RadOrder/OrderItem
					Source: /Container/OtherOrders/OtherOrder/OrderItem
						StructuredMappingRef: generic-Coded
			  -->
			  <xsl:apply-templates select="OrderItem" mode="fn-generic-Coded"/>
				<statusCode code="active"/>
				
			  <!--
				    Field : Plan of Treatment Order Time
				    Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/effectiveTime/@value
				    Source: HS.SDA3.AbstractOrder EnteredOn
				    Source: /Container/LabOrders/LabOrder/EnteredOn
				    Source: /Container/RadOrders/RadOrder/EnteredOn
				    Source: /Container/OtherOrders/OtherOrder/EnteredOn
		      -->
			  <xsl:apply-templates select="." mode="fn-effectiveTime"/>
				
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
			  
			  <!--
					Field : Plan of Treatment Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.AbstractOrder Comments
				    Source: /Container/LabOrders/LabOrder/Comments
				    Source: /Container/RadOrders/RadOrder/Comments
				    Source: /Container/OtherOrders/OtherOrder/Comments
			   -->
			  <xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareComments/text(),local-name(),'-',position())"/>
				</xsl:apply-templates>
				
			  <!-- Link this treatment plan to encounter noted in encounters section -->
			  <!--
					Field : Plan of Treatment Order Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/entryRelationship/encounter/id/@extension
					Source: HS.SDA3.AbstractOrder EncounterNumber
				    Source: /Container/LabOrders/LabOrder/EncounterNumber
				    Source: /Container/RadOrders/RadOrder/EncounterNumber
				    Source: /Container/OtherOrders/OtherOrder/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : This links the order to an encounter in the Encounters section.
				-->
			  <xsl:apply-templates select="." mode="fn-encounterLink-entryRelationship"/>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="Medication" mode="ePOT-EntryDetail-Medication">
		
		<entry typeCode="DRIV">
			<substanceAdministration classCode="SBADM" moodCode="RQO">
				<xsl:call-template name="ePOT-templateIds-planOfCareActivitySubstanceAdministration"/>
				
			    <!--
					Field : Plan of Treatment Medication Placer/Filler Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/substanceAdministration/id
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: HS.SDA3.AbstractOrder FillerId
					Source: /Container/Medications/Medication/PlacerId
					Source: /Container/Medications/Medication/FillerId
					Note  : SDA PlacerId or FillerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA PlacerId/FillerId have a value
							- Both SDA EnteredAt/Code and SDA PlacerId/FillerId have a value
			    -->
			    <xsl:apply-templates select="." mode="ePOT-id-ExternalPlacerFiller"/>
				
				<code nullFlavor="NA"/>
				<statusCode code="active"/>
				
				<xsl:apply-templates select="." mode="eM-medication-duration"/>
				<xsl:apply-templates select="Frequency" mode="eM-medication-frequency"/>

			    <!--
				  Field : Plan of Treatment Medication Route
				  Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/substanceAdministration/routeCode
				  Source: HS.SDA3.AbstractMedication Route
				  Source: /Container/Medications/Medication/Route
				  StructuredMappingRef: generic-Coded
			    -->
			    <xsl:apply-templates select="Route" mode="fn-code-route"/>
				<xsl:apply-templates select="." mode="eM-medication-doseQuantity"/>
				<xsl:apply-templates select="." mode="eM-medication-rateAmount"/>
				<xsl:apply-templates select="OrderItem" mode="eM-medication-consumable">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(),local-name(),'-',position())"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/> 
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<!-- Link this treatment plan to encounter noted in encounters section -->
			    <!--
					Field : Plan of Treatment Medication Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/substanceAdministration/entryRelationship/encounter/id/@extension
					Source: HS.SDA3.AbstractMedication EncounterNumber
			    	Source: /Container/Medications/Medication/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : This links the order to an encounter in the Encounters section.
				-->
			  <xsl:apply-templates select="." mode="fn-encounterLink-entryRelationship"/>
			</substanceAdministration>
		</entry>
	</xsl:template>
	
	<xsl:template match="Appointment" mode="ePOT-EntryDetail-Appointment">
		<entry typeCode="DRIV">
			<encounter classCode="ENC" moodCode="INT">
				<xsl:call-template name="ePOT-templateIds-planOfCareActivityEncounter"/>
				
			  <!--
				Field : Plan of Treatment Order Placer/Filler Appointment Id
				Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/encounter/id
				Source: HS.SDA3.Appointment PlacerApptId
				Source: HS.SDA3.Appointment FillerApptId
				Source: /Container/Appointments/Appointment/PlacerApptId
				Source: /Container/Appointments/Appointment/FillerApptId
				Note  : SDA PlacerApptId or FillerApptId is exported to CDA id if one of these conditions is met:
						- Both SDA EnteringOrganization/Organization/Code and SDA PlacerApptId/FillerApptId have a value
						- Both SDA EnteredAt/Code and SDA PlacerApptId/FillerApptId have a value
			  -->
			  <xsl:apply-templates select="." mode="ePOT-id-ApptExternalPlacerFiller"/>
				
			  <!--
					Field : Plan of Treatment Appointment Type coded
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/encounter/code
					Source: HS.SDA3.Appointment Type
				  Source: /Container/Appointments/Appointment/Type
					StructuredMappingRef: generic-Coded
			  -->
			  <xsl:apply-templates select="Type" mode="fn-generic-Coded"></xsl:apply-templates>
				
				<statusCode code="active"/>
				
			    <!--
				    Field : Plan of Treatment Appointment fromTime
				    Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/encounter/effectiveTime/low/@value
				    Source: HS.SDA3.Appointment FromTime
				    Source: /Container/Appointments/Appointment/FromTime
				-->
			    <!--
				    Field : Plan of Treatment Appointment toTime
				    Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/encounter/effectiveTime/high/@value
				    Source: HS.SDA3.Appointment ToTime
				    Source: /Container/Appointments/Appointment/ToTime
		        -->
			  <xsl:apply-templates select="." mode="fn-effectiveTime"/>
				
				<!-- Appointment Care Provider -->
				<xsl:apply-templates select="CareProvider" mode="fn-performer"/>
				
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<!-- Appointment location -->
				<!-- The encounter-location template is located in Export/Entry-Modules/CCDA/Encounter.xsl -->
				<xsl:apply-templates select="Location" mode="eE-encounter-location"/>
			</encounter>
		</entry>
	</xsl:template>
	
	<xsl:template match="Referral" mode="ePOT-EntryDetail-Referral">
		<entry typeCode="DRIV">
			<encounter classCode="ENC" moodCode="RQO">
				<xsl:call-template name="ePOT-templateIds-planOfCareActivityEncounter"/>
				
				<!--
					Field : Plan of Treatment Order Placer/Filler Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/encounter/id
					Source: HS.SDA3.Referral PlacerId
					Source: HS.SDA3.Referral FillerId
					Source: /Container/Referrals/Referral/PlacerId
					Source: /Container/Referrals/Referral/FillerId
					Note  : SDA PlacerId or FillerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA PlacerId/FillerId have a value
							- Both SDA EnteredAt/Code and SDA PlacerId/FillerId have a value
			    -->
			    <xsl:apply-templates select="." mode="ePOT-id-ExternalPlacerFiller"/>
				
			    <!--
					Field : Plan of Treatment Referral Reason	
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/encounter/code/originalText
					Source: HS.SDA3.Referral ReferralReason
				  	Source: /Container/Referrals/Referral/ReferralReason
				-->
			  	<code nullFlavor="UNK">
					<originalText><xsl:value-of select="ReferralReason/text()"/></originalText>
				</code>
				
				<statusCode code="active"/>
				
			  	<!--
					Field : Plan of Treatment Referral Start Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/encounter/effectiveTime/low/@value
					Source: HS.SDA3.Encounter FromTime
					Source: /Container/Referrals/Referral/FromTime
				-->
			  	<!--
					Field : Plan of Treatment Referral End Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/encounter/effectiveTime/high/@value
					Source: HS.SDA3.Encounter ToTime
					Source: /Container/Referrals/Referral/ToTime
				-->
			  	<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>
				
				<!-- Referee Care Provider -->
				<xsl:apply-templates select="ReferredToProvider" mode="fn-performer"/>
				
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<!-- Referee location -->
				<!-- The encounter-location template is located in Export/Entry-Modules/CCDA/Encounter.xsl -->
				<xsl:apply-templates select="ReferredToOrganization" mode="eE-encounter-location"/>
			</encounter>
		</entry>
	</xsl:template>
	
	<xsl:template match="Procedure" mode="ePOT-EntryDetail-Procedure">
		<entry typeCode="DRIV">
			<procedure classCode="PROC" moodCode="RQO">
				<xsl:call-template name="ePOT-templateIds-planOfCareActivityProcedure"/>
				
			  <!--
					Field : Plan of Treatment Order Placer/Filler Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/procedure/id
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: HS.SDA3.AbstractOrder FillerId
					Source: /Container/Procedures/Procedure/PlacerId
					Source: /Container/Procedures/Procedure/FillerId
					Note  : SDA PlacerId or FillerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA PlacerId/FillerId have a value
							- Both SDA EnteredAt/Code and SDA PlacerId/FillerId have a value
			  -->
			  <xsl:apply-templates select="." mode="ePOT-id-ExternalPlacerFiller"/>
				
			  <!--
					Field : Plan of Treatment Procedure coded
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/procedure/code
					Source: HS.SDA3.Procedure Procedure
				  	Source: /Container/Procedures/Procedure
					StructuredMappingRef: generic-Coded
			   -->
			  <xsl:apply-templates select="Procedure" mode="fn-generic-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(),'Procedure-',position())"/>
			  </xsl:apply-templates>
				
		      <statusCode code="active"/>
				
			  <!--
					Field : Procedure Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/procedure/effectiveTime/@value
					Source: HS.SDA3.Procedure ProcedureTime
					Source: /Container/Procedures/Procedure/ProcedureTime
			  -->
			  <xsl:choose>
					<xsl:when test="string-length(ProcedureTime)"><xsl:apply-templates select="ProcedureTime" mode="fn-effectiveTime-singleton"/></xsl:when>
					<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
			  </xsl:choose>
				
			  <xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
			  <xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
			</procedure>
		</entry>
	</xsl:template>
	
	<xsl:template match="Goal" mode="ePOT-EntryDetail-Goal">
		<xsl:variable name="narrativeLinkSuffix" select="concat('Goal-',position())"/>	
		
		<!-- Goal Observation Entry-->
		<entry>
			<observation classCode="OBS" moodCode="GOL">
			  <xsl:call-template name="eG-templateIds-goalObservation"/>
        		
        		<!--
					Field : Goal Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/id
					Source: HS.SDA3.Goal ExternalId
					Source: /Container/Goals/Goal/ExternalId
					StructuredMappingRef: id-External
				-->
        		<xsl:apply-templates select="." mode="fn-id-External" />

        		<!--
					Field : Goal Target Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/code
					Source: HS.SDA3.Observation ObservationCode
					Source: /Container/Goals/Goal/Target/ObservationCode
					StructuredMappingRef: generic-Coded
				-->
				<xsl:choose>
	        		<xsl:when test="Target/ObservationCode">
		        		<xsl:apply-templates select="Target/ObservationCode" mode="fn-generic-Coded" />
		        	</xsl:when>
		        	<xsl:otherwise>
		        		<code nullFlavor="NI"/>
		        	</xsl:otherwise>
		        </xsl:choose>        

		        <!--
					Field : Goal Description
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/text
					Source: HS.SDA3.Goal Description
					Source: /Container/Goals/Goal/Description
				-->
				<text><reference value="{concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)}"/></text>

				<statusCode code="active"/>

				<!--
					Field : Goal Effective Date - Start
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/effectiveTime/low/@value
					Source: HS.SDA3.Goal FromTime
					Source: /Container/Goals/Goal/FromTime
				-->
				<!--
					Field : Goal Effective Date - End
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/effectiveTime/high/@value
					Source: HS.SDA3.Goal ToTime
					Source: /Container/Goals/Goal/ToTime
				-->
				<xsl:if test="string-length(FromTime/text()) or string-length(ToTime/text())">
					<xsl:apply-templates select="." mode="fn-effectiveTime"/>
				</xsl:if>

				<!-- 
					Field: Goal Authors
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation[templateId/@root='2.16.840.1.113883.10.20.22.4.121']/author
					Source: Goals/Goal/Authors/DocumentProvider/Provider
					StructuredMappingRef: eAP-author-Human
				-->
				<xsl:apply-templates select="Authors/DocumentProvider/Provider" mode="eAP-author-Human"/>		

			</observation>
		</entry>		
	</xsl:template>
	
	<xsl:template match="Document" mode="ePOT-EntryDetail-Instructions">
		<xsl:variable name="narrativeLinkSuffix" select="concat('Instructions-',position())"/>	
		
		<entry typeCode="DRIV">
			<act classCode="ACT" moodCode="INT">
				<xsl:call-template name="ePOT-templateIds-planOfCareInstruction"/>
				
			    <!--
					Field : Plan of Treatment Instructions Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/act/id
					Source: HS.SDA3.CustomObject ExternalId
					Source: /Container/Documents/Document[DocumentType/Description='PlanOfCareInstruction']/ExternalId
					Source: /Container/Documents/Document[DocumentType/Code='PlanOfCareInstruction']/ExternalId
					StructuredMappingRef: id-External
				-->
			    <xsl:apply-templates select="." mode="fn-id-External"/>
				
				<!--
					Field : Plan of Treatment Instructions
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/act/code
					Source: HS.SDA3.Document CustomPairs
					Source: /Container/Documents/Document[DocumentType/Description='PlanOfCareInstruction']/OriginalText
					Source: /Container/Documents/Document[DocumentType/Code='PlanOfCareInstruction']/OriginalText
					StructuredMappingRef: generic-Coded
			    -->
			    <xsl:apply-templates select="." mode="fn-generic-Coded" />
				
				<text><reference value="{concat('#', $exportConfiguration/planOfCare/narrativeLinkPrefixes/planOfCareDescription/text(), $narrativeLinkSuffix)}"/></text>
				<statusCode code="completed"/>
				
				<!--
						Field : Instructions Date - Start
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/act/effectiveTime/low/@value
						Source: HS.SDA3.CustomObject FromTime
						Source: /Container/Documents/Document[DocumentType/Description='PlanOfCareInstruction']/FromTime
						Source: /Container/Documents/Document[DocumentType/Code='PlanOfCareInstruction']/FromTime
				-->
				<!--
						Field : Instructions Date - End
						Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/act/effectiveTime/high/@value
						Source: HS.SDA3.CustomObject ToTime
						Source: /Container/Documents/Document[DocumentType/Description='PlanOfCareInstruction']/ToTime
						Source: /Container/Documents/Document[DocumentType/Code='PlanOfCareInstruction']/ToTime
				-->
			    <xsl:if test="string-length(FromTime/text()) or string-length(ToTime/text())">
					<xsl:apply-templates select="." mode="fn-effectiveTime"/>
				</xsl:if>
				
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
			</act>
		</entry>
	</xsl:template>
		
	<xsl:template match="*" mode="ePOT-id-ExternalPlacerFiller">
		<!-- match can be LabOrder, RadOrder, OtherOrder, Medication, Referral, Procedure -->
		<!--
			This template is an alternative to the separate id-External,
			id-Placer and id-Filler templates.  This template exports
			only the <id> elements that are needed, instead of exporting
			possibly excess nullFlavor and/or uuid-valued ids.
		-->
		<xsl:variable name="hasEnteredAt" select="boolean(EnteredAt/Code/text())"/>
		<xsl:variable name="hasEnteringOrg" select="boolean(EnteringOrganization/Organization/Code/text())"/>
		<xsl:variable name="hasExternal" select="$hasEnteredAt and boolean(ExternalId/text())"/>
		<xsl:variable name="hasPlacerId" select="boolean(PlacerId/text())"/>
		<xsl:variable name="hasFillerId" select="boolean(FillerId/text())"/>
		<xsl:variable name="enteredAtOID">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
				<xsl:with-param name="Code" select="EnteredAt/Code/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="enteringOrgOID">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
				<xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:if test="$hasExternal">
			<id>
				<xsl:attribute name="root"><xsl:value-of select="$enteredAtOID"/></xsl:attribute>
				<xsl:attribute name="extension"><xsl:value-of select="ExternalId/text()"/></xsl:attribute>
				<xsl:attribute name="assigningAuthorityName">
					<xsl:value-of select="concat(EnteredAt/Code/text(), '-ExternalId')"/>
				</xsl:attribute>
			</id>
		</xsl:if>
	
		<xsl:choose>
			<xsl:when test="$hasEnteringOrg and $hasPlacerId">
				<id>
					<xsl:attribute name="root"><xsl:value-of select="$enteringOrgOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-PlacerId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="$hasEnteredAt and $hasPlacerId">
				<id>
					<xsl:attribute name="root"><xsl:value-of select="$enteredAtOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-PlacerId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="not($hasExternal)">
				<id root="{isc:evaluate('createGUID')}" assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedPlacerId')}"/>
			</xsl:when>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="$hasEnteringOrg and $hasFillerId">
				<id>
					<xsl:attribute name="root"><xsl:value-of select="$enteringOrgOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-FillerId')"/></xsl:attribute>
			 	</id>
			</xsl:when>
			<xsl:when test="$hasEnteredAt and $hasFillerId">
				<id>
					<xsl:attribute name="root"><xsl:value-of select="$enteredAtOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-FillerId')"/></xsl:attribute>
				</id>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Appointment" mode="ePOT-id-ApptExternalPlacerFiller">
		<!--
			This template is an alternative to the separate id-External,
			id-Placer and id-Filler templates.  This template exports
			only the <id> elements that are needed, instead of exporting
			possibly excess nullFlavor and/or uuid-valued ids.
			The Appointment version uses PlacerApptId and FillerApptId
			instead of PlacerId and FillerId.
		-->
		<xsl:variable name="hasEnteredAt" select="boolean(EnteredAt/Code/text())"/>
		<xsl:variable name="hasEnteringOrg" select="boolean(EnteringOrganization/Organization/Code/text())"/>
		<xsl:variable name="hasExternal" select="$hasEnteredAt and boolean(ExternalId/text())"/>
		<xsl:variable name="hasPlacerId" select="boolean(PlacerApptId/text())"/>
		<xsl:variable name="hasFillerId" select="boolean(FillerApptId/text())"/>
		<xsl:variable name="enteredAtOID">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
				<xsl:with-param name="Code" select="EnteredAt/Code/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="enteringOrgOID">
			<xsl:apply-templates select="." mode="fn-oid-for-code">
				<xsl:with-param name="Code" select="EnteringOrganization/Organization/Code/text()"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:if test="$hasExternal">
			<id>
				<xsl:attribute name="root"><xsl:value-of select="$enteredAtOID"/></xsl:attribute>
				<xsl:attribute name="extension"><xsl:value-of select="ExternalId/text()"/></xsl:attribute>
				<xsl:attribute name="assigningAuthorityName">
					<xsl:value-of select="concat(EnteredAt/Code/text(), '-ExternalId')"/>
				</xsl:attribute>
			</id>
		</xsl:if>
	
		<xsl:choose>
			<xsl:when test="$hasEnteringOrg and $hasPlacerId">
				<id>
					<xsl:attribute name="root"><xsl:value-of select="$enteringOrgOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerApptId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-PlacerApptId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="$hasEnteredAt and $hasPlacerId">
				<id>
					<xsl:attribute name="root"><xsl:value-of select="$enteredAtOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="PlacerApptId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-PlacerApptId')"/></xsl:attribute>
				</id>
			</xsl:when>
			<xsl:when test="not($hasExternal)">
				<id root="{isc:evaluate('createGUID')}" assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedPlacerApptId')}"/>
			</xsl:when>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="$hasEnteringOrg and $hasFillerId">
				<id>
					<xsl:attribute name="root"><xsl:value-of select="$enteringOrgOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerApptId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteringOrganization/Organization/Code/text(), '-FillerApptId')"/></xsl:attribute>
			 	</id>
			</xsl:when>
			<xsl:when test="$hasEnteredAt and $hasFillerId">
				<id>
					<xsl:attribute name="root"><xsl:value-of select="$enteredAtOID"/></xsl:attribute>
			 		<xsl:attribute name="extension"><xsl:value-of select="FillerApptId/text()"/></xsl:attribute>
			 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-FillerApptId')"/></xsl:attribute>
				</id>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="ePOT-templateIds-planOfCareActivityAct">
		<templateId root="{$ccda-PlanOfCareActivityAct}"/>
		<templateId root="{$ccda-PlanOfCareActivityAct}" extension="2014-06-09"/>
	</xsl:template>

	<xsl:template name="ePOT-templateIds-planOfCareActivityEncounter">
		<templateId root="{$ccda-PlanOfCareActivityEncounter}"/>
		<templateId root="{$ccda-PlanOfCareActivityEncounter}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="ePOT-templateIds-planOfCareActivityObservation">
		<templateId root="{$ccda-PlanOfCareActivityObservation}"/>
		<templateId root="{$ccda-PlanOfCareActivityObservation}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="ePOT-templateIds-planOfCareActivityProcedure">
		<templateId root="{$ccda-PlanOfCareActivityProcedure}"/>
		<templateId root="{$ccda-PlanOfCareActivityProcedure}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="ePOT-templateIds-planOfCareActivitySubstanceAdministration">
		<templateId root="{$ccda-PlanOfCareActivitySubstanceAdministration}"/>
		<templateId root="{$ccda-PlanOfCareActivitySubstanceAdministration}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="ePOT-templateIds-planOfCareActivitySupply">
		<templateId root="{$ccda-PlanOfCareActivitySupply}"/>
		<templateId root="{$ccda-PlanOfCareActivitySupply}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="ePOT-templateIds-planOfCareInstruction">
		<templateId root="{$ccda-Instructions}"/>
		<templateId root="{$ccda-Instructions}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="ePOT-templateIds-planStatusObservation">
		<xsl:if test="$hl7-CCD-StatusObservation">
			<templateId root="{$hl7-CCD-StatusObservation}"/>
			<templateId root="{$hl7-CCD-StatusObservation}" extension="2015-08-01"/>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>