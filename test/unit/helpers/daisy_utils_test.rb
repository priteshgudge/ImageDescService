require "test/unit"

class DaisyUtilsTest < Test::Unit::TestCase
  def test_extract_uid
    xml = File.read('features/fixtures/BookXMLWithImagesWithoutGroups.xml')
    doc = Nokogiri::XML xml
    
    book_uid = DaisyUtils.extract_book_uid(doc)
    
    assert_equal "en-us-20100517111839", book_uid
  end
  
  def test_missing_uid
    xml_without_uid = File.read('features/fixtures/BookXMLWithNoUID.xml')
    doc = Nokogiri::XML xml_without_uid
    
    begin
      DaisyUtils.extract_book_uid(doc)
      fail "Should have raised exception for missing book_uid"
    rescue MissingBookUIDException => e
      #ignore expected
    end
  end
end
