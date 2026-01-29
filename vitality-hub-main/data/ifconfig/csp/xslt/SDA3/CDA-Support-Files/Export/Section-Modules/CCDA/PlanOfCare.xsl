<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="planOfCare">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- These status codes disqualify an order from appearing in Plan of Care. -->
		<xsl:variable name="notPlanOfCareStatus">|C|D|E|I|R|</xsl:variable>
		
		<xsl:variable name="hasDataLabOrders" select="LabOrders/LabOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]"/>
		<xsl:variable name="hasDataRadOrders" select="RadOrders/RadOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]"/>
		<xsl:variable name="hasDataOtherOrders" select="OtherOrders/OtherOrder[not(Result) and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]"/>
		<xsl:variable name="hasDataAppointments" select="Appointments/Appointment[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0]"/>
		<xsl:variable name="hasDataReferrals" select="Referrals/Referral[not(string-length(ToTime/text())) or isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' ')) &lt; 0]"/>
		<xsl:variable name="hasDataMedications" select="Medications/Medication[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt;= 0 and not(contains($notPlanOfCareStatus,concat('|',Status/text(),'|')))]"/>
		<!-- for each Procedure, export if it: (came from PlanOfCare) OR ((has an effective date in the future) AND (has active status)) -->
		<!-- when computing effective date, check its ProcedureTime if available, else check its FromTime. -->
		<xsl:variable name="hasDataProcedures" select="count(Procedures/Procedure[((CustomPairs/NVPair/Name/text()='PlanOfCare') or (CustomPairs/NVPair/Name/text()='PlanOfTreatment')) 
			or (((Status/Code/text()='active') or not(string-length(Status/Code/text()))) 
				and ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)))])"/>
		<xsl:variable name="hasDataGoals" select="CustomObjects/CustomObject[CustomType/text()='PlanOfCareGoal']"/>
		<xsl:variable name="hasDataInstructions" select="CustomObjects/CustomObject[CustomType/text()='PlanOfCareInstructions']"/>
		
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/planOfCare/emptySection/exportData/text()"/>
		<xsl:variable name="hasData" select="$hasDataLabOrders or $hasDataRadOrders or $hasDataOtherOrders or $hasDataAppointments or $hasDataReferrals or $hasDataMedications or $hasDataProcedures or $hasDataGoals or $hasDataInstructions"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-planOfCareSection"/>
					
					<code code="18776-5" displayName="Treatment Plan" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Plan of Care</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="planOfCare-Narrative"/>
							<xsl:apply-templates select="." mode="planOfCare-Entries"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="planOfCare-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-planOfCareSection">
		<templateId root="{$ccda-PlanOfCareSection}"/>
	</xsl:template>
</xsl:stylesheet>
