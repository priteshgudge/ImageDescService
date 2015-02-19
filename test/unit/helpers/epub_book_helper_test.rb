require 'test/unit'

class EpubBookHelperTest < Test::Unit::TestCase
  
  def setup
    @library = Library.find(1)
    @book_directory = EpubUtils.get_epub_file_main_directory('features/fixtures/Magic_Tree_House_abbrev')
    @contents_filenames = EpubUtils.get_epub_book_xml_file_names(@book_directory)
  end
  
  def test_alt_insertion
    # Set up the data
    new_alt = Alt.create(:alt => "this is new alt text", 
            :dynamic_image_id => 5, 
                 :from_source => false)
    
    # Run the test
    content_documents = EpubBookHelper::BatchHelper.get_content_documents_with_updated_descriptions(@book_directory, @contents_filenames, @library)
    
    # Check the result
    assert_equal 1, content_documents.values.size, "Output content documents"
    
    doc = Nokogiri::XML content_documents.values.shift
    imgs = doc.xpath("//xmlns:img")
    assert_equal 4, imgs.size, "Image count in test file"
    
    assert_true imgs.any? { |img| 
      alt = img['alt']
      new_alt.alt === alt
      }, "Updated alt text"
  end
  
  def test_skip_alt
    # Set up the data
    # Say Alt is original soure, so shouldn't be text to update
    Alt.update_all({ :from_source => true })
    new_alt = Alt.create(:alt => "this is new alt text", 
            :dynamic_image_id => 5, 
                 :from_source => true)
    
    # Run the test
    content_documents = EpubBookHelper::BatchHelper.get_content_documents_with_updated_descriptions(@book_directory, @contents_filenames, @library)
    
    # Check the result
    assert_equal 1, content_documents.values.size, "Output content documents"
    
    doc = Nokogiri::XML content_documents.values.shift
    imgs = doc.xpath("//xmlns:img")
    assert_equal 4, imgs.size, "Image count in test file"
    
    # Should find that there were no updates
    assert_false imgs.any? { |img| 
      alt = img['alt']
      new_alt.alt === alt
      }, "Updated alt text"
  end
end