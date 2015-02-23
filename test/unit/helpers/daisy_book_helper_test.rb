require "test/unit"

class DaisyBookHelperTest < Test::Unit::TestCase
  def setup
    @helper = DaisyBookHelper::BatchHelper.new
    @library = Library.find(1)
    @alt_xml = File.read('features/fixtures/BookXMLWithImagesWithOurProdnotes.xml')
    @math_xml = File.read('features/fixtures/BookXMLWithMath.xml')
  end
  
  def test_alt_insertion
    # Set up the data
    new_alt = Alt.create(:alt => "this is new alt text", 
            :dynamic_image_id => 3, 
                 :from_source => false)
    
    # Run the test
    doc_string = @helper.get_contents_with_updated_descriptions(@alt_xml, @library)
    
    # Check the result
    doc = Nokogiri::XML doc_string
    imgs = doc.xpath("//xmlns:img")
    assert_equal 1, imgs.size, "Image count in test file"
    
    imgs.each do | img |
      alt = img['alt']
      assert_equal new_alt.alt, alt, "Updated alt text"
    end
  end
  
  def test_skip_alt
    # Set up the data
    # Say Alt is original soure, so shouldn't be text to update
    Alt.update_all({ :from_source => true })
    new_alt = Alt.create(:alt => "this is new alt text", 
            :dynamic_image_id => 3, 
                 :from_source => true)
    
    # Run the test
    doc_string = @helper.get_contents_with_updated_descriptions(@alt_xml, @library)
    
    # Check the result
    doc = Nokogiri::XML doc_string
    imgs = doc.xpath("//xmlns:img")
    assert_equal 1, imgs.size, "Image count in test file"
    
    imgs.each do | img |
      alt = img['alt']
      assert_not_equal new_alt.alt, alt, "Updated alt text"
    end
  end
  
  def test_math_insertion
    # Set up the data
    original_doc = Nokogiri::XML @math_xml
    original_imgs = original_doc.xpath("//xmlns:img")
    assert_equal 1, original_imgs.size, "Image count in original file"
    
    # Run the test
    doc_string = @helper.get_contents_with_updated_descriptions(@math_xml, @library)
    
    # Check the result
    doc = Nokogiri::XML doc_string
    imgs = doc.xpath("//xmlns:img")
    assert_equal 0, imgs.size, "Image count in test file"
    
    mathmls = doc.xpath("//xmlns:math")
    assert_equal 1, mathmls.size, "MathML count in test file"
    
    mathmls.each do | math |
      alt_img = math['altimg']
      assert_not_empty alt_img, "Altimg content on #{math['id']}"
    end
  end
end