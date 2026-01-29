<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
  
  <xsl:template match="*" mode="eHP-HealthcareProvider">
    <!--
			Field : Healthcare Provider Family Doctor
			Target: HS.SDA3.Patient FamilyDoctor
			Target: /Container/Patient/FamilyDoctor
			Source: /ClinicalDocument/documentationOf/serviceEvent/performer[(functionCode/@codeSystem='2.16.840.1.113883.5.88' and functionCode/@code='PCP')]
			StructuredMappingRef: DoctorDetail
		-->
    <xsl:apply-templates
      select="
      hl7:serviceEvent/hl7:performer[(hl7:functionCode/@codeSystem = $participationFunctionOID and hl7:functionCode/@code = 'PCP')
      or (hl7:functionCode/@codeSystem = $providerRoleOID and hl7:functionCode/@code = 'PP')][1]"
      mode="fn-FamilyDoctor"/>
  </xsl:template>
  
  <xsl:template match="hl7:performer" mode="eHP-DocumentProvider-performer">
    <!--
			Field : Care Plan Care Provider
			Target: HS.SDA3.Patient FamilyDoctor
			Target: /Container/CarePlans/CarePlan[1]/Providers/DocumentProvider/Provider
			Source: /ClinicalDocument/documentationOf/serviceEvent/performer
		-->
    
    <DocumentProvider>
      <Provider>
        <xsl:apply-templates select="hl7:assignedEntity/hl7:addr" mode="fn-T-pName-address"/>
        <xsl:apply-templates select="hl7:assignedEntity/hl7:assignedPerson/hl7:name" mode="fn-T-pName-ContactName"/>
        <xsl:apply-templates select="hl7:assignedEntity" mode="fn-T-pName-ContactInfo"/>
        <xsl:apply-templates select="hl7:functionCode" mode="fn-CodeTable">
          <xsl:with-param name="hsElementName">CareProviderType</xsl:with-param>
        </xsl:apply-templates>
      </Provider>
    </DocumentProvider>
  </xsl:template>
  
</xsl:stylesheet>