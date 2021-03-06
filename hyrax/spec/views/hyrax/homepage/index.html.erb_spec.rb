require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'hyrax/homepage/index.html.erb', type: :view do
  let(:search_state) { double(has_facet?: false, add_facet_params_and_redirect: { controller: 'catalog' }) }
  let(:page) { Capybara::Node::Simple.new(rendered) }
  let(:presenter) do
    instance_double(Hyrax::HomepagePresenter,
                    create_work_presenter: type_presenter,
                    create_many_work_types?: true,
                    draw_select_work_modal?: true)
  end
  let(:type_presenter) { instance_double(Hyrax::SelectTypeListPresenter) }

  before do
    allow(view).to receive(:current_search_parameters).and_return(nil)
    allow(view).to receive(:current_user).and_return(nil)
    assign(:presenter, presenter)
    assign(:featured_work_list, [])
    assign(:featured_researcher, ContentBlock.featured_researcher)
    stub_template 'shared/_select_work_type_modal.html.erb' => 'modal'
    stub_template "hyrax/homepage/_marketing.html.erb" => "marketing"
    stub_template "hyrax/homepage/_home_content.html.erb" => "home content"
    stub_template "_controls.html.erb" => "controls"
    stub_template "_masthead.html.erb" => "masthead"
    without_partial_double_verification {
      allow(view).to receive(:search_state).and_return(search_state)
      allow(presenter).to receive(:display_share_button?).and_return(true)
    }
  end

  it "shows the product's full name" do
    render template: 'hyrax/homepage/index', layout: 'layouts/homepage'
    expect(page).to have_title 'MDR: NIMS Materials Data Repository'
  end

  it "shows its full name in the default locale" do
    view.locale = :ja
    render template: 'hyrax/homepage/index', layout: 'layouts/homepage'
    expect(page).to have_title 'MDR: NIMS Materials Data Repository'
  end

  it 'renders twitter meta tags' do
    render template: 'hyrax/homepage/index', layout: 'layouts/homepage'
    expect(rendered).to have_css('meta[name="twitter:card"][content="product"]', visible: false )
    expect(rendered).to have_css('meta[name="twitter:site"][content="@nims_library"]', visible: false )
    expect(rendered).to have_css('meta[name="twitter:image"][content="http://test.host/assets/mdr-ogp-stacked-685ef3f1e803827523976360c6500d991e9eddf54890380c26867e21595946f1.png"]', visible: false )
    expect(rendered).to have_css('meta[property="og:url"][content="http://test.host/"]', visible: false )
    expect(rendered).to have_css('meta[property="og:image"][content="http://test.host/assets/mdr-ogp-linear-ca0cb54aaafa68d02aa9bc0dc81bbb2dce71fd20a5af5fb21c939655e01617bc.png"]', visible: false )
  end
end
