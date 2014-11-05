require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'poet_webdriver_test'
require 'page/home_page'
require 'page/login_page'
require 'page/edit_search_page'
require 'page/edit_page'

class BookSearchTest < PoetWebDriverTest

  def test_find_and_edit_by_uid
    @driver.get 'https://diagram-staging.herokuapp.com'
    
    # Click the login link
    home_page = HomePage.new(@driver)
    home_page.sign_in
    
    login_page = LoginPage.new(@driver)
    login_page.name = 'QA_admin'
    login_page.password = 'qaadmin123'
    login_page.submit
    
    # Go to search
    login_page.home
    home_page = HomePage.new(@driver)
    home_page.edit
    
    # Search by ID
    edit_search_page = EditSearchPage.new(@driver)
    edit_search_page.book_id = '_id384972'
    edit_search_page.submit
    
    # Check if book found
    edit_page = EditPage.new(@driver)
    assert edit_page.book_title.start_with? 'What is Biodiversity'
  end
end