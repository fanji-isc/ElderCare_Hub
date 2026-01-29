<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="encompassingEncounter">
		<xsl:param name="clinicians"/>
		
		<componentOf>
			<encompassingEncounter>
				<!--
					HS.SDA3.Encounter EncounterNumber
					HS.SDA3.Encounter HealthCareFacility.Organization
					CDA Section: Document Header - Encompassing Encounter
					CDA Field: Encounter ID
					CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/id[2]
				-->				
				<xsl:apply-templates select="." mode="id-Encounter"/>
				
				<xsl:apply-templates select="." mode="encompassingEncounter-patientClass-select"/>
				
				<!--
					HS.SDA3.Encounter FromTime
					HS.SDA3.Encounter ToTime
					CDA Section: Document Header - Encompassing Encounter
					CDA Field: Encounter Date/Time
					CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/effectiveTime
				-->				
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
				
				<xsl:apply-templates select="." mode="encounter-separationMode"/>
				
				<!--
					HS.SDA3.Encounter AttendingClinicians
					CDA Section: Document Header - Encompassing Encounter
					CDA Field: Discharge Clinician
					CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant
					
					There is no DischargeClinician in SDA, so the first Attending
					found is used when exporting DischargeClinician.
				-->				
				<!-- There is no DischargeClinician in SDA, so use the first Attending. -->
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|DIS|')">
					<xsl:apply-templates select="AttendingClinicians/CareProvider[1]" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'DIS'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<!--
					HS.SDA3.Encounter AttendingClinicians
					CDA Section: Document Header - Encompassing Encounter
					CDA Field: Attending Clinicians
					CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant
				-->				
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|ATND|')">
					<xsl:apply-templates select="AttendingClinicians/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'ATND'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<!--
					HS.SDA3.Encounter AdmittingClinician
					CDA Section: Document Header - Encompassing Encounter
					CDA Field: Admitting Clinician
					CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant
				-->				
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|ADM|')">
					<xsl:apply-templates select="AdmittingClinician/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'ADM'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<!--
					HS.SDA3.Encounter ConsultingClinicians
					CDA Section: Document Header - Encompassing Encounter
					CDA Field: Consulting Clinicians
					CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant
				-->				
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|CON|')">
					<xsl:apply-templates select="ConsultingClinicians/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'CON'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<!--
					HS.SDA3.Encounter ReferringClinician
					CDA Section: Document Header - Encompassing Encounter
					CDA Field: Referring Clinician
					CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant
				-->				
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|REF|')">
					<xsl:apply-templates select="ReferringClinician" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'REF'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<xsl:apply-templates select="HealthCareFacility" mode="encompassingEncounter-location"/>
			</encompassingEncounter>
		</componentOf>
	</xsl:template>
	
	<xsl:template match="*" mode="encounter-separationMode">
		
		<!--
			HS.SDA3.Encounter SeparationMode
			CDA Section: Document Header - Encompassing Encounter
			CDA Field: Discharge Disposition Code
			CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/dischargeDispositionCode
		-->		
		<xsl:choose>
			<xsl:when test="string-length(SeparationMode)">
				<xsl:variable name="displayText"><xsl:apply-templates select="SeparationMode" mode="encounter-separationModeDisplayText"/></xsl:variable>
				<xsl:apply-templates select="SeparationMode" mode="generic-Coded">
					<xsl:with-param name="isCodeRequired" select="'1'"/>
					<xsl:with-param name="writeOriginalText" select="'0'"/>
					<xsl:with-param name="cdaElementName" select="'dischargeDispositionCode'"/>
					<xsl:with-param name="displayText" select="$displayText"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise><dischargeDispositionCode nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="encounter-separationModeDisplayText">
		<!--
			If the Description is numeric or not provided, try to
			select the	correct Description text from value set
			2.16.840.1.113883.3.88.12.80.33 (Discharge Disposition,
			or NUBC UB-04 FL17-Patient Status) from code system
			2.16.840.1.113883.12.112 (HL7 Discharge Disposition).
		-->
		<xsl:variable name="codeNumber" select="number(Code/text())"/>
		<xsl:variable name="descNumber" select="number(Description/text())"/>
		
		<xsl:choose>
			<xsl:when test="number(Description/text())">
				<xsl:choose>
					<xsl:when test="$descNumber = '1'">Discharged to home or self care</xsl:when>
					<xsl:when test="$descNumber = '2'">Discharged/transferred to another short-term general hospital for inpatient care</xsl:when>
					<xsl:when test="$descNumber = '3'">Discharged/transferred to skilled nursing facility</xsl:when>
					<xsl:when test="$descNumber = '4'">Discharged/transferred to an intermediate-care facility</xsl:when>
					<xsl:when test="$descNumber = '5'">Discharged/transferred to another type of institution for inpatient care or referred for outpatient services to another institution</xsl:when>
					<xsl:when test="$descNumber = '6'">Discharged/transferred to home under care of organized home health service organization</xsl:when>
					<xsl:when test="$descNumber = '7'">Left against medical advice or discontinued care</xsl:when>
					<xsl:when test="$descNumber = '8'">Discharged/transferred to home under care of Home IV provider</xsl:when>
					<xsl:when test="$descNumber = '9'">Admitted as an inpatient to this hospital</xsl:when>
					<xsl:when test="$descNumber = '20'">Expired</xsl:when>
					<xsl:when test="$descNumber = '30'">Still patient or expected to return for outpatient services</xsl:when>
					<xsl:when test="$descNumber = '40'">Expired at home</xsl:when>
					<xsl:when test="$descNumber = '41'">Expired in a medical facility</xsl:when>
					<xsl:when test="$descNumber = '42'">Expired - place unknown</xsl:when>
					<xsl:otherwise><xsl:value-of select="Description/text()"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="string-length(Description/text())"><xsl:value-of select="Description/text()"/></xsl:when>
			<xsl:when test="number(Code/text())">
				<xsl:choose>
					<xsl:when test="$codeNumber = '1'">Discharged to home or self care</xsl:when>
					<xsl:when test="$codeNumber = '2'">Discharged/transferred to another short-term general hospital for inpatient care</xsl:when>
					<xsl:when test="$codeNumber = '3'">Discharged/transferred to skilled nursing facility</xsl:when>
					<xsl:when test="$codeNumber = '4'">Discharged/transferred to an intermediate-care facility</xsl:when>
					<xsl:when test="$codeNumber = '5'">Discharged/transferred to another type of institution for inpatient care or referred for outpatient services to another institution</xsl:when>
					<xsl:when test="$codeNumber = '6'">Discharged/transferred to home under care of organized home health service organization</xsl:when>
					<xsl:when test="$codeNumber = '7'">Left against medical advice or discontinued care</xsl:when>
					<xsl:when test="$codeNumber = '8'">Discharged/transferred to home under care of Home IV provider</xsl:when>
					<xsl:when test="$codeNumber = '9'">Admitted as an inpatient to this hospital</xsl:when>
					<xsl:when test="$codeNumber = '20'">Expired</xsl:when>
					<xsl:when test="$codeNumber = '30'">Still patient or expected to return for outpatient services</xsl:when>
					<xsl:when test="$codeNumber = '40'">Expired at home</xsl:when>
					<xsl:when test="$codeNumber = '41'">Expired in a medical facility</xsl:when>
					<xsl:when test="$codeNumber = '42'">Expired - place unknown</xsl:when>
					<xsl:otherwise><xsl:value-of select="Code/text()"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="Code/text()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="encompassingEncounter-participant">
		<xsl:param name="participantType"/>
		
		<encounterParticipant typeCode="{$participantType}">
			<time nullFlavor="UNK"/>
			<xsl:apply-templates select="." mode="assignedEntity-encounterParticipant"/>
		</encounterParticipant>
	</xsl:template>
	
	<xsl:template match="*" mode="encompassingEncounter-location">
		<!--
			HS.SDA3.Encounter HealthCareFacility
			CDA Section: Document Header - Encompassing Encounter
			CDA Field: Facility Location
			CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/location/healthCareFacility
		-->		
		<location>
			<healthCareFacility>
				<xsl:apply-templates select="." mode="id-encounterLocation"/>
				<xsl:apply-templates select="Organization" mode="serviceProviderOrganization"/>
			</healthCareFacility>
		</location>
	</xsl:template>
	
	<!--
		encompassingEncounter-patientClass-select determines whether
		to export CDA encounter type using SDA EncounterCodedType or
		EncounterType.  It calls encompassingEncounter-patientClass-coded
		or encompassingEncounter-patientClass, based on the available SDA
		data.
	-->
	<xsl:template match="Encounter" mode="encompassingEncounter-patientClass-select">
		<xsl:choose>
			<xsl:when test="string-length(EncounterCodedType)">
				<xsl:apply-templates select="EncounterCodedType" mode="encompassingEncounter-patientClass-coded"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="encompassingEncounter-patientClass"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="EncounterCodedType" mode="encompassingEncounter-patientClass-coded">
		<xsl:variable name="codeSystemOID">
			<xsl:choose>
				<xsl:when test="string-length(SDACodingStandard)">
					<xsl:apply-templates select="." mode="oid-for-code">
						<xsl:with-param name="Code" select="SDACodingStandard/text()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$noCodeSystemOID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--
			HITSP/C83 requires encompassingEncounter Patient Class code to
			be either IMP, EMER or AMB.  If Code does not equal any of these
			then export as nullFlavor and put the data into a translation
			element.
		-->
		<xsl:choose>
			<xsl:when test="string-length(SDACodingStandard) and (Code='IMP' or Code='AMB' or Code='EMER')">
				<code code="{Code/text()}" codeSystem="{$codeSystemOID}" codeSystemName="{SDACodingStandard/text()}" displayName="{Description/text()}">
					<xsl:if test="string-length(OriginalText)"><originalText><xsl:value-of select="OriginalText"/></originalText></xsl:if>
				</code>
			</xsl:when>
			<xsl:otherwise>
				<code nullFlavor="OTH">
					<xsl:if test="string-length(OriginalText)"><originalText><xsl:value-of select="OriginalText"/></originalText></xsl:if>
					<translation code="{Code/text()}" codeSystem="{$codeSystemOID}" codeSystemName="{SDACodingStandard/text()}" displayName="{Description/text()}"/>
				</code>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="encompassingEncounter-patientClass">
		<!--
			HS.SDA3.Encounter EncounterType
			CDA Section: Document Header - Encompassing Encounter
			CDA Field: Encounter Type
			CDA XPath: /ClinicalDocument/componentOf/encompassingEncounter/code
		-->	
		<!--
			HITSP/C83 requires encompassingEncounter Patient Class code to
			be either IMP, EMER or AMB.
		-->
		<xsl:variable name="patientClassCode">
			<xsl:choose>
				<xsl:when test="EncounterType/text()='I'">IMP</xsl:when>
				<xsl:when test="EncounterType/text()='O'">AMB</xsl:when>
				<xsl:when test="EncounterType/text()='E'">EMER</xsl:when>
				<xsl:when test="EncounterType/text()='P'">IMP</xsl:when>
				<xsl:when test="string-length(EncounterType/text())">IMP</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="patientClassDescription">
			<xsl:choose>
				<xsl:when test="$patientClassCode='IMP'">Inpatient</xsl:when>
				<xsl:when test="$patientClassCode='AMB'">Ambulatory</xsl:when>
				<xsl:when test="$patientClassCode='EMER'">Emergency</xsl:when>
			</xsl:choose>
		</xsl:variable>
				
		<xsl:choose>
			<xsl:when test="string-length($patientClassCode)">
				<code code="{$patientClassCode}" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}" displayName="{$patientClassDescription}"/>
			</xsl:when>
			<xsl:otherwise>
				<code nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
