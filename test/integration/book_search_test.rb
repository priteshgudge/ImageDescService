require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'

class BookSearchTest < Test::Unit::TestCase
  def setup
    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  end
  
  def teardown
    @driver.quit
  end
  
  def test_find_and_edit_by_uid
    @driver.get 'https://diagram-staging.herokuapp.com'
    
    # Click the login link
    @driver.find_element(:link => 'Sign in').click
    @driver.find_element(:id => 'user_login').send_keys 'QA_admin'
    @driver.find_element(:id => 'user_password').send_keys 'qaadmin123'
    @driver.find_element(:name => 'commit').click
    
    # Go to search
    @driver.find_element(:link => 'Poet Image Description').click
    @driver.find_element(:link => 'Edit').click
    # Search by ID
    @driver.find_element(:name => 'book_uid').send_keys '_id384972'
    @driver.find_element(:xpath => '//input[@value="Edit"]').click

    # Check if book found
    assert @driver.find_element(:xpath => '//div[@id="book_title"]').text.start_with? 'What is Biodiversity'
  end
end