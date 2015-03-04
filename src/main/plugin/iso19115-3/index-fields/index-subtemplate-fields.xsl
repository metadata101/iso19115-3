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
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#">

  <!-- Subtemplate indexing

  Add the [count(ancestor::node()) =  1] to only match element at the root of the document.
  This is the method to identify a subtemplate.
  -->
  <xsl:template mode="index"
                match="cit:CI_Responsibility[count(ancestor::node()) =  1]">

    <xsl:variable name="org"
                  select="normalize-space(cit:party/cit:CI_Organisation/cit:name/gco:CharacterString)"/>
    <xsl:variable name="name"
                  select="string-join(.//cit:individual/cit:CI_Individual/cit:name/gco:CharacterString, ', ')"/>
    <Field name="_title"
           string="{if ($name != '')
                    then concat($org, ' (', $name, ')')
                    else $org}"
           store="true" index="true"/>
    <Field name="orgName" string="{$org}" store="true" index="true"/>

    <xsl:call-template name="subtemplate-common-fields"/>
  </xsl:template>


  <xsl:template mode="index"
                match="mcc:MD_BrowseGraphic[count(ancestor::node()) =  1]">

    <xsl:variable name="fileName"
                  select="normalize-space(mcc:fileName/gco:CharacterString)"/>
    <xsl:variable name="fileDescription"
                  select="normalize-space(mcc:fileDescription/gco:CharacterString)"/>
    <Field name="_title"
           string="{if ($fileDescription != '')
                    then $fileDescription
                    else $fileName}"
           store="true" index="true"/>
    <xsl:call-template name="subtemplate-common-fields"/>
  </xsl:template>

  <xsl:template name="subtemplate-common-fields">
    <Field name="any" string="{normalize-space(string(.))}" store="false" index="true"/>
    <Field name="_root" string="{name(.)}" store="true" index="true"/>
  </xsl:template>

</xsl:stylesheet>