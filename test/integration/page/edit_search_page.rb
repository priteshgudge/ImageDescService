require 'page/poet_page'
require 'page/edit_page'

class EditSearchPage < PoetPage
  
  text_field(:book_id, :name => 'book_uid')
  button(:submit, :xpath => '//input[@value="Edit"]')
  
  def click_submit
    submit
    return EditPage.new(@browser)
  end
end