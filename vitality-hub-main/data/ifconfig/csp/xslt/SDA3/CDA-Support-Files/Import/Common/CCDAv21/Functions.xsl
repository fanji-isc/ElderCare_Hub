<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com"
  xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 sdtc xsi exsl">

  	<!-- General key on anything that has an ID attribute -->
	<xsl:key name="narrativeKey" match="*" use="@ID"/>
  	<xsl:key name="narrativeKey" match="/hl7:ClinicalDocument" use="'NEVER_MATCH_THIS!'"/>

	<!-- Key for /hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section -->
	<xsl:key name="sectionsByRoot" match="hl7:section" use="hl7:templateId/@root"/>
  	<xsl:key name="sectionsByRoot" match="/hl7:ClinicalDocument" use="'NEVER_MATCH_THIS!'"/>
  	<!-- Second line in each of the above keys is to ensure that the "key table" is populated
       with at least one row, but we never want to retrieve that row. -->
	
	<xsl:template match="*" mode="fn-XFRMAllEncounters">
		<xsl:param name="informationType"/>
		<xsl:param name="actionScope"/>
		<!--
			XFRMAllEncounters is called by a Section-Modules level XSL when a
			No-Data section is detected while the documentActionCode is XFRM.
			In this case an ActionCode of C is written for blank encounter
			number and for all encounter numbers found in the document header
			and in the Encounters section.
		-->
		
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
		
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-EncountersSectionEntriesOptional)/hl7:entry | key('sectionsByRoot',$ccda-EncountersSectionEntriesRequired)/hl7:entry" mode="fn-XFRMOverriddenEncounter">
			<xsl:with-param name="informationType" select="$informationType"/>
			<xsl:with-param name="actionScope" select="$actionScope"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="fn-XFRMOverriddenEncounter">
		<xsl:param name="informationType"/>
		<xsl:param name="actionScope"/>
		<!-- XFRMOverriddenEncounter is called by XFRMAllEncounters for each Encounter in the Encounters section. -->
		
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="$informationType"/>
			<xsl:with-param name="actionScope" select="$actionScope"/>
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
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-CodeTable">
		<xsl:param name="hsElementName"/><!-- Name of outer element to produce -->
		<xsl:param name="subCodedElementRootPath"/><!-- Now UNUSED, this was a way to emit auxiliary elements -->
		<xsl:param name="subElementName"/><!-- Used when this template calls itself recursively -->
		<xsl:param name="observationValueUnits"/><!-- String to be used in optional ObservationValueUnits sub-element -->
		<xsl:param name="importOriginalText" select="'0'"/><!-- If 1, emit OriginalText sub-element when there is content for it -->
		
		<!--
			firstTranslationCodeSystem is the codeSystem attribute on
			the first, if any, <translation> for this code.  If it is
			the No Code System OID, then we know that that translation
			was added by HealthShare export.
		-->
		<xsl:variable name="firstTranslationCodeSystem" select="hl7:translation[1]/@codeSystem"/>
	    <xsl:variable name="hasReferenceLink" select="string-length(substring-after(.//hl7:reference/@value, '#')) > 0"/>

	  	<xsl:choose>
		    <xsl:when test="($firstTranslationCodeSystem=$noCodeSystemOID) or ((@nullFlavor) and (hl7:translation[1]))">
		      <xsl:element name="{$hsElementName}">
		        <xsl:apply-templates select="." mode="fn-CodeTableDetail">
		          <xsl:with-param name="emitElementName" select="$hsElementName"/>
		          <xsl:with-param name="useFirstTranslation" select="'1'"/>
		          <xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
		          <xsl:with-param name="importOriginalText" select="$importOriginalText"/>
		        </xsl:apply-templates>
		        
		        <!-- This block is now UNUSED, but is left here for possible reactivation
		          <xsl:if test="$subCodedElementRootPath = true()">
		          <xsl:apply-templates select="$subCodedElementRootPath" mode="fn-CodeTable">
		          <xsl:with-param name="hsElementName" select="$subElementName"/>
		          <xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
		          <xsl:with-param name="importOriginalText" select="$importOriginalText"/>
		          </xsl:apply-templates>
		          </xsl:if>-->
		      	</xsl:element>
		    </xsl:when>
	    
		    <xsl:when test="($hasReferenceLink or not(@nullFlavor))
			                  and ($firstTranslationCodeSystem != $noCodeSystemOID or string-length($firstTranslationCodeSystem)=0)">
					<xsl:element name="{$hsElementName}">
						<xsl:apply-templates select="." mode="fn-CodeTableDetail">
							<xsl:with-param name="emitElementName" select="$hsElementName"/>
							<xsl:with-param name="useFirstTranslation" select="'0'"/>
							<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
							<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
						</xsl:apply-templates>
						
						<!-- This block is now UNUSED, but is left here for possible reactivation
						<xsl:if test="$subCodedElementRootPath = true()">
							<xsl:apply-templates select="$subCodedElementRootPath" mode="fn-CodeTable">
								<xsl:with-param name="hsElementName" select="$subElementName"/>
								<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
								<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
							</xsl:apply-templates>
						</xsl:if>-->
					</xsl:element>
			  </xsl:when>
			
		  	  <xsl:when test="(@nullFlavor and ($hasReferenceLink or string-length(hl7:originalText/text()) or (string-length(@displayName))))
		               or (@nullFlavor and $hsElementName='OrderItem' and (string-length($orderItemDefaultCode) or string-length($orderItemDefaultDescription)))">
		    	<xsl:element name="{$hsElementName}">
					<xsl:apply-templates select="." mode="fn-CodeTableDetail">
						<xsl:with-param name="emitElementName" select="$hsElementName"/>
						<xsl:with-param name="useFirstTranslation" select="'0'"/>
						<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
						<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
					</xsl:apply-templates>
					
					<!-- This block is now UNUSED, but is left here for possible reactivation
					<xsl:if test="$subCodedElementRootPath = true()">
						<xsl:apply-templates select="$subCodedElementRootPath" mode="fn-CodeTable">
							<xsl:with-param name="hsElementName" select="$subElementName"/>
							<xsl:with-param name="observationValueUnits" select="$observationValueUnits"/>
							<xsl:with-param name="importOriginalText" select="$importOriginalText"/>
						</xsl:apply-templates>
					</xsl:if>-->
				 </xsl:element>
			  </xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:code" mode="fn-CodeTable-CustomPair">
		<xsl:param name="emitElementName"/>
	<!--
		CodeTable-CustomPair is the CodeTable template, adapted
		for use with CustomPairs.  The difference between this
		and the CodeTable template is that this template does
		not support subCodedElementRootPath or subElementName,
		and it passes the isCustomPair parameter with a value
		of 1 when calling the CodeTableDetail template.
	-->
		
		<!--
			firstTranslationCodeSystem is the codeSystem attribute on
			the first, if any, <translation> for this code.  If it is
			the No Code System OID, then we know that that translation
			was added by HealthShare export.
		-->
		<xsl:variable name="firstTranslationCodeSystem" select="hl7:translation[1]/@codeSystem"/>
				
		<xsl:choose>
			<xsl:when test="($firstTranslationCodeSystem=$noCodeSystemOID) or ((@nullFlavor) and (hl7:translation[1]))">
				<xsl:apply-templates select="." mode="fn-CodeTableDetail">
				  <xsl:with-param name="emitElementName" select="$emitElementName"/>
					<xsl:with-param name="useFirstTranslation" select="'1'"/>
					<xsl:with-param name="isCustomPair" select="'1'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="(string-length(substring-after(.//hl7:reference/@value, '#')) or not(@nullFlavor)) and not($firstTranslationCodeSystem = $noCodeSystemOID)">
				<xsl:apply-templates select="." mode="fn-CodeTableDetail">
				  <xsl:with-param name="emitElementName" select="$emitElementName"/>
					<xsl:with-param name="useFirstTranslation" select="'0'"/>
					<xsl:with-param name="isCustomPair" select="'1'"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-CodeTableDetail">
		<xsl:param name="emitElementName"/>
		<!-- The above name is not completely arbitrary. If it contains any of
		     |Allergy|AllergyCategory|Diagnosis|DiagnosisType|DocumentType|TestItemCode|ObservationCode|OrderItem|Procedure|Severity|
		     as a substring, extra processing occurs. -->
		<xsl:param name="useFirstTranslation"/><!-- If 0, use @code, etc.; if 1, use the hl7:translation[1]/@code, etc. -->
		<xsl:param name="isCustomPair" select="'0'"/><!-- If 1, emit results in NVPair format -->
		<xsl:param name="observationValueUnits"/><!-- String to be used in optional ObservationValueUnits sub-element -->
		<xsl:param name="importOriginalText" select="'0'"/><!-- If 1, emit OriginalText sub-element when there is content for it -->

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
			<xsl:if test="string-length($referenceLink)">
					<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="hasReferenceValue" select="string-length(normalize-space($referenceValue)) > 0"/>
	  <xsl:variable name="hasOriginalText" select="string-length(normalize-space(hl7:originalText/text())) > 0"/>
	  <xsl:variable name="hasOrderItemDefault" select="($emitElementName='OrderItem') and string-length($orderItemDefaultCode) > 0"/>
	  
		<xsl:variable name="codingStandardTemp">
			<xsl:choose>
				<xsl:when test="not($useFirstTranslation='1')">
					<xsl:apply-templates select="." mode="fn-SDACodingStandard-text"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:translation[1]" mode="fn-SDACodingStandard-text"/>
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
		
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="not($useFirstTranslation='1')">
  			  <xsl:choose>
				    <xsl:when test="not($blockImportCTDCodeFromText='1')">
				      <xsl:choose>
				        <xsl:when test="@xsi:type = 'ST'"><xsl:value-of select="normalize-space(text())"/></xsl:when>
				        <xsl:when test="@code"><xsl:value-of select="translate(@code, '_', ' ')"/></xsl:when>
				        <xsl:when test="$hasReferenceValue"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
				        <xsl:when test="$hasOriginalText"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
				        <xsl:when test="$hasOrderItemDefault"><xsl:value-of select="$orderItemDefaultCode"/></xsl:when>
				      </xsl:choose>
				    </xsl:when>
				    <xsl:otherwise>
				      <!-- 
								$blockImportCTDCodeFromText blocks the import of any of
								the text values into SDA CodeTableDetail Code when the
								CDA element is nullFlavored.  The exception is the
								default value for OrderItem, if defined.
							-->
				      <xsl:choose>
				        <xsl:when test="(@nullFlavor) and $hasOrderItemDefault"><xsl:value-of select="$orderItemDefaultCode"/></xsl:when>
				        <xsl:when test="@nullFlavor"/>
				        <xsl:when test="@xsi:type = 'ST'"><xsl:value-of select="normalize-space(text())"/></xsl:when>
				        <xsl:when test="@code"><xsl:value-of select="translate(@code, '_', ' ')"/></xsl:when>
				        <xsl:when test="$hasReferenceValue"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
				        <xsl:when test="$hasOriginalText"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
				        <xsl:when test="$hasOrderItemDefault"><xsl:value-of select="$orderItemDefaultCode"/></xsl:when>
				      </xsl:choose>
				    </xsl:otherwise>
  			  </xsl:choose>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:choose>
				    <xsl:when test="not($blockImportCTDCodeFromText='1')">
				      <xsl:choose>
				        <xsl:when test="hl7:translation[1]/@xsi:type = 'ST'"><xsl:value-of select="normalize-space(hl7:translation[1]/text())"/></xsl:when>
				        <xsl:when test="hl7:translation[1]/@code"><xsl:value-of select="translate(hl7:translation[1]/@code, '_', ' ')"/></xsl:when>
				        <xsl:when test="$hasReferenceValue"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
				        <xsl:when test="$hasOriginalText"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
				      </xsl:choose>
				    </xsl:when>
				    <xsl:otherwise>
				      <!-- 
								$blockImportCTDCodeFromText blocks the import of any of
								the text values into SDA CodeTableDetail Code when the
								CDA element is nullFlavored.  The exception is the
								default value for OrderItem, if defined.
					   -->
				      <xsl:choose>
				        <xsl:when test="(hl7:translation[1]/@nullFlavor) and $hasOrderItemDefault"><xsl:value-of select="$orderItemDefaultCode"/></xsl:when>
				        <xsl:when test="hl7:translation[1]/@nullFlavor"/>
				        <xsl:when test="hl7:translation[1]/@xsi:type = 'ST'"><xsl:value-of select="normalize-space(hl7:translation[1]/text())"/></xsl:when>
				        <xsl:when test="hl7:translation[1]/@code"><xsl:value-of select="translate(hl7:translation[1]/@code, '_', ' ')"/></xsl:when>
				        <xsl:when test="$hasReferenceValue"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
				        <xsl:when test="$hasOriginalText"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
				        <xsl:when test="$hasOrderItemDefault"><xsl:value-of select="$orderItemDefaultCode"/></xsl:when>
				      </xsl:choose>
				    </xsl:otherwise>
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
						<xsl:when test="$hasReferenceValue"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
						<xsl:when test="normalize-space(hl7:originalText/text())"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
						<xsl:when test="($emitElementName='OrderItem') and string-length($orderItemDefaultDescription)"><xsl:value-of select="$orderItemDefaultDescription"/></xsl:when>
						<xsl:when test="string-length(normalize-space($codingStandard)) and string-length(normalize-space($code))"><xsl:value-of select="isc:evaluate('getRegistryDescription', $codingStandard, $code)"/></xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length(normalize-space(hl7:translation[1]/@displayName))"><xsl:value-of select="normalize-space(hl7:translation[1]/@displayName)"/></xsl:when>
						<xsl:when test="hl7:translation[1]/@xsi:type = 'ST'"><xsl:value-of select="normalize-space(hl7:translation[1]/text())"/></xsl:when>
						<xsl:when test="$hasReferenceValue"><xsl:value-of select="normalize-space($referenceValue)"/></xsl:when>
						<xsl:when test="normalize-space(hl7:originalText/text())"><xsl:value-of select="normalize-space(hl7:originalText/text())"/></xsl:when>
						<xsl:when test="string-length(normalize-space($codingStandard)) and string-length(normalize-space($code))"><xsl:value-of select="isc:evaluate('getRegistryDescription', $codingStandard, $code)"/></xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="not($isCustomPair = 1)">
				<!-- Let originalText retain line feeds and excess white space, but only if there is anything more than
						   line feeds and excess white space. -->
				<xsl:variable name="originalText">
					<xsl:choose>
						<xsl:when test="$hasReferenceValue">
							<xsl:value-of select="$referenceValue"/>
						</xsl:when>
						<xsl:when test="string-length(normalize-space(hl7:originalText/text()))">
							<xsl:value-of select="hl7:originalText/text()"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains('|Allergy|AllergyCategory|Diagnosis|DrugProduct|ObservationCode|OrderItem|Procedure|Severity|TestItemCode|', concat('|', $emitElementName, '|'))">
						<xsl:if test="string-length($codingStandard)">
							<SDACodingStandard><xsl:value-of select="$codingStandard"/></SDACodingStandard>
						</xsl:if>
						<!-- <s:element minOccurs="0" name="CodeSystemVersionId" type="s:string"/> -->
						<xsl:if test="$importOriginalText = '1' and string-length($originalText)">
							<OriginalText><xsl:value-of select="$originalText"/></OriginalText>
						</xsl:if>
						<xsl:apply-templates select="." mode="fn-PriorCodes">
							<xsl:with-param name="useFirstTranslation" select="$useFirstTranslation"/>
						</xsl:apply-templates>
						<!--  <s:element minOccurs="0" name="Extension" type="AllergyCodeExtension"/> -->
						<Code><xsl:value-of select="$code"/></Code>
						<Description><xsl:value-of select="$description"/></Description>
						<xsl:if test="string-length($observationValueUnits)">
							<ObservationValueUnits>
								<Code><xsl:value-of select="$observationValueUnits"/></Code>
							</ObservationValueUnits>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="string-length($codingStandard)">
							<SDACodingStandard><xsl:value-of select="$codingStandard"/></SDACodingStandard>
						</xsl:if>
						<!-- Prior Codes -->
						<xsl:if test="(not($isCustomPair=1))">
							<xsl:apply-templates select="." mode="fn-PriorCodes">
								<xsl:with-param name="useFirstTranslation" select="$useFirstTranslation"/>
							</xsl:apply-templates>
						</xsl:if>
						<Code><xsl:value-of select="$code"/></Code>
						<Description><xsl:value-of select="$description"/></Description>
						<xsl:if test="$importOriginalText = '1' and string-length($originalText)">
							<OriginalText><xsl:value-of select="$originalText"/></OriginalText>
						</xsl:if>
						<xsl:if test="string-length($observationValueUnits)">
							<ObservationValueUnits>
								<Code><xsl:value-of select="$observationValueUnits"/></Code>
							</ObservationValueUnits>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><!-- it IS a custom pair scenario -->
				<xsl:if test="string-length($codingStandard)">
					<NVPair>
						<Name><xsl:value-of select="concat($emitElementName,'CodingStandard')"/></Name>
						<Value><xsl:value-of select="$codingStandard"/></Value>
					</NVPair>
				</xsl:if>
				<NVPair>
					<Name><xsl:value-of select="concat($emitElementName,'Code')"/></Name>
					<Value><xsl:value-of select="$code"/></Value>
				</NVPair>
				<NVPair>
					<Name><xsl:value-of select="concat($emitElementName,'Description')"/></Name>
					<Value><xsl:value-of select="$description"/></Value>
				</NVPair>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-PriorCodes">
	  <!-- match could be hl7:code or whatever matched fn-CodeTableDetail -->
	  <xsl:param name="useFirstTranslation"/>
	<!--
		PriorCodes builds PriorCodes only if there is more than
		one translation element in the current coded element,
		OR if there is only one translation element and it was
		not used to export to SDA Code and Description already.
	-->
		<xsl:if test="count(hl7:translation)>1 or (count(hl7:translation)=1 and not($useFirstTranslation='1'))">
			<PriorCodes>
				<xsl:choose>
					<xsl:when test="$useFirstTranslation='1'"><!-- The first one was used already, take the rest -->
						<xsl:apply-templates select="hl7:translation[not(position()=1)]" mode="fn-PriorCode"/>
					</xsl:when>
					<xsl:otherwise><!-- Take them all -->
						<xsl:apply-templates select="hl7:translation" mode="fn-PriorCode"/>
					</xsl:otherwise>
				</xsl:choose>
			</PriorCodes>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:translation" mode="fn-PriorCode">
		<PriorCode>
			<Code><xsl:value-of select="@code"/></Code>
			<Description><xsl:value-of select="@displayName"/></Description>
			<CodeSystem><xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="@codeSystem"/></xsl:apply-templates></CodeSystem>
			<Type>A</Type>
		</PriorCode>
	</xsl:template>	

	<xsl:template match="*" mode="fn-SDACodingStandard-text">
	  <!-- Match could be hl7:translation or whatever matched fn-CodeTableDetail -->
	  <xsl:choose>
	    <!-- The InterSystems "no coding system" indicator (in global variables). Return nothing. -->
	    <xsl:when test="@codeSystem=$noCodeSystemOID or @codeSystemName=$noCodeSystemName"/>
	    <!-- @codeSystem is present.  Return $codeForOID, regardless of whether there is an entry for @codeSystem in the OID Registry. -->
	    <xsl:when test="string-length(@codeSystem)">
	      <xsl:apply-templates select="." mode="fn-code-for-oid">
	        <xsl:with-param name="OID" select="@codeSystem"/>
	      </xsl:apply-templates>
	    </xsl:when>
	    <!-- @codeSystemName is present but @codeSystem is not. Return @codeSystemName, regardless of whether there is an entry for @codeSystemName in the OID Registry. -->
	    <xsl:when test="string-length(@codeSystemName)">
	      <xsl:value-of select="@codeSystemName"/>
	    </xsl:when>
	    <!-- At this point both @codeSystem and @codeSystemName are missing. Return nothing. -->
	  </xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-I-SendingFacilityValue">
	  <!-- Match could be hl7:ClinicalDocument or this could be called directly from the top level -->
	  <!--
			Field: Sending Facility
			Target: HS.SDA3.Container SendingFacility
			Target: /Container/SendingFacility
			Source: /ClinicalDocument/informant/assignedEntity/representedOrganization
			Source: /ClinicalDocument/author/assignedEntity/representedOrganization
			Note  : Sending Facility is derived from the representedOrganization data for
					the first found of the following:
					- /ClinicalDocument/informant
					- /ClinicalDocument/author[not(hl7:assignedAuthor/hl7:assignedAuthoringDevice)]
					- /ClinicalDocument/author[hl7:assignedAuthor/hl7:assignedAuthoringDevice]
					If none those is found, then Sending Facility is derived from the IdentityCode
					for the OID found at /ClinicalDocument/recordTarget/patientRole/id/@root.
		-->
		<xsl:choose>
			<xsl:when test="$defaultInformantRootPath/hl7:assignedEntity/hl7:representedOrganization"><xsl:apply-templates select="$defaultInformantRootPath" mode="fn-SendingFacilityFromOrgInfo"/></xsl:when>
			<xsl:when test="$defaultAuthorRootPath/hl7:assignedAuthor/hl7:representedOrganization"><xsl:apply-templates select="$defaultAuthorRootPath" mode="fn-SendingFacilityFromOrgInfo"/></xsl:when>
			<xsl:when test="$defaultAuthoringDeviceRootPath/hl7:assignedAuthor/hl7:representedOrganization"><xsl:apply-templates select="$defaultAuthoringDeviceRootPath" mode="fn-SendingFacilityFromOrgInfo"/></xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$input/hl7:recordTarget/hl7:patientRole/hl7:id/@root"/></xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:author | hl7:informant" mode="fn-SendingFacilityFromOrgInfo">
		<xsl:variable name="facilityInformation"><xsl:apply-templates select=".//hl7:representedOrganization" mode="fn-P-FacilityInformation"/></xsl:variable>
		
		<xsl:if test="string-length($facilityInformation)">
			<xsl:variable name="flags" select="substring-before(substring-after($facilityInformation, 'F0:'), '|')"/>
			<xsl:choose>
				<xsl:when test="$flags > 1">
					<!-- use the Code -->
					<xsl:value-of select="substring-before(substring-after($facilityInformation, 'F2:'), '|')"/>
				</xsl:when>
				<xsl:when test="($flags mod 2) = 1">
					<!-- use the Description -->
					<xsl:value-of select="substring-before(substring-after($facilityInformation, 'F3:'), '|')"/>
				</xsl:when>
				<xsl:otherwise>Unknown</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:performer" mode="fn-PerformedAt">
		<!--
			StructuredMapping: PerformedAt
			
			Field
			Path  : CurrentProperty
			XPath : ./
			Source: assignedEntity
			StructuredMappingRef: OrganizationDetail
		-->
		<xsl:apply-templates select="hl7:assignedEntity" mode="fn-OrganizationDetail">
			<xsl:with-param name="emitElementName" select="'PerformedAt'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="fn-EnteredAt">
	  <!-- Match could be hl7:author, hl7:participant, hl7:informant, hl7:observation, more... -->
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
			<xsl:when test="hl7:informant"><xsl:apply-templates select="hl7:informant" mode="fn-OrganizationDetail"/></xsl:when>
			<xsl:when test="hl7:author"><xsl:apply-templates select="hl7:author" mode="fn-OrganizationDetail"/></xsl:when>
			<xsl:when test="local-name()='informant'"><xsl:apply-templates select="." mode="fn-OrganizationDetail"/></xsl:when>
			<xsl:when test="local-name()='author' and not(hl7:assignedAuthor/hl7:assignedAuthoringDevice)"><xsl:apply-templates select="." mode="fn-OrganizationDetail"/></xsl:when>
			<xsl:when test="$defaultInformantRootPath"><xsl:apply-templates select="$defaultInformantRootPath" mode="fn-OrganizationDetail"/></xsl:when>
			<xsl:when test="$defaultAuthorRootPath"><xsl:apply-templates select="$defaultAuthorRootPath" mode="fn-OrganizationDetail"/></xsl:when>
			<xsl:when test="$defaultAuthoringDeviceRootPath"><xsl:apply-templates select="$defaultAuthoringDeviceRootPath" mode="fn-OrganizationDetail"/></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="fn-EnteringOrganization">
	  <!-- Match could be hl7:act, hl7:procedure, hl7:substanceAdministration, hl7:observation -->
	  <!--
			StructuredMapping: EnteringOrganization
			
			Field
			Path  : Code
			XPath : Code/text()
			Source: assignedEntity/representedOrganization/id/@root
			
			Field
			Path  : Description
			XPath : Description/text()
			Source: assignedEntity/representedOrganization/name/text()
			
			Field
			Path  : Organization.Code
			XPath : Organization/Code/text()
			Source: assignedEntity/representedOrganization/id/@root
			
			Field
			Path  : Organization.Description
			XPath : Organization/Description/text()
			Source: assignedEntity/representedOrganization/name/text()
		-->
		<xsl:variable name="eoTypes">|INF|AUT|ENT|LOC|ORG|PRF|SPRF|</xsl:variable>
		<xsl:choose>
			<xsl:when test="hl7:informant">
				<xsl:apply-templates select="hl7:informant" mode="fn-HealthCareFacilityDetail">
					<xsl:with-param name="elementName" select="'EnteringOrganization'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="hl7:participant[contains($eoTypes, concat('|',@typeCode,'|'))]">
				<xsl:apply-templates select="hl7:participant[contains($eoTypes, concat('|',@typeCode,'|'))]" mode="fn-HealthCareFacilityDetail">
					<xsl:with-param name="elementName" select="'EnteringOrganization'"/>
				</xsl:apply-templates>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:apply-templates select="$defaultInformantRootPath" mode="fn-HealthCareFacilityDetail">
					<xsl:with-param name="elementName" select="'EnteringOrganization'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:location" mode="fn-HealthCareFacility">
		<xsl:apply-templates select="." mode="fn-HealthCareFacilityDetail">
			<xsl:with-param name="elementName" select="'HealthCareFacility'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:informant | hl7:location" mode="fn-HealthCareFacilityDetail">
		<xsl:param name="elementName"/>
		
		<xsl:variable name="facilityInformation"><xsl:apply-templates select=".//hl7:representedOrganization | .//hl7:serviceProviderOrganization" mode="fn-P-FacilityInformation"/></xsl:variable>
		
		<xsl:variable name="locationInformation"><xsl:apply-templates select="hl7:healthCareFacility" mode="fn-LocationInformation"/></xsl:variable>
		
		<xsl:variable name="sendingFacilityCode"><xsl:apply-templates select="$input" mode="fn-I-SendingFacilityValue"/></xsl:variable>
		
		<!-- Parse location information -->
		<xsl:variable name="locationFlags" select="substring-before(substring-after($locationInformation, 'L0:'), '|')"/>
		<xsl:variable name="locationCode" select="substring-before(substring-after($locationInformation, 'L2:'), '|')"/>
		<xsl:variable name="locationDescription" select="substring-before(substring-after($locationInformation, 'L3:'), '|')"/>
		
		<!-- Parse facility information -->
		<xsl:variable name="facilityFlags" select="substring-before(substring-after($facilityInformation, 'F0:'), '|')"/>
		<xsl:variable name="facilityCode" select="substring-before(substring-after($facilityInformation, 'F2:'), '|')"/>
		<xsl:variable name="facilityDescription" select="substring-before(substring-after($facilityInformation, 'F3:'), '|')"/>
		
	  <xsl:element name="{$elementName}">
			<xsl:choose>
				<xsl:when test="$locationFlags > 1">
					<Code><xsl:value-of select="$locationCode"/></Code>
					<xsl:if test="($locationFlags mod 2) = 1"><Description><xsl:value-of select="$locationDescription"/></Description></xsl:if>
				</xsl:when>
				<xsl:when test="$facilityFlags > 1">
					<Code><xsl:value-of select="$facilityCode"/></Code>
					<xsl:if test="($facilityFlags mod 2) = 1"><Description><xsl:value-of select="$facilityDescription"/></Description></xsl:if>
				</xsl:when>
				<xsl:when test="$sendingFacilityCode">
					<Code><xsl:value-of select="$sendingFacilityCode"/></Code>
					<Description><xsl:value-of select="$sendingFacilityCode"/></Description>
				</xsl:when>
			</xsl:choose>
			<Organization>
				<xsl:choose>
					<xsl:when test="$facilityFlags > 1">
						<Code><xsl:value-of select="$facilityCode"/></Code>
						<xsl:if test="($facilityFlags mod 2) = 1"><Description><xsl:value-of select="$facilityDescription"/></Description></xsl:if>
					</xsl:when>
					<xsl:when test="$locationFlags > 1">
						<Code><xsl:value-of select="$locationCode"/></Code>
						<xsl:if test="($locationFlags mod 2) = 1"><Description><xsl:value-of select="$locationDescription"/></Description></xsl:if>
					</xsl:when>
					<xsl:when test="$sendingFacilityCode">
						<Code><xsl:value-of select="$sendingFacilityCode"/></Code>
						<Description><xsl:value-of select="$sendingFacilityCode"/></Description>
					</xsl:when>
				</xsl:choose>
			</Organization>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*" mode="fn-HealthCareFacilityLocation">			
			<Location>
				<LocationDetail>
					<xsl:variable name="facilityName">
						<xsl:value-of select="hl7:healthCareFacility/hl7:serviceProviderOrganization/hl7:name" />
					</xsl:variable>	
					<xsl:choose>
						<xsl:when test="hl7:healthCareFacility" >
							<Code><xsl:value-of select="$facilityName" /></Code>
							<Description><xsl:value-of select="$facilityName" /></Description>
						</xsl:when>
						<xsl:otherwise>
							<Code>unknown</Code>
							<Description>unknown</Description>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="hl7:healthCareFacility/hl7:code" mode="fn-CodeTable">
						<xsl:with-param name="hsElementName" select="'LocationTypeCoded'"/>
						<xsl:with-param name="importOriginalText" select="'1'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="hl7:healthCareFacility/hl7:location/hl7:addr" mode="fn-T-pName-address"/>
					<xsl:apply-templates select="." mode="fn-T-pName-ContactInfo"/>								
				</LocationDetail>
			</Location>
	</xsl:template>
						
	<xsl:template match="*" mode="fn-OrganizationDetail">
	  <!-- Match could be hl7:assignedEntity, hl7:author, hl7:informant -->
	  <xsl:param name="emitElementName" select="'EnteredAt'"/>
		
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
		<xsl:variable name="facilityInformation"><xsl:apply-templates select=".//hl7:representedOrganization" mode="fn-P-FacilityInformation"/></xsl:variable>		
		
		<xsl:if test="string-length($facilityInformation)">
			<xsl:element name="{$emitElementName}">
				<Code><xsl:value-of select="substring-before(substring-after($facilityInformation, 'F2:'), '|')"/></Code>
				<Description><xsl:value-of select="substring-before(substring-after($facilityInformation, 'F3:'), '|')"/></Description>
				<xsl:apply-templates select=".//hl7:representedOrganization/hl7:addr" mode="fn-T-pName-address"/>
				<xsl:apply-templates select=".//hl7:representedOrganization" mode="fn-T-pName-ContactInfo"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-EnteredBy">
	  <!-- Match could be hl7:author, hl7:associatedPerson, hl7:entry, hl7:observation, hl7:act, hl7:procedure, hl7:organizer, hl7:encounter,
		   hl7:substanceAdministration, more... -->
	  <xsl:choose>
			<xsl:when test="hl7:author"><xsl:apply-templates select="hl7:author" mode="fn-EnteredByDetail"/></xsl:when>
			<xsl:when test="hl7:assignedAuthor"><xsl:apply-templates select="." mode="fn-EnteredByDetail"/></xsl:when>
			<xsl:when test="string-length(./hl7:associatedEntity/hl7:associatedPerson/hl7:name) > 0">
				<xsl:apply-templates select="./hl7:associatedEntity/hl7:associatedPerson" mode="fn-EnteredByDetail"/>
			</xsl:when>
			<xsl:otherwise><xsl:apply-templates select="$defaultAuthorRootPath" mode="fn-EnteredByDetail"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-EnteredByDetail">
	  <!-- Match is same as fn-EnteredBy -->
		<!--
			StructuredMapping: EnteredByDetail
			
			Field
			Path  : Code
			XPath : Code
			Source: assignedAuthor/code/@displayName
			Note  : If CDA @displayName is not available then originalText
					may be imported to SDA Code.  If originalText is also
					not available then assignedPerson/name is imported to
					SDA Code.
			
			Field
			Path  : Description
			XPath : Description
			Source: assignedAuthor/code/@displayName
			Note  : If CDA @displayName is not available then originalText
					may be imported to SDA Description  If originalText is
					also not available then assignedPerson/name is imported
					to SDA Description.
		-->		
		<xsl:choose>
			<xsl:when test="hl7:assignedAuthor/hl7:assignedPerson and not(hl7:assignedAuthor/hl7:assignedPerson/hl7:name/@nullFlavor)">	
				<EnteredBy>
					<xsl:choose>
						<xsl:when test="hl7:assignedAuthor/hl7:code and
							              (not(hl7:assignedAuthor/hl7:code/@nullFlavor)
							               or (hl7:assignedAuthor/hl7:code/@nullFlavor and string-length(hl7:assignedAuthor/hl7:code/hl7:originalText/text())))">
							<xsl:variable name="authorType">
								<xsl:choose>
									<xsl:when test="string-length(hl7:assignedAuthor/hl7:code/@displayName)">
										<xsl:value-of select="hl7:assignedAuthor/hl7:code/@displayName"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="hl7:assignedAuthor/hl7:code/hl7:originalText/text()"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
						
							<Code><xsl:value-of select="$authorType"/></Code>
							<Description><xsl:value-of select="$authorType"/></Description>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="contactNameFull"><xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name" mode="fn-ContactNameLongString"/></xsl:variable>

							<xsl:variable name="assignedAuthorIdExtension">
								<xsl:choose>
									<xsl:when test="hl7:author/hl7:assignedAuthor">
										<xsl:value-of select="hl7:author/hl7:assignedAuthor/hl7:id/extension"/>			
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="hl7:assignedAuthor">
											<xsl:value-of select="hl7:assignedAuthor/hl7:id/@extension"/>
										</xsl:if>	
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<!--For Code, id extension takes precedence over full name-->
							<xsl:choose>
								<xsl:when test="string-length($assignedAuthorIdExtension)>0">
									<Code><xsl:value-of select="$assignedAuthorIdExtension"/></Code>
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="string-length($contactNameFull)>0">
										<Code><xsl:value-of select="$contactNameFull"/></Code>
									</xsl:if>		
								</xsl:otherwise>
							</xsl:choose>

							<Description><xsl:value-of select="$contactNameFull"/></Description>
						</xsl:otherwise>
					</xsl:choose>
				</EnteredBy>
			</xsl:when>			
			<xsl:when test="./hl7:name">
				<EnteredBy>					
					<xsl:variable name="contactNameFull"><xsl:apply-templates select="./hl7:name" mode="fn-ContactNameLongString"/></xsl:variable>
					<Code><xsl:value-of select="$contactNameFull"/></Code>
					<Description><xsl:value-of select="$contactNameFull"/></Description>
				</EnteredBy>					
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:author" mode="fn-Performer">
		<xsl:choose>
			<xsl:when test="hl7:assignedAuthor/hl7:assignedPerson and not(hl7:assignedAuthor/hl7:assignedPerson/hl7:name/@nullFlavor)">	
				<Performer>
					<xsl:choose>
						<xsl:when test="hl7:assignedAuthor/hl7:code and
							              (not(hl7:assignedAuthor/hl7:code/@nullFlavor)
							               or (hl7:assignedAuthor/hl7:code/@nullFlavor and string-length(hl7:assignedAuthor/hl7:code/hl7:originalText/text())))">
							<xsl:variable name="authorType">
								<xsl:choose>
									<xsl:when test="string-length(hl7:assignedAuthor/hl7:code/@displayName)">
										<xsl:value-of select="hl7:assignedAuthor/hl7:code/@displayName"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="hl7:assignedAuthor/hl7:code/hl7:originalText/text()"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
						
							<Code><xsl:value-of select="$authorType"/></Code>
							<Description><xsl:value-of select="$authorType"/></Description>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="contactNameFull"><xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name" mode="fn-ContactNameLongString"/></xsl:variable>

							<xsl:variable name="assignedAuthorIdExtension">
								<xsl:choose>
									<xsl:when test="hl7:author/hl7:assignedAuthor">
										<xsl:value-of select="hl7:author/hl7:assignedAuthor/hl7:id/extension"/>			
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="hl7:assignedAuthor">
											<xsl:value-of select="hl7:assignedAuthor/hl7:id/@extension"/>
										</xsl:if>	
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<!--For Code, id extension takes precedence over full name-->
							<xsl:choose>
								<xsl:when test="string-length($assignedAuthorIdExtension)>0">
									<Code><xsl:value-of select="$assignedAuthorIdExtension"/></Code>
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="string-length($contactNameFull)>0">
										<Code><xsl:value-of select="$contactNameFull"/></Code>
									</xsl:if>		
								</xsl:otherwise>
							</xsl:choose>

							<Description><xsl:value-of select="$contactNameFull"/></Description>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="hl7:time" mode="fn-I-timestamp">
						<xsl:with-param name="emitElementName" >EnteredOn</xsl:with-param>
					</xsl:apply-templates>
					<xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name" mode="fn-T-pName-ContactName"/>				
					<xsl:apply-templates select="hl7:assignedAuthor/hl7:addr" mode="fn-T-pName-address"/>
					<xsl:apply-templates select="hl7:assignedAuthor" mode="fn-T-pName-ContactInfo"/>
				</Performer>
			</xsl:when>			
			<xsl:when test="./hl7:name">
				<Performer>					
					<xsl:variable name="contactNameFull"><xsl:apply-templates select="./hl7:name" mode="fn-ContactNameLongString"/></xsl:variable>
					<Code><xsl:value-of select="$contactNameFull"/></Code>
					<Description><xsl:value-of select="$contactNameFull"/></Description>
					<xsl:apply-templates select="hl7:time" mode="fn-I-timestamp">
						<xsl:with-param name="emitElementName" >EnteredOn</xsl:with-param>
					</xsl:apply-templates>
					<xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name" mode="fn-T-pName-ContactName"/>				
					<xsl:apply-templates select="hl7:assignedAuthor/hl7:addr" mode="fn-T-pName-address"/>
					<xsl:apply-templates select="hl7:assignedAuthor" mode="fn-T-pName-ContactInfo"/>
				</Performer>					
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="hl7:effectiveTime" mode="fn-ObservationTime">
		<xsl:if test="@value">		
			<ObservationTime>
				<xsl:value-of select="isc:evaluate('xmltimestamp', @value)" />
			</ObservationTime>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="fn-I-timestamp">
		<xsl:param name="emitElementName"/>
		<!-- Call this mode when the context node is an element whose @value attribute is the DateTime to be processed.
		     Usually, the element is one of hl7:effectiveTime, hl7:time, hl7:low, hl7:high.
		     We will test for content in @value before proceeding. -->
		<xsl:if test="string-length(@value) > 0">
			<xsl:apply-templates select="@value" mode="fn-E-paramName-timestamp">
				<xsl:with-param name="emitElementName" select="$emitElementName"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="@value" mode="fn-E-paramName-timestamp">
		<xsl:param name="emitElementName"/>
		<!-- This is the inner mode, which assumes that any necessary value check is already done -->
		<xsl:element name="{$emitElementName}">
			<xsl:call-template name="fn-S-timestamp">
				<xsl:with-param name="inputString" select="."/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="hl7:effectiveTime | hl7:time" mode="fn-EnteredOn">
		<!--
			StructuredMapping: EnteredOn
			
			Field  : EnteredOn
			Source : effectiveTime
			Target : EnteredOn
		-->	
		<xsl:apply-templates select="." mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'EnteredOn'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:effectiveTime | hl7:low" mode="fn-FromTime">		
		<xsl:apply-templates select="." mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'FromTime'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:effectiveTime | hl7:high" mode="fn-ToTime">
		<xsl:apply-templates select="." mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'ToTime'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:low | hl7:effectiveTime" mode="fn-StartTime">
		<xsl:apply-templates select="." mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'FromTime'"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="hl7:high | hl7:effectiveTime" mode="fn-EndTime">
		<xsl:apply-templates select="." mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'ToTime'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:encounter | hl7:encompassingEncounter" mode="fn-AttendingClinicians">
		<!--
			StructuredMapping: AttendingClinicians-NoFunction
			
			Field
			Path  : CareProvider
			XPath : ./CareProvider
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<!--
			StructuredMapping: AttendingClinicians-NoFunction
			
			Field
			Path  : CareProvider
			XPath : ./CareProvider
			Source: ./
			StrucuredMappingRef: DoctorDetail
		-->
		<xsl:if test="hl7:encounterParticipant[@typeCode = 'ATND'] | hl7:performer[@typeCode = 'PRF']">
			<AttendingClinicians>
				<xsl:apply-templates select="hl7:encounterParticipant[@typeCode = 'ATND'] | hl7:performer[@typeCode = 'PRF']" mode="fn-W-CareProvider"/>
			</AttendingClinicians>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:encompassingEncounter" mode="fn-ConsultingClinicians">
		<!--
			StructuredMapping: ConsultingClinicians-NoFunction
			
			Field
			Path  : CareProvider
			XPath : ./CareProvider
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<!--
			StructuredMapping: ConsultingClinicians-NoFunction
			
			Field
			Path  : CareProvider
			XPath : ./CareProvider
			Source: ./
			StrucuredMappingRef: DoctorDetail
		-->
		<xsl:if test="hl7:encounterParticipant[@typeCode = 'CON']">
			<ConsultingClinicians>
				<xsl:apply-templates select="hl7:encounterParticipant[@typeCode = 'CON']" mode="fn-W-CareProvider"/>
			</ConsultingClinicians>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:encounterParticipant" mode="fn-AdmittingClinician">
		<!--
			StructuredMapping: AdmittingClinician
			
			Field
			Path  : AdmittingClinician
			XPath : ./AdmittingClinician
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<AdmittingClinician>
			<xsl:apply-templates select="." mode="fn-CareProviderDetail"/>
		</AdmittingClinician>
	</xsl:template>

	<xsl:template match="hl7:encounterParticipant" mode="fn-ReferringClinician">
		<!--
			StructuredMapping: ReferringClinician
			
			Field
			Path  : ReferringClinician
			XPath : ./ReferringClinician
			Source: ./
			StrucuredMappingRef: DoctorDetail
		-->
		<ReferringClinician>
			<xsl:apply-templates select="." mode="fn-DoctorDetail"/>
		</ReferringClinician>
	</xsl:template>

	<xsl:template match="hl7:performer" mode="fn-FamilyDoctor">
		<!--
			StructuredMapping: FamilyDoctor
			
			Field
			Path  : FamilyDoctor
			XPath : ./FamilyDoctor
			Source: ./
			StrucuredMappingRef: DoctorDetail
		-->
		<FamilyDoctor>
			<xsl:apply-templates select="." mode="fn-DoctorDetail"/>
		</FamilyDoctor>
	</xsl:template>
	
	<xsl:template match="hl7:performer" mode="fn-Clinician">
		<!--
			StructuredMapping: Clinician
			
			Field
			Path  : Clinician
			XPath : ./Clinician
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<Clinician>
			<xsl:apply-templates select="." mode="fn-CareProviderDetail"/>
		</Clinician>
	</xsl:template>

	<xsl:template match="hl7:performer" mode="fn-DiagnosingClinician">
		<!--
			StructuredMapping: DiagnosingClinician
			
			Field
			Path  : DiagnosingClinician
			XPath : ./DiagnosingClinician
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<DiagnosingClinician>
			<xsl:apply-templates select="." mode="fn-CareProviderDetail"/>
		</DiagnosingClinician>
	</xsl:template>

	<xsl:template match="hl7:performer" mode="fn-OrderedBy">
		<!--
			StructuredMapping: OrderedBy
			
			Field
			Path  : OrderedBy
			XPath : ./OrderedBy
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<OrderedBy>
			<xsl:apply-templates select="." mode="fn-CareProviderDetail"/>
		</OrderedBy>
	</xsl:template>

	<xsl:template match="hl7:performer" mode="fn-ReferredToProvider">
		<!--
			StructuredMapping: ReferredToProvider
			
			Field
			Path  : ReferredToProvider
			XPath : ./ReferredToProvider
			Source: ./
			StrucuredMappingRef: CareProviderDetail
		-->
		<ReferredToProvider>
			<xsl:apply-templates select="." mode="fn-CareProviderDetail"/>
		</ReferredToProvider>
	</xsl:template>
	
	<xsl:template match="hl7:informant" mode="fn-ReferringProvider">
		<ReferringProvider>
			<xsl:variable name="entityPath" select="hl7:assignedEntity"/>
			<xsl:variable name="personPath" select="$entityPath/hl7:assignedPerson | $entityPath/hl7:associatedPerson"/>

			<xsl:if test="$personPath = true() and not($personPath/hl7:name/@nullFlavor)">
				<!-- Contact Name and Contact Information -->
				<xsl:apply-templates select="$personPath/hl7:name" mode="fn-T-pName-ContactName"/>
				<xsl:apply-templates select="$entityPath/hl7:addr" mode="fn-T-pName-address"/>
				<xsl:apply-templates select="$entityPath" mode="fn-T-pName-ContactInfo"/>
			</xsl:if>
		</ReferringProvider>
	</xsl:template>

	<xsl:template match="hl7:author" mode="fn-OrderedBy-Author">
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
					<xsl:variable name="contactNameRTF"><xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name" mode="fn-T-pName-ContactName"/></xsl:variable>
					<xsl:variable name="contactName" select="exsl:node-set($contactNameRTF)/Name"/>
					<xsl:variable name="contactNameFull" select="normalize-space(concat($contactName/NamePrefix/text(), ' ', $contactName/GivenName/text(), ' ', $contactName/MiddleName/text(), ' ', $contactName/FamilyName/text(), ' ', $contactName/ProfessionalSuffix/text()))"/>
					
					<Code>
						<xsl:choose>
							<xsl:when test="string-length(hl7:assignedAuthor/hl7:id/@extension)">
								<xsl:value-of select="hl7:assignedAuthor/hl7:id/@extension"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$contactNameFull"/>
							</xsl:otherwise>
						</xsl:choose>
					</Code>
					<Description><xsl:value-of select="$contactNameFull"/></Description>
					<xsl:if test="string-length($contactName/GivenName/text()) and string-length($contactName/FamilyName/text())">
						<xsl:copy-of select="$contactNameRTF"/><!-- This will include the Extension sub-tree, if present -->
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</OrderedBy>
	</xsl:template>

	<xsl:template match="hl7:encounterParticipant | hl7:informant | hl7:performer" mode="fn-W-CareProvider">
		<CareProvider>
			<xsl:apply-templates select="." mode="fn-CareProviderDetail"/>
		</CareProvider>
	</xsl:template>
	
	<xsl:template match="hl7:encounterParticipant | hl7:informant | hl7:performer" mode="fn-CareProviderDetail">
		<!-- This template provides CareProvider content. It should be called by some other mode that provides
		     surrounding element start and end tags. -->
		<!--
			StructuredMapping: CareProviderDetail
			
			Field
			Path  : Code
			XPath : Code/text()
			Source: assignedEntity/id/@extension
			Note  : If id/@extension is not available then assignedEntity/assignedPerson/name/text() is used.
			
			Field
			Path  : Description
			XPath : Description/text()
			Source: assignedEntity/assignedPerson/name
			Note  : The value used for SDA Description is a string assembled from the discrete parts of assignedEntity/assignedPerson/name.
			
			Field
			Path  : ContactName
			XPath : ContactName
			Source: assignedEntity/assignedPerson/name
			StructuredMappingRef: ContactName
			
			Field
			Path  : Address
			XPath : Address
			Source: assignedEntity/addr
			StructuredMappingRef: Address
			
			Field
			Path  : ContactInfo
			XPath : ContactInfo
			Source: assignedEntity
			StructuredMappingRef: ContactInfo
			
			Field
			Path  : CareProviderType.Code
			XPath : CareProviderType/Code/text()
			Source: functionCode/@code
			
			Field
			Path  : CareProviderType.Description
			XPath : CareProviderType/Description/text()
			Source: functionCode/@displayName
			
			Field
			Path  : CareProviderType.SDACodingStandard
			XPath : CareProviderType/SDACodingStandard/text()
			Source: functionCode/@codeSystem
		-->
		<xsl:variable name="entityPath" select="hl7:assignedEntity | hl7:associatedEntity"/>
		
		<xsl:if test="$entityPath = true()">
			<xsl:variable name="personPath" select="$entityPath/hl7:assignedPerson | $entityPath/hl7:associatedPerson"/>
			
			<xsl:if test="$personPath = true() and not($personPath/hl7:name/@nullFlavor)">
				<xsl:variable name="translation1code" select="hl7:functionCode/hl7:translation[1]/@code"/>
				<xsl:variable name="isNullFunctionCode" select="string-length(hl7:functionCode/@nullFlavor) > 0"/>
				<xsl:variable name="codeOrTranslation">
					<!-- 0 = no data, 1 = use hl7:functionCode, 2 = use hl7:functionCode/hl7:translation[1] -->
					<xsl:choose>
						<xsl:when test="$isNullFunctionCode and $translation1code and hl7:functionCode/hl7:translation[1]/@codeSystem">2</xsl:when>
						<xsl:when test="not($isNullFunctionCode) and $translation1code and hl7:functionCode/hl7:translation[1]/@codeSystem=$noCodeSystemOID">2</xsl:when>
						<xsl:when test="hl7:functionCode/@code and not($isNullFunctionCode)">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianFunctionCode">
					<xsl:choose>
						<xsl:when test="$codeOrTranslation='1'">
							<xsl:value-of select="hl7:functionCode/@code"/>
						</xsl:when>
						<xsl:when test="$codeOrTranslation='2'">
							<xsl:value-of select="$translation1code"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="clinicianAssigningAuthority">
					<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$entityPath/hl7:id/@root"/></xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="clinicianID" select="$entityPath/hl7:id/@extension"/>
				<xsl:variable name="clinicianName">
					<xsl:apply-templates select="$personPath/hl7:name" mode="fn-ContactNameString"/>
				</xsl:variable>
				
				<xsl:if test="string-length($clinicianAssigningAuthority) and not($clinicianAssigningAuthority=$noCodeSystemOID) and not($clinicianAssigningAuthority=$noCodeSystemName)">
					<SDACodingStandard><xsl:value-of select="$clinicianAssigningAuthority"/></SDACodingStandard>
				</xsl:if>
				<Code>
					<xsl:choose>
						<xsl:when test="string-length($clinicianID)"><xsl:value-of select="$clinicianID"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$clinicianName"/></xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description><xsl:value-of select="$clinicianName"/></Description>
				<!-- Contact Name and Contact Information -->
				<xsl:apply-templates select="$personPath/hl7:name" mode="fn-T-pName-ContactName"/>
				<xsl:apply-templates select="$entityPath/hl7:addr" mode="fn-T-pName-address"/>
				<xsl:apply-templates select="$entityPath" mode="fn-T-pName-ContactInfo"/>
				
				<!-- Contact Type -->
				<xsl:if test="string-length($clinicianFunctionCode)">
					<CareProviderType>
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
						<xsl:if test="string-length($clinicianFunctionCodeSystem)">
							<SDACodingStandard>
								<xsl:apply-templates select="." mode="fn-code-for-oid">
									<xsl:with-param name="OID" select="$clinicianFunctionCodeSystem"/>
								</xsl:apply-templates>
							</SDACodingStandard>
						</xsl:if>
						<Code><xsl:value-of select="$clinicianFunctionCode"/></Code>
						<Description>
							<xsl:choose>
								<xsl:when test="$codeOrTranslation = '1'">
									<xsl:value-of select="hl7:functionCode/@displayName"/>
								</xsl:when>
								<xsl:when test="$codeOrTranslation = '2'">
									<xsl:value-of select="hl7:functionCode/hl7:translation[1]/@displayName"/>
								</xsl:when>
							</xsl:choose>
						</Description>
					</CareProviderType>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:encounterParticipant | hl7:performer" mode="fn-DoctorDetail">
	<!--
		DoctorDetail is the same as CareProviderDetail, except
		for functionCode support, which is omitted here due to
		the contents of SDA FamilyDoctor and ReferringClinician.
	-->
		<!--
			StructuredMapping: DoctorDetail
			
			Field
			Path  : Code
			XPath : Code/text()
			Source: assignedEntity/id/@extension
			Note  : If id/@extension is not available then assignedPerson/name/text() is used.
			
			Field
			Path  : Description
			XPath : Description/text()
			Source: assignedEntity/assignedPerson/name/text()
			
			Field
			Path  : Name
			XPath : Name
			Source: assignedEntity/name
			StructuredMappingRef: ContactName
			
			Field
			Path  : Address
			XPath : Address
			Source: assignedEntity/addr
			StructuredMappingRef: Address
			
			Field
			Path  : ContactInfo
			XPath : ContactInfo
			Source: assignedEntity
			StructuredMappingRef: ContactInfo
		-->
		<xsl:variable name="entityPath" select="hl7:assignedEntity | hl7:associatedEntity"/>
		
		<xsl:if test="$entityPath = true()">
			<xsl:variable name="personPath" select="$entityPath/hl7:assignedPerson | $entityPath/hl7:associatedPerson"/>
			
			<xsl:if test="$personPath = true() and not($personPath/hl7:name/@nullFlavor)">
				<xsl:variable name="clinicianAssigningAuthority">
					<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$entityPath/hl7:id/@root"/></xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="clinicianID" select="$entityPath/hl7:id/@extension"/>
				<xsl:variable name="clinicianName">
					<xsl:apply-templates select="$personPath/hl7:name" mode="fn-ContactNameString"/>
				</xsl:variable>
					
				<xsl:if test="string-length($clinicianAssigningAuthority)">
					<SDACodingStandard><xsl:value-of select="$clinicianAssigningAuthority"/></SDACodingStandard>
				</xsl:if>
				<Code>
					<xsl:choose>
						<xsl:when test="string-length($clinicianID)"><xsl:value-of select="$clinicianID"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$clinicianName"/></xsl:otherwise>
					</xsl:choose>
				</Code>
				<Description><xsl:value-of select="$clinicianName"/></Description>
				
				<!-- Contact Name and Contact Information -->
				<xsl:apply-templates select="$personPath/hl7:name" mode="fn-T-pName-ContactName"/>
				<xsl:apply-templates select="$entityPath/hl7:addr" mode="fn-T-pName-address"/>
				<xsl:apply-templates select="$entityPath" mode="fn-T-pName-ContactInfo"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:name" mode="fn-T-pName-ContactName">
		<xsl:param name="emitElementName" select="'Name'"/>
		
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
			
			Field
			Path  : FromTime
			XPath : FromTime/text()
			Source: validTime/low/text()
			
			Field
			Path  : ToTime
			XPath : ToTime/text()
			Source: validTime/high/text()
		-->
		<xsl:if test="not(@nullFlavor)">
			<xsl:variable name="contactNamePrefix" select="normalize-space(hl7:prefix/text())"/>
			<xsl:variable name="contactNameGiven">
				<xsl:choose>
					<xsl:when test="string-length(normalize-space(hl7:given[1]/text()))">
						<xsl:value-of select="normalize-space(hl7:given[1]/text())"/>
					</xsl:when>
					<xsl:when test="string-length(normalize-space(text())) and contains(text(), ',')">
						<xsl:value-of select="normalize-space(substring-after(text(), ','))"/>
					</xsl:when>
					<xsl:when test="string-length(normalize-space(text())) and contains(text(), ' ')">
						<xsl:value-of select="normalize-space(substring-before(text(), ' '))"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="contactNameMiddle" select="normalize-space(hl7:given[2]/text())"/>
			<xsl:variable name="contactNameLast">
				<xsl:choose>
					<xsl:when test="string-length(normalize-space(hl7:family/text()))">
						<xsl:value-of select="normalize-space(hl7:family/text())"/>
					</xsl:when>
					<xsl:when test="string-length(normalize-space(text())) and contains(text(), ',')">
						<xsl:value-of select="normalize-space(substring-before(text(), ','))"/>
					</xsl:when>
					<xsl:when test="string-length(normalize-space(text())) and contains(text(), ' ')">
						<xsl:value-of select="normalize-space(substring-after(text(), ' '))"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="contactNameSuffix" select="normalize-space(hl7:suffix/text())"/>
			<xsl:variable name="nameQualifier">
				<xsl:choose>
					<xsl:when test="hl7:family/@qualifier[not(@nullFlavor)]">
						<xsl:value-of select="normalize-space(hl7:family/@qualifier)" />
					</xsl:when>
					<xsl:when test="hl7:given[1]/@qualifier[not(@nullFlavor)]">
						<xsl:value-of select="normalize-space(hl7:given[1]/@qualifier)" />
					</xsl:when>					
				</xsl:choose>			 
			</xsl:variable>

		  <xsl:element name="{$emitElementName}">
				<xsl:if test="string-length($contactNameLast)">
					<FamilyName><xsl:value-of select="$contactNameLast"/></FamilyName>
				</xsl:if>
				<xsl:if test="string-length($contactNamePrefix)">
					<NamePrefix><xsl:value-of select="$contactNamePrefix"/></NamePrefix>
				</xsl:if>
				<xsl:if test="string-length($contactNameGiven)">
					<GivenName><xsl:value-of select="$contactNameGiven"/></GivenName>
				</xsl:if>
				<xsl:if test="string-length($contactNameMiddle)">
					<MiddleName><xsl:value-of select="$contactNameMiddle"/></MiddleName>
				</xsl:if>
				<xsl:if test="string-length($contactNameSuffix)">
					<ProfessionalSuffix><xsl:value-of select="$contactNameSuffix"/></ProfessionalSuffix>
				</xsl:if>
				<xsl:choose>
				<xsl:when test="string-length($nameQualifier) and (translate($nameQualifier,$lowerCase,$upperCase) = 'BR')"><Type>Birth</Type></xsl:when>
				<xsl:when test="@use = 'L' or not(@use)"><Type>Legal</Type></xsl:when>
				<xsl:when test="@use = 'P'"><Type>Alias</Type></xsl:when>
				</xsl:choose>
				<xsl:apply-templates select="hl7:validTime/hl7:low" mode="fn-FromTime"/>
				<xsl:apply-templates select="hl7:validTime/hl7:high" mode="fn-ToTime"/>				
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:name" mode="fn-ContactNameString">
		<xsl:choose>
			<xsl:when test="string-length(normalize-space(text()))"><xsl:value-of select="normalize-space(text())"/></xsl:when>
			<xsl:when test="string-length(hl7:given[1]/text()) and string-length(hl7:family/text())">
				<xsl:value-of select="normalize-space(concat(hl7:family/text(), ', ', hl7:given[1]/text(), ' ', hl7:given[2]/text()))"/>
			</xsl:when>
			<xsl:when test="string-length(hl7:family/text())"><xsl:value-of select="hl7:family/text()"/></xsl:when>
			<xsl:when test="string-length(hl7:given[1]/text())"><xsl:value-of select="hl7:given[1]/text()"/></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:name" mode="fn-ContactNameLongString">
		<xsl:value-of select="normalize-space(concat(hl7:prefix, ' ', hl7:given[1], ' ', hl7:given[2], ' ', hl7:family, ' ', hl7:suffix))"/>
	</xsl:template>

	<xsl:template match="hl7:name" mode="fn-name-Split">
		<!-- match is encounter/entry/participant/partipantRole/playEntitity/name, which is a full name-->		

		<xsl:variable name="hasCommaInFullName" select="contains(text(),',')"/>	
		<xsl:variable name="contactLastName" select="normalize-space(substring-before(text(),','))"/>
		<xsl:variable name="contactFirstName" select="normalize-space(substring-after(text(),','))"/>
		<Name>
			<xsl:choose>
				<xsl:when test="$hasCommaInFullName">
					<xsl:if test="string-length($contactLastName)">
						<FamilyName><xsl:value-of select="$contactLastName"/></FamilyName>
					</xsl:if>
					<xsl:if test="string-length($contactFirstName)">
						<GivenName><xsl:value-of select="$contactFirstName"/></GivenName>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<FamilyName><xsl:value-of select="normalize-space(text())"/></FamilyName>
				</xsl:otherwise>
			</xsl:choose>
		</Name>
	</xsl:template>	
	
	<xsl:template match="*" mode="fn-W-Addresses">
	  <!-- Match is probably hl7:patientRole, but the template is generic -->
	  <!--
			Field: Patient Addresses
			Target: HS.SDA3.Patient Addresses.Address
			Target: /Container/Patient/Addresses/Address
			Source: /ClinicalDocument/recordTarget/patientRole/addr
			StructuredMappingRef: Address
		-->
		<xsl:if test="hl7:addr[not(@nullFlavor)]">
			<Addresses>
				<xsl:apply-templates select="hl7:addr" mode="fn-T-pName-address"/>
			</Addresses>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:addr" mode="fn-T-pName-address">
		<xsl:param name="emitElementName" select="'Address'"/>
		
		<!--
			StructuredMapping: Address
			
			Field
			Path  : Street
			XPath : Street/text()
			Source: streetAddressLine/text()
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
			<xsl:when test="string-length(normalize-space(text()))">
			  <xsl:element name="{$emitElementName}">
			    <Street><xsl:value-of select="normalize-space(text())"/></Street>
			  </xsl:element>
			</xsl:when>
			<xsl:otherwise>
			  <xsl:element name="{$emitElementName}">
					<xsl:if test="string-length(hl7:useablePeriod/hl7:low/@value)">
						<!--<FromTime><xsl:value-of select="isc:evaluate('xmltimestamp', hl7:useablePeriod/hl7:low/@value)"/></FromTime>-->
						<xsl:apply-templates select="hl7:useablePeriod/hl7:low/@value" mode="fn-E-paramName-timestamp">
							<xsl:with-param name="emitElementName" select="'FromTime'"/>
						</xsl:apply-templates>
					</xsl:if>
					<xsl:if test="string-length(hl7:useablePeriod/hl7:high/@value)">
						<!--<ToTime><xsl:value-of select="isc:evaluate('xmltimestamp', hl7:useablePeriod/hl7:high/@value)"/></ToTime>-->
						<xsl:apply-templates select="hl7:useablePeriod/hl7:high/@value" mode="fn-E-paramName-timestamp">
							<xsl:with-param name="emitElementName" select="'ToTime'"/>
						</xsl:apply-templates>
					</xsl:if>
					
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
	
	<xsl:template match="hl7:streetAddressLine">
		<xsl:if test="position()>1">; </xsl:if>
		<xsl:value-of select="normalize-space(text())"/>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-T-pName-ContactInfo">
	  <!-- Match could be hl7:assignedEntity, hl7:associatedEntity, hl7:representedOrganization, more... -->
	  <xsl:param name="emitElementName" select="'ContactInfo'"/>
		
		<!--
			StructuredMapping: ContactInfo
			
			Field
			Path  : HomePhoneNumber
			XPath : HomePhoneNumber/text()
			Source: telecom[@use='HP' or @use='HV' or not(@use)]
			
			Field
			Path  : WorkPhoneNumber
			XPath : WorkPhoneNumber/text()
			Source: telecom[@use='WP']
			
			Field
			Path  : MobilePhoneNumber
			XPath : MobilePhoneNumber/text()
			Source: telecom[@use='MC']
			
			Field
			Path  : EmailAddress
			XPath : EmailAddress/text()
			Source: telecom[contains(@value,'mailto:')]
		-->
		
		<xsl:if test="hl7:telecom[not(@nullFlavor)]">
			<xsl:variable name="homeTelecomUse">|H|HP|HV|PRN|</xsl:variable>
			<xsl:variable name="workTelecomUse">|W|WP|WPN|</xsl:variable>
			<xsl:variable name="mobileTelecomUse">|MC|</xsl:variable>
			<xsl:variable name="emailTelecomUse">|NET|</xsl:variable>
		  <xsl:element name="{$emitElementName}">
				<xsl:for-each select="hl7:telecom[not(@nullFlavor)]">
					<xsl:variable name="telecomValue">
						<xsl:choose>
							<xsl:when test="contains(@value, ':')"><xsl:value-of select="substring-after(@value, ':')"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="@value"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
			
					<xsl:choose>
						<xsl:when test="string-length(@use) > 0">
							<xsl:variable name="telecomUse" select="concat('|', @use, '|')"/>
							<xsl:choose>
						<xsl:when test="contains($homeTelecomUse, $telecomUse)"><HomePhoneNumber><xsl:value-of select="$telecomValue"/></HomePhoneNumber></xsl:when>
						<xsl:when test="contains($workTelecomUse, $telecomUse)"><WorkPhoneNumber><xsl:value-of select="$telecomValue"/></WorkPhoneNumber></xsl:when>
						<xsl:when test="contains($mobileTelecomUse, $telecomUse)"><MobilePhoneNumber><xsl:value-of select="$telecomValue"/></MobilePhoneNumber></xsl:when>
						<xsl:when test="contains($emailTelecomUse, $telecomUse)"><EmailAddress><xsl:value-of select="$telecomValue"/></EmailAddress></xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="contains(@value,'mailto:')"><EmailAddress><xsl:value-of select="$telecomValue"/></EmailAddress></xsl:when>
						<xsl:otherwise><HomePhoneNumber><xsl:value-of select="$telecomValue"/></HomePhoneNumber></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:representedOrganization | hl7:serviceProviderOrganization" mode="fn-OrganizationInformation">
		<xsl:variable name="wholeOrganizationRootPath" select="hl7:asOrganizationPartOf/hl7:wholeOrganization"/>
		
		<!-- Get community information -->
		<xsl:variable name="communityOID">
			<xsl:choose>
				<xsl:when test="$wholeOrganizationRootPath"><xsl:value-of select="$wholeOrganizationRootPath/hl7:id/@root"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="hl7:id/@root"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="communityCode">
			<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$communityOID"/></xsl:apply-templates>
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
		
		<xsl:variable name="idRootExt"><xsl:apply-templates select="hl7:id" mode="fn-representedOrganizationId"/></xsl:variable>
		
		<xsl:variable name="facilityOID" select="substring-before(substring-before($idRootExt,'/'),'|')"/>
		<xsl:variable name="facilityCodeFromIDs" select="substring-after(substring-before($idRootExt,'/'),'|')"/>
		<!--
			If FacilityCode found then use it for FacilityCode.
			If FacilityCode not found but OID found then get FacilityCode from OID.
			If FacilityCode not found from OID then use <name> for FacilityCode.
		-->
		<xsl:variable name="facilityCode">
			<xsl:choose>
				<xsl:when test="string-length($facilityCodeFromIDs)">
					<xsl:value-of select="$facilityCodeFromIDs"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="facilityCodeFromOID">
						<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$facilityOID"/></xsl:apply-templates>
					</xsl:variable>
					<xsl:choose>
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
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="facilityDescription"><xsl:if test="node()"><xsl:value-of select="hl7:name/text()"/></xsl:if></xsl:variable>
		
		<!-- Response format:  |F1:Facility OID|F2:Facility Code|F3:Facility Description|C1:Community OID|C2:Community Code|C3:Community Description| -->
		<xsl:value-of select="concat('|F1:', $facilityOID, '|F2:', $facilityCode, '|F3:', $facilityDescription, '|C1:', $communityOID, '|C2:', $communityCode, '|C3:', $communityDescription, '|')"/>
	</xsl:template>
	
	<xsl:template match="hl7:representedOrganization | hl7:serviceProviderOrganization" mode="fn-P-FacilityInformation">
		
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
		
		<xsl:variable name="idRootExt"><xsl:apply-templates select="hl7:id" mode="fn-representedOrganizationId"/></xsl:variable>
		<xsl:variable name="facilityOID" select="substring-before($idRootExt,'|')"/>
		<xsl:variable name="facilityCodeFromIDs" select="substring-after(substring-before($idRootExt,'/'),'|')"/>
		<!--
			If FacilityCode found then use it for FacilityCode.
			If FacilityCode not found but OID found then get FacilityCode from OID.
			If FacilityCode not found from OID then use <name> for FacilityCode.
		-->
		<xsl:variable name="facilityCode">
			<xsl:choose>
				<xsl:when test="string-length($facilityCodeFromIDs)">
					<xsl:value-of select="$facilityCodeFromIDs"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="facilityCodeFromOID">
						<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$facilityOID"/></xsl:apply-templates>
					</xsl:variable>
					<xsl:choose>
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
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="facilityDescription">
			<xsl:if test="node()"><xsl:value-of select="hl7:name/text()"/></xsl:if>
		</xsl:variable>
		<xsl:variable name="availabilityCode">
			<xsl:choose>
				<xsl:when test="string-length($facilityCode) > 0">
					<xsl:choose>
						<xsl:when test="string-length($facilityDescription) > 0"><xsl:text>3</xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>2</xsl:text></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length($facilityDescription) > 0"><xsl:text>1</xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Response format:  |F0:result flags|F1:Facility OID|F2:Facility Code|F3:Facility Description| -->
		<xsl:value-of select="concat('|F0:', $availabilityCode, '|F1:', $facilityOID, '|F2:', $facilityCode, '|F3:', $facilityDescription, '|')"/>
	</xsl:template>

	<xsl:template match="hl7:id" mode="fn-representedOrganizationId">
		<!--
		representedOrganizationId builds a string that indicates the
		OIDs and/or Facility Codes represented in the <id>'s collection
		under representedOrganization.  The format of the string is:
		OID1 | FacilityCode1 / ... / OIDn | FacilityCoden
	-->
		<xsl:variable name="rootIsGUID" select="string-length(@root)=36 and string-length(translate(@root,translate(@root,'-',''),''))=4 and not(string-length(translate(@root,'0123456789ABCDEFabcdef-','')))"/>
		<xsl:variable name="extensionIsNumber" select="string-length(translate(@extension,'0123456789.-',''))=0"/>
		<xsl:choose>
			<xsl:when test="@root and @extension and not($extensionIsNumber)">
				<xsl:value-of select="concat(@root, '|', @extension, '/')"/>
			</xsl:when>
			<xsl:when test="@root and not($rootIsGUID) and not(@extension)">
				<xsl:value-of select="concat(@root, '|/')"/>
			</xsl:when>
			<xsl:when test="$rootIsGUID=true() and @extension">
				<xsl:value-of select="concat('|', @extension, '/')"/>
			</xsl:when>
			<xsl:when test="@root and not($rootIsGUID) and $extensionIsNumber and not($repOrgconcatIdRootAndNumericExt='1')">
				<xsl:value-of select="concat(@root, '|', @extension, '/')"/>
			</xsl:when>
			<xsl:when test="@root and not($rootIsGUID) and $extensionIsNumber and $repOrgconcatIdRootAndNumericExt='1'">
				<xsl:value-of select="concat(@root, '.', @extension, '|', '/')"/>
			</xsl:when>
			<xsl:when test="@nullFlavor"/>
			<xsl:when test="$rootIsGUID=true() and not(@extension)"/>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:healthCareFacility" mode="fn-LocationInformation">
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
		<xsl:variable name="locationCode">
			<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="$locationOID"/></xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="locationDescription">
			<xsl:if test="node()"><xsl:value-of select="hl7:name/text()"/></xsl:if>
		</xsl:variable>
		<xsl:variable name="availabilityCode">
			<xsl:choose>
				<xsl:when test="string-length($locationCode) > 0">
					<xsl:choose>
						<xsl:when test="string-length($locationDescription) > 0"><xsl:text>3</xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>2</xsl:text></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length($locationDescription) > 0"><xsl:text>1</xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Response format:  |L0:result flags|L1:Location OID|L2:Location Code|L3:Location Description|element local name -->
		<xsl:value-of select="concat('|L0:', $availabilityCode, '|L1:', $locationOID, '|L2:', $locationCode, '|L3:', $locationDescription, '|', local-name())"/>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-ExternalId">
	<!--
		ExternalId overrides SDA ExternalId with <id> values from
		the source CDA, if enabled by $sdaOverrideExternalId = 1,
		which is configurable in ImportProfile.xsl.
	-->
		<!--
			StructuredMapping: ExternalId
			
			Field
			Path  : CurrentProperty
			XPath : ./
			Source: ./
			Note  : Import of CDA id to SDA ExternalId is enabled by setting
					ImportProfile.xsl configuration item
					$generalImportConfiguration/sdaActionCodes/overrideExternalId
					to 1.  If a CDA id with @assigningAuthorityName containing
					'ExternalId' is found then that id is used for import, regardless
					of position.  Otherwise id[1] is used.  If both @root and
					@extension are present on the id then the code (derived from the
					OID Registry) for @root is concatenated with @extension, delimited
					by vertical bar to form the ExternalId.  Otherwise just the raw
					@root value is used for ExternalId.
		-->
		<xsl:if test="($sdaOverrideExternalId = 1)">
			<xsl:apply-templates select="." mode="fn-ExternalId-concatenated" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-ExternalId-concatenated">
		<!--
			StructuredMapping: ExternalId
			
			Field
			Path  : CurrentProperty
			XPath : ./
			Source: ./
			Note  : If a CDA id with @assigningAuthorityName containing
					'ExternalId' is found then that id is used for import, regardless
					of position.  Otherwise id[1] is used.  If both @root and
					@extension are present on the id then the code (derived from the
					OID Registry) for @root is concatenated with @extension, delimited
					by vertical bar to form the ExternalId.  Otherwise just the raw
					@root value is used for ExternalId.
		-->
		<xsl:choose>
			<xsl:when test="hl7:id[contains(@assigningAuthorityName, 'ExternalId') and not(@nullFlavor)]">
				<ExternalId><xsl:apply-templates select="hl7:id[contains(@assigningAuthorityName, 'ExternalId')]" mode="fn-Id-External"/></ExternalId>
			</xsl:when>
			<xsl:when test="hl7:id[(position() = 1) and not(@nullFlavor)]">
				<ExternalId><xsl:apply-templates select="hl7:id[1]" mode="fn-Id-External"/></ExternalId>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:id" mode="fn-W-pName-ExternalId-reference">
		<!--
			StructuredMapping: ExternalId
			
			Field
			Path  : hl7:id
			XPath : ./
			Source: ./
			Note  : This template will produce the specified tag from an id. It is used to make references to external ids.
		-->
		<xsl:param name="hsElementName"/><!-- Name of outer element to produce -->
	  <xsl:element name="{$hsElementName}">
			<xsl:apply-templates select="." mode="fn-Id-External" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="*" mode="fn-PlacerId">
	  <!-- Match could be hl7:organizer, hl7:observation, hl7:encounter, hl7:substanceAdministration -->
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
			<xsl:when test="hl7:id[contains(@assigningAuthorityName, '-PlacerId') and not(@nullFlavor)]">
				<PlacerId><xsl:apply-templates select="hl7:id[contains(@assigningAuthorityName, '-PlacerId')]" mode="fn-S-Id"/></PlacerId>
			</xsl:when>
			<xsl:when test="hl7:id[(position() = 2) and not(@nullFlavor)]">
				<PlacerId><xsl:apply-templates select="hl7:id[2]" mode="fn-S-Id"/></PlacerId>
			</xsl:when>
			<xsl:otherwise>
				<PlacerId><xsl:value-of select="isc:evaluate('createGUID')"/></PlacerId>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-FillerId">
	  <!-- Match could be hl7:organizer, hl7:observation, hl7:encounter, hl7:substanceAdministration -->
	  <xsl:param name="makeDefault" select="'1'"/>
		
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
			<xsl:when test="hl7:id[contains(@assigningAuthorityName, '-FillerId') and not(@nullFlavor)]">
				<FillerId><xsl:apply-templates select="hl7:id[contains(@assigningAuthorityName, '-FillerId')]" mode="fn-S-Id"/></FillerId>
			</xsl:when>
			<xsl:when test="hl7:id[(position() = 3) and not(@nullFlavor)]">
				<FillerId><xsl:apply-templates select="hl7:id[3]" mode="fn-S-Id"/></FillerId>
			</xsl:when>
			<xsl:when test="$makeDefault='1'">
				<FillerId><xsl:value-of select="isc:evaluate('createGUID')"/></FillerId>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:encounter" mode="fn-PlacerApptId">
		<xsl:choose>
			<xsl:when test="hl7:id[contains(@assigningAuthorityName, '-PlacerApptId') and not(@nullFlavor)]">
				<PlacerApptId><xsl:apply-templates select="hl7:id[contains(@assigningAuthorityName, '-PlacerApptId')]" mode="fn-S-Id"/></PlacerApptId>
			</xsl:when>
			<xsl:when test="hl7:id[(position() = 2) and not(@nullFlavor)]">
				<PlacerApptId><xsl:apply-templates select="hl7:id[2]" mode="fn-S-Id"/></PlacerApptId>
			</xsl:when>
			<xsl:otherwise>
				<PlacerApptId><xsl:value-of select="isc:evaluate('createGUID')"/></PlacerApptId>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:encounter" mode="fn-FillerApptId">
		<xsl:param name="makeDefault" select="'1'"/>
		
		<xsl:choose>
			<xsl:when test="hl7:id[contains(@assigningAuthorityName, '-FillerApptId') and not(@nullFlavor)]">
				<FillerApptId><xsl:apply-templates select="hl7:id[contains(@assigningAuthorityName, '-FillerApptId')]" mode="fn-S-Id"/></FillerApptId>
			</xsl:when>
			<xsl:when test="hl7:id[(position() = 3) and not(@nullFlavor)]">
				<FillerApptId><xsl:apply-templates select="hl7:id[3]" mode="fn-S-Id"/></FillerApptId>
			</xsl:when>
			<xsl:when test="$makeDefault='1'">
				<FillerApptId><xsl:value-of select="isc:evaluate('createGUID')"/></FillerApptId>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:id" mode="fn-S-Id">
		<xsl:choose>
			<xsl:when test="@extension"><xsl:value-of select="@extension"/></xsl:when>
			<xsl:when test="@root"><xsl:value-of select="@root"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="isc:evaluate('createGUID')"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:id" mode="fn-Id-External">
		<xsl:variable name="rootCode">
			<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="@root"/></xsl:apply-templates>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@extension"><xsl:value-of select="concat($rootCode, '|', @extension)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@root"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-S-formatEncounterId">
	  <!-- Match could be hl7:encounter, hl7:encompassingEncounter, or whatever is passed into
		   sE-Encounters, eED-EncounterDiagnosis-OverriddenEncounter, or eHC-HealthConcernEntry -->
	  <xsl:variable name="encounterNumber">
			<xsl:choose>
				<xsl:when test="string-length(hl7:id/@extension)"><xsl:value-of select="hl7:id/@extension"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="hl7:id/@root"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="encounterNumberClean" select="translate($encounterNumber,';:% &#34;','_____')"/>
		<xsl:choose>
			<xsl:when test="starts-with(translate($encounterNumber,$upperCase,$lowerCase),'urn:uuid:')">
				<xsl:value-of select="substring($encounterNumberClean,10)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$encounterNumberClean"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-EncounterID-Entry">
	  <!-- Match could be hl7:act, hl7:entry, hl7:observation, hl7:procedure, hl7:substanceAdministration,
	     or whatever matched sDR-ResultsSection -->
	  <!--
			Assume that if .//hl7:encounter/hl7:id/@extension or @root
			has a value, then it is valid, meaning it is the number of
			an encounter from the Encounters section, or is the
			encompassingEncounter number.
		-->
		<xsl:variable name="encounterNumber">
			<xsl:choose>
				<xsl:when test="string-length(.//hl7:encounter/hl7:id/@extension)">
					<xsl:value-of select=".//hl7:encounter/hl7:id/@extension"/>
				</xsl:when>
				<xsl:when test="string-length(.//hl7:encounter/hl7:id/@root)">
					<xsl:value-of select=".//hl7:encounter/hl7:id/@root"/>
				</xsl:when>
				<xsl:when test="string-length($encompassingEncounterID)"><!-- a global variable -->
					<xsl:value-of select="$encompassingEncounterID"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="translate(substring($encounterNumber,1,9),$upperCase,$lowerCase) = 'urn:uuid:'">
				<xsl:value-of select="translate(substring($encounterNumber,10),';:% &#34;','_____')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate($encounterNumber,';:% &#34;','_____')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-code-for-oid">
		<xsl:param name="OID"/>
		<xsl:param name="default" select="$OID"/>
	<!--
		code-for-oid returns the IdentityCode for a specified OID.
		If no IdentityCode is found, then $default is returned.
	-->	
		<xsl:value-of select="isc:evaluate('getCodeForOID',$OID,'',$default)"/>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-oid-for-code">
		<xsl:param name="Code"/>
		<xsl:param name="default" select="$Code"/>
	<!--
		oid-for-code returns the OID for a specified IdentityCode.
		If no OID is found, then $default is returned.
	-->
		<xsl:value-of select="isc:evaluate('getOIDForCode',$Code,'',$default)"/>
	</xsl:template>
	
	<xsl:template match="hl7:reference" mode="fn-E-NVPair-Narrative">
		<xsl:param name="nvPairName"/>
		<xsl:variable name="referenceLink" select="substring-after(@value, '#')"/>
		<xsl:variable name="referenceValue">
			<xsl:if test="string-length($referenceLink)">
				<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$referenceValue">
			<NVPair>
				<Name><xsl:value-of select="$nvPairName" /></Name>
				<Value><xsl:value-of select="$referenceValue" /></Value>
			</NVPair>
		</xsl:if>
	</xsl:template>
	
	<!-- ========================= The next group of templates handle text blocks ================================= -->
	
	<xsl:template match="*" mode="fn-TextValue">
	  <!-- Match could be hl7:text, hl7:originalText, hl7:code, whatever is passed to eFS-FunctionalStatus or eM-PatientInstructions -->
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
				<xsl:apply-templates select="key('narrativeKey', $referenceLink)" mode="fn-importNarrative">
					<xsl:with-param name="narrativeImportMode" select="$narrativeImportMode"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string-length(translate(text(),'&#10;',''))">
				<xsl:value-of select="text()"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="fn-importNarrative">
	  <!-- Match could be hl7:text or anything having an ID attribute -->
	  <xsl:param name="narrativeImportMode" select="$narrativeImportModeGeneral"/>
	<!--
		importNarrative builds a string of text from the HTML
		found in a CDA section narrative.
	-->
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
			<xsl:when test="$narrativeImportMode='1'"><xsl:text>&#10;</xsl:text></xsl:when>
			<xsl:when test="$narrativeImportMode='2'"><xsl:text>&#13;</xsl:text></xsl:when>
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

	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="ActionCode">
		<xsl:param name="informationType"/><!-- Controls branching;
		     also used to track whether the action has been performed for this encounter;
		     also becomes the name of the element wrapped around the result in some scenarios
		     (other scenarios produce no output or just an unwrapped ActionCode element) -->
		<xsl:param name="actionScope"/><!-- String that becomes the content of ActionScope element in some scenarios -->
		<xsl:param name="encounterNumber"/><!-- This is often derived from fn-EncounterID-Entry mode -->
		
		<xsl:if test="($sdaActionCodesEnabled = 1) and string-length($documentActionCode) and string-length($informationType)">
			<xsl:variable name="hasEncounterNumber" select="string-length($encounterNumber) > 0"/>
			<xsl:variable name="encounterNumberSubscript">
				<xsl:choose>
					<xsl:when test="$hasEncounterNumber"><xsl:value-of select="$encounterNumber"/></xsl:when>
					<xsl:otherwise>(blank)</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="($documentActionCode = 'APND')">
					<xsl:choose>
						<xsl:when test="$informationType = 'Patient'"/>
						<xsl:when test="$informationType = 'Encounter'"><ActionCode>A</ActionCode></xsl:when>
						<xsl:when test="not(isc:evaluate('varGet','ActionCodes',$informationType,$encounterNumberSubscript)='1')">
							<xsl:element name="{$informationType}">
								<ActionCode>A</ActionCode>
								<xsl:if test="string-length($actionScope)"><ActionScope><xsl:value-of select="$actionScope"/></ActionScope></xsl:if>
								<xsl:if test="$hasEncounterNumber"><EncounterNumber><xsl:value-of select="$encounterNumber"/></EncounterNumber></xsl:if>
							</xsl:element>
							<xsl:if test="isc:evaluate('varSet','ActionCodes',$informationType,$encounterNumberSubscript,'1')"/>
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
								<xsl:if test="$hasEncounterNumber"><EncounterNumber><xsl:value-of select="$encounterNumber"/></EncounterNumber></xsl:if>
							</xsl:element>
							<xsl:if test="isc:evaluate('varSet','ActionCodes',$informationType,$encounterNumberSubscript,'1')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="fn-S-timestamp">
		<xsl:param name="inputString"/>
		<!-- Call isc:evaluate('xmltimestamp',$inputString) 
		     Input has the format YYYYMMDDHHNNSSpZZZZ, where all uppercase letters stand for digits and 
		     p stands for either a plus sign or minus sign. Valid input could be as short as YYYYMM.
		     Zeroes are supplied for time-of-day if some or all of the time fields are missing. -->
		<xsl:value-of select="isc:evaluate('xmltimestamp',$inputString)"/>
	</xsl:template>
  
  <xsl:template match="hl7:ClinicalDocument" mode="fn-HeaderInfo-AddlDocInfo">
    <!-- HeaderInfo is specific to importing the CDA header XML data into AdditionalDocumentInfo. -->
    <HeaderInfo>
      <xsl:apply-templates select="./*[contains($documentHeaderItemsList,concat('|',name(),'|'))]" mode="fn-E-Element-AddlDocInfo"/>
    </HeaderInfo>
  </xsl:template>
  
  <xsl:template match="*" mode="fn-E-Element-AddlDocInfo">
    <Element>
      <Name><xsl:value-of select="name()"/></Name>
      <xsl:if test="string-length(translate(text(),'&#9;&#10;&#13;&#32;',''))">
        <Value><xsl:value-of select="text()"/></Value>
      </xsl:if>
      <xsl:if test="attribute::*">
        <Attributes>
          <xsl:for-each select="attribute::*">
            <Attribute>
              <Name><xsl:value-of select="name()"/></Name>
              <Value><xsl:value-of select="."/></Value>
            </Attribute>
          </xsl:for-each>
        </Attributes>
      </xsl:if>
      <xsl:if test="child::*">
        <Elements>
          <xsl:for-each select="child::*">
            <xsl:apply-templates select="." mode="fn-E-Element-AddlDocInfo"/>
          </xsl:for-each>
        </Elements>
      </xsl:if>
    </Element>
  </xsl:template>
  
</xsl:stylesheet>
