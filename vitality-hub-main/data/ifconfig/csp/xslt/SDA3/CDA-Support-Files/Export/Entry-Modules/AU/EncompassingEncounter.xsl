<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="encompassingEncounter">
		<xsl:param name="clinicians"/>
		
		<componentOf>
			<encompassingEncounter>
				<id root="{$homeCommunityOID}" extension="{EncounterNumber/text()}"/>
				<xsl:apply-templates select="." mode="effectiveTime-FromTo"/>
				<xsl:apply-templates select="SeparationMode" mode="encounter-separationMode"/>
				
				<!-- There is no DischargeClinician in SDA, so use the first Attending. -->
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|DIS|')">
					<xsl:apply-templates select="AttendingClinicians/CareProvider[1]" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'DIS'"/>
					</xsl:apply-templates>
				</xsl:if>
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|ATND|')">
					<xsl:apply-templates select="AttendingClinicians/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'ATND'"/>
					</xsl:apply-templates>
				</xsl:if>
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|ADM|')">
					<xsl:apply-templates select="AdmittingClinician/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'ADM'"/>
					</xsl:apply-templates>
				</xsl:if>
				<xsl:if test="contains(concat('|',$clinicians,'|'),'|CON|')">
					<xsl:apply-templates select="ConsultingClinicians/CareProvider" mode="encompassingEncounter-participant">
							<xsl:with-param name="participantType" select="'CON'"/>
					</xsl:apply-templates>
				</xsl:if>
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
		<xsl:variable name="displayText"><xsl:apply-templates select="." mode="encounter-separationModeDisplayText"/></xsl:variable>
		
		<dischargeDispositionCode code="{Code/text()}" codeSystem="2.16.840.1.113883.13.65" codeSystemName="AIHW Mode of Separation" displayName="{$displayText}" />
	</xsl:template>
	
	<xsl:template match="*" mode="encounter-separationModeDisplayText">
		<xsl:choose>
			<xsl:when test="Code/text() = '1'">Other Hospital</xsl:when>
			<xsl:when test="Code/text() = '2'">Aged Care Service</xsl:when>
			<xsl:when test="Code/text() = '3'">Psychiatric Care</xsl:when>
			<xsl:when test="Code/text() = '4'">Health Service</xsl:when>
			<xsl:when test="Code/text() = '5'">Administrative Discharge</xsl:when>
			<xsl:when test="Code/text() = '6'">Self-discharged</xsl:when>
			<xsl:when test="Code/text() = '7'">Administrative from Leave</xsl:when>
			<xsl:when test="Code/text() = '8'">Deceased</xsl:when>
			<xsl:when test="Code/text() = '9'">Other/Home</xsl:when>
			<xsl:when test="string-length(Description/text())"><xsl:value-of select="Description/text()"/></xsl:when>
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
		<location>
			<healthCareFacility>
				<id>
					<xsl:attribute name="root"><xsl:apply-templates select="Code" mode="code-to-oid"/></xsl:attribute>
				</id>
				<code code="HOSP" codeSystem="2.16.840.1.113883.1.11.17660" codeSystemName="HL7 ServiceDeliveryLocationRoleType" displayName="Hospital"/>
				<xsl:apply-templates select="." mode="serviceProviderOrganization"/>
			</healthCareFacility>
		</location>
	</xsl:template>
</xsl:stylesheet>
