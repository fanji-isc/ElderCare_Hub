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
			
			<xsl:choose>
				<xsl:when test="/Container/Action = 'Merge'">
					<PriorMRN>
						<xsl:value-of select="PriorPatientNumbers/PatientNumber[NumberType = 'MRN']/Number"/>
					</PriorMRN>
					<PriorAssigningAuthority>
						<xsl:value-of
							select="PriorPatientNumbers/PatientNumber[NumberType = 'MRN']/Organization/Code"/>
					</PriorAssigningAuthority>
				</xsl:when>
				<xsl:otherwise>
					<FirstName>
						<xsl:value-of select="Name/GivenName"/>
					</FirstName>
					<MiddleName>
						<xsl:value-of select="Name/MiddleName"/>
					</MiddleName>
					<LastName>
						<xsl:value-of select="Name/FamilyName"/>
					</LastName>
					<Sex>
						<xsl:value-of select="Gender/Code"/>
					</Sex>
					<DOB>
						<xsl:value-of select="BirthTime"/>
					</DOB>
					<Street>
						<xsl:value-of select="Addresses/Address/Street"/>
					</Street>
					<City>
						<xsl:value-of select="Addresses/Address/City/Code"/>
					</City>
					<Zip>
						<xsl:value-of select="Addresses/Address/Zip/Code"/>
					</Zip>
					<State>
						<xsl:value-of select="Addresses/Address/State/Code"/>
					</State>
					<Telephone>
						<xsl:value-of select="ContactInfo/HomePhoneNumber"/>
					</Telephone>
					<SSN>
						<xsl:value-of select="PatientNumbers/PatientNumber[NumberType = 'SSN']/Number"/>
					</SSN>
				</xsl:otherwise>
			</xsl:choose>
		</PatientInfo>

	</xsl:template>	

</xsl:stylesheet>
