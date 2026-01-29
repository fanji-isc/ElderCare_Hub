<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">
	<!--
		documentHeaderItems is a vertical bar-delimited list of CDA
		document header items to import to SDA3 AdditionalDocumentInfo.
	-->
	<xsl:param name="documentHeaderItems" select="''"/>
	
	<xsl:variable name="documentHeaderItemsList">
		<xsl:choose>
			<!--
				If an "all" indicator was passed in, then set $documentHeaderItemsList to
				all items from POCD_MT000040.ClinicalDocument except for realmCode, typeId,
				templateId, code, languageCode, component.
			-->
			<xsl:when test="translate($documentHeaderItems,'al','AL')='ALL' or $documentHeaderItems='*'">
				<xsl:value-of select="'|id|title|effectiveTime|confidentialityCode|setId|versionNumber|copyTime|recordTarget|author|dataEnterer|informant|custodian|informationRecipient|legalAuthenticator|authenticator|participant|inFulfillmentOf|documentationOf|relatedDocument|authorization|componentOf|'"/>
			</xsl:when>
			<xsl:when test="string-length($documentHeaderItems)">
				<xsl:value-of select="concat('|',$documentHeaderItems,'|')"/>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="currentDateTime" select="isc:evaluate('timestamp')"/>
	<xsl:variable name="documentDateTime" select="/hl7:ClinicalDocument/hl7:effectiveTime/@value"/>
	<xsl:variable name="documentActionCode" select="/hl7:ClinicalDocument/hl7:relatedDocument/@typeCode"/>
	<xsl:variable name="sdaActionCodesEnabled" select="exsl:node-set($generalImportConfiguration)/sdaActionCodes/enabled/text()"/>
	<xsl:variable name="sdaOverrideExternalId" select="exsl:node-set($generalImportConfiguration)/sdaActionCodes/overrideExternalId/text()"/>
	<xsl:variable name="blockImportCTDCodeFromText" select="exsl:node-set($generalImportConfiguration)/blockImportCTDCodeFromText/text()"/>
	<!-- For repOrgconcatIdRootAndNumericExt the value in ImportProfile.xsl must be '1' or missing altogether in order to enable concat. -->
	<xsl:variable name="repOrgconcatIdRootAndNumericExt">
		<xsl:choose>
			<xsl:when test="exsl:node-set($generalImportConfiguration)/representedOrganizationId/concatRootAndNumericExtension/text()='0'">0</xsl:when>
			<xsl:when test="exsl:node-set($generalImportConfiguration)/representedOrganizationId/concatRootAndNumericExtension/text()='1'">1</xsl:when>
			<xsl:when test="not(string-length(exsl:node-set($generalImportConfiguration)/representedOrganizationId/concatRootAndNumericExtension/text()))">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="sectionRootPath" select="/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section"/>
	<xsl:variable name="nonXMLBodyRootPath" select="/hl7:ClinicalDocument/hl7:component/hl7:nonXMLBody"/>
	<xsl:variable name="defaultAuthorRootPath" select="/hl7:ClinicalDocument/hl7:author[not(hl7:assignedAuthor/hl7:assignedAuthoringDevice)]"/>
	<xsl:variable name="defaultAuthoringDeviceRootPath" select="/hl7:ClinicalDocument/hl7:author[hl7:assignedAuthor/hl7:assignedAuthoringDevice]"/>
	<xsl:variable name="defaultInformantRootPath" select="/hl7:ClinicalDocument/hl7:informant"/>
	
	<xsl:key name="narrativeKey" match="//*" use="@ID"/>
	
	<xsl:variable name="narrativeImportModeGeneral">
		<xsl:choose>
			<xsl:when test="string-length(exsl:node-set($generalImportConfiguration)/narrativeImportMode/text())">
				<xsl:value-of select="exsl:node-set($generalImportConfiguration)/narrativeImportMode/text()"/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- Section Template IDs -->
	<xsl:variable name="activeProblemsSectionTemplateId" select="exsl:node-set($problemsImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="admissionDiagnosesSectionTemplateId" select="exsl:node-set($admissionDiagnosesImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="advanceDirectivesSectionTemplateId" select="exsl:node-set($advanceDirectivesImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="allergiesSectionTemplateId" select="exsl:node-set($allergiesImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="assessmentAndPlanSectionTemplateId" select="exsl:node-set($assessmentAndPlanImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="careConsiderationsSectionTemplateId" select="exsl:node-set($careConsiderationsImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="commentsEntryTemplateId" select="exsl:node-set($commentsImportConfiguration)/entryTemplateId/text()"/>
	<xsl:variable name="dischargeDiagnosesSectionTemplateId" select="exsl:node-set($dischargeDiagnosesImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="dischargeMedicationsSectionTemplateId" select="exsl:node-set($dischargeMedicationsImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="encountersSectionTemplateId" select="exsl:node-set($encountersImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="familyHistorySectionTemplateId" select="exsl:node-set($familyHistoryImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="immunizationsSectionTemplateId" select="exsl:node-set($immunizationsImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="medicationInstructionsEntryTemplateId" select="exsl:node-set($medicationInstructionsImportConfiguration)/entryTemplateId/text()"/>
	<xsl:variable name="medicationsSectionTemplateId" select="exsl:node-set($medicationsImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="medicationsAdministeredSectionTemplateId" select="exsl:node-set($medicationsAdministeredImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="payersSectionTemplateId" select="exsl:node-set($payersImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="payersEntryCoverageTemplateId" select="exsl:node-set($payersImportConfiguration)/entryTemplateId/text()"/>
	<xsl:variable name="planSectionTemplateId" select="exsl:node-set($planImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="presentIllnessSectionTemplateId" select="exsl:node-set($presentIllnessImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="proceduresSectionTemplateId" select="exsl:node-set($proceduresImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="resolvedProblemsSectionTemplateId" select="exsl:node-set($pastIllnessImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="resultsC32SectionTemplateId" select="exsl:node-set($resultsImportConfiguration)/sectionC32TemplateId/text()"/>
	<xsl:variable name="resultsC37SectionTemplateId" select="exsl:node-set($resultsImportConfiguration)/sectionC37TemplateId/text()"/>
	<xsl:variable name="resultOrganizerTemplateId" select="exsl:node-set($resultsImportConfiguration)/resultOrganizerTemplateId/text()"/>
	<xsl:variable name="orderItemDefaultCode" select="exsl:node-set($resultsImportConfiguration)/orderItemDefaultCode/text()"/>
	<xsl:variable name="orderItemDefaultDescription" select="exsl:node-set($resultsImportConfiguration)/orderItemDefaultDescription/text()"/>
	<xsl:variable name="socialHistorySectionTemplateId" select="exsl:node-set($socialHistoryImportConfiguration)/sectionTemplateId/text()"/>
	<xsl:variable name="vitalSignsSectionTemplateId" select="exsl:node-set($vitalSignsImportConfiguration)/sectionTemplateId/text()"/>

	<!-- Medications PharmacyStatus -->
	<xsl:variable name="dischargeMedicationsPharmacyStatus">
		<xsl:choose>
			<xsl:when test="string-length(exsl:node-set($dischargeMedicationsImportConfiguration)/pharmacyStatus/text())">
				<xsl:value-of select="exsl:node-set($dischargeMedicationsImportConfiguration)/pharmacyStatus/text()"/>
			</xsl:when>
			<xsl:otherwise>DISCHARGE</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="medicationsPharmacyStatus">
		<xsl:choose>
			<xsl:when test="string-length(exsl:node-set($medicationsImportConfiguration)/pharmacyStatus/text())">
				<xsl:value-of select="exsl:node-set($medicationsImportConfiguration)/pharmacyStatus/text()"/>
			</xsl:when>
			<xsl:otherwise>MEDICATIONS</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="medicationsAdministeredPharmacyStatus">
		<xsl:choose>
			<xsl:when test="string-length(exsl:node-set($medicationsAdministeredImportConfiguration)/pharmacyStatus/text())">
				<xsl:value-of select="exsl:node-set($medicationsAdministeredImportConfiguration)/pharmacyStatus/text()"/>
			</xsl:when>
			<xsl:otherwise>ADMINISTERED</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- Global variable to hold mapping of CDA encounter codes to SDA EncounterType -->
	<xsl:variable name="encounterTypeMaps" select="exsl:node-set($encountersImportConfiguration)/encounterTypeMaps"/>
	
	<!-- 
		Global variables for payer section handling
		By default as HealthFunds (not MemberEnrollments) for backward compatibility 
	-->
	<xsl:variable name="healthFundImportMode">
		<xsl:choose>
			<xsl:when test="'0' = exsl:node-set($encountersImportConfiguration)/healthFundImportMode/text()">0</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="memberEnrollmentImportMode">
		<xsl:choose>
			<xsl:when test="'1' = exsl:node-set($payersImportConfiguration)/memberEnrollmentImportMode/text()">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- 
		Global variables for gender identity handling
		By default as SocialHistory (not Patient:GenderIdentity) for backward compatibility 
	-->
	<xsl:variable name="patientGenderIdentityImportMode">
		<xsl:choose>
			<xsl:when test="'1' = exsl:node-set($socialHistoryImportConfiguration)/patientGenderIdentityImportMode/text()">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="socialHistoryGenderIdentityImportMode">
		<xsl:choose>
			<xsl:when test="'0' = exsl:node-set($socialHistoryImportConfiguration)/socialHistoryGenderIdentityImportMode/text()">0</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- Global variables to hold lower case string and upper case string -->
	<xsl:variable name="lowerCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	
	<!-- encompassingEncounter ID, if any -->
	<xsl:variable name="encompassingEncounterID">
		<xsl:choose>
			<xsl:when test="string-length(/hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter/hl7:id/@extension)"><xsl:value-of select="/hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter/hl7:id/@extension"/></xsl:when>
			<xsl:when test="string-length(/hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter/hl7:id/@root)"><xsl:value-of select="/hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter/hl7:id/@root"/></xsl:when>
		</xsl:choose>
	</xsl:variable>
	
	<!-- encounterIDs is a vertical bar-delimited string of encounter ids. -->
	<xsl:variable name="encounterIDs">
		<xsl:apply-templates select="/hl7:ClinicalDocument" mode="getEncounterIDs">
			<xsl:with-param name="encompassingEncounterID" select="$encompassingEncounterID"/>
		</xsl:apply-templates>
	</xsl:variable>

	<!-- Gather all of the Encounter IDs into a vertical bar-delimited string. -->
	<xsl:template match="*" mode="getEncounterIDs">
		<xsl:param name="encompassingEncounterID"/>
		
		<xsl:variable name="encountersSectionEncounterIDs">
			<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$encountersSectionTemplateId]/hl7:entry" mode="getEncounterSectionIDs"/>
		</xsl:variable>
		<xsl:if test="string-length($encompassingEncounterID)"><xsl:value-of select="concat('|',$encompassingEncounterID)"/></xsl:if>
		<xsl:if test="string-length($encountersSectionEncounterIDs)"><xsl:value-of select="$encountersSectionEncounterIDs"/></xsl:if>
		<xsl:if test="string-length($encountersSectionEncounterIDs) or string-length($encompassingEncounterID)">|</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="getEncounterSectionIDs">
		<!--
			encounterIDTemp is used as an intermediate so that encounterID
			can be set up such that "000nnn" does NOT match "nnn" when
			comparing encounter numbers.
		-->
		<xsl:variable name="encounterIDTemp">
			<xsl:choose>
				<xsl:when test="string-length(hl7:encounter/hl7:id/@extension)">
					<xsl:value-of select="hl7:encounter/hl7:id/@extension"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="hl7:encounter/hl7:id/@root"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="encounterID" select="string($encounterIDTemp)"/>
		
		<xsl:value-of select="concat('|',$encounterID)"/>
	</xsl:template>
</xsl:stylesheet>
