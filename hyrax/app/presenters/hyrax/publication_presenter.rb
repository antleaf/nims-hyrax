# Generated via
#  `rails generate hyrax:work Publication`
module Hyrax
  class PublicationPresenter < Hyrax::WorkShowPresenter
    delegate :alternative_title, :complex_date, :complex_identifier, :complex_person,
             :complex_rights, :complex_version, :complex_event, :issue, :place,
             :table_of_contents, :total_number_of_pages, :complex_source,
             :first_published_url, :doi, :licensed_date, :creator, to: :solr_document

    Hyrax::MemberPresenterFactory.file_presenter_class = Hyrax::NimsFileSetPresenter
    prepend ::FilteredGraph
  end
end
