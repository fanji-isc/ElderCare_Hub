<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				exclude-result-prefixes="xsi"
				version="1.0">
	
	<xsl:output method="xml" indent="no" encoding="ISO-8859-1"/>

<xsl:template match="/">
	<Container>
		<xsl:copy-of select="Container/Patient"/>
	</Container>
</xsl:template>

</xsl:stylesheet>