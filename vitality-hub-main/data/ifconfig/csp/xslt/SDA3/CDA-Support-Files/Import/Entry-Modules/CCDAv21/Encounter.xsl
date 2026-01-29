<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="hl7 sdtc xsi exsl">
  <!-- AlsoInclude: HospitalDischargeInstructions.xsl Instructions.xsl Payers.xsl ReasonForVisit.xsl (these are all Section modules) -->

  <xsl:key name="participantsByTypeCode" match="hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter/hl7:encounterParticipant" use="@typeCode"/>
  <xsl:key name="participantsByTypeCode" match="/hl7:ClinicalDocument" use="'NEVER_MATCH_THIS!'"/>
  <!-- Second line the above key is to ensure that the "key table" is populated
       with at least one row, but we never want to retrieve that row. -->

  <xsl:template match="hl7:encompassingEncounter" mode="eE-DefaultEncounter">
	    <!-- DefaultEncounter imports the CDA encompassingEncounter. -->
	    <!--
				$encounterIDTemp is used as an intermediate so that
				$encounterID can be set such that "000nnn" does NOT
				match "nnn" when comparing encounter numbers.
			<xsl:variable name="encounterIDTemp"><xsl:apply-templates select="." mode="fn-S-formatEncounterId"/></xsl:variable>
			<xsl:variable name="encounterID" select="string($encounterIDTemp)"/> 
		-->

		<!--
			Check which data to import to Encounters/Encounter/EnteredBy and EnteredAt.
			If participant with typeCode CALLBCK exists, it takes precedence over Encounter/Author with typeCode AUT.
		-->
		<xsl:variable name="hasParticipantCALLBCK" select="string-length(../../hl7:participant[@typeCode='CALLBCK']/hl7:associatedEntity/hl7:associatedPerson/hl7:name/hl7:family/text()) > 0"/>

	    <Encounters>
	      <Encounter>

	        <!--
					Field : Encompassing Encounter Number
					Target: HS.SDA3.Encounter EncounterNumber
					Target: /Container/Encounters/Encounter/EncounterNumber
					Source: /ClinicalDocument/componentOf/encompassingEncounter/id[2]/@extension
					Note  : For import, if CDA id[2]/@extension is not
							present then CDA id[2]/@root is imported to
							SDA EncounterNumber.
			-->
	        <EncounterNumber>
	          <xsl:apply-templates select="." mode="fn-S-formatEncounterId"/>
	        </EncounterNumber>

			<!--
					Field : Encompassing Encounter Number Assigning Authority
					Target: HS.SDA3.Encounter EncounterNumberAssigningAuthority
					Target: /Container/Encounters/Encounter/EncounterNumberAssigningAuthority
					Source: /ClinicalDocument/componentOf/encompassingEncounter/id[2]/@root
			-->
			<EncounterNumberAssigningAuthority>
				<xsl:value-of select="hl7:id/@root"/>
			</EncounterNumberAssigningAuthority>

	        <xsl:apply-templates select="hl7:priorityCode" mode="eE-AdmissionType"/>

	        <!--
					Field : Encompassing Encounter Type
					Target: HS.SDA3.Encounter EncounterType
					Target: /Container/Encounters/Encounter/EncounterType
					Source: /ClinicalDocument/componentOf/encompassingEncounter/code/@code
					Note  : SDA EncounterType is a string property derived
							from the CDA coded encounter type information.
							Only values of E, I, or O are imported.  The
							logic is based on definitions in ImportProfile.xsl
							under variable encountersImportConfiguration.
			-->
	        <!--
					hl7:code in CDA encompassingEncounter is required
					to be Patient Class (EMER, IMP, AMB).  There is
					no Encounter Type in CDA encompassingEncounter,
					so without it, Patient Class is the closest thing
					there is.
			-->
	        <EncounterType>
	          <xsl:apply-templates select="hl7:code" mode="eE-EncounterType"/>
	        </EncounterType>

	        <!--
					Field : Encompassing Encounter Coded Type
					Target: HS.SDA3.Encounter EncounterCodedType
					Target: /Container/Encounters/Encounter/EncounterCodedType
					Source: /ClinicalDocument/componentOf/encompassingEncounter/code
					StructuredMappingRef: CodeTableDetail
					Note  : SDA EncounterCodedType is a coded element imported
							from the CDA coded encounter type information.
			-->
	        <xsl:apply-templates select="hl7:code" mode="eE-EncounterCodedType"/>

	        <!--
					Field : Encompassing Encounter Admitting Clinician
					Target: HS.SDA3.Encounter AdmittingClinician
					Target: /Container/Encounters/Encounter/AdmittingClinician
					Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode = 'ADM']
					StructuredMappingRef: DoctorDetail
			-->
	        <xsl:apply-templates select="hl7:encounterParticipant[@typeCode = 'ADM']" mode="fn-AdmittingClinician"/>

	        <!--
					Field : Encompassing Encounter Attending Clinicians
					Target: HS.SDA3.Encounter AttendingClinicians
					Target: /Container/Encounters/Encounter/AttendingClinicians
					Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode = 'ATND']
					StructuredMappingRef: AttendingClinicians-NoFunction
			-->
	        <xsl:apply-templates select="." mode="fn-AttendingClinicians"/>

	        <!--
					Field : Encompassing Encounter Consulting Clinicians
					Target: HS.SDA3.Encounter ConsultingClinicians
					Target: /Container/Encounters/Encounter/ConsultingClinicians
					Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode = 'CON']
					StructuredMappingRef: ConsultingClinicians-NoFunction
			-->
	        <xsl:apply-templates select="." mode="fn-ConsultingClinicians"/>

	        <!--
					Field : Encompassing Encounter Referring Clinician
					Target: HS.SDA3.Encounter ReferringClinician
					Target: /Container/Encounters/Encounter/ReferringClinician
					Source: /ClinicalDocument/componentOf/encompassingEncounter/encounterParticipant[@typeCode = 'REF']
					StructuredMappingRef: DoctorDetail
			-->
	        <xsl:apply-templates select="hl7:encounterParticipant[@typeCode = 'REF']" mode="fn-ReferringClinician"/>

	        <!--
				If encompassingEncounter has hl7:location, then use the generic fn-HealthCareFacility
				template to use hl7:location as the source for SDA3 HealthCareFacility/Organization.
				Otherwise, use the eE-encounter-HealthCareFacility template to use either hl7:id/@root
				or the derived SendingFacility code as the source.
			-->
	        <xsl:choose>
	          <xsl:when test="hl7:location">
	            <xsl:apply-templates select="hl7:location" mode="fn-HealthCareFacility"/>
				<Locations>
					<xsl:apply-templates select="hl7:location" mode="fn-HealthCareFacilityLocation"/>
				</Locations>
	          </xsl:when>
	          <xsl:otherwise>
	            <xsl:apply-templates select="." mode="eE-encounter-HealthCareFacility"/>
	          </xsl:otherwise>
	        </xsl:choose>

	        <!-- Visit Description -->
	        <xsl:apply-templates select="$input" mode="sRFV-ReasonForVisitSection"/>

	        <!--
					Field : Encounter MRN
					Target: HS.SDA3.Encounter EncounterMRN
					Target: /Container/Encounters/Encounter/EncounterMRN
					Source: /ClinicalDocument/recordTarget/patientRole/id[not(@root='2.16.840.1.113883.4.1')]/@extension
			-->
	        <xsl:apply-templates select="." mode="eE-EncounterMRN"/>

	        <!--
					Field : Encompassing Encounter Start Date/Time
					Target: HS.SDA3.Encounter FromTime
					Target: /Container/Encounters/Encounter/FromTime
					Source: /ClinicalDocument/componentOf/encompassingEncounter/effectiveTime/low/@value
			-->
	        <xsl:variable name="fromTime">
	          <xsl:choose>
	            <xsl:when test="hl7:effectiveTime/hl7:low/@value">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/hl7:low/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="hl7:effectiveTime/hl7:low/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="not(hl7:effectiveTime/hl7:low/@value) and not(hl7:effectiveTime/hl7:high/@value) and hl7:effectiveTime/@value">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="hl7:effectiveTime/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	          </xsl:choose>
	        </xsl:variable>

	        <!--
					Field : Encompassing Encounter End Date/Time
					Target: HS.SDA3.Encounter ToTime
					Target: /Container/Encounters/Encounter/ToTime
					Source: /ClinicalDocument/componentOf/encompassingEncounter/effectiveTime/high/@value
			-->
	        <xsl:variable name="toTime">
	          <xsl:choose>
	            <xsl:when test="hl7:effectiveTime/hl7:high/@value">
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="hl7:effectiveTime/hl7:high/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="not(hl7:effectiveTime/hl7:low/@value) and not(hl7:effectiveTime/hl7:high/@value) and hl7:effectiveTime/@value">
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="hl7:effectiveTime/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	          </xsl:choose>
	        </xsl:variable>

	        <xsl:call-template name="eE-detailPart2">
	          <xsl:with-param name="fromTime" select="$fromTime"/>
	          <xsl:with-param name="toTime" select="$toTime"/>
	        </xsl:call-template>

	        <!--
					Field : Encompassing Encounter RecommendationsProvided
					Target: HS.SDA3.Encounter 
					Target: /Container/Encounters/Encounter/RecommendationsProvided
					Source: /ClinicalDocument/component/structuredBody/component/section[hl7:templateId/@root=$ccda-InstructionsSection]
			-->
			<xsl:call-template name="eE-Instructions"/>

			<xsl:choose>
				<xsl:when test="not($hasParticipantCALLBCK)">

			        <!--
							Field : Encompassing Encounter Author EnteredBy
							Target: HS.SDA3.Encounter EnteredBy
							Target: /Container/Encounters/Encounter/EnteredBy
							Source: /ClinicalDocument/author[not(assignedAuthor/assignedAuthoringDevice)]
							StructuredMappingRef: EnteredByDetail
							Note  : When importing CDA encompassingEncounter to SDA
									Encounter, CDA document-level author is imported
									to SDA Encounter EnteredBy.
					-->
			        <xsl:apply-templates select="$defaultAuthorRootPath" mode="fn-EnteredBy"/>

			        <!--
							Field : Encompassing Encounter Author EnteredAt
							Target: HS.SDA3.Encounter EnteredAt
							Target: /Container/Encounters/Encounter/EnteredAt
							Source: /ClinicalDocument/author[not(assignedAuthor/assignedAuthoringDevice)]
							StructuredMappingRef: EnteredAt
							Note  : When importing CDA encompassingEncounter to SDA
									Encounter, CDA document-level author is
									imported to SDA Encounter EnteredAt.							
					-->
			        <xsl:apply-templates select="$defaultAuthorRootPath" mode="fn-EnteredAt"/>

			        <!--
							Field : Encompassing Encounter Author Time
							Target: HS.SDA3.Encounter EnteredOn
							Target: /Container/Encounters/Encounter/EnteredOn
							Source: /ClinicalDocument/author[not(assignedAuthor/assignedAuthoringDevice)]/time/@value
							Note  : When importing CDA encompassingEncounter to SDA
									Encounter, CDA document-level author/time is
									imported to SDA Encounter EnteredOn.
					-->
			        <xsl:apply-templates select="$defaultAuthorRootPath[1]/hl7:time" mode="fn-EnteredOn"/>		
			        	        
		    	</xsl:when>
		    	<xsl:otherwise>
					<xsl:call-template name="eE-encounter-ParticipantCallback"/>	 
		    	</xsl:otherwise>
	    	</xsl:choose>


	        <xsl:if test="string-length($fromTime)">
	          <FromTime>
	            <xsl:value-of select="$fromTime"/>
	          </FromTime>
	        </xsl:if>
	        <xsl:if test="string-length($toTime)">
	          <ToTime>
	            <xsl:value-of select="$toTime"/>
	          </ToTime>
	        </xsl:if>

	        <!--
					Field : Encompassing Encounter Number
					Target: HS.SDA3.Encounter ExternalId
					Target: /Container/Encounters/Encounter/ExternalId
					Source: /ClinicalDocument/componentOf/encompassingEncounter/id[1]
					StructuredMappingRef: ExternalId
			-->
	        <xsl:apply-templates select="." mode="fn-ExternalId"/>

	        <!-- Custom SDA Data-->
	        <xsl:apply-templates select="." mode="eE-ImportCustom-Encounter"/>
	      </Encounter>
	    </Encounters>
  </xsl:template>

  <xsl:template match="hl7:encounter" mode="eE-OverriddenEncounter">
	    <!-- OverriddenEncounter imports an encounter that is found only in the CDA Encounters section. -->		

	    <xsl:variable name="hasParticipantCALLBCK" select="string-length(../../../../../../hl7:participant[@typeCode='CALLBCK']/hl7:associatedEntity/hl7:associatedPerson/hl7:name/hl7:family/text()) > 0"/>

	    <Encounters>
	      <Encounter>

	        <!--
					Field : Encounter Number
					Target: HS.SDA3.Encounter EncounterNumber
					Target: /Container/Encounters/Encounter/EncounterNumber
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/id[2]/@extension
					Note  : For import, if CDA id[2]/@extension is not
							present then CDA id[2]/@root is imported to
							SDA EncounterNumber.
			-->
	        <EncounterNumber>
	          <xsl:apply-templates select="." mode="fn-S-formatEncounterId"/>
	        </EncounterNumber>

	        <!--
					Field : Encounter Admission Type
					Target: HS.SDA3.Encounter AdmissionType
					Target: /Container/Encounters/Encounter/AdmissionType
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/priorityCode
					StructuredMappingRef: CodeTableDetail
			-->
	        <xsl:apply-templates select="hl7:priorityCode" mode="eE-AdmissionType"/>

	        <!--
					Field : Encounter Type
					Target: HS.SDA3.Encounter EncounterType
					Target: /Container/Encounters/Encounter/EncounterType
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/code/@code
					Note  : SDA EncounterType is a string property derived
							from the CDA coded encounter type information.
							Only values of E, I, or O are imported.  The
							logic is based on definitions in ImportProfile.xsl
							under variable encountersImportConfiguration.
			-->
	        <EncounterType>
	          <xsl:apply-templates select="hl7:code" mode="eE-EncounterType"/>
	        </EncounterType>

	        <!--
					Field : Encounter Coded Type
					Target: HS.SDA3.Encounter EncounterCodedType
					Target: /Container/Encounters/Encounter/EncounterCodedType
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/code
					StructuredMappingRef: CodeTableDetail
					Note  : SDA EncounterCodedType is a coded element imported
							from the CDA coded encounter type information.
			-->
	        <xsl:apply-templates select="hl7:code" mode="eE-EncounterCodedType"/>

	        <!--
					Field : Encounter Attending Clinicians
					Target: HS.SDA3.Encounter AttendingClinicians
					Target: /Container/Encounters/Encounter/AttendingClinicians
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/performer[@typeCode = 'PRF']
					StructuredMappingRef: AttendingClinicians-NoFunction
			-->
	        <xsl:apply-templates select="." mode="fn-AttendingClinicians"/>

	        <!-- HS.SDA3.Encounter ConsultingClinicians -->
	        <!-- Consulting Clinicians from informant -->
	        <xsl:apply-templates select="." mode="eE-ConsultingClinicians-informant"/>

	        <!-- HealthCareFacility -->
	        <!--
					Field : Encounter HealthCare Facility
					Target: HS.SDA3.Encounter HealthCareFacility
					Target: /Container/Encounters/Encounter/HealthCareFacility
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/participant/participantRole/code/@codeSystem
			-->
	        <xsl:apply-templates select="." mode="eE-encounter-HealthCareFacility"/>

	        <!--
					Field : Encounter MRN
					Target: HS.SDA3.Encounter EncounterMRN
					Target: /Container/Encounters/Encounter/EncounterMRN
					Source: /ClinicalDocument/recordTarget/patientRole/id[not(@root='2.16.840.1.113883.4.1')]/@extension
			-->
	        <xsl:apply-templates select="." mode="eE-EncounterMRN"/>

	        <!-- Visit Description -->
	        <xsl:apply-templates select="$input" mode="sRFV-ReasonForVisitSection"/>

	        <!--
						Field : Encounter Start Date/Time
						Target: HS.SDA3.Encounter FromTime
						Target: /Container/Encounters/Encounter/FromTime
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/effectiveTime/low/@value
			-->
	        <xsl:variable name="fromTime">
	          <xsl:choose>
	            <xsl:when test="hl7:effectiveTime/hl7:low/@value">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/hl7:low/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="hl7:effectiveTime/hl7:low/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="not(hl7:effectiveTime/hl7:low/@value) and not(hl7:effectiveTime/hl7:high/@value) and hl7:effectiveTime/@value">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="hl7:effectiveTime/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	          </xsl:choose>
	        </xsl:variable>
	        <!--
						Field : Encounter End Date/Time
						Target: HS.SDA3.Encounter ToTime
						Target: /Container/Encounters/Encounter/ToTime
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/effectiveTime/high/@value
			-->
	        <xsl:variable name="toTime">
	          <xsl:choose>
	            <xsl:when test="hl7:effectiveTime/hl7:high/@value">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/hl7:high/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="hl7:effectiveTime/hl7:high/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="not(hl7:effectiveTime/hl7:low/@value) and not(hl7:effectiveTime/hl7:high/@value) and hl7:effectiveTime/@value">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:effectiveTime/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="hl7:effectiveTime/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	          </xsl:choose>
	        </xsl:variable>

	        <xsl:call-template name="eE-detailPart2">
	          <xsl:with-param name="fromTime" select="$fromTime"/>
	          <xsl:with-param name="toTime" select="$toTime"/>
	        </xsl:call-template>

	        <!--
					Field : Encounter RecommendationsProvided
					Target: HS.SDA3.Encounter 
					Target: /Container/Encounters/Encounter/RecommendationsProvided
					Source: /ClinicalDocument/component/structuredBody/component/section[hl7:templateId/@root=$ccda-InstructionsSection]
			-->
	        <xsl:call-template name="eE-Instructions"/>

			<xsl:choose>
				<xsl:when test="not($hasParticipantCALLBCK)">

			        <!--
							Field : Encounter Author EnteredBy
							Target: HS.SDA3.Encounter EnteredBy
							Target: /Container/Encounters/Encounter/EnteredBy
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/author
							StructuredMappingRef: EnteredByDetail
					-->
			        <xsl:apply-templates select="." mode="fn-EnteredBy"/>

			        <!--
							Field : Encounter Author EnteredAt
							Target: HS.SDA3.Encounter EnteredAt
							Target: /Container/Encounters/Encounter/EnteredAt
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/author
							StructuredMappingRef: EnteredAt
					-->
			        <xsl:apply-templates select="." mode="fn-EnteredAt"/>

			        <!--
							Field : Encounter Author Time
							Target: HS.SDA3.Encounter EnteredOn
							Target: /Container/Encounters/Encounter/EnteredOn
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/author/time/@value
					-->					
			        <xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>		
			        	        
		    	</xsl:when>
		    	<xsl:otherwise>
			        <xsl:call-template name="eE-encounter-ParticipantCallback"/>		
		    	</xsl:otherwise>
	    	</xsl:choose>	        

	        <xsl:if test="string-length($fromTime)">
	          <FromTime>
	            <xsl:value-of select="$fromTime"/>
	          </FromTime>
	        </xsl:if>
	        <xsl:if test="string-length($toTime)">
	          <ToTime>
	            <xsl:value-of select="$toTime"/>
	          </ToTime>
	        </xsl:if>

	        <!--
					Field : Encounter Number
					Target: HS.SDA3.Encounter ExternalId
					Target: /Container/Encounters/Encounter/ExternalId
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/id
					StructuredMappingRef: ExternalId
			-->
	        <xsl:apply-templates select="." mode="fn-ExternalId"/>

	        <!-- Custom SDA Data-->
	        <xsl:apply-templates select="." mode="eE-ImportCustom-Encounter"/>
	      </Encounter>
	    </Encounters>
  </xsl:template>

  <xsl:template match="hl7:ClinicalDocument" mode="eE-DuplicatedEncounter">
	    <xsl:param name="duplicatedEncounterOrg"/>
	    <xsl:param name="duplicatedEncounterID"/>
	    <!--
				DuplicatedEncounter imports an encounter that is found both
				in encompassingEncounter and in the Encounters section.
		-->	

	    <xsl:variable name="overriddenEncounterRootPath"
	      select="
	        (key('sectionsByRoot', $ccda-EncountersSectionEntriesOptional) | key('sectionsByRoot', $ccda-EncountersSectionEntriesRequired))/hl7:entry/hl7:encounter[(hl7:id/@extension = $duplicatedEncounterID and hl7:id/@root = $duplicatedEncounterOrg)
	        or (not(hl7:id/@extension) and hl7:id/@root = $duplicatedEncounterID)]"/>
	    <xsl:variable name="encompassingEncounterRootPath" select="hl7:componentOf/hl7:encompassingEncounter"/>
	    <xsl:variable name="encounterID" select="string($duplicatedEncounterID)"/>

	    <xsl:variable name="hasParticipantCALLBCK" select="string-length(./hl7:participant[@typeCode='CALLBCK']/hl7:associatedEntity/hl7:associatedPerson/hl7:name/hl7:family/text()) > 0"/>

	    <Encounters>    	
	      <Encounter>
	        <!-- Encounter ID - <id> should be same between Encounters section and encompassing -->
	        <EncounterNumber>
	          <xsl:apply-templates select="$overriddenEncounterRootPath" mode="fn-S-formatEncounterId"/>
	        </EncounterNumber>

			<!-- EncounterNumberAssigningAuthority -->
			<EncounterNumberAssigningAuthority>
	          <xsl:value-of select="$encompassingEncounterRootPath/hl7:id/@root"/>
	        </EncounterNumberAssigningAuthority>


	        <!-- Admission Type -->
	        <xsl:apply-templates select="$overriddenEncounterRootPath/hl7:priorityCode" mode="eE-AdmissionType"/>

	        <!--
				The value to import to EncounterType is derived
				here so it can be used as part of the logic for
				EndTime as well as for the actual export of
				EncounterType.
			-->
	        <xsl:variable name="encounterType">
	          <xsl:choose>
	            <xsl:when test="$overriddenEncounterRootPath/hl7:code">
	              <xsl:apply-templates select="$overriddenEncounterRootPath/hl7:code" mode="eE-EncounterType"/>
	            </xsl:when>
	            <xsl:otherwise>
	              <!--
							hl7:code in CDA encompassingEncounter is required
							to be Patient Class (EMER, IMP, AMB).  There is
							no Encounter Type in CDA encompassingEncounter,
							so without it, Patient Class is the closest thing
							there is.
				  -->
	              <xsl:apply-templates select="$encompassingEncounterRootPath/hl7:code" mode="eE-EncounterType"/>
	            </xsl:otherwise>
	          </xsl:choose>
	        </xsl:variable>

	        <!-- Encounter Type -->
	        <EncounterType>
	          <xsl:value-of select="$encounterType"/>
	        </EncounterType>

	        <!-- Encounter Coded Type -->
	        <xsl:choose>
	          <xsl:when test="$overriddenEncounterRootPath/hl7:code">
	            <xsl:apply-templates select="$overriddenEncounterRootPath/hl7:code" mode="eE-EncounterCodedType"/>
	          </xsl:when>
	          <xsl:otherwise>
	           <!--
						hl7:code in CDA encompassingEncounter is required
						to be Patient Class (EMER, IMP, AMB).  There is
						no Encounter Type in CDA encompassingEncounter,
						so without it, Patient Class is the closest thing
						there is.
				-->
	            <xsl:apply-templates select="$encompassingEncounterRootPath/hl7:code" mode="eE-EncounterCodedType"/>
	          </xsl:otherwise>
	        </xsl:choose>

	        <!--
				HS.SDA3.Encounter AdmittingClinician
				HS.SDA3.Encounter AttendingClinicians
				HS.SDA3.Encounter ReferringClinician
				HS.SDA3.Encounter ConsultingClinicians
			-->
	        <xsl:apply-templates select="key('participantsByTypeCode', 'ADM')" mode="fn-AdmittingClinician"/>
	        <xsl:apply-templates select="." mode="eE-AttendingCliniciansDuplicate">
	          <xsl:with-param name="overriddenEncounterRootPath" select="$overriddenEncounterRootPath"/>
	          <xsl:with-param name="encompassingEncounterRootPath" select="$encompassingEncounterRootPath"/>
	        </xsl:apply-templates>
	        <xsl:apply-templates select="$encompassingEncounterRootPath" mode="fn-ConsultingClinicians"/>
	        <xsl:apply-templates select="key('participantsByTypeCode', 'REF')" mode="fn-ReferringClinician"/>

	        <!-- 
				HS.SDA3.Encounter HealthCareFacility
				
				CDA to SDA import of duplicated encounter checks
				encompassingEncounter/location first.  If not
				found there, it instead uses
				encounter/participant[@typeCode='LOC']/participantRole[@classCode='SDLOC'].
			-->
	        <xsl:choose>
	          <xsl:when test="$encompassingEncounterRootPath/hl7:location">
	            <xsl:apply-templates select="$encompassingEncounterRootPath/hl7:location" mode="fn-HealthCareFacility"/>
				<Locations>
					<xsl:apply-templates select="$encompassingEncounterRootPath/hl7:location" mode="fn-HealthCareFacilityLocation"/>
				</Locations>
	          </xsl:when>
	          <xsl:otherwise>
	            <xsl:apply-templates select="$overriddenEncounterRootPath" mode="eE-encounter-HealthCareFacility"/>
	          </xsl:otherwise>
	        </xsl:choose>

	        <!-- Visit Description -->
	        <xsl:apply-templates select="$input" mode="sRFV-ReasonForVisitSection"/>

	        <!-- Encounter MRN -->
	        <xsl:apply-templates select="." mode="eE-EncounterMRNDuplicate">
	          <xsl:with-param name="overriddenEncounterRootPath" select="$overriddenEncounterRootPath"/>
	          <xsl:with-param name="encompassingEncounterRootPath" select="$encompassingEncounterRootPath"/>
	        </xsl:apply-templates>

	        <!--
				HS.SDA3.Encounter FromTime
				HS.SDA3.Encounter ToTime
				HS.SDA3.Encounter EndTime
			-->
	        <xsl:variable name="hasOverrideEffTime" select="string-length($overriddenEncounterRootPath/hl7:effectiveTime/@value) > 0"/>
	        <xsl:variable name="hasOverrideLowTime" select="string-length($overriddenEncounterRootPath/hl7:effectiveTime/hl7:low/@value) > 0"/>
	        <xsl:variable name="hasOverrideHighTime" select="string-length($overriddenEncounterRootPath/hl7:effectiveTime/hl7:high/@value) > 0"/>
	        <xsl:variable name="hasEncompEffTime" select="string-length($encompassingEncounterRootPath/hl7:effectiveTime/@value) > 0"/>
	        <xsl:variable name="hasEncompLowTime" select="string-length($encompassingEncounterRootPath/hl7:effectiveTime/hl7:low/@value) > 0"/>
	        <xsl:variable name="hasEncompHighTime" select="string-length($encompassingEncounterRootPath/hl7:effectiveTime/hl7:high/@value) > 0"/>
	        <xsl:variable name="fromTime">
	          <xsl:choose>
	            <xsl:when test="$hasOverrideLowTime">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', $overriddenEncounterRootPath/hl7:effectiveTime/hl7:low/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="$overriddenEncounterRootPath/hl7:effectiveTime/hl7:low/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="not($hasOverrideLowTime) and not($hasOverrideHighTime) and $hasOverrideEffTime">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', $overriddenEncounterRootPath/hl7:effectiveTime/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="$overriddenEncounterRootPath/hl7:effectiveTime/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="$hasEncompLowTime">
	                <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="$encompassingEncounterRootPath/hl7:effectiveTime/hl7:low/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="not($hasEncompLowTime) and not($hasEncompHighTime) and $hasEncompEffTime">
	              <!--<xsl:value-of select="isc:evaluate('xmltimestamp', $encompassingEncounterRootPath/hl7:effectiveTime/@value)"/>-->
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="$encompassingEncounterRootPath/hl7:effectiveTime/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	          </xsl:choose>
	        </xsl:variable>

	        <xsl:variable name="toTime">
	          <xsl:choose>
	            <xsl:when test="$hasOverrideHighTime">
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="$overriddenEncounterRootPath/hl7:effectiveTime/hl7:high/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="not($hasOverrideLowTime) and not($hasOverrideHighTime) and $hasOverrideEffTime">
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="$overriddenEncounterRootPath/hl7:effectiveTime/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="$hasEncompHighTime">
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="$encompassingEncounterRootPath/hl7:effectiveTime/hl7:high/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	            <xsl:when test="not($hasEncompLowTime) and not($hasEncompHighTime) and $hasEncompEffTime">
	              <xsl:call-template name="fn-S-timestamp">
	                <xsl:with-param name="inputString" select="$encompassingEncounterRootPath/hl7:effectiveTime/@value"/>
	              </xsl:call-template>
	            </xsl:when>
	          </xsl:choose>
	        </xsl:variable>

	        <xsl:call-template name="eE-detailPart2">
	          <xsl:with-param name="fromTime" select="$fromTime"/>
	          <xsl:with-param name="toTime" select="$toTime"/>
	        </xsl:call-template>

	        <!--
					Field : Encounter RecommendationsProvided
					Target: HS.SDA3.Encounter 
					Target: /Container/Encounters/Encounter/RecommendationsProvided
					Source: /ClinicalDocument/component/structuredBody/component/section[hl7:templateId/@root=$ccda-InstructionsSection]
			-->
	        <xsl:call-template name="eE-Instructions"/>

			<xsl:choose>
				<xsl:when test="not($hasParticipantCALLBCK)">

			        <!--
							Field : Encounter Author
							Target: HS.SDA3.Encounter EnteredBy
							Target: /Container/Encounters/Encounter/EnteredBy
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/author
							StructuredMappingRef: EnteredByDetail
					-->
			        <xsl:apply-templates select="$overriddenEncounterRootPath" mode="fn-EnteredBy"/>

			        <!--
							Field : Encounter EnteredAt
							Target: HS.SDA3.Encounter EnteredAt
							Target: /Container/Encounters/Encounter/EnteredAt
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/author
							StructuredMappingRef: EnteredAt
					-->
			        <xsl:apply-templates select="$overriddenEncounterRootPath" mode="fn-EnteredAt"/>

			        <!--
							Field : Encounter Author Time
							Target: HS.SDA3.Encounter EnteredOn
							Target: /Container/Encounters/Encounter/EnteredOn
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/entry/encounter/author/time/@value
					-->					
			        <xsl:choose>
			          <xsl:when test="string-length($overriddenEncounterRootPath/hl7:author/hl7:time/@value)">
			            <xsl:apply-templates select="$overriddenEncounterRootPath/hl7:author/hl7:time" mode="fn-EnteredOn"/>
			          </xsl:when>
			          <xsl:otherwise>
			            <xsl:apply-templates select="$defaultAuthorRootPath[1]/hl7:time" mode="fn-EnteredOn"/>
			          </xsl:otherwise>
			        </xsl:choose>		
			        	        
		    	</xsl:when>
		    	<xsl:otherwise>
			        <xsl:call-template name="eE-encounter-ParticipantCallback"/>	
		    	</xsl:otherwise>
	    	</xsl:choose>	    	     

	        <xsl:if test="string-length($fromTime)">
	          <FromTime>
	            <xsl:value-of select="$fromTime"/>
	          </FromTime>
	        </xsl:if>
	        <xsl:if test="string-length($toTime)">
	          <ToTime>
	            <xsl:value-of select="$toTime"/>
	          </ToTime>
	        </xsl:if>

	        <!-- HS.SDA3.Encounter ExternalId -->
	        <!-- Override ExternalId with the <id> values from the source CDA - <id> should be same between Encounters section and encompassing -->
	        <xsl:apply-templates select="$overriddenEncounterRootPath" mode="fn-ExternalId"/>

	        <!-- Custom SDA Data-->
	        <xsl:apply-templates select="." mode="eE-ImportCustom-Encounter"/>
	      </Encounter>
	    </Encounters>
  </xsl:template>

  <xsl:template match="hl7:code" mode="eE-EncounterType">
    <!--
		EncounterType returns a string value derived from
		the CDA coded encounter type information.
	-->
    <!--
			If the CDA Encounter Type data has the No Code
			System OID in the first translation element
			(if any), then use the first translation element
			for import.
		-->
    <xsl:variable name="code">
      <xsl:choose>
        <xsl:when test="not(@code) and hl7:translation[1]/@code">
          <xsl:value-of select="hl7:translation[1]/@code"/>
        </xsl:when>
        <xsl:when test="hl7:translation[1]/@codeSystem = $noCodeSystemOID">
          <xsl:value-of select="hl7:translation[1]/@code"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@code"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="codeSystem">
      <xsl:choose>
        <xsl:when test="not(@code) and hl7:translation[1]/@codeSystem">
          <xsl:value-of select="hl7:translation[1]/@codeSystem"/>
        </xsl:when>
        <xsl:when test="hl7:translation[1]/@codeSystem = $noCodeSystemOID">
          <xsl:value-of select="$noCodeSystemOID"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@codeSystem"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!--
			The value generated here is intended for SDA
			EncounterType, which shoud only be E, I, or O.
			
			$encounterTypeMaps is based on definitions in
			ImportProfile.xsl, under variable
			encountersImportConfiguration.
		-->
    <xsl:choose>
      <xsl:when
        test="string-length($encounterTypeMaps/encounterTypeMap[CDACode/text() = $code and CDACodeSystem = $codeSystem]/SDAEncounterType/text())">
        <xsl:value-of select="$encounterTypeMaps/encounterTypeMap[CDACode/text() = $code and CDACodeSystem = $codeSystem]/SDAEncounterType/text()"/>
      </xsl:when>
      <xsl:when test="$code = 'AMB'">O</xsl:when>
      <xsl:when test="$code = 'IMP'">I</xsl:when>
      <xsl:when test="$code = 'EMER'">E</xsl:when>
      <xsl:otherwise>O</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="hl7:code" mode="eE-EncounterCodedType">
    <!--
		EncounterCodedType imports CDA coded encounter
		type information as an SDA coded element.
	-->
    <xsl:apply-templates select="." mode="fn-CodeTable">
      <xsl:with-param name="hsElementName" select="'EncounterCodedType'"/>
      <xsl:with-param name="importOriginalText" select="'1'"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Match could be whatever is passed into sE-Encounters -->
  <xsl:template match="*" mode="eE-AttendingCliniciansDuplicate">
    <xsl:param name="overriddenEncounterRootPath"/>
    <xsl:param name="encompassingEncounterRootPath"/>

    <!--
			AttendingCliniciansDuplicate de-duplicates the attending
			clinicians between the encompassingEncounter and the
			Encounters section encounter, based on assignedEntity/id.
		-->
    <xsl:if test="key('participantsByTypeCode', 'ATND') | $overriddenEncounterRootPath/hl7:performer[@typeCode = 'PRF']">
      <xsl:variable name="encompassingEncounterAttendingsIds">
        <xsl:for-each select="key('participantsByTypeCode', 'ATND')/hl7:assignedEntity">
          <xsl:value-of select="concat('|', hl7:id/@root, '/', hl7:id/@extension, '|')"/>
        </xsl:for-each>
      </xsl:variable>

      <AttendingClinicians>
        <xsl:apply-templates select="key('participantsByTypeCode', 'ATND')" mode="fn-W-CareProvider"/>
        <xsl:apply-templates
          select="
            $overriddenEncounterRootPath/hl7:performer[@typeCode = 'PRF'
            and not(string-length(hl7:assignedEntity/hl7:id/@root)
            and contains($encompassingEncounterAttendingsIds, concat('|', hl7:assignedEntity/hl7:id/@root, '/', hl7:assignedEntity/hl7:id/@extension, '|')))]"
          mode="fn-W-CareProvider"/>
      </AttendingClinicians>
    </xsl:if>
  </xsl:template>

  <xsl:template match="hl7:encounter | hl7:encompassingEncounter" mode="eE-EncounterMRN">
    <EncounterMRN>
      <!-- 2.16.840.1.113883.4.1 is the SSN OID -->
      <xsl:value-of select="$input/hl7:recordTarget/hl7:patientRole/hl7:id[not(@root = '2.16.840.1.113883.4.1')]/@extension"/>
    </EncounterMRN>
  </xsl:template>

  <xsl:template match="*" mode="eE-EncounterMRNDuplicate">
    <!-- Match could be whatever is passed into sE-Encounters -->
    <xsl:param name="overriddenEncounterRootPath"/>
    <xsl:param name="encompassingEncounterRootPath"/>

    <!-- HS.SDA3.Encounter EncounterMRN -->
    <!--
			EncounterMRNDuplicate checks the encompassingEncounter for
			the encounter-level MRN first, then checks the Encounters
			section encounter if necessary.  If not in either then gets
			EncounterMRN from the patient-level MRN.
		-->
    <EncounterMRN>
      <xsl:choose>
        <xsl:when test="string-length($encompassingEncounterRootPath/hl7:encounterParticipant/hl7:assignedEntity/sdtc:patient/sdtc:id/@extension)">
          <xsl:value-of select="$encompassingEncounterRootPath/hl7:encounterParticipant/hl7:assignedEntity/sdtc:patient/sdtc:id/@extension"/>
        </xsl:when>
        <xsl:when test="string-length($overriddenEncounterRootPath/hl7:informant/hl7:assignedEntity/sdtc:patient/sdtc:id/@extension)">
          <xsl:value-of select="$overriddenEncounterRootPath/hl7:informant/hl7:assignedEntity/sdtc:patient/sdtc:id/@extension"/>
        </xsl:when>
        <!-- 2.16.840.1.113883.4.1 is the SSN OID -->
        <xsl:otherwise>
          <xsl:value-of select="$input/hl7:recordTarget/hl7:patientRole/hl7:id[not(@root = '2.16.840.1.113883.4.1')]/@extension"/>
        </xsl:otherwise>
      </xsl:choose>
    </EncounterMRN>
  </xsl:template>


  <xsl:template match="hl7:priorityCode" mode="eE-AdmissionType">
    <xsl:apply-templates select="." mode="fn-CodeTable">
      <xsl:with-param name="hsElementName" select="'AdmissionType'"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="eE-encounter-HealthCareFacility">
    <!-- Match could be hl7:encounter or whatever is passed into sE-Encounters -->
    <!-- 
			CDA to SDA import of duplicated encounter checks
			encompassingEncounter/location first.  If not
			found there, it instead uses
			encounter/participant[@typeCode='LOC']/participantRole[@classCode='SDLOC'].
		-->
    <!--
			$organizationCode really should get a value. If it
			does not, then that indicates something wrong with
			the document itself since not even SendingFacility
			could be found.
		-->
    <xsl:variable name="organizationCode">
      <xsl:apply-templates select="." mode="eE-encounter-HealthCareFacility-OrganizationCode"/>
    </xsl:variable>

    <!--
			If location is present, then import HealthCareFacility Code,
			LocationType (if present), and Organization Code.
		-->
    <xsl:choose>
      <xsl:when test="hl7:participant[@typeCode = 'LOC']/hl7:participantRole[@classCode = 'SDLOC']">
        <HealthCareFacility>
          <Code>
            <xsl:apply-templates select="hl7:participant[@typeCode = 'LOC']/hl7:participantRole[@classCode = 'SDLOC']"
              mode="eE-encounter-HealthCareFacility-LocationCode"/>
          </Code>

          <xsl:if test="string-length($organizationCode)">
            <Organization>
              <Code>
                <xsl:value-of select="$organizationCode"/>
              </Code>
            </Organization>
          </xsl:if>

          <!-- Code system 2.16.840.1.113883.6.259 is HL7 Healthcare Service Location. -->
          <xsl:variable name="locationTypeCode">
            <xsl:choose>
              <xsl:when test="hl7:code/@codeSystem = '2.16.840.1.113883.6.259'">
                <xsl:choose>
                  <xsl:when test="hl7:code/@code = '1117-1'">CLINIC</xsl:when>
                  <xsl:when test="hl7:code/@code = '1160-1'">CLINIC</xsl:when>
                  <xsl:when test="hl7:code/@code = '1108-0'">ER</xsl:when>
                  <xsl:when test="hl7:code/@code = '1010-8'">DEPARTMENT</xsl:when>
                  <xsl:otherwise>OTHER</xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="contains('|CLINIC|ER|DEPARTMENT|WARD|OTHER|', concat('|', hl7:code/@code, '|'))">
                <xsl:value-of select="hl7:code/@code"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:if test="string-length($locationTypeCode)">
            <LocationType>
              <xsl:value-of select="$locationTypeCode"/>
            </LocationType>
          </xsl:if>
        </HealthCareFacility>
      </xsl:when>
      <!--
				Otherwise if $organizationCode has a value then use it
				for both Organization Code and HealthCareFacility Code.
	  -->
      <xsl:when test="string-length($organizationCode)">
        <HealthCareFacility>
          <Code>
            <xsl:value-of select="$organizationCode"/>
          </Code>
          <Organization>
            <Code>
              <xsl:value-of select="$organizationCode"/>
            </Code>
          </Organization>
        </HealthCareFacility>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="hl7:participantRole" mode="eE-encounter-HealthCareFacility-LocationCode">
    <xsl:choose>
      <xsl:when test="string-length(hl7:id/@extension)">
        <xsl:value-of select="hl7:id/@extension"/>
      </xsl:when>
      <xsl:when test="string-length(hl7:id/@root)">
        <xsl:apply-templates select="." mode="fn-code-for-oid">
          <xsl:with-param name="OID" select="hl7:id[1]/@root"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="string-length(hl7:playingEntity/hl7:name/text())">
        <xsl:value-of select="hl7:playingEntity/hl7:name/text()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="eE-encounter-HealthCareFacility-OrganizationCode">
    <!-- Match could be hl7:encounter or whatever is passed into sE-Encounters -->
    <!--
			hl7:id/@root must be an OID and the OID must have
			an IdentityCode defined for it in order for it to
			be used to export the Organization Code.
			
			If Organization Code cannot be determined by using
			hl7:id/@root then use SendingFacility.
		-->
    <xsl:variable name="organizationCodeFromIdRoot">
      <xsl:apply-templates select="." mode="fn-code-for-oid">
        <xsl:with-param name="OID" select="hl7:id[1]/@root"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($organizationCodeFromIdRoot) and not($organizationCodeFromIdRoot = hl7:id[1]/@root)">
        <xsl:value-of select="$organizationCodeFromIdRoot"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="sendingFacilityForEncounter">
          <xsl:apply-templates select="$input" mode="fn-I-SendingFacilityValue"/>
        </xsl:variable>
        <xsl:if test="string-length($sendingFacilityForEncounter)">
          <xsl:value-of select="$sendingFacilityForEncounter"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="hl7:encounter" mode="eE-ConsultingClinicians-informant">
    <xsl:if
      test="hl7:informant[not(hl7:assignedEntity/hl7:id/@nullFlavor) and hl7:assignedEntity/hl7:id/@root and hl7:assignedEntity/hl7:id/@extension and string-length(hl7:assignedEntity/hl7:assignedPerson/hl7:name)]">
      <ConsultingClinicians>
        <xsl:apply-templates
          select="hl7:informant[not(hl7:assignedEntity/hl7:id/@nullFlavor) and hl7:assignedEntity/hl7:id/@root and hl7:assignedEntity/hl7:id/@extension and string-length(hl7:assignedEntity/hl7:assignedPerson/hl7:name)]"
          mode="fn-W-CareProvider"/>
      </ConsultingClinicians>
    </xsl:if>
  </xsl:template>

  <!--
		This empty template may be overridden with custom logic.
	
		The input node spec can be either of the following:
		- hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter
		- $sectionRootPath/hl7:entry/hl7:encounter
	-->
  <xsl:template match="*" mode="eE-ImportCustom-Encounter"> </xsl:template>

  <!--
		Determine if the Payers section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $planSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include payers data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
  <xsl:template match="hl7:section" mode="eE-IsNoDataSection-Payers">
    <xsl:choose>
      <xsl:when test="count(hl7:entry) = 0">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ***************************** NAMED TEMPLATES ************************************ -->
  <xsl:template name="eE-encounter-ParticipantCallback">

	    <!--
				Field : Encounter EnteredBy
				Target: HS.SDA3.Encounter EnteredBy
				Target: /Container/Encounters/Encounter/EnteredBy
				Source: /ClinicalDocument/participant[@typeCode='CALLBCK']
				StructuredMappingRef: EnteredByDetail
		-->				
	    <xsl:apply-templates select="/hl7:ClinicalDocument/hl7:participant[@typeCode='CALLBCK']" mode="fn-EnteredBy"/>

	    <!--
				Field : Encounter EnteredAt
				Target: HS.SDA3.Encounter EnteredAt
				Target: /Container/Encounters/Encounter/EnteredAt
				Source: /ClinicalDocument/participant[@typeCode='CALLBCK']
				StructuredMappingRef: EnteredAt
		-->
	    <xsl:apply-templates select="/hl7:ClinicalDocument/hl7:participant[@typeCode='CALLBCK']" mode="fn-EnteredAt"/>

	    <!--
				Field : Encounter EnteredOn
				Target: HS.SDA3.Encounter EnteredOn
				Target: /Container/Encounters/Encounter/EnteredOn
				Source: /ClinicalDocument/participant[@typeCode='CALLBCK']/time/@value
				StructuredMappingRef: EnteredOn
		-->
	    <xsl:apply-templates select="/hl7:ClinicalDocument/hl7:participant[@typeCode='CALLBCK']/hl7:time" mode="fn-EnteredOn"/>	 

  </xsl:template>



  <xsl:template name="eE-detailPart2">
    <xsl:param name="fromTime"/>
    <xsl:param name="toTime"/>

    <!-- HS.SDA3.Encounter HealthFunds -->
    <xsl:variable name="isNoDataSectionHF">
      <xsl:apply-templates select="key('sectionsByRoot', $ccda-PayersSection)" mode="eE-IsNoDataSection-Payers"/>
    </xsl:variable>
    <xsl:variable name="sectionEntriesHF" select="key('sectionsByRoot', $ccda-PayersSection)/hl7:entry"/>

    <!-- ActionCode is not supported for HealthFund, causes parse error in SDA3. -->
    <xsl:if test="$sectionEntriesHF and $isNoDataSectionHF = '0' and $healthFundImportMode = '1'">
      <HealthFunds>
        <xsl:apply-templates select="$sectionEntriesHF" mode="sP-HealthFunds"/>
      </HealthFunds>
    </xsl:if>

    <!-- The logic for endTime here matches that in HS.SDA3.Streamlet.Encounter. -->
    <xsl:variable name="endTime">
      <xsl:choose>
        <xsl:when test="string-length($toTime)">
          <xsl:value-of select="$toTime"/>
        </xsl:when>
        <xsl:when test="$encounterType = 'I'">
          <xsl:value-of select="'&#34;&#34;'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$fromTime"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="string-length($endTime)">
      <EndTime>
        <xsl:value-of select="$endTime"/>
      </EndTime>
    </xsl:if>
  </xsl:template>

  <xsl:template name="eE-Instructions">
    <!-- Recommendations Provided -->
    <!--
			Because HealthShare supports Hospital Discharge Instructions as text-only section, a no-data
			section check does not apply, while Instructions as text-entry section, so no-data section check is needed.
	-->
    <xsl:variable name="sectionNarrativeHDInstructions" select="key('sectionsByRoot', $ccda-HospitalDischargeInstructionsSection)"/>
    <xsl:variable name="sectionInstructions" select="key('sectionsByRoot', $ccda-InstructionsSection)"/>
    <xsl:variable name="IsNoDataSectionInstructions"><xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$ccda-InstructionsSection]" mode="eE-IsNoDataSection-Instructions"/> </xsl:variable>

    <!--
			Hospital Discharge Instructions has only narratives while Instructions has both narrative and entries.  
			There is no mechanism in that section to tie instructions to encounters.
			Also, those sections should be from a single-encounter document.
			However, to not lose data, we will import Discharge Instructions and/or Instructions as long as the document contains at least one encounter.
	 -->				
    <xsl:if test="$encounterCount >= 1 and ($sectionNarrativeHDInstructions or $sectionInstructions)">
      <RecommendationsProvided>

      	<!--Populate from Hospital Dischange Instructions section-->
        <xsl:apply-templates select="$sectionNarrativeHDInstructions" mode="sHDI-DischargeInstructionsSection-Narrative"/>

		    <!--Populate from Instructions section-->
        <xsl:if test="$IsNoDataSectionInstructions = '0'">
        	<xsl:apply-templates select="$sectionInstructions" mode="sIns-InstructionsSection"/>
    	</xsl:if>

      </RecommendationsProvided>      
    </xsl:if>
  </xsl:template>

	<!-- Determine if the Instructions section is present but has or indicates no data present.
	This logic is applied only if the section is present.
	The input node spec is the $sectionRootPath for the Instructions section.
	Return 1 if the section is present with nullFlavor or there is no hl7:entry element.
	Otherwise Return 0 (section is present and appears to include social history data).

	You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="*" mode="eE-IsNoDataSection-Instructions">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>