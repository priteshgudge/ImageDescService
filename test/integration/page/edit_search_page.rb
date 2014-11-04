require 'page-object'

class EditSearchPage
  include PageObject
  
  text_field(:book_id, :name => 'book_uid')
  button(:submit, :xpath => '//input[@value="Edit"]')
end