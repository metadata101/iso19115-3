<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0"
  xmlns:mcc="http://standards.iso.org/19115/-3/mcc/1.0"
  xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0"
  xmlns:gco="http://standards.iso.org/19115/-3/gco/1.0"
  xmlns:gn="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all" version="2.0">

  <!-- 
      Usage: 
        thumbnail-from-url-add?thumbnail_url=http://geonetwork.org/thumbnails/image.png
    -->

  <!-- Thumbnail base url (mandatory) -->
  <xsl:param name="thumbnail_url"/>
  <!-- Element to use for the file name. -->
  <xsl:param name="thumbnail_desc" select="''"/>
  <xsl:param name="thumbnail_type" select="''"/>

  <xsl:template match="mri:MD_DataIdentification|
                      *[@gco:isoType='mri:MD_DataIdentification']|
                      srv:SV_ServiceIdentification">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="mri:citation"/>
      <xsl:apply-templates select="mri:abstract"/>
      <xsl:apply-templates select="mri:purpose"/>
      <xsl:apply-templates select="mri:credit"/>
      <xsl:apply-templates select="mri:status"/>
      <xsl:apply-templates select="mri:pointOfContact"/>
      <xsl:apply-templates select="mri:spatialRepresentationType"/>
      <xsl:apply-templates select="mri:spatialResolution"/>
      <xsl:apply-templates select="mri:temporalResolution"/>
      <xsl:apply-templates select="mri:topicCategory"/>
      <xsl:apply-templates select="mri:extent"/>
      <xsl:apply-templates select="mri:additionalDocumentation"/>
      <xsl:apply-templates select="mri:processingLevel"/>
      <xsl:apply-templates select="mri:resourceMaintenance"/>

      <xsl:call-template name="fill"/>

      <xsl:apply-templates select="mri:graphicOverview"/>

      <xsl:apply-templates select="mri:resourceFormat"/>
      <xsl:apply-templates select="mri:descriptiveKeywords"/>
      <xsl:apply-templates select="mri:resourceSpecificUsage"/>
      <xsl:apply-templates select="mri:resourceConstraints"/>
      <xsl:apply-templates select="mri:associatedResource"/>

      <xsl:apply-templates select="mri:defaultLocale"/>
      <xsl:apply-templates select="mri:otherLocale"/>
      <xsl:apply-templates select="mri:environmentDescription"/>
      <xsl:apply-templates select="mri:supplementalInformation"/>

      <xsl:apply-templates select="srv:*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="fill">
    <xsl:if test="$thumbnail_url != ''">
      <mri:graphicOverview>
        <mcc:MD_BrowseGraphic>
          <mcc:fileName>
            <gco:CharacterString>
              <xsl:value-of select="$thumbnail_url"/>
            </gco:CharacterString>
          </mcc:fileName>
          <xsl:if test="$thumbnail_desc!=''">
            <mcc:fileDescription>
              <gco:CharacterString>
                <xsl:value-of select="$thumbnail_desc"/>
              </gco:CharacterString>
            </mcc:fileDescription>
          </xsl:if>
          <xsl:if test="$thumbnail_type!=''">
            <mcc:fileType>
              <gco:CharacterString>
                <xsl:value-of select="$thumbnail_type"/>
              </gco:CharacterString>
            </mcc:fileType>
          </xsl:if>
        </mcc:MD_BrowseGraphic>
      </mri:graphicOverview>
    </xsl:if>
  </xsl:template>


  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Always remove geonet:* elements. -->
  <xsl:template match="gn:*" priority="2"/>
</xsl:stylesheet>