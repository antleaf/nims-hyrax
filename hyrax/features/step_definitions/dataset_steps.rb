Given(/^there (?:are|is) (\d+) (open|authenticated|embargo|lease|restricted) datasets?$/) do |number, access|
  @datasets ||= {}
  @datasets[access] = FactoryBot.create_list(:dataset, number, access.to_sym, :with_description_seq, :with_keyword_seq, :with_subject_seq).each do |obj|
    ActiveFedora::SolrService.add(obj.to_solr)
  end
  ActiveFedora::SolrService.commit
end

Given(/^there is a dataset with:$/) do |table|
  @dataset = FactoryBot.create(:dataset, *table.rows.flatten.map(&:to_sym))
  ActiveFedora::SolrService.add(@dataset.to_solr)
  ActiveFedora::SolrService.commit
end

Given(/^I am on the dataset page$/) do
  visit hyrax_dataset_path(@dataset)
end

When(/^I navigate to the new dataset page$/) do
  visit hyrax.dashboard_path  # /dashboard
  click_link "Works"
  click_link "Add new work"

  # If you generate more than one work uncomment these lines
  choose "payload_concern", option: "Dataset"
  click_button "Create work"

  # small hack to skip to create dataset page without requiring javascript
  visit new_hyrax_dataset_path
end

When /^I try to navigate to the new dataset page$/ do
  visit new_hyrax_dataset_path
end

When(/^I navigate to the dataset catalog page$/) do
  visit root_path
  click_link 'Browse all datasets'
  # visit search_catalog_path('f[human_readable_type_sim][]' => 'Dataset')
end

When(/^I create the dataset with:$/) do |table|
  values = table.hashes.first # table is a table.hashes.keys # => [:TITLE, :SUPERVISOR, :DATA_ORIGIN, :CREATOR, :KEYWORD]

  expect(page).to have_content /Add New Dataset/i

  click_link "Files" # switch tab
  expect(page).to have_content /Add files/i
  expect(page).to have_content /Add folder/i
  within('span#addfiles') do
    attach_file("files[]", File.join(fixture_path,  'image.jp2'), visible: false)
    attach_file("files[]", File.join(fixture_path, 'jp2_fits.xml'), visible: false)
  end

  click_link "Descriptions" # switch tab
  fill_in('Title', with: values[:TITLE])
  fill_in('Supervisor', with: values[:SUPERVISOR])
  select(values[:DATA_ORIGIN], from: 'Data origin')
  fill_in('dataset[complex_person_attributes][0][name][]', with: values[:CREATOR])
  fill_in('Keyword', with: values[:KEYWORD])
  select('Creative Commons BY-SA Attribution-ShareAlike 4.0 International', from: 'dataset[complex_rights_attributes][0][rights][]')

  # With selenium and the chrome driver, focus remains on the
  # select box. Click outside the box so the next line can't find
  # its element
  find('body').click
  choose('dataset_visibility_open')
  expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
  check('agreement')

  click_on('Save')

  expect(page).to have_content(values[:TITLE])
end

Then(/^I should see the (open|authenticated|embargo|lease|restricted) datasets?$/) do |access|
  # first, verify @datasets is present and has some data
  expect(@datasets[access]).to be_present

  # next, verify there is a link to each dataset (using a regular expression to allow for the locale parameter)
  @datasets[access].each do |dataset|
    expect(page).to have_link(dataset.title.first, href: Regexp.new(hyrax_dataset_path(dataset)))
  end
end

Then(/^I should not see the (open|authenticated|embargo|lease|restricted) datasets?$/) do |access|
  # first, verify @datasets is present and has some data
  expect(@datasets[access]).to be_present

  # next, verify there is a link to each dataset (using a regular expression to allow for the locale parameter)
  @datasets[access].each do |dataset|
    expect(page).to_not have_link(dataset.title.first, href: Regexp.new(hyrax_dataset_path(dataset)))
  end
end

Then(/^I should see only the public metadata of the (open|authenticated|embargo|lease|restricted) datasets?$/) do |access|
  # first, verify @datasets is present and has some data
  expect(@datasets[access]).to be_present

  @datasets[access].each do |dataset|
    # check public metadata is visible
    [:subject, :keyword].each do |field|
      expect(page).to have_css('div.metadata dl dt', text: Regexp.new(field.to_s, Regexp::IGNORECASE))
      expect(page).to have_css('div.metadata dl dd', text: dataset.send(field).first)
    end

    # check restricted metadata is not visible
    [:description].each do |field|
      expect(page).not_to have_css('div.metadata dl dt', text: Regexp.new(field.to_s, Regexp::IGNORECASE))
      expect(page).not_to have_css('div.metadata dl dd', text: dataset.send(field).first)
    end
  end
end

Then(/^I should see both the public and restricted metadata of the (open|authenticated|embargo|lease|restricted) datasets?$/) do |access|
  # first, verify @datasets is present and has some data
  expect(@datasets[access]).to be_present

  @datasets[access].each do |dataset|
    # check public and restricted metadata is visible
    [:description, :subject, :keyword].each do |field|
      expect(page).to have_css('div.metadata dl dt', text: Regexp.new(field.to_s, Regexp::IGNORECASE))
      expect(page).to have_css('div.metadata dl dd', text: dataset.send(field).first)
    end
  end
end

Then(/^I should see the following links to datasets:$/) do |table|
  table.symbolic_hashes.each do |row|
    expect(page).to have_link(row[:label], href: Regexp.new(Regexp.quote(row[:href])))
  end
end

When("I try to navigate to the dashboard page") do
  visit hyrax.dashboard_path
end

Then("I should be redirected to the top page") do
  expect(current_path).to eql(root_path)
end

When(/^I navigate to the (open|authenticated|embargo|lease|restricted) dataset page$/) do |access|
  visit polymorphic_path(@datasets[access].first)
end

Then(/^I should access the (open|authenticated|embargo|lease|restricted) dataset$/) do |access|
  expect(page).to have_content("#{access.capitalize} Dataset")
  expect(page).not_to have_content('Unauthorized')
end

Then(/^I should not access the (open|authenticated|embargo|lease|restricted) dataset$/) do |access|
  expect(page).not_to have_content("#{access.capitalize} Dataset")
  expect(page).to have_content('Unauthorized')
end
