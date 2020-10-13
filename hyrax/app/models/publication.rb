require './lib/vocabularies/escidoc_publication'

class Publication < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = PublicationIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your publication must have a title.' }

  # property date_modified - defined in core metadata
  # property date_uploaded - defined in core metadata
  # property depositor - defined in core metadata
  # property title - defined in core metadata
  # property based_near - defined in the basic metadata
  # property bibliographic_citation - defined in the basic metadata
  # property contributor - defined in the basic metadata
  # property creator - defined in the basic metadata
  # property date_created - defined in the basic metadata
  # property description - defined in the basic metadata
  # property identifier - defined in the basic metadata
  # property import_url - defined in the basic metadata
  # property keyword - defined in the basic metadata
  # property label - defined in the basic metadata
  # property language - defined in the basic metadata
  # property publisher - defined in the basic metadata
  # property related_url - defined in the basic metadata
  # property relative_path - defined in the basic metadata
  # property resource_type - defined in the basic metadata
  # property license (rights) - defined in the basic metadata
  # property rights_statement - defined in the basic metadata
  # property source - defined in the basic metadata
  # property subject - defined in the basic metadata


  # NOTE: Not a part of Hyrax basic metadata
  # Not defining this field. It raises RSolr::Error::ConnectionRefused when added to index.
  # property :part_of, predicate: ::RDF::Vocab::DC.isPartOf do |index|
  #   index.as :stored_searchable
  # end

  # Required due to bug saving nested resources
  property :updated_subresources, predicate: ::RDF::URI.new('http://example.com/updatedSubresources'), class_name: "ActiveTriples::Resource"

  # NGDR Hyrax Work Common
  property :alternative_title, predicate: ::RDF::Vocab::DC.alternative, multiple: false do |index|
    index.as :stored_searchable
  end

  property :complex_date, predicate: ::RDF::Vocab::DC.date, class_name: 'ComplexDate'

  property :complex_identifier, predicate: ::RDF::Vocab::NimsRdp.identifier, class_name: 'ComplexIdentifier'

  property :complex_person, predicate: ::RDF::Vocab::SIOC.has_creator, class_name: 'ComplexPerson'

  # TODO: Need more information
  # property :complex_license, predicate: ::RDF::URI.new('http://www.niso.org/schemas/ali/1.0/license_ref'), class_name:'ComplexLicense'

  property :complex_rights, predicate: ::RDF::Vocab::DC11.rights, class_name: 'ComplexRights'

  property :complex_version, predicate: ::RDF::Vocab::NimsRdp.version, class_name: 'ComplexVersion'

  # NGDR Hyrax Work Publication MVP
  # Note: all date fields are covered by complex_date in Hyrax Work Common above

  property :complex_event, predicate: ::RDF::Vocab::ESciDocPublication.event, class_name: 'ComplexEvent'

  property :issue, predicate: ::RDF::Vocab::ESciDocPublication.issue, multiple: false do |index|
    index.as :stored_searchable
  end

  property :place, predicate: ::RDF::Vocab::ESciDocPublication.place, multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :table_of_contents, predicate: ::RDF::Vocab::DC.tableOfContents, multiple: false do |index|
    index.as :stored_searchable
  end

  property :total_number_of_pages, predicate: ::RDF::Vocab::ESciDocPublication['total-number-of-pages'], multiple: false do |index|
    index.as :stored_searchable, :sortable, type: :integer
  end

  property :complex_source, predicate: ::RDF::Vocab::ESciDocPublication.source, class_name: 'ComplexSource'

  property :supervisor_approval, predicate: ::RDF::Vocab::NimsRdp['supervisor-approval']

  property :first_published_url, predicate: ::RDF::Vocab::NimsRdp['first_published_url'], multiple: false do |index|
    index.as :stored_searchable
  end

  property :doi, predicate: ::RDF::Vocab::Identifiers.doi, multiple: false do |index|
    index.as :stored_searchable
  end

  property :licensed_date, predicate: ::RDF::Vocab::NimsRdp['licenced-date'], multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :specimen_set, predicate: ::RDF::Vocab::NimsRdp['specimen-set'] do |index|
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
  include ComplexValidation
  accepts_nested_attributes_for :complex_date, reject_if: :date_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_identifier, reject_if: :identifier_blank, allow_destroy: true
  # accepts_nested_attributes_for :complex_license, reject_if: :license_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_person, reject_if: :person_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_rights, reject_if: :rights_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_version, reject_if: :version_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_event, reject_if: :event_blank, allow_destroy: true
  accepts_nested_attributes_for :complex_source, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :updated_subresources, allow_destroy: true
end
