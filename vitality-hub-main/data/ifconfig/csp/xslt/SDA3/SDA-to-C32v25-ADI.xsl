<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HITSP.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-IHE.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
	<xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
	<xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/Functions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Common/Variables.xsl"/>
	<xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>

	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AdvanceDirective.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AllergyAndDrugSensitivity.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/AssessmentAndPlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Comment.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Condition.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/EncompassingEncounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Encounter.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/HealthcareProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Immunization.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/InformationSource.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/InsuranceProvider.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/LanguageSpoken.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Medication.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/PersonalInformation.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Procedure.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Result.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/Support.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Entry-Modules/VitalSign.xsl"/>

	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AdvanceDirectives.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AllergiesAndOtherAdverseReactions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/AssessmentAndPlan.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/DiagnosticResults.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/Encounters.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/Immunizations.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/Medications.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/Payers.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/PlanOfCare.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/ProblemList.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/ProceduresAndInterventions.xsl"/>
	<xsl:include href="CDA-Support-Files/Export/Section-Modules/VitalSigns.xsl"/>
	
	<xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>

	<!--
		This version of the SDA to C32v25 transform is for use only with a specific use
		case.  The SDA input to this transform is expected to have been the output of a
		CDA to SDA transform that added the non-persistent AdditionalDocumentInfo XML
		block to the SDA.  This transform expects SDA AdditionalDocumentInfo to hold a
		reconstituted version the CDA header data from the CDA document.
		
		This SDA to C32v25 transform is completely dependent on AdditionalDocumentInfo
		to be the source of CDA header data, except for those items (realmCode, typeId,
		templateId, code, languageCode) that should never vary for this document type.
	-->
	<xsl:template match="/Container">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
			<!-- Begin CDA Header -->
			<realmCode code="US"/>
			<typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
			
			<xsl:call-template name="templateIds-C32Header"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='id']" mode="fn-Document-Element"/>
			
			<code code="34133-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC" displayName="Summarization of Episode Note"/>
			
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='title']" mode="fn-Document-Element"/>
			
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='effectiveTime']" mode="fn-Document-TS"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='confidentialityCode']" mode="fn-Document-Element"/>
			<languageCode code="en-US"/>
			
			<!-- setId, versionNumber and copyTime have no SDA source, but might be found in AdditionalDocumentInfo/HeaderInfo. -->
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='setId']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='versionNumber']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='copyTime']" mode="fn-Document-Element"/>

			<!-- Person Information module - recordTarget/patientRole -->
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='recordTarget']" mode="fn-Document-Element"/>
			
			<!-- Information Source module - author, informant, custodian, legalAuthenticator and more -->
			<!-- dataEnterer, informationRecipient and authenticator have no SDA source, but might be found in AdditionalDocumentInfo/HeaderInfo. -->
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='author']" mode="fn-Document-Author"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='dataEnterer']" mode="fn-Document-DataEnterer"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='informant']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='custodian']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='informationRecipient']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='legalAuthenticator']" mode="fn-Document-Authenticator"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='authenticator']" mode="fn-Document-Authenticator"/>
			
			<!-- Support module	- participant -->
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='participant']" mode="fn-Document-Element"/>

			<!-- inFulfillmentOf has no SDA source, but might be found in AdditionalDocumentInfo/HeaderInfo. -->
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='inFulfillmentOf']" mode="fn-Document-Element"/>
			
			<!-- Healthcare Providers module - documentationOf -->
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='documentationOf']" mode="fn-Document-Element"/>
			
			<!-- relatedDocument and authorization have no SDA source, but might be found in AdditionalDocumentInfo/HeaderInfo. -->
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='relatedDocument']" mode="fn-Document-Element"/>
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='authorization']" mode="fn-Document-Element"/>
			
			<!-- Encompassing Encounter module - componentOf -->
			<xsl:apply-templates select="AdditionalDocumentInfo/HeaderInfo/Element[Name='componentOf']" mode="fn-Document-Element"/>
			
			<!-- Additional custom export for document header -->
			<xsl:apply-templates select="." mode="ExportCustom-DocumentHeader"/>
					
			<!-- End CDA Header -->	
			<!-- Begin CCD Body -->
			<component>
				<structuredBody>
					<!-- Payers -->
					<xsl:apply-templates select="." mode="payers"/>
					
					<!-- Advance Directives module -->
					<xsl:apply-templates select="." mode="advanceDirectives"/>
					
					<!-- Problem List module -->
					<xsl:apply-templates select="." mode="problems">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Allergies -->
					<xsl:apply-templates select="." mode="allergies">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Medications module -->
					<xsl:apply-templates select="." mode="medications">
						<xsl:with-param name="sectionRequired" select="'1'"/>
					</xsl:apply-templates>
					
					<!-- Immunizations module -->
					<xsl:apply-templates select="." mode="immunizations"/>
					
					<!-- Vital Signs module -->
					<xsl:apply-templates select="." mode="vitalSigns"/>
					
					<!-- Procedures and Interventions module -->
					<xsl:apply-templates select="." mode="procedures"/>

					<!-- Plan of Care module -->
					<xsl:apply-templates select="." mode="planOfCare"/>
					
					<!-- Assessment and Plan module -->
					<xsl:apply-templates select="." mode="assessmentAndPlan"/>
					
					<!-- Encounters module -->
					<xsl:apply-templates select="." mode="encounters"/>

					<!-- Results module -->
					<xsl:apply-templates select="." mode="results-C32"/>

					<!-- Custom export -->
					<xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
				</structuredBody>
			</component>
			<!-- End CCD Body -->
		</ClinicalDocument>
	</xsl:template>
	
	<xsl:template name="templateIds-C32Header">
		<xsl:if test="string-length($hl7-CDA-CDAR2GeneralHeader)"><templateId root="{$hl7-CDA-CDAR2GeneralHeader}"/></xsl:if>
		<xsl:if test="string-length($hl7-CCD-RegisteredTemplatesRoot)"><templateId root="{$hl7-CCD-RegisteredTemplatesRoot}"/></xsl:if>
		<xsl:if test="string-length($hl7-CCD-GeneralHeader)"><templateId root="{$hl7-CCD-GeneralHeader}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level1Declaration)"><templateId root="{$hl7-CDA-Level1Declaration}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level2Declaration)"><templateId root="{$hl7-CDA-Level2Declaration}"/></xsl:if>
		<xsl:if test="string-length($hl7-CDA-Level3Declaration)"><templateId root="{$hl7-CDA-Level3Declaration}"/></xsl:if>
		<xsl:if test="string-length($hitsp-C32-SummaryDocument)"><templateId root="{$hitsp-C32-SummaryDocument}"/></xsl:if>
		<xsl:if test="string-length($ihe-MedicalDocumentsSpecification)"><templateId root="{$ihe-MedicalDocumentsSpecification}"/></xsl:if>
		<xsl:if test="string-length($ihe-MedicalSummarySpecification)"><templateId root="{$ihe-MedicalSummarySpecification}"/></xsl:if>
		<xsl:if test="string-length($ihe-PHRExtractSpecification)"><templateId root="{$ihe-PHRExtractSpecification}"/></xsl:if>
		<xsl:if test="string-length($ihe-PHRUpdateSpecification)"><templateId root="{$ihe-PHRUpdateSpecification}"/></xsl:if>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-DocumentHeader">
	</xsl:template>

	<!-- This empty template may be overridden with custom logic. -->
	<xsl:template match="*" mode="ExportCustom-ClinicalDocument">
	</xsl:template>
</xsl:stylesheet>
