# Generated via
#  `rails generate hyrax:work Publication`
module Hyrax
  # Generated form for Publication
  class PublicationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Publication
    self.terms -= [
      # Fields not interested in
      :based_near, :contributor, :creator, :date_created, :identifier, :license,
      :rights_statement, :related_url, :source,
      # Fields interested in, but removing to re-order
      :title, :description, :keyword, :language, :publisher, :resource_type,
      :subject
      # Fields that are not displayed
      # :import_url, :date_modified, :date_uploaded, :depositor, :bibliographic_citation,
      # :date_created, :label, :relative_path
    ]

    self.terms += [
      # Adding all fields in order of display in form
      :first_published_url, :supervisor_approval,
      :title, :alternative_title, :complex_person, :description, :keyword,
      :publisher, :resource_type, :complex_rights,
      :complex_date, :complex_identifier, :complex_source, :complex_version,
      :complex_event, :language
    ]

    self.required_fields -= [
      # Fields not interested in
      :creator, :keyword, :rights_statement,
      # Fields interested in, but removing to re-order
      :title]

    self.required_fields += [
      # Adding all required fields in order of display in form
      :supervisor_approval, :title, :resource_type,
      :description, :keyword
    ]

    NESTED_ASSOCIATIONS = [:complex_date, :complex_identifier,
      :complex_person, :complex_rights, :complex_version, :complex_event, :complex_source].freeze

    protected

    def self.permitted_affiliation_params
      [:id,
       :_destroy,
       {
         job_title: [],
         complex_organization_attributes: permitted_organization_params,
       }
      ]
    end

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

    def self.permitted_organization_params
      [:id,
       :_destroy,
       {
         organization: [],
         sub_organization: [],
         purpose: [],
         complex_identifier_attributes: permitted_identifier_params,
       }
      ]
    end

    def self.permitted_person_params
      [:id,
       :_destroy,
       {
         last_name: [],
         first_name: [],
         name: [],
         role: [],
         orcid: [],
         organization: [],
         sub_organization: [],
         complex_affiliation_attributes: permitted_affiliation_params,
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

    def self.permitted_event_params
      [:id,
       :_destroy,
       {
         title: [],
         place: [],
         start_date: [],
         end_date: [],
         invitation_status: []
       }
      ]
    end

    def self.permitted_source_params
      [:id,
       :_destroy,
       {
         alternative_title: [],
         end_page: [],
         issue: [],
         sequence_number: [],
         start_page: [],
         title: [],
         total_number_of_pages: [],
         volume: []
       }
      ]
    end

    def self.build_permitted_params
      permitted = super
      permitted << { complex_date_attributes: permitted_date_params }
      permitted << { complex_identifier_attributes: permitted_identifier_params }
      permitted << { complex_person_attributes: permitted_person_params }
      permitted << { complex_rights_attributes: permitted_rights_params }
      permitted << { complex_version_attributes: permitted_version_params }
      permitted << { complex_event_attributes: permitted_event_params }
      permitted << { complex_source_attributes: permitted_source_params }
      permitted << :member_of_collection_ids
      permitted << :find_child_work
    end
  end
end
