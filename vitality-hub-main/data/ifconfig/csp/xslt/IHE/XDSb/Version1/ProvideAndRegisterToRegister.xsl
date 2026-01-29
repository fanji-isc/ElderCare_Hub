<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="isc rim rs lcm" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" xmlns:ihe="urn:ihe:iti:xds-b:2007">
	<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
	<xsl:param name="repositoryOID"/>
	<xsl:template match="/root/ihe:ProvideAndRegisterDocumentSetRequest/ihe:Document">
	<!-- if there are any inline documents be sure to remove them -->
	</xsl:template>
	<xsl:template match="/root/ihe:ProvideAndRegisterDocumentSetRequest/lcm:SubmitObjectsRequest/rim:RegistryObjectList">
		<lcm:SubmitObjectsRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0">
			<rim:RegistryObjectList><!-- Copy ObjectRef -->
				<xsl:call-template name="ObjectRef"/><!-- Copy ExtrinsicObject -->
				<xsl:call-template name="ExtrinsicObject"/><!-- Copy RegistryPackage -->
				<xsl:call-template name="RegistryPackage"/>
				<xsl:call-template name="Classification"/>
				<xsl:call-template name="Association"/>
			</rim:RegistryObjectList>
		</lcm:SubmitObjectsRequest>
	</xsl:template>
	<xsl:template name="ExtrinsicObject">
		<xsl:for-each select="rim:ExtrinsicObject">
			<xsl:variable name="position" select="position()"/>
			<xsl:variable name="size" select="/root/DocInfo[$position]/@size"/>
			<xsl:variable name="hash" select="/root/DocInfo[$position]/@hash"/>
			<rim:ExtrinsicObject>
				<xsl:if test="@id">
					<xsl:attribute name="id">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@lid">
					<xsl:attribute name="lid">
						<xsl:value-of select="@lid"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@mimeType">
					<xsl:attribute name="mimeType">
						<xsl:value-of select="@mimeType"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@objectType">
					<xsl:attribute name="objectType">
						<xsl:value-of select="@objectType"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@status">
					<xsl:attribute name="status">
						<xsl:value-of select="@status"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="Slot"/>
				<rim:Slot name="repositoryUniqueId">
					<rim:ValueList>
						<rim:Value>
							<xsl:value-of select="$repositoryOID"/>
						</rim:Value>
					</rim:ValueList>
				</rim:Slot>
				<rim:Slot name="hash">
					<rim:ValueList>
						<rim:Value>
							<xsl:value-of select="$hash"/>
						</rim:Value>
					</rim:ValueList>
				</rim:Slot>
				<rim:Slot name="size">
					<rim:ValueList>
						<rim:Value>
							<xsl:value-of select="$size"/>
						</rim:Value>
					</rim:ValueList>
				</rim:Slot>
				<xsl:call-template name="Name"/>
				<xsl:call-template name="Description"/>
				<xsl:call-template name="Classification"/>
				<xsl:call-template name="ExternalIdentifier"/>
			</rim:ExtrinsicObject>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="RegistryPackage">
		<xsl:for-each select="rim:RegistryPackage">
			<rim:RegistryPackage>
				<xsl:if test="@id">
					<xsl:attribute name="id">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@lid">
					<xsl:attribute name="lid">
						<xsl:value-of select="@lid"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@mimeType">
					<xsl:attribute name="mimeType">
						<xsl:value-of select="@mimeType"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@objectType">
					<xsl:attribute name="objectType">
						<xsl:value-of select="@objectType"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@status">
					<xsl:attribute name="status">
						<xsl:value-of select="@status"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="Slot"/>
				<xsl:call-template name="Name"/>
				<xsl:call-template name="Description"/>
				<xsl:call-template name="Classification"/>
				<xsl:call-template name="ExternalIdentifier"/>
			</rim:RegistryPackage>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="Association">
		<xsl:for-each select="rim:Association">
			<rim:Association>
				<xsl:if test="@id">
					<xsl:attribute name="id">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@lid">
					<xsl:attribute name="lid">
						<xsl:value-of select="@lid"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@associationType">
					<xsl:attribute name="associationType">
						<xsl:value-of select="@associationType"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@sourceObject">
					<xsl:attribute name="sourceObject">
						<xsl:value-of select="@sourceObject"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@targetObject">
					<xsl:attribute name="targetObject">
						<xsl:value-of select="@targetObject"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="Slot"/>
			</rim:Association>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="ObjectRef">
		<xsl:for-each select="rim:ObjectRef">
			<rim:ObjectRef>
				<xsl:if test="@id">
					<xsl:attribute name="id">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
				</xsl:if>
			</rim:ObjectRef>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="Slot">
		<xsl:for-each select="rim:Slot">
			<xsl:if test="not(@name = 'size' or @name='hash' or @name='repositoryUniqueId')">
			<rim:Slot>
				<xsl:if test="@name">
					<xsl:attribute name="name">
						<xsl:value-of select="@name"/>
					</xsl:attribute>
				</xsl:if>
				<rim:ValueList>
					<xsl:for-each select="rim:ValueList/rim:Value">
						<rim:Value>
							<xsl:value-of select="text()"/>
						</rim:Value>
					</xsl:for-each>
				</rim:ValueList>
			</rim:Slot>
				</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="Classification">
		<xsl:for-each select="rim:Classification">
			<rim:Classification>
				<xsl:if test="@classificationScheme">
					<xsl:attribute name="classificationScheme">
						<xsl:value-of select="@classificationScheme"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@classifiedObject">
					<xsl:attribute name="classifiedObject">
						<xsl:value-of select="@classifiedObject"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@id">
					<xsl:attribute name="id">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@nodeRepresentation">
					<xsl:attribute name="nodeRepresentation">
						<xsl:value-of select="@nodeRepresentation"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@objectType">
					<xsl:attribute name="objectType">
						<xsl:value-of select="@objectType"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@classificationNode">
					<xsl:attribute name="classificationNode">
						<xsl:value-of select="@classificationNode"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="Slot"/>
				<xsl:call-template name="Name"/>
				<xsl:call-template name="Description"/>
			</rim:Classification>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="ExternalIdentifier">
		<xsl:for-each select="rim:ExternalIdentifier">
			<rim:ExternalIdentifier>
				<xsl:if test="@id">
					<xsl:attribute name="id">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@registryObject">
					<xsl:attribute name="registryObject">
						<xsl:value-of select="@registryObject"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@identificationScheme">
					<xsl:attribute name="identificationScheme">
						<xsl:value-of select="@identificationScheme"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@objectType">
					<xsl:attribute name="objectType">
						<xsl:value-of select="@objectType"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@value">
					<xsl:attribute name="value">
						<xsl:value-of select="@value"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="Name"/>
				<xsl:call-template name="Description"/>
			</rim:ExternalIdentifier>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="Name">
		<xsl:if test="rim:Name">
			<xsl:variable name="context" select="rim:Name/rim:LocalizedString"/>
			<rim:Name>
				<xsl:if test="$context">
					<rim:LocalizedString>
						<xsl:if test="$context/@charset">
							<xsl:attribute name="charset">
								<xsl:value-of select="$context/@charset"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$context/@value">
							<xsl:attribute name="value">
								<xsl:value-of select="$context/@value"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$context/@xml:lang">
							<xsl:attribute name="xml:lang">
								<xsl:value-of select="$context/@xml:lang"/>
							</xsl:attribute>
						</xsl:if>
					</rim:LocalizedString>
				</xsl:if>
			</rim:Name>
		</xsl:if>
	</xsl:template>
	<xsl:template name="Description">
		<xsl:if test="rim:Description">
			<rim:Description>
				<xsl:variable name="context" select="rim:Description/rim:LocalizedString"/>
				<xsl:if test="$context">
					<rim:LocalizedString>
						<xsl:if test="$context/@charset">
							<xsl:attribute name="charset">
								<xsl:value-of select="$context/@charset"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$context/@value">
							<xsl:attribute name="value">
								<xsl:value-of select="$context/@value"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$context/@xml:lang">
							<xsl:attribute name="xml:lang">
								<xsl:value-of select="$context/@xml:lang"/>
							</xsl:attribute>
						</xsl:if>
					</rim:LocalizedString>
				</xsl:if>
			</rim:Description>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>
