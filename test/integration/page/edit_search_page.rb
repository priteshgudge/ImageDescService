require 'page/poet_page'

class EditSearchPage < PoetPage
  
  text_field(:book_id, :name => 'book_uid')
  button(:submit, :xpath => '//input[@value="Edit"]')
end