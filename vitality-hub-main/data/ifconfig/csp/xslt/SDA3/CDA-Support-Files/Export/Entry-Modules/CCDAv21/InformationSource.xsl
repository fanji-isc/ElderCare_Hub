<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc xsi">
  <!-- AlsoInclude: AuthorParticipation.xsl -->
  
	<xsl:template match="Patient" mode="eIS-informationSource">
		<xsl:param name="isCarePlan" select="false()"/>

		<!-- Document level Human author is handled differently  -->
		<!-- than the entry-level Human authors.  For now, omit  -->
		<!-- the person info and just use the organization info. -->
		<!-- MU2 doesn't allow an author with assignedAuthor/assignedPerson but no real assignedPerson data, so don't export author-Document. -->
		<!--<xsl:apply-templates select="$homeCommunity/Organization" mode="eAP-author-Document"/>-->
		
		<xsl:choose>
			<xsl:when test="$isCarePlan">
				<!-- Care Plan Authors-->
				<xsl:apply-templates select="../CarePlans/CarePlan[1]/Authors/DocumentProvider/Provider" mode="eAP-author-Human" />	
			</xsl:when>
			<xsl:otherwise>
				<!-- Author (Software Device) -->
				<xsl:apply-templates select="$homeCommunity/Organization" mode="eAP-author-Device"/>
			</xsl:otherwise>
		</xsl:choose>

		<!-- Office Contact info -->
		<!-- <xsl:apply-templates select ="../Encounters/Encounter/Extension/OfficeContact" mode="eIS-dataEnterer-officeContact"/> -->
		
		<!-- Informant -->
		<!--<xsl:apply-templates select="$homeCommunity/Organization" mode="fn-informant"/>-->

		<!-- Referral specific info -->
		<xsl:apply-templates select ="../Referrals/Referral/ReferringProvider" mode="eIS-informant-referralProvider"/>
		
		<!-- Custodian -->
		<xsl:apply-templates select="$homeCommunity/Organization" mode="fn-custodian"/>

		<!-- Referral specific info -->
		<xsl:if test="not($isCarePlan)">
			<xsl:apply-templates select ="../Referrals/Referral" mode="eIS-informationRecipient"/>
		</xsl:if>

		<!-- Legal Authenticator -->
		<xsl:apply-templates select="$legalAuthenticator/Contact" mode="fn-legalAuthenticator"/>

		<xsl:if test="$isCarePlan">
			<!-- Care Plan Support Contact-->
			<xsl:apply-templates select="../CarePlans/CarePlan[1]/SupportContacts/SupportContact" mode="eIS-participant-SupportContact" />	

			<!--Organization-->
			<xsl:apply-templates select="../CarePlans/CarePlan[1]/Organizations/DocumentOrganization/Organization" mode="eIS-organization" />				
		</xsl:if>
	</xsl:template>

 	<xsl:template match="*" mode="eIS-participant-SupportContact">
		<participant typeCode="IND">
			<xsl:apply-templates select="." mode="fn-associatedEntity">
				<xsl:with-param name="contactType" select="ContactType/Code/text()"/>
			</xsl:apply-templates>
		</participant>		
	</xsl:template>

 	<xsl:template match="*" mode="eIS-organization">
		<participant typeCode="LOC">
			<xsl:apply-templates select="." mode="fn-associatedEntity-scopingOrganization"/>
		</participant>
	</xsl:template>	

	<xsl:template match="ReferringProvider" mode="eIS-informant-referralProvider" >
		<informant>
			<assignedEntity>
				<!-- Referring id -->
				<xsl:apply-templates select="." mode="fn-id-Clinician"/>

				<!-- Referring address -->
				<xsl:apply-templates select="." mode="fn-address"/>

				<!-- Referring telecom -->
				<xsl:apply-templates select="." mode="fn-telecom"/>

    			<assignedPerson>
					<!-- Referring Name-->
					<xsl:apply-templates select="." mode="fn-name-Person"/>
			    </assignedPerson>
			</assignedEntity>
		</informant>
	</xsl:template>

	<xsl:template match="Referral" mode="eIS-informationRecipient" >
		<informationRecipient>
			<intendedRecipient>
				<!-- Referred To Telecom --> 
				<xsl:apply-templates select="ReferredToProvider" mode="fn-telecom"/>
				<informationRecipient>
					<!-- Referred To Name-->
					<xsl:apply-templates select="ReferredToProvider" mode="fn-name-Person"/>
				</informationRecipient>
				<receivedOrganization>
					<!-- Referred To Name-->
					<xsl:apply-templates select="ReferredToOrganization" mode="fn-name-Organization"/>

					<!-- Referred To Telecom --> 
					<xsl:apply-templates select="ReferredToOrganization/Organization" mode="fn-telecom"/>

					<!-- Referred To address -->
					<xsl:apply-templates select="ReferredToOrganization/Organization" mode="fn-address"/>
				</receivedOrganization>
			</intendedRecipient>
		</informationRecipient>
	</xsl:template>
	
</xsl:stylesheet>