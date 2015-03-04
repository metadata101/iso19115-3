<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0/2014-12-25"
  xmlns:mds="http://standards.iso.org/19115/-3/mds/1.0/2014-12-25"
  xmlns:mcc="http://standards.iso.org/19115/-3/mcc/1.0/2014-12-25"
  xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"
  xmlns:mrs="http://standards.iso.org/19115/-3/mrs/1.0/2014-12-25"
  xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0/2014-12-25"
  xmlns:mco="http://standards.iso.org/19115/-3/mco/1.0/2014-12-25"
  xmlns:mdq="http://standards.iso.org/19157/-2/mdq/1.0/2014-12-25"
  xmlns:msr="http://standards.iso.org/19115/-3/msr/1.0/2014-12-25"
  xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0/2014-12-25"
  xmlns:gcx="http://standards.iso.org/19115/-3/gcx/1.0/2014-12-25"
  xmlns:gex="http://standards.iso.org/19115/-3/gex/1.0/2014-12-25"
  xmlns:dqm="http://standards.iso.org/19157/-2/dqm/1.0/2014-12-25"
  xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
  xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
  xmlns:gmx="http://standards.iso.org/19115/-3/gmx"
  xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gn="http://www.fao.org/geonetwork"
  xmlns:gn-fn-core="http://geonetwork-opensource.org/xsl/functions/core" 
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
  exclude-result-prefixes="#all">

  <xsl:include href="utility-tpl.xsl"/>
  <xsl:include href="layout-custom-fields.xsl"/>
  <xsl:include href="layout-custom-fields-keywords.xsl"/>

  <!-- Visit all XML tree recursively -->
  <xsl:template mode="mode-iso19115-3"
                match="mds:*|mcc:*|mri:*|mrs:*|mrd:*|mco:*|msr:*|lan:*|
                       gcx:*|gex:*|dqm:*|mdq:*|cit:*|srv:*|gml:*|gts:*"
                priority="2">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:apply-templates mode="mode-iso19115-3" select="*|@*">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="labels" select="$labels"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Ignore all gn element -->
  <xsl:template mode="mode-iso19115-3" match="gn:*|@gn:*|@*" priority="1000"/>


  <!-- Template to display non existing element ie. geonet:child element
	of the metadocument. Display in editing mode only and if
  the editor mode is not flat mode. -->
  <xsl:template mode="mode-iso19115-3" match="gn:child" priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <!-- TODO: this should be common to all schemas -->
    <xsl:if test="$isEditing and
      not($isFlatMode)">

      <xsl:variable name="name" select="concat(@prefix, ':', @name)"/>
      <xsl:variable name="directive" select="gn-fn-metadata:getFieldAddDirective($editorConfig, $name)"/>

      <xsl:call-template name="render-element-to-add">
        <!-- TODO: add xpath and isoType to get label ? -->
        <xsl:with-param name="label"
                        select="gn-fn-metadata:getLabel($schema, $name, $labels, name(..), '', '')/label"/>
        <xsl:with-param name="directive" select="$directive"/>
        <xsl:with-param name="childEditInfo" select="."/>
        <xsl:with-param name="parentEditInfo" select="../gn:element"/>
        <xsl:with-param name="isFirst" select="count(preceding-sibling::*[name() = $name]) = 0"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Boxed element

      Details about the last line :
      * namespace-uri(.) != $gnUri: Only take into account profile's element
      * and $isFlatMode = false(): In flat mode, don't box any
      * and gmd:*: Match all elements having gmd child elements
      * and not(gco:CharacterString): Don't take into account those having gco:CharacterString (eg. multilingual elements)
  -->
  <xsl:template mode="mode-iso19115-3" priority="200"
                match="*[name() = $editorConfig/editor/fieldsWithFieldset/name
                          or @gco:isoType = $editorConfig/editor/fieldsWithFieldset/name]|
                        *[namespace-uri(.) != $gnUri and $isFlatMode = false() and
                        not(gco:CharacterString)]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>

    <xsl:variable name="attributes">
      <!-- Create form for all existing attribute (not in gn namespace)
      and all non existing attributes not already present. -->
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="
        @*|
        gn:attribute[not(@name = parent::node()/@*/name())]">
        <xsl:with-param name="ref" select="gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="gn:element/@ref"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="errors">
      <xsl:if test="$showValidationErrors">
        <xsl:call-template name="get-errors"/>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label"
                      select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)/label"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="errors" select="$errors"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
      <xsl:with-param name="subTreeSnippet">
        <!-- Process child of those element. Propagate schema
        and labels to all subchilds (eg. needed like iso19110 elements
        contains gmd:* child. -->
        <xsl:apply-templates mode="mode-iso19115-3" select="*">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="labels" select="$labels"/>
        </xsl:apply-templates>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Render simple element which usually match a form field -->
  <xsl:template mode="mode-iso19115-3" priority="200"
                match="*[gco:CharacterString|gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gmx:FileName|
       gco:Scale|gco:RecordType|gmx:MimeFileType|gco:LocalName|gco:ScopedName|gco:RecordType|
       gco:Record]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="elementName" select="name()"/>

    <xsl:variable name="hasPTFreeText" select="count(lan:PT_FreeText) > 0"/>

    <xsl:variable name="isMultilingualElement"
                  select="$metadataIsMultilingual and
              count($editorConfig/editor/multilingualFields/exclude[name = $elementName]) = 0"/>
    <xsl:variable name="isMultilingualElementExpanded"
                  select="count($editorConfig/editor/multilingualFields/expanded[name = $elementName]) > 0"/>

    <!-- For some fields, always display attributes.
    TODO: move to editor config ? -->
    <xsl:variable name="forceDisplayAttributes" select="false()"/>

    <!-- TODO: Support gmd:LocalisedCharacterString -->
    <xsl:variable name="theElement" select="gco:CharacterString|gco:Integer|gco:Decimal|
      gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gmx:FileName|
      gco:Scale|gco:RecordType|gmx:MimeFileType|gco:LocalName|gco:ScopedName|gco:RecordType|
       gco:Record"/>

    <!--
      This may not work if node context is lost eg. when an element is rendered
      after a selection with copy-of.
      <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>-->
    <xsl:variable name="xpath" select="gn-fn-metadata:getXPathByRef(gn:element/@ref, $metadata, false())"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="helper" select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>

    <xsl:variable name="attributes">

      <!-- Create form for all existing attribute (not in gn namespace)
      and all non existing attributes not already present for the
      current element and its children (eg. @uom in gco:Distance).
      A list of exception is defined in form-builder.xsl#render-for-field-for-attribute. -->
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="
            @*|
            gn:attribute[not(@name = parent::node()/@*/name())]">
        <xsl:with-param name="ref" select="gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="$theElement/gn:element/@ref"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="
        */@*|
        */gn:attribute[not(@name = parent::node()/@*/name())]">
        <xsl:with-param name="ref" select="*/gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="$theElement/gn:element/@ref"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="errors">
      <xsl:if test="$showValidationErrors">
        <xsl:call-template name="get-errors">
          <xsl:with-param name="theElement" select="$theElement"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="values">
      <xsl:if test="$isMultilingualElement">

        <values>
          <!-- Or the PT_FreeText element matching the main language -->
          <value ref="{$theElement/gn:element/@ref}" lang="{$metadataLanguage}"><xsl:value-of select="gco:CharacterString"/></value>

          <!-- the existing translation -->
          <xsl:for-each select="lan:PT_FreeText/lan:textGroup/lan:LocalisedCharacterString">
            <value ref="{gn:element/@ref}"
                   lang="{substring-after(@locale, '#')}"><xsl:value-of select="."/></value>
          </xsl:for-each>

          <!-- and create field for none translated language -->
          <xsl:for-each select="$metadataOtherLanguages/lang">
            <xsl:variable name="currentLanguageId" select="@id"/>
            <xsl:if test="count($theElement/parent::node()/
                            lan:PT_FreeText/lan:textGroup/
                              lan:LocalisedCharacterString[@locale = concat('#',$currentLanguageId)]) = 0">
              <value ref="lang_{@id}_{$theElement/parent::node()/gn:element/@ref}" lang="{@id}"></value>
            </xsl:if>
          </xsl:for-each>
        </values>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="$labelConfig/label"/>
      <xsl:with-param name="value" select="if ($isMultilingualElement) then $values else *"/>
      <xsl:with-param name="errors" select="$errors"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <!--<xsl:with-param name="widget"/>
        <xsl:with-param name="widgetParams"/>-->
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
      <xsl:with-param name="type"
                      select="gn-fn-metadata:getFieldType($editorConfig, name(),
        name($theElement))"/>
      <xsl:with-param name="name" select="if ($isEditing) then $theElement/gn:element/@ref else ''"/>
      <xsl:with-param name="editInfo" select="$theElement/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <!-- TODO: Handle conditional helper -->
      <xsl:with-param name="listOfValues" select="$helper"/>
      <xsl:with-param name="toggleLang" select="$isMultilingualElementExpanded"/>
      <xsl:with-param name="forceDisplayAttributes" select="$forceDisplayAttributes"/>
      <xsl:with-param name="isFirst" select="count(preceding-sibling::*[name() = $elementName]) = 0"/>
    </xsl:call-template>
  </xsl:template>



  <xsl:template mode="mode-iso19115-3"
                priority="200"
                match="*[gco:Date|gco:DateTime]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels)"/>

    <div data-gn-date-picker="{gco:Date|gco:DateTime}"
         data-label="{$labelConfig/label}"
         data-element-name="{name(gco:Date|gco:DateTime)}"
         data-element-ref="{concat('_X', gn:element/@ref)}">
    </div>
  </xsl:template>


  <xsl:template mode="mode-iso19115-3"
                match="gml:beginPosition|gml:endPosition|gml:timePosition"
                priority="400">
    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="value" select="normalize-space(text())"/>

    <xsl:variable name="attributes">
      <xsl:if test="$isEditing">
        <!-- Create form for all existing attribute (not in gn namespace)
        and all non existing attributes not already present. -->
        <xsl:apply-templates mode="render-for-field-for-attribute"
                             select="@*|
                              gn:attribute[not(@name = parent::node()/@*/name())]">
          <xsl:with-param name="ref" select="gn:element/@ref"/>
          <xsl:with-param name="insertRef" select="gn:element/@ref"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)/label"/>
      <xsl:with-param name="name" select="gn:element/@ref"/>
      <xsl:with-param name="value" select="text()"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type"
                      select="if (string-length($value) = 10 or $value = '') then 'date' else 'datetime'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
    </xsl:call-template>
  </xsl:template>



  <!--
  <xsl:template mode="mode-iso19115-3" match="*|@*" priority="0"/>
