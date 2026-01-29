<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				version="1.0">
	
	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
	<xsl:param name="OldMRN"/>
	<xsl:param name="NewMRN"/>
	<xsl:param name="Extension"/>

<xsl:template match="/">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="Patient">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	<xsl:if test="not(not($Extension))">
		<CustomXMLString>
		<xsl:value-of select="$Extension"/>
		</CustomXMLString>
		<CustomClassName>HS.Local.SDA3.PatientExtension</CustomClassName>
	</xsl:if>
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

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>