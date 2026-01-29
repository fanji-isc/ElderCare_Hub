<?xml version="1.0"?>
<!-- Record streamlet types (and MRN) found in SDA -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:isc="http://extension-functions.intersystems.com"
				version="1.0"
				exclude-result-prefixes="isc">
<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>

<xsl:template match="/Container/Patient">
	<xsl:variable name="mrn" select="concat(../SendingFacility,'^',PatientNumbers/PatientNumber[NumberType = 'MRN'][1]/Organization/Code,'^',PatientNumbers/PatientNumber[NumberType = 'MRN'][1]/Number,'||',../Action,'||',../EventDescription)"/>
	<xsl:value-of select="isc:evaluate('addStreamletType','Patient',$mrn)"/>
</xsl:template>
<xsl:template match="/Container/Encounters">
	<xsl:value-of select="isc:evaluate('addStreamletType','Encounter')"/>
</xsl:template>
<xsl:template match="/Container/Allergies">
	<xsl:value-of select="isc:evaluate('addStreamletType','Allergy')"/>
</xsl:template>
<xsl:template match="/Container/Alerts">
	<xsl:value-of select="isc:evaluate('addStreamletType','Alert')"/>
</xsl:template>
<xsl:template match="/Container/AdvanceDirectives">
	<xsl:value-of select="isc:evaluate('addStreamletType','AdvanceDirective')"/>
</xsl:template>
<xsl:template match="/Container/IllnessHistories">
	<xsl:value-of select="isc:evaluate('addStreamletType','IllnessHistory')"/>
</xsl:template>
<xsl:template match="/Container/FamilyHistories">
	<xsl:value-of select="isc:evaluate('addStreamletType','FamilyHistory')"/>
</xsl:template>
<xsl:template match="/Container/SocialHistories">
	<xsl:value-of select="isc:evaluate('addStreamletType','SocialHistory')"/>
</xsl:template>
<xsl:template match="/Container/Diagnoses">
	<xsl:value-of select="isc:evaluate('addStreamletType','Diagnosis')"/>
</xsl:template>
<xsl:template match="/Container/Medications">
	<xsl:value-of select="isc:evaluate('addStreamletType','Medication')"/>
</xsl:template>
<xsl:template match="/Container/Vaccinations">
	<xsl:value-of select="isc:evaluate('addStreamletType','Vaccination')"/>
</xsl:template>
<xsl:template match="/Container/LabOrders">
	<xsl:value-of select="isc:evaluate('addStreamletType','LabOrder')"/>
</xsl:template>
<xsl:template match="/Container/RadOrders">
	<xsl:value-of select="isc:evaluate('addStreamletType','RadOrder')"/>
</xsl:template>
<xsl:template match="/Container/OtherOrders">
	<xsl:value-of select="isc:evaluate('addStreamletType','OtherOrder')"/>
</xsl:template>
<xsl:template match="/Container/Observations">
	<xsl:value-of select="isc:evaluate('addStreamletType','Observation')"/>
</xsl:template>
<xsl:template match="/Container/Problems">
	<xsl:value-of select="isc:evaluate('addStreamletType','Problem')"/>
</xsl:template>
<xsl:template match="/Container/Documents">
	<xsl:value-of select="isc:evaluate('addStreamletType','Document')"/>
</xsl:template>
<xsl:template match="/Container/Procedures">
	<xsl:value-of select="isc:evaluate('addStreamletType','Procedure')"/>
</xsl:template>
<xsl:template match="/Container/PhysicalExams">
	<xsl:value-of select="isc:evaluate('addStreamletType','PhysicalExam')"/>
</xsl:template>

</xsl:stylesheet>