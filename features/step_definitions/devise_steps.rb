Then /^I should see error messages$/ do
  page.body.should match(/error(s)? prohibited/m)
end

# Paths

Then /^I should see the "([^"]*)" login page$/ do |subdomain|
  page.body.should match(%r{#{subdomain}})
  page.body.should match(/login/)
end

When /^I visit the subdomained "(.*)" under "(.*)"$/ do |path, subdomain|
  host = "#{subdomain}.#{$host}:#{$port}"
  case path
  when /signup page/
    visit new_user_registration_url(:host => host)
  else
    raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
      "Now, go and add a mapping in #{__FILE__}"
  end
end

# Users

Given /^An user signed up with "(.*)" name$/ do |name|
  Factory.create :user, :name => name
end

Given /^I signed up with "(.*)"$/ do |email_and_password|
  create_user(email_and_password)
end

Given /^I signed in with "(.*)"$/ do |email_and_password|
  email, password = email_and_password.split '/'
  user = create_user(email_and_password)

  visit new_user_session_url(:host => $host, :port => $port)
  fill_in 'Login',    :with => email
  fill_in 'Password', :with => password

  click_button 'Sign in'
end

Then /^a deploy user should exist for "([^"]*)"$/ do |subdomain|
  User.find_by_email("#{subdomain}@minege.ms").should_not be_nil
end

# Domains

Then /^I should be redirected to (.+) path$/ do |page_name|
  page.current_path.should == path_to(page_name)
end

Given /^A subdomain with "(.*)" tld$/ do |tld|
  Factory.create(:subdomain, :tld => tld)
end

Given /^I am authenticated as a "([^"]*)" member$/ do |tld|
  email, password = "email@person.com", "password"
  subdomain = Factory.create(:subdomain, :tld => tld)
  user      = create_user("#{email}/#{password}")
  user.confirm!
  subdomain.users << user
  subdomain.save

  visit new_user_session_url(:host => "#{tld}.#{$host}", :port => $port)
  fill_in 'Login',    :with => email
  fill_in 'Password', :with => password

  click_button 'Sign in'
end

# Session

Then /^I should be signed in$/ do
  pending
end

# Emails

Then /^a confirmation message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  sent = ActionMailer::Base.deliveries.first
  sent.to.should == [user.email]
  sent.subject.should match(/confirm/i)
  user.confirmation_token.should_not be_blank
  sent.body.should match(/#{user.confirmation_token}/)
end

When /^I follow the confirmation link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit user_confirmation_path(:user_id            => user,
                               :confirmation_token => user.confirmation_token)
end
