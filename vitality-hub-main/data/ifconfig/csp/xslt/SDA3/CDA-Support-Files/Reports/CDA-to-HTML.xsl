<?xml version="1.0"?>
<!-- 
  Revision History:  2012-01-21: Added support for BPPC documents, XDS-SD/BPPC-SD attachment inline
  Revision History:  04/11/14 Paul Lomayesva (InterSystems Corporation) Incorporated Rick Geimer's (Lantana Group) fixes for security vunerabilities and other misc minor changes from Rick.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n1="urn:hl7-org:v3" xmlns:n2="urn:hl7-org:v3/meta/voc" xmlns:n3="http://www.w3.org/1999/xhtml" xmlns:voc="urn:hl7-org:v3/voc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:isc="http://extension-functions.intersystems.com">
	<xsl:output method="html" indent="yes" version="4.01" encoding="ISO-8859-1" doctype-public="-//W3C//DTD HTML 4.01//EN"/><!-- CDA document -->
	<xsl:param name="nonXMLBodyCacheID"/>
    <xsl:param name="limit-external-images" select="'1'"/>

	<xsl:variable name="tableWidth">50%</xsl:variable>
	<xsl:variable name="title">
		<xsl:choose>
			<xsl:when test="/n1:ClinicalDocument/n1:title">
				<xsl:value-of select="/n1:ClinicalDocument/n1:title"/>
			</xsl:when>
			<xsl:otherwise>Clinical Document</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="/">
		<xsl:apply-templates select="n1:ClinicalDocument"/>
	</xsl:template>
	
	<xsl:template match="n1:ClinicalDocument">
		<html>
			<head>
				<!-- <meta name='Generator' content='&CDA-Stylesheet;'/> -->
				<xsl:comment>
					Do NOT edit this HTML directly, it was generated via an XSLT
					transformation from the original release 2 CDA Document.
				</xsl:comment>
				<title>
					<xsl:value-of select="$title"/>
				</title>
			</head>
			<xsl:comment>
				Derived from HL7 Finland R2 Tyylitiedosto: Tyyli_R2_B3_01.xslt
				Updated by:  Calvin E. Beebe, Mayo Clinic - Rochester, MN
				Updated for use at IHE NA 2010 by:  Mike LaRocca, InterSystems Corporation - Cambridge, MA
            </xsl:comment>
			<body>
				<h2 align="center">
					<xsl:value-of select="$title"/>
				</h2>
				<table width="100%">
					<tr>
						<td width="10%">
							<big>
								<b>
									<xsl:text>Patient: </xsl:text>
								</b>
							</big>
						</td>
						<td width="40%">
							<big>
								<xsl:call-template name="getName">
									<xsl:with-param name="name" select="/n1:ClinicalDocument/n1:recordTarget/n1:patientRole/n1:patient/n1:name"/>
								</xsl:call-template>
							</big>
						</td>
						<td width="25%" align="right">
							<b>
								<xsl:text>MRN: </xsl:text>
							</b>
						</td>
						<td width="25%">
							<xsl:value-of select="/n1:ClinicalDocument/n1:recordTarget/n1:patientRole/n1:id/@extension"/>
						</td>
					</tr>
					<tr>
						<td width="10%">
							<b>
								<xsl:text>Birthdate: </xsl:text>
							</b>
						</td>
						<td width="40%">
							<xsl:call-template name="formatDate">
								<xsl:with-param name="date" select="/n1:ClinicalDocument/n1:recordTarget/n1:patientRole/n1:patient/n1:birthTime/@value"/>
							</xsl:call-template>
						</td>
						<td width="25%" align="right">
							<b>
								<xsl:text>Sex: </xsl:text>
							</b>
						</td>
						<td width="25%">
							<xsl:variable name="sex" select="/n1:ClinicalDocument/n1:recordTarget/n1:patientRole/n1:patient/n1:administrativeGenderCode/@code"/>
							<xsl:choose>
								<xsl:when test="$sex='M'">Male</xsl:when>
								<xsl:when test="$sex='F'">Female</xsl:when>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<td width="10%">
							<b>
								<xsl:text>Consultant: </xsl:text>
							</b>
						</td>
						<td width="40%">
							<xsl:choose>
								<xsl:when test="/n1:ClinicalDocument/n1:responsibleParty/n1:assignedEntity/n1:assignedPerson/n1:name">
									<xsl:call-template name="getName">
										<xsl:with-param name="name" select="/n1:ClinicalDocument/n1:responsibleParty/n1:assignedEntity/n1:assignedPerson/n1:name"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="getName">
										<xsl:with-param name="name" select="/n1:ClinicalDocument/n1:legalAuthenticator/n1:assignedEntity/n1:assignedPerson/n1:name"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td width="25%" align="right">
							<b>
								<xsl:text>Created On: </xsl:text>
							</b>
						</td>
						<td width="25%">
							<xsl:call-template name="formatDate">
								<xsl:with-param name="date" select="/n1:ClinicalDocument/n1:effectiveTime/@value"/>
							</xsl:call-template>
						</td>
					</tr>
				</table>
				<br/>
				<xsl:apply-templates select="n1:component/n1:structuredBody"/>
				<xsl:call-template name="bottomline"/>
        <xsl:apply-templates select="n1:component/n1:nonXMLBody"/>
			</body>
		</html>
	</xsl:template>
	
	<!-- Get a Name -->
	<xsl:template name="getName">
		<xsl:param name="name"/>
		<xsl:choose>
			<xsl:when test="$name/n1:family">
				<xsl:value-of select="$name/n1:given"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$name/n1:family"/>
				<xsl:text/>
				<xsl:if test="$name/n1:suffix">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="$name/n1:suffix"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Format Date 
    
      outputs a date in Month Day, Year form
      e.g., 19991207  ==> December 07, 1999
	-->
	<xsl:template name="formatDate">
		<xsl:param name="date"/>
		<xsl:variable name="month" select="substring ($date, 5, 2)"/>
		<xsl:choose>
			<xsl:when test="$month='01'">
				<xsl:text>January </xsl:text>
			</xsl:when>
			<xsl:when test="$month='02'">
				<xsl:text>February </xsl:text>
			</xsl:when>
			<xsl:when test="$month='03'">
				<xsl:text>March </xsl:text>
			</xsl:when>
			<xsl:when test="$month='04'">
				<xsl:text>April </xsl:text>
			</xsl:when>
			<xsl:when test="$month='05'">
				<xsl:text>May </xsl:text>
			</xsl:when>
			<xsl:when test="$month='06'">
				<xsl:text>June </xsl:text>
			</xsl:when>
			<xsl:when test="$month='07'">
				<xsl:text>July </xsl:text>
			</xsl:when>
			<xsl:when test="$month='08'">
				<xsl:text>August </xsl:text>
			</xsl:when>
			<xsl:when test="$month='09'">
				<xsl:text>September </xsl:text>
			</xsl:when>
			<xsl:when test="$month='10'">
				<xsl:text>October </xsl:text>
			</xsl:when>
			<xsl:when test="$month='11'">
				<xsl:text>November </xsl:text>
			</xsl:when>
			<xsl:when test="$month='12'">
				<xsl:text>December </xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="substring ($date, 7, 1)=&quot;0&quot;">
				<xsl:value-of select="substring ($date, 8, 1)"/>
				<xsl:text>, </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring ($date, 7, 2)"/>
				<xsl:text>, </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="substring ($date, 1, 4)"/>
	</xsl:template>
	
	<!-- StructuredBody -->
	<xsl:template match="n1:component/n1:structuredBody">
		<xsl:apply-templates select="n1:component/n1:section"/>
	</xsl:template>
	
	<!-- Component/Section -->
	<xsl:template match="n1:component/n1:section">
		<xsl:apply-templates select="n1:title"/>
		<xsl:apply-templates select="n1:text"/>
		<xsl:apply-templates select="n1:component/n1:section"/>
	</xsl:template>
	
	<!-- Title -->
	<xsl:template match="n1:title">
		<h3>
			<span style="font-weight:bold;">
				<xsl:value-of select="."/>
			</span>
		</h3>
	</xsl:template>
	
	<!-- Text -->
	<xsl:template match="n1:text">
		<xsl:apply-templates/>
		<xsl:if test="not(string-length(n1:table))"><br/><br/></xsl:if>
	</xsl:template>
	
	<!-- Paragraph -->
	<xsl:template match="n1:paragraph">
		<xsl:apply-templates/>
		<br/>
	</xsl:template>
	
	<!-- Content w/ deleted text is hidden -->
	<xsl:template match="n1:content[@revised='delete']"/>
	
	<!-- Content for result narrative cells -->
	<xsl:template match="n1:content[contains(translate(@ID,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'result') and not(contains(translate(@ID,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'comment'))]">
		<xsl:choose>
			<xsl:when test="contains(text(),'&#10;')">
				<pre><xsl:apply-templates/></pre>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Content for result narrative cells -->
	<xsl:template match="n1:content[contains(translate(@ID,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'comment') or contains(translate(@ID,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'note')]">
		<td>
			<xsl:choose>
				<xsl:when test="contains(text(),'&#10;')">
					<xsl:apply-templates select="." mode="lineFeedToBR">
						<xsl:with-param name="currentText" select="text()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>
	
	<!-- Content -->
	<xsl:template match="n1:content">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- List -->
	<xsl:template match="n1:list">
		<xsl:if test="n1:caption">
			<span style="font-weight:bold; ">
				<xsl:apply-templates select="n1:caption"/>
			</span>
		</xsl:if>
		<ul>
			<xsl:for-each select="n1:item">
				<li>
					<xsl:apply-templates/>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
	<xsl:template match="n1:list[@listType='ordered']">
		<xsl:if test="n1:caption">
			<span style="font-weight:bold; ">
				<xsl:apply-templates select="n1:caption"/>
			</span>
		</xsl:if>
		<ol>
			<xsl:for-each select="n1:item">
				<li>
					<xsl:apply-templates/>
				</li>
			</xsl:for-each>
		</ol>
	</xsl:template>
	
	<!--  Caption -->
	<xsl:template match="n1:caption">
		<xsl:apply-templates/>
		<xsl:text>: </xsl:text>
	</xsl:template>
	
	<!-- Tables -->
	<xsl:template match="n1:table/@*|n1:thead/@*|n1:tfoot/@*|n1:tbody/@*|n1:colgroup/@*|n1:col/@*|n1:tr/@*|n1:th/@*|n1:td/@*">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="n1:table">
		<table>
			<xsl:apply-templates/>
		</table>
	</xsl:template>
	
	<xsl:template match="n1:thead">
		<thead>
			<xsl:apply-templates/>
		</thead>
	</xsl:template>
	
	<xsl:template match="n1:tfoot">
		<tfoot>
			<xsl:apply-templates/>
		</tfoot>
	</xsl:template>
	
	<xsl:template match="n1:tbody">
		<tbody>
			<xsl:apply-templates/>
		</tbody>
	</xsl:template>
	
	<xsl:template match="n1:colgroup">
		<colgroup>
			<xsl:apply-templates/>
		</colgroup>
	</xsl:template>
	
	<xsl:template match="n1:col">
		<col>
			<xsl:apply-templates/>
		</col>
	</xsl:template>
	
	<xsl:template match="n1:tr">
		<tr>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>
	
	<xsl:template match="n1:th">
		<th>
			<xsl:apply-templates/>
		</th>
	</xsl:template>
	
	<!-- td for result narrative cells -->
	<xsl:template match="n1:td[contains(translate(@ID,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'result') and not(contains(translate(@ID,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'comment'))]">
		<td>
		<xsl:choose>
			<xsl:when test="contains(text(),'&#10;')">
				<pre><xsl:apply-templates/></pre>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
		</td>
	</xsl:template>
	
	<!-- td for result narrative cells -->
	<xsl:template match="n1:td[contains(translate(@ID,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'comment') or contains(translate(@ID,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'note')]">
		<td>
			<xsl:choose>
				<xsl:when test="contains(text(),'&#10;')">
					<xsl:apply-templates select="." mode="lineFeedToBR">
						<xsl:with-param name="currentText" select="text()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>
	
	<!-- Convert line feeds to <br>'s -->
	<xsl:template match="*" mode="lineFeedToBR">
		<xsl:param name="currentText"/>
		<xsl:choose>
			<xsl:when test="contains($currentText,'&#10;')">
				<xsl:value-of select="substring-before($currentText,'&#10;')"/><br/>
				<xsl:apply-templates select="." mode="lineFeedToBR">
					<xsl:with-param name="currentText" select="substring-after($currentText,'&#10;')"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$currentText"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="n1:td">
		<td>
			<xsl:apply-templates/>
		</td>
	</xsl:template>
	
	<xsl:template match="n1:table/n1:caption">
		<span style="font-weight:bold; ">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
   <xsl:template match="n1:renderMultiMedia">
      <xsl:variable name="imageRef" select="@referencedObject"/>
      <xsl:choose>
		  <xsl:when test="//n1:regionOfInterest[@ID=$imageRef]">
			   <xsl:apply-templates select="//n1:regionOfInterest[@ID=$imageRef]//n1:observationMedia" mode="create-image"/>
		  </xsl:when>
		  <xsl:otherwise>
			   <xsl:apply-templates select="//n1:observationMedia[@ID=$imageRef]" mode="create-image"/>
		  </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="n1:observationMedia" mode="create-image">
      <xsl:variable name="image-uri" select="n1:value/n1:reference/@value"/>
      <xsl:choose>
          <xsl:when test="$limit-external-images='1' and contains($image-uri,':')">
                <p>WARNING: non-local image found <xsl:value-of select="$image-uri"/></p>
                <xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/></xsl:message>
          </xsl:when>
          <xsl:when test="$limit-external-images='1' and starts-with($image-uri,'\\')">
                <p>WARNING: non-local image found <xsl:value-of select="$image-uri"/></p>
                <xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/></xsl:message>
          </xsl:when>
          <xsl:when test="string-length($image-uri)">
                <br clear="all"/>
                <xsl:element name="img">
                    <xsl:attribute name="src"><xsl:value-of select="$image-uri"/></xsl:attribute>
                </xsl:element>
          </xsl:when>
          <xsl:otherwise>
                <br clear="all"/>
                <xsl:element name="img">
                    <xsl:attribute name="src"><xsl:text>data:</xsl:text><xsl:value-of select="n1:value/@mediaType"/><xsl:text>;base64,</xsl:text><xsl:value-of select="n1:value"/></xsl:attribute>
                </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
	
	<!-- 	Stylecode processing:  Supports Bold, Underline and Italics display -->
	<xsl:template match="//n1:*[@styleCode]">
		<xsl:if test="@styleCode='Bold'">
			<xsl:element name="{local-name()}">
			<xsl:element name="b">
				<xsl:apply-templates/>
			</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="@styleCode='Italics'">
			<xsl:element name="{local-name()}">
			<xsl:element name="i">
				<xsl:apply-templates/>
			</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="@styleCode='Underline'">
			<xsl:element name="{local-name()}">
			<xsl:element name="u">
				<xsl:apply-templates/>
			</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="contains(@styleCode,'Bold') and contains(@styleCode,'Italics') and not (contains(@styleCode, 'Underline'))">
			<xsl:element name="{local-name()}">
			<xsl:element name="b">
				<xsl:element name="i">
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="contains(@styleCode,'Bold') and contains(@styleCode,'Underline') and not (contains(@styleCode, 'Italics'))">
			<xsl:element name="{local-name()}">
			<xsl:element name="b">
				<xsl:element name="u">
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="contains(@styleCode,'Italics') and contains(@styleCode,'Underline') and not (contains(@styleCode, 'Bold'))">
			<xsl:element name="{local-name()}">
			<xsl:element name="i">
				<xsl:element name="u">
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="contains(@styleCode,'Italics') and contains(@styleCode,'Underline') and contains(@styleCode, 'Bold')">
			<xsl:element name="{local-name()}">
			<xsl:element name="b">
				<xsl:element name="i">
					<xsl:element name="u">
						<xsl:apply-templates/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="not (contains(@styleCode,'Italics') or contains(@styleCode,'Underline') or contains(@styleCode, 'Bold'))">
			<xsl:element name="{local-name()}">
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<!-- 	Superscript or Subscript   -->
	<xsl:template match="n1:sup">
		<xsl:element name="sup">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="n1:sub">
		<xsl:element name="sub">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="n1:pre">
		<xsl:element name="pre">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="n1:br">
		<xsl:element name="br">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!--  Bottomline  -->
	<xsl:template name="bottomline">
		<b><xsl:text>Signed by: </xsl:text></b>
		<xsl:call-template name="getName">
			<xsl:with-param name="name" select="/n1:ClinicalDocument/n1:legalAuthenticator/n1:assignedEntity/n1:assignedPerson/n1:name"/>
		</xsl:call-template>
		<xsl:text> on </xsl:text>
		<xsl:call-template name="formatDate">
			<xsl:with-param name="date" select="//n1:ClinicalDocument/n1:legalAuthenticator/n1:time/@value"/>
		</xsl:call-template>
	</xsl:template>
