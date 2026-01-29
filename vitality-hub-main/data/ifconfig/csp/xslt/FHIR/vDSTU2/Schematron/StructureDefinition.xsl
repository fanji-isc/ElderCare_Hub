<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->

	<xsl:param name="includeSuccessfulTests" select="'0'"/>

	<xsl:output indent="no" method="text" media-type="application/json"/>

	<xsl:template match="/">
		<xsl:text>{"result":[</xsl:text>
		<xsl:apply-templates select="f:StructureDefinition"/>
		<xsl:apply-templates select="f:StructureDefinition/f:text/h:div"/>
		<xsl:apply-templates select="f:StructureDefinition/f:identifier/f:period"/>
		<xsl:apply-templates select="f:StructureDefinition/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:StructureDefinition/f:contact/f:telecom"/>
		<xsl:apply-templates select="f:StructureDefinition/f:contact/f:telecom/f:period"/>
		<xsl:apply-templates select="f:StructureDefinition/f:mapping"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:slicing"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:max"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:type"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:binding"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetUri"/>
		<xsl:apply-templates select="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:slicing"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:max"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:type"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:binding"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetUri"/>
		<xsl:apply-templates select="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference"/>
		<xsl:text>{"status":0}</xsl:text>
		<xsl:text>]}</xsl:text>
	</xsl:template>

	<xsl:template match="f:StructureDefinition">
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
			<xsl:when test="not(exists(f:constrainedType)) or not(exists(f:snapshot)) or (f:constrainedType/@value = f:snapshot/f:element[1]/f:path/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(exists(f:constrainedType)) or not(exists(f:snapshot)) or (f:constrainedType/@value = f:snapshot/f:element[1]/f:path/@value)",</xsl:text>
					<xsl:text>"text":"sdf-11: If there&apos;s a constrained type, its content must match the path name in the first element of a snapshot",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(exists(f:constrainedType)) or not(exists(f:snapshot)) or (f:constrainedType/@value = f:snapshot/f:element[1]/f:path/@value)",</xsl:text>
				<xsl:text>"text":"sdf-11: If there&apos;s a constrained type, its content must match the path name in the first element of a snapshot",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(f:constrainedType/@value = &apos;extension&apos;) or (exists(f:context) and exists(f:contextType))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(f:constrainedType/@value = &apos;extension&apos;) or (exists(f:context) and exists(f:contextType))",</xsl:text>
					<xsl:text>"text":"sdf-5: If the structure defines an extension then the structure must have context information",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(f:constrainedType/@value = &apos;extension&apos;) or (exists(f:context) and exists(f:contextType))",</xsl:text>
				<xsl:text>"text":"sdf-5: If the structure defines an extension then the structure must have context information",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="f:base or not(exists(f:snapshot/f:element/f:base) or exists(f:differential/f:element/f:base))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"f:base or not(exists(f:snapshot/f:element/f:base) or exists(f:differential/f:element/f:base))",</xsl:text>
					<xsl:text>"text":"sdf-12: element.base cannot appear if there is no base on the structure definition",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"f:base or not(exists(f:snapshot/f:element/f:base) or exists(f:differential/f:element/f:base))",</xsl:text>
				<xsl:text>"text":"sdf-12: element.base cannot appear if there is no base on the structure definition",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(f:abstract/@value =true()) or exists(f:base)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"(f:abstract/@value =true()) or exists(f:base)",</xsl:text>
					<xsl:text>"text":"sdf-4: A structure must have a base unless abstract = true",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"(f:abstract/@value =true()) or exists(f:base)",</xsl:text>
				<xsl:text>"text":"sdf-4: A structure must have a base unless abstract = true",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(f:constrainedType) or not(f:snapshot/f:element[not(f:base)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(f:constrainedType) or not(f:snapshot/f:element[not(f:base)])",</xsl:text>
					<xsl:text>"text":"sdf-13: element.base must appear if there is a base on the structure definition",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(f:constrainedType) or not(f:snapshot/f:element[not(f:base)])",</xsl:text>
				<xsl:text>"text":"sdf-13: element.base must appear if there is a base on the structure definition",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:constrainedType)) or f:url/@value=concat(&apos;http://hl7.org/fhir/StructureDefinition/&apos;, f:id/@value)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"not(exists(f:constrainedType)) or f:url/@value=concat(&apos;http://hl7.org/fhir/StructureDefinition/&apos;, f:id/@value)",</xsl:text>
					<xsl:text>"text":"sdf-7: If the structure describes a base Resource or Type, the URL has to start with \&quot;http://hl7.org/fhir/StructureDefinition/\&quot; and the tail must match the id",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"not(exists(f:constrainedType)) or f:url/@value=concat(&apos;http://hl7.org/fhir/StructureDefinition/&apos;, f:id/@value)",</xsl:text>
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
			<xsl:when test="string-join(for $elementName in f:*[self::f:snapshot or self::f:differential]/f:element[position()&gt;1]/f:path/@value return if (starts-with($elementName, concat($elementName/ancestor::f:element/parent::f:*/f:element[1]/f:path/@value, &apos;.&apos;))) then &apos;&apos; else $elementName,&apos;&apos;)=&apos;&apos;">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"string-join(for $elementName in f:*[self::f:snapshot or self::f:differential]/f:element[position()&gt;1]/f:path/@value return if (starts-with($elementName, concat($elementName/ancestor::f:element/parent::f:*/f:element[1]/f:path/@value, &apos;.&apos;))) then &apos;&apos; else $elementName,&apos;&apos;)=&apos;&apos;",</xsl:text>
					<xsl:text>"text":"sdf-8: In any snapshot or differential, all the elements except the first have to have a path that starts with the path of the first + \&quot;.\&quot;",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"string-join(for $elementName in f:*[self::f:snapshot or self::f:differential]/f:element[position()&gt;1]/f:path/@value return if (starts-with($elementName, concat($elementName/ancestor::f:element/parent::f:*/f:element[1]/f:path/@value, &apos;.&apos;))) then &apos;&apos; else $elementName,&apos;&apos;)=&apos;&apos;",</xsl:text>
				<xsl:text>"text":"sdf-8: In any snapshot or differential, all the elements except the first have to have a path that starts with the path of the first + \&quot;.\&quot;",</xsl:text>
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
			<xsl:when test="(f:abstract/@value=true()) or not(exists(f:constrainedType)) or exists(f:base)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition",</xsl:text>
					<xsl:text>"assert":"(f:abstract/@value=true()) or not(exists(f:constrainedType)) or exists(f:base)",</xsl:text>
					<xsl:text>"text":"sdf-10: If the structure is not abstract, or there&apos;s a constrained type, then there SHALL be a base",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition",</xsl:text>
				<xsl:text>"assert":"(f:abstract/@value=true()) or not(exists(f:constrainedType)) or exists(f:base)",</xsl:text>
				<xsl:text>"text":"sdf-10: If the structure is not abstract, or there&apos;s a constrained type, then there SHALL be a base",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:text/h:div">
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
		<xsl:choose>
			<xsl:when test="not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])",</xsl:text>
					<xsl:text>"text":"txt-1: The narrative SHALL contain only the basic html formatting elements described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"not(descendant-or-self::*[not(local-name(.)=(&apos;a&apos;, &apos;abbr&apos;, &apos;acronym&apos;, &apos;b&apos;, &apos;big&apos;, &apos;blockquote&apos;, &apos;br&apos;, &apos;caption&apos;, &apos;cite&apos;, &apos;code&apos;, &apos;col&apos;, &apos;colgroup&apos;, &apos;dd&apos;, &apos;dfn&apos;, &apos;div&apos;, &apos;dl&apos;, &apos;dt&apos;, &apos;em&apos;, &apos;h1&apos;, &apos;h2&apos;, &apos;h3&apos;, &apos;h4&apos;, &apos;h5&apos;, &apos;h6&apos;, &apos;hr&apos;, &apos;i&apos;, &apos;img&apos;, &apos;li&apos;, &apos;ol&apos;, &apos;p&apos;, &apos;pre&apos;, &apos;q&apos;, &apos;samp&apos;, &apos;small&apos;, &apos;span&apos;, &apos;strong&apos;, &apos;table&apos;, &apos;tbody&apos;, &apos;td&apos;, &apos;tfoot&apos;, &apos;th&apos;, &apos;thead&apos;, &apos;tr&apos;, &apos;tt&apos;, &apos;ul&apos;, &apos;var&apos;))])",</xsl:text>
				<xsl:text>"text":"txt-1: The narrative SHALL contain only the basic html formatting elements described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:text/h:div",</xsl:text>
					<xsl:text>"assert":"not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])",</xsl:text>
					<xsl:text>"text":"txt-3: The narrative SHALL contain only the basic html formatting attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:text/h:div",</xsl:text>
				<xsl:text>"assert":"not(descendant-or-self::*/@*[not(name(.)=(&apos;abbr&apos;, &apos;accesskey&apos;, &apos;align&apos;, &apos;alt&apos;, &apos;axis&apos;, &apos;bgcolor&apos;, &apos;border&apos;, &apos;cellhalign&apos;, &apos;cellpadding&apos;, &apos;cellspacing&apos;, &apos;cellvalign&apos;, &apos;char&apos;, &apos;charoff&apos;, &apos;charset&apos;, &apos;cite&apos;, &apos;class&apos;, &apos;colspan&apos;, &apos;compact&apos;, &apos;coords&apos;, &apos;dir&apos;, &apos;frame&apos;, &apos;headers&apos;, &apos;height&apos;, &apos;href&apos;, &apos;hreflang&apos;, &apos;hspace&apos;, &apos;id&apos;, &apos;lang&apos;, &apos;longdesc&apos;, &apos;name&apos;, &apos;nowrap&apos;, &apos;rel&apos;, &apos;rev&apos;, &apos;rowspan&apos;, &apos;rules&apos;, &apos;scope&apos;, &apos;shape&apos;, &apos;span&apos;, &apos;src&apos;, &apos;start&apos;, &apos;style&apos;, &apos;summary&apos;, &apos;tabindex&apos;, &apos;title&apos;, &apos;type&apos;, &apos;valign&apos;, &apos;value&apos;, &apos;vspace&apos;, &apos;width&apos;))])",</xsl:text>
				<xsl:text>"text":"txt-3: The narrative SHALL contain only the basic html formatting attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes",</xsl:text>
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
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:identifier/f:assigner",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
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

	<xsl:template match="f:StructureDefinition/f:mapping">
		<xsl:choose>
			<xsl:when test="exists(f:uri) or exists(f:name)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:mapping",</xsl:text>
					<xsl:text>"assert":"exists(f:uri) or exists(f:name)",</xsl:text>
					<xsl:text>"text":"sdf-2: Must have at a name or a uri (or both)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:mapping",</xsl:text>
				<xsl:text>"assert":"exists(f:uri) or exists(f:name)",</xsl:text>
				<xsl:text>"text":"sdf-2: Must have at a name or a uri (or both)",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot">
		<xsl:choose>
			<xsl:when test="count(f:element) &gt;= count(distinct-values(f:element/f:path/@value))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot",</xsl:text>
					<xsl:text>"assert":"count(f:element) &gt;= count(distinct-values(f:element/f:path/@value))",</xsl:text>
					<xsl:text>"text":"sdf-1: Element paths must be unique - or not (LM)",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot",</xsl:text>
				<xsl:text>"assert":"count(f:element) &gt;= count(distinct-values(f:element/f:path/@value))",</xsl:text>
				<xsl:text>"text":"sdf-1: Element paths must be unique - or not (LM)",</xsl:text>
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
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))",</xsl:text>
					<xsl:text>"text":"eld-8: Pattern and value are mutually exclusive",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))",</xsl:text>
				<xsl:text>"text":"eld-8: Pattern and value are mutually exclusive",</xsl:text>
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
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)=1)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)=1)",</xsl:text>
					<xsl:text>"text":"eld-7: Pattern may only be specified if there is one type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)=1)",</xsl:text>
				<xsl:text>"text":"eld-7: Pattern may only be specified if there is one type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)=1)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)=1)",</xsl:text>
					<xsl:text>"text":"eld-6: Fixed value may only be specified if there is one type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)=1)",</xsl:text>
				<xsl:text>"text":"eld-6: Fixed value may only be specified if there is one type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:nameReference) and exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:nameReference) and exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))",</xsl:text>
					<xsl:text>"text":"eld-5: Either a namereference or a fixed value (but not both) is permitted",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:nameReference) and exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))",</xsl:text>
				<xsl:text>"text":"eld-5: Either a namereference or a fixed value (but not both) is permitted",</xsl:text>
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
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetUri">
		<xsl:choose>
			<xsl:when test="starts-with(string(@value), &apos;http:&apos;) or starts-with(string(@value), &apos;https:&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetUri",</xsl:text>
					<xsl:text>"assert":"starts-with(string(@value), &apos;http:&apos;) or starts-with(string(@value), &apos;https:&apos;)",</xsl:text>
					<xsl:text>"text":"eld-12: URI SHALL start with http:// or https://",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetUri",</xsl:text>
				<xsl:text>"assert":"starts-with(string(@value), &apos;http:&apos;) or starts-with(string(@value), &apos;https:&apos;)",</xsl:text>
				<xsl:text>"text":"eld-12: URI SHALL start with http:// or https://",</xsl:text>
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
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:snapshot/f:element/f:binding/f:valueSetReference",</xsl:text>
				<xsl:text>"assert":"not(starts-with(f:reference/@value, &apos;#&apos;)) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, &apos;#&apos;)])",</xsl:text>
				<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element">
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
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))",</xsl:text>
					<xsl:text>"text":"eld-8: Pattern and value are mutually exclusive",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or not(exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))",</xsl:text>
				<xsl:text>"text":"eld-8: Pattern and value are mutually exclusive",</xsl:text>
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
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)=1)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)=1)",</xsl:text>
					<xsl:text>"text":"eld-7: Pattern may only be specified if there is one type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;pattern&apos;)])) or (count(f:type)=1)",</xsl:text>
				<xsl:text>"text":"eld-7: Pattern may only be specified if there is one type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)=1)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)=1)",</xsl:text>
					<xsl:text>"text":"eld-6: Fixed value may only be specified if there is one type",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:*[starts-with(local-name(.), &apos;fixed&apos;)])) or (count(f:type)=1)",</xsl:text>
				<xsl:text>"text":"eld-6: Fixed value may only be specified if there is one type",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="not(exists(f:nameReference) and exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
					<xsl:text>"assert":"not(exists(f:nameReference) and exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))",</xsl:text>
					<xsl:text>"text":"eld-5: Either a namereference or a fixed value (but not both) is permitted",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element",</xsl:text>
				<xsl:text>"assert":"not(exists(f:nameReference) and exists(f:*[starts-with(local-name(.), &apos;value&apos;)]))",</xsl:text>
				<xsl:text>"text":"eld-5: Either a namereference or a fixed value (but not both) is permitted",</xsl:text>
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
	</xsl:template>

	<xsl:template match="f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetUri">
		<xsl:choose>
			<xsl:when test="starts-with(string(@value), &apos;http:&apos;) or starts-with(string(@value), &apos;https:&apos;)">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetUri",</xsl:text>
					<xsl:text>"assert":"starts-with(string(@value), &apos;http:&apos;) or starts-with(string(@value), &apos;https:&apos;)",</xsl:text>
					<xsl:text>"text":"eld-12: URI SHALL start with http:// or https://",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetUri",</xsl:text>
				<xsl:text>"assert":"starts-with(string(@value), &apos;http:&apos;) or starts-with(string(@value), &apos;https:&apos;)",</xsl:text>
				<xsl:text>"text":"eld-12: URI SHALL start with http:// or https://",</xsl:text>
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
					<xsl:text>"text":"ref-1: SHALL have a local reference if the resource is provided inline",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:StructureDefinition/f:differential/f:element/f:binding/f:valueSetReference",</xsl:text>
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
