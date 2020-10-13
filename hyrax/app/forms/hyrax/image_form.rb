# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  # Generated form for Image
  class ImageForm < Hyrax::Forms::WorkForm
    self.model_class = ::Image

    self.terms -= [
      # Fields not interested in
      :based_near, :contributor, :creator, :date_created, :identifier, :license,
      :related_url, :source,
      # Fields interested in, but removing to re-order
      :title, :description, :keyword, :language, :publisher, :resource_type, :subject
      # Fields that are not displayed
      # :import_url, :date_modified, :date_uploaded, :depositor, :bibliographic_citation,
      # :date_created, :label, :relative_path
    ]

    self.terms += [
      # Adding all fields in order of display in form
      :title, :alternative_title, :description, :keyword, :language,
      :publisher, :resource_type, :subject,
      :complex_date, :complex_identifier, :complex_person, :complex_version,
      :status, :instrument, :specimen_set, :complex_relation, :custom_property
    ]

    self.required_fields -= [
      # Fields not interested in
      :creator, :keyword,
      # Fields interested in, but removing to re-order
      :title]

    self.required_fields += [
      # # Adding all required fields in order of display in form
      :title
    ]

    NESTED_ASSOCIATIONS = [:complex_date, :complex_identifier, :complex_person,
      :complex_version, :complex_relation, :custom_property].freeze

    protected

    def self.permitted_date_params
      [:id,
       :_destroy,
       {
         date: [],
         description: []
       }
      ]
    end

    def self.permitted_identifier_params
      [:id,
       :_destroy,
       {
         identifier: [],
         scheme: [],
         label: []
       }
      ]
    end

    def self.permitted_person_params
      [:id,
       :_destroy,
       {
         name: [],
         role: [],
         affiliation: [],
         complex_identifier_attributes: permitted_identifier_params,
         uri: []
       }
      ]
    end

    def self.permitted_rights_params
      [:id,
       :_destroy,
       {
         date: [],
         rights: []
       }
      ]
    end

    def self.permitted_version_params
      [:id,
       :_destroy,
       {
         date: [],
         description: [],
         identifier: [],
         version: []
       }
      ]
    end

    def self.permitted_relation_params
      [:id,
       :_destroy,
       {
         title: [],
         url: [],
         complex_identifier_attributes: permitted_identifier_params,
         relationship: []
       }
      ]
    end

    def self.permitted_custom_property_params
      [:id,
       :_destroy,
       {
         label: [],
         description: []
       }
      ]
    end

    def self.build_permitted_params
      permitted = super
      permitted << { complex_date_attributes: permitted_date_params }
      permitted << { complex_identifier_attributes: permitted_identifier_params }
      permitted << { complex_person_attributes: permitted_person_params }
      permitted << { complex_version_attributes: permitted_version_params }
      permitted << { complex_relation_attributes: permitted_relation_params }
      permitted << { custom_property_attributes: permitted_custom_property_params }
    end

  end
end
