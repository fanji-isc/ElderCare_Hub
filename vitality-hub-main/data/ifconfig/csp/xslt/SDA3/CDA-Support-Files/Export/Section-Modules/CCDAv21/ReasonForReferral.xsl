<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="*" mode="sRFR-reasonForReferral">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasParameterData" select="string-length($eventReason) > 0"/><!-- checking a global variable; see Variables.xsl -->
		<xsl:variable name="hasSDAData" select="string-length(Referrals/Referral/ReferralReason/text()) > 0"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/reasonForReferral/emptySection/exportData/text()"/>

		<!-- imported section narratives -->
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-ReasonForReferralSection]/code/@code)]"/>
		<xsl:variable name="hasDocs" select="count($docs)"/>

		<xsl:if test="($hasDocs > 0) or ($hasParameterData) or ($hasSDAData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="($hasDocs = 0) and not(($hasParameterData) or ($hasSDAData))"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sRFR-templateIds-reasonForReferralSection"/>
					
					<code code="42349-1" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Reason for Referral"/>
					<title>Reason for Referral</title>
					
					<xsl:choose>
						<xsl:when test="$hasParameterData or $hasSDAData or ($hasDocs > 0)">
							<text>
								<xsl:if test="$hasParameterData">
									<xsl:value-of select="$eventReason" disable-output-escaping="yes"/>
								</xsl:if>
								<xsl:if test="$hasSDAData or ($hasDocs > 0)">
									<xsl:if test="$hasParameterData"><br/></xsl:if>
									<!-- use the structured narrative if there is one -->
									<xsl:choose>
										<xsl:when test="($hasDocs > 0)">
											<xsl:apply-templates mode="narrative-export-documents" select=".">
												<xsl:with-param name="docs" select="$docs"/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:when test="$hasSDAData">
											<xsl:value-of select="Referrals/Referral/ReferralReason/text()"/>
										</xsl:when>
									</xsl:choose>
								</xsl:if>
							</text>
						</xsl:when>
						<xsl:otherwise><xsl:apply-templates select="." mode="sRFR-reasonForReferral-NoData"/></xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- Following two modes are now unused -->
	<xsl:template match="*" mode="sRFR-reasonForReferral-parameter-Narrative">
		<xsl:value-of select="$eventReason" disable-output-escaping="yes"/>
	</xsl:template>
	
	<xsl:template match="*" mode="sRFR-reasonForReferral-SDA-Narrative">
		<xsl:value-of select="Referrals/Referral/ReferralReason/text()"/>
	</xsl:template>
	
	<xsl:template match="*" mode="sRFR-reasonForReferral-NoData">
		<text><xsl:value-of select="$exportConfiguration/reasonForReferral/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="sRFR-reasonForReferral-hasStructuredNarrativeDocs">
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-ReasonForReferralSection]/code/@code)]"/>
		<xsl:value-of select="count($docs) > 0"/>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sRFR-templateIds-reasonForReferralSection">
		<templateId root="{$ccda-ReasonForReferralSection}"/>
		<templateId root="{$ccda-ReasonForReferralSection}" extension="2014-06-09"/>
	</xsl:template>
	
</xsl:stylesheet>