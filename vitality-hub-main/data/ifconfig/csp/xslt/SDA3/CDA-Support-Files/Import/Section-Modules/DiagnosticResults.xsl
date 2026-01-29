<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="ResultsSection">
		<xsl:variable name="resultsC32Section" select="$sectionRootPath[hl7:templateId/@root=$resultsC32SectionTemplateId]"/>
		<xsl:variable name="resultsC37Section" select="$sectionRootPath[hl7:templateId/@root=$resultsC37SectionTemplateId]"/>
		
		<xsl:variable name="resultsC32NoData"><xsl:apply-templates select="$resultsC32Section" mode="IsNoDataSection-Results"/></xsl:variable>
		<xsl:variable name="resultsC37NoData"><xsl:apply-templates select="$resultsC37Section" mode="IsNoDataSection-Results"/></xsl:variable>
		<xsl:variable name="resultsC32Entries" select="$resultsC32Section/hl7:entry[(count(hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')]) &gt; 0) and (not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		<xsl:variable name="resultsC37Entries" select="$resultsC37Section/hl7:entry[(count(hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')]) &gt; 0) and (not(string-length(.//hl7:encounter/hl7:id/@extension)) and not(string-length(.//hl7:encounter/hl7:id/@root))) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@extension,'|')) or contains($encounterIDs,concat('|',.//hl7:encounter/hl7:id/@root,'|'))]"/>
		
		<xsl:choose>
			<xsl:when test="($resultsC32NoData='1' or $resultsC37NoData='1') and $documentActionCode='XFRM'">
				<LabOrders>
					<xsl:apply-templates select="." mode="LabOrderActionCode"/>
				</LabOrders>
				<RadOrders>
					<xsl:apply-templates select="." mode="RadOrderActionCode"/>
				</RadOrders>
			</xsl:when>
			<xsl:when test="$resultsC32Entries or $resultsC37Entries">
				<LabOrders>
					<xsl:if test="isc:evaluate('varSet', 'LabOrderActionCodeDone', '0')"></xsl:if>
					<xsl:apply-templates select="$resultsC32Entries[(.//hl7:organizer) and (string-length(substring-after(.//hl7:procedure/hl7:code/hl7:originalText/hl7:reference/@value, '#')) or not(.//hl7:procedure/hl7:code/@nullFlavor))] | $resultsC37Entries[(.//hl7:organizer) and (string-length(substring-after(hl7:act/hl7:code/hl7:originalText/hl7:reference/@value, '#')) or not(hl7:act/hl7:code/@nullFlavor))]" mode="LabResults"/>
				</LabOrders>
				<RadOrders>
					<xsl:if test="isc:evaluate('varSet', 'RadOrderActionCodeDone', '0')"></xsl:if>
					<xsl:apply-templates select="$resultsC32Entries[(.//hl7:organizer) and (string-length(substring-after(.//hl7:procedure/hl7:code/hl7:originalText/hl7:reference/@value, '#')) or not(.//hl7:procedure/hl7:code/@nullFlavor))] | $resultsC37Entries[(.//hl7:organizer) and (string-length(substring-after(hl7:act/hl7:code/hl7:originalText/hl7:reference/@value, '#')) or not(hl7:act/hl7:code/@nullFlavor))]" mode="RadResults"/>
				</RadOrders>
				<xsl:if test="$enableOtherOrders = 1">
					<OtherOrders>
						<xsl:if test="isc:evaluate('varSet', 'OtherOrderActionCodeDone', '0')"></xsl:if>
						<xsl:apply-templates select="$resultsC32Entries[(.//hl7:organizer) and (string-length(substring-after(.//hl7:procedure/hl7:code/hl7:originalText/hl7:reference/@value, '#')) or not(.//hl7:procedure/hl7:code/@nullFlavor))] | $resultsC37Entries[(.//hl7:organizer) and (string-length(substring-after(hl7:act/hl7:code/hl7:originalText/hl7:reference/@value, '#')) or not(hl7:act/hl7:code/@nullFlavor))]" mode="OtherResults"/>
					</OtherOrders>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- Insert an order with corresponding Laboratory results-->
	<xsl:template match="*" mode="LabResults">
	
		<xsl:variable name="resultRootPath" select=".//hl7:organizer[hl7:templateId/@root = $resultOrganizerTemplateId or hl7:templateId/@root = $ihe-PCC-LabBatteryOrganizer]"/>
		<xsl:variable name="isLabResult"><xsl:apply-templates select="$resultRootPath" mode="IsLabResult"/></xsl:variable>
		
		<xsl:if test="$isLabResult = 1">
			<xsl:if test="isc:evaluate('varGet', 'LabOrderActionCodeDone')=0">
				<xsl:apply-templates select="." mode="LabOrderActionCode"/>
				<xsl:if test="isc:evaluate('varSet', 'LabOrderActionCodeDone', '1')"></xsl:if>
			</xsl:if>
			<xsl:apply-templates select="." mode="Result"><xsl:with-param name="elementName" select="'LabOrder'"/></xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<!-- Insert an order with corresponding Radiology results-->
	<xsl:template match="*" mode="RadResults">
	
		<xsl:variable name="resultRootPath" select=".//hl7:organizer[hl7:templateId/@root = $resultOrganizerTemplateId]"/>
		<xsl:variable name="isLabResult"><xsl:apply-templates select="$resultRootPath" mode="IsLabResult"/></xsl:variable>
		<xsl:variable name="isRadResult"><xsl:apply-templates select="$resultRootPath" mode="IsRadResult"><xsl:with-param name="paramIsLabResult" select="$isLabResult"/></xsl:apply-templates></xsl:variable>
				
		<xsl:if test="$isRadResult = 1">
			<xsl:if test="isc:evaluate('varGet', 'RadOrderActionCodeDone')=0">
				<xsl:apply-templates select="." mode="RadOrderActionCode"/>
				<xsl:if test="isc:evaluate('varSet', 'RadOrderActionCodeDone', '1')"></xsl:if>
			</xsl:if>
			<xsl:apply-templates select="." mode="Result"><xsl:with-param name="elementName" select="'RadOrder'"/></xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<!-- Insert an order with corresponding Other results-->
	<xsl:template match="*" mode="OtherResults">
	
		<xsl:variable name="resultRootPath" select=".//hl7:organizer[hl7:templateId/@root = $resultOrganizerTemplateId]"/>
		<xsl:variable name="isLabResult"><xsl:apply-templates select="$resultRootPath" mode="IsLabResult"/></xsl:variable>
		<xsl:variable name="isRadResult"><xsl:apply-templates select="$resultRootPath" mode="IsRadResult"><xsl:with-param name="paramIsLabResult" select="$isLabResult"/></xsl:apply-templates></xsl:variable>
				
		<xsl:if test="$isLabResult = 0 and $isRadResult = 0">
			<xsl:if test="isc:evaluate('varGet', 'OtherOrderActionCodeDone')=0">
				<xsl:apply-templates select="." mode="OtherOrderActionCode"/>
				<xsl:if test="isc:evaluate('varSet', 'OtherOrderActionCodeDone', '1')"></xsl:if>
			</xsl:if>
			<xsl:apply-templates select="." mode="Result"><xsl:with-param name="elementName" select="'OtherOrder'"/></xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="LabOrderActionCode">
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'LabOrder'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="*" mode="RadOrderActionCode">
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'RadOrder'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="*" mode="OtherOrderActionCode">
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'OtherOrder'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="*" mode="IsLabResult">
		<!-- Apply heuristics to determine if this is a lab result.
			
			IsLabResult provides the off-the-shelf criteria for
			determining is/is not a lab result.
			
			You may override the functionality of this template by
			creating the same template in ../../Site/ImportCustom.xsl
			and applying the logic that you desire.  If you create
			the custom template, then the version of the template
			here will not be used at all.
			 
			1. Is this a HITSP C37 / IHE XD-LAB report entry (templateId = 1.3.6.1.4.1.19376.1.3.1)?
			2. Is the observation explicitly marked as an IHE PCC Laboratory Observation (templateId = 1.3.6.1.4.1.19376.1.3.1.6)?
			3. Is there a reference range associated with the lab result?
			4. Is the lab result atomic (a collection of test items with specific values, rather than a text result)?
		-->
		<xsl:choose>
			<xsl:when test="parent::node()/hl7:templateId[@root = $ihe-PCC-LaboratoryReportEntry]">1</xsl:when>
			<xsl:when test="hl7:component/hl7:observation/hl7:templateId[@root = $ihe-PCC-LaboratoryObservation]">1</xsl:when>
			<xsl:when test="hl7:component/hl7:observation/hl7:referenceRange/hl7:observationRange">1</xsl:when>
			<!-- atomic result value has @value when xsi:type=PQ -->
			<xsl:when test="hl7:component/hl7:observation/hl7:value/@value">1</xsl:when>
			<!-- atomic result value has text() when xsi:type=ST -->
			<xsl:when test="string-length(normalize-space(hl7:component/hl7:observation/hl7:value/text()))">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="IsRadResult">
		<xsl:param name="paramIsLabResult" select="'0'"/>
		
		<!-- IsRadResult provides the off-the-shelf criteria for
			 determining is/is not a rad result. Basically it is
			 "if it's not a lab result, then it's a rad result".
			 
			 You may override the functionality of this template by
			 creating the same template in ../../Site/ImportCustom.xsl
			 and applying the logic that you desire.  If you create
			 the custom template, then the version of the template
			 here will not be used at all.
		-->
		<xsl:choose>
			<xsl:when test="$paramIsLabResult='0'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Determine if a Results section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $resultsC32Section or $resultsC37Section.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include results data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="IsNoDataSection-Results">
		<xsl:choose>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry/hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
