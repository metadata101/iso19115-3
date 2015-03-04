<?xml version="1.0" encoding="UTF-8"?>
<!--  
Stylesheet used to update metadata for a service and 
attached it to the metadata for data.
-->
<xsl:stylesheet version="2.0" xmlns:gmd="http://standards.iso.org/19115/-3/gmd"
                xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
                xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
                xmlns:mrc="http://standards.iso.org/19115/-3/mrc/1.0/2014-12-25"
                xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:param name="uuidref"/>
  <xsl:param name="siteUrl"/>

  <xsl:template match="/mdb:MD_Metadata|*[@gco:isoType='mdb:MD_Metadata']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <xsl:apply-templates select="mdb:metadataIdentifier"/>
      <xsl:apply-templates select="mdb:defaultLocale"/>
      <xsl:apply-templates select="mdb:parentMetadata"/>
      <xsl:apply-templates select="mdb:metadataScope"/>
      <xsl:apply-templates select="mdb:contact"/>
      <xsl:apply-templates select="mdb:dateInfo"/>
      <xsl:apply-templates select="mdb:metadataStandard"/>
      <xsl:apply-templates select="mdb:metadataProfile"/>
      <xsl:apply-templates select="mdb:alternativeMetadataReference"/>
      <xsl:apply-templates select="mdb:otherLocale"/>
      <xsl:apply-templates select="mdb:metadataLinkage"/>
      <xsl:apply-templates select="mdb:spatialRepresentationInfo"/>
      <xsl:apply-templates select="mdb:referenceSystemInfo"/>
      <xsl:apply-templates select="mdb:metadataExtensionInfo"/>
      <xsl:apply-templates select="mdb:identificationInfo"/>


      <xsl:choose>
        <!-- Check if featureCatalogueCitation for uuidref -->
        <xsl:when
            test="mdb:contentInfo/mrc:MD_FeatureCatalogueDescription/gmd:featureCatalogueCitation[@uuidref = $uuidref]">
          <mdb:contentInfo>
            <mrc:MD_FeatureCatalogueDescription>
              <xsl:copy-of select="mdb:contentInfo/mrc:MD_FeatureCatalogueDescription/mrc:featureCatalogueCitation[@uuidref = $uuidref]/../mrc:complianceCode|
                                mdb:contentInfo/mrc:MD_FeatureCatalogueDescription/mrc:featureCatalogueCitation[@uuidref = $uuidref]/../mrc:language|
                                mdb:contentInfo/mrc:MD_FeatureCatalogueDescription/mrc:featureCatalogueCitation[@uuidref = $uuidref]/../mrc:includedWithDataset|
                                mdb:contentInfo/mrc:MD_FeatureCatalogueDescription/mrc:featureCatalogueCitation[@uuidref = $uuidref]/../mrc:featureTypes"/>

              <!-- Add xlink:href featureCatalogueCitation -->
              <mrc:featureCatalogueCitation uuidref="{$uuidref}"
                                            xlink:href="{$siteUrl}/csw?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;outputSchema=http://standards.iso.org/19115/-3/gmd&amp;elementSetName=full&amp;id={$uuidref}">
                <xsl:copy-of
                    select="mdb:contentInfo/mrc:MD_FeatureCatalogueDescription/mrc:featureCatalogueCitation[@uuidref = $uuidref]/cit:CI_Citation"/>
              </mrc:featureCatalogueCitation>

            </mrc:MD_FeatureCatalogueDescription>
          </mdb:contentInfo>
        </xsl:when>

        <xsl:otherwise>
          <xsl:copy-of select="gmd:contentInfo"/>
          <mdb:contentInfo>
            <mrc:MD_FeatureCatalogueDescription>
              <mrc:includedWithDataset/>
              <mrc:featureCatalogueCitation uuidref="{$uuidref}"
                                            xlink:href="{$siteUrl}/csw?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;outputSchema=http://standards.iso.org/19115/-3/gmd&amp;elementSetName=full&amp;id={$uuidref}"/>
            </mrc:MD_FeatureCatalogueDescription>
          </mdb:contentInfo>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="mdb:distributionInfo"/>
      <xsl:apply-templates select="mdb:dataQualityInfo"/>
      <xsl:apply-templates select="mdb:resourceLineage"/>
      <xsl:apply-templates select="mdb:portrayalCatalogueInfo"/>
      <xsl:apply-templates select="mdb:metadataConstraints"/>
      <xsl:apply-templates select="mdb:applicationSchemaInfo"/>
      <xsl:apply-templates select="mdb:metadataMaintenance"/>
      <xsl:apply-templates select="mdb:acquisitionInformation"/>
    </xsl:copy>

  </xsl:template>

  <!-- Remove geonet:* elements. -->
  <xsl:template match="gn:*" priority="2"/>

  <!-- Copy everything. -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>