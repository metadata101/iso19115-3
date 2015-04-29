<?xml version="1.0" encoding="UTF-8"?>
<!--  
Stylesheet used to link a dataset to a service 
metadata record by adding a operatesOn and 
a coupledResource reference.
-->
<xsl:stylesheet version="2.0"
                xmlns:gco="http://standards.iso.org/19115/-3/gco/1.0"
                xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0"
                xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0"
                xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn="http://www.fao.org/geonetwork"
                exclude-result-prefixes="#all">

  <!-- UUID of the dataset metadata -->
  <xsl:param name="uuidref"/>
  
  <!-- List of layers -->
  <xsl:param name="scopedName"/>

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
              
              <xsl:if test="$uuidref">
                <xsl:copy-of select="$coupledResource"/>  
              </xsl:if>
              
              <xsl:copy-of
                select="mdb:identificationInfo/*/srv:operatedDataset|
                mdb:identificationInfo/*/srv:profile|
                mdb:identificationInfo/*/srv:serviceStandard|
                mdb:identificationInfo/*/srv:containsOperations"/>
              
              <xsl:if test="$uuidref">
                <srv:operatesOn uuidref="{$uuidref}"
                  xlink:href="{$siteUrl}/csw?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;outputSchema=http://www.isotc211.org/2005/gmd&amp;elementSetName=full&amp;id={$uuidref}"/>
              </xsl:if>
              
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
      
      <xsl:apply-templates select="mdb:contentInfo"/>
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