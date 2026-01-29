<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="Patient" mode="eS-nextOfKin">
		<xsl:apply-templates select="SupportContacts/SupportContact" mode="eS-participant-NextOfKin"/>
	</xsl:template>
	
	<xsl:template match="SupportContact" mode="eS-participant-NextOfKin">
		<!--
			Field : Support Contact
			Target: /ClinicalDocument/participant[@typeCode='IND']/associatedEntity
			Source: HS.SDA3.SupportContact
			Source: /Container/Patient/SupportContacts/SupportContact
			StructuredMappingRef: associatedEntity
		-->
		<participant typeCode="IND">			
			<!-- According to CCD, this should represent the time during which the SupportContact provides support.  Not known in SDA. -->
			<time nullFlavor="UNK"/>
			
			<!-- Here, the address will always be constructed as Work-Primary since SDA doesn't have an addressUse field.  We should fix this. -->
			<xsl:apply-templates select="." mode="fn-associatedEntity">
				<xsl:with-param name="contactType">
					<xsl:variable name="sourceContact" select="ContactType/Code/text()"/>
					<xsl:choose>
						<xsl:when test="$sourceContact = 'F'">AGNT</xsl:when>
						<xsl:when test="$sourceContact = 'C'">ECON</xsl:when>
						<xsl:when test="$sourceContact = 'N'">NOK</xsl:when>
						<xsl:when test="$sourceContact = 'O'">CAREGIVER</xsl:when>
						<xsl:when test="$sourceContact = 'S'">GUARD</xsl:when>
						<xsl:when test="$sourceContact = 'U'">PRS</xsl:when>
						<xsl:otherwise>PRS</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:apply-templates>
		</participant>
	</xsl:template>

	<xsl:template match="Encounter" mode="eS-participant-CallBack">	

		<participant typeCode="CALLBCK">

			<time>
				<xsl:choose>
					<xsl:when test="string-length(EnteredOn)">
						<xsl:attribute name="value">
							<xsl:apply-templates select="EnteredOn" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</time>			

			<xsl:apply-templates select="." mode="fn-associatedEntity-ParticipantCallback"/>			

		</participant>

	</xsl:template>
	
</xsl:stylesheet>