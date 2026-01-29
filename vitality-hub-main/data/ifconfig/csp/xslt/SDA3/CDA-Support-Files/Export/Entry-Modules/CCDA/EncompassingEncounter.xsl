<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="encompassingEncounter">
		<xsl:param name="clinicians"/>
		
		<componentOf>
			<encompassingEncounter>
			
				<!--
					Field : Encompassing Encounter Number
					Target: /ClinicalDocument/componentOf/encompassingEncounter/id
					Source: HS.SDA3.Encounter EncounterNumber
					Source: /Container/Encounters/Encounter/EncounterNumber
					StructuredMappingRef: id-Encounter
				-->
				<xsl:apply-templates select="." mode="id-Encounter"/>
				
				<xsl:apply-templates select="." mode="encompassingEncounter-patientClass-select"/>
			
				<!--
					Field : Encompassing Encounter Start Time
					Target: /ClinicalDocument/componentOf/encompassingEncounter/effectiveTime/low/@value
					Source: HS.SDA3.Encounter FromTime
					Source: /Container/Encounters/Encounter/FromTime
				-->
				<!--
					Field : Encompassing Encounter End Time
					Target: /ClinicalDocument/componentOf/encompassingEncounter/effectiveTime/high/@value
					Source: HS.SDA3.Encounter ToTime
					Source: /Container/Encounters/Encounter/ToTime
				-->
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
				
				<xsl:apply-templates select="." mode="encounter-separationMode"/>
				
				<!--
					Field : Encompassing Encounter Discharge Clinician
					Target: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode='DIS']/assignedEntity
					Source: HS.SDA3.Encounter AttendingClinicians.CareProvider[1]
					Source: /Container/Encounters/Encounter/AttendingClinicians/CareProvider[1]
					StructuredMappingRef: assignedEntity-encounterParticipant
					Note  : There is no DischargeClinician in SDA, so the first Attending
							found is used when exporting DischargeClinician.
				-->
				<!-- There is no DischargeClinician in SDA, so use the first Attending. -->
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|DIS|')">
					<xsl:apply-templates select="AttendingClinicians/CareProvider[1]" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'DIS'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<!--
					Field : Encompassing Encounter Attending Clinicians
					Target: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode='ATND']/assignedEntity
					Source: HS.SDA3.Encounter AttendingClinicians.CareProvider
					Source: /Container/Encounters/Encounter/AttendingClinicians/CareProvider
					StructuredMappingRef: assignedEntity-encounterParticipant
				-->
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|ATND|')">
					<xsl:apply-templates select="AttendingClinicians/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'ATND'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<!--
					Field : Encompassing Encounter Admitting Clinician
					Target: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode='ADM']/assignedEntity
					Source: HS.SDA3.Encounter AdmittingClinician
					Source: /Container/Encounters/Encounter/AdmittingClinician
					StructuredMappingRef: assignedEntity-encounterParticipant
				-->
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|ADM|')">
					<xsl:apply-templates select="AdmittingClinician/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'ADM'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<!--
					Field : Encompassing Encounter Consulting Clinicians
					Target: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode='CON']/assignedEntity
					Source: HS.SDA3.Encounter ConsultingClinicians.CareProvider
					Source: /Container/Encounters/Encounter/ConsultingClinicians/CareProvider
					StructuredMappingRef: assignedEntity-encounterParticipant
				-->
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|CON|')">
					<xsl:apply-templates select="ConsultingClinicians/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'CON'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<!--
					Field : Encompassing Encounter Referring Clinician
					Target: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode='REF']/assignedEntity
					Source: HS.SDA3.Encounter ReferringClinician
					Source: /Container/Encounters/Encounter/ReferringClinician
					StructuredMappingRef: assignedEntity-encounterParticipant
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
			Field : Encompassing Encounter Discharge Disposition Code
			Target: /ClinicalDocument/componentOf/encompassingEncounter/dischargeDispositionCode
			Source: HS.SDA3.Encounter SeparationMode
			Source: /Container/Encounters/Encounter/SeparationMode
			StructuredMappingRef: generic-Coded
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
			Field : Encompassing Encounter Facility Location
			Target: /ClinicalDocument/componentOf/encompassingEncounter/location/healthCareFacility/id
			Source: HS.SDA3.Encounter HealthCareFacility
			Source: /Container/Encounters/Encounter/HealthCareFacility
			StructuredMappingRef: id-encounterLocation
		-->
		<!--
			Field : Encompassing Encounter Service Provider Organization
			Target: /ClinicalDocument/componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization
			Source: HS.SDA3.Encounter HealthCareFacility.Organization
			Source: /Container/Encounters/Encounter/HealthCareFacility/Organization
			StructuredMappingRef: serviceProviderOrganization
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
		<!--
			C-CDA allows any coded values, but recommends using
			the Evaluation and Management (E&M) value set.
		-->
		<!--
			Field : Encompassing Encounter Coded Type
			Target: /ClinicalDocument/componentOf/encompassingEncounter/code
			Source: HS.SDA3.Encounter EncounterCodedType
			Source: /Container/Encounters/Encounter/EncounterCodedType
			StructuredMappingRef: generic-Coded
		-->
		<xsl:apply-templates select="." mode="generic-Coded"/>
	</xsl:template>
	
	<xsl:template match="*" mode="encompassingEncounter-patientClass">
	
		<!--
			Field : Encompassing Encounter Type Code
			Target: /ClinicalDocument/componentOf/encompassingEncounter/code/@code
			Source: HS.SDA3.Encounter EncounterType
			Source: /Container/Encounters/Encounter/EncounterType
			Note  : SDA EncounterType maps to @code in the following manner:
					If EncounterType='I' then @code='IMP'
					If EncounterType='O' then @code='AMB'
					If EncounterType='E' then @code='EMER'
					If EncounterType='P' then @code='IMP'
					If EncounterType is any other non-blank value then @code='IMP'
		-->
		<!--
			Field : Encompassing Encounter Type Description
			Target: /ClinicalDocument/componentOf/encompassingEncounter/code/@displayName
			Source: HS.SDA3.Encounter EncounterType
			Source: /Container/Encounters/Encounter/EncounterType
			Note  : SDA EncounterType maps to @displayName in the following manner:
					If EncounterType='I' then @displayName='Inpatient'
					If EncounterType='O' then @displayName='Ambulatory'
					If EncounterType='E' then @displayName='Emergency'
					If EncounterType='P' then @displayName='Inpatient'
					If EncounterType is any other non-blank value then @displayName='Inpatient'
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
