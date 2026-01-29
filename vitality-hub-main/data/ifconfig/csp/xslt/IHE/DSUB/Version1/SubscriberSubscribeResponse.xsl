<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:isc="http://extension-functions.intersystems.com" 
xmlns:wsnt="http://docs.oasis-open.org/wsn/b-2" 
xmlns:wsa="http://www.w3.org/2005/08/addressing" 
exclude-result-prefixes="isc xsi">
<xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:template match="/">
<SubscriptionResponse>
<CancellationAddress><xsl:value-of select="wsnt:SubscribeResponse/wsnt:SubscriptionReference/wsa:Address/text()"/></CancellationAddress>
<TerminationTime><xsl:value-of select="wsnt:SubscribeResponse/wsnt:TerminationTime/text()"/></TerminationTime>
</SubscriptionResponse>
</xsl:template>

</xsl:stylesheet>
