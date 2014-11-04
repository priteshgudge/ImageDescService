require 'page-object'

class LoginPage
  include PageObject
  
  text_field(:name, :id => 'user_login')
  text_field(:password, :id => 'user_password')
  button(:submit, :name => 'commit')
  
  # Common navigation elements on all pages
  link(:home, :link => 'Poet Image Description')
  link(:my_books, :link => 'My Books')
  link(:training, :link => 'Training')
  link(:help, :link => 'Help')
  link(:reports, :link => 'Reports')
  # TODO: Define the dropdowns for Books, Users, profile
end
