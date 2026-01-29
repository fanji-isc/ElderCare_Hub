<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

	<xsl:template match="*" mode="socialHistory">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="hasData" select="boolean(SocialHistories) or boolean(Patient/GenderIdentity)"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/socialHistory/emptySection/exportData/text()"/>
		<xsl:variable name="exportSmokingStatusWhenNoSmokingStatus" select="$exportConfiguration/socialHistory/emptySmokingStatus/exportData/text()"/>
		
		<xsl:variable name="snomedSmokingCodes">|449868002|428041000124106|8517006|266919005|77176002|266927001|428071000124103|428061000124105|</xsl:variable>
		
		<xsl:variable name="sdaNonSmokingCodes">
			<xsl:apply-templates select="SocialHistories/SocialHistory" mode="socialHistory-sdaSmokingCode">
				<xsl:with-param name="smokingCodes" select="$snomedSmokingCodes"/>
				<xsl:with-param name="smoking" select="'0'"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:variable name="sdaSmokingCodes">
			<xsl:apply-templates select="SocialHistories/SocialHistory" mode="socialHistory-sdaSmokingCode">
				<xsl:with-param name="smokingCodes" select="$snomedSmokingCodes"/>
				<xsl:with-param name="smoking" select="'1'"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1') or ($exportSmokingStatusWhenNoSmokingStatus='1')">
			<component>
				<section>
					<xsl:if test="not($hasData) and not($exportSmokingStatusWhenNoSmokingStatus='1')"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:apply-templates select="." mode="templateIds-socialHistorySection"/>
					
					<code code="29762-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Social History</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<text>
								<xsl:if test="string-length($sdaNonSmokingCodes)">
									<xsl:apply-templates select="SocialHistories" mode="socialHistory-Narrative">
										<xsl:with-param name="sdaSmokingCodes" select="$sdaSmokingCodes"/>
									</xsl:apply-templates>
								</xsl:if>
								<xsl:if test="string-length($sdaSmokingCodes)">
									<xsl:apply-templates select="SocialHistories" mode="socialHistory-Narrative-Smoking">
										<xsl:with-param name="sdaSmokingCodes" select="$sdaSmokingCodes"/>
									</xsl:apply-templates>
								</xsl:if>
								<xsl:if test="(not(string-length($sdaSmokingCodes))) and $exportSmokingStatusWhenNoSmokingStatus='1'">
									<xsl:apply-templates select="SocialHistories" mode="socialHistory-NoData-Smoking-Narrative">
										<xsl:with-param name="narrativeLinkSuffix" select="count(SocialHistories/SocialHistory)+1"/>
									</xsl:apply-templates>
								</xsl:if>
								<xsl:apply-templates select="Patient/GenderIdentity" mode="socialHistory-Narrative-GenderIdentity">
									<xsl:with-param name="genderIdentityDate" select="Patient/EnteredOn"/>
								</xsl:apply-templates>
							</text>
							<xsl:apply-templates select="SocialHistories" mode="socialHistory-Entries">
								<xsl:with-param name="sdaSmokingCodes" select="$sdaSmokingCodes"/>
							</xsl:apply-templates>
							<xsl:if test="(not(string-length($sdaSmokingCodes))) and $exportSmokingStatusWhenNoSmokingStatus='1'">
								<xsl:apply-templates select="." mode="socialHistory-NoData-Smoking-EntryDetail">
									<xsl:with-param name="narrativeLinkSuffix" select="count(SocialHistories/SocialHistory)+1"/>
								</xsl:apply-templates>
							</xsl:if>
							<xsl:apply-templates select="Patient/GenderIdentity" mode="socialHistory-GenderIdentity-EntryDetail">
								<xsl:with-param name="genderIdentityDate" select="Patient/EnteredOn"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$exportSmokingStatusWhenNoSmokingStatus='1'">
									<text>
										<xsl:apply-templates select="." mode="socialHistory-NoData-Smoking-Narrative">
											<xsl:with-param name="narrativeLinkSuffix" select="'1'"/>
										</xsl:apply-templates>
									</text>
									<xsl:apply-templates select="." mode="socialHistory-NoData-Smoking-EntryDetail">
										<xsl:with-param name="narrativeLinkSuffix" select="'1'"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="socialHistory-NoData"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="socialHistory-sdaSmokingCode">
		<xsl:param name="smokingCodes"/>
		<xsl:param name="smoking"/>
		
		<xsl:variable name="dU">
			<xsl:choose>
				<xsl:when test="string-length(SocialHabit/Description/text())">
					<xsl:value-of select="translate(SocialHabit/Description/text(), $lowerCase, $upperCase)"/>
				</xsl:when>
				<xsl:when test="string-length(SocialHabit/Code/text())">
					<xsl:value-of select="translate(SocialHabit/Code/text(), $lowerCase, $upperCase)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($smokingCodes, concat('|', SocialHabit/Code/text(), '|')) or $dU='CURRENT EVERY DAY SMOKER' or $dU='CURRENT SOME DAY SMOKER' or $dU='FORMER SMOKER' or $dU='NEVER SMOKER' or $dU='SMOKER, CURRENT STATUS UNKNOWN' or $dU='UNKNOWN IF EVER SMOKED' or $dU='HEAVY TOBACCO SMOKER' or $dU='LIGHT TOBACCO SMOKER' or $dU='HEAVY SMOKER' or $dU='LIGHT SMOKER'">
				<xsl:if test="$smoking='1'"><xsl:value-of select="concat(SocialHabit/Code/text(), '|')"/></xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$smoking='0'"><xsl:value-of select="concat(SocialHabit/Code/text(), '|')"/></xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*" mode="templateIds-socialHistorySection">
		<templateId root="{$ccda-SocialHistorySection}"/>
	</xsl:template>
</xsl:stylesheet>
