require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'poet_webdriver_test'
require 'page/home_page'

class BookSearchTest < PoetWebDriverTest

  def test_find_by_uid
    @driver.get 'https://diagram-staging.herokuapp.com'
    
    # Click the login link
    home_page = HomePage.new(@driver)
    login_page = home_page.click_sign_in
    
    login_page.name = 'QA_admin'
    login_page.password = 'qaadmin123'

    books_page = login_page.click_submit_admin
    
    # Search by ID
    books_page.uid_search = '_id384972'
    books_page.submit
    
    # Check if book found
    assert books_page.books_table_element['_id384972']['Title'].text.start_with? 'What is Biodiversity'
    
    # Search by ISBN
    books_page.clear_filter
    books_page.isbn_search = '9780078952715'
    books_page.submit
    
    assert books_page.books_table_element['9780078952715']['Title'].text.start_with? 'Glencoe Geometry'
    
    # Search by title
    books_page.clear_filter
    books_page.title_search = 'Hugo Cabret'
    books_page.submit
    
    assert books_page.books_table_element['9780439813785']['Title'].text.start_with? 'The Invention of Hugo Cabret'
  end
end