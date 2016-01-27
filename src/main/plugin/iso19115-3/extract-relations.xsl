<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Create a simple XML tree for relation description.
  <relations>
    <relation type="related|services|children">
      + super-brief representation.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:gmx="http://standards.iso.org/iso/19115/-3/gmx"
  xmlns:gn="http://www.fao.org/geonetwork"
  xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
  xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
  xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
  exclude-result-prefixes="#all" >
  
  
  <!-- Relation contained in the metadata record has to be returned
  It could be document or thumbnails
  -->
  <xsl:template mode="relation" match="metadata[mdb:MD_Metadata or *[contains(@gco:isoType, 'MD_Metadata')]]" priority="99">
    
    <xsl:for-each select="*/descendant::*[name(.) = 'mri:graphicOverview']/*">
      <relation type="thumbnail">
        <id><xsl:value-of select="mcc:fileName/gco:CharacterString"/></id>
        <title><xsl:value-of select="mcc:fileDescription/gco:CharacterString"/></title>
      </relation>
    </xsl:for-each>

    <xsl:for-each select="*/descendant::*[
                            local-name() = 'portrayalCatalogueCitation'
                            ]/*[cit:onlineResource/*/cit:linkage/gco:CharacterString != '']">
      <relation type="onlinesrc" subtype="portrayal">
        <id><xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></id>
        <url><xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></url>
        <title><xsl:value-of select="cit:title/gco:CharacterString"/></title>
      </relation>
    </xsl:for-each>

    <xsl:for-each select="*/descendant::*[
                            local-name() = 'additionalDocumentation' or
                            local-name() = 'specification' or
                            local-name() = 'reportReference'
                            ]/*[cit:onlineResource/*/cit:linkage/gco:CharacterString != '']">
      <relation type="onlinesrc" subtype="dq">
        <id><xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></id>
        <url><xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></url>
        <title><xsl:value-of select="cit:title/gco:CharacterString"/></title>
      </relation>
    </xsl:for-each>

    <xsl:for-each select="*/descendant::*[
                            local-name() = 'featureCatalogueCitation'
                            ]/*[cit:onlineResource/*/cit:linkage/gco:CharacterString != '']">
      <relation type="fcats" subtype="{parent::node()/local-name()}">
        <id><xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></id>
        <url><xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></url>
        <title><xsl:value-of select="cit:title/gco:CharacterString"/></title>
      </relation>
    </xsl:for-each>

    
    <xsl:for-each select="*/descendant::*[
                            local-name() = 'onLine'
                            ]/*[cit:linkage/gco:CharacterString != '']">
      <relation type="onlinesrc">
        <xsl:if test="cit:function/*">
          <xsl:attribute name="subtype" select="cit:function/*/@codeListValue"/>
        </xsl:if>
        <!-- Compute title based on online source info-->
        <xsl:variable name="title">
          <xsl:variable name="title" select="''"/>
          <xsl:value-of select="if ($title = '' and ../@uuidref) then ../@uuidref else $title"/><xsl:text> </xsl:text>
          <xsl:value-of select="if (cit:name/gco:CharacterString != '') 
            then cit:name/gco:CharacterString 
            else if (cit:name/gmx:MimeFileType != '')
            then cit:name/gmx:MimeFileType
            else if (cit:description/gco:CharacterString != '')
            then cit:description/gco:CharacterString
            else cit:linkage/gco:CharacterString"/>
        </xsl:variable>
        
        <id><xsl:value-of select="cit:linkage/gco:CharacterString"/></id>
        <title>
          <xsl:value-of select="if ($title != '') then $title else cit:linkage/gco:CharacterString"/>
        </title>
        <url>
          <xsl:value-of select="cit:linkage/gco:CharacterString"/>
        </url>
        <name>
          <xsl:value-of select="cit:name/gco:CharacterString"/>
        </name>        
        <abstract><xsl:value-of select="cit:description/gco:CharacterString"/></abstract>
        <description><xsl:value-of select="cit:description/gco:CharacterString"/></description>
        <protocol><xsl:value-of select="cit:protocol/gco:CharacterString"/></protocol>
      </relation>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
