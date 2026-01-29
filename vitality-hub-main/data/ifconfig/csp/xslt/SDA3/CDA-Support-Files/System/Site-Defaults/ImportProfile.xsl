<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<xsl:variable name="generalImportConfiguration">
		<!--
			SDA Action Codes:
				A = Add or Update
				C = Clear (physical delete) all existing entries in the ECR
				D = Delete (physical delete) existing entries where SDA's ExternalId matches the inbound CDA's setId
				I = Inactivate all existing entries in the ECR
		-->
		<sdaActionCodes>
			<enabled>1</enabled>
			<overrideExternalId>0</overrideExternalId>
		</sdaActionCodes>
		
		<!-- The evaluation of diagnostic results to look for OtherOrders
			 incurs a significant performance cost that should be avoided
			 when not needed.  enableOtherOrders toggles that evaluation.
			 
			 It is possible for an order to be considered an OtherOrder
			 only when IsLabResult-site and IsRadResult-site have site-
			 specific logic that could cause an order to be considered
			 neither lab nor rad. Only when such logic is implemented
			 should enableOtherOrders be set to 1.
		-->
		<enableOtherOrders>0</enableOtherOrders>
		
		<!--
			concatRootAndNumericExtension is used during the parsing
			of hl7:representedOrganization/hl7:id when deriving facility
			information.  When concatRootAndNumericExtension equals 1,
			if hl7:representedOrganization/hl7:id @root is an OID and
			@extension is numeric, then @root and @extension are
			concatenated into one facility OID.
		-->
		<representedOrganizationId>
			<concatRootAndNumericExtension>0</concatRootAndNumericExtension>
		</representedOrganizationId>
		
		<!--
			narrativeImportMode is used when importing content from
			the section narrative, as opposed to the strucutured body.
			This general setting value is used when a field-specific
			value is not specified.
			1 = import as text, import both <br/> and narrative line feeds as line feeds
			2 = import as text, import <br/> as line feed, ignore narrative line feeds
		-->
		<narrativeImportMode>1</narrativeImportMode>
		
		<!--
			blockImportCTDCodeFromText is used to block the import of
			CDA string, narrative text, or originalText into an SDA
			CodeTableDetail Code property when the CDA @code attribute
			is not available.
			
			Long-standing import functionality has been to import from
			those items when @code is not present (i.e., @nullFlavor is
			present).  Setting this item to 1 will alter that behavior
			and will cause <Code/> to be imported if the CDA coded element
			is nullFlavor.
		-->
		<blockImportCTDCodeFromText>0</blockImportCTDCodeFromText>
	</xsl:variable>

	<xsl:variable name="admissionDiagnosesImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-HospitalAdmissionDiagnosis"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="advanceDirectivesImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-CodedAdvanceDirectives"/></sectionTemplateId>
	</xsl:variable>
	
	<xsl:variable name="allergiesImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-AllergiesAndOtherAdverseReactions"/></sectionTemplateId>
	</xsl:variable>
	
	<xsl:variable name="assessmentAndPlanImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-AssessmentAndPlan"/></sectionTemplateId>
	</xsl:variable>
	
	<xsl:variable name="careConsiderationsImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$other-ActiveHealth-CareConsiderationsSection"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="commentsImportConfiguration">
		<entryTemplateId><xsl:value-of select="$ihe-PCC-Comments"/></entryTemplateId>
	</xsl:variable>

	<xsl:variable name="dischargeDiagnosesImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-DischargeDiagnosis"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="dischargeMedicationsImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-HospitalDischargeMedications"/></sectionTemplateId>
		<pharmacyStatus>DISCHARGE</pharmacyStatus>
	</xsl:variable>

	<xsl:variable name="encountersImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-EncounterHistories"/></sectionTemplateId>
		<!-- 
			encounterTypeMaps maps CDA coded encounter type information
			(code and codeSystem) to values for the SDA EncounterType
			string property.
			
			encounterTypeMap XML element names and intended values:
			- CDACode          = Encounter Code from the CDA document.
			- CDACodeSystem    = codeSystem OID associated with CDAcode.
			- SDAEncounterType = Valid values are I, O, or E.
			
			This is an example of what the map may look like:
			
			<encounterTypeMaps>
				<encounterTypeMap>
					<CDACode>92202</CDACode>
					<CDACodeSystem>2.16.840.1.113883.6.12</CDACodeSystem>
					<SDAEncounterType>O</SDAEncounterType>
				</encounterTypeMap>
				<encounterTypeMap>
					<CDACode>99212</CDACode>
					<CDACodeSystem>2.16.840.1.113883.6.12</CDACodeSystem>
					<SDAEncounterType>I</SDAEncounterType>
				</encounterTypeMap>
			</encounterTypeMaps>
			
			To add your own mappings, copy and paste the encounterTypeMap
			section that is within the encounterTypeMaps section below to
			create new entries with your desired values.
		-->
		<encounterTypeMaps>
			<encounterTypeMap>
				<CDACode>code</CDACode>
				<CDACodeSystem>oid</CDACodeSystem>
				<SDAEncounterType>IOE</SDAEncounterType>
			</encounterTypeMap>
		</encounterTypeMaps>

		<!--
		healthFundImportMode controls if payers will be imported as encounter
		HealthFunds. Turn this off to avoid duplicating each payer in every
		encounter. See also memberEnrollmentImportMode.
		0 - do not import HealthFunds
		1 - import HealthFunds (default for backward compatibilty)
		-->
		<healthFundImportMode>1</healthFundImportMode>
	</xsl:variable>

	<xsl:variable name="familyHistoryImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-FamilyMedicalHistory"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="functionalStatusImportConfiguration">
		<sectionTemplateId><xsl:value-of select="'Not Supported'"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="immunizationsImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-Immunizations"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="medicalEquipmentImportConfiguration">
		<sectionTemplateId><xsl:value-of select="'Not Supported'"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="medicationInstructionsImportConfiguration">
		<entryTemplateId><xsl:value-of select="$ihe-PCC-PatientMedicationInstructions"/></entryTemplateId>
	</xsl:variable>

	<xsl:variable name="medicationsImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-Medications"/></sectionTemplateId>
		<pharmacyStatus>MEDICATIONS</pharmacyStatus>
	</xsl:variable>

	<xsl:variable name="medicationsAdministeredImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-SelectMedsAdministered"/></sectionTemplateId>
		<pharmacyStatus>ADMINISTERED</pharmacyStatus>
	</xsl:variable>

	<xsl:variable name="narrativeImportConfiguration">
		<!-- line wrap length; words are broken on whitespace only -->
		<wrapWidth>80</wrapWidth>

		<!-- case-sensitive phrases that will skip import if present (@nullFlavor sections are always skipped) 
			Use @mode="full" to do equality instead of a contains check
		-->
		<exclude>patient has no known</exclude>
		<exclude mode="full">Unknown.</exclude>
		<exclude mode="full">None recorded.</exclude>

		<!-- the following section narratives are imported by default because there they have no existing
				discrete hl7:entry import stylesheet or typically provide clinicial relevance without entries.
		Properties:
			templateId - required; if present the narrative for this section will be imported
			title      - recommended; override hl7:section/hl7:title value that is mapped to DocumentName (used for CV grouping)
			code       - optional; default LOINC hl7:section/hl7:code/@code and @displayName values that are mapped to DocumentType
			exclude    - optional; phrases that will skip import specific to this section 
		-->
		<section>
			<title>Admission Medication</title>
			<code code="42346-7" displayName="Medications on Admission"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.44" extension="2015-08-01"/>
		</section>
		<section> <!-- not part of CCDAv21 spec but supported by HealthShare -->
			<title>Admission Medication</title>
			<code code="42346-7" displayName="Medications on Admission"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.44.1" extension="2015-08-01"/>
		</section>
		<section>
			<title>Anesthesia</title>
			<code code="59774-0" displayName="Anesthesia"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.25" extension="2014-06-09"/>
		</section>
		<section>
			<title>Assessment and Plan</title>
			<code code="51847-2" displayName="Assessment and Plan"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.9" extension="2014-06-09"/>
		</section>
		<section>
			<title>Assessment</title>
			<code code="51848-0" displayName="Assessments"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.8"/>
		</section>
		<section>
			<title>Chief Complaint and Reason for Visit</title>
			<code code="46239-0" displayName="Chief Complaint and Reason for Visit"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.13"/>
		</section>
		<section>
			<title>Chief Complaint</title>
			<code code="10154-3" displayName="Chief Complaint"/>
			<templateId root="1.3.6.1.4.1.19376.1.5.3.1.1.13.2.1"/>
		</section>
		<section>
			<title>Complications</title>
			<code code="55109-3" displayName="Complications"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.37" extension="2015-08-01"/>
		</section>
		<section>
			<title>Course of Care</title>
			<code code="8648-8" displayName="Hospital Course"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.64"/>
		</section>
		<section>
			<title>Family History</title>
			<code code="10157-6" displayName="Family History"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.15" extension="2015-08-01"/>
		</section>
		<section>
			<title>Functional Status</title>
			<code code="47420-5" displayName="Functional Status"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.14" extension="2014-06-09"/>
		</section>
		<section>
			<title>General Status</title>
			<code code="10210-3" displayName="General Status"/>
			<templateId root="2.16.840.1.113883.10.20.2.5"/>
		</section>
		<section>
			<title>Goals</title>
			<code code="61146-7" displayName="Goals"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.60"/>
		</section>
		<section>
			<title>History of Present Illness</title>
			<code code="10164-2" displayName="History of Present Illness"/>
			<templateId root="1.3.6.1.4.1.19376.1.5.3.1.3.4"/>
		</section>
		<section>
			<title>Hospital Consultations</title>
			<code code="18841-7" displayName="Hospital Consultation"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.42"/>
		</section>
		<section>
			<title>Hospital Course</title>
			<code code="8648-8" displayName="Hospital Course"/>
			<templateId root="1.3.6.1.4.1.19376.1.5.3.1.3.5"/>
		</section>
		<section>
			<title>Hospital Discharge Physical</title>
			<code code="10184-0" displayName="Hospital Discharge Physical"/>
			<templateId root="1.3.6.1.4.1.19376.1.5.3.1.3.26"/>
		</section>
		<section>
			<title>Hospital Discharge Studies</title>
			<code code="11493-4" displayName="Hospital Discharge Studies Summary"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.16"/>
		</section>
		<section>
			<title>Instructions</title>
			<code code="69730-0" displayName="Instructions"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.45" extension="2014-06-09"/>
		</section>
		<section>
			<title>Interventions</title>
			<code code="62387-6" displayName="Interventions Provided"/>
			<templateId root="2.16.840.1.113883.10.20.21.2.3" extension="2015-08-01"/>
		</section>
		<section>
			<title>Medical (General) History</title>
			<code code="11329-0" displayName="Medical (General) History"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.39"/>
		</section>
		<section>
			<title>Medical Equipment</title>
			<code code="46264-8" displayName="Medical Equipment"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.23" extension="2014-06-09"/>
		</section>
		<section>
			<title>Mental Status</title>
			<code code="10190-7" displayName="Mental Status"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.56" extension="2015-08-01"/>
		</section>
		<section>
			<title>Nutrition</title>
			<code code="61144-2" displayName="Diet and nutrition"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.57"/>
		</section>
		<section>
			<title>Objective</title>
			<code code="61149-1" displayName="Objective"/>
			<templateId root="2.16.840.1.113883.10.20.21.2.1"/>
		</section>
		<section>
			<title>Operative Note Fluids</title>
			<code code="10216-0" displayName="Operative Note Fluids"/>
			<templateId root="2.16.840.1.113883.10.20.7.12"/>
		</section>
		<section>
			<title>Operative Note Surgical Procedure</title>
			<code code="10223-6" displayName="Operative Note Surgical Procedure"/>
			<templateId root="2.16.840.1.113883.10.20.7.14"/>
		</section>
		<section>
			<title>Past Medical History</title>
			<code code="11348-0" displayName="History of Past Illness"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.20" extension="2015-08-01"/>
		</section>
		<section>
			<title>Physical Exam</title>
			<code code="29545-1" displayName="Physical Findings"/>
			<templateId root="2.16.840.1.113883.10.20.2.10" extension="2015-08-01"/>
		</section>
		<section>
			<title>Plan of Treatment</title>
			<code code="18776-5" displayName="Plan of Treatment"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.10" extension="2014-06-09"/>
		</section>
		<section>
			<title>Planned Procedure</title>
			<code code="59772-4" displayName="Planned Procedure"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.30" extension="2014-06-09"/>
		</section>
		<section>
			<title>Postoperative Diagnosis</title>
			<code code="10218-6" displayName="Postoperative Diagnosis"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.35"/>
		</section>
		<section>
			<title>Postprocedure Diagnosis</title>
			<code code="59769-0" displayName="Postprocedure Diagnosis"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.36" extension="2015-08-01"/>
		</section>
		<section>
			<title>Preoperative Diagnosis</title>
			<code code="10219-4" displayName="Preoperative Diagnosis"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.34" extension="2015-08-01"/>
		</section>
		<section>
			<title>Procedure Description</title>
			<code code="29554-3" displayName="Procedure Description"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.27"/>
		</section>
		<section>
			<title>Procedure Disposition</title>
			<code code="59775-7" displayName="Procedure Disposition"/>
			<templateId root="2.16.840.1.113883.10.20.18.2.12"/>
		</section>
		<section>
			<title>Procedure Estimated Blood Loss</title>
			<code code="59770-8" displayName="Procedure Estimated Blood Loss"/>
			<templateId root="2.16.840.1.113883.10.20.18.2.9"/>
		</section>
		<section>
			<title>Procedure Findings</title>
			<code code="59776-5" displayName="Procedure Findings"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.28" extension="2015-08-01"/>
		</section>
		<section>
			<title>Procedure Implants</title>
			<code code="59771-6" displayName="Procedure Implants"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.40"/>
		</section>
		<section>
			<title>Procedure Indications</title>
			<code code="59768-2" displayName="Procedure Indications"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.29" extension="2014-06-09"/>
		</section>
		<section>
			<title>Procedure Specimens Taken</title>
			<code code="59773-2" displayName="Procedure Specimens Taken"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.31"/>
		</section>
		<section>
			<title>Reason for Referral</title>
			<code code="42349-1" displayName="Reason for Referral"/>
			<templateId root="1.3.6.1.4.1.19376.1.5.3.1.3.1" extension="2014-06-09"/>
		</section>
		<section>
			<title>Reason for Visit</title>
			<code code="29299-5" displayName="Reason for Visit"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.12"/>
		</section>
		<section>
			<title>Review of Systems</title>
			<code code="10187-3" displayName="Review of Systems"/>
			<templateId root="1.3.6.1.4.1.19376.1.5.3.1.3.18"/>
		</section>
		<section>
			<title>Subjective</title>
			<code code="61150-9" displayName="Subjective"/>
			<templateId root="2.16.840.1.113883.10.20.21.2.2"/>
		</section>
		<section>
			<title>Surgical Drains</title>
			<code code="11537-8" displayName="Surgical Drains"/>
			<templateId root="2.16.840.1.113883.10.20.7.13"/>
		</section>
		<section>
			<title>Care Teams</title>
			<code code="85847-2" displayName="Patient Care team information"/>
			<templateId root="2.16.840.1.113883.10.20.22.2.500" extension="2022-06-01"/>
		</section>
	</xsl:variable>

	<xsl:variable name="notesImportConfiguration">
		<!-- 
			Limit note import to sections matching the given LOINC codes
			For example, to only import notes mandated by the 2015 Cures Act:
			<includeSections>|11488-4|18842-5|34117-2|28570-0|11506-3|18748-4|11502-2|11526-1|</includeSections>
		-->
		<includeSections></includeSections>

		<!--
			Exclude note import from sections matching the given LOINC codes
		-->
		<excludeSections></excludeSections>

		<!--
			Always import note entries matching the given LOINC codes even if corresponding section isn't imported
		-->
		<includeNotes></includeNotes>

		<!--
			Never import note entries matching the given LOINC codes even if corresponding section is imported
		-->
		<excludeNotes></excludeNotes>
	</xsl:variable>

	<xsl:variable name="pastIllnessImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-HistoryOfPastIllness"/></sectionTemplateId>
	</xsl:variable>
	
	<xsl:variable name="payersImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-Payers"/></sectionTemplateId>
		<entryTemplateId><xsl:value-of select="$ihe-PCC_CDASupplement-CoverageEntry"/></entryTemplateId>

		<!--
		memberEnrollmentImportMode controls if payers will be imported as MemberEnrollment.
		See also healthFundImportMode.
		0 - do not import MemberEnrollment (default)
		1 - import MemberEnrollment
		-->
		<memberEnrollmentImportMode>0</memberEnrollmentImportMode>
	</xsl:variable>

	<xsl:variable name="payerPlanDetailsImportConfiguration">
		<entryTemplateId><xsl:value-of select="$ihe-PCC_CDASupplement-PayerEntry"/></entryTemplateId>
	</xsl:variable>

	<xsl:variable name="planImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-CarePlan"/></sectionTemplateId>
		<effectiveTimeCenter>0</effectiveTimeCenter>
	</xsl:variable>

	<xsl:variable name="presentIllnessImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-HistoryOfPresentIllness"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="problemsImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-ActiveProblems"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="proceduresImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-ListOfSurgeries"/></sectionTemplateId>
	</xsl:variable>

	<xsl:variable name="purposeImportConfiguration">
		<sectionTemplateId><xsl:value-of select="'Not Supported'"/></sectionTemplateId>
	</xsl:variable>

 	<!-- resultOrganizerTemplateId is used to help select the correct -->
 	<!-- hl7:organizer within a given results entry, in case there is -->
 	<!-- more than one. One alternate value that might be assigned to -->
 	<!-- this variable is $ihe-PCC-LabBatteryOrganizer.               -->
	<xsl:variable name="resultsImportConfiguration">
		<sectionC32TemplateId><xsl:value-of select="$ihe-PCC-CodedResults"/></sectionC32TemplateId>
		<sectionC37TemplateId><xsl:value-of select="$ihe-PCC-LaboratorySpecialty"/></sectionC37TemplateId>
		<resultOrganizerTemplateId><xsl:value-of select="$hl7-CCD-ResultOrganizer"/></resultOrganizerTemplateId>
		<orderItemDefaultCode></orderItemDefaultCode>
		<orderItemDefaultDescription></orderItemDefaultDescription>
	</xsl:variable>

	<xsl:variable name="socialHistoryImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-SocialHistory"/></sectionTemplateId>

		<!--
		patientGenderIdentityImportMode controls whether gender identity SocialHistory entries
		will be mapped to Patient:GenderIdentity. 
		0 - gender identity observations will not be mapped to Patient:GenderIdentity (default)
		1 - gender identity observations will be mapped to Patient:GenderIdentity
		-->
		<patientGenderIdentityImportMode>0</patientGenderIdentityImportMode>

		<!--
		socialHistoryGenderIdentityImportMode controls if gender identity SocialHistory entries
		will be translated over into SDA3. Turn this off to avoid duplicate infromation with
		Patient:GenderIdentity. See also patientGenderIdentityImportMode.
		0 - gender identity observations will be excluded from SocialHistory translation
		1 - gender identity obesrvations will be translated into SocialHistory (default for backward compatilbity)
		-->
		<socialHistoryGenderIdentityImportMode>1</socialHistoryGenderIdentityImportMode>
	</xsl:variable>

	<xsl:variable name="vitalSignsImportConfiguration">
		<sectionTemplateId><xsl:value-of select="$ihe-PCC-CodedVitalSigns"/></sectionTemplateId>
	</xsl:variable>
 
 </xsl:stylesheet>
