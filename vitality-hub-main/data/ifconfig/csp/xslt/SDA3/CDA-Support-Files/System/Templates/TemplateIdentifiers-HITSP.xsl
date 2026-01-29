<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<!-- HITSP Document Templates -->
	<xsl:variable name="hitsp-C28-EmergencyCareSummary">2.16.840.1.113883.3.88.11.28</xsl:variable>
	<xsl:variable name="hitsp-C32-SummaryDocument">2.16.840.1.113883.3.88.11.32.1</xsl:variable>
	<xsl:variable name="hitsp-C37-LabReportDocument">2.16.840.1.113883.3.88.11.37</xsl:variable>
	<xsl:variable name="hitsp-C48-ReferralSummary">2.16.840.1.113883.3.88.11.48.1</xsl:variable>
	<xsl:variable name="hitsp-C48-DischargeSummary">2.16.840.1.113883.3.88.11.48.2</xsl:variable>
	<xsl:variable name="hitsp-C78-ImmunizationDocument">2.16.840.1.113883.3.88.11.78</xsl:variable>
	<xsl:variable name="hitsp-C84-ConsultationNote">2.16.840.1.113883.3.88.11.84.1</xsl:variable>
	<xsl:variable name="hitsp-C84-HistoryAndPhysicalNote">2.16.840.1.113883.3.88.11.84.2</xsl:variable>

	<!-- HITSP CDA Section Templates -->
	<xsl:variable name="hitsp-CDA-PayersSection">2.16.840.1.113883.3.88.11.83.101.1</xsl:variable>
	<xsl:variable name="hitsp-CDA-AllergiesAndOtherAdverseReactionsSection">2.16.840.1.113883.3.88.11.83.102</xsl:variable>
	<xsl:variable name="hitsp-CDA-ProblemListSection">2.16.840.1.113883.3.88.11.83.103</xsl:variable>
	<xsl:variable name="hitsp-CDA-HistoryOfPastIllnessSection">2.16.840.1.113883.3.88.11.83.104</xsl:variable>
	<xsl:variable name="hitsp-CDA-ChiefComplaintSection">2.16.840.1.113883.3.88.11.83.105</xsl:variable>
	<xsl:variable name="hitsp-CDA-ReasonForReferralSection">2.16.840.1.113883.3.88.11.83.106</xsl:variable>
	<xsl:variable name="hitsp-CDA-HistoryOfPresentIllnessSection">2.16.840.1.113883.3.88.11.83.107</xsl:variable>
	<xsl:variable name="hitsp-CDA-ListOfSurgeriesSection">2.16.840.1.113883.3.88.11.83.108</xsl:variable>
	<xsl:variable name="hitsp-CDA-FunctionalStatusSection">2.16.840.1.113883.3.88.11.83.109</xsl:variable>
	<xsl:variable name="hitsp-CDA-HospitalAdmissionDiagnosisSection">2.16.840.1.113883.3.88.11.83.110</xsl:variable>
	<xsl:variable name="hitsp-CDA-DischargeDiagnosisSection">2.16.840.1.113883.3.88.11.83.111</xsl:variable>
	<xsl:variable name="hitsp-CDA-MedicationsSection">2.16.840.1.113883.3.88.11.83.112</xsl:variable>
	<xsl:variable name="hitsp-CDA-AdmissionMedicationsHistorySection">2.16.840.1.113883.3.88.11.83.113</xsl:variable>
	<xsl:variable name="hitsp-CDA-HospitalDischargeMedicationsSection">2.16.840.1.113883.3.88.11.83.114</xsl:variable>
	<xsl:variable name="hitsp-CDA-MedicationsAdministeredSection">2.16.840.1.113883.3.88.11.83.115</xsl:variable>
	<xsl:variable name="hitsp-CDA-AdvanceDirectivesSection">2.16.840.1.113883.3.88.11.83.116</xsl:variable>
	<xsl:variable name="hitsp-CDA-ImmunizationsSection">2.16.840.1.113883.3.88.11.83.117</xsl:variable>
	<xsl:variable name="hitsp-CDA-PhysicalExaminationSection">2.16.840.1.113883.3.88.11.83.118</xsl:variable>
	<xsl:variable name="hitsp-CDA-VitalSignsSection">2.16.840.1.113883.3.88.11.83.119</xsl:variable>
	<xsl:variable name="hitsp-CDA-ReviewOfSystemsSection">2.16.840.1.113883.3.88.11.83.120</xsl:variable>
	<xsl:variable name="hitsp-CDA-HospitalCourseSection">2.16.840.1.113883.3.88.11.83.121</xsl:variable>
	<xsl:variable name="hitsp-CDA-DiagnosticResultsSection">2.16.840.1.113883.3.88.11.83.122</xsl:variable>
	<xsl:variable name="hitsp-CDA-AssessmentAndPlanSection">2.16.840.1.113883.3.88.11.83.123</xsl:variable>
	<xsl:variable name="hitsp-CDA-PlanOfCareSection">2.16.840.1.113883.3.88.11.83.124</xsl:variable>
	<xsl:variable name="hitsp-CDA-FamilyHistorySection">2.16.840.1.113883.3.88.11.83.125</xsl:variable>
	<xsl:variable name="hitsp-CDA-SocialHistorySection">2.16.840.1.113883.3.88.11.83.126</xsl:variable>
	<xsl:variable name="hitsp-CDA-EncountersSection">2.16.840.1.113883.3.88.11.83.127</xsl:variable>
	<xsl:variable name="hitsp-CDA-MedicalEquipmentSection">2.16.840.1.113883.3.88.11.83.128</xsl:variable>
	<xsl:variable name="hitsp-CDA-PreOperativeDiagnosisSection">2.16.840.1.113883.3.88.11.83.129</xsl:variable>
	<xsl:variable name="hitsp-CDA-PostOperativeDiagnosisSection">2.16.840.1.113883.3.88.11.83.130</xsl:variable>
	<xsl:variable name="hitsp-CDA-SurgeryDescriptionSection">2.16.840.1.113883.3.88.11.83.131</xsl:variable>
	<xsl:variable name="hitsp-CDA-SurgicalOperationNoteFindingsSection">2.16.840.1.113883.3.88.11.83.132</xsl:variable>
	<xsl:variable name="hitsp-CDA-AnesthesiaSection">2.16.840.1.113883.3.88.11.83.133</xsl:variable>
	<xsl:variable name="hitsp-CDA-EstimatedBloodLossSection">2.16.840.1.113883.3.88.11.83.134</xsl:variable>
	<xsl:variable name="hitsp-CDA-SpecimensRemovedSection">2.16.840.1.113883.3.88.11.83.135</xsl:variable>
	<xsl:variable name="hitsp-CDA-ComplicationsSection">2.16.840.1.113883.3.88.11.83.136</xsl:variable>
	<xsl:variable name="hitsp-CDA-PlannedProcedureSection">2.16.840.1.113883.3.88.11.83.137</xsl:variable>
	<xsl:variable name="hitsp-CDA-IndicationsSection">2.16.840.1.113883.3.88.11.83.138</xsl:variable>
	<xsl:variable name="hitsp-CDA-DispositionSection">2.16.840.1.113883.3.88.11.83.139</xsl:variable>
	<xsl:variable name="hitsp-CDA-OperativeNoteFluidsSection">2.16.840.1.113883.3.88.11.83.140</xsl:variable>
	<xsl:variable name="hitsp-CDA-OperativeNoteSurgicalProcedureSection">2.16.840.1.113883.3.88.11.83.141</xsl:variable>
	<xsl:variable name="hitsp-CDA-SurgicalDrainsSection">2.16.840.1.113883.3.88.11.83.142</xsl:variable>
	<xsl:variable name="hitsp-CDA-ImplantsSection">2.16.840.1.113883.3.88.11.83.143</xsl:variable>
	<xsl:variable name="hitsp-CDA-AssessmentsSection">2.16.840.1.113883.3.88.11.83.144</xsl:variable>
	<xsl:variable name="hitsp-CDA-ProceduresAndInterventionsSection">2.16.840.1.113883.3.88.11.83.145</xsl:variable>
	<xsl:variable name="hitsp-CDA-ProviderOrdersSection">2.16.840.1.113883.3.88.11.83.146</xsl:variable>
	<xsl:variable name="hitsp-CDA-QuestionnaireAssessmentSection">2.16.840.1.113883.3.88.11.83.147</xsl:variable>

	<!-- HITSP CDA Entry Templates -->
	<xsl:variable name="hitsp-CDA-LanguageSpoken">2.16.840.1.113883.3.88.11.83.2</xsl:variable>
	<xsl:variable name="hitsp-CDA-Support">2.16.840.1.113883.3.88.11.83.3</xsl:variable>
	<xsl:variable name="hitsp-CDA-HealthcareProvider">2.16.840.1.113883.3.88.11.83.4</xsl:variable>
	<xsl:variable name="hitsp-CDA-InsuranceProvider">2.16.840.1.113883.3.88.11.83.5</xsl:variable>
	<xsl:variable name="hitsp-CDA-AllergyAndDrugSensitivityModule">2.16.840.1.113883.3.88.11.83.6</xsl:variable>
	<xsl:variable name="hitsp-CDA-Condition">2.16.840.1.113883.3.88.11.83.7</xsl:variable>
	<xsl:variable name="hitsp-CDA-Medication">2.16.840.1.113883.3.88.11.83.8</xsl:variable>
	<xsl:variable name="hitsp-CDA-TypeofMedication">2.16.840.1.113883.3.88.11.83.8.1</xsl:variable>
	<xsl:variable name="hitsp-CDA-MedicationInformation">2.16.840.1.113883.3.88.11.83.8.2</xsl:variable>
	<xsl:variable name="hitsp-CDA-OrderInformation">2.16.840.1.113883.3.88.11.83.8.3</xsl:variable>
	<xsl:variable name="hitsp-CDA-Comments">2.16.840.1.113883.3.88.11.83.11</xsl:variable>
	<xsl:variable name="hitsp-CDA-AdvanceDirective">2.16.840.1.113883.3.88.11.83.12</xsl:variable>
	<xsl:variable name="hitsp-CDA-Immunization">2.16.840.1.113883.3.88.11.83.13</xsl:variable>
	<xsl:variable name="hitsp-CDA-VitalSigns">2.16.840.1.113883.3.88.11.83.14</xsl:variable>
	<xsl:variable name="hitsp-CDA-Results">2.16.840.1.113883.3.88.11.83.15</xsl:variable>
	<xsl:variable name="hitsp-CDA-Results-C83v2">2.16.840.1.113883.3.88.11.83.15.1</xsl:variable>
	<xsl:variable name="hitsp-CDA-Encounters">2.16.840.1.113883.3.88.11.83.16</xsl:variable>
	<xsl:variable name="hitsp-CDA-Procedure">2.16.840.1.113883.3.88.11.83.17</xsl:variable>
	<xsl:variable name="hitsp-CDA-FamilyHistory">2.16.840.1.113883.3.88.11.83.18</xsl:variable>
	<xsl:variable name="hitsp-CDA-SocialHistory">2.16.840.1.113883.3.88.11.83.19</xsl:variable>
	<xsl:variable name="hitsp-CDA-MedicalEquipment">2.16.840.1.113883.3.88.11.83.20</xsl:variable>
	<xsl:variable name="hitsp-CDA-FunctionalStatus">2.16.840.1.113883.3.88.11.83.21</xsl:variable>
	<xsl:variable name="hitsp-CDA-PlanOfCare">2.16.840.1.113883.3.88.11.83.22</xsl:variable>

	<!-- HITSP CDA Other Templates -->
	<xsl:variable name="hitsp-CDA-FamilyHistoryOrganizer">2.16.840.1.113883.3.88.11.83.18</xsl:variable>
</xsl:stylesheet>
