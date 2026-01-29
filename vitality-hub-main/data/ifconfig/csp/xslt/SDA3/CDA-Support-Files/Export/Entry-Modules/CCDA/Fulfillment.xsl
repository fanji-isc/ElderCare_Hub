<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">

	<xsl:template match="Patient" mode="fulfillment">
		<inFulfillmentOf typeCode="FLFS">
			<order classCode="ACT" moodCode="RQO">
				<id nullFlavor="NI"/>
			</order>
		</inFulfillmentOf>
	</xsl:template>
</xsl:stylesheet>
