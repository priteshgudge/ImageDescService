require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SplitXmlHelper. 

describe SplitXmlHelper do
  it "should split at each level when we have a relatively low max limit of images" do
    xml_splitting, image_limit = load_test_xml 3
    segments = parse_and_segment xml_splitting, image_limit
    
    segments.size.should eq 3
  end

  it "should not split at each level when we have a relatively high max limit of images" do
    xml_splitting, image_limit = load_test_xml 1
    segments = parse_and_segment xml_splitting, image_limit
    
    segments.size.should eq 1
  end
  
  it "should be able to apply the xslt file to transform the XML into HTML" do
    xml_splitting, image_limit = load_test_xml 1
    segments = parse_and_segment xml_splitting, image_limit

    xsl = File.read(DaisyParser.daisy_xsl)
    transformer = Nokogiri::XSLT(xsl)

    segments.each do |seg|
      xml_doc = Nokogiri::XML seg
      num_xml_images = xml_doc.css('img').size
      
      html_doc = transformer.transform(xml_doc)
      num_html_images = html_doc.css('img').size
      
      num_html_images.size.should eq num_xml_images.size
    end
    
  end
  
  def load_test_xml target_chunks
    xml_splitting = File.read('features/fixtures/TestOfSplittingXml.xml')
    doc = Nokogiri::XML xml_splitting
    num_images = doc.css('img').size
    
    # Shoot for about target_chunks chunks of images
    image_limit = num_images/target_chunks
    [xml_splitting, image_limit]
  end
  
  def parse_and_segment xml_splitting, image_limit
    # Create our parser
    splitter = SplitXmlHelper::DTBookSplitter.new(image_limit)
    parser = Nokogiri::XML::SAX::Parser.new(splitter)

    # Send some XML to the parser
    parser.parse(xml_splitting)
    splitter.segments   #array of fully formed xml strings that each represent a broken up piece of the whole xml
  end
end
