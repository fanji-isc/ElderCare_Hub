<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
	<xsl:output method="xml" indent="yes"/>
	<!-- This stylesheet can be used to pre-process an SDA export document before export
	     restructuring. It removes the "Z" time-zone indicator from certain elements
	     that are expected to contain a date-time as their sole text content. -->

	<!-- Identity template, copies all nodes (except below) -->
	<xsl:template match="node()">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- Catch all the elements whose content is one text node containing a date-time value in yyyy-mm-ddThh:mm:ssZ
	   format and strip off the Z. If there are additional custom elements that should be caught, copy this
	   template and in the copy, change the list of element names. If necessary, elements can be further
	   qualified by the name of their parent (e.g., Encounter/StartTime) or predicates, but keep in mind that
	   such filters add to the processing time. -->
	<xsl:template match="ActionTime | ActualPaidDate | AdmissionDate | AnalysisTime | AuthorizationTime | BirthTime |
			ClaimProcessedDate | ConfirmedTime | CreatedOn | CreatedTime | DeathTime | DischargeDate | DiscoveryTime |
			DOB | DocumentTime | EmergencyAdmitDateTime | EmploymentStopDate | EndTime | EnteredOn | ExpectedAdmitTime |
			ExpectedDischargeTime | ExpectedLOAReturnTime | ExpirationDate | ExpiryDate | FromTime | GUIDExpDate |
			HireEffectiveDate | IdentificationTime | ImmunizationRegistryStatusEffectiveDate | InactiveTime |
			ObservationTime | ObservationValueTime | OnsetTime | PhysExamTime | ProcedureTime | ProtectedEffectiveDate |
			PublicityEffectiveDate | ReassessmentTime | ReceivedDate | ResultTime | SpecimenCollectedTime | StartDate |
			StartTime | SubmissionDate | ToTime | TranscriptionTime | UpdatedOn | VerifiedTime">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="translate(., 'Z', '')"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
