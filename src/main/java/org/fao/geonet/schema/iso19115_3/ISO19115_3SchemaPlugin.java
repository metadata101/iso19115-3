package org.fao.geonet.schema.iso19115_3;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.google.common.collect.ImmutableSet;
import org.fao.geonet.kernel.schema.AssociatedResource;
import org.fao.geonet.kernel.schema.AssociatedResourcesSchemaPlugin;
import org.fao.geonet.kernel.schema.ISOPlugin;
import org.fao.geonet.kernel.schema.MultilingualSchemaPlugin;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import org.jdom.xpath.XPath;

/**
 * Created by francois on 6/15/14.
 */
public class ISO19115_3SchemaPlugin
        extends org.fao.geonet.kernel.schema.SchemaPlugin
        implements
                AssociatedResourcesSchemaPlugin,
                MultilingualSchemaPlugin,
                ISOPlugin {
    public static final String IDENTIFIER = "iso19115-3";

    private static ImmutableSet<Namespace> allNamespaces;
    static {
        allNamespaces = ImmutableSet.<Namespace>builder()
                .add(ISO19115_3Namespaces.GCO)
                .add(ISO19115_3Namespaces.MDB)
                .add(ISO19115_3Namespaces.MRC)
                .add(ISO19115_3Namespaces.MRL)
                .add(ISO19115_3Namespaces.SRV)
                .build();
    }

    public ISO19115_3SchemaPlugin() {
        super(IDENTIFIER);
    }

    public Set<AssociatedResource> getAssociatedResourcesUUIDs(Element metadata) {
        String XPATH_FOR_AGGRGATIONINFO = "*//mri:associatedResource/*" +
                "[mri:metadataReference/@uuidref " +
                "and mri:initiativeType/mri:DS_InitiativeTypeCode/@codeListValue != '']";
        Set<AssociatedResource> listOfResources = new HashSet<AssociatedResource>();
        List<?> sibs = null;
        try {
            sibs = Xml
                    .selectNodes(
                            metadata,
                            XPATH_FOR_AGGRGATIONINFO,
                            allNamespaces.asList());


            for (Object o : sibs) {
                if (o instanceof Element) {
                    Element sib = (Element) o;
                    Element agId = (Element) sib.getChild("metadataReference", ISO19115_3Namespaces.MRI);
                    // TODO: Reference may be defined in Citation identifier
                    String sibUuid = agId.getAttributeValue("uuidref");
                    String initType = sib.getChild("initiativeType", ISO19115_3Namespaces.MRI)
                            .getChild("DS_InitiativeTypeCode", ISO19115_3Namespaces.MRI)
                            .getAttributeValue("codeListValue");

                    AssociatedResource resource = new AssociatedResource(sibUuid, initType, "");
                    listOfResources.add(resource);
                }
            }
        } catch (JDOMException e) {
            e.printStackTrace();
        }
        return listOfResources;
    }

    @Override
    public Set<String> getAssociatedParentUUIDs(Element metadata) {
        ElementFilter elementFilter = new ElementFilter("parentMetadata", ISO19115_3Namespaces.MDB);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null,
                "uuidref");
    }

    public Set<String> getAssociatedDatasetUUIDs (Element metadata) {
        return getAttributeUuidrefValues(metadata, "operatesOn", ISO19115_3Namespaces.SRV);
    };
    public Set<String> getAssociatedFeatureCatalogueUUIDs (Element metadata) {
        return getAttributeUuidrefValues(metadata, "featureCatalogueCitation", ISO19115_3Namespaces.MRC);
    };
    public Set<String> getAssociatedSourceUUIDs (Element metadata) {
        return getAttributeUuidrefValues(metadata, "source", ISO19115_3Namespaces.MRL);
    }

    private Set<String> getAttributeUuidrefValues(Element metadata, String tagName, Namespace namespace) {
        ElementFilter elementFilter = new ElementFilter(tagName, namespace);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null,
                "uuidref");
    };


    @Override
    public List<Element> getTranslationForElement(Element element, String languageIdentifier) {
        final String path = ".//lan:LocalisedCharacterString" +
                "[@locale='#" + languageIdentifier + "']";
        try {
            XPath xpath = XPath.newInstance(path);
            @SuppressWarnings("unchecked")
            List<Element> matches = xpath.selectNodes(element);
            return matches;
        } catch (Exception e) {
            Log.debug(LOGGER_NAME, getIdentifier() + ": getTranslationForElement failed " +
                    "on element " + Xml.getString(element) +
                    " using XPath '" + path +
                    " Exception: " + e.getMessage());
        }
        return null;
    }

    /**
     *  Add a LocalisedCharacterString to an element. In ISO19139, the translation are
     *  stored gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString.
     *
     * <pre>
     * <cit:title xsi:type="lan:PT_FreeText_PropertyType">
     *    <gco:CharacterString>Template for Vector data</gco:CharacterString>
     *    <lan:PT_FreeText>
     *        <lan:textGroup>
     *            <lan:LocalisedCharacterString locale="#FRE">Modèle de données vectorielles en ISO19139 (multilingue)</lan:LocalisedCharacterString>
     *        </lan:textGroup>
     * </pre>
     *
     * @param element
     * @param languageIdentifier
     * @param value
     */
    @Override
    public void addTranslationToElement(Element element, String languageIdentifier, String value) {
        element.setAttribute("type", "lan:PT_FreeText_PropertyType",
                Namespace.getNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance"));

        // Create a new translation for the language
        Element langElem = new Element("LocalisedCharacterString", ISO19115_3Namespaces.LAN);
        langElem.setAttribute("locale", "#" + languageIdentifier);
        langElem.setText(value);
        Element textGroupElement = new Element("textGroup", ISO19115_3Namespaces.LAN);
        textGroupElement.addContent(langElem);

        // Get the PT_FreeText node where to insert the translation into
        Element freeTextElement = element.getChild("PT_FreeText", ISO19115_3Namespaces.LAN);
        if (freeTextElement == null) {
            freeTextElement = new Element("PT_FreeText", ISO19115_3Namespaces.LAN);
            element.addContent(freeTextElement);
        }
        freeTextElement.addContent(textGroupElement);
    }

    @Override
    public String getBasicTypeCharacterStringName() {
        return "gco:CharacterString";
    }

    @Override
    public Element createBasicTypeCharacterString() {
        return new Element("CharacterString", ISO19115_3Namespaces.GCO);
    }
}
