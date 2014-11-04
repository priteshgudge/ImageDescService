require 'page-object'

class HomePage
  include PageObject

  link(:edit, :link => 'Edit')
  link(:upload, :link => 'Upload')
  link(:process, :link => 'Process')
  link(:check, :link => 'Check')
  
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
