<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                exclude-result-prefixes="#all">

  <!--
   This is an example template to display quality measures
   as a simple table view. In this table, only values can be edited.
  -->
  <xsl:template name="iso19115-3-qm">
    <xsl:param name="config" as="node()?"/>

    <h1><xsl:value-of select="$strings/qualityMeasures"/></h1>

    <xsl:variable name="values">
      <header>
        <col>
          <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'mdq:nameOfMeasure', $labels,'', '', '')/label"/>
        </col>
        <col>
          <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'mdq:value', $labels,'', '', '')/label"/>
        </col>
        <col>
          <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'mdq:valueUnit', $labels,'', '', '')/label"/>
        </col>
      </header>
      <xsl:for-each select="*/mdq:report/mdq:*">
        <xsl:variable name="measureName"
                      select="mdq:measure/*/mdq:nameOfMeasure/*"/>
        <xsl:variable name="measureDesc"
                      select="mdq:measure/*/mdq:measureDescription/*"/>

        <xsl:for-each select="mdq:result">
          <xsl:variable name="unit"
                        select="*/mdq:valueUnit/*/gml:identifier"/>

          <!-- TODO: Add group by date -->
          <row title="{$measureDesc}">
            <xsl:choose>
              <!-- Quantitative results with units -->
              <xsl:when test="mdq:DQ_QuantitativeResult">
                <col readonly="">
                  <xsl:value-of select="$measureName"/>
                </col>
                <col type="{*/mdq:valueRecordType/*/text()}">
                  <xsl:copy-of select="*/mdq:value/gco:*"/>
                </col>
                <col readonly="">
                  <xsl:value-of select="if ($unit/text() != '')
                                        then $unit/text()
                                        else */mdq:valueRecordType/*/normalize-space()"/>
                </col>
                <col remove="">
                  <xsl:copy-of select="ancestor::mdq:report/gn:element"/>
                </col>
              </xsl:when>
              <!-- Descriptive results -->
              <xsl:when test="mdq:DQ_DescriptiveResult">
                <col readonly="">
                  <xsl:value-of select="$measureName"/>
                  (<xsl:value-of select="gn-fn-metadata:getLabel($schema, 'mdq:DQ_DescriptiveResult', $labels,'', '', '')/label"/>)
                </col>
                <col type="textarea" colspan="2">
                  <xsl:copy-of select="*/mdq:statement/gco:*"/>
                </col>
                <col/>
              </xsl:when>
              <xsl:otherwise>
                <!-- Not supported -->
              </xsl:otherwise>
            </xsl:choose>
          </row>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <xsl:call-template name="render-table">
      <xsl:with-param name="values" select="$values"/>
      <xsl:with-param name="addControl">
        <xsl:if test="$config/@or">
          <xsl:apply-templates select="*/gn:child[@name = $config/@or]"
                               mode="mode-iso19115-3"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
