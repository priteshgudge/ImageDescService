require "test/unit"

class DaisyParserTest < Test::Unit::TestCase
  
  def setup
    @parser = DaisyParser.new
  end
  
  def test_extract_title
    # Set up the data
    xml = File.read('features/fixtures/BookXMLWithImagesWithoutGroups.xml')
    doc = Nokogiri::XML xml
    
    # Run the test
    book_title = @parser.extract_optional_book_title(doc)
    
    # Check the result
    assert_equal 'Outline of U.S. History', book_title
  end

  def test_extract_missing_title
    # Set up the data
    xml_without_title = File.read('features/fixtures/NotValidBook.xml')
    doc = Nokogiri::XML xml_without_title
    
    # Run the test
    title = @parser.extract_optional_book_title(doc)
    
    # Check the result
    assert_nil title
  end

  def test_extract_isbn
    # Set up the data
    xml = File.read('features/fixtures/Sample.opf')
    doc = Nokogiri::XML xml
    
    # Run the test
    isbn = @parser.extract_optional_isbn(doc)
    
    # Check the result
    assert_equal '9780078913280', isbn
  end
end
