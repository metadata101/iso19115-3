<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0"
  xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0"
  xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0"
  xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0"
  xmlns:gco="http://standards.iso.org/19115/-3/gco/1.0"
  xmlns:gn="http://www.fao.org/geonetwork"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all" >
  
  <!-- TODO: could be nice to define the target distributor -->
  
  <xsl:param name="uuidref"/>
  <xsl:param name="extra_metadata_uuid"/>
  <xsl:param name="protocol" select="'OGC:WMS-1.1.1-http-get-map'"/>
  <xsl:param name="url"/>
  <xsl:param name="name"/>
  <xsl:param name="desc"/>

  <xsl:variable name="separator" select="'\|'"/>

  <xsl:variable name="mainLang"
                select="/mdb:MD_Metadata/mdb:defaultLocale/*/lan:language/*/@codeListValue"
                as="xs:string"/>

  <xsl:variable name="useOnlyPTFreeText"
                select="count(//*[lan:PT_FreeText and not(gco:CharacterString)]) > 0"
                as="xs:boolean"/>

  <xsl:template match="/mdb:MD_Metadata|*[contains(@gco:isoType, 'mdb:MD_Metadata')]">

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
      <xsl:apply-templates select="mdb:contentInfo"/>
      
      
      <xsl:choose>
        <xsl:when
          test="count(mdb:distributionInfo) = 0">
          <mdb:distributionInfo>
            <mrd:MD_Distribution>
              <mrd:transferOptions>
                <mrd:MD_DigitalTransferOptions>
                  <xsl:call-template name="fill"/>
                </mrd:MD_DigitalTransferOptions>
              </mrd:transferOptions>
            </mrd:MD_Distribution>
          </mdb:distributionInfo>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="mdb:distributionInfo">
            <xsl:copy>
              <xsl:copy-of select="@*"/>
              <mrd:MD_Distribution>
                <xsl:apply-templates select="mrd:MD_Distribution/mrd:description"/>
                <xsl:apply-templates select="mrd:MD_Distribution/mrd:distributionFormat"/>
                <xsl:apply-templates select="mrd:MD_Distribution/mrd:distributor"/>
                <xsl:choose>
                  <xsl:when test="position() = 1">
                    <mrd:transferOptions>
                      <mrd:MD_DigitalTransferOptions>
                        <xsl:apply-templates select="mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:unitsOfDistribution"/>
                        <xsl:apply-templates select="mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:transferSize"/>
                        <xsl:apply-templates select="mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:onLine"/>
                        
                        <xsl:call-template name="fill"/>
                        
                        <xsl:apply-templates select="mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:offLine"/>
                        <xsl:apply-templates select="mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:transferFrequency"/>
                        <xsl:apply-templates select="mrd:MD_Distribution/mrd:transferOptions[1]/mrd:MD_DigitalTransferOptions/mrd:distributionFormat"/>
                      </mrd:MD_DigitalTransferOptions>
                   </mrd:transferOptions>
                   
                   <xsl:apply-templates
                     select="mrd:MD_Distribution/mrd:transferOptions[position() > 1]"/>
                 </xsl:when>
                 <xsl:otherwise>
                   <xsl:apply-templates select="mrd:transferOptions"/>
                 </xsl:otherwise>
               </xsl:choose>
              </mrd:MD_Distribution>
            </xsl:copy>
          </xsl:for-each>
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
  
  <!-- Remove geonet:* elements. -->
  <xsl:template match="gn:*" priority="2"/>
  
  <!-- Copy everything. -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="fill">
    <!-- Add all online source from the target metadata to the
                    current one -->
    <xsl:if test="//extra">
      <xsl:for-each select="//extra//mrd:onLine">
        <mrd:onLine>
          <xsl:if test="$extra_metadata_uuid">
            <xsl:attribute name="uuidref" select="$extra_metadata_uuid"/>
          </xsl:if>
          <xsl:copy-of select="*"/>
        </mrd:onLine>
      </xsl:for-each>
    </xsl:if>
    
    <!-- Add online source from URL -->
    <xsl:if test="$url">
      
      <!-- If a name is provided loop on all languages -->
      <xsl:choose>
        <xsl:when test="normalize-space($name) != ''">
          <xsl:for-each select="tokenize($name, ',')">
            <mrd:onLine>
              <cit:CI_OnlineResource>
                <cit:linkage>
                  <gco:CharacterString>
                    <xsl:value-of select="$url"/>
                  </gco:CharacterString>
                </cit:linkage>

                <xsl:if test="$protocol != ''">
                  <cit:protocol>
                    <gco:CharacterString>
                      <xsl:value-of select="$protocol"/>
                    </gco:CharacterString>
                  </cit:protocol>
                </xsl:if>

                <xsl:if test="normalize-space($name) != ''">
                  <cit:name>
                    <xsl:call-template name="fillTextElement">
                      <xsl:with-param name="formattedText" select="$name"/>
                    </xsl:call-template>
                  </cit:name>
                </xsl:if>

                <xsl:if test="$desc != ''">
                  <cit:description>
                    <xsl:call-template name="fillTextElement">
                      <xsl:with-param name="formattedText" select="$desc"/>
                    </xsl:call-template>
                  </cit:description>
                </xsl:if>
              </cit:CI_OnlineResource>
            </mrd:onLine>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <mrd:onLine>
            <cit:CI_OnlineResource>
              <cit:linkage>
                <gco:CharacterString>
                  <xsl:value-of select="$url"/>
                </gco:CharacterString>
              </cit:linkage>

              <xsl:if test="$protocol != ''">
                <cit:protocol>
                  <gco:CharacterString>
                    <xsl:value-of select="$protocol"/>
                  </gco:CharacterString>
                </cit:protocol>
              </xsl:if>

              <xsl:if test="$desc != ''">
                <cit:description>
                  <xsl:call-template name="fillTextElement">
                    <xsl:with-param name="formattedText" select="$desc"/>
                  </xsl:call-template>
                </cit:description>
              </xsl:if>
            </cit:CI_OnlineResource>
          </mrd:onLine>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:if>
  </xsl:template>


  <xsl:template name="fillTextElement">
    <xsl:param name="formattedText"/>
    <xsl:choose>
      <xsl:when test="contains($formattedText, '|')">
        <lan:PT_FreeText>
          <xsl:for-each select="tokenize($formattedText, $separator)">
            <xsl:variable name="descLang"
                          select="substring-before(., '#')"/>
            <xsl:variable name="descValue"
                          select="substring-after(., '#')"/>
            <xsl:if test="$useOnlyPTFreeText = false() and $descLang = $mainLang">
              <gco:CharacterString>
                <xsl:value-of select="$descValue"/>
              </gco:CharacterString>
            </xsl:if>
          </xsl:for-each>

          <xsl:for-each select="tokenize($formattedText, $separator)">
            <xsl:variable name="descLang"
                          select="substring-before(., '#')"/>
            <xsl:variable name="descValue"
                          select="substring-after(., '#')"/>
            <xsl:if test="$useOnlyPTFreeText or $descLang != $mainLang">
              <lan:textGroup>
                <lan:LocalisedCharacterString locale="{concat('#', $descLang)}">
                  <xsl:value-of select="$descValue" />
                </lan:LocalisedCharacterString>
              </lan:textGroup>
            </xsl:if>
          </xsl:for-each>
        </lan:PT_FreeText>
      </xsl:when>
      <xsl:otherwise>
        <gco:CharacterString>
          <xsl:value-of select="if (contains($formattedText, '#'))
                                then substring-after($formattedText, '#')
                                else $formattedText"/>
        </gco:CharacterString>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
</xsl:stylesheet>