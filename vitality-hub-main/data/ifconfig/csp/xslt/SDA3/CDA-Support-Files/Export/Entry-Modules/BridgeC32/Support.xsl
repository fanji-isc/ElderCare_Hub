<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="Patient" mode="nextOfKin">
		<xsl:apply-templates select="SupportContacts/SupportContact" mode="participant-NextOfKin"/>
		<!--
			If SDA Patient MothersMaidenName has a value but there is no
			SupportContact that is the Mother, record a CDA support contact
			that is just the mother's maiden name.
		-->
		<xsl:if test="not(SupportContacts/SupportContact[Relationship/Code/text()='MTH']) and string-length(/Container/Patient/MothersMaidenName/text())">
			<xsl:apply-templates select="." mode="participant-MothersMaidenName"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="SupportContact" mode="participant-NextOfKin">
		<participant typeCode="IND">			
			<xsl:apply-templates select="." mode="templateIds-NextOfKinParticipant"/>
			
			<xsl:apply-templates select="." mode="time"/>
			
			<!-- Here, the address will always be constructed as Work-Primary since SDA doesn't have an addressUse field. -->
			<xsl:apply-templates select="." mode="associatedEntity">
				<!--
					From HL7 v2.5 Contact Role code table:
					- E = Employer
					- C = Emergency Contact
					- F = Federal Agency
					- I = Insurance Company
					- N = Next-of-Kin
					- S = State Agency
					- O = Other
					- U = Unknown
					
					From Value Set 2.16.840.1.113883.11.20.9.33 (INDRoleclassCodes):
					- PRS       = personal relationship
					- NOK       = next of kin
					- CAREGIVER = caregiver
					- AGNT      = agent
					- GUAR      = guarantor
					- ECON      = emergency contact
				-->
				<xsl:with-param name="contactType">
					<xsl:choose>
						<xsl:when test="ContactType/Code/text() = 'F'"><xsl:text>AGNT</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'C'"><xsl:text>ECON</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'N'"><xsl:text>NOK</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'O'"><xsl:text>CAREGIVER</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'S'"><xsl:text>GUARD</xsl:text></xsl:when>
						<xsl:when test="ContactType/Code/text() = 'U'"><xsl:text>PRS</xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>PRS</xsl:text></xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:apply-templates>
		</participant>
	</xsl:template>
	
	<!--
		participant-MothersMaidenName is used only when SDA Patient
		MothersMaidenName has a value but there is no SupportContact
		that is the Mother.
	-->
	<xsl:template match="*" mode="participant-MothersMaidenName">
		<participant typeCode="IND">
			<xsl:apply-templates select="." mode="templateIds-NextOfKinParticipant"/>
			<time nullFlavor="UNK"/>
			<associatedEntity classCode="NOK">
				<id nullFlavor="UNK"/>
				<code code="MTH" codeSystem="{$roleCodeOID}" codeSystemName="{$roleCodeName}" displayName="Mother">
					<originalText>Mother</originalText>
				</code>
				<addr nullFlavor="UNK"/>
				<telecom nullFlavor="UNK"/>
				<associatedPerson>
					<name use="L"><family qualifier="BR"><xsl:value-of select="/Container/Patient/MothersMaidenName/text()"/></family></name>
				</associatedPerson>
			</associatedEntity>
		</participant>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-NextOfKinParticipant">
		<xsl:if test="$hitsp-CDA-Support"><templateId root="{$hitsp-CDA-Support}"/></xsl:if>
		<xsl:if test="$ihe-PCC-PatientContacts"><templateId root="{$ihe-PCC-PatientContacts}"/></xsl:if>
	</xsl:template>
</xsl:stylesheet>
