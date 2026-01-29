<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="Organization" mode="eAP-author-Document">
		<author typeCode="AUT">
			<xsl:call-template name="eAP-templateIds-authorParticipation"/>

			<time value="{$currentDateTime}"/>
			<xsl:apply-templates select="." mode="eAP-assignedAuthor-Document"/>
		</author>
	</xsl:template>

	<xsl:template match="EnteredBy | OrderedBy | VerifiedBy | SupportContact | Provider | Clinician | Performer" mode="eAP-author-Human">
		<!--
			StructuredMapping: author-Human
			
			Field
			Path  : time
			Source: ParentProperty.EnteredOn
			Source: ../EnteredOn

			Field
			Path  : assignedAuthor
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: assignedAuthor-Human
		-->
		<author typeCode="AUT">
			<xsl:call-template name="eAP-templateIds-authorParticipation"/>

			<time>
				<xsl:choose>
					<xsl:when test="string-length(../EnteredOn)">
						<xsl:attribute name="value">
							<xsl:apply-templates select="../EnteredOn" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:attribute>
					</xsl:when>
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

			<xsl:apply-templates select="." mode="eAP-assignedAuthor-Human"/>			

		</author>
		
	</xsl:template>


	<xsl:template match="Organization" mode="eAP-author-Device">
		<author typeCode="AUT">
			<xsl:call-template name="eAP-templateIds-authorParticipation"/>
			<time value="{$currentDateTime}"/>
			<xsl:apply-templates select="." mode="eAP-assignedAuthor-Device"/>
		</author>
	</xsl:template>

	<!-- Match could be EnteredBy, OrderedBy, VerifiedBy, Provider, or Performer -->
	<xsl:template match="*" mode="eAP-assignedAuthor-Human">
		<!--
			StructuredMapping: assignedAuthor-Human
			
			Field
			Path  : id
			Source: CurrentProperty
			Source: ./
			StructuredMappingRef: id-Clinician
			
			Field
			Path  : code
			Source: Description
			Source: ./Description
			StructuredMappingRef: author-Code
			Note  : assignedAuthor/code is exported only when the SDA Description
					indicates patient-entered data, when Description is "Payer",
					"Payor" or "Patient".
			
			Field
			Path  : representedOrganization
			Source: ParentProperty.EnteredAt
			Source: ../EnteredAt
			StructuredMappingRef: representedOrganization
		-->
		<assignedAuthor classCode="ASSIGNED">
			<!-- Clinician ID -->
			<xsl:apply-templates select="." mode="fn-id-Clinician"/>

			<!-- HealthShare-specific author types -->
			<xsl:apply-templates
				select="Description[contains('|PAYER|PAYOR|PATIENT|', translate(text(), $lowerCase, $upperCase))]"
				mode="eAP-author-Code"/>
			
			<!-- ContactType -->
			<xsl:apply-templates select="ContactType" mode="fn-generic-Coded">
				<xsl:with-param name="cdaElementName">code</xsl:with-param>
			</xsl:apply-templates>

			<!-- Author Address -->
			<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
			
			<!-- Author Telecom -->
			<xsl:apply-templates select="." mode="fn-telecom"/>

			<!-- Person -->
			<xsl:apply-templates select="." mode="fn-assignedPerson"/>
						
			<!-- Represented Organization -->
			<xsl:apply-templates select="../EnteredAt" mode="fn-representedOrganization"/>
		</assignedAuthor>
	</xsl:template>

	<xsl:template match="*" mode="eAP-author-Code">
		<!--
			StructuredMapping: author-Code
			
			Field
			Path  : originalText/text()
			Source: CurrentProperty
			Source: text()
		-->
		<code nullFlavor="NA">
			<originalText><xsl:value-of select="text()"/></originalText>
		</code>
	</xsl:template>

	<xsl:template match="Organization" mode="eAP-assignedAuthor-Document">
		<assignedAuthor classCode="ASSIGNED">
			<id nullFlavor="NA"/>
			<addr nullFlavor="NA"/>
			<telecom nullFlavor="NA"/>
			
			<!-- Represented Organization -->
			<xsl:apply-templates select="." mode="fn-representedOrganization-Document"/>
		</assignedAuthor>
	</xsl:template>

	<xsl:template match="Organization" mode="eAP-assignedAuthor-Device">
		<assignedAuthor classCode="ASSIGNED">
			<!-- HealthShare ID -->
			<xsl:apply-templates select="." mode="fn-id-HealthShare"/>
			
			<xsl:apply-templates select="." mode="fn-address-WorkPrimary"/>
			<xsl:apply-templates select="." mode="fn-telecom"/>
			
			<!-- Software Device -->
			<xsl:apply-templates select="." mode="fn-assignedAuthoringDevice"/>
			
			<xsl:apply-templates select="." mode="fn-representedOrganization-Document"/>
		</assignedAuthor>
	</xsl:template>

	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eAP-templateIds-authorParticipation">
		<templateId root="{$ccda-AuthorParticipation}"/>
	</xsl:template>
	
</xsl:stylesheet>