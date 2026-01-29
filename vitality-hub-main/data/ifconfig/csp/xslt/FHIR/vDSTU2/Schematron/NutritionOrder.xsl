<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->

	<xsl:param name="includeSuccessfulTests" select="'0'"/>

	<xsl:output indent="no" method="text" media-type="application/json"/>

	<xsl:template match="/">
		<xsl:text>{"result":[</xsl:text>
		<xsl:apply-templates select="f:NutritionOrder"/>
		<xsl:apply-templates select="f:NutritionOrder/f:text/h:div"/>
		<xsl:apply-templates select="f:NutritionOrder/f:patient"/>
		<xsl:apply-templates select="f:NutritionOrder/f:orderer"/>
		<xsl:apply-templates select="f:NutritionOrder/f:identifier/f:period"/>
		<xsl:apply-templates select="f:NutritionOrder/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:NutritionOrder/f:encounter"/>
		<xsl:apply-templates select="f:NutritionOrder/f:allergyIntolerance"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsQuantity"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange/f:low"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange/f:high"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsPeriod"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:duration"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:period"/>
		<xsl:apply-templates select="f:NutritionOrder/f:oralDiet/f:nutrient/f:amount"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:schedule/f:repeat"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsQuantity"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange/f:low"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange/f:high"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsPeriod"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:duration"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:period"/>
		<xsl:apply-templates select="f:NutritionOrder/f:supplement/f:quantity"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:caloricDensity"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsQuantity"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange/f:low"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange/f:high"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsPeriod"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:duration"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:period"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:quantity"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:rateQuantity"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio/f:numerator"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio/f:denominator"/>
		<xsl:apply-templates select="f:NutritionOrder/f:enteralFormula/f:maxVolumeToDeliver"/>
		<xsl:text>{"status":0}</xsl:text>
		<xsl:text>]}</xsl:text>
	</xsl:template>

	<xsl:template match="f:NutritionOrder">
		<xsl:choose>
			<xsl:when test="not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder",</xsl:text>
					<xsl:text>"assert":"not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))",</xsl:text>
					<xsl:text>"text":"dom-4: If a resource is contained in another resource, it SHALL NOT have a meta.versionId or a meta.lastUpdated",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder",</xsl:text>
				<xsl:text>"assert":"not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))",</xsl:text>
				<xsl:text>"text":"dom-4: If a resource is contained in another resource, it SHALL NOT have a meta.versionId or a meta.lastUpdated",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder",</xsl:text>
					<xsl:text>"assert":"not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))",</xsl:text>
					<xsl:text>"text":"dom-3: If the resource is contained in another resource, it SHALL be referred to from elsewhere in the resource",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder",</xsl:text>
				<xsl:text>"assert":"not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))",</xsl:text>
				<xsl:text>"text":"dom-3: If the resource is contained in another resource, it SHALL be referred to from elsewhere in the resource",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(parent::f:contained and f:contained)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder",</xsl:text>
					<xsl:text>"assert":"not(parent::f:contained and f:contained)",</xsl:text>
					<xsl:text>"text":"dom-2: If the resource is contained in another resource, it SHALL NOT contain nested Resources",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder",</xsl:text>
				<xsl:text>"assert":"not(parent::f:contained and f:contained)",</xsl:text>
				<xsl:text>"text":"dom-2: If the resource is contained in another resource, it SHALL NOT contain nested Resources",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(parent::f:contained and f:text)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder",</xsl:text>
					<xsl:text>"assert":"not(parent::f:contained and f:text)",</xsl:text>
					<xsl:text>"text":"dom-1: If the resource is contained in another resource, it SHALL NOT contain any narrative",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder",</xsl:text>
				<xsl:text>"assert":"not(parent::f:contained and f:text)",</xsl:text>
				<xsl:text>"text":"dom-1: If the resource is contained in another resource, it SHALL NOT contain any narrative",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="exists(f:oralDiet) or exists(f:supplement) or exists(f:enteralFormula)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder",</xsl:text>
					<xsl:text>"assert":"exists(f:oralDiet) or exists(f:supplement) or exists(f:enteralFormula)",</xsl:text>
					<xsl:text>"text":"nor-1: Nutrition Order SHALL contain either Oral Diet , Supplement, or Enteral Formula class",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder",</xsl:text>
				<xsl:text>"assert":"exists(f:oralDiet) or exists(f:supplement) or exists(f:enteralFormula)",</xsl:text>
				<xsl:text>"text":"nor-1: Nutrition Order SHALL contain either Oral Diet , Supplement, or Enteral Formula class",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:text/h:div">
		<xsl:choose>
			<xsl:when test="descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]",</xsl:text>
					<xsl:text>"text":"txt-2: The narrative SHALL have some non-whitespace content",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]",</xsl:text>
				<xsl:text>"text":"txt-2: The narrative SHALL have some non-whitespace content",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])",</xsl:text>
					<xsl:text>"text":"txt-1: The narrative SHALL contain only the basic html formatting elements described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])",</xsl:text>
				<xsl:text>"text":"txt-1: The narrative SHALL contain only the basic html formatting elements described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])",</xsl:text>
					<xsl:text>"text":"txt-3: The narrative SHALL contain only the basic html formatting attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])",</xsl:text>
				<xsl:text>"text":"txt-3: The narrative SHALL contain only the basic html formatting attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:patient">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:patient",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:patient",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:orderer">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:orderer",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:orderer",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:identifier/f:period">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:identifier/f:period",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:identifier/f:period",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:identifier/f:assigner">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:identifier/f:assigner",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:identifier/f:assigner",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:encounter">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:encounter",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:encounter",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:allergyIntolerance">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:allergyIntolerance",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:allergyIntolerance",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat">
		<xsl:choose>
			<xsl:when test="not(exists(f:frequency)) or not(exists(f:when))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:frequency)) or not(exists(f:when))",</xsl:text>
					<xsl:text>"text":"tim-3: Either frequency or when can exist, not both",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:frequency)) or not(exists(f:when))",</xsl:text>
				<xsl:text>"text":"tim-3: Either frequency or when can exist, not both",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:duration)) or exists(f:durationUnits)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:duration)) or exists(f:durationUnits)",</xsl:text>
					<xsl:text>"text":"tim-1: if there&apos;s a duration, there needs to be duration units",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:duration)) or exists(f:durationUnits)",</xsl:text>
				<xsl:text>"text":"tim-1: if there&apos;s a duration, there needs to be duration units",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:period)) or exists(f:periodUnits)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:period)) or exists(f:periodUnits)",</xsl:text>
					<xsl:text>"text":"tim-2: if there&apos;s a period, there needs to be period units",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:period)) or exists(f:periodUnits)",</xsl:text>
				<xsl:text>"text":"tim-2: if there&apos;s a period, there needs to be period units",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:periodMax)) or exists(f:period)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:periodMax)) or exists(f:period)",</xsl:text>
					<xsl:text>"text":"tim-6: If there&apos;s a periodMax, there must be a period",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:periodMax)) or exists(f:period)",</xsl:text>
				<xsl:text>"text":"tim-6: If there&apos;s a periodMax, there must be a period",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:durationMax)) or exists(f:duration)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:durationMax)) or exists(f:duration)",</xsl:text>
					<xsl:text>"text":"tim-7: If there&apos;s a durationMax, there must be a duration",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:durationMax)) or exists(f:duration)",</xsl:text>
				<xsl:text>"text":"tim-7: If there&apos;s a durationMax, there must be a duration",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange">
		<xsl:choose>
			<xsl:when test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange",</xsl:text>
					<xsl:text>"assert":"not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))",</xsl:text>
					<xsl:text>"text":"rng-2: If present, low SHALL have a lower value than high",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange",</xsl:text>
				<xsl:text>"assert":"not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))",</xsl:text>
				<xsl:text>"text":"rng-2: If present, low SHALL have a lower value than high",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange/f:low">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange/f:low",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange/f:low",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange/f:high">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange/f:high",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsRange/f:high",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsPeriod">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsPeriod",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:boundsPeriod",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:duration">
		<xsl:choose>
			<xsl:when test="@value &gt;= 0 or not(@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:duration",</xsl:text>
					<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
					<xsl:text>"text":"tim-4: duration SHALL be a non-negative value",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:duration",</xsl:text>
				<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
				<xsl:text>"text":"tim-4: duration SHALL be a non-negative value",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:period">
		<xsl:choose>
			<xsl:when test="@value &gt;= 0 or not(@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:period",</xsl:text>
					<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
					<xsl:text>"text":"tim-5: period SHALL be a non-negative value",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:schedule/f:repeat/f:period",</xsl:text>
				<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
				<xsl:text>"text":"tim-5: period SHALL be a non-negative value",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:oralDiet/f:nutrient/f:amount">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:nutrient/f:amount",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:oralDiet/f:nutrient/f:amount",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:schedule/f:repeat">
		<xsl:choose>
			<xsl:when test="not(exists(f:frequency)) or not(exists(f:when))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:frequency)) or not(exists(f:when))",</xsl:text>
					<xsl:text>"text":"tim-3: Either frequency or when can exist, not both",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:frequency)) or not(exists(f:when))",</xsl:text>
				<xsl:text>"text":"tim-3: Either frequency or when can exist, not both",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:duration)) or exists(f:durationUnits)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:duration)) or exists(f:durationUnits)",</xsl:text>
					<xsl:text>"text":"tim-1: if there&apos;s a duration, there needs to be duration units",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:duration)) or exists(f:durationUnits)",</xsl:text>
				<xsl:text>"text":"tim-1: if there&apos;s a duration, there needs to be duration units",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:period)) or exists(f:periodUnits)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:period)) or exists(f:periodUnits)",</xsl:text>
					<xsl:text>"text":"tim-2: if there&apos;s a period, there needs to be period units",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:period)) or exists(f:periodUnits)",</xsl:text>
				<xsl:text>"text":"tim-2: if there&apos;s a period, there needs to be period units",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:periodMax)) or exists(f:period)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:periodMax)) or exists(f:period)",</xsl:text>
					<xsl:text>"text":"tim-6: If there&apos;s a periodMax, there must be a period",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:periodMax)) or exists(f:period)",</xsl:text>
				<xsl:text>"text":"tim-6: If there&apos;s a periodMax, there must be a period",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:durationMax)) or exists(f:duration)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:durationMax)) or exists(f:duration)",</xsl:text>
					<xsl:text>"text":"tim-7: If there&apos;s a durationMax, there must be a duration",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:durationMax)) or exists(f:duration)",</xsl:text>
				<xsl:text>"text":"tim-7: If there&apos;s a durationMax, there must be a duration",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange">
		<xsl:choose>
			<xsl:when test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange",</xsl:text>
					<xsl:text>"assert":"not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))",</xsl:text>
					<xsl:text>"text":"rng-2: If present, low SHALL have a lower value than high",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange",</xsl:text>
				<xsl:text>"assert":"not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))",</xsl:text>
				<xsl:text>"text":"rng-2: If present, low SHALL have a lower value than high",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange/f:low">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange/f:low",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange/f:low",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange/f:high">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange/f:high",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsRange/f:high",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsPeriod">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsPeriod",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:boundsPeriod",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:duration">
		<xsl:choose>
			<xsl:when test="@value &gt;= 0 or not(@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:duration",</xsl:text>
					<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
					<xsl:text>"text":"tim-4: duration SHALL be a non-negative value",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:duration",</xsl:text>
				<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
				<xsl:text>"text":"tim-4: duration SHALL be a non-negative value",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:period">
		<xsl:choose>
			<xsl:when test="@value &gt;= 0 or not(@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:period",</xsl:text>
					<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
					<xsl:text>"text":"tim-5: period SHALL be a non-negative value",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:schedule/f:repeat/f:period",</xsl:text>
				<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
				<xsl:text>"text":"tim-5: period SHALL be a non-negative value",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:supplement/f:quantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:supplement/f:quantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:supplement/f:quantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:caloricDensity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:caloricDensity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:caloricDensity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat">
		<xsl:choose>
			<xsl:when test="not(exists(f:frequency)) or not(exists(f:when))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:frequency)) or not(exists(f:when))",</xsl:text>
					<xsl:text>"text":"tim-3: Either frequency or when can exist, not both",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:frequency)) or not(exists(f:when))",</xsl:text>
				<xsl:text>"text":"tim-3: Either frequency or when can exist, not both",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:duration)) or exists(f:durationUnits)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:duration)) or exists(f:durationUnits)",</xsl:text>
					<xsl:text>"text":"tim-1: if there&apos;s a duration, there needs to be duration units",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:duration)) or exists(f:durationUnits)",</xsl:text>
				<xsl:text>"text":"tim-1: if there&apos;s a duration, there needs to be duration units",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:period)) or exists(f:periodUnits)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:period)) or exists(f:periodUnits)",</xsl:text>
					<xsl:text>"text":"tim-2: if there&apos;s a period, there needs to be period units",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:period)) or exists(f:periodUnits)",</xsl:text>
				<xsl:text>"text":"tim-2: if there&apos;s a period, there needs to be period units",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:periodMax)) or exists(f:period)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:periodMax)) or exists(f:period)",</xsl:text>
					<xsl:text>"text":"tim-6: If there&apos;s a periodMax, there must be a period",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:periodMax)) or exists(f:period)",</xsl:text>
				<xsl:text>"text":"tim-6: If there&apos;s a periodMax, there must be a period",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:durationMax)) or exists(f:duration)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
					<xsl:text>"assert":"not(exists(f:durationMax)) or exists(f:duration)",</xsl:text>
					<xsl:text>"text":"tim-7: If there&apos;s a durationMax, there must be a duration",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat",</xsl:text>
				<xsl:text>"assert":"not(exists(f:durationMax)) or exists(f:duration)",</xsl:text>
				<xsl:text>"text":"tim-7: If there&apos;s a durationMax, there must be a duration",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange">
		<xsl:choose>
			<xsl:when test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange",</xsl:text>
					<xsl:text>"assert":"not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))",</xsl:text>
					<xsl:text>"text":"rng-2: If present, low SHALL have a lower value than high",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange",</xsl:text>
				<xsl:text>"assert":"not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))",</xsl:text>
				<xsl:text>"text":"rng-2: If present, low SHALL have a lower value than high",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange/f:low">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange/f:low",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange/f:low",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange/f:high">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange/f:high",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsRange/f:high",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsPeriod">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsPeriod",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:boundsPeriod",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:duration">
		<xsl:choose>
			<xsl:when test="@value &gt;= 0 or not(@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:duration",</xsl:text>
					<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
					<xsl:text>"text":"tim-4: duration SHALL be a non-negative value",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:duration",</xsl:text>
				<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
				<xsl:text>"text":"tim-4: duration SHALL be a non-negative value",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:period">
		<xsl:choose>
			<xsl:when test="@value &gt;= 0 or not(@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:period",</xsl:text>
					<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
					<xsl:text>"text":"tim-5: period SHALL be a non-negative value",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:schedule/f:repeat/f:period",</xsl:text>
				<xsl:text>"assert":"@value &gt;= 0 or not(@value)",</xsl:text>
				<xsl:text>"text":"tim-5: period SHALL be a non-negative value",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:quantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:quantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:quantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:rateQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:rateQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:rateQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio">
		<xsl:choose>
			<xsl:when test="(count(f:numerator) = count(f:denominator)) and ((count(f:numerator) &gt; 0) or (count(f:extension) &gt; 0))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio",</xsl:text>
					<xsl:text>"assert":"(count(f:numerator) = count(f:denominator)) and ((count(f:numerator) &gt; 0) or (count(f:extension) &gt; 0))",</xsl:text>
					<xsl:text>"text":"rat-1: Numerator and denominator SHALL both be present, or both are absent. If both are absent, there SHALL be some extension present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio",</xsl:text>
				<xsl:text>"assert":"(count(f:numerator) = count(f:denominator)) and ((count(f:numerator) &gt; 0) or (count(f:extension) &gt; 0))",</xsl:text>
				<xsl:text>"text":"rat-1: Numerator and denominator SHALL both be present, or both are absent. If both are absent, there SHALL be some extension present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio/f:numerator">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio/f:numerator",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio/f:numerator",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio/f:denominator">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio/f:denominator",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:administration/f:rateRatio/f:denominator",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:NutritionOrder/f:enteralFormula/f:maxVolumeToDeliver">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:maxVolumeToDeliver",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:NutritionOrder/f:enteralFormula/f:maxVolumeToDeliver",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
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
