<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Entry module has non-parallel name. AlsoInclude: Condition.xsl -->
  
  	<xsl:variable name="assessmentDiagnosisTypeCodes" select="translate($exportConfiguration/assessments/diagnosisType/codes/text(), $lowerCase, $upperCase)"/>

	<xsl:template match="*" mode="sA-assessments">
		<xsl:param name="sectionRequired" select="'0'"/>

		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/assessments/emptySection/exportData/text()"/>		

		<xsl:variable name="hasDiagnosisData">
			<xsl:apply-templates select="." mode="sA-assessments-hasDiagnosisData"/>				
		</xsl:variable>
		<xsl:variable name="hasEncounterAssessmentData">
			<xsl:apply-templates select="." mode="sA-assessments-hasEncounterAssessmentData"/>	
		</xsl:variable>
		<xsl:variable name="hasAssessmentData">
			<xsl:apply-templates select="." mode="sA-assessments-hasAssessmentData"/>
		</xsl:variable>	

		<!-- imported section narratives -->
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-AssessmentSection]/code/@code)]"/>
		<xsl:variable name="hasDocs" select="count($docs)"/>

		<xsl:if test="($hasDocs > 0) or ($hasAssessmentData='true') or ($exportSectionWhenNoData = '1') or ($sectionRequired = '1')">
			<component>
				<section>
					<xsl:if test="($hasDocs = 0) and ($hasDiagnosisData='false') and ($hasEncounterAssessmentData='false')"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sA-templateIds-assessmentsSection"/>					
					<code code="51848-0" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Assessments"/>
					<title>Assessments</title>
					
					<xsl:choose>					
						<!--Either diagnosis assessment or encounter assessment or both-->
						<xsl:when test="$hasAssessmentData='true'">
							<text>
								<xsl:choose>
									<!-- use imported structured narrative if there is one -->
									<xsl:when test="$hasDocs > 0">
										<xsl:apply-templates mode="narrative-export-documents" select=".">
											<xsl:with-param name="docs" select="$docs"/>
										</xsl:apply-templates>
									</xsl:when>
									<!--Encounter assessment-->
									<xsl:when test="$hasEncounterAssessmentData='true'">
										<table border="1" width="100%">
											<thead>
												<tr>
													<th>Assessment</th>
													<th>EncounterNumber</th>
												</tr>
											</thead>
											<tbody>
												<xsl:for-each select="Documents/Document[DocumentType/Code/text()='Assessment' or DocumentType/Description/text()='Assessment']">
													<xsl:apply-templates select ="." mode="eA-assessment-NarrativeDetail">
														<xsl:with-param name="AssessmentNarrativeDetailSuffix" select="position()"/>
													</xsl:apply-templates>
												</xsl:for-each>
											</tbody>
										</table>
									</xsl:when>
								</xsl:choose>

								<!--Diagnosis assessment-->	
								<xsl:if test="$hasDiagnosisData='true'">
									<xsl:apply-templates select="." mode="sA-diagnosesEncounterAssessment-Narrative">
										<xsl:with-param name="diagnosisTypeCodes" select="$assessmentDiagnosisTypeCodes"/>
										<xsl:with-param name="narrativeLinkCategory">assessments</xsl:with-param>
									</xsl:apply-templates>
								</xsl:if>
							</text>

							<xsl:if test="$hasDiagnosisData='true'">
								<xsl:apply-templates select="." mode="eCn-diagnoses-Entries">
									<xsl:with-param name="diagnosisTypeCodes" select="$assessmentDiagnosisTypeCodes"/>
									<xsl:with-param name="narrativeLinkCategory">assessments</xsl:with-param>
								</xsl:apply-templates>
							</xsl:if>			

						</xsl:when>
						<!-- use imported structured narrative document if there is one -->
						<xsl:when test="$hasDocs > 0">
							<text>
								<xsl:apply-templates mode="narrative-export-documents" select=".">
									<xsl:with-param name="docs" select="$docs"/>
								</xsl:apply-templates>
							</text>
						</xsl:when>
						<!--No assessment-->	
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="sA-assessments-NoData"/>
						</xsl:otherwise>
					</xsl:choose>

				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="sA-assessments-NoData">
		<text><xsl:value-of select="$exportConfiguration/assessments/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<xsl:template match="*" mode="sA-diagnosesEncounterAssessment-Narrative">
		<xsl:param name="narrativeLinkCategory"/>
		<xsl:param name="diagnosisTypeCodes"/><!-- This was previously uppercased -->
				
		<table border="1" width="100%">
			<thead>
				<tr>
					<th>Condition Name</th>
					<th>Status</th>
					<th>Diagnosis Date</th>
					<th>Treating Clinician</th>
				</tr>
			</thead>
			<tbody>
				<xsl:apply-templates select="Diagnoses/Diagnosis[contains($diagnosisTypeCodes, concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|'))]" mode="eCn-diagnoses-NarrativeDetail">
					<xsl:with-param name="narrativeLinkCategory" select="$narrativeLinkCategory"/>
				</xsl:apply-templates>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="*" mode="sA-assessments-hasDiagnosisData">
		<xsl:variable name="hasDiagnosisData" select="count(Diagnoses/Diagnosis[contains($assessmentDiagnosisTypeCodes, concat('|', translate(DiagnosisType/Code/text(), $lowerCase, $upperCase), '|'))])"/>
		<xsl:value-of select="$hasDiagnosisData &gt; 0"/>
	</xsl:template>

	<xsl:template match="*" mode="sA-assessments-hasEncounterAssessmentData">
		<xsl:variable name="hasEncounterAssessmentData" select="count(Documents/Document[DocumentType/Code/text()='Assessment' or DocumentType/Description/text()='Assessment'])"/>
		<xsl:value-of select="$hasEncounterAssessmentData &gt; 0"/>
	</xsl:template>

	<xsl:template match="*" mode="sA-assessments-hasAssessmentData">
		<xsl:variable name="hasDiagnosisData">
			<xsl:apply-templates select="." mode="sA-assessments-hasDiagnosisData"/>				
		</xsl:variable>
		<xsl:variable name="hasEncounterAssessmentData">
			<xsl:apply-templates select="." mode="sA-assessments-hasEncounterAssessmentData"/>	
		</xsl:variable>
		<xsl:value-of select="($hasEncounterAssessmentData='true') or ($hasDiagnosisData='true')"/>
	</xsl:template>
	
	<xsl:template match="*" mode="sA-assessments-hasStructuredNarrativeDocs">
		<xsl:variable name="docs" select="Documents/Document[(Category/Code/text() = 'SectionNarrative') and (DocumentType/Code/text() = $exportConfiguration/narrative/section[templateId/@root = $ccda-AssessmentSection]/code/@code)]"/>
		<xsl:value-of select="count($docs) > 0"/>
	</xsl:template>

	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sA-templateIds-assessmentsSection">
		<templateId root="{$ccda-AssessmentSection}"/>
		<templateId root="{$ccda-AssessmentSection}" extension="2015-08-01"/>
	</xsl:template>
  
</xsl:stylesheet>