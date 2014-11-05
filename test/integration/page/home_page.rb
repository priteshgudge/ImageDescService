require 'page/poet_page'

class HomePage < PoetPage

  link(:edit, :link => 'Edit')
  link(:upload, :link => 'Upload')
  link(:process, :link => 'Process')
  link(:check, :link => 'Check')
  
end
