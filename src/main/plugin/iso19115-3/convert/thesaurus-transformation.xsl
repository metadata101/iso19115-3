<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mds="http://standards.iso.org/19115/-3/mds/1.0/2014-12-25"
  xmlns:gcx="http://standards.iso.org/19115/-3/gcx/1.0/2014-12-25"
  xmlns:mri="http://standards.iso.org/19115/-3/mri/1.0/2014-12-25"
  xmlns:mcc="http://standards.iso.org/19115/-3/mcc/1.0/2014-12-25"
  xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25"
  xmlns:lan="http://standards.iso.org/19115/-3/lan/1.0/2014-12-25"
  xmlns:srv="http://standards.iso.org/19115/-3/srv/2.0/2014-12-25"
  xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
  xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:xlink="http://www.w3.org/1999/xlink">
	
	
	<!-- A set of templates use to convert thesaurus concept to 
       iso19115-3 fragments. -->
	
  <!-- uses functions from schema iso19139/process/process-utility.xsl -->
	<xsl:include href="../process/process-utility.xsl"/>
	
	<!-- Convert a concept to an iso19115-3 fragment with an Anchor 
        for each keywords pointing to the concept URI-->
	<xsl:template name="to-iso19115-3-keyword-with-anchor">
		<xsl:call-template name="to-iso19115-3-keyword">
			<xsl:with-param name="withAnchor" select="true()"/>
		</xsl:call-template>
	</xsl:template>
	
	
	<!-- Convert a concept to an iso19115-3 mri:MD_Keywords with an 
       XLink which will be resolved by XLink resolver. -->
	<xsl:template name="to-iso19115-3-keyword-as-xlink">
		<xsl:call-template name="to-iso19115-3-keyword">
			<xsl:with-param name="withXlink" select="true()"/>
		</xsl:call-template>
	</xsl:template>
	
	
	<!-- Convert a concept to an iso19115-3 keywords.
    If no keyword is provided, only thesaurus section is adaded.
    -->
	<xsl:template name="to-iso19115-3-keyword">
		<xsl:param name="withAnchor" select="false()"/>
		<xsl:param name="withXlink" select="false()"/>
		<!-- Add thesaurus identifier using an Anchor which points to the download link. 
        It's recommended to use it in order to have the thesaurus widget inline editor
        which use the thesaurus identifier for initialization. -->
		<xsl:param name="withThesaurusAnchor" select="true()"/>
    <mri:descriptiveKeywords>
      <mri:MD_Keywords>
        <xsl:choose>
          <xsl:when test="$withXlink">
            <xsl:variable name="multiple" select="if (contains(/root/request/id, ',')) then 'true' else 'false'"/>
            <xsl:attribute name="xlink:href"
              select="concat($serviceUrl, '/xml.keyword.get?thesaurus=', thesaurus/key,
              '&amp;amp;id=', replace(/root/request/id, '#', '%23'), '&amp;amp;multiple=', $multiple)"/>
            <xsl:attribute name="xlink:show">replace</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <!-- Get thesaurus ID from keyword or from request parameter if no keyword found. -->
            <xsl:variable name="currentThesaurus" select="if (thesaurus/key) then thesaurus/key else /root/request/thesaurus"/>

            <!-- Loop on all keyword from the same thesaurus -->
            <xsl:for-each select="//keyword[thesaurus/key = $currentThesaurus]">
              <mri:keyword>
                <xsl:choose>
                  <xsl:when test="$withAnchor">
                    <!-- TODO multilingual Anchor ? -->
                    <gcx:Anchor
                      xlink:href="{$serviceUrl}/xml.keyword.get?thesaurus={thesaurus/key}&amp;id={uri}">
                      <xsl:value-of select="value"/>
                    </gcx:Anchor>
                  </xsl:when>
                  <xsl:otherwise>
                    <gco:CharacterString>
                      <xsl:value-of select="value"/>
                    </gco:CharacterString>
                    <!-- TODO multilingual keywords
                              add a lang parameter to only get some of them -->
                    <!--                            <xsl:for-each select="values"> </xsl:for-each>
  -->                     </xsl:otherwise>
                </xsl:choose>

              </mri:keyword>
            </xsl:for-each>

            <!-- Add thesaurus theme -->
            <mri:type>
              <mri:MD_KeywordTypeCode
                codeList="http://standards.iso.org/19115/-3/resources/codeList.xml#MD_KeywordTypeCode"
                codeListValue="{thesaurus/type}"/>
            </mri:type>
            <xsl:if test="not(/root/request/keywordOnly)">
              <mri:thesaurusName>
                <cit:CI_Citation>
                  <cit:title>
                    <gco:CharacterString>
                      <xsl:value-of select="/root/gui/thesaurus/thesauri/thesaurus[key = $currentThesaurus]/title"/>
                    </gco:CharacterString>
                  </cit:title>

                  <xsl:variable name="thesaurusDate" select="normalize-space(/root/gui/thesaurus/thesauri/thesaurus[key = $currentThesaurus]/date)"/>

                  <xsl:if test="$thesaurusDate != ''">
                    <cit:date>
                      <cit:CI_Date>
                        <cit:date>
                          <xsl:choose>
                            <xsl:when test="contains($thesaurusDate, 'T')">
                              <gco:DateTime>
                                <xsl:value-of select="$thesaurusDate"/>
                              </gco:DateTime>
                            </xsl:when>
                            <xsl:otherwise>
                              <gco:Date>
                                <xsl:value-of select="$thesaurusDate"/>
                              </gco:Date>
                            </xsl:otherwise>
                          </xsl:choose>
                        </cit:date>
                        <cit:dateType>
                          <cit:CI_DateTypeCode
                            codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode"
                            codeListValue="publication"/>
                        </cit:dateType>
                      </cit:CI_Date>
                    </cit:date>
                  </xsl:if>

                  <xsl:if test="$withThesaurusAnchor">
                    <cit:identifier>
                      <mcc:MD_Identifier>
                        <mcc:code>
                          <gcx:Anchor xlink:href="{/root/gui/thesaurus/thesauri/thesaurus[key = $currentThesaurus]/url}"
                            >geonetwork.thesaurus.<xsl:value-of
                              select="$currentThesaurus"/></gcx:Anchor>
                        </mcc:code>
                      </mcc:MD_Identifier>
                    </cit:identifier>
                  </xsl:if>
                </cit:CI_Citation>
              </mri:thesaurusName>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </mri:MD_Keywords>
    </mri:descriptiveKeywords>
	</xsl:template>
	
	
	
	<!-- Convert a concept to an iso19115-3 extent -->
	<xsl:template name="to-iso19115-3-extent">
		<xsl:param name="isService" select="false()"/>
		
		<xsl:variable name="currentThesaurus" select="thesaurus/key"/>
		<!-- Loop on all keyword from the same thesaurus -->
		<xsl:for-each select="//keyword[thesaurus/key = $currentThesaurus]">
			<xsl:choose>
				<xsl:when test="$isService">
					<srv:extent>
						<xsl:copy-of select="geonet:make-iso-extent(geo/west, geo/south, geo/east, geo/north, value)"/>
					</srv:extent>
				</xsl:when>
				<xsl:otherwise>
					<mri:extent>
						<xsl:copy-of select="geonet:make-iso-extent(geo/west, geo/south, geo/east, geo/north, value)"/>
					</mri:extent>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
