<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
	<!-- AlsoInclude: Comment.xsl -->
	
	<xsl:template match="hl7:observation" mode="eSH-SocialHistory">
		<SocialHistory>
			<xsl:variable name="isSmokingObsv" select="hl7:templateId/@root=$ccda-SmokingStatusObservation"/>
			
			<!-- Social Habit -->
			<xsl:choose>
				<xsl:when test="$isSmokingObsv">
					<xsl:apply-templates select="." mode="eSH-SocialHabit-SmokingStatus"/>
				</xsl:when>
				<xsl:when test="hl7:templateId/@root=$ccda-TobaccoUse">
					<xsl:apply-templates select="." mode="eSH-SocialHabit-Description"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="eSH-SocialHabit-Description"/>
				</xsl:otherwise>
			</xsl:choose>
			

			<!-- Social Habit Quantity -->
			<xsl:if test="not($isSmokingObsv)">
				<xsl:apply-templates select="." mode="eSH-SocialHabitQuantity"/>
			</xsl:if>

			<!--
				Target: /Container/SocialHistories/SocialHistory/SocialHabitCategory
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/code
				Note  : SocialHabitCategory is used to distinguish Smoking Status from Tobacco Use
			-->
			<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'SocialHabitCategory'"/>
			</xsl:apply-templates>
			
			<!--
				Field : Social History Comments
				Target: HS.SDA3.SocialHistory SocialHabitComments
				Target: /Container/SocialHistories/SocialHistory/SocialHabitComments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/entryRelationship/observation[code/@code='48767-8']/value
			-->
			<xsl:apply-templates select="." mode="eCm-Comment">
				<xsl:with-param name="emitElementName" select="'SocialHabitComments'"/>
			</xsl:apply-templates>

			<!-- Social History Status -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value" mode="eSH-Status"/>

			<!--
				Field : Social History Author
				Target: HS.SDA3.SocialHistory EnteredBy
				Target: /Container/SocialHistories/SocialHistory/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!--
				Field : Social History Information Source
				Target: HS.SDA3.SocialHistory EnteredAt
				Target: /Container/SocialHistories/SocialHistory/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!--
				Field : Social History Author Time
				Target: HS.SDA3.SocialHistory EnteredOn
				Target: /Container/SocialHistories/SocialHistory/EnteredOn
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/author/time/@value
			-->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
			
			<!--
				Field : Social History Id
				Target: HS.SDA3.SocialHistory ExternalId
				Target: /Container/SocialHistories/SocialHistory/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
			
			<!--
				Field : Social History Start Date
				Target: HS.SDA3.SocialHistory FromTime
				Target: /Container/SocialHistories/SocialHistory/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/effectiveTime/low/@value
				Note  : If only CDA effectiveTime/@value is present then both
						SDA FromTime and ToTime are imported from that value.
			-->
			<!--
				Field : Social History End Date
				Target: HS.SDA3.SocialHistory ToTime
				Target: /Container/SocialHistories/SocialHistory/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/effectiveTime/high/@value
				Note  : If only CDA effectiveTime/@value is present then both
						SDA FromTime and ToTime are imported from that value.
			-->
			<!-- Social History effectiveTime can be single value (TS) or low and high (IVL_TS). -->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/@value">
					<!--<xsl:apply-templates select="hl7:effectiveTime" mode="fn-FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime" mode="fn-ToTime"/>-->
					<xsl:apply-templates select="hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'FromTime'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ToTime'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<!--<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>-->
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-I-timestamp">
						<xsl:with-param name="emitElementName" select="'FromTime'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-I-timestamp">
						<xsl:with-param name="emitElementName" select="'ToTime'"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
						
			<xsl:variable name="assessmentIDs" select="hl7:entryRelationship/hl7:observation[hl7:templateId/@root=$ccda-AssessmentScaleObservation]/hl7:id"/>
			<xsl:variable name="entryRefIDs" select="hl7:entryRelationship/hl7:act[hl7:templateId/@root=$ccda-EntryReference]/hl7:id"/>
			<xsl:if test="$assessmentIDs or $entryRefIDs">
				<DeterminantIDs>
					<xsl:apply-templates select="$assessmentIDs"  mode="fn-W-pName-ExternalId-reference">
						<xsl:with-param name="hsElementName">DeterminantIDsItem</xsl:with-param>
					</xsl:apply-templates>
					<xsl:apply-templates select="$entryRefIDs"  mode="fn-W-pName-ExternalId-reference">
						<xsl:with-param name="hsElementName">DeterminantIDsItem</xsl:with-param>
					</xsl:apply-templates>
				</DeterminantIDs>
				<!--If the SocialHistory has SDOH data, ensure that ExternalId is present to aid with deduplication-->
				<xsl:if test="not($sdaOverrideExternalId = 1)">
					<xsl:apply-templates select="." mode="fn-ExternalId-concatenated"/>
				</xsl:if>
			</xsl:if>

			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eSH-ImportCustom-SocialHistory"/>
		</SocialHistory>
	</xsl:template>
		
	<xsl:template match="hl7:observation" mode="eSH-SocialHabitQuantity">
		<!--
			Field : Social History Observed Value
			Target: HS.SDA3.SocialHistory SocialHabitQty
			Target: /Container/SocialHistories/SocialHistory/SocialHabitQty
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/value
		-->
		<SocialHabitQty>
			<xsl:if test="hl7:value">
				<xsl:variable name="valueCode" select="hl7:value/@code"/>
				<xsl:variable name="hasQtyUnit" select="hl7:value/@value and hl7:value/@unit"/>
				<xsl:variable name="quantityCodeSystem">
					<xsl:if test="$valueCode and hl7:value/@codeSystem">
						<xsl:value-of select="hl7:value/@codeSystem"/>
					</xsl:if>
				</xsl:variable>
				<xsl:if test="string-length($quantityCodeSystem)">
					<SDACodingStandard>
						<xsl:apply-templates select="." mode="fn-code-for-oid">
							<xsl:with-param name="OID" select="$quantityCodeSystem"/>
						</xsl:apply-templates>
					</SDACodingStandard>
				</xsl:if>
				<Code>
					<xsl:choose>
						<xsl:when test="$hasQtyUnit"><xsl:value-of select="concat(hl7:value/@value, ' ', hl7:value/@unit)"/></xsl:when>
						<xsl:when test="$valueCode"><xsl:value-of select="$valueCode"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="hl7:value/text()"/></xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description>
					<xsl:choose>
						<xsl:when test="$hasQtyUnit"><xsl:value-of select="concat(hl7:value/@value, ' ', hl7:value/@unit)"/></xsl:when>
						<xsl:when test="$valueCode and hl7:value/@displayName"><xsl:value-of select="hl7:value/@displayName"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="hl7:value/text()"/></xsl:otherwise>
					</xsl:choose>
				</Description>
			</xsl:if>
		</SocialHabitQty>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eSH-SocialHabit-Description">
		<!-- The mode formerly known as SocialHabitDescription -->
		<!--
			Field : Social History Type
			Target: HS.SDA3.SocialHistory SocialHabit
			Target: /Container/SocialHistories/SocialHistory/SocialHabit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/code
			StructuredMappingRef: CodeTableDetail
			Note  : If CDA entry/observation/code/@code is not
					present then SDA SocialHabit is imported
					from entry/observation/text instead.
		-->
		<xsl:choose>
			<xsl:when test="(hl7:code/@code) or (hl7:code/hl7:translation[1]/@codeSystem=$noCodeSystemOID) or (hl7:code/@nullFlavor and hl7:code/hl7:translation[1]/@code)">
				<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'SocialHabit'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="hl7:text" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'SocialHabit'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="eSH-SocialHabit-SmokingStatus">
		<!-- The mode formerly known as SmokingStatus -->
		<!--
			Field : Social History Type - Smoking Status
			Target: HS.SDA3.SocialHistory SocialHabit
			Target: /Container/SocialHistories/SocialHistory/SocialHabit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/value
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'SocialHabit'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:value" mode="eSH-Status">
		<!-- The mode formerly known as SocialHistoryStatus -->
		<!--
			Field : Social History Status
			Target: HS.SDA3.SocialHistory Status
			Target: /Container/SocialHistories/SocialHistory/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.17']/entry/observation/entryRelationship/observation[code/@code='33999-4']/value
			Note  : CDA value code of 55561003 is imported to SDA Status as "A".
					All other values - including blank - are imported as "I".
		-->
		<xsl:if test="@code">
			<Status>
				<xsl:choose>
					<xsl:when test="@code = '55561003'"><xsl:text>A</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text>I</xsl:text></xsl:otherwise>
				</xsl:choose>
			</Status>
		</xsl:if>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:observation.
	-->
	<xsl:template match="*" mode="eSH-ImportCustom-SocialHistory">
	</xsl:template>
	
</xsl:stylesheet>