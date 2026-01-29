<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->

	<xsl:param name="includeSuccessfulTests" select="'0'"/>

	<xsl:output indent="no" method="text" media-type="application/json"/>

	<xsl:template match="/">
		<xsl:text>{"result":[</xsl:text>
		<xsl:apply-templates select="f:TestScript"/>
		<xsl:apply-templates select="f:TestScript/f:text/h:div"/>
		<xsl:apply-templates select="f:TestScript/f:identifier/f:period"/>
		<xsl:apply-templates select="f:TestScript/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:TestScript/f:contact/f:telecom"/>
		<xsl:apply-templates select="f:TestScript/f:contact/f:telecom/f:period"/>
		<xsl:apply-templates select="f:TestScript/f:metadata"/>
		<xsl:apply-templates select="f:TestScript/f:metadata/f:capability/f:conformance"/>
		<xsl:apply-templates select="f:TestScript/f:fixture/f:resource"/>
		<xsl:apply-templates select="f:TestScript/f:profile"/>
		<xsl:apply-templates select="f:TestScript/f:variable"/>
		<xsl:apply-templates select="f:TestScript/f:setup/f:metadata"/>
		<xsl:apply-templates select="f:TestScript/f:setup/f:action"/>
		<xsl:apply-templates select="f:TestScript/f:setup/f:action/f:operation"/>
		<xsl:apply-templates select="f:TestScript/f:setup/f:action/f:assert"/>
		<xsl:apply-templates select="f:TestScript/f:test/f:metadata"/>
		<xsl:apply-templates select="f:TestScript/f:test/f:action"/>
		<xsl:apply-templates select="f:TestScript/f:test/f:action/f:operation"/>
		<xsl:apply-templates select="f:TestScript/f:test/f:action/f:assert"/>
		<xsl:apply-templates select="f:TestScript/f:teardown/f:action"/>
		<xsl:apply-templates select="f:TestScript/f:teardown/f:action/f:operation"/>
		<xsl:text>{"status":0}</xsl:text>
		<xsl:text>]}</xsl:text>
	</xsl:template>

	<xsl:template match="f:TestScript">
		<xsl:choose>
			<xsl:when test="not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript",</xsl:text>
					<xsl:text>"assert":"not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))",</xsl:text>
					<xsl:text>"text":"dom-4: If a resource is contained in another resource, it SHALL NOT have a meta.versionId or a meta.lastUpdated",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript",</xsl:text>
				<xsl:text>"assert":"not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))",</xsl:text>
				<xsl:text>"text":"dom-4: If a resource is contained in another resource, it SHALL NOT have a meta.versionId or a meta.lastUpdated",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript",</xsl:text>
					<xsl:text>"assert":"not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))",</xsl:text>
					<xsl:text>"text":"dom-3: If the resource is contained in another resource, it SHALL be referred to from elsewhere in the resource",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript",</xsl:text>
				<xsl:text>"assert":"not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))",</xsl:text>
				<xsl:text>"text":"dom-3: If the resource is contained in another resource, it SHALL be referred to from elsewhere in the resource",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(parent::f:contained and f:contained)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript",</xsl:text>
					<xsl:text>"assert":"not(parent::f:contained and f:contained)",</xsl:text>
					<xsl:text>"text":"dom-2: If the resource is contained in another resource, it SHALL NOT contain nested Resources",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript",</xsl:text>
				<xsl:text>"assert":"not(parent::f:contained and f:contained)",</xsl:text>
				<xsl:text>"text":"dom-2: If the resource is contained in another resource, it SHALL NOT contain nested Resources",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(parent::f:contained and f:text)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript",</xsl:text>
					<xsl:text>"assert":"not(parent::f:contained and f:text)",</xsl:text>
					<xsl:text>"text":"dom-1: If the resource is contained in another resource, it SHALL NOT contain any narrative",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript",</xsl:text>
				<xsl:text>"assert":"not(parent::f:contained and f:text)",</xsl:text>
				<xsl:text>"text":"dom-1: If the resource is contained in another resource, it SHALL NOT contain any narrative",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:text/h:div">
		<xsl:choose>
			<xsl:when test="descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]",</xsl:text>
					<xsl:text>"text":"txt-2: The narrative SHALL have some non-whitespace content",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]",</xsl:text>
				<xsl:text>"text":"txt-2: The narrative SHALL have some non-whitespace content",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])",</xsl:text>
					<xsl:text>"text":"txt-1: The narrative SHALL contain only the basic html formatting elements described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])",</xsl:text>
				<xsl:text>"text":"txt-1: The narrative SHALL contain only the basic html formatting elements described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])",</xsl:text>
					<xsl:text>"text":"txt-3: The narrative SHALL contain only the basic html formatting attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])",</xsl:text>
				<xsl:text>"text":"txt-3: The narrative SHALL contain only the basic html formatting attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:identifier/f:period">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:identifier/f:period",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:identifier/f:period",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:identifier/f:assigner">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:identifier/f:assigner",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:identifier/f:assigner",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:contact/f:telecom">
		<xsl:choose>
			<xsl:when test="not(exists(f:value)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:contact/f:telecom",</xsl:text>
					<xsl:text>"assert":"not(exists(f:value)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"cpt-2: A system is required if a value is provided.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:contact/f:telecom",</xsl:text>
				<xsl:text>"assert":"not(exists(f:value)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"cpt-2: A system is required if a value is provided.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:contact/f:telecom/f:period">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:contact/f:telecom/f:period",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:contact/f:telecom/f:period",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:metadata">
		<xsl:choose>
			<xsl:when test="f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:metadata",</xsl:text>
					<xsl:text>"assert":"f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)",</xsl:text>
					<xsl:text>"text":"inv-5: TestScript metadata capability SHALL contain required or validated or both.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:metadata",</xsl:text>
				<xsl:text>"assert":"f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)",</xsl:text>
				<xsl:text>"text":"inv-5: TestScript metadata capability SHALL contain required or validated or both.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:metadata/f:capability/f:conformance">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:metadata/f:capability/f:conformance",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:metadata/f:capability/f:conformance",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:fixture/f:resource">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:fixture/f:resource",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:fixture/f:resource",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:profile">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:profile",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:profile",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:variable">
		<xsl:choose>
			<xsl:when test="not(f:headerField and f:path)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:variable",</xsl:text>
					<xsl:text>"assert":"not(f:headerField and f:path)",</xsl:text>
					<xsl:text>"text":"inv-4: Variable cannot contain both headerField and path.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:variable",</xsl:text>
				<xsl:text>"assert":"not(f:headerField and f:path)",</xsl:text>
				<xsl:text>"text":"inv-4: Variable cannot contain both headerField and path.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:setup/f:metadata">
		<xsl:choose>
			<xsl:when test="f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:setup/f:metadata",</xsl:text>
					<xsl:text>"assert":"f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)",</xsl:text>
					<xsl:text>"text":"inv-6: Setup metadata capability SHALL contain required or validated or both.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:setup/f:metadata",</xsl:text>
				<xsl:text>"assert":"f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)",</xsl:text>
				<xsl:text>"text":"inv-6: Setup metadata capability SHALL contain required or validated or both.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:setup/f:action">
		<xsl:choose>
			<xsl:when test="(f:operation or f:assert) and not(f:operation and f:assert)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:setup/f:action",</xsl:text>
					<xsl:text>"assert":"(f:operation or f:assert) and not(f:operation and f:assert)",</xsl:text>
					<xsl:text>"text":"inv-1: Setup action SHALL contain either an operation or assert but not both.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:setup/f:action",</xsl:text>
				<xsl:text>"assert":"(f:operation or f:assert) and not(f:operation and f:assert)",</xsl:text>
				<xsl:text>"text":"inv-1: Setup action SHALL contain either an operation or assert but not both.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:setup/f:action/f:operation">
		<xsl:choose>
			<xsl:when test="f:sourceId or ((f:targetId or f:url or f:params) and (count(f:targetId) + count(f:url) + count(f:params) =1)) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:setup/f:action/f:operation",</xsl:text>
					<xsl:text>"assert":"f:sourceId or ((f:targetId or f:url or f:params) and (count(f:targetId) + count(f:url) + count(f:params) =1)) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)",</xsl:text>
					<xsl:text>"text":"inv-10: Setup operation SHALL contain either sourceId or targetId or params or url.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:setup/f:action/f:operation",</xsl:text>
				<xsl:text>"assert":"f:sourceId or ((f:targetId or f:url or f:params) and (count(f:targetId) + count(f:url) + count(f:params) =1)) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)",</xsl:text>
				<xsl:text>"text":"inv-10: Setup operation SHALL contain either sourceId or targetId or params or url.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:setup/f:action/f:assert">
		<xsl:choose>
			<xsl:when test="(f:compareToSourceId and f:compareToSourcePath) or not(f:compareToSourceId or f:compareToSourcePath)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:setup/f:action/f:assert",</xsl:text>
					<xsl:text>"assert":"(f:compareToSourceId and f:compareToSourcePath) or not(f:compareToSourceId or f:compareToSourcePath)",</xsl:text>
					<xsl:text>"text":"inv-13: Setup action assert shall contain both compareToSourceId and compareToSourcePath or neither.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:setup/f:action/f:assert",</xsl:text>
				<xsl:text>"assert":"(f:compareToSourceId and f:compareToSourcePath) or not(f:compareToSourceId or f:compareToSourcePath)",</xsl:text>
				<xsl:text>"text":"inv-13: Setup action assert shall contain both compareToSourceId and compareToSourcePath or neither.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(f:contentType) + count(f:headerField) + count(f:minimumId) + count(f:navigationLinks) + count(f:path) + count(f:resource) + count(f:responseCode) + count(f:response) + count(f:validateProfileId)  &lt;=1">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:setup/f:action/f:assert",</xsl:text>
					<xsl:text>"assert":"count(f:contentType) + count(f:headerField) + count(f:minimumId) + count(f:navigationLinks) + count(f:path) + count(f:resource) + count(f:responseCode) + count(f:response) + count(f:validateProfileId)  &lt;=1",</xsl:text>
					<xsl:text>"text":"inv-8: Only a single assertion SHALL be present within setup action assert element.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:setup/f:action/f:assert",</xsl:text>
				<xsl:text>"assert":"count(f:contentType) + count(f:headerField) + count(f:minimumId) + count(f:navigationLinks) + count(f:path) + count(f:resource) + count(f:responseCode) + count(f:response) + count(f:validateProfileId)  &lt;=1",</xsl:text>
				<xsl:text>"text":"inv-8: Only a single assertion SHALL be present within setup action assert element.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:test/f:metadata">
		<xsl:choose>
			<xsl:when test="f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:test/f:metadata",</xsl:text>
					<xsl:text>"assert":"f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)",</xsl:text>
					<xsl:text>"text":"inv-7: Test metadata capability SHALL contain required or validated or both.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:test/f:metadata",</xsl:text>
				<xsl:text>"assert":"f:capability/f:required or f:capability/f:validated or (f:capability/f:required and f:capability/f:validated)",</xsl:text>
				<xsl:text>"text":"inv-7: Test metadata capability SHALL contain required or validated or both.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:test/f:action">
		<xsl:choose>
			<xsl:when test="(f:operation or f:assert) and not(f:operation and f:assert)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:test/f:action",</xsl:text>
					<xsl:text>"assert":"(f:operation or f:assert) and not(f:operation and f:assert)",</xsl:text>
					<xsl:text>"text":"inv-2: Test action SHALL contain either an operation or assert but not both.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:test/f:action",</xsl:text>
				<xsl:text>"assert":"(f:operation or f:assert) and not(f:operation and f:assert)",</xsl:text>
				<xsl:text>"text":"inv-2: Test action SHALL contain either an operation or assert but not both.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:test/f:action/f:operation">
		<xsl:choose>
			<xsl:when test="f:sourceId or (f:targetId or f:url or f:params) and (count(f:targetId) + count(f:url) + count(f:params) =1) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:test/f:action/f:operation",</xsl:text>
					<xsl:text>"assert":"f:sourceId or (f:targetId or f:url or f:params) and (count(f:targetId) + count(f:url) + count(f:params) =1) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)",</xsl:text>
					<xsl:text>"text":"inv-11: Test operation SHALL contain either sourceId or targetId or params or url.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:test/f:action/f:operation",</xsl:text>
				<xsl:text>"assert":"f:sourceId or (f:targetId or f:url or f:params) and (count(f:targetId) + count(f:url) + count(f:params) =1) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)",</xsl:text>
				<xsl:text>"text":"inv-11: Test operation SHALL contain either sourceId or targetId or params or url.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:test/f:action/f:assert">
		<xsl:choose>
			<xsl:when test="(f:compareToSourceId and f:compareToSourcePath) or not(f:compareToSourceId or f:compareToSourcePath)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:test/f:action/f:assert",</xsl:text>
					<xsl:text>"assert":"(f:compareToSourceId and f:compareToSourcePath) or not(f:compareToSourceId or f:compareToSourcePath)",</xsl:text>
					<xsl:text>"text":"inv-14: Test action assert shall contain both compareToSourceId and compareToSourcePath or neither.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:test/f:action/f:assert",</xsl:text>
				<xsl:text>"assert":"(f:compareToSourceId and f:compareToSourcePath) or not(f:compareToSourceId or f:compareToSourcePath)",</xsl:text>
				<xsl:text>"text":"inv-14: Test action assert shall contain both compareToSourceId and compareToSourcePath or neither.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(f:contentType) + count(f:headerField) + count(f:minimumId) + count(f:navigationLinks) + count(f:path) + count(f:resource) + count(f:responseCode) + count(f:response) + count(f:validateProfileId)  &lt;=1">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:test/f:action/f:assert",</xsl:text>
					<xsl:text>"assert":"count(f:contentType) + count(f:headerField) + count(f:minimumId) + count(f:navigationLinks) + count(f:path) + count(f:resource) + count(f:responseCode) + count(f:response) + count(f:validateProfileId)  &lt;=1",</xsl:text>
					<xsl:text>"text":"inv-9: Only a single assertion SHALL be present within test action assert element.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:test/f:action/f:assert",</xsl:text>
				<xsl:text>"assert":"count(f:contentType) + count(f:headerField) + count(f:minimumId) + count(f:navigationLinks) + count(f:path) + count(f:resource) + count(f:responseCode) + count(f:response) + count(f:validateProfileId)  &lt;=1",</xsl:text>
				<xsl:text>"text":"inv-9: Only a single assertion SHALL be present within test action assert element.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:teardown/f:action">
		<xsl:choose>
			<xsl:when test="f:operation">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:teardown/f:action",</xsl:text>
					<xsl:text>"assert":"f:operation",</xsl:text>
					<xsl:text>"text":"inv-3: Teardown action SHALL contain an operation.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:teardown/f:action",</xsl:text>
				<xsl:text>"assert":"f:operation",</xsl:text>
				<xsl:text>"text":"inv-3: Teardown action SHALL contain an operation.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:TestScript/f:teardown/f:action/f:operation">
		<xsl:choose>
			<xsl:when test="f:sourceId or (f:targetId or f:url or (f:params and f:resource)) and (count(f:targetId) + count(f:url) + count(f:params) =1) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:TestScript/f:teardown/f:action/f:operation",</xsl:text>
					<xsl:text>"assert":"f:sourceId or (f:targetId or f:url or (f:params and f:resource)) and (count(f:targetId) + count(f:url) + count(f:params) =1) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)",</xsl:text>
					<xsl:text>"text":"inv-12: Teardown operation SHALL contain either sourceId or targetId or params or url.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:TestScript/f:teardown/f:action/f:operation",</xsl:text>
				<xsl:text>"assert":"f:sourceId or (f:targetId or f:url or (f:params and f:resource)) and (count(f:targetId) + count(f:url) + count(f:params) =1) or (f:type/f:code/@value=&apos;conformance&apos; or f:type/f:code/@value=&apos;search&apos; or f:type/f:code/@value=&apos;transaction&apos; or f:type/f:code/@value=&apos;history&apos;)",</xsl:text>
				<xsl:text>"text":"inv-12: Teardown operation SHALL contain either sourceId or targetId or params or url.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="currentXPath">
		<xsl:param name="includePosition" select="'0'"/>
		<xsl:variable name="currentName" select="local-name()"/>
		<xsl:variable name="currentPosition" select="count(self::*/preceding-sibling::*[name()=$currentName]) + 1"/>
		<xsl:if test="not(local-name()=name(parent::node())) and string-length(name(parent::node()))">
			<xsl:apply-templates select=".." mode="currentXPath">
				<xsl:with-param name="includePosition" select="$includePosition"/>
				</xsl:apply-templates>
			</xsl:if>
			<xsl:variable name="namespacePrefix">
				<xsl:choose>
					<xsl:when test="namespace-uri()='http://hl7.org/fhir'">/f:</xsl:when>
					<xsl:otherwise>/h:</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="$namespacePrefix"/>
			<xsl:value-of select="local-name()"/>
			<xsl:if test="$includePosition='1'">
				<xsl:value-of select="concat('[',$currentPosition,']')"/>
			</xsl:if>
	</xsl:template>
	
	<!--
		currentXPathWithPos provides a shorthand way of
		using currentXPath without having to include the
		with-param to explictly specify includePosition=1
		in the apply-templates call.
	-->
	<xsl:template match="*" mode="currentXPathWithPos">
		<xsl:apply-templates select="." mode="currentXPath">
			<xsl:with-param name="includePosition" select="'1'"/>
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
