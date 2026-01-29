<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="xsi exsl">
  <!-- AlsoInclude: AuthorParticipation.xsl Comment.xsl Medication.xsl -->

  <!-- Immunization Variables -->
  <!-- E = Executed (Completed), R = Replaced -->
  <xsl:variable name="immunizationExecutedStatusCodes">|E|R|</xsl:variable>
  <!-- H = On-Hold (Held), INT = Intended (default, if no status value specified), IP = In-Progress (Active)-->
  <xsl:variable name="immunizationIntendedStatusCodes">|H|INT|IP|</xsl:variable>
  <!-- C = Cancelled, D = Discontinued -->
  <xsl:variable name="immunizationCancelledStatusCodes">|C|D|</xsl:variable>
  <!-- If you wish to block exporting vaccination(s) with zero administrations (default), export profile code should be 0.
	   If you wish to include exporting vaccination(s) with zero administrations, export profile code should be 1.-->
  <xsl:variable name="checkAdministrations" select="$exportConfiguration/immunizations/checkAdministrations/text()"/>

  <xsl:template match="*" mode="eI-immunizations-Narrative">
    <text>
      <table border="1" width="100%">
        <thead>
          <tr>
            <th>Ordered Immunization Name</th>
            <th>Filled Immunization Name</th>
            <th>Date</th>
            <th>Status</th>
            <th>Comments</th>
            <th>Refusal Reason</th>
          </tr>
        </thead>
        <tbody>
		  <xsl:choose>
		    <xsl:when test="$checkAdministrations='1'">
			  <xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|'))) and not(Administrations/Administration)] | Vaccinations/Vaccination/Administrations/Administration" mode="eI-immunizations-NarrativeDetail-Combined"/>
			</xsl:when>
			<xsl:otherwise>
              <xsl:apply-templates select="Vaccinations/Vaccination/Administrations/Administration" mode="eI-immunizations-NarrativeDetail"/>
			</xsl:otherwise>
		  </xsl:choose>
		</tbody>
      </table>
    </text>
  </xsl:template>

  <!-- This template exports a combines list of Vaccinations with no administrations plus Vaccinations with administrations-->
  <xsl:template match="*" mode="eI-immunizations-NarrativeDetail-Combined">
    <xsl:variable name="narrativeLinkSuffix" select="position()"/>

    <tr ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}">
      <td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)}">
        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="OrderItem" mode="fn-originalTextOrDescriptionOrCode"/>
          </xsl:when>
		  <xsl:otherwise>
            <xsl:apply-templates select="../../OrderItem" mode="fn-originalTextOrDescriptionOrCode"/>
		  </xsl:otherwise>
		</xsl:choose>
      </td>
      <td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)}">
        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="DrugProduct" mode="fn-originalTextOrDescriptionOrCode"/>
          </xsl:when>
		  <xsl:otherwise>
            <xsl:apply-templates select="../../DrugProduct" mode="fn-originalTextOrDescriptionOrCode"/>
		  </xsl:otherwise>
		</xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="string-length(FromTime)">
            <xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/>
          </xsl:when>
          <xsl:when test="string-length(EnteredOn)">
            <xsl:apply-templates select="EnteredOn" mode="fn-narrativeDateFromODBC"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'Unknown'"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="Status" mode="eI-immunization-statusDescription"/>
          </xsl:when>
		  <xsl:otherwise>
            <xsl:apply-templates select="../../Status" mode="eI-immunization-statusDescription"/>
		  </xsl:otherwise>
		</xsl:choose>
      </td>
      <td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)}">
        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:value-of select="Comments/text()"/>
          </xsl:when>
		  <xsl:otherwise>
            <xsl:value-of select="../../Comments/text()"/>
		  </xsl:otherwise>
		</xsl:choose>
      </td>
      <td ID="{concat('immunizationRefusalReason-', $narrativeLinkSuffix)}">
        <xsl:choose>
          <xsl:when test="local-name()='Administration'">
            <xsl:value-of select="RefusalReason/Description/text()"/>
          </xsl:when>
		</xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="Administration" mode="eI-immunizations-NarrativeDetail">
    <xsl:variable name="narrativeLinkSuffix" select="position()"/>

    <tr ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}">
      <td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)}">
        <xsl:apply-templates select="../../OrderItem" mode="fn-originalTextOrDescriptionOrCode"/>
      </td>
      <td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)}">
        <xsl:apply-templates select="../../DrugProduct" mode="fn-originalTextOrDescriptionOrCode"/>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="string-length(FromTime)">
            <xsl:apply-templates select="FromTime" mode="fn-narrativeDateFromODBC"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'Unknown'"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:apply-templates select="../../Status" mode="eI-immunization-statusDescription"/>
      </td>
      <td ID="{concat($exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)}">
        <xsl:value-of select="../../Comments/text()"/>
      </td>
      <td ID="{concat('immunizationRefusalReason-', $narrativeLinkSuffix)}">
        <xsl:value-of select="Administrations/Administration/RefusalReason/Description/text()"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="*" mode="eI-immunizations-Entries">
	  <xsl:choose>
		<xsl:when test="$checkAdministrations='1'">
		  <xsl:apply-templates select="Vaccinations/Vaccination[not(contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|'))) and not(Administrations/Administration)] | Vaccinations/Vaccination/Administrations/Administration" mode="eI-immunizations-EntryDetail-Combined"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:apply-templates select="Vaccinations/Vaccination/Administrations/Administration" mode="eI-immunizations-EntryDetail"/>
		</xsl:otherwise>
	  </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="eI-immunizations-EntryDetail-Combined">
    <xsl:variable name="narrativeLinkSuffix" select="position()"/>
    <xsl:variable name="negationInd">
      <xsl:choose>
        <xsl:when test="contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|'))">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <entry typeCode="DRIV">
      <substanceAdministration classCode="SBADM" negationInd="{$negationInd}">
        <!-- The following template is defined in Export/Entry-Modules/Medication.xsl -->
        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="." mode="eM-moodCodeAttr"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="../../." mode="eM-moodCodeAttr"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="eI-templateIds-immunizationAdministration"/>

        <!-- External, Placer, and Filler IDs-->
        <!--
					Field : Immunization Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[1]
					Source: HS.SDA3.Vaccination ExternalId
					Source: /Container/Vaccinations/Vaccination/ExternalId
					StructuredMappingRef: id-External
				-->
        <!--
					Field : Immunization Placer Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[2]
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: /Container/Vaccinations/Vaccination/PlacerId
					StructuredMappingRef: id-Placer
					Note  : SDA PlacerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA PlacerId have a value
							- Both SDA EnteredAt/Code and SDA PlacerId have a value
							
							For example, if EnteringOrganization/Organization/Code equals "CGH", and
							CGH has OID 1.3.6.1.4.1.21367.2010.1.2.300.2.1, and PlacerId equals 7676,
							then this is exported
							
							<id root="1.3.6.1.4.1.21367.2010.1.2.300.2.1" extension="7676" assigningAuthorityName="CGH-PlacerId"/>
							
							Otherwise, a CDA id is exported with a GUID and some placeholder text.
							For example
							
							<id root="fcbcb478-fceb-11e3-ae03-31c1b7edac00" assigningAuthorityName="CGH-UnspecifiedPlacerId"/>
				-->
        <!--
					Field : Immunization Filler Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[3]
					Source: HS.SDA3.AbstractOrder FillerId
					Source: /Container/Vaccinations/Vaccination/FillerId
					StructuredMappingRef: id-Filler
					Note  : SDA FillerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA FillerId have a value
							- Both SDA EnteredAt/Code and SDA FillerId have a value
							
							For example, if EnteringOrganization/Organization/Code equals "CGH", and
							CGH has OID 1.3.6.1.4.1.21367.2010.1.2.300.2.1, and FillerID equals 7676,
							then this is exported
							
							<id root="1.3.6.1.4.1.21367.2010.1.2.300.2.1" extension="7676" assigningAuthorityName="CGH-FillerId"/>
							
							Otherwise, a CDA id is exported with a GUID and some placeholder text.
							For example
							
							<id root="fcbcb478-fceb-11e3-ae03-31c1b7edac00" assigningAuthorityName="CGH-UnspecifiedFillerId"/>
				-->
        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="." mode="fn-id-Medication"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="../../." mode="fn-id-Medication"/>
          </xsl:otherwise>
        </xsl:choose>

        <code code="IMMUNIZ" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
        <text>
          <reference value="{concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}"/>
        </text>

        <!--Status code-->
        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="Status" mode="eI-statusCode-immunization"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="../../Status" mode="eI-statusCode-immunization"/>
          </xsl:otherwise>
        </xsl:choose>

        <!--
			Field : Immunization Administered From Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/@value
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/low/@value
			Source: HS.SDA3.Administration FromTime
			Source: /Container/Vaccinations/Vaccination/Administrations/Administration/FromTime
			Note: When ToTime is present, FromTime maps to low value of a range.  When ToTime is not present, FromTime simply maps to effectiveDate/@value.
		-->
        <!--
			Field : Immunization Administered To Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/high/@value
			Source: HS.SDA3.Administration ToTime
			Source: /Container/Vaccinations/Vaccination/Administrations/Administration/ToTime
		-->
		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
		    <xsl:apply-templates select="." mode="fn-effectiveTime-singletonChoice"/>
		  </xsl:when>
		  <xsl:otherwise>
			<effectiveTime>
				<xsl:choose>
					<xsl:when test="string-length(ToTime/text())">
						<xsl:choose>
							<xsl:when test="string-length(FromTime/text())">
								<low><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute></low>
							</xsl:when>
							<xsl:otherwise><low nullFlavor="UNK"/></xsl:otherwise>
						</xsl:choose>
						<high><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute></high>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string-length(FromTime/text())">
								<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>				
					</xsl:otherwise>
				</xsl:choose>
			</effectiveTime>
		  </xsl:otherwise>			
		</xsl:choose>
		
        <!--
					Field : Immunization Route
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/routeCode
					Source: HS.SDA3.AbstractMedication Route
					Source: /Container/Immunizations/Immunization/Route
					StructuredMappingRef: generic-Coded
				-->
        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="Route" mode="fn-code-route"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="../../Route" mode="fn-code-route"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="." mode="eI-doseQuantity-immunization"/>
         </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="../../." mode="eI-doseQuantity-immunization"/>
          </xsl:otherwise>
        </xsl:choose>

		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
			<xsl:apply-templates select="OrderItem" mode="eI-immunization-order">
			  <xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)"/>
			</xsl:apply-templates>
          </xsl:when>
		  <xsl:otherwise>
			<xsl:apply-templates select="../../OrderItem" mode="eI-immunization-order">
			  <xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)"/>
			</xsl:apply-templates>
          </xsl:otherwise>
		</xsl:choose>
		
        <!--
					Field : Immunization Ordering Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/performer
					Source: HS.SDA3.AbstractOrder OrderedBy
					Source: /Container/Vaccinations/Vaccination/OrderedBy
					StructuredMappingRef: performer
				-->
		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="OrderedBy" mode="fn-performer"/>
          </xsl:when>
		  <xsl:otherwise>
            <xsl:apply-templates select="../../OrderedBy" mode="fn-performer"/>
          </xsl:otherwise>
		</xsl:choose>

        <!--
					Field : Immunization Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author
					Source: HS.SDA3.AbstractOrder EnteredBy
					Source: /Container/Vaccinations/Vaccination/EnteredBy
					StructuredMappingRef: author-Human
				-->
        <!--
					Field : Immunization Author Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author
					Source: HS.SDA3.Administration EnteredOn
					Source: /Container/Vaccinations/Vaccination/Administrations/Administration/EnteredOn
				-->
        <!--
					Field : Immunization Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/informant
					Source: HS.SDA3.AbstractOrder EnteredAt
					Source: /Container/Vaccinations/Vaccination/EnteredAt
					StructuredMappingRef: informant
				-->
		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
			<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
		  </xsl:when>
		  <xsl:otherwise>
			<author typeCode="AUT">
				<xsl:call-template name="eAP-templateIds-authorParticipation"/>

				<xsl:choose>
					<xsl:when test="string-length(EnteredOn/text())">
						<time><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></time>
					</xsl:when>
					<xsl:otherwise>
						<time nullFlavor="UNK"/>
					</xsl:otherwise>
				</xsl:choose>

				<assignedAuthor classCode="ASSIGNED">
					<!-- Clinician ID -->
					<xsl:apply-templates select="../../EnteredBy" mode="fn-id-Clinician"/>

					<!-- HealthShare-specific author types -->
					<xsl:apply-templates
						select="../../Description[contains('|PAYER|PAYOR|PATIENT|', translate(text(), $lowerCase, $upperCase))]"
						mode="eAP-author-Code"/>
					
					<!-- ContactType -->
					<xsl:apply-templates select="../../ContactType" mode="fn-generic-Coded">
						<xsl:with-param name="cdaElementName">code</xsl:with-param>
					</xsl:apply-templates>

					<!-- Author Address -->
					<xsl:apply-templates select="../../." mode="fn-address-WorkPrimary"/>
					
					<!-- Author Telecom -->
					<xsl:apply-templates select="../../." mode="fn-telecom"/>

					<!-- Person -->
					<xsl:apply-templates select="../../EnteredBy" mode="fn-assignedPerson"/>
								
					<!-- Represented Organization -->
					<xsl:apply-templates select="../../EnteredAt" mode="fn-representedOrganization"/>
				</assignedAuthor>
			</author>
		  </xsl:otherwise>			
		</xsl:choose>
		
		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
          </xsl:when>
		  <xsl:otherwise>
            <xsl:apply-templates select="../../EnteredAt" mode="fn-informant"/>
          </xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="." mode="eI-observation-immunizationStatus"/>
          </xsl:when>
		  <xsl:otherwise>
            <xsl:apply-templates select="../../." mode="eI-observation-immunizationStatus"/>
          </xsl:otherwise>
		</xsl:choose>

        <!--
					Field : Immunization Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.AbstractOrder Comments
					Source: /Container/Vaccinations/Vaccination/Comments
				-->
		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
			<xsl:apply-templates select="Comments" mode="eCm-entryRelationship-comments">
			  <xsl:with-param name="narrativeLink"
				select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)"/>
			</xsl:apply-templates>
          </xsl:when>
		  <xsl:otherwise>
			<xsl:apply-templates select="../../Comments" mode="eCm-entryRelationship-comments">
			  <xsl:with-param name="narrativeLink"
				select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)"/>
			</xsl:apply-templates>
          </xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
			<xsl:apply-templates select="DrugProduct" mode="eI-immunization-supply">
			  <xsl:with-param name="narrativeLink"
				select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)"/>
			</xsl:apply-templates>
          </xsl:when>
		  <xsl:otherwise>
			<xsl:apply-templates select="../../DrugProduct" mode="eI-immunization-supply">
			  <xsl:with-param name="narrativeLink"
				select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)"/>
			</xsl:apply-templates>
          </xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
		  <xsl:when test="local-name()='Administration'">
			<xsl:apply-templates select="RefusalReason" mode="eI-observation-refusalReason">
			  <xsl:with-param name="narrativeLink" select="concat('#immunizationRefusalReason-', $narrativeLinkSuffix)"/>
			</xsl:apply-templates>
		  </xsl:when>
		</xsl:choose>

        <!--
					Field : Immunization Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship
					Source: HS.SDA3.AbstractOrder EncounterNumber
					Source: /Container/Vaccinations/Vaccination/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : This links the Immunization to an encounter in the Encounters section.
				-->
		<xsl:choose>
		  <xsl:when test="local-name()='Vaccination'">
            <xsl:apply-templates select="." mode="fn-encounterLink-entryRelationship"/>
          </xsl:when>
		  <xsl:otherwise>
            <xsl:apply-templates select="../../." mode="fn-encounterLink-entryRelationship"/>
          </xsl:otherwise>
		</xsl:choose>
      </substanceAdministration>
    </entry>
  </xsl:template>

  <xsl:template match="Administration" mode="eI-immunizations-EntryDetail">
    <xsl:variable name="narrativeLinkSuffix" select="position()"/>
    <xsl:variable name="negationInd">
      <xsl:choose>
        <xsl:when test="contains($immunizationCancelledStatusCodes, concat('|', Status/text(), '|'))">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <entry typeCode="DRIV">
      <substanceAdministration classCode="SBADM" negationInd="{$negationInd}">
        <!-- The following template is defined in Export/Entry-Modules/Medication.xsl -->
        <xsl:apply-templates select="../../." mode="eM-moodCodeAttr"/>

        <xsl:call-template name="eI-templateIds-immunizationAdministration"/>

        <!-- External, Placer, and Filler IDs-->
        <!--
					Field : Immunization Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[1]
					Source: HS.SDA3.Vaccination ExternalId
					Source: /Container/Vaccinations/Vaccination/ExternalId
					StructuredMappingRef: id-External
				-->
        <!--
					Field : Immunization Placer Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[2]
					Source: HS.SDA3.AbstractOrder PlacerId
					Source: /Container/Vaccinations/Vaccination/PlacerId
					StructuredMappingRef: id-Placer
					Note  : SDA PlacerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA PlacerId have a value
							- Both SDA EnteredAt/Code and SDA PlacerId have a value
							
							For example, if EnteringOrganization/Organization/Code equals "CGH", and
							CGH has OID 1.3.6.1.4.1.21367.2010.1.2.300.2.1, and PlacerId equals 7676,
							then this is exported
							
							<id root="1.3.6.1.4.1.21367.2010.1.2.300.2.1" extension="7676" assigningAuthorityName="CGH-PlacerId"/>
							
							Otherwise, a CDA id is exported with a GUID and some placeholder text.
							For example
							
							<id root="fcbcb478-fceb-11e3-ae03-31c1b7edac00" assigningAuthorityName="CGH-UnspecifiedPlacerId"/>
				-->
        <!--
					Field : Immunization Filler Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[3]
					Source: HS.SDA3.AbstractOrder FillerId
					Source: /Container/Vaccinations/Vaccination/FillerId
					StructuredMappingRef: id-Filler
					Note  : SDA FillerId is exported to CDA id if one of these conditions is met:
							- Both SDA EnteringOrganization/Organization/Code and SDA FillerId have a value
							- Both SDA EnteredAt/Code and SDA FillerId have a value
							
							For example, if EnteringOrganization/Organization/Code equals "CGH", and
							CGH has OID 1.3.6.1.4.1.21367.2010.1.2.300.2.1, and FillerID equals 7676,
							then this is exported
							
							<id root="1.3.6.1.4.1.21367.2010.1.2.300.2.1" extension="7676" assigningAuthorityName="CGH-FillerId"/>
							
							Otherwise, a CDA id is exported with a GUID and some placeholder text.
							For example
							
							<id root="fcbcb478-fceb-11e3-ae03-31c1b7edac00" assigningAuthorityName="CGH-UnspecifiedFillerId"/>
				-->
        <xsl:apply-templates select="../../." mode="fn-id-Medication"/>

        <code code="IMMUNIZ" codeSystem="{$actCodeOID}" codeSystemName="{$actCodeName}"/>
        <text>
          <reference value="{concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationNarrative/text(), $narrativeLinkSuffix)}"/>
        </text>

        <!--Status code-->
        <xsl:apply-templates select="../../Status" mode="eI-statusCode-immunization"/>

        <!--
			Field : Immunization Administered From Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/low/@value
			Source: HS.SDA3.Administration FromTime
			Source: /Container/Vaccinations/Vaccination/Administrations/Administration/FromTime
			Note: When ToTime is present, FromTime maps to low value of a range.  When ToTime is not present, FromTime simply maps to effectiveDate/@value.
		-->
        <!--
			Field : Immunization Administered To Time
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/high/@value
			Source: HS.SDA3.Administration ToTime
			Source: /Container/Vaccinations/Vaccination/Administrations/Administration/ToTime
		-->
		<effectiveTime>
			<xsl:choose>
				<xsl:when test="string-length(ToTime/text())">
					<xsl:choose>
						<xsl:when test="string-length(FromTime/text())">
							<low><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute></low>
						</xsl:when>
						<xsl:otherwise><low nullFlavor="UNK"/></xsl:otherwise>
					</xsl:choose>
					<high><xsl:attribute name="value"><xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute></high>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length(FromTime/text())">
							<xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="nullFlavor">UNK</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>				
				</xsl:otherwise>
			</xsl:choose>
		</effectiveTime>

        <!--
					Field : Immunization Route
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/routeCode
					Source: HS.SDA3.AbstractMedication Route
					Source: /Container/Immunizations/Immunization/Route
					StructuredMappingRef: generic-Coded
				-->
        <xsl:apply-templates select="../../Route" mode="fn-code-route"/>

        <xsl:apply-templates select="../../." mode="eI-doseQuantity-immunization"/>

        <xsl:apply-templates select="../../OrderItem" mode="eI-immunization-order">
          <xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationOrderedName/text(), $narrativeLinkSuffix)"/>
        </xsl:apply-templates>

        <!--
					Field : Immunization Ordering Clinician
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/performer
					Source: HS.SDA3.AbstractOrder OrderedBy
					Source: /Container/Vaccinations/Vaccination/OrderedBy
					StructuredMappingRef: performer
				-->
        <xsl:apply-templates select="../../OrderedBy" mode="fn-performer"/>

        <!--
					Field : Immunization Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author
					Source: HS.SDA3.AbstractOrder EnteredBy
					Source: /Container/Vaccinations/Vaccination/EnteredBy
					StructuredMappingRef: author-Human
				-->
        <!--
					Field : Immunization Author Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author
					Source: HS.SDA3.Administration EnteredOn
					Source: /Container/Vaccinations/Vaccination/Administrations/Administration/EnteredOn
				-->
		<author typeCode="AUT">
			<xsl:call-template name="eAP-templateIds-authorParticipation"/>

			<xsl:choose>
				<xsl:when test="string-length(EnteredOn/text())">
					<time><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></time>
				</xsl:when>
				<xsl:otherwise>
					<time nullFlavor="UNK"/>
				</xsl:otherwise>
			</xsl:choose>

			<assignedAuthor classCode="ASSIGNED">
				<!-- Clinician ID -->
				<xsl:apply-templates select="../../EnteredBy" mode="fn-id-Clinician"/>

				<!-- HealthShare-specific author types -->
				<xsl:apply-templates
					select="../../Description[contains('|PAYER|PAYOR|PATIENT|', translate(text(), $lowerCase, $upperCase))]"
					mode="eAP-author-Code"/>
				
				<!-- ContactType -->
				<xsl:apply-templates select="../../ContactType" mode="fn-generic-Coded">
					<xsl:with-param name="cdaElementName">code</xsl:with-param>
				</xsl:apply-templates>

				<!-- Author Address -->
				<xsl:apply-templates select="../../." mode="fn-address-WorkPrimary"/>
				
				<!-- Author Telecom -->
				<xsl:apply-templates select="../../." mode="fn-telecom"/>

				<!-- Person -->
				<xsl:apply-templates select="../../EnteredBy" mode="fn-assignedPerson"/>
							
				<!-- Represented Organization -->
				<xsl:apply-templates select="../../EnteredAt" mode="fn-representedOrganization"/>
			</assignedAuthor>
		</author>
		
        <!--
					Field : Immunization Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/informant
					Source: HS.SDA3.AbstractOrder EnteredAt
					Source: /Container/Vaccinations/Vaccination/EnteredAt
					StructuredMappingRef: informant
				-->
        <xsl:apply-templates select="../../EnteredAt" mode="fn-informant"/>

        <xsl:apply-templates select="../../." mode="eI-observation-immunizationStatus"/>

        <!--
					Field : Immunization Comments
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
					Source: HS.SDA3.AbstractOrder Comments
					Source: /Container/Vaccinations/Vaccination/Comments
				-->
        <xsl:apply-templates select="../../Comments" mode="eCm-entryRelationship-comments">
          <xsl:with-param name="narrativeLink"
            select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationComments/text(), $narrativeLinkSuffix)"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="../../DrugProduct" mode="eI-immunization-supply">
          <xsl:with-param name="narrativeLink"
            select="concat('#', $exportConfiguration/immunizations/narrativeLinkPrefixes/immunizationFilledName/text(), $narrativeLinkSuffix)"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="Administrations/Administration/RefusalReason" mode="eI-observation-refusalReason">
          <xsl:with-param name="narrativeLink" select="concat('#immunizationRefusalReason-', $narrativeLinkSuffix)"/>
        </xsl:apply-templates>

        <!--
					Field : Immunization Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship
					Source: HS.SDA3.AbstractOrder EncounterNumber
					Source: /Container/Vaccinations/Vaccination/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : This links the Immunization to an encounter in the Encounters section.
				-->
        <xsl:apply-templates select="../../." mode="fn-encounterLink-entryRelationship"/>
      </substanceAdministration>
    </entry>
  </xsl:template>

  <xsl:template match="*" mode="eI-immunizations-NoData">
    <text>
      <xsl:value-of select="$exportConfiguration/immunizations/emptySection/narrativeText/text()"/>
    </text>
  </xsl:template>

  <xsl:template match="OrderItem" mode="eI-immunization-order">
    <xsl:param name="narrativeLink"/>

    <consumable typeCode="CSM">
      <manufacturedProduct classCode="MANU">
        <xsl:call-template name="eI-templateIds-manufacturedProduct-Immunization"/>

        <!--
					Field : Immunization Ordered Product
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/consumable/manufacturedProduct
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/Vaccinations/Vaccination/OrderItem
					StructuredMappingRef: immunization-manufacturedMaterial
				-->
        <xsl:apply-templates select="." mode="eI-manufacturedMaterial">
          <xsl:with-param name="narrativeLink" select="$narrativeLink"/>
        </xsl:apply-templates>
      </manufacturedProduct>
    </consumable>
  </xsl:template>

  <xsl:template match="DrugProduct" mode="eI-immunization-supply">
    <xsl:param name="narrativeLink"/>

    <entryRelationship typeCode="REFR">
      <supply classCode="SPLY" moodCode="EVN">
        <!--
					Field : Immunization Prescription Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
					Source: HS.SDA3.AbstractMedication PrescriptionNumber
					Source: /Container/Vaccinations/Vaccination/PrescriptionNumber
					StructuredMappingRef: id-PrescriptionNumber
				-->
        <xsl:apply-templates select=".." mode="fn-id-PrescriptionNumber"/>

        <repeatNumber nullFlavor="UNK"/>

        <!--
					Field : Immunization Quantity
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/quantity
					Source: HS.SDA3.AbstractMedication DrugProduct
					Source: /Container/Vaccinations/Vaccination/DrugProduct
					StructuredMappingRef: medication-quantity
				-->
        <xsl:apply-templates select="." mode="eM-medication-quantity"/>

        <!--
					Field : Immunization Supply
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/product/manufacturedProduct
					Source: HS.SDA3.AbstractOrder OrderItem
					Source: /Container/Vaccinations/Vaccination/OrderItem
					StructuredMappingRef: immunization-manufacturedMaterial
				-->
        <product typeCode="PRD">
          <manufacturedProduct classCode="MANU">
            <xsl:call-template name="eI-templateIds-manufacturedProduct-Immunization"/>

            <xsl:apply-templates select="." mode="eI-manufacturedMaterial">
              <xsl:with-param name="narrativeLink" select="$narrativeLink"/>
            </xsl:apply-templates>
          </manufacturedProduct>
        </product>
      </supply>
    </entryRelationship>
  </xsl:template>

  <xsl:template match="Vaccination" mode="eI-doseQuantity-immunization">
    <!--
			Field : Immunization Dose Quantity
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/doseQuantity/@value
			Source: HS.SDA3.AbstractMedication DoseQuantity
			Source: /Container/Immunizations/Immunization/DoseQuantity
		-->
    <!--
			Field : Immunization Dose Quantity Unit
			Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.3.23']/entry/substanceAdministration/doseQuantity/@unit
			Source: HS.SDA3.AbstractMedication DoseUoM
			Source: /Container/Immunizations/Immunization/DoseUoM
		-->
    <xsl:choose>
      <xsl:when test="string-length(DoseQuantity)">
        <doseQuantity value="{DoseQuantity/text()}">
          <xsl:if test="string-length(DoseUoM/Code)">
            <xsl:attribute name="unit">
              <xsl:value-of select="DoseUoM/Code/text()"/>
            </xsl:attribute>
          </xsl:if>
        </doseQuantity>
      </xsl:when>
      <xsl:otherwise>
        <doseQuantity nullFlavor="NI"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="RefusalReason" mode="eI-observation-refusalReason">
    <xsl:param name="narrativeLink"/>

    <entryRelationship typeCode="RSON">
      <observation classCode="OBS" moodCode="EVN">
        <templateId root="{$ccda-ImmunizationRefusalReason}"/>
        <id nullFlavor="NI"/>

        <!--
					Field : Immunization RefusalReason
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/observation[@moodCode='EVN']/code
					Source: HS.SDA3.Administration RefusalReason
					Source: /Container/Vaccinations/Vaccination/Administrations/Administration/RefusalReason
				-->
        <code codeSystemName="HL7 ActNoImmunizationReason" codeSystem="2.16.840.1.113883.5.8">
          <xsl:attribute name="code">
            <xsl:value-of select="Code/text()"/>
          </xsl:attribute>
          <xsl:attribute name="displayName">
            <xsl:value-of select="Description/text()"/>
          </xsl:attribute>
        </code>
        <xsl:if test="string-length($narrativeLink)">
          <text>
            <reference value="{$narrativeLink}"/>
          </text>
        </xsl:if>
        <statusCode code="completed"/>
      </observation>
    </entryRelationship>
  </xsl:template>

  <xsl:template match="DrugProduct | OrderItem" mode="eI-manufacturedMaterial">
    <xsl:param name="narrativeLink"/>

    <manufacturedMaterial classCode="MMAT" determinerCode="KIND">
      <!-- 
				This field has slightly different requirements than other
				coded element fields.  Like many coded element fields, it
				has only one valid codeSystem - in this case, CVX.  However,
				it requires that if there is a <translation> on the code,
				then the codeSystem on it must be for RxNorm or NDC, or it
				must be nullFlavor.                                          
			-->
      <xsl:variable name="sdaCodingStandardOID">
        <xsl:apply-templates select="." mode="fn-oid-for-code">
          <xsl:with-param name="Code" select="SDACodingStandard/text()"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:variable name="description">
        <xsl:apply-templates select="." mode="fn-descriptionOrCode"/>
      </xsl:variable>
      <!--
				2.16.840.1.113883.6.59 was retired by HL7. 2.16.840.1.113883.12.292
				is the correct OID for CVX. $sdaCodingStandard will get the old OID
				when the SDA streamlet SDACodingStandard actually has the old OID,
				or when the HS OID Registry still has the old OID entered for CVX.
			-->
      <!--
				StructuredMapping: immunization-manufacturedMaterial
				
				Field
				Path: manufacturedProduct/manufacturedMaterial/code/@code
				Source: Code
				Source: Code/text()
				Note  : The code element is exported with attributes only when the SDA OrderItem SDACodingStandard indicates CVX.
				
				Field
				Path: manufacturedProduct/manufacturedMaterial/code/@displayName
				Source: Description
				Source: Description/text()
				Note  : The code element is exported with attributes only when the SDA OrderItem SDACodingStandard indicates CVX.
				
				Field
				Path: manufacturedProduct/manufacturedMaterial/code/translation/@code
				Source: Code
				Source: Code/text()
				Note  : The code translation element is exported only when the SDA OrderItem SDACodingStandard indicates RXNORM.
				
				Field
				Path: manufacturedProduct/manufacturedMaterial/code/translation/@displayName
				Source: Description
				Source: Description/text()
				Note  : The code translation element is exported only when the SDA OrderItem SDACodingStandard indicates RXNORM.
				
				Field
				Path: manufacturedProduct/manufacturedMaterial/name/text()
				Source: Description
				Source: Description/text()
			-->
      <xsl:choose>
        <xsl:when test="$sdaCodingStandardOID = $cvxOID or $sdaCodingStandardOID = '2.16.840.1.113883.6.59'">
          <code code="{Code/text()}" codeSystem="{$cvxOID}" codeSystemName="{$cvxName}" displayName="{$description}">
            <originalText>
              <reference value="{$narrativeLink}"/>
            </originalText>
          </code>
        </xsl:when>
        <xsl:when test="$sdaCodingStandardOID = $rxNormOID or $sdaCodingStandardOID = $ndcOID">
          <code nullFlavor="UNK">
            <originalText>
              <reference value="{$narrativeLink}"/>
            </originalText>
            <translation code="{Code/text()}" codeSystem="{$sdaCodingStandardOID}" codeSystemName="{SDACodingStandard/text()}"
              displayName="{$description}"/>
          </code>
        </xsl:when>
        <xsl:otherwise>
          <code nullFlavor="UNK">
            <originalText>
              <reference value="{$narrativeLink}"/>
            </originalText>
            <translation nullFlavor="UNK"/>
          </code>
        </xsl:otherwise>
      </xsl:choose>
      <name>
        <xsl:choose>
          <xsl:when test="string-length($description)">
            <xsl:value-of select="$description"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'Unknown Immunization'"/>
          </xsl:otherwise>
        </xsl:choose>
      </name>
      <!--
				Field : Immunization LotNumber
				Target: manufacturedMaterial/lotNumberText
				Source: HS.SDA3.Administration LotNumber
				Source: Administrations/Administration/LotNumber
			-->
      <xsl:for-each select="../Administrations/Administration">
        <lotNumberText>
          <xsl:choose>
            <xsl:when test="LotNumber">
              <xsl:value-of select="LotNumber"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="nullFlavor">NI</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </lotNumberText>
      </xsl:for-each>
    </manufacturedMaterial>
  </xsl:template>

  <xsl:template match="Vaccination" mode="eI-observation-immunizationStatus">
    <entryRelationship typeCode="REFR" inversionInd="false">
      <observation classCode="OBS" moodCode="EVN">
        <!-- All codes herein are fixed, not derived from the source document. -->
        <xsl:call-template name="eI-templateIds-immunizationStatusObservation"/>

        <code code="33999-4" displayName="Status" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
        <statusCode code="completed"/>

        <!-- Status Detail:  Hard-coded to "active" for an immunization -->
        <xsl:variable name="statusInformation">
          <Status xmlns="">
            <SDACodingStandard>
              <xsl:value-of select="$snomedName"/>
            </SDACodingStandard>
            <Code>55561003</Code>
            <Description>Active</Description>
          </Status>
        </xsl:variable>

        <xsl:apply-templates select="exsl:node-set($statusInformation)/Status" mode="fn-value-CE"/>
      </observation>
    </entryRelationship>
  </xsl:template>

  <xsl:template match="Status" mode="eI-immunization-statusDescription">
    <xsl:choose>
      <xsl:when test="text() = 'D'"><xsl:text>Aborted</xsl:text></xsl:when>
      <xsl:when test="text() = 'IP'"><xsl:text>Active</xsl:text></xsl:when>
      <xsl:when test="text() = 'C'"><xsl:text>Cancelled</xsl:text></xsl:when>
      <xsl:when test="text() = 'H'"><xsl:text>Held</xsl:text></xsl:when>
      <xsl:when test="text() = 'INT'"><xsl:text>New</xsl:text></xsl:when>
      <xsl:when test="text() = 'R'"><xsl:text>Obsolete</xsl:text></xsl:when>
      <xsl:otherwise><xsl:text>Completed</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Status" mode="eI-statusCode-immunization">
    <!--
					Field : Immunization status code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/statusCode
					Source: HS.SDA3.AbstractOrder Status
					Source: /Container/Vaccinations/Vaccination/Status
					Note  : 1- and 2-letter codes from SDA are expanded to a word
				-->
    <statusCode>
      <xsl:attribute name="code">
        <xsl:choose>
          <xsl:when test="text() = 'D'">aborted</xsl:when>
          <xsl:when test="text() = 'IP'">active</xsl:when>
          <xsl:when test="text() = 'C'">cancelled</xsl:when>
          <xsl:when test="text() = 'H'">held</xsl:when>
          <xsl:when test="text() = 'INT'">new</xsl:when>
          <xsl:when test="text() = 'R'">obsolete</xsl:when>
          <xsl:otherwise>completed</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </statusCode>
  </xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->

  <xsl:template name="eI-templateIds-immunizationAdministration">
    <templateId root="{$ccda-ImmunizationActivity}"/>
    <templateId root="{$ccda-ImmunizationActivity}" extension="2015-08-01"/>
  </xsl:template>

  <xsl:template name="eI-templateIds-manufacturedProduct-Immunization">
    <templateId root="{$ccda-ImmunizationMedicationInformation}"/>
    <templateId root="{$ccda-ImmunizationMedicationInformation}" extension="2014-06-09"/>
  </xsl:template>

  <xsl:template name="eI-templateIds-immunizationStatusObservation">
    <xsl:if test="$hl7-CCD-StatusObservation">
      <templateId root="{$hl7-CCD-StatusObservation}"/>
      <templateId root="{$hl7-CCD-StatusObservation}" extension="2015-08-01"/>
    </xsl:if>
    <xsl:if test="$hl7-CCD-MedicationStatusObservation">
      <templateId root="{$hl7-CCD-MedicationStatusObservation}"/>
      <templateId root="{$hl7-CCD-MedicationStatusObservation}" extension="2015-08-01"/>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
