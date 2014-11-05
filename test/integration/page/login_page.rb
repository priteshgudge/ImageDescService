require 'page/poet_page'
require 'page/home_page'

class LoginPage < PoetPage
  
  text_field(:name, :id => 'user_login')
  text_field(:password, :id => 'user_password')
  button(:submit, :name => 'commit')
  
  def click_home
    home
    return HomePage.new(@browser)
  end
end
