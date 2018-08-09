package org.fao.geonet.schema.iso19115_3;
import java.util.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.kernel.schema.*;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import org.jdom.xpath.XPath;

import static org.fao.geonet.schema.iso19115_3.ISO19115_3Namespaces.*;
/**
 * Created by francois on 6/15/14.
 */
public class ISO19115_3SchemaPlugin
        extends org.fao.geonet.kernel.schema.SchemaPlugin
        implements
                AssociatedResourcesSchemaPlugin,
                MultilingualSchemaPlugin,
                ExportablePlugin,
                ISOPlugin {
    public static final String IDENTIFIER = "iso19115-3";

    private static ImmutableSet<Namespace> allNamespaces;
    private static Map<String, Namespace> allTypenames;
    private static Map<String, String> allExportFormats;

    static {
        allNamespaces = ImmutableSet.<Namespace>builder()
                .add(GCO)
                .add(MDB)
                .add(ISO19115_3Namespaces.MRC)
                .add(ISO19115_3Namespaces.MRL)
                .add(ISO19115_3Namespaces.MRI)
                .add(SRV)
                .build();

        allTypenames = ImmutableMap.<String, Namespace>builder()
                .put("csw:Record", Namespace.getNamespace("csw", "http://www.opengis.net/cat/csw/2.0.2"))
                .put("mdb:MD_Metadata", Namespace.getNamespace("mdb", "http://standards.iso.org/iso/19115/-3/mdb/1.0"))
                .put("gmd:MD_Metadata", Namespace.getNamespace("gmd", "http://www.isotc211.org/2005/gmd"))
                .build();

        allExportFormats = ImmutableMap.<String, String>builder()
                .put("convert/ISO19139/toISO19139.xsl", "metadata-iso19139.xml")
                .build();
    }

    public ISO19115_3SchemaPlugin() {
        super(IDENTIFIER, allNamespaces);
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

                    String associationType = sib.getChild("associationType", ISO19115_3Namespaces.MRI)
                        .getChild("DS_AssociationTypeCode", ISO19115_3Namespaces.MRI)
                        .getAttributeValue("codeListValue");

                    String initType = "";
                    final Element initiativeTypeEl = sib.getChild("initiativeType", ISO19115_3Namespaces.MRI);
                    if (initiativeTypeEl != null) {
                        initType = initiativeTypeEl.getChild("DS_InitiativeTypeCode", ISO19115_3Namespaces.MRI)
                            .getAttributeValue("codeListValue");
                    }

                    AssociatedResource resource = new AssociatedResource(sibUuid, initType, associationType);
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
        ElementFilter elementFilter = new ElementFilter("parentMetadata", MDB);
        return Xml.filterElementValues(
                metadata,
                elementFilter,
                null, null,
                "uuidref");
    }

    public Set<String> getAssociatedDatasetUUIDs (Element metadata) {
        return getAttributeUuidrefValues(metadata, "operatesOn", SRV);
    };
    public Set<String> getAssociatedFeatureCatalogueUUIDs (Element metadata) {
        // Feature catalog may also be embedded into the document
        // Or the citation of the feature catalog may contains a reference to it
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

    /**
     * Remove all multingual aspect of an element. Keep the md language localized strings
     * as default gco:CharacterString for the element.
     *
     * @param element
     * @param langs Metadata languages. The main language MUST be the first one.
     * @return
     * @throws JDOMException
     */
    @Override
    public Element removeTranslationFromElement(Element element, List<String> langs) throws JDOMException {
        String mainLanguage = langs != null && langs.size() > 0 ? langs.get(0) : "#EN";

        List<Element> nodesWithStrings = (List<Element>) Xml.selectNodes(element, "*//lan:PT_FreeText", Arrays.asList(ISO19115_3Namespaces.LAN));

        for(Element e : nodesWithStrings) {
            // Retrieve or create the main language element
            Element mainCharacterString = ((Element)e.getParent()).getChild("CharacterString", GCO);
            if (mainCharacterString == null) {
                // create it if it does not exist
                mainCharacterString = new Element("CharacterString", GCO);
                ((Element)e.getParent()).addContent(0, mainCharacterString);
            }

            // Retrieve the main language value if exist
            List<Element> mainLangElement = (List<Element>) Xml.selectNodes(
                e,
                "*//lan:LocalisedCharacterString[@locale='" + mainLanguage + "']",
                Arrays.asList(ISO19115_3Namespaces.LAN));

            // Set the main language value
            if (mainLangElement.size() == 1) {
                String mainLangString = mainLangElement.get(0).getText();

                if (StringUtils.isNotEmpty(mainLangString)) {
                    mainCharacterString.setText(mainLangString);
                } else if (mainCharacterString.getAttribute("nilReason", GCO) == null){
                    ((Element)mainCharacterString.getParent()).setAttribute("nilReason", "missing", GCO);
                }
            } else if (StringUtils.isEmpty(mainCharacterString.getText())) {
                ((Element)mainCharacterString.getParent()).setAttribute("nilReason", "missing", GCO);
            }
        }

        // Remove unused lang entries
        List<Element> translationNodes = (List<Element>)Xml.selectNodes(element, "*//node()[@locale]");
        for(Element el : translationNodes) {
            // Remove all translations if there is no or only one language requested
            if(langs.size() <= 1 ||
                !langs.contains(el.getAttribute("locale").getValue())) {
                Element parent = (Element)el.getParent();
                parent.detach();
            }
        }

        // Remove PT_FreeText which might be emptied by above processing
        for(Element el : nodesWithStrings) {
            if (el.getChildren().size() == 0) {
                el.detach();
            }
        }

        return element;
    }

    @Override
    public String getBasicTypeCharacterStringName() {
        return "gco:CharacterString";
    }

    @Override
    public Element createBasicTypeCharacterString() {
        return new Element("CharacterString", GCO);
    }


    @Override
    public Element addOperatesOn(Element serviceRecord,
                                 Map<String, String> layers,
                                 String serviceType,
                                 String baseUrl) {

        Element root = serviceRecord
            .getChild("identificationInfo", MDB)
            .getChild("SV_ServiceIdentification", SRV);

        if (root != null) {

            // Coupling type MUST be present as it is the insertion point
            // for coupledResource
            Element couplingType = root.getChild("couplingType", SRV);
            int coupledResourceIdx = root.indexOf(couplingType);

            layers.keySet().forEach(uuid -> {
                String layerName = layers.get(uuid);

                // Create coupled resources elements to register all layername
                // in service metadata. This information could be used to add
                // interactive map button when viewing service metadata.
                Element coupledResource = new Element("coupledResource", SRV);
                coupledResource.setAttribute("nilReason", "synchronizedFromOGC", GCO);
                Element scr = new Element("SV_CoupledResource", SRV);


                // Create operation according to service type
                Element operation = new Element("operationName", SRV);
                Element operationValue = new Element("CharacterString", GCO);

                if (serviceType.startsWith("WMS"))
                    operationValue.setText("GetMap");
                else if (serviceType.startsWith("WFS"))
                    operationValue.setText("GetFeature");
                else if (serviceType.startsWith("WCS"))
                    operationValue.setText("GetCoverage");
                else if (serviceType.startsWith("SOS"))
                    operationValue.setText("GetObservation");
                operation.addContent(operationValue);

                // Create identifier (which is the metadata identifier)
                Element id = new Element("identifier", SRV);
                Element idValue = new Element("CharacterString", GCO);
                idValue.setText(uuid);
                id.addContent(idValue);

                // Create scoped name element as defined in CSW 2.0.2 ISO profil
                // specification to link service metadata to a layer in a service.
                Element scopedName = new Element("ScopedName", GCO);
                scopedName.setText(layerName);

                scr.addContent(operation);
                scr.addContent(id);
                scr.addContent(scopedName);
                coupledResource.addContent(scr);

                // Add coupled resource before coupling type element
                if (coupledResourceIdx != -1) {
                    root.addContent(coupledResourceIdx, coupledResource);
                }


                // Add operatesOn element at the end of identification section.
                Element op = new Element("operatesOn", SRV);
                op.setAttribute("nilReason", "synchronizedFromOGC", GCO);
                op.setAttribute("uuidref", uuid);

                String hRefLink = baseUrl + "api/records/" + uuid + "/formatters/xml";
                op.setAttribute("href", hRefLink, XLINK);

                root.addContent(op);
            });
        }

        return serviceRecord;
    }

    @Override
    public List<Extent> getExtents(Element record) {
        List<Extent> extents = new ArrayList<>();

        ElementFilter bboxFinder = new ElementFilter("EX_GeographicBoundingBox", GEX);
        @SuppressWarnings("unchecked")
        Iterator<Element> bboxes = record.getDescendants(bboxFinder);
        while (bboxes.hasNext()) {
            Element box = bboxes.next();
            try {
                extents.add(new Extent(
                    Double.valueOf(box.getChild("westBoundLongitude", GEX).getChild("Decimal", GCO).getText()),
                    Double.valueOf(box.getChild("eastBoundLongitude", GEX).getChild("Decimal", GCO).getText()),
                    Double.valueOf(box.getChild("southBoundLatitude", GEX).getChild("Decimal", GCO).getText()),
                    Double.valueOf(box.getChild("northBoundLatitude", GEX).getChild("Decimal", GCO).getText())
                ));
            } catch (NullPointerException e) {}
        }
        return extents;
    }


    @Override
    public Map<String, Namespace> getCswTypeNames() {
        return allTypenames;
    }

    @Override
    public Map<String, String> getExportFormats() {
        return allExportFormats;
    }
}
