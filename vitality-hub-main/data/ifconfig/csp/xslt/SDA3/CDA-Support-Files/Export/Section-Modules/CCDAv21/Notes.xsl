<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc exsl set">

	<xsl:template match="*" mode="sN-notes">
		<xsl:param name="sectionRequired" select="'0'"/>

		<!-- Document export to Notes section must be explicitly enabled via ExportProfile.xml -->
		<xsl:if test="$exportConfiguration/notes">
			<xsl:variable name="default" select="$exportConfiguration/notes/category[code/text() = $exportConfiguration/notes/default/text()]"/>
			<xsl:variable name="documents" select="Documents"/>
			<xsl:variable name="categorized"><xsl:apply-templates mode="sN-notes-categorize" select="Documents/Document"/></xsl:variable>
			<xsl:variable name="docs" select="exsl:node-set($categorized)"/>

			<xsl:choose>
				<!-- all documents to default section -->
				<xsl:when test="$exportConfiguration/notes/singleSection/text() = '1'">
					<xsl:apply-templates select="$documents" mode="sN-notes-section">
						<xsl:with-param name="sectionRequired" select="$sectionRequired"/>
						<xsl:with-param name="config" select="$default"/>
						<xsl:with-param name="docs" select="$docs/doc"/>
					</xsl:apply-templates>
				</xsl:when>
				<!-- categorized to specific section; optionally uncategoried to default section -->
				<xsl:otherwise>
					<xsl:for-each select="$exportConfiguration/notes/category">
						<xsl:variable name="config" select="."/>
						<xsl:if test="($exportConfiguration/notes/uncategorized/text() = '1') or (not($config/code/text() = $default/code/text()))">
							<xsl:apply-templates select="$documents" mode="sN-notes-section">
								<xsl:with-param name="sectionRequired" select="$sectionRequired"/>
								<xsl:with-param name="config" select="$config"/>
								<xsl:with-param name="docs" select="$docs/doc[@category = $config/code/text()]"/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Documents" mode="sN-notes-section">
		<xsl:param name="sectionRequired" />
		<xsl:param name="config" />
		<xsl:param name="docs" />

		<xsl:variable name="hasData" select="count($docs)"/>

		<xsl:if test="($hasData > 0) or ($sectionRequired = '1')">
			<component>
				<section>
					<xsl:if test="$hasData = 0"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>

					<xsl:call-template name="sN-templateIds-notesSection"/>

					<code code="{$config/code/text()}" displayName="{$config/name/text()}" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title><xsl:value-of select="$config/title/text()"/></title>

					<xsl:choose>
						<xsl:when test="$hasData > 0">
							<xsl:apply-templates select="." mode="eN-notes-Narrative">
								<xsl:with-param name="config" select="$config"/>
								<xsl:with-param name="docs" select="$docs"/>
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="eN-notes-Entries">
								<xsl:with-param name="config" select="$config"/>
								<xsl:with-param name="docs" select="$docs"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="eN-notes-NoData">
								<xsl:with-param name="config" select="$config"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose> 

				</section>
			</component>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Document" mode="sN-notes-categorize">
		<xsl:variable name="docType" select="DocumentType/Code/text()"/>
		<xsl:variable name="docCat" select="Category/Code/text()"/>

		<!-- determine the category (section) this document will get exported to -->
		<xsl:variable name="category">
			<xsl:choose>
				<!-- exact category match -->
				<xsl:when test="$exportConfiguration/notes/category/code[text() = $docCat]">
					<xsl:value-of select="$docCat"/>
				</xsl:when>
				<!-- doctype is a category -->
				<xsl:when test="$exportConfiguration/notes/category/code[text() = $docType]">
					<xsl:value-of select="$docType"/>
				</xsl:when>
				<!-- search for doctype in typeCodes -->
				<xsl:otherwise>
					<xsl:variable name="find" select="concat('|',$docType,'|')"/>
					<xsl:variable name="found" select="$exportConfiguration/notes/category[contains(typeCodes/text(),$find)]"/>
					<xsl:choose>
						<!-- use first category found -->
						<xsl:when test="$found">
								<xsl:value-of select="$found[1]/code/text()"/>
						</xsl:when>
						<!-- else optionally include uncategorized in default section -->
						<xsl:when test="$exportConfiguration/notes/uncategorized/text() = '1'">
								<xsl:value-of select="$exportConfiguration/notes/default/text()"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- include documents with calculated category as an attribute -->
		<xsl:if test="string-length($category)">
			<doc xmlns="" id="{generate-id(.)}" pos="{position()}" category="{$category}"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sN-templateIds-notesSection">
		<templateId root="{$ccda-NotesSection}" extension="2016-11-01"/>
	</xsl:template>

</xsl:stylesheet>