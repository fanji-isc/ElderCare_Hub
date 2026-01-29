<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="isc hl7">
	<!-- AlsoInclude: Comment.xsl Medication.xsl Procedure.xsl Result.xsl -->
	
	<xsl:template match="hl7:observation" mode="ePOT-Plan">
		<OtherOrder>
			<!-- Add SDA EncounterNumber only when explicitly stated on the Plan of Treatment entry. -->
			<xsl:if test=".//hl7:encounter">
				<EncounterNumber><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></EncounterNumber>
			</xsl:if>

			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:effectiveTime" mode="fn-EnteredOn"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
			
			<!-- Entering Organization -->
			<xsl:apply-templates select="." mode="fn-EnteringOrganization"/>
			
			<!-- Start and End Time -->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-StartTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-EndTime"/>
		
			<!-- Placer and Filler IDs -->
			<xsl:apply-templates select="." mode="fn-PlacerId"/>
			<xsl:apply-templates select="." mode="fn-FillerId"/>
			
			<!-- Order Item -->
			<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
			</xsl:apply-templates>

			<!-- Order Status -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:observation/hl7:value" mode="ePOT-Status-Plan"/>
 						
			<!-- Comments -->
			<!-- The Comment template is in Import/Entry-Modules/CCDA/Comment.xsl -->
			<xsl:apply-templates select="." mode="eCm-Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ePOT-ImportCustom-PlanOfTreatment"/>
		</OtherOrder>
	</xsl:template>
	
	<xsl:template match="hl7:value" mode="ePOT-Status-Plan">
		<xsl:if test="@code">
			<Status>
				<xsl:choose>
					<xsl:when test="@code = '55561003'"><xsl:text>A</xsl:text></xsl:when>
					<xsl:when test="@code = '421139008'"><xsl:text>H</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text>I</xsl:text></xsl:otherwise>
				</xsl:choose>
			</Status>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="ePOT-paramName-Orders">
		<xsl:variable name="isLabOrder"><xsl:apply-templates select="hl7:observation" mode="ePOT-B-IsLabOrder"/></xsl:variable>
		<xsl:variable name="isRadOrder">
			<xsl:apply-templates select="hl7:observation" mode="ePOT-B-IsRadOrder">
				<xsl:with-param name="paramIsLabOrder" select="$isLabOrder"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<!--
			If the PlanOfTreatment-IsLabOrder and PlanOfTreatment-IsRadOrder
			templates have not been customized then all orders
			will be considered OtherOrder.
		-->
		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="$isLabOrder='1'">LabOrder</xsl:when>
				<xsl:when test="$isRadOrder='1'">RadOrder</xsl:when>
				<xsl:otherwise>OtherOrder</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:element name="{concat($elementName,'s')}">
			<xsl:apply-templates select="hl7:observation" mode="ePOT-paramName-Order">
				<xsl:with-param name="elementName" select="$elementName"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="ePOT-B-IsLabOrder">
		<!-- Override IsLabOrder to add custom logic for determining LabOrder in the Plan of Care section. -->
		<xsl:choose>
			<xsl:when test="'1'='1'">0</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="ePOT-B-IsRadOrder">
		<!-- Override IsRadOrder to add custom logic for determining RadOrder in the Plan of Care section. -->
		<xsl:param name="paramIsLabOrder" select="'0'"/>
		
		<xsl:choose>
			<xsl:when test="$paramIsLabOrder='0'">0</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:observation" mode="ePOT-paramName-Order">
		<xsl:param name="elementName"/>
		
		<xsl:element name="{$elementName}">			
			<!-- Placer and Filler IDs -->
			<xsl:apply-templates select="." mode="fn-PlacerId"/>
			<xsl:apply-templates select="." mode="fn-FillerId"><xsl:with-param name="makeDefault" select="'0'"/></xsl:apply-templates>

			<!-- Order Item -->
			<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
			</xsl:apply-templates>
			
			<!-- Order Category -->
			<!-- The order-category-mode template is in Import/Entry-Modules/CCDA/Result.xsl -->
			<xsl:variable name="hsOrderCategory"><xsl:apply-templates select="." mode="eR-order-category-code"/></xsl:variable>
			<xsl:if test="string-length($hsOrderCategory)">
				<OrderCategory>
					<Code>
						<xsl:value-of select="$hsOrderCategory"/>
					</Code>
				</OrderCategory>
			</xsl:if>
			
			<!-- OrderedBy -->
			<xsl:apply-templates select="hl7:performer" mode="fn-OrderedBy"/>

			<!-- EnteringOrganization -->
			<xsl:apply-templates select="." mode="fn-EnteringOrganization"/>

			<!-- Status
				If start time is after today then Status is P (Future Scheduled Test),
				otherwise Status is IP (Diagnostic Test Pending).
			-->
			<Status>
				<xsl:choose>
					<xsl:when test="not(string-length(hl7:effectiveTime/hl7:low/@value))">P</xsl:when>
					<xsl:when test="isc:evaluate('dateDiff', 'dd', translate(isc:evaluate('xmltimestamp', hl7:effectiveTime/hl7:low/@value),'TZ',' ')) &lt; 0">P</xsl:when>
					<xsl:otherwise>IP</xsl:otherwise>
				</xsl:choose>
			</Status>

			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>

			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
			
			<!-- From and To Time -->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
						
			<!-- Specimen -->
			<!-- The Specimen template is in Import/Entry-Modules/CCDA/Result.xsl -->
			<xsl:apply-templates select=".//hl7:specimen/hl7:specimenRole/hl7:specimenPlayingEntity/hl7:code" mode="eR-Specimen"/>
			
			<!-- Order Comments -->
			<!-- The Comment template is in Import/Entry-Modules/CCDA/Comment.xsl -->
			<xsl:apply-templates select="." mode="eCm-Comment"/>

			<!-- Add SDA EncounterNumber only when explicitly stated on the Plan of Treatment entry. -->
			<xsl:if test=".//hl7:encounter">
				<EncounterNumber><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></EncounterNumber>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="ePOT-Medications">
		<Medications>
			<!-- The Medication template is in Import/Entry-Modules/CCDA/Medication.xsl -->
			<xsl:apply-templates select="hl7:substanceAdministration" mode="eM-Medication">
				<!-- Pass in medicationType of MEDPOC to force Medication Status to P. -->
				<xsl:with-param name="medicationType" select="'MEDPOC'"/>
			</xsl:apply-templates>
		</Medications>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="ePOT-Appointments">
		<Appointments>
			<xsl:apply-templates select="hl7:encounter" mode="ePOT-Appointment"/>
		</Appointments>
	</xsl:template>
	
	<xsl:template match="hl7:encounter" mode="ePOT-Appointment">
		<Appointment>
			<!-- Status -->
			<Status>BOOKED</Status>
			
			<!-- OrderItem -->
			<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
			</xsl:apply-templates>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
			
			<!-- Placer and Filler Appointment IDs -->
			<!-- SDA Appointment requires PlacerApptId or FillerApptId (or both) be present -->
			<xsl:apply-templates select="." mode="fn-PlacerApptId"/>
			<xsl:apply-templates select="." mode="fn-FillerApptId"><xsl:with-param name="makeDefault" select="'0'"/></xsl:apply-templates>
			
			<!-- CareProvider -->
			<xsl:apply-templates select="hl7:performer" mode="fn-W-CareProvider"/>
			
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
			
			<!-- FromTime and ToTime -->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:low or hl7:effectiveTime/hl7:high">
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>
				</xsl:when>
				<xsl:when test="hl7:effectiveTime/@value">
					<xsl:apply-templates select="hl7:effectiveTime" mode="fn-FromTime"/>
				</xsl:when>
			</xsl:choose>
			
		</Appointment>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="ePOT-Referrals">
		<Referrals>
			<xsl:apply-templates select="hl7:encounter" mode="ePOT-Referral"/>
		</Referrals>
	</xsl:template>
	
	<xsl:template match="hl7:encounter" mode="ePOT-Referral">
		<Referral>
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
			
			<!-- Placer and Filler IDs -->
			<xsl:apply-templates select="." mode="fn-PlacerId"/>
			<xsl:apply-templates select="." mode="fn-FillerId"><xsl:with-param name="makeDefault" select="'0'"/></xsl:apply-templates>
			
			<!-- ReferralReason -->
			<xsl:choose>
				<xsl:when test="string-length(hl7:code/hl7:originalText/text())">
					<ReferralReason><xsl:value-of select="hl7:code/hl7:originalText/text()"/></ReferralReason>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="reasonFromReasonSection" select="key('sectionsByRoot',$ccda-ReasonForReferralSection)/text"/>
					<xsl:choose>
						<xsl:when test="string-length($reasonFromReasonSection)">
							<ReferralReason><xsl:value-of select="$reasonFromReasonSection"/></ReferralReason>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="referenceLink" select="substring-after(hl7:code/hl7:originalText/hl7:reference/@value, '#')"/>
							<xsl:variable name="referenceValue">
								<xsl:choose>
									<xsl:when test="string-length($referenceLink)">
										<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
									</xsl:when>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="string-length($referenceValue)">
								<ReferralReason><xsl:value-of select="$referenceValue"/></ReferralReason>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- ReferringProvider -->
			<xsl:apply-templates select="$input/hl7:informant" mode="fn-ReferringProvider"/>

			<!-- ReferredToProvider -->
			<xsl:apply-templates select="hl7:performer" mode="fn-ReferredToProvider"/>
			
			
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
			
			<!-- FromTime and ToTime -->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>
		</Referral>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="ePOT-Procedures">
		<Procedures>
			<!-- The Procedure template is in Import/Entry-Modules/CCDAv21/Procedure.xsl -->
			<xsl:apply-templates select="hl7:procedure" mode="eP-Procedure">
				<xsl:with-param name="PlanOfTreatment" select="'1'"/>
			</xsl:apply-templates>
		</Procedures>
	</xsl:template>	

	<!--
		Field : Goals Goal
		Target: HS.SDA3.Document DocumentName
		Target: /Container/Documents/Document/DocumentName
		Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.9']/entry/act/code/@displayName
		Note  : The SDA3 DocumentName string-type property is populated with the
				first found of CDA code/@displayName, code/@originalText, or code/@code.
	-->
	<xsl:template match="hl7:observation" mode="ePOT-Goal">
		<Goal>
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!-- FromTime and ToTime -->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="fn-FromTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-ToTime"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="fn-ExternalId"/>

			<Description><xsl:apply-templates select="hl7:text" mode="fn-TextValue" /></Description>

			<Target>
				<xsl:apply-templates select="hl7:code" mode="fn-CodeTable" >
					<xsl:with-param name="hsElementName" select="'ObservationCode'"/>					
				</xsl:apply-templates>
			</Target>

			<!--
				Field : Goal Authors
				Target: HS.SDA3.Goal Authors
				Target: /Container/Goals/Goal/Authors
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/observation/author
			-->
			<xsl:if test="hl7:author">
				<Authors>
					<xsl:apply-templates select="hl7:author" mode="eAP-DocumentProvider"/>
				</Authors>
			</xsl:if>

			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>

		</Goal>
	</xsl:template>	
	
	
	<xsl:template match="hl7:section" mode="ePOT-Document-Instruction">
		<!-- we keep PlanOfCare in the SDA for compatibility with 1.1 transforms -->
		<xsl:for-each select="hl7:entry[hl7:act/hl7:templateId/@root=$ccda-Instructions]">
			<Document>
				<DocumentType>
					<Code>PlanOfCareInstruction</Code>
					<Description>PlanOfCareInstruction</Description>
				</DocumentType>

				<!--
					Field : Document NoteText
					Target: HS.SDA3.Document NoteText
					Target: /Container/Documents/Document/NoteText
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.10']/entry/act/text/reference/@value
					Note  : The Document NoteText is imported from the first CDA comment
							entryRelationship, the text element, or code/originalText.
				-->			
				<xsl:choose>
					<xsl:when test="hl7:act/hl7:entryRelationship[@typeCode='SUBJ']/hl7:act[hl7:templateId/@root=$ccda-CommentActivity]/hl7:text">
						<xsl:apply-templates select="." mode="eCm-Comment">
							<xsl:with-param name="elementName" select="'NoteText'"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>

						<xsl:variable name="textReferenceLink" select="substring-after(hl7:act[hl7:templateId/@root=$ccda-Instructions]/hl7:text/hl7:reference/@value, '#')"/>
						<xsl:variable name="textReferenceValue">
							<xsl:if test="string-length($textReferenceLink)">
								<xsl:value-of select="normalize-space(key('narrativeKey', $textReferenceLink))"/>
							</xsl:if>
						</xsl:variable>			
						<xsl:variable name="originalTextReferenceLink" select="substring-after(hl7:act/hl7:code/hl7:originalText/hl7:reference/@value, '#')"/>
						<xsl:variable name="originalTextReferenceValue">
							<xsl:if test="string-length($originalTextReferenceLink)">
								<xsl:value-of select="key('narrativeKey', $originalTextReferenceLink)"/>
							</xsl:if>
						</xsl:variable>		

						<xsl:choose>
							<xsl:when test="string-length(normalize-space($textReferenceValue))">
								<NoteText>
									<xsl:value-of select="$textReferenceValue"/>
								</NoteText>
							</xsl:when>				
							<xsl:when test="string-length(normalize-space(hl7:entry/hl7:act[hl7:templateId/@root=$ccda-Instructions]/hl7:text/text()))">
								<NoteText>						
									<xsl:value-of select="hl7:entry/hl7:act/hl7:text/text()"/>
								</NoteText>
							</xsl:when>
							<xsl:when test="string-length(normalize-space($originalTextReferenceValue))">
								<NoteText>
									<xsl:value-of select="$originalTextReferenceValue"/>
								</NoteText>
							</xsl:when>
							<xsl:when test="string-length(normalize-space(hl7:code/hl7:originalText/text()))">
								<NoteText>
									<xsl:value-of select="hl7:entry/hl7:act[hl7:templateId/@root=$ccda-Instructions]/hl7:code/hl7:originalText/text()"/>
								</NoteText>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>		

				<!-- Custom SDA Data-->
				<xsl:apply-templates select="." mode="ePOT-ImportCustom-PlanOfTreatment"/>

			</Document>
		</xsl:for-each>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic.
	     The input node spec is normally $sectionRootPath/hl7:entry/hl7:observation.
	-->
	<xsl:template match="*" mode="ePOT-ImportCustom-PlanOfTreatment">
	</xsl:template>
	
</xsl:stylesheet>