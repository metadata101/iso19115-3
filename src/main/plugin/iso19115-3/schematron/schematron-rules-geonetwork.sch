<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <sch:title xmlns="http://www.w3.org/2001/XMLSchema">Schematron validation / GeoNetwork recommendations</sch:title>
    <sch:ns prefix="mds" uri="http://standards.iso.org/19115/-3/mds/1.0/2013-03-28"/>
    <sch:ns prefix="lan" uri="http://standards.iso.org/19115/-3/lan/1.0/2013-03-28"/>
    <sch:ns prefix="gco" uri="http://standards.iso.org/19139/gco/1.0/2014-12-25"/>
    <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
    <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>    

    <!-- =============================================================
    GeoNetwork schematron rules:
    ============================================================= -->
    <sch:pattern>
        <sch:title>$loc/strings/M500</sch:title>
        <sch:rule
            context="//mds:MD_Metadata|//*[@gco:isoType='mds:MD_Metadata']">
        	<sch:let name="language" value="mds:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue"/>
            <sch:let name="localeAndNoLanguage" value="not(mds:defaultLocale and mds:defaultLocale/lan:PT_Locale/lan:language/@gco:nilReason='missing')
                and not(mds:defaultLocale and not(mds:defaultLocale/lan:PT_Locale/lan:language))"/>
            <sch:let name="duplicateLanguage" value="not(mds:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode/@codeListValue=$language)"/>
   
   
            <!--  Check that main language is not defined and gmd:locale element exist. -->
            <sch:assert test="$localeAndNoLanguage"
                >$loc/strings/alert.M500</sch:assert>
            <sch:report test="$localeAndNoLanguage"
                ><sch:value-of select="$loc/strings/report.M500"/> "<sch:value-of select="normalize-space($language)"/>"</sch:report>
            
    
            <!-- 
  * Check that main language is defined and does not exist in mds:defaultLocale.
  * Do not declare a language twice in mds:defaultLocale section.	
    This should not happen due to XSD error
    which is usually made before schematron validation:
    "The value 'XX' of attribute 'id' on element 'lan:PT_Locale' is not valid with respect to its type, 'ID'. 
      (Element: lan:PT_Locale with parent element: mds:defaultLocale)"
            -->
            <sch:assert test="$duplicateLanguage"
                >$loc/strings/alert.M501</sch:assert>
            <sch:report test="$duplicateLanguage"
                >$loc/strings/report.M501</sch:report>
            
        </sch:rule>
    </sch:pattern>
</sch:schema>
