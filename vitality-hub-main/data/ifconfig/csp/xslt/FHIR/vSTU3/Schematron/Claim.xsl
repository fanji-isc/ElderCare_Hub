<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">
<!-- *** THIS XSLT STYLESHEET IS DEPRECATED *** -->

	<xsl:param name="includeSuccessfulTests" select="'0'"/>

	<xsl:output indent="no" method="text" media-type="application/json"/>

	<xsl:template match="/">
		<xsl:text>{"result":[</xsl:text>
		<xsl:apply-templates select="f:Claim/f:extension"/>
		<xsl:apply-templates select="f:Claim/f:modifierExtension"/>
		<xsl:apply-templates select="f:Claim"/>
		<xsl:apply-templates select="f:Claim/f:text/h:div"/>
		<xsl:apply-templates select="f:Claim/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:patient"/>
		<xsl:apply-templates select="f:Claim/f:patient/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:patient/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:billablePeriod"/>
		<xsl:apply-templates select="f:Claim/f:enterer"/>
		<xsl:apply-templates select="f:Claim/f:enterer/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:enterer/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:insurer"/>
		<xsl:apply-templates select="f:Claim/f:insurer/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:insurer/f:identifier//f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:provider"/>
		<xsl:apply-templates select="f:Claim/f:provider/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:provider/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:organization"/>
		<xsl:apply-templates select="f:Claim/f:organization/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:organization/f:identifier//f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:related/f:claim"/>
		<xsl:apply-templates select="f:Claim/f:related/f:claim/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:related/f:claim/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:related/f:reference/f:period"/>
		<xsl:apply-templates select="f:Claim/f:related/f:reference/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:prescription"/>
		<xsl:apply-templates select="f:Claim/f:prescription/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:prescription/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:originalPrescription"/>
		<xsl:apply-templates select="f:Claim/f:originalPrescription/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:originalPrescription/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:payee/f:party"/>
		<xsl:apply-templates select="f:Claim/f:payee/f:party/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:payee/f:party/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:referral"/>
		<xsl:apply-templates select="f:Claim/f:referral/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:referral/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:facility"/>
		<xsl:apply-templates select="f:Claim/f:facility/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:facility/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:careTeam/f:provider"/>
		<xsl:apply-templates select="f:Claim/f:careTeam/f:provider/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:careTeam/f:provider/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:information/f:timingPeriod"/>
		<xsl:apply-templates select="f:Claim/f:information/f:valueQuantity"/>
		<xsl:apply-templates select="f:Claim/f:information/f:valueAttachment"/>
		<xsl:apply-templates select="f:Claim/f:information/f:valueReference"/>
		<xsl:apply-templates select="f:Claim/f:information/f:valueReference/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:information/f:valueReference/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:diagnosis/f:diagnosisReference"/>
		<xsl:apply-templates select="f:Claim/f:diagnosis/f:diagnosisReference/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:diagnosis/f:diagnosisReference/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:procedure/f:procedureReference"/>
		<xsl:apply-templates select="f:Claim/f:procedure/f:procedureReference/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:procedure/f:procedureReference/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:insurance/f:coverage"/>
		<xsl:apply-templates select="f:Claim/f:insurance/f:coverage/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:insurance/f:coverage/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:insurance/f:claimResponse"/>
		<xsl:apply-templates select="f:Claim/f:insurance/f:claimResponse/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:insurance/f:claimResponse/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:accident/f:locationAddress/f:period"/>
		<xsl:apply-templates select="f:Claim/f:accident/f:locationReference"/>
		<xsl:apply-templates select="f:Claim/f:accident/f:locationReference/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:accident/f:locationReference/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:employmentImpacted"/>
		<xsl:apply-templates select="f:Claim/f:hospitalization"/>
		<xsl:apply-templates select="f:Claim/f:item/f:servicedPeriod"/>
		<xsl:apply-templates select="f:Claim/f:item/f:locationAddress/f:period"/>
		<xsl:apply-templates select="f:Claim/f:item/f:locationReference"/>
		<xsl:apply-templates select="f:Claim/f:item/f:locationReference/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:item/f:locationReference/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:item/f:quantity"/>
		<xsl:apply-templates select="f:Claim/f:item/f:unitPrice"/>
		<xsl:apply-templates select="f:Claim/f:item/f:net"/>
		<xsl:apply-templates select="f:Claim/f:item/f:udi"/>
		<xsl:apply-templates select="f:Claim/f:item/f:udi/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:item/f:udi/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:item/f:encounter"/>
		<xsl:apply-templates select="f:Claim/f:item/f:encounter/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:item/f:encounter/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:quantity"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:unitPrice"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:net"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:udi"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:udi/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:udi/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:subDetail/f:quantity"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:subDetail/f:unitPrice"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:subDetail/f:net"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:subDetail/f:udi"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:subDetail/f:udi/f:identifier/f:period"/>
		<xsl:apply-templates select="f:Claim/f:item/f:detail/f:subDetail/f:udi/f:identifier/f:assigner"/>
		<xsl:apply-templates select="f:Claim/f:total"/>
		<xsl:text>{"status":0}</xsl:text>
		<xsl:text>]}</xsl:text>
	</xsl:template>

	<xsl:template match="f:Claim/f:extension">
		<xsl:choose>
			<xsl:when test="exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Claim/f:extension",</xsl:text>
					<xsl:text>"assert":"exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])",</xsl:text>
					<xsl:text>"text":"ext-1: Must have either extensions or value[x], not both",</xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"status":0,</xsl:text>
				<xsl:text>"context":"f:Claim/f:extension",</xsl:text>
				<xsl:text>"assert":"exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])",</xsl:text>
				<xsl:text>"text":"ext-1: Must have either extensions or value[x], not both",</xsl:text>
				<xsl:text>"location":"</xsl:text><xsl:apply-templates select="." mode="currentXPathWithPos"/><xsl:text>"},</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="f:Claim/f:modifierExtension">
		<xsl:choose>
			<xsl:when test="exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])">
				<xsl:if test="$includeSuccessfulTests='1'">
					<xsl:text>{"status":1,</xsl:text>
					<xsl:text>"context":"f:Claim/f:modifierExtension",</xsl:text>
					<xsl:text>"assert":"exists(f:extension)!=exists(f:*[starts-with(local-name(.), &apos;value&apos;)])",</xsl:text>
					<xsl:text>"text":"ext-1: Must have either extensions or value[x], not both",</xsl:text>
					<xsl:text>"location":
