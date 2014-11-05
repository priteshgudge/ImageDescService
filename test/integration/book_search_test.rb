require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'
require 'poet_webdriver_test'
require 'page/home_page'

class BookSearchTest < PoetWebDriverTest

  def test_find_and_edit_by_uid
    @driver.get 'https://diagram-staging.herokuapp.com'
    
    # Click the login link
    home_page = HomePage.new(@driver)
    login_page = home_page.click_sign_in
    
    login_page.name = 'QA_admin'
    login_page.password = 'qaadmin123'
    login_page.submit
    
    # Go to search
    home_page = login_page.click_home
    
    # Search by ID
    edit_search_page = home_page.click_edit
    edit_search_page.book_id = '_id384972'
    edit_search_page.submit
    
    # Check if book found
    edit_page = edit_search_page.click_submit
    assert edit_page.book_title.start_with? 'What is Biodiversity'
  end
end