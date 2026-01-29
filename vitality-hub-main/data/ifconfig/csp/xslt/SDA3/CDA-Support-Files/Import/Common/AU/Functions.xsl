<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 sdtc xsi exsl">

<xsl:template match="*" mode="CodeTable">
		<xsl:param name="hsElementName"/>
		<xsl:param name="subCodedElementRootPath"/>
		<xsl:param name="subElementName"/>
		<xsl:param name="observationValueUnits"/>
		<xsl:param name="importOriginalText" select="'0'"/>

		<!--
			firstTranslationCodeSystem is the codeSystem attribute on
			the first, if any, <translation> for this code.  If it is
			the No Code System OID, then we know that that translation
			was added by HealthShare export.
		-->
		<xsl:variable name="firstTranslationCodeSystem"><xsl:value-of select="hl7:translation[1]/@codeSystem"/></xsl:variable>

		<xsl:choose>

			<xsl:when test="($firstTranslationCodeSystem=$noCodeSystemOID) or ((@nullFlavor) and (hl7:translation[1]/@code))">
				<xsl:element name="{$hsElementName}">
					<xsl:apply-templates select="." mode="CodeTableDetail">
						<xsl:with-param name="hsElementName" select="$hsElementName"/>
						<xsl:with-param name="useFirstTranslation" select="'1'"/>
						<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
						<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
					</xsl:apply-templates>

					<xsl:if test="$subCodedElementRootPath = true()">
						<xsl:apply-templates select="$subCodedElementRootPath" mode="CodeTable">
							<xsl:with-param name="hsElementName" select="$subElementName"/>
							<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
							<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:element>
			</xsl:when>

			<xsl:when test="(string-length(substring-after(.//hl7:reference/@value, '#')) or not(@nullFlavor)) and ($firstTranslationCodeSystem != $noCodeSystemOID)">
				<xsl:element name="{$hsElementName}">
					<xsl:apply-templates select="." mode="CodeTableDetail">
						<xsl:with-param name="hsElementName" select="$hsElementName"/>
						<xsl:with-param name="useFirstTranslation" select="'0'"/>
						<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
						<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
					</xsl:apply-templates>

					<xsl:if test="$subCodedElementRootPath = true()">
						<xsl:apply-templates select="$subCodedElementRootPath" mode="CodeTable">
							<xsl:with-param name="hsElementName" select="$subElementName"/>
							<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
							<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:element>
			</xsl:when>

			<xsl:when test="@nullFlavor and (string-length(substring-after(.//hl7:reference/@value, '#')) or string-length(hl7:originalText/text()))">
				<xsl:element name="{$hsElementName}">
					<xsl:apply-templates select="." mode="CodeTableDetail">
						<xsl:with-param name="hsElementName" select="$hsElementName"/>
						<xsl:with-param name="useFirstTranslation" select="'0'"/>
						<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
						<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
					</xsl:apply-templates>

					<xsl:if test="$subCodedElementRootPath = true()">
						<xsl:apply-templates select="$subCodedElementRootPath" mode="CodeTable">
							<xsl:with-param name="hsElementName" select="$subElementName"/>
							<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
							<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:element>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!--
		CodeTable-CustomPair is the CodeTable template, adapted
		for use with CustomPairs.  The difference between this
		and the CodeTable template is that this template does
		not support subCodedElementRootPath or subElementName,
		and it passes the isCustomPair parameter with a value
		of 1 when calling the CodeTableDetail template.
	-->
	<xsl:template match="*" mode="CodeTable-CustomPair">
		<xsl:param name="hsElementName"/>

		<!--
			firstTranslationCodeSystem is the codeSystem attribute on
			the first, if any, <translation> for this code.  If it is
			the No Code System OID, then we know that that translation
			was added by HealthShare export.
		-->
		<xsl:variable name="firstTranslationCodeSystem"><xsl:value-of select="hl7:translation[1]/@codeSystem"/></xsl:variable>

		<xsl:choose>

			<xsl:when test="($firstTranslationCodeSystem=$noCodeSystemOID) or ((@nullFlavor) and (hl7:translation[1]/@code))">
				<xsl:apply-templates select="." mode="CodeTableDetail">
					<xsl:with-param name="hsElementName" select="$hsElementName"/>
					<xsl:with-param name="useFirstTranslation" select="'1'"/>
					<xsl:with-param name="isCustomPair" select="'1'"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:when test="(string-length(substring-after(.//hl7:reference/@value, '#')) or not(@nullFlavor)) and ($firstTranslationCodeSystem != $noCodeSystemOID)">
				<xsl:apply-templates select="." mode="CodeTableDetail">
					<xsl:with-param name="hsElementName" select="$hsElementName"/>
					<xsl:with-param name="useFirstTranslation" select="'0'"/>
					<xsl:with-param name="isCustomPair" select="'1'"/>
				</xsl:apply-templates>
			</xsl:when>

		</xsl:choose>

	</xsl:template>

	<xsl:template match="*" mode="CodeTableDetail">
		<xsl:param name="hsElementName"/>
		<xsl:param name="useFirstTranslation"/>
		<xsl:param name="isCustomPair" select="'0'"/>
		<xsl:param name="observationValueUnits"/>
		<xsl:param name="importOriginalText" select="'0'"/>

		<!--
			StructuredMapping: CodeTableDetail

			Field
			Path  : Code
			XPath : Code/text()
			Source: @code
			Note  : If @codeSystem on the first translation sub-element
					is the ISC-NoCodeSystem OID, then Code, Description and
					SDACodingStandard are imported from that translation
					element, instead of from the current source element.

			Field
			Path  : Description
			XPath : Description/text()
			Source: @displayName

			Field
			Path  : SDACodingStandard
			XPath : SDACodingStandard/text()
			Source: @codeSystem
			Note  : SDACodingStandard is the IdentityCode for the OID
					Registry entry for the @codeSystem OID.

			Field
			Path  : OriginalText
			XPath : OriginalText/text()
			Source: originalText/text()
			Note  : CDA originalText may have text() or it may have a reference
					sub-element that has a @value attribute that is a pointer
					to text in the narrative.

			Field
			Path  : PriorCodes.PriorCode.Code
			XPath : PriorCodes/PriorCode/Code/text()
			Source: translation/@code
			Note  : translation is used to populate PriorCodes when @codeSystem
					on the translation is not the ISC-NoCodeSystem OID.

			Field
			Path  : PriorCodes.PriorCode.Description
			XPath : PriorCodes/PriorCode/Description/text()
			Source: translation/@displayName
			Note  : translation is used to populate PriorCodes when @codeSystem
					on the translation is not the ISC-NoCodeSystem OID.

			Field
			Path  : PriorCodes.PriorCode.SDACodingStandard
			XPath : PriorCodes/PriorCode/SDACodingStandard/text()
			Source: translation/@codeSystem
			Note  : translation is used to populate PriorCodes when @codeSystem
					on the translation is not the ISC-NoCodeSystem OID.
					SDACodingStandard is the IdentityCode for the OID Registry
					entry for the @codeSystem OID.
		-->

		<xsl:variable name="referenceLink" select="substring-after(.//hl7:reference/@value, '#')"/>
		<xsl:variable name="referenceValue">
			<xsl:choose>
				<xsl:when test="string-length($referenceLink)">
					<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="codingStandardTemp">
			<xsl:choose>
				<xsl:when test="not($useFirstTranslation='1')">
					<xsl:apply-templates select="." mode="SDACodingStandard-text"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:translation[1]" mode="SDACodingStandard-text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--
			2.16.840.1.113883.6.59 is the old retired CVX code.
			It should not be defined in the HS OID Registry.

			$cvxName is defined in OIDs-Other.xsl and is based
			on OID 2.16.840.1.113883.12.292.
		 -->
		<xsl:variable name="codingStandard">
			<xsl:choose>
				<xsl:when test="not($codingStandardTemp='2.16.840.1.113883.6.59')">
					<xsl:value-of select="$codingStandardTemp"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$cvxName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--
			Let originalText retain line feeds and excess white
			space, but only if there is anything more than line
			feeds and excess white space.
		-->
		<xsl:variable name="originalText">
			<xsl:choose>
				<xsl:when test="string-length(normalize-space($referenceValue))"><xsl:value-of select="$referenceValue"/></xsl:when>
				<xsl:when test="string-length(normalize-space(hl7:originalText/text()))"><xsl:value-of select="hl7:originalText/text()"/></xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="not($useFirstTranslation='1')">
					<xsl:choose>
						<xsl:when test="@xsi:type = 'ST'"><xsl:value-of select="normalize-space(text())"/></xsl:when>
						<xsl:when test="@code"><xsl:value-of select="translate(@code, '_', ' ')"/></xsl:when>
						<xsl:when test="string-length(normalize-space($referenceValue))"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
						<xsl:when test="string-length(normalize-space(hl7:originalText/text()))"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
						<xsl:when test="($hsElementName='OrderItem') and string-length($orderItemDefaultCode)"><xsl:value-of select="$orderItemDefaultCode"/></xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="hl7:translation[1]/@xsi:type = 'ST'"><xsl:value-of select="normalize-space(hl7:translation[1]/text())"/></xsl:when>
						<xsl:when test="hl7:translation[1]/@code"><xsl:value-of select="translate(hl7:translation[1]/@code, '_', ' ')"/></xsl:when>
						<xsl:when test="string-length(normalize-space($referenceValue))"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
						<xsl:when test="string-length(normalize-space(hl7:originalText/text()))"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="not($useFirstTranslation='1')">
					<xsl:choose>
						<xsl:when test="string-length(normalize-space(@displayName))"><xsl:value-of select="normalize-space(@displayName)"/></xsl:when>
						<xsl:when test="@xsi:type = 'ST'"><xsl:value-of select="normalize-space(text())"/></xsl:when>
						<xsl:when test="string-length(normalize-space($referenceValue))"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
						<xsl:when test="normalize-space(hl7:originalText/text())"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
						<xsl:when test="($hsElementName='OrderItem') and string-length($orderItemDefaultDescription)"><xsl:value-of select="$orderItemDefaultDescription"/></xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length(normalize-space(hl7:translation[1]/@displayName))"><xsl:value-of select="normalize-space(hl7:translation[1]/@displayName)"/></xsl:when>
						<xsl:when test="hl7:translation[1]/@xsi:type = 'ST'"><xsl:value-of select="normalize-space(hl7:translation[1]/text())"/></xsl:when>
						<xsl:when test="string-length(normalize-space($referenceValue))"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
						<xsl:when test="normalize-space(hl7:originalText/text())"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="not($isCustomPair=1)">
				<xsl:if test="string-length($codingStandard)"><SDACodingStandard><xsl:value-of select="$codingStandard"/></SDACodingStandard></xsl:if>
				<Code><xsl:value-of select="$code"/></Code>
				<Description><xsl:value-of select="$description"/></Description>
				<xsl:if test="string-length($observationValueUnits)">
					<ObservationValueUnits>
						<Code>
							<xsl:value-of select="$observationValueUnits"/>
						</Code>
					</ObservationValueUnits>
				</xsl:if>
				<xsl:if test="$importOriginalText='1' and string-length($originalText)"><OriginalText><xsl:value-of select="$originalText"/></OriginalText></xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length($codingStandard)">
					<NVPair>
						<Name><xsl:value-of select="concat($hsElementName,'CodingStandard')"/></Name>
						<Value><xsl:value-of select="$codingStandard"/></Value>
					</NVPair>
				</xsl:if>
				<NVPair>
					<Name><xsl:value-of select="concat($hsElementName,'Code')"/></Name>
					<Value><xsl:value-of select="$code"/></Value>
				</NVPair>
				<NVPair>
					<Name><xsl:value-of select="concat($hsElementName,'Description')"/></Name>
					<Value><xsl:value-of select="$description"/></Value>
				</NVPair>
			</xsl:otherwise>
		</xsl:choose>

		<!-- Prior Codes -->
		<!-- Use property names of translatable types, not class names. So TestItemCode instead of LabTestItem, OrderItem instead of Order -->
		<xsl:if test="(not($isCustomPair=1)) and contains('|Allergy|AllergyCategory|Diagnosis|DiagnosisType|DocumentType|TestItemCode|ObservationCode|OrderItem|Procedure|Severity|', concat('|', $hsElementName, '|'))">
			<xsl:apply-templates select="." mode="PriorCodes">
				<xsl:with-param name="useFirstTranslation" select="$useFirstTranslation"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="TextValue">
		<xsl:param name="narrativeImportMode" select="$narrativeImportModeGeneral"/>

		<xsl:variable name="referenceLink" select="substring-after(.//hl7:reference/@value, '#')"/>
		<xsl:variable name="referenceValue">
			<xsl:choose>
				<xsl:when test="string-length($referenceLink)">
					<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length(translate($referenceValue,'&#10;',''))">
				<xsl:apply-templates select="key('narrativeKey', $referenceLink)" mode="importNarrative">
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string-length(translate(text(),'&#10;',''))">
				<xsl:value-of select="text()"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!--
		PriorCodes builds PriorCodes only if there is more than
		one translation element in the current coded element,
		OR if there is only one translation element and it was
		not used to export to SDA Code and Description already.
	-->
	<xsl:template match="*" mode="PriorCodes">
		<xsl:param name="useFirstTranslation"/>
		<xsl:if test="count(hl7:translation)>1 or (count(hl7:translation)=1 and not($useFirstTranslation='1'))">
			<PriorCodes>
				<xsl:apply-templates select="hl7:translation[not(position()=1 and $useFirstTranslation='1')]" mode="PriorCode"/>
			</PriorCodes>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="PriorCode">
		<PriorCode>
			<CodeSystem><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="@codeSystem"/></xsl:apply-templates></CodeSystem>
			<Code><xsl:value-of select="@code"/></Code>
			<Description><xsl:value-of select="@displayName"/></Description>
			<Type>A</Type>
		</PriorCode>
	</xsl:template>

	<xsl:template match="*" mode="SDACodingStandard">
		<xsl:if test="(string-length(@codeSystem)) and (not(@codeSystem=$noCodeSystemOID))"><SDACodingStandard><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="@codeSystem"/></xsl:apply-templates></SDACodingStandard></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="SDACodingStandard-text">
		<xsl:if test="(string-length(@codeSystem)) and (not(@codeSystem=$noCodeSystemOID))"><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="@codeSystem"/></xsl:apply-templates></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="SendingFacility">
		<xsl:variable name="organizationInformation"><xsl:apply-templates select=".//hl7:representedOrganization" mode="OrganizationInformation"/></xsl:variable>

		<xsl:if test="string-length($organizationInformation)">
			<!-- Parse facility information -->
			<xsl:variable name="facilityOID" select="substring-before(substring-after($organizationInformation, 'F1:'), '|')"/>
			<xsl:variable name="facilityCode" select="substring-before(substring-after($organizationInformation, 'F2:'), '|')"/>
			<xsl:variable name="facilityDescription" select="substring-before(substring-after($organizationInformation, 'F3:'), '|')"/>

			<SendingFacility>
				<xsl:choose>
					<xsl:when test="string-length($facilityCode)"><xsl:value-of select="$facilityCode"/></xsl:when>
					<xsl:when test="string-length($facilityDescription)"><xsl:value-of select="$facilityDescription"/></xsl:when>
					<xsl:otherwise>Unknown</xsl:otherwise>
				</xsl:choose>
			</SendingFacility>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="SendingFacility-AU">
		<xsl:choose>
			<xsl:when test="string-length(@extension)">
				<SendingFacility>
					<xsl:value-of select="@extension"/>
				</SendingFacility>
			</xsl:when>
			<xsl:when test="string-length(@root)">
				<SendingFacility>
					<xsl:apply-templates select="." mode="code-for-oid">
						<xsl:with-param name="OID" select="@root"/>
					</xsl:apply-templates>
				</SendingFacility>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="SendingFacilityValue">
		<xsl:choose>
			<xsl:when test="hl7:componentOf/hl7:encompassingEncounter/hl7:location/hl7:healthCareFacility/hl7:serviceProviderOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/ext:asEntityIdentifier/ext:id[@assigningAuthorityName='HPI-O']/@root">
				<xsl:apply-templates select="hl7:componentOf/hl7:encompassingEncounter/hl7:location/hl7:healthCareFacility/hl7:serviceProviderOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/ext:asEntityIdentifier/ext:id[@assigningAuthorityName='HPI-O']" mode="SendingFacility-AU"/>
			</xsl:when>
			<xsl:when test="hl7:componentOf/hl7:encompassingEncounter/hl7:location/hl7:healthCareFacility/hl7:serviceProviderOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/ext:asEntityIdentifier/ext:id/@root">
				<xsl:apply-templates select="hl7:componentOf/hl7:encompassingEncounter/hl7:location/hl7:healthCareFacility/hl7:serviceProviderOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/ext:asEntityIdentifier/ext:id" mode="SendingFacility-AU"/>
			</xsl:when>
			<xsl:when test="hl7:author/hl7:assignedAuthor/hl7:assignedPerson/ext:asEmployment/ext:employerOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/ext:asEntityIdentifier/ext:id[@assigningAuthorityName='HPI-O']/@root">
				<xsl:apply-templates select="hl7:author/hl7:assignedAuthor/hl7:assignedPerson/ext:asEmployment/ext:employerOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/ext:asEntityIdentifier/ext:id[@assigningAuthorityName='HPI-O']" mode="SendingFacility-AU"/>
			</xsl:when>
			<xsl:when test="hl7:author/hl7:assignedAuthor/hl7:assignedPerson/ext:asEmployment/ext:employerOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/ext:asEntityIdentifier/ext:id/@root">
				<xsl:apply-templates select="hl7:author/hl7:assignedAuthor/hl7:assignedPerson/ext:asEmployment/ext:employerOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/ext:asEntityIdentifier/ext:id" mode="SendingFacility-AU"/>
			</xsl:when>
			<xsl:when test="string-length(hl7:author/hl7:assignedAuthor/hl7:assignedPerson/ext:asEmployment/ext:employerOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name)">
				<xsl:value-of select="hl7:author/hl7:assignedAuthor/hl7:assignedPerson/ext:asEmployment/ext:employerOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name"/>
			</xsl:when>
			<xsl:when test="string-length(hl7:author/hl7:assignedAuthor/hl7:assignedPerson/ext:asEmployment/ext:employerOrganization/hl7:name)">
				<xsl:value-of select="hl7:author/hl7:assignedAuthor/hl7:assignedPerson/ext:asEmployment/ext:employerOrganization/hl7:name"/>
			</xsl:when>
			<xsl:when test="$defaultInformantRootPath"><xsl:apply-templates select="$defaultInformantRootPath" mode="SendingFacility"/></xsl:when>
			<xsl:otherwise><xsl:apply-templates select="$defaultAuthorRootPath" mode="SendingFacility"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="SendingFacilityFromId">
		<xsl:choose>
			<xsl:when test="string-length(@extension)"><xsl:value-of select="@extension"/></xsl:when>
			<xsl:when test="string-length(@root)">
				<xsl:apply-templates select="." mode="code-for-oid">
					<xsl:with-param name="OID" select="@root"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="PerformedAt">
		<!--
			StructuredMapping: PerformedAt

			Field
			Path  : CurrentProperty
			XPath : ./
			Source: assignedEntity
			StructuredMappingRef: OrganizationDetail
		-->
		<xsl:apply-templates select="hl7:assignedEntity" mode="OrganizationDetail"><xsl:with-param name="elementName" select="'PerformedAt'"/></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="EnteredAt">
		<!--
			StructuredMapping: EnteredAt

			Field
			Path  : CurrentProperty
			XPath : ./
			Source: ./
			StructuredMappingRef: OrganizationDetail
			Note  : If informant is not present then author is used.
					- Else if author is not present and current source node
					is informant then current source node is used.
					- Else if current source node is author then current
					source node is used.
					- Else if document-level informant is present then document-
					level informant is used.
					- Else if document-level author is present then document-
					level author is used.
					- Else if document authoring device is present then use
					document authoring device.
		-->
		<xsl:choose>
			<xsl:when test="hl7:informant"><xsl:apply-templates select="hl7:informant" mode="OrganizationDetail"/></xsl:when>
			<xsl:when test="hl7:author"><xsl:apply-templates select="hl7:author" mode="OrganizationDetail"/></xsl:when>
			<xsl:when test="local-name()='informant'"><xsl:apply-templates select="." mode="OrganizationDetail"/></xsl:when>
			<xsl:when test="local-name()='author' and not(hl7:assignedAuthor/hl7:assignedAuthoringDevice)"><xsl:apply-templates select="." mode="OrganizationDetail"/></xsl:when>
			<xsl:when test="$defaultInformantRootPath"><xsl:apply-templates select="$defaultInformantRootPath" mode="OrganizationDetail"/></xsl:when>
			<xsl:when test="$defaultAuthorRootPath"><xsl:apply-templates select="$defaultAuthorRootPath" mode="OrganizationDetail"/></xsl:when>
			<xsl:when test="$defaultAuthoringDeviceRootPath"><xsl:apply-templates select="$defaultAuthoringDeviceRootPath" mode="OrganizationDetail"/></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="EnteringOrganization">
		<!--
			StructuredMapping: EnteringOrganization

			Field
			Path  : Code
			XPath : Code/text()
			Source: healthCareFacility/id/@root

			Field
			Path  : Description
			XPath : Description/text()
			Source: healthCareFacility/name/text()

			Field
			Path  : Organization.Code
			XPath : Organization/Code/text()
			Source: representedOrganization/id/@root

			Field
			Path  : Organization.Description
			XPath : Organization/Description/text()
			Source: representedOrganization/name/text()
		-->
		<xsl:choose>
			<xsl:when test="hl7:informant">
				<xsl:apply-templates select="hl7:informant" mode="HealthCareFacilityDetail"><xsl:with-param name="elementName" select="'EnteringOrganization'"/></xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$defaultInformantRootPath" mode="HealthCareFacilityDetail"><xsl:with-param name="elementName" select="'EnteringOrganization'"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="HealthCareFacility">
		<xsl:apply-templates select="." mode="HealthCareFacilityDetail"><xsl:with-param name="elementName" select="'HealthCareFacility'"/></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="HealthCareFacilityDetail">
		<xsl:param name="elementName"/>

		<xsl:variable name="organizationInformation"><xsl:apply-templates select=".//hl7:representedOrganization | .//hl7:serviceProviderOrganization | .//ext:employerOrganization" mode="OrganizationInformation"/></xsl:variable>

		<xsl:if test="string-length($elementName) and string-length($organizationInformation)">
			<!-- Parse facility information -->
			<xsl:variable name="facilityOID" select="substring-before(substring-after($organizationInformation, 'F1:'), '|')"/>
			<xsl:variable name="facilityCode" select="substring-before(substring-after($organizationInformation, 'F2:'), '|')"/>
			<xsl:variable name="facilityDescription" select="substring-before(substring-after($organizationInformation, 'F3:'), '|')"/>

			<!-- Parse community information -->
			<xsl:variable name="communityOID" select="substring-before(substring-after($organizationInformation, 'C1:'), '|')"/>
			<xsl:variable name="communityCode" select="substring-before(substring-after($organizationInformation, 'C2:'), '|')"/>
			<xsl:variable name="communityDescription" select="substring-before(substring-after($organizationInformation, 'C3:'), '|')"/>

			<xsl:variable name="codeUpper" select="translate(hl7:code/@code,$lowerCase,$upperCase)"/>
			<xsl:variable name="facilityRole">
				<xsl:choose>
					<xsl:when test="$codeUpper='CLINIC'">CLINIC</xsl:when>
					<xsl:when test="$codeUpper='ER' or starts-with($codeUpper,'EMERGENCY')">ER</xsl:when>
					<xsl:when test="$codeUpper='DEPARTMENT' or $codeUpper='DEPT'">DEPARTMENT</xsl:when>
					<xsl:when test="$codeUpper='WARD' or $codeUpper='DEPT'">WARD</xsl:when>
					<xsl:when test="$codeUpper='OTH' or $codeUpper='OTHER'">OTHER</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:element name="{$elementName}">
				<Code><xsl:value-of select="$facilityCode"/></Code>
				<Description><xsl:value-of select="$facilityDescription"/></Description>
				<xsl:if test="string-length($facilityRole)"><LocationType><xsl:value-of select="$facilityRole"/></LocationType></xsl:if>
				<Organization>
					<Code><xsl:value-of select="$communityCode"/></Code>
					<Description><xsl:value-of select="$communityDescription"/></Description>

					<xsl:apply-templates select="hl7:addr" mode="Address"/>
					<xsl:apply-templates select="." mode="ContactInfo"/>
				</Organization>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="OrganizationDetail">
		<xsl:param name="elementName" select="'EnteredAt'"/>

		<!--
			StructuredMapping: OrganizationDetail

			Field
			Path  : Code
			XPath : Code/text()
			Source: representedOrganization/id/@extension
			Note  : If @extension is not present and @root is present
					then Code is derived from the OID Registry entry
					for @root.  If neither @root nor @extension is
					present then the name sub-element is used.

			Field
			Path  : Description
			XPath : Description/text()
			Source: representedOrganization/name/text()

			Field
			Path  : Address
			XPath : Address
			Source: representedOrganization/addr
			StructuredMappingRef: Address

			Field
			Path  : ContactInfo
			XPath : ContactInfo
			Source: representedOrganization
			StructuredMappingRef: ContactInfo
		-->

		<xsl:variable name="organizationInformation"><xsl:apply-templates select=".//hl7:representedOrganization" mode="OrganizationInformation"/></xsl:variable>

		<xsl:if test="string-length($organizationInformation)">
			<!-- Parse facility information -->
			<xsl:variable name="facilityOID" select="substring-before(substring-after($organizationInformation, 'F1:'), '|')"/>
			<xsl:variable name="facilityCode" select="substring-before(substring-after($organizationInformation, 'F2:'), '|')"/>
			<xsl:variable name="facilityDescription" select="substring-before(substring-after($organizationInformation, 'F3:'), '|')"/>

			<!-- Parse community information -->
			<xsl:variable name="communityOID" select="substring-before(substring-after($organizationInformation, 'C1:'), '|')"/>
			<xsl:variable name="communityCode" select="substring-before(substring-after($organizationInformation, 'C2:'), '|')"/>
			<xsl:variable name="communityDescription" select="substring-before(substring-after($organizationInformation, 'C3:'), '|')"/>

			<xsl:element name="{$elementName}">
				<Code><xsl:value-of select="$facilityCode"/></Code>
				<Description><xsl:value-of select="$facilityDescription"/></Description>

				<xsl:apply-templates select=".//hl7:representedOrganization/hl7:addr" mode="Address"/>
				<xsl:apply-templates select=".//hl7:representedOrganization" mode="ContactInfo"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="EnteredBy">
		<xsl:choose>
			<xsl:when test="hl7:author"><xsl:apply-templates select="hl7:author" mode="EnteredByDetail"/></xsl:when>
			<xsl:when test="hl7:assignedAuthor"><xsl:apply-templates select="." mode="EnteredByDetail"/></xsl:when>
			<xsl:otherwise><xsl:apply-templates select="$defaultAuthorRootPath" mode="EnteredByDetail"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="EnteredByDetail">
		<xsl:if test="hl7:assignedAuthor/hl7:assignedPerson and not(hl7:assignedAuthor/hl7:assignedPerson/hl7:name/@nullFlavor)">
			<EnteredBy>
				<xsl:choose>
					<xsl:when test="hl7:assignedAuthor/hl7:assignedPerson/ext:asEntityIdentifier/ext:id">
						<xsl:variable name="authorCode"><xsl:value-of select="hl7:assignedAuthor/hl7:assignedPerson/ext:asEntityIdentifier/ext:id/@root"/></xsl:variable>
						<xsl:variable name="authorDescription">
							<xsl:choose>
								<!-- Updated logic to capture name/text() if present, by stripping tabs, spaces, and CRLFs -->
								<xsl:when test="contains(hl7:assignedAuthor/hl7:assignedPerson/hl7:name/text(),'&#10;') and string-length(translate(hl7:assignedAuthor/hl7:assignedPerson/hl7:name/text(),'&#10;&#9; ','')) and hl7:assignedAuthor/hl7:assignedPerson/hl7:name/text()=descendant-or-self::node()">
									<xsl:value-of select="normalize-space(hl7:assignedAuthor/hl7:assignedPerson/hl7:name/text())"/>
								</xsl:when>
								<!-- Parse complete name from parts -->
								<xsl:when test="string-length(hl7:assignedAuthor/hl7:assignedPerson/hl7:name/text())">
									<xsl:variable name="contactNameXML"><xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name[@use='L']" mode="ContactName"/></xsl:variable>
									<xsl:variable name="contactName" select="exsl:node-set($contactNameXML)/Name"/>
									<xsl:variable name="contactNameFull" select="normalize-space(concat($contactName/NamePrefix/text(), ' ', $contactName/GivenName/text(), ' ', $contactName/MiddleName/text(), ' ', $contactName/FamilyName/text(), ' ', $contactName/ProfessionalSuffix/text()))"/>
									<xsl:value-of select="$contactNameFull"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$authorCode"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<Code><xsl:value-of select="$authorCode"/></Code>
						<Description><xsl:value-of select="$authorDescription"/></Description>
					</xsl:when>
					<xsl:when test="hl7:assignedAuthor/hl7:code and ((not(hl7:assignedAuthor/hl7:code/@nullFlavor)) or (hl7:assignedAuthor/hl7:code/@nullFlavor and string-length(hl7:assignedAuthor/hl7:code/hl7:originalText/text())))">
						<xsl:variable name="authorType">
							<xsl:choose>
								<xsl:when test="string-length(hl7:assignedAuthor/hl7:code/@displayName)"><xsl:value-of select="hl7:assignedAuthor/hl7:code/@displayName"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="hl7:assignedAuthor/hl7:code/hl7:originalText/text()"/></xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<Code><xsl:value-of select="$authorType"/></Code>
						<Description><xsl:value-of select="$authorType"/></Description>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="contactNameXML"><xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name" mode="ContactName"/></xsl:variable>
						<xsl:variable name="contactName" select="exsl:node-set($contactNameXML)/Name"/>
						<xsl:variable name="contactNameFull" select="normalize-space(concat($contactName/NamePrefix/text(), ' ', $contactName/GivenName/text(), ' ', $contactName/MiddleName/text(), ' ', $contactName/FamilyName/text(), ' ', $contactName/ProfessionalSuffix/text()))"/>

						<Code><xsl:value-of select="$contactNameFull"/></Code>
						<Description><xsl:value-of select="$contactNameFull"/></Description>
					</xsl:otherwise>
				</xsl:choose>
			</EnteredBy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="Informant">
		<xsl:choose>
			<xsl:when test="node()"><xsl:apply-templates select="." mode="EnteredAt"/></xsl:when>
			<xsl:otherwise><xsl:apply-templates select="$defaultInformantRootPath" mode="EnteredAt"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="EnteredOn">
		<xsl:if test="@value"><EnteredOn><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></EnteredOn></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="FromTime">
		<xsl:if test="@value"><FromTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></FromTime></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="ToTime">
		<xsl:if test="@value"><ToTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></ToTime></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="StartTime">
		<xsl:if test="@value"><FromTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></FromTime></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="EndTime">
		<xsl:if test="@value"><ToTime><xsl:value-of select="isc:evaluate('xmltimestamp', @value)"/></ToTime></xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="AttendingClinicians">
		<!--
			StructuredMapping: AttendingClinicians

			Field
			Path  : CareProvider
			XPath : ./CareProvider
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<xsl:if test="hl7:encounterParticipant[@typeCode = 'ATND' or @typeCode='DIS'] | hl7:performer[@typeCode = 'PRF']">
			<AttendingClinicians>
				<xsl:apply-templates select="hl7:encounterParticipant[@typeCode = 'ATND' or @typeCode='DIS'] | hl7:performer[@typeCode = 'PRF']" mode="CareProvider"/>
			</AttendingClinicians>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="ConsultingClinicians">
		<!--
			StructuredMapping: ConsultingClinicians

			Field
			Path  : CareProvider
			XPath : ./CareProvider
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<xsl:if test="hl7:encounterParticipant[@typeCode = 'CON']">
			<ConsultingClinicians>
				<xsl:apply-templates select="hl7:encounterParticipant[@typeCode = 'CON']" mode="CareProvider"/>
			</ConsultingClinicians>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="AdmittingClinician">
		<AdmittingClinician>
			<xsl:apply-templates select="." mode="CareProviderDetail"/>
		</AdmittingClinician>
	</xsl:template>

	<xsl:template match="*" mode="ReferringClinician">
		<ReferringClinician>
			<xsl:apply-templates select="." mode="DoctorDetail"/>
		</ReferringClinician>
	</xsl:template>

	<xsl:template match="*" mode="FamilyDoctor">
		<FamilyDoctor>
			<xsl:apply-templates select="." mode="DoctorDetail"/>
		</FamilyDoctor>
	</xsl:template>

	<xsl:template match="*" mode="Clinician">
		<!--
			StructuredMapping: Clinician

			Field
			Path  : Clinician
			XPath : ./Clinician
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<Clinician>
			<xsl:apply-templates select="." mode="CareProviderDetail"/>
		</Clinician>
	</xsl:template>

	<xsl:template match="*" mode="DiagnosingClinician">
		<DiagnosingClinician>
			<xsl:apply-templates select="." mode="CareProviderDetail"/>
		</DiagnosingClinician>
	</xsl:template>

	<xsl:template match="*" mode="OrderedBy">
		<OrderedBy>
			<xsl:apply-templates select="." mode="CareProviderDetail"/>
		</OrderedBy>
	</xsl:template>

	<xsl:template match="*" mode="OrderedBy-Author">
		<OrderedBy>
			<xsl:choose>
				<xsl:when test="hl7:assignedAuthor/hl7:code and not(hl7:assignedAuthor/hl7:code/@nullFlavor)">
					<xsl:variable name="authorType">
						<xsl:choose>
							<xsl:when test="string-length(hl7:assignedAuthor/hl7:code/@displayName)"><xsl:value-of select="hl7:assignedAuthor/hl7:code/@displayName"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="hl7:assignedAuthor/hl7:code/hl7:originalText/text()"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<Code><xsl:value-of select="$authorType"/></Code>
					<Description><xsl:value-of select="$authorType"/></Description>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="contactNameXML"><xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name" mode="ContactName"/></xsl:variable>
					<xsl:variable name="contactName" select="exsl:node-set($contactNameXML)/Name"/>
					<xsl:variable name="contactNameFull" select="normalize-space(concat($contactName/NamePrefix/text(), ' ', $contactName/GivenName/text(), ' ', $contactName/MiddleName/text(), ' ', $contactName/FamilyName/text(), ' ', $contactName/ProfessionalSuffix/text()))"/>
					<xsl:variable name="orderedByCode">
						<xsl:choose>
							<xsl:when test="string-length(hl7:assignedAuthor/hl7:id/@extension)">
								<xsl:value-of select="hl7:assignedAuthor/hl7:id/@extension"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$contactNameFull"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<Code><xsl:value-of select="$orderedByCode"/></Code>
					<Description><xsl:value-of select="$contactNameFull"/></Description>
					<xsl:if test="string-length($contactName/GivenName/text()) and string-length($contactName/FamilyName/text())">
						<Name>
							<xsl:if test="string-length($contactName/FamilyName/text())"><FamilyName><xsl:value-of select="$contactName/FamilyName/text()"/></FamilyName></xsl:if>
							<xsl:if test="string-length($contactName/NamePrefix/text())"><NamePrefix><xsl:value-of select="$contactName/NamePrefix/text()"/></NamePrefix></xsl:if>
							<xsl:if test="string-length($contactName/GivenName/text())"><GivenName><xsl:value-of select="$contactName/GivenName/text()"/></GivenName></xsl:if>
							<xsl:if test="string-length($contactName/MiddleName/text())"><MiddleName><xsl:value-of select="$contactName/MiddleName/text()"/></MiddleName></xsl:if>
							<xsl:if test="string-length($contactName/ProfessionalSuffix/text())"><ProfessionalSuffix><xsl:value-of select="$contactName/ProfessionalSuffix/text()"/></ProfessionalSuffix></xsl:if>
						</Name>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</OrderedBy>
	</xsl:template>

	<xsl:template match="*" mode="CareProvider">
		<CareProvider>
			<xsl:apply-templates select="." mode="CareProviderDetail"/>
		</CareProvider>
	</xsl:template>

	<xsl:template match="*" mode="CareProviderDetail">
		<xsl:variable name="entityPath" select="hl7:assignedEntity | hl7:associatedEntity"/>

		<xsl:if test="$entityPath = true()">
			<xsl:variable name="personPath" select="$entityPath/hl7:assignedPerson | $entityPath/hl7:associatedPerson"/>

			<xsl:if test="$personPath = true() and not($personPath/hl7:name/@nullFlavor)">
				<xsl:variable name="codeOrTranslation">
					<!-- 0 = no data, 1 = use hl7:functionCode, 2 = use hl7:functionCode/hl7:translation[1] -->
					<xsl:choose>
						<xsl:when test="not(hl7:functionCode/@nullFlavor) and hl7:functionCode/hl7:translation[1]/@code and hl7:functionCode/hl7:translation[1]/@codeSystem=$noCodeSystemOID">2</xsl:when>
						<xsl:when test="hl7:functionCode/@nullFlavor and hl7:functionCode/hl7:translation[1]/@code and hl7:functionCode/hl7:translation[1]/@codeSystem">2</xsl:when>
						<xsl:when test="hl7:functionCode/@code and not(hl7:functionCode/@nullFlavor)">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianFunctionCode">
					<xsl:choose>
						<xsl:when test="$codeOrTranslation='1'">
							<xsl:value-of select="hl7:functionCode/@code"/>
						</xsl:when>
						<xsl:when test="$codeOrTranslation='2'">
							<xsl:value-of select="hl7:functionCode/hl7:translation[1]/@code"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianFunctionDesc">
					<xsl:choose>
						<xsl:when test="$codeOrTranslation='1'">
							<xsl:value-of select="hl7:functionCode/@displayName"/>
						</xsl:when>
						<xsl:when test="$codeOrTranslation='2'">
							<xsl:value-of select="hl7:functionCode/hl7:translation[1]/@displayName"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianFunctionCodeSystem">
					<xsl:choose>
						<xsl:when test="$codeOrTranslation='1' and not(hl7:functionCode/@codeSystem=$noCodeSystemOID)">
							<xsl:value-of select="hl7:functionCode/@codeSystem"/>
						</xsl:when>
						<xsl:when test="$codeOrTranslation='2' and not(hl7:functionCode/hl7:translation[1]/@codeSystem=$noCodeSystemOID)">
							<xsl:value-of select="hl7:functionCode/hl7:translation[1]/@codeSystem"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianAssigningAuthority">
					<xsl:choose>
						<xsl:when test="$personPath/ext:asEntityIdentifier/ext:id/@assigningAuthorityName">
							<xsl:value-of select="$personPath/ext:asEntityIdentifier/ext:id/@assigningAuthorityName"/>
						</xsl:when>
						<xsl:when test="$personPath/ext:asEntityIdentifier/ext:id/@root and $personPath/ext:asEntityIdentifier/ext:id/@extension">
							<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$personPath/ext:asEntityIdentifier/ext:id/@root"/></xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$entityPath/hl7:id/@root and $entityPath/hl7:id/@extension">
							<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$entityPath/hl7:id/@root"/></xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianID">
					<xsl:choose>
						<xsl:when test="$personPath/ext:asEntityIdentifier/ext:id/@extension">
							<xsl:value-of select="$personPath/ext:asEntityIdentifier/ext:id/@extension"/>
						</xsl:when>
						<xsl:when test="$personPath/ext:asEntityIdentifier/ext:id/@root and not($personPath/ext:asEntityIdentifier/ext:id/@extension)">
							<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$personPath/ext:asEntityIdentifier/ext:id/@root"/></xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$entityPath/hl7:id/@root and not($entityPath/hl7:id/@extension)">
							<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$entityPath/hl7:id/@root"/></xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianName"><xsl:apply-templates select="$personPath/hl7:name" mode="ContactNameString"/></xsl:variable>

				<xsl:if test="string-length($clinicianAssigningAuthority) and not($clinicianAssigningAuthority=$noCodeSystemOID) and not($clinicianAssigningAuthority=$noCodeSystemName)"><SDACodingStandard><xsl:value-of select="$clinicianAssigningAuthority"/></SDACodingStandard></xsl:if>
				<Code>
					<xsl:choose>
						<xsl:when test="string-length($clinicianID)"><xsl:value-of select="$clinicianID"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$clinicianName"/></xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description><xsl:value-of select="$clinicianName"/></Description>

				<!-- Contact Name and Contact Information -->
				<xsl:apply-templates select="$personPath/hl7:name" mode="ContactName"/>
				<xsl:apply-templates select="$entityPath/hl7:addr" mode="Address"/>
				<xsl:apply-templates select="$entityPath" mode="ContactInfo"/>

				<!-- Contact Type -->
				<xsl:if test="string-length($clinicianFunctionCode)">
					<CareProviderType>
						<xsl:if test="string-length($clinicianFunctionCodeSystem)"><SDACodingStandard><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$clinicianFunctionCodeSystem"/></xsl:apply-templates></SDACodingStandard></xsl:if>
						<Code><xsl:value-of select="$clinicianFunctionCode"/></Code>
						<Description><xsl:value-of select="$clinicianFunctionDesc"/></Description>
					</CareProviderType>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!--
		DoctorDetail is the same as CareProviderDetail, except
		for functionCode support, which is omitted here due to
		the contents of SDA FamilyDoctor and ReferringClinician.
	-->
	<xsl:template match="*" mode="DoctorDetail">
		<xsl:variable name="entityPath" select="hl7:assignedEntity | hl7:associatedEntity"/>

		<xsl:if test="$entityPath = true()">
			<xsl:variable name="personPath" select="$entityPath/hl7:assignedPerson | $entityPath/hl7:associatedPerson"/>

			<xsl:if test="$personPath = true() and not($personPath/hl7:name/@nullFlavor)">
				<xsl:variable name="clinicianAssigningAuthority">
					<xsl:choose>
						<xsl:when test="$personPath/ext:asEntityIdentifier/ext:id/@assigningAuthorityName">
							<xsl:value-of select="$personPath/ext:asEntityIdentifier/ext:id/@assigningAuthorityName"/>
						</xsl:when>
						<xsl:when test="$personPath/ext:asEntityIdentifier/ext:id/@root and $personPath/ext:asEntityIdentifier/ext:id/@extension">
							<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$personPath/ext:asEntityIdentifier/ext:id/@root"/></xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$entityPath/hl7:id/@root and $entityPath/hl7:id/@extension">
							<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$entityPath/hl7:id/@root"/></xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianID">
					<xsl:choose>
						<xsl:when test="$personPath/ext:asEntityIdentifier/ext:id/@extension">
							<xsl:value-of select="$personPath/ext:asEntityIdentifier/ext:id/@extension"/>
						</xsl:when>
						<xsl:when test="$personPath/ext:asEntityIdentifier/ext:id/@root and not($personPath/ext:asEntityIdentifier/ext:id/@extension)">
							<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$personPath/ext:asEntityIdentifier/ext:id/@root"/></xsl:apply-templates>
						</xsl:when>
						<xsl:when test="$entityPath/hl7:id/@root and not($entityPath/hl7:id/@extension)">
							<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$entityPath/hl7:id/@root"/></xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianName"><xsl:apply-templates select="$personPath/hl7:name" mode="ContactNameString"/></xsl:variable>

				<xsl:if test="string-length($clinicianAssigningAuthority) and not($clinicianAssigningAuthority=$noCodeSystemOID) and not($clinicianAssigningAuthority=$noCodeSystemName)"><SDACodingStandard><xsl:value-of select="$clinicianAssigningAuthority"/></SDACodingStandard></xsl:if>
				<Code>
					<xsl:choose>
						<xsl:when test="string-length($clinicianID)"><xsl:value-of select="$clinicianID"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$clinicianName"/></xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description><xsl:value-of select="$clinicianName"/></Description>

				<!-- Contact Name and Contact Information -->
				<xsl:apply-templates select="$personPath/hl7:name" mode="ContactName"/>
				<xsl:apply-templates select="$entityPath/hl7:addr" mode="Address"/>
				<xsl:apply-templates select="$entityPath" mode="ContactInfo"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="ContactName">
		<xsl:param name="elementName" select="'Name'"/>

		<!--
			StructuredMapping: ContactName

			Field
			Path  : FamilyName
			XPath : FamilyName/text()
			Source: family/text()

			Field
			Path  : NamePrefix
			XPath : NamePrefix/text()
			Source: prefix/text()

			Field
			Path  : GivenName
			XPath : GivenName/text()
			Source: given[1]/text()

			Field
			Path  : MiddleName
			XPath : MiddleName/text()
			Source: given[2]/text()

			Field
			Path  : ProfessionalSuffix
			XPath : ProfessionalSuffix/text()
			Source: suffix/text()
		-->

		<xsl:if test="not(@nullFlavor)">
			<xsl:variable name="contactNamePrefix" select="hl7:prefix/text()"/>
			<xsl:variable name="contactNameGiven">
				<xsl:choose>
					<xsl:when test="string-length(hl7:given[1]/text())"><xsl:value-of select="hl7:given[1]/text()"/></xsl:when>
					<xsl:when test="string-length(normalize-space(text())) and contains(text(), ',')"><xsl:value-of select="normalize-space(substring-after(text(), ','))"/></xsl:when>
					<xsl:when test="string-length(normalize-space(text())) and contains(text(), ' ')"><xsl:value-of select="normalize-space(substring-before(text(), ' '))"/></xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="contactNameMiddle" select="hl7:given[2]/text()"/>
			<xsl:variable name="contactNameLast">
				<xsl:choose>
					<xsl:when test="string-length(hl7:family/text())"><xsl:value-of select="hl7:family/text()"/></xsl:when>
					<xsl:when test="string-length(normalize-space(text())) and contains(text(), ',')"><xsl:value-of select="normalize-space(substring-before(text(), ','))"/></xsl:when>
					<xsl:when test="string-length(normalize-space(text())) and contains(text(), ' ')"><xsl:value-of select="normalize-space(substring-after(text(), ' '))"/></xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="contactNameSuffix" select="hl7:suffix/text()"/>

			<xsl:element name="{$elementName}">
				<xsl:if test="string-length($contactNameLast)"><FamilyName><xsl:value-of select="$contactNameLast"/></FamilyName></xsl:if>
				<xsl:if test="string-length($contactNamePrefix)"><NamePrefix><xsl:value-of select="$contactNamePrefix"/></NamePrefix></xsl:if>
				<xsl:if test="string-length($contactNameGiven)"><GivenName><xsl:value-of select="$contactNameGiven"/></GivenName></xsl:if>
				<xsl:if test="string-length($contactNameMiddle)"><MiddleName><xsl:value-of select="$contactNameMiddle"/></MiddleName></xsl:if>
				<xsl:if test="string-length($contactNameSuffix)"><ProfessionalSuffix><xsl:value-of select="$contactNameSuffix"/></ProfessionalSuffix></xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="ContactNameString">
		<xsl:choose>
			<xsl:when test="string-length(normalize-space(text()))"><xsl:value-of select="normalize-space(text())"/></xsl:when>
			<xsl:when test="string-length(hl7:given[1]/text()) and string-length(hl7:given[2]/text()) and string-length(hl7:family/text())"><xsl:value-of select="concat(hl7:family/text(), ', ', hl7:given[1]/text(), ' ', hl7:given[2]/text())"/></xsl:when>
			<xsl:when test="string-length(hl7:given[1]/text()) and string-length(hl7:family/text())"><xsl:value-of select="concat(hl7:family/text(), ', ', hl7:given[1]/text())"/></xsl:when>
			<xsl:when test="string-length(hl7:family/text())"><xsl:value-of select="hl7:family/text()"/></xsl:when>
			<xsl:when test="string-length(hl7:given[1]/text())"><xsl:value-of select="hl7:given[1]/text()"/></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="Addresses">
		<!--
			Field: Patient Addresses
			Target: HS.SDA3.Patient Addresses
			Target: /Container/Patient/Addresses
			Source: /ClinicalDocument/recordTarget/patientRole/addr
			StructuredMappingRef: Address
		-->
		<xsl:if test="hl7:addr[not(@nullFlavor)]">
			<Addresses>
				<xsl:apply-templates select="hl7:addr" mode="Address"/>
			</Addresses>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="Address">
		<xsl:param name="elementName" select="'Address'"/>

		<!--
			StructuredMapping: Address

			Field
			Path  : Street
			XPath : Street/text()
			Source: streetAddressLine[]/text()
			Note  : Multiple streetAddressLine elements are concatenated into one semicolon-delimited string when imported.

			Field
			Path  : City.Code
			XPath : City/Code/text()
			Source: city/text()

			Field
			Path  : State.Code
			XPath : State/Code/text()
			Source: state/text()

			Field
			Path  : Zip.Code
			XPath : Zip/Code/text()
			Source: postalCode/text()

			Field
			Path  : Country.Code
			XPath : Country/Code/text()
			Source: country/text()

			Field
			Path  : County.Code
			XPath : County/Code/text()
			Source: county/text()
		-->
		<xsl:choose>
			<xsl:when test="@nullFlavor"/>
			<xsl:when test="string-length(normalize-space(text()))"><xsl:element name="{$elementName}"><Street><xsl:value-of select="normalize-space(text())"/></Street></xsl:element></xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$elementName}">
					<xsl:if test="string-length(hl7:useablePeriod/hl7:low/@value)"><FromTime><xsl:value-of select="isc:evaluate('xmltimestamp', hl7:useablePeriod/hl7:low/@value)"/></FromTime></xsl:if>
					<xsl:if test="string-length(hl7:useablePeriod/hl7:high/@value)"><ToTime><xsl:value-of select="isc:evaluate('xmltimestamp', hl7:useablePeriod/hl7:high/@value)"/></ToTime></xsl:if>

					<xsl:if test="string-length(normalize-space(hl7:streetAddressLine))">
						<Street>
							<xsl:apply-templates select="hl7:streetAddressLine"/>
						</Street>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(hl7:city/text()))">
						<City>
							<Code><xsl:value-of select="normalize-space(hl7:city/text())"/></Code>
						</City>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(hl7:state/text()))">
						<State>
							<Code><xsl:value-of select="normalize-space(hl7:state/text())"/></Code>
						</State>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(hl7:postalCode/text()))">
						<Zip>
							<Code><xsl:value-of select="normalize-space(hl7:postalCode/text())"/></Code>
						</Zip>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(hl7:country/text()))">
						<Country>
							<Code><xsl:value-of select="normalize-space(hl7:country/text())"/></Code>
						</Country>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(hl7:county/text()))">
						<County>
							<Code><xsl:value-of select="normalize-space(hl7:county/text())"/></Code>
						</County>
					</xsl:if>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- AddressType imports to HS.Types.Address instead of to HS.SDA3.Address. -->
	<xsl:template match="*" mode="AddressType">
		<xsl:param name="elementName" select="'Address'"/>

		<xsl:choose>
			<xsl:when test="@nullFlavor"/>
			<xsl:when test="string-length(normalize-space(text()))"><xsl:element name="{$elementName}"><Street><xsl:value-of select="normalize-space(text())"/></Street></xsl:element></xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$elementName}">
					<xsl:if test="hl7:streetAddressLine">
						<StreetLine>
							<xsl:apply-templates select="hl7:streetAddressLine"/>
						</StreetLine>
					</xsl:if>
					<xsl:if test="hl7:city">
						<City>
							<xsl:value-of select="normalize-space(hl7:city/text())"/>
						</City>
					</xsl:if>
					<xsl:if test="hl7:state">
						<State>
							<xsl:value-of select="normalize-space(hl7:state/text())"/>
						</State>
					</xsl:if>
					<xsl:if test="hl7:postalCode">
						<PostalCode>
							<xsl:value-of select="normalize-space(hl7:postalCode/text())"/>
						</PostalCode>
					</xsl:if>
					<xsl:if test="hl7:country">
						<Country>
							<xsl:value-of select="normalize-space(hl7:country/text())"/>
						</Country>
					</xsl:if>
					<xsl:if test="hl7:county">
						<County>
							<xsl:value-of select="normalize-space(hl7:county/text())"/>
						</County>
					</xsl:if>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:streetAddressLine">
		<xsl:if test="position()>1">; </xsl:if>
		<xsl:value-of select="normalize-space(text())"/>
	</xsl:template>

	<xsl:template match="*" mode="ContactInfo">
		<xsl:param name="elementName" select="'ContactInfo'"/>

		<!--
			StructuredMapping: ContactInfo

			Field
			Path  : HomePhoneNumber
			XPath : HomePhoneNumber/text()
			Source: telecom[@use='H' or @use='HP' or @use='HV' or @use='PRN' or not(@use)]

			Field
			Path  : WorkPhoneNumber
			XPath : WorkPhoneNumber/text()
			Source: telecom[@use='W' or @use='WP' or @use='WPN']

			Field
			Path  : MobilePhoneNumber
			XPath : MobilePhoneNumber/text()
			Source: telecom[@use='MC']

			Field
			Path  : EmailAddress
			XPath : EmailAddress/text()
			Source: telecom[@use='NET' or contains(@value,'mailto:')]
		-->

		<xsl:if test="hl7:telecom[not(@nullFlavor)]">
			<xsl:element name="{$elementName}">
				<xsl:for-each select="hl7:telecom[not(@nullFlavor)]">
					<xsl:variable name="homeTelecomUse">,H,HP,HV,PRN,</xsl:variable>
					<xsl:variable name="workTelecomUse">,W,WP,WPN,</xsl:variable>
					<xsl:variable name="mobileTelecomUse">,MC,</xsl:variable>
					<xsl:variable name="emailTelecomUse">,NET,</xsl:variable>
					<xsl:variable name="telecomUse" select="concat(',', @use, ',')"/>
					<xsl:variable name="telecomValue">
						<xsl:choose>
							<xsl:when test="contains(@value, ':')"><xsl:value-of select="substring-after(@value, ':')"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="@value"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:choose>
						<xsl:when test="contains($homeTelecomUse, $telecomUse)"><HomePhoneNumber><xsl:value-of select="$telecomValue"/></HomePhoneNumber></xsl:when>
						<xsl:when test="contains($workTelecomUse, $telecomUse)"><WorkPhoneNumber><xsl:value-of select="$telecomValue"/></WorkPhoneNumber></xsl:when>
						<xsl:when test="contains($mobileTelecomUse, $telecomUse)"><MobilePhoneNumber><xsl:value-of select="$telecomValue"/></MobilePhoneNumber></xsl:when>
						<xsl:when test="contains($emailTelecomUse, $telecomUse)"><EmailAddress><xsl:value-of select="$telecomValue"/></EmailAddress></xsl:when>
						<xsl:when test="not(string-length(@use)) and contains(@value,'mailto:')"><EmailAddress><xsl:value-of select="$telecomValue"/></EmailAddress></xsl:when>
						<xsl:when test="not(string-length(@use))"><HomePhoneNumber><xsl:value-of select="$telecomValue"/></HomePhoneNumber></xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="OrganizationInformation">
		<xsl:variable name="wholeOrganizationRootPath" select="hl7:asOrganizationPartOf/hl7:wholeOrganization"/>

		<!-- Get community information -->
		<xsl:variable name="communityOID">
			<xsl:choose>
				<xsl:when test="$wholeOrganizationRootPath/ext:asEntityIdentifier/ext:id/@root"><xsl:value-of select="$wholeOrganizationRootPath/ext:asEntityIdentifier/ext:id/@root"/></xsl:when>
				<xsl:when test="$wholeOrganizationRootPath"><xsl:value-of select="$wholeOrganizationRootPath/hl7:id/@root"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="hl7:id/@root"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="communityCode">
		<xsl:choose>
			<xsl:when test="starts-with($communityOID,concat($hiServiceOID,'.',$hpioPrefix))">
				<xsl:value-of select="$communityOID"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$communityOID"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		<xsl:variable name="communityDescription">
			<xsl:choose>
				<xsl:when test="$wholeOrganizationRootPath"><xsl:value-of select="$wholeOrganizationRootPath/hl7:name/text()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="hl7:name/text()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--
			Get facility information from <id> and possibly from the OID Registry.

			$repOrgconcatIdRootAndNumericExt is defined in ImportProfile.xsl.

			There are several <id> formats that may legally be present here:

			1. <id root="<OID>"/> - @root is intended to be the OID of a facility.
			2. <id root="<OID>" extension="<alphanumericvalue>"/> - @extension is intended to be a facility code.
			3. <id root="<OID>" extension="<numericvalue>"/> -
				a. If $repOrgconcatIdRootAndNumericExt'=1 then @extension is intended to be a facility code.
				b. If $repOrgconcatIdRootAndNumericExt=1 then concatenate @root+@extension and use as facility OID.
			4. <id root="<GUID>" extension="<anyvalue>"/> - @extension is intended to be a facility code.
			5. <id nullFlavor="UNK"/> - no id, and so no facility code.
			6. <id root="<GUID>"/> - same effect as nullFlavor.

			There may be multiple <id>'s and a mix of the scenarios shown above.

			Use the first non-nullFlavor/non-GUID-only <id> for the facility information.
		-->

		<xsl:variable name="idRootExt"><xsl:apply-templates select="hl7:id" mode="representedOrganizationId"/></xsl:variable>

		<xsl:variable name="facilityOID" select="substring-before(substring-before($idRootExt,'/'),'|')"/>
		<xsl:variable name="facilityCodeFromIds" select="substring-after(substring-before($idRootExt,'/'),'|')"/>
		<xsl:variable name="facilityCodeFromOID"><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$facilityOID"/></xsl:apply-templates></xsl:variable>
		<!--
			If FacilityCode found then use it for FacilityCode.
			If FacilityCode not found but OID found then get FacilityCode from OID.
			If FacilityCode not found from OID then use <name> for FacilityCode.
		-->
		<xsl:variable name="facilityCode">
			<xsl:choose>
				<xsl:when test="string-length($facilityCodeFromIds)">
					<xsl:value-of select="$facilityCodeFromIds"/>
				</xsl:when>
				<xsl:when test="string-length($facilityCodeFromOID)">
					<xsl:value-of select="$facilityCodeFromOID"/>
				</xsl:when>
				<xsl:when test="string-length(hl7:name/text())">
					<xsl:value-of select="hl7:name/text()"/>
				</xsl:when>
				<xsl:when test="string-length($facilityOID)">
					<xsl:value-of select="$facilityOID"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="facilityDescription"><xsl:if test="node()"><xsl:value-of select="hl7:name/text()"/></xsl:if></xsl:variable>

		<!-- Reponse format:  |F1:Facility OID|F2:Facility Code|F3:Facility Description|C1:Community OID|C2:Community Code|C3:Community Description| -->
		<xsl:value-of select="concat('|F1:', $facilityOID, '|F2:', $facilityCode, '|F3:', $facilityDescription, '|C1:', $communityOID, '|C2:', $communityCode, '|C3:', $communityDescription, '|')"/>
	</xsl:template>

	<!--
		representedOrganizationId builds a string that indicates the
		OIDs and/or Facility Codes represented in the <id>'s collection
		under representedOrganization.  The format of the string is:
		OID1 | FacilityCode1 / ... / OIDn | FacilityCoden
	-->
	<xsl:template match="hl7:id" mode="representedOrganizationId">
		<xsl:variable name="rootIsGUID" select="string-length(@root)=36 and string-length(translate(@root,translate(@root,'-',''),''))=4 and not(string-length(translate(@root,'0123456789ABCDEFabcdef-','')))"/>
		<xsl:choose>
			<xsl:when test="@root and @extension and not(number(@extension))">
				<xsl:value-of select="concat(@root, '|', @extension, '/')"/>
			</xsl:when>
			<xsl:when test="@root and $rootIsGUID=false() and not(@extension)">
				<xsl:value-of select="concat(@root, '|/')"/>
			</xsl:when>
			<xsl:when test="$rootIsGUID=true() and @extension">
				<xsl:value-of select="concat('|', @extension, '/')"/>
			</xsl:when>
			<xsl:when test="@root and $rootIsGUID=false() and number(@extension) and not($repOrgconcatIdRootAndNumericExt='1')">
				<xsl:value-of select="concat(@root, '|', @extension, '/')"/>
			</xsl:when>
			<xsl:when test="@root and $rootIsGUID=false() and number(@extension) and $repOrgconcatIdRootAndNumericExt='1'">
				<xsl:value-of select="concat(@root, '.', @extension, '|', '/')"/>
			</xsl:when>
			<xsl:when test="@nullFlavor"/>
			<xsl:when test="$rootIsGUID=true() and not(@extension)"/>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="LocationInformation">
		<!--
			LocationInformation provides for the possibility
			that there may be a nullFlavor <id> before any
			non-nullFlavor <id>'s that have the facility data.
		-->
		<xsl:variable name="idRootExt">
			<xsl:for-each select="hl7:id">
				<xsl:choose>
					<xsl:when test="string-length(@root) and not(number(@extension)) and not(@displayable='true')">
						<xsl:value-of select="concat(@root, '/')"/>
					</xsl:when>
					<xsl:when test="string-length(@root) and number(@extension) and not(@displayable='true')">
						<xsl:value-of select="concat(@root, '.', @extension, '/')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="locationOID" select="substring-before($idRootExt,'/')"/>
		<xsl:variable name="locationCode"><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="$locationOID"/></xsl:apply-templates></xsl:variable>
		<xsl:variable name="locationDescription"><xsl:if test="node()"><xsl:value-of select="hl7:name/text()"/></xsl:if></xsl:variable>

		<!-- Reponse format:  |L1:Location OID|L2:Location Code|L3:Location Description| -->
		<xsl:value-of select="concat('|L1:', $locationOID, '|L2:', $locationCode, '|L3:', $locationDescription, '|', local-name())"/>
	</xsl:template>

	<!--
		ExternalId overrides SDA ExternalId with <id> values from
		the source CDA, if enabled by $sdaOverrideExternalId = 1,
		which is configurable in ImportProfile.xsl.
	-->
	<xsl:template match="*" mode="ExternalId">
		<xsl:if test="($sdaOverrideExternalId = 1)">
			<xsl:variable name="isUUID">
				<xsl:choose>
					<xsl:when test="not(string-length(hl7:id/@extension)) and not(string-length(hl7:id/@assigningAuthorityName)) and string-length(hl7:id/@root)>30 and contains(translate(hl7:id/@root,concat($lowerCase,'0123456789'),''),'---')">1</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="not($isUUID) and hl7:id[contains(@assigningAuthorityName, 'ExternalId') and not(@nullFlavor)]"><ExternalId><xsl:apply-templates select="hl7:id[contains(@assigningAuthorityName, 'ExternalId')]" mode="Id-External"/></ExternalId></xsl:when>
				<xsl:when test="not($isUUID) and hl7:id[(position() = 1) and not(@nullFlavor)]"><ExternalId><xsl:apply-templates select="hl7:id[1]" mode="Id-External"/></ExternalId></xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="PlacerId">
		<!--
			StructuredMapping: PlacerId

			Field
			Path  : CurrentProperty
			XPath : ./
			Source: ./
			Note  : If a CDA id with @assigningAuthorityName containing '-PlacerId'
					is found then that id is used for import to SDA PlacerId,
					regardless of position.  Otherwise id[2] is used if present.
					Otherwise if id[2] is also not present, then a PlacerId with a
					newly generated GUID value is imported.  When using id data for
					PlacerId, if @extension is present then @extension is used.
					Otherwise if @root is present then @root is used.  Otherwise
					PlacerId is imported with a newly generated GUID value.
		-->
		<xsl:choose>
			<xsl:when test="hl7:id[contains(@assigningAuthorityName, '-PlacerId') and not(@nullFlavor)]"><PlacerId><xsl:apply-templates select="hl7:id[contains(@assigningAuthorityName, '-PlacerId')]" mode="Id"/></PlacerId></xsl:when>
			<xsl:when test="hl7:id[(position() = 2) and not(@nullFlavor)]"><PlacerId><xsl:apply-templates select="hl7:id[2]" mode="Id"/></PlacerId></xsl:when>
			<xsl:otherwise><PlacerId><xsl:value-of select="isc:evaluate('createGUID')"/></PlacerId></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="FillerId">
		<!--
			StructuredMapping: FillerId

			Field
			Path  : CurrentProperty
			XPath : ./
			Source: ./
			Note  : If a CDA id with @assigningAuthorityName containing '-FillerId'
					is found then that id is used for import to SDA FillerId,
					regardless of position.  Otherwise id[3] is used if present.
					Otherwise if id[3] is also not present, then a FillerId with a
					newly generated GUID value is imported.  When using id data for
					FillerId, if @extension is present then @extension is used.
					Otherwise if @root is present then @root is used.  Otherwise
					FillerId is imported with a newly generated GUID value.
		-->
		<xsl:choose>
			<xsl:when test="hl7:id[contains(@assigningAuthorityName, '-FillerId') and not(@nullFlavor)]"><FillerId><xsl:apply-templates select="hl7:id[contains(@assigningAuthorityName, '-FillerId')]" mode="Id"/></FillerId></xsl:when>
			<xsl:when test="hl7:id[(position() = 3) and not(@nullFlavor)]"><FillerId><xsl:apply-templates select="hl7:id[3]" mode="Id"/></FillerId></xsl:when>
			<xsl:otherwise><FillerId><xsl:value-of select="isc:evaluate('createGUID')"/></FillerId></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="Id">
		<xsl:choose>
			<xsl:when test="@extension"><xsl:value-of select="@extension"/></xsl:when>
			<xsl:when test="@root"><xsl:value-of select="@root"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="isc:evaluate('createGUID')"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="Id-External">
		<xsl:variable name="rootCode"><xsl:apply-templates select="." mode="code-for-oid"><xsl:with-param name="OID" select="@root"/></xsl:apply-templates></xsl:variable>
		<xsl:choose>
			<xsl:when test="@extension"><xsl:value-of select="concat($rootCode, '|', @extension)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@root"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		XFRMAllEncounters is called by a Section-Modules level XSL when a
		No-Data section is detected while the documentActionCode is XFRM.
		In this case an ActionCode of C is written for blank encounter
		number and for all encounter numbers found in the document header
		and in the Encounters section.
	-->
	<xsl:template match="*" mode="XFRMAllEncounters">
		<xsl:param name="informationType"/>
		<xsl:param name="actionScope"/>

		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="$informationType"/>
			<xsl:with-param name="actionScope" select="$actionScope"/>
		</xsl:call-template>

		<xsl:if test="string-length($encompassingEncounterID)">
			<xsl:call-template name="ActionCode">
				<xsl:with-param name="informationType" select="$informationType"/>
				<xsl:with-param name="actionScope" select="$actionScope"/>
				<xsl:with-param name="encounterNumber"><xsl:value-of select="$encompassingEncounterID"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates select="$sectionRootPath[hl7:templateId/@root=$encountersSectionTemplateId]/hl7:entry" mode="XFRMOverriddenEncounter">
			<xsl:with-param name="informationType" select="$informationType"/>
			<xsl:with-param name="actionScope" select="$actionScope"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- XFRMOverriddenEncounter is called by XFRMAllEncounters for each Encounter in the Encounters section. -->
	<xsl:template match="*" mode="XFRMOverriddenEncounter">
		<xsl:param name="informationType"/>
		<xsl:param name="actionScope"/>

		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="$informationType"/>
			<xsl:with-param name="encounterNumber">
				<xsl:choose>
					<xsl:when test="string-length(hl7:encounter/hl7:id/@extension)">
						<xsl:value-of select="hl7:encounter/hl7:id/@extension"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="hl7:encounter/hl7:id/@root"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="actionScope" select="$actionScope"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="ActionCode">
		<xsl:param name="informationType"/>
		<xsl:param name="actionScope"/>
		<xsl:param name="encounterNumber"/>

		<xsl:variable name="encounterNumberSubscript">
			<xsl:choose>
				<xsl:when test="string-length($encounterNumber)"><xsl:value-of select="$encounterNumber"/></xsl:when>
				<xsl:otherwise>(blank)</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="($sdaActionCodesEnabled = 1) and string-length($documentActionCode) and string-length($informationType)">
			<xsl:choose>
				<xsl:when test="($documentActionCode = 'APND')">
					<xsl:choose>
						<xsl:when test="$informationType = 'Patient'"/>
						<xsl:when test="$informationType = 'Encounter'"><ActionCode>A</ActionCode></xsl:when>
						<xsl:when test="not(isc:evaluate('varGet','ActionCodes',$informationType,$encounterNumberSubscript)='1')">
							<xsl:element name="{$informationType}">
								<ActionCode>A</ActionCode>
								<xsl:if test="string-length($actionScope)"><ActionScope><xsl:value-of select="$actionScope"/></ActionScope></xsl:if>
								<xsl:if test="string-length($encounterNumber)"><EncounterNumber><xsl:value-of select="$encounterNumber"/></EncounterNumber></xsl:if>
							</xsl:element>
							<xsl:if test="isc:evaluate('varSet','ActionCodes',$informationType,$encounterNumberSubscript,'1')"></xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="($documentActionCode = 'RPLC')">
					<xsl:choose>
						<xsl:when test="$informationType = 'Patient'"><ActionCode>R</ActionCode></xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="($documentActionCode = 'XFRM')">
					<xsl:choose>
						<xsl:when test="$informationType = 'Patient'"/>
						<xsl:when test="$informationType = 'Encounter'"><ActionCode>R</ActionCode></xsl:when>
						<xsl:when test="not(isc:evaluate('varGet','ActionCodes',$informationType,$encounterNumberSubscript)='1')">
							<xsl:element name="{$informationType}">
								<ActionCode>C</ActionCode>
								<xsl:if test="string-length($actionScope)"><ActionScope><xsl:value-of select="$actionScope"/></ActionScope></xsl:if>
								<xsl:if test="string-length($encounterNumber)"><EncounterNumber><xsl:value-of select="$encounterNumber"/></EncounterNumber></xsl:if>
							</xsl:element>
							<xsl:if test="isc:evaluate('varSet','ActionCodes',$informationType,$encounterNumberSubscript,'1')"></xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="EncounterID-Entry">
		<!--
			Assume that if .//hl7:encounter/hl7:id/@extension or @root
			has a value, then it is valid, meaning it is the number of
			an encounter from the Encounters section, or is the
			encompassingEncounter number.
		-->
		<xsl:variable name="encounterNumber">
			<xsl:choose>
				<xsl:when test="string-length(.//hl7:encounter/hl7:id/@extension)"><xsl:value-of select=".//hl7:encounter/hl7:id/@extension"/></xsl:when>
				<xsl:when test="string-length(.//hl7:encounter/hl7:id/@root)"><xsl:value-of select=".//hl7:encounter/hl7:id/@root"/></xsl:when>
				<xsl:when test="string-length($encompassingEncounterID)"><xsl:value-of select="$encompassingEncounterID"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="encounterNumberLower" select="translate($encounterNumber,$upperCase,$lowerCase)"/>
		<xsl:variable name="encounterNumberClean" select="translate($encounterNumber,';:% &#34;','_____')"/>
		<xsl:choose>
			<xsl:when test="starts-with($encounterNumberLower,'urn:uuid:')">
				<xsl:value-of select="substring($encounterNumberClean,10)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$encounterNumberClean"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		code-for-oid returns the IdentityCode for a specified OID.
		If no IdentityCode is found, then $default is returned.
	-->
	<xsl:template match="*" mode="code-for-oid">
		<xsl:param name="OID"/>
		<xsl:param name="default" select="$OID"/>

		<xsl:value-of select="isc:evaluate('getCodeForOID',$OID,'',$default)"/>
	</xsl:template>

	<!--
		oid-for-code returns the OID for a specified IdentityCode.
		If no OID is found, then $default is returned.
	-->
	<xsl:template match="*" mode="oid-for-code">
		<xsl:param name="Code"/>
		<xsl:param name="default" select="$Code"/>

		<xsl:value-of select="isc:evaluate('getOIDForCode',$Code,'',$default)"/>
	</xsl:template>

	<!--
		importNarrative builds a string of text from the HTML
		found in a CDA section narrative.
	-->
	<xsl:template match="*" mode="importNarrative">
		<xsl:param name="narrativeImportMode" select="$narrativeImportModeGeneral"/>
		<!--
			narrativeImportMode:
			1 = import as text, import both <br/> and narrative line feeds as line feeds
			2 = import as text, import <br/> as line feed, ignore narrative line feeds
		-->
 		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$narrativeImportMode='2'">
				<xsl:variable name="firstPass">
					<xsl:apply-templates>
						<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="translate(translate($firstPass,'&#10;',' '),'&#13;','&#10;')"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:br">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1'"><xsl:value-of select="'&#10;'"/></xsl:when>
			<xsl:when test="$narrativeImportMode='2'"><xsl:value-of select="'&#13;'"/></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:table">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:thead">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:tbody">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:tr">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:th">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:td">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:content">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="hl7:paragraph">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="hl7:list">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="hl7:item">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="hl7:caption">
		<xsl:param name="narrativeImportMode"/>
		<xsl:choose>
			<xsl:when test="$narrativeImportMode='1' or $narrativeImportMode='2'">
				<xsl:apply-templates>
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
