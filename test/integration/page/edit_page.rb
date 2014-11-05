require 'page/poet_page'

class EditPage < PoetPage
  
  div(:book_title, :xpath => '//div[@id="book_title"]')
end