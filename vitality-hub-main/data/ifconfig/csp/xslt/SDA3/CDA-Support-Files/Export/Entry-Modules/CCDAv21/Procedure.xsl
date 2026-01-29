<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- AlsoInclude: AuthorParticipation.xsl -->
  
	<xsl:template match="*" mode="eP-procedures-Narrative">
		<xsl:param name="procedureList"/>
		<text>
			<table border="1" width="100%">
				<thead>
					<tr>
						<th>Procedure</th>
						<th>Date / Time Performed</th>
						<th>Performing Clinician</th>
						<th>Device</th>
					</tr>
				</thead>
				<tbody>
					<!-- Export Procedures for the current date or earlier, or with no date.  Future Procedures should be exported under Plan of Treatment. -->
					<xsl:apply-templates select="$procedureList" mode="eP-procedures-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="Procedure" mode="eP-procedures-NarrativeDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<tr ID="{concat($exportConfiguration/procedures/narrativeLinkPrefixes/procedureNarrative/text(), $narrativeLinkSuffix)}">
			<td ID="{concat($exportConfiguration/procedures/narrativeLinkPrefixes/procedureDescription/text(), $narrativeLinkSuffix)}"><xsl:apply-templates select="Procedure" mode="fn-originalTextOrDescriptionOrCode"/></td>
			<td><xsl:apply-templates select="ProcedureTime" mode="fn-narrativeDateFromODBC"/></td>
			<td><xsl:apply-templates select="Clinician" mode="fn-name-Person-Narrative"/></td>
			<td><xsl:apply-templates select="Devices" mode="fn-device-procedure"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="eP-procedures-Entries">
		<xsl:param name="procedureList"/>
		<!-- Export Procedures for the current date or earlier, or with no date.  Future Procedures should be exported under Plan of Treatment. -->
		<xsl:apply-templates select="$procedureList" mode="eP-procedures-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="Procedure" mode="eP-procedures-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>		
		
		<entry typeCode="DRIV">
			<procedure classCode="PROC" moodCode="EVN">
				<xsl:call-template name="eP-templateIds-procedureEntry"/>

				<!--
					Field : Procedure Id
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/id
					Source: HS.SDA3.Procedure ExternalId
					Source: /Container/Procedures/Procedure/ExternalId
					StructuredMappingRef: id-External
				-->
				<xsl:apply-templates select="." mode="fn-id-External"/>
				
				<!--
					Field : Procedure Type
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/code
					Source: HS.SDA3.Procedure Procedure
					Source: /Container/Procedures/Procedure/Procedure
					StructuredMappingRef: generic-Coded
				-->
				<xsl:apply-templates select="Procedure" mode="fn-generic-Coded">
					<xsl:with-param name="narrativeLink" select="concat('#', $exportConfiguration/procedures/narrativeLinkPrefixes/procedureDescription/text(), $narrativeLinkSuffix)"/>
				</xsl:apply-templates>
				
				<!--
					Field : Procedure Status
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/statusCode
					Source: HS.SDA3.Procedure Status
					Source: /Container/Procedures/Procedure/Status
				-->
				<xsl:choose>
					<xsl:when test="string-length(Status/Code/text())">
						<statusCode>
							<xsl:attribute name="code">
								<xsl:value-of select="Status/Code/text()"/>
							</xsl:attribute>
						</statusCode>
					</xsl:when>
					<xsl:otherwise>
						<statusCode code="completed"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Procedure Date/Time
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/effectiveTime/@value
					Source: HS.SDA3.Procedure ProcedureTime
					Source: /Container/Procedures/Procedure/ProcedureTime
				-->
				<xsl:choose>
					<xsl:when test="string-length(ProcedureTime/text())">
						<xsl:apply-templates select="ProcedureTime" mode="fn-effectiveTime-singleton"/>
					</xsl:when>
					<xsl:otherwise>
						<effectiveTime><xsl:attribute name="nullFlavor">UNK</xsl:attribute></effectiveTime>
					</xsl:otherwise>
				</xsl:choose>
				
				<!--
					Field : Procedure Provider
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/performer
					Source: HS.SDA3.Procedure Clinician
					Source: /Container/Procedures/Procedure/Clinician
					StructuredMappingRef: performer-procedure
				-->
				<xsl:apply-templates select="Clinician" mode="fn-performer-procedure"/>
				
				<!--
					Field : Procedure Author
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/author
					Source: HS.SDA3.Procedure EnteredBy
					Source: /Container/Procedures/Procedure/EnteredBy
					StructuredMappingRef: author-Human
				-->
				<xsl:apply-templates select="EnteredBy" mode="eAP-author-Human"/>
				
				<!--
					Field : Procedure Information Source
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/informant
					Source: HS.SDA3.Procedure EnteredAt
					Source: /Container/Procedures/Procedure/EnteredAt
					StructuredMappingRef: informant
				-->
				<xsl:apply-templates select="EnteredAt" mode="fn-informant"/>
				
				<xsl:apply-templates select="Devices/Device" mode="eP-participant-productInstance"/>
				<!--
					Field : Procedure Encounter
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/entryRelationship
					Source: HS.SDA3.Procedure EncounterNumber
					Source: /Container/Procedures/Procedure/EncounterNumber
					StructuredMappingRef: encounterLink-entryRelationship
					Note  : This links the Procedure to an encounter in the Encounters section.
				-->
				<xsl:apply-templates select="." mode="fn-encounterLink-entryRelationship"/>
			</procedure>
		</entry>
	</xsl:template>
	
	<xsl:template match="Device" mode="eP-participant-productInstance">
		<participant typeCode="DEV">
			<participantRole classCode="MANU">
				<templateId root="2.16.840.1.113883.10.20.22.4.37"/>
				<!-- ToDo: replace above with normal call-template and global variable -->
				
				<!--
					Field : Procedure Device Root
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/participant/participantRole/id@root
					Source: HS.SDA3.Device UDIRoot
					Source: /Container/Procedures/Procedure/Devices/Device/UDIRoot
				-->
				<!--
					Field : Procedure Device Extension
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/participant/participantRole/id@extension
					Source: HS.SDA3.Device UDIExtension
					Source: /Container/Procedures/Procedure/Devices/Device/UDIExtension
				-->
				<!--
					Field : Procedure Device AssigningAuthorityName
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/participant/participantRole/id@assigningAuthorityName
					Source: HS.SDA3.Device UDIAssigningAuthority
					Source: /Container/Procedures/Procedure/Devices/Device/UDIAssigningAuthority
				-->
				<id>
					<xsl:attribute name="root"><xsl:value-of select="UDIRoot/text()"/></xsl:attribute>
					<xsl:attribute name="extension"><xsl:value-of select="UDIExtension/text()"/></xsl:attribute>
					<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="UDIAssigningAuthority/text()"/></xsl:attribute>
				</id>
				
				<!--
					Field : Procedure Device Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/participant/participantRole/playingDevice
					Source: HS.SDA3.Device UDIAssigningAuthority
					Source: /Container/Procedures/Procedure/Devices/Device/Device
					StructuredMappingRef: generic-Coded
				-->
				<playingDevice>
					<xsl:apply-templates select="Device" mode="fn-generic-Coded">
						<xsl:with-param name="isCodeRequired" select="'1'"/>
					</xsl:apply-templates>
				</playingDevice>


				<!--
					Field : Procedure Device Code
					Target: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/participant/participantRole/scopingEntity/id
					Source: HS.SDA3.Device UDIAssigningAuthority
					Source: /Container/Procedures/Procedure/Devices/Device/UDIRoot
				-->
				<scopingEntity>
					<id>
						<xsl:attribute name="root"><xsl:value-of select="UDIRoot/text()"/></xsl:attribute>
					</id>
				</scopingEntity>
			</participantRole>
		</participant>
	</xsl:template>
	
	<xsl:template match="*" mode="eP-procedures-NoData">
		<text><xsl:value-of select="$exportConfiguration/procedures/emptySection/narrativeText/text()"/></text>
	</xsl:template>

	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eP-templateIds-procedureEntry">
		<templateId root="{$ccda-ProcedureActivityProcedure}"/>
		<templateId root="{$ccda-ProcedureActivityProcedure}" extension="2014-06-09"/>
	</xsl:template>
	
	<xsl:template name="eP-templateIds-productInstance">
		<!-- UNUSED, but available -->
		<templateId root="{$ccda-ProductInstance}"/>
	</xsl:template>

</xsl:stylesheet>