<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
  xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template
    match="mdb:MD_Metadata">
    <xsl:variable name="revisionDate" 
                  select="mdb:dateInfo/cit:CI_Date
      [cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']
      /cit:date/*"/>
    <dateStamp>
      <xsl:choose>
        <xsl:when test="normalize-space($revisionDate)">
          <xsl:value-of select="$revisionDate"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mdb:dateInfo/cit:CI_Date
            [cit:dateType/cit:CI_DateTypeCode/@codeListValue='creation']
            /cit:date/*"/>
          <!-- TODO: Should we handle when no creation nor revision date
          defined ? -->
        </xsl:otherwise>
      </xsl:choose>
    </dateStamp>
  </xsl:template>
</xsl:stylesheet>