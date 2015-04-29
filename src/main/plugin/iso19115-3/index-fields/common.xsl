<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0"
                xmlns:dqm="http://standards.iso.org/19157/-2/dqm/1.0"
                xmlns:gco="http://standards.iso.org/19115/-3/gco/1.0"
                xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0"
                xmlns:mcc="http://standards.iso.org/19115/-3/mcc/1.0"
                xmlns:mrc="http://standards.iso.org/19115/-3/mrc/1.0"
                xmlns:mco="http://standards.iso.org/19115/-3/mco/1.0"
                xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0"
                xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/19115/-3/mrs/1.0"
                xmlns:mrl="http://standards.iso.org/19115/-3/mrl/1.0"
                xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0"
                xmlns:gcx="http://standards.iso.org/19115/-3/gcx/1.0"
                xmlns:gex="http://standards.iso.org/19115/-3/gex/1.0"
                xmlns:gfc="http://standards.iso.org/19110/gfc/1.1"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gn-fn-iso19115-3="http://geonetwork-opensource.org/xsl/functions/profiles/iso19115-3"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                exclude-result-prefixes="#all">


  <xsl:include href="../convert/functions.xsl"/>
  <xsl:include href="../layout/utility-tpl-multilingual.xsl"/>
  <xsl:include href="index-subtemplate-fields.xsl"/>


  <!-- Thesaurus folder -->
  <xsl:param name="thesauriDir"/>

  <!-- Enable INSPIRE or not -->
  <xsl:param name="inspire" select="false()"/>

  <!-- If identification citation dates
    should be indexed as a temporal extent information (eg. in INSPIRE
    metadata implementing rules, those elements are defined as part
    of the description of the temporal extent). -->
  <xsl:variable name="useDateAsTemporalExtent" select="false()"/>

  <!-- Load INSPIRE theme thesaurus if available -->
  <xsl:variable name="inspire-thesaurus"
                select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>

  <xsl:variable name="inspire-theme"
                select="if ($inspire-thesaurus//skos:Concept)
                        then $inspire-thesaurus//skos:Concept
                        else ''"/>

  <xsl:variable name="metadata"
                select="/mdb:MD_Metadata"/>


  <!-- Metadata UUID. -->
  <xsl:variable name="fileIdentifier"
                select="$metadata/
                            mdb:metadataIdentifier[1]/
                            mcc:MD_Identifier/mcc:code/*"/>

  <!-- Get the language -->
  <xsl:variable name="documentMainLanguage">
    <xsl:call-template name="langId19115-3"/>
  </xsl:variable>



  <xsl:template name="indexMetadata">
    <xsl:param name="lang" select="$documentMainLanguage"/>
    <xsl:param name="langId" select="''"/>

    <Document locale="{$lang}">
      <Field name="_locale" string="{$lang}" store="true" index="true"/>
      <Field name="_docLocale" string="{$lang}" store="true" index="true"/>

      <!-- Extension point using index mode -->
      <xsl:apply-templates mode="index" select="*"/>

      <xsl:call-template name="CommonFieldsFactory">
        <xsl:with-param name="lang" select="$lang"/>
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>



      <!-- === Free text search === -->
      <Field name="any" store="false" index="true">
        <xsl:attribute name="string">
          <xsl:choose>
            <xsl:when test="$langId != ''">
              <xsl:value-of select="normalize-space(//node()[@locale=$langId])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(string(.))"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> </xsl:text>
          <xsl:for-each select="//@codeListValue">
            <xsl:value-of select="concat(., ' ')"/>
          </xsl:for-each>
        </xsl:attribute>
      </Field>
    </Document>
  </xsl:template>



  <!-- Index a field based on the language -->
  <xsl:function name="gn-fn-iso19115-3:index-field" as="node()?">
    <xsl:param name="fieldName" as="xs:string"/>
    <xsl:param name="element" as="node()"/>

    <xsl:copy-of select="gn-fn-iso19115-3:index-field($fieldName,
                  $element, $documentMainLanguage, true(), true())"/>
  </xsl:function>
  <xsl:function name="gn-fn-iso19115-3:index-field" as="node()?">
    <xsl:param name="fieldName" as="xs:string"/>
    <xsl:param name="element" as="node()"/>
    <xsl:param name="langId" as="xs:string"/>

    <xsl:copy-of select="gn-fn-iso19115-3:index-field($fieldName,
                  $element, $langId, true(), true())"/>
  </xsl:function>
  <xsl:function name="gn-fn-iso19115-3:index-field" as="node()?">
    <xsl:param name="fieldName" as="xs:string"/>
    <xsl:param name="element" as="node()"/>
    <xsl:param name="langId" as="xs:string"/>
    <xsl:param name="store" as="xs:boolean"/>
    <xsl:param name="index" as="xs:boolean"/>

    <xsl:variable name="value">
      <xsl:for-each select="$element">
        <xsl:apply-templates mode="localised" select=".">
          <xsl:with-param name="langId" select="concat('#', $langId)"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </xsl:variable>
    <!--<xsl:message><xsl:value-of select="$fieldName"/>:<xsl:value-of select="normalize-space($value)"/> (<xsl:value-of select="$langId"/>) </xsl:message>-->
    <xsl:if test="normalize-space($value) != ''">
      <Field name="{$fieldName}"
             string="{normalize-space($value)}"
             store="{$store}"
             index="{$index}"/>
    </xsl:if>
  </xsl:function>



  <xsl:template name="CommonFieldsFactory">
    <xsl:param name="lang" select="$documentMainLanguage"/>
    <xsl:param name="langId" select="''"/>

    <!-- The default title in the main language -->
    <xsl:variable name="_defaultTitle">
      <xsl:call-template name="defaultTitle">
        <xsl:with-param name="isoDocLangId" select="$documentMainLanguage"/>
      </xsl:call-template>
    </xsl:variable>

    <Field name="_defaultTitle"
           string="{string($_defaultTitle)}"
           store="true"
           index="true"/>
    <!-- not tokenized title for sorting, needed for multilingual sorting -->
    <Field name="_title"
           string="{string($_defaultTitle)}"
           store="true"
           index="true" />



    <xsl:for-each select="$metadata/mdb:identificationInfo/*">

      <xsl:for-each select="mri:citation/*">
        <xsl:for-each select="mcc:identifier/mcc:MD_Identifier/mcc:code">
          <xsl:copy-of select="gn-fn-iso19115-3:index-field('identifier', ., $langId)"/>
        </xsl:for-each>

        <xsl:for-each select="cit:title">
          <xsl:copy-of select="gn-fn-iso19115-3:index-field('title', ., $langId)"/>
        </xsl:for-each>

        <xsl:for-each select="cit:alternateTitle">
          <xsl:copy-of select="gn-fn-iso19115-3:index-field('altTitle', ., $langId)"/>
        </xsl:for-each>

        <xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date">
          <Field name="revisionDate"
                 string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                 store="true" index="true"/>
          <Field name="createDateMonth"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 8)}"
                 store="true" index="true"/>
          <Field name="createDateYear"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 5)}"
                 store="true" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin"
                   string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                   store="true" index="true"/>
          </xsl:if>
        </xsl:for-each>


        <xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='creation']/cit:date">
          <Field name="createDate"
                 string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                 store="true" index="true"/>
          <Field name="createDateMonth"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 8)}"
                 store="true" index="true"/>
          <Field name="createDateYear"
                 string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 5)}"
                 store="true" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin"
                   string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                   store="true" index="true"/>
          </xsl:if>
        </xsl:for-each>


        <xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='publication']/cit:date">
          <Field name="publicationDate"
                 string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                 store="true" index="true"/>
          <xsl:if test="$useDateAsTemporalExtent">
            <Field name="tempExtentBegin"
                   string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}"
                   store="true" index="true"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="mri:abstract">
        <xsl:copy-of select="gn-fn-iso19115-3:index-field('abstract', ., $langId)"/>
      </xsl:for-each>

      <xsl:for-each select="mri:credit">
        <xsl:copy-of select="gn-fn-iso19115-3:index-field('credit', ., $langId)"/>
      </xsl:for-each>


      <xsl:for-each select="*/gex:EX_Extent">
        <xsl:apply-templates select="gex:geographicElement/gex:EX_GeographicBoundingBox" mode="latLon19115-3"/>

        <xsl:for-each select="gex:geographicElement/gex:EX_GeographicDescription/gex:geographicIdentifier/
                                  mcc:MD_Identifier/mcc:code">
          <xsl:copy-of select="gn-fn-iso19115-3:index-field('geoDescCode', ., $langId)"/>
        </xsl:for-each>

        <xsl:for-each select="mri:temporalElement/gex:EX_TemporalExtent/gex:extent">
          <xsl:for-each select="gml:TimePeriod">
            <xsl:variable name="times">
              <xsl:call-template name="newGmlTime">
                <xsl:with-param name="begin" select="gml:beginPosition|gml:begin/gml:TimeInstant/gml:timePosition"/>
                <xsl:with-param name="end" select="gml:endPosition|gml:end/gml:TimeInstant/gml:timePosition"/>
              </xsl:call-template>
            </xsl:variable>

            <Field name="tempExtentBegin" string="{lower-case(substring-before($times,'|'))}" store="true" index="true"/>
            <Field name="tempExtentEnd" string="{lower-case(substring-after($times,'|'))}" store="true" index="true"/>
          </xsl:for-each>

        </xsl:for-each>
      </xsl:for-each>


      <xsl:for-each select="//mri:MD_Keywords">
        <xsl:for-each select="mri:keyword">
          <xsl:copy-of select="gn-fn-iso19115-3:index-field('keyword', ., $langId)"/>
        </xsl:for-each>

        <xsl:for-each select="mri:keyword/gco:CharacterString|
                                mri:keyword/gcx:Anchor|
                                mri:keyword/lan:PT_FreeText/lan:textGroup/lan:LocalisedCharacterString">
          <xsl:if test="$inspire">
            <xsl:if test="string-length(.) &gt; 0">

              <xsl:variable name="inspireannex">
                <xsl:call-template name="determineInspireAnnex">
                  <xsl:with-param name="keyword" select="string(.)"/>
                  <xsl:with-param name="inspireThemes" select="$inspire-theme"/>
                </xsl:call-template>
              </xsl:variable>

              <!-- Add the inspire field if it's one of the 34 themes -->
              <xsl:if test="normalize-space($inspireannex)!=''">
                <Field name="inspiretheme" string="{string(.)}" store="false" index="true"/>
                <Field name="inspireannex" string="{$inspireannex}" store="false" index="true"/>
                <Field name="inspirecat" string="true" store="false" index="true"/>
              </xsl:if>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="mri:topicCategory/mri:MD_TopicCategoryCode">
        <Field name="topicCat" string="{string(.)}" store="true" index="true"/>

        <!--FIXME <Field name="keyword"
               string="{util:getCodelistTranslation('gmd:MD_TopicCategoryCode', string(.), $lang}"
               store="true" index="true"/>-->
      </xsl:for-each>

      <xsl:for-each select="mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
        <Field name="datasetLang" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>


      <!-- TODO: Index new type of resolution -->
      <xsl:for-each select="mri:spatialResolution/mri:MD_Resolution">
        <xsl:for-each select="mri:equivalentScale/mri:MD_RepresentativeFraction/mri:denominator/gco:Integer">
          <Field name="denominator" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="mri:distance/gco:Distance">
          <Field name="distanceVal" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="mri:distance/gco:Distance/@uom">
          <Field name="distanceUom" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:for-each>



      <!-- Index associated resources and provides option to query by type of
           association and type of initiative

      Association info is indexed by adding the following fields to the index:
       * agg_use: boolean
       * agg_with_association: {$associationType}
       * agg_{$associationType}: {$code}
       * agg_{$associationType}_with_initiative: {$initiativeType}
       * agg_{$associationType}_{$initiativeType}: {$code}

      Sample queries:
       * Search for records with siblings: http://localhost:8080/geonetwork/srv/fre/q?agg_use=true
       * Search for records having a crossReference with another record:
       http://localhost:8080/geonetwork/srv/fre/q?agg_crossReference=23f0478a-14ba-4a24-b365-8be88d5e9e8c
       * Search for records having a crossReference with another record:
       http://localhost:8080/geonetwork/srv/fre/q?agg_crossReference=23f0478a-14ba-4a24-b365-8be88d5e9e8c
       * Search for records having a crossReference of type "study" with another record:
       http://localhost:8080/geonetwork/srv/fre/q?agg_crossReference_study=23f0478a-14ba-4a24-b365-8be88d5e9e8c
       * Search for records having a crossReference of type "study":
       http://localhost:8080/geonetwork/srv/fre/q?agg_crossReference_with_initiative=study
       * Search for records having a "crossReference" :
       http://localhost:8080/geonetwork/srv/fre/q?agg_with_association=crossReference
      -->
      <xsl:for-each select="mri:associatedResource/mri:MD_AssociatedResource">
        <xsl:variable name="code" select="mri:metadataReference/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString"/>
        <xsl:if test="$code != ''">
          <xsl:variable name="associationType" select="mri:associationType/mri:DS_AssociationTypeCode/@codeListValue"/>
          <xsl:variable name="initiativeType" select="mri:initiativeType/mri:DS_InitiativeTypeCode/@codeListValue"/>
          <Field name="agg_{$associationType}_{$initiativeType}" string="{$code}" store="false" index="true"/>
          <Field name="agg_{$associationType}_with_initiative" string="{$initiativeType}" store="false" index="true"/>
          <Field name="agg_{$associationType}" string="{$code}" store="false" index="true"/>
          <Field name="agg_with_association" string="{$associationType}" store="false" index="true"/>
          <Field name="agg_use" string="true" store="false" index="true"/>
        </xsl:if>
      </xsl:for-each>



      <xsl:for-each select="srv:serviceType/gco:LocalName">
        <Field name="serviceType" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:serviceTypeVersion/gco:CharacterString">
        <Field  name="serviceTypeVersion" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//srv:SV_OperationMetadata/srv:operationName/gco:CharacterString">
        <Field  name="operation" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:operatesOn/@uuidref">
        <Field  name="operatesOn" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="srv:coupledResource">
        <xsl:for-each select="srv:SV_CoupledResource/srv:identifier/gco:CharacterString">
          <Field  name="operatesOnIdentifier" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="srv:SV_CoupledResource/srv:operationName/gco:CharacterString">
          <Field  name="operatesOnName" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:for-each>


      <xsl:for-each select="mri:pointOfContact/cit:CI_Responsibility">
        <xsl:variable name="orgName" select="string(cit:party/cit:CI_Organisation/cit:name/*)"/>

        <xsl:copy-of select="gn-fn-iso19115-3:index-field('orgName', cit:party/cit:CI_Organisation/cit:name, $langId)"/>

        <xsl:variable name="role" select="cit:role/*/@codeListValue"/>
        <xsl:variable name="email" select="cit:contactInfo/cit:CI_Contact/
                                              cit:address/cit:CI_Address/
                                              cit:electronicMailAddress/gco:CharacterString"/>
        <xsl:variable name="logo" select="cit/party/cit:CI_Organisation/
                                              cit:logo/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString"/>

        <Field name="responsibleParty"
               string="{concat($role, '|resource|', $orgName, '|', $logo, '|', $email)}"
               store="true" index="false"/>
      </xsl:for-each>



      <!-- FIXME: Additional constraints have been created in the mco schema -->
      <xsl:for-each select="mri:resourceConstraints">
        <xsl:for-each select="//mco:otherConstraints">
          <xsl:copy-of select="gn-fn-iso19115-3:index-field('otherConstr', ., $langId)"/>
        </xsl:for-each>
        <xsl:for-each select="//mco:useLimitation">
          <xsl:copy-of select="gn-fn-iso19115-3:index-field('conditionApplyingToAccessAndUse', ., $langId)"/>
        </xsl:for-each>
      </xsl:for-each>





      <!-- FIXME: BrowseGraphic needs improvement - there are changes
           to get URL from mcc:linkage rather than mcc:fileName and
           mcc:fileDescription - see extract-thumnails.xsl -->
      <xsl:for-each select="mri:graphicOverview/mcc:MD_BrowseGraphic">
        <xsl:variable name="fileName"  select="mcc:fileName/gco:CharacterString"/>
        <xsl:if test="$fileName != ''">
          <xsl:variable name="fileDescr" select="mcc:fileDescription/gco:CharacterString"/>
          <xsl:choose>
            <xsl:when test="contains($fileName ,'://')">
              <xsl:choose>
                <xsl:when test="string($fileDescr)='thumbnail'">
                  <Field  name="image" string="{concat('thumbnail|', $fileName)}" store="true" index="false"/>
                </xsl:when>
                <xsl:when test="string($fileDescr)='large_thumbnail'">
                  <Field  name="image" string="{concat('overview|', $fileName)}" store="true" index="false"/>
                </xsl:when>
                <xsl:otherwise>
                  <Field  name="image" string="{concat('unknown|', $fileName)}" store="true" index="false"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="count(mri:graphicOverview/mcc:MD_BrowseGraphic) = 0">
        <Field  name="nooverview" string="true" store="false" index="true"/>
      </xsl:if>

    </xsl:for-each>



    <xsl:for-each select="$metadata/mdb:distributionInfo/mrd:MD_Distribution">
      <xsl:for-each select="mrd:distributionFormat/mrd:MD_Format/
                                mrd:formatSpecificationCitation/cit:CI_Citation/cit:title">
        <xsl:copy-of select="gn-fn-iso19115-3:index-field('format', ., $langId)"/>
      </xsl:for-each>


      <!-- TODO: Need a rework -->
      <xsl:for-each select="mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[cit:linkage/*!='']">
        <xsl:variable name="download_check"><xsl:text>&amp;fname=&amp;access</xsl:text></xsl:variable>
        <xsl:variable name="linkage" select="cit:linkage/*" />
        <xsl:variable name="title" select="normalize-space(cit:name/gco:CharacterString|cit:name/gcx:MimeFileType)"/>
        <xsl:variable name="desc" select="normalize-space(cit:description/gco:CharacterString)"/>
        <xsl:variable name="protocol" select="normalize-space(cit:protocol/gco:CharacterString)"/>
        <xsl:variable name="mimetype" select="''"/>
        <!--<xsl:variable name="mimetype" select="geonet:protocolMimeType($linkage, $protocol, cit:name/gcx:MimeFileType/@type)"/>-->

        <!-- If the linkage points to WMS service and no protocol specified, manage as protocol OGC:WMS -->
        <xsl:variable name="wmsLinkNoProtocol" select="contains(lower-case($linkage), 'service=wms') and not(string($protocol))" />

        <!-- ignore empty downloads -->
        <xsl:if test="string($linkage)!='' and not(contains($linkage,$download_check))">
          <Field name="protocol" string="{string($protocol)}" store="true" index="true"/>
        </xsl:if>

        <xsl:if test="normalize-space($mimetype)!=''">
          <Field name="mimetype" string="{$mimetype}" store="true" index="true"/>
        </xsl:if>

        <xsl:if test="contains($protocol, 'WWW:DOWNLOAD')">
          <Field name="download" string="true" store="false" index="true"/>
        </xsl:if>

        <xsl:if test="contains($protocol, 'OGC:WMS') or $wmsLinkNoProtocol">
          <Field name="dynamic" string="true" store="false" index="true"/>
        </xsl:if>

        <!-- ignore WMS links without protocol (are indexed below with mimetype application/vnd.ogc.wms_xml) -->
        <xsl:if test="not($wmsLinkNoProtocol)">
          <Field name="link" string="{concat($title, '|', $desc, '|', $linkage, '|', $protocol, '|', $mimetype)}" store="true" index="false"/>
        </xsl:if>

        <!-- Add KML link if WMS -->
        <xsl:if test="starts-with($protocol,'OGC:WMS-') and contains($protocol,'-get-map') and string($linkage)!='' and string($title)!=''">
          <!-- FIXME : relative path -->
          <Field name="link" string="{concat($title, '|', $desc, '|',
              '../../srv/en/google.kml?uuid=', $fileIdentifier, '&amp;layers=', $title,
              '|application/vnd.google-earth.kml+xml|application/vnd.google-earth.kml+xml')}" store="true" index="false"/>
        </xsl:if>

        <!-- Try to detect Web Map Context by checking protocol or file extension -->
        <xsl:if test="starts-with($protocol,'OGC:WMC') or contains($linkage,'.wmc')">
          <Field name="link" string="{concat($title, '|', $desc, '|',
              $linkage, '|application/vnd.ogc.wmc|application/vnd.ogc.wmc')}" store="true" index="false"/>
        </xsl:if>

        <xsl:if test="$wmsLinkNoProtocol">
          <Field name="link" string="{concat($title, '|', $desc, '|',
      $linkage, '|OGC:WMS|application/vnd.ogc.wms_xml')}" store="true" index="false"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>





    <xsl:for-each select="$metadata/mdb:dataQualityInfo/*/dqm:report/*/dqm:result">
      <xsl:if test="$inspire">
        <!--
        INSPIRE related dataset could contains a conformity section with:
        * COMMISSION REGULATION (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services
        * INSPIRE Data Specification on <Theme Name> – <version>
        * INSPIRE Specification on <Theme Name> – <version> for CRS and GRID

        Index those types of citation title to found dataset related to INSPIRE (which may be better than keyword
        which are often used for other types of datasets).

        "1089/2010" is maybe too fuzzy but could work for translated citation like "Règlement n°1089/2010, Annexe II-6" TODO improved
        -->
        <xsl:if test="(
            contains(dqm:DQ_ConformanceResult/dqm:specification/cit:CI_Citation/cit:title/gco:CharacterString, '1089/2010') or
            contains(dqm:DQ_ConformanceResult/dqm:specification/cit:CI_Citation/cit:title/gco:CharacterString, 'INSPIRE Data Specification') or
            contains(dqm:DQ_ConformanceResult/dqm:specification/cit:CI_Citation/cit:title/gco:CharacterString, 'INSPIRE Specification'))">
          <Field name="inspirerelated" string="on" store="false" index="true"/>
        </xsl:if>
      </xsl:if>

      <xsl:for-each select="//dqm:pass/gco:Boolean">
        <Field name="degree" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//dqm:specification/*/cit:title">
        <xsl:copy-of select="gn-fn-iso19115-3:index-field('specificationTitle', ., $langId)"/>
      </xsl:for-each>

      <xsl:for-each select="//dqm:specification/*/cit:date/*/cit:date">
        <Field name="specificationDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="//dqm:specification/*/cit:date/*/cit:dateType/cit:CI_DateTypeCode/@codeListValue">
        <Field name="specificationDateType" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="mdb:dataQualityInfo/*/dqm:lineage/*/dqm:statement">
      <xsl:copy-of select="gn-fn-iso19115-3:index-field('lineage', ., $langId)"/>
    </xsl:for-each>





    <xsl:for-each select="$metadata/mdb:contact/cit:CI_Responsibility">
      <xsl:variable name="orgName" select="string(cit:party/cit:CI_Organisation/cit:name/*)"/>
      <xsl:copy-of select="gn-fn-iso19115-3:index-field('orgName', cit:party/cit:CI_Organisation/cit:name, $langId)"/>

      <xsl:variable name="role" select="cit:role/*/@codeListValue"/>
      <xsl:variable name="logo" select="cit/party/cit:CI_Organisation/
                                              cit:logo/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString"/>

      <Field name="responsibleParty" string="{concat($role, '|metadata|', $orgName, '|', $logo)}" store="true" index="false"/>
    </xsl:for-each>





    <xsl:for-each select="$metadata/mdb:contentInfo/mrc:MD_FeatureCatalogueDescription/mrc:featureCatalogueCitation[@uuidref]">
      <Field  name="hasfeaturecat" string="{string(@uuidref)}" store="false" index="true"/>
    </xsl:for-each>

    <!-- Index feature catalog as complex object in attributeTable field.
    TODO multilingual -->
    <xsl:for-each select="$metadata/mdb:contentInfo/mrc:MD_FeatureCatalogue/mrc:featureCatalogue">
      <xsl:variable name="attributes"
                    select=".//gfc:carrierOfCharacteristics"/>
      <xsl:if test="count($attributes) > 0">
        <xsl:variable name="jsonAttributeTable">
          [<xsl:for-each select="$attributes">
          {"name": "<xsl:value-of select="*/gfc:code/*/text()"/>",
          "definition": "<xsl:value-of select="*/gfc:definition/*/text()"/>",
          "type": "<xsl:value-of select="*/gfc:valueType/gco:TypeName/gco:aName/*/text()"/>"
          <xsl:if test="*/gfc:listedValue">
            ,"values": [<xsl:for-each select="*/gfc:listedValue">{
            "label": "<xsl:value-of select="*/gfc:label/*/text()"/>",
            "code": "<xsl:value-of select="*/gfc:code/*/text()"/>",
            "definition": "<xsl:value-of select="*/gfc:definition/*/text()"/>"}
            <xsl:if test="position() != last()">,</xsl:if>
          </xsl:for-each>]
          </xsl:if>}
          <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>]
        </xsl:variable>
        <Field name="attributeTable" index="true" store="true"
               string="{$jsonAttributeTable}"/>
      </xsl:if>
    </xsl:for-each>



    <xsl:for-each select="$metadata/mdb:resourceLineage/*/mrl:source[@uuidref]">
      <Field  name="hassource" string="{string(@uuidref)}" store="false" index="true"/>
    </xsl:for-each>




    <!-- Metadata scope -->
    <xsl:choose>
      <xsl:when test="$metadata/mdb:metadataScope">
        <xsl:for-each select="$metadata/mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue">
          <Field name="type" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- If not defined, record is a dataset -->
        <Field name="type" string="dataset" store="true" index="true"/>
      </xsl:otherwise>
    </xsl:choose>


    <!-- TODO need a check -->
    <xsl:variable name="isDataset"
                  select="count($metadata/mdb:metadataScope[mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue='dataset']) > 0"/>
    <xsl:variable name="isMapDigital"
                  select="count($metadata/mri:identificationInfo/*/cit:citation/*/
			                          cit:presentationForm[cit:CI_PresentationFormCode/@codeListValue = 'mapDigital']) > 0"/>
    <xsl:variable name="isStatic"
                  select="count($metadata/mdb:distributionInfo/mrd:MD_Distribution/
			                          mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/*/
			                            cit:name/gco:CharacterString[
			                              contains(., 'PDF') or
			                              contains(., 'PNG') or
			                              contains(., 'JPEG')]) > 0"/>
    <xsl:variable name="isInteractive"
                  select="count($metadata/mdb:distributionInfo/*/
                                mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/*/
                                  cit:name/gco:CharacterString[
                                    contains(., 'OGC:WMC') or
                                    contains(., 'OGC:OWS')]) > 0"/>
    <xsl:variable name="isPublishedWithWMCProtocol"
                  select="count($metadata/mdb:distributionInfo/*/mrd:transferOptions/*/mrd:onLine/*/cit:protocol[
                                  starts-with(gco:CharacterString, 'OGC:WMC')]) > 0"/>

    <xsl:if test="$isDataset and $isMapDigital and ($isStatic or $isInteractive or $isPublishedWithWMCProtocol)">
      <Field name="type" string="map" store="true" index="true"/>
      <xsl:choose>
        <xsl:when test="$isStatic">
          <Field name="type" string="staticMap" store="true" index="true"/>
        </xsl:when>
        <xsl:when test="$isInteractive or $isPublishedWithWMCProtocol">
          <Field name="type" string="interactiveMap" store="true" index="true"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>


    <xsl:choose>
      <xsl:when test="$metadata/mdb:identificationInfo/srv:SV_ServiceIdentification">
        <Field name="type" string="service" store="false" index="true"/>
      </xsl:when>
    </xsl:choose>

    <xsl:for-each select="$metadata/mdb:metadataScope/mdb:MD_MetadataScope/mdb:name">
      <xsl:copy-of select="gn-fn-iso19115-3:index-field('levelName', .)"/>
    </xsl:for-each>




    <xsl:for-each select="$metadata/mdb:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue|
                          $metadata/mdb:otherLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
      <Field name="language" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>





    <xsl:for-each select="$metadata/mdb:metadataIdentifier/mcc:MD_Identifier">
      <Field name="fileId" string="{string(mcc:code/gco:CharacterString)}" store="false" index="true"/>
    </xsl:for-each>



    <xsl:for-each select="
	    $metadata/mdb:parentMetadata/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString|
	    $metadata/mdb:parentMetadata/@uuidref">
      <Field name="parentUuid" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>




    <xsl:for-each select="$metadata/mdb:dateInfo/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/*">
      <Field name="changeDate" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>


    <!-- TODO: Need a check -->
    <xsl:for-each select="$metadata/mdb:referenceSystemInfo/mrs:MD_ReferenceSystem">
      <xsl:for-each select="mrs:referenceSystemIdentifier/mcc:MD_Identifier">
        <xsl:variable name="crs" select="concat(string(mcc:codeSpace/gco:CharacterString),'::',string(mcc:code/gco:CharacterString))"/>

        <xsl:if test="$crs != '::'">
          <Field name="crs" string="{$crs}" store="false" index="true"/>
        </xsl:if>

        <Field name="authority" string="{string(mcc:codeSpace/gco:CharacterString)}" store="false" index="true"/>
        <Field name="crsCode" string="{string(mcc:code/gco:CharacterString)}" store="false" index="true"/>
        <Field name="crsVersion" string="{string(mcc:version/gco:CharacterString)}" store="false" index="true"/>
      </xsl:for-each>
    </xsl:for-each>


    <!-- Index all codelist -->
    <xsl:for-each select="$metadata//*[*/@codeListValue != '']">
      <Field name="cl_{local-name()}"
             string="{*/@codeListValue}"
             store="true" index="true"/>
      <!--<xsl:message><xsl:value-of select="name(*)"/>:<xsl:value-of select="*/@codeListValue"/> (<xsl:value-of select="$lang"/>) = <xsl:value-of select="util:getCodelistTranslation(name(*), string(*/@codeListValue), $lang)"/></xsl:message>-->
      <Field name="cl_{concat(local-name(), '_text')}"
             string="{util:getCodelistTranslation(name(*), string(*/@codeListValue), string($lang))}"
             store="true" index="true"/>
    </xsl:for-each>

  </xsl:template>





  <!-- Traverse the tree in index mode -->
  <xsl:template mode="index" match="*|@*">
    <xsl:apply-templates mode="index" select="*|@*"/>
  </xsl:template>



  <!-- inspireThemes is a nodeset consisting of skos:Concept elements -->
  <!-- each containing a skos:definition and skos:prefLabel for each language -->
  <!-- This template finds the provided keyword in the skos:prefLabel elements and returns the English one from the same skos:Concept -->
  <xsl:template name="translateInspireThemeToEnglish">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>
    <xsl:for-each select="$inspireThemes/skos:prefLabel">
      <!-- if this skos:Concept contains a kos:prefLabel with text value equal to keyword -->
      <xsl:if test="text() = $keyword">
        <xsl:value-of select="../skos:prefLabel[@xml:lang='en']/text()"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="determineInspireAnnex">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>
    <xsl:variable name="englishKeywordMixedCase">
      <xsl:call-template name="translateInspireThemeToEnglish">
        <xsl:with-param name="keyword" select="$keyword"/>
        <xsl:with-param name="inspireThemes" select="$inspireThemes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="englishKeyword" select="lower-case($englishKeywordMixedCase)"/>
    <!-- Another option could be to add the annex info in the SKOS thesaurus using something
    like a related concept. -->
    <xsl:choose>
      <!-- annex i -->
      <xsl:when test="$englishKeyword='coordinate reference systems' or $englishKeyword='geographical grid systems'
			            or $englishKeyword='geographical names' or $englishKeyword='administrative units'
			            or $englishKeyword='addresses' or $englishKeyword='cadastral parcels'
			            or $englishKeyword='transport networks' or $englishKeyword='hydrography'
			            or $englishKeyword='protected sites'">
        <xsl:text>i</xsl:text>
      </xsl:when>
      <!-- annex ii -->
      <xsl:when test="$englishKeyword='elevation' or $englishKeyword='land cover'
			            or $englishKeyword='orthoimagery' or $englishKeyword='geology'">
        <xsl:text>ii</xsl:text>
      </xsl:when>
      <!-- annex iii -->
      <xsl:when test="$englishKeyword='statistical units' or $englishKeyword='buildings'
			            or $englishKeyword='soil' or $englishKeyword='land use'
			            or $englishKeyword='human health and safety' or $englishKeyword='utility and government services'
			            or $englishKeyword='environmental monitoring facilities' or $englishKeyword='production and industrial facilities'
			            or $englishKeyword='agricultural and aquaculture facilities' or $englishKeyword='population distribution - demography'
			            or $englishKeyword='area management/restriction/regulation zones and reporting units'
			            or $englishKeyword='natural risk zones' or $englishKeyword='atmospheric conditions'
			            or $englishKeyword='meteorological geographical features' or $englishKeyword='oceanographic geographical features'
			            or $englishKeyword='sea regions' or $englishKeyword='bio-geographical regions'
			            or $englishKeyword='habitats and biotopes' or $englishKeyword='species distribution'
			            or $englishKeyword='energy resources' or $englishKeyword='mineral resources'">
        <xsl:text>iii</xsl:text>
      </xsl:when>
      <!-- inspire annex cannot be established: leave empty -->
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>