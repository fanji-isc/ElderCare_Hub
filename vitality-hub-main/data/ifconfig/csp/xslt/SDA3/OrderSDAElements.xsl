<!-- Order and sort SDA -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" version="1.0"
				exclude-result-prefixes="isc">
	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
	<xsl:strip-space elements="*"/>

	<!-- Patient comes first, then Encounter -->
	<xsl:template match="/Container">
    <xsl:variable name="data"
      select="concat(SendingFacility, '^', Patient/PatientNumbers/PatientNumber[NumberType = 'MRN'][1]/Organization/Code, '^', Patient/PatientNumbers/PatientNumber[NumberType = 'MRN'][1]/Number, '||', Action, '||', EventDescription)"/>
    <xsl:value-of select="isc:evaluate('recordSDAData', $data)"/>
		<xsl:copy>
			<xsl:apply-templates select="Patient"/>
			<xsl:apply-templates select="Encounters"/>
      <xsl:apply-templates select="*[not(self::Patient | self::Encounters)]"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Encounters">
		<xsl:copy>
			<xsl:for-each select="Encounter">
        <xsl:sort select="string-length(EndTime) = 0" order="descending"/>
				<xsl:sort select="EndTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Alerts">
		<xsl:copy>
			<xsl:for-each select="Alert">
        <xsl:sort select="string-length(ToTime) = 0" order="descending"/>
				<xsl:sort select="ToTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/AdvanceDirectives">
		<xsl:copy>
			<xsl:for-each select="AdvanceDirective">
        <xsl:sort select="string-length(ToTime) = 0" order="descending"/>
				<xsl:sort select="ToTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Allergies">
		<xsl:copy>
			<xsl:for-each select="Allergy">
        <xsl:sort select="string-length(InactiveTime) = 0" order="descending"/>
				<xsl:sort select="InactiveTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/IllnessHistories">
		<xsl:copy>
			<xsl:for-each select="IllnessHistory">
        <xsl:sort select="string-length(ToTime) = 0" order="descending"/>
				<xsl:sort select="ToTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/SocialHistories">
		<xsl:copy>
			<xsl:for-each select="SocialHistory">
        <xsl:sort select="string-length(ToTime) = 0" order="descending"/>
				<xsl:sort select="ToTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/FamilyHistories">
		<xsl:copy>
			<xsl:for-each select="FamilyHistory">
        <xsl:sort select="string-length(ToTime) = 0" order="descending"/>
				<xsl:sort select="ToTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Diagnoses">
		<xsl:copy>
			<xsl:for-each select="Diagnosis">
				<xsl:sort select="EnteredOn" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Observations">
		<xsl:copy>
			<xsl:for-each select="Observation">
				<xsl:sort select="ObservationTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Problems">
		<xsl:copy>
			<xsl:for-each select="Problem">
        <xsl:sort select="string-length(ToTime) = 0" order="descending"/>
				<xsl:sort select="ToTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/PhysicalExams">
		<xsl:copy>
			<xsl:for-each select="PhysicalExam">
				<xsl:sort select="PhysExamTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Procedures">
		<xsl:copy>
			<xsl:for-each select="Procedure">
				<xsl:sort select="ProcedureTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Documents">
		<xsl:copy>
			<xsl:for-each select="Document">
				<xsl:sort select="DocumentTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/LabOrders">
		<xsl:copy>
			<xsl:for-each select="LabOrder">
        <xsl:sort select="string-length(SpecimenCollectedTime) = 0" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/RadOrders">
		<xsl:copy>
			<xsl:for-each select="RadOrder">
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/OtherOrders">
		<xsl:copy>
			<xsl:for-each select="OtherOrder">
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Medications">
		<xsl:copy>
			<xsl:for-each select="Medication">
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/Vaccinations">
		<xsl:copy>
			<xsl:for-each select="Vaccination">
				<xsl:sort select="FromTime" order="descending"/>
        <xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

  <!--skip AdditionalInfo-->
  <xsl:template match="/Container/AdditionalInfo"/>

  <!--skip AdditionalDocumentInfo-->
  <xsl:template match="/Container/AdditionalDocumentInfo"/>

	<!--Copy all elements not explicitly referenced above-->
  <xsl:template match="@* | node()">
		<xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
	<!--HSIEC-8678 Remove Null SDA values -->
	<xsl:template match="*[not(.//text()[normalize-space()])]"/>

  <xsl:template match="comment()"/>

</xsl:stylesheet>