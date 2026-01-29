<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">
  <!-- AlsoInclude: AuthorParticipation.xsl -->
  
	<xsl:template match="*" mode="eCm-component-comment">
		<!-- This mode appears to be UNUSED -->
		<xsl:param name="narrativeLink"/>
		
		<component>
			<xsl:apply-templates select="." mode="eCm-act-comment"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
		</component>
	</xsl:template>

	<xsl:template match="Comments | NoteText | SocialHabitComments" mode="eCm-entryRelationship-comments">
		<xsl:param name="narrativeLink"/>
		
		<entryRelationship typeCode="SUBJ" inversionInd="true">
			<xsl:apply-templates select="." mode="eCm-act-comment"><xsl:with-param name="narrativeLink" select="$narrativeLink"/></xsl:apply-templates>
		</entryRelationship>
	</xsl:template>
	
	<xsl:template match="*" mode="eCm-act-comment">
		<xsl:param name="narrativeLink"/>
		
		<act classCode="ACT" moodCode="EVN"> 
			<xsl:call-template name="eCm-templateIds-comments"/>
			
			<code code="48767-8" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Annotation Comment"/> 
			<text><reference value="{$narrativeLink}"/></text>
			
			<!-- Author (Human) -->
			<xsl:apply-templates select="../Clinician | ../DiagnosingClinician | ../OrderedBy | ../VerifiedBy | ../../VerifiedBy | ../Result/VerifiedBy" mode="eAP-author-Human"/>
		</act>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="eCm-templateIds-comments">
		<templateId root="{$ccda-CommentActivity}"/>
		<templateId root="{$ccda-CommentActivity}" extension="2015-08-01"/>
	</xsl:template>
</xsl:stylesheet>
