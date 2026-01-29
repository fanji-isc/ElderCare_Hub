<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->

	<xsl:param name="includeSuccessfulTests" select="'0'"/>

	<xsl:output indent="no" method="text" media-type="application/json"/>

	<xsl:template match="/">
		<xsl:text>{"result":[</xsl:text>
		<xsl:apply-templates select="f:Bundle"/>
		<xsl:apply-templates select="f:Bundle/f:entry"/>
		<xsl:apply-templates select="f:Bundle/f:signature/f:whoReference"/>
		<xsl:text>{"status":0}</xsl:text>
		<xsl:text>]}</xsl:text>
	</xsl:template>

	<xsl:template match="f:Bundle">
		<xsl:choose>
			<xsl:when test="not(f:entry/f:search) or (f:type/@value = &apos;searchset&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Bundle",</xsl:text>
					<xsl:text>"assert":"not(f:entry/f:search) or (f:type/@value = &apos;searchset&apos;)",</xsl:text>
					<xsl:text>"text":"bdl-2: entry.search only when a search",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Bundle",</xsl:text>
				<xsl:text>"assert":"not(f:entry/f:search) or (f:type/@value = &apos;searchset&apos;)",</xsl:text>
				<xsl:text>"text":"bdl-2: entry.search only when a search",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(f:total) or (f:type/@value = &apos;searchset&apos;) or (f:type/@value = &apos;history&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Bundle",</xsl:text>
					<xsl:text>"assert":"not(f:total) or (f:type/@value = &apos;searchset&apos;) or (f:type/@value = &apos;history&apos;)",</xsl:text>
					<xsl:text>"text":"bdl-1: total only when a search or history",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Bundle",</xsl:text>
				<xsl:text>"assert":"not(f:total) or (f:type/@value = &apos;searchset&apos;) or (f:type/@value = &apos;history&apos;)",</xsl:text>
				<xsl:text>"text":"bdl-1: total only when a search or history",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(for $entry in f:entry[f:resource] return $entry[count(parent::f:Bundle/f:entry[f:fullUrl/@value=$entry/f:fullUrl/@value and ((not(f:resource/*/f:meta/f:versionId/@value) and not($entry/f:resource/*/f:meta/f:versionId/@value)) or f:resource/*/f:meta/f:versionId/@value=$entry/f:resource/*/f:meta/f:versionId/@value)])!=1])=0">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Bundle",</xsl:text>
					<xsl:text>"assert":"count(for $entry in f:entry[f:resource] return $entry[count(parent::f:Bundle/f:entry[f:fullUrl/@value=$entry/f:fullUrl/@value and ((not(f:resource/*/f:meta/f:versionId/@value) and not($entry/f:resource/*/f:meta/f:versionId/@value)) or f:resource/*/f:meta/f:versionId/@value=$entry/f:resource/*/f:meta/f:versionId/@value)])!=1])=0",</xsl:text>
					<xsl:text>"text":"bdl-7: FullUrl must be unique in a bundle, or else entries with the same fullUrl must have different meta.versionId",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Bundle",</xsl:text>
				<xsl:text>"assert":"count(for $entry in f:entry[f:resource] return $entry[count(parent::f:Bundle/f:entry[f:fullUrl/@value=$entry/f:fullUrl/@value and ((not(f:resource/*/f:meta/f:versionId/@value) and not($entry/f:resource/*/f:meta/f:versionId/@value)) or f:resource/*/f:meta/f:versionId/@value=$entry/f:resource/*/f:meta/f:versionId/@value)])!=1])=0",</xsl:text>
				<xsl:text>"text":"bdl-7: FullUrl must be unique in a bundle, or else entries with the same fullUrl must have different meta.versionId",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(f:entry/f:request) or (f:type/@value = &apos;batch&apos;) or (f:type/@value = &apos;transaction&apos;) or (f:type/@value = &apos;history&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Bundle",</xsl:text>
					<xsl:text>"assert":"not(f:entry/f:request) or (f:type/@value = &apos;batch&apos;) or (f:type/@value = &apos;transaction&apos;) or (f:type/@value = &apos;history&apos;)",</xsl:text>
					<xsl:text>"text":"bdl-3: entry.transaction when (and only when) a transaction",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Bundle",</xsl:text>
				<xsl:text>"assert":"not(f:entry/f:request) or (f:type/@value = &apos;batch&apos;) or (f:type/@value = &apos;transaction&apos;) or (f:type/@value = &apos;history&apos;)",</xsl:text>
				<xsl:text>"text":"bdl-3: entry.transaction when (and only when) a transaction",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(f:entry/f:response) or (f:type/@value = &apos;batch-response&apos;) or (f:type/@value = &apos;transaction-response&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Bundle",</xsl:text>
					<xsl:text>"assert":"not(f:entry/f:response) or (f:type/@value = &apos;batch-response&apos;) or (f:type/@value = &apos;transaction-response&apos;)",</xsl:text>
					<xsl:text>"text":"bdl-4: entry.transactionResponse when (and only when) a transaction-response",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Bundle",</xsl:text>
				<xsl:text>"assert":"not(f:entry/f:response) or (f:type/@value = &apos;batch-response&apos;) or (f:type/@value = &apos;transaction-response&apos;)",</xsl:text>
				<xsl:text>"text":"bdl-4: entry.transactionResponse when (and only when) a transaction-response",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:Bundle/f:entry">
		<xsl:choose>
			<xsl:when test="f:resource or f:request or f:response">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Bundle/f:entry",</xsl:text>
					<xsl:text>"assert":"f:resource or f:request or f:response",</xsl:text>
					<xsl:text>"text":"bdl-5: must be a resource unless there&apos;s a transaction or transaction response",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Bundle/f:entry",</xsl:text>
				<xsl:text>"assert":"f:resource or f:request or f:response",</xsl:text>
				<xsl:text>"text":"bdl-5: must be a resource unless there&apos;s a transaction or transaction response",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(not(exists(f:fullUrl)) and not(exists(f:resource))) or (exists(f:fullUrl) and exists(f:resource))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Bundle/f:entry",</xsl:text>
					<xsl:text>"assert":"(not(exists(f:fullUrl)) and not(exists(f:resource))) or (exists(f:fullUrl) and exists(f:resource))",</xsl:text>
					<xsl:text>"text":"bdl-6: The fullUrl element must be present when a resource is present, and not present otherwise",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Bundle/f:entry",</xsl:text>
				<xsl:text>"assert":"(not(exists(f:fullUrl)) and not(exists(f:resource))) or (exists(f:fullUrl) and exists(f:resource))",</xsl:text>
				<xsl:text>"text":"bdl-6: The fullUrl element must be present when a resource is present, and not present otherwise",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:Bundle/f:signature/f:whoReference">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Bundle/f:signature/f:whoReference",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Bundle/f:signature/f:whoReference",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
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
