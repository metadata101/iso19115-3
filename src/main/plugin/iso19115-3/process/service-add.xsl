<?xml version="1.0" encoding="UTF-8"?>
<!--  
Stylesheet used to link a service to a dataset
by adding a reference to the distribution section.
-->
<xsl:stylesheet version="2.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gn-fn-iso19115-3="http://geonetwork-opensource.org/xsl/functions/profiles/iso19115-3"
                xmlns:gn="http://www.fao.org/geonetwork"
                exclude-result-prefixes="#all">
  <xsl:import href="../layout/utility-fn.xsl"/>

  <!-- Unused -->
  <xsl:param name="uuidref"/>
  
  <!-- List of layers -->
  <xsl:param name="scopedName"/>
  <xsl:param name="protocol" select="'OGC:WMS'"/>
  <xsl:param name="url"/>
  <xsl:param name="desc"/>
  
  <xsl:param name="siteUrl"/>

  <xsl:variable name="mainLang"
                select="/mdb:MD_Metadata/mdb:defaultLocale/*/lan:language/*/@codeListValue"
                as="xs:string"/>

  <xsl:variable name="useOnlyPTFreeText"
                select="count(//*[lan:PT_FreeText and not(gco:CharacterString)]) > 0"
                as="xs:boolean"/>

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
      <xsl:apply-templates select="mri:contentInfo"/>

      <xsl:choose>
        <xsl:when
            test="mdb:identificationInfo/srv:SV_ServiceIdentification">
          <!-- For service nothing to do -->
          <xsl:apply-templates select="mdb:distributionInfo"/>
        </xsl:when>
        <!-- In a dataset add a link in the distribution section if a URL is provided -->
        <xsl:otherwise>

          <xsl:variable name="nbOfDistributionSection"
                        select="count(mrd:distributionInfo)"/>
          <xsl:choose>
            <xsl:when test="$url != '' and $scopedName != '' and $nbOfDistributionSection = 0">
              <!-- Create a new one -->
              <mdb:distributionInfo>
                <mrd:MD_Distribution>
                  <mrd:transferOptions>
                    <mrd:MD_DigitalTransferOptions>
                      <xsl:call-template name="create-online"/>
                    </mrd:MD_DigitalTransferOptions>
                  </mrd:transferOptions>
                </mrd:MD_Distribution>
              </mdb:distributionInfo>
            </xsl:when>
            <xsl:when test="$url != '' and $nbOfDistributionSection > 0">
              <mdb:distributionInfo>
                <mrd:MD_Distribution>
                  <xsl:copy-of
                          select="mrd:distributionInfo[1]/mrd:MD_Distribution/mrd:description"/>
                  <xsl:copy-of
                          select="mrd:distributionInfo[1]/mrd:MD_Distribution/mrd:distributionFormat"/>
                  <xsl:copy-of
                          select="mrd:distributionInfo[1]/mrd:MD_Distribution/mrd:distributor"/>
                  <xsl:copy-of
                          select="mrd:distributionInfo[1]/mrd:MD_Distribution/mrd:transferOptions"/>

                  <mrd:transferOptions>
                    <mrd:MD_DigitalTransferOptions>
                      <xsl:call-template name="create-online"/>
                    </mrd:MD_DigitalTransferOptions>
                  </mrd:transferOptions>
                </mrd:MD_Distribution>
              </mdb:distributionInfo>
              <xsl:apply-templates select="mdb:distributionInfo[position() > 1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="mdb:distributionInfo"/>
            </xsl:otherwise>
          </xsl:choose>

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


  <xsl:template name="create-online">
    <xsl:for-each select="tokenize($scopedName, ',')">
      <mrd:onLine>
        <cit:CI_OnlineResource>
          <cit:linkage>
            <xsl:copy-of
                    select="gn-fn-iso19115-3:fillTextElement($url, $mainLang, $useOnlyPTFreeText)"/>
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
        </cit:CI_OnlineResource>
      </mrd:onLine>
    </xsl:for-each>
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