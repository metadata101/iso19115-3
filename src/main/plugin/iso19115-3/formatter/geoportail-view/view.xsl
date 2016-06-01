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


  <xsl:template
    match="/">
    <!-- contenu du template -->
    <div class="container gn-metadata-view">
      <!-- Nav tabs -->
      <div class="row">
        <xsl:call-template name="topdescription"></xsl:call-template>
      </div>
      <ul class="nav nav-tabs geoportail-tab" role="tablist">
        <li role="presentation" class="active">
          <a data-target="#overview" aria-controls="overview" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'overview')"/></a>
        </li>
        <li role="presentation">
          <a data-target="#access" aria-controls="access" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'access')"/></a>
        </li>
        <li role="presentation">
          <a data-target="#description" aria-controls="description" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'description')"/></a>
        </li>
        <li role="presentation">
          <a data-target="#use" aria-controls="use" role="tab" data-toggle="tab"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'use')"/></a>
        </li>
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
    <div class="row metaheader">
      <xsl:value-of select="$metadata/mdb:metadataScope/*/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue"/> | <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:spatialRepresentationType/mcc:MD_SpatialRepresentationTypeCode/@codeListValue"/>
      <span class="pull-right"><xsl:if test="$test = 'Donnée officielle wallonne'">
        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'wallonia')"/>
      </xsl:if>
      <xsl:if test="$test = 'Reporting INSPIRE'">
        <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'mw-inspire')"/>
      </xsl:if></span>
    </div>
    <div class="row mainheaheader">
      <div class="col-lg-9 headertext">
        <div class="row">
        <h2><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:citation/*/cit:title"/></h2>
        </div>
        <div class="row">
        <div class="col-lg-7 headertextleft">
          <p><span class="title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'proprietary')"/> :</span><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='owner']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/></p>
        </div>
        <div class="col-lg-5">
          <p class="pull-right">
            <span class="title"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'lastupdate')"/> :</span>
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
      <div class="col-lg-3 headerlogo">
        <xsl:element name="img">
          <xsl:attribute name="class">geoportail-logo</xsl:attribute> 
          <xsl:attribute name="src"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
        </xsl:element>
      </div>
    </div>

  </xsl:template>

  <xsl:template name="overviewTemplate">
    <div class="geoportail-section">
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'overview')"/></h3>
      </div>
      <div class="geoportail-section-content">
        <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:abstract"/>
      </div>
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'keywords')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
        <xsl:if test="$metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[not(*/mri:thesaurusName)]/*/mri:keyword">
          <h6 ><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'othersTheme')"/> :</h6>
          <p><xsl:value-of select="string-join($metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[not(*/mri:thesaurusName)]/*/mri:keyword,';')"/></p>
        </xsl:if>
      </div>
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'thumbnails')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
    <div class="geoportail-section">
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'viewing')"/></h3>
      </div>
      <div class="geoportail-section-content">
        <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'applicationview')"/></h4>
        <div class="row application">
          <a>
            <xsl:attribute name="class">col-lg-6 btn btn-default btn-lg disabled mwdisabled mwapplications</xsl:attribute>
            <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'thematicmap')"/></span>
            <p></p>
          </a>
          <a class="col-lg-6 btn btn-default btn-lg disabled mwdisabled mwapplications">
            <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'walonmap')"/></span>
            <p></p>
          </a>
        </div>
        <div class="row application">
          <a class="col-lg-6 btn btn-default btn-lg disabled mwdisabled mwapplications">
            <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'arcgis')"/></span>
            <p></p>
          </a>
          <xsl:element name="a">
            <xsl:if test="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString">
              <xsl:attribute name="class">col-lg-6 btn btn-default btn-lg mwapplications</xsl:attribute> 
              <xsl:attribute name="src"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
              <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'googleearth')"/></span>
              <p class="mwdisabled"></p>
            </xsl:if>
            <xsl:if test="not($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString)">
              <xsl:attribute name="class">col-lg-6 btn btn-default btn-lg disabled mwdisabled mwapplications</xsl:attribute> 
              <xsl:attribute name="src"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
              <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'googleearth')"/></span>
              <p></p>
            </xsl:if>
          </xsl:element>
        </div>
        <div class="row application">
          <xsl:element name="a">
            <xsl:if test="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString">
              <xsl:attribute name="class">col-lg-12 btn btn-default btn-lg mwapplications</xsl:attribute> 
              <xsl:attribute name="src"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
              <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'otherstools')"/></span>
            </xsl:if>
            <xsl:if test="not($metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'WWW:LINK-1.0-http--link') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing' and cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='application/vnd.google-earth.kml+xml']/cit:CI_OnlineResource/cit:linkage/gco:CharacterString)">
              <xsl:attribute name="class">col-lg-12 btn btn-default btn-lg disabled mwdisabled mwapplications</xsl:attribute> 
              <xsl:attribute name="src"><xsl:value-of select="$metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString"/></xsl:attribute>
              <span><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'otherstools')"/></span>
            </xsl:if>
          </xsl:element>
        </div>
        <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'webserviceview')"/></h4>
        <xsl:apply-templates select="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">
        </xsl:apply-templates>
        <xsl:apply-templates select="$metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[starts-with(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'OGC') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">
        </xsl:apply-templates>
      </div>
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'copy')"/></h3>
      </div>
      <div class="geoportail-section-content">
        <div class="row subsection">
        <div class="col-lg-3"></div>
        <div class="col-lg-9">
          <xsl:apply-templates select="$metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributionOrderProcess/mrd:MD_StandardOrderProcess/mrd:orderingInstructions/gco:CharacterString" />
        </div>
        </div>
        <div class="row twoside subsection">
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
        <h4><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'conditions')"/></h4>
        <xsl:apply-templates select="$metadata/mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints/gco:CharacterString" />
      </div>
    </div>
  </xsl:template>

  <xsl:template name="descriptionTemplate">
    <div class="geoportail-section">
      <div class="row">
      <div class="col-lg-6 twoside2">
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'aoi')"/></h3>
      </div>
      <div class="geoportail-section-content">
        <xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:extent/gex:EX_Extent/gex:description/gco:CharacterString"/>
      </div>
      </div>
      <div class="col-lg-6 twoside2">
      <div class="geoportail-section-title">
        <h3 class="bordertitel"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'spatialreference')"/></h3>
      </div>
      <div class="geoportail-section-content bordercontent">
        <xsl:call-template name="formatEPSG">
          <xsl:with-param name="epsgParam" select="$metadata/mdb:referenceSystemInfo/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString" />
        </xsl:call-template>
      </div>
      </div>
      </div>
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'toi')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'model')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'legend')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
      <div class="row">
      <div class="col-lg-6 twoside2">
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'mtdidentification')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
      <div class="col-lg-6 twoside2">
      <div class="geoportail-section-title">
        <h3 class="bordertitel"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'dataidentification')"/></h3>
      </div>
      <div class="geoportail-section-content bordercontent">
        <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'dataid')"/></h6>
        <p><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString"/><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[mcc:codeSpace/gco:CharacterString !='']/mcc:code/gco:CharacterString"/></p>
        <h6><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'datalastdiffusion')"/></h6>
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
      </div>
      </div>
      </div>
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'language')"/></h3>
      </div>
      <div class="geoportail-section-content">
        <p><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue" /></p>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="useTemplate">
    <div class="geoportail-section">
      <div class="row">
        <div class="col-lg-6 twoside2">
          <div class="geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'referencescale')"/></h3>
          </div>
          <div class="geoportail-section-content">
            <p><xsl:value-of select="'1:'"/><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:spatialResolution/mri:MD_Resolution/mri:equivalentScale/mri:MD_RepresentativeFraction/mri:denominator/gco:Integer"/></p>
          </div>
        </div>
        <div class="col-lg-6 twoside2">
          <div class="geoportail-section-title">
            <h3 class="bordertitel"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'resolution')"/></h3>
          </div>
          <div class="geoportail-section-content bordercontent">
            <p><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:spatialResolution/mri:MD_Resolution/mri:distance/gco:Distance"/><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:spatialResolution/mri:MD_Resolution/mri:distance/gco:Distance/@uom"/></p>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-lg-6 twoside2">
          <div class="geoportail-section-title">
            <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'precision')"/></h3>
          </div>
          <div class="geoportail-section-content">
            <p><xsl:value-of select="$metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AbsoluteExternalPositionalAccuracy/mdq:result/mdq:DQ_QuantitativeResult/mdq:value/gco:Record"/></p>
          </div>
          </div>
          <div class="col-lg-6 twoside2">
          <div class="geoportail-section-title">
            <h3 class="bordertitel"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'precisionz')"/></h3>
          </div>
          <div class="geoportail-section-content bordercontent">
            <p></p>
          </div>
        </div>
      </div>
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'genealogy')"/></h3>
      </div>
      <div class="geoportail-section-content">
        <p><xsl:value-of select="$metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:statement/gco:CharacterString"/></p>
      </div>
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'qualityreport')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'conformitytest')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
    <div class="geoportail-section">
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'associateddata')"/></h3>
      </div>
      <div class="geoportail-section-content">
        <!--xsl:call-template name="associatedtable">
         
        </xsl:call-template-->
      </div>
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'associatedsite')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
      <div class="geoportail-section-title">
        <h3><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'associateddocument')"/></h3>
      </div>
      <div class="geoportail-section-content">
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
    <div class="geoportail-section">
      <div class="geoportail-section-title">
        <h2><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'question')"/></h2>
      </div>
      <div class="geoportail-section-content">
        <div class="row geoportailcontact">
          <div class="col-lg-6  contacttemplateleft">
            <span><i class="fa fa-angle-right" aria-hidden="true"></i><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'distributioninfo')"/></span>
          </div>
          <div class="col-lg-6 contacttemplateright">
            <a>
              <xsl:attribute name="href">mailto:<xsl:value-of select="$metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='distributor']/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString"/></xsl:attribute>
              <span><xsl:value-of select="$metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue='distributor']/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/></span><span class="pull-right"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
            </a>
          </div>
        </div>
        <div class="row">
        </div>
        <div class="row">
          <div class="col-lg-6  contacttemplateleft">
            <span><i class="fa fa-angle-right" aria-hidden="true"></i><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'contentinfo')"/></span>
          </div>
          <div class="col-lg-6 contacttemplateright">
            <a>
              <xsl:attribute name="href">mailto:<xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='owner']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString" /></xsl:attribute>
              <span><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='owner']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/></span><span class="pull-right"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
            </a>
          </div>
        </div>
      </div>
      <div class="geoportail-section-title">
        <h2><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'whishes')"/></h2>
      </div>
      <div class="geoportail-section-content">
        <div class="row">
          <div class="col-lg-6  contacttemplateleft">
            <span><i class="fa fa-angle-right" aria-hidden="true"></i><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'responsable')"/></span>
          </div>
          <div class="col-lg-6 contacttemplateright">
            <a>
              <xsl:attribute name="href">mailto:<xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='pointOfContact']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress/gco:CharacterString" /></xsl:attribute>
              <span><xsl:value-of select="$metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue='pointOfContact']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString"/></span><span class="pull-right"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
            </a>
          </div>
        </div>
      </div>
      <div class="geoportail-section-title">
        <h2><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'othersquestions')"/></h2>
      </div>
      <div class="geoportail-section-content">
        <div class="row">
          <div class="col-lg-6  contacttemplateleft">
            <span><i class="fa fa-angle-right" aria-hidden="true"></i><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'geoportail')"/></span>
          </div>
          <div class="col-lg-6 contacttemplateright">
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
    <table class="table table-bordered geoportailtable">
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
                <i class="fa fa-2x fa-folder-open" aria-hidden="true"></i>
              </a>
            </td>
          </tr>
        </xsl:for-each> 
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="tableConformity">
    <table class="table table-bordered geoportailtable">
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
              <i class="fa fa-2x fa-thumbs-o-down" aria-hidden="true"></i>
            </xsl:if>
            <xsl:if test="$metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_DomainConsistency/mdq:result/mdq:DQ_ConformanceResult/mdq:pass/gco:Boolean = 'true'">
              <i class="fa fa-2x fa-thumbs-o-up" aria-hidden="true"></i>
            </xsl:if>
          </td>
        </tr> 
      </tbody>
    </table>
  </xsl:template>

<xsl:template name="associatedtable">
  <xsl:param name="param1"/>
  <xsl:param name="param2"/>
  <table class="table table-bordered geoportailtable">
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
    <tr>
      <td>
        <xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/>
      </td>
        <td>
          <xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/>
        </td>
      <td>
        <a href="{cit:CI_OnlineResource/cit:linkage/gco:CharacterString}" target="_blank" title="Ouvrir">
          <i class="fa fa-info-circle fa-2x" aria-hidden="true"></i>
        </a>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="/root/mdb:MD_Metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='information' and (cit:CI_OnlineResource/cit:applicationProfile/gco:CharacterString='' or not(cit:CI_OnlineResource/cit:applicationProfile))]">
    <tr>
      <td>
        <xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/>
      </td>
        <td>
          <xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/>
        </td>
      <td>
        <a href="{cit:CI_OnlineResource/cit:linkage/gco:CharacterString}" target="_blank" title="Ouvrir">
          <i class="fa fa-info-circle fa-2x" aria-hidden="true"></i>
        </a>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="/root/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[contains(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'ESRI:REST') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">
    <div class="row webservice">
      <div class="col-lg-6">
        <h5><xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/></h5>
        <p><xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/></p>
      </div>
      <div class="col-lg-6">
        <div class='row webservicebox'>
          <div class="col-lg-6 sheetleft">
            <div class="servicesheet servicecenter"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'descriptivesheet')"/> <i class="fa fa-info-circle pull-right servicecenter" aria-hidden="true"></i></div>
          </div>
          <div class="col-lg-6 sheetright">
            <div class="servicetype servicecenter"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'arcgismapping')"/></div>
          </div>
        </div>
        <div class='row webservicebox'>
          <div class="col-lg-3 servicesheet">
            <button class="servicecenter" style=" padding: 0;border: none; background: none;">
              <xsl:attribute name=" data-clipboard-text"><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></xsl:attribute>
                    <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'copyurl')"/>
            </button>
          </div>
          <div class="col-lg-9 servicetype servicecenter">
            <a><p><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></p></a>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="/root/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine[starts-with(cit:CI_OnlineResource/cit:protocol/gco:CharacterString,'OGC') and cit:CI_OnlineResource/cit:function/cit:CI_OnLineFunctionCode/@codeListValue='browsing']">
    
     <div class="row webservice"> <div class="col-lg-6">
        <h5><xsl:value-of select="cit:CI_OnlineResource/cit:name/gco:CharacterString"/></h5>
        <p><xsl:value-of select="cit:CI_OnlineResource/cit:description/gco:CharacterString"/></p>
      </div>
      <div class="col-lg-6">
        <div class='row webservicebox'>
          <div class="col-lg-6 sheetleft">
            <div class="servicesheet servicecenter"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'descriptivesheet')"/> <i class="fa fa-info-circle pull-right servicecenter" aria-hidden="true"></i></div>
          </div>
          <div class="col-lg-6 sheetright">
            <div class="servicetype servicecenter"><xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'view')"/></div>
          </div>
        </div>
        <div class='row webservicebox'>
          <div class="col-lg-3 servicesheet">
            <button class="servicecenter" style=" padding: 0;border: none; background: none;">
              <xsl:attribute name=" data-clipboard-text"><xsl:value-of select="cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/></xsl:attribute>
                <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'copyurl')"/>
            </button>
          </div>
          <div class="col-lg-9 servicetype servicecenter">
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
      <div class="carousel-inner" role="listbox">
        <xsl:for-each select="/root/mdb:MD_Metadata/mdb:identificationInfo/*/mri:graphicOverview/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString">
          <div class="item">
            <xsl:if test="position() = 1"><xsl:attribute name="class">item active</xsl:attribute></xsl:if>
            <img class="img-responsive center-block" src="{.}" alt="aa"/>
          </div>
        </xsl:for-each> 
      </div>
      <!-- Controls -->
      <a class="left carousel-control geoportail-carousel" data-target="#carousel-example-generic" role="button" data-slide="prev">
        <span class="fa-stack fa-lg" style=" vertical-align: middle;">
          <i class="fa fa-2x fa-circle-thin fa-stack-1x" aria-hidden="true"></i>
          <i class="fa fa-caret-left fa-stack-1x" aria-hidden="true"></i></span>
      </a>
      <a class="right carousel-control geoportail-carousel" data-target="#carousel-example-generic" role="button" data-slide="next">
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
    <xsl:choose>
         <xsl:when test="tokenize($epsgParam,'/')[last()] = '31371'">Belge 1972 / Belgian Lambert 72 (EPSG: 31370)</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="gn-fn-render:get-schema-strings($schemaStrings,'notfilledin')"/>
        </xsl:otherwise>
    </xsl:choose>
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
