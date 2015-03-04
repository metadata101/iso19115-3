<xsl:stylesheet version="2.0" 
    xmlns:mds="http://standards.iso.org/19115/-3/mds/1.0/2014-12-25"
    xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0/2014-12-25"
    xmlns:gex="http://standards.iso.org/19115/-3/gex/1.0/2014-12-25"
    xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0/2014-12-25"
    xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
    xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"
    xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:java="java:org.fao.geonet.util.XslUtil"
    xmlns:joda="java:org.fao.geonet.domain.ISODate"
    xmlns:mime="java:org.fao.geonet.util.MimeTypeFinder"
    exclude-result-prefixes="#all">
    
    <!-- ========================================================================================= -->
    <!-- latlon coordinates indexed as numeric. -->
    
    <xsl:template match="*" mode="latLon19115-3">
        <xsl:variable name="format" select="'##.00'"></xsl:variable>
        
        <xsl:if test="number(gex:westBoundLongitude/gco:Decimal)
            and number(gex:southBoundLatitude/gco:Decimal)
            and number(gex:eastBoundLongitude/gco:Decimal)
            and number(gex:northBoundLatitude/gco:Decimal)
            ">
            <Field name="westBL" string="{format-number(gex:westBoundLongitude/gco:Decimal, $format)}" store="false" index="true"/>
            <Field name="southBL" string="{format-number(gex:southBoundLatitude/gco:Decimal, $format)}" store="false" index="true"/>
            
            <Field name="eastBL" string="{format-number(gex:eastBoundLongitude/gco:Decimal, $format)}" store="false" index="true"/>
            <Field name="northBL" string="{format-number(gex:northBoundLatitude/gco:Decimal, $format)}" store="false" index="true"/>
            
            <Field name="geoBox" string="{concat(gex:westBoundLongitude/gco:Decimal, '|', 
                gex:southBoundLatitude/gco:Decimal, '|', 
                gex:eastBoundLongitude/gco:Decimal, '|', 
                gex:northBoundLatitude/gco:Decimal
                )}" store="true" index="false"/>
        </xsl:if>
        
    </xsl:template>


  <!-- iso3code of default index language -->
  <xsl:variable name="defaultLang">eng</xsl:variable>

  <xsl:template name="langId19115-3">
      <xsl:variable name="tmp">
          <xsl:choose>
              <xsl:when test="/*[name(.)='mds:MD_Metadata' or @gco:isoType='mds:MD_Metadata']/mds:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
                  <xsl:value-of select="/*[name(.)='mds:MD_Metadata' or @gco:isoType='mds:MD_Metadata']/mds:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue"/>
              </xsl:when>
              <xsl:otherwise><xsl:value-of select="$defaultLang"/></xsl:otherwise>
          </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string($tmp))"></xsl:value-of>
  </xsl:template>


  <xsl:template name="defaultTitle">
      <xsl:param name="isoDocLangId"/>

      <xsl:variable name="poundLangId" select="concat('#',upper-case(java:twoCharLangCode($isoDocLangId)))" />

      <xsl:variable name="identification" select="/*[name(.)='mds:MD_Metadata' or @gco:isoType='mds:MD_Metadata']/mds:identificationInfo/*"></xsl:variable>
      <xsl:variable name="docLangTitle" select="$identification/mri:citation/*/cit:title//lan:LocalisedCharacterString[@locale=$poundLangId]"/>
      <xsl:variable name="charStringTitle" select="$identification/mri:citation/*/cit:title/gco:CharacterString"/>
      <xsl:variable name="locStringTitles" select="$identification/mri:citation/*/cit:title//lan:LocalisedCharacterString"/>
      <xsl:choose>
      <xsl:when    test="string-length(string($docLangTitle)) != 0">
          <xsl:value-of select="$docLangTitle[1]"/>
      </xsl:when>
      <xsl:when    test="string-length(string($charStringTitle[1])) != 0">
          <xsl:value-of select="string($charStringTitle[1])"/>
      </xsl:when>
      <xsl:otherwise>
          <xsl:value-of select="string($locStringTitles[1])"/>
      </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <xsl:template name="getMimeTypeFile">
    <xsl:param name="datadir"/>
    <xsl:param name="fname"/>
    <xsl:value-of select="mime:detectMimeTypeFile($datadir,$fname)"/>
  </xsl:template>

  <xsl:template name="getMimeTypeUrl">
    <xsl:param name="linkage"/>
    <xsl:value-of select="mime:detectMimeTypeUrl($linkage)"/>
  </xsl:template>



  <xsl:template name="newGmlTime">
    <xsl:param name="begin"/>
    <xsl:param name="end"/>

    <xsl:variable name="value1">
      <xsl:call-template name="fixNonIso">
        <xsl:with-param name="value" select="normalize-space($begin)"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="value2">
      <xsl:call-template name="fixNonIso">
        <xsl:with-param name="value" select="normalize-space($end)"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- must be a full ISODateTimeFormat - so parse it and make sure it is
         returned as a long format using the joda Java Time library -->
    <xsl:value-of select="joda:parseISODateTimes($value1,$value2)"/>
  </xsl:template>




  <xsl:template name="fixNonIso">
    <xsl:param name="value"/>

    <xsl:choose>
      <xsl:when test="$value='' or
                      lower-case($value)='unknown' or
                      lower-case($value)='current' or
                      lower-case($value)='now'">
        <xsl:variable name="df">[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:variable>
        <xsl:value-of select="format-dateTime(current-dateTime(),$df)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
