<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
                xmlns:dqm="http://standards.iso.org/iso/19157/-2/dqm/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
                xmlns:reg="http://standards.iso.org/iso/19115/-3/reg/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/1.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.1"
                xmlns:tr="java:org.fao.geonet.services.metadata.format.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <!-- This formatter render an ISO19139 record based on the
  editor configuration file.


  The layout is made in 2 modes:
  * render-field taking care of elements (eg. sections, label)
  * render-value taking care of element values (eg. characterString, URL)

  3 levels of priority are defined: 100, 50, none

  -->


  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('config-geoportail.xml')"/>

  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl"/>
  <xsl:include href="../../layout/utility-tpl-multilingual.xsl"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>
  <!--<xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/>-->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/mdb:MD_Metadata"/>

  <xsl:variable name="test" select="$metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                          contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                   'Mots-clés InfraSIG')]/*/mri:keyword/gco:CharacterString"/>

  <!-- Load associated resources -->
  <xsl:variable name="url"
                select="'http://localhost:8080/geonetwork/srv/api/records/'"/>
  <xsl:variable name="uuid"
                select="$metadata/mdb:metadataIdentifier/*/mcc:code/gco:CharacterString"/>
  <xsl:variable name="request"
                select="'/related?type=parent&amp;type=children&amp;type=services&amp;type=datasets&amp;type=hassources&amp;type=sources&amp;type=fcats&amp;type=siblings&amp;type=associated'"/>
  <xsl:variable name="globalrequest" select="concat($url, $uuid,$request)" />

  <xsl:variable name="associatedRessources"
                select="document($globalrequest)"/>

  <xsl:template
    match="/">
    <!-- contenu du template -->
    <div class="container gn-metadata-view">
      <!-- Nav tabs -->
      <div class="row">
        <xsl:call-template name="topdescription"></xsl:call-template>
      </div>
      <ul class="nav nav-tabs rw-fr-geoportail-tab" role="tablist">
        <li role="presentation" class="active">
          <a data-target="#overview" aria-controls="overview" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'overview')"/></a>
        </li>
        <li role="presentation">
          <a data-target="#access" aria-controls="access" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'access')"/></a>
        </li>
        <li role="presentation">
          <a data-target="#description" aria-controls="description" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'description')"/></a>
        </li>
        <xsl:choose>
          <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!='application'">
            <li role="presentation">
              <a data-target="#use" aria-controls="use" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'use')"/></a>
            </li>
          </xsl:when>
        </xsl:choose>

        <li role="presentation">
          <a data-target="#associatedresources" aria-controls="associatedresources" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'associatedressources')"/></a>
        </li>
        <li role="presentation">
          <a data-target="#contact" aria-controls="contact" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'mw-contact')"/></a>
        </li>
      </ul>

      <!-- Tab panes -->
      <div class="tab-content">
        <div role="tabpanel" class="tab-pane active" id="overview">
          <xsl:call-template name="overviewTemplate"></xsl:call-template>
        </div>
        <div role="tabpanel" class="tab-pane" id="access">
          <xsl:call-template name="accessTemplate"></xsl:call-template>
        </div>
        <div role="tabpanel" class="tab-pane" id="description">
          <xsl:call-template name="descriptionTemplate"></xsl:call-template>
        </div>
        <div role="tabpanel" class="tab-pane" id="use">
          <xsl:call-template name="useTemplate"></xsl:call-template>
        </div>
        <div role="tabpanel" class="tab-pane" id="associatedresources">
          <xsl:call-template name="associatedresourcesTemplate"></xsl:call-template>
        </div>
        <div role="tabpanel" class="tab-pane" id="contact">
          <xsl:call-template name="contactTemplate"></xsl:call-template>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="topdescription">
    <div class="row rw-fr-geoportail-header-top">
      <xsl:choose>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!=''">
          <xsl:value-of select="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="' | '" />
      <xsl:choose>
        <xsl:when test="$metadata/mdb:identificationInfo/*/mri:spatialRepresentationType/mcc:MD_SpatialRepresentationTypeCode/@codeListValue!=''">
          <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:spatialRepresentationType/mcc:MD_SpatialRepresentationTypeCode/@codeListValue"/>
        </xsl:when>
        <xsl:when test="$metadata/mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:ScopedName!=''">
          <xsl:value-of select="$metadata/mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:ScopedName"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
        </xsl:otherwise>
      </xsl:choose>
      <span class="pull-right"><xsl:if test="$test = 'Donnée officielle wallonne'">
        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'wallonia')"/>
      </xsl:if>
        <xsl:if test="$test = 'Reporting INSPIRE'">
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'mw-inspire')"/>
        </xsl:if></span>
    </div>
    <div class="row rw-fr-geoportail-header-main">
      <div class="col-lg-9 pad-left-0">
        <div class="row">
          <h2>
            <xsl:choose>
              <xsl:when test="$metadata/mdb:identificationInfo/*/mri:citation/*/cit:title!=''">
                <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:citation/*/cit:title"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
              </xsl:otherwise>
            </xsl:choose>
          </h2>
        </div>
        <div class="row">
          <p>
            <xsl:choose>
              <xsl:when test="$metadata/mdb:identificationInfo/*/mri:abstract!=''">
                <!-- TO DO ANALYSE WHY LAZY NOT RUN IN REGEX
                <xsl:analyze-string select="$metadata/mdb:identificationInfo/*/mri:abstract" regex="^(.*?)[.?!]">
                  <xsl:matching-substring>
                    <xsl:value-of select="."/>66
                  </xsl:matching-substring>
                </xsl:analyze-string-->
                <xsl:value-of select="substring-before(translate($metadata/mdb:identificationInfo/*/mri:abstract,'?!','..'),'.')"/>.
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
              </xsl:otherwise>
            </xsl:choose>
          </p>
        </div>
        <div class="row">
          <div class="col-lg-7 pad-left-0">
            <p>
              <span class="rw-fr-geoportail-data-key">
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'proprietary')"/> :
              </span>
              <xsl:choose>
                <xsl:when test="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='owner']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString!=''">
                  <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='owner']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
                </xsl:otherwise>
              </xsl:choose>
            </p>
          </div>
          <div class="col-lg-5">
            <p class="pull-right">
              <span class="rw-fr-geoportail-data-key"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'lastupdate')"/> :</span>
              <xsl:choose>
                <xsl:when test="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/gco:Date!=''">
                  <xsl:call-template name="formatDate">
                    <xsl:with-param name="dateParam" select="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/gco:Date" />
                    <xsl:with-param name="dateType" select='"string"'/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
                </xsl:otherwise>
              </xsl:choose>
            </p>
          </div>
        </div>
      </div>
      <div class="col-lg-3 rw-fr-geoportail-logo">
        <xsl:element name="img">
          <xsl:attribute name="class">rw-fr-geoportail-logo-dimension</xsl:attribute>
          <xsl:attribute name="src"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
        </xsl:element>
      </div>
    </div>

  </xsl:template>

  <xsl:template name="overviewTemplate">
    <div class="rw-fr-geoportail-section">
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'overview')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="$metadata/mdb:identificationInfo/*/mri:abstract!=''">
            <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:abstract"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'categories')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="$metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                       'Thèmes du géoportail wallon')]/* or $metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                           'INSPIRE')] or $metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                           'GEMET - Concepts, version 2.4')] or $metadata//mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode">
            <xsl:if test="$metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                       'Thèmes du géoportail wallon')]/*">
              <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'geoportailTheme')"/> :</h6>
              <p><xsl:value-of select="string-join($metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                       'Thèmes du géoportail wallon')]/*/mri:keyword,';')"/></p>

            </xsl:if>
            <xsl:if test="$metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                           'INSPIRE')]">
              <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'inspireTheme')"/> :</h6>
              <p><xsl:value-of select="string-join($metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                           'INSPIRE')]/*/mri:keyword,';')"/></p>
            </xsl:if>
            <xsl:if test="$metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                           'GEMET - Concepts, version 2.4')]">
              <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'gemetTheme')"/> :</h6>
              <p><xsl:value-of select="string-join($metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[
                              contains(*/mri:thesaurusName/*/cit:title/gco:CharacterString,
                                           'GEMET - Concepts, version 2.4')]/*/mri:keyword,';')"/></p>
            </xsl:if>
            <xsl:if test="$metadata//mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode">
              <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'isoTheme')"/> :</h6>
              <p><xsl:value-of select="string-join($metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode,'; ')"/></p>

            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'keywords')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="$metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[not(*/mri:thesaurusName)]/*/mri:keyword">
            <p><xsl:value-of select="string-join($metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[not(*/mri:thesaurusName)]/*/mri:keyword,';')"/></p>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'thumbnails')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="$metadata/mdb:identificationInfo/*/mri:graphicOverview/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString">
            <xsl:call-template name="carousel"></xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="accessTemplate">
    <div class="rw-fr-geoportail-section">
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'viewing')"/></h3>
      </div>
      <xsl:choose>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!='application' or $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!='series'">
          <div class="rw-fr-geoportail-section-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset'">
                <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'dataView')"/></h4>
              </xsl:when>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='service'">
                <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'serviceView')"/></h4>
              </xsl:when>
            </xsl:choose>

            <div class="row col-lg-12 rw-fr-geoportail-application"><br></br></div>
            <div class="row rw-fr-geoportail-application">
              <xsl:element name="div">
                <xsl:attribute name="class">col-lg-6 rw-fr-geoportail-application-element</xsl:attribute>
                <xsl:if test="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and (cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='' or cit:CI_OnlineResource[not(cit:applicationProfile/gco:CharacterString)])]">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg</xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and (cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='' or cit:CI_OnlineResource[not(cit:applicationProfile/gco:CharacterString)])]/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'thematicmap')"/></span>
                  </xsl:element>
                  <p class="rw-fr-geoportail-application-element-text"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'thematicmaptext')"/></p>
                  <p class="rw-fr-geoportail-application-element-bottom"></p>
                </xsl:if>
                <xsl:if test="not($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and (cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='' or cit:CI_OnlineResource[not(cit:applicationProfile/gco:CharacterString)])])">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg disabled rw-fr-geoportail-disabled</xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'thematicmap')"/></span>
                  </xsl:element>
                  <p class="rw-fr-geoportail-application-element-text rw-fr-geoportail-opacity"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'thematicmaptext')"/></p>
                  <p class="rw-fr-geoportail-application-element-bottom"></p>
                </xsl:if>
              </xsl:element>
              <xsl:element name="div">
                <xsl:attribute name="class">col-lg-6 rw-fr-geoportail-application-element</xsl:attribute>
                <xsl:if test="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg</xsl:attribute>
                    <xsl:attribute name="href">http://geoportail.wallonie.be/walonmap#panier=[{"serviceId":<xsl:value-of select="$metadata/mdb:metadataIdentifier/*/mcc:code/gco:CharacterString"/>,"visible": true,"url":<xsl:value-of select="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString[1]"/>,"label":<xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:citation/*/cit:title"/>,"type":"AGS_DYNAMIC"}]</xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'walonmap')"/></span>
                  </xsl:element>
                  <p class="rw-fr-geoportail-application-element-text"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'walonmaptext')"/></p>
                  <p class="rw-fr-geoportail-application-element-bottom"></p>
                </xsl:if>
                <xsl:if test="not($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing'])">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg disabled rw-fr-geoportail-disabled</xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'walonmap')"/></span>
                  </xsl:element>
                  <p class="rw-fr-geoportail-application-element-text rw-fr-geoportail-opacity"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'walonmaptext')"/></p>
                  <p class="rw-fr-geoportail-application-element-bottom"></p>
                </xsl:if>
              </xsl:element>
            </div>
            <div class="row rw-fr-geoportail-application">
              <xsl:element name="div">
                <xsl:attribute name="class">col-lg-6 rw-fr-geoportail-application-element</xsl:attribute>
                <xsl:if test="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing'] and position() = 1">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg</xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing'][1]/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/>?f=lyr&amp;v=9.3</xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'arcgis')"/>  ®</span>
                  </xsl:element>
                  <p class="rw-fr-geoportail-application-element-text"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'arcgistext')"/></p>
                  <p class="rw-fr-geoportail-application-element-bottom"></p>
                </xsl:if>
                <xsl:if test="not($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST')and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing'])">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg disabled rw-fr-geoportail-disabled</xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'arcgis')"/>  ®</span>
                  </xsl:element>
                  <p class="rw-fr-geoportail-application-element-text rw-fr-geoportail-opacity"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'arcgistext')"/></p>
                  <p class="rw-fr-geoportail-application-element-bottom"></p>
                </xsl:if>
              </xsl:element>
              <xsl:element name="div">
                <xsl:attribute name="class">col-lg-6 rw-fr-geoportail-application-element</xsl:attribute>
                <xsl:if test="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg</xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'googleearth')"/>  ®</span>
                  </xsl:element>
                  <p class="rw-fr-geoportail-application-element-text"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'googleearthtext')"/></p>
                  <p class="rw-fr-geoportail-application-element-bottom"></p>
                </xsl:if>
                <xsl:if test="not($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString)">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg disabled rw-fr-geoportail-disabled</xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'googleearth')"/>  ®</span>
                  </xsl:element>
                  <p class="rw-fr-geoportail-application-element-text rw-fr-geoportail-opacity"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'googleearthtext')"/></p>
                  <p class="rw-fr-geoportail-application-element-bottom"></p>
                </xsl:if>
              </xsl:element>
            </div>
            <div class="row rw-fr-geoportail-application">
              <xsl:element name="div">
                <xsl:attribute name="class">col-lg-12 rw-fr-geoportail-application-element</xsl:attribute>
                <xsl:if test="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg</xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'otherstools')"/></span>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="not($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString)">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg disabled rw-fr-geoportail-disabled</xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'otherstools')"/></span>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
            </div>
            <div class="row col-lg-12 rw-fr-geoportail-application"><br></br></div>
          </div>
          <xsl:choose>
            <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset'">
              <div class="rw-fr-geoportail-section-content">
                <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'webserviceview')"/></h4>
                <xsl:apply-templates select="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">
                </xsl:apply-templates>
                <xsl:apply-templates select="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[starts-with(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'OGC') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">
                </xsl:apply-templates>
              </div>
            </xsl:when>
            <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='service'">
              <div class="rw-fr-geoportail-section-content">
                <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'serviceurlview')"/></h4>
                <div class='row'>
                  <div class="col-lg-2"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'address')"/></div>
                  <div class='col-lg-10 rw-fr-geoportail-webservice-button-box'>
                    <div class="col-lg-12 rw-fr-geoportail-webservice-button-content-value rw-fr-geoportail-webservice-button-content-center">
                      <a><p><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></p></a>
                    </div>
                  </div>
                </div>
                <div class='row'>
                  <div class="col-lg-2"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'type')"/></div>
                  <div class='col-lg-10 rw-fr-geoportail-webservice-button-box'>
                    <div class="col-lg-3 rw-fr-geoportail-webservice-button-content-key">
                      <button class="rw-fr-geoportail-webservice-button-content-center" style=" padding: 0;border: none; background: none;">
                        <xsl:attribute name=" data-clipboard-text"><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></xsl:attribute>
                        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'copyurl')"/>
                      </button>
                    </div>
                    <div class="col-lg-9 rw-fr-geoportail-webservice-button-content-value rw-fr-geoportail-webservice-button-content-center">
                      <a><p><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></p></a>
                    </div>
                  </div>
                </div>
              </div>
            </xsl:when>
          </xsl:choose>

        </xsl:when>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='application'">
          <div class="rw-fr-geoportail-section-content">
            <div class="row col-lg-12 rw-fr-geoportail-application"><br></br></div>
            <div class="row rw-fr-geoportail-application">
              <xsl:element name="div">
                <xsl:attribute name="class">col-lg-12 rw-fr-geoportail-application-element</xsl:attribute>
                <xsl:if test="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg</xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'applicationView')"/></span>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="not($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString)">
                  <xsl:element name="a">
                    <xsl:attribute name="class">btn btn-default btn-lg disabled rw-fr-geoportail-disabled</xsl:attribute>
                    <span class="rw-fr-geoportail-icon-service"></span><br></br>
                    <span class="rw-fr-geoportail-application-element-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'applicationView')"/></span>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
            </div>
            <div class="row col-lg-12 rw-fr-geoportail-application"><br></br></div>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset' or $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='series'">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'copy')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <div class="row rw-fr-geoportail-subsection">
              <div class="col-lg-3"></div>
              <div class="col-lg-9">
                <xsl:apply-templates select="$metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributionOrderProcess/mrd:MD_StandardOrderProcess/mrd:orderingInstructions/gco:CharacterString" />
              </div>
            </div>
            <div class="row rw-fr-geoportail-subsection-twocolumns rw-fr-geoportail-subsection">
              <div class="col-lg-6">
                <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'formatter-distributor')"/></h4>
                <p><xsl:value-of select="$metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='distributor']/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/><br></br>
                  <a>
                    <xsl:attribute name="href">mailto:<xsl:value-of select="$metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='distributor']/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString"/></xsl:attribute>
                    <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'contact')"/></span>
                  </a>
                </p>
              </div>
              <div class="col-lg-6">
                <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'formatter-format')"/></h4>
                <xsl:value-of select="string-join($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString,'; ')"/>
                <xsl:value-of select="string-join($metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString,'; ')"/>
              </div>
            </div>
            <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'conditionsData')"/></h4>
            <xsl:apply-templates select="$metadata/mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints/gco:CharacterString" />
          </div>
        </xsl:when>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='application' or $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='service'">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'conditions')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='application'">
                <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'conditionsApplications')"/></h4>
              </xsl:when>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='service'">
                <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'conditionsService')"/></h4>
              </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="$metadata/mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints/gco:CharacterString"/>
          </div>
        </xsl:when>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="descriptionTemplate">
    <div class="rw-fr-geoportail-section">
      <div class="row">
        <div class="col-lg-6 rw-fr-geoportail-twocolumns">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'aoi')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:extent/gex:EX_Extent/gex:description/gco:CharacterString"/>
          </div>
        </div>
        <div class="col-lg-6 rw-fr-geoportail-twocolumns">
          <div class="rw-fr-geoportail-section-title">
            <h3 class="rw-fr-geoportail-border-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'spatialreference')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content rw-fr-geoportail-border-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString">
                <xsl:call-template name="formatEPSG">
                  <xsl:with-param name="epsgParam" select="$metadata/mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString" />
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </div>
      </div>
      <xsl:choose>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!='service'">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'toi')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:identificationInfo/*/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition!='' and $metadata/mdb:identificationInfo/*/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition!=''">
                <xsl:call-template name="formatDate">
                  <xsl:with-param name="dateParam" select="$metadata/mdb:identificationInfo/*/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition" />
                  <xsl:with-param name="dateType" select='"string"'/>
                </xsl:call-template>
                <span> &#8594; </span>
                <xsl:call-template name="formatDate">
                  <xsl:with-param name="dateParam" select="$metadata/mdb:identificationInfo/*/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition" />
                  <xsl:with-param name="dateType" select='"string"'/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <p><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/></p>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </xsl:when>
      </xsl:choose>


      <xsl:choose>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!='application' and $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!='service'">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'model')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='information.content'">
                <xsl:call-template name="descriptiontable">
                  <xsl:with-param name="param">information.content</xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </xsl:when>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!='service'">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'legend')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='information.portrayal'">
                <xsl:call-template name="descriptiontable">
                  <xsl:with-param name="param">information.portrayal</xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </xsl:when>
      </xsl:choose>


      <div class="row">
        <div class="col-lg-6 rw-fr-geoportail-twocolumns">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'mtdidentification')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'mtdid')"/></h6>
            <p><xsl:value-of select="$metadata/mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString"/></p>
            <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'mtdlastupdate')"/></h6>
            <p>
              <xsl:choose>
                <xsl:when test="$metadata/mdb:dateInfo[cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:CI_Date/cit:date/gco:DateTime!=''">
                  <xsl:call-template name="formatDate">
                    <xsl:with-param name="dateParam" select="$metadata/mdb:dateInfo[cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:CI_Date/cit:date/gco:DateTime" />
                    <xsl:with-param name="dateType" select='"number"'/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
                </xsl:otherwise>
              </xsl:choose>


            </p>
          </div>
        </div>
        <div class="col-lg-6 rw-fr-geoportail-twocolumns">
          <div class="rw-fr-geoportail-section-title">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='service'">
                <h3 class="rw-fr-geoportail-border-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'serviceIdentification')"/></h3>
              </xsl:when>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='application'">
                <h3 class="rw-fr-geoportail-border-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'applicationIdentification')"/></h3>
              </xsl:when>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='series' or $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset'">
                <h3 class="rw-fr-geoportail-border-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'dataIdentification')"/></h3>
              </xsl:when>
            </xsl:choose>

          </div>
          <div class="rw-fr-geoportail-section-content rw-fr-geoportail-border-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='service'">
                <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'serviceId')"/></h6>
              </xsl:when>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='application'">
                <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'applicationId')"/></h6>
              </xsl:when>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='series' or $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset'">
                <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'dataId')"/></h6>
              </xsl:when>
            </xsl:choose>
            <p>
              <xsl:choose>
                <xsl:when test="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString">
                  <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString"/>
                  <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[mcc:codeSpace/gco:CharacterString !='']/mcc:code/gco:CharacterString"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
                </xsl:otherwise>
              </xsl:choose>
            </p>
            <xsl:choose>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='service'">
                <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'serviceLastdiffusion')"/></h6>
              </xsl:when>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='application'">
                <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'applicationLastdiffusion')"/></h6>
              </xsl:when>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='series' or $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset'">
                <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'datalastdiffusion')"/></h6>
              </xsl:when>
            </xsl:choose>

            <p>
              <xsl:choose>
                <xsl:when test="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='publication']/cit:date/gco:Date!=''">
                  <xsl:call-template name="formatDate">
                    <xsl:with-param name="dateParam" select="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='publication']/cit:date/gco:Date" />
                    <xsl:with-param name="dateType" select='"number"'/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
                </xsl:otherwise>
              </xsl:choose>
            </p>
            <xsl:choose>
              <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset' or $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='series'">
                <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'lastupdate')"/></h6>
                <xsl:choose>
                  <xsl:when test="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/gco:Date!=''">
                    <xsl:call-template name="formatDate">
                      <xsl:with-param name="dateParam" select="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/gco:Date" />
                      <xsl:with-param name="dateType" select='"number"'/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </div>
        </div>
      </div>
      <xsl:choose>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='application'">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'languageApplication')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <p><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue" /></p>
          </div>
        </xsl:when>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset' or $metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='series'">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'languageData')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <p><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue" /></p>
          </div>
        </xsl:when>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="useTemplate">
    <div class="rw-fr-geoportail-section">
      <div class="row">
        <div class="col-lg-6 rw-fr-geoportail-twocolumns">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'referencescale')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:identificationInfo/*/mri:spatialResolution/mri:MD_Resolution/mri:equivalentScale/mri:MD_RepresentativeFraction/mri:denominator/gco:Integer">
                <p><xsl:value-of select="'1:'"/><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:spatialResolution/mri:MD_Resolution/mri:equivalentScale/mri:MD_RepresentativeFraction/mri:denominator/gco:Integer"/></p>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </div>
        <div class="col-lg-6 rw-fr-geoportail-twocolumns">
          <div class="rw-fr-geoportail-section-title">
            <h3 class="rw-fr-geoportail-border-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'resolution')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content rw-fr-geoportail-border-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:identificationInfo/*/mri:spatialResolution/mri:MD_Resolution/mri:distance/gco:Distance">
                <p><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:spatialResolution/mri:MD_Resolution/mri:distance/gco:Distance"/><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:spatialResolution/mri:MD_Resolution/mri:distance/gco:Distance/@uom"/></p>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-lg-6 rw-fr-geoportail-twocolumns">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'precision')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <xsl:choose>
              <xsl:when test="$metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AbsoluteExternalPositionalAccuracy/mdq:result/mdq:DQ_QuantitativeResult/mdq:value/gco:Record">
                <p><xsl:value-of select="$metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AbsoluteExternalPositionalAccuracy/mdq:result/mdq:DQ_QuantitativeResult/mdq:value/gco:Record"/></p>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </div>
        <div class="col-lg-6 rw-fr-geoportail-twocolumns">
          <div class="rw-fr-geoportail-section-title">
            <h3 class="rw-fr-geoportail-border-title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'precisionz')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content rw-fr-geoportail-border-content">
            <p></p>
          </div>
        </div>
      </div>
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'genealogy')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="$metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:statement/gco:CharacterString">
            <p><xsl:value-of select="$metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:statement/gco:CharacterString"/></p>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'qualityreport')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='information.qualityReport'">
            <xsl:call-template name="descriptiontable">
              <xsl:with-param name="param">information.qualityReport</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'conformitytest')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="$metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_DomainConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:specification/cit:CI_Citation/cit:title/gco:CharacterString">
            <xsl:call-template name="tableConformity"></xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="associatedresourcesTemplate">
    <div class="rw-fr-geoportail-section">
      <xsl:choose>
        <xsl:when test="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue!='application'">
          <div class="rw-fr-geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'associateddata')"/></h3>
          </div>
          <div class="rw-fr-geoportail-section-content">
            <xsl:call-template name="associatedRessourcestable">
            </xsl:call-template>
          </div>
        </xsl:when>
      </xsl:choose>

      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'associatedsite')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="/root/mdb:MD_Metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='information' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString!='']">
            <xsl:call-template name="associatedtable">
              <xsl:with-param name="param1">information</xsl:with-param>
              <xsl:with-param name="param2">site</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>


      </div>
      <div class="rw-fr-geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'associateddocument')"/></h3>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <xsl:choose>
          <xsl:when test="/root/mdb:MD_Metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='information' and (cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='' or not(cit:CI_OnlineResource/cit:applicationProfile))]">
            <xsl:call-template name="associatedtable">
              <xsl:with-param name="param1">information</xsl:with-param>
              <xsl:with-param name="param2">doc</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="contactTemplate">
    <div class="rw-fr-geoportail-section">
      <div class="rw-fr-geoportail-section-title">
        <h2><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'question')"/></h2>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <div class="row rw-fr-geoportail-contact">
          <div class="col-lg-6  rw-fr-geoportail-contact-leftside">
            <span><i class="fa fa-angle-right" aria-hidden="true"></i><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'distributioninfo')"/></span>
          </div>
          <div class="col-lg-6 rw-fr-geoportail-contact-rightside">
            <a>
              <xsl:attribute name="href">mailto:<xsl:value-of select="$metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='distributor']/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString"/></xsl:attribute>
              <span><xsl:value-of select="$metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='distributor']/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/></span><span class="pull-right"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
            </a>
          </div>
        </div>
        <div class="row">
        </div>
        <div class="row">
          <div class="col-lg-6  rw-fr-geoportail-contact-leftside">
            <span><i class="fa fa-angle-right" aria-hidden="true"></i><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'contentinfo')"/></span>
          </div>
          <div class="col-lg-6 rw-fr-geoportail-contact-rightside">
            <a>
              <xsl:attribute name="href">mailto:<xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='owner']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString" /></xsl:attribute>
              <span><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='owner']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/></span><span class="pull-right"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
            </a>
          </div>
        </div>
      </div>
      <div class="rw-fr-geoportail-section-title">
        <h2><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'whishes')"/></h2>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <div class="row">
          <div class="col-lg-6  rw-fr-geoportail-contact-leftside">
            <span><i class="fa fa-angle-right" aria-hidden="true"></i><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'responsable')"/></span>
          </div>
          <div class="col-lg-6 rw-fr-geoportail-contact-rightside">
            <a>
              <xsl:attribute name="href">mailto:<xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='pointOfContact']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString" /></xsl:attribute>
              <span><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='pointOfContact']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/></span><span class="pull-right"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
            </a>
          </div>
        </div>
      </div>
      <div class="rw-fr-geoportail-section-title">
        <h2><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'othersquestions')"/></h2>
      </div>
      <div class="rw-fr-geoportail-section-content">
        <div class="row">
          <div class="col-lg-6  rw-fr-geoportail-contact-leftside">
            <span><i class="fa fa-angle-right" aria-hidden="true"></i><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'geoportail')"/></span>
          </div>
          <div class="col-lg-6 rw-fr-geoportail-contact-rightside">
            <a>
              <xsl:attribute name="href">mailto:<xsl:value-of select="email" /></xsl:attribute>
              <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'helpdeskgeoportail')"/></span><span class="pull-right"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
            </a>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="descriptiontable">
    <xsl:param name="param"/>
    <table class="table table-bordered rw-fr-geoportail-table">
      <thead>
        <tr>
          <th style="width: 25%" ><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'document')"/> </th>
          <th style="width: 60%" ><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'description')"/></th>
          <th style="width: 15%" ><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'open')"/></th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue=$param]">
          <tr>
            <td>
              <xsl:value-of select="$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/
                *[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue=$param]/cit:CI_OnlineResource/cit:name/gco:CharacterString"/>
            </td>
            <td>
              <xsl:value-of select="$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/
                *[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue=$param]/cit:CI_OnlineResource/cit:description/gco:CharacterString"/>
            </td>
            <td>
              <a href="{$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/
                *[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue=$param]/cit:CI_OnlineResource/cit:linkage/gco:CharacterString}" target="_blank" title="Ouvrir">
                <span class="rw-fr-geoportail-icon-link"></span>
              </a>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="tableConformity">
    <table class="table table-bordered rw-fr-geoportail-table">
      <thead>
        <tr>
          <th style="width: 90%; vertical-align: middle"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'testname')"/></th>
          <th style="width: 10%"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'status')"/></th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>
            <xsl:value-of select="$metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_DomainConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:specification/cit:CI_Citation/cit:title/gco:CharacterString"/>
          </td>
          <td>
            <xsl:if test="$metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_DomainConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:pass/gco:Boolean = 'false'">
              <span class="rw-fr-geoportail-icon-link"></span>
            </xsl:if>
            <xsl:if test="$metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_DomainConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:pass/gco:Boolean = 'true'">
              <span class="rw-fr-geoportail-icon-link"></span>
            </xsl:if>
          </td>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="associatedRessourcestable">
    <table class="table table-bordered rw-fr-geoportail-table">
      <thead>
        <tr>
          <th style="width: 25%"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'name')"/></th>
          <th style="width: 60%"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'description')"/></th>
          <th style="width: 15%"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'descriptivesheet')"/></th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="$associatedRessources/related/*/item">
          <xsl:choose>
            <xsl:when test="position() mod 2 = 1">
              <tr class="rw-fr-geoportail-table-color">
                <td>
                  <xsl:value-of select="title/value"/>
                </td>
                <td>
                  <xsl:value-of select="description/value"/>
                </td>
                <td>
                  <a href="{id}" target="_blank" title="Ouvrir">
                    <span class="rw-fr-geoportail-icon-info"></span>
                  </a>
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <tr class="rw-fr-geoportail-table-nocolor">
                <td>
                  <xsl:value-of select="title/value"/>
                </td>
                <td>
                  <xsl:value-of select="description/value"/>
                </td>
                <td>
                  <a href="{id}" target="_blank" title="Ouvrir">
                    <span class="rw-fr-geoportail-icon-info"></span>
                  </a>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="associatedtable">
    <xsl:param name="param1"/>
    <xsl:param name="param2"/>
    <table class="table table-bordered rw-fr-geoportail-table">
      <thead>
        <tr>
          <th style="width: 25%"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'name')"/></th>
          <th style="width: 60%"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'description')"/></th>
          <th style="width: 15%"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'descriptivesheet')"/></th>
        </tr>
      </thead>
      <tbody>
        <xsl:choose>
          <xsl:when test="$param2='doc'">
            <xsl:apply-templates select="$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue=$param1 and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString!='']">
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue=$param1 and (cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='' or not(cit:CI_OnlineResource/cit:applicationProfile))]">
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="/root/mdb:MD_Metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='information' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString!='']">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 1">
        <tr class="rw-fr-geoportail-table-color">
          <td>
            <xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/>
          </td>
          <td>
            <xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/>
          </td>
          <td>
            <a href="{cit:CI_OnlineResource/cit:linkage/gco:CharacterString}" target="_blank" title="Ouvrir">
              <span class="rw-fr-geoportail-icon-link"></span>
            </a>
          </td>
        </tr>
      </xsl:when>
      <xsl:otherwise>
        <tr class="rw-fr-geoportail-table-nocolor">
          <td>
            <xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/>
          </td>
          <td>
            <xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/>
          </td>
          <td>
            <a href="{cit:CI_OnlineResource/cit:linkage/gco:CharacterString}" target="_blank" title="Ouvrir">
              <span class="rw-fr-geoportail-icon-link"></span>
            </a>
          </td>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/root/mdb:MD_Metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='information' and (cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='' or not(cit:CI_OnlineResource/cit:applicationProfile))]">
    <xsl:choose>
      <xsl:when test="position() mod 2 = 1">
        <tr class="rw-fr-geoportail-table-color">
          <td>
            <xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/>
          </td>
          <td>
            <xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/>
          </td>
          <td>
            <a href="{cit:CI_OnlineResource/cit:linkage/gco:CharacterString}" target="_blank" title="Ouvrir">
              <span class="rw-fr-geoportail-icon-link"></span>
            </a>
          </td>
        </tr>
      </xsl:when>
      <xsl:otherwise>
        <tr class="rw-fr-geoportail-table-nocolor">
          <td>
            <xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/>
          </td>
          <td>
            <xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/>
          </td>
          <td>
            <a href="{cit:CI_OnlineResource/cit:linkage/gco:CharacterString}" target="_blank" title="Ouvrir">
              <span class="rw-fr-geoportail-icon-link"></span>
            </a>
          </td>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/root/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">
    <div class="row rw-fr-geoportail-webservice">
      <div class="col-lg-6">
        <h5><xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/></h5>
        <p><xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/></p>
      </div>
      <div class="col-lg-6">
        <div class='row rw-fr-geoportail-webservice-button-box'>
          <div class="col-lg-6 rw-fr-geoportail-webservice-button-leftcontent">
            <div class="rw-fr-geoportail-webservice-button-content-key rw-fr-geoportail-webservice-button-content-center"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'descriptivesheet')"/> <i class="fa fa-info-circle pull-right rw-fr-geoportail-webservice-button-content-center" aria-hidden="true"></i></div>
          </div>
          <div class="col-lg-6 rw-fr-geoportail-webservice-button-rightcontent">
            <div class="rw-fr-geoportail-webservice-button-content-value rw-fr-geoportail-webservice-button-content-center"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'arcgismapping')"/></div>
          </div>
        </div>
        <div class='row rw-fr-geoportail-webservice-button-box'>
          <div class="col-lg-3 rw-fr-geoportail-webservice-button-content-key">
            <button class="rw-fr-geoportail-webservice-button-content-center" style=" padding: 0;border: none; background: none;">
              <xsl:attribute name=" data-clipboard-text"><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></xsl:attribute>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'copyurl')"/>
            </button>
          </div>
          <div class="col-lg-9 rw-fr-geoportail-webservice-button-content-value rw-fr-geoportail-webservice-button-content-center">
            <a><p><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></p></a>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="/root/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[starts-with(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'OGC') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">

    <div class="row rw-fr-geoportail-webservice"> <div class="col-lg-6">
      <h5><xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/></h5>
      <p><xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/></p>
    </div>
      <div class="col-lg-6">
        <div class='row rw-fr-geoportail-webservice-button-box'>
          <div class="col-lg-6 rw-fr-geoportail-webservice-button-leftcontent">
            <div class="rw-fr-geoportail-webservice-button-content-key rw-fr-geoportail-webservice-button-content-center"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'descriptivesheet')"/> <i class="fa fa-info-circle pull-right rw-fr-geoportail-webservice-button-content-center" aria-hidden="true"></i></div>
          </div>
          <div class="col-lg-6 rw-fr-geoportail-webservice-button-rightcontent">
            <div class="rw-fr-geoportail-webservice-button-content-value rw-fr-geoportail-webservice-button-content-center"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'view')"/></div>
          </div>
        </div>
        <div class='row rw-fr-geoportail-webservice-button-box'>
          <div class="col-lg-3 rw-fr-geoportail-webservice-button-content-key">
            <button class="rw-fr-geoportail-webservice-button-content-center" style=" padding: 0;border: none; background: none;">
              <xsl:attribute name=" data-clipboard-text"><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></xsl:attribute>
              <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'copyurl')"/>
            </button>
          </div>
          <div class="col-lg-9 rw-fr-geoportail-webservice-button-content-value rw-fr-geoportail-webservice-button-content-center">
            <a><p><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></p></a>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="carousel">
    <div id="carousel-example-generic" class="carousel slide" data-ride="carousel">
      <!-- Indicators -->
      <ol class="carousel-indicators">
        <xsl:for-each select="/root/mdb:MD_Metadata/mdb:identificationInfo/*/mri:graphicOverview/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString">
          <li data-target="#carousel-example-generic">
            <xsl:if test="position() = 1"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
            <xsl:attribute name="data-slide-to"><xsl:value-of select="position()-1"/></xsl:attribute>
          </li>
        </xsl:for-each>
      </ol>
      <!-- Wrapper for slides -->
      <div class="carousel-inner rw-fr-geoportail-carousel" role="listbox">
        <xsl:for-each select="/root/mdb:MD_Metadata/mdb:identificationInfo/*/mri:graphicOverview/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString">
          <div class="item">
            <xsl:if test="position() = 1"><xsl:attribute name="class">item active</xsl:attribute></xsl:if>
            <img class="img-responsive center-block" src="{.}" alt="aa"/>
          </div>
        </xsl:for-each>
      </div>
      <!-- Controls -->
      <a class="left carousel-control rw-fr-geoportail-carousel-button" data-target="#carousel-example-generic" role="button" data-slide="prev">
        <span class="fa-stack fa-lg" style=" vertical-align: middle;">
          <i class="fa fa-2x fa-circle-thin fa-stack-1x" aria-hidden="true"></i>
          <i class="fa fa-caret-left fa-stack-1x" aria-hidden="true"></i></span>
      </a>
      <a class="right carousel-control rw-fr-geoportail-carousel-button" data-target="#carousel-example-generic" role="button" data-slide="next">
        <span class="fa-stack fa-lg">
          <i class="fa fa-2x fa-circle-thin fa-stack-1x" aria-hidden="true" style=" vertical-align: middle;"></i>
          <i class="fa fa-caret-right fa-stack-1x" aria-hidden="true" style=" vertical-align: middle;"></i></span>
      </a>
    </div>
  </xsl:template>

  <xsl:template name="formatDate">
    <xsl:param name="dateParam"/>
    <xsl:param name="dateType"/>
    <xsl:if  test="string-length(substring-before($dateParam,'T')) != 0">
      <xsl:variable name="year" select="substring-before($dateParam,'-')"/>
      <xsl:variable name="month" select="substring-before(substring-after($dateParam,'-'),'-')"/>
      <xsl:variable name="day" select="substring-before(substring-after(substring-after($dateParam,'-'),'-'),'T')"/>
      <xsl:value-of select="$day"/>
      <xsl:if  test="$dateType='string'">
        <xsl:value-of select="' '"/>
        <xsl:value-of select="format-date(xs:date(concat($year,'-',$month,'-',$day)),'[MNn]')"/>
        <xsl:value-of select="' '"/>
      </xsl:if>
      <xsl:if  test="$dateType='number'">
        <xsl:value-of select="'/'"/>
        <xsl:value-of select="$month"/>
        <xsl:value-of select="'/'"/>
      </xsl:if>
      <xsl:value-of select="$year"/>
    </xsl:if>
    <xsl:if   test="string-length(substring-before($dateParam,'T')) = 0">
      <xsl:variable name="year" select="substring-before($dateParam,'-')"/>
      <xsl:variable name="month" select="substring-before(substring-after($dateParam,'-'),'-')"/>
      <xsl:variable name="day" select="substring-after(substring-after($dateParam,'-'),'-')"/>
      <xsl:value-of select="$day"/>
      <xsl:if  test="$dateType='string'">
        <xsl:value-of select="' '"/>
        <xsl:value-of select="format-date(xs:date(concat($year,'-',$month,'-',$day)),'[MNn]')"/>
        <xsl:value-of select="' '"/>
      </xsl:if>
      <xsl:if  test="$dateType='number'">
        <xsl:value-of select="'/'"/>
        <xsl:value-of select="$month"/>
        <xsl:value-of select="'/'"/>
      </xsl:if>
      <xsl:value-of select="$year"/>
    </xsl:if >
  </xsl:template>
  <xsl:template name="formatEPSG">
    <xsl:param name="epsgParam"/>
    <xsl:for-each select="$epsgParam">
      <xsl:if test="contains(.,'31370')">
        <span>- Belge 1972 / Belgian Lambert 72 (EPSG: 31370)</span><br></br>
      </xsl:if>
      <xsl:if test="not(contains(.,'31370'))">
        <span>- <xsl:value-of select="."/></span><br></br>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/root/mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributionOrderProcess/mrd:MD_StandardOrderProcess/mrd:orderingInstructions/gco:CharacterString">
    <xsl:call-template name="hyperlinks">
      <xsl:with-param name="textParam" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="/root/mdb:MD_Metadata/mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints/gco:CharacterString">
    <xsl:call-template name="hyperlinks">
      <xsl:with-param name="textParam" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="hyperlinks">
    <xsl:param name="textParam"/>
    <xsl:analyze-string select="$textParam"
                        regex="http://[^ ]+">
      <xsl:matching-substring>
        <a href="{.}">
          <xsl:value-of select="." />
        </a>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="." />
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>



</xsl:stylesheet>
