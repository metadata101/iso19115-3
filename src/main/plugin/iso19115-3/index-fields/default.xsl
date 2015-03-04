<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" 
            xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
            xmlns:dqm="http://standards.iso.org/19157/-2/dqm/1.0/2014-12-25"
            xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
            xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0/2014-12-25"
            xmlns:mcc="http://standards.iso.org/19115/-3/mcc/1.0/2014-12-25"
            xmlns:mrc="http://standards.iso.org/19115/-3/mrc/1.0/2014-12-25"
            xmlns:mco="http://standards.iso.org/19115/-3/mco/1.0/2014-12-25"
            xmlns:mdb="http://standards.iso.org/19115/-3/mdb/1.0/2014-12-25"
            xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"
            xmlns:mrs="http://standards.iso.org/19115/-3/mrs/1.0/2014-12-25"
            xmlns:mrl="http://standards.iso.org/19115/-3/mrl/1.0/2014-12-25"
            xmlns:mrd="http://standards.iso.org/19115/-3/mrd/1.0/2014-12-25"
						xmlns:gml="http://www.opengis.net/gml/3.2"
            xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0/2014-12-25"
						xmlns:gcx="http://standards.iso.org/19115/-3/gcx/1.0/2014-12-25"
						xmlns:gex="http://standards.iso.org/19115/-3/gex/1.0/2014-12-25"
            xmlns:gfc="http://standards.iso.org/19110/gfc/1.1/2014-12-25"
						xmlns:geonet="http://www.fao.org/geonetwork"
						xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:skos="http://www.w3.org/2004/02/skos/core#">

  <xsl:include href="../convert/functions.xsl"/>
	<xsl:include href="../../../xsl/utils-fn.xsl"/>
  <xsl:include href="index-subtemplate-fields.xsl"/>
	
	<!-- This file defines what parts of the metadata are indexed by Lucene
	     Searches can be conducted on indexes defined here. 
	     The Field@name attribute defines the name of the search variable.
		 If a variable has to be maintained in the user session, it needs to be 
		 added to the GeoNetwork constants in the Java source code.
		 Please keep indexes consistent among metadata standards if they should
		 work accross different metadata resources -->

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no" />



  <xsl:param name="thesauriDir"/>
  <xsl:param name="inspire">false</xsl:param>
  
  <xsl:variable name="inspire-thesaurus" select="if ($inspire!='false') then document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf')) else ''"/>
  <xsl:variable name="inspire-theme" select="if ($inspire!='false') then $inspire-thesaurus//skos:Concept else ''"/>
  
  <!-- If identification creation, publication and revision date
    should be indexed as a temporal extent information (eg. in INSPIRE 
    metadata implementing rules, those elements are defined as part
    of the description of the temporal extent). -->
	<xsl:variable name="useDateAsTemporalExtent" select="false()"/>


  <!-- TODO: discussed where to place UUID. -->
  <xsl:variable name="fileIdentifier"
                select="//(mdb:MD_Metadata|*[contains(@gco:isoType,'mdb:MD_Metadata')])/
                  mdb:metadataIdentifier[1]/mcc:MD_Identifier/mcc:code/*"/>

	<xsl:template match="/">
	    <xsl:variable name="isoLangId">
	  	    <xsl:call-template name="langId19115-3"/>
        </xsl:variable>

		<Document locale="{$isoLangId}">
			<Field name="_locale" string="{$isoLangId}" store="true" index="true"/>

			<Field name="_docLocale" string="{$isoLangId}" store="true" index="true"/>

			
			<xsl:variable name="_defaultTitle">
				<xsl:call-template name="defaultTitle">
					<xsl:with-param name="isoDocLangId" select="$isoLangId"/>
				</xsl:call-template>
			</xsl:variable>
			<Field name="_defaultTitle" string="{string($_defaultTitle)}" store="true" index="true"/>
			<!-- not tokenized title for sorting, needed for multilingual sorting -->
            <Field name="_title" string="{string($_defaultTitle)}" store="true" index="true" />

			<xsl:apply-templates select="*[name(.)='mdb:MD_Metadata' or @gco:isoType='mdb:MD_Metadata']" mode="metadata"/>

			<xsl:apply-templates mode="index" select="*"/>
			
		</Document>
	</xsl:template>
	
	
	<!-- Add index mode template in order to easily add new field in the index (eg. in profiles).
        
        For example, index some keywords from a specific thesaurus in a new field:
        <xsl:template mode="index"
            match="mri:MD_Keywords[mri:thesaurusName/cit:CI_Citation/
                        cit:title/gco:CharacterString='My thesaurus']/
                        mri:keyword[normalize-space(gco:CharacterString) != '']">
            <Field name="myThesaurusKeyword" string="{string(.)}" store="true" index="true"/>
        </xsl:template>
        
        Note: if more than one template match the same element in a mode, only one will be 
        used (usually the last one).
        
        If matching a upper level element, apply mode to its child to further index deeper level if required:
        <xsl:template mode="index" match="gex:EX_Extent">
            ... do something
            ... and continue indexing
            <xsl:apply-templates mode="index" select="*"/>
        </xsl:template>
            -->
	<xsl:template mode="index" match="*|@*">
		<xsl:apply-templates mode="index" select="*|@*"/>
	</xsl:template>
	
	
	<xsl:template mode="index"
		match="mri:extent/gex:EX_Extent/gex:description/gco:CharacterString[normalize-space(.) != '']">
		<Field name="extentDesc" string="{string(.)}" store="false" index="true"/>
	</xsl:template>
	


	<xsl:template match="*" mode="metadata">

		<!-- === Data or Service Identification === -->		

		<!-- the double // here seems needed to index MD_DataIdentification when
           it is nested in a SV_ServiceIdentification class -->

		<xsl:for-each select="mdb:identificationInfo//mri:MD_DataIdentification|
			mdb:identificationInfo//*[contains(@gco:isoType, 'MD_DataIdentification')]|
			mdb:identificationInfo/srv:SV_ServiceIdentification">

			<xsl:for-each select="mri:citation/cit:CI_Citation">
				<xsl:for-each select="mcc:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString">
					<Field name="identifier" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<xsl:for-each select="cit:title/gco:CharacterString">
					<Field name="title" string="{string(.)}" store="true" index="true"/>
                    <!-- not tokenized title for sorting -->
                    <Field name="_title" string="{string(.)}" store="false" index="true"/>
				</xsl:for-each>
	
				<xsl:for-each select="cit:alternateTitle/gco:CharacterString">
					<Field name="altTitle" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>

				<xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date">
					<Field name="revisionDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
					<Field name="createDateMonth" string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 8)}" store="true" index="true"/>
					<Field name="createDateYear" string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 5)}" store="true" index="true"/>
					<xsl:if test="$useDateAsTemporalExtent">
						<Field name="tempExtentBegin" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
					</xsl:if>
				</xsl:for-each>

				<xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='creation']/cit:date">
					<Field name="createDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
					<Field name="createDateMonth" string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 8)}" store="true" index="true"/>
					<Field name="createDateYear" string="{substring(gco:Date[.!='']|gco:DateTime[.!=''], 0, 5)}" store="true" index="true"/>
					<xsl:if test="$useDateAsTemporalExtent">
						<Field name="tempExtentBegin" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
					</xsl:if>
				</xsl:for-each>

				<xsl:for-each select="cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='publication']/cit:date">
					<Field name="publicationDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
					<xsl:if test="$useDateAsTemporalExtent">
						<Field name="tempExtentBegin" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
					</xsl:if>
				</xsl:for-each>

				<!-- fields used to search for metadata in paper or digital format -->

				<xsl:for-each select="cit:presentationForm">
					<Field name="presentationForm" string="{cit:CI_PresentationFormCode/@codeListValue}" store="true" index="true"/>
					
					<xsl:if test="contains(cit:CI_PresentationFormCode/@codeListValue, 'Digital')">
						<Field name="digital" string="true" store="false" index="true"/>
					</xsl:if>
				
					<xsl:if test="contains(cit:CI_PresentationFormCode/@codeListValue, 'Hardcopy')">
						<Field name="paper" string="true" store="false" index="true"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>

            <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

            <xsl:for-each select="mri:pointOfContact[1]/*/cit:role/*/@codeListValue">
            	<Field name="responsiblePartyRole" string="{string(.)}" store="true" index="true"/>
            </xsl:for-each>
            
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
	
			<xsl:for-each select="mri:abstract/gco:CharacterString">
				<Field name="abstract" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			
			<xsl:for-each select="mri:credit/gco:CharacterString">
				<Field name="credit" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			
			
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

			<xsl:for-each select="*/gex:EX_Extent">
				<xsl:apply-templates select="gex:geographicElement/gex:EX_GeographicBoundingBox" mode="latLon19115-3"/>

				<xsl:for-each select="gex:geographicElement/gex:EX_GeographicDescription/gex:geographicIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString">
					<Field name="geoDescCode" string="{string(.)}" store="true" index="true"/>
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

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

			<xsl:for-each select="//mri:MD_Keywords">
			  
				<xsl:for-each select="mri:keyword/gco:CharacterString|mri:keyword/gcx:Anchor|mri:keyword/lan:PT_FreeText/lan:textGroup/lan:LocalisedCharacterString">
                    <xsl:variable name="keywordLower" select="lower-case(.)"/>
                    <Field name="keyword" string="{string(.)}" store="true" index="true"/>
					
                    <xsl:if test="$inspire='true'">
                        <xsl:if test="string-length(.) &gt; 0">
                         
                          <xsl:variable name="inspireannex">
                            <xsl:call-template name="determineInspireAnnex">
                              <xsl:with-param name="keyword" select="string(.)"/>
                              <xsl:with-param name="inspireThemes" select="$inspire-theme"/>
                            </xsl:call-template>
                          </xsl:variable>
                          
                          <!-- Add the inspire field if it's one of the 34 themes -->
                          <xsl:if test="normalize-space($inspireannex)!=''">
                            <!-- Maybe we should add the english version to the index to not take the language into account 
                            or create one field in the metadata language and one in english ? -->
                            <Field name="inspiretheme" string="{string(.)}" store="false" index="true"/>
                          	<Field name="inspireannex" string="{$inspireannex}" store="false" index="true"/>
                            <!-- FIXME : inspirecat field will be set multiple time if one record has many themes -->
                          	<Field name="inspirecat" string="true" store="false" index="true"/>
                          </xsl:if>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>

				<xsl:for-each select="mri:type/mri:MD_KeywordTypeCode/@codeListValue">
					<Field name="keywordType" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
			</xsl:for-each>

      <xsl:for-each select="mri:pointOfContact/cit:CI_Responsibility">
        <xsl:variable name="orgName" select="string(cit:party/cit:CI_Organisation/cit:name/*)"/>

        <Field name="orgName" string="{$orgName}" store="true" index="true"/>
				
				<xsl:variable name="role" select="cit:role/*/@codeListValue"/>
        <xsl:variable name="email" select="cit:contactInfo/cit:CI_Contact/
                                          cit:address/cit:CI_Address/
                                          cit:electronicMailAddress/gco:CharacterString"/>
				<xsl:variable name="logo" select="cit/party/cit:CI_Organisation/
				                                    cit:logo/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString"/>
			
				<Field name="responsibleParty" string="{concat($role, '|resource|', $orgName, '|', $logo, '|', $email)}" store="true" index="false"/>
				
			</xsl:for-each>

	
			<xsl:choose>
				<xsl:when test="mri:resourceConstraints/mco:MD_SecurityConstraints">
					<Field name="secConstr" string="true" store="true" index="true"/>
				</xsl:when>
				<xsl:otherwise>
					<Field name="secConstr" string="false" store="true" index="true"/>
				</xsl:otherwise>
			</xsl:choose>

	
			<xsl:for-each select="mri:topicCategory/mri:MD_TopicCategoryCode">
				<Field name="topicCat" string="{string(.)}" store="true" index="true"/>
				<Field name="keyword" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>


      <!-- mri:defaultLocale/lan:PT_Locale takes over from gmd:language -->
			<xsl:for-each select="mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
				<Field name="datasetLang" string="{string(.)}" store="true" index="true"/>
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
		  <xsl:for-each select="mri:spatialRepresentationType">
		    <Field name="spatialRepresentationType" string="{mri:MD_SpatialRepresentationTypeCode/@codeListValue}" store="true" index="true"/>
		  </xsl:for-each>
			
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		
      <!-- FIXME: Additional constraints have been created in the mco schema -->
			<xsl:for-each select="mri:resourceConstraints">
				<xsl:for-each select="//mco:accessConstraints/mco:MD_RestrictionCode/@codeListValue">
					<Field name="accessConstr" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="//mco:otherConstraints/gco:CharacterString">
					<Field name="otherConstr" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="//mco:classification/mco:MD_ClassificationCode/@codeListValue">
					<Field name="classif" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="//mco:useLimitation/gco:CharacterString">
					<Field name="conditionApplyingToAccessAndUse" string="{string(.)}" store="true" index="true"/>
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
			
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<!--  Fields use to search on Service -->
			
			<xsl:for-each select="srv:serviceType/gco:LocalName">
				<Field  name="serviceType" string="{string(.)}" store="true" index="true"/>
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
			
			<xsl:for-each select="//srv:SV_CouplingType/@codeListValue">
				<Field  name="couplingType" string="{string(.)}" store="true" index="true"/>
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
			
			
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<!-- === Distribution === -->		

		<xsl:for-each select="mdb:distributionInfo/mrd:MD_Distribution">
			<xsl:for-each select="mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString">
				<Field name="format" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>

			<!-- index online protocol -->
			
			<xsl:for-each select="mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource[cit:linkage/*!='']">
				<xsl:variable name="download_check"><xsl:text>&amp;fname=&amp;access</xsl:text></xsl:variable>
				<xsl:variable name="linkage" select="cit:linkage/*" /> 
				<xsl:variable name="title" select="normalize-space(cit:name/gco:CharacterString|cit:name/gcx:MimeFileType)"/>
				<xsl:variable name="desc" select="normalize-space(cit:description/gco:CharacterString)"/>
				<xsl:variable name="protocol" select="normalize-space(cit:protocol/gco:CharacterString)"/>
				<xsl:variable name="mimetype" select="geonet:protocolMimeType($linkage, $protocol, cit:name/gcx:MimeFileType/@type)"/>

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

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Content info === -->
		<xsl:for-each select="mdb:contentInfo/mrc:MD_FeatureCatalogueDescription/mrc:featureCatalogueCitation[@uuidref]">
			<Field  name="hasfeaturecat" string="{string(@uuidref)}" store="false" index="true"/>
		</xsl:for-each>

    <xsl:for-each select="mdb:contentInfo/mrc:MD_FeatureCatalogue/mrc:featureCatalogue">
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


		<!-- === Lineage  === -->
		<xsl:for-each select="mdb:resourceLineage/*/mrl:source[@uuidref]">
			<Field  name="hassource" string="{string(@uuidref)}" store="false" index="true"/>
		</xsl:for-each>
		
		<xsl:for-each select="mdb:dataQualityInfo/*/dqm:report/*/dqm:result">
			<xsl:if test="$inspire='true'">
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
			
			<xsl:for-each select="//dqm:specification/*/cit:title/gco:CharacterString">
				<Field name="specificationTitle" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			
			<xsl:for-each select="//dqm:specification/*/cit:date/*/cit:date">
				<Field name="specificationDate" string="{string(gco:Date[.!='']|gco:DateTime[.!=''])}" store="true" index="true"/>
			</xsl:for-each>
			
			<xsl:for-each select="//dqm:specification/*/cit:date/*/cit:dateType/cit:CI_DateTypeCode/@codeListValue">
				<Field name="specificationDateType" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
		</xsl:for-each>
		<xsl:for-each select="mdb:dataQualityInfo/*/dqm:lineage/*/dqm:statement/gco:CharacterString">
			<Field name="lineage" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<!-- === General stuff === -->		
		<!-- Metadata type  -->
		<xsl:choose>
			<xsl:when test="mdb:metadataScope">
				<xsl:for-each select="mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue">
					<Field name="type" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- If not defined, record is a dataset FIXME: check this -->
				<Field name="type" string="dataset" store="true" index="true"/>
			</xsl:otherwise>
		</xsl:choose>
		
		
		<!-- Metadata on maps -->
		<xsl:variable name="isDataset" select="count(mdb:hierarchyLevel[mcc:MD_ScopeCode/@codeListValue='dataset']) > 0"/>
		<xsl:variable name="isMapDigital" select="count(mri:identificationInfo/*/cit:citation/cit:CI_Citation/
			cit:presentationForm[cit:CI_PresentationFormCode/@codeListValue = 'mapDigital']) > 0"/>
		<xsl:variable name="isStatic" select="count(mdb:distributionInfo/mrd:MD_Distribution/
			mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:name/gco:CharacterString[contains(., 'PDF') or contains(., 'PNG') or contains(., 'JPEG')]) > 0"/>
		<xsl:variable name="isInteractive" select="count(mdb:distributionInfo/mrd:MD_Distribution/
			mrd:distributionFormat/mrd:MD_Format/mrd:formatSpecificationCitation/cit:CI_Citation/cit:name/gco:CharacterString[contains(., 'OGC:WMC') or contains(., 'OGC:OWS')]) > 0"/>
		<xsl:variable name="isPublishedWithWMCProtocol" select="count(mdb:distributionInfo/mrd:MD_Distribution/
			mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:protocol[starts-with(gco:CharacterString, 'OGC:WMC')]) > 0"/>
		
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
			<!-- Check if metadata is a service metadata record -->
			<xsl:when test="mdb:identificationInfo/srv:SV_ServiceIdentification">
				<Field name="type" string="service" store="false" index="true"/>
			</xsl:when>
	     <!-- <xsl:otherwise>
	      ... gmd:*_DataIdentification / hierachicalLevel is used and return dataset, serie, ... 
	      </xsl:otherwise>-->
	    </xsl:choose>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<xsl:for-each select="mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode">
			<Field name="levelName" string="{string(@codeListValue)}" store="false" index="true"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

		<xsl:for-each select="mdb:language/gco:CharacterString
			|mdb:language/lan:LanguageCode/@codeListValue
			|mdb:locale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue">
			<Field name="language" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
    <!-- fileIdentifier is deprecated in favour of metadataIdentifier -->
		<xsl:for-each select="mdb:metadataIdentifier/mcc:MD_Identifier">
			<Field name="fileId" string="{string(mcc:code/gco:CharacterString)}" store="false" index="true"/>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
    <!-- parentIdentifier is deprecated in favour of parentMetadata -->
	  <xsl:for-each select="
	    mdb:parentMetadata/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString|
	    mdb:parentMetadata/@uuidref">
			<Field name="parentUuid" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		
    <!-- mdb:dateInfo is change date -->
		<xsl:for-each select="mdb:dateInfo/cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue='revision']/cit:date/*">
			<Field name="changeDate" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <xsl:for-each select="mdb:contact/cit:CI_Responsibility">
      <xsl:variable name="orgName" select="string(cit:party/cit:CI_Organisation/cit:name/*)"/>
      <Field name="orgName" string="{$orgName}" store="true" index="true"/>

      <xsl:variable name="role" select="cit:role/*/@codeListValue"/>
      <xsl:variable name="logo" select="cit/party/cit:CI_Organisation/
				                                    cit:logo/mcc:MD_BrowseGraphic/mcc:fileName/gco:CharacterString"/>

      <Field name="responsibleParty" string="{concat($role, '|metadata|', $orgName, '|', $logo)}" store="true" index="false"/>
    </xsl:for-each>




		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<!-- === Reference system info === -->		

		<xsl:for-each select="mdb:referenceSystemInfo/mrs:MD_ReferenceSystem">
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

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		<!-- === Free text search === -->		

		<Field name="any" store="false" index="true">
			<xsl:attribute name="string">
				<xsl:value-of select="normalize-space(string(.))"/>
				<xsl:text> </xsl:text>
				<xsl:for-each select="//@codeListValue">
					<xsl:value-of select="concat(., ' ')"/>
				</xsl:for-each>
			</xsl:attribute>
		</Field>
				
		<!--<xsl:apply-templates select="." mode="codeList"/>-->
		
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
	
	
	<!-- ========================================================================================= -->

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
