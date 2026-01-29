<?xml version="1.0" encoding="UTF-8"?>
<!-- IHE constants, keep in sync with EnsLib.IHE.Common.Macros -->
<xsl:stylesheet 
version="1.0" 
xmlns:exsl="http://exslt.org/common"
xmlns:set="http://exslt.org/sets"
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"

xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0" 
xmlns:query="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0"
xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" 
xmlns:xdsb="urn:ihe:iti:xds-b:2007" 
xmlns:xop="http://www.w3.org/2004/08/xop/include" 

exclude-result-prefixes="isc exsl set">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

<xsl:variable name="lcm"		select="'urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0'"/>
<xsl:variable name="query"	select="'urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0'"/>
<xsl:variable name="rim"		select="'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'"/>
<xsl:variable name="rs"			select="'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0'"/> 
<xsl:variable name="xdsb"		select="'urn:ihe:iti:xds-b:2007'"/>
<xsl:variable name="xop"		select="'http://www.w3.org/2004/08/xop/include'"/>

<xsl:variable name="xdsbQueryAction"					select="'urn:ihe:iti:2007:RegistryStoredQuery'"/>
<xsl:variable name="xdsbQueryResponseAction"	select="'urn:ihe:iti:2007:RegistryStoredQueryResponse'"/>
<xsl:variable name="xdsbQueryRequest" 				select="'XDSb_QueryRequest'"/>
<xsl:variable name="xdsbQueryResponse" 				select="'XDSb_QueryResponse'"/>
<xsl:variable name="xdsbQueryFindDocuments"						select="'urn:uuid:14d4debf-8f97-4251-9a74-a90016b0af0d'"/>
<xsl:variable name="xdsbQueryFindSubmissionSets"			select="'urn:uuid:f26abbcb-ac74-4422-8a30-edb644bbc1a9'"/>
<xsl:variable name="xdsbQueryFindFolders"							select="'urn:uuid:958f3006-baad-4929-a4de-ff1114824431'"/>
<xsl:variable name="xdsbQueryGetAll"									select="'urn:uuid:10b545ea-725c-446d-9b95-8aeb444eddf3'"/>
<xsl:variable name="xdsbQueryGetDocuments"           	select="'urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4'"/>
<xsl:variable name="xdsbQueryGetFolders"             	select="'urn:uuid:5737b14c-8a1a-4539-b659-e03a34a5e1e4'"/>
<xsl:variable name="xdsbQueryGetAssociations"        	select="'urn:uuid:a7ae438b-4bc2-4642-93e9-be891f7bb155'"/>
<xsl:variable name="xdsbQueryGetDocsAndAssociations"	select="'urn:uuid:bab9529a-4a10-40b3-a01f-f68a615d247a'"/>
<xsl:variable name="xdsbQueryGetSubmissionSets"				select="'urn:uuid:51224314-5390-4169-9b91-b1980040715a'"/>
<xsl:variable name="xdsbQueryGetSubSetsAndContents"		select="'urn:uuid:e8e3cb2c-e39c-46b9-99e4-c12f57260b83'"/>
<xsl:variable name="xdsbQueryGetFolderAndContents"		select="'urn:uuid:b909a503-523d-4517-8acf-8e5834dfc4c7'"/>
<xsl:variable name="xdsbQueryGetFoldersForDocument"		select="'urn:uuid:10cae35a-c7f9-4cf5-b61e-fc3278ffb578'"/>
<xsl:variable name="xdsbQueryGetRelatedDocuments"			select="'urn:uuid:d90e5407-b356-4d91-a89f-873917b4b0e6'"/>

<xsl:variable name="xdsbRegisterAction"					select="'urn:ihe:iti:2007:RegisterDocumentSet-b'"/>
<xsl:variable name="xdsbRegisterResponseAction" select="'urn:ihe:iti:2007:RegisterDocumentSet-bResponse'"/>
<xsl:variable name="xdsbRegisterRequest" 				select="'XDSb_RegisterRequest'"/>
<xsl:variable name="xdsbRegisterResponse" 			select="'XDSb_RegisterResponse'"/>

<xsl:variable name="xdsbRegisterOnDemandAction" 				select="'urn:ihe:iti:2010:RegisterOnDemandDocumentEntry'"/>
<xsl:variable name="xdsbRegisterOnDemandResponseAction" select="'urn:ihe:iti:2010:RegisterOnDemandDocumentResponse'"/>
<xsl:variable name="xdsbRegisterOnDemandRequest"				select="'XDSb_RegisterOnDemandRequest'"/>
<xsl:variable name="xdsbRegisterOnDemandResponse"				select="'XDSb_RegisterOnDemandResponse'"/>

<xsl:variable name="xdsbProvideAndRegisterAction" 				select="'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b'"/>
<xsl:variable name="xdsbProvideAndRegisterResponseAction" select="'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-bResponse'"/>
<xsl:variable name="xdsbProvideAndRegisterRequest" 				select="'XDSb_ProvideAndRegisterRequest'"/>
<xsl:variable name="xdsbProvideAndRegisterResponse"				select="'XDSb_ProvideAndRegisterResponse'"/>

<xsl:variable name="xdsbRetrieveAction" 				select="'urn:ihe:iti:2007:RetrieveDocumentSet'"/>
<xsl:variable name="xdsbRetrieveResponseAction" select="'urn:ihe:iti:2007:RetrieveDocumentSetResponse'"/>
<xsl:variable name="xdsbRetrieveRequest" 				select="'XDSb_RetrieveRequest'"/>
<xsl:variable name="xdsbRetrieveResponse" 			select="'XDSb_RetrieveResponse'"/>

<!-- XDSb ExtrinsicObject types -->
<xsl:variable name="xdsbStableDocument"   select="'urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1'"/>
<xsl:variable name="xdsbOnDemandDocument" select="'urn:uuid:34268e47-fdf5-41a6-ba33-82133c465248'"/>

<!-- Status/error codes -->
<xsl:variable name="failure" 	select="'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Failure'"/>
<xsl:variable name="partial" 	select="'urn:ihe:iti:2007:ResponseStatusType:PartialSuccess'"/>
<xsl:variable name="success" 	select="'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success'"/>
<xsl:variable name="warning" 	select="'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Warning'"/>
<xsl:variable name="error" 		select="'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error'"/>

<!-- OnDemand messages -->
<xsl:variable name="xdsbPushDeliveryRequest"        select="'XDSb_PushDeliveryRequest'"/>
<xsl:variable name="xdsbOnDemandPersistenceRequest" select="'XDSb_OnDemandPersistenceRequest'"/>
<xsl:variable name="xdsbOnDemandDocumentList"       select="'XDSb_OnDemandDocumentList'"/>

<!-- Associations -->
<xsl:variable name="hasMember" select="'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember'"/>
<xsl:variable name="replaces" select="'urn:ihe:iti:2007:AssociationType:RPLC'"/>
<xsl:variable name="transforms" select="'urn:ihe:iti:2007:AssociationType:XFRM'"/>
<xsl:variable name="appends" select="'urn:ihe:iti:2007:AssociationType:APND'"/>
<xsl:variable name="transformsAndReplaces" select="'urn:ihe:iti:2007:AssociationType:XFRM_RPLC'"/>
<xsl:variable name="signs" select="'urn:ihe:iti:2007:AssociationType:signs'"/>
<xsl:variable name="isSnapshotOf" select="'urn:ihe:iti:2010:AssociationType:IsSnapshotOf'"/>


</xsl:stylesheet>
