# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyrax::WorkShowPresenter
    delegate :alternative_title, :complex_date, :complex_identifier, :complex_person,
      :complex_rights, :complex_version, :status, :specimen_set, :instrument,
      :complex_relation, :custom_property, :licensed_date, to: :solr_document

    Hyrax::MemberPresenterFactory.file_presenter_class = Hyrax::NimsFileSetPresenter
    prepend ::FilteredGraph
  end
end
