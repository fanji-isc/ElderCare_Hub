<!-- Return an SDA with only patients, encounters, enrollments, and claims -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:isc="http://extension-functions.intersystems.com"
				version="1.0"
				exclude-result-prefixes="isc">
	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
	<xsl:strip-space elements="*"/>

	<!-- Patient comes first, then Encounter -->
	<xsl:template match="/Container">
		<xsl:copy>
			<xsl:apply-templates select="MemberEnrollments"/>
			<xsl:apply-templates select="MedicalClaims"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/MemberEnrollments">
		<xsl:copy>
			<xsl:for-each select="MemberEnrollment">
				<xsl:sort select="string-length(ToTime)=0" order="descending"/>
				<xsl:sort select="ToTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
				<xsl:copy-of select="." /> 
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Container/MedicalClaims">
		<xsl:copy>
			<xsl:for-each select="MedicalClaim">
				<xsl:sort select="string-length(ToTime)=0" order="descending"/>
				<xsl:sort select="ToTime" order="descending"/>
				<xsl:sort select="FromTime" order="descending"/>
				<xsl:copy-of select="." /> 
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>