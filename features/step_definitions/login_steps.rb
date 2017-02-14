  Given /^I am a user named "([^"]*)" with an email "([^"]*)" and password "([^"]*)" and username "([^"]*)"$/ do |name, email, password, username|
  User.new(:first_name => name,
            :last_name => 'User',
            :email => email,
            :username => username,
            :password => password,
            :password_confirmation => password).save!
  end

  Then /^I should be already signed in$/ do
    And %{I should see "Logout"}
  end

  Given /^I am signed up as "(.*)\/(.*)"$/ do |email, password|
    Given %{I am not logged in}
    When %{I go to the sign up page}
    And %{I fill in "user_login" with "#{email}"}
    And %{I fill in "Password" with "#{password}"}
    And %{I fill in "Password confirmation" with "#{password}"}
    And %{I press "Sign up"}
    Then %{I should see "You have signed up successfully. If enabled, a confirmation was sent to your e-mail."}
  end



  When /^I sign in as "(.*)\/(.*)"$/ do |email, password|
    When %{I go to the sign in page}
    And %{I fill in "user_login" with "#{email}"}
    And %{I fill in "Password" with "#{password}"}
    And %{I press "Sign in"}
  end
