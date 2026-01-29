<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:key name="encountersByAdmitting" match="Encounter" use="AdmittingClinician/Code"/>
    <xsl:key name="encountersByAdmitting" match="/Container" use="'NEVER_MATCH_THIS!'"/>

	<xsl:key name="encountersByAttending" match="Encounter" use="AttendingClinicians/CareProvider/Code"/>
    <xsl:key name="encountersByAttending" match="/Container" use="'NEVER_MATCH_THIS!'"/>

	<xsl:key name="problemsByClinician" match="Problem" use="Clinician/Code"/>
    <xsl:key name="problemsByClinician" match="/Container" use="'NEVER_MATCH_THIS!'"/>

	<xsl:key name="diagnosesByClinician" match="Diagnosis" use="DiagnosingClinician/Code"/>
    <xsl:key name="diagnosesByClinician" match="/Container" use="'NEVER_MATCH_THIS!'"/>
    <!-- Second line in each of the above keys is to ensure that the "key table" is populated
       with at least one row, but we never want to retrieve that row. -->
  
	<xsl:template match="Patient" mode="eHP-healthcareProviders">
		<xsl:param name="includeDiagnosisClinicians" select="'0'"/>
		
		<xsl:variable name="hasAttendings" select="boolean(/Container/Encounters/Encounter/AttendingClinicians/CareProvider/Code)"/>
		<xsl:variable name="hasAdmitting" select="boolean(/Container/Encounters/Encounter/AdmittingClinician/Code)"/>
		<xsl:variable name="hasProblemClinicians" select="boolean(/Container/Problems/Problem/Clinician/Code)"/>
		<xsl:variable name="hasDiagnosisClinicians" select="boolean(/Container/Diagnoses/Diagnosis/DiagnosingClinician/Code) and not($includeDiagnosisClinicians = '0')"/>
		
		<xsl:choose>
			<xsl:when test="boolean(FamilyDoctor) or $hasAttendings or $hasAdmitting or $hasProblemClinicians or $hasDiagnosisClinicians">
				<documentationOf>
					<serviceEvent classCode="PCPR">
						<xsl:call-template name="eHP-templateIds-serviceEventProvider" />
						
						<!-- Effective Time -->
						<xsl:apply-templates select="/Container/Encounters"	mode="eHP-effectiveTime-serviceEvent"/>
						
						<!-- Primary Care Physician -->
						<xsl:apply-templates select="FamilyDoctor" mode="eHP-documentationOf-FamilyDoctor"/>
						<!-- Other Physicians - Attendings -->
						<xsl:if test="$hasAttendings">
							<xsl:apply-templates select="/Container/Encounters" mode="eHP-documentationOf-OtherDoctors"/>
						</xsl:if>
						<!-- Admitting Physician -->
						<xsl:if test="$hasAdmitting">
							<xsl:apply-templates select="/Container/Encounters" mode="eHP-documentationOf-AdmittingClinicians"/>
						</xsl:if>
						<!-- Condition Physicians - Problems -->
						<xsl:if test="$hasProblemClinicians">
							<xsl:apply-templates select="/Container/Problems"	mode="eHP-documentationOf-ProblemClinicians"/>
						</xsl:if>
						<!-- Condition Physicians - Diagnoses -->
						<xsl:if test="$hasDiagnosisClinicians">
							<xsl:apply-templates select="/Container/Diagnoses" mode="eHP-documentationOf-DiagnosisClinicians"/>
						</xsl:if>
					</serviceEvent>
				</documentationOf>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="eHP-documentationOf-Unknown"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="eHP-documentationOf-FamilyDoctor">
		<!-- Family Doctor = Primary Care Doctor -->
		<xsl:variable name="careProviderType">
			<CareProviderType xmlns="">
				<SDACodingStandard><xsl:value-of select="$participationFunctionName"/></SDACodingStandard>
				<Code>PCP</Code>
				<Description>Primary Care Physician</Description>
			</CareProviderType>
		</xsl:variable>
		
		<performer typeCode="PRF">
			<xsl:apply-templates select="exsl:node-set($careProviderType)/CareProviderType" mode="fn-code-function"/>
			
			<time>
				<low nullFlavor="UNK"/>
				<high nullFlavor="UNK"/>
			</time>
			
			<!--
				Field : Healthcare Provider Family Doctor
				Target: /ClinicalDocument/documentationOf/serviceEvent/performer[(functionCode/@codeSystem='2.16.840.1.113883.5.88' and functionCode/@code='PCP')]/assignedEntity
				Source: HS.SDA3.Patient FamilyDoctor
				Source: /Container/Patient/FamilyDoctor
				StructuredMappingRef: assignedEntity-performer
			-->
			<xsl:apply-templates select="." mode="fn-assignedEntity-performer"/>
		</performer>
	</xsl:template>
	
	<xsl:template match="Encounters" mode="eHP-documentationOf-OtherDoctors">
		<!-- For Encounter, the functionCode element produced will always be
			derived from this generic CareProviderType for Attending Clinician.
			So we prepare the CareProviderType here. -->
		
		<xsl:variable name="careProviderTypeRTF">
			<CareProviderType xmlns="">
				<SDACodingStandard><xsl:value-of select="$participationFunctionName"/></SDACodingStandard>
				<Code>ATTPHYS</Code>
				<Description>Attending Clinician</Description>
			</CareProviderType>
		</xsl:variable>
		<xsl:variable name="careProviderType" select="exsl:node-set($careProviderTypeRTF)/CareProviderType"/>
		
		<xsl:for-each select="set:distinct(Encounter/AttendingClinicians/CareProvider/Code)">			
			<xsl:variable name="careProviderCode" select="text()"/>
			
			<!--
				If the care provider is an attending on multiple encounters
				and if any of those encounters is missing the To time, then
				effective time high should be unknown (i.e., care provider
				still in service for the patient).
			-->
			
			<!--
				If multiple encounters, then the From or To times could
				contain multiple date values. Just keep the earliest FromTime and
				(if all Encounter elements have a ToTime) the latest ToTime.
			-->
			
			<performer typeCode="PRF">
				<xsl:apply-templates select="$careProviderType" mode="fn-code-function"/>
				
				<!--
					Field: Healthcare Provider Attending Clinician Start Time
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer[functionCode/@code='ATTPHYS']/time/low/@value
					Source: HS.SDA3.Encounter FromTime
					Source: /Container/Encounters/Encounter[AttendingClinicians/CareProvider]/FromTime
				-->
				<!--
					Field: Healthcare Provider Attending Clinician End Time
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer[functionCode/@code='ATTPHYS']/time/high/@value
					Source: HS.SDA3.Encounter ToTime
					Source: /Container/Encounters/Encounter[AttendingClinicians/CareProvider]/ToTime
				-->
				<time>
					<low>
						<xsl:attribute name="value">
							<xsl:for-each select="key('encountersByAttending',$careProviderCode)">
								<xsl:sort select="FromTime" order="ascending"/>
								<xsl:if test="position()=1">
									<xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>
					</low>
					<xsl:if test="not(key('encountersByAttending', $careProviderCode)[not(string-length(ToTime/text()))])">
						<high>
							<xsl:attribute name="value">
								<xsl:for-each select="key('encountersByAttending', $careProviderCode)">
									<xsl:sort select="ToTime" order="descending"/>
									<xsl:if test="position() = 1">
										<xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:attribute>
						</high>
					</xsl:if>
				</time>
				
				<!--
					Field : Healthcare Provider Attending Clinician
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer[functionCode/@code='ATTPHYS']/assignedEntity
					Source: HS.SDA3.Encounter AttendingClinicians.CareProvider
					Source: /Container/Encounters/Encounter/AttendingClinicians/CareProvider
					StructuredMappingRef: assignedEntity-performer
				-->
				<xsl:apply-templates select=".." mode="fn-assignedEntity-performer"/>
			</performer>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Encounters" mode="eHP-documentationOf-AdmittingClinicians">
		<!-- For Encounter, the functionCode element produced will always be
			derived from this generic CareProviderType for Admitting Clinician.
			So we prepare the CareProviderType here. -->
		
		<xsl:variable name="careProviderTypeRTF">
			<CareProviderType xmlns="">
				<SDACodingStandard><xsl:value-of select="$participationFunctionName"/></SDACodingStandard>
				<Code>ADMPHYS</Code>
				<Description>Admitting Clinician</Description>
			</CareProviderType>
		</xsl:variable>
		<xsl:variable name="careProviderType" select="exsl:node-set($careProviderTypeRTF)/CareProviderType"/>
		
		<xsl:for-each select="set:distinct(Encounter/AdmittingClinician/Code)">			
			<xsl:variable name="careProviderCode" select="text()"/>
			
			<!--
				If the care provider is an attending on multiple encounters
				and if any of those encounters is missing the To time, then
				effective time high should be unknown (i.e., care provider
				still in service for the patient).
			-->
			
			<!--
				If multiple encounters, then the From or To times could
				contain multiple date values. Just keep the earliest FromTime and
				(if all Encounter elements have a ToTime) the latest ToTime.
			-->
			
			<performer typeCode="PRF">
				<xsl:apply-templates select="$careProviderType" mode="fn-code-function"/>
				
				<!--
					Field: Healthcare Provider Admitting Clinician Start Time
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer[functionCode/@code='ADMPHYS']/time/low/@value
					Source: HS.SDA3.Encounter FromTime
					Source: /Container/Encounters/Encounter[AdmittingClinician]/FromTime
				-->
				<!--
					Field: Healthcare Provider Admitting Clinician End Time
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer[functionCode/@code='ADMPHYS']/time/high/@value
					Source: HS.SDA3.Encounter ToTime
					Source: /Container/Encounters/Encounter[AdmittingClinician]/ToTime
				-->
				<time>
					<low>
						<xsl:attribute name="value">
							<xsl:for-each select="key('encountersByAdmitting',$careProviderCode)">
								<xsl:sort select="FromTime" order="ascending"/>
								<xsl:if test="position()=1">
									<xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>
					</low>
					<xsl:if test="not(key('encountersByAdmitting',$careProviderCode)[not(string-length(ToTime/text()))])">
						<high>
							<xsl:attribute name="value">
								<xsl:for-each select="key('encountersByAdmitting',$careProviderCode)">
									<xsl:sort select="ToTime" order="descending"/>
									<xsl:if test="position() = 1">
										<xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:attribute>
						</high>
					</xsl:if>
				</time>
				
				<!--
					Field : Healthcare Provider Admitting Clinician
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer[functionCode/@code='ADMPHYS']/assignedEntity
					Source: HS.SDA3.Encounter AdmittingClinician
					Source: /Container/Encounters/Encounter/AdmittingClinician
					StructuredMappingRef: assignedEntity-performer
				-->
				<xsl:apply-templates select=".." mode="fn-assignedEntity-performer"/>
			</performer>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Problems" mode="eHP-documentationOf-ProblemClinicians">
		<xsl:for-each select="set:distinct(Problem/Clinician/Code)">			
			<xsl:variable name="careProviderCode" select="text()"/>
			
			<!--
				If the care provider is on multiple problems and if any of
				those problems is missing the To time, then effective time
				high should be unknown (i.e., care provider still in service
				for the patient).
			-->
			<!--
				If multiple problems, then the From or To times could
				contain multiple date values. Just keep the earliest FromTime and
				(if all Problem elements for this Clinician have a ToTime) the latest ToTime.
			-->
			
			<performer typeCode="PRF">
				<!--
					Field : HealthcareProvider ProblemClinician FunctionCode
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer/functionCode
					Source: HS.SDA3.Problem Clinician.CareProviderType
					Source: /Container/Problems/Problem/Clinician/CareProviderType
					StructuredMappingRef: code-function
				-->
				<xsl:apply-templates select="../CareProviderType" mode="fn-code-function"/>
				
				<!--
					Field: Healthcare Provider Problem Clinician Start Time
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer/time/low/@value
					Source: HS.SDA3.Problem FromTime
					Source: /Container/Problems/Problem/FromTime
				-->
				<!--
					Field: Healthcare Provider Problem Clinician End Time
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer/time/high/@value
					Source: HS.SDA3.Problem ToTime
					Source: /Container/Problems/Problem/ToTime
				-->
				<time>
					<low>
						<xsl:attribute name="value">
							<xsl:for-each select="key('problemsByClinician',$careProviderCode)">
								<xsl:sort select="FromTime" order="ascending"/>
								<xsl:if test="position()=1">
									<xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>
					</low>
					<xsl:if test="not(key('problemsByClinician',$careProviderCode)[not(string-length(ToTime/text()))])">
						<high>
							<xsl:attribute name="value">
								<xsl:for-each select="key('problemsByClinician',$careProviderCode)">
									<xsl:sort select="ToTime" order="descending"/>
									<xsl:if test="position() = 1">
										<xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/>
									</xsl:if>
								</xsl:for-each>
							</xsl:attribute>
						</high>
					</xsl:if>
				</time>
				
				<!--
					Field : Healthcare Provider Problem Clinician
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer/assignedEntity
					Source: HS.SDA3.Problem Clinician
					Source: /Container/Problems/Problem/Clinician
					StructuredMappingRef: assignedEntity-performer
				-->
				<xsl:apply-templates select=".." mode="fn-assignedEntity-performer"/>
			</performer>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Diagnoses" mode="eHP-documentationOf-DiagnosisClinicians">
		<xsl:for-each select="set:distinct(Diagnosis/DiagnosingClinician/Code)">			
			<xsl:variable name="careProviderCode" select="text()"/>
			
			<!--
				effectiveTime for diagnoses is made from IdentificationTime
				or from EnteredOn, instead of FromTime and ToTime.  If there
				is only one time found, it will occupy both high and low in
				the effectiveTime.
			-->
			
			<xsl:variable name="earliestIdentificationTime1">
				<xsl:for-each select="key('diagnosesByClinician',$careProviderCode)">
					<xsl:sort select="IdentificationTime" order="ascending"/>
					<xsl:if test="position()=1">
						<xsl:apply-templates select="IdentificationTime" mode="fn-xmlToHL7TimeStamp"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="latestIdentificationTime1">
				<xsl:for-each select="key('diagnosesByClinician',$careProviderCode)">
					<xsl:sort select="IdentificationTime" order="descending"/>
					<xsl:if test="position()=1">
						<xsl:apply-templates select="IdentificationTime" mode="fn-xmlToHL7TimeStamp"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="earliestEnteredOn">
				<xsl:for-each select="key('diagnosesByClinician',$careProviderCode)">
					<xsl:sort select="EnteredOn" order="ascending"/>
					<xsl:if test="position()=1">
						<xsl:apply-templates select="EnteredOn" mode="fn-xmlToHL7TimeStamp"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<!--
				If multiple diagnoses, then the high or low times could
				contain multiple date values. Just keep the earliest and
				(if all Diagnosis elements have some time element) the latest.
				Identification time is preferred.
			-->
			<xsl:variable name="earliestIdentificationTime2">
				<xsl:choose>
					<xsl:when test="string-length($earliestIdentificationTime1)">
						<xsl:value-of select="$earliestIdentificationTime1"/>
					</xsl:when>
					<xsl:when test="string-length($earliestEnteredOn)">
						<xsl:value-of select="$earliestEnteredOn"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="latestIdentificationTime2">
				<xsl:choose>
					<xsl:when test="string-length($latestIdentificationTime1)">
						<xsl:value-of select="$latestIdentificationTime1"/>
					</xsl:when>
					<xsl:when test="string-length($earliestIdentificationTime1)">
						<xsl:value-of select="$earliestIdentificationTime1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="latestEnteredOn">
							<xsl:for-each select="key('diagnosesByClinician',$careProviderCode)">
								<xsl:sort select="EnteredOn" order="descending"/>
								<xsl:if test="position()=1">
									<xsl:apply-templates select="EnteredOn" mode="fn-xmlToHL7TimeStamp"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="string-length($latestEnteredOn)">
								<xsl:value-of select="$latestEnteredOn"/>
							</xsl:when>
							<xsl:when test="string-length($earliestEnteredOn)">
								<xsl:value-of select="$earliestEnteredOn"/>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="serviceTime">
				<ServiceTime xmlns="">
					<FromTime>
						<xsl:value-of select="$earliestIdentificationTime2"/>
					</FromTime>
					<xsl:if test="string-length($latestIdentificationTime2)">
						<ToTime>
							<xsl:value-of select="$latestIdentificationTime2"/>
						</ToTime>
					</xsl:if>
				</ServiceTime>
			</xsl:variable>
			
			<performer typeCode="PRF">
				<!--
					Field : HealthcareProvider Diagnosing Clinician Function Code
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer/functionCode
					Source: HS.SDA3.Diagnosis DiagnosingClinician.CareProviderType
					Source: /Container/Diagnoses/Diagnosis/DiagnosingClinician/CareProviderType
					StructuredMappingRef: code-function
				-->
				<xsl:apply-templates select="../CareProviderType" mode="fn-code-function"/>
				
				<!--
					Field: Healthcare Provider Diagnosing Clinician Start Time
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer/time/low/@value
					Source: HS.SDA3.Diagnosis FromTime
					Source: /Container/Diagnoses/Diagnosis/FromTime
				-->
				<!--
					Field: Healthcare Provider Diagnosing Clinician End Time
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer/time/high/@value
					Source: HS.SDA3.Diagnosis ToTime
					Source: /Container/Diagnoses/Diagnosis/ToTime
				-->
				<time>
					<low>
						<xsl:attribute name="value">
							<xsl:value-of select="$earliestIdentificationTime2"/>
						</xsl:attribute>
					</low>
					<xsl:if test="string-length($latestIdentificationTime2)">
						<high>
							<xsl:attribute name="value">
								<xsl:value-of select="$latestIdentificationTime2"/>
							</xsl:attribute>
						</high>
					</xsl:if>
				</time>
				
				<!--
					Field : Healthcare Provider Diagnosing Clinician
					Target: /ClinicalDocument/documentationOf/serviceEvent/performer/assignedEntity
					Source: HS.SDA3.Diagnosis DiagnosingClinician
					Source: /Container/Diagnoses/Diagnosis/DiagnosingClinician
					StructuredMappingRef: assignedEntity-performer
				-->
				<xsl:apply-templates select=".." mode="fn-assignedEntity-performer"/>
			</performer>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Encounters" mode="eHP-effectiveTime-serviceEvent">
		
		<!--
				If multiple encounters, then the From or To times could
				contain multiple date values. Just keep the earliest FromTime and
				(if all Encounter elements have a ToTime) the latest ToTime. If
				there is any encounter lacking a ToTime, then service has not
				ended when viewed in the aggregate.
			-->
		
		<effectiveTime>
			<low>
				<xsl:attribute name="value">
					<xsl:for-each select="Encounter">
						<xsl:sort select="FromTime" order="ascending"/>
						<xsl:if test="position() = 1">
							<xsl:apply-templates select="FromTime" mode="fn-xmlToHL7TimeStamp"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:attribute>
			</low>
			<!-- Only emit ToTime if there are no active encounters -->
			<xsl:if test="not(Encounter[not(string-length(ToTime/text()))])">
				<high>
					<xsl:attribute name="value">
						<xsl:for-each select="Encounter">
							<xsl:sort select="ToTime" order="descending"/>
							<xsl:if test="position() = 1">
								<xsl:apply-templates select="ToTime" mode="fn-xmlToHL7TimeStamp"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:attribute>
				</high>
			</xsl:if>
		</effectiveTime>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eHP-documentationOf-Unknown">
		<!--
			Minimal data is required for export to documentationOf/serviceEvent when there is no
			family doctor or attending clinician data. 
		-->
		<documentationOf>
			<serviceEvent classCode="PCPR">
				<xsl:call-template name="eHP-templateIds-serviceEventProvider"/>
				<effectiveTime>
					<low nullFlavor="UNK"/>
					<high nullFlavor="UNK"/>
				</effectiveTime>
				<performer typeCode="PRF">
					<time>
						<low nullFlavor="UNK"/>
						<high nullFlavor="UNK"/>
					</time>
					<assignedEntity classCode="ASSIGNED">
						<id nullFlavor="UNK"/>
						<addr nullFlavor="UNK"/>
						<telecom nullFlavor="UNK"/>
						<assignedPerson>
							<name nullFlavor="UNK"/>
						</assignedPerson>
					</assignedEntity>
				</performer>
			</serviceEvent>
		</documentationOf>
	</xsl:template>
	
	<xsl:template name="eHP-templateIds-serviceEventProvider">
		<templateId root="{$ccda-ServiceEventProvider}"/>
		<templateId root="{$ccda-ServiceEventProvider}" extension="2015-08-01"/>
	</xsl:template>
  
</xsl:stylesheet>