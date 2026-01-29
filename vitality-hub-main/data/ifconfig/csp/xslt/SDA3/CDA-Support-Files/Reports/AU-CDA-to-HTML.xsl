<?xml version="1.0" encoding="UTF-8"?>
<!--*** THIS XSLT STYLESHEET IS DEPRECATED AS OF UNIFIED CARE RECORD 2024.1 ***-->
<!--
   Copyright 2011 NEHTA
   
   Licensed under the NEHTA Open Source (Apache) License; you may not use this
   file except in compliance with the License. A copy of the License is in the
   'license.txt' file, which should be provided with this work.
   
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
   License for the specific language governing permissions and limitations
   under the License.
   
   Date: 31 October 2011

   Revision History:  04/14/14 Paul Lomayesva (InterSystems Corporation) Incorporated Rick Geimer's (Lantana Group) recommended fixes for security vunerabilities.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:cda="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:nehtaCDA="http://ns.electronichealth.net.au/Ci/Cda/Extensions/3.0"
   xmlns:in="urn:lantana-com:inline-variable-data"
   exclude-result-prefixes="xsi cda nehtaCDA">
   <xsl:output method="html" indent="yes" version="4.01" encoding="ISO-8859-1"
      doctype-system="http://www.w3.org/TR/html4/strict.dtd"
      doctype-public="-//W3C//DTD HTML 4.01//EN"/>


   <xsl:param name="renderHeaderHPIIs"/>
   <xsl:param name="renderHeaderHPIOs"/>
   <xsl:param name="renderCDAHeader"/>
   <xsl:param name="limit-external-images" select="'1'"/>
   
   
   <!-- string processing variables -->
   
   <xsl:variable name="simple-sanitizer-match"><xsl:text>&#10;&#13;&#34;&#39;&#58;&#59;&#63;&#96;&#123;&#125;&#8220;&#8221;&#8222;&#8218;&#8217;</xsl:text></xsl:variable>
   <xsl:variable name="simple-sanitizer-replace" select="'***************'"/>
   <xsl:variable name="javascript-injection-warning">WARNING: Javascript injection attempt detected in source CDA document. Terminating</xsl:variable>
   <xsl:variable name="malicious-content-warning">WARNING: Potentially malicious content found in CDA document.</xsl:variable>
   
   <!-- global variable document types -->
                                                            
   <xsl:variable name="NEHTA_DISCHARGE_SUMMARY_TEMPLATE_ID">1.2.36.1.2001.1001.101.100.20000</xsl:variable>
   <xsl:variable name="NEHTA_E_PRESCRIPTION_TEMPLATE_ID">1.2.36.1.2001.1001.101.100.16100</xsl:variable>
   <xsl:variable name="NEHTA_DISPENSE_RECORD_TEMPLATE_ID">1.2.36.1.2001.1001.101.100.16112</xsl:variable>
   <xsl:variable name="NEHTA_PRESCRIPTION_REQUEST_TEMPLATE_ID">1.2.36.1.2001.1001.101.100.16285</xsl:variable>
   <xsl:variable name="NEHTA_SHARED_HEALTH_SUMMARY_TEMPLATE_ID">1.2.36.1.2001.1001.101.100.16565</xsl:variable>
   <xsl:variable name="NEHTA_E_REFERRAL_TEMPLATE_ID">1.2.36.1.2001.1001.101.100.21000</xsl:variable>
   <xsl:variable name="NEHTA_SPECIALIST_LETTER_TEMPLATE_ID">1.2.36.1.2001.1001.101.100.16615</xsl:variable>
    <xsl:variable name="NEHTA_EVENT_SUMMARY_TEMPLATE_ID">1.2.36.1.2001.1001.101.100.16473</xsl:variable>
   
   <xsl:variable name="NEHTA_TEMPLATE_IDs">
      <!-- Discharge Summary --><xsl:value-of select="$NEHTA_DISCHARGE_SUMMARY_TEMPLATE_ID"/>
      <!-- E-Prescription --><xsl:value-of select="$NEHTA_E_PRESCRIPTION_TEMPLATE_ID"/>
      <!-- Dispense Record --><xsl:value-of select="$NEHTA_DISPENSE_RECORD_TEMPLATE_ID"/>
      <!-- Prescription Request --><xsl:value-of select="$NEHTA_PRESCRIPTION_REQUEST_TEMPLATE_ID"/>
      <!-- Shared Health Summary --><xsl:value-of select="$NEHTA_SHARED_HEALTH_SUMMARY_TEMPLATE_ID"/>
      <!-- E-Referral --><xsl:value-of select="$NEHTA_E_REFERRAL_TEMPLATE_ID"/>
      <!-- Specialist Letter --><xsl:value-of select="$NEHTA_SPECIALIST_LETTER_TEMPLATE_ID"/>
       <!-- Event Summary --><xsl:value-of select="$NEHTA_EVENT_SUMMARY_TEMPLATE_ID"/>
   </xsl:variable>

   <!-- global variable title -->
   <xsl:variable name="title">
      <xsl:choose>
         <xsl:when test="string-length(/cda:ClinicalDocument/cda:title)  &gt;= 1">
            <xsl:value-of select="/cda:ClinicalDocument/cda:title"/>
         </xsl:when>
         <xsl:when test="contains($NEHTA_TEMPLATE_IDs, /cda:ClinicalDocument/cda:templateId/@root)">
            <xsl:call-template name="getNEHTADocumentTitleFromTemplateID">
               <xsl:with-param name="templateIdRoot" select="/cda:ClinicalDocument/cda:templateId/@root"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="/cda:ClinicalDocument/cda:code/@displayName">
            <xsl:value-of select="/cda:ClinicalDocument/cda:code/@displayName"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Clinical Document</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="screenPageWidth" select="1000"/>
   <xsl:variable name="screenHalfPageWidth" select="500"/>
   <xsl:variable name="screenQuarterPageWidth" select="250"/>
   <xsl:variable name="screenPageHeaderItemGap" select="75"/>
   <xsl:variable name="screenSummaryDetailsLeftGap" select="30"/>

   <xsl:variable name="printPageWidth" select="1000"/>
   <xsl:variable name="printHalfPageWidth" select="500"/>
   <xsl:variable name="printQuarterPageWidth" select="250"/>
   <xsl:variable name="printPageHeaderItemGap" select="75"/>
   <xsl:variable name="printSummaryDetailsLeftGap" select="30"/>

   <!-- Main -->
   <xsl:template match="/">
      <xsl:apply-templates select="cda:ClinicalDocument"/>
   </xsl:template>
   <!-- produce browser rendered, human readable clinical document -->
   <xsl:template match="cda:ClinicalDocument">
      <html>
         <head>
            <xsl:comment> Do NOT edit this HTML directly: it was generated via an XSLT
               transformation from a CDA Release 2 XML document. </xsl:comment>
            <title>
               <xsl:value-of select="$title"/>
            </title>
            <xsl:call-template name="addCSS"/>
         </head>
         <body>

            <!-- START display top portion of clinical document -->
            <xsl:call-template name="topBanner"/>

            <div id="content">
               <xsl:if test="$renderCDAHeader!='false'">
                 <xsl:call-template name="documentGeneral"/>
               </xsl:if>

                <xsl:if test="$renderCDAHeader!='false'">
                    <xsl:call-template name="show-participants">
                        <xsl:with-param name="title">PARTICIPANTS</xsl:with-param>
                        <xsl:with-param name="participants"
                            select="cda:participant[@typeCode='PART' and (cda:functionCode[@code!='PCP'] or not(cda:functionCode))]"/>
                    </xsl:call-template>
                </xsl:if>
                
               <xsl:if test="$renderCDAHeader!='false'">
               <xsl:call-template name="show-recipients">
                  <xsl:with-param name="title">PRIMARY RECIPIENTS</xsl:with-param>
                  <xsl:with-param name="recipients"
                     select="./cda:informationRecipient[@typeCode!='TRC' or not(@typeCode)]/cda:intendedRecipient"
                  />
               </xsl:call-template>
               </xsl:if>


               <!-- END display top portion of clinical document -->

               <!-- produce human readable document content -->

               <xsl:apply-templates
                  select="cda:component/cda:structuredBody|cda:component/cda:nonXMLBody"/>


               <xsl:if test="$renderCDAHeader!='false'">
               <xsl:call-template name="show-participants">
                  <xsl:with-param name="title">NOMINATED PRIMARY HEALTHCARE PROVIDERS</xsl:with-param>
                  <xsl:with-param name="participants"
                     select="cda:participant[@typeCode='PART' and cda:functionCode[@code='PCP']]"/>
               </xsl:call-template>
               </xsl:if>
               
               <xsl:if test="$renderCDAHeader!='false'">
               <xsl:call-template name="show-recipients">
                  <xsl:with-param name="title">OTHER RECIPIENTS</xsl:with-param>
                  <xsl:with-param name="recipients"
                     select="./cda:informationRecipient[@typeCode='TRC']/cda:intendedRecipient"/>
               </xsl:call-template>
               </xsl:if>
            </div>
         
             
         </body>
      </html>
   </xsl:template>

   <!-- fixed banner at top -->
   <xsl:template name="topBanner">
      
      <xsl:variable name="patientIHI">
         <xsl:call-template name="formatHI">
            <xsl:with-param name="hiValue"
               select="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier/nehtaCDA:id[@assigningAuthorityName='IHI']/@root"
            />
         </xsl:call-template>
      </xsl:variable>
      
      <xsl:variable name="patientName">
         <xsl:call-template name="show-patient-name">
            <xsl:with-param name="name"
               select="cda:recordTarget/cda:patientRole/cda:patient/cda:name"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientDateOfBirth">
         <xsl:call-template name="show-time">
            <xsl:with-param name="datetime"
               select="cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientAge">
         <xsl:call-template name="calculateAgeInYears">
            <xsl:with-param name="birthDate">
               <xsl:value-of
                  select="cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime/@value"/>
            </xsl:with-param>
            <xsl:with-param name="docDate">
               <xsl:value-of select="substring(cda:effectiveTime/@value,1,8)"/>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="documentId" select="cda:id/@root"/>

      <div class="noprint"
         style="position:fixed;
         top:10px;
         left:10px;
         height:70px;
         overflow:auto;
         background:#FFFFFF;
         color:#FFFFFF;
         ">
         <table class="pageWidth" style="border: 1px SOLID #000000;" cellspacing="0" cellpadding="0" summary="top banner panel">
                <xsl:choose>
                    <xsl:when test="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@extension and 
                        not (cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@displayable='false')">
                        <tr>
                            <th colspan="2" align="center" style="background: #EEEEEE; color: #000000; font-size: 16px; padding: 2px;"
                                ><xsl:value-of select="$title"/></th>
                        </tr>
                        <tr>
                            <th align="left"
                            style="background: #EEEEEE; color: #000000; font-size: 13px; padding: 2px;"
                            >PATIENT: <xsl:value-of select="$patientName"/><xsl:call-template
                                name="printNBSPs"><xsl:with-param name="number" select="6"
                                /></xsl:call-template>DOB: <xsl:value-of select="$patientDateOfBirth"/>
                            (<xsl:value-of select="$patientAge"/> years)<xsl:if test="$patientIHI!=''"><xsl:call-template
                                name="printNBSPs"><xsl:with-param name="number" select="6"
                                /></xsl:call-template>IHI: <xsl:value-of select="$patientIHI"/></xsl:if></th>
                        <th align="right" style="background: #EEEEEE; color: #000000; font-size: 13px; padding: 2px;">
                            <xsl:if test="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@extension and 
                                not (cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@displayable='false')">
                                MRN: <xsl:value-of select="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@extension"/>
                            </xsl:if>
                        </th>
                        </tr>
                    </xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <th colspan="1" align="center" style="background: #EEEEEE; color: #000000; font-size: 16px; padding: 2px;"
                                ><xsl:value-of select="$title"/></th>
                        </tr>
                        <tr>
                            <th colspan="2" align="left"
                            style="background: #EEEEEE; color: #000000; font-size: 13px; padding: 2px;"
                            >PATIENT: <xsl:value-of select="$patientName"/><xsl:call-template
                                name="printNBSPs"><xsl:with-param name="number" select="6"
                                /></xsl:call-template>DOB: <xsl:value-of select="$patientDateOfBirth"/>
                            (<xsl:value-of select="$patientAge"/> years)<xsl:if test="$patientIHI!=''"><xsl:call-template
                                name="printNBSPs"><xsl:with-param name="number" select="6"
                                /></xsl:call-template>IHI: <xsl:value-of select="$patientIHI"/></xsl:if></th>
                            </tr>
                    </xsl:otherwise>
                </xsl:choose>
         </table>
      </div>
      <div class="noscreen"
         style="
         top:10px;
         left:10px;
         height:70px;
         background:#FFFFFF;
         color:#FFFFFF;
         ">
          <table class="pageWidth" style="border: 1px SOLID #000000;" cellspacing="0" cellpadding="0" summary="top banner panel">
                <xsl:choose>
                    <xsl:when test="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@extension and 
                        not (cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@displayable='false')">
                        <tr>
                            <th colspan="2" align="center" style="background: #EEEEEE; color: #000000; font-size: 16px; padding: 2px;"><xsl:value-of select="$title"/></th>
                        </tr>
                        <tr>
                        <th align="left"
                            style="background: #EEEEEE; color: #000000; font-size: 13px; padding: 2px;"
                            >PATIENT: <xsl:value-of select="$patientName"/><xsl:call-template
                                name="printNBSPs"><xsl:with-param name="number" select="6"
                                /></xsl:call-template>DOB: <xsl:value-of select="$patientDateOfBirth"/>
                            (<xsl:value-of select="$patientAge"/> years)<xsl:if test="$patientIHI!=''"><xsl:call-template
                                name="printNBSPs"><xsl:with-param name="number" select="6"
                                /></xsl:call-template>IHI: <xsl:value-of select="$patientIHI"/></xsl:if></th>
                        <th align="right" style="background: #EEEEEE; color: #000000; font-size: 13px; padding: 2px;">
                            <xsl:if test="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@extension and 
                                not (cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@displayable='false')">
                                MRN: <xsl:value-of select="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id/@extension"/>
                            </xsl:if>
                        </th>
                        </tr>
                    </xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <th colspan="1" align="center" style="background: #EEEEEE; color: #000000; font-size: 16px; padding: 2px;"><xsl:value-of select="$title"/></th>
                        </tr>
                        <tr>
                        <th colspan="2" align="left"
                            style="background: #EEEEEE; color: #000000; font-size: 13px; padding: 2px;"
                            >PATIENT: <xsl:value-of select="$patientName"/><xsl:call-template
                                name="printNBSPs"><xsl:with-param name="number" select="6"
                                /></xsl:call-template>DOB: <xsl:value-of select="$patientDateOfBirth"/>
                            (<xsl:value-of select="$patientAge"/> years)<xsl:if test="$patientIHI!=''"><xsl:call-template
                                name="printNBSPs"><xsl:with-param name="number" select="6"
                                /></xsl:call-template>IHI: <xsl:value-of select="$patientIHI"/></xsl:if></th>
                         </tr>
                    </xsl:otherwise>
                </xsl:choose>
         </table>
      </div>
   </xsl:template>

   <!-- generate table of contents -->
   <xsl:template name="make-tableofcontents">
      <h2>
         <a name="toc">Table of Contents</a>
      </h2>
      <ul>
         <xsl:for-each select="cda:component/cda:structuredBody/cda:component/cda:section/cda:title">
            <li>
               <a href="#{generate-id(.)}">
                  <xsl:value-of select="."/>
               </a>
            </li>
         </xsl:for-each>
      </ul>
   </xsl:template>
   <!-- header elements -->
   <xsl:template name="documentGeneral">
      <!-- Patient Variables -->
      <xsl:variable name="patientName">
         <xsl:call-template name="show-patient-name">
            <xsl:with-param name="name"
               select="cda:recordTarget/cda:patientRole/cda:patient/cda:name"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientDateOfBirth">
         <xsl:call-template name="show-time">
            <xsl:with-param name="datetime"
               select="cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientAge">
         <xsl:call-template name="calculateAgeInYears">
            <xsl:with-param name="birthDate">
               <xsl:value-of
                  select="cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime/@value"/>
            </xsl:with-param>
            <xsl:with-param name="docDate">
               <xsl:value-of select="substring(cda:effectiveTime/@value,1,8)"/>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientIHI">
         <xsl:call-template name="formatHI">
            <xsl:with-param name="hiValue"
               select="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier/nehtaCDA:id[@assigningAuthorityName='IHI']/@root"
            />
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientMRN">
         <xsl:call-template name="trim">
            <xsl:with-param name="string" select="cda:recordTarget/cda:patientRole/cda:id/@extension"/>
         </xsl:call-template>
      </xsl:variable> 
      
      <xsl:variable name="genderCode"
         select="cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode/@code"/>

      <xsl:variable name="patientSex">
         <xsl:choose>
            <xsl:when test="$genderCode = 'M'">Male</xsl:when>
            <xsl:when test="$genderCode = 'F'">Female</xsl:when>
            <xsl:otherwise>Not Stated</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:variable name="patientAddressResidence">
         <xsl:call-template name="show-address">
            <xsl:with-param name="address"
               select="cda:recordTarget/cda:patientRole/cda:addr[@use='H']"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientAddressPostal">
         <xsl:call-template name="show-address">
            <xsl:with-param name="address"
               select="cda:recordTarget/cda:patientRole/cda:addr[@use='PST']"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientContactHomePhone">
         <xsl:call-template name="show-telecom">
            <xsl:with-param name="telecom"
               select="cda:recordTarget/cda:patientRole/cda:telecom[@use='H']"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="patientContactMobilePhone">
         <xsl:call-template name="show-telecom">
            <xsl:with-param name="telecom"
               select="cda:recordTarget/cda:patientRole/cda:telecom[@use='M']"/>
         </xsl:call-template>
      </xsl:variable>


      <!-- Document Variables -->
         
          <!-- Facility Name -->
       <xsl:variable name="facilityName">
           <xsl:choose>
              <xsl:when test="cda:componentOf/cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:name">
                      <xsl:value-of select="cda:componentOf/cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:name"/>
              </xsl:when>
              <xsl:when test="cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:name">
                      <xsl:value-of select="cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:name"/>
              </xsl:when>
              <xsl:when test="cda:author/cda:assignedAuthor/cda:representedOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:name">
                      <xsl:value-of select="cda:author/cda:assignedAuthor/cda:representedOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:name"/>
              </xsl:when>
              <xsl:when test="cda:author/cda:assignedAuthor/cda:representedOrganization/cda:name">
                      <xsl:value-of select="cda:author/cda:assignedAuthor/cda:representedOrganization/cda:name"/>
              </xsl:when>
           </xsl:choose>
       </xsl:variable>

       <!-- Facility HPI-O -->
       <xsl:variable name="facilityHPIO">
           <xsl:choose>
           <xsl:when test="cda:componentOf/cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:name">
                   <xsl:call-template name="formatHI">
                       <xsl:with-param name="hiValue"
                           select="cda:componentOf/cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-O']/@root"
                       />
                   </xsl:call-template>
           </xsl:when>
           <xsl:when test="cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:name">
                   <xsl:call-template name="formatHI">
                       <xsl:with-param name="hiValue"
                           select="cda:componentOf/cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-O']/@root"
                       />
                   </xsl:call-template>
           </xsl:when>
           <xsl:when test="cda:author/cda:assignedAuthor/cda:representedOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:name">
                   <xsl:call-template name="formatHI">
                       <xsl:with-param name="hiValue"
                           select="cda:author/cda:assignedAuthor/cda:representedOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-O']/@root"
                       />
                   </xsl:call-template>
           </xsl:when>
           <xsl:when test="cda:author/cda:assignedAuthor/cda:representedOrganization/cda:name">
                   <xsl:call-template name="formatHI">
                       <xsl:with-param name="hiValue"
                           select="cda:author/cda:assignedAuthor/cda:representedOrganization/nehtaCDA:id[@assigningAuthorityName='HPI-O']/@root"
                       />
                   </xsl:call-template>
           </xsl:when>
           </xsl:choose>
           </xsl:variable>
       
      <xsl:variable name="documentVersion" select="cda:versionNumber/@value"/>
      
      <xsl:variable name="documentId" select="cda:id/@root"/>
      
      <xsl:variable name="completionCode">
         <xsl:choose>
            <xsl:when test="/cda:ClinicalDocument/nehtaCDA:completionCode/@code='F'">Final</xsl:when>
            <xsl:when test="/cda:ClinicalDocument/nehtaCDA:completionCode/@code='I'">Interim</xsl:when>
            <xsl:when test="/cda:ClinicalDocument/nehtaCDA:completionCode/@code='W'">Withdrawn</xsl:when>
            <xsl:otherwise>Final</xsl:otherwise>   
         </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="dateCompleted">
         <xsl:call-template name="show-time">
            <xsl:with-param name="datetime" select="cda:effectiveTime"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="documentAuthor">
         <xsl:call-template name="show-name">
            <xsl:with-param name="name"
               select="cda:author/cda:assignedAuthor/cda:assignedPerson/cda:name"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="documentAuthorPhone">
         <xsl:call-template name="show-telecom">
            <xsl:with-param name="telecom" select="cda:author/cda:assignedAuthor/cda:telecom"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="documentAuthorHI">
         <xsl:call-template name="formatHI">
            <xsl:with-param name="hiValue"
               select="cda:author/cda:assignedAuthor/cda:assignedPerson/nehtaCDA:asEntityIdentifier/nehtaCDA:id[@assigningAuthorityName='HPI-I']/@root"
            />
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="documentAuthorRole"
         select="cda:author/cda:assignedAuthor/cda:code/@displayName"/>

      <xsl:variable name="documentAuthorOrganisation"
         select="cda:author/cda:assignedAuthor/cda:representedOrganization/cda:name"/>

      <xsl:variable name="documentAuthorOrganisationHPIO">
         <xsl:call-template name="formatHI">
            <xsl:with-param name="hiValue"
               select="cda:author/cda:assignedAuthor/cda:representedOrganization/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-O']/@root"
            />
         </xsl:call-template>
      </xsl:variable>


      <!-- Encounter Variables -->
      <xsl:variable name="admissionDate">
         <xsl:if
            test="cda:componentOf/cda:encompassingEncounter/cda:effectiveTime/cda:low/@value!=''">
            <xsl:call-template name="show-time">
               <xsl:with-param name="datetime"
                  select="cda:componentOf/cda:encompassingEncounter/cda:effectiveTime/cda:low"/>
            </xsl:call-template>
         </xsl:if>
      </xsl:variable>


      <xsl:variable name="dischargeDate">
         <xsl:if
            test="cda:componentOf/cda:encompassingEncounter/cda:effectiveTime/cda:high/@value!=''">
            <xsl:call-template name="show-time">
               <xsl:with-param name="datetime"
                  select="cda:componentOf/cda:encompassingEncounter/cda:effectiveTime/cda:high"/>
            </xsl:call-template>
         </xsl:if>

      </xsl:variable>

      <xsl:variable name="separationMode"
         select="cda:componentOf/cda:encompassingEncounter/cda:dischargeDispositionCode/@displayName"/>

      <xsl:variable name="department"
         select="cda:componentOf/cda:encompassingEncounter/cda:encounterParticipant/cda:assignedEntity/cda:representedOrganization/cda:name"/>

      <!-- Facility Variables -->
      <xsl:variable name="facilityAddress">
         <xsl:call-template name="show-address">
            <xsl:with-param name="address"
               select="cda:componentOf/cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:addr"
            />
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="facilityContactPhone">
         <xsl:call-template name="show-telecom">
            <xsl:with-param name="telecom"
               select="cda:componentOf/cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:telecom[starts-with(@value, 'tel:')]"
            />
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="facilityContactFax">
         <xsl:call-template name="show-telecom">
            <xsl:with-param name="telecom"
               select="cda:componentOf/cda:encompassingEncounter/cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:telecom[starts-with(@value, 'fax:')]"
            />
         </xsl:call-template>
      </xsl:variable>

       <table class="pageWidth" cellspacing="0" cellpadding="0" style="page-break-inside: avoid;" summary="document general">
         <tr>
            <td valign="top">
               <!-- PATIENT / FACILITY / ENCOMPASSING ENCOUNTER -->
                <table summary="Patient / Facility / Encompassing Encounter details">
                  <tr>
                     <td valign="top">
                        <!-- PATIENT -->

                         <table class="halfPageWidth" cellspacing="0" cellpadding="0" summary="Patient details">
                           <tr>
                              <th colspan="2" class="sectionheader" align="left">
                                 <strong>PATIENT</strong>
                              </th>
                           </tr>
                           <tr>
                              <td class="sidevaluenames">Name</td>
                              <td class="sidevalue">
                                 <xsl:value-of select="$patientName"/>
                              </td>
                           </tr>
                           <tr>
                              <td class="sidevaluenames">IHI</td>
                              <td class="sidevalue">
                                 <xsl:value-of select="$patientIHI"/>
                              </td>
                           </tr>
                           
                           <xsl:for-each select="cda:recordTarget/cda:patientRole/cda:patient/nehtaCDA:asEntityIdentifier[nehtaCDA:code/@code='MR']/nehtaCDA:id">                           
                              <tr>
                                 <xsl:if test="position()=1">
                                    <xsl:if test="position()=last()"><td class="sidevaluenames">MRN</td></xsl:if>
                                    <xsl:if test="position()!=last()"><td class="sidevaluenames">MRNs</td></xsl:if>
                                 </xsl:if>
                                 <xsl:if test="position()!=1">
                                    <td class="sidevaluenames"></td>
                                 </xsl:if>
                                 <td class="sidevalue">
                                     <xsl:choose>
                                         <xsl:when test="./@assigningAuthorityName">
                                             <xsl:value-of select="./@extension"/> (<xsl:value-of select="./@assigningAuthorityName"/>)
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:value-of select="./@extension"/>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                     
                                 </td>
                              </tr>
                           </xsl:for-each>
                           
                           <tr>
                              <td class="sidevaluenames">Date of Birth</td>
                              <td class="sidevalue"><xsl:value-of select="$patientDateOfBirth"/>
                                    (<xsl:value-of select="$patientAge"/> years)</td>
                           </tr>
                           <tr>
                              <td class="sidevaluenames">Sex</td>
                              <td class="sidevalue">
                                 <xsl:value-of select="$patientSex"/>
                              </td>
                           </tr>
                           <tr>
                              <td class="sidevaluenames">Address</td>
                              <td class="sidevalue">
                                 <xsl:if test="$patientAddressResidence!=''">Residence:
                                       <xsl:value-of select="$patientAddressResidence"
                                    /><br/></xsl:if>
                                 <xsl:if test="$patientAddressPostal!=''">Postal: <xsl:value-of
                                       select="$patientAddressPostal"/></xsl:if>
                              </td>
                           </tr>
                           <xsl:if
                              test="($patientContactHomePhone!='') or ($patientContactMobilePhone!='')">
                              <tr>
                                 <td class="sidevaluenames">Contact</td>
                                 <td class="sidevalue">
                                    <xsl:if test="$patientContactHomePhone!=''">Home Phone:
                                          <xsl:value-of select="$patientContactHomePhone"
                                       /><br/></xsl:if>
                                    <xsl:if test="$patientContactMobilePhone!=''">Mobile:
                                          <xsl:value-of select="$patientContactMobilePhone"
                                       /></xsl:if>
                                 </td>
                              </tr>
                           </xsl:if>
                        </table>
                        <div class="horizontalspacer"/>
                     </td>
                  </tr>
                  <xsl:element name="tr"><xsl:element name="td"></xsl:element></xsl:element>
                  <tr>
                     <td valign="top">
                        <!-- FACILITY DETAILS -->
                         <table class="halfPageWidth" cellspacing="0" cellpadding="0" summary="Facility details">
                           <xsl:if test="$facilityName != ''">
                              <tr>
                                 <th class="sectionheader" colspan="2">
                                    <b>FACILITY DETAILS</b>
                                 </th>
                              </tr>
                              <xsl:if test="$facilityName!=''">
                                 <tr>
                                    <td class="sidevaluenames">Name</td>
                                    <td class="sidevalue">
                                       <xsl:value-of select="$facilityName"/>
                                       <xsl:if test="$facilityHPIO!='' and $renderHeaderHPIOs='true'">
                                          <br/>
                                          <div class="hi" style="margin-left: 20px;">[HPI-O:
                                                <xsl:value-of select="$facilityHPIO"/>]</div>
                                       </xsl:if>
                                    </td>
                                 </tr>
                              </xsl:if>

                              <xsl:if test="$facilityAddress!=''">
                                 <tr>
                                    <td class="sidevaluenames">Address</td>
                                    <td class="sidevalue">
                                       <xsl:value-of select="$facilityAddress"/>
                                    </td>
                                 </tr>
                              </xsl:if>

                              <xsl:if test="$facilityContactPhone!='' or $facilityContactFax!=''">
                                 <tr>
                                    <td class="sidevaluenames">Contact</td>
                                    <td class="sidevalue">
                                       <xsl:if test="$facilityContactPhone!=''">Phone: <xsl:value-of
                                             select="$facilityContactPhone"/><br/></xsl:if>
                                       <xsl:if test="$facilityContactFax!=''">Fax: <xsl:value-of
                                             select="$facilityContactFax"/></xsl:if>
                                    </td>
                                 </tr>
                              </xsl:if>
                           </xsl:if>
                        </table>
                        <div class="horizontalspacer"/>
                     </td>
                     <td/>
                  </tr>

                  <xsl:if
                     test="$admissionDate != '' or
                     $dischargeDate != '' or
                     $department != '' or
                     $separationMode != '' or
                     count(cda:component/cda:structuredBody/cda:component/cda:section[cda:title='Administrative Observations']/cda:text/cda:table[cda:caption='SPECIALTIES']/cda:tbody/cda:tr) &gt; 0">
                     <tr>
                        <td valign="top">
                           <!-- ENCOUNTER DETAILS -->
                            <table class="halfPageWidth" cellspacing="0" cellpadding="0" summary="Encounter details">
                              <tr>
                                 <th class="sectionheader" align="left" colspan="2">
                                    <b>ENCOUNTER DETAILS</b>
                                 </th>
                              </tr>

                              <xsl:if test="$admissionDate!=''">
                                 <tr>
                                    <td class="sidevaluenames">Start Date</td>
                                    <td class="sidevalue">
                                       <xsl:value-of select="$admissionDate"/>
                                    </td>
                                 </tr>
                              </xsl:if>

                              <xsl:if test="$dischargeDate!=''">
                                 <tr>
                                    <td class="sidevaluenames">End Date</td>
                                    <td class="sidevalue">
                                       <xsl:value-of select="$dischargeDate"/>
                                    </td>
                                 </tr>
                              </xsl:if>

                              <xsl:if test="$department!=''">
                                 <tr>
                                    <td class="sidevaluenames">Department</td>
                                    <td class="sidevalue">
                                       <xsl:value-of select="$department"/>
                                    </td>
                                 </tr>
                              </xsl:if>

                              <xsl:if test="$separationMode!=''">
                                 <tr>
                                    <td class="sidevaluenames">Separation Mode</td>
                                    <td class="sidevalue">
                                       <xsl:value-of select="$separationMode"/>
                                    </td>
                                 </tr>
                              </xsl:if>
                           </table>
                        </td>
                        <td/>
                     </tr>
                  </xsl:if>


               </table>
            </td>
            <td valign="top">
               <!-- MAIN TITLE -->
                <table summary="Main Title">
                  <tr>
                     <td valign="top">
                        <!-- MAIN TITLE -->
                         <table class="halfPageWidth" cellspacing="0" cellpadding="0" summary="Main Title">
                           <tr>
                              <td colspan="2" class="facility" align="center">
                                 <br/>
                                 <xsl:value-of select="$facilityName"/>
                                 <xsl:if test="$facilityHPIO!='' and $renderHeaderHPIOs='true'">
                                    <br/>
                                    <div class="hi">[HPI-O: <xsl:value-of select="$facilityHPIO"
                                       />]</div>
                                 </xsl:if>
                              </td>
                           </tr>

                           <xsl:if test="//cda:observationMedia[@ID='LOGO']/cda:value[@mediaType='image/png']">
                           <tr>
                              <td colspan="2" class="facility" align="center">
                                 <xsl:call-template name="renderLogo"/>
                              </td>
                           </tr>
                           </xsl:if>
                           
                           <tr>
                              <td colspan="2"><br/></td>
                           </tr>

                           <tr>
                              <td class="summarydetails"><div class="summaryDetailsLeftGap"
                                 style="display: inline; "/>Document ID</td>
                              <td class="documentdetailsvalues">
                                 <xsl:value-of select="$documentId"/>
                              </td>
                           </tr>
                           
                           <tr>
                              <td class="summarydetails"><div class="summaryDetailsLeftGap"
                                 style="display: inline; "/>Completion Code</td>
                              <td class="documentdetailsvalues">
                                 <xsl:value-of select="$completionCode"/>
                              </td>
                           </tr>
                           
                           <tr>
                              <td class="summarydetails"><div class="summaryDetailsLeftGap"
                                 style="display: inline; "/>Version Number</td>
                              <td class="documentdetailsvalues">
                                 <xsl:value-of select="$documentVersion"/>
                              </td>
                           </tr>
                           
                           <tr>
                              <td class="summarydetails"><div class="summaryDetailsLeftGap"
                                    style="display: inline; "/>Date completed</td>
                              <td class="documentdetailsvalues">
                                 <xsl:value-of select="$dateCompleted"/>
                              </td>
                           </tr>

                           <tr>
                              <td class="summarydetails"><div class="summaryDetailsLeftGap"
                                    style="display: inline; "/>Document Author</td>
                              <td class="documentdetailsvalues">
                                 <xsl:value-of select="$documentAuthor"/>
                                 <xsl:call-template name="printNBSPs">
                                    <xsl:with-param name="number" select="1"/>
                                 </xsl:call-template>
                                 <xsl:if test="$documentAuthorRole!=''">(<xsl:value-of
                                       select="$documentAuthorRole"/>)</xsl:if>
                                 <br/>
                                 <xsl:if test="$documentAuthorPhone!=''">Phone: <xsl:value-of
                                       select="$documentAuthorPhone"/></xsl:if>
                                 <xsl:if test="$documentAuthorHI!='' and $renderHeaderHPIIs='true'">
                                    <br/>
                                    <div class="hi" style="margin-left: 20px;">[HPI-I: <xsl:value-of
                                          select="$documentAuthorHI"/>]</div>
                                 </xsl:if>
                              </td>
                           </tr>

                           <tr>
                              <td class="summarydetails"/>
                              <td class="documentdetailsvalues">
                                 <xsl:if test="$documentAuthorOrganisation!=''">
                                    <xsl:value-of select="$documentAuthorOrganisation"/>
                                 </xsl:if>
                                 <br/>
                                 <xsl:if test="$documentAuthorOrganisationHPIO!='' and $renderHeaderHPIOs='true'">
                                    <div class="hi" style="margin-left: 20px;">[HPI-O: <xsl:value-of
                                          select="$documentAuthorOrganisationHPIO"/>]</div>
                                 </xsl:if>
                              </td>
                           </tr>

                        </table>
                     </td>
                  </tr>
               </table>
            </td>
         </tr>


      </table>

      <div class="horizontalspacer"/>
   </xsl:template>
   <!-- confidentiality -->
   <xsl:template name="confidentiality">
       <table class="header_table" summary="confidentiality">
         <tbody>
            <td width="20%" bgcolor="#3399ff">
               <xsl:text>Confidentiality</xsl:text>
            </td>
            <td width="80%">
               <xsl:choose>
                  <xsl:when test="cda:confidentialityCode/@code  = &apos;N&apos;">
                     <xsl:text>Normal</xsl:text>
                  </xsl:when>
                  <xsl:when test="cda:confidentialityCode/@code  = &apos;R&apos;">
                     <xsl:text>Restricted</xsl:text>
                  </xsl:when>
                  <xsl:when test="cda:confidentialityCode/@code  = &apos;V&apos;">
                     <xsl:text>Very restricted</xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:if test="cda:confidentialityCode/cda:originalText">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="cda:confidentialityCode/cda:originalText"/>
               </xsl:if>
            </td>
         </tbody>
      </table>
   </xsl:template>
   <!-- author -->
   <xsl:template name="author">
      <xsl:if test="cda:author">
          <table class="header_table" summary="author">
            <tbody>
               <xsl:for-each select="cda:author/cda:assignedAuthor">
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Author</xsl:text>
                        </span>
                     </td>
                     <td width="80%">
                        <xsl:choose>
                           <xsl:when test="cda:assignedPerson/cda:name">
                              <xsl:call-template name="show-name">
                                 <xsl:with-param name="name" select="cda:assignedPerson/cda:name"/>
                              </xsl:call-template>
                              <xsl:if test="cda:representedOrganization">
                                 <xsl:text>, </xsl:text>
                                 <xsl:call-template name="show-name">
                                    <xsl:with-param name="name"
                                       select="cda:representedOrganization/cda:name"/>
                                 </xsl:call-template>
                              </xsl:if>
                           </xsl:when>
                           <xsl:when test="cda:assignedAuthoringDevice/cda:softwareName">
                              <xsl:value-of select="cda:assignedAuthoringDevice/cda:softwareName"/>
                           </xsl:when>
                           <xsl:when test="cda:representedOrganization">
                              <xsl:call-template name="show-name">
                                 <xsl:with-param name="name"
                                    select="cda:representedOrganization/cda:name"/>
                              </xsl:call-template>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:for-each select="cda:id">
                                 <xsl:call-template name="show-id"/>
                                 <br/>
                              </xsl:for-each>
                           </xsl:otherwise>
                        </xsl:choose>
                     </td>
                  </tr>
                  <xsl:if test="cda:addr | cda:telecom">
                     <tr>
                        <td bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Contact info</xsl:text>
                           </span>
                        </td>
                        <td>
                           <xsl:call-template name="show-contactInfo">
                              <xsl:with-param name="contact" select="."/>
                           </xsl:call-template>
                        </td>
                     </tr>
                  </xsl:if>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!--  authenticator -->
   <xsl:template name="authenticator">
      <xsl:if test="cda:authenticator">
          <table class="header_table" summary="authenticator">
            <tbody>
               <tr>
                  <xsl:for-each select="cda:authenticator">
                     <tr>
                        <td width="20%" bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Signed </xsl:text>
                           </span>
                        </td>
                        <td width="80%">
                           <xsl:call-template name="show-name">
                              <xsl:with-param name="name"
                                 select="cda:assignedEntity/cda:assignedPerson/cda:name"/>
                           </xsl:call-template>
                           <xsl:text> at </xsl:text>
                           <xsl:call-template name="show-time">
                              <xsl:with-param name="date" select="cda:time"/>
                           </xsl:call-template>
                        </td>
                     </tr>
                     <xsl:if test="cda:assignedEntity/cda:addr | cda:assignedEntity/cda:telecom">
                        <tr>
                           <td bgcolor="#3399ff">
                              <span class="td_label">
                                 <xsl:text>Contact info</xsl:text>
                              </span>
                           </td>
                           <td width="80%">
                              <xsl:call-template name="show-contactInfo">
                                 <xsl:with-param name="contact" select="cda:assignedEntity"/>
                              </xsl:call-template>
                           </td>
                        </tr>
                     </xsl:if>
                  </xsl:for-each>
               </tr>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- legalAuthenticator -->
   <xsl:template name="legalAuthenticator">
      <xsl:if test="cda:legalAuthenticator">
          <table class="header_table" summary="Legal Authenticator">
            <tbody>
               <tr>
                  <td width="20%" bgcolor="#3399ff">
                     <span class="td_label">
                        <xsl:text>Legal authenticator</xsl:text>
                     </span>
                  </td>
                  <td width="80%">
                     <xsl:call-template name="show-assignedEntity">
                        <xsl:with-param name="asgnEntity"
                           select="cda:legalAuthenticator/cda:assignedEntity"/>
                     </xsl:call-template>
                     <xsl:text> </xsl:text>
                     <xsl:call-template name="show-sig">
                        <xsl:with-param name="sig" select="cda:legalAuthenticator/cda:signatureCode"
                        />
                     </xsl:call-template>
                     <xsl:if test="cda:legalAuthenticator/cda:time/@value">
                        <xsl:text> at </xsl:text>
                        <xsl:call-template name="show-time">
                           <xsl:with-param name="datetime" select="cda:legalAuthenticator/cda:time"
                           />
                        </xsl:call-template>
                     </xsl:if>
                  </td>
               </tr>
               <xsl:if
                  test="cda:legalAuthenticator/cda:assignedEntity/cda:addr | cda:legalAuthenticator/cda:assignedEntity/cda:telecom">
                  <tr>
                     <td bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Contact info</xsl:text>
                        </span>
                     </td>
                     <td>
                        <xsl:call-template name="show-contactInfo">
                           <xsl:with-param name="contact"
                              select="cda:legalAuthenticator/cda:assignedEntity"/>
                        </xsl:call-template>
                     </td>
                  </tr>
               </xsl:if>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- dataEnterer -->
   <xsl:template name="dataEnterer">
      <xsl:if test="cda:dataEnterer">
          <table class="header_table" summary="Data Enterer">
            <tbody>
               <tr>
                  <td width="20%" bgcolor="#3399ff">
                     <span class="td_label">
                        <xsl:text>Entered by</xsl:text>
                     </span>
                  </td>
                  <td width="80%">
                     <xsl:call-template name="show-assignedEntity">
                        <xsl:with-param name="asgnEntity"
                           select="cda:dataEnterer/cda:assignedEntity"/>
                     </xsl:call-template>
                  </td>
               </tr>
               <xsl:if
                  test="cda:dataEnterer/cda:assignedEntity/cda:addr | cda:dataEnterer/cda:assignedEntity/cda:telecom">
                  <tr>
                     <td bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Contact info</xsl:text>
                        </span>
                     </td>
                     <td>
                        <xsl:call-template name="show-contactInfo">
                           <xsl:with-param name="contact"
                              select="cda:dataEnterer/cda:assignedEntity"/>
                        </xsl:call-template>
                     </td>
                  </tr>
               </xsl:if>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- componentOf -->
   <xsl:template name="componentof">
      <xsl:if test="cda:componentOf">
          <table class="header_table" summary="Encompassing Encounter">
            <tbody>
               <xsl:for-each select="cda:componentOf/cda:encompassingEncounter">
                  <xsl:if test="cda:id">
                     <tr>
                        <xsl:choose>
                           <xsl:when test="cda:code">
                              <td width="20%" bgcolor="#3399ff">
                                 <span class="td_label">
                                    <xsl:text>Encounter Id</xsl:text>
                                 </span>
                              </td>
                              <td width="30%">
                                 <xsl:call-template name="show-id">
                                    <xsl:with-param name="id" select="cda:id"/>
                                 </xsl:call-template>
                              </td>
                              <td width="15%" bgcolor="#3399ff">
                                 <span class="td_label">
                                    <xsl:text>Encounter Type</xsl:text>
                                 </span>
                              </td>
                              <td>
                                 <xsl:call-template name="show-code">
                                    <xsl:with-param name="code" select="cda:code"/>
                                 </xsl:call-template>
                              </td>
                           </xsl:when>
                           <xsl:otherwise>
                              <td width="20%" bgcolor="#3399ff">
                                 <span class="td_label">
                                    <xsl:text>Encounter Id</xsl:text>
                                 </span>
                              </td>
                              <td>
                                 <xsl:call-template name="show-id">
                                    <xsl:with-param name="id" select="cda:id"/>
                                 </xsl:call-template>
                              </td>
                           </xsl:otherwise>
                        </xsl:choose>
                     </tr>
                  </xsl:if>
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Encounter Date</xsl:text>
                        </span>
                     </td>
                     <td colspan="3">
                        <xsl:if test="cda:effectiveTime">
                           <xsl:choose>
                              <xsl:when test="cda:effectiveTime/@value">
                                 <xsl:text>&#160;at&#160;</xsl:text>
                                 <xsl:call-template name="show-time">
                                    <xsl:with-param name="datetime" select="cda:effectiveTime"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:when test="cda:effectiveTime/cda:low">
                                 <xsl:text>&#160;From&#160;</xsl:text>
                                 <xsl:call-template name="show-time">
                                    <xsl:with-param name="datetime"
                                       select="cda:effectiveTime/cda:low"/>
                                 </xsl:call-template>
                                 <xsl:if test="cda:effectiveTime/cda:high">
                                    <xsl:text> to </xsl:text>
                                    <xsl:call-template name="show-time">
                                       <xsl:with-param name="datetime"
                                          select="cda:effectiveTime/cda:high"/>
                                    </xsl:call-template>
                                 </xsl:if>
                              </xsl:when>
                           </xsl:choose>
                        </xsl:if>
                     </td>
                  </tr>
                  <xsl:if test="cda:location/cda:healthCareFacility">
                     <tr>
                        <td width="20%" bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Encounter Location</xsl:text>
                           </span>
                        </td>
                        <td colspan="3">
                           <xsl:choose>
                              <xsl:when
                                 test="cda:location/cda:healthCareFacility/cda:location/cda:name">
                                 <xsl:call-template name="show-name">
                                    <xsl:with-param name="name"
                                       select="cda:location/cda:healthCareFacility/cda:location/cda:name"
                                    />
                                 </xsl:call-template>
                                 <xsl:for-each
                                    select="cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:name">
                                    <xsl:text> of </xsl:text>
                                    <xsl:call-template name="show-name">
                                       <xsl:with-param name="name"
                                          select="cda:location/cda:healthCareFacility/cda:serviceProviderOrganization/cda:name"
                                       />
                                    </xsl:call-template>
                                 </xsl:for-each>
                              </xsl:when>
                              <xsl:when test="cda:location/cda:healthCareFacility/cda:code">
                                 <xsl:call-template name="show-code">
                                    <xsl:with-param name="code"
                                       select="cda:location/cda:healthCareFacility/cda:code"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:if test="cda:location/cda:healthCareFacility/cda:id">
                                    <xsl:text>id: </xsl:text>
                                    <xsl:for-each
                                       select="cda:location/cda:healthCareFacility/cda:id">
                                       <xsl:call-template name="show-id">
                                          <xsl:with-param name="id" select="."/>
                                       </xsl:call-template>
                                    </xsl:for-each>
                                 </xsl:if>
                              </xsl:otherwise>
                           </xsl:choose>
                        </td>
                     </tr>
                  </xsl:if>
                  <xsl:if test="cda:responsibleParty">
                     <tr>
                        <td width="20%" bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Responsible party</xsl:text>
                           </span>
                        </td>
                        <td colspan="3">
                           <xsl:call-template name="show-assignedEntity">
                              <xsl:with-param name="asgnEntity"
                                 select="cda:responsibleParty/cda:assignedEntity"/>
                           </xsl:call-template>
                        </td>
                     </tr>
                  </xsl:if>
                  <xsl:if
                     test="cda:responsibleParty/cda:assignedEntity/cda:addr | cda:responsibleParty/cda:assignedEntity/cda:telecom">
                     <tr>
                        <td width="20%" bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Contact info</xsl:text>
                           </span>
                        </td>
                        <td colspan="3">
                           <xsl:call-template name="show-contactInfo">
                              <xsl:with-param name="contact"
                                 select="cda:responsibleParty/cda:assignedEntity"/>
                           </xsl:call-template>
                        </td>
                     </tr>
                  </xsl:if>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- custodian -->
   <xsl:template name="custodian">
      <xsl:if test="cda:custodian">
          <table class="header_table" summary="Custodian">
            <tbody>
               <tr>
                  <td width="20%" bgcolor="#3399ff">
                     <span class="td_label">
                        <xsl:text>Document maintained by</xsl:text>
                     </span>
                  </td>
                  <td width="80%">
                     <xsl:choose>
                        <xsl:when
                           test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:name">
                           <xsl:call-template name="show-name">
                              <xsl:with-param name="name"
                                 select="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:name"
                              />
                           </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:for-each
                              select="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:id">
                              <xsl:call-template name="show-id"/>
                              <xsl:if test="position()!=last()">
                                 <br/>
                              </xsl:if>
                           </xsl:for-each>
                        </xsl:otherwise>
                     </xsl:choose>
                  </td>
               </tr>
               <xsl:if
                  test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:addr |             cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:telecom">
                  <tr>
                     <td bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Contact info</xsl:text>
                        </span>
                     </td>
                     <td width="80%">
                        <xsl:call-template name="show-contactInfo">
                           <xsl:with-param name="contact"
                              select="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization"
                           />
                        </xsl:call-template>
                     </td>
                  </tr>
               </xsl:if>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- documentationOf -->
   <xsl:template name="documentationOf">
      <xsl:if test="cda:documentationOf">
          <table class="header_table" summary="Documentation Of">
            <tbody>
               <xsl:for-each select="cda:documentationOf">
                  <xsl:if test="cda:serviceEvent/@classCode and cda:serviceEvent/cda:code">
                     <xsl:variable name="displayName">
                        <xsl:call-template name="show-actClassCode">
                           <xsl:with-param name="clsCode" select="cda:serviceEvent/@classCode"/>
                        </xsl:call-template>
                     </xsl:variable>
                     <xsl:if test="$displayName">
                        <tr>
                           <td width="20%" bgcolor="#3399ff">
                              <span class="td_label">
                                 <xsl:call-template name="firstCharCaseUp">
                                    <xsl:with-param name="data" select="$displayName"/>
                                 </xsl:call-template>
                              </span>
                           </td>
                           <td width="80%" colspan="3">
                              <xsl:call-template name="show-code">
                                 <xsl:with-param name="code" select="cda:serviceEvent/cda:code"/>
                              </xsl:call-template>
                              <xsl:if test="cda:serviceEvent/cda:effectiveTime">
                                 <xsl:choose>
                                    <xsl:when test="cda:serviceEvent/cda:effectiveTime/@value">
                                       <xsl:text>&#160;at&#160;</xsl:text>
                                       <xsl:call-template name="show-time">
                                          <xsl:with-param name="datetime"
                                             select="cda:serviceEvent/cda:effectiveTime"/>
                                       </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="cda:serviceEvent/cda:effectiveTime/cda:low">
                                       <xsl:text>&#160;from&#160;</xsl:text>
                                       <xsl:call-template name="show-time">
                                          <xsl:with-param name="datetime"
                                             select="cda:serviceEvent/cda:effectiveTime/cda:low"/>
                                       </xsl:call-template>
                                       <xsl:if test="cda:serviceEvent/cda:effectiveTime/cda:high">
                                          <xsl:text> to </xsl:text>
                                          <xsl:call-template name="show-time">
                                             <xsl:with-param name="datetime"
                                                select="cda:serviceEvent/cda:effectiveTime/cda:high"
                                             />
                                          </xsl:call-template>
                                       </xsl:if>
                                    </xsl:when>
                                 </xsl:choose>
                              </xsl:if>
                           </td>
                        </tr>
                     </xsl:if>
                  </xsl:if>
                  <xsl:for-each select="cda:serviceEvent/cda:performer">
                     <xsl:variable name="displayName">
                        <xsl:call-template name="show-participationType">
                           <xsl:with-param name="ptype" select="@typeCode"/>
                        </xsl:call-template>
                        <xsl:text> </xsl:text>
                        <xsl:if test="cda:functionCode/@code">
                           <xsl:call-template name="show-participationFunction">
                              <xsl:with-param name="pFunction" select="cda:functionCode/@code"/>
                           </xsl:call-template>
                        </xsl:if>
                     </xsl:variable>
                     <tr>
                        <td width="20%" bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:call-template name="firstCharCaseUp">
                                 <xsl:with-param name="data" select="$displayName"/>
                              </xsl:call-template>
                           </span>
                        </td>
                        <td width="80%" colspan="3">
                           <xsl:call-template name="show-assignedEntity">
                              <xsl:with-param name="asgnEntity" select="cda:assignedEntity"/>
                           </xsl:call-template>
                        </td>
                     </tr>
                  </xsl:for-each>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- inFulfillmentOf -->
   <xsl:template name="inFulfillmentOf">
      <xsl:if test="cda:infulfillmentOf">
          <table class="header_table" summary="In Fulfillment Of">
            <tbody>
               <xsl:for-each select="cda:inFulfillmentOf">
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>In fulfillment of</xsl:text>
                        </span>
                     </td>
                     <td width="80%">
                        <xsl:for-each select="cda:order">
                           <xsl:for-each select="cda:id">
                              <xsl:call-template name="show-id"/>
                           </xsl:for-each>
                           <xsl:for-each select="cda:code">
                              <xsl:text>&#160;</xsl:text>
                              <xsl:call-template name="show-code">
                                 <xsl:with-param name="code" select="."/>
                              </xsl:call-template>
                           </xsl:for-each>
                           <xsl:for-each select="cda:priorityCode">
                              <xsl:text>&#160;</xsl:text>
                              <xsl:call-template name="show-code">
                                 <xsl:with-param name="code" select="."/>
                              </xsl:call-template>
                           </xsl:for-each>
                        </xsl:for-each>
                     </td>
                  </tr>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- informant -->
   <xsl:template name="informant">
      <xsl:if test="cda:informant">
          <table class="header_table" summary="Informant">
            <tbody>
               <xsl:for-each select="cda:informant">
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Informant</xsl:text>
                        </span>
                     </td>
                     <td width="80%">
                        <xsl:if test="cda:assignedEntity">
                           <xsl:call-template name="show-assignedEntity">
                              <xsl:with-param name="asgnEntity" select="cda:assignedEntity"/>
                           </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="cda:relatedEntity">
                           <xsl:call-template name="show-relatedEntity">
                              <xsl:with-param name="relatedEntity" select="cda:relatedEntity"/>
                           </xsl:call-template>
                        </xsl:if>
                     </td>
                  </tr>
                  <xsl:choose>
                     <xsl:when test="cda:assignedEntity/cda:addr | cda:assignedEntity/cda:telecom">
                        <tr>
                           <td bgcolor="#3399ff">
                              <span class="td_label">
                                 <xsl:text>Contact info</xsl:text>
                              </span>
                           </td>
                           <td>
                              <xsl:if test="cda:assignedEntity">
                                 <xsl:call-template name="show-contactInfo">
                                    <xsl:with-param name="contact" select="cda:assignedEntity"/>
                                 </xsl:call-template>
                              </xsl:if>
                           </td>
                        </tr>
                     </xsl:when>
                     <xsl:when test="cda:relatedEntity/cda:addr | cda:relatedEntity/cda:telecom">
                        <tr>
                           <td bgcolor="#3399ff">
                              <span class="td_label">
                                 <xsl:text>Contact info</xsl:text>
                              </span>
                           </td>
                           <td>
                              <xsl:if test="cda:relatedEntity">
                                 <xsl:call-template name="show-contactInfo">
                                    <xsl:with-param name="contact" select="cda:relatedEntity"/>
                                 </xsl:call-template>
                              </xsl:if>
                           </td>
                        </tr>
                     </xsl:when>
                  </xsl:choose>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- informantionRecipient -->
   <xsl:template name="informationRecipient">
      <xsl:if test="cda:informationRecipient">
          <table class="header_table" summary="Information Recipient">
            <tbody>
               <xsl:for-each select="cda:informationRecipient">
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Information recipient:</xsl:text>
                        </span>
                     </td>
                     <td width="80%">
                        <xsl:choose>
                           <xsl:when test="cda:intendedRecipient/cda:informationRecipient/cda:name">
                              <xsl:for-each select="cda:intendedRecipient/cda:informationRecipient">
                                 <xsl:call-template name="show-name">
                                    <xsl:with-param name="name" select="cda:name"/>
                                 </xsl:call-template>
                                 <xsl:if test="position() != last()">
                                    <br/>
                                 </xsl:if>
                              </xsl:for-each>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:for-each select="cda:intendedRecipient">
                                 <xsl:for-each select="cda:id">
                                    <xsl:call-template name="show-id"/>
                                 </xsl:for-each>
                                 <xsl:if test="position() != last()">
                                    <br/>
                                 </xsl:if>
                                 <br/>
                              </xsl:for-each>
                           </xsl:otherwise>
                        </xsl:choose>
                     </td>
                  </tr>
                  <xsl:if test="cda:intendedRecipient/cda:addr | cda:intendedRecipient/cda:telecom">
                     <tr>
                        <td bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Contact info</xsl:text>
                           </span>
                        </td>
                        <td>
                           <xsl:call-template name="show-contactInfo">
                              <xsl:with-param name="contact" select="cda:intendedRecipient"/>
                           </xsl:call-template>
                        </td>
                     </tr>
                  </xsl:if>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- participant -->
   <xsl:template name="participant">
      <xsl:if test="cda:participant">
          <table class="header_table" summary="Paticipant">
            <tbody>
               <xsl:for-each select="cda:participant">
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <xsl:variable name="participtRole">
                           <xsl:call-template name="translateRoleAssoCode">
                              <xsl:with-param name="classCode"
                                 select="cda:associatedEntity/@classCode"/>
                              <xsl:with-param name="code" select="cda:associatedEntity/cda:code"/>
                           </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                           <xsl:when test="$participtRole">
                              <span class="td_label">
                                 <xsl:call-template name="firstCharCaseUp">
                                    <xsl:with-param name="data" select="$participtRole"/>
                                 </xsl:call-template>
                              </span>
                           </xsl:when>
                           <xsl:otherwise>
                              <span class="td_label">
                                 <xsl:text>Participant</xsl:text>
                              </span>
                           </xsl:otherwise>
                        </xsl:choose>
                     </td>
                     <td width="80%">
                        <xsl:if test="cda:functionCode">
                           <xsl:call-template name="show-code">
                              <xsl:with-param name="code" select="cda:functionCode"/>
                           </xsl:call-template>
                        </xsl:if>
                        <xsl:call-template name="show-associatedEntity">
                           <xsl:with-param name="assoEntity" select="cda:associatedEntity"/>
                        </xsl:call-template>
                        <xsl:if test="cda:time">
                           <xsl:if test="cda:time/cda:low">
                              <xsl:text> from </xsl:text>
                              <xsl:call-template name="show-time">
                                 <xsl:with-param name="datetime" select="cda:time/cda:low"/>
                              </xsl:call-template>
                           </xsl:if>
                           <xsl:if test="cda:time/cda:high">
                              <xsl:text> to </xsl:text>
                              <xsl:call-template name="show-time">
                                 <xsl:with-param name="datetime" select="cda:time/cda:high"/>
                              </xsl:call-template>
                           </xsl:if>
                        </xsl:if>
                        <xsl:if test="position() != last()">
                           <br/>
                        </xsl:if>
                     </td>
                  </tr>
                  <xsl:if test="cda:associatedEntity/cda:addr | cda:associatedEntity/cda:telecom">
                     <tr>
                        <td bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Contact info</xsl:text>
                           </span>
                        </td>
                        <td>
                           <xsl:call-template name="show-contactInfo">
                              <xsl:with-param name="contact" select="cda:associatedEntity"/>
                           </xsl:call-template>
                        </td>
                     </tr>
                  </xsl:if>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- recordTarget -->
   <xsl:template name="recordTarget">
       <table class="header_table" summary="Record Target">
         <tbody>
            <xsl:for-each select="/cda:ClinicalDocument/cda:recordTarget/cda:patientRole">
               <xsl:if test="not(cda:id/@nullFlavor)">
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Patient</xsl:text>
                        </span>
                     </td>
                     <td colspan="3">
                        <xsl:call-template name="show-name">
                           <xsl:with-param name="name" select="cda:patient/cda:name"/>
                        </xsl:call-template>
                     </td>
                  </tr>
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Date of birth</xsl:text>
                        </span>
                     </td>
                     <td width="30%">
                        <xsl:call-template name="show-time">
                           <xsl:with-param name="datetime" select="cda:patient/cda:birthTime"/>
                        </xsl:call-template>
                     </td>
                     <td width="15%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Sex</xsl:text>
                        </span>
                     </td>
                     <td>
                        <xsl:for-each select="cda:patient/cda:administrativeGenderCode">
                           <xsl:call-template name="show-gender"/>
                        </xsl:for-each>
                     </td>
                  </tr>
                  <xsl:if test="cda:patient/cda:raceCode | (cda:patient/cda:ethnicGroupCode)">
                     <tr>
                        <td width="20%" bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Race</xsl:text>
                           </span>
                        </td>
                        <td width="30%">
                           <xsl:choose>
                              <xsl:when test="cda:patient/cda:raceCode">
                                 <xsl:for-each select="cda:patient/cda:raceCode">
                                    <xsl:call-template name="show-race-ethnicity"/>
                                 </xsl:for-each>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:text>Information not available</xsl:text>
                              </xsl:otherwise>
                           </xsl:choose>
                        </td>
                        <td width="15%" bgcolor="#3399ff">
                           <span class="td_label">
                              <xsl:text>Ethnicity</xsl:text>
                           </span>
                        </td>
                        <td>
                           <xsl:choose>
                              <xsl:when test="cda:patient/cda:ethnicGroupCode">
                                 <xsl:for-each select="cda:patient/cda:ethnicGroupCode">
                                    <xsl:call-template name="show-race-ethnicity"/>
                                 </xsl:for-each>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:text>Information not available</xsl:text>
                              </xsl:otherwise>
                           </xsl:choose>
                        </td>
                     </tr>
                  </xsl:if>
                  <tr>
                     <td bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Contact info</xsl:text>
                        </span>
                     </td>
                     <td>
                        <xsl:call-template name="show-contactInfo">
                           <xsl:with-param name="contact" select="."/>
                        </xsl:call-template>
                     </td>
                     <td bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Patient IDs</xsl:text>
                        </span>
                     </td>
                     <td>
                        <xsl:for-each select="cda:id">
                           <xsl:call-template name="show-id"/>
                           <br/>
                        </xsl:for-each>
                     </td>
                  </tr>
               </xsl:if>
            </xsl:for-each>
         </tbody>
      </table>
   </xsl:template>
   <!-- relatedDocument -->
   <xsl:template name="relatedDocument">
      <xsl:if test="cda:relatedDocument">
          <table class="header_table" summary="Related Document">
            <tbody>
               <xsl:for-each select="cda:relatedDocument">
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Related document</xsl:text>
                        </span>
                     </td>
                     <td width="80%">
                        <xsl:for-each select="cda:parentDocument">
                           <xsl:for-each select="cda:id">
                              <xsl:call-template name="show-id"/>
                              <br/>
                           </xsl:for-each>
                        </xsl:for-each>
                     </td>
                  </tr>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- authorization (consent) -->
   <xsl:template name="authorization">
      <xsl:if test="cda:authorization">
          <table class="header_table" summary="Authorization">
            <tbody>
               <xsl:for-each select="cda:authorization">
                  <tr>
                     <td width="20%" bgcolor="#3399ff">
                        <span class="td_label">
                           <xsl:text>Consent</xsl:text>
                        </span>
                     </td>
                     <td width="80%">
                        <xsl:choose>
                           <xsl:when test="cda:consent/cda:code">
                              <xsl:call-template name="show-code">
                                 <xsl:with-param name="code" select="cda:consent/cda:code"/>
                              </xsl:call-template>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:call-template name="show-code">
                                 <xsl:with-param name="code" select="cda:consent/cda:statusCode"/>
                              </xsl:call-template>
                           </xsl:otherwise>
                        </xsl:choose>
                        <br/>
                     </td>
                  </tr>
               </xsl:for-each>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- setAndVersion -->
   <xsl:template name="setAndVersion">
      <xsl:if test="cda:setId and cda:versionNumber">
          <table class="header_table" summary="Set and Version">
            <tbody>
               <tr>
                  <td width="20%">
                     <xsl:text>SetId and Version</xsl:text>
                  </td>
                  <td colspan="3">
                     <xsl:text>SetId: </xsl:text>
                     <xsl:call-template name="show-id">
                        <xsl:with-param name="id" select="cda:setId"/>
                     </xsl:call-template>
                     <xsl:text>  Version: </xsl:text>
                     <xsl:value-of select="cda:versionNumber/@value"/>
                  </td>
               </tr>
            </tbody>
         </table>
      </xsl:if>
   </xsl:template>
   <!-- show StructuredBody  -->
   <xsl:template match="cda:component/cda:structuredBody">
      <xsl:for-each select="cda:component/cda:section">
         <xsl:call-template name="section"/>
      </xsl:for-each>
   </xsl:template>
   <!-- show nonXMLBody -->
   <xsl:template match="cda:component/cda:nonXMLBody">
      <xsl:choose>
         <!-- if there is a reference, use that in an IFRAME -->
         <xsl:when test="cda:text/cda:reference">
            <xsl:variable name="source" select="string(cda:text/cda:reference/@value)"/>
            <xsl:variable name="lcSource" select="translate($source, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
            <xsl:variable name="scrubbedSource" select="translate($source, $simple-sanitizer-match, $simple-sanitizer-replace)"/>
            <xsl:message><xsl:value-of select="$source"/>, <xsl:value-of select="$lcSource"/></xsl:message>
            <xsl:choose>
                <xsl:when test="contains($lcSource,'javascript')">
                    <p><xsl:value-of select="$javascript-injection-warning"/> </p>
                    <xsl:message><xsl:value-of select="$javascript-injection-warning"/></xsl:message>
                </xsl:when>
                <xsl:when test="not($source = $scrubbedSource)">
                    <p><xsl:value-of select="$malicious-content-warning"/> </p>
                    <xsl:message><xsl:value-of select="$malicious-content-warning"/></xsl:message>
                </xsl:when>
                <xsl:otherwise>
                    <IFRAME name='nonXMLBody' id='nonXMLBody' WIDTH='80%' HEIGHT='600' src='{$source}'/>
                </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="cda:text/@mediaType=&quot;text/plain&quot;">
            <pre>
               <xsl:value-of select="cda:text/text()"/>
            </pre>
         </xsl:when>
         <xsl:otherwise>
            <CENTER>Cannot display the text</CENTER>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- top level component/section: display title and text,
     and process any nested component/sections
   -->
   <xsl:template name="section">

      <xsl:if test="cda:title">
         <xsl:call-template name="section-title">
            <xsl:with-param name="title" select="cda:title"/>
         </xsl:call-template>
      </xsl:if>

      <!--
         <xsl:call-template name="section-author"/>
      -->
      <xsl:call-template name="section-text"/>
      <xsl:for-each select="cda:component/cda:section">
         <xsl:call-template name="nestedSection"/>
      </xsl:for-each>
   </xsl:template>


   <!-- top level section title -->
   <xsl:template name="section-title">
      <xsl:param name="title"/>
      <div class="sectiontitleheader">
         <xsl:value-of select="$title"/>
      </div>
   </xsl:template>
   <!-- section author -->
   <xsl:template name="section-author">
      <xsl:if test="count(cda:author)&gt;0">
         <div style="margin-left : 2em;">
            <b>
               <xsl:text>Section Author: </xsl:text>
            </b>
            <xsl:for-each select="cda:author/cda:assignedAuthor">
               <xsl:choose>
                  <xsl:when test="cda:assignedPerson/cda:name">
                     <xsl:call-template name="show-name">
                        <xsl:with-param name="name" select="cda:assignedPerson/cda:name"/>
                     </xsl:call-template>
                     <xsl:if test="cda:representedOrganization">
                        <xsl:text>, </xsl:text>
                        <xsl:call-template name="show-name">
                           <xsl:with-param name="name" select="cda:representedOrganization/cda:name"
                           />
                        </xsl:call-template>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="cda:assignedAuthoringDevice/cda:softwareName">
                     <xsl:value-of select="cda:assignedAuthoringDevice/cda:softwareName"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:for-each select="cda:id">
                        <xsl:call-template name="show-id"/>
                        <br/>
                     </xsl:for-each>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
            <br/>
         </div>
      </xsl:if>
   </xsl:template>
   <!-- top-level section Text   -->
   <xsl:template name="section-text">
      <div>
         <xsl:apply-templates select="cda:text"/>
      </div>
   </xsl:template>
   <!-- nested component/section -->
   <!-- nested component/section -->
   <xsl:template name="nestedSection">
      <!--
         <xsl:param name="margin"/>
         <h4 style="margin-left : {$margin}em;">
         <xsl:value-of select="cda:title"/>
         </h4>
         <div style="margin-left : {$margin}em;">
         <xsl:apply-templates select="cda:text"/>
         </div>
      -->
      <xsl:if test="cda:title">
         <xsl:call-template name="section-title">
            <xsl:with-param name="title" select="cda:title"/>
         </xsl:call-template>
      </xsl:if>

      <xsl:apply-templates select="cda:text"/>
      <xsl:for-each select="cda:component/cda:section">
         <xsl:call-template name="nestedSection"/>
      </xsl:for-each>
   </xsl:template>

   <!--   Content w/ deleted text is hidden -->
   <xsl:template match="cda:content[@revised='delete']"/>
   <!--   content  -->
   <xsl:template match="cda:content">
      <span>
         <xsl:choose>
            <xsl:when test="@styleCode">
               <xsl:call-template name="processStyleCode">
                  <xsl:with-param name="code" select="@styleCode"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
      </span>
   </xsl:template>
   <!-- line break -->
   <xsl:template match="cda:br">
      <xsl:element name="br">
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
   <!--   list  -->
   <xsl:template match="cda:list">
      <xsl:choose>
         <xsl:when test="@styleCode">
            <xsl:choose>
               <xsl:when test="@styleCode='Disc'">
                  <xsl:element name="ul">
                     <xsl:attribute name="style">list-style-type: disc;</xsl:attribute>
                     <xsl:for-each select="cda:item">
                        <li>
                        <xsl:choose>
                           <xsl:when test="@styleCode">
                              <xsl:call-template name="processStyleCode">
                                 <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                 <xsl:with-param name="code" select="@styleCode"/>
                              </xsl:call-template>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:apply-templates/>
                           </xsl:otherwise>
                        </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:when>

               <xsl:when test="@styleCode='Circle'">
                  <xsl:element name="ul">
                     <xsl:attribute name="style">list-style-type: circle;</xsl:attribute>
                     <xsl:for-each select="cda:item">
                        <li>
                           <xsl:choose>
                              <xsl:when test="@styleCode">
                                 <xsl:call-template name="processStyleCode">
                                    <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                    <xsl:with-param name="code" select="@styleCode"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:apply-templates/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:when>

               <xsl:when test="@styleCode='Square'">
                  <xsl:element name="ul">
                     <xsl:attribute name="style">list-style-type: square;</xsl:attribute>
                     <xsl:for-each select="cda:item">
                        <li>
                           <xsl:choose>
                              <xsl:when test="@styleCode">
                                 <xsl:call-template name="processStyleCode">
                                    <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                    <xsl:with-param name="code" select="@styleCode"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:apply-templates/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:when>

               <xsl:otherwise>
                  <ul>
                     <xsl:for-each select="cda:item">
                        <li>
                           <xsl:choose>
                              <xsl:when test="@styleCode">
                                 <xsl:call-template name="processStyleCode">
                                    <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                    <xsl:with-param name="code" select="@styleCode"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:apply-templates/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </ul>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <ul>
               <xsl:for-each select="cda:item">
                  <li>
                     <xsl:apply-templates/>
                  </li>
               </xsl:for-each>
            </ul>
         </xsl:otherwise>
      </xsl:choose>







   </xsl:template>
   <xsl:template match="cda:list[@listType='ordered']">
      <xsl:choose>
         <xsl:when test="@styleCode">
            <xsl:choose>
               <xsl:when test="@styleCode='LittleRoman'">
                  <xsl:element name="ol">
                     <xsl:attribute name="style">list-style-type: lower-roman;</xsl:attribute>
                     <xsl:for-each select="cda:item">
                        <li>
                           <xsl:choose>
                              <xsl:when test="@styleCode">
                                 <xsl:call-template name="processStyleCode">
                                    <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                    <xsl:with-param name="code" select="@styleCode"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:apply-templates/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:when>

               <xsl:when test="@styleCode='BigRoman'">
                  <xsl:element name="ol">
                     <xsl:attribute name="style">list-style-type: upper-roman;</xsl:attribute>
                     <xsl:for-each select="cda:item">
                        <li>
                           <xsl:choose>
                              <xsl:when test="@styleCode">
                                 <xsl:call-template name="processStyleCode">
                                    <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                    <xsl:with-param name="code" select="@styleCode"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:apply-templates/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:when>

               <xsl:when test="@styleCode='LittleAlpha'">
                  <xsl:element name="ol">
                     <xsl:attribute name="style">list-style-type: lower-alpha;</xsl:attribute>
                     <xsl:for-each select="cda:item">
                        <li>
                           <xsl:choose>
                              <xsl:when test="@styleCode">
                                 <xsl:call-template name="processStyleCode">
                                    <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                    <xsl:with-param name="code" select="@styleCode"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:apply-templates/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:when>

               <xsl:when test="@styleCode='BigAlpha'">
                  <xsl:element name="ol">
                     <xsl:attribute name="style">list-style-type: upper-alpha;</xsl:attribute>
                     <xsl:for-each select="cda:item">
                        <li>
                           <xsl:choose>
                              <xsl:when test="@styleCode">
                                 <xsl:call-template name="processStyleCode">
                                    <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                    <xsl:with-param name="code" select="@styleCode"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:apply-templates/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </xsl:element>
               </xsl:when>

               <xsl:otherwise>
                  <ol>
                     <xsl:for-each select="cda:item">
                        <li>
                           <xsl:choose>
                              <xsl:when test="@styleCode">
                                 <xsl:call-template name="processStyleCode">
                                    <xsl:with-param name="initialCssClasses"></xsl:with-param>
                                    <xsl:with-param name="code" select="@styleCode"/>
                                 </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:apply-templates/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </li>
                     </xsl:for-each>
                  </ol>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <ol>
               <xsl:for-each select="cda:item">
                  <li>
                     <xsl:choose>
                        <xsl:when test="@styleCode">
                           <xsl:call-template name="processStyleCode">
                              <xsl:with-param name="initialCssClasses"></xsl:with-param>
                              <xsl:with-param name="code" select="@styleCode"/>
                           </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:apply-templates/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </li>
               </xsl:for-each>
            </ol>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--   caption  -->
   <xsl:template match="cda:caption"/>
   <!--  Tables   -->

  <!--
   		Create a list of valid CDA R2 HTML attributes
   		and use the list plus the output-attrs template
   		to copy over only the valid attributes.
   -->
    <xsl:variable name="table-elem-attrs">
        <in:tableElems>
            <in:elem name="table">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="summary"/>
                <in:attr name="width"/>
                <in:attr name="border"/>
                <in:attr name="frame"/>
                <in:attr name="rules"/>
                <in:attr name="cellspacing"/>
                <in:attr name="cellpadding"/>
            </in:elem>
            <in:elem name="thead">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="align"/>
                <in:attr name="char"/>
                <in:attr name="charoff"/>
                <in:attr name="valign"/>
            </in:elem>
            <in:elem name="tfoot">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="align"/>
                <in:attr name="char"/>
                <in:attr name="charoff"/>
                <in:attr name="valign"/>
            </in:elem>
            <in:elem name="tbody">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="align"/>
                <in:attr name="char"/>
                <in:attr name="charoff"/>
                <in:attr name="valign"/>
            </in:elem>
            <in:elem name="colgroup">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="span"/>
                <in:attr name="width"/>
                <in:attr name="align"/>
                <in:attr name="char"/>
                <in:attr name="charoff"/>
                <in:attr name="valign"/>
            </in:elem>
            <in:elem name="col">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="span"/>
                <in:attr name="width"/>
                <in:attr name="align"/>
                <in:attr name="char"/>
                <in:attr name="charoff"/>
                <in:attr name="valign"/>
            </in:elem>
            <in:elem name="tr">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="align"/>
                <in:attr name="char"/>
                <in:attr name="charoff"/>
                <in:attr name="valign"/>
            </in:elem>
            <in:elem name="th">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="abbr"/>
                <in:attr name="axis"/>
                <in:attr name="headers"/>
                <in:attr name="scope"/>
                <in:attr name="rowspan"/>
                <in:attr name="colspan"/>
                <in:attr name="align"/>
                <in:attr name="char"/>
                <in:attr name="charoff"/>
                <in:attr name="valign"/>
            </in:elem>
            <in:elem name="td">
                <in:attr name="ID"/>
                <in:attr name="language"/>
                <in:attr name="styleCode"/>
                <in:attr name="abbr"/>
                <in:attr name="axis"/>
                <in:attr name="headers"/>
                <in:attr name="scope"/>
                <in:attr name="rowspan"/>
                <in:attr name="colspan"/>
                <in:attr name="align"/>
                <in:attr name="char"/>
                <in:attr name="charoff"/>
                <in:attr name="valign"/>
            </in:elem>
        </in:tableElems>
    </xsl:variable>

    <xsl:template name="output-attrs">
        <xsl:variable name="elem-name" select="local-name(.)"/>
        <xsl:for-each select="@*">
            <xsl:variable name="attr-name" select="local-name(.)"/>
            <xsl:variable name="source" select="."/>
            <xsl:variable name="lcSource" select="translate($source, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
            <xsl:variable name="scrubbedSource" select="translate($source, $simple-sanitizer-match, $simple-sanitizer-replace)"/>
            <xsl:choose>
                <xsl:when test="contains($lcSource,'javascript')">
                    <p><xsl:value-of select="$javascript-injection-warning"/></p>
                    <xsl:message terminate="yes"><xsl:value-of select="$javascript-injection-warning"/></xsl:message>
                </xsl:when>
                <xsl:when test="not(document('')/xsl:stylesheet/xsl:variable[@name='table-elem-attrs']/in:tableElems/in:elem[@name=$elem-name]/in:attr[@name=$attr-name])">
                    <xsl:message><xsl:value-of select="$attr-name"/> is not legal in <xsl:value-of select="$elem-name"/></xsl:message>
                </xsl:when>
                <xsl:when test="not($source = $scrubbedSource)">
                    <p><xsl:value-of select="$malicious-content-warning"/> </p>
                    <xsl:message><xsl:value-of select="$malicious-content-warning"/></xsl:message>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cda:table">
                   <xsl:choose>
                       <xsl:when test="cda:caption">
                               <xsl:element name="table">
                                   <xsl:attribute name="class">generictable</xsl:attribute>
                                   <xsl:attribute name="summary"><xsl:value-of select="cda:caption"/></xsl:attribute>
                                   <xsl:element name="caption">
                                       <xsl:attribute name="class">tableCaption</xsl:attribute>
                                       <xsl:value-of select="cda:caption"/>
                                   </xsl:element>
                                   <xsl:call-template name="output-attrs"/>
                                   <xsl:apply-templates/>
                               </xsl:element>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:element name="table">
                               <xsl:attribute name="class">generictable</xsl:attribute>
                               <xsl:attribute name="summary">no summary</xsl:attribute>
                               <xsl:call-template name="output-attrs"/>
                               <xsl:apply-templates/>
                           </xsl:element>
                       </xsl:otherwise>
                   </xsl:choose>
               <div class="horizontalspacer"/>
   </xsl:template>

   <xsl:template match="cda:thead">
      <thead>
         <xsl:call-template name="output-attrs"/>
         <xsl:apply-templates/>
      </thead>
   </xsl:template>
   <xsl:template match="cda:tfoot">
      <tfoot>
         <xsl:call-template name="output-attrs"/>
         <xsl:apply-templates/>
      </tfoot>
   </xsl:template>
   <xsl:template match="cda:tbody">
      <tbody>
         <xsl:call-template name="output-attrs"/>
         <xsl:apply-templates/>
      </tbody>
   </xsl:template>
   <xsl:template match="cda:colgroup">
      <colgroup>
         <xsl:call-template name="output-attrs"/>
         <xsl:apply-templates/>
      </colgroup>
   </xsl:template>
   <xsl:template match="cda:col">
      <col>
         <xsl:call-template name="output-attrs"/>
         <xsl:apply-templates/>
      </col>
   </xsl:template>
   <xsl:template match="cda:tr">
      <tr class="narr_tr">
         <xsl:call-template name="output-attrs"/>
         <xsl:apply-templates/>
      </tr>
   </xsl:template>
   <xsl:template match="cda:th">
      <th class="borderedcolumnheadings">
         <xsl:choose>
            <xsl:when test="@styleCode">
               <xsl:call-template name="processStyleCode">
                  <!-- <xsl:with-param name="initialCssClasses">borderedcolumnheadings</xsl:with-param> -->
                  <xsl:with-param name="code" select="@styleCode"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
      </th>
   </xsl:template>

   <xsl:template match="cda:td">
      <td class="borderedcolumnheadings">
         <xsl:choose>
            <xsl:when test="@styleCode">
               <xsl:call-template name="processStyleCode">
                  <!-- <xsl:with-param name="initialCssClasses">borderedcolumnheadings</xsl:with-param> -->
                  <xsl:with-param name="code" select="@styleCode"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
      </td>
   </xsl:template>

   <xsl:template match="cda:renderMultiMedia">
      <xsl:variable name="imageRef" select="@referencedObject"/>
      <xsl:variable name="mediaType">
          <xsl:choose>
              <xsl:when test="//cda:observationMedia[@ID=$imageRef]/cda:value/@mediaType">
                  <xsl:value-of select="//cda:observationMedia[@ID=$imageRef]/cda:value/@mediaType"/>
              </xsl:when>
              <xsl:when test="not(//cda:observationMedia[@ID=$imageRef]/cda:value/@mediaType)">text/plain</xsl:when>
              <xsl:otherwise>text/plain</xsl:otherwise>
          </xsl:choose>
      </xsl:variable>
      <xsl:variable name="image-uri" select="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value"/>
       
      <xsl:choose>
         <!--
         <xsl:when
            test="//cda:observationMedia[@ID=$imageRef]/cda:value[@mediaType='application/pdf']">
               <xsl:if test="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value">
                  <div class="horizontalspacer"/>
                  <xsl:element name="embed">
                     <xsl:attribute name="src">
                        <xsl:value-of
                           select="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value"
                        />
                     </xsl:attribute>
                     <xsl:attribute name="width">
                        <xsl:value-of select="$screenPageWidth"/>
                     </xsl:attribute>
                  </xsl:element>
               </xsl:if>
         </xsl:when>
         -->

         <xsl:when test="$limit-external-images='1' and contains($image-uri,':')">
            <p>WARNING: non-local image found <xsl:value-of select="$image-uri"/></p>
            <xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/></xsl:message>
         </xsl:when>
         <xsl:when test="$limit-external-images='1' and starts-with($image-uri,'\\')">
            <p>WARNING: non-local image found <xsl:value-of select="$image-uri"/></p>
            <xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/></xsl:message>
         </xsl:when>
         <xsl:when
            test="$mediaType='application/pdf'">
            <div class="horizontalspacer"/>
            <xsl:if test="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value">
               <div class="horizontalspacer"/>
               <xsl:element name="A">
                  <xsl:attribute name="href"><xsl:value-of select="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value"/></xsl:attribute>
                  <xsl:value-of select="cda:caption"/>
               </xsl:element>
            </xsl:if>
         </xsl:when>
         
         <xsl:when
             test="$mediaType='text/rtf'">
            <div class="horizontalspacer"/>
               <xsl:if test="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value">
                  <div class="horizontalspacer"/>
                  <xsl:element name="A">
                     <xsl:attribute name="href"><xsl:value-of select="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value"/></xsl:attribute>
                     <xsl:value-of select="cda:caption"/>
                  </xsl:element>
               </xsl:if>
         </xsl:when>

          <xsl:when
              test="$mediaType='text/plain'">
              <div class="horizontalspacer"/>
              <xsl:if test="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value">
                  <div class="horizontalspacer"/>
                  <xsl:element name="A">
                      <xsl:attribute name="href"><xsl:value-of select="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value"/></xsl:attribute>
                      <xsl:value-of select="cda:caption"/>
                  </xsl:element>
              </xsl:if>
          </xsl:when>
          
         <xsl:otherwise>
            <!-- Here is where the direct MultiMedia image referencing goes -->
            <xsl:if
                test="$mediaType='image/gif' or $mediaType='image/jpeg' or $mediaType='image/png'">
                  <xsl:if
                     test="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value">
                     <div class="horizontalspacer"/>
                      <table summary="image">
                        <tr>
                           <td align="center">
                              <xsl:element name="img">
                           <xsl:attribute name="src">
                              <xsl:value-of
                                 select="//cda:observationMedia[@ID=$imageRef]/cda:value/cda:reference/@value"
                              />
                           </xsl:attribute>
                           <xsl:attribute name="style">padding-bottom:0.5em;</xsl:attribute>
                           <xsl:if test="cda:caption">
                              <xsl:attribute name="alt">
                                 <xsl:value-of select="cda:caption"/>
                              </xsl:attribute>
                           </xsl:if>
                        </xsl:element>
                           </td>
                        </tr>
                        <xsl:if test="cda:caption">
                           <tr>
                              <td align="center"><xsl:value-of select="cda:caption"/></td>
                           </tr>
                        </xsl:if>
                     </table>
                  </xsl:if>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
      <div class="horizontalspacer"/>
   </xsl:template>

    <xsl:template name="processStyleCode">
        <xsl:param name="code"/>
        <xsl:param name="initialCssClasses"/>

        <xsl:choose>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline xFixed</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic underline</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic xFixed</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold italic</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline xFixed</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold underline</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold xFixed</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($code, 'Bold') and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> bold</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline xFixed</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic underline</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic xFixed</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and contains($code, 'Italic') and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> italic</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline xFixed</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and contains($code, 'Underline') and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> underline</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and contains($code, 'xFixed') and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/> xFixed</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and contains($code, 'xFgColour') and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processColourStyleCode">
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and contains($code, 'xBgColour') and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processColourStyleCode">
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processFontSizePx">
                        <xsl:with-param name="type" select="px"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and contains($code, 'xFontSizePx') and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processFontSizePx">
                    <xsl:with-param name="type" select="px"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:call-template name="processFontSizeEm">
                        <xsl:with-param name="type" select="em"/>
                        <xsl:with-param name="code" select="$code"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and contains($code, 'xFontSizeEm') and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:call-template name="processFontSizeEm">
                    <xsl:with-param name="type" select="em"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and contains($code, 'xPre')">
                <xsl:element name="pre">
                    <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not (contains($code, 'Bold')) and not (contains($code, 'Italic')) and not (contains($code, 'Underline')) and not (contains($code, 'xFixed')) and not (contains($code, 'xFgColour')) and not (contains($code, 'xBgColour')) and not (contains($code, 'xFontSizePx')) and not (contains($code, 'xFontSizeEm')) and not (contains($code, 'xPre'))">
                <xsl:attribute name="class"><xsl:value-of select="$initialCssClasses"/></xsl:attribute>
                <xsl:apply-templates/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

   <xsl:template match="cda:paragraph">
      <p class="paragraph">
         <xsl:choose>
            <xsl:when test="@styleCode">
               <xsl:call-template name="processStyleCode">
                  <xsl:with-param name="code" select="@styleCode"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
      </p>
   </xsl:template>


   <!--    Superscript or Subscript   -->
   <xsl:template match="cda:sup">
      <xsl:element name="sup">
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="cda:sub">
      <xsl:element name="sub">
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
   <!-- show-signature -->
   <xsl:template name="show-sig">
      <xsl:param name="sig"/>
      <xsl:choose>
         <xsl:when test="$sig/@code =&apos;S&apos;">
            <xsl:text>signed</xsl:text>
         </xsl:when>
         <xsl:when test="$sig/@code=&apos;I&apos;">
            <xsl:text>intended</xsl:text>
         </xsl:when>
         <xsl:when test="$sig/@code=&apos;X&apos;">
            <xsl:text>signature required</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <!--  show-id -->
   <xsl:template name="show-id">
      <xsl:param name="id"/>
      <xsl:choose>
         <xsl:when test="not($id)">
            <xsl:if test="not(@nullFlavor)">
               <xsl:if test="@extension">
                  <xsl:value-of select="@extension"/>
               </xsl:if>
               <xsl:text> </xsl:text>
               <xsl:value-of select="@root"/>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="not($id/@nullFlavor)">
               <xsl:if test="$id/@extension">
                  <xsl:value-of select="$id/@extension"/>
               </xsl:if>
               <xsl:text> </xsl:text>
               <xsl:value-of select="$id/@root"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- show-name  -->
   <xsl:template name="show-name">
      <xsl:param name="name"/>
      <xsl:choose>
         <xsl:when test="$name/cda:family">
            <xsl:if test="$name/cda:prefix">
               <xsl:value-of select="$name/cda:prefix"/>
               <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="$name/cda:given"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$name/cda:family"/>
            <xsl:if test="$name/cda:suffix">
               <xsl:text>, </xsl:text>
               <xsl:value-of select="$name/cda:suffix"/>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$name"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- show-patient-name  -->
   <xsl:template name="show-patient-name">
      <xsl:param name="name"/>
      <xsl:choose>
         <xsl:when test="$name/cda:family">
            <xsl:if test="$name/cda:prefix">
               <xsl:value-of select="$name/cda:prefix"/>
               <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="$name/cda:given"/>
            <xsl:text> </xsl:text>
            <xsl:call-template name="caseUp">
               <xsl:with-param name="data">
                  <xsl:value-of select="$name/cda:family"/>
               </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$name/cda:suffix">
               <xsl:text>, </xsl:text>
               <xsl:value-of select="$name/cda:suffix"/>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$name"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- show-gender  -->
   <xsl:template name="show-gender">
      <xsl:choose>
         <xsl:when test="@code   = &apos;M&apos;">
            <xsl:text>Male</xsl:text>
         </xsl:when>
         <xsl:when test="@code  = &apos;F&apos;">
            <xsl:text>Female</xsl:text>
         </xsl:when>
         <xsl:when test="@code  = &apos;U&apos;">
            <xsl:text>Undifferentiated</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <!-- show-race-ethnicity  -->
   <xsl:template name="show-race-ethnicity">
      <xsl:choose>
         <xsl:when test="@displayName">
            <xsl:value-of select="@displayName"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="@code"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- show-contactInfo -->
   <xsl:template name="show-contactInfo">
      <xsl:param name="contact"/>
      <xsl:call-template name="show-address">
         <xsl:with-param name="address" select="$contact/cda:addr"/>
      </xsl:call-template>
      <xsl:call-template name="show-telecom">
         <xsl:with-param name="telecom" select="$contact/cda:telecom"/>
      </xsl:call-template>
   </xsl:template>
   <!-- show-address -->
   <xsl:template name="show-address">
      <xsl:param name="address"/>
      <xsl:if test="$address">
         <xsl:for-each select="$address/cda:streetAddressLine">
            <xsl:value-of select="."/>
            <xsl:text>, </xsl:text>
         </xsl:for-each>
         <xsl:if test="$address/cda:streetName">
            <xsl:value-of select="$address/cda:streetName"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$address/cda:houseNumber"/>
            <xsl:text>, </xsl:text>
         </xsl:if>
         <xsl:if test="string-length($address/cda:city)>0">
            <xsl:value-of select="$address/cda:city"/>
         </xsl:if>
         <xsl:if test="string-length($address/cda:state)>0">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$address/cda:state"/>
         </xsl:if>
         <xsl:if test="string-length($address/cda:postalCode)>0">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$address/cda:postalCode"/>
         </xsl:if>
         <xsl:if test="string-length($address/cda:country)>0">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$address/cda:country"/>
         </xsl:if>
      </xsl:if>
   </xsl:template>
   <!-- show-telecom -->
   <xsl:template name="show-telecom">
      <xsl:param name="telecom"/>
      <xsl:if test="$telecom">
         <xsl:choose>
            <xsl:when test="contains($telecom/@value, ':')">
               <xsl:variable name="value" select="substring-after($telecom/@value, ':')"/>
               <xsl:if test="$value">
                  <xsl:value-of select="$value"/>
               </xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$telecom/@value"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <!-- show-recipientType -->
   <xsl:template name="show-recipientType">
      <xsl:param name="typeCode"/>
      <xsl:choose>
         <xsl:when test="$typeCode='PRCP'">Primary Recipient:</xsl:when>
         <xsl:when test="$typeCode='TRC'">Secondary Recipient:</xsl:when>
         <xsl:otherwise>Recipient:</xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Convert Telecom URL to display text -->
   <xsl:template name="translateTelecomCode">
      <xsl:param name="code"/>
      <!--xsl:value-of select="document('voc.xml')/systems/system[@root=$code/@codeSystem]/code[@value=$code/@code]/@displayName"/-->
      <!--xsl:value-of select="document('codes.xml')/*/code[@code=$code]/@display"/-->
      <xsl:choose>
         <!-- lookup table Telecom URI -->
         <xsl:when test="$code='tel'">
            <xsl:text>Tel</xsl:text>
         </xsl:when>
         <xsl:when test="$code='fax'">
            <xsl:text>Fax</xsl:text>
         </xsl:when>
         <xsl:when test="$code='http'">
            <xsl:text>Web</xsl:text>
         </xsl:when>
         <xsl:when test="$code='mailto'">
            <xsl:text>Mail</xsl:text>
         </xsl:when>
         <xsl:when test="$code='H'">
            <xsl:text>Home</xsl:text>
         </xsl:when>
         <xsl:when test="$code='HV'">
            <xsl:text>Vacation Home</xsl:text>
         </xsl:when>
         <xsl:when test="$code='HP'">
            <xsl:text>Pirmary Home</xsl:text>
         </xsl:when>
         <xsl:when test="$code='WP'">
            <xsl:text>Work Place</xsl:text>
         </xsl:when>
         <xsl:when test="$code='PUB'">
            <xsl:text>Pub</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>{$code='</xsl:text>
            <xsl:value-of select="$code"/>
            <xsl:text>'?}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- convert RoleClassAssociative code to display text -->
   <xsl:template name="translateRoleAssoCode">
      <xsl:param name="classCode"/>
      <xsl:param name="code"/>
      <xsl:choose>
         <xsl:when test="$classCode='AFFL'">
            <xsl:text>affiliate</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='AGNT'">
            <xsl:text>agent</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='ASSIGNED'">
            <xsl:text>assigned entity</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='COMPAR'">
            <xsl:text>commissioning party</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='CON'">
            <xsl:text>contact</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='ECON'">
            <xsl:text>emergency contact</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='NOK'">
            <xsl:text>next of kin</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='SGNOFF'">
            <xsl:text>signing authority</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='GUARD'">
            <xsl:text>guardian</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='GUAR'">
            <xsl:text>guardian</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='CIT'">
            <xsl:text>citizen</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='COVPTY'">
            <xsl:text>covered party</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='PRS'">
            <xsl:text>personal relationship</xsl:text>
         </xsl:when>
         <xsl:when test="$classCode='CAREGIVER'">
            <xsl:text>care giver</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>{$classCode='</xsl:text>
            <xsl:value-of select="$classCode"/>
            <xsl:text>'?}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="($code/@code) and ($code/@codeSystem='2.16.840.1.113883.5.111')">
         <xsl:text> </xsl:text>
         <xsl:choose>
            <xsl:when test="$code/@code='FTH'">
               <xsl:text>(Father)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MTH'">
               <xsl:text>(Mother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NPRN'">
               <xsl:text>(Natural parent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='STPPRN'">
               <xsl:text>(Step parent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SONC'">
               <xsl:text>(Son)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='DAUC'">
               <xsl:text>(Daughter)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='CHILD'">
               <xsl:text>(Child)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='EXT'">
               <xsl:text>(Extended family member)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NBOR'">
               <xsl:text>(Neighbor)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SIGOTHR'">
               <xsl:text>(Significant other)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>{$code/@code='</xsl:text>
               <xsl:value-of select="$code/@code"/>
               <xsl:text>'?}</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <!-- show time -->
   <xsl:template name="show-time">
      <xsl:param name="datetime"/>
      <xsl:choose>
         <xsl:when test="not($datetime)">
            <xsl:call-template name="formatDateTime">
               <xsl:with-param name="date" select="@value"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="formatDateTime">
               <xsl:with-param name="date" select="$datetime/@value"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- paticipant facility and date -->
   <xsl:template name="facilityAndDates">
      <table class="header_table" summary="Facility and Dates">
         <tbody>
            <!-- facility id -->
            <tr>
               <td width="20%" bgcolor="#3399ff">
                  <span class="td_label">
                     <xsl:text>Facility ID</xsl:text>
                  </span>
               </td>
               <td colspan="3">
                  <xsl:choose>
                     <xsl:when
                        test="count(/cda:ClinicalDocument/cda:participant
                                      [@typeCode='LOC'][@contextControlCode='OP']
                                      /cda:associatedEntity[@classCode='SDLOC']/cda:id)&gt;0">
                        <!-- change context node -->
                        <xsl:for-each
                           select="/cda:ClinicalDocument/cda:participant
                                      [@typeCode='LOC'][@contextControlCode='OP']
                                      /cda:associatedEntity[@classCode='SDLOC']/cda:id">
                           <xsl:call-template name="show-id"/>
                           <!-- change context node again, for the code -->
                           <xsl:for-each select="../cda:code">
                              <xsl:text> (</xsl:text>
                              <xsl:call-template name="show-code">
                                 <xsl:with-param name="code" select="."/>
                              </xsl:call-template>
                              <xsl:text>)</xsl:text>
                           </xsl:for-each>
                        </xsl:for-each>
                     </xsl:when>
                     <xsl:otherwise> Not available </xsl:otherwise>
                  </xsl:choose>
               </td>
            </tr>
            <!-- Period reported -->
            <tr>
               <td width="20%" bgcolor="#3399ff">
                  <span class="td_label">
                     <xsl:text>First day of period reported</xsl:text>
                  </span>
               </td>
               <td colspan="3">
                  <xsl:call-template name="show-time">
                     <xsl:with-param name="datetime"
                        select="/cda:ClinicalDocument/cda:documentationOf
                                      /cda:serviceEvent/cda:effectiveTime/cda:low"
                     />
                  </xsl:call-template>
               </td>
            </tr>
            <tr>
               <td width="20%" bgcolor="#3399ff">
                  <span class="td_label">
                     <xsl:text>Last day of period reported</xsl:text>
                  </span>
               </td>
               <td colspan="3">
                  <xsl:call-template name="show-time">
                     <xsl:with-param name="datetime"
                        select="/cda:ClinicalDocument/cda:documentationOf
                                      /cda:serviceEvent/cda:effectiveTime/cda:high"
                     />
                  </xsl:call-template>
               </td>
            </tr>
         </tbody>
      </table>
   </xsl:template>
   <!-- show assignedEntity -->
   <xsl:template name="show-assignedEntity">
      <xsl:param name="asgnEntity"/>
      <xsl:choose>
         <xsl:when test="$asgnEntity/cda:assignedPerson/cda:name">
            <xsl:call-template name="show-name">
               <xsl:with-param name="name" select="$asgnEntity/cda:assignedPerson/cda:name"/>
            </xsl:call-template>
            <xsl:if test="$asgnEntity/cda:representedOrganization/cda:name">
               <xsl:text> of </xsl:text>
               <xsl:value-of select="$asgnEntity/cda:representedOrganization/cda:name"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="$asgnEntity/cda:representedOrganization">
            <xsl:value-of select="$asgnEntity/cda:representedOrganization/cda:name"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="$asgnEntity/cda:id">
               <xsl:call-template name="show-id"/>
               <xsl:choose>
                  <xsl:when test="position()!=last()">
                     <xsl:text>, </xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <br/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- show relatedEntity -->
   <xsl:template name="show-relatedEntity">
      <xsl:param name="relatedEntity"/>
      <xsl:choose>
         <xsl:when test="$relatedEntity/cda:relatedPerson/cda:name">
            <xsl:call-template name="show-name">
               <xsl:with-param name="name" select="$relatedEntity/cda:relatedPerson/cda:name"/>
            </xsl:call-template>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <!-- show associatedEntity -->
   <xsl:template name="show-associatedEntity">
      <xsl:param name="assoEntity"/>
      <xsl:choose>
         <xsl:when test="$assoEntity/cda:associatedPerson">
            <xsl:for-each select="$assoEntity/cda:associatedPerson/cda:name">
               <xsl:call-template name="show-name">
                  <xsl:with-param name="name" select="."/>
               </xsl:call-template>
               <br/>
            </xsl:for-each>
         </xsl:when>
         <xsl:when test="$assoEntity/cda:scopingOrganization">
            <xsl:for-each select="$assoEntity/cda:scopingOrganization">
               <xsl:if test="cda:name">
                  <xsl:call-template name="show-name">
                     <xsl:with-param name="name" select="cda:name"/>
                  </xsl:call-template>
                  <br/>
               </xsl:if>
               <xsl:if test="cda:standardIndustryClassCode">
                  <xsl:value-of select="cda:standardIndustryClassCode/@displayName"/>
                  <xsl:text> code:</xsl:text>
                  <xsl:value-of select="cda:standardIndustryClassCode/@code"/>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <xsl:when test="$assoEntity/cda:code">
            <xsl:call-template name="show-code">
               <xsl:with-param name="code" select="$assoEntity/cda:code"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="$assoEntity/cda:id">
            <xsl:value-of select="$assoEntity/cda:id/@extension"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$assoEntity/cda:id/@root"/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <!-- show code 
    if originalText present, return it, otherwise, check and return attribute: display name
    -->
   <xsl:template name="show-code">
      <xsl:param name="code"/>
      <xsl:variable name="this-codeSystem">
         <xsl:value-of select="$code/@codeSystem"/>
      </xsl:variable>
      <xsl:variable name="this-code">
         <xsl:value-of select="$code/@code"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$code/cda:originalText">
            <xsl:value-of select="$code/cda:originalText"/>
         </xsl:when>
         <xsl:when test="$code/@displayName">
            <xsl:value-of select="$code/@displayName"/>
         </xsl:when>
         <!--
      <xsl:when test="$the-valuesets/*/voc:system[@root=$this-codeSystem]/voc:code[@value=$this-code]/@displayName">
        <xsl:value-of select="$the-valuesets/*/voc:system[@root=$this-codeSystem]/voc:code[@value=$this-code]/@displayName"/>
      </xsl:when>
      -->
         <xsl:otherwise>
            <xsl:value-of select="$this-code"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- show classCode -->
   <xsl:template name="show-actClassCode">
      <xsl:param name="clsCode"/>
      <xsl:choose>
         <xsl:when test=" $clsCode = 'ACT' ">
            <xsl:text>healthcare service</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'ACCM' ">
            <xsl:text>accommodation</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'ACCT' ">
            <xsl:text>account</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'ACSN' ">
            <xsl:text>accession</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'ADJUD' ">
            <xsl:text>financial adjudication</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'CONS' ">
            <xsl:text>consent</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'CONTREG' ">
            <xsl:text>container registration</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'CTTEVENT' ">
            <xsl:text>clinical trial timepoint event</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'DISPACT' ">
            <xsl:text>disciplinary action</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'ENC' ">
            <xsl:text>encounter</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'INC' ">
            <xsl:text>incident</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'INFRM' ">
            <xsl:text>inform</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'INVE' ">
            <xsl:text>invoice element</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'LIST' ">
            <xsl:text>working list</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'MPROT' ">
            <xsl:text>monitoring program</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'PCPR' ">
            <xsl:text>care provision</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'PROC' ">
            <xsl:text>procedure</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'REG' ">
            <xsl:text>registration</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'REV' ">
            <xsl:text>review</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'SBADM' ">
            <xsl:text>substance administration</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'SPCTRT' ">
            <xsl:text>speciment treatment</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'SUBST' ">
            <xsl:text>substitution</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'TRNS' ">
            <xsl:text>transportation</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'VERIF' ">
            <xsl:text>verification</xsl:text>
         </xsl:when>
         <xsl:when test=" $clsCode = 'XACT' ">
            <xsl:text>financial transaction</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <!-- show participationType -->
   <xsl:template name="show-participationType">
      <xsl:param name="ptype"/>
      <xsl:choose>
         <xsl:when test=" $ptype='PPRF' ">
            <xsl:text>primary performer</xsl:text>
         </xsl:when>
         <xsl:when test=" $ptype='PRF' ">
            <xsl:text>performer</xsl:text>
         </xsl:when>
         <xsl:when test=" $ptype='VRF' ">
            <xsl:text>verifier</xsl:text>
         </xsl:when>
         <xsl:when test=" $ptype='SPRF' ">
            <xsl:text>secondary performer</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <!-- show participationFunction -->
   <xsl:template name="show-participationFunction">
      <xsl:param name="pFunction"/>
      <xsl:choose>
         <!-- From the HL7 v3 ParticipationFunction code system -->
         <xsl:when test=" $pFunction = 'ADMPHYS' ">
            <xsl:text>(admitting physician)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'ANEST' ">
            <xsl:text>(anesthesist)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'ANRS' ">
            <xsl:text>(anesthesia nurse)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'ATTPHYS' ">
            <xsl:text>(attending physician)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'DISPHYS' ">
            <xsl:text>(discharging physician)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'FASST' ">
            <xsl:text>(first assistant surgeon)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'MDWF' ">
            <xsl:text>(midwife)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'NASST' ">
            <xsl:text>(nurse assistant)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'PCP' ">
            <xsl:text>(primary care physician)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'PRISURG' ">
            <xsl:text>(primary surgeon)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'RNDPHYS' ">
            <xsl:text>(rounding physician)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'SASST' ">
            <xsl:text>(second assistant surgeon)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'SNRS' ">
            <xsl:text>(scrub nurse)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'TASST' ">
            <xsl:text>(third assistant)</xsl:text>
         </xsl:when>
         <!-- From the HL7 v2 Provider Role code system (2.16.840.1.113883.12.443) which is used by HITSP -->
         <xsl:when test=" $pFunction = 'CP' ">
            <xsl:text>(consulting provider)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'PP' ">
            <xsl:text>(primary care provider)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'RP' ">
            <xsl:text>(referring provider)</xsl:text>
         </xsl:when>
         <xsl:when test=" $pFunction = 'MP' ">
            <xsl:text>(medical home provider)</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="formatDateTime">
      <xsl:param name="date"/>
      <!-- day -->
      <xsl:choose>
          <xsl:when test="substring ($date, 7, 1)='0'">
              <xsl:value-of select="substring ($date, 8, 1)"/>
          </xsl:when>
          <xsl:otherwise>
              <xsl:value-of select="substring ($date, 7, 2)"/>
          </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <!-- month -->
      <xsl:variable name="month" select="substring ($date, 5, 2)"/>
      <xsl:choose>
         <xsl:when test="$month='01'">
            <xsl:text>Jan </xsl:text>
         </xsl:when>
         <xsl:when test="$month='02'">
            <xsl:text>Feb </xsl:text>
         </xsl:when>
         <xsl:when test="$month='03'">
            <xsl:text>Mar </xsl:text>
         </xsl:when>
         <xsl:when test="$month='04'">
            <xsl:text>Apr </xsl:text>
         </xsl:when>
         <xsl:when test="$month='05'">
            <xsl:text>May </xsl:text>
         </xsl:when>
         <xsl:when test="$month='06'">
            <xsl:text>Jun </xsl:text>
         </xsl:when>
         <xsl:when test="$month='07'">
            <xsl:text>July </xsl:text>
         </xsl:when>
         <xsl:when test="$month='08'">
            <xsl:text>Aug </xsl:text>
         </xsl:when>
         <xsl:when test="$month='09'">
            <xsl:text>Sep </xsl:text>
         </xsl:when>
         <xsl:when test="$month='10'">
            <xsl:text>Oct </xsl:text>
         </xsl:when>
         <xsl:when test="$month='11'">
            <xsl:text>Nov </xsl:text>
         </xsl:when>
         <xsl:when test="$month='12'">
            <xsl:text>Dec </xsl:text>
         </xsl:when>
      </xsl:choose>
      <!-- year -->
      <xsl:value-of select="substring ($date, 1, 4)"/>
      <!-- time and US timezone -->
      <xsl:if test="string-length($date) > 8">
         <xsl:text> </xsl:text>
         <!-- time -->
         <xsl:variable name="time">
            <xsl:value-of select="substring($date,9,6)"/>
         </xsl:variable>
         <xsl:variable name="hh">
            <xsl:value-of select="substring($time,1,2)"/>
         </xsl:variable>
         <xsl:variable name="mm">
            <xsl:value-of select="substring($time,3,2)"/>
         </xsl:variable>
         <xsl:variable name="ss">
            <xsl:value-of select="substring($time,5,2)"/>
         </xsl:variable>
         <xsl:if test="string-length($hh)&gt;1">
            <xsl:value-of select="$hh"/>
            <xsl:if
               test="string-length($mm)&gt;1 and not(contains($mm,'-')) and not (contains($mm,'+'))">
               <xsl:text>:</xsl:text>
               <xsl:value-of select="$mm"/>
               <xsl:if
                  test="string-length($ss)&gt;1 and not(contains($ss,'-')) and not (contains($ss,'+'))">
                  <xsl:text>:</xsl:text>
                  <xsl:value-of select="$ss"/>
               </xsl:if>
            </xsl:if>
         </xsl:if>
         <!-- time zone -->
         <xsl:variable name="tzon">
            <xsl:choose>
               <xsl:when test="contains($date,'+')">
                  <xsl:text>+</xsl:text>
                  <xsl:value-of select="substring-after($date, '+')"/>
               </xsl:when>
               <xsl:when test="contains($date,'-')">
                  <xsl:text>-</xsl:text>
                  <xsl:value-of select="substring-after($date, '-')"/>
               </xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:choose>
            <!-- reference: http://www.timeanddate.com/library/abbreviations/timezones/na/ -->
            <xsl:when test="$tzon = '-0500' ">
               <xsl:text>, EST</xsl:text>
            </xsl:when>
            <xsl:when test="$tzon = '-0600' ">
               <xsl:text>, CST</xsl:text>
            </xsl:when>
            <xsl:when test="$tzon = '-0700' ">
               <xsl:text>, MST</xsl:text>
            </xsl:when>
            <xsl:when test="$tzon = '-0800' ">
               <xsl:text>, PST</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text> </xsl:text>
               <xsl:value-of select="$tzon"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>

   <!-- show recipient -->
   <xsl:template name="show-recipients">
      <xsl:param name="recipients"/>
      <xsl:param name="title"/>

      <xsl:if test="count($recipients)&gt;0">
         <table class="pageWidth" cellspacing="0" cellpadding="0"
             style="page-break-inside: avoid;" summary="recipients">
            <tr>
               <th class="sectionheader" colspan="4">
                  <b>
                     <xsl:value-of select="$title"/>
                  </b>
               </th>
            </tr>
            <tr>
               <th class="recipientcolumnheadings">Name (+relationship to patient)</th>
               <th class="recipientcolumnheadings">Organisation</th>
               <th class="recipientcolumnheadings">Address</th>
               <th class="recipientcolumnheadingsrightelement">Contact</th>
            </tr>

            <xsl:for-each select="$recipients">
               <xsl:variable name="recipientPhoneNumber">
                  <xsl:call-template name="show-telecom">
                     <xsl:with-param name="telecom"
                        select="./cda:telecom[starts-with(@value, 'tel:')]"/>
                  </xsl:call-template>
               </xsl:variable>
               <xsl:variable name="recipientEmail"
                  select="./cda:telecom[starts-with(@value, 'mailto:')]/@value"/>
               <xsl:variable name="recipientRelationship" select="./nehtaCDA:code/@displayName"/>
               <xsl:variable name="hpii">
                  <xsl:call-template name="formatHI">
                     <xsl:with-param name="hiValue"
                        select="./cda:informationRecipient/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-I']/@root"
                     />
                  </xsl:call-template>
               </xsl:variable>
               <xsl:variable name="hpio">
                  <xsl:call-template name="formatHI">
                     <xsl:with-param name="hiValue"
                        select="./cda:receivedOrganization/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-O']/@root"
                     />
                  </xsl:call-template>
               </xsl:variable>

               <tr>
                  <xsl:choose>
                     <xsl:when test="$recipientRelationship='Patient'">
                        <td class="recipientcolumnheadingvalues" valign="top">
                           <xsl:call-template name="show-patient-name">
                              <xsl:with-param name="name"
                                 select="./cda:informationRecipient/cda:name"/>
                           </xsl:call-template>
                           <xsl:call-template name="printNBSPs">
                              <xsl:with-param name="number" select="1"/>
                           </xsl:call-template>
                           <xsl:if test="$recipientRelationship!=''">(<xsl:value-of
                                 select="$recipientRelationship"/>)</xsl:if>
                        </td>
                     </xsl:when>
                     <xsl:otherwise>
                        <td class="recipientcolumnheadingvalues" valign="top">
                           <xsl:call-template name="show-name">
                              <xsl:with-param name="name"
                                 select="./cda:informationRecipient/cda:name"/>
                           </xsl:call-template>
                           <xsl:call-template name="printNBSPs">
                              <xsl:with-param name="number" select="1"/>
                           </xsl:call-template>
                           <xsl:if test="$recipientRelationship!=''">(<xsl:value-of
                                 select="$recipientRelationship"/>)</xsl:if>
                           <xsl:if test="$hpii!='' and $renderHeaderHPIIs='true'">
                              <br/>
                              <div class="hi" style="margin-left: 20px;">[HPI-I: <xsl:value-of
                                    select="$hpii"/>]</div>
                           </xsl:if>
                        </td>
                     </xsl:otherwise>
                  </xsl:choose>

                  <xsl:choose>
                     <xsl:when test="$recipientRelationship='Patient'">
                        <td class="recipientcolumnheadingvalues" valign="top">
                           <xsl:value-of select="./cda:receivedOrganization/cda:name"/>
                           <xsl:call-template name="printNBSPs">
                              <xsl:with-param name="number" select="1"/>
                           </xsl:call-template>
                        </td>
                     </xsl:when>
                     <xsl:otherwise>
                        <td class="recipientcolumnheadingvalues" valign="top">
                           <xsl:value-of select="./cda:receivedOrganization/cda:name"/>
                           <xsl:call-template name="printNBSPs">
                              <xsl:with-param name="number" select="1"/>
                           </xsl:call-template>
                           <xsl:if test="$hpio!='' and $renderHeaderHPIOs='true'">
                              <br/>
                              <div class="hi" style="margin-left: 20px;">[HPI-O: <xsl:value-of
                                    select="$hpio"/>]</div>
                           </xsl:if>
                        </td>
                     </xsl:otherwise>
                  </xsl:choose>
                  <td class="recipientcolumnheadingvalues" valign="top">
                     <xsl:call-template name="show-address">
                        <xsl:with-param name="address" select="./cda:addr[@use='WP' or @use='H']"/>
                     </xsl:call-template>
                     <xsl:call-template name="printNBSPs">
                        <xsl:with-param name="number" select="1"/>
                     </xsl:call-template>
                  </td>
                  <td class="recipientcolumnheadingvaluesrightelement" valign="top">
                     <xsl:if test="$recipientPhoneNumber!=''">Phone: <xsl:value-of
                           select="$recipientPhoneNumber"/><br/></xsl:if>
                     <xsl:if test="$recipientEmail!=''">Email: <xsl:value-of
                           select="$recipientEmail"/></xsl:if>
                     <xsl:call-template name="printNBSPs">
                        <xsl:with-param name="number" select="1"/>
                     </xsl:call-template>
                  </td>
               </tr>
            </xsl:for-each>
         </table>
         <div class="horizontalspacer"/>
      </xsl:if>
   </xsl:template>
   <!-- show participants -->
   <xsl:template name="show-participants">
      <xsl:param name="participants"/>
      <xsl:param name="title"/>

      <xsl:if test="count($participants/cda:associatedEntity/cda:associatedPerson/cda:name) != 0">

          <table class="pageWidth" cellspacing="0" cellpadding="0" style="page-break-inside: avoid;"  summary="Participants">
            <tr>
               <th class="sectionheader" colspan="4">
                  <xsl:value-of select="$title"/>
               </th>
            </tr>
            <tr>
               <th class="recipientcolumnheadings">Name (+role)</th>
               <th class="recipientcolumnheadings">Organisation</th>
               <th class="recipientcolumnheadings">Address</th>
               <th class="recipientcolumnheadingsrightelement">Contact</th>
            </tr>
            <xsl:for-each select="$participants">
               <xsl:variable name="participantPhone">
                  <xsl:call-template name="show-telecom">
                     <xsl:with-param name="telecom"
                        select="./cda:associatedEntity/cda:telecom[starts-with(@value, 'tel:')]"/>
                  </xsl:call-template>
               </xsl:variable>

               <xsl:variable name="participantHI">
                  <xsl:call-template name="formatHI">
                     <xsl:with-param name="hiValue"
                        select="./cda:associatedEntity/cda:associatedPerson/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-I']/@root"
                     />
                  </xsl:call-template>
               </xsl:variable>
               <xsl:variable name="participantOrgHI1">
                  <xsl:call-template name="formatHI">
                     <xsl:with-param name="hiValue"
                        select="./cda:associatedEntity/cda:scopingOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-O']/@root"
                     />
                  </xsl:call-template>
               </xsl:variable>
               <xsl:variable name="participantOrgHI2">
                  <xsl:call-template name="formatHI">
                     <xsl:with-param name="hiValue"
                        select="./cda:associatedEntity/cda:scopingOrganization/nehtaCDA:asEntityIdentifier[@classCode='IDENT']/nehtaCDA:id[@assigningAuthorityName='HPI-O']/@root"
                     />
                  </xsl:call-template>
               </xsl:variable>

               <xsl:variable name="participantEmail"
                  select="./cda:associatedEntity/cda:telecom[starts-with(@value, 'mailto:')]/@value"/>
               <tr>
                  <td class="recipientcolumnheadingvalues" style="vertical-align: top;"
                        ><xsl:call-template name="show-name"><xsl:with-param name="name"
                           select="./cda:associatedEntity/cda:associatedPerson/cda:name"
                        /></xsl:call-template><xsl:call-template name="printNBSPs"><xsl:with-param
                           name="number" select="1"/></xsl:call-template>(<xsl:value-of
                        select="./cda:associatedEntity/cda:code/@displayName"/>)<xsl:if
                           test="$participantHI!='' and $renderHeaderHPIIs='true'"><br/><div class="hi" style="margin-left: 20px;"
                           >[HPI-I: <xsl:value-of select="$participantHI"/>]</div></xsl:if></td>
                  <td class="recipientcolumnheadingvalues" style="vertical-align: top;">
                     <xsl:value-of select="./cda:associatedEntity/cda:scopingOrganization/cda:name"/>
                     <xsl:call-template name="printNBSPs">
                        <xsl:with-param name="number" select="1"/>
                     </xsl:call-template>
                     <xsl:if test="$participantOrgHI1!='' and $renderHeaderHPIOs='true'">
                        <br/>
                        <div class="hi" style="margin-left: 20px;">[HPI-O: <xsl:value-of
                              select="$participantOrgHI1"/>]</div>
                     </xsl:if>
                     <xsl:if test="$participantOrgHI2!='' and $renderHeaderHPIOs='true'">
                        <br/>
                        <div class="hi" style="margin-left: 20px;">[HPI-O: <xsl:value-of
                              select="$participantOrgHI2"/>]</div>
                     </xsl:if>
                  </td>
                  <td class="recipientcolumnheadingvalues" style="vertical-align: top;">
                     <xsl:call-template name="show-address">
                        <xsl:with-param name="address"
                           select="./cda:associatedEntity/cda:addr[@use='WP']"/>
                     </xsl:call-template>
                     <xsl:call-template name="printNBSPs">
                        <xsl:with-param name="number" select="1"/>
                     </xsl:call-template>
                  </td>
                  <td class="recipientcolumnheadingvaluesrightelement" style="vertical-align: top;">
                     <xsl:if test="$participantPhone!=''">Phone: <xsl:value-of
                           select="$participantPhone"/><br/></xsl:if>
                     <xsl:if test="$participantEmail!=''">Email: <xsl:value-of
                           select="$participantEmail"/></xsl:if>
                     <xsl:call-template name="printNBSPs">
                        <xsl:with-param name="number" select="1"/>
                     </xsl:call-template>
                  </td>
               </tr>
            </xsl:for-each>
         </table>
         <div class="horizontalspacer"/>
      </xsl:if>
   </xsl:template>
   <!-- convert to lower case -->
   <xsl:template name="caseDown">
      <xsl:param name="data"/>
      <xsl:if test="$data">
         <xsl:value-of
            select="translate($data, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:if>
   </xsl:template>
   <!-- convert to upper case -->
   <xsl:template name="caseUp">
      <xsl:param name="data"/>
      <xsl:if test="$data">
         <xsl:value-of
            select="translate($data,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
      </xsl:if>
   </xsl:template>
   <!-- convert first character to upper case -->
   <xsl:template name="firstCharCaseUp">
      <xsl:param name="data"/>
      <xsl:if test="$data">
         <xsl:call-template name="caseUp">
            <xsl:with-param name="data" select="substring($data,1,1)"/>
         </xsl:call-template>
         <xsl:value-of select="substring($data,2)"/>
      </xsl:if>
   </xsl:template>
   <!-- show-noneFlavor -->
   <xsl:template name="show-noneFlavor">
      <xsl:param name="nf"/>
      <xsl:choose>
         <xsl:when test=" $nf = 'NI' ">
            <xsl:text>no information</xsl:text>
         </xsl:when>
         <xsl:when test=" $nf = 'INV' ">
            <xsl:text>invalid</xsl:text>
         </xsl:when>
         <xsl:when test=" $nf = 'MSK' ">
            <xsl:text>masked</xsl:text>
         </xsl:when>
         <xsl:when test=" $nf = 'NA' ">
            <xsl:text>not applicable</xsl:text>
         </xsl:when>
         <xsl:when test=" $nf = 'UNK' ">
            <xsl:text>unknown</xsl:text>
         </xsl:when>
         <xsl:when test=" $nf = 'OTH' ">
            <xsl:text>other</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>


   <xsl:template name="addCSS">
         <style type="text/css" media="screen">
                    .pageWidth { width: <xsl:value-of select="$screenPageWidth"/>px; }
                    .halfPageWidth { width: <xsl:value-of select="$screenHalfPageWidth"/>px; }
                    .quarterPageWidth { width: <xsl:value-of select="$screenQuarterPageWidth"/>px; }
                    .pageHeaderItemGap { margin-left: <xsl:value-of select="$screenPageHeaderItemGap"/>px; }
                    .summaryDetailsLeftGap { margin-left: <xsl:value-of select="$screenSummaryDetailsLeftGap"/>px; }
                    
                    
                    body { font-size:12px; font-family:Verdana; }
                    
                    .generictable {
                    width: <xsl:value-of select="$screenPageWidth"/>px;
                    border-spacing: 0px; 
                    padding: 0px;
                    border-spacing: 0px;
                    empty-cells: show;
                    page-break-inside: avoid;
                    border: 1px SOLID #EEEEEE;
                    }
                    
                    .xFixed {
                      font-family:monospace;
                    }

                    .borderlesstable {
                    width: <xsl:value-of select="$screenPageWidth"/>px;
                    border-spacing: 0px; 
                    padding: 0px;
                    border-spacing: 0px;
                    empty-cells: show;
                    page-break-inside: avoid;
                    border: 0px SOLID #EEEEEE;                    
                    }
                    
                    table { 
                    border-spacing: 0px; 
                    padding: 0px;
                    border-spacing: 0px;
                    empty-cells: show;
                    }
                    
                    td { border-left: 0px;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 0px;
                    padding: 1px;
                    
                    }
                    th { 
                    border-left: 0px;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 0px;
                    padding: 1px;
                    }
                    
                    .tableCaption {
                      font-weight: bold;
                      text-align: left;
                    }
                    
                    .sectionheader { 
                    background-color: #EEEEEE; text-align: left; width: <xsl:value-of select="$screenPageWidth"/>px;
                    border-left: 0px;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 0px;
                    padding: 1px;
                    text-decoration: none;
                    font-weight: bold;
                    text-decoration: none;
                    }
                    
                    
                    .sectiontitleheader { 
                    background-color: #DDDDDD; text-align: left; width: <xsl:value-of select="$screenPageWidth"/>px;
                    border-left: 0px;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 0px;
                    padding: 1px;
                    text-decoration: none;
                    font-size: 16px;
                    font-weight: bold;
                    text-decoration: none;
                    }
                    
                    
                    
                    .underline {
                      text-decoration: underline;
                    }

                    .nounderline {
                      text-decoration: none;
                    }
                    
                    .bold {
                      font-weight: bold;
                    }

                    .italic {
                      font-style: italic;
                    }

                    .paragraph {
                      width: <xsl:value-of select="$screenPageWidth"/>px;
                      border-spacing: 0px; 
                      padding: 0px;
                      border-spacing: 0px;
                      empty-cells: show;
                      page-break-inside: avoid;
                      border: 0px SOLID #EEEEEE;                    
                    }




                    p.div {
                      width: <xsl:value-of select="$screenPageWidth"/>px;
                    }

                    a:link { color: blue; }
                    a:visited { color: blue }
                    a:hover { color: red; }
                    a:active { color: red; }
                    
                    .horizontalspacer {height:15px; border-style:none; border-width:1px; border-color:#FFFFFF; }

                    .maintitle { text-align:center; font-family:Verdana; font-size:16px; }
                    .facility { text-align:center; font-size:16px; }
                    .sidevaluenames { width: 120px; font-weight: bold; text-align: left; vertical-align: top; }
                    .sidevalue { width: <xsl:value-of select="$screenHalfPageWidth - 120"/>px; }
                    .hi { font-size: 9px; }
                    .summarydetails { display: inline; width: <xsl:value-of select="$screenQuarterPageWidth - 100"/>px; font-weight: bold; vertical-align: top; }
                    .documentdetailsvalues { width: <xsl:value-of select="$screenQuarterPageWidth + 50"/>px; vertical-align: top; }
            
                    .generalcolumnheadings { text-align: left; font-weight: bold; vertical-align: top; }
                    .generalcolumnheadingvalues { text-align: left; }

                                         .recipientcolumnheadings { text-align: left; background: #FFFFFF; vertical-align: top; width: 250px; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 0px;
                    border-top: 1px SOLID #EEEEEE;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    .recipientcolumnheadingsrightelement { text-align: left; background: #FFFFFF; vertical-align: top; width: 250px; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 1px SOLID #EEEEEE;
                    border-top: 1px SOLID #EEEEEE;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    
                    .recipientcolumnheadingvalues { text-align: left; background: #FFFFFF; width: 250px; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    
                    .recipientcolumnheadingvaluesrightelement { text-align: left; background: #FFFFFF; width: 250px; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 1px SOLID #EEEEEE;
                    border-top: 0px;
                    border-bottom: 1px SOLID #EEEEEE;
                    }

                                        .borderedcolumnheadings { text-align: left; background: #FFFFFF; vertical-align: top;
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 0px;
                    border-top: 1px SOLID #EEEEEE;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    .borderedcolumnheadingsrightelement { text-align: left; background: #FFFFFF; vertical-align: top;
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 1px SOLID #EEEEEE;
                    border-top: 1px SOLID #EEEEEE;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    .borderedcolumnheadingvalues { text-align: left; background: #FFFFFF; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    
                    .borderedcolumnheadingvaluesrightelement { text-align: left; background: #FFFFFF; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 1px SOLID #EEEEEE;
                    border-top: 0px;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    
                    div#content {
                    position:fixed; 
                    top:65px;
                    left:10px;
                    bottom:0px; 
                    right:0; 
                    overflow:auto; 
                    background:#FFFFFF;
                    padding: 0px;
                    }
                    .noscreen { display: none; width: <xsl:value-of select="$printPageWidth"/>px; }
                    
                    div#logo {
                       width: 400px;
                       height: 100px;
                       clip: rect(0px, 400px, 100px, 0px);
                       overflow: hidden;
                    }
                    
                </style>
                
                <style type="text/css" media="print">
                    .pageWidth { width: <xsl:value-of select="$printPageWidth"/>px; }
                    .halfPageWidth { width: <xsl:value-of select="$printHalfPageWidth"/>px; }
                    .quarterPageWidth { width: <xsl:value-of select="$printQuarterPageWidth"/>px; }
                    .pageHeaderItemGap { margin-left: <xsl:value-of select="$printPageHeaderItemGap"/>px; }
                    .summaryDetailsLeftGap { margin-left: <xsl:value-of select="$printSummaryDetailsLeftGap"/>px; }
                    
                    
                    body { font-size:12px; font-family:Verdana; }
                    
                    .generictable {
                    width: <xsl:value-of select="$printPageWidth"/>px;
                    border-spacing: 0px; 
                    padding: 0px;
                    border-spacing: 0px;
                    empty-cells: show;
                    page-break-inside: avoid;
                    border: 1px SOLID #EEEEEE;
                    }
                    
                    .xFixed {
                      font-family:monospace;
                    }

                    .borderlesstable {
                    width: <xsl:value-of select="$printPageWidth"/>px;
                    border-spacing: 0px; 
                    padding: 0px;
                    border-spacing: 0px;
                    empty-cells: show;
                    page-break-inside: avoid;
                    border: 0px SOLID #EEEEEE;                    
                    }
                    
                    table { 
                    border-spacing: 0px; 
                    padding: 0px;
                    border-spacing: 0px;
                    empty-cells: show;
                    }
                    
                    td { border-left: 0px;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 0px;
                    padding: 1px;
                    
                    }
                    th { 
                    border-left: 0px;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 0px;
                    padding: 1px;
                    }
                    
                    .tableCaption {
                      font-weight: bold;
                      text-align: left;
                    }
                    
                    .sectionheader { 
                    background-color: #EEEEEE; text-align: left; width: <xsl:value-of select="$printPageWidth"/>px;
                    border-left: 0px;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 0px;
                    padding: 1px;
                    text-decoration: none;
                    font-weight: bold;
                    text-decoration: none;
                    }
                    
                    
                    .sectiontitleheader { 
                    background-color: #DDDDDD; text-align: left; width: <xsl:value-of select="$printPageWidth"/>px;
                    border-left: 0px;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 0px;
                    padding: 1px;
                    text-decoration: none;
                    font-size: 16px;
                    font-weight: bold;
                    text-decoration: none;
                    }
                    
                    
                    
                    .underline {
                      text-decoration: underline;
                    }

                    .nounderline {
                      text-decoration: none;
                    }
                    
                    .bold {
                      font-weight: bold;
                    }

                    .italic {
                      font-style: italic;
                    }

                    .paragraph {
                      width: <xsl:value-of select="$printPageWidth"/>px;
                      border-spacing: 0px; 
                      padding: 0px;
                      border-spacing: 0px;
                      empty-cells: show;
                      page-break-inside: avoid;
                      border: 0px SOLID #EEEEEE;                    
                    }




                    p.div {
                      width: <xsl:value-of select="$printPageWidth"/>px;
                    }

                    a:link { color: blue; }
                    a:visited { color: blue }
                    a:hover { color: red; }
                    a:active { color: red; }
                    
                    .horizontalspacer {height:15px; border-style:none; border-width:1px; border-color:#FFFFFF; }

                    .maintitle { text-align:center; font-family:Verdana; font-size:16px; }
                    .facility { text-align:center; font-size:16px; }
                    .sidevaluenames { width: 120px; font-weight: bold; text-align: left; vertical-align: top; }
                    .sidevalue { width: <xsl:value-of select="$printHalfPageWidth - 120"/>px; }
                    .hi { font-size: 9px; }
                    .summarydetails { display: inline; width: <xsl:value-of select="$printQuarterPageWidth"/>px; font-weight: bold; vertical-align: top; }
                    .documentdetailsvalues { width: <xsl:value-of select="$printQuarterPageWidth"/>px; vertical-align: top; }
            
                    .generalcolumnheadings { text-align: left; font-weight: bold; vertical-align: top; }
                    .generalcolumnheadingvalues { text-align: left; }

                                         .recipientcolumnheadings { text-align: left; background: #FFFFFF; vertical-align: top; width: 250px; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 0px;
                    border-top: 1px SOLID #EEEEEE;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    .recipientcolumnheadingsrightelement { text-align: left; background: #FFFFFF; vertical-align: top; width: 250px; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 1px SOLID #EEEEEE;
                    border-top: 1px SOLID #EEEEEE;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    
                    .recipientcolumnheadingvalues { text-align: left; background: #FFFFFF; width: 250px; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    
                    .recipientcolumnheadingvaluesrightelement { text-align: left; background: #FFFFFF; width: 250px; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 1px SOLID #EEEEEE;
                    border-top: 0px;
                    border-bottom: 1px SOLID #EEEEEE;
                    }

                                        .borderedcolumnheadings { text-align: left; background: #FFFFFF; vertical-align: top;
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 0px;
                    border-top: 1px SOLID #EEEEEE;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    .borderedcolumnheadingsrightelement { text-align: left; background: #FFFFFF; vertical-align: top;
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 1px SOLID #EEEEEE;
                    border-top: 1px SOLID #EEEEEE;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    .borderedcolumnheadingvalues { text-align: left; background: #FFFFFF; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 0px;
                    border-top: 0px;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    
                    .borderedcolumnheadingvaluesrightelement { text-align: left; background: #FFFFFF; 
                    border-left: 1px SOLID #EEEEEE;
                    border-right: 1px SOLID #EEEEEE;
                    border-top: 0px;
                    border-bottom: 1px SOLID #EEEEEE;
                    }
                    
                    div#content {
                    top:65px;
                    left:10px;
                    bottom:0px; 
                    right:0; 
                    background:#FFFFFF;
                    padding: 0px;
                    }
                    
                    .noprint { display: none; width: <xsl:value-of select="$printPageWidth"/>px; }
                   
                    div#logo {
                       width: 400px;
                       height: 100px;
                       clip: rect(0px, 400px, 100px, 0px);
                       overflow: hidden;
                    }

                </style>
   </xsl:template>

   <!-- calculated the difference (in years) between two dates -->
   <xsl:template name="calculateAgeInYears">

      <xsl:param name="birthDate"/>
      <xsl:param name="docDate"/>

      <xsl:variable name="birthYear" select="substring($birthDate,1,4)"/>
      <xsl:variable name="birthMonth" select="substring($birthDate,5,2)"/>
      <xsl:variable name="birthDay" select="substring($birthDate,7,2)"/>

      <xsl:variable name="currentYear" select="substring($docDate,1,4)"/>
      <xsl:variable name="currentMonth" select="substring($docDate,5,2)"/>
      <xsl:variable name="currentDay" select="substring($docDate,7,2)"/>

      <xsl:variable name="startAge" select="$currentYear - $birthYear"/>
      <xsl:choose>
         <xsl:when test="$currentMonth &lt; $birthMonth">
            <xsl:variable name="age" select="$startAge - 1"/>
            <xsl:value-of select="$age"/>
         </xsl:when>
         <xsl:when test="$currentMonth = $birthMonth">
            <xsl:choose>
               <xsl:when test="$currentDay &lt; $birthDay">
                  <xsl:variable name="age" select="$startAge - 1"/>
                  <xsl:value-of select="$age"/>
               </xsl:when>
			   <xsl:otherwise>
                  <xsl:variable name="age" select="$startAge"/>
                  <xsl:value-of select="$age"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="age" select="$startAge"/>
            <xsl:value-of select="$age"/>
         </xsl:otherwise>
      </xsl:choose>
	</xsl:template>
	
   <!-- returns the 16-digit HI. If the value is greater than 16 characters, return the last 16. -->
   <xsl:template name="formatHI">
      <xsl:param name="hiValue"/>

      <xsl:if test="$hiValue">
         <xsl:variable name="identifier">
            <xsl:choose>
               <xsl:when test="string-length($hiValue) &gt; 16">
                  <xsl:value-of
                     select="substring($hiValue, string-length($hiValue)-15, string-length($hiValue))"
                  />
               </xsl:when>
               <xsl:when test="string-length($hiValue) = 16">
                  <xsl:value-of select="$hiValue"/>
               </xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:value-of select="substring($identifier,1,4)"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="substring($identifier,5,4)"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="substring($identifier,9,4)"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="substring($identifier,13,4)"/>
      </xsl:if>
   </xsl:template>

   <xsl:template name="printNBSPs">
      <xsl:param name="number"/>
      <xsl:if test="$number &gt; 0">
         <span style="margin-left: 4px;"/>
         <xsl:call-template name="printNBSPs">
            <xsl:with-param name="number" select="$number - 1"/>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>

   <xsl:template name="processColourStyleCode">
      <xsl:param name="code"/>

      <!-- Isolate xFgColour stylecode -->
      <xsl:variable name="fgColourStyleCodeStart" select="substring-after($code, 'xFgColour=')"/>
      <xsl:variable name="fgColourHexCode">
         <xsl:choose>
            <xsl:when test="contains($fgColourStyleCodeStart, ' ')">
               <xsl:value-of select="substring-before($fgColourStyleCodeStart, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fgColourStyleCodeStart"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Isolate xBgColour stylecode -->
      <xsl:variable name="bgColourStyleCodeStart" select="substring-after($code, 'xBgColour=')"/>
      <xsl:variable name="bgColourHexCode">
         <xsl:choose>
            <xsl:when test="contains($bgColourStyleCodeStart, ' ')">
               <xsl:value-of select="substring-before($bgColourStyleCodeStart, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$bgColourStyleCodeStart"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- generate style value -->
      <xsl:choose>
         <xsl:when test="$fgColourHexCode != '' and $bgColourHexCode !=''">
            <xsl:attribute name="style">
               <xsl:text>background: #</xsl:text>
               <xsl:value-of select="$bgColourHexCode"/>
               <xsl:text>;</xsl:text>
               <xsl:text> color: #</xsl:text>
               <xsl:value-of select="$fgColourHexCode"/>
               <xsl:text>;</xsl:text>
            </xsl:attribute>
         </xsl:when>
         <xsl:when test="$fgColourHexCode = '' and $bgColourHexCode !=''">
            <xsl:attribute name="style">
               <xsl:text>background: #</xsl:text>
               <xsl:value-of select="$bgColourHexCode"/>
               <xsl:text>;</xsl:text>
            </xsl:attribute>
         </xsl:when>
         <xsl:when test="$fgColourHexCode != '' and $bgColourHexCode =''">
            <xsl:attribute name="style">
               <xsl:text>color: #</xsl:text>
               <xsl:value-of select="$fgColourHexCode"/>
               <xsl:text>;</xsl:text>
            </xsl:attribute>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template name="processFontSizePx">
      <xsl:param name="code"/>
      
      <!-- Isolate xFontSize stylecode -->
      <xsl:variable name="fontSizeStyleCodeStart" select="substring-after($code, 'xFontSizePx=')"/>
      <xsl:variable name="fontSize">
         <xsl:choose>
            <xsl:when test="contains($fontSizeStyleCodeStart, ' ')">
               <xsl:value-of select="substring-before($fontSizeStyleCodeStart, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fontSizeStyleCodeStart"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <!-- generate style value -->
      <xsl:choose>
         <xsl:when test="$fontSize != ''">
            <xsl:attribute name="style">
               <xsl:text>font-size: </xsl:text>
               <xsl:value-of select="$fontSize"/>
               <xsl:text>px;</xsl:text>
            </xsl:attribute>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="processFontSizeEm">
      <xsl:param name="code"/>
      
      <!-- Isolate xFontSize stylecode -->
      <xsl:variable name="fontSizeStyleCodeStart" select="substring-after($code, 'xFontSizeEm=')"/>
      <xsl:variable name="fontSize">
         <xsl:choose>
            <xsl:when test="contains($fontSizeStyleCodeStart, ' ')">
               <xsl:value-of select="substring-before($fontSizeStyleCodeStart, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fontSizeStyleCodeStart"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <!-- generate style value -->
      <xsl:choose>
         <xsl:when test="$fontSize != ''">
            <xsl:attribute name="style">
               <xsl:text>font-size: </xsl:text>
               <xsl:value-of select="$fontSize"/>
               <xsl:text>em;</xsl:text>
            </xsl:attribute>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template name="renderLogo">
         <xsl:if
            test="//cda:observationMedia[@ID='LOGO']/cda:value[@mediaType='image/png']/cda:reference/@value">
             <div class="halfPageWidth" align="center">
            <div id="logo">
            <xsl:element name="img">
               <xsl:attribute name="alt">logo</xsl:attribute>
               <xsl:attribute name="src">
                  <xsl:value-of
                     select="//cda:observationMedia[@ID='LOGO']/cda:value[@mediaType='image/png']/cda:reference/@value"
                  />
               </xsl:attribute>
            </xsl:element>
            </div>
             </div>
         </xsl:if>
   </xsl:template>
   
   <xsl:template name="getNEHTADocumentTitleFromTemplateID">
      <xsl:param name="templateIdRoot"/>
      <xsl:choose>
         <xsl:when test="$templateIdRoot = $NEHTA_DISCHARGE_SUMMARY_TEMPLATE_ID">Discharge Summary</xsl:when>
         <xsl:when test="$templateIdRoot = $NEHTA_E_PRESCRIPTION_TEMPLATE_ID">e-Prescription</xsl:when>
         <xsl:when test="$templateIdRoot = $NEHTA_DISPENSE_RECORD_TEMPLATE_ID">Dispense Record</xsl:when>
         <xsl:when test="$templateIdRoot = $NEHTA_PRESCRIPTION_REQUEST_TEMPLATE_ID">Prescription Request</xsl:when>
         <xsl:when test="$templateIdRoot = $NEHTA_E_REFERRAL_TEMPLATE_ID">e-Referral</xsl:when>
         <xsl:when test="$templateIdRoot = $NEHTA_SPECIALIST_LETTER_TEMPLATE_ID">Specialist Letter</xsl:when>
         <xsl:when test="$templateIdRoot = $NEHTA_SHARED_HEALTH_SUMMARY_TEMPLATE_ID">Shared Health Summary</xsl:when>
         <xsl:when test="$templateIdRoot = $NEHTA_SHARED_HEALTH_SUMMARY_TEMPLATE_ID">Event Summary</xsl:when>
      </xsl:choose>
   </xsl:template>
   
   <!-- Left Trim -->
   <xsl:template name="lTrim">
      <xsl:param name="string"/>
      <xsl:choose>
         <xsl:when test="substring($string, 1, 1) = ''">
            <xsl:value-of select="$string"/>
         </xsl:when>
         <xsl:when test="normalize-space(substring($string, 1, 1)) = ''">
            <xsl:call-template name="lTrim">
               <xsl:with-param name="string" select="substring($string, 2)"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$string"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- Right Trim -->
   <xsl:template name="rTrim">
      <xsl:param name="string"/>
      <xsl:choose>
         <xsl:when test="substring($string, 1, 1) = ''">
            <xsl:value-of select="$string"/>
         </xsl:when>
         <xsl:when test="normalize-space(substring($string, string-length($string))) = ''">
            <xsl:call-template name="rTrim">
               <xsl:with-param name="string" select="substring($string, 1, string-length($string) - 1)"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$string"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!-- Trim by using right and left trim -->
   <xsl:template name="trim">
      <xsl:param name="string"/>
      <xsl:call-template name="rTrim">
         <xsl:with-param name="string">
            <xsl:call-template name="lTrim">
               <xsl:with-param name="string" select="$string"/>
            </xsl:call-template>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   

</xsl:stylesheet>
