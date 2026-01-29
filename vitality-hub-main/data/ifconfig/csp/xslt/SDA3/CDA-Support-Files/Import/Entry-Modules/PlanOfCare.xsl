<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="isc hl7 xsi exsl">

	<xsl:template match="*" mode="Plan">
		<OtherOrder>
			<!-- Add SDA EncounterNumber only when explicitly stated on the Plan of Care entry. -->
			<xsl:if test=".//hl7:encounter">
				<EncounterNumber><xsl:apply-templates select="." mode="EncounterID-Entry"/></EncounterNumber>
			</xsl:if>

			<!-- EnteredBy -->
			<xsl:apply-templates select="." mode="EnteredBy"/>
			
			<!-- EnteredAt -->
			<xsl:apply-templates select="." mode="EnteredAt"/>
			
			<!-- EnteredOn -->
			<xsl:apply-templates select="hl7:effectiveTime" mode="EnteredOn"/>
			
			<!-- Override ExternalId with the <id> values from the source CDA -->
			<xsl:apply-templates select="." mode="ExternalId"/>
			
			<!-- Entering Organization -->
			<xsl:apply-templates select="." mode="EnteringOrganization"/>
			
			<!-- Start and End Time -->
			<xsl:apply-templates select="hl7:effectiveTime/hl7:low" mode="StartTime"/>
			<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="EndTime"/>
		
			<!-- Placer and Filler IDs -->
			<xsl:apply-templates select="." mode="PlacerId"/>
			<xsl:apply-templates select="." mode="FillerId"/>
			
			<!-- Order Item -->
			<xsl:apply-templates select="hl7:code" mode="CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
			</xsl:apply-templates>

			<!-- Order Status -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:observation/hl7:value" mode="PlanStatus"/>
 						
			<!-- Comments -->
			<xsl:apply-templates select="." mode="Comment"/>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="ImportCustom-PlanOfCare"/>
		</OtherOrder>
	</xsl:template>
	
	<xsl:template match="*" mode="PlanStatus">
		<xsl:if test="@code">
			<Status>
				<xsl:choose>
					<xsl:when test="@code = '55561003'"><xsl:text>A</xsl:text></xsl:when>
					<xsl:when test="@code = '421139008'"><xsl:text>H</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text>I</xsl:text></xsl:otherwise>
				</xsl:choose>
			</Status>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="PlanOfCare-Procedures">
		<Procedures>
			<!-- The Procedure template is in Import/Entry-Modules/Procedure.xsl -->
			<xsl:apply-templates select="hl7:procedure" mode="Procedure">
				<xsl:with-param name="PlanOfCare" select="'1'"/>
			</xsl:apply-templates>
		</Procedures>
	</xsl:template>
	
	<!-- This empty template may be overridden with custom logic.
	-->
	<xsl:template match="*" mode="ImportCustom-PlanOfCare">
	</xsl:template>
</xsl:stylesheet>