-->
  <!-- Codelists -->
  <xsl:template mode="mode-iso19115-3" priority="200"
                match="*[*/@codeList]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$codelists" required="no"/>
    <xsl:variable name="elementName" select="name()"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)/label"/>
      <xsl:with-param name="value" select="*/@codeListValue"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="gn-fn-iso19139:getCodeListType(name())"/>
      <xsl:with-param name="name"
                      select="concat(*/gn:element/@ref, '_codeListValue')"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="listOfValues"
                      select="gn-fn-metadata:getCodeListValues($schema, name(*[@codeListValue]), $codelists, .)"/>
      <xsl:with-param name="isFirst" select="count(preceding-sibling::*[name() = $elementName]) = 0"/>
    </xsl:call-template>
  </xsl:template>


  <!--
    Take care of enumerations.

    In the metadocument an enumeration provide the list of possible values:
  <gmd:topicCategory>
    <gmd:MD_TopicCategoryCode>
    <geonet:element ref="69" parent="68" uuid="gmd:MD_TopicCategoryCode_0073afa8-bc8f-4c52-94f3-28d3aa686772" min="1" max="1">
      <geonet:text value="farming"/>
      <geonet:text value="biota"/>
      <geonet:text value="boundaries"/
  -->
  <xsl:template mode="mode-iso19115-3"
                match="*[gn:element/gn:text]"
                priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$codelists" required="no"/>
    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', '')/label"/>
      <xsl:with-param name="value" select="text()"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="type" select="gn-fn-iso19139:getCodeListType(name())"/>
      <xsl:with-param name="name" select="gn:element/@ref"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="listOfValues"
                      select="gn-fn-metadata:getCodeListValues($schema, name(), $codelists, .)"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Some element to ignore which are matched by the
  next template -->
  <xsl:template mode="mode-iso19115-3" priority="400" match="gml:TimeInstantType"/>

  <!-- the gml element having no child eg. gml:name. -->
  <xsl:template mode="mode-iso19115-3" priority="300" match="gml:*[count(.//gn:element) = 1]">
    <xsl:variable name="name" select="name(.)"/>

    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, $name, $labels)"/>
    <xsl:variable name="helper" select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>

    <xsl:variable name="added" select="parent::node()/parent::node()/@gn:addedObj"/>
    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="$labelConfig/label"/>
      <xsl:with-param name="value" select="."/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      <xsl:with-param name="type" select="gn-fn-metadata:getFieldType($editorConfig, name(), '')"/>
      <xsl:with-param name="name" select="if ($isEditing) then gn:element/@ref else ''"/>
      <xsl:with-param name="editInfo"
                      select="gn:element"/>
      <xsl:with-param name="listOfValues" select="$helper"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
