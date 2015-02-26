module MathHelper
  MATHML_NS = 'http://www.w3.org/1998/Math/MathML'
  MATHML_EXTENSION = 'z39-86-extension-version'
  MATHML_FALLBACK = 'DTBook-XSLTFallback'
  MATHML_FALLBACK_FILE = 'mathml-fallback.xslt'

  MATHML_COMMON_ATTRIB = <<-END_OF_STRING
    xlink:href    CDATA       #IMPLIED
    xlink:type     CDATA       #IMPLIED
    class          CDATA       #IMPLIED
    style          CDATA       #IMPLIED
    id             ID          #IMPLIED
    xref           IDREF       #IMPLIED
    other          CDATA       #IMPLIED
    xmlns:dtbook   CDATA       #FIXED
'http://www.daisy.org/z3986/2005/dtbook/'
    dtbook:smilref CDATA       #IMPLIED
    END_OF_STRING
  MATHML_EXTERNAL_NAMESPACES = <<-EOS
    xmlns:m CDATA #FIXED
    			'http://www.w3.org/1998/Math/MathML'
    EOS
  MATHML_2_SYSTEM_ID = 'http://www.w3.org/Math/DTD/mathml2/mathml2.dtd'
  MATHML_2_EXTERNAL_ID = '-//W3C//DTD MathML 2.0//EN'
  MATHML_ENTITY_DECL_TYPE = 4
  DTD_ENTITY_DECL_TYPE = 5
    
  def self.get_opf_contents_for_math(filename, contents_xml)
    file = File.new(filename)
    doc = Nokogiri::XML file

    math_elements = contents_xml.xpath('//m:math', 'm' => MATHML_NS)
    if math_elements.size > 0
      meta_elements = doc.xpath("//xmlns:meta")
      if meta_elements.none? { |elt| elt['name'] === MATHML_FALLBACK}
        fallback = Nokogiri::XML::Node.new "meta", doc
        fallback['name'] = MATHML_FALLBACK
        fallback['scheme'] = MATHML_NS
        fallback['content'] = MATHML_FALLBACK_FILE
      
        meta_elements.first.add_next_sibling fallback
      end
    
      if meta_elements.none? { |elt| elt['name'] === MATHML_EXTENSION }
        extension = Nokogiri::XML::Node.new "meta", doc
        extension['name'] = MATHML_EXTENSION
        extension['scheme'] = MATHML_NS
        extension['content'] = '1.0'
      
        meta_elements.first.add_next_sibling extension
      end
    end
  
    return doc.to_xml
  end

  def self.create_math_element(equation)
    fragment = Nokogiri::XML.fragment equation.element
    return fragment.children.first
  end
  
  def self.replace_math_image(image_element, math_element, image_source)
    math_element.parent = image_element.parent
    image_element.unlink
    math_element['altimg'] = image_source
  end
  
  def self.attach_math_extensions(doc)
    # For description of DTD extensions, see http://www.daisy.org/projects/mathml/mathml-in-daisy-spec.html#h_23
    if (doc.internal_subset.children.none? { |elt| elt.name == "MATHML.prefixed" })
      Nokogiri::XML::EntityDecl.new("MATHML.prefixed", doc, MATHML_ENTITY_DECL_TYPE, nil, nil, "INCLUDE")
      Nokogiri::XML::EntityDecl.new("MATHML.prefix", doc, MATHML_ENTITY_DECL_TYPE, nil, nil, "m")
      Nokogiri::XML::EntityDecl.new("MATHML.C.attrib", doc, MATHML_ENTITY_DECL_TYPE, nil, nil, MATHML_COMMON_ATTRIB)
      Nokogiri::XML::EntityDecl.new("mathML2", doc, DTD_ENTITY_DECL_TYPE, MATHML_2_EXTERNAL_ID, MATHML_2_SYSTEM_ID)
      Nokogiri::XML::EntityDecl.new("externalFlow", doc, MATHML_ENTITY_DECL_TYPE, nil, nil, "| m:math")
      Nokogiri::XML::EntityDecl.new("externalNamespaces", doc, MATHML_ENTITY_DECL_TYPE, nil, nil, "| m:math")
    end
    return doc
  end
  
  def self.contains_math(content_string)
    doc = Nokogiri::XML content_string
    return doc.xpath('//m:math', 'm' => MATHML_NS).size > 0
  end
end