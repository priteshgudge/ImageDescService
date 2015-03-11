require 'test/unit'

class EpubBookHelperTest < Test::Unit::TestCase
  
  def setup
    @library = Library.find(1)
    @book_directory = EpubUtils.get_epub_file_main_directory('features/fixtures/Magic_Tree_House_abbrev')
    @contents_filenames = EpubUtils.get_epub_book_xml_file_names(@book_directory)
    @math_book_directory = EpubUtils.get_epub_file_main_directory('features/fixtures/Magic_Tree_House_abbrev_math')
    @math_contents_filenames = EpubUtils.get_epub_book_xml_file_names(@math_book_directory)
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

  def test_math_insertion
    # Set up the data
    math_file = File.read(@math_contents_filenames.first)
    original_doc = Nokogiri::XML math_file
    original_imgs = original_doc.xpath("//xmlns:img")
    assert_equal 2, original_imgs.size, "Image count in original file"
    
    original_img_src = original_imgs[1]["src"]
    
    # Run the test
    content_documents = EpubBookHelper::BatchHelper.get_content_documents_with_updated_descriptions(@math_book_directory, @math_contents_filenames, @library)
    
    # Check the result
    assert_equal 1, content_documents.values.size, "Output content documents"
    
    doc = Nokogiri::XML content_documents.values.shift
    imgs = doc.xpath("//xmlns:img")
    assert_equal 1, imgs.size, "Image count in test file"
    
    mathmls = doc.xpath("//mml:math", "mml" => "http://www.w3.org/1998/Math/MathML")
    assert_equal 1, mathmls.size, "MathML count in test file"
    
    mathmls.each do | math |
      alt_img = math['altimg']
      assert_equal original_img_src, alt_img, "Altimg content on math element"
    end
  end
end