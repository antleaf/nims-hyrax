require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'hyrax/citations/work' do
  let(:publication) { build(:publication, :open, :with_alternative_title, :with_people, :with_keyword, :with_subject, :with_language,
                        :with_publisher, :with_complex_date, :with_complex_identifier, :with_rights_statement, :with_complex_rights,
                        :with_complex_version, :with_resource_type, :with_source, :with_issue, :with_complex_source, :with_complex_event,
                        :with_place, :with_table_of_contents, :with_number_of_pages,
                        doi: 'https://doi.org/10.5555/12345678',
                        creator: ['Asahiko Matsuda, Kosuke Tanabe']) }
  let(:ability) { double }
  let(:presenter) { Hyrax::PublicationPresenter.new(SolrDocument.new(publication.to_solr), Ability.new(user), controller.request) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    login_as user if user.present?
    assign(:presenter, presenter)
    render
  end

  # NB: the visibility of individual metadata components is set in app/models/ability.rb
  # This test confirms the current expected behaviour (which is that most metadata is visible)

  context 'unauthenticated user' do
    let(:user) { nil }
    it 'shows the correct metadata' do
      expect(rendered).to have_content('Asahiko Matsuda, Kosuke Tanabe.')
      expect(rendered).to have_content("\"Open Publication\".\nTest journal. 3, no. 34. 1.2.2.\n(0528):")
      expect(rendered).to have_content('https://doi.org/10.5555/12345678')
    end
  end

  context 'authenticated NIMS Researcher' do
    let(:user) { create(:user, :nims_researcher) }
    it 'shows the correct metadata' do
      expect(rendered).to have_content('Asahiko Matsuda, Kosuke Tanabe.')
      expect(rendered).to have_content("\"Open Publication\".\nTest journal. 3, no. 34. 1.2.2.\n(0528):")
      expect(rendered).to have_content('https://doi.org/10.5555/12345678')
    end
  end
end