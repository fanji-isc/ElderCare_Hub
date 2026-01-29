<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="*" mode="sSH-socialHistory">
		<xsl:param name="sectionRequired" select="'0'"/>
		
		<xsl:variable name="pregnancyObservations" select="Observations/Observation[ObservationCode/Code/text()='82810-3']"/>
		<xsl:variable name="hasData" select="boolean(SocialHistories) or boolean(SocialDeterminants) or boolean(Patient/BirthGender) or boolean(Patient/GenderIdentity) or boolean($pregnancyObservations)"/>
		<xsl:variable name="exportSectionWhenNoData" select="$exportConfiguration/socialHistory/emptySection/exportData/text()"/>
		<xsl:variable name="exportSmokingStatusWhenNoSmokingStatus" select="$exportConfiguration/socialHistory/emptySmokingStatus/exportData/text()"/>

		<xsl:variable name="snomedSmokingCodes">|449868002|428041000124106|8517006|266919005|77176002|266927001|428071000124103|428061000124105|</xsl:variable>
		
		<xsl:variable name="sdaNonSmokingCodes">
			<xsl:apply-templates select="SocialHistories/SocialHistory" mode="sSH-appendToHabitList">
				<xsl:with-param name="smokingCodes" select="$snomedSmokingCodes"/>
				<xsl:with-param name="smoking" select="'0'"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:variable name="subjectSmokingCodes">
			<xsl:apply-templates select="SocialHistories/SocialHistory" mode="sSH-appendToHabitList">
				<xsl:with-param name="smokingCodes" select="$snomedSmokingCodes"/>
				<xsl:with-param name="smoking" select="'1'"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="hasSmokingCodes" select="string-length($subjectSmokingCodes) &gt; 0"/>
		
		<xsl:if test="($hasData) or ($exportSectionWhenNoData='1') or ($sectionRequired='1') or ($exportSmokingStatusWhenNoSmokingStatus='1')">
			<component>
				<section>
					<xsl:if test="not($hasData) and not($exportSmokingStatusWhenNoSmokingStatus='1')"><xsl:attribute name="nullFlavor">NI</xsl:attribute></xsl:if>
					
					<xsl:call-template name="sSH-templateIds-socialHistorySection"/>
					
					<code code="29762-2" codeSystem="{$loincOID}" codeSystemName="{$loincName}"/>
					<title>Social History</title>
					
					<xsl:choose>
						<xsl:when test="$hasData">
							<!-- The narrative has 4 optional parts, but the 2nd and 3rd will not both be taken. -->
							<text>
								<xsl:if test="string-length($sdaNonSmokingCodes)">
									<xsl:apply-templates select="SocialHistories" mode="eSH-socialHistory-Narrative">
										<xsl:with-param name="sdaSmokingCodes" select="concat('|',$subjectSmokingCodes)"/>
									</xsl:apply-templates>
								</xsl:if>
								<xsl:if test="$hasSmokingCodes">
									<xsl:apply-templates select="SocialHistories" mode="eSH-socialHistory-Narrative-Smoking">
										<xsl:with-param name="sdaSmokingCodes" select="concat('|',$subjectSmokingCodes)"/>
									</xsl:apply-templates>
								</xsl:if>
								<xsl:if test="not($hasSmokingCodes) and $exportSmokingStatusWhenNoSmokingStatus='1'">
									<xsl:apply-templates select="SocialHistories" mode="eSH-socialHistory-NoData-Smoking-Narrative">
										<xsl:with-param name="narrativeLinkSuffix" select="count(SocialHistories/SocialHistory)+1"/>
									</xsl:apply-templates>
								</xsl:if>
								<xsl:apply-templates select="Patient/BirthGender" mode="eSH-BirthSex-Narrative">
									<xsl:with-param name="narrativeLinkSuffix" select="'BirthSex'"/>
									<xsl:with-param name="birthTime" select="Patient/BirthTime"/>
								</xsl:apply-templates>
								<xsl:apply-templates select="Patient/GenderIdentity" mode="eSH-GenderIdentity-Narrative">
									<xsl:with-param name="narrativeLinkSuffix" select="'GenderIdentity'"/>
									<xsl:with-param name="genderIdentityDate" select="Patient/EnteredOn"/>
								</xsl:apply-templates>
								<xsl:apply-templates select="." mode="eSH-PregnancyStatus-Narrative">
									<xsl:with-param name="pregnancyObservations" select="$pregnancyObservations"/>
								</xsl:apply-templates>
								<xsl:for-each select="SocialDeterminants/SocialDeterminant">
									<xsl:variable name="determinantID" select="ExternalId/text()"/>
									<xsl:if test="count(//SocialHistory/DeterminantIDs/DeterminantIDsItem[text()=$determinantID])=0 and count(//SocialDeterminant/MemberIDs/MemberIDsItem[text()=$determinantID])=0">
										<xsl:apply-templates select="." mode="eSH-SocialDeterminant-Narrative">
											<xsl:with-param name="narrativeLinkSuffix" select="position()"/>
										</xsl:apply-templates>
									</xsl:if>
								</xsl:for-each>
							</text>
							<!-- Next, prepare the basic SocialHistory entries. -->
							<xsl:apply-templates select="SocialHistories" mode="eSH-socialHistory-Entries">
								<xsl:with-param name="sdaSmokingCodes" select="concat('|',$subjectSmokingCodes)"/>
							</xsl:apply-templates>

							<xsl:apply-templates select="SocialDeterminants" mode="eSH-socialDeterminantEntries"/>

							<!-- Might want to report smoking status, even if we don't have any data. -->
							<xsl:if test="not($hasSmokingCodes) and $exportSmokingStatusWhenNoSmokingStatus='1'">
								<xsl:apply-templates select="." mode="eSH-socialHistory-NoData-Smoking-EntryDetail">
									<xsl:with-param name="narrativeLinkSuffix" select="count(SocialHistories/SocialHistory)+1"/>
								</xsl:apply-templates>
							</xsl:if>
							<!-- Make an entry about BirthGender, if we have data. -->
							<xsl:apply-templates select="Patient/BirthGender" mode="eSH-BirthSex-EntryDetail">
								<xsl:with-param name="narrativeLinkSuffix" select="'BirthSex'"/>
								<xsl:with-param name="birthTime" select="Patient/BirthTime"/>
							</xsl:apply-templates>
							<!-- Make an entry about GenderIdentity, if we have data. -->
							<xsl:apply-templates select="Patient/GenderIdentity" mode="eSH-GenderIdentity-EntryDetail">
								<xsl:with-param name="narrativeLinkSuffix" select="'GenderIdentity'"/>
								<xsl:with-param name="genderIdentityDate" select="Patient/EnteredOn"/>
							</xsl:apply-templates>
							<!-- Make an entry about Pregnancy Status, if we have data. -->
							<xsl:apply-templates select="$pregnancyObservations" mode="eSH-PregnancyStatus-EntryDetail"/>
						</xsl:when>
						<xsl:otherwise><!-- We don't have data, but might still want to report smoking status -->
							<xsl:choose>
								<xsl:when test="$exportSmokingStatusWhenNoSmokingStatus='1'">
									<text>
										<xsl:apply-templates select="." mode="eSH-socialHistory-NoData-Smoking-Narrative">
											<xsl:with-param name="narrativeLinkSuffix" select="'1'"/>
										</xsl:apply-templates>
									</text>
									<xsl:apply-templates select="." mode="eSH-socialHistory-NoData-Smoking-EntryDetail">
										<xsl:with-param name="narrativeLinkSuffix" select="'1'"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="eSH-socialHistory-NoData"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</section>
			</component>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="sSH-appendToHabitList">
		<xsl:param name="smokingCodes"/>
		<xsl:param name="smoking"/>
		<!-- Add a member to a |-separated list of codes for social habits.
		     The $smoking param controls whether the list is of smoking (1) or non-smoking (0) habits
		     and the $smokingCodes param is used as one of the distinguishing criteria. -->
		
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
			<xsl:when test="SocialHabitCategory/Code/text() = $loincSmokingStatus or SocialHabitCategory/Code/text() = $loincTobaccoUse">
				<xsl:if test="$smoking='1'"><xsl:value-of select="concat(SocialHabit/Code/text(), '|')"/></xsl:if>
			</xsl:when>
			<xsl:when test="contains($smokingCodes, concat('|', SocialHabit/Code/text(), '|'))">
				<xsl:if test="$smoking='1'"><xsl:value-of select="concat(SocialHabit/Code/text(), '|')"/></xsl:if>
			</xsl:when>
			<xsl:when test="$dU='CURRENT EVERY DAY SMOKER' or $dU='CURRENT SOME DAY SMOKER' or $dU='FORMER SMOKER' or $dU='NEVER SMOKER' or $dU='SMOKER, CURRENT STATUS UNKNOWN' or $dU='UNKNOWN IF EVER SMOKED' or $dU='HEAVY TOBACCO SMOKER' or $dU='LIGHT TOBACCO SMOKER' or $dU='HEAVY SMOKER' or $dU='LIGHT SMOKER'">
				<xsl:if test="$smoking='1'"><xsl:value-of select="concat(SocialHabit/Code/text(), '|')"/></xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$smoking='0'"><xsl:value-of select="concat(SocialHabit/Code/text(), '|')"/></xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ***************************** NAMED TEMPLATES ************************************ -->
	
	<xsl:template name="sSH-templateIds-socialHistorySection">
		<templateId root="{$ccda-SocialHistorySection}"/>
		<templateId root="{$ccda-SocialHistorySection}" extension="2015-08-01"/>
	</xsl:template>
	
</xsl:stylesheet>
