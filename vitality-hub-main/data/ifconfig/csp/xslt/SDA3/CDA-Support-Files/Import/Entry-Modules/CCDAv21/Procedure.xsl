<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="hl7:procedure" mode="eP-Procedure">
		<xsl:param name="PlanOfTreatment" select="'0'"/>

		<Procedure>
			<!--
				Field : Procedure Encounter
				Target: HS.SDA3.Procedure EncounterNumber
				Target: /Container/Procedures/Procedure/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Procedure and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></EncounterNumber>

			<!--
				Field : Procedure Id
				Target: HS.SDA3.Procedure ExternalId
				Target: /Container/Procedures/Procedure/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
			
			<!--
				Field : Procedure Type
				Target: HS.SDA3.Procedure Procedure
				Target: /Container/Procedures/Procedure/Procedure
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/code
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'Procedure'"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>

			<!--
				Field : Implantable Device
				Target: HS.SDA3.Device Device
				Target: /Container/Procedures/Procedure/Devices/Device
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/participant[@typeCode='DEV']
				StructuredMappingRef: Clinician
			-->
			<xsl:if test="hl7:participant[@typeCode='DEV']">
				<Devices>
					<xsl:apply-templates select="hl7:participant[@typeCode='DEV']/hl7:participantRole" mode="eP-ImplantableDevice"/>
				</Devices>
			</xsl:if>

			<!--
				Field : Procedure Date/Time
				Target: HS.SDA3.Procedure ProcedureTime
				Target: /Container/Procedures/Procedure/ProcedureTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/effectiveTime/@value
				Note  : Procedure CDA effectiveTime should have only a single
						value, but it is legal to have a high and a low value.
						When importing to SDA ProcedureTime, use the first found
						of effectiveTime/@value, effectiveTime/low/@value,
						effectiveTime/high/@value.
			-->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/@value">
					<xsl:apply-templates select="hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ProcedureTime'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="hl7:effectiveTime/hl7:low/@value">
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ProcedureTime'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="hl7:effectiveTime/hl7:high/@value">
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ProcedureTime'"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>

			<!--
				Field : Procedure Provider
				Target: HS.SDA3.Procedure Clinician
				Target: /Container/Procedures/Procedure/Clinician
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/performer
				StructuredMappingRef: Clinician
			-->
			<xsl:apply-templates select="hl7:performer" mode="fn-Clinician"/>

			<!--
				Field : Procedure Author
				Target: HS.SDA3.Procedure EnteredBy
				Target: /Container/Procedures/Procedure/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!--
				Field : Procedure Information Source
				Target: HS.SDA3.Procedure EnteredAt
				Target: /Container/Procedures/Procedure/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!--
				Field : Procedure Author Time
				Target: HS.SDA3.Procedure EnteredOn
				Target: /Container/Procedures/Procedure/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>

			<!--
				Field : Procedure Status
				Target: HS.SDA3.Procedure Status
 				Target: /Container/Procedures/Procedure/Status
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.7.1']/entry/procedure/statusCode/@code
			-->
			<xsl:apply-templates select="hl7:statusCode" mode="eP-ProcedureStatus"/>			

			<!--
				There is no property on HS.SDA3.Procedure that may be used to
				indicate that this procedure is from the CDA Plan of Treatment section in C-CDA2.1.
				Add a CustomPair to flag this when it is from Plan of Treatment in C-CDA2.1.
			-->
			<xsl:if test="$PlanOfTreatment='1'">
				<CustomPairs>
					<NVPair>
						<Name>PlanOfTreatment</Name>
						<Value>1</Value>
					</NVPair>
				</CustomPairs>
			</xsl:if>

			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eP-ImportCustom-Procedure"/>
		</Procedure>
	</xsl:template>
	
	<xsl:template match="hl7:participantRole" mode="eP-ImplantableDevice" >
		<Device>
			<Device>
				<SDACodingStandard><xsl:value-of select="hl7:playingDevice/hl7:code/@codeSystemName" /></SDACodingStandard>
				<Code><xsl:value-of select="hl7:playingDevice/hl7:code/@code" /></Code>
				<Description><xsl:value-of select="hl7:playingDevice/hl7:code/@displayName" /></Description>
			</Device>
			<UDIRoot><xsl:value-of select="hl7:id/@root" /></UDIRoot>
			<UDIExtension><xsl:value-of select="hl7:id/@extension" /></UDIExtension>
			<UDIAssigningAuthority><xsl:value-of select="hl7:id/@assigningAuthorityName" /></UDIAssigningAuthority>
		</Device>
	</xsl:template>

	<xsl:template match="hl7:statusCode" mode="eP-ProcedureStatus">
		<xsl:if test="@code">
			<xsl:variable name="actStatusCode" select="@code" />
			<Status>
				<SDACodingStandard><xsl:value-of select="$actStatusName"/></SDACodingStandard>
				<Code><xsl:value-of select="$actStatusCode" /></Code>
				<Description>
					<xsl:choose>
						<xsl:when test="$actStatusCode = 'completed'"><xsl:text>Completed</xsl:text></xsl:when>
						<xsl:when test="$actStatusCode = 'active'"><xsl:text>Active</xsl:text></xsl:when>
						<xsl:when test="$actStatusCode = 'aborted'"><xsl:text>Aborted</xsl:text></xsl:when>
						<xsl:when test="$actStatusCode = 'cancelled'"><xsl:text>Cancelled</xsl:text></xsl:when>
						<xsl:otherwise><xsl:value-of select="$actStatusCode" /></xsl:otherwise>
					</xsl:choose>
				</Description>
			</Status>
		</xsl:if>
	</xsl:template>

	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:procedure.
	-->
	<xsl:template match="*" mode="eP-ImportCustom-Procedure">
	</xsl:template>
	
</xsl:stylesheet>