<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:dsub="urn:ihe:iti:dsub:2009" 
xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2"
xmlns:a="http://www.w3.org/2005/08/addressing">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
<xsl:param name="terminationTime"/>
<xsl:param name="cancellationAddress"/>

<xsl:template match="/">
<wsnt:SubscribeResponse>
<wsnt:SubscriptionReference>
<a:Address><xsl:value-of select="$cancellationAddress"/></a:Address>
</wsnt:SubscriptionReference>
<xsl:if test="$terminationTime!=''">
<wsnt:TerminationTime><xsl:value-of select="$terminationTime"/></wsnt:TerminationTime>
</xsl:if>
</wsnt:SubscribeResponse>
</xsl:template>
</xsl:stylesheet>
