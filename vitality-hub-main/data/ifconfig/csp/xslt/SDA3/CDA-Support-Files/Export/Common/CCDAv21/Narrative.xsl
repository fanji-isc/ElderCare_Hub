<!-- C-CDA narrative export from structured plain text

	USAGE
		<xsl:apply-templates mode="narrative-export-sections" select="Container"/>
			<xsl:with-param name="templates">
				<item root="{$ccda-CourseOfCareSection}"/>
				<item root="{$ccda-GeneralStatusSection}"/>
			</xsl:with-param>
		</xsl:apply-templates>

			Exports "standalone" section with structured narrative if configured.


		<xsl:apply-templates mode="narrative-export-documents" select="Container">
			<xsl:with-param name="docs" select="Documents/Document[....]"/>
		</xsl:apply-templates>

			Exports a list of documents as a single StrucDoc.Table element with date
			and author/source in addition to the structured note.


		<xsl:apply-templates mode="narrative-export" select="Document"/>

			Exports SDA3 Document with FormatCode 'NARRATIVE' as CCDA StrucDoc narrative 
			fragment otherwise as is replacing newlines with <br/>. This is the inverse
			of the transforms done in the Import/Common/CCDAv21/Narrative.xsl stylesheet.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="urn:hl7-org:v3" 
  xmlns:hl7="urn:hl7-org:v3" 
  xmlns:isc="http://extension-functions.intersystems.com"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="hl7 isc exsl">

	<!--
		PUBLIC API
	-->

	<!-- export the given "standalone" section narratives if configured -->
	<xsl:template mode="narrative-export-sections" match="Container">
		<xsl:param name="templates"/> <!-- result-tree-fragment of elements with @root -->

		<xsl:variable name="container" select="."/>

		<xsl:for-each select="exsl:node-set($templates)//@root">
			<xsl:variable name="root" select="."/>
			<xsl:variable name="conf" select="$exportConfiguration/narrative/section[templateId/@root = $root]"/>
			<xsl:if test="count($conf) > 0">
				<xsl:variable name="docs" select="$container/Documents/Document[(Category/Code = 'SectionNarrative') and (DocumentType/Code = $conf/code/@code)]"/>
				<xsl:if test="count($docs) > 0">
					<component>
						<section>
							<templateId><xsl:copy-of select="$conf/templateId/@*"/></templateId>
							<code code="{$conf/code/@code}" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="{$conf/code/@displayName}"/>
							<title><xsl:value-of select="$conf/title/text()"/></title>
							<text>
								<xsl:apply-templates mode="narrative-export-documents" select="$container">
									<xsl:with-param name="docs" select="$docs"/>
								</xsl:apply-templates>
							</text>
						</section>
					</component>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- export narrative documents-->
	<xsl:template mode="narrative-export-documents" match="Container">
		<xsl:param name="docs"/>

		<xsl:for-each select="$docs">
			<paragraph ID="{concat('StrucDoc_',translate(DocumentNumber/text(),'|','_'))}">
				<content styleCode="Bold">
					<xsl:value-of select="substring-before(translate(DocumentTime,'T',' '),' ')"/>
					<xsl:if test="string-length(EnteredBy/Description/text())">
						<xsl:text> </xsl:text>
						<xsl:value-of select="EnteredBy/Description/text()"/>
					</xsl:if>
					<xsl:if test="string-length(EnteredAt/Description/text())">
						<xsl:if test="string-length(EnteredBy/Description/text())">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text> </xsl:text>
						<xsl:value-of select="EnteredAt/Description/text()"/>
					</xsl:if>
				</content>
			</paragraph>
			<xsl:apply-templates mode="narrative-export" select="."/>
		</xsl:for-each>
	</xsl:template>

	<!-- export SDA Document as CCDA structured narrative if possiblel otherwise as plain-text -->
	<xsl:template mode="narrative-export" match="Document">
		<xsl:param name="isCell" select="0"/> <!-- hl7:td doesn't allow hl7:table child so it must be wrapped in a hl7:list -->
		<xsl:choose>
			<xsl:when test="FormatCode/Code/text() = 'NARRATIVE'">
				<xsl:if test="isc:evaluate('varKill','narrativeIdPrefix')"/>
				<xsl:choose>
					<xsl:when test="($isCell = 1) and contains(NoteText/text(), '&#10;+-')"> <!-- top level table found, need to wrap-->
						<list>
							<item>
								<xsl:call-template name="narrative-export-structured">
									<xsl:with-param name="value" select="translate(NoteText/text(), '&#13;', '')"/>
								</xsl:call-template>
							</item>
						</list>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="narrative-export-structured">
							<xsl:with-param name="value" select="translate(NoteText/text(), '&#13;', '')"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="narrative-export-text">
					<xsl:with-param name="value" select="translate(NoteText/text(), '&#13;', '')"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
		SECTION TEMPLATES
	-->

	<!-- 
		NARRATIVE TEMPLATES
	-->

	<!-- output text as is with newlines replaced with <br/> -->
	<xsl:template name="narrative-export-text">
		<xsl:param name="value" />
		<xsl:choose>
			<xsl:when test="contains($value,'&#10;')">
				<xsl:value-of select="substring-before($value, '&#10;')" />
				<xsl:element name="br"/>
				<xsl:call-template name="narrative-export-text">
					<xsl:with-param name="value" select="substring-after($value, '&#10;')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- convert value into structured CCDA narrative elements -->
	<xsl:template name="narrative-export-structured">
		<xsl:param name="value" />
		
		<!-- parse value into list of top-level block elements delimited by blank lines -->
		<xsl:variable name="chunks">
			<xsl:call-template name="narrative-export-chunks">
				<xsl:with-param name="value" select="$value"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- process each chunk -->
		<xsl:apply-templates mode="narrative-export-render" select="exsl:node-set($chunks)"/>
	</xsl:template>

	<!-- determine type of a single block element and delegate to approprate handler -->
	<xsl:template mode="narrative-export-render" match="hl7:chunk">
		<xsl:if test="string-length(text())">

			<xsl:variable name="first">
				<xsl:call-template name="narrative-export-first-piece">
					<xsl:with-param name="value" select="text()"/>
					<xsl:with-param name="delim" select="'&#10;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="rest" select="substring-after(text(), '&#10;')"/>
			<xsl:variable name="second" select="substring-before($rest, '&#10;')"/>

			<xsl:choose>
				<xsl:when test="(substring($first, 1, 3) = '  *') or (substring($first, 1, 3) = '  1')">
					<xsl:apply-templates mode="narrative-export-render-list" select="."/>
				</xsl:when>
				<xsl:when test="substring($first, 1, 2) = '+-'">
					<xsl:apply-templates mode="narrative-export-render-table" select="."/>
				</xsl:when>
				<xsl:when test="substring($first, 1, 2) = '--'">
					<xsl:apply-templates mode="narrative-export-render-footnote" select="text()"/>
				</xsl:when>
				<xsl:when test="(substring($second, 1, 3) = '  *') or (substring($second, 1, 3) = '  1')">
					<xsl:apply-templates mode="narrative-export-render-list" select="."/>
				</xsl:when>
				<xsl:when test="substring($second, 1, 2) = '+-'">
					<xsl:apply-templates mode="narrative-export-render-table" select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="narrative-export-render-paragraph" select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- process a paragraph chunk -->
	<xsl:template mode="narrative-export-render-paragraph" match="hl7:chunk">
		<paragraph>
			<xsl:choose>
				<!-- with caption -->
				<xsl:when test="contains(text(),'&#10;  ')">
					<caption>
						<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set(substring-before(text(),'&#10;'))"/>
					</caption>
					<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set(substring-after(text(),'&#10;'))"/>
				</xsl:when>
				<!-- without caption -->
				<xsl:otherwise>
					<xsl:apply-templates mode="narrative-export-render-inline" select="text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</paragraph>
	</xsl:template>

	<!-- process a list chunk -->
	<xsl:template mode="narrative-export-render-list" match="hl7:chunk">
		<xsl:variable name="first">
			<xsl:call-template name="narrative-export-first-piece">
				<xsl:with-param name="value" select="text()"/>
				<xsl:with-param name="delim" select="'&#10;'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="rest" select="substring-after(text(),'&#10;')"/>
		<xsl:variable name="second" select="substring-before($rest,'&#10;')"/>

		<list>
		 	<xsl:choose>
				<!-- no caption -->
				<xsl:when test="substring($first,1,2) = '  '">
					<xsl:if test="substring($first,3,1) = '1'">
						<xsl:attribute name="listType">ordered</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates mode="narrative-export-render-items" select="text()"/>
				</xsl:when>
				<!-- with caption -->
				<xsl:otherwise>
					<xsl:if test="substring($second,3,1) = '1'">
						<xsl:attribute name="listType">ordered</xsl:attribute>
					</xsl:if>
					<caption>
						<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set($first)"/>
					</caption>
					<xsl:apply-templates mode="narrative-export-render-items" select="exsl:node-set($rest)"/>
				</xsl:otherwise>
			</xsl:choose>
		</list>
	</xsl:template>

	<!-- process text containing all remaining list items -->
	<xsl:template mode="narrative-export-render-items" match="text()">
		<!-- only when first line starts with a bullet -->
		<xsl:if test="string-length(normalize-space(substring(.,1,3)))">
			<!-- extract the bullet -->
			<xsl:variable name="bullet">
				<xsl:choose>
					<xsl:when test="substring(.,3,1) = '*'">
						<xsl:value-of select="'  * '"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="curr" select="substring-before(substring(.,3),'.')"/>
						<xsl:value-of select="concat('  ', $curr + 1, '. ')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- get the first item -->
			<xsl:variable name="first">
				<xsl:call-template name="narrative-export-first-piece">
					<xsl:with-param name="value" select="."/>
					<xsl:with-param name="delim" select="concat('&#10;',$bullet)"/>
				</xsl:call-template>
			</xsl:variable>

			<!-- remove the indent -->
			<xsl:variable name="lines">
				<xsl:call-template name="narrative-export-outdent">
					<xsl:with-param name="value" select="$first"/>
					<xsl:with-param name="start" select="string-length($bullet) + 1"/>
				</xsl:call-template>
			</xsl:variable>

			<!-- process single item -->
			<xsl:apply-templates mode="narrative-export-render-item" select="exsl:node-set($lines)"/>

			<!-- recur for the remaining items-->
			<xsl:variable name="rest" select="substring(., string-length($first) + 2)"/>
			<xsl:apply-templates mode="narrative-export-render-items" select="exsl:node-set($rest)"/>
		</xsl:if>
	</xsl:template>

	<!-- process text for a single list item (sans bullet and indent) -->
	<xsl:template mode="narrative-export-render-item" match="text()">
		<!-- convert to a fragment of CCDA StrucDoc nodes -->
		<xsl:variable name="block">
			<xsl:call-template name="narrative-export-structured">
				<xsl:with-param name="value" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="kids" select="exsl:node-set($block)"/>

		<!-- add nodes to the export with a few exceptions -->
		<xsl:choose>
			<!-- if only one hl7:list node, pull up the caption to text() for better compatibility with default ToHTML stylesheet -->
			<xsl:when test="(count($kids/*) = 1) and ($kids/hl7:list)">
				<item>
					<xsl:copy-of select="$kids/hl7:list/hl7:caption/node()"/>
					<list>
						<xsl:copy-of select="@listType"/>
						<xsl:copy-of select="$kids/hl7:list/hl7:item"/>
					</list>
				</item>
			</xsl:when>

			<!-- if only one simple hl7:paragraph node unwrap it to avoid extra spacing when converted to HTML -->
			<xsl:when test="(count($kids/*) = 1) and ($kids/hl7:paragraph) and not($kids/hl7:paragraph/hl7:caption)">
				<item>
					<xsl:copy-of select="$kids/hl7:paragraph/node()"/>
				</item>
			</xsl:when>

			<!-- otherwise copy nodes as is -->
			<xsl:otherwise>
				<item>
					<xsl:copy-of select="$kids"/>
				</item>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- process text for all remaining footnotes -->
	<xsl:template mode="narrative-export-render-footnote" match="text()">
		<!-- get the first footnote text -->
		<xsl:variable name="first">
			<xsl:call-template name="narrative-export-first-piece">
				<xsl:with-param name="value" select="."/>
				<xsl:with-param name="delim" select="'&#10;[^'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="rest" select="substring-after(.,'&#10;[^')"/>

		<xsl:choose>
			<!-- skip empty footnotes -->
			<xsl:when test="not(string-length(normalize-space($first)))"/>

			<!-- ignore the separator horizontal rule -->
			<xsl:when test="substring($first,1,2) = '--'">
				<xsl:apply-templates mode="narrative-export-render-footnote" select="exsl:node-set($rest)"/>
			</xsl:when>

			<xsl:otherwise>
				<!-- get the positional reference -->
				<xsl:variable name="anchor" select="substring-before($first,']')"/>

				<!-- convert position() into a cached UUID -->
				<xsl:variable name="uuid" select="isc:evaluate('varGet','narrativeIdPrefix',$anchor)"/>

				<!-- remove the positional reference and dedent content (assumes less than 9 footnotes) -->
				<xsl:variable name="text">
					<xsl:call-template name="narrative-export-replace-string">
						<xsl:with-param name="text" select="substring-after($first, ' ')"/>
						<xsl:with-param name="replace" select="'&#10;     '"/>
						<xsl:with-param name="with" select="'&#10;'"/>
					</xsl:call-template>
				</xsl:variable>

				<!-- export the footnote -->
				<footnote ID="{concat($uuid,'_',$anchor)}">
					<xsl:call-template name="narrative-export-structured">
						<xsl:with-param name="value" select="$text"/>
					</xsl:call-template>
				</footnote>

				<!-- recur on the remaining footnotes -->
				<xsl:apply-templates mode="narrative-export-render-footnote" select="exsl:node-set($rest)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- process a table chunk -->
	<xsl:template mode="narrative-export-render-table" match="hl7:chunk">
		<table>
			<xsl:choose>

				<!-- without caption-->
				<xsl:when test="substring(text(),1,2) = '+-'">
					<!-- get offset and width for each column -->
					<xsl:variable name="segments">
						<xsl:call-template name="narrative-export-table-segments">
							<xsl:with-param name="value" select="substring-before(text(),'&#10;')"/>
						</xsl:call-template>
					</xsl:variable>
					<!-- export all rows -->
					<xsl:call-template name="narrative-export-render-rows">
						<xsl:with-param name="value" select="text()"/>
						<xsl:with-param name="segments" select="exsl:node-set($segments)"/>
					</xsl:call-template>
				</xsl:when>

				<!-- with caption -->
				<xsl:otherwise>
					<xsl:variable name="first">
						<xsl:call-template name="narrative-export-first-piece">
							<xsl:with-param name="value" select="text()"/>
							<xsl:with-param name="delim" select="'&#10;'"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="rest" select="substring-after(text(),'&#10;')"/>
					<!-- export the caption -->
					<caption>
						<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set($first)"/>
					</caption>
					<!-- get offset and width for each column -->
					<xsl:variable name="segments">
						<xsl:call-template name="narrative-export-table-segments">
							<xsl:with-param name="value" select="substring-before($rest,'&#10;')"/>
						</xsl:call-template>
					</xsl:variable>
					<!-- export all rows -->
					<xsl:call-template name="narrative-export-render-rows">
						<xsl:with-param name="value" select="$rest"/>
						<xsl:with-param name="segments" select="exsl:node-set($segments)"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</table>
	</xsl:template>

	<!-- calculate start and length for each column from first line in table
		input: +–––––––––+–––––––+––––––––––––––––––––––+
		guide:
			         1         2         3         4
			123456789012345678901234567890123456789012
			  xxxxxxx   xxxxx   xxxxxxxxxxxxxxxxxxxx
			+–––––––––+–––––––+––––––––––––––––––––––+
		output:
			<segement length="7" start="3"/>
			<segement length="5" start="13"/>
			<segement length="20" start="21"/>
	-->
	<xsl:template name="narrative-export-table-segments">
		<xsl:param name="value" />
		<xsl:param name="pos" select="1"/>
		<xsl:if test="string-length($value) > $pos">
			<xsl:variable name="part" select="substring-before(substring($value,$pos+1), '+')" />
			<segement start="{$pos+2}" length="{string-length($part) - 2}"/>
			<xsl:call-template name="narrative-export-table-segments">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="pos" select="$pos + string-length($part) + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- break table into thead/tbody/tfoot and delegate -->
	<xsl:template name="narrative-export-render-rows">
		<xsl:param name="value" />
		<xsl:param name="segments" />

		<xsl:choose>

			<!-- table has a header -->
			<xsl:when test="contains($value, '&#10;+=')">
				<!-- extract and export the thead -->
				<thead>
					<xsl:call-template name="narrative-export-render-row">
						<xsl:with-param name="value" select="substring-before(substring-after($value,'-+&#10;'),'&#10;+=')"/>
						<xsl:with-param name="segments" select="$segments"/>
						<xsl:with-param name="tag" select="'th'"/>
					</xsl:call-template>
				</thead>

				<xsl:variable name="rest" select="substring-after($value,'=+&#10;')"/>
				<xsl:choose>
					<!-- table contains a footer -->
					<xsl:when test="contains($rest,'&#10;+=')">
						<!-- extract and process the tbody -->
						<tbody>
							<xsl:call-template name="narrative-export-render-row">
								<xsl:with-param name="value" select="substring-before($rest,'&#10;+=')"/>
								<xsl:with-param name="segments" select="$segments"/>
							</xsl:call-template>
						</tbody>
						<!-- extract and process the tfoot -->
						<tfoot>
							<xsl:call-template name="narrative-export-render-row">
								<xsl:with-param name="value" select="substring-after($rest,'=+&#10;')"/>
								<xsl:with-param name="tag" select="'th'"/>
								<xsl:with-param name="segments" select="$segments"/>
							</xsl:call-template>
						</tfoot>
					</xsl:when>

					<!-- no footer, just a body -->
					<xsl:otherwise>
						<tbody>
							<xsl:call-template name="narrative-export-render-row">
								<xsl:with-param name="value" select="$rest"/>
								<xsl:with-param name="segments" select="$segments"/>
							</xsl:call-template>
						</tbody>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- no header, just a body (tfoot without thead is not supported) -->
			<xsl:otherwise>
				<tbody>
					<xsl:call-template name="narrative-export-render-row">
						<xsl:with-param name="value" select="substring-after($value,'-+&#10;')"/>
						<xsl:with-param name="segments" select="$segments"/>
					</xsl:call-template>
				</tbody>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- process each remaining row -->
	<xsl:template name="narrative-export-render-row">
		<xsl:param name="value" />
		<xsl:param name="segments" />
		<xsl:param name="tag" select="'td'"/>

		<xsl:if test="string-length($value)">
			<!-- get the next row -->
			<xsl:variable name="row">
				<xsl:call-template name="narrative-export-first-piece">
					<xsl:with-param name="value" select="$value"/>
					<xsl:with-param name="delim" select="'&#10;+-'"/>
				</xsl:call-template>
			</xsl:variable>

			<!-- parse into list of cells by column: <cell col="2">hello world</cell> -->
			<xsl:variable name="cells">
				<xsl:call-template name="narrative-export-render-cells">
					<xsl:with-param name="row" select="$row"/>
					<xsl:with-param name="segments" select="$segments"/>
				</xsl:call-template>
			</xsl:variable>

			<!-- export the row -->
			<tr>
				<xsl:call-template name="narrative-export-render-cols">
					<xsl:with-param name="cells" select="exsl:node-set($cells)"/>
					<xsl:with-param name="tag" select="$tag"/>
				</xsl:call-template>
			</tr>

			<!-- recur on the remaining rows -->
			<xsl:variable name="rest" select="substring-after($value,'-+&#10;')"/>
			<xsl:call-template name="narrative-export-render-row">
				<xsl:with-param name="value" select="$rest"/>
				<xsl:with-param name="tag" select="$tag"/>
				<xsl:with-param name="segments" select="$segments"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- export a single row of structured columns -->
	<xsl:template name="narrative-export-render-cols">
		<xsl:param name="cells"/>
		<xsl:param name="tag" select="'td'"/>
		<xsl:param name="col" select="1"/>

		<!-- only if there is data for the given column -->
		<xsl:if test="$cells/*[@col = $col]">

			<!-- combine lines for this column -->
			<xsl:variable name="text">
				<xsl:for-each select="$cells/*[@col = $col]">
					<!-- trim to remove width padding for other rows -->
					<xsl:call-template name="narrative-rtrim">
						<xsl:with-param name="text" select="text()"/>
					</xsl:call-template>
					<xsl:if test="following-sibling::*[@col=$col]">
						<xsl:text>&#10;</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<!-- trim to remove height padding for other columns -->
			<xsl:variable name="trimmed">
				<xsl:call-template name="narrative-rtrim">
					<xsl:with-param name="text" select="$text"/>
				</xsl:call-template>
			</xsl:variable>

			<!-- convert the lines into structured fragment -->
			<xsl:variable name="block">
				<xsl:call-template name="narrative-export-structured">
					<xsl:with-param name="value" select="$trimmed"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="kids" select="exsl:node-set($block)"/>

			<!-- export the fragment as a cell with a few exceptions -->
			<xsl:element name="{$tag}"> 
				<xsl:choose>
					<!-- if only one simple hl7:paragraph node then unwrap -->
					<xsl:when test="(count($kids/*) = 1) and ($kids/hl7:paragraph) and not($kids/hl7:paragraph/hl7:caption)">
						<xsl:copy-of select="$kids/hl7:paragraph/node()"/>
					</xsl:when>

					<!-- hl7:td/th can nest everything but a hl7:table so if one is present need to wrap in a list -->
					<xsl:when test="$kids/hl7:table">
						<list>
							<xsl:for-each select="$kids/*">
								<item>
									<xsl:copy-of select="."/>
								</item>
							</xsl:for-each>
						</list>
					</xsl:when>

					<!-- otherwise copy nodes as is -->
					<xsl:otherwise>
						<xsl:copy-of select="$kids"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<!-- move on to the next column -->
			<xsl:call-template name="narrative-export-render-cols">
				<xsl:with-param name="cells" select="$cells"/>
				<xsl:with-param name="tag" select="$tag"/>
				<xsl:with-param name="col" select="$col + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- convert row text into list of cell nodes with column 
		input:  | Greeting | hello |
		        |          | world |
		output: <cell col="1">Greeting</cell>
		        <cell col="2">hello</cell>
						<cell col="1">        </cell>
						<cell col="2">world</cell>
	-->
	<xsl:template name="narrative-export-render-cells">
		<xsl:param name="row"/>
		<xsl:param name="segments"/>
		<xsl:variable name="line">
			<xsl:call-template name="narrative-export-first-piece">
				<xsl:with-param name="value" select="$row"/>
				<xsl:with-param name="delim" select="'&#10;'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length($line)">
			<xsl:for-each select="$segments/*">
				<cell col="{position()}">
					<xsl:value-of select="substring($line,@start,@length)"/>
				</cell>
			</xsl:for-each>
			<xsl:call-template name="narrative-export-render-cells">
				<xsl:with-param name="row" select="substring-after($row,'&#10;')"/>
				<xsl:with-param name="segments" select="$segments"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- convert inline markup to structured nodes (br, sup, linkHtml, footnoteRef) -->
	<xsl:template mode="narrative-export-render-inline" match="text()">
		<xsl:choose>
			<xsl:when test="contains(., '](')">
				<xsl:apply-templates mode="narrative-export-render-inline-linkHtml" select="."/>
			</xsl:when>
			<xsl:when test="contains(., '[^')">
				<xsl:apply-templates mode="narrative-export-render-inline-footnoteRef" select="."/>
			</xsl:when>
			<xsl:when test="contains(., '^')">
				<xsl:apply-templates mode="narrative-export-render-inline-sup" select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="narrative-export-render-lines">
					<xsl:with-param name="text" select="."/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- convert linefeed to br -->
	<xsl:template name="narrative-export-render-lines">
		<xsl:param name="text" />
		<xsl:choose>
			<xsl:when test="not(contains($text,'&#10;'))">
				<xsl:value-of select="$text"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($text,'&#10;')"/>
				<br/>
				<xsl:call-template name="narrative-export-render-lines">
					<xsl:with-param name="text" select="substring-after($text,'&#10;')"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- convert ^* into <sup>*</sup> -->
	<xsl:template mode="narrative-export-render-inline-sup" match="text()">
		<xsl:variable name="before" select="substring-before(., '^')"/>
		<xsl:variable name="after" select="substring-after(., '^')"/>
		<xsl:variable name="power">
			<xsl:call-template name="narrative-export-get-superscript">
				<xsl:with-param name="value" select="$after"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set($before)"/>

		<xsl:choose>
			<xsl:when test="string-length($power)">
				<sup><xsl:value-of select="$power"/></sup>
				<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set(substring($after, string-length($power) + 1))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>^</xsl:text>
				<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set($after)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- read valid superscript characters -->
	<xsl:template name="narrative-export-get-superscript">
		<xsl:param name="value"/>
		<xsl:if test="string-length($value)">
			<xsl:variable name="first" select="substring($value,1,1)"/>
			<xsl:if test="contains('0123456789.+-Ee',$first)">
				<xsl:value-of select="$first"/>
				<xsl:call-template name="narrative-export-get-superscript">
					<xsl:with-param name="value" select="substring($value,2)"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- convert [text](url) into <linkHtml href="url">text</linkHtml> -->
	<xsl:template mode="narrative-export-render-inline-linkHtml" match="text()">
		<xsl:variable name="before" select="substring-before(., '](')"/>
		<xsl:variable name="after" select="substring-after(., '](')"/>
		<xsl:variable name="text">
			<xsl:call-template name="narrative-export-last-piece">
				<xsl:with-param name="value" select="$before"/>
				<xsl:with-param name="delim" select="'['"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="href">
			<xsl:call-template name="narrative-export-first-piece">
				<xsl:with-param name="value" select="$after"/>
				<xsl:with-param name="delim" select="')'"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set(substring($before, 1, string-length($before) - string-length($text) - 1))"/>
		<xsl:text> </xsl:text>
		<linkHtml href="{$href}">
			<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set($text)"/>
		</linkHtml>
		<xsl:text> </xsl:text>
		<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set(substring-after($after,')'))"/>
	</xsl:template>

	<!-- convert [^*] into <footnoteRef IDREF="#uuid_*"/> -->
	<xsl:template mode="narrative-export-render-inline-footnoteRef" match="text()">
		<xsl:variable name="before" select="substring-before(., '[^')"/>
		<xsl:variable name="after" select="substring-after(., '[^')"/>
		<xsl:variable name="anchor">
			<xsl:call-template name="narrative-export-first-piece">
				<xsl:with-param name="value" select="$after"/>
				<xsl:with-param name="delim" select="']'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="uuid" select="isc:evaluate('varGet','narrativeIdPrefix',$anchor)"/>
		<xsl:variable name="prefix">
			<xsl:choose>
				<xsl:when test="string-length($uuid)">
					<xsl:value-of select="$uuid"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="uuidNew" select="isc:evaluate('createUUID')"/>
					<xsl:if test="isc:evaluate('varSet','narrativeIdPrefix',$anchor,$uuidNew)"/>
					<xsl:value-of select="$uuidNew"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set($before)"/>

		<footnoteRef IDREF="{concat('#',$prefix,'_',$anchor)}"/>
		<xsl:text> </xsl:text>

		<xsl:apply-templates mode="narrative-export-render-inline" select="exsl:node-set(substring-after($after,']'))"/>
	</xsl:template>

	<!-- breakup value into list, table, or paragraph chunks based on blank lines -->
	<xsl:template name="narrative-export-chunks">
		<xsl:param name="value" />
		<xsl:choose>
			<!-- value has blank line -->
			<xsl:when test="contains($value,'&#10;&#10;')">
				<xsl:variable name="before" select="substring-before($value,'&#10;&#10;')"/>
				<xsl:variable name="after" select="substring-after($value,'&#10;&#10;')"/>
				<xsl:variable name="second" select="substring-after($before, '&#10;')"/>

				<xsl:choose>
					<!-- allow blank lines in content when:
						- char after blank line is a space
						- first or second lines before blank line are a list bullet
						  OR fist line before blank is a footnote ruler
					-->
					<xsl:when test="(substring($after,1,1) = ' ') 
						and (   ((substring($before,1,3) = '  *') or (substring($before,1,3) = '  1'))
						     or ((substring($second,1,3) = '  *') or (substring($second,1,3) = '  1'))
						     or (substring($before,1,2) = '--'))">
						<xsl:call-template name="narrative-export-chunks">
							<xsl:with-param name="value" select="concat($before,'&#13;&#13;',$after)"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<chunk>
							<xsl:value-of select="translate($before,'&#13;','&#10;')"/>
						</chunk>
						<xsl:call-template name="narrative-export-chunks">
							<xsl:with-param name="value" select="$after"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<chunk>
					<xsl:value-of select="translate($value,'&#13;','&#10;')"/>
				</chunk>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- return last piece of a string (even if string doesn't contain delimiter)-->
	<xsl:template name="narrative-export-last-piece">
		<xsl:param name="value"/>
		<xsl:param name="delim" select="' '"/>
		<xsl:choose>
			<xsl:when test="not(contains($value,$delim))">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="narrative-export-last-piece">
					<xsl:with-param name="value" select="substring-after($value,$delim)"/>
					<xsl:with-param name="delim" select="$delim"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- return first piece of a string (even if it doesn't have delim unlike substring-before) -->
	<xsl:template name="narrative-export-first-piece" mode="narrative-export-first-piece" match="text()">
		<xsl:param name="value" select="."/>
		<xsl:param name="delim" select="' '"/>
		<xsl:choose>
			<xsl:when test="not(contains($value,$delim))">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($value,$delim)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- copied from System/Common/String-Functions.xsl to avoid any back-compat issues -->
	<xsl:template name="narrative-export-replace-string">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="with"/>
		<xsl:variable name="stringText" select="string($text)"/>
		<xsl:choose>
			<xsl:when test="contains($stringText,$replace)">
				<xsl:value-of select="substring-before($stringText,$replace)"/>
				<xsl:value-of select="$with"/>
				<xsl:call-template name="narrative-export-replace-string">
					<xsl:with-param name="text" select="substring-after($stringText,$replace)"/>
					<xsl:with-param name="replace" select="$replace"/>
					<xsl:with-param name="with" select="$with"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$stringText"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- remove leading chars from each line in given value -->
	<xsl:template name="narrative-export-outdent">
		<xsl:param name="value"/>
		<xsl:param name="start"/>

		<xsl:if test="string-length($value)">
			<xsl:variable name="first">
				<xsl:call-template name="narrative-export-first-piece">
					<xsl:with-param name="value" select="$value"/>
					<xsl:with-param name="delim" select="'&#10;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="rest" select="substring-after($value, '&#10;')"/>

			<xsl:value-of select="substring($first, $start)"/>
			<xsl:if test="string-length($rest)">
				<xsl:text>&#10;</xsl:text>
				<xsl:call-template name="narrative-export-outdent">
					<xsl:with-param name="value" select="substring-after($value, '&#10;')"/>
					<xsl:with-param name="start" select="$start"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- FUTURE: find common place for functions shared by import/export -->
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
