<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com"
  xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
  <xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-HL7.xsl"/>
  <xsl:include href="CDA-Support-Files/System/Templates/TemplateIdentifiers-CCDA.xsl"/>
  <xsl:include href="CDA-Support-Files/System/OIDs/OIDs-InterSystems.xsl"/>
  <xsl:include href="CDA-Support-Files/System/OIDs/OIDs-Other.xsl"/>
  <xsl:include href="CDA-Support-Files/System/Common/Functions.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Functions.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Variables.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Common/CCDAv21/Narrative.xsl"/>
  <xsl:include href="CDA-Support-Files/Site/Variables.xsl"/>

  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AdvanceDirective.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AllergyAndDrugSensitivity.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Assessment.xsl"/>  
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AssessmentAndPlan.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/AuthorParticipation.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Comment.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Condition.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/EncompassingEncounter.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Encounter.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/FamilyHistory.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/FunctionalStatus.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Goals.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HealthConcerns.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HealthcareProvider.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/HistoryOfPresentIllness.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Immunization.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/InformationSource.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/InsuranceProvider.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/LanguageSpoken.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Medication.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Note.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PersonalInformation.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PlanOfTreatment.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/PriorityPreference.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Procedure.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Result.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/SocialHistory.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/Support.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Entry-Modules/CCDAv21/VitalSign.xsl"/>

  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/AdvanceDirectives.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/AllergiesAndOtherAdverseReactions.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Assessments.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/AssessmentAndPlan.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/DiagnosticResults.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Encounters.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/FamilyHistory.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/FunctionalStatus.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HealthConcerns.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HistoryOfPresentIllness.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HistoryOfPastIllness.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/HospitalDischargeInstructions.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Immunizations.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Medications.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Notes.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/Payers.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/PlanOfTreatment.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/ProblemList.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/ProceduresAndInterventions.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/SocialHistory.xsl"/>
  <xsl:include href="CDA-Support-Files/Export/Section-Modules/CCDAv21/VitalSigns.xsl"/>

  <xsl:include href="CDA-Support-Files/Site/OutputEncoding.xsl"/>

  <xsl:template match="/Container">
    <ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc">
      <!-- Begin CDA Header -->
      <realmCode code="US"/>
      <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>

      <xsl:apply-templates select="." mode="fn-templateId-USRealmHeader"/>

      <xsl:apply-templates select="." mode="templateId-CCDHeader"/>

      <xsl:apply-templates select="Patient" mode="fn-id-Document"/>

      <code code="34133-9" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Summarization of Episode Note"/>

      <xsl:apply-templates select="." mode="fn-title-forDocument">
        <xsl:with-param name="title1">Patient Summary Document</xsl:with-param>
      </xsl:apply-templates>

      <effectiveTime value="{$currentDateTime}"/>
      <xsl:apply-templates mode="document-confidentialityCode" select="."/>
      <languageCode code="en-US"/>

      <!-- Person Information module -->
      <xsl:apply-templates select="Patient" mode="ePI-personInformation"/>

      <!-- Information Source module -->
      <xsl:apply-templates select="Patient" mode="eIS-informationSource"/>

      <!-- Healthcare Providers module -->
      <xsl:apply-templates select="Patient" mode="eHP-healthcareProviders"/>

      <!--
				Encompassing Encounter module
				
				Export only if requested via $encompassingEncNum and $encompassingEncOrg.
			-->
      <xsl:variable name="encompassingEncNum">
        <xsl:apply-templates select="." mode="fn-encompassingEncounterNumber"/>
      </xsl:variable>
      <xsl:variable name="encompassingEncOrg">
        <xsl:apply-templates select="." mode="fn-encompassingEncounterOrganization"/>
      </xsl:variable>
      <xsl:if test="string-length($encompassingEncNum) and string-length($encompassingEncOrg)">
        <xsl:apply-templates
          select="Encounters/Encounter[(EncounterNumber/text() = $encompassingEncNum) and (HealthCareFacility/Organization/Code/text() = $encompassingEncOrg)]"
          mode="eEE-encompassingEncounter">
          <xsl:with-param name="clinicians" select="'|DIS|ATND|ADM|CON|REF|'"/>
        </xsl:apply-templates>
      </xsl:if>

      <!-- End CDA Header -->
      <!-- Begin CCD Body -->
      <component>
        <structuredBody>
          <!-- Allergies -->
          <xsl:apply-templates select="." mode="sAOAR-allergies">
            <xsl:with-param name="sectionRequired" select="'1'"/>
            <xsl:with-param name="entriesRequired" select="'1'"/>
          </xsl:apply-templates>

          <!-- Medications module -->
          <xsl:apply-templates select="." mode="sM-medications">
            <xsl:with-param name="sectionRequired" select="'1'"/>
            <xsl:with-param name="entriesRequired" select="'1'"/>
          </xsl:apply-templates>

          <!-- Problem List module -->
          <xsl:apply-templates select="." mode="sPL-problems">
            <xsl:with-param name="sectionRequired" select="'1'"/>
            <xsl:with-param name="entriesRequired" select="'1'"/>
          </xsl:apply-templates>

          <!-- Procedures and Interventions module -->
          <xsl:apply-templates select="." mode="sPAI-procedures">
            <xsl:with-param name="sectionRequired" select="'1'"/>
            <xsl:with-param name="entriesRequired" select="'1'"/>
          </xsl:apply-templates>

          <!-- Results module -->
          <xsl:apply-templates select="." mode="sDR-results">
            <xsl:with-param name="sectionRequired" select="'1'"/>
            <xsl:with-param name="entriesRequired" select="'1'"/>
          </xsl:apply-templates>

          <!-- Assessment module -->
          <xsl:apply-templates select="." mode="sA-assessments"/>

          <!-- Advance Directives module -->
          <xsl:apply-templates select="." mode="sAD-advanceDirectives"/>

          <!-- Encounters module -->
          <xsl:apply-templates select="." mode="sE-encounters"/>

          <!-- Family History module -->
          <xsl:apply-templates select="." mode="sFH-familyHistory"/>

          <!-- Functional Status module -->
          <xsl:apply-templates select="." mode="sFS-functionalStatus"/>

          <!-- Immunizations module -->
          <xsl:apply-templates select="." mode="sIm-immunizations"/>

          <!-- Payers -->
          <xsl:apply-templates select="." mode="sP-payers"/>

          <!-- Plan of Treatment module -->
          <xsl:apply-templates select="." mode="sPOT-planOfTreatment"/>

          <!-- Assessment and Plan module-->
          <xsl:apply-templates select="." mode="sANP-assessmentAndPlan"/>

          <!-- Social History module -->
          <xsl:apply-templates select="." mode="sSH-socialHistory">
            <xsl:with-param name="sectionRequired" select="'1'"/>
          </xsl:apply-templates>

          <!-- Vital Signs module -->
          <xsl:apply-templates select="." mode="sVS-vitalSigns">
            <xsl:with-param name="sectionRequired" select="'1'"/>
            <xsl:with-param name="entriesRequired" select="'1'"/>
          </xsl:apply-templates>

          <!-- Hospital Discharge Instructions module -->
          <xsl:apply-templates select="." mode="sHDI-dischargeInstructions"/>

          <!-- Health Concerns module -->
          <xsl:apply-templates select="." mode="sHC-HealthConcerns"/>

          <!-- Notes module -->
          <xsl:apply-templates select="." mode="sN-notes"/>

          <!-- standalone structured narratives -->
          <xsl:apply-templates mode="narrative-export-sections" select=".">
            <xsl:with-param name="templates">
              <item root="{$ccda-MedicalEquipmentSection}"/>
              <item root="{$ccda-MentalStatusSection}"/>
              <item root="{$ccda-NutritionSection}"/>
              <item root="{$ccda-CareTeamsSection}"/>
            </xsl:with-param>
          </xsl:apply-templates>

          <!-- Custom export -->
          <xsl:apply-templates select="." mode="ExportCustom-ClinicalDocument"/>
        </structuredBody>
      </component>
      <!-- End CCD Body -->
    </ClinicalDocument>
  </xsl:template>

  <xsl:template match="Container" mode="templateId-CCDHeader">
    <templateId root="{$ccda-ContinuityOfCareCCD}"/>
    <templateId root="{$ccda-ContinuityOfCareCCD}" extension="2015-08-01"/>
  </xsl:template>

  <!-- confidentialityCode may be overriden by stylesheets that import this one -->
  <xsl:template match="Container" mode="document-confidentialityCode">
    <confidentialityCode nullFlavor="{$confidentialityNullFlavor}"/>
  </xsl:template>

  <!-- This empty template may be overridden with custom logic. -->
  <xsl:template match="Container" mode="ExportCustom-ClinicalDocument"> </xsl:template>
  
</xsl:stylesheet>