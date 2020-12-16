include Warden::Test::Helpers

Given(/^an? (guest|email|nims_other|nims_researcher|admin) user$/) do |user_type|
  @user = FactoryBot.create(:user, user_type.to_sym)
end

Given(/^I am logged in$/) do
  login_as @user
end

Given(/^I am logged in as an? (guest|email|nims_other|nims_researcher|admin) user$/) do |user_type|
  step "a #{user_type} user"
  step 'I am logged in'
end

Given(/^there (?:are|is) (\d+) (guest|email|nims_other|nims_researcher|admin) users?$/) do |number, user_type|
  @users ||= {}
  @users[user_type] = FactoryBot.create_list(:user, number, user_type.to_sym)
end

When(/^I navigate to the users list$/) do
  visit hyrax.users_path
end

Then(/^I should see the (guest|email|nims_other|nims_researcher|admin) users?$/) do |user_type|
  # first, verify @users is present and has some data
  expect(@users[user_type]).to be_present

  # next, verify there is a link to each dataset (using a regular expression to allow for the locale parameter)
  @users[user_type].each do |user|
    expect(page).to have_link(user.username, href: Regexp.new(hyrax.user_path(user)))
  end
end

Then(/^I should not see the (guest|nims_other|nims_researcher|admin) users?$/) do |user_type|
  # first, verify @users is present and has some data
  expect(@users[user_type]).to be_present

  # next, verify there is a link to each dataset (using a regular expression to allow for the locale parameter)
  @users[user_type].each do |user|
    expect(page).to_not have_link(user.username, href: Regexp.new(hyrax.user_path(user)))
  end
end

Then(/^I should be redirected to the login page$/) do
  expect(current_path).to eql(new_user_session_path)
end

Then(/^I should be redirected to the home page$/) do
  expect(current_path).to eql(root_path)
end
