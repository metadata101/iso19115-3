<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gml="http://www.opengis.net/gml/3.2" 
  xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0/2014-12-25"
  xmlns:gcx="http://standards.iso.org/19115/-3/gcx/1.0/2014-12-25"
  xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
  xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
  xmlns:mcc="http://standards.iso.org/19115/-3/mcc/1.0/2014-12-25"
  xmlns:mrc="http://standards.iso.org/19115/-3/mrc/1.0/2014-12-25"
  xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0/2014-12-25"
  xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
  xmlns:dqm="http://standards.iso.org/19157/-2/dqm/1.0/2014-12-25"
  xmlns:gfc="http://standards.iso.org/19110/gfc/1.1/2014-12-25"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:gn="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all">
  
  <xsl:import href="convert/create19115-3Namespaces.xsl"/>
  
  <xsl:include href="convert/functions.xsl"/>


  <!-- If no metadata linkage exist, build one based on
  the metadata UUID. -->
  <xsl:variable name="createMetadataLinkage" select="true()"/>
  <xsl:variable name="url" select="/root/env/siteURL"/>
  <xsl:variable name="uuid" select="/root/env/uuid"/>

  <xsl:template match="/root">
    <xsl:apply-templates select="mdb:MD_Metadata"/>
  </xsl:template>
  
  <xsl:template match="mdb:MD_Metadata">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      
      <xsl:call-template name="add-iso19115-3-namespaces"/>
      
      <!-- Add metadataIdentifier if it doesn't exist -->
      <mdb:metadataIdentifier>
        <mcc:MD_Identifier>
          <!-- authority could be for this GeoNetwork node ?
            <mcc:authority><cit:CI_Citation>etc</cit:CI_Citation></mcc:authority>
          -->
          <mcc:code>
            <gco:CharacterString><xsl:value-of select="/root/env/uuid"/></gco:CharacterString>
          </mcc:code>
          <mcc:codeSpace>
            <gco:CharacterString>urn:uuid</gco:CharacterString>
          </mcc:codeSpace>
        </mcc:MD_Identifier>
      </mdb:metadataIdentifier>
      
      <xsl:apply-templates select="mdb:defaultLocale"/>
      <xsl:apply-templates select="mdb:parentMetadata"/>
      <xsl:apply-templates select="mdb:metadataScope"/>
      <xsl:apply-templates select="mdb:contact"/>
      
      <!-- Add dateInfo creation and revision if they don't exist -->
      <xsl:if test="not(mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='creation']) and /root/env/changeDate">
        <mdb:dateInfo>
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="creation"/>
            </cit:dateType>
          </cit:CI_Date>
        </mdb:dateInfo>
      </xsl:if>
      <xsl:if test="not(mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']) and /root/env/changeDate">
        <mdb:dateInfo>
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision"/>
            </cit:dateType>
          </cit:CI_Date>
        </mdb:dateInfo>
      </xsl:if>
      <xsl:apply-templates select="mdb:dateInfo"/>
      
      <!-- Add metadataStandard if it doesn't exist -->
      <xsl:choose>
        <xsl:when test="not(mdb:metadataStandard)">
          <mdb:metadataStandard>
            <cit:CI_Citation>
              <cit:title>
                <gco:CharacterString>ISO 19115-3</gco:CharacterString>
              </cit:title>
            </cit:CI_Citation>
          </mdb:metadataStandard>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="mdb:metadataStandard"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:apply-templates select="mdb:metadataProfile"/>
      <xsl:apply-templates select="mdb:alternativeMetadataReference"/>
      <xsl:apply-templates select="mdb:otherLocale"/>
      <xsl:apply-templates select="mdb:metadataLinkage"/>

      <xsl:variable name="pointOfTruthUrl" select="concat($url, '/search?uuid=', $uuid)"/>

      <xsl:if test="$createMetadataLinkage and count(mdb:metadataLinkage/cit:CI_OnlineResource/cit:linkage/*[. = $pointOfTruthUrl]) = 0">
        <!-- TODO: This should only be updated for not harvested records ? -->
        <mdb:metadataLinkage>
          <cit:CI_OnlineResource>
            <cit:linkage>
              <!-- TODO: define a URL pattern and use it here -->
              <!-- TODO: URL could be multilingual ? -->
              <gco:CharacterString><xsl:value-of select="$pointOfTruthUrl"/></gco:CharacterString>
            </cit:linkage>
            <!-- TODO: Could be relevant to add description of the
            point of truth for the metadata linkage but this
            needs to be language dependant. -->
            <cit:function>
              <cit:CI_OnLineFunctionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_OnLineFunctionCode"
                                         codeListValue="completeMetadata"/>
            </cit:function>
          </cit:CI_OnlineResource>
        </mdb:metadataLinkage>
      </xsl:if>

      <xsl:apply-templates select="mdb:spatialRepresentationInfo"/>
      <xsl:apply-templates select="mdb:referenceSystemInfo"/>
      <xsl:apply-templates select="mdb:metadataExtensionInfo"/>
      <xsl:apply-templates select="mdb:identificationInfo"/>
      <xsl:apply-templates select="mdb:contentInfo"/>
      <xsl:apply-templates select="mdb:distributionInfo"/>
      <xsl:apply-templates select="mdb:dataQualityInfo"/>
      <xsl:apply-templates select="mdb:resourceLineage"/>
      <xsl:apply-templates select="mdb:portrayalCatalogueInfo"/>
      <xsl:apply-templates select="mdb:metadataConstraints"/>
      <xsl:apply-templates select="mdb:applicationSchemaInfo"/>
      <xsl:apply-templates select="mdb:metadataMaintenance"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Update revision date -->
  <xsl:template match="mdb:dateInfo[cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue='lastUpdate']">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="/root/env/changeDate">
          <cit:CI_Date>
            <cit:date>
              <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
            </cit:date>
            <cit:dateType>
              <cit:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="lastUpdate"/>
            </cit:dateType>
          </cit:CI_Date>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="@gml:id">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- Fix srsName attribute generate CRS:84 (EPSG:4326 with long/lat 
    ordering) by default -->
  <xsl:template match="@srsName">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="srsName">
          <xsl:text>CRS:84</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Add required gml attributes if missing -->
  <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]">
    <xsl:copy>
      <xsl:attribute name="gml:id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:attribute name="srsName">
        <xsl:text>urn:x-ogc:def:crs:EPSG:6.6:4326</xsl:text>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="*[gco:CharacterString]">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(name()='gco:nilReason')]"/>
      <xsl:choose>
        <xsl:when test="normalize-space(gco:CharacterString)=''">
          <xsl:attribute name="gco:nilReason">
            <xsl:choose>
              <xsl:when test="@gco:nilReason"><xsl:value-of select="@gco:nilReason"/></xsl:when>
              <xsl:otherwise>missing</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@gco:nilReason!='missing' and normalize-space(gco:CharacterString)!=''">
          <xsl:copy-of select="@gco:nilReason"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- codelists: set @codeList path -->
  <xsl:template match="lan:LanguageCode[@codeListValue]" priority="10">
    <lan:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>
    </lan:LanguageCode>
  </xsl:template>
  
  <xsl:template match="dqm:*[@codeListValue]" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of select="concat('http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19157_Schemas/resources/codelist/ML_gmxCodelists.xml#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[@codeListValue]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of select="concat('http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- online resources: download -->
  <xsl:template match="cit:CI_OnlineResource[matches(cit:protocol/gco:CharacterString,'^WWW:DOWNLOAD-.*-http--download.*') and cit:name]">
    <xsl:variable name="fname" select="cit:name/gco:CharacterString|cit:name/gcx:MimeFileType"/>
    <xsl:variable name="mimeType">
      <xsl:call-template name="getMimeTypeFile">
        <xsl:with-param name="datadir" select="/root/env/datadir"/>
        <xsl:with-param name="fname" select="$fname"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <cit:linkage>
        <cit:URL>
          <xsl:choose>
            <xsl:when test="/root/env/config/downloadservice/simple='true'">
              <xsl:value-of select="concat(/root/env/siteURL,'/resources.get?uuid=',/root/env/uuid,'&amp;fname=',$fname,'&amp;access=private')"/>
            </xsl:when>
            <xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
              <xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?uuid=',/root/env/uuid,'&amp;fname=',$fname,'&amp;access=private')"/>
            </xsl:when>
            <xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
              <xsl:value-of select="cit:linkage/gco:CharacterString"/>
            </xsl:otherwise>
          </xsl:choose>
        </cit:URL>
      </cit:linkage>
      <xsl:copy-of select="cit:protocol"/>
      <xsl:copy-of select="cit:applicationProfile"/>
      <cit:name>
        <gcx:MimeFileType type="{$mimeType}">
          <xsl:value-of select="$fname"/>
        </gcx:MimeFileType>
      </cit:name>
      <xsl:copy-of select="cit:description"/>
      <xsl:copy-of select="cit:function"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- online resources: link-to-downloadable data etc -->
  <xsl:template match="cit:CI_OnlineResource[starts-with(cit:protocol/gco:CharacterString,'WWW:LINK-') and contains(cit:protocol/gco:CharacterString,'http--download')]">
    <xsl:variable name="mimeType">
      <xsl:call-template name="getMimeTypeUrl">
        <xsl:with-param name="linkage" select="cit:linkage/gco:CharacterString"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="cit:linkage"/>
      <xsl:copy-of select="cit:protocol"/>
      <xsl:copy-of select="cit:applicationProfile"/>
      <cit:name>
        <gcx:MimeFileType type="{$mimeType}"/>
      </cit:name>
      <xsl:copy-of select="cit:description"/>
      <xsl:copy-of select="cit:function"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="gcx:FileName[name(..)!='cit:contactInstructions']">
    <xsl:copy>
      <xsl:attribute name="src">
        <xsl:choose>
          <xsl:when test="/root/env/config/downloadservice/simple='true'">
            <xsl:value-of select="concat(/root/env/siteURL,'/resources.get?uuid=',/root/env/uuid,'&amp;fname=',.,'&amp;access=private')"/>
          </xsl:when>
          <xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
            <xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?uuid=',/root/env/uuid,'&amp;fname=',.,'&amp;access=private')"/>
          </xsl:when>
          <xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
            <xsl:value-of select="@src"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Do not allow to expand operatesOn sub-elements 
    and constrain users to use uuidref attribute to link
    service metadata to datasets. This will avoid to have
    error on XSD validation. -->
  <xsl:template match="srv:operatesOn|mrc:featureCatalogueCitation">
    <xsl:copy>
      <xsl:copy-of select="@uuidref"/>
      <xsl:if test="@uuidref">
        <xsl:choose>
          <xsl:when test="not(string(@xlink:href)) or starts-with(@xlink:href, /root/env/siteURL)">
            <xsl:attribute name="xlink:href">
              <xsl:value-of select="concat(/root/env/siteURL,'/csw?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;outputSchema=http://standards.iso.org/19115/-3/gmd&amp;elementSetName=full&amp;id=',@uuidref)"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="@xlink:href"/>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:if>
    </xsl:copy>
    
  </xsl:template>
  
  
  <!-- Set local identifier to the first 3 letters of iso code. Locale ids
    are used for multilingual charcterString using #iso2code for referencing.
  -->
  <xsl:template match="lan:PT_Locale">
    <xsl:element name="lan:{local-name()}">
      <xsl:variable name="id" select="upper-case(
        substring(lan:language/lan:LanguageCode/@codeListValue, 1, 3))"/>
      
      <xsl:apply-templates select="@*"/>
      <xsl:if test="normalize-space(@id)='' or normalize-space(@id)!=$id">
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- Apply same changes as above to the lan:LocalisedCharacterString -->
  <xsl:variable name="language" select="//lan:PT_Locale" /> <!-- Need list of all locale -->
  
  <xsl:template match="lan:LocalisedCharacterString">
    <xsl:element name="lan:{local-name()}">
      <xsl:variable name="currentLocale" select="upper-case(replace(normalize-space(@locale), '^#', ''))"/>
      <xsl:variable name="ptLocale" select="$language[upper-case(replace(normalize-space(@id), '^#', ''))=string($currentLocale)]"/>
      <xsl:variable name="id" select="upper-case(substring($ptLocale/lan:language/lan:LanguageCode/@codeListValue, 1, 3))"/>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$id != '' and ($currentLocale='' or @locale!=concat('#', $id)) ">
        <xsl:attribute name="locale">
          <xsl:value-of select="concat('#',$id)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- ================================================================= -->
  <!-- Adjust the namespace declaration - In some cases name() is used to get the 
    element. The assumption is that the name is in the format of  <ns:element> 
    however in some cases it is in the format of <element xmlns=""> so the 
    following will convert them back to the expected value. This also corrects the issue 
    where the <element xmlns=""> loose the xmlns="" due to the exclude-result-prefixes="#all" -->
  <!-- Note: Only included prefix gml, mds and gco for now. -->
  <!-- TODO: Figure out how to get the namespace prefix via a function so that we don't need to hard code them -->
  <!-- ================================================================= -->
  
  <xsl:template name="correct_ns_prefix">
    <xsl:param name="element" />
    <xsl:param name="prefix" />
    <xsl:choose>
      <xsl:when test="local-name($element)=name($element) and $prefix != '' ">
        <xsl:element name="{$prefix}:{local-name($element)}">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mdb:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'mdb'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="gco:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gco'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="gml:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gml'"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- copy everything else as is -->
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
