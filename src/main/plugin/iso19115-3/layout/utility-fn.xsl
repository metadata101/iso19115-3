<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0"
  xmlns:gn-fn-iso19115-3="http://geonetwork-opensource.org/xsl/functions/profiles/iso19115-3"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  exclude-result-prefixes="#all">


  <!-- Get language id attribute defined in
  the metadata PT_Locale section matching the lang
  parameter. If not found, return the lang parameter
  prefixed by #.
        -->
  <xsl:function name="gn-fn-iso19115-3:getLangId" as="xs:string">
    <xsl:param name="md"/>
    <xsl:param name="lang"/>

    <xsl:variable name="languageIdentifier"
                  select="$md/lan:locale/lan:PT_Locale[
          lan:languageCode/lan:LanguageCode/@codeListValue = $lang]/@id"/>
    <xsl:choose>
      <xsl:when
        test="$languageIdentifier">
        <xsl:value-of
          select="concat('#', $languageIdentifier)"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('#', upper-case($lang))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:function name="gn-fn-iso19115-3:getCodeListType" as="xs:string">
    <xsl:param name="name" as="xs:string"/>
    
    <xsl:variable name="configType"
                  select="$editorConfig/editor/fields/for[@name = $name]/@use"/>
    
    <xsl:value-of select="if ($configType) then $configType else 'select'"/>
  </xsl:function>
</xsl:stylesheet>
