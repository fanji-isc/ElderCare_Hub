<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:isc="http://extension-functions.intersystems.com" xmlns:exsl="http://exslt.org/common" xmlns:set="http://exslt.org/sets" exclude-result-prefixes="isc xsi sdtc exsl set">

<!-- If you are using an XSLT 2.0 processor and have not yet refactored
	  to remove all references to the set:distinct function, include
	  this module to provide a compatible implementation. -->

	<xsl:function name="set:distinct">
       <xsl:param name="nodes"/>

       <xsl:for-each select="$nodes">
               <xsl:if test="position() = index-of($nodes,current())[1]">
                       <xsl:variable name="firstPos" select="position()"/>
                       <xsl:sequence select="$nodes[position() = $firstPos]"/>
               </xsl:if>
       </xsl:for-each>
    </xsl:function>
</xsl:stylesheet>