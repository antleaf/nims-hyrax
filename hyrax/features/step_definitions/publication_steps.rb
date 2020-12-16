Given(/^there (?:are|is) (\d+) (open|authenticated|embargo|lease|restricted) publications?$/) do |number, access|
  @publications ||= {}
  @publications[access] = FactoryBot.create_list(:publication, number, access.to_sym, :with_source, :with_complex_author).each do |obj|
    ActiveFedora::SolrService.add(obj.to_solr)
  end
  ActiveFedora::SolrService.commit
end

Given(/^there is a publication with:$/) do |table|
  @publication = FactoryBot.create(:publication, *table.rows.flatten.map(&:to_sym))
  ActiveFedora::SolrService.add(@publication.to_solr)
  ActiveFedora::SolrService.commit
end

Given(/^I am on the publication page$/) do
  visit hyrax_publication_path(@publication)
end

When(/^I navigate to the new publication page$/) do
  visit hyrax.dashboard_path  # /dashboard
  click_link "Works"
  click_link "Add new work"

  # If you generate more than one work uncomment these lines
  choose "payload_concern", option: "Publication"
  click_button "Create work"

  # small hack to skip to create publication page without requiring javascript
  visit new_hyrax_publication_path
end

When /^I try to navigate to the new publication page$/ do
  visit new_hyrax_publication_path
end

When(/^I navigate to the publication catalog page$/) do
  visit root_path
  click_link 'Browse all publications'
  # visit search_catalog_path('f[human_readable_type_sim][]' => 'Publication')
end

When(/^I create the publication with:$/) do |table|
  values = table.hashes.first # table is a table.hashes.keys # => [:TITLE, :SUPERVISOR, :DATA_ORIGIN, :CREATOR, :KEYWORD]

  expect(page).to have_content /Add New Publication/i

  click_link "Files" # switch tab
  expect(page).to have_content /Add files/i
  expect(page).to have_content /Add folder/i
  within('span#addfiles') do
    attach_file("files[]", File.join(fixture_path, 'image.jp2'), visible: false)
    attach_file("files[]", File.join(fixture_path, 'jp2_fits.xml'), visible: false)
  end

  click_link "Descriptions" # switch tab
  fill_in('Title', with: values[:TITLE])
  fill_in('Supervisor', with: values[:SUPERVISOR])
  select(values[:DATA_ORIGIN], from: 'Data origin')
  fill_in('publication[complex_person_attributes][0][name][]', with: values[:CREATOR])
  fill_in('Keyword', with: values[:KEYWORD])
  select('Creative Commons BY-SA Attribution-ShareAlike 4.0 International', from: 'publication[complex_rights_attributes][0][rights][]')

  # With selenium and the chrome driver, focus remains on the
  # select box. Click outside the box so the next line can't find
  # its element
  find('body').click
  choose('publication_visibility_open')
  expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
  check('agreement')

  click_on('Save')

  expect(page).to have_content(values[:TITLE])
end

Then(/^I should see the (open|authenticated|embargo|lease|restricted) publications?$/) do |access|
  # first, verify @publications is present and has some data
  expect(@publications[access]).to be_present

  # next, verify there is a link to each publication (using a regular expression to allow for the locale parameter)
  @publications[access].each do |publication|
    expect(page).to have_link(publication.title.first, href: Regexp.new(hyrax_publication_path(publication)))
  end
end

Then(/^I should not see the (open|authenticated|embargo|lease|restricted) publications?$/) do |access|
  # first, verify @publications is present and has some data
  expect(@publications[access]).to be_present

  # next, verify there is a link to each publication (using a regular expression to allow for the locale parameter)
  @publications[access].each do |publication|
    expect(page).to_not have_link(publication.title.first, href: Regexp.new(hyrax_publication_path(publication)))
  end
end

Then(/^I should see only the public metadata of the (open|authenticated|embargo|lease|restricted) publications?$/) do |access|
  # first, verify @publications is present and has some data
  expect(@publications[access]).to be_present

  @publications[access].each do |publication|
    # check public metadata is visible
    [:subject, :keyword].each do |field|
      expect(page).to have_css('div.metadata dl dt', text: Regexp.new(field.to_s, Regexp::IGNORECASE))
      expect(page).to have_css('div.metadata dl dd', text: publication.send(field).first)
    end

    # check restricted metadata is not visible
    [:description].each do |field|
      expect(page).not_to have_css('div.metadata dl dt', text: Regexp.new(field.to_s, Regexp::IGNORECASE))
      expect(page).not_to have_css('div.metadata dl dd', text: publication.send(field).first)
    end
  end
end

Then(/^I should see both the public and restricted metadata of the (open|authenticated|embargo|lease|restricted) publications?$/) do |access|
  # first, verify @publications is present and has some data
  expect(@publications[access]).to be_present

  @publications[access].each do |publication|
    # check public and restricted metadata is visible
    [:description, :subject, :keyword].each do |field|
      expect(page).to have_css('div.metadata dl dt', text: Regexp.new(field.to_s, Regexp::IGNORECASE))
      expect(page).to have_css('div.metadata dl dd', text: publication.send(field).first)
    end
  end
end

Then(/^I should see the following links to publications:$/) do |table|
  table.symbolic_hashes.each do |row|
    expect(page).to have_link(row[:label], href: Regexp.new(Regexp.quote(row[:href])))
  end
end

When(/^I navigate to the (open|authenticated|embargo|lease|restricted) publication page$/) do |access|
  visit polymorphic_path(@publications[access].first)
end

Then(/^I should access the (open|authenticated|embargo|lease|restricted) publication$/) do |access|
  expect(page).to have_content("#{access.capitalize} Publication")
  expect(page).not_to have_content('Unauthorized')
end

Then(/^I should not access the (open|authenticated|embargo|lease|restricted) publication$/) do |access|
  expect(page).not_to have_content("#{access.capitalize} Publication")
  expect(page).to have_content('Unauthorized')
end
