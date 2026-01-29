<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="Encounter" mode="eEE-encompassingEncounter">
		<xsl:param name="clinicians"/><!-- list of clinician type codes, delimited by |
		           CAUTION: must have leading and trailing | characters -->
		
		<componentOf>
			<encompassingEncounter>
			
				<!--
					Field : Encompassing Encounter Number
					Target: /ClinicalDocument/componentOf/encompassingEncounter/id
					Source: HS.SDA3.Encounter EncounterNumber
					Source: /Container/Encounters/Encounter/EncounterNumber
					StructuredMappingRef: id-Encounter
				-->
				<xsl:apply-templates select="." mode="fn-id-Encounter"/>
				
				<xsl:apply-templates select="." mode="eEE-encompassingEncounter-patientClass-select"/>
			
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
				<xsl:apply-templates select="." mode="fn-effectiveTime-FromTo"/>
				
				<xsl:apply-templates select="." mode="eEE-dischargeDispositionCode"/>
				
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
				<xsl:if test="contains($clinicians,'|DIS|')">
					<xsl:apply-templates select="AttendingClinicians/CareProvider[1]" mode="eEE-encompassingEncounter-participant">
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
				<xsl:if test="contains($clinicians,'|ATND|')">
					<xsl:apply-templates select="AttendingClinicians/CareProvider" mode="eEE-encompassingEncounter-participant">
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
				<xsl:if test="contains($clinicians,'|ADM|')">
					<xsl:apply-templates select="AdmittingClinician/CareProvider" mode="eEE-encompassingEncounter-participant">
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
				<xsl:if test="contains($clinicians,'|CON|')">
					<xsl:apply-templates select="ConsultingClinicians/CareProvider" mode="eEE-encompassingEncounter-participant">
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
				<xsl:if test="contains($clinicians,'|REF|')">
					<xsl:apply-templates select="ReferringClinician" mode="eEE-encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'REF'"/>
					</xsl:apply-templates>
				</xsl:if>
				
				<xsl:apply-templates select="HealthCareFacility" mode="eEE-encompassingEncounter-location"/>
			</encompassingEncounter>
		</componentOf>
	</xsl:template>
	
	<xsl:template match="Encounter" mode="eEE-dischargeDispositionCode">
	
		<!--
			Field : Encompassing Encounter Discharge Disposition Code
			Target: /ClinicalDocument/componentOf/encompassingEncounter/dischargeDispositionCode
			Source: HS.SDA3.Encounter SeparationMode
			Source: /Container/Encounters/Encounter/SeparationMode
			StructuredMappingRef: generic-Coded
		-->
		<xsl:choose>
			<xsl:when test="string-length(SeparationMode)">
				<xsl:variable name="displayText">
					<!-- This string becomes the value of the displayName attribute -->
					<xsl:apply-templates select="SeparationMode" mode="eEE-formatDischargeDisplayName"/>
				</xsl:variable>
				<xsl:apply-templates select="SeparationMode" mode="fn-generic-Coded">
					<xsl:with-param name="isCodeRequired" select="'1'"/>
					<xsl:with-param name="writeOriginalText" select="'0'"/>
					<xsl:with-param name="cdaElementName" select="'dischargeDispositionCode'"/>
					<xsl:with-param name="displayText" select="$displayText"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise><dischargeDispositionCode nullFlavor="UNK"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="SeparationMode" mode="eEE-formatDischargeDisplayName">
		<!--
			If the Description is numeric or not provided, try to
			select the	correct Description text from value set
			2.16.840.1.113883.3.88.12.80.33 (Discharge Disposition,
			or NUBC UB-04 FL17-Patient Status) from code system
			2.16.840.1.113883.12.112 (HL7 Discharge Disposition).
		-->
		<xsl:variable name="codeAsNumber" select="number(Code/text())"/>
		<xsl:variable name="descAsNumber" select="number(Description/text())"/>
		
		<!-- ToDoXSLT2: make a "local key table" for the number codes below -->
		<xsl:choose>
			<xsl:when test="not($descAsNumber = 'NaN')">
				<xsl:choose>
					<xsl:when test="$descAsNumber = '1'">Discharged to home or self care</xsl:when>
					<xsl:when test="$descAsNumber = '2'">Discharged/transferred to another short-term general hospital for inpatient care</xsl:when>
					<xsl:when test="$descAsNumber = '3'">Discharged/transferred to skilled nursing facility</xsl:when>
					<xsl:when test="$descAsNumber = '4'">Discharged/transferred to an intermediate-care facility</xsl:when>
					<xsl:when test="$descAsNumber = '5'">Discharged/transferred to another type of institution for inpatient care or referred for outpatient services to another institution</xsl:when>
					<xsl:when test="$descAsNumber = '6'">Discharged/transferred to home under care of organized home health service organization</xsl:when>
					<xsl:when test="$descAsNumber = '7'">Left against medical advice or discontinued care</xsl:when>
					<xsl:when test="$descAsNumber = '8'">Discharged/transferred to home under care of Home IV provider</xsl:when>
					<xsl:when test="$descAsNumber = '9'">Admitted as an inpatient to this hospital</xsl:when>
					<xsl:when test="$descAsNumber = '20'">Expired</xsl:when>
					<xsl:when test="$descAsNumber = '30'">Still patient or expected to return for outpatient services</xsl:when>
					<xsl:when test="$descAsNumber = '40'">Expired at home</xsl:when>
					<xsl:when test="$descAsNumber = '41'">Expired in a medical facility</xsl:when>
					<xsl:when test="$descAsNumber = '42'">Expired - place unknown</xsl:when>
					<xsl:otherwise><xsl:value-of select="Description/text()"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="string-length(Description/text())"><xsl:value-of select="Description/text()"/></xsl:when>
			<xsl:when test="not($codeAsNumber = 'NaN')">
				<xsl:choose>
					<xsl:when test="$codeAsNumber = '1'">Discharged to home or self care</xsl:when>
					<xsl:when test="$codeAsNumber = '2'">Discharged/transferred to another short-term general hospital for inpatient care</xsl:when>
					<xsl:when test="$codeAsNumber = '3'">Discharged/transferred to skilled nursing facility</xsl:when>
					<xsl:when test="$codeAsNumber = '4'">Discharged/transferred to an intermediate-care facility</xsl:when>
					<xsl:when test="$codeAsNumber = '5'">Discharged/transferred to another type of institution for inpatient care or referred for outpatient services to another institution</xsl:when>
					<xsl:when test="$codeAsNumber = '6'">Discharged/transferred to home under care of organized home health service organization</xsl:when>
					<xsl:when test="$codeAsNumber = '7'">Left against medical advice or discontinued care</xsl:when>
					<xsl:when test="$codeAsNumber = '8'">Discharged/transferred to home under care of Home IV provider</xsl:when>
					<xsl:when test="$codeAsNumber = '9'">Admitted as an inpatient to this hospital</xsl:when>
					<xsl:when test="$codeAsNumber = '20'">Expired</xsl:when>
					<xsl:when test="$codeAsNumber = '30'">Still patient or expected to return for outpatient services</xsl:when>
					<xsl:when test="$codeAsNumber = '40'">Expired at home</xsl:when>
					<xsl:when test="$codeAsNumber = '41'">Expired in a medical facility</xsl:when>
					<xsl:when test="$codeAsNumber = '42'">Expired - place unknown</xsl:when>
					<xsl:otherwise><xsl:value-of select="Code/text()"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="Code/text()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="CareProvider | ReferringClinician" mode="eEE-encompassingEncounter-participant">
		<xsl:param name="participantType"/>
		
		<encounterParticipant typeCode="{$participantType}">
			<time nullFlavor="UNK"/>
			<xsl:apply-templates select="." mode="fn-assignedEntity-performer"/>
		</encounterParticipant>
	</xsl:template>
	
	<xsl:template match="HealthCareFacility" mode="eEE-encompassingEncounter-location">
	
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
				<xsl:apply-templates select="." mode="fn-id-encounterLocation"/>
				<xsl:apply-templates select="Organization" mode="fn-serviceProviderOrganization"/>
			</healthCareFacility>
		</location>
	</xsl:template>
	
	<xsl:template match="Encounter" mode="eEE-encompassingEncounter-patientClass-select">
		<!--
		encompassingEncounter-patientClass-select determines whether to export CDA
		encounter type using SDA EncounterCodedType or EncounterType,
		preferring the former. When EncounterCodedType is present,
		produce a code element for it. If not, invoke encompassingEncounter-patientClass,
		and make the best code element we can from EncounterType.
	-->
		<xsl:choose>
			<xsl:when test="string-length(EncounterCodedType)">
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
				<xsl:apply-templates select="EncounterCodedType" mode="fn-generic-Coded"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="eEE-code-patientClass"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Encounter" mode="eEE-code-patientClass">
	
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
		
		<xsl:choose>
			<xsl:when test="string-length($patientClassCode)">
				<xsl:variable name="patientClassDescription">
					<xsl:choose>
						<xsl:when test="$patientClassCode='IMP'">Inpatient</xsl:when>
						<xsl:when test="$patientClassCode='AMB'">Ambulatory</xsl:when>
						<xsl:when test="$patientClassCode='EMER'">Emergency</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<code code="{$patientClassCode}" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}" displayName="{$patientClassDescription}"/>
			</xsl:when>
			<xsl:otherwise>
				<code nullFlavor="UNK"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="EncounterCodedType" mode="eEE-encompassingEncounter-patientClass-coded">
		<!-- UNUSED -->
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
		<xsl:apply-templates select="." mode="fn-generic-Coded"/>
	</xsl:template>
	
</xsl:stylesheet>