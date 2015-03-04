<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
                xmlns:dqm="http://standards.iso.org/19157/-2/dqm/1.0/2014-12-25"
                xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
                xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0/2014-12-25"
                xmlns:mcc="http://standards.iso.org/19115/-3/mcc/1.0/2014-12-25"
                xmlns:mrc="http://standards.iso.org/19115/-3/mrc/1.0/2014-12-25"
                xmlns:mco="http://standards.iso.org/19115/-3/mco/1.0/2014-12-25"
                xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
                xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"
                xmlns:mrs="http://standards.iso.org/19115/-3/mrs/1.0/2014-12-25"
                xmlns:mrl="http://standards.iso.org/19115/-3/mrl/1.0/2014-12-25"
                xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0/2014-12-25"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0/2014-12-25"
                xmlns:gcx="http://standards.iso.org/19115/-3/gcx/1.0/2014-12-25"
                xmlns:gex="http://standards.iso.org/19115/-3/gex/1.0/2014-12-25"
                xmlns:gfc="http://standards.iso.org/19110/gfc/1.1/2014-12-25"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#">


  <!-- Load INSPIRE theme thesaurus if available -->
  <xsl:variable name="inspire-thesaurus"
                select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>

  <xsl:variable name="inspire-theme"
                select="if ($inspire-thesaurus//skos:Concept)
                        then $inspire-thesaurus//skos:Concept
                        else ''"/>



  <!-- Metadata UUID. -->
  <xsl:variable name="fileIdentifier"
                select="//(mdb:MD_Metadata|*[contains(@gco:isoType,'mdb:MD_Metadata')])/
                            mdb:metadataIdentifier[1]/
                            mcc:MD_Identifier/mcc:code/*"/>



  <!-- Get the language -->
  <xsl:variable name="documentMainLanguage">
    <xsl:call-template name="langId19115-3"/>
  </xsl:variable>

  <xsl:template name="CommonFieldsFactory">

    <!-- The default title in the main language -->
    <xsl:variable name="_defaultTitle">
      <xsl:call-template name="defaultTitle">
        <xsl:with-param name="isoDocLangId" select="$documentMainLanguage"/>
      </xsl:call-template>
    </xsl:variable>

    <Field name="_defaultTitle"
           string="{string($_defaultTitle)}"
           store="true"
           index="true"/>

  </xsl:template>


</xsl:stylesheet>