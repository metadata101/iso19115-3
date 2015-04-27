<?xml version="1.0" encoding="UTF-8"?>
<!--  
Stylesheet used to update metadata for a service and 
attached it to the metadata for data.
-->
<xsl:stylesheet version="2.0"
                xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
                xmlns:srv="http://standards.iso.org/19115/-3/srv/1.0/2014-12-25"
                xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"
                xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0/2014-12-25"
                xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
                xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn="http://www.fao.org/geonetwork"
                exclude-result-prefixes="#all">

  <!-- Linking a dataset to a service -->
  <!-- UUID of the metadata to attached to the service -->
  <xsl:param name="uuidref"/>

  <!-- Comma separated values of layers to attached to -->
  <xsl:param name="scopedName"/>



  <!-- Linking a service to a dataset -->
  <!-- Protocol of the service to attach to the dataset record -->
  <xsl:param name="protocol" select="'OGC:WMS-1.1.1-http-get-map'"/>

  <!-- URL of the service -->
  <xsl:param name="url"/>

  <!-- Optional description -->
  <xsl:param name="desc"/>



  <xsl:param name="siteUrl"/>


  <xsl:template match="/mdb:MD_Metadata">
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


      <!-- Check current metadata is a service metadata record
        And add the link to the dataset -->
      <xsl:choose>
        <xsl:when
            test="mdb:identificationInfo/srv:SV_ServiceIdentification">
          <mdb:identificationInfo>
            <srv:SV_ServiceIdentification>
              <xsl:copy-of
                      select="mdb:identificationInfo/*/mri:*"/>

              <xsl:copy-of
                  select="mdb:identificationInfo/*/srv:serviceType|
                          mdb:identificationInfo/*/srv:serviceTypeVersion|
                          mdb:identificationInfo/*/srv:accessProperties|
                          mdb:identificationInfo/*/srv:couplingType|
                          mdb:identificationInfo/*/srv:coupledResource[*/srv:resourceReference/@uuidref != $uuidref]"/>


              <!-- Handle SV_CoupledResource -->
              <xsl:variable name="coupledResource">
                <xsl:for-each select="tokenize($scopedName, ',')">
                  <srv:coupledResource>
                    <srv:SV_CoupledResource>
                      <srv:scopedName>
                        <gco:ScopedName>
                          <xsl:value-of select="."/>
                        </gco:ScopedName>
                      </srv:scopedName>
                      <srv:resourceReference uuidref="{$uuidref}"/>
                    </srv:SV_CoupledResource>
                  </srv:coupledResource>
                </xsl:for-each>
              </xsl:variable>

              <xsl:copy-of select="$coupledResource"/>


              <xsl:copy-of
                  select="mdb:identificationInfo/*/srv:operatedDataset|
                          mdb:identificationInfo/*/srv:profile|
                          mdb:identificationInfo/*/srv:serviceStandard|
                          mdb:identificationInfo/*/srv:containsOperations"/>

              <srv:operatesOn uuidref="{$uuidref}"
                              xlink:href="{$siteUrl}/csw?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;outputSchema=http://www.isotc211.org/2005/gmd&amp;elementSetName=full&amp;id={$uuidref}"/>

              <xsl:copy-of
                      select="mdb:identificationInfo/*/srv:containsChain"/>
            </srv:SV_ServiceIdentification>
          </mdb:identificationInfo>
        </xsl:when>
        <xsl:otherwise>
          <!-- Probably a dataset metadata record -->
          <xsl:copy-of select="mdb:identificationInfo"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:copy-of select="mri:contentInfo"/>


      <xsl:choose>
        <xsl:when
            test="mdb:identificationInfo/srv:SV_ServiceIdentification">
          <xsl:copy-of select="mri:distributionInfo"/>
        </xsl:when>
        <!-- In a dataset add a link in the distribution section -->
        <xsl:otherwise>
          <!-- TODO we could check if online resource already exists before adding information -->
          <mdb:distributionInfo>
            <mrd:MD_Distribution>
              <xsl:copy-of
                  select="mrd:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat"/>
              <xsl:copy-of
                  select="mrd:distributionInfo/mrd:MD_Distribution/mrd:distributor"/>
              <mrd:transferOptions>
                <mrd:MD_DigitalTransferOptions>
                  <xsl:copy-of
                      select="mrd:distributionInfo/mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:unitsOfDistribution"/>
                  <xsl:copy-of
                      select="mrd:distributionInfo/mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:transferSize"/>
                  <xsl:copy-of
                      select="mrd:distributionInfo/mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:onLine"/>

                  <xsl:for-each select="tokenize($scopedName, ',')">
                    <mrd:onLine>
                      <cit:CI_OnlineResource>
                        <cit:linkage>
                          <gco:CharacterString>
                            <xsl:value-of select="$url"/>
                          </gco:CharacterString>
                        </cit:linkage>
                        <cit:protocol>
                          <gco:CharacterString>
                            <xsl:value-of select="$protocol"/>
                          </gco:CharacterString>
                        </cit:protocol>
                        <cit:name>
                          <gco:CharacterString>
                            <xsl:value-of select="."/>
                          </gco:CharacterString>
                        </cit:name>
                        <cit:description>
                          <gco:CharacterString>
                            <xsl:value-of select="."/>
                          </gco:CharacterString>
                        </cit:description>
                      </cit:CI_OnlineResource>
                    </mrd:onLine>
                  </xsl:for-each>
                  <xsl:copy-of
                      select="mrd:distributionInfo/mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:offLine"
                      />
                </mrd:MD_DigitalTransferOptions>
              </mrd:transferOptions>
              <xsl:copy-of
                  select="mrd:distributionInfo/mrd:MD_Distribution/mrd:transferOptions[position() > 1]"
                  />
            </mrd:MD_Distribution>

          </mdb:distributionInfo>
        </xsl:otherwise>
      </xsl:choose>


      <xsl:apply-templates select="mdb:dataQualityInfo"/>
      <xsl:apply-templates select="mdb:resourceLineage"/>
      <xsl:apply-templates select="mdb:portrayalCatalogueInfo"/>
      <xsl:apply-templates select="mdb:metadataConstraints"/>
      <xsl:apply-templates select="mdb:applicationSchemaInfo"/>
      <xsl:apply-templates select="mdb:metadataMaintenance"/>
      <xsl:apply-templates select="mdb:acquisitionInformation"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>