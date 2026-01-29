<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="ext isc hl7 sdtc xsi exsl">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-AU.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/String-Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Common/AU/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Common/AU/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/ImportProfile.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>

	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/Alert.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/Result.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Entry-Modules/AU/Support.xsl"/>

	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/Alerts.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/DiagnosticResults.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/DiagnosticInvestigations.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/HospitalDischargeMedications.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Import/Section-Modules/AU/Referrals.xsl"/>

	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>

	<!-- Canonicalize the SDA output -->
	<xsl:template match="/">
		<xsl:variable name="firstPass"><xsl:apply-templates select="/hl7:ClinicalDocument"/></xsl:variable>
		<xsl:apply-templates select="exsl:node-set($firstPass)" mode= "Canonicalize"/>
	</xsl:template>

	<xsl:template match="/hl7:ClinicalDocument">
		<Container>
			<!-- Sending Facility -->
			<xsl:variable name="sendingFacility"><xsl:apply-templates select="." mode="SendingFacilityValue"/></xsl:variable>
			<xsl:if test="string-length($sendingFacility)">
				<SendingFacility><xsl:value-of select="$sendingFacility"/></SendingFacility>
			</xsl:if>

			<Patient>
				<!-- Personal Information -->
				<xsl:apply-templates select="hl7:recordTarget/hl7:patientRole" mode="PersonalInformation"/>

				<!-- Healthcare Provider module -->
				<xsl:apply-templates select="." mode="HealthcareProvider"/>

				<!-- Support Contacts -->
				<xsl:apply-templates select="." mode="Support"/>
			</Patient>

			<!-- Encounters -->
			<xsl:apply-templates select="." mode="Encounters"/>

			<!-- Alerts - under Health Profile -->
			<xsl:apply-templates select="$healthProfileSection/hl7:component/hl7:section[hl7:code/@code='101.20021' and hl7:code/@codeSystem=$nctisOID]" mode="Alerts"/>

			<!-- Adverse Reactions (Allergies)
				Discharge Summary   - under Health Profile
				All other documents - at root section level
			-->
			<xsl:choose>
				<xsl:when test="$documentTypeOID=$nehta-DischargeSummary">
					<xsl:apply-templates select="$healthProfileSection/hl7:component/hl7:section[hl7:code/@code='101.20113' and hl7:code/@codeSystem=$nctisOID and not(hl7:entry[1]/hl7:observation/hl7:code/@code='103.16302.4.3.4' and hl7:entry[1]/hl7:observation/hl7:code/@codeSystem=$nctisOID)]" mode="Allergies-Discharge"/>
				</xsl:when>
				<xsl:when test="$documentTypeOID=$nehta-sharedHealthSummary">
					<xsl:apply-templates select="$sectionRootPath[hl7:code/@code='101.20113' and hl7:code/@codeSystem=$nctisOID and not(hl7:entry[1]/hl7:observation/hl7:code/@code='103.16302.120.1.1' and hl7:entry[1]/hl7:observation/hl7:code/@codeSystem=$nctisOID)]" mode="Allergies"/>
				</xsl:when>
				<xsl:when test="$documentTypeOID=$nehta-eReferral">
					<xsl:apply-templates select="$sectionRootPath[hl7:code/@code='101.20113' and hl7:code/@codeSystem=$nctisOID and not(hl7:entry[1]/hl7:observation/hl7:code/@code='103.16302.2.2.2' and hl7:entry[1]/hl7:observation/hl7:code/@codeSystem=$nctisOID)]" mode="Allergies"/>
				</xsl:when>
				<xsl:when test="$documentTypeOID=$nehta-eventSummary">
					<xsl:apply-templates select="$sectionRootPath[hl7:code/@code='101.20113' and hl7:code/@codeSystem=$nctisOID]" mode="Allergies"/>
				</xsl:when>
			</xsl:choose>

			<!-- History of Present Illness - under Medical History as Other Medical History Item -->
			<xsl:if test="$medicalHistorySection/hl7:entry[hl7:act/hl7:code/@code='102.16627' and hl7:act/hl7:code/@codeSystem=$nctisOID]">
				<xsl:apply-templates select="$medicalHistorySection" mode="PresentIllnesses"/>
			</xsl:if>

			<!-- Problems/Diagnoses (Problems)
				Discharge Summary     - under Event
				Shared Health Summary - under Medical History
				Event Summary         - under Diagnoses/Interventions
				Referral              - under Medical History
			-->
			<xsl:choose>
				<xsl:when test="$documentTypeOID=$nehta-DischargeSummary">
					<xsl:apply-templates select="$eventSection/hl7:component/hl7:section[hl7:code/@code='101.16142' and hl7:code/@codeSystem=$nctisOID and not(hl7:entry[1]/hl7:observation/hl7:code/@code='103.16302.4.3.1' and hl7:entry[1]/hl7:observation/hl7:code/@codeSystem=$nctisOID)]/hl7:entry" mode="Problems"/>
				</xsl:when>
				<xsl:when test="$documentTypeOID=$nehta-sharedHealthSummary or $documentTypeOID=$nehta-eReferral">
					<xsl:apply-templates select="$medicalHistorySection/hl7:entry[hl7:observation/hl7:code/@code='282291009' and hl7:observation/hl7:code/@codeSystem=$snomedOID and not(hl7:observation/hl7:code/@code='103.16302.120.1.3' and hl7:entry[1]/hl7:observation/hl7:code/@codeSystem=$nctisOID)]" mode="Problems"/>
				</xsl:when>
				<xsl:when test="$documentTypeOID=$nehta-eventSummary">
					<xsl:apply-templates select="diagnosesInterventionsSection/hl7:component/hl7:section[hl7:code/@code='101.16142' and hl7:code/@codeSystem=$nctisOID and not(hl7:entry[1]/hl7:observation/hl7:code/@code='103.16302.4.3.1' and hl7:entry[1]/hl7:observation/hl7:code/@codeSystem=$nctisOID)]/hl7:entry" mode="Problems"/>
				</xsl:when>
			</xsl:choose>

			<!-- Procedures/Interventions (Procedures)
				Discharge Summary     - under Event
				Shared Health Summary - under Medical History
				Event Summary         - under Diagnoses/Interventions
				Referral              - under Medical History
			-->
			<xsl:variable name="procedureEntries">
				<xsl:choose>
					<xsl:when test="$documentTypeOID=$nehta-DischargeSummary">
						<xsl:value-of select="$eventSection/hl7:component/hl7:section[hl7:code/@code='101.20109' and hl7:code/@codeSystem=$nctisOID]/hl7:entry"/>
					</xsl:when>
					<xsl:when test="$documentTypeOID=$nehta-sharedHealthSummary or $documentTypeOID=$nehta-eReferral">
						<xsl:value-of select="$medicalHistorySection/hl7:entry[hl7:procedure/@classCode='PROC']"/>
					</xsl:when>
					<xsl:when test="$documentTypeOID=$nehta-eventSummary">
						<xsl:value-of select="$diagnosesInterventionsSection/hl7:entry[hl7:procedure/@classCode='PROC']"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="string-length($procedureEntries)">
				<Procedures>
					<xsl:choose>
						<xsl:when test="$documentTypeOID=$nehta-DischargeSummary">
							<xsl:apply-templates select="$eventSection/hl7:component/hl7:section[hl7:code/@code='101.20109' and hl7:code/@codeSystem=$nctisOID]/hl7:entry" mode="Procedures"/>
						</xsl:when>
						<xsl:when test="$documentTypeOID=$nehta-sharedHealthSummary or $documentTypeOID=$nehta-eReferral">
							<xsl:apply-templates select="$medicalHistorySection/hl7:entry[hl7:procedure/@classCode='PROC']" mode="Procedures"/>
						</xsl:when>
						<xsl:when test="$documentTypeOID=$nehta-eventSummary">
							<xsl:apply-templates select="$diagnosesInterventionsSection/hl7:entry[hl7:procedure/@classCode='PROC']" mode="Procedures"/>
						</xsl:when>
					</xsl:choose>
				</Procedures>
			</xsl:if>

			<!-- Diagnostic Investigations (Results)
				Discharge Summary     - under Event
				Shared Health Summary - not included
				Event Summary         - at root section level
				Referral              - at root section level
			-->
			<xsl:variable name="pathologyTestEntries">
				<xsl:choose>
					<xsl:when test="$documentTypeOID=$nehta-DischargeSummary">
						<xsl:value-of select="$eventSection/hl7:component/hl7:section[hl7:code/@code='101.20117' and hl7:code/@codeSystem=$nctisOID]/hl7:component/hl7:section[hl7:code/@code='102.16144' and hl7:code/@codeSystem=$nctisOID]/hl7:entry"/>
					</xsl:when>
					<xsl:when test="$documentTypeOID=$nehta-eReferral or $documentTypeOID=$nehta-eventSummary">
						<xsl:value-of select="$sectionRootPath[hl7:code/@code='101.20117' and hl7:code/@codeSystem=$nctisOID]/hl7:component/hl7:section[hl7:code/@code='102.16144' and hl7:code/@codeSystem=$nctisOID]/hl7:entry"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="imagingExaminationEntries">
				<xsl:choose>
					<xsl:when test="$documentTypeOID=$nehta-DischargeSummary">
						<xsl:value-of select="$eventSection/hl7:component/hl7:section[hl7:code/@code='101.20117' and hl7:code/@codeSystem=$nctisOID]/hl7:component/hl7:section[hl7:code/@code='102.16145' and hl7:code/@codeSystem=$nctisOID]/hl7:entry"/>
					</xsl:when>
					<xsl:when test="$documentTypeOID=$nehta-eReferral or $documentTypeOID=$nehta-eventSummary">
						<xsl:value-of select="$sectionRootPath[hl7:code/@code='101.20117' and hl7:code/@codeSystem=$nctisOID]/hl7:component/hl7:section[hl7:code/@code='102.16145' and hl7:code/@codeSystem=$nctisOID]/hl7:entry"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="string-length($pathologyTestEntries)">
				<LabOrders>
					<xsl:if test="isc:evaluate('varSet', 'LabOrderActionCodeDone', '0')"></xsl:if>
					<xsl:choose>
						<xsl:when test="$documentTypeOID=$nehta-DischargeSummary">
							<xsl:apply-templates select="$eventSection/hl7:component/hl7:section[hl7:code/@code='101.20117' and hl7:code/@codeSystem=$nctisOID]/hl7:component/hl7:section[hl7:code/@code='102.16144' and hl7:code/@codeSystem=$nctisOID]/hl7:entry" mode="LabResults"/>
						</xsl:when>
						<xsl:when test="$documentTypeOID=$nehta-eReferral or $documentTypeOID=$nehta-eventSummary">
							<xsl:apply-templates select="$sectionRootPath[hl7:code/@code='101.20117' and hl7:code/@codeSystem=$nctisOID]/hl7:component/hl7:section[hl7:code/@code='102.16144' and hl7:code/@codeSystem=$nctisOID]/hl7:entry" mode="LabResults"/>
						</xsl:when>
					</xsl:choose>
				</LabOrders>
			</xsl:if>
			<xsl:if test="string-length($imagingExaminationEntries)">
				<RadOrders>
					<xsl:if test="isc:evaluate('varSet', 'RadOrderActionCodeDone', '0')"></xsl:if>
					<xsl:choose>
						<xsl:when test="$documentTypeOID=$nehta-DischargeSummary">
							<xsl:apply-templates select="$eventSection/hl7:component/hl7:section[hl7:code/@code='101.20117' and hl7:code/@codeSystem=$nctisOID]/hl7:component/hl7:section[hl7:code/@code='102.16145' and hl7:code/@codeSystem=$nctisOID]/hl7:entry" mode="RadResults"/>
						</xsl:when>
						<xsl:when test="$documentTypeOID=$nehta-eReferral or $documentTypeOID=$nehta-eventSummary">
							<xsl:apply-templates select="$sectionRootPath[hl7:code/@code='101.20117' and hl7:code/@codeSystem=$nctisOID]/hl7:component/hl7:section[hl7:code/@code='102.16145' and hl7:code/@codeSystem=$nctisOID]/hl7:entry" mode="RadResults"/>
						</xsl:when>
					</xsl:choose>
				</RadOrders>
			</xsl:if>

			<!-- Discharge Medications and Medications -->
			<xsl:variable name="dischargeCurrentMedicationEntries" select="$dischargeCurrentMedicationSection/hl7:entry[not(hl7:observation/hl7:code/@code='103.16302.4.3.2' and hl7:observation/hl7:code/@codeSystem=$nctisOID)]"/>
			<xsl:variable name="dischargeCeasedMedicationEntries" select="$dischargeCeasedMedicationSection/hl7:entry[not(hl7:observation/hl7:code/@code='103.16302.4.3.3' and hl7:observation/hl7:code/@codeSystem=$nctisOID)]"/>
			<xsl:variable name="medicationEntries" select="$medicationSection/hl7:entry[not(hl7:observation/hl7:code/@codeSystem=$nctisOID and (hl7:observation/hl7:code/@code='103.16302.120.1.2' or hl7:observation/hl7:code/@code='103.16302.2.2.1' or hl7:observation/hl7:code/@code='103.16302.132.1.1'))]"/>
			<xsl:if test="string-length($dischargeCurrentMedicationEntries) or string-length($dischargeCeasedMedicationEntries) or string-length($medicationEntries)">
				<Medications>
					<xsl:apply-templates select="$dischargeCurrentMedicationEntries" mode="DischargeMedications"/>
					<xsl:apply-templates select="$dischargeCeasedMedicationEntries" mode="DischargeMedications"/>
					<xsl:apply-templates select="$medicationEntries" mode="Medications"/>
				</Medications>
			</xsl:if>

			<!-- Immunizations -->
			<xsl:variable name="immunizationEntries" select="$immunizationSection/hl7:entry[not(hl7:observation/hl7:code/@code='103.16302.120.1.5' and hl7:observation/hl7:code/@codeSystem=$nctisOID)]"/>
			<xsl:if test="$immunizationEntries">
				<Vaccinations>
					<xsl:apply-templates select="$immunizationEntries" mode="Immunizations"/>
				</Vaccinations>
			</xsl:if>

			<!-- Referrals -->
			<xsl:if test="$documentTypeOID=$nehta-eReferral and $referralDetailSection/hl7:entry">
				<xsl:apply-templates select="$referralDetailSection" mode="Referrals"/>
			</xsl:if>

			<!-- Custom import -->
			<xsl:apply-templates select="." mode="ImportCustom-Container"/>
		</Container>
	</xsl:template>

	<!-- At the top SDA level, insert the first element, then loop through the node sets of subsequent elements with the same name -->
	<xsl:template match="/Container/*" mode="Canonicalize">
		<xsl:variable name="elementName" select="local-name()"/>
		<xsl:if test="count(preceding-sibling::*[name()=$elementName])=0">
				<xsl:copy>
					<xsl:for-each select="self::* | following-sibling::*[name()=$elementName]">
						<xsl:apply-templates mode="Canonicalize"/>
					</xsl:for-each>
				</xsl:copy>
		</xsl:if>
	</xsl:template>

	<!-- Copy all other SDA elements as is -->
	<xsl:template match="*" mode="Canonicalize">
		<xsl:copy>
			<xsl:apply-templates mode="Canonicalize"/>
		</xsl:copy>
	</xsl:template>

	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ImportCustom-Container">
	</xsl:template>
</xsl:stylesheet>
