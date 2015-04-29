<?xml version="1.0" encoding="UTF-8"?>
<!--  
Stylesheet used to link a service to a dataset
by adding a reference to the distribution section.
-->
<xsl:stylesheet version="2.0"
                xmlns:gco="http://standards.iso.org/19115/-3/gco/1.0"
                xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0"
                xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0"
                xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0"
                xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0"
                xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gn="http://www.fao.org/geonetwork"
                exclude-result-prefixes="#all">
  <xsl:output indent="yes"/>

  <!-- Unused -->
  <xsl:param name="uuidref"/>
  
  <!-- List of layers -->
  <xsl:param name="scopedName"/>
  <xsl:param name="protocol" select="'OGC:WMS'"/>
  <xsl:param name="url"/>
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


      <xsl:apply-templates select="mdb:identificationInfo"/>
        
      <xsl:copy-of select="mri:contentInfo"/>

      <xsl:choose>
        <xsl:when
            test="mdb:identificationInfo/srv:SV_ServiceIdentification">
          <xsl:apply-templates select="mdb:distributionInfo"/>
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
  
  
  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Remove geonet:* elements. -->
  <xsl:template match="gn:*"
    priority="2"/>
</xsl:stylesheet>