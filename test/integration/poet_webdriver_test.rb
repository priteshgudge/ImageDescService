require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'

# A base test class that handles the setup and teardown of
# the WebDriver instance.
class PoetWebDriverTest < Test::Unit::TestCase
  def setup
    @driver = Selenium::WebDriver.for :firefox
  end
  
  def teardown
    @driver.quit
  end
  
end
