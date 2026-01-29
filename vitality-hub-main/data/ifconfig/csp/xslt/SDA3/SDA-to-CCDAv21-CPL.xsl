<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-CCDA.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Narrative.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AuthorParticipation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/EncompassingEncounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/EntryReference.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/FamilyHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Fulfillment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Goals.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HealthConcerns.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HistoryOfPresentIllness.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Immunization.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Interventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Note.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Outcomes.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PlanOfTreatment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PriorityPreference.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Result.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/SocialHistory.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/VitalSign.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HealthConcerns.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Goals.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Interventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Outcomes.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Notes.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>
	
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:apply-templates select="." mode="fn-templateId-USRealmHeader"/>		
				
			<xsl:apply-templates select="." mode="templateId-CPLHeader"/>

			<xsl:choose>
				<xsl:when test="CarePlans/CarePlan[1]/ExternalId">
					<xsl:apply-templates select="." mode="fn-id-External-CarePlan">
			          <xsl:with-param name="externalId" select="CarePlans/CarePlan[1]/ExternalId"/>
			        </xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="Patient" mode="fn-id-Document"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--For 15.03, Care Plan document's code is fixed and hard-coded.
			It is unclear whether this code will be used to represent different types of Care Plan. 
			And this code is imported to HS.SDA3.CarePlan Type property for 15.03. 
			This will be modified accordingly when the C-CDA2.1 specs are clear about what to use to represent 
			differrent types of Care Plan.-->
			<code code="52521-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Care Plan"/>			

			<xsl:apply-templates select="." mode="fn-title-forDocument">
				<xsl:with-param name="title1">Care Plan</xsl:with-param>
			</xsl:apply-templates>
			
			<effectiveTime value="{$currentDateTime}"/>
			<xsl:apply-templates mode="document-confidentialityCode" select="."/>
			
			<languageCode code="en-US"/>
			
			<xsl:apply-templates select="CarePlans/CarePlan[1]" mode="versionNumber-CPLHeader" />

			<!-- Person Information module -->
			<xsl:apply-templates select="Patient" mode="ePI-personInformation"/>		
			
			<!-- Information Source module -->
			<xsl:apply-templates select="Patient" mode="eIS-informationSource">
				<xsl:with-param name="isCarePlan" select="true()"/>
			</xsl:apply-templates>
						
			<documentationOf>
				<serviceEvent classCode="PCPR">
					<xsl:apply-templates select="CarePlans/CarePlan[1]" mode="fn-effectiveTime-FromTo" />
					<xsl:apply-templates select="CarePlans/CarePlan[1]/Providers/DocumentProvider/Provider" mode="fn-performer-carePlanProvider" />
				</serviceEvent>
			</documentationOf>

			<!--
				Encompassing Encounter module
				
				Limit cardinality to 1. 
			-->			
			<xsl:apply-templates select="Encounters/Encounter[1]" mode="eEE-encompassingEncounter">
				<xsl:with-param name="clinicians" select="'|DIS|ATND|ADM|CON|REF|'"/>
			</xsl:apply-templates>				

			<!-- End CDA Header -->
			<!-- Begin CCD Body -->
			<component>
				<structuredBody>
					<!-- Health Concerns module -->
					<xsl:apply-templates select="." mode="sHC-HealthConcerns">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates> 

					<!-- Goals module -->
					<xsl:apply-templates select="." mode="sG-Goals">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates> 

					<!-- Interventions module -->
					<xsl:apply-templates select="." mode="sIn-Interventions">
						<xsl:with-param name="sectionRequired" select="'0'"/>
					</xsl:apply-templates> 

					<!-- Health Status and Outcomes module -->
					<xsl:apply-templates select="." mode="sHSO-HealthStatusAndOutcomes">
						<xsl:with-param name="sectionRequired" select="'0'"/>
					</xsl:apply-templates> 

					<!-- Notes module -->
					<xsl:apply-templates select="." mode="sN-notes"/>
					
					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template match="*" mode="templateId-CPLHeader">
		<templateId root="{$ccda-CarePlan}"/>		
		<templateId root="{$ccda-CarePlan}" extension="2015-08-01"/>
	</xsl:template>
	
	<xsl:template match="CarePlan" mode="versionNumber-CPLHeader" >
		<xsl:if test="string-length(Version/text()) > 0 and string-length(SetId/text()) > 0">
			<setId><xsl:attribute name="root"><xsl:value-of select="SetId/text()" /></xsl:attribute></setId>
			<versionNumber><xsl:attribute name="value"><xsl:value-of select="Version/text()" /></xsl:attribute></versionNumber>
		</xsl:if>
	</xsl:template>

	<!-- confidentialityCode may be overriden by stylesheets that import this one -->
	<xsl:template mode="document-confidentialityCode" match="Container">
		<confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
	</xsl:template>

	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
