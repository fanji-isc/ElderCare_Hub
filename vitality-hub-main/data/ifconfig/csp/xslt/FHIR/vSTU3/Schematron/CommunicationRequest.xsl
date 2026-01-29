<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->

	<xsl:param name="includeSuccessfulTests" select="'0'"/>

	<xsl:output indent="no" method="text" media-type="application/json"/>

	<xsl:template match="/">
		<xsl:text>{"result":[</xsl:text>
		<xsl:apply-templates select="f:CommunicationRequest/f:extension"/>
		<xsl:apply-templates select="f:CommunicationRequest/f:modifierExtension"/>
		<xsl:apply-templates select="f:CommunicationRequest"/>
		<xsl:apply-templates select="f:CommunicationRequest/f:text/h:div"/>
		<xsl:apply-templates select="f:CommunicationRequest/f:identifier/f:period"/>
		<xsl:apply-templates select="f:CommunicationRequest/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:CommunicationRequest/f:basedOn"/>
		<xsl:apply-templates select="f:CommunicationRequest/f:basedOn/f:identifier/f:period"/>
		<xsl:apply-templates select="f:CommunicationRequest/f:basedOn/f:identifier/f:assigner"/>
