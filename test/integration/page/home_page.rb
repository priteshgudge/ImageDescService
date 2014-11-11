require 'page/poet_page'
require 'page/edit_search_page'
require 'page/login_page'

class HomePage < PoetPage

  link(:edit, :link => 'Edit')
  link(:upload, :link => 'Upload')
  link(:process, :link => 'Process')
  link(:check, :link => 'Check')

  def click_edit
    edit
    return EditSearchPage.new(@browser)
  end

  def click_sign_in
    sign_in
    return LoginPage.new(@browser)
  end
  
end
