<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Plan">
		<OtherOrder>
			<!-- Add SDA EncounterNumber only when explicitly stated on the Plan of Care entry. -->
			<xsl:if test=".//hl7:encounter">
				<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>
			</xsl:if>

			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:effectiveTime" mode="EnteredOn"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- Entering Organization -->
			<xsl:apply-templates select="." mode="EnteringOrganization"/>
			
			<!-- Start and End Time -->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="StartTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="EndTime"/>
		
			<!-- Placer and Filler IDs -->
			<xsl:apply-templates select="." mode="PlacerId"/>
			<xsl:apply-templates select="." mode="FillerId"/>
			
			<!-- Order Item -->
			<xsl:apply-templates select="hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
			</xsl:apply-templates>

			<!-- Order Status -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:observation/hl7:value" mode="PlanStatus"/>
 						
			<!-- Comments -->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-PlanOfCare"/>
		</OtherOrder>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanStatus">
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
	
	<xsl:template match="*" mode="PlanOfCare-Orders">
		<xsl:variable name="isLabOrder"><xsl:apply-templates select="hl7:observation" mode="PlanOfCare-IsLabOrder"/></xsl:variable>
		<xsl:variable name="isRadOrder"><xsl:apply-templates select="hl7:observation" mode="PlanOfCare-IsRadOrder"><xsl:with-param name="paramIsLabOrder" select="$isLabOrder"/></xsl:apply-templates></xsl:variable>
		
		<!--
			If the PlanOfCare-IsLabOrder and PlanOfCare-IsRadOrder
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
		<xsl:variable name="groupName"><xsl:value-of select="concat($elementName,'s')"/></xsl:variable>
		
		<xsl:element name="{$groupName}">
			<xsl:apply-templates select="hl7:observation" mode="PlanOfCare-Order">
				<xsl:with-param name="elementName" select="$elementName"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<!-- Override IsLabOrder to add custom logic for determining LabOrder in the Plan of Care section. -->
	<xsl:template match="*" mode="PlanOfCare-IsLabOrder">
		<xsl:choose>
			<xsl:when test="'1'='1'">0</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Override IsRadOrder to add custom logic for determining RadOrder in the Plan of Care section. -->
	<xsl:template match="*" mode="PlanOfCare-IsRadOrder">
		<xsl:param name="paramIsLabOrder" select="'0'"/>
		
		<xsl:choose>
			<xsl:when test="$paramIsLabOrder='0'">0</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Order">
		<xsl:param name="elementName"/>
		
		<xsl:element name="{$elementName}">
			<!-- Add SDA EncounterNumber only when explicitly stated on the Plan of Care entry. -->
			<xsl:if test=".//hl7:encounter">
				<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>
			</xsl:if>
			
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- EnteringOrganization -->
			<xsl:apply-templates select="." mode="EnteringOrganization"/>
			
			<!-- OrderedBy -->
			<xsl:apply-templates select="hl7:performer" mode="OrderedBy"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!-- From and To Time -->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:center">
					<xsl:choose>
						<xsl:when test="$planImportEffectiveTimeCenter='1'">
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="ToTime"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- Placer and Filler IDs -->
			<xsl:apply-templates select="." mode="PlacerId"/>
			<xsl:apply-templates select="." mode="FillerId"><xsl:with-param name="makeDefault" select="'0'"/></xsl:apply-templates>
			
			<!-- Order Item -->
			<xsl:apply-templates select="hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
			</xsl:apply-templates>
			
			<!-- Order Category -->
			<xsl:variable name="hsOrderCategory"><xsl:apply-templates select="." mode="order-category-code"/></xsl:variable>
			<xsl:if test="string-length($hsOrderCategory)">
				<OrderCategory>
					<Code>
						<xsl:value-of select="$hsOrderCategory"/>
					</Code>
				</OrderCategory>
			</xsl:if>
			
			<!--
				Status
				
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
			
			<!-- Specimen -->
			<xsl:apply-templates select=".//hl7:specimen/hl7:specimenRole/hl7:specimenPlayingEntity/hl7:code" mode="Specimen"/>
			
			<!-- Order Comments -->
			<xsl:apply-templates select="." mode="Comment"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Medications">
		<Medications>
			<!-- The Medication template is in Import/Entry-Modules/CCDA/Medication.xsl -->
			<xsl:apply-templates select="hl7:substanceAdministration" mode="Medication">
				<!-- Pass in medicationType of MEDPOC to force Medication Status to P. -->
				<xsl:with-param name="medicationType" select="'MEDPOC'"/>
			</xsl:apply-templates>
		</Medications>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Appointments">
		<Appointments>
			<xsl:apply-templates select="hl7:encounter" mode="PlanOfCare-Appointment"/>
		</Appointments>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Appointment">
		<Appointment>
			<!-- Status -->
			<Status>BOOKED</Status>
			
			<!-- Type -->
			<xsl:apply-templates select="hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
			</xsl:apply-templates>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- Placer and Filler Appointment IDs -->
			<!-- SDA Appointment requires PlacerApptId or FillerApptId (or both) be present -->
			<xsl:apply-templates select="." mode="PlacerApptId"/>
			<xsl:apply-templates select="." mode="FillerApptId"><xsl:with-param name="makeDefault" select="'0'"/></xsl:apply-templates>
			
			<!-- CareProvider -->
			<xsl:apply-templates select="hl7:performer" mode="CareProvider"/>
			
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!-- FromTime and ToTime -->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:center">
					<xsl:choose>
						<xsl:when test="$planImportEffectiveTimeCenter='1'">
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="ToTime"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="hl7:effectiveTime/hl7:low or hl7:effectiveTime/hl7:high">
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
				</xsl:when>
				<xsl:when test="hl7:effectiveTime/@value">
					<xsl:apply-templates select="hl7:effectiveTime" mode="FromTime"/>
				</xsl:when>
			</xsl:choose>
		</Appointment>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Referrals">
		<Referrals>
			<xsl:apply-templates select="hl7:encounter" mode="PlanOfCare-Referral"/>
		</Referrals>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Referral">
		<Referral>
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- Placer and Filler IDs -->
			<xsl:apply-templates select="." mode="PlacerId"/>
			<xsl:apply-templates select="." mode="FillerId"><xsl:with-param name="makeDefault" select="'0'"/></xsl:apply-templates>
			
			<!-- ReferralReason -->
			<xsl:variable name="referenceLink" select="substring-after(hl7:code/hl7:originalText/hl7:reference/@value, '#')"/>
			<xsl:variable name="referenceValue">
				<xsl:choose>
					<xsl:when test="string-length($referenceLink)">
						<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="reasonFromReasonSection" select="$sectionRootPath[hl7:templateId/@root=$ccda-ReasonForReferralSection]/text"/>
			<xsl:choose>
				<xsl:when test="string-length(hl7:code/hl7:originalText/text())">
					<ReferralReason><xsl:value-of select="hl7:code/hl7:originalText/text()"/></ReferralReason>
				</xsl:when>
				<xsl:when test="string-length($reasonFromReasonSection)">
					<ReferralReason><xsl:value-of select="$reasonFromReasonSection"/></ReferralReason>
				</xsl:when>
				<xsl:when test="string-length($referenceValue)">
					<ReferralReason><xsl:value-of select="$referenceValue"/></ReferralReason>
				</xsl:when>
			</xsl:choose>
			
			<!-- ReferredToProvider -->
			<xsl:apply-templates select="hl7:performer" mode="ReferredToProvider"/>
			
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!-- FromTime and ToTime -->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:center">
					<xsl:choose>
						<xsl:when test="$planImportEffectiveTimeCenter='1'">
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="ToTime"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
				</xsl:otherwise>
			</xsl:choose>
		</Referral>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Procedures">
		<Procedures>
			<!-- The Procedure template is in Import/Entry-Modules/CCDA/Procedure.xsl -->
			<xsl:apply-templates select="hl7:procedure" mode="Procedure">
				<xsl:with-param name="PlanOfCare" select="'1'"/>
			</xsl:apply-templates>
		</Procedures>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Goals">
		<CustomObjects>
			<xsl:apply-templates select="hl7:act" mode="PlanOfCare-Goal"/>
		</CustomObjects>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Goal">
		<CustomObject>
			<CustomType>PlanOfCareGoal</CustomType>
			<CustomPairs>
				<xsl:apply-templates select="hl7:code" mode="CodeTable-CustomPair">
					<xsl:with-param name="hsElementName" select="'PlanOfCareGoal'"/>
				</xsl:apply-templates>
			</CustomPairs>
			
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!-- FromTime and ToTime -->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:center">
					<xsl:choose>
						<xsl:when test="$planImportEffectiveTimeCenter='1'">
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="ToTime"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
		</CustomObject>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Instructions">
		<CustomObjects>
			<xsl:apply-templates select="hl7:act" mode="PlanOfCare-Instruction"/>
		</CustomObjects>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanOfCare-Instruction">
		<CustomObject>
			<CustomType>PlanOfCareInstructions</CustomType>
			<CustomPairs>
				<xsl:apply-templates select="hl7:code" mode="CodeTable-CustomPair">
					<xsl:with-param name="hsElementName" select="'PlanOfCareInstructions'"/>
				</xsl:apply-templates>
				
				<xsl:variable name="referenceLink" select="substring-after(hl7:text/hl7:reference/@value, '#')"/>
				<xsl:variable name="referenceValue">
					<xsl:choose>
						<xsl:when test="string-length($referenceLink)">
							<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<NVPair>
					<Name>PlanOfCareInstructionsText</Name>
					<Value><xsl:value-of select="$referenceValue"/></Value>
				</NVPair>
			</CustomPairs>
			
			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:author/hl7:time" mode="EnteredOn"/>
			
			<!-- FromTime and ToTime -->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/hl7:center">
					<xsl:choose>
						<xsl:when test="$planImportEffectiveTimeCenter='1'">
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="ToTime"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="hl7:effectiveTime/hl7:center" mode="FromTime"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="FromTime"/>
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="ToTime"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
		</CustomObject>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic.
	-->
	<xsl:template match="*" mode="ImportCustom-PlanOfCare">
	</xsl:template>
</xsl:stylesheet>
