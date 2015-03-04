<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron">

  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="cit" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/cit.sch')"/>
  <xsl:variable name="gex" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/gex.sch')"/>
  <xsl:variable name="mco" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/mco.sch')"/>
  <xsl:variable name="mdb" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/mdb.sch')"/>
  <xsl:variable name="mex" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/mex.sch')"/>
  <xsl:variable name="mmi" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/mmi.sch')"/>
  <xsl:variable name="mrc" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/mrc.sch')"/>
  <xsl:variable name="mrd" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/mrd.sch')"/>
  <xsl:variable name="mri" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/mri.sch')"/>
  <xsl:variable name="mrs" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/mrs.sch')"/>
  <xsl:variable name="srv" select="document('src/main/plugin/iso19115-3/schema/schematron/rules/srv.sch')"/>


  <xsl:template match="/">
    <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

      <sch:title xmlns="http://www.w3.org/2001/XMLSchema"
                 xml:lang="en">Schematron validation for ISO 19115-1:2014 standard</sch:title>
      <sch:title xmlns="http://www.w3.org/2001/XMLSchema"
                 xml:lang="fr">Règles de validation pour le standard ISO 19115-1:2014</sch:title>


      <sch:ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>

      <sch:ns prefix="srv" uri="http://standards.iso.org/19115/-3/srv/2.0/2014-12-25"/>


      <sch:ns prefix="cit" uri="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"/>
      <sch:ns prefix="gex" uri="http://standards.iso.org/19115/-3/gex/1.0/2014-12-25"/>
      <sch:ns prefix="mco" uri="http://standards.iso.org/19115/-3/mco/1.0/2014-12-25"/>
      <sch:ns prefix="mdb" uri="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"/>
      <sch:ns prefix="mex" uri="http://standards.iso.org/19115/-3/mex/1.0/2014-12-25"/>
      <sch:ns prefix="mmi" uri="http://standards.iso.org/19115/-3/mmi/1.0/2014-12-25"/>
      <sch:ns prefix="gmw" uri="http://standards.iso.org/19139/gmw/1.0/2014-12-25"/>
      <sch:ns prefix="mrc" uri="http://standards.iso.org/19115/-3/mrc/1.0/2014-12-25"/>
      <sch:ns prefix="mrd" uri="http://standards.iso.org/19115/-3/mrd/1.0/2014-12-25"/>
      <sch:ns prefix="mri" uri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"/>
      <sch:ns prefix="mrs" uri="http://standards.iso.org/19115/-3/mrs/1.0/2014-12-25"/>
      <sch:ns prefix="mcc" uri="http://standards.iso.org/19115/-3/mcc/1.0/2014-12-25"/>
      <sch:ns prefix="lan" uri="http://standards.iso.org/19115/-3/lan/1.0/2014-12-25"/>
      <sch:ns prefix="gco" uri="http://standards.iso.org/19139/gco/1.0/2014-12-25"/>

      <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
      <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
      <sch:ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema"/>
      


      <xsl:copy-of select="$cit//sch:pattern|$cit//sch:diagnostics"/>
      <xsl:copy-of select="$gex//sch:pattern|$gex//sch:diagnostics"/>
      <xsl:copy-of select="$mco//sch:pattern|$mco//sch:diagnostics"/>
      <xsl:copy-of select="$mdb//sch:pattern|$mdb//sch:diagnostics"/>
      <xsl:copy-of select="$mex//sch:pattern|$mex//sch:diagnostics"/>
      <xsl:copy-of select="$mmi//sch:pattern|$mmi//sch:diagnostics"/>
      <xsl:copy-of select="$mrc//sch:pattern|$mrc//sch:diagnostics"/>
      <xsl:copy-of select="$mrd//sch:pattern|$mrd//sch:diagnostics"/>
      <xsl:copy-of select="$mri//sch:pattern|$mri//sch:diagnostics"/>
      <xsl:copy-of select="$mrs//sch:pattern|$mrs//sch:diagnostics"/>
      <xsl:copy-of select="$srv//sch:pattern|$srv//sch:diagnostics"/>



    </sch:schema>
  </xsl:template>

</xsl:stylesheet>