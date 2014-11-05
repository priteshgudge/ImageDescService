require 'page/poet_page'

class BooksPage < PoetPage
  
  table(:books_table, :id => 'index_table_books')
  
  text_field(:title_search, :id => 'q_title')
  text_field(:isbn_search, :id => 'q_isbn')
  text_field(:uid_search, :id => 'q_uid')
  button(:submit, :name => 'commit')
end