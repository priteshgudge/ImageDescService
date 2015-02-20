require "test/unit"

class DaisyBookHelperTest < Test::Unit::TestCase
  def setup
    @helper = DaisyBookHelper::BatchHelper.new
    @library = Library.find(1)
    @xml = File.read('features/fixtures/BookXMLWithImagesWithOurProdnotes.xml')
  end
  
  def test_alt_insertion
    # Set up the data
    new_alt = Alt.create(:alt => "this is new alt text", 
            :dynamic_image_id => 3, 
                 :from_source => false)
    
    # Run the test
    doc_string = @helper.get_contents_with_updated_descriptions(@xml, @library)
    
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
    doc_string = @helper.get_contents_with_updated_descriptions(@xml, @library)
    
    # Check the result
    doc = Nokogiri::XML doc_string
    imgs = doc.xpath("//xmlns:img")
    assert_equal 1, imgs.size, "Image count in test file"
    
    imgs.each do | img |
      alt = img['alt']
      assert_not_equal new_alt.alt, alt, "Updated alt text"
    end
  end
end