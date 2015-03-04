<?xml version="1.0" encoding="UTF-8"?>
<!--  
Stylesheet used to update metadata for a service and 
detach a dataset metadata
-->
<xsl:stylesheet version="2.0"
                xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
                xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
                xmlns:srv="http://standards.iso.org/19115/-3/srv/1.0/2014-12-25"
                xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"
                xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
                xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn="http://www.fao.org/geonetwork">
	<xsl:param name="uuidref"/>

	<!-- Detach -->
	<xsl:template match="srv:operatesOn[@uuidref=$uuidref]" priority="2"/>
	<xsl:template match="srv:coupledResource[srv:SV_CoupledResource/
	          srv:identifier/gco:CharacterString=$uuidref]" priority="2"/>

	<!-- Do a copy of every nodes and attributes -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- Remove gn:* elements. -->
	<xsl:template match="gn:*" priority="2"/>
</xsl:stylesheet>
