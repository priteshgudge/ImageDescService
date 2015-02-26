require "test/unit"
require "math_helper"

class MathHelperTest < Test::Unit::TestCase
  def setup
    @math_xml = File.read('features/fixtures/BookXMLWithMath.xml')
    @math_image_xml = File.read('features/fixtures/BookXMLWithMathImage.xml')
  end
  
  def test_opf_math
    # Set up the data
    original_opf = 'features/fixtures/Sample.opf'
    math_content = Nokogiri::XML @math_xml
    
    # Run the test
    math_opf_string = MathHelper.get_opf_contents_for_math(original_opf, math_content)
    
    # Check the results
    math_opf_doc = Nokogiri::XML math_opf_string
    meta_elements = math_opf_doc.xpath("//xmlns:meta")
    
    assert_true meta_elements.any? { |elt|
      elt['name'] === 'z39-86-extension-version'
      }, "Updated extension meta element"

    assert_true meta_elements.any? { |elt|
      elt['name'] === 'DTBook-XSLTFallback'
      }, "Updated fallback meta element"
  end
  
  def test_opf_no_math
    # Set up the data
    original_opf = 'features/fixtures/Sample.opf'
    math_content = Nokogiri::XML @math_image_xml
    
    # Run the test
    math_opf_string = MathHelper.get_opf_contents_for_math(original_opf, math_content)
    
    # Check the results
    math_opf_doc = Nokogiri::XML math_opf_string
    meta_elements = math_opf_doc.xpath("//xmlns:meta")
    
    # If there was no MathML, we shouldn't have any math meta elements
    assert_false meta_elements.any? { |elt|
      elt['name'] === 'z39-86-extension-version'
      }, "Updated extension meta element"

    assert_false meta_elements.any? { |elt|
      elt['name'] === 'DTBook-XSLTFallback'
      }, "Updated fallback meta element"
  end
end
