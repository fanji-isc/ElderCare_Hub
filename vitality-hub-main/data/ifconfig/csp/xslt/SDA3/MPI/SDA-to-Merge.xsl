<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				version="1.0">
	
	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>
		
	<xsl:template match="/">
		<xsl:apply-templates select="Container/Patient" />
	</xsl:template>
			
	<xsl:template match="/Container/Patient">
		<PatientInfo>
			<Facility>
				<xsl:value-of select="/Container/SendingFacility"/>
			</Facility>
			<MRN>
				<xsl:value-of select="PatientNumbers/PatientNumber[NumberType = 'MRN']/Number"/>
			</MRN>
			<AssigningAuthority>
				<xsl:value-of
					select="PatientNumbers/PatientNumber[NumberType = 'MRN']/Organization/Code"/>
			</AssigningAuthority>
			<PriorMRN>
				<xsl:value-of select="PriorPatientNumbers/PatientNumber[NumberType = 'MRN']/Number"/>
			</PriorMRN>
			<PriorAssigningAuthority>
				<xsl:value-of
					select="PriorPatientNumbers/PatientNumber[NumberType = 'MRN']/Organization/Code"/>
			</PriorAssigningAuthority>
		</PatientInfo>
	</xsl:template>	

</xsl:stylesheet>
