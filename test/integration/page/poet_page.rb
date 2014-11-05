require 'page-object'

# A base Page Object that shares the common elements found
# on all Poet pages, such as the top navigation elements.
class PoetPage
  include PageObject
  
  # Common navigation elements on all pages
  link(:home, :link => 'Poet Image Description')
  link(:my_books, :link => 'My Books')
  link(:training, :link => 'Training')
  link(:help, :link => 'Help')
  link(:reports, :link => 'Reports')
  # Only available when not logged in
  link(:register, :link => 'Register')
  link(:sign_in, :link => 'Sign in')
  # TODO: Define the dropdowns for Books, Users, profile
  
end
