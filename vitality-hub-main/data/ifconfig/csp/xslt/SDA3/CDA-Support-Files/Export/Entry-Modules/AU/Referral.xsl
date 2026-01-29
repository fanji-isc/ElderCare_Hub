<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:ext="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">
	
	<xsl:template match="*" mode="referral-Narrative">
		<xsl:variable name="referralDate">
			<xsl:choose>
				<xsl:when test="string-length(Referrals/Referral/FromTime/text())">
					<xsl:apply-templates select="Referrals/Referral/FromTime" mode="narrativeDateFromODBC"/>
				</xsl:when>
				<xsl:when test="string-length(Referrals/Referral/EnteredOn/text())">
					<xsl:apply-templates select="Referrals/Referral/EnteredOn" mode="narrativeDateFromODBC"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- If specified, durationUnit should use the Code, which should be "d" or "w" or "mo" or "y" -->
		<xsl:variable name="durationUnit">
			<xsl:choose>
				<xsl:when test="string-length(Referrals/Referral/ValidityDuration/Code/text())">
					<xsl:value-of select="translate(Referrals/Referral/ValidityDuration/Code/text(),$upperCase,$lowerCase)"/>
				</xsl:when>
				<xsl:otherwise>d</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="referralDuration">
			<xsl:choose>
				<xsl:when test="string-length(Referrals/Referral/ValidityDuration)">
					<xsl:value-of select="Referrals/Referral/ValidityDuration/Factor/text()"/>
				</xsl:when>
				<xsl:when test="string-length($referralDate) and string-length(Referrals/Referral/ToTime/text())">
					<xsl:value-of select="isc:evaluate('dateDiff', 'dd', $referralDate, translate(Referrals/Referral/ToTime/text(), 'TZ', ' '))"/>
				</xsl:when>
				<xsl:when test="string-length($referralDate) and not(string-length(Referrals/Referral/ToTime/text()))">Indefinite</xsl:when>
				<xsl:otherwise>Unknown</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="referralUnitDisplay">
			<xsl:choose>
				<xsl:when test="$referralDuration = '1'">
					<xsl:choose>
						<xsl:when test="starts-with($durationUnit,'d')">day</xsl:when>
						<xsl:when test="starts-with($durationUnit,'w')">week</xsl:when>
						<xsl:when test="starts-with($durationUnit,'m')">month</xsl:when>
						<xsl:when test="starts-with($durationUnit,'y')">year</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="number($referralDuration) > 1">
					<xsl:choose>
						<xsl:when test="starts-with($durationUnit,'d')">days</xsl:when>
						<xsl:when test="starts-with($durationUnit,'w')">weeks</xsl:when>
						<xsl:when test="starts-with($durationUnit,'m')">months</xsl:when>
						<xsl:when test="starts-with($durationUnit,'y')">years</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<text>
			<table border="1" width="100%">
				<caption>Date and Duration</caption> 
				<thead>
					<tr>
						<th>Date</th>
						<th>Duration</th>
					</tr>
				</thead>
				<tbody>
					<tr ID="{concat($exportConfiguration/referrals/narrativeLinkPrefixes/referralNarrative/text(), '1')}">
						<td>
							<xsl:choose>
								<xsl:when test="string-length($referralDate)">
									<xsl:value-of select="$referralDate"/>
								</xsl:when>
								<xsl:otherwise>Unknown</xsl:otherwise>
							</xsl:choose>
						</td>
						<td>
							<xsl:value-of select="concat($referralDuration,' ',$referralUnitDisplay)"/>
						</td>
					</tr>
				</tbody>
			</table>
			<table border="1" width="100%">
				<caption>Reason for Referral</caption> 
				<tbody>
					<tr>
						<td ID="{concat($exportConfiguration/referrals/narrativeLinkPrefixes/referralReason/text(), '1')}"><xsl:value-of select="Referrals/Referral/ReferralReason/text()"/></td>
					</tr>
				</tbody>
			</table>	
		</text>
	</xsl:template>
		
	<xsl:template match="*" mode="referral-Entries">		
		<xsl:apply-templates select="Referrals/Referral" mode="referral-EntryDetail"/>
	</xsl:template>
	
	<xsl:template match="*" mode="referral-EntryDetail">
		<xsl:variable name="narrativeLinkSuffix" select="position()"/>
		
		<xsl:apply-templates select="." mode="referral-Duration"/>
		<xsl:apply-templates select="." mode="referral-DateTime"/>
		<xsl:apply-templates select="." mode="referral-Reason"/>
	</xsl:template>
	
	<xsl:template match="*" mode="referral-NoData">
		<text mediaType="text/x-hl7-text+xml"><xsl:value-of select="$exportConfiguration/referrals/emptySection/narrativeText/text()"/></text>
	</xsl:template>
	
	<xsl:template match="*" mode="referral-Duration">
		<xsl:variable name="referralDate">
			<xsl:choose>
				<xsl:when test="string-length(FromTime/text())">
					<xsl:value-of select="FromTime/text()"/>
				</xsl:when>
				<xsl:when test="string-length(EnteredOn/text())">
					<xsl:value-of select="EnteredOn/text()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="referralDuration">
			<xsl:choose>
				<xsl:when test="string-length(ValidityDuration)">
					<xsl:value-of select="ValidityDuration/Factor/text()"/>
				</xsl:when>
				<xsl:when test="string-length($referralDate) and string-length(ToTime/text())">
					<xsl:value-of select="isc:evaluate('dateDiff', 'dd', translate($referralDate, 'TZ', ' '), translate(ToTime/text(), 'TZ', ' '))"/>
				</xsl:when>
				<xsl:when test="string-length($referralDate) and not(string-length(ToTime/text()))">Indefinite</xsl:when>
				<xsl:otherwise>Unknown</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="referral-id"/>
				<code code="103.16622" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Referral Validity Duration"/>
				<xsl:choose>
					<xsl:when test="not($referralDuration='Indefinite') and not($referralDuration='Unknown')">
						<value xsi:type="IVL_TS">
							<width value="{$referralDuration}" unit="{translate(ValidityDuration/Code/text(),$upperCase,$lowerCase)}"/>
						</value>
					</xsl:when>
					<xsl:otherwise>
						<value xsi:type="ST">
							<xsl:value-of select="$referralDuration"/>
						</value>
					</xsl:otherwise>
				</xsl:choose>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="referral-DateTime">		
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="referral-id"/>
				<code code="103.16620" codeSystem="{$nctisOID}" codeSystemName="{$nctisName}" displayName="Referral DateTime"/>
				<xsl:choose>
					<xsl:when test="string-length(FromTime/text())"><value xsi:type="TS"><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></value></xsl:when>
					<xsl:when test="string-length(EnteredOn/text())"><value xsi:type="TS"><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></value></xsl:when>
					<xsl:otherwise><value nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="referral-Reason">
		<xsl:param name="narrativeLinkSuffix"/>
		
		<entry>
			<observation classCode="OBS" moodCode="EVN">
				<xsl:apply-templates select="." mode="referral-id"/>
				<code code="42349-1" codeSystem="{$loincOID}" codeSystemName="{$loincName}" displayName="Reason for referral"/>
				<xsl:choose>
					<xsl:when test="string-length(FromTime/text())"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="FromTime" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
					<xsl:when test="string-length(EnteredOn/text())"><effectiveTime><xsl:attribute name="value"><xsl:apply-templates select="EnteredOn" mode="xmlToHL7TimeStamp"/></xsl:attribute></effectiveTime></xsl:when>
					<xsl:otherwise><effectiveTime nullFlavor="UNK"/></xsl:otherwise>
				</xsl:choose>
				<value xsi:type="ST"><xsl:value-of select="ReferralReason/text()"/></value>
			</observation>
		</entry>
	</xsl:template>
	
	<xsl:template match="*" mode="referral-id">
		<xsl:choose>
			<xsl:when test="string-length(EnteredAt/Code) and (string-length(PlacerId) or string-length(FillerId))">
				<xsl:if test="string-length(PlacerId)">
					<id>
				 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
				 		<xsl:attribute name="extension"><xsl:value-of select="PlacerId/text()"/></xsl:attribute>
				 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-PlacerId')"/></xsl:attribute>
					</id>
				</xsl:if>
				<xsl:if test="string-length(FillerId)">
					<id>
				 		<xsl:attribute name="root"><xsl:apply-templates select="." mode="oid-for-code"><xsl:with-param name="Code" select="EnteredAt/Code/text()"/></xsl:apply-templates></xsl:attribute>
				 		<xsl:attribute name="extension"><xsl:value-of select="FillerId/text()"/></xsl:attribute>
				 		<xsl:attribute name="assigningAuthorityName"><xsl:value-of select="concat(EnteredAt/Code/text(), '-FillerId')"/></xsl:attribute>
					</id>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<id root="{isc:evaluate('createUUID')}" assigningAuthorityName="{concat(EnteredAt/Code/text(), '-UnspecifiedPlacerId')}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
