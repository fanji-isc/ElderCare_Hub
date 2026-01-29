<!-- C-CDA narrative import as plain text

	USAGE
	* <xsl:apply-templates mode="narrative-import" select="hl7:text"/>

			Converts an hl7:entry/hl7:text into structured plain-text if it contains a 
			hl7:reference into the section narrative otherwise just outputs the text().

			By default the NoteText property is used but can be changed using the emitText
			parameter with the name of a different property to populate.
			
			The FormatCode.Code property is also populated by default to assist rendering
			the fixed width content. 'NARRATIVE' indicates the content is fixed and can
			be exported back out as CCDA StructDoc while 'FIXED' the content is fixed but
			not structured so can only be exported as plain text. This can be disabled
			by sending the emitFormat parameter to the null string. The content is fixed
			if it does not contain descendant elements AND has a run of 3 spaces.

	* <xsl:apply-templates mode="narrative-import-sections" select="$input"/>

			Import all section narratives configured in the ImportProfile as an SDA3 Document per section

	* <xsl:apply-templates mode="narrative-import-section" select="hl7:section"/>

			Import single section narrative as an SDA3 Document (ignores ImportProfile)

	MAPPING
		CCDA         Plain Text
		text()       LF preserved; tabs/nbsp converted to space; CR dropped; normalized-space
		br           line-feed
		caption      as text() with inline nodes resolved; forced to single line reguardless of length
		content      as text() with inline nodes resolved
		footnote     mixed block content
		footnoteRef  [^#] where # is the first position the reference is used
		item         mixed block content
		linkHtml     as content; fragment hrefs dropped, external hrefs preserved
		list         mixed block content (only caption and item allowed); items indented by 2 spaces
		paragraph    mixed inline content plus br; if captioned will indent text by 2 spaces
		sub          preserved as is but cannot be exported (H<sub>2</sub>O becomes H2O) 
		sup          ^* where * is the inline content limited to chars `0123456789.eE+-`
		table        rendered as a markdown grid-table
		tr           
		td / th      mixed block content with single space padding on both ends
		tbody        rows delimited by - separator
		tfoot        rows delimited by - separator; start with = separator
		thead        rows delimited by - separator; end with = separator
		@IDREF       used for resolving footnotes; replaced with numerical position
		@ID          used for resolveing footnotes replaced with numerical position
		@href        used for external links

	NOT SUPPORTED
		- col, colgroup: these are styling and thus not releveant for plain-text
		- tableCaption, tableFootnote: these are defined in the schema but not used
		- renderMultiMedia: only briefly mentioned in the spec, not present in either
			the Implementation Guide, Companion Guide, or C-CDA Samples repository
		- Any attribute or node not listed above is ignored

	CLINICAL VIEWER
		To faithfully render structured plain-text in the CV2 a small customization is
		needed to use a monospaced font and allow horizontal-scroll without wrapping.
		Here is an example (replace 'HS' with your CV site code)

			Class Custom.HS.JS.MRNursingNotes.Edit Extends websys.AbstractJavaScript
			{
			ClientMethod JSContent() [ Language = javascript ]
			{
			function notesBodyLoadHandler() {
					var patientId = document.getElementById("PatientID").value;
					var viewerId = document.getElementById("ID").value;
					var format = tkMakeServerCall("Custom.HS.JS.MRNursingNotes.Edit","GetFormat",patientId,viewerId);   
					if ((format == "FIXED")||(format == "NARRATIVE")) {
							setTimeout(function() {
									var note = window.document.querySelector("#MRNursingNotes_Edit_0-item-NOTNotes")
									if (note) {
											note.style.fontFamily = "'Courier New', monospace";
											note.style.whiteSpace = "pre";
											note.style.overflowX = "auto";
											note.style.display = "block";
											note.style.lineHeight = "normal";
											note.style.pointerEvents = "auto";
									}
							}, 1000);
					}
			}
			websys_addListener("load","onload",notesBodyLoadHandler);
			}

			ClassMethod GetFormat(patientId, viewerId) As %String
			{
					If patientId '= "", viewerId '= "" {
							Set id = ##class(web.SDA3.Loader).GetStreamletId(, patientId, "DOC", viewerId)
							If id '= "" {
									Set doc = ##class(HS.SDA3.Streamlet.Document).%OpenId(id)
									If $IsObject(doc) {
											Do doc.LoadSDA()
											Return doc.SDA.FormatCode.Code
									}
							}
					}
					Return ""
			}
			}

	NOTES
		- block elements (paragraph, list, table) always followed by a blank line
		- works best with minified XML input but should handle most pretty-printed XML
		- input with over 8000 block elements and/or 1000 lines in a single block will 
			have a noticiable performance imact. 
		- input with over 32000 blocks elements or 10000 lines in a single block will 
			fail and log an error. 
		- expect CDA import to take 2x as long if every section narrative is imported, 
		  larger documents will add more overhead (e.g. 2MB doc adds 1.5 seconds)
		- long lines are wrapped at the block level, not the document level 

	REFERENCES
		cda_r2_normativewebedition2010/infrastructure/cda/cda.htm#CDA_Section_Narrative_Block
		cda_r2_normativewebedition2010/processable/coreschemas/NarrativeBlock.xsd
		https://www.hl7.org/ccdasearch/pdfs/Companion_Guide.pdf
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:hl7="urn:hl7-org:v3" 
	xmlns:isc="http://extension-functions.intersystems.com"
	xmlns:set="http://exslt.org/sets"
	xmlns:exsl="http://exslt.org/common"
	xmlns:math="http://exslt.org/math"
	exclude-result-prefixes="hl7 isc set exsl math">

  <!-- footnoteRef could point to anywhere in hl7:ClinicalDocument -->
	<xsl:key name="narrative-footnoteKey" match="hl7:footnote" use="@ID"/>
	<xsl:key name="narrative-footnoteKey" match="/hl7:ClinicalDocument" use="'NEVER_MATCH_THIS!'"/>

	<!-- used to construct indentation -->
	<xsl:variable name="narrative-v-spaces" select="'                                                                                                                                                                                                                                                                                                                                                                                                                '"/>

	<!-- 
		PUBLIC API
	-->

	<!-- populate NoteText and FormatCode for a given hl7:entry/hl7:text; see header comment for detail -->
	<xsl:template mode="narrative-import" match="hl7:text">
		<!-- by default emit to SDA3 Document properties -->
		<xsl:param name="emitText" select="'NoteText'"/>
		<xsl:param name="emitFormat" select="'FormatCode'"/>

		<xsl:variable name="referenceLink" select="substring-after(hl7:reference/@value, '#')"/>
		<xsl:variable name="referenceValue">
			<xsl:if test="string-length($referenceLink)">
				<xsl:value-of select="key('narrativeKey', $referenceLink)"/>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<!-- use structured import when there is a valid hl7:reference -->
			<xsl:when test="string-length(translate($referenceValue,'&#10;',''))">
				<xsl:apply-templates mode="narrative-import-main" select="key('narrativeKey', $referenceLink)">
					<xsl:with-param name="emitText" select="$emitText"/>
					<xsl:with-param name="emitFormat" select="$emitFormat"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- fallback to legacy behavior when narrative reference isn't found -->
			<xsl:when test="string-length(normalize-space(text()))">
				<xsl:element name="{$emitText}">
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- create SDA3 Document for each configured section narrative -->
	<xsl:template mode="narrative-import-sections" match="hl7:ClinicalDocument">
		<Documents>
			<xsl:for-each select="hl7:component/hl7:structuredBody/hl7:component/hl7:section">
				<xsl:variable name="check">
					<xsl:apply-templates mode="narrative-import-section-check" select="."/>
				</xsl:variable>
				<xsl:variable name="conf" select="exsl:node-set($check)"/>
				<xsl:if test="count($conf/node()) > 0">
					<xsl:apply-templates mode="narrative-import-section" select=".">
						<xsl:with-param name="conf" select="$conf"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
		</Documents>
	</xsl:template>

	<!-- create SDA3 Document for the given section -->
	<xsl:template mode="narrative-import-section" match="hl7:section">
		<xsl:param name="conf"/>
		<Document>
			<xsl:apply-templates select="." mode="narrative-import-section-EncounterNumber"/>
			<xsl:apply-templates select="." mode="narrative-import-section-DocumentNumber"/>
			<xsl:apply-templates select="." mode="narrative-import-section-DocumentType">
				<xsl:with-param name="defaultCode" select="$conf/code/@code"/>
				<xsl:with-param name="defaultName" select="$conf/code/@displayName"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="." mode="narrative-import-section-Category"/>
			<xsl:apply-templates select="." mode="narrative-import-section-EnteredBy"/>
			<xsl:apply-templates select="." mode="narrative-import-section-EnteredAt"/>
			<xsl:apply-templates select="." mode="narrative-import-section-EnteredOn"/>
			<xsl:apply-templates select="." mode="narrative-import-section-DocumentTime"/>
			<xsl:apply-templates select="." mode="narrative-import-section-DocumentName"/>
			<xsl:apply-templates select="." mode="narrative-import-section-FileType"/>
			<xsl:apply-templates select="." mode="narrative-import-section-NoteText-and-Format"/>
		</Document>
	</xsl:template>

	<!-- 
		SECTION TEMPLATES
	-->

	<!-- returns config result-tree-fragment if a section narrative is eligible for import -->
	<xsl:template mode="narrative-import-section-check" match="hl7:section">
		<xsl:variable name="root" select="hl7:templateId/@root"/>
		<xsl:variable name="conf" select="$narrativeImportStructured/section[templateId/@root = $root]/node()"/>

		<xsl:choose>
			<xsl:when test="count($conf) = 0"/>  <!-- not configured for import -->
			<xsl:when test="@nullFlavor"/>       <!-- explicitly marked as no-data -->
			<xsl:otherwise>
				<!-- get the full normalized narrative text -->
				<xsl:variable name="text">
					<xsl:apply-templates mode="fn-importNarrative" select="hl7:text"/>
				</xsl:variable>
				<xsl:variable name="norm" select="normalize-space($text)"/>

				<!-- check for exclusions -->
				<xsl:variable name="exclude">
					<xsl:for-each select="$conf/exclude | $narrativeImportStructured/exclude">
						<xsl:choose>
							<xsl:when test="@mode = 'full'">
								<xsl:if test="$norm = text()">1</xsl:if>
							</xsl:when>
							<xsl:when test="contains($norm, text())">1</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>

				<!-- return the config -->
				<xsl:if test="not(string-length($exclude))">
					<xsl:copy-of select="$conf"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-EncounterNumber">
		<!-- Only link encounter for episodic documents -->
		<xsl:if test="string-length($encompassingEncounterID)">
			<EncounterNumber><xsl:value-of select="$encompassingEncounterID"/></EncounterNumber>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-DocumentNumber">
		<!-- use hl7:section/hl7:id if present, otherwise use hl7:ClinicalDocument/hl7:id with hl7:section/hl7:templateId/@root -->
		<xsl:choose>
			<xsl:when test="hl7:id">
				<xsl:apply-templates select="hl7:id" mode="fn-W-pName-ExternalId-reference">
					<xsl:with-param name="hsElementName" select="'DocumentNumber'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<DocumentNumber>
					<xsl:apply-templates select="$input/hl7:id" mode="fn-Id-External" />
					<xsl:value-of select="concat('|',hl7:templateId/@root)"/>
				</DocumentNumber>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-DocumentType">
		<!-- hl7:section/hl7:code only used when both @code and @displayName present -->
		<xsl:param name="defaultCode"/>
		<xsl:param name="defaultName"/>
		<xsl:param name="defaultSystem" select="'LN'"/>
		<xsl:choose>
			<xsl:when test="not(@nullFlavor) and string-length(hl7:code/@code) and string-length(hl7:code/@dispayName)">
				<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'DocumentType'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="string-length($defaultCode) and string-length($defaultName) and string-length($defaultSystem)">
				<DocumentType>
					<Code><xsl:value-of select="$defaultCode"/></Code>
					<Description><xsl:value-of select="$defaultName"/></Description>
					<SDACodingStandard><xsl:value-of select="$defaultSystem"/></SDACodingStandard>
				</DocumentType>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-Category">
		<!-- hardcoded and needed for CCDAv21 export -->
		<Category>
			<Code>SectionNarrative</Code>
			<Description>CCDAv21 Section Narrative</Description>
		</Category>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-EnteredBy">
		<!-- uses section or document author -->
		<xsl:apply-templates select="." mode="fn-EnteredBy"/>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-EnteredAt">
		<!-- uses section or document author -->
		<xsl:apply-templates select="." mode="fn-EnteredAt"/>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-EnteredOn">
		<!-- use document effectiveTime -->
		<xsl:apply-templates select="$input/hl7:effectiveTime" mode="fn-EnteredOn"/>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-DocumentTime">
		<!-- uses section or document author time -->
		<xsl:choose>
			<xsl:when test="hl7:author/hl7:time/@value">
				<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-I-timestamp">
					<xsl:with-param name="emitElementName" select="'DocumentTime'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$input/hl7:author/hl7:time" mode="fn-I-timestamp">
					<xsl:with-param name="emitElementName" select="'DocumentTime'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-DocumentName">
		<!-- allows optional override for consistent grouping in the clinical viewer -->
		<xsl:param name="override"/>
		<DocumentName>
			<xsl:choose>
				<xsl:when test="string-length($override)"><xsl:value-of select="$override"/></xsl:when>
				<xsl:when test="string-length(hl7:title/text())"><xsl:value-of select="hl7:title/text()"/></xsl:when>
				<xsl:when test="string-length(hl7:code/@displayName)"><xsl:value-of select="hl7:code/@displayName"/></xsl:when>
				<xsl:otherwise>Narrative</xsl:otherwise>
			</xsl:choose>
		</DocumentName>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-FileType">
		<!-- hardcoded since the output is put into NoteText -->
		<FileType>TXT</FileType>
	</xsl:template>

	<xsl:template match="hl7:section" mode="narrative-import-section-NoteText-and-Format">
		<!-- NoteText from hl7:text with FormatCode hardcoded to either FIXED or NARRATIVE -->
		<xsl:apply-templates mode="narrative-import-main" select="hl7:text"/>
	</xsl:template>

	<!-- 
		NARRATIVE TEMPLATES
	-->

	<!-- by default fallback to traditional narrative import for unsupported hl7:reference targets -->
	<xsl:template mode="narrative-import-main" match="*">
		<xsl:apply-templates mode="fn-TextValue" select="."/>
	</xsl:template>

	<!-- import supported elements as structured plain text -->
	<xsl:template mode="narrative-import-main" match="hl7:text | hl7:content | hl7:item | hl7:td | hl7:paragraph | hl7:table | hl7:list">
		<xsl:param name="emitText" select="'NoteText'"/>
		<xsl:param name="emitFormat" select="'FormatCode'"/>

		<!-- $footnoteRefs is a list of footnote references in the order they appear under the matched node -->
		<xsl:variable name="footnoteRefs" select="set:distinct(.//hl7:footnoteRef/@IDREF)"/>

		<!-- pass1 creates a more linear node-tree with resolved inline elements -->
		<xsl:variable name="pass1">
			<xsl:choose>
				
				<!-- retain block level nodes-->
				<xsl:when test="contains('paragraph table list', local-name(.))">
					<xsl:apply-templates mode="narrative-import-pass1" select=".">
						<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
					</xsl:apply-templates>
				</xsl:when>

				<!-- but only process children for intermediate nodes (e.g. td, item)-->
				<xsl:otherwise>
					<xsl:apply-templates mode="narrative-import-pass1" select="node()">
						<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

			<!-- put footnotes at the end  -->
			<xsl:if test="count($footnoteRefs) > 0">
				<xsl:for-each select="$footnoteRefs">
					<footnote pos="{position()}">
						<xsl:apply-templates mode="narrative-import-pass1" select="key('narrative-footnoteKey',substring-after(.,'#'))/node()">
							<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
						</xsl:apply-templates>
					</footnote>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<!-- content isn't structured but if it contains a run of 3 spaces consider it fixed width -->
			<xsl:when test="count(.//*[not(local-name(.)='br')]) = 0">
				<xsl:element name="{$emitText}">
					<xsl:value-of select="$pass1"/>
				</xsl:element>
				<xsl:if test="string-length($emitFormat) and contains($pass1, '   ')">
					<xsl:element name="{$emitFormat}">
						<Code>FIXED</Code>
						<Description>Fixed width text</Description>
					</xsl:element>
				</xsl:if>
			</xsl:when>

			<!-- otherwise pass2 processes the linear tree with indentation and formatting -->
			<xsl:when test="string-length($pass1) > 0">
				<xsl:element name="{$emitText}">
					<xsl:apply-templates mode="narrative-import-pass2" select="exsl:node-set($pass1)"/>
				</xsl:element>
				<xsl:if test="string-length($emitFormat)">
					<xsl:element name="{$emitFormat}">
						<Code>NARRATIVE</Code>
						<Description>Formatted C-CDA narrative text</Description>
					</xsl:element>
				</xsl:if>
			</xsl:when>

		</xsl:choose>
	</xsl:template>

	<!-- *********************************************************************** 
		PASS 1: preprocess into a linear node-tree with inline elements resolved
		After this pass the tree will only contain text(), paragraph, list/item, and table/thead/tbody/tfoot/tr/th/td nodes
	*********************************************************************** -->

	<!--drop all attributes -->
	<xsl:template mode="narrative-import-pass1" match="@*"/>

	<!-- cleanup whitespace in text() nodes including whitespace due to pretty-printing -->
	<xsl:template mode="narrative-import-pass1" match="text()">
		<!-- replace tab and nbsp with space; drop carriage return -->
		<xsl:variable name="text" select="translate(.,'&#9;&#xa0;&#13;','  ')"/>

		<!-- remove leading whitespace due to pretty-printing: starts w/LF followed by whitespace -->
		<xsl:variable name="left">
			<xsl:choose>
				<xsl:when test="substring($text,1,1)='&#10;'">
					<xsl:if test="string-length(normalize-space($text))">
						<xsl:call-template name="narrative-ltrim">
							<xsl:with-param name="text" select="$text"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- remove trailing whitespace due to pretty-printing: ends w/LF followed by whitespace -->
		<xsl:variable name="right">
			<xsl:call-template name="narrative-rtrim">
				<xsl:with-param name="text" select="$left"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($left) = 0"/>
			<xsl:when test="$left = $right">
				<xsl:value-of select="$right"/>
			</xsl:when>
			<xsl:when test="substring($left, string-length($right) + 1, 1) = '&#10;'">
				<xsl:value-of select="$right"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$left"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- drop all unsupported elements -->
	<xsl:template mode="narrative-import-pass1" match="*"/>

	<!-- sub: text preserved but cannot be exported back to CCDA StrucDoc 
		input:  H<sub>2</sub>O
		output: H2O
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:sub">
		<xsl:apply-templates mode="narrative-import-pass1" select="text()"/>
	</xsl:template>

	<!-- sup: text prefixed with caret
		input:  N<sup>2</sup>
		output: N^2
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:sup">
		<xsl:text>^</xsl:text>
		<xsl:apply-templates mode="narrative-import-pass1" select="text()"/>
	</xsl:template>

	<!-- content: text resolved (only inline; footnotes handled separately)
		input:  <content>hello world</content>
		output: hello world
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:content">
		<xsl:param name="footnoteRefs"/>
		
		<!-- always prefix with a space to account for pretty-printed consecutive content elements:
				<content>hello</content>
				<content>world</content>
			otherwise the pretty-printed whitespace node would be deleted and result in "helloworld"

			The normalize-space() in pass2 will take care of situations where the input is properly spaced
				<content>hello</content> <content>world</content>
			pass1: hello  world
			pass2: hello world
		-->
		<xsl:text> </xsl:text> 
		<xsl:apply-templates mode="narrative-import-pass1" select="node()">
			<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- linkHtml: text resolved; only external links preserved 

		Example: fragment dropped
			input:  <linkHtml href="#sample">sample</linkHtml>
			output: sample

		Example: external preserved
			input:  <linkHtml href="http://example.com">example</linkHtml>
			output: [example](http://example.com)

		NOTE: text will not wrap across lines to simplify export logic
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:linkHtml">
		<xsl:param name="footnoteRefs"/>

		<xsl:variable name="text">
			<xsl:apply-templates mode="narrative-import-pass1" select="node()">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:choose>
			
			<!-- preserve external and ensure text does not wrap -->
			<xsl:when test="not(substring(@href,1,1) = '#')">
				<xsl:value-of select="concat('[', translate(normalize-space($text),' ','&#xa0;'), '](', @href, ')')"/>
			</xsl:when>

			<!-- otherwise treat like a hl7:content -->
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- footnoteRef: replace @IDREF with positional number
		input:  Fruit<footnoteRef IDREF="#apple"/> Vegetable<footnoteRef IDREF="#carrot"/>
		output: Fruit[^1] Vegetable[^2]
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:footnoteRef">
		<xsl:param name="footnoteRefs"/>
		<xsl:variable name="idref" select="@IDREF"/>

		<!-- FUTURE: figure out better way to get position; this will only trigger once since $footnoteRefs is a distinct set -->
		<xsl:for-each select="$footnoteRefs"> 
			<xsl:if test=". = $idref">
				<xsl:text>[^</xsl:text>
				<xsl:value-of select="position()"/>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- br: replace with linefeed -->
	<xsl:template mode="narrative-import-pass1" match="hl7:br">
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<!-- caption: resolve text; always a single line that does not wrap 
		input:  <caption>Hello World</caption>
		output: Hello World
		
		NOTE: the output uses NBSP
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:caption">
		<xsl:param name="footnoteRefs"/>

		<xsl:variable name="text">
			<xsl:apply-templates mode="narrative-import-pass1" select="node()">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</xsl:variable>

		<!-- ensure caption does not wrap -->
		<xsl:value-of select="translate(normalize-space($text),' ','&#xa0;')"/>
	</xsl:template>

	<!-- paragraph: resolve text and caption; rename node to 'p'
		input:  <paragraph><caption>Lorem Ipsum</caption>Irure ut deserunt sint non id laborum sint adipisicing deserunt duis qui Lorem occaecat eu ipsum ullamco deserunt minim.</paragraph>
		output: <p><caption>Lorem Ipsum</caption>Irure ut deserunt sint non id laborum sint adipisicing deserunt duis qui Lorem occaecat eu ipsum ullamco deserunt minim.</p>

		NOTE: the caption output uses NBSP
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:paragraph">
		<xsl:param name="footnoteRefs"/>
		<p>
			<xsl:if test="hl7:caption">
				<caption>
					<xsl:apply-templates mode="narrative-import-pass1" select="hl7:caption">
						<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
					</xsl:apply-templates>
				</caption>
			</xsl:if>
			<xsl:apply-templates mode="narrative-import-pass1" select="node()[not(local-name()='caption')]">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</p>
	</xsl:template>

	<!-- list: resolve caption and items
		input:  <list><caption>Hello World</caption><item>one</item><item>two</item></list>
		output: <list>caption>Hello World</caption><item bullet="*">one</item><item bullet="*">two</item></list>

		NOTE: the caption output uses NBSP
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:list">
		<xsl:param name="footnoteRefs"/>
		<list>
			<xsl:if test="hl7:caption">
				<caption>
					<xsl:apply-templates mode="narrative-import-pass1" select="hl7:caption">
						<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
					</xsl:apply-templates>
				</caption>
			</xsl:if>
			<xsl:apply-templates mode="narrative-import-pass1" select="hl7:item">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</list>
	</xsl:template>

	<!-- item: resolve text and calculate bullet 
		Example: unordered list
			input:  <list><item>one</item><item>two</item></list>
			output: <list><item bullet="*">one</item><item bullet="*">two</item></list>

		Example: ordered list
			input:  <list listType="ordered"><item>one</item><item>two</item></list>
			output: <list><item bullet="1.">one</item><item bullet="2.">two</item></list>
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:item">
		<xsl:param name="footnoteRefs"/>

		<xsl:variable name="bullet">
			<xsl:choose>
				<xsl:when test="../@listType = 'ordered'">
					<xsl:value-of select="concat(position(),'.')"/>
				</xsl:when>
				<xsl:otherwise>*</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<item bullet="{$bullet}">
			<xsl:apply-templates mode="narrative-import-pass1" select="node()">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</item>
	</xsl:template>

	<!-- table: resolve caption and thead/tbody/tfoot 
		input:  <table><caption>Hello World</caption><tbody><tr><td>H<sub>2</sub>O</td></tr></tbody></table>
		output: <table><caption>Hello World</caption><tbody><tr><td>H2O</td></tr></tbody></table>

		NOTE: the caption output uses NBSP
	-->
	<xsl:template mode="narrative-import-pass1" match="hl7:table">
		<xsl:param name="footnoteRefs"/>
		<table>
			<xsl:if test="hl7:caption">
				<caption>
					<xsl:apply-templates mode="narrative-import-pass1" select="hl7:caption">
						<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
					</xsl:apply-templates>
				</caption>
			</xsl:if>
			<xsl:apply-templates mode="narrative-import-pass1" select="node()">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</table>
	</xsl:template>

	<!-- table groupers: copied as is -->
	<xsl:template mode="narrative-import-pass1" match="hl7:thead | hl7:tbody | hl7:tfoot">
		<xsl:param name="footnoteRefs"/>
		<xsl:element name="{local-name(.)}">
			<xsl:apply-templates mode="narrative-import-pass1" select="hl7:tr">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<!-- table row: copied as is -->
	<xsl:template mode="narrative-import-pass1" match="hl7:tr">
		<xsl:param name="footnoteRefs"/>
		<tr>
			<xsl:apply-templates mode="narrative-import-pass1" select="hl7:th | hl7:td">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</tr>
	</xsl:template>

	<!-- table cell: copied with resolved text -->
	<xsl:template mode="narrative-import-pass1" match="hl7:td | hl7:th">
		<xsl:param name="footnoteRefs"/>
		<xsl:element name="{local-name(.)}">
			<xsl:apply-templates mode="narrative-import-pass1" select="node()">
				<xsl:with-param name="footnoteRefs" select="$footnoteRefs"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<!-- ************************************************************************
		PASS 2: convert PASS1 linear tree into structured text
	************************************************************************ -->

	<!-- text: wrap and add blank line if not the last sibling -->
	<xsl:template mode="narrative-import-pass2" match="text()">
		<xsl:param name="indent" select="''"/>
		<xsl:param name="break" select="'&#10;&#10;'"/> <!-- default to blank line after -->

		<xsl:choose>
			<xsl:when test="string-length(normalize-space(.)) > 0"> 
				<xsl:call-template name="narrative-import-format">
					<xsl:with-param name="text" select="."/>
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
				<xsl:if test="following-sibling::*[1]">
					<xsl:value-of select="$break"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- paragraph: wrap and indent by 2 spaces if captioned 
		Example: without caption
			input:  <p>Irure ut deserunt sint non id laborum sint adipisicing deserunt duis qui Lorem occaecat eu ipsum ullamco deserunt minim.</p>
			output: Irure ut deserunt sint non id laborum sint adipisicing deserunt duis qui Lorem 
			        occaecat eu ipsum ullamco deserunt minim.

		Example: with caption
			input:  <p><caption>Lorem Ipsum</caption>Irure ut deserunt sint non id laborum sint adipisicing deserunt duis qui Lorem occaecat eu ipsum ullamco deserunt minim.</p>
			output: Lorem Ipsum
			          Irure ut deserunt sint non id laborum sint adipisicing deserunt duis qui Lorem 
			          occaecat eu ipsum ullamco deserunt minim.

		NOTE: caption input uses NBSP which after wrapping is converted into a space
	-->
	<xsl:template mode="narrative-import-pass2" match="p">
		<xsl:param name="indent" select="''"/>

		<xsl:variable name="caption" select="normalize-space(caption/text())"/>
		<xsl:variable name="norm" select="normalize-space(text())"/>

		<xsl:choose>
			
			<xsl:when test="string-length($caption) > 0"> 
				<!-- add the caption -->
				<xsl:call-template name="narrative-import-format">
					<xsl:with-param name="text" select="$caption"/>
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>

				<!-- add the paragraph text indented starting on next line -->
				<xsl:if test="string-length($norm)">
					<xsl:text>&#10;</xsl:text>
					<xsl:apply-templates mode="narrative-import-pass2" select="text()">
						<xsl:with-param name="indent" select="concat($indent,'  ')"/>
					</xsl:apply-templates>
				</xsl:if>

				<!-- add a blank line if next sibling is a block element OR non-whitespace text() -->
				<xsl:if test="following-sibling::*[1] or following-sibling::text()[string-length(normalize-space(.))>0]">
					<xsl:text>&#10;&#10;</xsl:text>
				</xsl:if>
			</xsl:when>

			<xsl:when test="string-length($norm)">
				<!-- add the paragraph text without additional indentation -->
				<xsl:apply-templates mode="narrative-import-pass2" select="text()">
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:apply-templates>

				<!-- add a blank line if next sibling is a block element OR non-whitespace text() -->
				<xsl:if test="following-sibling::*[1] or following-sibling::text()[string-length(normalize-space(.))>0]">
					<xsl:text>&#10;&#10;</xsl:text>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- footnote: wrap content using positional reference with rule before first
		input:  <footnote>one</footnote><footnote>Velit occaecat tempor quis irure qui ea aliquip sunt ullamco laboris et ad dolore veniam.<footnote>
		output: –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		        [^1] one
		        [^2] Velit occaecat tempor quis irure qui ea aliquip sunt ullamco laboris et ad
		             dolore veniam.
	-->
	<xsl:template mode="narrative-import-pass2" match="footnote">
		<!-- output horizontal ruler on first item only -->
		<xsl:if test="@pos = 1">
			<xsl:text>-------------------------------------------------------------------------------</xsl:text>
		</xsl:if>

		<!-- compute offset for indent -->
		<xsl:variable name="offset" select="4 + string-length(@pos)"/>

		<!-- get indented and wrapped payload -->
		<xsl:variable name="content">
			<xsl:apply-templates mode="narrative-import-pass2" select="node()">
				<xsl:with-param name="indent" select="substring($narrative-v-spaces, 1, $offset)"/>
			</xsl:apply-templates>
		</xsl:variable>

		<!-- output payload replacing first line with footnote reference markup -->
		<xsl:text>&#10;[^</xsl:text>
		<xsl:value-of select="@pos"/>
		<xsl:text>] </xsl:text>
		<xsl:value-of select="substring($content, $offset + 1)"/>
	</xsl:template>

	<!-- list: single line caption with all items indented by 2 spaces
		Example: simple list 
			input:  <list><item bullet="*">one</item><item bullet="*">two</item></list> 
			output: * one 
			        * two

		Example: captioned list
			input:  <list><caption>Numbers</caption><item bullet="*">one</item><item bullet="*">two</item></list>
			output: Numbers
			          * one
			          * two

		Example: ordered list
			input:  <list listType="ordered"><item bullet="1.">one</item><item bullet="2.">two</item></list>
			output:   1. one
			          2. two

		Example: nested list using item text()
			input:  <list><item bullet="*">one</item><item bullet="*">two<list><item bullet="*">three</item><item bullet="*">four</item></list></item></list>
			output:   * one
			          * two
			              * three
			              * four

		Example: nested list using list caption  (same output as above)
			input:  <list><item bullet="*">one</item><item bullet="*"><list><caption>two</caption><item bullet="*">three</item><item bullet="*">four</item></list></item></list>
			output:   * one
			          * two
			              * three
			              * four

		Example: list item wrapping is after the bullet
			input:  <list><item bullet="*">Ea ex labore sit excepteur duis anim nisi pariatur labore nisi tempor aliqua ut nisi adipisicing deserunt excepteur est.</item></list>
			output:   * Ea ex labore sit excepteur duis anim nisi pariatur labore nisi tempor aliqua ut
			            nisi adipisicing deserunt excepteur est.
	-->
	<xsl:template mode="narrative-import-pass2" match="list">
		<xsl:param name="indent" select="''"/>

		<xsl:variable name="caption" select="normalize-space(caption/text())"/>

		<xsl:choose>
			<xsl:when test="string-length($caption) > 0"> 
				<!-- add the caption -->
				<xsl:call-template name="narrative-import-format">
					<xsl:with-param name="text" select="$caption"/>
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>

				<!-- add items starting on next line with additional indent -->
				<xsl:if test="item">
					<xsl:text>&#10;</xsl:text>
					<xsl:apply-templates mode="narrative-import-pass2" select="item">
						<xsl:with-param name="indent" select="concat($indent,'  ')"/>
					</xsl:apply-templates>
				</xsl:if>

				<!-- add a blank line if next sibling is a block element OR non-whitespace text() -->
				<xsl:if test="following-sibling::*[1] or following-sibling::text()[string-length(normalize-space(.))>0]">
					<xsl:text>&#10;&#10;</xsl:text>
				</xsl:if>
			</xsl:when>

			<xsl:when test="item">
				<!-- add items with additional indent starting on current line -->
				<xsl:apply-templates mode="narrative-import-pass2" select="item">
					<xsl:with-param name="indent" select="concat($indent,'  ')"/>
				</xsl:apply-templates>

				<!-- add a blank line if next sibling is a block element OR non-whitespace text() -->
				<xsl:if test="following-sibling::*[1] or following-sibling::text()[string-length(normalize-space(.))>0]">
					<xsl:text>&#10;&#10;</xsl:text>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- item: output item with bullet and content wrapped to position after bullet space
		input:  <item bullet="*">Ea ex labore sit excepteur duis anim nisi pariatur labore nisi tempor aliqua ut nisi adipisicing deserunt excepteur est.</item>
		output:   * Ea ex labore sit excepteur duis anim nisi pariatur labore nisi tempor aliqua ut
		            nisi adipisicing deserunt excepteur est.
	-->
	<xsl:template mode="narrative-import-pass2" match="item">
		<xsl:param name="indent" select="''"/>
		<xsl:param name="bullet" select="concat(@bullet,' ')"/>

		<!-- indent all content; supports up to 1-99 ordered items 
			soft break after first text if first child element is a nested list: <item>label<list>...</list>....</item>
		-->
		<xsl:variable name="nested" select="(local-name(node()[1]) = '') and (local-name(node()[2]) = 'list')"/>
		<xsl:variable name="content">
			<xsl:choose>
				<xsl:when test="$nested">
					<xsl:apply-templates mode="narrative-import-pass2" select="node()[1]">
						<xsl:with-param name="indent" select="concat($indent,substring('    ', 1, string-length($bullet)))"/>
						<xsl:with-param name="break" select="'&#10;'"/>
					</xsl:apply-templates>
					<xsl:apply-templates mode="narrative-import-pass2" select="node()[position()>1]">
						<xsl:with-param name="indent" select="concat($indent,substring('    ', 1, string-length($bullet)))"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="narrative-import-pass2" select="node()">
						<xsl:with-param name="indent" select="concat($indent,substring('    ', 1, string-length($bullet)))"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- replace first line indent with bullet with workaround for nested tables (td>list>item>table)-->
		<xsl:choose>
			<xsl:when test="(local-name(../..) = 'td') and (local-name(./*[1]) = 'table')">
				<xsl:text>+---</xsl:text>
				<xsl:value-of select="substring($content,5)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$indent"/>
				<xsl:value-of select="$bullet"/>
				<xsl:value-of select="substring($content,string-length($indent) + string-length($bullet) + 1)"/>
			</xsl:otherwise>
		</xsl:choose>

		<!-- move to next line if there is another item -->
		<xsl:if test="following-sibling::item[1]">
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- table: convert to markdown grid table will structured cell content 
		input: <table><thead><tr><th>Fruit</th><th>Price</th></tr></thead><tbody><tr><td>Bananas</td><td>$1.34</td></tr><tr><td>Oranges></td><td>$2.10</td></tr></tbody></table>
		output:
			+–––––––––+–––––––+
			| Fruit   | Price |
			+=========+=======+
			| Bananas | $1.34 |
			+–––––––––+–––––––+
			| Oranges | $2.10 |
			+–––––––––+–––––––+
	-->
	<xsl:template mode="narrative-import-pass2" match="table">
		<xsl:param name="indent" select="''"/>

		<!-- output single line caption and move to next line -->
		<xsl:variable name="caption" select="normalize-space(caption/text())"/>
		<xsl:if test="string-length($caption) > 0"> 
			<xsl:call-template name="narrative-import-format">
				<xsl:with-param name="text" select="$caption"/>
				<xsl:with-param name="indent" select="$indent"/>
			</xsl:call-template>
			<xsl:text>&#10;</xsl:text>
		</xsl:if>

		<!-- convert to a refactored tree of rows, cells and lines
			<table>
				<row type="h">  // h for thead, f for tfoot, else r for tbody
					<cell>
						<line len="5">hello</line>
		-->
		<xsl:variable name="formatted">
			<table>
				<xsl:apply-templates mode="narrative-import-pass2" select="thead"/>
				<xsl:apply-templates mode="narrative-import-pass2" select="tbody"/>
				<xsl:if test="thead"> <!-- tfoot without a thead is not supported -->
					<xsl:apply-templates mode="narrative-import-pass2" select="tfoot"/>
				</xsl:if>
			</table>
		</xsl:variable>
		<xsl:variable name="table" select="exsl:node-set($formatted)"/>

		<!-- render the refactored tree -->
		<xsl:apply-templates mode="narrative-import-table" select="$table"/>

		<!-- add a blank line if next sibling is a block element OR non-whitespace text() -->
		<xsl:if test="following-sibling::*[1] or following-sibling::text()[string-length(normalize-space(.))>0]">
			<xsl:text>&#10;</xsl:text> <!-- only one since last row separator includes newline -->
		</xsl:if>
	</xsl:template>

	<!-- thead: render header rows with type="h" -->
	<xsl:template mode="narrative-import-pass2" match="thead">
		<xsl:apply-templates mode="narrative-import-pass2" select="tr">
			<xsl:with-param name="type" select="'h'"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- tfoot: render footer rows with type="f" -->
	<xsl:template mode="narrative-import-pass2" match="tfoot">
		<xsl:apply-templates mode="narrative-import-pass2" select="tr">
			<xsl:with-param name="type" select="'f'"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- tbody: render body rows type="r" -->
	<xsl:template mode="narrative-import-pass2" match="tbody">
		<xsl:apply-templates mode="narrative-import-pass2" select="tr"/>
	</xsl:template>

	<!-- tr: render row with given type -->
	<xsl:template mode="narrative-import-pass2" match="tr">
		<xsl:param name="type" select="'r'"/>
		<row type="{$type}">
			<xsl:apply-templates mode="narrative-import-pass2" select="th | td"/>
		</row>
	</xsl:template>

	<!-- td/th: resolve and wrap content and render cell lines -->
	<xsl:template mode="narrative-import-pass2" match="th | td">
		<xsl:variable name="text">
			<xsl:apply-templates mode="narrative-import-pass2" select="node()"/>
		</xsl:variable>
		<cell>
			<xsl:call-template name="narrative-import-lines">
				<xsl:with-param name="text" select="$text"/>
			</xsl:call-template>
		</cell>
	</xsl:template>

	<!-- process refactored table (table -> rows -> cells -> lines) -->
	<xsl:template mode="narrative-import-table" match="table">
		<!-- determine table columns -->
		<xsl:variable name="columns">
			<xsl:apply-templates mode="narrative-import-table-columns" select="."/>
		</xsl:variable>
		<xsl:variable name="cols" select="exsl:node-set($columns)/col"/>

		<!-- start the table with separator -->
		<xsl:call-template name="narrative-import-table-separator">
			<xsl:with-param name="cols" select="$cols"/>
		</xsl:call-template>

		<!-- output table rows by column -->
		<xsl:apply-templates mode="narrative-import-table-row" select="row">
			<xsl:with-param name="cols" select="$cols"/>
		</xsl:apply-templates>

		<!-- end the table with separator-->
		<xsl:call-template name="narrative-import-table-separator">
			<xsl:with-param name="cols" select="$cols"/>
		</xsl:call-template>
	</xsl:template>

	<!-- get table columns and the max width of each -->
	<xsl:template mode="narrative-import-table-columns" match="table">
		<xsl:param name="col" select="1"/>

		<xsl:if test=".//row/cell[$col]/line"> <!-- skip columns without content -->
			<col width="{math:max(.//row/cell[$col]/line/@len)}"/>
			<xsl:apply-templates mode="narrative-import-table-columns" select=".">
				<xsl:with-param name="col" select="$col + 1"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<!-- output table separator based on provided columns -->
	<xsl:template name="narrative-import-table-separator">
		<xsl:param name="cols"/>
		<xsl:param name="char" select="'-'"/>
		<xsl:for-each select="$cols">
			<xsl:text>+</xsl:text>
			<xsl:value-of select="translate(substring($narrative-v-spaces,1,@width + 2),' ',$char)"/>
		</xsl:for-each>
		<xsl:text>+&#10;</xsl:text>
	</xsl:template>

	<!-- output table row based on provided columns; recur over each line -->
	<xsl:template mode="narrative-import-table-row" match="row">
		<xsl:param name="cols"/>
		<xsl:param name="line" select="1"/>

		<xsl:choose>
			<!-- there is a cell with data for this line -->
			<xsl:when test="./cell/line[$line]">

				<!-- write the footer separator on first tfoot row -->
				<xsl:if test="($line = 1) and (@type = 'f') and not(preceding-sibling::row[1]/@type = 'f')">
					<xsl:call-template name="narrative-import-table-separator">
						<xsl:with-param name="cols" select="$cols"/>
						<xsl:with-param name="char" select="'='"/>
					</xsl:call-template>
				</xsl:if>

				<!-- write current line for this row -->
				<xsl:variable name="row" select="."/>
				<xsl:for-each select="$cols">
					<xsl:variable name="col" select="position()"/>
					<xsl:variable name="text" select="$row/cell[$col]/line[$line]/text()"/>
					<xsl:text>| </xsl:text>
					<xsl:value-of select="$text"/>
					<xsl:value-of select="substring($narrative-v-spaces,1,@width - string-length($text) + 1)"/>
				</xsl:for-each>
				<xsl:text>|&#10;</xsl:text>

				<!-- move on to the next line for this row -->
				<xsl:apply-templates mode="narrative-import-table-row" select="$row">
					<xsl:with-param name="cols" select="$cols"/>
					<xsl:with-param name="line" select="$line+1"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- skip row if no cells have data -->
			<xsl:when test="$line = 1"/> <!-- if any cells written line always > 1 -->

			<!-- write the header separator for the last thead row -->
			<xsl:when test="(@type = 'h') and (following-sibling::row[1]/@type = 'r')">
				<xsl:call-template name="narrative-import-table-separator">
					<xsl:with-param name="cols" select="$cols"/>
					<xsl:with-param name="char" select="'='"/>
				</xsl:call-template>
			</xsl:when>

			<!-- write the row separator if there is another tbody row -->
			<xsl:when test="(@type = 'r') and (following-sibling::row[1]/@type = 'r')">
				<xsl:call-template name="narrative-import-table-separator">
					<xsl:with-param name="cols" select="$cols"/>
					<xsl:with-param name="char" select="'-'"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!--  
		UTILITY
	-->

	<!-- convert table cell content into list of <line> nodes with @len length attribute 
		input:  apple
		        banana
		output: <line len="5">apple</line><line len="6">banana</line>
	-->
	<xsl:template name="narrative-import-lines">
		<xsl:param name="text" />
		<xsl:choose>
			<xsl:when test="string-length($text) = 0"/>
			<xsl:when test="contains($text,'&#10;')">
				<xsl:variable name="line" select="substring-before($text,'&#10;')"/>
				<line len="{string-length($line)}">
					<xsl:value-of select="$line"/>
				</line>
				<xsl:call-template name="narrative-import-lines">
					<xsl:with-param name="text" select="substring-after($text,'&#10;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<line len="{string-length($text)}">
					<xsl:value-of select="$text"/>
				</line>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- indent and wrap text -->
	<xsl:template name="narrative-import-format">
		<xsl:param name="text"/>
		<xsl:param name="indent" select="''"/>
		<xsl:param name="width" select="$narrativeImportWrapWidth"/>

		<xsl:choose>
			<xsl:when test="string-length($text) = 0"/>
			<xsl:when test="contains($text, '&#10;')">
				<xsl:call-template name="narrative-import-format">
					<xsl:with-param name="text" select="substring-before($text,'&#10;')"/>
					<xsl:with-param name="indent" select="$indent"/>
					<xsl:with-param name="width" select="$width"/>
				</xsl:call-template>
				<xsl:text>&#10;</xsl:text>
				<xsl:call-template name="narrative-import-format">
					<xsl:with-param name="text" select="substring-after($text,'&#10;')"/>
					<xsl:with-param name="indent" select="$indent"/>
					<xsl:with-param name="width" select="$width"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="narrative-import-wrap">
					<xsl:with-param name="text" select="normalize-space($text)"/>
					<xsl:with-param name="indent" select="$indent"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- wrap a line of text using provided boundary chars, width and indent  
		This will convert NBSP added during pass 1 to prevent wrapping (e.g. captions and link text) back into spaces
	-->
	<xsl:template name="narrative-import-wrap">
		<xsl:param name="text"/> 
		<xsl:param name="indent" select="''"/>
		<xsl:param name="width" select="$narrativeImportWrapWidth"/>
		<xsl:param name="chars" select="' '"/>

		<xsl:choose>
			<xsl:when test="string-length($text) = 0"/>
			<xsl:otherwise>
				<!-- remove leading whitespace from the line -->
				<xsl:variable name="line">
					<xsl:call-template name="narrative-ltrim">
						<xsl:with-param name="text" select="$text"/>
					</xsl:call-template>
				</xsl:variable>

				<!-- find the first break before $width -->
				<xsl:variable name="pos">
					<xsl:call-template name="narrative-import-findPrevious">
						<xsl:with-param name="text" select="$line"/>
						<xsl:with-param name="pos" select="$width"/>
						<xsl:with-param name="chars" select="$chars"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:choose>
					<!-- no boundary found before $width  -->
					<xsl:when test="$pos = 0"> 
						
						<!-- find the first break after $width -->
						<xsl:variable name="next">
							<xsl:call-template name="narrative-import-findNext">
								<xsl:with-param name="text" select="$line"/>
								<xsl:with-param name="pos" select="$width + 1"/>
								<xsl:with-param name="chars" select="$chars"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:choose>
							<!-- no boundary found so output entire line -->
							<xsl:when test="$next = 0"> 
								<xsl:value-of select="$indent"/>
								<xsl:value-of select="translate($line,'&#xa0;',' ')"/>
							</xsl:when>

							<!-- boundary found after $width so output wrap at point longer than width -->
							<xsl:otherwise> 
								<xsl:value-of select="$indent"/>
								<xsl:value-of select="translate(substring($line, 1, $next),'&#xa0;',' ')"/>
								
								<!-- recur only if text didn't end on a break characteer -->
								<xsl:if test="string-length($line) > $next">
									<xsl:text>&#10;</xsl:text>
									<xsl:call-template name="narrative-import-wrap">
										<xsl:with-param name="text" select="substring($line, $next + 1)"/>
										<xsl:with-param name="indent" select="$indent"/>
										<xsl:with-param name="chars" select="$chars"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<!-- boundary found before $width -->
					<xsl:otherwise> 
						<xsl:value-of select="$indent"/>
						<xsl:value-of select="translate(substring($line, 1, $pos),'&#xa0;',' ')"/>

						<!-- recur only if text didn't end on a break characteer -->
						<xsl:if test="string-length($line) > $pos">
							<xsl:text>&#10;</xsl:text>
							<xsl:call-template name="narrative-import-wrap">
								<xsl:with-param name="text" select="substring($line, $pos + 1)"/>
								<xsl:with-param name="indent" select="$indent"/>
								<xsl:with-param name="chars" select="$chars"/>
							</xsl:call-template>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- return previous position starting at given position matching one of a list of characters -->
	<xsl:template name="narrative-import-findPrevious">
		<xsl:param name="text"/>
		<xsl:param name="pos"/>
		<xsl:param name="chars" select="' '"/>
		<xsl:choose>
			<xsl:when test="($pos = 0) or (contains($chars,substring($text,$pos,1)))">
				<xsl:value-of select="$pos"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="narrative-import-findPrevious">
					<xsl:with-param name="text" select="$text"/>
					<xsl:with-param name="pos" select="$pos - 1"/>
					<xsl:with-param name="chars" select="$chars"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- return next position starting at given position matching one of a list of characters -->
	<xsl:template name="narrative-import-findNext">
		<xsl:param name="text"/>
		<xsl:param name="pos"/>
		<xsl:param name="chars" select="' '"/>
		<xsl:choose>
			<xsl:when test="$pos > string-length($text)">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="contains($chars,substring($text,$pos,1))">
				<xsl:value-of select="$pos"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="narrative-import-findNext">
					<xsl:with-param name="text" select="$text"/>
					<xsl:with-param name="pos" select="$pos + 1"/>
					<xsl:with-param name="chars" select="$chars"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- remove chars from both ends of given string -->
	<xsl:template name="narrative-trim">
		<xsl:param name="text" />
		<xsl:param name="chars" select="' &#9;&#10;&#13;'"/>

		<xsl:call-template name="narrative-ltrim">
			<xsl:with-param name="text">
				<xsl:call-template name="narrative-rtrim">
					<xsl:with-param name="text" select="$text"/>
					<xsl:with-param name="chars" select="$chars"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="chars" select="$chars"/>
		</xsl:call-template>
	</xsl:template>

	<!-- remove chars from left of given string -->
	<xsl:template name="narrative-ltrim">
		<xsl:param name="text" />
		<xsl:param name="chars" select="' &#9;&#10;&#13;'"/>
		<xsl:choose>
			<xsl:when test="string-length($text) = 0 or not(contains($chars,substring($text,1,1)))">
				<xsl:value-of select="$text" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="narrative-ltrim">
					<xsl:with-param name="text" select="substring($text,2)"/>
					<xsl:with-param name="chars" select="$chars"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- remove chars from right of given string -->
	<xsl:template name="narrative-rtrim">
		<xsl:param name="text" />
		<xsl:param name="chars" select="' &#9;&#10;&#13;'"/>
		<xsl:variable name="len" select="string-length($text)"/>
		<xsl:choose>
			<xsl:when test="$len = 0 or not(contains($chars,substring($text,$len)))">
				<xsl:value-of select="$text" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="narrative-rtrim">
					<xsl:with-param name="text" select="substring($text, 1, $len - 1)"/>
					<xsl:with-param name="chars" select="$chars"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
