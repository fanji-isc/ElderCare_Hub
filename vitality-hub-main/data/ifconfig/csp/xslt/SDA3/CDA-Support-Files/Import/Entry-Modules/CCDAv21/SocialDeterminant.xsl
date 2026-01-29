<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">
	<!-- AlsoInclude: Comment.xsl -->
	
	<xsl:template match="hl7:observation" mode="eSD-SocialDeterminant">
		<SocialDeterminant>
			<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'SocialDeterminantCode'"/>
			</xsl:apply-templates>
			
			<Status>A</Status>

			<Category>
				<SDACodingStandard>http://terminology.hl7.org/CodeSystem/observation-category</SDACodingStandard>
				<Code>survey</Code>
				<Description>Survey</Description>
			</Category>

			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>

			<xsl:apply-templates select="hl7:author" mode="fn-Performer"/>

			<xsl:apply-templates select="." mode="fn-EnteredBy"/>

			<xsl:apply-templates select="." mode="fn-ExternalId-concatenated"/>

			<xsl:choose>
				<xsl:when test="hl7:value and not(hl7:value/@nullFlavor)">
					<xsl:choose>
						<xsl:when test="hl7:value/@code">
							<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
								<xsl:with-param name="hsElementName" select="'SocialDeterminantValueCoded'"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="hl7:value/@value">
							<SocialDeterminantValueNumeric><xsl:value-of select="hl7:value/@value"/></SocialDeterminantValueNumeric>
							<xsl:if test="hl7:value/@unit">
								<SocialDeterminantUnitOfMeasure>
									<Code><xsl:value-of select="hl7:value/@unit"/></Code>
									<Description><xsl:value-of select="hl7:value/@unit"/></Description>
									<SDACodingStandard>UCUM</SDACodingStandard>
								</SocialDeterminantUnitOfMeasure>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<SocialDeterminantValueText><xsl:value-of select="hl7:value/text()"/></SocialDeterminantValueText>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:value/@nullFlavor" mode="eSD-DataAbsentReason"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/@value">
					<xsl:apply-templates select="hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'FromTime'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ToTime'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-I-timestamp">
						<xsl:with-param name="emitElementName" select="'FromTime'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-I-timestamp">
						<xsl:with-param name="emitElementName" select="'ToTime'"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="count(hl7:entryRelationship/hl7:observation[hl7:templateId/@root=$ccda-AssessmentScaleSupportingObservation]) &gt; 0">
				<MemberIDs>
					<xsl:for-each select="hl7:entryRelationship/hl7:observation[hl7:templateId/@root=$ccda-AssessmentScaleSupportingObservation]">
						<xsl:apply-templates select="hl7:id"  mode="fn-W-pName-ExternalId-reference">
							<xsl:with-param name="hsElementName">MemberIDsItem</xsl:with-param>
						</xsl:apply-templates>
					</xsl:for-each>
				</MemberIDs>
			</xsl:if>

			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eSD-ImportCustom-SocialDeterminant"/>
		</SocialDeterminant>

		<xsl:apply-templates select="hl7:entryRelationship/hl7:observation[hl7:templateId/@root=$ccda-AssessmentScaleSupportingObservation]" mode="eSD-SupportingObservation"/>
	</xsl:template>

	<xsl:template match="hl7:observation" mode="eSD-SupportingObservation">
		<SocialDeterminant>
			<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'SocialDeterminantCode'"/>
			</xsl:apply-templates>
			
			<Status>A</Status>

			<Category>
				<SDACodingStandard>http://terminology.hl7.org/CodeSystem/observation-category</SDACodingStandard>
				<Code>survey</Code>
				<Description>Survey</Description>
			</Category>

			<xsl:apply-templates select="../../hl7:author" mode="fn-Performer"/>

			<xsl:apply-templates select="../../hl7:author" mode="fn-EnteredBy"/>			

			<xsl:apply-templates select="../../hl7:author/hl7:time" mode="fn-EnteredOn"/>

			<xsl:apply-templates select="." mode="fn-ExternalId-concatenated"/>

			<xsl:choose>
				<xsl:when test="hl7:value and not(hl7:value/@nullFlavor)">
					<xsl:choose>
						<xsl:when test="hl7:value/@code">
							<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
								<xsl:with-param name="hsElementName" select="'SocialDeterminantValueCoded'"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="hl7:value/@value">
							<SocialDeterminantValueNumeric><xsl:value-of select="hl7:value/@value"/></SocialDeterminantValueNumeric>
							<xsl:if test="hl7:value/@unit">
								<SocialDeterminantUnitOfMeasure>
									<Code><xsl:value-of select="hl7:value/@unit"/></Code>
									<Description><xsl:value-of select="hl7:value/@unit"/></Description>
									<SDACodingStandard>UCUM</SDACodingStandard>
								</SocialDeterminantUnitOfMeasure>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<SocialDeterminantValueText><xsl:value-of select="hl7:value/text()"/></SocialDeterminantValueText>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:value/@nullFlavor" mode="eSD-DataAbsentReason"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="../../hl7:effectiveTime/@value">
					<xsl:apply-templates select="../../hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'FromTime'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="../../hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ToTime'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="../../hl7:effectiveTime/hl7:low" mode="fn-I-timestamp">
						<xsl:with-param name="emitElementName" select="'FromTime'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="../../hl7:effectiveTime/hl7:high" mode="fn-I-timestamp">
						<xsl:with-param name="emitElementName" select="'ToTime'"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eSD-ImportCustom-SocialDeterminant"/>
		</SocialDeterminant>
	</xsl:template>

	<xsl:template match="hl7:act" mode="eSD-EntryReference">
		<xsl:variable name="entryId" select="hl7:id/@root"/>
		<xsl:apply-templates select="//hl7:observation[hl7:templateId/@root=$ccda-AssessmentScaleObservation and hl7:id/@root=$entryId]" mode="eSD-SocialDeterminant"/>
	</xsl:template>

	<xsl:template match="hl7:value/@nullFlavor" mode="eSD-DataAbsentReason">
		<xsl:variable name="valueNullFlavor" select="@nullFlavor"/>
		<DataAbsentReason>
			<xsl:choose>
				<xsl:when test="$valueNullFlavor = 'NI'">
					<Code>unknown</Code>
					<Description>Unknown</Description>
				</xsl:when>
				<xsl:when test="$valueNullFlavor = 'NA'">
					<Code>not-applicable</Code>
					<Description>Not Applicable</Description>
				</xsl:when>
				<xsl:when test="$valueNullFlavor = 'UNK'">
					<Code>unknown</Code>
					<Description>Unknown</Description>
				</xsl:when>
				<xsl:when test="$valueNullFlavor = 'ASKU'">
					<Code>asked-unknown</Code>
					<Description>Asked But Unknown</Description>
				</xsl:when>
				<xsl:when test="$valueNullFlavor = 'NAV'">
					<Code>temp-unknown</Code>
					<Description>Temporarily Unknown</Description>
				</xsl:when>
				<xsl:when test="$valueNullFlavor = 'NASK'">
					<Code>not-asked</Code>
					<Description>Not Asked</Description>
				</xsl:when>
				<xsl:when test="$valueNullFlavor = 'MSK'">
					<Code>masked</Code>
					<Description>Masked</Description>
				</xsl:when>
				<xsl:when test="$valueNullFlavor = 'OTH'">
					<Code>unsupported</Code>
					<Description>Unsupported</Description>
				</xsl:when>
				<xsl:otherwise>
					<Code>unknown</Code>
					<Description>Unknown</Description>
				</xsl:otherwise>
			</xsl:choose>
			<SDACodingStandard>http://hl7.org/fhir/R4/valueset-data-absent-reason.html</SDACodingStandard>
		</DataAbsentReason>
	</xsl:template>

	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:observation/hl7:entryRelationship/hl7:observation.
	-->
	<xsl:template match="*" mode="eSD-ImportCustom-SocialDeterminant">
	</xsl:template>
	
</xsl:stylesheet>