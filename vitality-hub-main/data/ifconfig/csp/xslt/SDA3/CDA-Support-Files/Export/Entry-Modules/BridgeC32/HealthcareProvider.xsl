<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="healthcareProviders">
		<xsl:param name="includeDiagnosisClinicians" select="'0'"/>
	
		<xsl:variable name="hasAttendings">
			<xsl:for-each select="set:distinct(/Container/Encounters/Encounter/AttendingClinicians/CareProvider/Code)">1</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="hasProblemClinicians">
			<xsl:for-each select="set:distinct(/Container/Problems/Problem/Clinician/Code)">1</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="hasDiagnosisClinicians">
			<xsl:choose>
				<xsl:when test="$includeDiagnosisClinicians='1'">
					<xsl:for-each select="set:distinct(/Container/Diagnoses/Diagnosis/DiagnosingClinician/Code)">1</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length(FamilyDoctor) or string-length($hasAttendings) or string-length($hasProblemClinicians) or string-length($hasDiagnosisClinicians)">
				<!-- Primary Care Physician -->
				<xsl:apply-templates select="FamilyDoctor" mode="documentationOf-FamilyDoctor"/>
				<!-- Other Physicians - Attendings -->
				<xsl:if test="string-length($hasAttendings)"><xsl:apply-templates select="/Container/Encounters" mode="documentationOf-OtherDoctors"/></xsl:if>
				<!-- Condition Physicians - Problems -->
				<xsl:if test="string-length($hasProblemClinicians)"><xsl:apply-templates select="/Container/Problems" mode="documentationOf-ProblemClinicians"/></xsl:if>
				<!-- Condition Physicians - Diagnoses -->
				<xsl:if test="string-length($hasDiagnosisClinicians)"><xsl:apply-templates select="/Container/Diagnoses" mode="documentationOf-DiagnosisClinicians"/></xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="documentationOf-Unknown"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="documentationOf-FamilyDoctor">
		<documentationOf>
			<serviceEvent classCode="PCPR">
				<!-- Effective Time -->
				<effectiveTime>
					<low nullFlavor="UNK"/>
					<high nullFlavor="UNK"/>
				</effectiveTime>
				
				<!-- Family Doctor = Primary Care Doctor -->
				<xsl:variable name="careProviderType">
					<CareProviderType xmlns="">
						<SDACodingStandard><xsl:value-of select="$providerRoleName"/></SDACodingStandard>
						<Code>PP</Code>
						<Description>Primary Care Provider</Description>
					</CareProviderType>
				</xsl:variable>
				
				<performer typeCode="PRF">
					<xsl:variable name="performerIdentifierAssigningAuthority"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
					
					<xsl:if test="$performerIdentifierAssigningAuthority = $nationalProviderIdentifierOID"><templateId root="{$hitsp-CDA-HealthcareProvider}"/></xsl:if>
					<templateId root="{$ihe-PCC-HealthcareProvidersAndPharmacies}"/>
					
					<xsl:apply-templates select="exsl:node-set($careProviderType)/CareProviderType" mode="code-function"/>
					<time>
						<low nullFlavor="UNK"/>
						<high nullFlavor="UNK"/>
					</time>
					<xsl:apply-templates select="." mode="assignedEntity-performer"/>
				</performer>
			</serviceEvent>
		</documentationOf>
	</xsl:template>
	
	<xsl:template match="*" mode="documentationOf-OtherDoctors">
		<!--
			HS.SDA3.Encounter AttendingClinicians
			CDA Section: Document Header - Healthcare Providers
			CDA Field: Healthcare Provider
			CDA XPath: /ClinicalDocument/documentationOf/serviceEvent
		-->	
		<xsl:for-each select="set:distinct(Encounter/AttendingClinicians/CareProvider/Code)">			
			<xsl:variable name="encountersRoot" select="../../../.."/>
			<xsl:variable name="careProviderCode" select="text()"/>
			
			<!--
				If the care provider is an attending on multiple encounters
				and if any of those encounters is missing the To time, then
				effective time high should be unknown (i.e., care provider
				still in service for the patient).
			-->
			<xsl:variable name="hasActiveEncounter">
				<xsl:for-each select="$encountersRoot/Encounter[AttendingClinicians/CareProvider/Code/text() = $careProviderCode]">
					<xsl:if test="not(string-length(ToTime/text()))">1</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="earliestFromTime1">
				<xsl:for-each select="$encountersRoot/Encounter[AttendingClinicians/CareProvider/Code/text() = $careProviderCode]">
					<xsl:sort select="FromTime" order="ascending"/>
					<xsl:value-of select="translate(FromTime/text(), 'TZ:- ', '')"/>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="latestToTime1">
				<xsl:if test="not(string-length($hasActiveEncounter))">
					<xsl:for-each select="$encountersRoot/Encounter[AttendingClinicians/CareProvider/Code/text() = $careProviderCode]">
						<xsl:sort select="ToTime" order="descending"/>
						<xsl:value-of select="translate(ToTime/text(), 'TZ:- ', '')"/>
					</xsl:for-each>
				</xsl:if>
			</xsl:variable>
			
			<!--
				If multiple encounters, then the From or To times could
				contain multiple date values. Just keep the first one.
			-->
			<xsl:variable name="earliestFromTime2" select="substring($earliestFromTime1,1,14)"/>
			<xsl:variable name="latestToTime2" select="substring($latestToTime1,1,14)"/>
			
			<documentationOf>
				<serviceEvent classCode="PCPR">
					<xsl:variable name="serviceTime">
						<ServiceTime xmlns="">
							<FromTime><xsl:value-of select="$earliestFromTime2"/></FromTime>
							<xsl:if test="string-length($latestToTime2)"><ToTime><xsl:value-of select="$latestToTime2"/></ToTime></xsl:if>
						</ServiceTime>
					</xsl:variable>
					
					<!-- Effective Time -->
					<xsl:apply-templates select="exsl:node-set($serviceTime)/ServiceTime" mode="effectiveTime-FromTo"/>
					
					<performer typeCode="PRF">
						<xsl:variable name="performerIdentifierAssigningAuthority"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="parent::node()/SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
						
						<xsl:if test="$performerIdentifierAssigningAuthority = $nationalProviderIdentifierOID"><templateId root="{$hitsp-CDA-HealthcareProvider}"/></xsl:if>
						<templateId root="{$ihe-PCC-HealthcareProvidersAndPharmacies}"/>
						
						<xsl:apply-templates select="parent::node()/CareProviderType" mode="code-function"/>
						<xsl:apply-templates select="exsl:node-set($serviceTime)/ServiceTime" mode="time"/>
						<xsl:apply-templates select="parent::node()" mode="assignedEntity-performer"/>
					</performer>
				</serviceEvent>
			</documentationOf>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="*" mode="documentationOf-ProblemClinicians">
		<!--
			HS.SDA3.Problem Clinician
			CDA Section: Document Header - Healthcare Providers
			CDA Field: Healthcare Provider
			CDA XPath: /ClinicalDocument/documentationOf/serviceEvent
		-->	
		<xsl:for-each select="set:distinct(Problem/Clinician/Code)">			
			<xsl:variable name="problemsRoot" select="../../.."/>
			<xsl:variable name="careProviderCode" select="text()"/>
			
			<!--
				If the care provider is on multiple problems and if any of
				those problems is missing the To time, then effective time
				high should be unknown (i.e., care provider still in service
				for the patient).
			-->
			<xsl:variable name="hasActiveProblem">
				<xsl:for-each select="$problemsRoot/Problem[Clinician/Code/text() = $careProviderCode]">
					<xsl:if test="not(string-length(ToTime/text()))">1</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="earliestFromTime1">
				<xsl:for-each select="$problemsRoot/Problem[Clinician/Code/text() = $careProviderCode]">
					<xsl:sort select="FromTime" order="ascending"/>
					<xsl:value-of select="translate(FromTime/text(), 'TZ:- ', '')"/>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="latestToTime1">
				<xsl:if test="not(string-length($hasActiveProblem))">
					<xsl:for-each select="$problemsRoot/Problem[Clinician/Code/text() = $careProviderCode]">
						<xsl:sort select="ToTime" order="descending"/>
						<xsl:value-of select="translate(ToTime/text(), 'TZ:- ', '')"/>
					</xsl:for-each>
				</xsl:if>
			</xsl:variable>
			
			<!--
				If multiple problems, then the From or To times could
				contain multiple date values. Just keep the first one.
			-->
			<xsl:variable name="earliestFromTime2" select="substring($earliestFromTime1,1,14)"/>
			<xsl:variable name="latestToTime2" select="substring($latestToTime1,1,14)"/>
			
			<documentationOf>
				<serviceEvent classCode="PCPR">
					<xsl:variable name="serviceTime">
						<ServiceTime xmlns="">
							<FromTime><xsl:value-of select="$earliestFromTime2"/></FromTime>
							<xsl:if test="string-length($latestToTime2)"><ToTime><xsl:value-of select="$latestToTime2"/></ToTime></xsl:if>
						</ServiceTime>
					</xsl:variable>
					
					<!-- Effective Time -->
					<xsl:apply-templates select="exsl:node-set($serviceTime)/ServiceTime" mode="effectiveTime-FromTo"/>
					
					<performer typeCode="PRF">
						<xsl:variable name="performerIdentifierAssigningAuthority"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="parent::node()/SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
						
						<xsl:if test="$performerIdentifierAssigningAuthority = $nationalProviderIdentifierOID"><templateId root="{$hitsp-CDA-HealthcareProvider}"/></xsl:if>
						<templateId root="{$ihe-PCC-HealthcareProvidersAndPharmacies}"/>
						
						<xsl:apply-templates select="parent::node()/CareProviderType" mode="code-function"/>
						<xsl:apply-templates select="exsl:node-set($serviceTime)/ServiceTime" mode="time"/>
						<xsl:apply-templates select="parent::node()" mode="assignedEntity-performer"/>
					</performer>
				</serviceEvent>
			</documentationOf>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="*" mode="documentationOf-DiagnosisClinicians">
		<!--
			HS.SDA3.Diagnosis DiagnosingClinician
			CDA Section: Document Header - Healthcare Providers
			CDA Field: Healthcare Provider
			CDA XPath: /ClinicalDocument/documentationOf/serviceEvent
			
			Diagnosis Clinician is included only for certain CDA document
			types (e.g., C48.2v25).  Export of Diagnosis Clinician in
			Healthcare Provider is triggered by the includeDiagnosisClinicians
			parameter on the healthcareProviders template.
		-->	
		<xsl:for-each select="set:distinct(Diagnosis/DiagnosingClinician/Code)">			
			<xsl:variable name="diagnosesRoot" select="../../.."/>
			<xsl:variable name="careProviderCode" select="text()"/>
			
			<!--
				effectiveTime for diagnoses is made from IdentificationTime
				or from EnteredOn, instead of FromTime and ToTime.  If there
				is only one time found, it will occupy both high and low in
				the effectiveTime.
			-->
			<xsl:variable name="earliestIdentificationTime1">
				<xsl:for-each select="$diagnosesRoot/Diagnosis[DiagnosingClinician/Code/text() = $careProviderCode]">
					<xsl:sort select="IdentificationTime" order="ascending"/>
					<xsl:value-of select="translate(IdentificationTime/text(), 'TZ:- ', '')"/>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="latestIdentificationTime1">
				<xsl:for-each select="$diagnosesRoot/Diagnosis[DiagnosingClinician/Code/text() = $careProviderCode]">
					<xsl:sort select="IdentificationTime" order="descending"/>
					<xsl:value-of select="translate(IdentificationTime/text(), 'TZ:- ', '')"/>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="earliestEnteredOn1">
				<xsl:for-each select="$diagnosesRoot/Diagnosis[DiagnosingClinician/Code/text() = $careProviderCode]">
					<xsl:sort select="EnteredOn" order="ascending"/>
					<xsl:value-of select="translate(EnteredOn/text(), 'TZ:- ', '')"/>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="latestEnteredOn1">
				<xsl:for-each select="$diagnosesRoot/Diagnosis[DiagnosingClinician/Code/text() = $careProviderCode]">
					<xsl:sort select="EnteredOn" order="descending"/>
					<xsl:value-of select="translate(EnteredOn/text(), 'TZ:- ', '')"/>
				</xsl:for-each>
			</xsl:variable>
			
			<!--
				If multiple diagnoses, then the times could contain
				multiple date values. Just keep the first one.
			-->
			<xsl:variable name="earliestIdentificationTime2">
				<xsl:choose>
					<xsl:when test="string-length($earliestIdentificationTime1)">
						<xsl:value-of select="substring($latestIdentificationTime1,1,14)"/>
					</xsl:when>
					<xsl:when test="string-length($earliestEnteredOn1)">
						<xsl:value-of select="substring($earliestEnteredOn1,1,14)"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="latestIdentificationTime2">
				<xsl:choose>
					<xsl:when test="string-length($latestIdentificationTime1)">
						<xsl:value-of select="substring($latestIdentificationTime1,1,14)"/>
					</xsl:when>
					<xsl:when test="string-length($earliestIdentificationTime1)">
						<xsl:value-of select="substring($earliestIdentificationTime1,1,14)"/>
					</xsl:when>
					<xsl:when test="string-length($latestEnteredOn1)">
						<xsl:value-of select="substring($latestEnteredOn1,1,14)"/>
					</xsl:when>
					<xsl:when test="string-length($earliestEnteredOn1)">
						<xsl:value-of select="substring($earliestEnteredOn1,1,14)"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<documentationOf>
				<serviceEvent classCode="PCPR">
					<xsl:variable name="serviceTime">
						<ServiceTime xmlns="">
							<FromTime><xsl:value-of select="$earliestIdentificationTime2"/></FromTime>
							<xsl:if test="string-length($latestIdentificationTime2)"><ToTime><xsl:value-of select="$latestIdentificationTime2"/></ToTime></xsl:if>
						</ServiceTime>
					</xsl:variable>
					
					<!-- Effective Time -->
					<xsl:apply-templates select="exsl:node-set($serviceTime)/ServiceTime" mode="effectiveTime-FromTo"/>
					
					<performer typeCode="PRF">
						<xsl:variable name="performerIdentifierAssigningAuthority"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="parent::node()/SDACodingStandard/text()"/></xsl:apply-templates></xsl:variable>
						
						<xsl:if test="$performerIdentifierAssigningAuthority = $nationalProviderIdentifierOID"><templateId root="{$hitsp-CDA-HealthcareProvider}"/></xsl:if>
						<templateId root="{$ihe-PCC-HealthcareProvidersAndPharmacies}"/>
						
						<xsl:apply-templates select="parent::node()/CareProviderType" mode="code-function"/>
						<xsl:apply-templates select="exsl:node-set($serviceTime)/ServiceTime" mode="time"/>
						<xsl:apply-templates select="parent::node()" mode="assignedEntity-performer"/>
					</performer>
				</serviceEvent>
			</documentationOf>
		</xsl:for-each>
	</xsl:template>
	
	<!--
		Minimal data is required for export to
		documentationOf/serviceEvent when there is no
		family doctor or attending clinician data.
	-->
	<xsl:template name="documentationOf-Unknown">
		<documentationOf>
			<serviceEvent classCode="PCPR">
				<effectiveTime>
					<low nullFlavor="UNK"/>
					<high nullFlavor="UNK"/>
				</effectiveTime>
				<performer typeCode="PRF">
					<templateId root="1.3.6.1.4.1.19376.1.5.3.1.2.3"/>
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
</xsl:stylesheet>
