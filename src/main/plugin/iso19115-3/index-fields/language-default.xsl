<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0" 
            xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
            xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
            xmlns:dqm="http://standards.iso.org/19157/-2/dqm/1.0/2014-12-25"
            xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0/2014-12-25"
            xmlns:mcc="http://standards.iso.org/19115/-3/mcc/1.0/2014-12-25"
            xmlns:mrc="http://standards.iso.org/19115/-3/mrc/1.0/2014-12-25"
            xmlns:mco="http://standards.iso.org/19115/-3/mco/1.0/2014-12-25"
            xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"
            xmlns:mrs="http://standards.iso.org/19115/-3/mrs/1.0/2014-12-25"
            xmlns:mrl="http://standards.iso.org/19115/-3/mrl/1.0/2014-12-25"
            xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0/2014-12-25"
            xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0/2014-12-25"
						xmlns:gcx="http://standards.iso.org/19115/-3/gcx/1.0/2014-12-25"
						xmlns:gex="http://standards.iso.org/19115/-3/gex/1.0/2014-12-25"
            xmlns:gfc="http://standards.iso.org/19110/gfc/1.1/2014-12-25"
						xmlns:gml="http://www.opengis.net/gml/3.2"
            xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
						xmlns:java="java:org.fao.geonet.util.XslUtil"
						xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--This file defines what parts of the metadata are indexed by Lucene
		Searches can be conducted on indexes defined here.
		The Field@name attribute defines the name of the search variable.
		If a variable has to be maintained in the user session, it needs to be
		added to the GeoNetwork constants in the Java source code.
		Please keep indexes consistent among metadata standards if they should
		work accross different metadata resources -->
	<!-- ========================================================================================= -->

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no" />
	<xsl:include href="../convert/functions.xsl"/>


  <!-- TODO: discussed where to place UUID. -->
  <xsl:variable name="fileIdentifier"
                select="//(mdb:MD_Metadata|*[contains(@gco:isoType,'mdb:MD_Metadata')])/
                  mdb:metadataIdentifier[1]/mcc:MD_Identifier/mcc:code/*"/>

  <xsl:variable name="isoDocLangId">
    <xsl:call-template name="langId19115-3"/>
  </xsl:variable>

    <xsl:template match="/">

        <Documents>
            <xsl:for-each select="/*[name(.)='mdb:MD_Metadata' or contains(@gco:isoType,'MD_Metadata')]/mdb:defaultLocale/lan:PT_Locale">
            	<xsl:call-template name="document">
            		<xsl:with-param name="isoLangId" select="java:threeCharLangCode(normalize-space(string(lan:language/lan:LanguageCode/@codeListValue)))"/>
            		<xsl:with-param name="langId" select="@id"></xsl:with-param>
            	</xsl:call-template>
            </xsl:for-each>
           <!-- 
           		Create a language document only if PT_Locale defined (ie. is a multilingual document)
           		and mdb:defaultLocale contains the main metadata language. -->
           	<xsl:if test="/*[name(.)='mdb:MD_Metadata' or contains(@gco:isoType,'MD_Metadata')]/mdb:defaultLocale/lan:PT_Locale
           		and count(/*[name(.)='mdb:MD_Metadata' or contains(@gco:isoType,'MD_Metadata')]/lan:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode[@codeListValue = $isoDocLangId]) = 0">
            	<xsl:call-template name="document">
            		<xsl:with-param name="isoLangId" select="$isoDocLangId"></xsl:with-param>
            		<xsl:with-param name="langId" select="java:twoCharLangCode(normalize-space(string($isoDocLangId)))"></xsl:with-param>
            	</xsl:call-template>
            </xsl:if>
        </Documents>
    </xsl:template>

		<xsl:template name="document">
  			<xsl:param name="isoLangId"/>
  			<xsl:param name="langId"/>
			
			<Document locale="{$isoLangId}">
				<Field name="_locale" string="{$isoLangId}" store="true" index="true"/>
				<Field name="_docLocale" string="{$isoDocLangId}" store="true" index="true"/>
		
				<xsl:variable name="poundLangId" select="concat('#',$langId)" />
				<xsl:variable name="_defaultTitle">
					<xsl:call-template name="defaultTitle">
						<xsl:with-param name="isoDocLangId" select="$isoLangId"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$isoLangId!=$isoDocLangId">
					<!-- not tokenized title for sorting -->
					<Field name="_defaultTitle" string="{string($_defaultTitle)}" store="true" index="true" />
				</xsl:if>
				<xsl:variable name="title"
					select="/*[name(.)='mdb:MD_Metadata' or contains(@gco:isoType,'MD_Metadata')]/mdb:identificationInfo//mri:citation//cit:title//lan:LocalisedCharacterString[@locale=$poundLangId]"/>
		
				<!-- not tokenized title for sorting -->
				<xsl:choose>
                 	<xsl:when test="normalize-space($title) = ''">
                 		<Field name="_title" string="{string($_defaultTitle)}" store="true" index="true" />
                 	</xsl:when>
                 	<xsl:otherwise>
                 		<Field name="_title" string="{string($title)}" store="true" index="true" />
                 	</xsl:otherwise>
				</xsl:choose>
		
				<xsl:apply-templates select="/*[name(.)='mdb:MD_Metadata' or contains(@gco:isoType,'MD_Metadata')]" mode="metadata">
					<xsl:with-param name="langId" select="$poundLangId"/>
				</xsl:apply-templates>

				<xsl:apply-templates mode="index" select="*[name(.)='mdb:MD_Metadata' or contains(@gco:isoType,'MD_Metadata')]">
					<xsl:with-param name="langId" select="$poundLangId"/>
				</xsl:apply-templates>
			</Document>
	</xsl:template>
	
	<xsl:template mode="index" match="*|@*">
		<xsl:param name="langId" />
		
		<xsl:apply-templates mode="index" select="*|@*">
			<xsl:with-param name="langId" select="$langId"/>
		</xsl:apply-templates>
	</xsl:template>


	<xsl:template match="*" mode="metadata">
		<xsl:param name="langId" />
		<!-- === Data or Service Identification === -->

		<!-- the double // here seems needed to index MD_DataIdentification when
			it is nested in a SV_ServiceIdentification class -->

		<xsl:for-each select="mdb:identificationInfo/*">

			<xsl:for-each select="mri:citation/cit:CI_Citation">

				<xsl:for-each select="cit:identifier/mcc:MD_Identifier/mcc:code//lan:LocalisedCharacterString[@locale=$langId]">
					<Field name="identifier" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<!-- not tokenized title for sorting -->
				<Field name="_defaultTitle" string="{string(cit:title/gco:CharacterString)}" store="true" index="true"/>
				<!-- not tokenized title for sorting -->
				<Field name="_title" string="{string(cit:title//lan:LocalisedCharacterString[@locale=$langId])}" store="true" index="true"/>

				<xsl:for-each select="cit:title//lan:LocalisedCharacterString[@locale=$langId]">
					<Field name="title" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<xsl:for-each select="cit:alternateTitle//lan:LocalisedCharacterString[@locale=$langId]">
					<Field name="altTitle" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

        <!-- FIXME: this is the revisionDate for the resource, not the metadata
                    but not sure what revisionDate is supposed to be? -->
				<xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/gco:Date">
					<Field name="revisionDate" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='creation']/cit:date/gco:Date">
					<Field name="createDate" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='publication']/cit:date/gco:Date">
					<Field name="publicationDate" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<!-- fields used to search for metadata in paper or digital format -->

				<xsl:for-each select="cit:presentationForm">
					<xsl:if test="contains(cit:CI_PresentationFormCode/@codeListValue, 'Digital')">
						<Field name="digital" string="true" store="true" index="true"/>
					</xsl:if>

					<xsl:if test="contains(cit:CI_PresentationFormCode/@codeListValue, 'Hardcopy')">
						<Field name="paper" string="true" store="true" index="true"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="mri:abstract//lan:LocalisedCharacterString[@locale=$langId]">
				<Field name="abstract" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="*/gex:EX_Extent">
        <xsl:apply-templates select="gex:geographicElement/gex:EX_GeographicBoundingBox" mode="latLon19115-3"/>

				<xsl:for-each select="gex:geographicElement/gex:EX_GeographicDescription/gex:geographicIdentifier/mcc:MD_Identifier/mcc:code//lan:LocalisedCharacterString[@locale=$langId]">
					<Field name="geoDescCode" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<xsl:for-each select="gex:description//lan:LocalisedCharacterString[@locale=$langId]">
					<Field name="extentDesc" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<xsl:for-each select="gex:temporalElement/gex:EX_TemporalExtent/gex:extent|
					gex:temporalElement/gex:EX_SpatialTemporalExtent/gex:extent">
					<xsl:for-each select="gml:TimePeriod/gml:beginPosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>

					<xsl:for-each select="gml:TimePeriod/gml:endPosition">
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>

					<xsl:for-each select="gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>

					<xsl:for-each select="gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>

					<xsl:for-each select="gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>

				</xsl:for-each>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="*/mri:MD_Keywords">
				<xsl:for-each select="mri:keyword//lan:LocalisedCharacterString[@locale=$langId]">
					<Field name="keyword" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<xsl:for-each select="mri:type/mri:MD_KeywordTypeCode/@codeListValue">
					<Field name="keywordType" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="mri:pointOfContact//cit:CI_Organisation/cit:name//lan:LocalisedCharacterString[@locale=$langId]">
                <Field name="orgName" string="{string(.)}" store="true" index="true"/>
                <Field name="_orgName" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:choose>
				<xsl:when test="mri:resourceConstraints/mco:MD_SecurityConstraints">
					<Field name="secConstr" string="true" store="true" index="true"/>
				</xsl:when>
				<xsl:otherwise>
					<Field name="secConstr" string="false" store="true" index="true"/>
				</xsl:otherwise>
			</xsl:choose>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="mri:topicCategory/mri:MD_TopicCategoryCode">
				<Field name="topicCat" string="{string(.)}" store="true" index="true"/>
				<Field name="subject" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
				<Field name="datasetLang" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="mri:spatialRepresentationType/mri:MD_SpatialRepresentationTypeCode/@codeListValue">
				<Field name="spatialRepresentationType" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

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

            <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

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
              <xsl:when test="string($fileDescr)='thumbnail'">
                  <!-- FIXME : relative path -->
                  <Field  name="image" string="{concat($fileDescr, '|', '../../srv/eng/resources.get?uuid=', $fileIdentifier, '&amp;fname=', $fileName, '&amp;access=public')}" store="true" index="false"/>
              </xsl:when>
              <xsl:when test="string($fileDescr)='large_thumbnail'">
                <!-- FIXME : relative path -->
                <Field  name="image" string="{concat('overview', '|', '../../srv/eng/resources.get?uuid=', $fileIdentifier, '&amp;fname=', $fileName, '&amp;access=public')}" store="true" index="false"/>
              </xsl:when>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>

            <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<!--  Fields use to search on Service -->

			<xsl:for-each select="srv:serviceType/gco:LocalName">
				<Field  name="serviceType" string="{string(.)}" store="true" index="true"/>
				<Field  name="type" string="service-{string(.)}" store="true" index="true"/>
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

			<xsl:for-each select="//srv:SV_CouplingType/srv:code/@codeListValue">
				<Field  name="couplingType" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>

		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Distribution === -->

		<xsl:for-each select="mdb:distributionInfo/mrd:MD_Distribution">
			<xsl:for-each select="mrd:distributionFormat/mrd:MD_Format/mrd:name//lan:LocalisedCharacterString[@locale=$langId]">
				<Field name="format" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>

			<!-- index online protocol -->

			<xsl:for-each select="mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:protocol//lan:LocalisedCharacterString[@locale=$langId]">
				<Field name="protocol" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
		</xsl:for-each>


		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Service stuff ===  -->
		<!-- Service type           -->
		<xsl:for-each select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName|
			mdb:identificationInfo/*[contains(@gco:isoType, 'SV_ServiceIdentification')]/srv:serviceType/gco:LocalName">
			<Field name="serviceType" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>

		<!-- Service version        -->
		<xsl:for-each select="mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceTypeVersion/gco:CharacterString|
			mdb:identificationInfo/*[contains(@gco:isoType, 'SV_ServiceIdentification')]/srv:serviceTypeVersion/gco:CharacterString">
			<Field name="serviceTypeVersion" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>


		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === General stuff === -->

		<xsl:choose>
			<xsl:when test="mdb:metadataScope">
				<xsl:for-each select="mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue">
					<Field name="type" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<Field name="type" string="dataset" store="true" index="true"/>
			</xsl:otherwise>
		</xsl:choose>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="mdb:metadataIdentifier/mcc:MD_Identifier">
			<Field name="fileId" string="{string(mcc:code/gco:CharacterString)}" store="true" index="true"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="mdb:parentMetadata/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString">
			<Field name="parentUuid" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Reference system info === -->

		<xsl:for-each select="mdb:referenceSystemInfo/mrs:MD_ReferenceSystem">
			<xsl:for-each select="mrs:referenceSystemIdentifier/mcc:MD_Identifier">
				<xsl:variable name="crs" select="concat(string(mcc:codeSpace/gco:CharacterString),'::',string(mcc:code/gco:CharacterString))"/>

				<xsl:if test="$crs != '::'">
					<Field name="crs" string="{$crs}" store="true" index="true"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>

    <xsl:for-each select="mdb:contentInfo/mrc:MD_FeatureCatalogue/mrc:featureCatalogue">
      <xsl:variable name="attributes"
                    select=".//gfc:carrierOfCharacteristics"/>
      <xsl:if test="count($attributes) > 0">
        <xsl:variable name="jsonAttributeTable">
          [<xsl:for-each select="$attributes">
          {"name": "<xsl:value-of select="*/gfc:memberName/*/text()"/>",
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
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Free text search === -->
		<Field name="any" store="false" index="true">
			<xsl:attribute name="string">
				<xsl:value-of select="normalize-space(//node()[@locale=$langId])"/>
				<xsl:text> </xsl:text>
				<xsl:for-each select="//@codeListValue">
					<xsl:value-of select="concat(., ' ')"/>
				</xsl:for-each>
			</xsl:attribute>
		</Field>

		<xsl:apply-templates select="." mode="codeList"/>

	</xsl:template>

	<!-- ========================================================================================= -->
	<!-- codelist element, indexed, not stored nor tokenized -->

	<xsl:template match="*[./*/@codeListValue]" mode="codeList">
		<xsl:param name="name" select="name(.)"/>

		<Field name="{$name}" string="{*/@codeListValue}" store="false" index="true"/>
	</xsl:template>

	<!-- ========================================================================================= -->

	<xsl:template match="*" mode="codeList">
		<xsl:apply-templates select="*" mode="codeList"/>
	</xsl:template>

</xsl:stylesheet>
