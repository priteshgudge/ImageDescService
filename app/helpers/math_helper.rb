module MathHelper
  MATHML_NS = 'http://www.w3.org/1998/Math/MathML'
  MATHML_EXTENSION = 'z39-86-extension-version'
  MATHML_FALLBACK = 'DTBook-XSLTFallback'

  def self.get_opf_contents_for_math(filename, contents_xml)
    file = File.new(filename)
    doc = Nokogiri::XML file

    math_elements = contents_xml.xpath('//m:math', 'm' => MATHML_NS)
    if math_elements.size > 0
      meta_elements = doc.xpath("//xmlns:meta")
      if !meta_elements.any? { |elt| elt['name'] === MATHML_FALLBACK}
        fallback = Nokogiri::XML::Node.new "meta", doc
        fallback['name'] = MATHML_FALLBACK
        fallback['scheme'] = MATHML_NS
        fallback['content'] = 'mathml-fallback.xslt'
      
        meta_elements.first.add_next_sibling fallback
      end
    
      if !meta_elements.any? { |elt| elt['name'] === MATHML_EXTENSION }
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
  
  def self.replace_math_image(image_element, math_element)
    math_element.parent = image_element.parent
    image_element.unlink
    math_element['altimg'] = image_element['src']
  end
end