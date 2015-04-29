<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0"
  xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0"
  xmlns:gco="http://standards.iso.org/19115/-3/gco/1.0"
  xmlns:gn="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all" >
  
  <xsl:param name="url"/>
  <xsl:param name="name" />
  
  <!-- Copy everything -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Remove gn:* elements and matching online resource. -->
  <xsl:template match="gn:*|
    mrd:onLine[
    normalize-space(cit:CI_OnlineResource/cit:linkage/gco:CharacterString) = $url and 
    normalize-space(cit:CI_OnlineResource/cit:name/gco:CharacterString) = $name]|
    mrd:onLine[
    normalize-space(cit:CI_OnlineResource/cit:linkage/gco:CharacterString) = $url and 
    normalize-space(cit:CI_OnlineResource/cit:protocol/gco:CharacterString) = 'WWW:DOWNLOAD-1.0-http--download']"
    priority="2"/>
</xsl:stylesheet>