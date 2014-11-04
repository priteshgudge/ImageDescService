require 'page-object'

class EditPage
  include PageObject
  
  div(:book_title, :xpath => '//div[@id="book_title"]')
end