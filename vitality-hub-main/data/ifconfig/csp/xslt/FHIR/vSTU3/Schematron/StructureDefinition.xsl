<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->

	<xsl:param name="includeSuccessfulTests" select="'0'"/>

	<xsl:output indent="no" method="text" media-type="application/json"/>

	<xsl:template match="/">
		<xsl:text>{"result":[</xsl:text>
		<xsl:apply-templates select="f:StructureDefinition/f:extension"/>
		<xsl:apply-templates select="f:StructureDefinition/f:modifierExtension"/>
		<xsl:apply-templates select="f:StructureDefinition"/>
		<xsl:apply-templates select="f:StructureDefinition/f:text/h:div"/>
		<xsl:apply-templates select="f:StructureDefinition/f:identifier/f:period"/>
		<xsl:apply-templates select="f:StructureDefinition/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:StructureDefinition/f:contact/f:telecom"/>
		<xsl:apply-templates select="f:StructureDefinition/f:contact/f:telecom/f:period"/>
		<xsl:apply-templates select="f:StructureDefinition/f:useContext/f:valueQuantity"/>
		<xsl:apply-templates select="f:StructureDefinition/f:useContext/f:valueRange"/>
		<xsl:apply-templates select="f:StructureDefinition/f:useContext/f:valueRange/f:low"/>
		<xsl:apply-templates select="f:StructureDefinition/f:useContext/f:valueRange/f:high"/>
		<xsl:apply-templates select="f:StructureDefinition/f:mapping"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:slicing"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:max"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:type"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:minValueQuantity"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:maxValueQuantity"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:binding"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference/f:identifier/f:period"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:slicing"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:max"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:type"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:minValueQuantity"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:maxValueQuantity"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:binding"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference/f:identifier/f:period"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference/f:identifier/f:assigner"/>
		<xsl:text>{"status":0}</xsl:text>
		<xsl:text>]}</xsl:text>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:extension">
		<xsl:choose>
			<xsl:when test="exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:extension",</xsl:text>
					<xsl:text>"assert":"exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])",</xsl:text>
					<xsl:text>"text":"ext-1: Must have either extensions or value[x], not both",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:extension",</xsl:text>
				<xsl:text>"assert":"exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])",</xsl:text>
				<xsl:text>"text":"ext-1: Must have either extensions or value[x], not both",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:modifierExtension">
		<xsl:choose>
			<xsl:when test="exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:modifierExtension",</xsl:text>
					<xsl:text>"assert":"exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])",</xsl:text>
					<xsl:text>"text":"ext-1: Must have either extensions or value[x], not both",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:modifierExtension",</xsl:text>
				<xsl:text>"assert":"exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])",</xsl:text>
				<xsl:text>"text":"ext-1: Must have either extensions or value[x], not both",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition">
		<xsl:choose>
			<xsl:when test="not(parent::f:contained and f:contained)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(parent::f:contained and f:contained)",</xsl:text>
					<xsl:text>"text":"dom-2: If the resource is contained in another resource, it SHALL NOT contain nested Resources",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(parent::f:contained and f:contained)",</xsl:text>
				<xsl:text>"text":"dom-2: If the resource is contained in another resource, it SHALL NOT contain nested Resources",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(parent::f:contained and f:text)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(parent::f:contained and f:text)",</xsl:text>
					<xsl:text>"text":"dom-1: If the resource is contained in another resource, it SHALL NOT contain any narrative",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(parent::f:contained and f:text)",</xsl:text>
				<xsl:text>"text":"dom-1: If the resource is contained in another resource, it SHALL NOT contain any narrative",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))",</xsl:text>
					<xsl:text>"text":"dom-4: If a resource is contained in another resource, it SHALL NOT have a meta.versionId or a meta.lastUpdated",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))",</xsl:text>
				<xsl:text>"text":"dom-4: If a resource is contained in another resource, it SHALL NOT have a meta.versionId or a meta.lastUpdated",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))",</xsl:text>
					<xsl:text>"text":"dom-3: If the resource is contained in another resource, it SHALL be referred to from elsewhere in the resource",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(exists(for $id in f:contained/*/@id return $id[not(ancestor::f:contained/parent::*/descendant::f:reference/@value=concat(&apos;#&apos;, $id))]))",</xsl:text>
				<xsl:text>"text":"dom-3: If the resource is contained in another resource, it SHALL be referred to from elsewhere in the resource",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:snapshot/f:element[not(contains(f:path/@value, &apos;.&apos;)) and (f:label or f:code or f:requirements)])) and not(exists(f:differential/f:element[not(contains(f:path/@value, &apos;.&apos;)) and (f:label or f:code or f:requirements)]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(exists(f:snapshot/f:element[not(contains(f:path/@value, &apos;.&apos;)) and (f:label or f:code or f:requirements)])) and not(exists(f:differential/f:element[not(contains(f:path/@value, &apos;.&apos;)) and (f:label or f:code or f:requirements)]))",</xsl:text>
					<xsl:text>"text":"sdf-9: In any snapshot or differential, no label, code or requirements on the an element without a \&quot;.\&quot; in the path (e.g. the first element)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(exists(f:snapshot/f:element[not(contains(f:path/@value, &apos;.&apos;)) and (f:label or f:code or f:requirements)])) and not(exists(f:differential/f:element[not(contains(f:path/@value, &apos;.&apos;)) and (f:label or f:code or f:requirements)]))",</xsl:text>
				<xsl:text>"text":"sdf-9: In any snapshot or differential, no label, code or requirements on the an element without a \&quot;.\&quot; in the path (e.g. the first element)",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="f:kind/@value = &apos;logical&apos; or count(f:differential/f:element/f:type/f:code[@value and not(matches(string(@value), &apos;^[a-zA-Z0-9]+$&apos;))]|f:snapshot/f:element/f:type/f:code[@value and not(matches(string(@value), &apos;^[a-zA-Z0-9]+$&apos;))]) =0">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"f:kind/@value = &apos;logical&apos; or count(f:differential/f:element/f:type/f:code[@value and not(matches(string(@value), &apos;^[a-zA-Z0-9]+$&apos;))]|f:snapshot/f:element/f:type/f:code[@value and not(matches(string(@value), &apos;^[a-zA-Z0-9]+$&apos;))]) =0",</xsl:text>
					<xsl:text>"text":"sdf-19: Custom types can only be used in logical models",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"f:kind/@value = &apos;logical&apos; or count(f:differential/f:element/f:type/f:code[@value and not(matches(string(@value), &apos;^[a-zA-Z0-9]+$&apos;))]|f:snapshot/f:element/f:type/f:code[@value and not(matches(string(@value), &apos;^[a-zA-Z0-9]+$&apos;))]) =0",</xsl:text>
				<xsl:text>"text":"sdf-19: Custom types can only be used in logical models",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(*/f:element)=count(*/f:element/@id)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"count(*/f:element)=count(*/f:element/@id)",</xsl:text>
					<xsl:text>"text":"sdf-16: All element definitions must have unique ids (snapshot)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"count(*/f:element)=count(*/f:element/@id)",</xsl:text>
				<xsl:text>"text":"sdf-16: All element definitions must have unique ids (snapshot)",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:contextInvariant)) or (f:type/@value = &apos;Extension&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(exists(f:contextInvariant)) or (f:type/@value = &apos;Extension&apos;)",</xsl:text>
					<xsl:text>"text":"sdf-18: Context Invariants can only be used for extensions",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(exists(f:contextInvariant)) or (f:type/@value = &apos;Extension&apos;)",</xsl:text>
				<xsl:text>"text":"sdf-18: Context Invariants can only be used for extensions",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(*/f:element)=count(*/f:element/@id)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"count(*/f:element)=count(*/f:element/@id)",</xsl:text>
					<xsl:text>"text":"sdf-17: All element definitions must have unique ids (diff)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"count(*/f:element)=count(*/f:element/@id)",</xsl:text>
				<xsl:text>"text":"sdf-17: All element definitions must have unique ids (diff)",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="f:baseDefinition or not(exists(f:snapshot/f:element/f:base) or exists(f:differential/f:element/f:base))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"f:baseDefinition or not(exists(f:snapshot/f:element/f:base) or exists(f:differential/f:element/f:base))",</xsl:text>
					<xsl:text>"text":"sdf-12: element.base cannot appear if there is no base on the structure definition",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"f:baseDefinition or not(exists(f:snapshot/f:element/f:base) or exists(f:differential/f:element/f:base))",</xsl:text>
				<xsl:text>"text":"sdf-12: element.base cannot appear if there is no base on the structure definition",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:snapshot)) or (f:type/@value = f:snapshot/f:element[1]/f:path/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(exists(f:snapshot)) or (f:type/@value = f:snapshot/f:element[1]/f:path/@value)",</xsl:text>
					<xsl:text>"text":"sdf-11: If there&apos;s a type, its content must match the path name in the first element of a snapshot",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(exists(f:snapshot)) or (f:type/@value = f:snapshot/f:element[1]/f:path/@value)",</xsl:text>
				<xsl:text>"text":"sdf-11: If there&apos;s a type, its content must match the path name in the first element of a snapshot",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(*/f:element)=count(*/f:element/@id)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"count(*/f:element)=count(*/f:element/@id)",</xsl:text>
					<xsl:text>"text":"sdf-14: All element definitions must have an id",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"count(*/f:element)=count(*/f:element/@id)",</xsl:text>
				<xsl:text>"text":"sdf-14: All element definitions must have an id",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(f:derivation/@value = &apos;constraint&apos;) or (count(f:snapshot/f:element) = count(distinct-values(f:snapshot/f:element/f:path/@value)))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"(f:derivation/@value = &apos;constraint&apos;) or (count(f:snapshot/f:element) = count(distinct-values(f:snapshot/f:element/f:path/@value)))",</xsl:text>
					<xsl:text>"text":"sdf-1: Element paths must be unique unless the structure is a constraint",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"(f:derivation/@value = &apos;constraint&apos;) or (count(f:snapshot/f:element) = count(distinct-values(f:snapshot/f:element/f:path/@value)))",</xsl:text>
				<xsl:text>"text":"sdf-1: Element paths must be unique unless the structure is a constraint",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(f:derivation/@value = &apos;constraint&apos;) or (f:kind/@value = &apos;logical&apos;) or (f:url/@value=concat(&apos;http://hl7.org/fhir/StructureDefinition/&apos;, f:id/@value))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"(f:derivation/@value = &apos;constraint&apos;) or (f:kind/@value = &apos;logical&apos;) or (f:url/@value=concat(&apos;http://hl7.org/fhir/StructureDefinition/&apos;, f:id/@value))",</xsl:text>
					<xsl:text>"text":"sdf-7: If the structure describes a base Resource or Type, the URL has to start with \&quot;http://hl7.org/fhir/StructureDefinition/\&quot; and the tail must match the id",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"(f:derivation/@value = &apos;constraint&apos;) or (f:kind/@value = &apos;logical&apos;) or (f:url/@value=concat(&apos;http://hl7.org/fhir/StructureDefinition/&apos;, f:id/@value))",</xsl:text>
				<xsl:text>"text":"sdf-7: If the structure describes a base Resource or Type, the URL has to start with \&quot;http://hl7.org/fhir/StructureDefinition/\&quot; and the tail must match the id",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="exists(f:snapshot) or exists(f:differential)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"exists(f:snapshot) or exists(f:differential)",</xsl:text>
					<xsl:text>"text":"sdf-6: A structure must have either a differential, or a snapshot (or both)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"exists(f:snapshot) or exists(f:differential)",</xsl:text>
				<xsl:text>"text":"sdf-6: A structure must have either a differential, or a snapshot (or both)",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(f:type/@value = &apos;extension&apos;) or (f:derivation/@value = &apos;specialization&apos;) or (exists(f:context) and exists(f:contextType))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(f:type/@value = &apos;extension&apos;) or (f:derivation/@value = &apos;specialization&apos;) or (exists(f:context) and exists(f:contextType))",</xsl:text>
					<xsl:text>"text":"sdf-5: If the structure defines an extension then the structure must have context information",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(f:type/@value = &apos;extension&apos;) or (f:derivation/@value = &apos;specialization&apos;) or (exists(f:context) and exists(f:contextType))",</xsl:text>
				<xsl:text>"text":"sdf-5: If the structure defines an extension then the structure must have context information",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(f:abstract/@value=true()) or exists(f:baseDefinition)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"(f:abstract/@value=true()) or exists(f:baseDefinition)",</xsl:text>
					<xsl:text>"text":"sdf-4: If the structure is not abstract, then there SHALL be a baseDefinition",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"(f:abstract/@value=true()) or exists(f:baseDefinition)",</xsl:text>
				<xsl:text>"text":"sdf-4: If the structure is not abstract, then there SHALL be a baseDefinition",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:text/h:div">
		<xsl:choose>
			<xsl:when test="not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;sub&apos;, &apos;sup&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))]) and not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;sub&apos;, &apos;sup&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))]) and not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])",</xsl:text>
					<xsl:text>"text":"txt-1: The narrative SHALL contain only the basic html formatting elements and attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;sub&apos;, &apos;sup&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))]) and not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])",</xsl:text>
				<xsl:text>"text":"txt-1: The narrative SHALL contain only the basic html formatting elements and attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]",</xsl:text>
					<xsl:text>"text":"txt-2: The narrative SHALL have some non-whitespace content",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"descendant::text()[normalize-space(.)!=&apos;&apos;] or descendant::h:img[@src]",</xsl:text>
				<xsl:text>"text":"txt-2: The narrative SHALL have some non-whitespace content",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:identifier/f:period">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:identifier/f:period",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:identifier/f:period",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:identifier/f:assigner">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:identifier/f:assigner",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:identifier/f:assigner",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:contact/f:telecom">
		<xsl:choose>
			<xsl:when test="not(exists(f:value)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:contact/f:telecom",</xsl:text>
					<xsl:text>"assert":"not(exists(f:value)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"cpt-2: A system is required if a value is provided.",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:contact/f:telecom",</xsl:text>
				<xsl:text>"assert":"not(exists(f:value)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"cpt-2: A system is required if a value is provided.",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:contact/f:telecom/f:period">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:contact/f:telecom/f:period",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:contact/f:telecom/f:period",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:useContext/f:valueQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:useContext/f:valueQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:useContext/f:valueQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:useContext/f:valueRange">
		<xsl:choose>
			<xsl:when test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:useContext/f:valueRange",</xsl:text>
					<xsl:text>"assert":"not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))",</xsl:text>
					<xsl:text>"text":"rng-2: If present, low SHALL have a lower value than high",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:useContext/f:valueRange",</xsl:text>
				<xsl:text>"assert":"not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))",</xsl:text>
				<xsl:text>"text":"rng-2: If present, low SHALL have a lower value than high",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:useContext/f:valueRange/f:low">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:useContext/f:valueRange/f:low",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:useContext/f:valueRange/f:low",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:useContext/f:valueRange/f:high">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:useContext/f:valueRange/f:high",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:useContext/f:valueRange/f:high",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:mapping">
		<xsl:choose>
			<xsl:when test="exists(f:uri) or exists(f:name)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:mapping",</xsl:text>
					<xsl:text>"assert":"exists(f:uri) or exists(f:name)",</xsl:text>
					<xsl:text>"text":"sdf-2: Must have at least a name or a uri (or both)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:mapping",</xsl:text>
				<xsl:text>"assert":"exists(f:uri) or exists(f:name)",</xsl:text>
				<xsl:text>"text":"sdf-2: Must have at least a name or a uri (or both)",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot">
		<xsl:choose>
			<xsl:when test="not(f:element[1]/f:type)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot",</xsl:text>
					<xsl:text>"assert":"not(f:element[1]/f:type)",</xsl:text>
					<xsl:text>"text":"sdf-15: The first element in a snapshot has no type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot",</xsl:text>
				<xsl:text>"assert":"not(f:element[1]/f:type)",</xsl:text>
				<xsl:text>"text":"sdf-15: The first element in a snapshot has no type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="f:element[1]/f:path/@value=parent::f:StructureDefinition/f:type/@value and count(f:element[position()!=1])=count(f:element[position()!=1][starts-with(f:path/@value, concat(ancestor::f:StructureDefinition/f:type/@value, &apos;.&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot",</xsl:text>
					<xsl:text>"assert":"f:element[1]/f:path/@value=parent::f:StructureDefinition/f:type/@value and count(f:element[position()!=1])=count(f:element[position()!=1][starts-with(f:path/@value, concat(ancestor::f:StructureDefinition/f:type/@value, &apos;.&apos;))])",</xsl:text>
					<xsl:text>"text":"sdf-8: In any snapshot, all the elements must be in the specified type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot",</xsl:text>
				<xsl:text>"assert":"f:element[1]/f:path/@value=parent::f:StructureDefinition/f:type/@value and count(f:element[position()!=1])=count(f:element[position()!=1][starts-with(f:path/@value, concat(ancestor::f:StructureDefinition/f:type/@value, &apos;.&apos;))])",</xsl:text>
				<xsl:text>"text":"sdf-8: In any snapshot, all the elements must be in the specified type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(f:element) = count(f:element[exists(f:definition) and exists(f:min) and exists(f:max)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot",</xsl:text>
					<xsl:text>"assert":"count(f:element) = count(f:element[exists(f:definition) and exists(f:min) and exists(f:max)])",</xsl:text>
					<xsl:text>"text":"sdf-3: Each element definition in a snapshot must have a formal definition and cardinalities",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot",</xsl:text>
				<xsl:text>"assert":"count(f:element) = count(f:element[exists(f:definition) and exists(f:min) and exists(f:max)])",</xsl:text>
				<xsl:text>"text":"sdf-3: Each element definition in a snapshot must have a formal definition and cardinalities",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element">
		<xsl:choose>
			<xsl:when test="not(exists(f:min)) or not(exists(f:max)) or (not(f:max/@value) and not(f:min/@value)) or (f:max/@value = &apos;*&apos;) or (number(f:max/@value) &gt;= f:min/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:min)) or not(exists(f:max)) or (not(f:max/@value) and not(f:min/@value)) or (f:max/@value = &apos;*&apos;) or (number(f:max/@value) &gt;= f:min/@value)",</xsl:text>
					<xsl:text>"text":"eld-2: Min &lt;= Max",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:min)) or not(exists(f:max)) or (not(f:max/@value) and not(f:min/@value)) or (f:max/@value = &apos;*&apos;) or (number(f:max/@value) &gt;= f:min/@value)",</xsl:text>
				<xsl:text>"text":"eld-2: Min &lt;= Max",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:contentReference) and (exists(f:type) or exists(f:*[starts-with(local-name(.), &apos;value&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;defaultValue&apos;)])  or exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;example&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:minValue&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:maxValue&apos;)]) or exists(f:maxLength) or exists(f:binding)))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:contentReference) and (exists(f:type) or exists(f:*[starts-with(local-name(.), &apos;value&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;defaultValue&apos;)])  or exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;example&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:minValue&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:maxValue&apos;)]) or exists(f:maxLength) or exists(f:binding)))",</xsl:text>
					<xsl:text>"text":"eld-5: if the element definition has a contentReference, it cannot have type, defaultValue, fixed, pattern, example, minValue, maxValue, maxLength, or binding",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:contentReference) and (exists(f:type) or exists(f:*[starts-with(local-name(.), &apos;value&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;defaultValue&apos;)])  or exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;example&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:minValue&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:maxValue&apos;)]) or exists(f:maxLength) or exists(f:binding)))",</xsl:text>
				<xsl:text>"text":"eld-5: if the element definition has a contentReference, it cannot have type, defaultValue, fixed, pattern, example, minValue, maxValue, maxLength, or binding",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)&lt;=1)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)&lt;=1)",</xsl:text>
					<xsl:text>"text":"eld-7: Pattern may only be specified if there is one type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)&lt;=1)",</xsl:text>
				<xsl:text>"text":"eld-7: Pattern may only be specified if there is one type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)&lt;=1)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)&lt;=1)",</xsl:text>
					<xsl:text>"text":"eld-6: Fixed value may only be specified if there is one type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)&lt;=1)",</xsl:text>
				<xsl:text>"text":"eld-6: Fixed value may only be specified if there is one type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:binding)) or (count(f:type/f:code) = 0) or  f:type/f:code/@value=(&apos;code&apos;,&apos;Coding&apos;,&apos;CodeableConcept&apos;,&apos;Quantity&apos;,&apos;Extension&apos;, &apos;string&apos;, &apos;uri&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:binding)) or (count(f:type/f:code) = 0) or  f:type/f:code/@value=(&apos;code&apos;,&apos;Coding&apos;,&apos;CodeableConcept&apos;,&apos;Quantity&apos;,&apos;Extension&apos;, &apos;string&apos;, &apos;uri&apos;)",</xsl:text>
					<xsl:text>"text":"eld-11: Binding can only be present for coded elements, string, and uri",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:binding)) or (count(f:type/f:code) = 0) or  f:type/f:code/@value=(&apos;code&apos;,&apos;Coding&apos;,&apos;CodeableConcept&apos;,&apos;Quantity&apos;,&apos;Extension&apos;, &apos;string&apos;, &apos;uri&apos;)",</xsl:text>
				<xsl:text>"text":"eld-11: Binding can only be present for coded elements, string, and uri",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]))",</xsl:text>
					<xsl:text>"text":"eld-8: Pattern and value are mutually exclusive",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]))",</xsl:text>
				<xsl:text>"text":"eld-8: Pattern and value are mutually exclusive",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(f:constraint) = count(distinct-values(f:constraint/f:key/@value))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"count(f:constraint) = count(distinct-values(f:constraint/f:key/@value))",</xsl:text>
					<xsl:text>"text":"eld-14: Constraints must be unique by key",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"count(f:constraint) = count(distinct-values(f:constraint/f:key/@value))",</xsl:text>
				<xsl:text>"text":"eld-14: Constraints must be unique by key",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(for $type in f:type return $type/preceding-sibling::f:type[f:code/@value=$type/f:code/@value and f:profile/@value = $type/f:profile/@value]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(for $type in f:type return $type/preceding-sibling::f:type[f:code/@value=$type/f:code/@value and f:profile/@value = $type/f:profile/@value]))",</xsl:text>
					<xsl:text>"text":"eld-13: Types must be unique by the combination of code and profile",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(for $type in f:type return $type/preceding-sibling::f:type[f:code/@value=$type/f:code/@value and f:profile/@value = $type/f:profile/@value]))",</xsl:text>
				<xsl:text>"text":"eld-13: Types must be unique by the combination of code and profile",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:sliceName/@value)) or matches(f:sliceName/@value, &apos;^[a-zA-Z0-9\\/\\-\\_]+$&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:sliceName/@value)) or matches(f:sliceName/@value, &apos;^[a-zA-Z0-9\\/\\-\\_]+$&apos;)",</xsl:text>
					<xsl:text>"text":"eld-16: sliceName must be composed of proper tokens separated by \&quot;/\&quot;",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:sliceName/@value)) or matches(f:sliceName/@value, &apos;^[a-zA-Z0-9\\/\\-\\_]+$&apos;)",</xsl:text>
				<xsl:text>"text":"eld-16: sliceName must be composed of proper tokens separated by \&quot;/\&quot;",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or not(exists(f:meaningWhenMissing))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or not(exists(f:meaningWhenMissing))",</xsl:text>
					<xsl:text>"text":"eld-15: default value and meaningWhenMissing are mutually exclusive",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or not(exists(f:meaningWhenMissing))",</xsl:text>
				<xsl:text>"text":"eld-15: default value and meaningWhenMissing are mutually exclusive",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:slicing">
		<xsl:choose>
			<xsl:when test="(f:discriminator) or (f:description)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:slicing",</xsl:text>
					<xsl:text>"assert":"(f:discriminator) or (f:description)",</xsl:text>
					<xsl:text>"text":"eld-1: If there are no discriminators, there must be a definition",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:slicing",</xsl:text>
				<xsl:text>"assert":"(f:discriminator) or (f:description)",</xsl:text>
				<xsl:text>"text":"eld-1: If there are no discriminators, there must be a definition",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:max">
		<xsl:choose>
			<xsl:when test="@value=&apos;*&apos; or (normalize-space(@value)!=&apos;&apos; and normalize-space(translate(@value, &apos;0123456789&apos;,&apos;&apos;))=&apos;&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:max",</xsl:text>
					<xsl:text>"assert":"@value=&apos;*&apos; or (normalize-space(@value)!=&apos;&apos; and normalize-space(translate(@value, &apos;0123456789&apos;,&apos;&apos;))=&apos;&apos;)",</xsl:text>
					<xsl:text>"text":"eld-3: Max SHALL be a number or \&quot;*\&quot;",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:max",</xsl:text>
				<xsl:text>"assert":"@value=&apos;*&apos; or (normalize-space(@value)!=&apos;&apos; and normalize-space(translate(@value, &apos;0123456789&apos;,&apos;&apos;))=&apos;&apos;)",</xsl:text>
				<xsl:text>"text":"eld-3: Max SHALL be a number or \&quot;*\&quot;",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:type">
		<xsl:choose>
			<xsl:when test="not(exists(f:aggregation)) or exists(f:code[@value = &apos;Reference&apos;])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:type",</xsl:text>
					<xsl:text>"assert":"not(exists(f:aggregation)) or exists(f:code[@value = &apos;Reference&apos;])",</xsl:text>
					<xsl:text>"text":"eld-4: Aggregation may only be specified if one of the allowed types for the element is a resource",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:type",</xsl:text>
				<xsl:text>"assert":"not(exists(f:aggregation)) or exists(f:code[@value = &apos;Reference&apos;])",</xsl:text>
				<xsl:text>"text":"eld-4: Aggregation may only be specified if one of the allowed types for the element is a resource",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:minValueQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:minValueQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:minValueQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:maxValueQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:maxValueQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:maxValueQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:binding">
		<xsl:choose>
			<xsl:when test="(exists(f:valueSetUri) or exists(f:valueSetReference)) or exists(f:description)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding",</xsl:text>
					<xsl:text>"assert":"(exists(f:valueSetUri) or exists(f:valueSetReference)) or exists(f:description)",</xsl:text>
					<xsl:text>"text":"eld-10: provide either a reference or a description (or both)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding",</xsl:text>
				<xsl:text>"assert":"(exists(f:valueSetUri) or exists(f:valueSetReference)) or exists(f:description)",</xsl:text>
				<xsl:text>"text":"eld-10: provide either a reference or a description (or both)",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:valueSetUri)) or (starts-with(string(f:valueSetUri/@value), &apos;http:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;https:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;urn:&apos;))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding",</xsl:text>
					<xsl:text>"assert":"not(exists(f:valueSetUri)) or (starts-with(string(f:valueSetUri/@value), &apos;http:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;https:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;urn:&apos;))",</xsl:text>
					<xsl:text>"text":"eld-12: ValueSet as a URI SHALL start with http:// or https:// or urn:",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding",</xsl:text>
				<xsl:text>"assert":"not(exists(f:valueSetUri)) or (starts-with(string(f:valueSetUri/@value), &apos;http:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;https:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;urn:&apos;))",</xsl:text>
				<xsl:text>"text":"eld-12: ValueSet as a URI SHALL start with http:// or https:// or urn:",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference/f:identifier/f:period">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference/f:identifier/f:period",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference/f:identifier/f:period",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference/f:identifier/f:assigner">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference/f:identifier/f:assigner",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference/f:identifier/f:assigner",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential">
		<xsl:choose>
			<xsl:when test="not(f:element[1][not(contains(f:path/@value, &apos;.&apos;))]/f:type)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential",</xsl:text>
					<xsl:text>"assert":"not(f:element[1][not(contains(f:path/@value, &apos;.&apos;))]/f:type)",</xsl:text>
					<xsl:text>"text":"sdf-15a: If the first element in a differential has no \&quot;.\&quot; in the path, it has no type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential",</xsl:text>
				<xsl:text>"assert":"not(f:element[1][not(contains(f:path/@value, &apos;.&apos;))]/f:type)",</xsl:text>
				<xsl:text>"text":"sdf-15a: If the first element in a differential has no \&quot;.\&quot; in the path, it has no type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(f:element[1]/f:slicing)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential",</xsl:text>
					<xsl:text>"assert":"not(f:element[1]/f:slicing)",</xsl:text>
					<xsl:text>"text":"sdf-20: No slicing on the root element",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential",</xsl:text>
				<xsl:text>"assert":"not(f:element[1]/f:slicing)",</xsl:text>
				<xsl:text>"text":"sdf-20: No slicing on the root element",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(f:element)=count(f:element[f:path/@value=ancestor::f:StructureDefinition/f:type/@value or starts-with(f:path/@value, concat(ancestor::f:StructureDefinition/f:type/@value, &apos;.&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential",</xsl:text>
					<xsl:text>"assert":"count(f:element)=count(f:element[f:path/@value=ancestor::f:StructureDefinition/f:type/@value or starts-with(f:path/@value, concat(ancestor::f:StructureDefinition/f:type/@value, &apos;.&apos;))])",</xsl:text>
					<xsl:text>"text":"sdf-8a: In any differential, all the elements must be in the specified type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential",</xsl:text>
				<xsl:text>"assert":"count(f:element)=count(f:element[f:path/@value=ancestor::f:StructureDefinition/f:type/@value or starts-with(f:path/@value, concat(ancestor::f:StructureDefinition/f:type/@value, &apos;.&apos;))])",</xsl:text>
				<xsl:text>"text":"sdf-8a: In any differential, all the elements must be in the specified type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element">
		<xsl:choose>
			<xsl:when test="not(exists(f:min)) or not(exists(f:max)) or (not(f:max/@value) and not(f:min/@value)) or (f:max/@value = &apos;*&apos;) or (number(f:max/@value) &gt;= f:min/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:min)) or not(exists(f:max)) or (not(f:max/@value) and not(f:min/@value)) or (f:max/@value = &apos;*&apos;) or (number(f:max/@value) &gt;= f:min/@value)",</xsl:text>
					<xsl:text>"text":"eld-2: Min &lt;= Max",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:min)) or not(exists(f:max)) or (not(f:max/@value) and not(f:min/@value)) or (f:max/@value = &apos;*&apos;) or (number(f:max/@value) &gt;= f:min/@value)",</xsl:text>
				<xsl:text>"text":"eld-2: Min &lt;= Max",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:contentReference) and (exists(f:type) or exists(f:*[starts-with(local-name(.), &apos;value&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;defaultValue&apos;)])  or exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;example&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:minValue&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:maxValue&apos;)]) or exists(f:maxLength) or exists(f:binding)))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:contentReference) and (exists(f:type) or exists(f:*[starts-with(local-name(.), &apos;value&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;defaultValue&apos;)])  or exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;example&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:minValue&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:maxValue&apos;)]) or exists(f:maxLength) or exists(f:binding)))",</xsl:text>
					<xsl:text>"text":"eld-5: if the element definition has a contentReference, it cannot have type, defaultValue, fixed, pattern, example, minValue, maxValue, maxLength, or binding",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:contentReference) and (exists(f:type) or exists(f:*[starts-with(local-name(.), &apos;value&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;defaultValue&apos;)])  or exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;example&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:minValue&apos;)]) or exists(f:*[starts-with(local-name(.), &apos;f:maxValue&apos;)]) or exists(f:maxLength) or exists(f:binding)))",</xsl:text>
				<xsl:text>"text":"eld-5: if the element definition has a contentReference, it cannot have type, defaultValue, fixed, pattern, example, minValue, maxValue, maxLength, or binding",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)&lt;=1)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)&lt;=1)",</xsl:text>
					<xsl:text>"text":"eld-7: Pattern may only be specified if there is one type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)&lt;=1)",</xsl:text>
				<xsl:text>"text":"eld-7: Pattern may only be specified if there is one type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)&lt;=1)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)&lt;=1)",</xsl:text>
					<xsl:text>"text":"eld-6: Fixed value may only be specified if there is one type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)&lt;=1)",</xsl:text>
				<xsl:text>"text":"eld-6: Fixed value may only be specified if there is one type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:binding)) or (count(f:type/f:code) = 0) or  f:type/f:code/@value=(&apos;code&apos;,&apos;Coding&apos;,&apos;CodeableConcept&apos;,&apos;Quantity&apos;,&apos;Extension&apos;, &apos;string&apos;, &apos;uri&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:binding)) or (count(f:type/f:code) = 0) or  f:type/f:code/@value=(&apos;code&apos;,&apos;Coding&apos;,&apos;CodeableConcept&apos;,&apos;Quantity&apos;,&apos;Extension&apos;, &apos;string&apos;, &apos;uri&apos;)",</xsl:text>
					<xsl:text>"text":"eld-11: Binding can only be present for coded elements, string, and uri",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:binding)) or (count(f:type/f:code) = 0) or  f:type/f:code/@value=(&apos;code&apos;,&apos;Coding&apos;,&apos;CodeableConcept&apos;,&apos;Quantity&apos;,&apos;Extension&apos;, &apos;string&apos;, &apos;uri&apos;)",</xsl:text>
				<xsl:text>"text":"eld-11: Binding can only be present for coded elements, string, and uri",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]))",</xsl:text>
					<xsl:text>"text":"eld-8: Pattern and value are mutually exclusive",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)]))",</xsl:text>
				<xsl:text>"text":"eld-8: Pattern and value are mutually exclusive",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count(f:constraint) = count(distinct-values(f:constraint/f:key/@value))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"count(f:constraint) = count(distinct-values(f:constraint/f:key/@value))",</xsl:text>
					<xsl:text>"text":"eld-14: Constraints must be unique by key",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"count(f:constraint) = count(distinct-values(f:constraint/f:key/@value))",</xsl:text>
				<xsl:text>"text":"eld-14: Constraints must be unique by key",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(for $type in f:type return $type/preceding-sibling::f:type[f:code/@value=$type/f:code/@value and f:profile/@value = $type/f:profile/@value]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(for $type in f:type return $type/preceding-sibling::f:type[f:code/@value=$type/f:code/@value and f:profile/@value = $type/f:profile/@value]))",</xsl:text>
					<xsl:text>"text":"eld-13: Types must be unique by the combination of code and profile",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(for $type in f:type return $type/preceding-sibling::f:type[f:code/@value=$type/f:code/@value and f:profile/@value = $type/f:profile/@value]))",</xsl:text>
				<xsl:text>"text":"eld-13: Types must be unique by the combination of code and profile",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:sliceName/@value)) or matches(f:sliceName/@value, &apos;^[a-zA-Z0-9\\/\\-\\_]+$&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:sliceName/@value)) or matches(f:sliceName/@value, &apos;^[a-zA-Z0-9\\/\\-\\_]+$&apos;)",</xsl:text>
					<xsl:text>"text":"eld-16: sliceName must be composed of proper tokens separated by \&quot;/\&quot;",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:sliceName/@value)) or matches(f:sliceName/@value, &apos;^[a-zA-Z0-9\\/\\-\\_]+$&apos;)",</xsl:text>
				<xsl:text>"text":"eld-16: sliceName must be composed of proper tokens separated by \&quot;/\&quot;",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or not(exists(f:meaningWhenMissing))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or not(exists(f:meaningWhenMissing))",</xsl:text>
					<xsl:text>"text":"eld-15: default value and meaningWhenMissing are mutually exclusive",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or not(exists(f:meaningWhenMissing))",</xsl:text>
				<xsl:text>"text":"eld-15: default value and meaningWhenMissing are mutually exclusive",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:slicing">
		<xsl:choose>
			<xsl:when test="(f:discriminator) or (f:description)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:slicing",</xsl:text>
					<xsl:text>"assert":"(f:discriminator) or (f:description)",</xsl:text>
					<xsl:text>"text":"eld-1: If there are no discriminators, there must be a definition",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:slicing",</xsl:text>
				<xsl:text>"assert":"(f:discriminator) or (f:description)",</xsl:text>
				<xsl:text>"text":"eld-1: If there are no discriminators, there must be a definition",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:max">
		<xsl:choose>
			<xsl:when test="@value=&apos;*&apos; or (normalize-space(@value)!=&apos;&apos; and normalize-space(translate(@value, &apos;0123456789&apos;,&apos;&apos;))=&apos;&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:max",</xsl:text>
					<xsl:text>"assert":"@value=&apos;*&apos; or (normalize-space(@value)!=&apos;&apos; and normalize-space(translate(@value, &apos;0123456789&apos;,&apos;&apos;))=&apos;&apos;)",</xsl:text>
					<xsl:text>"text":"eld-3: Max SHALL be a number or \&quot;*\&quot;",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:max",</xsl:text>
				<xsl:text>"assert":"@value=&apos;*&apos; or (normalize-space(@value)!=&apos;&apos; and normalize-space(translate(@value, &apos;0123456789&apos;,&apos;&apos;))=&apos;&apos;)",</xsl:text>
				<xsl:text>"text":"eld-3: Max SHALL be a number or \&quot;*\&quot;",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:type">
		<xsl:choose>
			<xsl:when test="not(exists(f:aggregation)) or exists(f:code[@value = &apos;Reference&apos;])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:type",</xsl:text>
					<xsl:text>"assert":"not(exists(f:aggregation)) or exists(f:code[@value = &apos;Reference&apos;])",</xsl:text>
					<xsl:text>"text":"eld-4: Aggregation may only be specified if one of the allowed types for the element is a resource",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:type",</xsl:text>
				<xsl:text>"assert":"not(exists(f:aggregation)) or exists(f:code[@value = &apos;Reference&apos;])",</xsl:text>
				<xsl:text>"text":"eld-4: Aggregation may only be specified if one of the allowed types for the element is a resource",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:minValueQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:minValueQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:minValueQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:maxValueQuantity">
		<xsl:choose>
			<xsl:when test="not(exists(f:code)) or exists(f:system)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:maxValueQuantity",</xsl:text>
					<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
					<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:maxValueQuantity",</xsl:text>
				<xsl:text>"assert":"not(exists(f:code)) or exists(f:system)",</xsl:text>
				<xsl:text>"text":"qty-3: If a code for the unit is present, the system SHALL also be present",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:binding">
		<xsl:choose>
			<xsl:when test="(exists(f:valueSetUri) or exists(f:valueSetReference)) or exists(f:description)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding",</xsl:text>
					<xsl:text>"assert":"(exists(f:valueSetUri) or exists(f:valueSetReference)) or exists(f:description)",</xsl:text>
					<xsl:text>"text":"eld-10: provide either a reference or a description (or both)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding",</xsl:text>
				<xsl:text>"assert":"(exists(f:valueSetUri) or exists(f:valueSetReference)) or exists(f:description)",</xsl:text>
				<xsl:text>"text":"eld-10: provide either a reference or a description (or both)",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:valueSetUri)) or (starts-with(string(f:valueSetUri/@value), &apos;http:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;https:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;urn:&apos;))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding",</xsl:text>
					<xsl:text>"assert":"not(exists(f:valueSetUri)) or (starts-with(string(f:valueSetUri/@value), &apos;http:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;https:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;urn:&apos;))",</xsl:text>
					<xsl:text>"text":"eld-12: ValueSet as a URI SHALL start with http:// or https:// or urn:",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding",</xsl:text>
				<xsl:text>"assert":"not(exists(f:valueSetUri)) or (starts-with(string(f:valueSetUri/@value), &apos;http:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;https:&apos;) or starts-with(string(f:valueSetUri/@value), &apos;urn:&apos;))",</xsl:text>
				<xsl:text>"text":"eld-12: ValueSet as a URI SHALL start with http:// or https:// or urn:",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference/f:identifier/f:period">
		<xsl:choose>
			<xsl:when test="not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference/f:identifier/f:period",</xsl:text>
					<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
					<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference/f:identifier/f:period",</xsl:text>
				<xsl:text>"assert":"not(exists(f:start)) or not(exists(f:end)) or (f:start/@value &lt;= f:end/@value)",</xsl:text>
				<xsl:text>"text":"per-1: If present, start SHALL have a lower value than end",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference/f:identifier/f:assigner">
		<xsl:choose>
			<xsl:when test="not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference/f:identifier/f:assigner",</xsl:text>
					<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
					<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference/f:identifier/f:assigner",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a contained resource if a local reference is provided",</xsl:text>
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
