<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sPOT-PlanOfTreatmentSection">
		<!-- we keep PlanOfCare in the templateId names for compatibility with 1.1 transforms -->
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-PlanOfCareSection)" mode="sPOT-PlanOfTreatmentSectionEntries"/>
	</xsl:template>

	<xsl:template match="*" mode="sPOT-PlanOfTreatmentSection-Orders">
		<xsl:for-each select="key('sectionsByRoot',$ccda-PlanOfCareSection)">
			<xsl:apply-templates select="hl7:entry[hl7:observation/hl7:templateId/@root=$ccda-PlanOfCareActivityObservation and not(.//@negationInd='true')]" mode="ePOT-paramName-Orders"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="sPOT-PlanOfTreatmentSection-Referrals">
		<xsl:for-each select="key('sectionsByRoot',$ccda-PlanOfCareSection)">
			<xsl:apply-templates select="hl7:entry[hl7:encounter/hl7:templateId/@root=$ccda-PlanOfCareActivityEncounter and hl7:encounter/@moodCode='RQO' and not(.//@negationInd='true')]" mode="ePOT-Referrals"/>
		</xsl:for-each>
	</xsl:template>
	

	<xsl:template match="*" mode="sPOT-Goals">
		<xsl:for-each select="key('sectionsByRoot',$ccda-PlanOfCareSection)">
			<xsl:if test="hl7:entry/hl7:observation/hl7:templateId[@root=$ccda-GoalObservation]">
				<Goals>
					<xsl:apply-templates select="hl7:entry/hl7:observation[hl7:templateId/@root=$ccda-GoalObservation and not(.//@negationInd='true')]" mode="ePOT-Goal"/>
				</Goals>
			</xsl:if>			
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="*" mode="sPOT-PlanOfTreatmentSection-Documents">
			<xsl:if test="key('sectionsByRoot',$ccda-PlanOfCareSection)">
				<Documents>	
					<xsl:apply-templates select="hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root=$ccda-PlanOfCareSection and hl7:entry/hl7:act/hl7:templateId/@root=$ccda-Instructions and not(.//@negationInd='true')]" mode="ePOT-Document-Instruction"/>				
				</Documents>	
			</xsl:if>
	</xsl:template>	
		
	<xsl:template match="hl7:section" mode="sPOT-PlanOfTreatmentSectionEntries">
		<xsl:variable name="isNoDataSection"><xsl:apply-templates select="." mode="sPOT-IsNoDataSection-Plan"/></xsl:variable>
		
		<xsl:if test="$isNoDataSection='0'">
			<xsl:apply-templates select="hl7:entry[hl7:substanceAdministration/hl7:templateId/@root=$ccda-PlanOfCareActivitySubstanceAdministration and not(.//@negationInd='true')]" mode="ePOT-Medications"/>
			<xsl:apply-templates select="hl7:entry[hl7:encounter/hl7:templateId/@root=$ccda-PlanOfCareActivityEncounter and hl7:encounter/@moodCode='INT' and not(.//@negationInd='true')]" mode="ePOT-Appointments"/>
			<xsl:apply-templates select="hl7:entry[hl7:procedure/hl7:templateId/@root=$ccda-PlanOfCareActivityProcedure and not(.//@negationInd='true')]" mode="ePOT-Procedures"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="sPOT-PlanOfTreatment">
		<!-- currently UNUSED -->
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Order'"/>
			<xsl:with-param name="actionScope" select="'OTH'"/>
		</xsl:call-template>
		
		<xsl:apply-templates select="hl7:observation[not(.//@negationInd='true')]" mode="ePOT-Plan"/>
	</xsl:template>
	
	<!--
		Determine if the Plan section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $planSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include plan data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sPOT-IsNoDataSection-Plan">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry[not(.//@negationInd='true')])=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>