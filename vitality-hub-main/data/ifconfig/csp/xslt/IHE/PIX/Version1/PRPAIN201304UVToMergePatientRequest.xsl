<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wrapper="http://wrapper.intersystems.com" xmlns:isc="http://extension-functions.intersystems.com" version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="isc wrapper hl7">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:template match="//hl7:PRPA_IN201304UV02">
<xsl:variable name="facilityCode" select="isc:evaluate('OIDtoCode',./hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient/hl7:providerOrganization/hl7:id/@root)"/>
<xsl:variable name="assigningAuthority" select="isc:evaluate('OIDtoCode',./hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient/hl7:id/@root)"/>
<xsl:variable name="patientIdentifier" select="./hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:subject1/hl7:patient/hl7:id/@extension"/>
<xsl:variable name="priorAssigningAuthority" select="isc:evaluate('OIDtoCode',./hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:replacementOf/hl7:priorRegistration/hl7:subject1/hl7:priorRegisteredRole/hl7:id/@root)"/>
<xsl:variable name="priorPatientIdentifier" select="./hl7:controlActProcess/hl7:subject/hl7:registrationEvent/hl7:replacementOf/hl7:priorRegistration/hl7:subject1/hl7:priorRegisteredRole/hl7:id/@extension"/>

<MergePatientRequest>
<AssigningAuthority><xsl:value-of select="$assigningAuthority"/></AssigningAuthority>
<MRN><xsl:value-of select="$patientIdentifier"/></MRN>
<PriorAssigningAuthority><xsl:value-of select="$priorAssigningAuthority"/></PriorAssigningAuthority>
<PriorMRN><xsl:value-of select="$priorPatientIdentifier"/></PriorMRN>
<Facility><xsl:value-of select="$facilityCode"/></Facility>
</MergePatientRequest>
</xsl:template>

</xsl:stylesheet>
