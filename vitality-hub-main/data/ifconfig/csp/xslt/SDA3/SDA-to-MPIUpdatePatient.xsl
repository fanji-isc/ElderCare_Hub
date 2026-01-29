<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				version="1.0">
	
	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
	<xsl:param name="OldMRN"/>
	<xsl:param name="NewMRN"/>
	<!-- not in use, but keeping for reference as potentially useful code for the future-->

	<xsl:template match="Container">
		<Container>
		<Facility>
			<xsl:value-of select="SendingFacility"/>
		</Facility>
		<EventDescription><xsl:value-of select="EventDescription"/></EventDescription>
		<Action><xsl:value-of select="Action"/></Action>
		<UpdateECRDemographics><xsl:value-of select="UpdateECRDemographics"/></UpdateECRDemographics>
		<xsl:apply-templates select="Patient" />
		<xsl:apply-templates select="AdditionalInfo" />
		</Container>
	</xsl:template>

	<xsl:template match="AdditionalInfo">
		<xsl:copy-of select = "."/>
	</xsl:template>

	<xsl:template match="Patient">
			  <xsl:copy>
			    <xsl:apply-templates select="@* | node()"/>
			  </xsl:copy>
	</xsl:template>
		
	<xsl:template match="PatientNumbers/PatientNumber">
		<xsl:choose>
			<xsl:when test="(NumberType = 'MRN') and (Number = $OldMRN)">
				<PatientNumber>
					<Number><xsl:value-of select="$NewMRN"/></Number>
					<NumberType>MRN</NumberType>
					<xsl:copy-of select="Organization"/>
				</PatientNumber>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*">
		<xsl:if test="node()">			
			<xsl:copy>
			    <xsl:apply-templates select="@* | node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>