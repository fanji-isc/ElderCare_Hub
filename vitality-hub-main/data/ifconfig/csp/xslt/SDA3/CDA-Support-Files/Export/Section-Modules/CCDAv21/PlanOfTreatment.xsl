<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc">
	<!-- Three extra entry modules used. AlsoInclude: Comment.xsl Encounter.xsl Medication.xsl PlanOfTreatment.xsl -->

	<xsl:template match="*" mode="sPOT-planOfTreatment">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<!-- These status codes disqualify an order from appearing in Plan of Care/Treatment. -->
		<xsl:variable name="notPlanOfTreatmentStatus">|C|D|E|I|R|</xsl:variable>

		<xsl:variable name="hasPlanofTreatmentData">
			<xsl:apply-templates select="." mode="sPOT-planOfTreatment-hasData"/>
		</xsl:variable>

		<!-- imported section narratives -->
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-PlanOfCareSection]/code/@code)]"/>
		<xsl:variable name="hasDocs" select="count($docs)"/>

		<xsl:if test="($hasDocs > 0) or ($hasPlanofTreatmentData='true') or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="($hasDocs = 0) and ($hasPlanofTreatmentData='false')"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sPOT-templateIds-planOfTreatmentSection"/>
					
					<code code="18776-5" displayName="Treatment Plan" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Plan of Treatment</title>
					
					<xsl:choose>
						<xsl:when test="$hasPlanofTreatmentData='true'">
							<xsl:apply-templates select="." mode="ePOT-planOfTreatment-Narrative">
								<xsl:with-param name="disqualifyCodes" select="$notPlanOfTreatmentStatus"/>
								<xsl:with-param name="docs" select="$docs"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="ePOT-planOfTreatment-Entries">
								<xsl:with-param name="disqualifyCodes" select="$notPlanOfTreatmentStatus"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$hasDocs > 0">
							<text>
								<xsl:apply-templates mode="narrative-export-documents" select=".">
									<xsl:with-param name="docs" select="$docs"/>
								</xsl:apply-templates>
							</text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="ePOT-planOfTreatment-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="sPOT-planOfTreatment-hasData">

		<!-- For orders, look at the Status. For other items, look at whether the pertinent date is in the future (i.e. dateDiff is less than zero). -->
		<xsl:variable name="hasDataLabOrders" select="count(LabOrders/LabOrder[not(Result) and not(contains($notPlanOfTreatmentStatus,concat('|',Status/text(),'|')))])"/>
		<xsl:variable name="hasDataRadOrders" select="count(RadOrders/RadOrder[not(Result) and not(contains($notPlanOfTreatmentStatus,concat('|',Status/text(),'|')))])"/>
		<xsl:variable name="hasDataOtherOrders" select="count(OtherOrders/OtherOrder[not(Result) and not(contains($notPlanOfTreatmentStatus,concat('|',Status/text(),'|')))])"/>
		<xsl:variable name="hasDataAppointments" select="count(Appointments/Appointment[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0])"/>
		<xsl:variable name="hasDataReferrals" select="count(Referrals/Referral[not(string-length(ToTime/text())) or isc:evaluate('dateDiff', 'dd', translate(ToTime/text(), 'TZ', ' ')) &lt; 0])"/>
		<xsl:variable name="hasDataMedications" select="count(Medications/Medication[isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt;= 0 and not(contains($notPlanOfTreatmentStatus,concat('|',Status/text(),'|')))])"/>
		<!-- for each Procedure, export if it: (came from PlanOfTreatment) OR ((has an effective date in the future) AND (has active status)) -->
		<!-- when computing effective date, check its ProcedureTime if available, else check its FromTime. -->
		<xsl:variable name="hasDataProcedures" select="count(Procedures/Procedure[((CustomPairs/NVPair/Name/text()='PlanOfCare') or (CustomPairs/NVPair/Name/text()='PlanOfTreatment')) 
			or (((Status/Code/text()='active') or not(string-length(Status/Code/text()))) 
				and ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0)))])"/>
		<xsl:variable name="hasDataInstructions" select="count(Documents/Document[DocumentType/Description/text()='PlanOfCareInstruction' or DocumentType/Code/text()='PlanOfCareInstruction'])"/>
		<xsl:variable name="hasDataGoals" select="count(Goals/Goal)"/>		
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/planOfCare/emptySection/exportData/text()"/>

		<xsl:variable name="hasData" select="$hasDataLabOrders or $hasDataRadOrders or $hasDataOtherOrders or $hasDataAppointments or $hasDataReferrals or $hasDataMedications or $hasDataProcedures or $hasDataInstructions or $hasDataGoals"/>

		<xsl:value-of select="$hasData"/>

	</xsl:template>

	<xsl:template match="*" mode="sPOT-planOfTreatment-hasStructuredNarrativeDocs">
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-PlanOfCareSection]/code/@code)]"/>
		<xsl:value-of select="count($docs) > 0"/>
	</xsl:template>

	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sPOT-templateIds-planOfTreatmentSection">
		<templateId root="{$ccda-PlanOfCareSection}"/>
		<templateId root="{$ccda-PlanOfCareSection}" extension="2014-06-09"/>
	</xsl:template>
	
</xsl:stylesheet>