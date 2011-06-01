module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    when /the xml upload page/
      '/update_descriptions_in_book'
    when /the daisy upload page/
      '/daisy_book/upload'
    when /the description editing page/
      '/daisy_book/edit'
    when /the content page/
      '/daisy_book/content'
    when /the header panel/
      '/daisy_book/top_bar'
    when /the sidebar/
      '/daisy_book/side_bar'
    when /the images list page/
      '/dynamic_images'
      
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
