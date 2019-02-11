<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
  xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
  xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
  xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
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
  <xsl:template match="
        gn:*|
        mrd:onLine[
          normalize-space(cit:CI_OnlineResource/cit:linkage/gco:CharacterString) = $url and
          normalize-space(cit:CI_OnlineResource/cit:name/gco:CharacterString) = $name]|
        mrd:onLine[
          normalize-space(cit:CI_OnlineResource/cit:linkage/gco:CharacterString) = $url and
          normalize-space(cit:CI_OnlineResource/cit:protocol/gco:CharacterString) = 'WWW:DOWNLOAD-1.0-http--download']|
        mdb:portrayalCatalogueInfo[
          count(*/node()) = 1 and
          */mpc:portrayalCatalogueCitation/*/cit:onlineResource/*/cit:linkage/*/text() = $url]|
        mdq:report[
          */mdq:result/*/mdq:specification/
          */cit:onlineResource/*/cit:linkage/*/text() = $url]|
        mdq:standaloneQualityReport[
          */mdq:reportReference/
          */cit:onlineResource/*/cit:linkage/*/text() = $url]|
        mrl:additionalDocumentation[
          */cit:onlineResource/*/cit:linkage/*/text() = $url]|
        mpc:portrayalCatalogueCitation[
          */cit:onlineResource/*/cit:linkage/*/text() = $url]|
        mdb:contentInfo[
          */mrc:featureCatalogueCitation/*/cit:onlineResource/*/cit:linkage/*/text() = $url and
          */mrc:featureCatalogueCitation/*/cit:title/gco:CharacterString = $name]"
                priority="2"/>
</xsl:stylesheet>
