<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<!-- 
		healthcareProviders overrides the template from ../HealthcareProvider.xsl.
		This version exports Laboratory Performer, but only when there is only
		one distinct Laboratory Performer found in the XD-LAB document.
	-->
	<xsl:template match="*" mode="healthcareProviders">
		<!--
			Field : Laboratory Result Performer
			Target: /ClinicalDocument/documentationOf/serviceEvent/performer/assignedEntity
			Source: HS.SDA3.Result PerformedAt
			Source: /Container/LabOrders/LabOrder/Result/PerformedAt/Code
			StructuredMappingRef: assignedEntity-performer
			Note  : Laboratory Result Performer is exported to serviceEvent
					only of there is one distinct PerformedAt throughout
					the document.
		-->
		<!--
			Field : Laboratory Result Item Performer
			Target: /ClinicalDocument/documentationOf/serviceEvent/performer/assignedEntity
			Source: HS.SDA3.LabResultItem PerformedAt
			Source: /Container/LabOrders/LabOrder/Result/ResultItems/LabResultItem/PerformedAt/Code
			StructuredMappingRef: assignedEntity-performer
			Note  : Laboratory Result Item Performer is exported to
					serviceEvent only of there is one distinct PerformedAt
					throughout the document.
		-->
		<xsl:variable name="laboratoryPerformers">
			<xsl:for-each select="set:distinct(/Container/LabOrders/LabOrder//PerformedAt/Code)">1</xsl:for-each>
		</xsl:variable>
		
		<xsl:if test="$laboratoryPerformers='1'">
			<documentationOf>
				<serviceEvent>
					<!-- Effective Time -->
					<effectiveTime>
						<low nullFlavor="UNK"/>
						<high nullFlavor="UNK"/>
					</effectiveTime>
					
					<xsl:apply-templates select="/Container" mode="documentationOf-labPerformer"/>
				</serviceEvent>
			</documentationOf>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="documentationOf-labPerformer">
		<xsl:for-each select="set:distinct(/Container/LabOrders/LabOrder//PerformedAt/Code)">
			<performer typeCode="PRF">
				<templateId root="{$ihe-PCC-LaboratoryPerformer}"/>
				<time>
					<low nullFlavor="UNK"/>
					<high nullFlavor="UNK"/>
				</time>
				<xsl:apply-templates select="parent::node()" mode="assignedEntity-performer"/>
			</performer>
		</xsl:for-each>
	</xsl:template>
	
	<!-- participants-OrderedBy exports SDA LabOrder OrderedBy (ordering clinicians) into document-level participants. -->
	<xsl:template match="*" mode="participants-OrderedBy">
		<xsl:apply-templates select="LabOrders/LabOrder[(string-length(Result/ResultText/text()) or string-length(Result/ResultItems)) and string-length(OrderedBy)]" mode="participant-OrderedBy"/>
	</xsl:template>
	
	<xsl:template match="*" mode="participant-OrderedBy">
		<!--
			Field : Ordering Physician
			Target: /ClinicalDocument/participant[templateId='1.3.6.1.4.1.19376.1.3.3.1.6']
			Source: HS.SDA3.AbstractOrder OrderedBy
			Source: /Container/LabOrders/LabOrder/associatedEntity
			StructuredMappingRef: associatedEntity
			Note  : The CDA particpant for Ordering Physician appears
					only in CDA XD-LAB.  SDA OrderedBy is export to
					CDA Ordering Physician only for SDA LabOrders
					that have results.
		-->
		<participant typeCode="REF">
			<templateId root="{$ihe-PCC-ReferralOrderingPhysician}"/>
			<xsl:apply-templates select="." mode="time"/>
			<xsl:apply-templates select="OrderedBy" mode="associatedEntity">
				<xsl:with-param name="contactType" select="'PROV'"/>
			</xsl:apply-templates>
		</participant>
	</xsl:template>
</xsl:stylesheet>
