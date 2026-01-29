<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="recommendations-Narrative">
		<text mediaType="text/x-hl7-text+xml">
			<table border="1" width="100%">
				<caption>Record of Recommendations and Information Provided</caption>
				<thead>
					<tr>
						<th>Recipient Person Name</th>
						<th>Recipient Organisation</th>
						<th>Address / Contact</th>
						<th>Note</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="Encounters/Encounter/RecommendationsProvided/Recommendation" mode="recommendations-NarrativeDetail"/>
				</tbody>
			</table>
		</text>
	</xsl:template>

	<xsl:template match="*" mode="recommendations-NarrativeDetail">
		<!--
			RecommendationsProvided is a property of Encounter. However,
			it is used for Discharge Summary and for Specialist Letter,
			which are only used for reporting on a single encounter.
			Therefore using only position() as the link suffix is okay.
		-->
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<xsl:apply-templates select="RecipientPersons/CareProvider" mode="recommendations-NarrativeDetail-Person">
			<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="RecipientOrganizations/HealthCareFacility" mode="recommendations-NarrativeDetail-Organization">
			<xsl:with-param name="narrativeLinkSuffix" select="$narrativeLinkSuffix"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*" mode="recommendations-NarrativeDetail-Person">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:variable name="personNarrativeLinkSuffix" select="concat($narrativeLinkSuffix,'-person.',position())"/>
 		<xsl:variable name="cityText"><xsl:apply-templates select="Address/City" mode="descriptionOrCode"/></xsl:variable>
		<xsl:variable name="stateText"><xsl:apply-templates select="Address/State" mode="descriptionOrCode"/></xsl:variable>
		<xsl:variable name="zipText"><xsl:apply-templates select="Address/Zip" mode="descriptionOrCode"/></xsl:variable>
		<xsl:variable name="addressText">
			<xsl:value-of select="normalize-space(concat(Address/Street/text(),', ',$cityText,', ',$stateText,', ',zipText))"/>
		</xsl:variable>
		<xsl:variable name="addressText2">
			<xsl:value-of select="translate($addressText,', ','')"/>
		</xsl:variable>
		<tr ID="{concat($exportConfiguration/recommendations/narrativeLinkPrefixes/recommendationNarrative/text(), $personNarrativeLinkSuffix)}">
			<td><xsl:value-of select="normalize-space(concat(Name/Prefix/text(),' ',Name/GivenName/text(),' ',Name/FamilyName/text(),' ',Name/NameSuffix/text(),' ',Name/ProfessionalSuffix,text()))"/></td>
			<td/>
			<td>
				<xsl:if test="string-length($addressText2)"><content><xsl:value-of select="$addressText"/></content></xsl:if>
				<xsl:if test="string-length(ContactInfo/HomePhoneNumber/text())">
					<xsl:if test="string-length($addressText2)"><br/></xsl:if>
					<content><xsl:value-of select="concat('Home Phone: ',ContactInfo/HomePhoneNumber/text())"/></content>
				</xsl:if> 
				<xsl:if test="string-length(ContactInfo/WorkPhoneNumber/text())">
					<xsl:if test="string-length($addressText2) or string-length(ContactInfo/HomePhoneNumber/text())"><br/></xsl:if>
					<content><xsl:value-of select="concat('Work Phone: ',ContactInfo/WorkPhoneNumber/text())"/></content>
				</xsl:if> 
				<xsl:if test="string-length(ContactInfo/MobilePhoneNumber/text())">
					<xsl:if test="string-length($addressText2) or string-length(ContactInfo/HomePhoneNumber/text()) or string-length(ContactInfo/WorkPhoneNumber/text())"><br/></xsl:if>
					<content><xsl:value-of select="concat('Mobile Phone: ',ContactInfo/MobilePhoneNumber/text())"/></content>
				</xsl:if> 
				<xsl:if test="string-length(ContactInfo/EmailAddress/text())">
					<xsl:if test="string-length($addressText2) or string-length(ContactInfo/HomePhoneNumber/text()) or string-length(ContactInfo/WorkPhoneNumber/text()) or string-length(ContactInfo/MobilePhoneNumber/text())"><br/></xsl:if>
					<content><xsl:value-of select="concat('Email: ',ContactInfo/EmailAddress/text())"/></content>
				</xsl:if> 
			</td>
			<td ID="{concat($exportConfiguration/recommendations/narrativeLinkPrefixes/recommendationNoteText/text(), $personNarrativeLinkSuffix)}"><xsl:value-of select="../../NoteText/text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="recommendations-NarrativeDetail-Organization">
 		<xsl:param name="narrativeLinkSuffix"/>
		
		<xsl:variable name="organizationNarrativeLinkSuffix" select="concat($narrativeLinkSuffix,'-organization.',position())"/>
		<xsl:variable name="cityText"><xsl:apply-templates select="Organization/Address/City" mode="descriptionOrCode"/></xsl:variable>
		<xsl:variable name="stateText"><xsl:apply-templates select="Organization/Address/State" mode="descriptionOrCode"/></xsl:variable>
		<xsl:variable name="zipText"><xsl:apply-templates select="Organization/Address/Zip" mode="descriptionOrCode"/></xsl:variable>
		<xsl:variable name="addressText">
			<xsl:value-of select="normalize-space(concat(Organization/Address/Street/text(),', ',$cityText,', ',$stateText,', ',zipText))"/>
		</xsl:variable>
		<xsl:variable name="addressText2">
			<xsl:value-of select="translate($addressText,', ','')"/>
		</xsl:variable>
		<tr ID="{concat($exportConfiguration/recommendations/narrativeLinkPrefixes/recommendationNarrative/text(), $organizationNarrativeLinkSuffix)}">
			<td/>
			<td><xsl:apply-templates select="Organization" mode="descriptionOrCode"/></td>
			<td>
				<xsl:if test="string-length($addressText2)"><content><xsl:value-of select="$addressText"/></content></xsl:if>
				<xsl:if test="string-length(Organization/ContactInfo/WorkPhoneNumber/text())">
					<xsl:if test="string-length($addressText2)"><br/></xsl:if>
					<content><xsl:value-of select="concat('Work Phone: ',Organization/ContactInfo/WorkPhoneNumber/text())"/></content>
				</xsl:if> 
				<xsl:if test="string-length(Organization/ContactInfo/EmailAddress/text())">
					<xsl:if test="string-length($addressText2) or string-length(ContactInfo/WorkPhoneNumber/text())"><br/></xsl:if>
					<content><xsl:value-of select="concat('Email: ',Organization/ContactInfo/EmailAddress/text())"/></content>
				</xsl:if> 
			</td>
			<td ID="{concat($exportConfiguration/recommendations/narrativeLinkPrefixes/recommendationNoteText/text(), $organizationNarrativeLinkSuffix)}"><xsl:value-of select="../../NoteText/text()"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="*" mode="recommendations-Entries">
		<xsl:apply-templates select="Encounters/Encounter/RecommendationsProvided/Recommendation" mode="recommendations-EntryDetail"/>
	</xsl:template>

	<xsl:template match="*" mode="recommendations-EntryDetail">		
		<xsl:apply-templates select="RecipientPersons/CareProvider" mode="recommendations-EntryDetail-Person"/>
		<xsl:apply-templates select="RecipientOrganizations/HealthCareFacility" mode="recommendations-EntryDetail-Organization"/>
	</xsl:template>

	<xsl:template match="*" mode="recommendations-EntryDetail-Person">
		<entry typeCode="DRIV">
			<act classCode="INFRM" moodCode="PRP">
				<id root="{isc:evaluate('createUUID')}"/>
				
				<code code="102.20016.4.1.1" codeSystem="1.2.36.1.2001.1001.101" codeSystemName="NCTIS Data Components" displayName="Recommendations Provided"/>
				
				<text xsi:type="ST"><xsl:value-of select="../../NoteText/text()"/></text>
				
				<performer typeCode="PRF">
					<assignedEntity>
						<id root="{isc:evaluate('createUUID')}"/>
						<xsl:apply-templates select="CareProviderType" mode="generic-Coded"/>
						<xsl:apply-templates select="." mode="address"/>
						<xsl:apply-templates select="." mode="telecom"/>
						<xsl:apply-templates select="." mode="assignedPerson"/>
					</assignedEntity>
				</performer>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="recommendations-EntryDetail-Organization">
		<entry typeCode="DRIV">
			<act classCode="INFRM" moodCode="PRP">
				<id root="{isc:evaluate('createUUID')}"/>
				
				<code code="102.20016.4.1.1" codeSystem="1.2.36.1.2001.1001.101" codeSystemName="NCTIS Data Components" displayName="Recommendations Provided"/>
				
				<text xsi:type="ST"><xsl:value-of select="../../NoteText/text()"/></text>
				
				<performer typeCode="PRF">
					<assignedEntity>
						<id root="{isc:evaluate('createUUID')}"/>
						<code code="{LocationType/text()}" codeSystem="{$noCodeSystemOID}" codeSystemName="{$noCodeSystemName}" displayName="{LocationType/text()}"/>
						<xsl:apply-templates select="Organization" mode="address"/>
						<xsl:apply-templates select="Organization" mode="telecom"/>
						<xsl:apply-templates select="." mode="representedOrganization-Recipient"/>
					</assignedEntity>
				</performer>
			</act>
		</entry>
	</xsl:template>

	<xsl:template match="*" mode="recommendations-NoData">
		<text mediaType="text/x-hl7-text+xml"><xsl:value-of select="$exportConfiguration/recommendations/emptySection/narrativeText/text()"/></text>
	</xsl:template>
</xsl:stylesheet>
