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
  end
end