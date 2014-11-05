require 'page/poet_page'
require 'page/home_page'
require 'page/books_page'

class LoginPage < PoetPage
  
  text_field(:name, :id => 'user_login')
  text_field(:password, :id => 'user_password')
  button(:submit, :name => 'commit')
  
  def click_home
    home
    return HomePage.new(@browser)
  end
  
  # An admin user who logs in will be taken
  # to the list of uploaded books.
  def click_submit_admin
    submit
    return BooksPage.new(@browser)
  end
end
