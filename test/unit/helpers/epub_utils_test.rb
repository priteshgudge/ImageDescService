require "test/unit"

class EpubUtilsTest < Test::Unit::TestCase
  
  def test_get_filenames_from_manifest
    bookDirectory = EpubUtils.get_epub_file_main_directory('features/fixtures/Magic_Tree_House__4__Pirates_Pas')
    filenames = EpubUtils.get_epub_book_xml_file_names(bookDirectory)
    
    assert_equal filenames.size, 13
  end
  
end
