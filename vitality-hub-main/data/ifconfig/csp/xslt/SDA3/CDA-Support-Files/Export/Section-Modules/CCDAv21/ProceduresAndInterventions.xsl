<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc">
  <!-- Entry module has non-parallel name. AlsoInclude: Procedure.xsl -->
  
	<xsl:template match="*" mode="sPAI-procedures">
		<xsl:param name="sectionRequired" select="'0'"/>
		<xsl:param name="entriesRequired" select="'0'"/>
		
		<!-- Export Procedures that: (did not come from PlanOfTreatment) AND ((with no date) OR (have a current or past effective date) OR (have a future effective date AND status not active)) -->
		<xsl:variable name="allowableProcedures" select="Procedures/Procedure[(not(CustomPairs/NVPair/Name[text()='PlanOfCare' or text()='PlanOfTreatment']))
			and ((not(string-length(ProcedureTime/text())) and not(string-length(FromTime/text())))
				or ((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) >= 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) >= 0))
				or (((string-length(ProcedureTime/text()) and isc:evaluate('dateDiff', 'dd', translate(ProcedureTime/text(), 'TZ', ' ')) &lt; 0) or (not(string-length(ProcedureTime/text())) and string-length(FromTime/text()) and isc:evaluate('dateDiff', 'dd', translate(FromTime/text(), 'TZ', ' ')) &lt; 0))
					and (string-length(Status/Code/text()) and not(Status/Code/text()='active'))))]"/>
		<xsl:variable name="hasData" select="count($allowableProcedures) > 0"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/procedures/emptySection/exportData/text()"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1')">
			<component>
				<section>
					<xsl:if test="not($hasData)"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sPAI-templateIds-proceduresSection">
						<xsl:with-param name="entriesRequired" select="$entriesRequired"/>
					</xsl:call-template>
					
					<code code="47519-4" displayName="History of Procedures" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Procedures</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<xsl:apply-templates select="." mode="eP-procedures-Narrative">
								<xsl:with-param name="procedureList" select="$allowableProcedures"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="eP-procedures-Entries">
								<xsl:with-param name="procedureList" select="$allowableProcedures"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eP-procedures-NoData"/>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sPAI-templateIds-proceduresSection">
		<xsl:param name="entriesRequired"/>
		<xsl:choose>
			<xsl:when test="$entriesRequired = '1'">
				<templateId root="{$ccda-ProceduresSectionEntriesRequired}"/>
				<templateId root="{$ccda-ProceduresSectionEntriesRequired}" extension="2014-06-09"/>
			</xsl:when>
			<xsl:otherwise>
				<templateId root="{$ccda-ProceduresSectionEntriesOptional}"/>
				<templateId root="{$ccda-ProceduresSectionEntriesOptional}" extension="2014-06-09"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
