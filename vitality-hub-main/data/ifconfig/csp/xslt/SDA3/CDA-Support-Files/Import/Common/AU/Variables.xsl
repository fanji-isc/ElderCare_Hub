<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:variable name="currentDateTime" select="isc:evaluate('timestamp')"/>
	<xsl:variable name="documentDateTime" select="/hl7:ClinicalDocument/hl7:effectiveTime/@value"/>
	<xsl:variable name="documentActionCode" select="/hl7:ClinicalDocument/hl7:relatedDocument/@typeCode"/>
	<xsl:variable name="sdaActionCodesEnabled" select="exsl:node-set($generalImportConfiguration)/sdaActionCodes/enabled/text()"/>
	<xsl:variable name="sdaOverrideExternalId" select="exsl:node-set($generalImportConfiguration)/sdaActionCodes/overrideExternalId/text()"/>
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

	<!-- Section Paths -->
	<xsl:variable name="administrativeObservationsSection" select="$sectionRootPath[hl7:code/@code='102.16080' and hl7:code/@codeSystem=$nctisOID]"/>
	<xsl:variable name="alertSection" select="$sectionRootPath[hl7:code/@code='101.16011' and hl7:code/@codeSystem=$nctisOID]"/>
	<xsl:variable name="eventSection" select="$sectionRootPath[hl7:code/@code='101.16006' and hl7:code/@codeSystem=$nctisOID]"/>
	<xsl:variable name="medicalHistorySection" select="$sectionRootPath[hl7:code/@code='101.16117' and hl7:code/@codeSystem=$nctisOID]"/>
	<xsl:variable name="diagnosesInterventionsSection" select="$sectionRootPath[hl7:code/@code='101.16117' and hl7:code/@codeSystem=$nctisOID]"/>
	<xsl:variable name="healthProfileSection" select="$sectionRootPath[hl7:code/@code='101.16011' and hl7:code/@codeSystem=$nctisOID]"/>
	<xsl:variable name="planSection" select="$sectionRootPath[hl7:code/@code='101.16020' and hl7:code/@codeSystem=$nctisOID]"/>

	<xsl:variable name="dischargeMedicationSection" select="$sectionRootPath[hl7:code/@code='101.16022' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']"/>
	<xsl:variable name="dischargeCurrentMedicationSection" select="$dischargeMedicationSection/hl7:component/hl7:section[hl7:code/@code='101.16146.4.1.1' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']"/>
	<xsl:variable name="dischargeCeasedMedicationSection" select="$dischargeMedicationSection/hl7:component/hl7:section[hl7:code/@code='101.16146.4.1.2' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']"/>
	<xsl:variable name="medicationSection" select="$sectionRootPath[hl7:code/@code='101.16146' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']"/>
	<xsl:variable name="immunizationSection" select="$sectionRootPath[hl7:code/@code='101.16638' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']"/>
	<xsl:variable name="referralDetailSection" select="$sectionRootPath[hl7:code/@code='102.16347' and hl7:code/@codeSystem='1.2.36.1.2001.1001.101']"/>

	<xsl:variable name="orderItemDefaultCode" select="exsl:node-set($resultsImportConfiguration)/orderItemDefaultCode/text()"/>
	<xsl:variable name="orderItemDefaultDescription" select="exsl:node-set($resultsImportConfiguration)/orderItemDefaultDescription/text()"/>

	<xsl:variable name="commentsEntryTemplateId" select="exsl:node-set($commentsImportConfiguration)/entryTemplateId/text()"/>
	<xsl:variable name="encountersSectionTemplateId" select="exsl:node-set($encountersImportConfiguration)/sectionTemplateId/text()"/>

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

	<!-- Global variables to hold lower case string and upper case string -->
	<xsl:variable name="lowerCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

	<!-- Global variables to hold HI Service OID and prefixes -->
	<xsl:variable name="hiServiceOID" select="'1.2.36.1.2001.1003.0'"/>
	<xsl:variable name="ihiPrefix" select="'800360'"/>
	<xsl:variable name="hpiiPrefix" select="'800361'"/>
	<xsl:variable name="hpioPrefix" select="'800362'"/>

	<!-- Global variable to hold the document type OID -->
	<xsl:variable name="documentTypeOID" select="/hl7:ClinicalDocument/hl7:templateId[1]/@root"/>

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