<!-- render document attachement inline if possible-->
<xsl:template match="n1:nonXMLBody">
<xsl:choose>

<!-- text attachment, either raw text or b64 encoded, use a simple pre tag -->
<xsl:when test="n1:text/@mediaType='text/plain'">
<xsl:element name="pre">
<xsl:attribute name="width">100%</xsl:attribute>
<xsl:choose>
<xsl:when test="n1:text/@representation='TXT'">
<xsl:copy-of select="n1:text/text()"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="isc:evaluate('decode',n1:text/text())"/>
</xsl:otherwise>
</xsl:choose>
</xsl:element>
</xsl:when>

<!-- binary attachement -->
<xsl:when test="string-length($nonXMLBodyCacheID)>0">
<xsl:choose>

<!-- pdf attachment, use HTML embed tag to use plugin to render -->
<xsl:when test="n1:text/@mediaType='application/pdf'">
<xsl:element name="embed">
<xsl:attribute name="src">
<xsl:value-of select="concat('HS.IHE.XDSb.Consumer.ViewerFetchProcess.CacheGet.cls?ID=',$nonXMLBodyCacheID)"/>
</xsl:attribute>
<xsl:attribute name="type">application/pdf</xsl:attribute>
<xsl:attribute name="width">100%</xsl:attribute>
<xsl:attribute name="height">500px</xsl:attribute>
</xsl:element>
</xsl:when>

<!-- image attachment, use HTML img tag -->
<xsl:when test="substring-before(n1:text/@mediaType,'/')='image'">
<xsl:element name="div">
<xsl:element name="img">
<xsl:attribute name="src">
<xsl:value-of select="concat('HS.IHE.XDSb.Consumer.ViewerFetchProcess.CacheGet.cls?ID=',$nonXMLBodyCacheID)"/>
</xsl:attribute>
</xsl:element>
</xsl:element>
</xsl:when>

</xsl:choose>

</xsl:when>
</xsl:choose>
</xsl:template>
</xsl:stylesheet>
